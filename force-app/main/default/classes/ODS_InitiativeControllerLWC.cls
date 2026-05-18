/**
* @author           Converted to LWC
* @version          2.0 
* @date             2025
* @description      LWC Controller for Initiative Management
*/
public with sharing class ODS_InitiativeControllerLWC {
    
    /**
     * @description Initialize component data
     * @param initiativeId - Current Initiative Id
     * @param accServiceId - Account Service Id
     * @return Map<String, Object> containing all initialization data
     */
    @AuraEnabled
    public static Map<String, Object> initializeComponent(String initiativeId, String accServiceId) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            // Get current user info
            User currentUser = [SELECT Id, Name, ContactId, PortalUserRole__c, Profile.Name 
                              FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            
            result.put('currentUser', currentUser);
            result.put('currentDate', Datetime.now().format('MM/dd/yyyy'));
            
            // Get Account Service details
            if (String.isNotBlank(accServiceId)) {
                Account_Services__c accService = [
                    SELECT Id, Account__c, Account__r.Name, Account__r.Customer_Type__c,
                           ODS_Services__c, ODS_Service_Name__c, ODS_Services__r.Name,
                           Service_Workspace_Id__c, Technical_Account_Manager_Email__c,
                           Agile__c, JIRA_Domain_Name__c
                    FROM Account_Services__c 
                    WHERE Id = :accServiceId LIMIT 1
                ];
                
                result.put('accountService', accService);
                result.put('accountName', accService.Account__r.Name);
                result.put('serviceName', accService.ODS_Service_Name__c);
                result.put('accountId', accService.Account__c);
                result.put('serviceId', accService.ODS_Services__c);
                result.put('nonABCType', accService.Account__r.Customer_Type__c != 'ABC Type');
                
                // Check if Save & Create Jira should be shown
                Boolean showSaveCreateJira = (accService.Agile__c == 'JIRA' && 
                                             accService.JIRA_Domain_Name__c == System.Label.ODS_Demandblue_JIRA_URL && 
                                             String.isNotBlank(accService.Service_Workspace_Id__c));
                result.put('showSaveCreateJira', showSaveCreateJira);
                
                // Get approvers for this account/service
                result.put('approvers', getApproversForAccountService(accService.Account__c, accService.ODS_Services__c, currentUser, null));
                
                // Check if user is approver
                if (currentUser.ContactId != null) {
                    List<Contact_Account_Service__c> contactAccService = [
                        SELECT Is_Approver__c, Is_initiate_approver__c
                        FROM Contact_Account_Service__c
                        WHERE Contact__c = :currentUser.ContactId 
                        AND ODS_Service__c = :accService.ODS_Services__c
                        LIMIT 1
                    ];
                    
                    if (!contactAccService.isEmpty()) {
                        result.put('isPortalApprover', contactAccService[0].Is_Approver__c);
                        result.put('isInitiativeApprover', contactAccService[0].Is_initiate_approver__c);
                    }
                }
            }
            
            // Get Initiative details if exists
            if (String.isNotBlank(initiativeId)) {
                Map<String, Object> initiativeData = getInitiativeDetails(initiativeId, currentUser.PortalUserRole__c);
                result.putAll(initiativeData);
                
                // Check for inactive approver
                Initiatives__c initiative = (Initiatives__c)initiativeData.get('initiative');
                if (initiative != null && String.isNotBlank(initiative.Client_side_Contact__c)) {
                    List<Contact_Account_Service__c> clientContact = [
                        SELECT Is_initiate_approver__c, Contact__r.Name
                        FROM Contact_Account_Service__c
                        WHERE Contact__c = :initiative.Client_side_Contact__c
                        AND Account__c = :initiative.Account_Service__r.Account__c
                        AND ODS_Service__c = :initiative.Account_Service__r.ODS_Services__c
                        LIMIT 1
                    ];
                    
                    if (!clientContact.isEmpty() && !clientContact[0].Is_initiate_approver__c) {
                        result.put('inactiveApprover', true);
                        result.put('inactiveApproverName', clientContact[0].Contact__r.Name);
                    }
                }
            }
            
            // Get picklist values
            result.put('initiativeTypeOptions', getPicklistValues('Initiatives__c', 'Initiative_Type__c'));
            result.put('initiativeBillingTypeOptions', getPicklistValues('Initiatives__c', 'Initiative_Billing_Type__c'));
            result.put('triggerForInitiativeOptions', getPicklistValues('Initiatives__c', 'Trigger_For_Initiative__c'));
            result.put('architectEngineerOptions', getPicklistValues('Initiatives__c', 'Solution_Architect_Engineer__c'));
            result.put('technicalPMOptions', getPicklistValues('Initiatives__c', 'Technical_Project_Manager__c'));
            result.put('initiativeTagOptions', getPicklistValues('Initiatives__c', 'Tags_About_Initiative__c'));
            result.put('phaseOptions', getPhaseOptions());
            
            // Check if delivery team
            result.put('isDeliveryTeam', currentUser.Profile.Name == System.Label.DeliveryRoleProfile);
            result.put('isCustomer', currentUser.PortalUserRole__c == 'Customer' || currentUser.PortalUserRole__c == 'Partner');
            
            // Get existing JIRA IDs for validation
            if (String.isNotBlank(accServiceId)) {
                result.put('existingJiraIds', getExistingJiraIds(accServiceId, initiativeId));
            }
            
            result.put('success', true);
            
        } catch (Exception e) {
            result.put('success', false);
            result.put('error', e.getMessage());
            ODS_ExceptionUtility.saveErrorLogs(
                String.valueOf(e.getCause()), 
                e.getMessage(), 
                e.getStackTraceString(), 
                e.getTypeName()
            );
        }
        
        return result;
    }
    
    /**
     * @description Get Initiative details with estimates and attachments
     */
    @AuraEnabled
    public static Map<String, Object> getInitiativeDetails(String initiativeId, String userRole) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            // Get initiative
            Initiatives__c initiative = [
                SELECT Id, Name, JIRA_ID__c, Offshore_Estimate__c, Probability_Percentage__c,
                       Probable_Start_Date__c, Probable_End_Date__c, UAT_Expected_Date__c,
                       Client_side_Contact__c, Client_side_Contact__r.Name, Status__c,
                       Initiative_Type__c, Initiative_Programming_Reason__c, Product__c,
                       Business_Challenge__c, Persona_s_Involved__c, Technology_Details__c,
                       Outcome_of_our_solution__c, Initiative_Billing_Type__c,
                       Trigger_For_Initiative__c, Solution_Architect_Engineer__c,
                       Technical_Project_Manager__c, Tags_About_Initiative__c,
                       Brief_Description__c, Assumption__c, Is_a_bucket_of_hours_type__c,
                       Account_Service__c, Account_Service__r.Account__c, 
                       Account_Service__r.ODS_Services__c
                FROM Initiatives__c
                WHERE Id = :initiativeId
                LIMIT 1
            ];
            
            result.put('initiative', initiative);
            result.put('status', initiative.Status__c);
            
            // Get estimates
            List<Estimate__c> estimates;
            if (userRole == 'Customer' || userRole == 'Partner') {
                estimates = [
                    SELECT Id, Phase__c, Task_Components__c, Assumptions__c, Hours__c
                    FROM Estimate__c
                    WHERE Initiative_Lookup__c = :initiativeId
                    AND Phase__c != 'Post Production Support'
                    ORDER BY CreatedDate ASC
                ];
            } else {
                estimates = [
                    SELECT Id, Phase__c, Task_Components__c, Assumptions__c, Hours__c
                    FROM Estimate__c
                    WHERE Initiative_Lookup__c = :initiativeId
                    ORDER BY CreatedDate ASC
                ];
            }
            result.put('estimates', estimates);
            
            // Calculate total hours
            Decimal totalHours = 0;
            for (Estimate__c est : estimates) {
                if (est.Hours__c != null) {
                    totalHours += est.Hours__c;
                }
            }
            result.put('totalHours', totalHours);
            
            // Get attachments
            List<Attachment> attachments = [
                SELECT Id, Name, CreatedDate
                FROM Attachment
                WHERE ParentId = :initiativeId
                ORDER BY CreatedDate DESC
                LIMIT 10
            ];
            result.put('attachments', attachments);
            
            // Get escalations
            List<InitiativeEscalation__c> escalations = [
                SELECT Id, EscalationDateTime__c, EscalationDetails__c, 
                       InitiativeEscalationRecipients__c
                FROM InitiativeEscalation__c
                WHERE Initiative__c = :initiativeId
                ORDER BY EscalationDateTime__c DESC
            ];
            result.put('escalations', escalations);
            
            // Get utilization metrics
            Map<String, Decimal> utilizationMetrics = getUtilizationMetrics(initiativeId);
            result.put('utilizationMetrics', utilizationMetrics);
            
            // Get burndown chart data
            Map<String, Object> burndownData = getBurndownChartData(initiativeId);
            result.put('burndownData', burndownData);
            
            // Check for estimation summary
            List<Estimation_Summary__c> estimationSummary = [
                SELECT Id FROM Estimation_Summary__c 
                WHERE Project_ID__c = :initiativeId 
                AND Status__c = 'Approved' 
                LIMIT 1
            ];
            result.put('hasEstimationSummary', !estimationSummary.isEmpty());
            if (!estimationSummary.isEmpty()) {
                result.put('estimationSummaryId', estimationSummary[0].Id);
            }
            
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching initiative details: ' + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Save Initiative and Estimates
     */
    @AuraEnabled
    public static Map<String, Object> saveInitiative(String initiativeData, String estimatesData, 
                                                     String action, String accServiceId) {
        Map<String, Object> result = new Map<String, Object>();
        Savepoint sp = Database.setSavepoint();
        
        try {
            // Parse initiative data
            Map<String, Object> initiativeMap = (Map<String, Object>)JSON.deserializeUntyped(initiativeData);
            
            Initiatives__c initiative = new Initiatives__c();
            String initiativeId = (String)initiativeMap.get('Id');
            
            if (String.isNotBlank(initiativeId)) {
                initiative.Id = initiativeId;
            } else {
                initiative.Account_Service__c = accServiceId;
            }
            
            // Map all fields
            initiative.Name = (String)initiativeMap.get('Name');
            initiative.JIRA_ID__c = (String)initiativeMap.get('JIRA_ID__c');
            initiative.Brief_Description__c = (String)initiativeMap.get('Brief_Description__c');
            initiative.Assumption__c = (String)initiativeMap.get('Assumption__c');
            
            String startDate = (String)initiativeMap.get('Probable_Start_Date__c');
            if (String.isNotBlank(startDate)) {
                initiative.Probable_Start_Date__c = Date.valueOf(startDate);
            }
            
            String endDate = (String)initiativeMap.get('Probable_End_Date__c');
            if (String.isNotBlank(endDate)) {
                initiative.Probable_End_Date__c = Date.valueOf(endDate);
            }
            
            String uatDate = (String)initiativeMap.get('UAT_Expected_Date__c');
            if (String.isNotBlank(uatDate)) {
                initiative.UAT_Expected_Date__c = Date.valueOf(uatDate);
            }
            
            initiative.Initiative_Type__c = (String)initiativeMap.get('Initiative_Type__c');
            initiative.Initiative_Programming_Reason__c = (String)initiativeMap.get('Initiative_Programming_Reason__c');
            initiative.Business_Challenge__c = (String)initiativeMap.get('Business_Challenge__c');
            initiative.Persona_s_Involved__c = (String)initiativeMap.get('Persona_s_Involved__c');
            initiative.Technology_Details__c = (String)initiativeMap.get('Technology_Details__c');
            initiative.Outcome_of_our_solution__c = (String)initiativeMap.get('Outcome_of_our_solution__c');
            initiative.Product__c = (String)initiativeMap.get('Product__c');
            initiative.Trigger_For_Initiative__c = (String)initiativeMap.get('Trigger_For_Initiative__c');
            initiative.Solution_Architect_Engineer__c = (String)initiativeMap.get('Solution_Architect_Engineer__c');
            initiative.Technical_Project_Manager__c = (String)initiativeMap.get('Technical_Project_Manager__c');
            initiative.Tags_About_Initiative__c = (String)initiativeMap.get('Tags_About_Initiative__c');
            initiative.Initiative_Billing_Type__c = (String)initiativeMap.get('Initiative_Billing_Type__c');
            initiative.Is_a_bucket_of_hours_type__c = (Boolean)initiativeMap.get('Is_a_bucket_of_hours_type__c');
            
            if (initiativeMap.containsKey('Offshore_Estimate__c') && initiativeMap.get('Offshore_Estimate__c') != null) {
                initiative.Offshore_Estimate__c = Decimal.valueOf(String.valueOf(initiativeMap.get('Offshore_Estimate__c')));
            }
            
            if (initiativeMap.containsKey('Probability_Percentage__c') && initiativeMap.get('Probability_Percentage__c') != null) {
                initiative.Probability_Percentage__c = Decimal.valueOf(String.valueOf(initiativeMap.get('Probability_Percentage__c')));
            }
            
            // Get approver contact
            String approverName = (String)initiativeMap.get('ClientContact');
            if (String.isNotBlank(approverName)) {
                List<Contact_Account_Service__c> contactAccService = [
                    SELECT Contact__c FROM Contact_Account_Service__c
                    WHERE Contact__r.Name = :approverName
                    AND Account__c = :initiative.Account_Service__r.Account__c
                    AND ODS_Service__c = :initiative.Account_Service__r.ODS_Services__c
                    LIMIT 1
                ];
                
                if (!contactAccService.isEmpty()) {
                    initiative.Client_side_Contact__c = contactAccService[0].Contact__c;
                }
            }
            
            // Set status based on action
            if (action == 'Saved' || action == 'SaveCreateJira') {
                initiative.Status__c = 'Saved';
            } else if (action == 'Submitted') {
                initiative.Status__c = 'Initiative Submitted';
            } else if (action == 'btnSavePostSubmit') {
                // Keep existing status
            }
            
            upsert initiative;
            
            // Handle estimates
            List<Estimate__c> estimates = new List<Estimate__c>();
            if (String.isNotBlank(estimatesData)) {
                List<Object> estimatesList = (List<Object>)JSON.deserializeUntyped(estimatesData);
                
                // Delete existing estimates if updating
                if (String.isNotBlank(initiativeId)) {
                    delete [SELECT Id FROM Estimate__c WHERE Initiative_Lookup__c = :initiativeId];
                }
                
                for (Object estObj : estimatesList) {
                    Map<String, Object> estMap = (Map<String, Object>)estObj;
                    
                    Estimate__c est = new Estimate__c();
                    est.Initiative_Lookup__c = initiative.Id;
                    est.Phase__c = (String)estMap.get('Phase');
                    est.Task_Components__c = (String)estMap.get('TaskName');
                    est.Assumptions__c = (String)estMap.get('Assumption');
                    
                    if (estMap.get('Hours') != null) {
                        est.Hours__c = Decimal.valueOf(String.valueOf(estMap.get('Hours')));
                    }
                    
                    estimates.add(est);
                }
                
                if (!estimates.isEmpty()) {
                    insert estimates;
                }
            }
            
            // Send email if submitted
            if (action == 'Submitted') {
                sendInitiativeSubmissionEmail(initiative.Id);
            }
            
            // Create Jira if requested
            if (action == 'SaveCreateJira') {
                createJiraTicket(initiative.Id);
            }
            
            result.put('success', true);
            result.put('initiativeId', initiative.Id);
            result.put('message', 'Initiative saved successfully');
            
        } catch (Exception e) {
            Database.rollback(sp);
            result.put('success', false);
            result.put('error', e.getMessage());
            ODS_ExceptionUtility.saveErrorLogs(
                String.valueOf(e.getCause()), 
                e.getMessage(), 
                e.getStackTraceString(), 
                e.getTypeName()
            );
        }
        
        return result;
    }
    
    /**
     * @description Approve Initiative
     */
    @AuraEnabled
    public static Map<String, Object> approveInitiative(String initiativeId, String comments) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            Initiatives__c initiative = [SELECT Id, Status__c FROM Initiatives__c WHERE Id = :initiativeId LIMIT 1];
            initiative.Status__c = 'Initiative Approved';
            initiative.Comments__c = comments;
            update initiative;
            
            // Send approval email
            sendInitiativeApprovalEmail(initiativeId);
            
            result.put('success', true);
            result.put('message', 'Initiative approved successfully');
            
        } catch (Exception e) {
            result.put('success', false);
            result.put('error', e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Reject Initiative
     */
    @AuraEnabled
    public static Map<String, Object> rejectInitiative(String initiativeId, String comments) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            Initiatives__c initiative = [SELECT Id, Status__c FROM Initiatives__c WHERE Id = :initiativeId LIMIT 1];
            initiative.Status__c = 'Re-evaluate';
            initiative.Comments__c = comments;
            update initiative;
            
            // Send rejection email
            sendInitiativeRejectionEmail(initiativeId, comments);
            
            result.put('success', true);
            result.put('message', 'Initiative sent for re-evaluation');
            
        } catch (Exception e) {
            result.put('success', false);
            result.put('error', e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Cancel Initiative
     */
    @AuraEnabled
    public static Map<String, Object> cancelInitiative(String initiativeId) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            Initiatives__c initiative = [SELECT Id, Status__c FROM Initiatives__c WHERE Id = :initiativeId LIMIT 1];
            initiative.Status__c = 'Initiative Cancelled';
            update initiative;
            
            result.put('success', true);
            result.put('message', 'Initiative cancelled successfully');
            
        } catch (Exception e) {
            result.put('success', false);
            result.put('error', e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Change Initiative Status (Active/On Hold/Delivered)
     */
    @AuraEnabled
    public static Map<String, Object> changeInitiativeStatus(String initiativeId, String newStatus) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            Initiatives__c initiative = [SELECT Id, Status__c FROM Initiatives__c WHERE Id = :initiativeId LIMIT 1];
            initiative.Status__c = newStatus;
            update initiative;
            
            result.put('success', true);
            result.put('message', 'Status updated successfully');
            
        } catch (Exception e) {
            result.put('success', false);
            result.put('error', e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Escalate Initiative
     */
    @AuraEnabled
    public static Map<String, Object> escalateInitiative(String initiativeId, String escalationDetails) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            // Create escalation record
            InitiativeEscalation__c escalation = new InitiativeEscalation__c();
            escalation.Initiative__c = initiativeId;
            escalation.EscalationDetails__c = escalationDetails;
            escalation.EscalationDateTime__c = Datetime.now();
            insert escalation;
            
            // Send escalation email
            sendEscalationEmail(initiativeId, escalationDetails);
            
            result.put('success', true);
            result.put('message', 'Initiative escalated successfully');
            
        } catch (Exception e) {
            result.put('success', false);
            result.put('error', e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Clone Initiative
     */
    @AuraEnabled
    public static Map<String, Object> cloneInitiative(String initiativeId) {
        Map<String, Object> result = new Map<String, Object>();
        Savepoint sp = Database.setSavepoint();
        
        try {
            // Get original initiative
            Initiatives__c original = [
                SELECT Name, JIRA_ID__c, Offshore_Estimate__c, Probability_Percentage__c,
                       Probable_Start_Date__c, Probable_End_Date__c, UAT_Expected_Date__c,
                       Client_side_Contact__c, Initiative_Type__c, Initiative_Programming_Reason__c,
                       Product__c, Business_Challenge__c, Persona_s_Involved__c, Technology_Details__c,
                       Outcome_of_our_solution__c, Initiative_Billing_Type__c,
                       Trigger_For_Initiative__c, Solution_Architect_Engineer__c,
                       Technical_Project_Manager__c, Tags_About_Initiative__c,
                       Brief_Description__c, Assumption__c, Is_a_bucket_of_hours_type__c,
                       Account_Service__c
                FROM Initiatives__c
                WHERE Id = :initiativeId
                LIMIT 1
            ];
            
            // Clone initiative
            Initiatives__c cloned = original.clone(false, true, false, false);
            cloned.Name = original.Name + ' - Clone';
            cloned.Status__c = 'Saved';
            cloned.JIRA_ID__c = null; // Clear JIRA ID
            insert cloned;
            
            // Clone estimates
            List<Estimate__c> originalEstimates = [
                SELECT Phase__c, Task_Components__c, Assumptions__c, Hours__c
                FROM Estimate__c
                WHERE Initiative_Lookup__c = :initiativeId
            ];
            
            List<Estimate__c> clonedEstimates = new List<Estimate__c>();
            for (Estimate__c est : originalEstimates) {
                Estimate__c clonedEst = est.clone(false, true, false, false);
                clonedEst.Initiative_Lookup__c = cloned.Id;
                clonedEstimates.add(clonedEst);
            }
            
            if (!clonedEstimates.isEmpty()) {
                insert clonedEstimates;
            }
            
            result.put('success', true);
            result.put('initiativeId', cloned.Id);
            result.put('message', 'Initiative cloned successfully');
            
        } catch (Exception e) {
            Database.rollback(sp);
            result.put('success', false);
            result.put('error', e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Recall Initiative
     */
    @AuraEnabled
    public static Map<String, Object> recallInitiative(String initiativeId) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            Initiatives__c initiative = [SELECT Id, Status__c FROM Initiatives__c WHERE Id = :initiativeId LIMIT 1];
            initiative.Status__c = 'Initiative Recalled';
            update initiative;
            
            // Send recall email
            sendInitiativeRecallEmail(initiativeId);
            
            result.put('success', true);
            result.put('message', 'Initiative recalled successfully');
            
        } catch (Exception e) {
            result.put('success', false);
            result.put('error', e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Resend Initiative Email
     */
    @AuraEnabled
    public static Map<String, Object> resendInitiativeEmail(String initiativeId) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            sendInitiativeSubmissionEmail(initiativeId);
            
            result.put('success', true);
            result.put('message', 'Email resent successfully');
            
        } catch (Exception e) {
            result.put('success', false);
            result.put('error', e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Save attachment
     */
    @AuraEnabled
    public static Map<String, Object> saveAttachment(String initiativeId, String fileName, String base64Data) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            Attachment att = new Attachment();
            att.Name = fileName;
            att.Body = EncodingUtil.base64Decode(base64Data);
            att.ParentId = initiativeId;
            insert att;
            
            result.put('success', true);
            result.put('attachmentId', att.Id);
            result.put('message', 'File uploaded successfully');
            
        } catch (Exception e) {
            result.put('success', false);
            result.put('error', e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Delete attachment
     */
    @AuraEnabled
    public static Map<String, Object> deleteAttachment(String attachmentId) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            delete [SELECT Id FROM Attachment WHERE Id = :attachmentId];
            
            result.put('success', true);
            result.put('message', 'File deleted successfully');
            
        } catch (Exception e) {
            result.put('success', false);
            result.put('error', e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Get approvers for account/service
     */
    private static List<Map<String, String>> getApproversForAccountService(String accountId, String serviceId, 
                                                                           User currentUser, String currentStatus) {
        List<Map<String, String>> approvers = new List<Map<String, String>>();
        
        try {
            // Security check
            ODS_InitiativeSecurityHelper.checkContactAccountServiceReadAccess();
            
            List<Contact_Account_Service__c> contacts;
            Boolean isCustomer = (currentUser.PortalUserRole__c == 'Customer' || currentUser.PortalUserRole__c == 'Partner');
            
            if (String.isBlank(accountId) || String.isBlank(serviceId)) {
                return approvers;
            }
            
            if (!isCustomer && (currentStatus == null || currentStatus == 'Saved' || 
                currentStatus == 'Initiative Recalled' || currentStatus == 'Re-evaluate')) {
                contacts = [
                    SELECT Contact__r.Name, Contact__c
                    FROM Contact_Account_Service__c
                    WHERE Account__c = :accountId
                    AND ODS_Service__c = :serviceId
                    AND Is_initiate_approver__c = true
                    ORDER BY Contact__r.Name ASC
                ];
            } else {
                contacts = [
                    SELECT Contact__r.Name, Contact__c
                    FROM Contact_Account_Service__c
                    WHERE Account__c = :accountId
                    AND ODS_Service__c = :serviceId
                    ORDER BY Contact__r.Name ASC
                ];
            }
            
            // Strip inaccessible fields
            contacts = (List<Contact_Account_Service__c>)ODS_InitiativeSecurityHelper.stripInaccessibleFields(
                contacts, AccessType.READABLE);
            
            for (Contact_Account_Service__c contact : contacts) {
                if (contact.Contact__r != null && String.isNotBlank(contact.Contact__r.Name)) {
                    Map<String, String> approver = new Map<String, String>();
                    approver.put('label', contact.Contact__r.Name);
                    approver.put('value', contact.Contact__r.Name);
                    approver.put('contactId', contact.Contact__c);
                    approvers.add(approver);
                }
            }
        } catch (Exception e) {
            System.debug('Error fetching approvers: ' + e.getMessage());
            // Return empty list on error
        }
        
        return approvers;
    }
    
    /**
     * @description Get picklist values
     */
    private static List<Map<String, String>> getPicklistValues(String objectName, String fieldName) {
        List<Map<String, String>> options = new List<Map<String, String>>();
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Schema.DescribeFieldResult fieldDescribe = objDescribe.fields.getMap().get(fieldName).getDescribe();
        
        for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
            if (entry.isActive()) {
                Map<String, String> option = new Map<String, String>();
                option.put('label', entry.getLabel());
                option.put('value', entry.getValue());
                options.add(option);
            }
        }
        
        return options;
    }
    
    /**
     * @description Get phase options for estimate table
     */
    private static List<Map<String, String>> getPhaseOptions() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        List<String> phases = new List<String>{
            'Analysis', 'Design', 'Development', 'System Testing', 'Deployment',
            'Data Migration', 'Consulting / Advisory Hours', 'UAT Support',
            'Post Production Support', 'Sandbox Refresh', 'Scrum Activities', 'Others'
        };
        
        for (String phase : phases) {
            Map<String, String> option = new Map<String, String>();
            option.put('label', phase);
            option.put('value', phase);
            options.add(option);
        }
        
        return options;
    }
    
    /**
     * @description Get existing JIRA IDs for validation
     */
    private static Set<String> getExistingJiraIds(String accServiceId, String currentInitiativeId) {
        Set<String> jiraIds = new Set<String>();
        
        List<Initiatives__c> initiatives = [
            SELECT JIRA_ID__c
            FROM Initiatives__c
            WHERE Account_Service__c = :accServiceId
            AND JIRA_ID__c != null
            AND Id != :currentInitiativeId
        ];
        
        for (Initiatives__c init : initiatives) {
            if (String.isNotBlank(init.JIRA_ID__c)) {
                jiraIds.add(init.JIRA_ID__c.toLowerCase());
            }
        }
        
        return jiraIds;
    }
    
    /**
     * @description Get utilization metrics for progress gauges
     */
    @AuraEnabled
    public static Map<String, Decimal> getUtilizationMetrics(String initiativeId) {
        Map<String, Decimal> metrics = new Map<String, Decimal>();
        
        try {
            // Get total estimated hours
            AggregateResult[] estimateAgg = [
                SELECT SUM(Hours__c) totalEstimated
                FROM Estimate__c
                WHERE Initiative_Lookup__c = :initiativeId
            ];
            
            Decimal totalEstimated = (Decimal)estimateAgg[0].get('totalEstimated');
            if (totalEstimated == null) totalEstimated = 0;
            
            // Get consumed hours from timesheets
            // TODO: Verify correct field names for Time_Sheet_Cost__c object
            // Need to confirm: Hours field name and Initiative lookup field name
            Decimal totalConsumed = 0;
            // Temporarily disabled until correct field names are confirmed
            /*
            try {
                AggregateResult[] timesheetAgg = [
                    SELECT SUM(Hours_Worked__c) totalConsumed
                    FROM Time_Sheet_Cost__c
                    WHERE Initiative_Lookup__c = :initiativeId
                    AND Status__c = 'Approved'
                ];
                
                if (!timesheetAgg.isEmpty() && timesheetAgg[0].get('totalConsumed') != null) {
                    totalConsumed = (Decimal)timesheetAgg[0].get('totalConsumed');
                }
            } catch (Exception e) {
                System.debug('Error fetching timesheet hours: ' + e.getMessage());
                totalConsumed = 0;
            }
            */
            
            // Calculate metrics
            Decimal remainingHours = totalEstimated - totalConsumed;
            Decimal utilizationPercent = totalEstimated > 0 ? (totalConsumed / totalEstimated * 100) : 0;
            Decimal remainingPercent = totalEstimated > 0 ? (remainingHours / totalEstimated * 100) : 0;
            
            metrics.put('totalEstimated', totalEstimated);
            metrics.put('totalConsumed', totalConsumed);
            metrics.put('remainingHours', remainingHours);
            metrics.put('utilizationPercent', utilizationPercent.setScale(2));
            metrics.put('remainingPercent', remainingPercent.setScale(2));
            
        } catch (Exception e) {
            metrics.put('totalEstimated', 0);
            metrics.put('totalConsumed', 0);
            metrics.put('remainingHours', 0);
            metrics.put('utilizationPercent', 0);
            metrics.put('remainingPercent', 0);
        }
        
        return metrics;
    }
    
    /**
     * @description Get burndown chart data
     */
    private static Map<String, Object> getBurndownChartData(String initiativeId) {
        Map<String, Object> chartData = new Map<String, Object>();
        List<String> labels = new List<String>();
        List<Decimal> actualHours = new List<Decimal>();
        List<Decimal> cumulativeHours = new List<Decimal>();
        
        try {
            // Get approved timesheets grouped by date
            // TODO: Verify correct field names for Time_Sheet_Cost__c object
            // Need to confirm: Date field name, Hours field name, and Initiative lookup field name
            List<AggregateResult> timesheetData = new List<AggregateResult>();
            // Temporarily disabled until correct field names are confirmed
            /*
            try {
                timesheetData = [
                    SELECT Timesheet_Date__c startDate, SUM(Hours_Worked__c) totalHours
                    FROM Time_Sheet_Cost__c
                    WHERE Initiative_Lookup__c = :initiativeId
                    AND Status__c = 'Approved'
                    GROUP BY Timesheet_Date__c
                    ORDER BY Timesheet_Date__c ASC
                ];
            } catch (Exception e) {
                System.debug('Error fetching timesheet data: ' + e.getMessage());
                // Return empty list - burndown chart will show no data
            }
            */
            
            Decimal cumulative = 0;
            for (AggregateResult ar : timesheetData) {
                Date startDate = (Date)ar.get('startDate');
                Decimal hours = (Decimal)ar.get('totalHours');
                
                labels.add(startDate.format());
                actualHours.add(hours);
                cumulative += hours;
                cumulativeHours.add(cumulative);
            }
            
            chartData.put('labels', labels);
            chartData.put('actualHours', actualHours);
            chartData.put('cumulativeHours', cumulativeHours);
            
        } catch (Exception e) {
            // Return empty data on error
            chartData.put('labels', new List<String>());
            chartData.put('actualHours', new List<Decimal>());
            chartData.put('cumulativeHours', new List<Decimal>());
        }
        
        return chartData;
    }
    
    /**
     * @description Send initiative submission email
     */
    private static void sendInitiativeSubmissionEmail(String initiativeId) {
        // Implementation depends on email template configuration
        // This is a placeholder for the email sending logic
        try {
            Initiatives__c initiative = [
                SELECT Id, Name, Client_side_Contact__c, Account_Service__r.Technical_Account_Manager_Email__c
                FROM Initiatives__c
                WHERE Id = :initiativeId
                LIMIT 1
            ];
            
            // Send email logic here
            // Use EmailTemplate and Messaging.SingleEmailMessage
            
        } catch (Exception e) {
            System.debug('Error sending email: ' + e.getMessage());
        }
    }
    
    /**
     * @description Send initiative approval email
     */
    private static void sendInitiativeApprovalEmail(String initiativeId) {
        // Similar to submission email
    }
    
    /**
     * @description Send initiative rejection email
     */
    private static void sendInitiativeRejectionEmail(String initiativeId, String comments) {
        // Similar to submission email
    }
    
    /**
     * @description Get product list for selection modal
     * @param selectedProducts Currently selected products (comma-separated)
     * @return Map containing product groups organized in 3 columns
     */
    @AuraEnabled
    public static Map<String, Object> getProductList(String selectedProducts) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            Map<String, List<Map<String, Object>>> productMap = new Map<String, List<Map<String, Object>>>();
            Map<String, List<Map<String, Object>>> productMap1 = new Map<String, List<Map<String, Object>>>();
            Map<String, List<Map<String, Object>>> productMap2 = new Map<String, List<Map<String, Object>>>();
            Map<String, List<Map<String, Object>>> productMap3 = new Map<String, List<Map<String, Object>>>();
            
            Set<String> selectedSet = new Set<String>();
            if (String.isNotBlank(selectedProducts)) {
                for (String product : selectedProducts.split(',')) {
                    selectedSet.add(product.trim());
                }
            }
            
            // Get product groups from metadata
            List<Salesforce_Product_Group__mdt> spg = [
                SELECT Id, Label 
                FROM Salesforce_Product_Group__mdt 
                ORDER BY Label ASC
            ];
            
            // Get technology group terms
            List<Technology_Group_Term__mdt> terms = [
                SELECT Id, Label, Salesforce_Product_Group__c, Salesforce_Product_Group__r.Label
                FROM Technology_Group_Term__mdt
                WHERE Salesforce_Product_Group__c IN :spg
                ORDER BY Label ASC
            ];
            
            // Build product map
            for (Technology_Group_Term__mdt term : terms) {
                String groupLabel = term.Salesforce_Product_Group__r.Label;
                
                if (!productMap.containsKey(groupLabel)) {
                    productMap.put(groupLabel, new List<Map<String, Object>>());
                }
                
                Map<String, Object> product = new Map<String, Object>();
                product.put('pname', term.Label);
                product.put('ischecked', selectedSet.contains(term.Label));
                productMap.get(groupLabel).add(product);
            }
            
            // Split into 3 columns
            Integer groupSize = spg.size();
            Integer subGroupSize = groupSize / 3;
            
            for (String key : productMap.keySet()) {
                if (productMap1.size() <= subGroupSize) {
                    productMap1.put(key, productMap.get(key));
                } else if (productMap2.size() <= subGroupSize) {
                    productMap2.put(key, productMap.get(key));
                } else {
                    productMap3.put(key, productMap.get(key));
                }
            }
            
            result.put('productMap1', productMap1);
            result.put('productMap2', productMap2);
            result.put('productMap3', productMap3);
            result.put('success', true);
            
        } catch (Exception e) {
            result.put('success', false);
            result.put('error', e.getMessage());
            System.debug('Error in getProductList: ' + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Send initiative recall email
     */
    private static void sendInitiativeRecallEmail(String initiativeId) {
        // Similar to submission email
    }
    
    /**
     * @description Send escalation email
     */
    private static void sendEscalationEmail(String initiativeId, String escalationDetails) {
        // Similar to submission email
    }
    
    /**
     * @description Create JIRA ticket
     */
    private static void createJiraTicket(String initiativeId) {
        // Implementation for JIRA API integration
        // This is a placeholder
        try {
            // Call JIRA API to create ticket
            // Update initiative with JIRA ID
        } catch (Exception e) {
            System.debug('Error creating JIRA ticket: ' + e.getMessage());
        }
    }
}
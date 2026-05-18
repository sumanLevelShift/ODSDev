/**
 * @description Apex Controller for Status Report Lightning Web Component
 * @author      System Administrator
 * @version     1.0
 * @date        2024
 */
public with sharing class ODS_StatusReportLWCController {
    
    /**
     * @description Get status reports based on filter criteria
     * @param accountId Selected account ID
     * @param serviceId Selected service ID  
     * @param status Selected status filter
     * @param fromDate From date filter
     * @param toDate To date filter
     * @return List of Status_Report__c records
     */
    @AuraEnabled(cacheable=true)
    public static List<Status_Report__c> getStatusReports(
        String accountId, 
        String serviceId, 
        String status, 
        String fromDate, 
        String toDate
    ) {
        try {
            // Build dynamic SOQL query
            String query = buildStatusReportQuery(accountId, serviceId, status, fromDate, toDate);
            
            // Execute query and return results
            return Database.query(query);
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving status reports: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get account options for dropdown
     * @return List of SelectOption for accounts
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getAccountOptions() {
        try {
            List<Map<String, String>> options = new List<Map<String, String>>();
            
            // Add "All" option
            options.add(new Map<String, String>{
                'label' => 'All Accounts',
                'value' => 'All'
            });
            
            // Get user-specific accounts using existing utility
            ODS_Common_Utility objUtility = new ODS_Common_Utility();
            List<SelectOption> accountSelectOptions = objUtility.getCustomersByLoggedInUser();
            
            // Convert to LWC format
            for (SelectOption option : accountSelectOptions) {
                if (option.getValue() != 'All') {
                    options.add(new Map<String, String>{
                        'label' => option.getLabel(),
                        'value' => option.getValue()
                    });
                }
            }
            
            return options;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving account options: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get service options for dropdown based on selected account
     * @param accountId Selected account ID
     * @return List of SelectOption for services
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getServiceOptions(String accountId) {
        try {
            List<Map<String, String>> options = new List<Map<String, String>>();
            
            // Add "All" option
            options.add(new Map<String, String>{
                'label' => 'All Services',
                'value' => 'All'
            });
            
            // Get services based on account
            if (String.isNotBlank(accountId) && accountId != 'All') {
                List<Account_Services__c> accountServices = ODS_Data_Utility.fetchAccServcesByAcc(accountId);
                
                for (Account_Services__c accService : accountServices) {
                    options.add(new Map<String, String>{
                        'label' => accService.ODS_Services__r.Name__c,
                        'value' => accService.ODS_Services__c
                    });
                }
            } else {
                // Get all services if no specific account selected
                List<ODS_Services__c> allServices = ODS_Data_Utility.GetAllServices();
                
                for (ODS_Services__c service : allServices) {
                    options.add(new Map<String, String>{
                        'label' => service.Name__c,
                        'value' => service.Id
                    });
                }
            }
            
            return options;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving service options: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get status picklist options
     * @return List of SelectOption for status values
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getStatusOptions() {
        try {
            List<Map<String, String>> options = new List<Map<String, String>>();
            
            // Add "All" option
            options.add(new Map<String, String>{
                'label' => 'All Statuses',
                'value' => 'All'
            });
            
            // Get picklist values dynamically
            Schema.DescribeFieldResult fieldResult = Status_Report__c.Status__c.getDescribe();
            List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
            
            for (Schema.PicklistEntry entry : picklistValues) {
                options.add(new Map<String, String>{
                    'label' => entry.getLabel(),
                    'value' => entry.getValue()
                });
            }
            
            return options;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving status options: ' + e.getMessage());
        }
    }
    
    /**
     * @description Delete a status report record
     * @param statusReportId ID of the status report to delete
     * @return Success message
     */
    @AuraEnabled
    public static String deleteStatusReport(Id statusReportId) {
        try {
            if (statusReportId == null) {
                throw new IllegalArgumentException('Status Report ID cannot be null');
            }
            
            // Check if record exists and user has permission to delete
            Status_Report__c statusReport = [
                SELECT Id, Status__c 
                FROM Status_Report__c 
                WHERE Id = :statusReportId 
                LIMIT 1
            ];
            
            // Business rule: Cannot delete submitted reports
            if (statusReport.Status__c == 'Submitted') {
                throw new AuraHandledException('Cannot delete submitted status reports');
            }
            
            // Delete the record
            delete statusReport;
            
            return 'Status report deleted successfully';
            
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting status report: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get user context information
     * @return Map containing user role and permissions
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getUserContext() {
        try {
            User currentUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());
            
            return new Map<String, Object>{
                'portalUserRole' => currentUser.PortalUserRole__c,
                'isCustomer' => currentUser.PortalUserRole__c == 'Customer',
                'isPortalAccess' => currentUser.Is_Portal_Access__c,
                'contactId' => currentUser.ContactId
            };
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving user context: ' + e.getMessage());
        }
    }
    
    /**
     * @description Build dynamic SOQL query for status reports
     * @param accountId Account filter
     * @param serviceId Service filter
     * @param status Status filter
     * @param fromDate From date filter
     * @param toDate To date filter
     * @return SOQL query string
     */
    private static String buildStatusReportQuery(
        String accountId, 
        String serviceId, 
        String status, 
        String fromDate, 
        String toDate
    ) {
        // Base query with required fields
        String query = 'SELECT Id, Name, Account_Services__c, ' +
                      'Account_Services__r.Account__c, Account_Services__r.Account__r.Name, ' +
                      'Account_Services__r.ODS_Services__r.Name__c, Account_Services__r.ODS_Services__c, ' +
                      'LastModifiedDate, Status__c, Status_Date__c, Issues_and_Concerns__c, ' +
                      'Status_Report_Frequency__c, Account_Services__r.Status_Report_Frequency__c, ' +
                      'Work_For_The_Day__c, Work_For_The_Next_Day__c ' +
                      'FROM Status_Report__c WHERE ';
        
        List<String> conditions = new List<String>();
        
        // Account filter
        if (String.isNotBlank(accountId) && accountId != 'All') {
            conditions.add('Account_Services__r.Account__c = \'' + String.escapeSingleQuotes(accountId) + '\'');
        }
        
        // Service filter  
        if (String.isNotBlank(serviceId) && serviceId != 'All') {
            conditions.add('Account_Services__r.ODS_Services__c = \'' + String.escapeSingleQuotes(serviceId) + '\'');
        }
        
        // Status filter
        User currentUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());
        if (currentUser.PortalUserRole__c == 'Customer') {
            // Customers can only see submitted reports
            conditions.add('Status__c = \'Submitted\'');
        } else if (String.isNotBlank(status) && status != 'All') {
            conditions.add('Status__c = \'' + String.escapeSingleQuotes(status) + '\'');
        }
        
        // Date filters
        if (String.isNotBlank(fromDate)) {
            conditions.add('Status_Date__c >= ' + Date.valueOf(fromDate));
        }
        
        if (String.isNotBlank(toDate)) {
            conditions.add('Status_Date__c <= ' + Date.valueOf(toDate));
        }
        
        // Current date filter (only show reports up to today)
        conditions.add('Status_Date__c <= TODAY');
        
        // User-specific data access
        if (currentUser.PortalUserRole__c == 'Customer') {
            // Filter by customer's accessible accounts/services
            Set<String> accessibleAccountIds = getAccessibleAccountIds(currentUser.ContactId);
            if (!accessibleAccountIds.isEmpty()) {
                String accountIdList = '\'' + String.join(new List<String>(accessibleAccountIds), '\',\'') + '\'';
                conditions.add('Account_Services__r.Account__c IN (' + accountIdList + ')');
            }
        }
        
        // Combine conditions
        if (!conditions.isEmpty()) {
            query += String.join(conditions, ' AND ');
        } else {
            query += '1=1'; // Fallback condition
        }
        
        // Add ordering and limit
        query += ' ORDER BY Status_Date__c DESC LIMIT 500';
        
        return query;
    }
    
    /**
     * @description Get accessible account IDs for a customer contact
     * @param contactId Contact ID
     * @return Set of accessible account IDs
     */
    private static Set<String> getAccessibleAccountIds(Id contactId) {
        Set<String> accountIds = new Set<String>();
        
        if (contactId != null) {
            // Get accounts accessible to this contact
            List<Contact_Account_Service__c> contactAccServices = 
                ODS_Data_Utility.GetCustomerAccService(null, contactId);
            
            for (Contact_Account_Service__c cas : contactAccServices) {
                if (cas.Account__c != null) {
                    accountIds.add(cas.Account__c);
                }
            }
        }
        
        return accountIds;
    }
    
    /**
     * @description Validate user permissions for status report operations
     * @param operation The operation being performed (view, edit, delete)
     * @param statusReport The status report record
     * @return Boolean indicating if operation is allowed
     */
    @AuraEnabled
    public static Boolean validateUserPermissions(String operation, Id statusReportId) {
        try {
            User currentUser = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());
            
            // Get status report details
            Status_Report__c statusReport = [
                SELECT Id, Status__c, Account_Services__r.Account__c
                FROM Status_Report__c 
                WHERE Id = :statusReportId 
                LIMIT 1
            ];
            
            // Customer role restrictions
            if (currentUser.PortalUserRole__c == 'Customer') {
                // Customers can only view submitted reports
                return operation == 'view' && statusReport.Status__c == 'Submitted';
            }
            
            // Partner role restrictions  
            if (currentUser.PortalUserRole__c == 'Partner') {
                // Partners cannot edit or delete
                return operation == 'view';
            }
            
            // Internal users - check status for edit/delete operations
            if (operation == 'edit' || operation == 'delete') {
                return statusReport.Status__c != 'Submitted';
            }
            
            // View operation is allowed for internal users
            return true;
            
        } catch (Exception e) {
            System.debug('Error validating permissions: ' + e.getMessage());
            return false;
        }
    }
}
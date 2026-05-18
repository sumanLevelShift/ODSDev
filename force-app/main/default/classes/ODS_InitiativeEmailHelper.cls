/**
 * @description Email helper class for Initiative notifications
 * Handles all email sending operations
 */
public with sharing class ODS_InitiativeEmailHelper {
    
    /**
     * @description Send initiative submission email to approvers and TAM
     * @param initiativeId Initiative record ID
     */
    public static void sendSubmissionEmail(String initiativeId) {
        try {
            Initiatives__c initiative = [
                SELECT Id, Name, Client_side_Contact__c, Client_side_Contact__r.Email,
                       Account_Service__r.Technical_Account_Manager_Email__c,
                       CreatedBy.Name, CreatedBy.Email
                FROM Initiatives__c
                WHERE Id = :initiativeId
                LIMIT 1
            ];
            
            List<String> recipients = new List<String>();
            
            // Add approver email
            if (String.isNotBlank(initiative.Client_side_Contact__r.Email)) {
                recipients.add(initiative.Client_side_Contact__r.Email);
            }
            
            // Add TAM email
            if (String.isNotBlank(initiative.Account_Service__r.Technical_Account_Manager_Email__c)) {
                recipients.add(initiative.Account_Service__r.Technical_Account_Manager_Email__c);
            }
            
            if (!recipients.isEmpty()) {
                sendEmail(
                    recipients,
                    'Initiative Submitted for Approval: ' + initiative.Name,
                    buildSubmissionEmailBody(initiative),
                    initiative.CreatedBy.Email
                );
            }
        } catch (Exception e) {
            System.debug('Error sending submission email: ' + e.getMessage());
            // Don't throw - email failure shouldn't block the operation
        }
    }
    
    /**
     * @description Send initiative approval email
     * @param initiativeId Initiative record ID
     */
    public static void sendApprovalEmail(String initiativeId) {
        try {
            Initiatives__c initiative = [
                SELECT Id, Name, CreatedBy.Email, CreatedBy.Name,
                       Account_Service__r.Technical_Account_Manager_Email__c
                FROM Initiatives__c
                WHERE Id = :initiativeId
                LIMIT 1
            ];
            
            List<String> recipients = new List<String>();
            recipients.add(initiative.CreatedBy.Email);
            
            if (String.isNotBlank(initiative.Account_Service__r.Technical_Account_Manager_Email__c)) {
                recipients.add(initiative.Account_Service__r.Technical_Account_Manager_Email__c);
            }
            
            sendEmail(
                recipients,
                'Initiative Approved: ' + initiative.Name,
                buildApprovalEmailBody(initiative),
                null
            );
        } catch (Exception e) {
            System.debug('Error sending approval email: ' + e.getMessage());
        }
    }
    
    /**
     * @description Send initiative rejection email
     * @param initiativeId Initiative record ID
     * @param comments Rejection comments
     */
    public static void sendRejectionEmail(String initiativeId, String comments) {
        try {
            Initiatives__c initiative = [
                SELECT Id, Name, CreatedBy.Email, CreatedBy.Name,
                       Account_Service__r.Technical_Account_Manager_Email__c
                FROM Initiatives__c
                WHERE Id = :initiativeId
                LIMIT 1
            ];
            
            List<String> recipients = new List<String>();
            recipients.add(initiative.CreatedBy.Email);
            
            if (String.isNotBlank(initiative.Account_Service__r.Technical_Account_Manager_Email__c)) {
                recipients.add(initiative.Account_Service__r.Technical_Account_Manager_Email__c);
            }
            
            sendEmail(
                recipients,
                'Initiative Requires Re-evaluation: ' + initiative.Name,
                buildRejectionEmailBody(initiative, comments),
                null
            );
        } catch (Exception e) {
            System.debug('Error sending rejection email: ' + e.getMessage());
        }
    }
    
    /**
     * @description Send initiative recall email
     * @param initiativeId Initiative record ID
     */
    public static void sendRecallEmail(String initiativeId) {
        try {
            Initiatives__c initiative = [
                SELECT Id, Name, Client_side_Contact__r.Email,
                       Account_Service__r.Technical_Account_Manager_Email__c
                FROM Initiatives__c
                WHERE Id = :initiativeId
                LIMIT 1
            ];
            
            List<String> recipients = new List<String>();
            
            if (String.isNotBlank(initiative.Client_side_Contact__r.Email)) {
                recipients.add(initiative.Client_side_Contact__r.Email);
            }
            
            if (String.isNotBlank(initiative.Account_Service__r.Technical_Account_Manager_Email__c)) {
                recipients.add(initiative.Account_Service__r.Technical_Account_Manager_Email__c);
            }
            
            if (!recipients.isEmpty()) {
                sendEmail(
                    recipients,
                    'Initiative Recalled: ' + initiative.Name,
                    buildRecallEmailBody(initiative),
                    null
                );
            }
        } catch (Exception e) {
            System.debug('Error sending recall email: ' + e.getMessage());
        }
    }
    
    /**
     * @description Send escalation email
     * @param initiativeId Initiative record ID
     * @param escalationDetails Escalation details
     */
    public static void sendEscalationEmail(String initiativeId, String escalationDetails) {
        try {
            Initiatives__c initiative = [
                SELECT Id, Name, Account_Service__r.Technical_Account_Manager_Email__c,
                       CreatedBy.Email, CreatedBy.Name
                FROM Initiatives__c
                WHERE Id = :initiativeId
                LIMIT 1
            ];
            
            List<String> recipients = new List<String>();
            
            // Add TAM and escalation contacts
            if (String.isNotBlank(initiative.Account_Service__r.Technical_Account_Manager_Email__c)) {
                recipients.add(initiative.Account_Service__r.Technical_Account_Manager_Email__c);
            }
            
            // Add submitter
            recipients.add(initiative.CreatedBy.Email);
            
            sendEmail(
                recipients,
                'Initiative Escalation: ' + initiative.Name,
                buildEscalationEmailBody(initiative, escalationDetails),
                null
            );
        } catch (Exception e) {
            System.debug('Error sending escalation email: ' + e.getMessage());
        }
    }
    
    /**
     * @description Send email using Messaging API
     * @param recipients List of recipient email addresses
     * @param subject Email subject
     * @param body Email body (HTML)
     * @param replyTo Reply-to email address
     */
    private static void sendEmail(List<String> recipients, String subject, String body, String replyTo) {
        try {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(recipients);
            email.setSubject(subject);
            email.setHtmlBody(body);
            
            if (String.isNotBlank(replyTo)) {
                email.setReplyTo(replyTo);
            }
            
            // Set OrgWideEmailAddress if configured
            List<OrgWideEmailAddress> orgWideEmails = [
                SELECT Id, Address
                FROM OrgWideEmailAddress
                WHERE Address = 'noreply@demandblue.com'
                LIMIT 1
            ];
            
            if (!orgWideEmails.isEmpty()) {
                email.setOrgWideEmailAddressId(orgWideEmails[0].Id);
            }
            
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
        } catch (Exception e) {
            System.debug('Error in sendEmail: ' + e.getMessage());
        }
    }
    
    /**
     * @description Build submission email body
     */
    private static String buildSubmissionEmailBody(Initiatives__c initiative) {
        String body = '<html><body>';
        body += '<h2>Initiative Submitted for Approval</h2>';
        body += '<p>A new initiative has been submitted for your review:</p>';
        body += '<table border="1" cellpadding="5">';
        body += '<tr><td><strong>Initiative Name:</strong></td><td>' + initiative.Name + '</td></tr>';
        body += '<tr><td><strong>Submitted By:</strong></td><td>' + initiative.CreatedBy.Name + '</td></tr>';
        body += '<tr><td><strong>Action Required:</strong></td><td>Please review and approve/reject</td></tr>';
        body += '</table>';
        body += '<p><a href="' + URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/Initiatives__c/' + initiative.Id + '/view">View Initiative</a></p>';
        body += '</body></html>';
        return body;
    }
    
    /**
     * @description Build approval email body
     */
    private static String buildApprovalEmailBody(Initiatives__c initiative) {
        String body = '<html><body>';
        body += '<h2>Initiative Approved</h2>';
        body += '<p>Your initiative has been approved:</p>';
        body += '<table border="1" cellpadding="5">';
        body += '<tr><td><strong>Initiative Name:</strong></td><td>' + initiative.Name + '</td></tr>';
        body += '<tr><td><strong>Status:</strong></td><td>Approved</td></tr>';
        body += '</table>';
        body += '<p><a href="' + URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/Initiatives__c/' + initiative.Id + '/view">View Initiative</a></p>';
        body += '</body></html>';
        return body;
    }
    
    /**
     * @description Build rejection email body
     */
    private static String buildRejectionEmailBody(Initiatives__c initiative, String comments) {
        String body = '<html><body>';
        body += '<h2>Initiative Requires Re-evaluation</h2>';
        body += '<p>Your initiative requires changes:</p>';
        body += '<table border="1" cellpadding="5">';
        body += '<tr><td><strong>Initiative Name:</strong></td><td>' + initiative.Name + '</td></tr>';
        body += '<tr><td><strong>Status:</strong></td><td>Re-evaluate</td></tr>';
        body += '<tr><td><strong>Comments:</strong></td><td>' + String.escapeSingleQuotes(comments) + '</td></tr>';
        body += '</table>';
        body += '<p><a href="' + URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/Initiatives__c/' + initiative.Id + '/view">View Initiative</a></p>';
        body += '</body></html>';
        return body;
    }
    
    /**
     * @description Build recall email body
     */
    private static String buildRecallEmailBody(Initiatives__c initiative) {
        String body = '<html><body>';
        body += '<h2>Initiative Recalled</h2>';
        body += '<p>The following initiative has been recalled:</p>';
        body += '<table border="1" cellpadding="5">';
        body += '<tr><td><strong>Initiative Name:</strong></td><td>' + initiative.Name + '</td></tr>';
        body += '</table>';
        body += '</body></html>';
        return body;
    }
    
    /**
     * @description Build escalation email body
     */
    private static String buildEscalationEmailBody(Initiatives__c initiative, String escalationDetails) {
        String body = '<html><body>';
        body += '<h2>Initiative Escalation</h2>';
        body += '<p>An initiative has been escalated:</p>';
        body += '<table border="1" cellpadding="5">';
        body += '<tr><td><strong>Initiative Name:</strong></td><td>' + initiative.Name + '</td></tr>';
        body += '<tr><td><strong>Escalated By:</strong></td><td>' + initiative.CreatedBy.Name + '</td></tr>';
        body += '<tr><td><strong>Escalation Details:</strong></td><td>' + String.escapeSingleQuotes(escalationDetails) + '</td></tr>';
        body += '</table>';
        body += '<p><a href="' + URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/Initiatives__c/' + initiative.Id + '/view">View Initiative</a></p>';
        body += '</body></html>';
        return body;
    }
}
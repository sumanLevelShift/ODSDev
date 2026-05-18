trigger opportunity_SendEmails on Opportunity (after insert, after update) {
    List<Opportunity> opportunity_SendMail = new List<Opportunity>();
    
    // Get both record type IDs
    Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
    String projectODSRecordId = rtMap.get('Project/ODS').getRecordTypeId();
    String staffingRecordId   = rtMap.get('Staffing').getRecordTypeId();
    
    if (Trigger.isUpdate) {
        for (Opportunity opportunityObj : Trigger.new) {
            Opportunity opp_beforeUpdate = Trigger.oldMap.get(opportunityObj.Id);
            
            // Include both record types
            if (opportunityObj.RecordTypeId == projectODSRecordId || opportunityObj.RecordTypeId == staffingRecordId) {
                if (
                    (opp_beforeUpdate.StageName != 'Closed Won' && opportunityObj.StageName == 'Closed Won') &&
                    (
                        (opportunityObj.Type == 'Existing Business' &&
                         (opportunityObj.Opportunity_Type__c == 'New' || opportunityObj.Opportunity_Type__c == 'Change Request')) ||
                        opportunityObj.Type != 'Existing Business'
                    )
                ) {
                    opportunity_SendMail.add(opportunityObj);
                }
            }
        }
    }
    
    if (Trigger.isInsert) {
        for (Opportunity opportunityObj : Trigger.new) {
            if (opportunityObj.RecordTypeId == projectODSRecordId || opportunityObj.RecordTypeId == staffingRecordId) {
                if (
                    (opportunityObj.StageName == 'Closed Won') &&
                    (
                        (opportunityObj.Type == 'Existing Business' && opportunityObj.Opportunity_Type__c == 'New') ||
                        (opportunityObj.Type != 'Change Request' && opportunityObj.Type != 'Existing Business')
                    )
                ) {
                    opportunity_SendMail.add(opportunityObj);
                }
            }
        }
    }
    
    // Send emails if any Opportunities qualify
    if (!opportunity_SendMail.isEmpty()) {
        opportunity_SendEmailCntrl.sendEmailMethod(opportunity_SendMail);
    }
}
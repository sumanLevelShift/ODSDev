/**
 * @description Security helper class for Initiative operations
 * Handles CRUD/FLS checks and data sanitization
 */
public with sharing class ODS_InitiativeSecurityHelper {
    
    /**
     * @description Check if user has access to perform operation on object
     * @param objType SObjectType to check
     * @param operation Type of operation (READ, CREATE, UPDATE, DELETE)
     */
    public static void checkObjectAccess(Schema.SObjectType objType, String operation) {
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        if (operation == 'READ' && !objDescribe.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to read ' + objDescribe.getName());
        } else if (operation == 'CREATE' && !objDescribe.isCreateable()) {
            throw new AuraHandledException('Insufficient permissions to create ' + objDescribe.getName());
        } else if (operation == 'UPDATE' && !objDescribe.isUpdateable()) {
            throw new AuraHandledException('Insufficient permissions to update ' + objDescribe.getName());
        } else if (operation == 'DELETE' && !objDescribe.isDeletable()) {
            throw new AuraHandledException('Insufficient permissions to delete ' + objDescribe.getName());
        }
    }
    
    /**
     * @description Check field-level security for specific fields
     * @param objType SObjectType to check
     * @param fieldNames Set of field API names
     * @param operation Type of operation (READ, CREATE, UPDATE)
     */
    public static void checkFieldAccess(Schema.SObjectType objType, Set<String> fieldNames, String operation) {
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        
        for (String fieldName : fieldNames) {
            if (!fieldMap.containsKey(fieldName)) {
                continue;
            }
            
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            if (operation == 'READ' && !fieldDescribe.isAccessible()) {
                throw new AuraHandledException('Insufficient permissions to read field ' + fieldName);
            } else if (operation == 'CREATE' && !fieldDescribe.isCreateable()) {
                throw new AuraHandledException('Insufficient permissions to create field ' + fieldName);
            } else if (operation == 'UPDATE' && !fieldDescribe.isUpdateable()) {
                throw new AuraHandledException('Insufficient permissions to update field ' + fieldName);
            }
        }
    }
    
    /**
     * @description Strip inaccessible fields from query results
     * @param records List of records to sanitize
     * @param accessType Type of access (READABLE, CREATABLE, UPDATABLE)
     * @return Sanitized list of records
     */
    public static List<SObject> stripInaccessibleFields(List<SObject> records, System.AccessType accessType) {
        if (records == null || records.isEmpty()) {
            return records;
        }
        
        SObjectAccessDecision decision = Security.stripInaccessible(accessType, records);
        return decision.getRecords();
    }
    
    /**
     * @description Check if current user has access to Initiative
     * @param initiativeId Initiative record ID
     * @return Boolean indicating access
     */
    public static Boolean hasInitiativeAccess(String initiativeId) {
        try {
            checkObjectAccess(Schema.Initiatives__c.SObjectType, 'READ');
            
            List<Initiatives__c> initiatives = [
                SELECT Id 
                FROM Initiatives__c 
                WHERE Id = :initiativeId 
                LIMIT 1
            ];
            
            return !initiatives.isEmpty();
        } catch (Exception e) {
            return false;
        }
    }
    
    /**
     * @description Validate DML operation before execution
     * @param records List of records to perform DML on
     * @param operation Type of DML operation
     */
    public static void validateDML(List<SObject> records, String operation) {
        if (records == null || records.isEmpty()) {
            return;
        }
        
        Schema.SObjectType objType = records[0].getSObjectType();
        checkObjectAccess(objType, operation);
        
        // For UPDATE, also check that records exist and user has access
        if (operation == 'UPDATE' || operation == 'DELETE') {
            Set<Id> recordIds = new Set<Id>();
            for (SObject record : records) {
                if (record.Id != null) {
                    recordIds.add(record.Id);
                }
            }
            
            if (!recordIds.isEmpty()) {
                // Query to verify access via sharing rules
                String query = 'SELECT Id FROM ' + objType.getDescribe().getName() + 
                              ' WHERE Id IN :recordIds';
                List<SObject> accessibleRecords = Database.query(query);
                
                if (accessibleRecords.size() != recordIds.size()) {
                    throw new AuraHandledException('Some records are not accessible');
                }
            }
        }
    }
    
    /**
     * @description Get accessible fields for an object
     * @param objType SObjectType to check
     * @param operation Type of operation
     * @return Set of accessible field names
     */
    public static Set<String> getAccessibleFields(Schema.SObjectType objType, String operation) {
        Set<String> accessibleFields = new Set<String>();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        
        for (String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            Boolean isAccessible = false;
            if (operation == 'READ') {
                isAccessible = fieldDescribe.isAccessible();
            } else if (operation == 'CREATE') {
                isAccessible = fieldDescribe.isCreateable();
            } else if (operation == 'UPDATE') {
                isAccessible = fieldDescribe.isUpdateable();
            }
            
            if (isAccessible) {
                accessibleFields.add(fieldName);
            }
        }
        
        return accessibleFields;
    }
    
    /**
     * @description Check read access for User object
     */
    public static void checkUserReadAccess() {
        checkObjectAccess(Schema.User.SObjectType, 'READ');
    }
    
    /**
     * @description Check read access for Account_Services__c object
     */
    public static void checkAccountServiceReadAccess() {
        checkObjectAccess(Schema.Account_Services__c.SObjectType, 'READ');
    }
    
    /**
     * @description Check read access for Contact_Account_Service__c object
     */
    public static void checkContactAccountServiceReadAccess() {
        checkObjectAccess(Schema.Contact_Account_Service__c.SObjectType, 'READ');
    }
    
    /**
     * @description Check access for Initiatives__c object
     * @param operation Operation type
     */
    public static void checkInitiativeAccess(String operation) {
        checkObjectAccess(Schema.Initiatives__c.SObjectType, operation);
    }
    
    /**
     * @description Check access for Estimate__c object
     * @param operation Operation type
     */
    public static void checkEstimateAccess(String operation) {
        checkObjectAccess(Schema.Estimate__c.SObjectType, operation);
    }
    
    /**
     * @description Check access for Attachment object
     * @param operation Operation type
     */
    public static void checkAttachmentAccess(String operation) {
        checkObjectAccess(Schema.Attachment.SObjectType, operation);
    }
    
    /**
     * @description Check access for InitiativeEscalation__c object
     * @param operation Operation type
     */
    public static void checkEscalationAccess(String operation) {
        checkObjectAccess(Schema.InitiativeEscalation__c.SObjectType, operation);
    }
}
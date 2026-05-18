public with sharing class ItemMasterLookupController {
    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(Datetime currentDatetime,string searchKey , string sObjectApiName, string workOrderId,string unitOfMeasure) {  
        List < sObject > returnList = new List < sObject > ();
        string sWildCardText = '%' + searchKey + '%';
        system.debug('unitOfMeasure-'+unitOfMeasure);
        List<Work_Order__c> wo=[Select ID,Business_Unit__c FROM Work_Order__c WHERE ID =:workOrderId LIMIT 1];
        String businessUnit = !wo.isEmpty()? wo[0].Business_Unit__c: '';
        string sQuery = 'Select Id,Description__c,Unit_of_Measure__c,Tax_Rate__c From ' + sObjectApiName + ' Where Description__c Like : sWildCardText ';
        sQuery += ' AND Business_Unit__c=:businessUnit AND IsActive__c=true AND Unit_of_Measure__c=:unitOfMeasure order by Description__c ASC LIMIT 5';
        system.debug('sQuery-'+sQuery);
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchEmployeeLookupData(Datetime currentDatetime,string searchKey , string sObjectApiName) {  
        List<sObject> returnList = new List<sObject>();
        
        String accountID = System.Label.BC_Staffing_Account_ID;
        system.debug('accountID-' + accountID);
        system.debug('searchKey-' + searchKey);
        
        String sQuery = 'SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email != null AND AccountId = :accountID AND AccountId != null ';
        
        if (String.isNotBlank(searchKey)) {
            String sWildCardText = '%' + String.escapeSingleQuotes(searchKey) + '%';
            system.debug('sWildCardText-' + sWildCardText);
            sQuery += 'AND (FirstName LIKE :sWildCardText OR LastName LIKE :sWildCardText OR Email LIKE :sWildCardText) ';
        }
        
        sQuery += 'ORDER BY FirstName ASC LIMIT 5';
        
        System.debug('sQuery: ' + sQuery);
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
}
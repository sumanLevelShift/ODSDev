public class HierarchyCustomLookupLwcController {
    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName, string typeLookup) {    
        List < sObject > returnList = new List < sObject > ();
        string sWildCardText = '%' + searchKey + '%';
        string sQuery = 'Select Id,Full_Name__c From ' + sObjectApiName + ' Where Full_Name__c Like : sWildCardText ';
        if(typeLookup =='TPM/SME'){
            string tpm='TPM/SME';
            string pms='Program Manager';
            sQuery +='AND (Delivery_Role__c =:tpm OR Delivery_Role__c =:pms) ';
        }
        if(typeLookup =='PM'){
            string pm='Program Manager';
            sQuery +='AND Delivery_Role__c =:pm ';
        }
        system.debug('typeLookup--'+typeLookup);
         if(typeLookup =='createBy'){
             string userId=UserInfo.getUserId();
             List<User> userList=[Select Id,Delivery_Role__c From User Where Id=:userId and Delivery_Role__c !=null];
             
             if(!userList.isEmpty()){
                 string role=userList[0].Delivery_Role__c;
                 List<string> deliveryRole=role.split(';');
                 Set<string> deliveryRoleSet=New Set<string>();
                 for(string s:deliveryRole){
                     if(s=='Developer'){
                         deliveryRoleSet.add('None');
                     }
                     deliveryRoleSet.add(s);
                 }
                 system.debug('deliveryRoleSet-'+deliveryRoleSet);
                 sQuery +='AND Delivery_Role__c IN:deliveryRoleSet ';   
             }
        }
        sQuery +=  'AND IsActive__c=true order by Full_Name__c DESC LIMIT 5';
        system.debug('sQuery-'+sQuery);
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    @AuraEnabled(cacheable=true)
    public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
        string sRecId = recordId;    
        system.debug('hr sRecId--'+sRecId);
        string sQuery = 'Select Id,Full_Name__c From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
        for (sObject obj: database.query(sQuery)) {
            return obj;
        }
        return null;
    }
    
}
public class OpportunityHandler {
    //Append account name and owner name to opp name & Check the checkbox if stage is 'qualification'
	public static void appendAccountAndOwnerName(List<Opportunity> oppList)
    {	
        
        //Get the account ids first as accountname is not directly available in Opportunity
        Set<Id> accountIdset = new Set<Id>(); 
        //Get the owner ids first as owner is not directly available in Opportunity
        Set<Id> ownerIdset = new Set<Id>();
        for(Opportunity opp : oppList)
        {
            if(opp.AccountId != null)
            {
                accountIdset.add(opp.accountID);
                ownerIdset.add(opp.OwnerId);
            }
         } 
        //Get the account name with Id
        Map<Id,Account> accountMap = new Map<Id, Account>([Select Id, name from Account where Id in :accountIdset]);
        //Get the owner name with Id
        Map<Id,User> ownerMap = new Map<Id, User>([Select Id, name from User where Id in :ownerIdset]);    
        
        //Append all the data to opp name
        for(Opportunity opp : oppList)
        {
            if(opp.AccountId != null){
                opp.Name += accountMap.get(opp.AccountId).name + ownerMap.get(opp.OwnerId).name;
            }
            opp.isQualified__c = ischeckIfQualified(opp.StageName);
        }
    }
    //Check the checkbox if stage is 'qualification'
    public static boolean ischeckIfQualified(String oppStageName)
    {
        if(oppStageName == 'Qualification')
        {
            return true;
        }
        return false;
    }
}
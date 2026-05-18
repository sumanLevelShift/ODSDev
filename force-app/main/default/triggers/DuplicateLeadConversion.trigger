/**
 * @author           Anil Kumar
 * @Modified		 Siva
 * @version          2.1 
 * @date             05-Dec-2017
 * @Status           Developed
 * @description      This is the trigger to convert associated leads.
 * @Class            DuplicateLeadConvertClass.
 */
trigger DuplicateLeadConversion on Lead (after update) {
    List<lead> ConvertedLeads = new List<Lead>();
    Map<String,Id> CompanyNameList = new Map<String,Id>();
    Set<Id> LeadIds = new Set<Id>();
    Set<Id> CampaignIds = new Set<Id>();
    
    
    //Lead Active Based on custom label implemented 30/07/2020 
    if(system.Label.DuplicateLeadConversionActivate == 'Active'){
        
        for(Lead ld : Trigger.New)
        {
            if(Trigger.OldMap.get(ld.Id).isConverted == false && Trigger.NewMap.get(ld.Id).isConverted == true && Trigger.NewMap.get(ld.Id).convertedAccountId != null)
            {
                CompanyNameList.put(ld.Company,ld.convertedAccountId);
                LeadIds.add(ld.Id);
                
            }
        }
        // To Avoid recursion. //Changes - 2020-12-08-SD:
        if(DuplicateLeadConvertClass.isFutureCalled = true){
            
            DuplicateLeadConvertClass.futureCallout(LeadIds, CompanyNameList); 
        }
    }
}
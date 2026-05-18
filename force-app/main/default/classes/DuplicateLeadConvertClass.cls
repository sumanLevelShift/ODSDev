/**
 * @author           Anil Kumar
 * @Modified		 Siva
 * @version          2.1 
 * @date             05-Dec-2017
 * @Status           Developed
 * @description      This is the controller class for DuplicateLeadconversion.
 *
 */
public class DuplicateLeadConvertClass {
    
    //Changes - 2020-12-08-SD:
    public static boolean isFutureCalled=true; //Boolean variable to control recursion. 
    
    public static void futureCallout(set<Id> ledIds, Map<String,Id> CompanyNameList ){
        
        try{
            isFutureCalled =false;
            Set<Id> CampaignIds = new Set<Id>();
            
            List<Database.LeadConvert> lcList = new List<Database.LeadConvert>();
            
            List<CampaignMember> getLeadCampaigns = [Select Id, LeadId, CampaignId from CampaignMember where LeadId in: ledIds]; 
            If(getLeadCampaigns.size() > 0)
            {
                for(Campaignmember cam : getLeadCampaigns)
                {
                    CampaignIds.add(cam.CampaignId);
                }
            } 
            
            //DupLeadsToconvert = [select Id, Company from lead where company in: CompanyNameList.keyset() and isConverted = false];
            List<CampaignMember> DupLeadsToconvert = [ Select Id, LeadId,Lead.Company, CampaignId from CampaignMember where Lead.Company  in: CompanyNameList.keyset() and Lead.isConverted = false and CampaignId In: CampaignIds];
            
            
            for(CampaignMember dup : DupLeadsToconvert)
            {
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(dup.LeadId);
                lc.setAccountId(CompanyNameList.get(dup.Lead.Company));
                lc.setDoNotCreateOpportunity(TRUE);
                lc.setConvertedStatus('Qualified');
                lcList.add(lc);
            }
            if ( lcList.size() > 0 ) {
                List<Database.LeadConvertResult> lcr = Database.convertLead(lcList);
                system.debug('lcr ++'+lcr); 
            }
            
        }
        catch(Exception Error){
            
            ODS_ExceptionUtility.saveErrorLogs(string.Valueof(Error.getCause()), Error.getMessage(), Error.getStackTraceString(), Error.getTypeName());
          	System.debug('futureCallout.Exception'+Error);
        }
    }
    //Changes - 2020-12-08-SD:
}
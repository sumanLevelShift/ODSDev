/*******************************************************************************************
* @author           Suman & Sathish
* @version          1.0 
* @date             07-APR-2021
* @Status           In-Progress
* @Class Name       LeadSettingsUtilization
* @description      This class is being called from - RunExtendedValidation

*********************************************************************************************
Version     Date       Team          Comments
*********************************************************************************************
* 1         Apr 2021    Suman & Sathish          Initial Creation
*********************************************************************************************/
public class LeadSettingsUtilization{
    
    public static Double getUtilization(String jsonInput,string accountId){
        if(String.isBlank(jsonInput))
            return 0.0;
        
        Decimal isOrgWideMergeAndDeleteEnabledUsage = 0; 
        Decimal isConversionsOnMobileEnabledUsage = 0;
        Decimal trackHistory = 0;
        Decimal leadConvertDefaultSubjectBlankTaskCreation=0;
        Decimal leadConvertRequireValidation=0;
        Decimal opportunityConvertLead=0;
        Decimal preserveLeadStatus=0;
        
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
        for (Object item : (List<Object>)response.get('records')) {
            Map<String, Object> i = (Map<String, Object>)item;
            if(i.get('IsOrgWideMergeAndDeleteEnabled')==true)
                isOrgWideMergeAndDeleteEnabledUsage=100;
            
            if(i.get('IsConversionsOnMobileEnabled')==true)
                isConversionsOnMobileEnabledUsage=100;
            
            if(i.get('DoesTrackHistory')==true)
                trackHistory=100;
            
            if(i.get('DoesEnableLeadConvertDefaultSubjectBlankTaskCreation')==true)
                leadConvertDefaultSubjectBlankTaskCreation=100;
            
            if(i.get('ShouldLeadConvertRequireValidation')==true)
                leadConvertRequireValidation = 100;
            
            if(i.get('DoesHideOpportunityInConvertLeadWindow')==false && i.get('DoesSelectNoOpportunityOnConvertLead')==false )
                opportunityConvertLead = 100;
            
            if(i.get('DoesPreserveLeadStatus')==true)
                preserveLeadStatus = 100;
            
        }
        
        decimal clientUsage=(isOrgWideMergeAndDeleteEnabledUsage + isConversionsOnMobileEnabledUsage + trackHistory + leadConvertDefaultSubjectBlankTaskCreation + leadConvertRequireValidation + opportunityConvertLead + preserveLeadStatus)/7;
        return clientUsage;
    }    
}
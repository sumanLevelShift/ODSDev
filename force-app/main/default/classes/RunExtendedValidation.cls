/*******************************************************************************************
* @author           Yuvaraj
* @version          1.0 
* @date             06-APR-2021
* @Status           In-Progress
* @Class Name       RunExtendedValidation
* @description      This class is being called from - ProdSubfeatureClientUsageHelper

*********************************************************************************************
Version     Date       Team          Comments
*********************************************************************************************
* 1         Apr 2021    Yuvaraj          Initial Creation
*********************************************************************************************/
public class RunExtendedValidation{
    public static Double getUtilizationPercentage(String subfeature, String jsonInput,string accountId){
        switch on subfeature{
            when 'Lead Settings'{
                double usage=LeadSettingsUtilization.getUtilization(jsonInput,accountId);
                return usage;
            }
            when else{
                return 0.0;
            }
        }        
    }
}
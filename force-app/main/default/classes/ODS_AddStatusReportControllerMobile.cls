/**
 * @author           Indumathi.V
 * @version          1.0 
 * @date             07-OCT-2016
 * @Status           Developed
 * @description      This is the controller class for Add Status report Page
 *
 */


global class ODS_AddStatusReportControllerMobile extends ODS_AddStatusReportController
{


    /// <OBJECTIVE>
    /// Constructor.
    /// </OBJECTIVE>
    public ODS_AddStatusReportControllerMobile() 
    {
          super.isMobile = true;
         
    }
    
    public static List<SelectOption> GetAccountPicklistValues()
    {
         return ODS_AddStatusReportController.GetAccountPicklistValues(); 
    }
    
}
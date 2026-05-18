global class ODS_StatusReportControllerMobile extends ODS_StatusReportController
{
    public boolean blShow {get;set;}    
    public void show(){
        blShow = true;  
    }
    public void hide(){
        blShow = false;
    }
    
    public ODS_StatusReportControllerMobile() 
    {
        super.isMobile = true; //Referring the Variable from the base class ODS_StatusReportController        
    }
    
    public static List<SelectOption> GetStatusPicklistValues()
    {
        return ODS_StatusReportController.GetStatusPicklistValues();  
    }
}
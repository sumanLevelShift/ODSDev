public with sharing class CreateRemoteSiteSettings {
    
    public static void createRemoteSitess(string url, string description ,Boolean isActive , Boolean disableProtocolSecurity)
    {   
        try{
            String regExp= '[^\\w\\s]';
            string devName=url.replaceAll('/','');
            string devName1=devName.replaceAll('--','_');
            string devName2=devName1.replaceAll(regExp,'_');
            string fullname=devName2.substring(0, 35);
            
            system.debug('fullname-'+fullname);
            MetadataService.MetadataPort service = createService();
            MetadataService.RemoteSiteSetting remoteSiteSettings = new MetadataService.RemoteSiteSetting();
            
            remoteSiteSettings.fullName = fullname ;
            remoteSiteSettings.url = URL;
            remoteSiteSettings.description=Description;
            remoteSiteSettings.isActive=ISActive;
            remoteSiteSettings.disableProtocolSecurity=DisableProtocolSecurity;
            MetadataService.AsyncResult[] results = service.create(new List<MetadataService.Metadata> { remoteSiteSettings });
            MetadataService.AsyncResult[] checkResults = service.checkStatus(new List<string> {string.ValueOf(results[0].Id)});
        }catch(Exception e){
            system.debug('exception-'+e.getMessage());
            system.debug('exception-'+e.getLineNumber());
            
        }
    }
    
    public static MetadataService.MetadataPort createService()
    {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }
}
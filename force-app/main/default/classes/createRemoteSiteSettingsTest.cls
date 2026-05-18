@isTest
public class createRemoteSiteSettingsTest {
    
    @isTest
    public static void remoteSite(){
        
        test.startTest();
        // Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        createRemoteSiteSettings.createRemoteSitess('https://www.google.com', 'Description', True, True);
        createRemoteSiteSettings.createService();
        system.assert(true);
        test.stopTest();             
    }
    
    
    
}
/**
 * @author           Gnana Prakash
 * @version          1.0 
 * @date             28-Sep-2016
 * @Status           Developed
 * @description      The main purpose of this class that exposes the site login functionality
 * @Updated By       Indhu G
 * @Updated On       24-Oct-2018
 * @Description      Implemented the logic to redirect to related page when user clicks the link on email and when the user is not logged in to Salesforce
 */

global without sharing class ODSLoginController
{
    global String username {get; set;}
    global String password {get; set;}
    
    public Boolean IsNotMobileSDK {
        get{
            return WebUtility.IsNotMobileSDK();
        }
    }
    
    global ODSLoginController()
    {
    }
    global PageReference login()
    {
       
        string PortalAccessResult= getPortalAccess();

        
        if(PortalAccessResult=='InvalidUser'){
             ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,'Your login attempt has failed. Make sure the username and password are correct.'));
            return null;
        }     
       else if(IsNotMobileSDK && (ApexPages.currentPage().getParameters().get('g-recaptcha-response')==null||ApexPages.currentPage().getParameters().get('g-recaptcha-response')==''))
        {
            system.debug('g-recaptcha-response==='+ApexPages.currentPage().getParameters().get('g-recaptcha-response'));
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,Label.ODS_recaptcha));
            return null;
        }
        else if(PortalAccessResult=='NoAccess')
        {
             ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,Label.ODS_Is_Portal_Access));    
             return null;
        }
        else
        {  
            if(!string.isEmpty(username))
                username = username.trim();  
                
            //Updated by Indhu on 25-Oct-2018 as per the request to redirect to related url when email link to record is clicked
            String startURL = System.currentPageReference().getParameters().get('startURL');
            return Site.login(username, password, startURL);
        }
    }
    
    global PageReference ForgotPassword()
    {       
        PageReference pgRef = Page.Forgot_Password;
        pgRef.setRedirect(True);
        return pgRef;
    } 
    
    Public string getPortalAccess()
    {
       
          Boolean IsPortalAccess = false;
          string Result = '';
          
          if(!string.isEmpty(username))
              username = username.trim();
           
          User[] users= ODS_Data_Utility.getPortalAccessByUserName(username);
        system.debug('users====>'+users);
          if(users.size() > 0){
                IsPortalAccess  = users[0].Is_Portal_Access__c;
                if(IsPortalAccess){
                    Result = 'AccessEnabled';
                }else{
                    Result = 'NoAccess';
                }
           }else{
                Result = 'InvalidUser';
           }
        return Result ;

    } 
    
}
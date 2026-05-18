/*******************************************************************************************
* @author           Gireesh
* @version          1.0 
* @Status           Development Completed
* @Class Name       CreateContactAPI_Test
* @description      This is the test class For CreateContactAPI class
*********************************************************************************************
Version     Date        	Team        	Comments
*********************************************************************************************
* 1        	01-APR-2021    	DemandBlue 		Initial Development
*********************************************************************************************/
@isTest
public class CreateContactAPI_Test{    
    public static testMethod void testHttpPost() {
        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/createContact'; //Request URL
        req.httpMethod = 'POST';
        String reqBody = '{"Title":"developer","Status":null,"RoleLevel":null,"ReportsToId":"0037i00000kCpLqAAK","Phone":"8015128339","OtherStreet":"","OtherState":"","OtherPostalCode":"","OtherCountry":"","OtherCity":"","ODSDotNetStatus":null,"Name":null,"MobilePhone":"9876543210","MailingStreet":"NELLOREPALLI","MailingState":"ca","MailingPostalCode":"524413","MailingCountry":"India","MailingCity":"SPSR Nellore","LastName":"Wrapper2","isPrimary":false,"IsPortalAccess":false,"Id":null,"HasOptedOutOfEmail":false,"FirstName":"Gireesh","Email":"gireesh_k@preludesys.com","AccountId":"0013D00000opXTeQAM"}';
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response= res;
        //"Id":"0037i00000kCtDdAAK"
        Test.startTest();        
        CreateContactAPI.createContactNew();
        Test.stopTest();        
    }
}
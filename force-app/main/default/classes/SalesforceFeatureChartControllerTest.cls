@isTest
public class SalesforceFeatureChartControllerTest {
    @isTest
    public static void productChart(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);
        
        system.runAs(portalAccountOwner1) {
            ODS_Data_Utility odsUtil = new ODS_Data_Utility(null);
            
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account newAccount = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                            'California', True,2000,'9433578865', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, newAccount.Id, 'Others', 'ODS Project');                      
            contact1.Is_Approver__c = True;
            update contact1;
            
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('Salesforce','test',true);                        
            
            Contact_Account_Service__c cas = new Contact_Account_Service__c();
            cas.Account__c = newAccount.Id;
            cas.Contact__c = contact1.Id;
            cas.Is_Approver__c = true;
            cas.ODS_Service__c = odsSrv.Id;
            cas.Type_of_Engagement__c = 'ODS';
            insert cas; 
            
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',newAccount.Id,odsSrv.Id);
            
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(newAccount.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            usrAcc.Role_in_Account__c = 'Account Partner';            
            update usrAcc;
            
            string strPrjtTeaMbId = string.valueOf(ObjTeamMembr.Id);
            date strtDt =  System.Today().addYears(-1);
            date endDt = System.Today().addYears(2);
            Date Startdte = System.Today().addYears(-1);
            Date Enddte = System.Today().addYears(2);
            Date thisMonthStart = System.Today().toStartOfMonth();
            Integer thisMonthDays = Date.daysInMonth(System.Today().year(),System.Today().month());
            Date thisMonthEnd = Date.newInstance(System.Today().year(),System.Today().month(),thisMonthDays);
            
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(newAccount.id,strtDt, endDt,
                                                                                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'Salesforce');
            accSrvc.Invoice_Frequency__c = 'Monthly';
            accSrvc.Contract_Term__c = 'Net 30';
            update accSrvc;
            
                       
            Salesforce_Product__c newSalesforceProducttest=new Salesforce_Product__c();
            newSalesforceProducttest.Name='Sales Cloud';
            newSalesforceProducttest.Product_Percentage__c=100;
            newSalesforceProducttest.Description__c='test';
            insert newSalesforceProducttest;
            
            Salesforce_Product_Feature__c newSalesforceProductFeatureTest=new Salesforce_Product_Feature__c();
            newSalesforceProductFeatureTest.Name='Lead Management';
            newSalesforceProductFeatureTest.Salesforce_Product__c=newSalesforceProducttest.id;
            newSalesforceProductFeatureTest.Client_Usage_Percentage__c=100;
            newSalesforceProductFeatureTest.Feature_Percentage__c=100;
            newSalesforceProductFeatureTest.Description__c='<span style="font-size: 11pt;">\\<.*?\\><span style=""><span style="font-family: Calibri,sans-serif;"><span style=""><span style="color: #202124;">Asset Management allows service representatives to easily track what their customer recently purchased relevant to the company products and also have a look on the status of the purchased product whether it is installed or not. Assets represent purchased or installed products, and are an essential piece of the Salesforce puzzle. You can link assets to maintenance plans, entitlements, work orders, and more so your support team can quickly assess the history of a customer&#39;s product.</span></span></span></span></span><br> ';
            insert newSalesforceProductFeatureTest;   
            
            SF_Feature_Details__c sfFTest=new SF_Feature_Details__c();
            sfFTest.Feature_ID__c=newSalesforceProductFeatureTest.id;
            sfFTest.IsActive__c=true;
            insert sfFTest;
            
            Salesforce_Product_Subfeature__c newSalesforceSubFeature=new Salesforce_Product_Subfeature__c();
            newSalesforceSubFeature.Name='Contact Validation Rule';
            newSalesforceSubFeature.Client_Usage_Percentage__c=100;
            newSalesforceSubFeature.Salesforce_Product_Feature__c=newSalesforceProductFeatureTest.id;
            newSalesforceSubFeature.Subfeature_Percentage__c=89;
            newSalesforceSubFeature.Description__c='<span style="font-size: 11pt;">\\<.*?\\><span style=""><span style="font-family: Calibri,sans-serif;"><span style=""><span style="color: #202124;">Asset Management allows service representatives to easily track what their customer recently purchased relevant to the company products and also have a look on the status of the purchased product whether it is installed or not. Assets represent purchased or installed products, and are an essential piece of the Salesforce puzzle. You can link assets to maintenance plans, entitlements, work orders, and more so your support team can quickly assess the history of a customer&#39;s product.</span></span></span></span></span><br> ';
            insert newSalesforceSubFeature;
            
            Salesforce_Product_Subfeature__c newSalesforceSubFeature1=new Salesforce_Product_Subfeature__c();
            newSalesforceSubFeature1.Name='Dashboard on Contact Reports';
            newSalesforceSubFeature1.Client_Usage_Percentage__c=100;
            newSalesforceSubFeature1.Salesforce_Product_Feature__c=newSalesforceProductFeatureTest.id;
            newSalesforceSubFeature1.Subfeature_Percentage__c=90;
            newSalesforceSubFeature1.Description__c='<span style="font-size: 11pt;">\\<.*?\\><span style=""><span style="font-family: Calibri,sans-serif;"><span style=""><span style="color: #202124;">Asset Management allows service representatives to easily track what their customer recently purchased relevant to the company products and also have a look on the status of the purchased product whether it is installed or not. Assets represent purchased or installed products, and are an essential piece of the Salesforce puzzle. You can link assets to maintenance plans, entitlements, work orders, and more so your support team can quickly assess the history of a customer&#39;s product.</span></span></span></span></span><br> ';
            insert newSalesforceSubFeature1;
            
            Salesforce_Subfeature_Rules__c newSalesforceSubfeatureRules=new Salesforce_Subfeature_Rules__c();
            newSalesforceSubfeatureRules.Name='Web to lead Check';
            newSalesforceSubfeatureRules.Salesforce_Product_Subfeature__c=newSalesforceSubFeature.id;
            newSalesforceSubfeatureRules.Type__c='Manual';
            newSalesforceSubfeatureRules.Rest_API_Name__c='';
            newSalesforceSubfeatureRules.Rule__c='';
            insert newSalesforceSubfeatureRules;
            
            Product_Client_Usage__c newProductClientUsage=new Product_Client_Usage__c();
            newProductClientUsage.Account__c=newAccount.id;
            newProductClientUsage.Salesforce_Product__c=newSalesforceProducttest.id;
            newProductClientUsage.Salesforce_Product_Usage__c=100;
            insert newProductClientUsage;
            
            Product_Feature_Client_Usage__c newProductFeatureClient=new Product_Feature_Client_Usage__c();
            newProductFeatureClient.Product_Client_Usage__c=newProductClientUsage.id;
            newProductFeatureClient.Account__c=newAccount.id;
            newProductFeatureClient.Salesforce_Product__c=newSalesforceProducttest.id;
            newProductFeatureClient.Salesforce_Product_Feature__c=newSalesforceProductFeatureTest.id;
            newProductFeatureClient.Client_Usage_Percentage__c=100;
            newProductFeatureClient.Feature_Percentage__c=100;
            insert newProductFeatureClient;
            
            Product_Subfeature_Client_Usage__c newPSCU=new Product_Subfeature_Client_Usage__c();
            newPSCU.Account__c=newAccount.id;
            newPSCU.Client_Usage_Percentage__c=0;
            newPSCU.Name='Contact Validation Rule';
            newPSCU.Salesforce_Product__c=newSalesforceProducttest.id;
            newPSCU.Salesforce_Product_Feature__c=newSalesforceProductFeatureTest.id;
            newPSCU.Salesforce_Product_Subfeature__c=newSalesforceSubFeature.id;
            newPSCU.Subfeature_Weightage__c=90;
            newPSCU.Product_Feature_Client_Usage__c=newProductFeatureClient.id;
            insert newPSCU;
            
            Product_Subfeature_Client_Usage__c newPSCU1=new Product_Subfeature_Client_Usage__c();
            newPSCU1.Account__c=newAccount.id;
            newPSCU1.Client_Usage_Percentage__c=0;
            newPSCU1.Name='Dashboard on Contact Reports';
            newPSCU1.Salesforce_Product__c=newSalesforceProducttest.id;
            newPSCU1.Salesforce_Product_Feature__c=newSalesforceProductFeatureTest.id;
            newPSCU1.Salesforce_Product_Subfeature__c=newSalesforceSubFeature1.id;
            newPSCU1.Subfeature_Weightage__c=90;
            newPSCU.Product_Feature_Client_Usage__c=newProductFeatureClient.id;
            insert newPSCU1;
            
            List<Salesforce_Product__c> salesforceProductList=[Select Id,Name From Salesforce_Product__c limit 1];
            
            system.assertEquals(salesforceProductList.size(), 1);
            system.assertEquals(salesforceProductList[0].Name, 'Sales Cloud');
            
            ODS_SessionData__c objSessiondata = new ODS_SessionData__c();
            objSessiondata.Name = 'Test';
            objSessiondata.Account_Id__c = newAccount.id;
            objSessiondata.Current_user_Id__c = portalAccountOwner1.id;
            objSessiondata.Service_Id__c = 'All';
            insert objSessiondata ;
            
            Attachment attachment = new Attachment();
            attachment.Body = EncodingUtil.base64Decode('test');
            attachment.Name = 'productCloud.png';
            attachment.ParentId = accSrvc.id; 
            insert attachment;
            
            Test.startTest();
            SalesforceFeatureChartController obj=new SalesforceFeatureChartController();
            obj.AccountId=newAccount.id;
            obj.productImageUrl=EncodingUtil.base64Encode(Blob.valueOf('emp'));
           /* PageReference pageRef = Page.OdsSalesforceFeatureChart;
            pageRef.getParameters().put('SelectedAccountId', newAccount.id);
            pageRef.getParameters().put('SelectedServiceID', '');
            pageRef.getParameters().put('productImageUrl', string.valueOf(blob.valueOf('test world')));*/
            obj.downloadHeatMapReport();
            obj.GetAccountServiceID();
            system.assertEquals(attachment.ParentId ,accSrvc.id);
            Test.stopTest();
        }
    }
}
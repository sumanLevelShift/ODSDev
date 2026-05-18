@isTest()
public class UpdateChartColorHelperTest {
    @isTest()
    public static void productTest(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                  'en_US','en_US',profile.Id,'America/Chicago',System.now().millisecond() + 
                                                                                  'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                                     
        System.runAs (portalAccountOwner)
        {
            Salesforce_Product__c newSalesforceProducttest=new Salesforce_Product__c();
            newSalesforceProducttest.Name='Sales Cloud';
            newSalesforceProducttest.Product_Percentage__c=100;
            insert newSalesforceProducttest;
            
            Salesforce_Product_Feature__c newSalesforceProductFeatureTest=new Salesforce_Product_Feature__c();
            newSalesforceProductFeatureTest.Name='Lead Management';
            newSalesforceProductFeatureTest.Salesforce_Product__c=newSalesforceProducttest.id;
            newSalesforceProductFeatureTest.Client_Usage_Percentage__c=100;
            newSalesforceProductFeatureTest.Feature_Percentage__c=100;
            insert newSalesforceProductFeatureTest;   
            
            SF_Feature_Details__c sfFTest=new SF_Feature_Details__c();
            sfFTest.Feature_ID__c=newSalesforceProductFeatureTest.id;
            sfFTest.IsActive__c=true;
            insert sfFTest;
            
            Account newAccount = new Account();
            newAccount.Name = 'TestAccount';
            newAccount.OwnerID = portalAccountOwner.Id;
            newAccount.Is_Portal_Access__c = True;
            newAccount.AnnualRevenue = 666;
            newAccount.Phone = '95543567654';
            newAccount.Lead_Gen_Name__c = 'Others';
            newAccount.If_Others_Please_Specify__c = 'Others';
            newAccount.NumberofEmployees = 100;
            newAccount.Industry = 'Nonprofit';
            insert newAccount;
            
            ODS_Services__c odsServices = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
            User_Account__c userAccount = ODS_DataFactory_Test_Utility.insertUsrAccnt(newAccount.id,'Technical Account Manager',portalAccountOwner.Id,odsServices.Id);
            date accountServiceStartDate =  Date.today();
            date accountServiceEndDate = accountServiceStartDate.adddays(5);
            Account_Services__c accountServices = ODS_DataFactory_Test_Utility.insertAccountServices(newAccount.id,accountServiceStartDate, accountServiceEndDate,
                                                                                                     150.0, odsServices.id, 1000, 'Monthly', portalAccountOwner.Id, 'GGF');   
            
            
            Salesforce_Product_Feature__c newSalesforceProductFeature=new Salesforce_Product_Feature__c();
            newSalesforceProductFeature.Name='Account and Contact Management';
            newSalesforceProductFeature.Salesforce_Product__c=newSalesforceProducttest.id;
            newSalesforceProductFeature.Client_Usage_Percentage__c=100;
            newSalesforceProductFeature.Feature_Percentage__c=100;
            insert newSalesforceProductFeature;   
            
            SF_Feature_Details__c sf=new SF_Feature_Details__c();
            sf.Feature_ID__c=newSalesforceProductFeature.id;
            sf.IsActive__c=true;
            insert sf;
            
            Product_Client_Usage__c newProductClientUsage=new Product_Client_Usage__c();
            newProductClientUsage.Account__c=newAccount.id;
            newProductClientUsage.Salesforce_Product__c=newSalesforceProducttest.id;
            newProductClientUsage.Salesforce_Product_Usage__c=100;
            insert newProductClientUsage;
            
            Product_Feature_Client_Usage__c newProductFeatureClient=new Product_Feature_Client_Usage__c();
            newProductFeatureClient.Product_Client_Usage__c=newProductClientUsage.id;
            newProductFeatureClient.Account__c=newAccount.id;
            newProductFeatureClient.Salesforce_Product__c=newSalesforceProducttest.id;
            newProductFeatureClient.Salesforce_Product_Feature__c=newSalesforceProductFeature.id;
            newProductFeatureClient.Client_Usage_Percentage__c=100;
            newProductFeatureClient.Feature_Percentage__c=100;
            insert newProductFeatureClient;
            
            Salesforce_Product_Subfeature__c newSalesforceSubFeature=new Salesforce_Product_Subfeature__c();
            newSalesforceSubFeature.Name='Contact Validation Rule';
            newSalesforceSubFeature.Client_Usage_Percentage__c=100;
            newSalesforceSubFeature.Salesforce_Product_Feature__c=newSalesforceProductFeature.id;
            newSalesforceSubFeature.Subfeature_Percentage__c=89;
            insert newSalesforceSubFeature;
            
            Salesforce_Product_Subfeature__c newSalesforceSubFeature1=new Salesforce_Product_Subfeature__c();
            newSalesforceSubFeature1.Name='Dashboard on Contact Reports';
            newSalesforceSubFeature1.Client_Usage_Percentage__c=100;
            newSalesforceSubFeature1.Salesforce_Product_Feature__c=newSalesforceProductFeature.id;
            newSalesforceSubFeature1.Subfeature_Percentage__c=90;
            insert newSalesforceSubFeature1;
            
            Salesforce_Subfeature_Rules__c newSalesforceSubfeatureRules=new Salesforce_Subfeature_Rules__c();
            newSalesforceSubfeatureRules.Name='Web to lead Check';
            newSalesforceSubfeatureRules.Salesforce_Product_Subfeature__c=newSalesforceSubFeature.id;
            newSalesforceSubfeatureRules.Type__c='Manual';
            newSalesforceSubfeatureRules.Rest_API_Name__c='';
            newSalesforceSubfeatureRules.Rule__c='';
            insert newSalesforceSubfeatureRules;
            
            Salesforce_Subfeature_Rules__c newSalesforceSubfeatureRules1=new Salesforce_Subfeature_Rules__c();
            newSalesforceSubfeatureRules1.Name='Einstein Lead Scoring Check';
            newSalesforceSubfeatureRules1.Salesforce_Product_Subfeature__c=newSalesforceSubFeature1.id;
            newSalesforceSubfeatureRules1.Type__c='Manual';
            newSalesforceSubfeatureRules1.Rest_API_Name__c='';
            newSalesforceSubfeatureRules1.Rule__c='';
            insert newSalesforceSubfeatureRules1;
            
            Product_Subfeature_Client_Usage__c newPSCU=new Product_Subfeature_Client_Usage__c();
            newPSCU.Account__c=newAccount.id;
            newPSCU.Client_Usage_Percentage__c=0;
            newPSCU.Name='Contact Validation Rule';
            newPSCU.Salesforce_Product__c=newSalesforceProducttest.id;
            newPSCU.Salesforce_Product_Feature__c=newSalesforceProductFeature.id;
            newPSCU.Salesforce_Product_Subfeature__c=newSalesforceSubFeature.id;
            newPSCU.Subfeature_Weightage__c=90;
            insert newPSCU;
            
            Product_Subfeature_Client_Usage__c newPSCU1=new Product_Subfeature_Client_Usage__c();
            newPSCU1.Account__c=newAccount.id;
            newPSCU1.Client_Usage_Percentage__c=0;
            newPSCU1.Name='Dashboard on Contact Reports';
            newPSCU1.Salesforce_Product__c=newSalesforceProducttest.id;
            newPSCU1.Salesforce_Product_Feature__c=newSalesforceProductFeature.id;
            newPSCU1.Salesforce_Product_Subfeature__c=newSalesforceSubFeature1.id;
            newPSCU1.Subfeature_Weightage__c=90;
            insert newPSCU1;
            
            Salesforce_Product__c newSalesforceProduct2=new Salesforce_Product__c();
            newSalesforceProduct2.Name='Sales Cloud';
            newSalesforceProduct2.Product_Percentage__c=100;
            insert newSalesforceProduct2;
            
            Salesforce_Product_Feature__c newSalesforceProductFeature1=new Salesforce_Product_Feature__c();
            newSalesforceProductFeature1.Name='Account and Contact Management';
            newSalesforceProductFeature1.Salesforce_Product__c=newSalesforceProduct2.id;
            newSalesforceProductFeature1.Client_Usage_Percentage__c=100;
            newSalesforceProductFeature1.Feature_Percentage__c=100;
            insert newSalesforceProductFeature1;
            
            Salesforce_Product_Subfeature__c newSalesforceSubFeature3=new Salesforce_Product_Subfeature__c();
            newSalesforceSubFeature3.Name='Dashboard on Contact Reports';
            newSalesforceSubFeature3.Client_Usage_Percentage__c=100;
            newSalesforceSubFeature3.Salesforce_Product_Feature__c=newSalesforceProductFeature1.id;
            newSalesforceSubFeature3.Subfeature_Percentage__c=90;
            insert newSalesforceSubFeature3;
            
            Salesforce_Subfeature_Rules__c newSalesforceSubfeatureRules3=new Salesforce_Subfeature_Rules__c();
            newSalesforceSubfeatureRules3.Name='Web to lead Check';
            newSalesforceSubfeatureRules3.Salesforce_Product_Subfeature__c=newSalesforceSubFeature3.id;
            newSalesforceSubfeatureRules3.Type__c='Manual';
            newSalesforceSubfeatureRules3.Rest_API_Name__c='';
            newSalesforceSubfeatureRules3.Rule__c='';
            insert newSalesforceSubfeatureRules3;
            system.assertEquals(newSalesforceSubfeatureRules3.Type__c,'Manual');
            
        }
    }
}
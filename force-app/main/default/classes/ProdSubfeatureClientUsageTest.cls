@isTest
public class ProdSubfeatureClientUsageTest {
    @isTest
    public static void updateMetadataTest(){
        ClientAndNamedCredMapping__mdt clientandNameCred1=[SELECT Account_Id__c,DeveloperName,Id,Is_Active__c,Label,Language,Last_Run_Date_Time__c,MasterLabel,Named_Credentail__c,NamespacePrefix,Next_Run_Date_Time__c,QualifiedApiName,Schedule_Frequency__c,Username__c,Use_Connected_App__c FROM ClientAndNamedCredMapping__mdt where Is_Active__c=:True and Account_Id__c !=:null and Account_Id__c !=:'NOT_FOUND' and Account_Id__c !=:'NEW' AND In_progress__c=false Limit 1];
        
        String accountID = clientandNameCred1.Account_Id__c;
        Salesforce_Product__c newSalesforceProduct=new Salesforce_Product__c();
        newSalesforceProduct.Name='Sales Cloud';
        newSalesforceProduct.Product_Percentage__c=100;
        newSalesforceProduct.Description__c='test';
        insert newSalesforceProduct;
        
        Salesforce_Product_Feature__c newSalesforceProductFeature=new Salesforce_Product_Feature__c();
        newSalesforceProductFeature.Name='Lead Management';
        newSalesforceProductFeature.Salesforce_Product__c=newSalesforceProduct.id;
        newSalesforceProductFeature.Client_Usage_Percentage__c=100;
        newSalesforceProductFeature.Feature_Percentage__c=100;
        insert newSalesforceProductFeature;
        
        Product_Client_Usage__c newProductClientUsage=new Product_Client_Usage__c();
        newProductClientUsage.Account__c=accountID;
        newProductClientUsage.Salesforce_Product__c=newSalesforceProduct.id;
        newProductClientUsage.Salesforce_Product_Usage__c=100;
        insert newProductClientUsage;
        
        Product_Feature_Client_Usage__c newProductFeatureClient=new Product_Feature_Client_Usage__c();
        newProductFeatureClient.Product_Client_Usage__c=newProductClientUsage.id;
        newProductFeatureClient.Account__c=accountID;
        newProductFeatureClient.Salesforce_Product__c=newSalesforceProduct.id;
        newProductFeatureClient.Salesforce_Product_Feature__c=newSalesforceProductFeature.id;
        newProductFeatureClient.Client_Usage_Percentage__c=100;
        newProductFeatureClient.Feature_Percentage__c=100;
        insert newProductFeatureClient;
        
        Salesforce_Product_Subfeature__c newSalesforceSubFeature2Con=new Salesforce_Product_Subfeature__c();
        newSalesforceSubFeature2Con.Name='Contact Duplicate Rule';
        newSalesforceSubFeature2Con.Client_Usage_Percentage__c=100;
        newSalesforceSubFeature2Con.Salesforce_Product_Feature__c=newSalesforceProductFeature.id;
        newSalesforceSubFeature2Con.Subfeature_Percentage__c=90;
        insert newSalesforceSubFeature2Con;
        
        Salesforce_Product_Subfeature__c newSalesforceSubFeature2Mobile=new Salesforce_Product_Subfeature__c();
        newSalesforceSubFeature2Mobile.Name='MobileSettingsAssignment';
        newSalesforceSubFeature2Mobile.Client_Usage_Percentage__c=100;
        newSalesforceSubFeature2Mobile.Salesforce_Product_Feature__c=newSalesforceProductFeature.id;
        newSalesforceSubFeature2Mobile.Subfeature_Percentage__c=90;
        insert newSalesforceSubFeature2Mobile;
        
        Salesforce_Product_Subfeature__c newSalesforceSubFeature2Feed=new Salesforce_Product_Subfeature__c();
        newSalesforceSubFeature2Feed.Name='Feed';
        newSalesforceSubFeature2Feed.Client_Usage_Percentage__c=100;
        newSalesforceSubFeature2Feed.Salesforce_Product_Feature__c=newSalesforceProductFeature.id;
        newSalesforceSubFeature2Feed.Subfeature_Percentage__c=90;
        insert newSalesforceSubFeature2Feed;
        
        Salesforce_Subfeature_Rules__c newSalesforceSubfeatureRules3=new Salesforce_Subfeature_Rules__c();
        newSalesforceSubfeatureRules3.Name='Contact Duplicate Rule Check';
        newSalesforceSubfeatureRules3.Salesforce_Product_Subfeature__c=newSalesforceSubFeature2Con.id;
        newSalesforceSubfeatureRules3.Type__c='Query';
        newSalesforceSubfeatureRules3.Rest_API_Name__c='query';
        newSalesforceSubfeatureRules3.Has_Extended_Validation__c=true;
        newSalesforceSubfeatureRules3.Active__c=true;
        newSalesforceSubfeatureRules3.Rule__c='SELECT Id FROM DuplicateRule';
        newSalesforceSubfeatureRules3.Subfeature_Rule_Percentage__c=100;
        newSalesforceSubfeatureRules3.IsRuleHelperApplicable__c=true;
        insert newSalesforceSubfeatureRules3;
        
        Salesforce_Subfeature_Rule_Constraint__c newSalesforceSubfeatureConstraint4=new Salesforce_Subfeature_Rule_Constraint__c();
        newSalesforceSubfeatureConstraint4.Name='Contact Duplicate Rule Constraint';
        newSalesforceSubfeatureConstraint4.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules3.id;
        newSalesforceSubfeatureConstraint4.Usage_Percentage__c=100;
        newSalesforceSubfeatureConstraint4.Execution_Order__c=1;
        newSalesforceSubfeatureConstraint4.Constraint__c='IsActive = true';
        insert newSalesforceSubfeatureConstraint4;
        
        Salesforce_Subfeature_Rule_Helper__c helperRec=new Salesforce_Subfeature_Rule_Helper__c();
        helperRec.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules3.id;
        helperRec.Record_Count_Size__c=3;
        helperRec.Usage_Percentage__c=100;
        insert helperRec;
        
        Salesforce_Subfeature_Rule_Helper__c helperRecV1=new Salesforce_Subfeature_Rule_Helper__c();
        helperRecV1.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules3.id;
        helperRecV1.Record_Count_Size__c=2;
        helperRecV1.Usage_Percentage__c=100;
        insert helperRecV1;
        
        Salesforce_Subfeature_Rules__c newSalesforceSubfeatureRules4=new Salesforce_Subfeature_Rules__c();
        newSalesforceSubfeatureRules4.Name='Contact Validation Rule Check';
        newSalesforceSubfeatureRules4.Salesforce_Product_Subfeature__c=newSalesforceSubFeature2Con.id;
        newSalesforceSubfeatureRules4.Type__c='Query';
        newSalesforceSubfeatureRules4.Rest_API_Name__c='query';
        newSalesforceSubfeatureRules4.Has_Extended_Validation__c=false;
        newSalesforceSubfeatureRules4.Active__c=true;
        newSalesforceSubfeatureRules4.Rule__c='SELECT Id FROM ValidationRule';
        newSalesforceSubfeatureRules4.Subfeature_Rule_Percentage__c=100;
        newSalesforceSubfeatureRules4.IsRuleHelperApplicable__c=true;
        insert newSalesforceSubfeatureRules4;
        
        Salesforce_Subfeature_Rule_Constraint__c newSalesforceSubfeatureConstraint2=new Salesforce_Subfeature_Rule_Constraint__c();
        newSalesforceSubfeatureConstraint2.Name='Contact Validation Rule Constraint';
        newSalesforceSubfeatureConstraint2.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules4.id;
        newSalesforceSubfeatureConstraint2.Usage_Percentage__c=100;
        newSalesforceSubfeatureConstraint2.Execution_Order__c=1;
        newSalesforceSubfeatureConstraint2.Constraint__c='IsActive = true';
        insert newSalesforceSubfeatureConstraint2;
        
        Salesforce_Subfeature_Rule_Helper__c helperRec1=new Salesforce_Subfeature_Rule_Helper__c();
        helperRec1.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules4.id;
        helperRec1.Record_Count_Size__c=1;
        helperRec1.Usage_Percentage__c=100;
        insert helperRec1;
        
        Salesforce_Subfeature_Rules__c newSalesforceSubfeatureRules5=new Salesforce_Subfeature_Rules__c();
        newSalesforceSubfeatureRules5.Name='MobileSettingsAssignment';
        newSalesforceSubfeatureRules5.Salesforce_Product_Subfeature__c=newSalesforceSubFeature2Mobile.id;
        newSalesforceSubfeatureRules5.Type__c='Query';
        newSalesforceSubfeatureRules5.Rest_API_Name__c='query';
        newSalesforceSubfeatureRules5.Has_Extended_Validation__c=false;
        newSalesforceSubfeatureRules5.Active__c=true;
        newSalesforceSubfeatureRules5.Rule__c='SELECT Id FROM ValidationRule';
        newSalesforceSubfeatureRules5.Subfeature_Rule_Percentage__c=100;
        newSalesforceSubfeatureRules5.IsRuleHelperApplicable__c=true;
        insert newSalesforceSubfeatureRules5;
        
        Salesforce_Subfeature_Rule_Constraint__c newSalesforceSubfeatureConstraint3=new Salesforce_Subfeature_Rule_Constraint__c();
        newSalesforceSubfeatureConstraint3.Name='MobileSettingsAssignment Constraint';
        newSalesforceSubfeatureConstraint3.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules5.id;
        newSalesforceSubfeatureConstraint3.Usage_Percentage__c=100;
        newSalesforceSubfeatureConstraint3.Execution_Order__c=1;
        newSalesforceSubfeatureConstraint3.Constraint__c='IsActive = true';
        insert newSalesforceSubfeatureConstraint3;
        
        Salesforce_Subfeature_Rule_Helper__c helperRec2=new Salesforce_Subfeature_Rule_Helper__c();
        helperRec2.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules5.id;
        helperRec2.Record_Count_Size__c=1;
        helperRec2.Usage_Percentage__c=100;
        insert helperRec2;
        Salesforce_Subfeature_Rule_Helper__c helperRec2V2=new Salesforce_Subfeature_Rule_Helper__c();
        helperRec2V2.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules5.id;
        helperRec2V2.Record_Count_Size__c=2;
        helperRec2V2.Usage_Percentage__c=100;
        insert helperRec2V2;
        Salesforce_Subfeature_Rule_Helper__c helperRec2V3=new Salesforce_Subfeature_Rule_Helper__c();
        helperRec2V3.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules5.id;
        helperRec2V3.Record_Count_Size__c=3;
        helperRec2V3.Usage_Percentage__c=100;
        insert helperRec2V3;
        Salesforce_Subfeature_Rule_Helper__c helperRec2V4=new Salesforce_Subfeature_Rule_Helper__c();
        helperRec2V4.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules5.id;
        helperRec2V4.Record_Count_Size__c=4;
        helperRec2V4.Usage_Percentage__c=100;
        insert helperRec2V4;
        Salesforce_Subfeature_Rule_Helper__c helperRec2V5=new Salesforce_Subfeature_Rule_Helper__c();
        helperRec2V5.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules5.id;
        helperRec2V5.Record_Count_Size__c=5;
        helperRec2V5.Usage_Percentage__c=100;
        insert helperRec2V5;
        Salesforce_Subfeature_Rules__c newSalesforceSubfeatureRules6=new Salesforce_Subfeature_Rules__c();
        newSalesforceSubfeatureRules6.Name='Feed';
        newSalesforceSubfeatureRules6.Salesforce_Product_Subfeature__c=newSalesforceSubFeature2Feed.id;
        newSalesforceSubfeatureRules6.Type__c='Query';
        newSalesforceSubfeatureRules6.Rest_API_Name__c='query';
        newSalesforceSubfeatureRules6.Has_Extended_Validation__c=false;
        newSalesforceSubfeatureRules6.Active__c=true;
        newSalesforceSubfeatureRules6.Rule__c='SELECT Id FROM ValidationRule';
        newSalesforceSubfeatureRules6.Subfeature_Rule_Percentage__c=100;
        newSalesforceSubfeatureRules6.IsRuleHelperApplicable__c=true;
        insert newSalesforceSubfeatureRules6;
        
        Salesforce_Subfeature_Rule_Constraint__c newSalesforceSubfeatureConstraint5=new Salesforce_Subfeature_Rule_Constraint__c();
        newSalesforceSubfeatureConstraint5.Name='Feed Constraint';
        newSalesforceSubfeatureConstraint5.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules6.id;
        newSalesforceSubfeatureConstraint5.Usage_Percentage__c=100;
        newSalesforceSubfeatureConstraint5.Execution_Order__c=1;
        newSalesforceSubfeatureConstraint5.Constraint__c='IsActive = true';
        insert newSalesforceSubfeatureConstraint5;
        
        Salesforce_Subfeature_Rule_Helper__c helperRec3=new Salesforce_Subfeature_Rule_Helper__c();
        helperRec3.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules6.id;
        helperRec3.Record_Count_Size__c=1;
        helperRec3.Usage_Percentage__c=100;
        insert helperRec3;
        SF_Feature_Details__c sf=new SF_Feature_Details__c();
        sf.Feature_ID__c=newSalesforceProductFeature.id;
        sf.IsActive__c=true;
        insert sf;
        ProdSubfeatureClientUsageSchedular o=new ProdSubfeatureClientUsageSchedular();
        o.execute(null);
        ProdSubfeatureClientUsage_Constants psfcuc = new ProdSubfeatureClientUsage_Constants();
        ProdSubfeatureClientUsageHelper helper=new ProdSubfeatureClientUsageHelper();
        helper.getProdFeatureUsageRecToBeUpdated(newSalesforceProductFeature.id,newSalesforceProduct.id,accountID);
        ProdSubfeatureClientUsageController.updateCustomMetaData(accountID,Date.today());
        ClientAndNamedCredMapping__mdt clientandNameCred=[SELECT Account_Id__c,DeveloperName,Id,Is_Active__c,Label,Language,Last_Run_Date_Time__c,MasterLabel,Named_Credentail__c,NamespacePrefix,Next_Run_Date_Time__c,QualifiedApiName,Schedule_Frequency__c,Username__c,Use_Connected_App__c FROM ClientAndNamedCredMapping__mdt where Is_Active__c=:True and Account_Id__c !=:null and Account_Id__c !=:'NEW' and Account_Id__c !=:'NOT_FOUND' AND In_progress__c=false limit 1];
        clientandNameCred.Next_Run_Date_Time__c=null;
        clientandNameCred.Last_Run_Date_Time__c=null;
        CustomMetaDataUpdation.upsertMetadata(clientandNameCred);
        ProdSubfeatureClientUsageHelper.getDuplicateRuleLimitUsage(newSalesforceSubfeatureRules3.id,3);
        ProdSubfeatureClientUsageHelper.getDuplicateRuleLimitUsage(newSalesforceSubfeatureRules4.id,10);
        ProdSubfeatureClientUsageHelper.getDuplicateRuleLimitUsage(newSalesforceSubfeatureRules3.id,2);
        ProdSubfeatureClientUsageHelper.getDuplicateRuleLimitUsage(newSalesforceSubfeatureRules3.id,1);
        ProdSubfeatureClientUsageHelper.getDuplicateRuleLimitUsage(newSalesforceSubfeatureRules5.id,1);
        ProdSubfeatureClientUsageHelper.getDuplicateRuleLimitUsage(newSalesforceSubfeatureRules5.id,2);
        ProdSubfeatureClientUsageHelper.getDuplicateRuleLimitUsage(newSalesforceSubfeatureRules5.id,3);
        ProdSubfeatureClientUsageHelper.getDuplicateRuleLimitUsage(newSalesforceSubfeatureRules5.id,4);
        ProdSubfeatureClientUsageHelper.getDuplicateRuleLimitUsage(newSalesforceSubfeatureRules5.id,5);
        ProdSubfeatureClientUsageHelper.getDuplicateRuleLimitUsage(newSalesforceSubfeatureRules6.id,1);
        system.assertEquals(clientandNameCred.Is_Active__c, true);
        
    }
    @isTest
    public static void updateMetadataTest1(){
        ClientAndNamedCredMapping__mdt clientandNameCred1=[SELECT Account_Id__c,DeveloperName,Id,Is_Active__c,Label,Language,Last_Run_Date_Time__c,MasterLabel,Named_Credentail__c,NamespacePrefix,Next_Run_Date_Time__c,QualifiedApiName,Schedule_Frequency__c,Username__c,Use_Connected_App__c FROM ClientAndNamedCredMapping__mdt where Is_Active__c=:True and Account_Id__c !=:null and Account_Id__c !=:'NEW' and Account_Id__c !=:'NOT_FOUND' AND In_progress__c=false Limit 1];
        
        String accountID = clientandNameCred1.Account_Id__c;//Hard coded for now
        Salesforce_Product__c newSalesforceProduct=new Salesforce_Product__c();
        newSalesforceProduct.Name='Sales Cloud';
        newSalesforceProduct.Product_Percentage__c=100;
        newSalesforceProduct.Description__c='test';        
        insert newSalesforceProduct;
        
        Salesforce_Product_Feature__c newSalesforceProductFeature=new Salesforce_Product_Feature__c();
        newSalesforceProductFeature.Name='Lead Management';
        newSalesforceProductFeature.Salesforce_Product__c=newSalesforceProduct.id;
        newSalesforceProductFeature.Client_Usage_Percentage__c=100;
        newSalesforceProductFeature.Feature_Percentage__c=100;
        insert newSalesforceProductFeature;
        
        Salesforce_Product_Subfeature__c newSalesforceSubFeature2Con=new Salesforce_Product_Subfeature__c();
        newSalesforceSubFeature2Con.Name='Contact Duplicate Rule';
        newSalesforceSubFeature2Con.Client_Usage_Percentage__c=100;
        newSalesforceSubFeature2Con.Salesforce_Product_Feature__c=newSalesforceProductFeature.id;
        newSalesforceSubFeature2Con.Subfeature_Percentage__c=90;
        insert newSalesforceSubFeature2Con;
        
        Salesforce_Subfeature_Rules__c newSalesforceSubfeatureRules3=new Salesforce_Subfeature_Rules__c();
        newSalesforceSubfeatureRules3.Name='Contact Duplicate Rule Check';
        newSalesforceSubfeatureRules3.Salesforce_Product_Subfeature__c=newSalesforceSubFeature2Con.id;
        newSalesforceSubfeatureRules3.Type__c='Query';
        newSalesforceSubfeatureRules3.Rest_API_Name__c='query';
        newSalesforceSubfeatureRules3.Has_Extended_Validation__c=true;
        newSalesforceSubfeatureRules3.Active__c=true;
        newSalesforceSubfeatureRules3.Rule__c='SELECT Id FROM DuplicateRule';
        newSalesforceSubfeatureRules3.Subfeature_Rule_Percentage__c=100;
        newSalesforceSubfeatureRules3.IsRuleHelperApplicable__c=true;
        insert newSalesforceSubfeatureRules3;
        
        Salesforce_Subfeature_Rule_Constraint__c newSalesforceSubfeatureConstraint4=new Salesforce_Subfeature_Rule_Constraint__c();
        newSalesforceSubfeatureConstraint4.Name='Contact Duplicate Rule Constraint';
        newSalesforceSubfeatureConstraint4.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules3.id;
        newSalesforceSubfeatureConstraint4.Usage_Percentage__c=100;
        newSalesforceSubfeatureConstraint4.Execution_Order__c=1;
        newSalesforceSubfeatureConstraint4.Constraint__c='IsActive = true';
        insert newSalesforceSubfeatureConstraint4;
        
        Salesforce_Subfeature_Rule_Helper__c helperRec=new Salesforce_Subfeature_Rule_Helper__c();
        helperRec.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules3.id;
        helperRec.Record_Count_Size__c=13;
        helperRec.Usage_Percentage__c=100;
        insert helperRec;
        
        Salesforce_Subfeature_Rules__c newSalesforceSubfeatureRules4=new Salesforce_Subfeature_Rules__c();
        newSalesforceSubfeatureRules4.Name='Contact Validation Rule Check';
        newSalesforceSubfeatureRules4.Salesforce_Product_Subfeature__c=newSalesforceSubFeature2Con.id;
        newSalesforceSubfeatureRules4.Type__c='Query';
        newSalesforceSubfeatureRules4.Rest_API_Name__c='query';
        newSalesforceSubfeatureRules4.Has_Extended_Validation__c=false;
        newSalesforceSubfeatureRules4.Active__c=true;
        newSalesforceSubfeatureRules4.Rule__c='SELECT Id FROM ValidationRule';
        newSalesforceSubfeatureRules4.Subfeature_Rule_Percentage__c=100;
        newSalesforceSubfeatureRules4.IsRuleHelperApplicable__c=true;
        insert newSalesforceSubfeatureRules4;
        
        Salesforce_Subfeature_Rule_Constraint__c newSalesforceSubfeatureConstraint2=new Salesforce_Subfeature_Rule_Constraint__c();
        newSalesforceSubfeatureConstraint2.Name='Contact Validation Rule Constraint';
        newSalesforceSubfeatureConstraint2.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules4.id;
        newSalesforceSubfeatureConstraint2.Usage_Percentage__c=100;
        newSalesforceSubfeatureConstraint2.Execution_Order__c=1;
        newSalesforceSubfeatureConstraint2.Constraint__c='IsActive = true';
        insert newSalesforceSubfeatureConstraint2;
        
        Salesforce_Subfeature_Rule_Helper__c helperRec1=new Salesforce_Subfeature_Rule_Helper__c();
        helperRec1.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules4.id;
        helperRec1.Record_Count_Size__c=10;
        helperRec1.Usage_Percentage__c=100;
        insert helperRec1;
        
        ProdSubfeatureClientUsage_Constants psfcuc = new ProdSubfeatureClientUsage_Constants();
        ProdSubfeatureClientUsageHelper helper=new ProdSubfeatureClientUsageHelper();
        ProdSubfeatureClientUsageController.updateCustomMetaData(accountID,Date.today());
        ClientAndNamedCredMapping__mdt clientandNameCred=[SELECT Account_Id__c,DeveloperName,Id,Is_Active__c,Label,Language,Last_Run_Date_Time__c,MasterLabel,Named_Credentail__c,NamespacePrefix,Next_Run_Date_Time__c,QualifiedApiName,Schedule_Frequency__c,Username__c,Use_Connected_App__c FROM ClientAndNamedCredMapping__mdt where Is_Active__c=:True and Account_Id__c =:accountID AND In_progress__c=false];
        clientandNameCred.Next_Run_Date_Time__c=null;
        clientandNameCred.Last_Run_Date_Time__c=null;
        CustomMetaDataUpdation.upsertMetadata(clientandNameCred);
        system.assertEquals(clientandNameCred1.Is_Active__c, true);
        
        ProdSubfeatureClientUsageHelper.getDuplicateRuleLimitUsage(newSalesforceSubfeatureRules4.id,10);
    }
    @isTest
    public static void SubfeatureClientTest(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                  'en_US','en_US',profile.Id,'America/Chicago',System.now().millisecond() + 
                                                                                  'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                                     
        System.runAs (portalAccountOwner)
        {
            ClientAndNamedCredMapping__mdt clientandNameCred=[SELECT Account_Id__c,DeveloperName,Id,Is_Active__c,Label,Language,Last_Run_Date_Time__c,MasterLabel,Named_Credentail__c,NamespacePrefix,Next_Run_Date_Time__c,QualifiedApiName,Schedule_Frequency__c,Username__c,Use_Connected_App__c FROM ClientAndNamedCredMapping__mdt where Is_Active__c=:True and Account_Id__c !=:null and Account_Id__c !=:'NEW' and Account_Id__c !=:'NOT_FOUND' AND In_progress__c=false limit 1];
            String accountID=clientandNameCred.Account_Id__c;
            
            
            Salesforce_Product__c newSalesforceProduct=new Salesforce_Product__c();
            newSalesforceProduct.Name='Sales Cloud';
            newSalesforceProduct.Product_Percentage__c=100;
            newSalesforceProduct.Description__c='test';
            insert newSalesforceProduct;
            
            Salesforce_Product_Feature__c newSalesforceProductFeature=new Salesforce_Product_Feature__c();
            newSalesforceProductFeature.Name='Lead Management';
            newSalesforceProductFeature.Salesforce_Product__c=newSalesforceProduct.id;
            newSalesforceProductFeature.Client_Usage_Percentage__c=100;
            newSalesforceProductFeature.Feature_Percentage__c=100;
            insert newSalesforceProductFeature;
            
            Salesforce_Product_Feature__c newSalesforceProductFeature2=new Salesforce_Product_Feature__c();
            newSalesforceProductFeature2.Name='Oppournity Management';
            newSalesforceProductFeature2.Salesforce_Product__c=newSalesforceProduct.id;
            newSalesforceProductFeature2.Client_Usage_Percentage__c=100;
            newSalesforceProductFeature2.Feature_Percentage__c=100;
            insert newSalesforceProductFeature2;
            
            Salesforce_Product_Feature__c newSalesforceProductFeature1=new Salesforce_Product_Feature__c();
            newSalesforceProductFeature1.Name='Oppournity Management';
            newSalesforceProductFeature1.Salesforce_Product__c=newSalesforceProduct.id;
            newSalesforceProductFeature1.Client_Usage_Percentage__c=100;
            newSalesforceProductFeature1.Feature_Percentage__c=100;
            insert newSalesforceProductFeature1;
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
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
            
            Product_Client_Usage__c newProductClientUsage=new Product_Client_Usage__c();
            newProductClientUsage.Account__c=accountID;
            newProductClientUsage.Salesforce_Product__c=newSalesforceProduct.id;
            newProductClientUsage.Salesforce_Product_Usage__c=100;
            insert newProductClientUsage;
            
            Product_Feature_Client_Usage__c newProductFeatureClient=new Product_Feature_Client_Usage__c();
            newProductFeatureClient.Product_Client_Usage__c=newProductClientUsage.id;
            newProductFeatureClient.Account__c=accountID;
            newProductFeatureClient.Salesforce_Product__c=newSalesforceProduct.id;
            newProductFeatureClient.Salesforce_Product_Feature__c=newSalesforceProductFeature.id;
            newProductFeatureClient.Client_Usage_Percentage__c=100;
            newProductFeatureClient.Feature_Percentage__c=100;
            insert newProductFeatureClient;
            
            
            ProdSubfeatureClientUsageBatch cu=new ProdSubfeatureClientUsageBatch(newSalesforceProductFeature.id,'001',accountID,newSalesforceProduct.id);
            list<Product_Feature_Client_Usage__c> pfcuList=new list<Product_Feature_Client_Usage__c>();
            pfcuList.add(newProductFeatureClient);
            Salesforce_Product_Subfeature__c newSalesforceSubFeature=new Salesforce_Product_Subfeature__c();
            newSalesforceSubFeature.Name='Lead Record';
            newSalesforceSubFeature.Client_Usage_Percentage__c=100;
            newSalesforceSubFeature.Salesforce_Product_Feature__c=newSalesforceProductFeature.id;
            newSalesforceSubFeature.Subfeature_Percentage__c=89;
            insert newSalesforceSubFeature;
            
            Salesforce_Product_Subfeature__c newSalesforceSubFeature1=new Salesforce_Product_Subfeature__c();
            newSalesforceSubFeature1.Name='Lead Report';
            newSalesforceSubFeature1.Client_Usage_Percentage__c=100;
            newSalesforceSubFeature1.Salesforce_Product_Feature__c=newSalesforceProductFeature.id;
            newSalesforceSubFeature1.Subfeature_Percentage__c=90;
            insert newSalesforceSubFeature1;
            
            Salesforce_Product_Subfeature__c newSalesforceSubFeature2=new Salesforce_Product_Subfeature__c();
            newSalesforceSubFeature2.Name='Lead Settings';
            newSalesforceSubFeature2.Client_Usage_Percentage__c=100;
            newSalesforceSubFeature2.Salesforce_Product_Feature__c=newSalesforceProductFeature.id;
            newSalesforceSubFeature2.Subfeature_Percentage__c=90;
            insert newSalesforceSubFeature2;
            
            Salesforce_Product_Subfeature__c newSalesforceSubFeature3=new Salesforce_Product_Subfeature__c();
            newSalesforceSubFeature3.Name='Chatter';
            newSalesforceSubFeature3.Client_Usage_Percentage__c=100;
            newSalesforceSubFeature3.Salesforce_Product_Feature__c=newSalesforceProductFeature.id;
            newSalesforceSubFeature3.Subfeature_Percentage__c=90;
            insert newSalesforceSubFeature3;
            
            Salesforce_Subfeature_Rules__c newSalesforceSubfeatureRules=new Salesforce_Subfeature_Rules__c();
            newSalesforceSubfeatureRules.Name='Lead Record Check';
            newSalesforceSubfeatureRules.Salesforce_Product_Subfeature__c=newSalesforceSubFeature.id;
            newSalesforceSubfeatureRules.Type__c='Query';
            newSalesforceSubfeatureRules.Rest_API_Name__c='query';
            newSalesforceSubfeatureRules.Rule__c='SELECT Id,Name,IsConverted,LeadSource,Status,AnnualRevenue FROM Lead';
            newSalesforceSubfeatureRules.Active__c=true;
            newSalesforceSubfeatureRules.Subfeature_Rule_Percentage__c=90;
            insert newSalesforceSubfeatureRules;
            
            Salesforce_Subfeature_Rules__c newSalesforceSubfeatureRules1=new Salesforce_Subfeature_Rules__c();
            newSalesforceSubfeatureRules1.Name='Lead Report Check';
            newSalesforceSubfeatureRules1.Salesforce_Product_Subfeature__c=newSalesforceSubFeature1.id;
            newSalesforceSubfeatureRules1.Type__c='Query';
            newSalesforceSubfeatureRules1.Rest_API_Name__c='query';
            newSalesforceSubfeatureRules1.Rule__c='SELECT Id,Name FROM Report';
            newSalesforceSubfeatureRules1.Active__c=true;
            newSalesforceSubfeatureRules1.Subfeature_Rule_Percentage__c=90;
            
            insert newSalesforceSubfeatureRules1;
            
            
            
            Salesforce_Subfeature_Rules__c newSalesforceSubfeatureRules2=new Salesforce_Subfeature_Rules__c();
            newSalesforceSubfeatureRules2.Name='Lead Settings Check';
            newSalesforceSubfeatureRules2.Salesforce_Product_Subfeature__c=newSalesforceSubFeature2.id;
            newSalesforceSubfeatureRules2.Type__c='Query';
            newSalesforceSubfeatureRules2.Rest_API_Name__c='tooling/query';
            newSalesforceSubfeatureRules2.Has_Extended_Validation__c=true;
            newSalesforceSubfeatureRules2.Active__c=true;
            newSalesforceSubfeatureRules2.Rule__c='Select Id,FullName,Metadata,DoesPreserveLeadStatus,IsOrgWideMergeAndDeleteEnabled,DoesSelectNoOpportunityOnConvertLead,DoesEnableLeadConvertDefaultSubjectBlankTaskCreation,DoesHideOpportunityInConvertLeadWindow,IsConversionsOnMobileEnabled,DoesTrackHistory,ShouldLeadConvertRequireValidation From LeadConfigSettings';
            newSalesforceSubfeatureRules2.Subfeature_Rule_Percentage__c=100;
            insert newSalesforceSubfeatureRules2;
            
            Salesforce_Subfeature_Rule_Constraint__c newSalesforceSubfeatureConstraint=new Salesforce_Subfeature_Rule_Constraint__c();
            newSalesforceSubfeatureConstraint.Name='Lead Record Constraint1';
            newSalesforceSubfeatureConstraint.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules.id;
            newSalesforceSubfeatureConstraint.Usage_Percentage__c=100;
            newSalesforceSubfeatureConstraint.Constraint__c='CreatedDate=LAST_N_DAYS:30';
            newSalesforceSubfeatureConstraint.Execution_Order__c=1;
            insert newSalesforceSubfeatureConstraint;
            
            Salesforce_Subfeature_Rule_Constraint__c newSalesforceSubfeatureConstraint1=new Salesforce_Subfeature_Rule_Constraint__c();
            newSalesforceSubfeatureConstraint1.Name='Lead Record Constraint2';
            newSalesforceSubfeatureConstraint1.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules.id;
            newSalesforceSubfeatureConstraint1.Usage_Percentage__c=50;
            newSalesforceSubfeatureConstraint1.Constraint__c='CreatedDate=LAST_N_DAYS:365';
            newSalesforceSubfeatureConstraint1.Execution_Order__c=2;
            insert newSalesforceSubfeatureConstraint1;
            
            Salesforce_Subfeature_Rule_Constraint__c newSalesforceSubfeatureConstraint2=new Salesforce_Subfeature_Rule_Constraint__c();
            newSalesforceSubfeatureConstraint2.Name='Lead Report Constraint';
            newSalesforceSubfeatureConstraint2.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules1.id;
            newSalesforceSubfeatureConstraint2.Usage_Percentage__c=100;
            newSalesforceSubfeatureConstraint2.Constraint__c='Name like \'%lead%\'';
            newSalesforceSubfeatureConstraint2.Execution_Order__c=1;
            insert newSalesforceSubfeatureConstraint2;
            
            Salesforce_Subfeature_Rule_Constraint__c newSalesforceSubfeatureConstraint3=new Salesforce_Subfeature_Rule_Constraint__c();
            newSalesforceSubfeatureConstraint3.Name='Lead Settings Constraint';
            newSalesforceSubfeatureConstraint3.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules2.id;
            newSalesforceSubfeatureConstraint3.Usage_Percentage__c=100;
            newSalesforceSubfeatureConstraint3.Execution_Order__c=1;
            insert newSalesforceSubfeatureConstraint3;
            
            Salesforce_Product_Subfeature__c newSalesforceSubFeature2Con=new Salesforce_Product_Subfeature__c();
            newSalesforceSubFeature2Con.Name='Contact Duplicate Rule';
            newSalesforceSubFeature2Con.Client_Usage_Percentage__c=100;
            newSalesforceSubFeature2Con.Salesforce_Product_Feature__c=newSalesforceProductFeature1.id;
            newSalesforceSubFeature2Con.Subfeature_Percentage__c=90;
            insert newSalesforceSubFeature2Con;
            
            Salesforce_Subfeature_Rules__c newSalesforceSubfeatureRules3=new Salesforce_Subfeature_Rules__c();
            newSalesforceSubfeatureRules3.Name='Contact Duplicate Rule Check';
            newSalesforceSubfeatureRules3.Salesforce_Product_Subfeature__c=newSalesforceSubFeature2Con.id;
            newSalesforceSubfeatureRules3.Type__c='Query';
            newSalesforceSubfeatureRules3.Rest_API_Name__c='query';
            newSalesforceSubfeatureRules3.Has_Extended_Validation__c=false;
            newSalesforceSubfeatureRules3.Active__c=true;
            newSalesforceSubfeatureRules3.Rule__c='SELECT Id FROM DuplicateRule';
            newSalesforceSubfeatureRules3.Subfeature_Rule_Percentage__c=100;
            newSalesforceSubfeatureRules3.IsRuleHelperApplicable__c=true;
            insert newSalesforceSubfeatureRules3;
            
            Salesforce_Subfeature_Rule_Constraint__c newSalesforceSubfeatureConstraint4=new Salesforce_Subfeature_Rule_Constraint__c();
            newSalesforceSubfeatureConstraint4.Name='Contact Duplicate Rule Constraint';
            newSalesforceSubfeatureConstraint4.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules3.id;
            newSalesforceSubfeatureConstraint4.Usage_Percentage__c=100;
            newSalesforceSubfeatureConstraint4.Execution_Order__c=1;
            newSalesforceSubfeatureConstraint4.Constraint__c='IsActive = true';
            insert newSalesforceSubfeatureConstraint4;
            
            
            Salesforce_Subfeature_Rules__c newSalesforceSubfeatureRules4=new Salesforce_Subfeature_Rules__c();
            newSalesforceSubfeatureRules4.Name='Chatter Rule';
            newSalesforceSubfeatureRules4.Salesforce_Product_Subfeature__c=newSalesforceSubFeature3.id;
            newSalesforceSubfeatureRules4.Type__c='Chatter';
            newSalesforceSubfeatureRules4.Rest_API_Name__c='chatter/feeds';
            newSalesforceSubfeatureRules4.Rule__c='';
            newSalesforceSubfeatureRules4.Active__c=true;
            newSalesforceSubfeatureRules4.IsRuleHelperApplicable__c=false;
            newSalesforceSubfeatureRules4.Subfeature_Rule_Percentage__c=90;
            insert newSalesforceSubfeatureRules4;
            
            Salesforce_Subfeature_Rule_Constraint__c newSalesforceSubfeatureConstraint5=new Salesforce_Subfeature_Rule_Constraint__c();
            newSalesforceSubfeatureConstraint5.Name='Chatter Constraint';
            newSalesforceSubfeatureConstraint5.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules4.id;
            newSalesforceSubfeatureConstraint5.Usage_Percentage__c=100;
            newSalesforceSubfeatureConstraint5.Execution_Order__c=1;
            newSalesforceSubfeatureConstraint5.Constraint__c='';
            insert newSalesforceSubfeatureConstraint5;
            
            Salesforce_Subfeature_Rules__c newSalesforceSubfeatureRules5=new Salesforce_Subfeature_Rules__c();
            newSalesforceSubfeatureRules5.Name='Feed Rule';
            newSalesforceSubfeatureRules5.Salesforce_Product_Subfeature__c=newSalesforceSubFeature3.id;
            newSalesforceSubfeatureRules5.Type__c='Query';
            newSalesforceSubfeatureRules5.Rest_API_Name__c='query';
            newSalesforceSubfeatureRules5.Rule__c='Select Id,DeveloperName,IsFeedEnabled From EntityDefinition';
            newSalesforceSubfeatureRules5.Active__c=true;
            newSalesforceSubfeatureRules5.IsRuleHelperApplicable__c=true;
            newSalesforceSubfeatureRules5.Subfeature_Rule_Percentage__c=90;
            insert newSalesforceSubfeatureRules5;
            
            Salesforce_Subfeature_Rule_Constraint__c newSalesforceSubfeatureConstraint6=new Salesforce_Subfeature_Rule_Constraint__c();
            newSalesforceSubfeatureConstraint6.Name='Feed Constraint';
            newSalesforceSubfeatureConstraint6.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules5.id;
            newSalesforceSubfeatureConstraint6.Usage_Percentage__c=100;
            newSalesforceSubfeatureConstraint6.Execution_Order__c=1;
            newSalesforceSubfeatureConstraint5.Constraint__c='(DeveloperName="Account" OR DeveloperName="Contact" OR DeveloperName="Lead" OR DeveloperName="Case" OR DeveloperName="Opportunity") AND IsFeedEnabled = true';
            insert newSalesforceSubfeatureConstraint6;
            
            Salesforce_Subfeature_Rule_Helper__c newRuleHelper=new Salesforce_Subfeature_Rule_Helper__c();
            newRuleHelper.Name='Feed Record 1';
            newRuleHelper.Record_Count_Size__c=5;
            newRuleHelper.Usage_Percentage__c=100;
            newRuleHelper.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules5.id;
            insert newRuleHelper;
            
            Salesforce_Subfeature_Rule_Helper__c newRuleHelper1=new Salesforce_Subfeature_Rule_Helper__c();
            newRuleHelper1.Name='Duplicate Record 1';
            newRuleHelper1.Record_Count_Size__c=5;
            newRuleHelper1.Usage_Percentage__c=100;
            newRuleHelper1.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules3.id;
            insert newRuleHelper1;
            
            SF_Feature_Details__c sf=new SF_Feature_Details__c();
            sf.Feature_ID__c=newSalesforceProductFeature.id;
            sf.IsActive__c=false;
            insert sf;
            
            SF_Feature_Details__c sf1=new SF_Feature_Details__c();
            sf1.Feature_ID__c=newSalesforceProductFeature1.id;
            sf1.IsActive__c=false;
            insert sf1;
            
            SF_Feature_Details__c sf2=new SF_Feature_Details__c();
            sf2.Feature_ID__c=newSalesforceProductFeature2.id;
            sf2.IsActive__c=true;
            insert sf2;
            system.debug('sf--'+sf);
            system.debug('sf2--'+sf1);
            system.debug('sf2--'+sf2);
            Test.startTest();
            
            ProdSubfeatureClientUsage_Constants psfcuc = new ProdSubfeatureClientUsage_Constants();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            ProdSubfeatureClientUsageHelper helper=new ProdSubfeatureClientUsageHelper();
            SchedulableContext sc = null;
            ProdSubfeatureClientUsageSchedular x = new ProdSubfeatureClientUsageSchedular();
            x.execute(sc);
            String CRON_EXP = '0 0 0 3 9 ? 2022';
            HeatMapRecordsSchedular x1 = new HeatMapRecordsSchedular(accountID);
            String jobId = System.schedule('HeatMap Request From ConApp For '+accountID,'0 24 * * * ?', x1);
            ProdSubfeatureClientUsageBatch cu1=new ProdSubfeatureClientUsageBatch(newSalesforceProductFeature.id,'001',accountID,newSalesforceProduct.id);
            system.assertEquals(clientandNameCred.Is_Active__c, true);
            Test.stopTest();
        }
        
        
        
    }
    @isTest
    public static void SubfeatureClientMannualTest(){
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                  'en_US','en_US',profile.Id,'America/Chicago',System.now().millisecond() + 
                                                                                  'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                                     
        System.runAs (portalAccountOwner)
        {
            ClientAndNamedCredMapping__mdt clientandNameCred=[SELECT Account_Id__c,DeveloperName,Id,Is_Active__c,Label,Language,Last_Run_Date_Time__c,MasterLabel,Named_Credentail__c,NamespacePrefix,Next_Run_Date_Time__c,QualifiedApiName,Schedule_Frequency__c,Username__c,Use_Connected_App__c FROM ClientAndNamedCredMapping__mdt where Is_Active__c=:True and Account_Id__c !=:null and Account_Id__c !=:'NEW' and Account_Id__c !=:'NOT_FOUND' AND In_progress__c=false limit 1];
            String accountID=clientandNameCred.Account_Id__c;
            // String accountID = '0013D00000YoJk9QAF';//Hard coded for now
            //String productID = 'a3O3D000000kjmXUAQ';//Hard coded for now
            //String leadMgtFeatureId = 'a3P3D000001GBEFUA4';//Hard coded for now
            
            /* Account newAccount=new Account();
newAccount.Name='New Account Test';
insert newAccount;*/
            
            Salesforce_Product__c newSalesforceProduct=new Salesforce_Product__c();
            newSalesforceProduct.Name='Sales Cloud';
            newSalesforceProduct.Product_Percentage__c=100;
            newSalesforceProduct.Description__c='test';
            insert newSalesforceProduct;
            
            Salesforce_Product_Feature__c newSalesforceProductFeature=new Salesforce_Product_Feature__c();
            newSalesforceProductFeature.Name='Lead Management';
            newSalesforceProductFeature.Salesforce_Product__c=newSalesforceProduct.id;
            newSalesforceProductFeature.Client_Usage_Percentage__c=100;
            newSalesforceProductFeature.Feature_Percentage__c=100;
            insert newSalesforceProductFeature;
            
            Salesforce_Product_Feature__c newSalesforceProductFeature2=new Salesforce_Product_Feature__c();
            newSalesforceProductFeature2.Name='Oppournity Management';
            newSalesforceProductFeature2.Salesforce_Product__c=newSalesforceProduct.id;
            newSalesforceProductFeature2.Client_Usage_Percentage__c=100;
            newSalesforceProductFeature2.Feature_Percentage__c=100;
            insert newSalesforceProductFeature2;
            
            Salesforce_Product_Feature__c newSalesforceProductFeature1=new Salesforce_Product_Feature__c();
            newSalesforceProductFeature1.Name='Oppournity Management';
            newSalesforceProductFeature1.Salesforce_Product__c=newSalesforceProduct.id;
            newSalesforceProductFeature1.Client_Usage_Percentage__c=100;
            newSalesforceProductFeature1.Feature_Percentage__c=100;
            insert newSalesforceProductFeature1;
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;            
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
            
            Product_Client_Usage__c newProductClientUsage=new Product_Client_Usage__c();
            newProductClientUsage.Account__c=accountID;
            newProductClientUsage.Salesforce_Product__c=newSalesforceProduct.id;
            newProductClientUsage.Salesforce_Product_Usage__c=100;
            insert newProductClientUsage;
            
            Product_Feature_Client_Usage__c newProductFeatureClient=new Product_Feature_Client_Usage__c();
            newProductFeatureClient.Product_Client_Usage__c=newProductClientUsage.id;
            newProductFeatureClient.Account__c=accountID;
            newProductFeatureClient.Salesforce_Product__c=newSalesforceProduct.id;
            newProductFeatureClient.Salesforce_Product_Feature__c=newSalesforceProductFeature.id;
            newProductFeatureClient.Client_Usage_Percentage__c=100;
            newProductFeatureClient.Feature_Percentage__c=100;
            insert newProductFeatureClient;
            
            
            ProdSubfeatureClientUsageBatch cu=new ProdSubfeatureClientUsageBatch(newSalesforceProductFeature.id,'001',accountID,newSalesforceProduct.id);
            list<Product_Feature_Client_Usage__c> pfcuList=new list<Product_Feature_Client_Usage__c>();
            pfcuList.add(newProductFeatureClient);
            Salesforce_Product_Subfeature__c newSalesforceSubFeature=new Salesforce_Product_Subfeature__c();
            newSalesforceSubFeature.Name='Lead Record';
            newSalesforceSubFeature.Client_Usage_Percentage__c=100;
            newSalesforceSubFeature.Salesforce_Product_Feature__c=newSalesforceProductFeature.id;
            newSalesforceSubFeature.Subfeature_Percentage__c=89;
            insert newSalesforceSubFeature;
            
            Salesforce_Product_Subfeature__c newSalesforceSubFeature1=new Salesforce_Product_Subfeature__c();
            newSalesforceSubFeature1.Name='Lead Report';
            newSalesforceSubFeature1.Client_Usage_Percentage__c=100;
            newSalesforceSubFeature1.Salesforce_Product_Feature__c=newSalesforceProductFeature.id;
            newSalesforceSubFeature1.Subfeature_Percentage__c=90;
            insert newSalesforceSubFeature1;
            
            Salesforce_Product_Subfeature__c newSalesforceSubFeature2=new Salesforce_Product_Subfeature__c();
            newSalesforceSubFeature2.Name='Lead Settings';
            newSalesforceSubFeature2.Client_Usage_Percentage__c=100;
            newSalesforceSubFeature2.Salesforce_Product_Feature__c=newSalesforceProductFeature.id;
            newSalesforceSubFeature2.Subfeature_Percentage__c=90;
            insert newSalesforceSubFeature2;
            
            Salesforce_Product_Subfeature__c newSalesforceSubFeature3=new Salesforce_Product_Subfeature__c();
            newSalesforceSubFeature3.Name='Chatter';
            newSalesforceSubFeature3.Client_Usage_Percentage__c=100;
            newSalesforceSubFeature3.Salesforce_Product_Feature__c=newSalesforceProductFeature.id;
            newSalesforceSubFeature3.Subfeature_Percentage__c=90;
            insert newSalesforceSubFeature3;
            
            Salesforce_Subfeature_Rules__c newSalesforceSubfeatureRules=new Salesforce_Subfeature_Rules__c();
            newSalesforceSubfeatureRules.Name='Lead Record Check';
            newSalesforceSubfeatureRules.Salesforce_Product_Subfeature__c=newSalesforceSubFeature.id;
            newSalesforceSubfeatureRules.Type__c='Query';
            newSalesforceSubfeatureRules.Rest_API_Name__c='query';
            newSalesforceSubfeatureRules.Rule__c='SELECT Id,Name,IsConverted,LeadSource,Status,AnnualRevenue FROM Lead';
            newSalesforceSubfeatureRules.Active__c=true;
            newSalesforceSubfeatureRules.Subfeature_Rule_Percentage__c=90;
            insert newSalesforceSubfeatureRules;
            
            Salesforce_Subfeature_Rules__c newSalesforceSubfeatureRules1=new Salesforce_Subfeature_Rules__c();
            newSalesforceSubfeatureRules1.Name='Lead Report Check';
            newSalesforceSubfeatureRules1.Salesforce_Product_Subfeature__c=newSalesforceSubFeature1.id;
            newSalesforceSubfeatureRules1.Type__c='Query';
            newSalesforceSubfeatureRules1.Rest_API_Name__c='query';
            newSalesforceSubfeatureRules1.Rule__c='SELECT Id,Name FROM Report';
            newSalesforceSubfeatureRules1.Active__c=true;
            newSalesforceSubfeatureRules1.Subfeature_Rule_Percentage__c=90;
            
            insert newSalesforceSubfeatureRules1;
            
            Salesforce_Subfeature_Rules__c newSalesforceSubfeatureRules2=new Salesforce_Subfeature_Rules__c();
            newSalesforceSubfeatureRules2.Name='Lead Settings Check';
            newSalesforceSubfeatureRules2.Salesforce_Product_Subfeature__c=newSalesforceSubFeature2.id;
            newSalesforceSubfeatureRules2.Type__c='Query';
            newSalesforceSubfeatureRules2.Rest_API_Name__c='tooling/query';
            newSalesforceSubfeatureRules2.Has_Extended_Validation__c=true;
            newSalesforceSubfeatureRules2.Active__c=true;
            newSalesforceSubfeatureRules2.Rule__c='Select Id,FullName,Metadata,DoesPreserveLeadStatus,IsOrgWideMergeAndDeleteEnabled,DoesSelectNoOpportunityOnConvertLead,DoesEnableLeadConvertDefaultSubjectBlankTaskCreation,DoesHideOpportunityInConvertLeadWindow,IsConversionsOnMobileEnabled,DoesTrackHistory,ShouldLeadConvertRequireValidation From LeadConfigSettings';
            newSalesforceSubfeatureRules2.Subfeature_Rule_Percentage__c=100;
            insert newSalesforceSubfeatureRules2;
            
            Salesforce_Subfeature_Rule_Constraint__c newSalesforceSubfeatureConstraint=new Salesforce_Subfeature_Rule_Constraint__c();
            newSalesforceSubfeatureConstraint.Name='Lead Record Constraint1';
            newSalesforceSubfeatureConstraint.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules.id;
            newSalesforceSubfeatureConstraint.Usage_Percentage__c=100;
            newSalesforceSubfeatureConstraint.Constraint__c='CreatedDate=LAST_N_DAYS:30';
            newSalesforceSubfeatureConstraint.Execution_Order__c=1;
            insert newSalesforceSubfeatureConstraint;
            
            Salesforce_Subfeature_Rule_Constraint__c newSalesforceSubfeatureConstraint1=new Salesforce_Subfeature_Rule_Constraint__c();
            newSalesforceSubfeatureConstraint1.Name='Lead Record Constraint2';
            newSalesforceSubfeatureConstraint1.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules.id;
            newSalesforceSubfeatureConstraint1.Usage_Percentage__c=50;
            newSalesforceSubfeatureConstraint1.Constraint__c='CreatedDate=LAST_N_DAYS:365';
            newSalesforceSubfeatureConstraint1.Execution_Order__c=2;
            insert newSalesforceSubfeatureConstraint1;
            
            Salesforce_Subfeature_Rule_Constraint__c newSalesforceSubfeatureConstraint2=new Salesforce_Subfeature_Rule_Constraint__c();
            newSalesforceSubfeatureConstraint2.Name='Lead Report Constraint';
            newSalesforceSubfeatureConstraint2.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules1.id;
            newSalesforceSubfeatureConstraint2.Usage_Percentage__c=100;
            newSalesforceSubfeatureConstraint2.Constraint__c='Name like \'%lead%\'';
            newSalesforceSubfeatureConstraint2.Execution_Order__c=1;
            insert newSalesforceSubfeatureConstraint2;
            
            Salesforce_Subfeature_Rule_Constraint__c newSalesforceSubfeatureConstraint3=new Salesforce_Subfeature_Rule_Constraint__c();
            newSalesforceSubfeatureConstraint3.Name='Lead Settings Constraint';
            newSalesforceSubfeatureConstraint3.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules2.id;
            newSalesforceSubfeatureConstraint3.Usage_Percentage__c=100;
            newSalesforceSubfeatureConstraint3.Execution_Order__c=1;
            insert newSalesforceSubfeatureConstraint3;
            
            Salesforce_Product_Subfeature__c newSalesforceSubFeature2Con=new Salesforce_Product_Subfeature__c();
            newSalesforceSubFeature2Con.Name='Contact Duplicate Rule';
            newSalesforceSubFeature2Con.Client_Usage_Percentage__c=100;
            newSalesforceSubFeature2Con.Salesforce_Product_Feature__c=newSalesforceProductFeature1.id;
            newSalesforceSubFeature2Con.Subfeature_Percentage__c=90;
            insert newSalesforceSubFeature2Con;
            
            Salesforce_Subfeature_Rules__c newSalesforceSubfeatureRules3=new Salesforce_Subfeature_Rules__c();
            newSalesforceSubfeatureRules3.Name='Contact Duplicate Rule Check';
            newSalesforceSubfeatureRules3.Salesforce_Product_Subfeature__c=newSalesforceSubFeature2Con.id;
            newSalesforceSubfeatureRules3.Type__c='Query';
            newSalesforceSubfeatureRules3.Rest_API_Name__c='query';
            newSalesforceSubfeatureRules3.Has_Extended_Validation__c=false;
            newSalesforceSubfeatureRules3.Active__c=true;
            newSalesforceSubfeatureRules3.Rule__c='SELECT Id FROM DuplicateRule';
            newSalesforceSubfeatureRules3.Subfeature_Rule_Percentage__c=100;
            newSalesforceSubfeatureRules3.IsRuleHelperApplicable__c=true;
            insert newSalesforceSubfeatureRules3;
            
            Salesforce_Subfeature_Rule_Constraint__c newSalesforceSubfeatureConstraint4=new Salesforce_Subfeature_Rule_Constraint__c();
            newSalesforceSubfeatureConstraint4.Name='Contact Duplicate Rule Constraint';
            newSalesforceSubfeatureConstraint4.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules3.id;
            newSalesforceSubfeatureConstraint4.Usage_Percentage__c=100;
            newSalesforceSubfeatureConstraint4.Execution_Order__c=1;
            newSalesforceSubfeatureConstraint4.Constraint__c='IsActive = true';
            insert newSalesforceSubfeatureConstraint4;
            
            Salesforce_Subfeature_Rules__c newSalesforceSubfeatureRules5=new Salesforce_Subfeature_Rules__c();
            newSalesforceSubfeatureRules5.Name='Chatter Rule';
            newSalesforceSubfeatureRules5.Salesforce_Product_Subfeature__c=newSalesforceSubFeature3.id;
            newSalesforceSubfeatureRules5.Type__c='Chatter';
            newSalesforceSubfeatureRules5.Rest_API_Name__c='chatter/feeds';
            newSalesforceSubfeatureRules5.Rule__c='';
            newSalesforceSubfeatureRules5.Active__c=true;
            newSalesforceSubfeatureRules5.IsRuleHelperApplicable__c=false;
            newSalesforceSubfeatureRules5.Subfeature_Rule_Percentage__c=90;
            insert newSalesforceSubfeatureRules5;
            
            Salesforce_Subfeature_Rule_Constraint__c newSalesforceSubfeatureConstraint5=new Salesforce_Subfeature_Rule_Constraint__c();
            newSalesforceSubfeatureConstraint5.Name='Chatter Constraint';
            newSalesforceSubfeatureConstraint5.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules5.id;
            newSalesforceSubfeatureConstraint5.Usage_Percentage__c=100;
            newSalesforceSubfeatureConstraint5.Execution_Order__c=1;
            newSalesforceSubfeatureConstraint5.Constraint__c='';
            insert newSalesforceSubfeatureConstraint5;
            
            SF_Feature_Details__c sf=new SF_Feature_Details__c();
            sf.Feature_ID__c=newSalesforceProductFeature.id;
            sf.IsActive__c=true;
            insert sf;
            
            SF_Feature_Details__c sf1=new SF_Feature_Details__c();
            sf1.Feature_ID__c=newSalesforceProductFeature1.id;
            sf1.IsActive__c=true;
            insert sf1;
            
            SF_Feature_Details__c sf2=new SF_Feature_Details__c();
            sf2.Feature_ID__c=newSalesforceProductFeature2.id;
            sf2.IsActive__c=true;
            insert sf2;
            system.debug('sf--'+sf);
            system.debug('sf2--'+sf1);
            system.debug('sf2--'+sf2);
            Test.startTest();
            
            ProdSubfeatureClientUsage_Constants psfcuc = new ProdSubfeatureClientUsage_Constants();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            ProdSubfeatureClientUsageHelper helper=new ProdSubfeatureClientUsageHelper();
            SchedulableContext sc = null;
            ProdSubfeatureClientUsageSchedular x = new ProdSubfeatureClientUsageSchedular();
            //x.execute(sc);
            Database.BatchableContext BC;
            
            
            
            ProdSubfeatureClientUsageBatch cu1=new ProdSubfeatureClientUsageBatch(newSalesforceProductFeature.id,'001',accountID,newSalesforceProduct.id);
            cu1.execute(BC, pfcuList);
            ProdSubfeatureClientUsageAPIHelper apiHelper=new ProdSubfeatureClientUsageAPIHelper();
            apiHelper.getNamedCredForClient(accountID);
            system.assertEquals(clientandNameCred.Is_Active__c, true);
            
            Test.stopTest();
        }
        
        
        
    }
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"size" : 1, "totalSize" : 1,  "done" : true,  "queryLocator" : null,  "entityTypeName" : "LeadConfigSettings",  "records" : [ {    "attributes" : {"type" : "LeadConfigSettings","url" : "/services/data/v50.0/tooling/sobjects/LeadConfigSettings/bWRjLzBIRS9MZWFkQ29uZmlnU2V0dGluZ3M%3D" },"Id" : "000000000000000AAA", "FullName" : "LeadConfig","Metadata" : {"urls" : null,"doesEnableLeadConvertDefaultSubjectBlankTaskCreation" : false,"doesHideOpportunityInConvertLeadWindow" : false,"doesPreserveLeadStatus" : true,"doesSelectNoOpportunityOnConvertLead" : false,"doesTrackHistory" : false,"enableConversionsOnMobile" : false,"enableOrgWideMergeAndDelete" : false,"shouldLeadConvertRequireValidation" : true},"DoesPreserveLeadStatus" : true,"IsOrgWideMergeAndDeleteEnabled" : true,"DoesSelectNoOpportunityOnConvertLead" : false, "DoesEnableLeadConvertDefaultSubjectBlankTaskCreation" : false,"DoesHideOpportunityInConvertLeadWindow" : false,"IsConversionsOnMobileEnabled" : true,"DoesTrackHistory" : false,"ShouldLeadConvertRequireValidation" : true} ]}');
            res.setStatusCode(200);
            return res;
        }
    }
}
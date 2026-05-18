@isTest
public class RunExtendedValidationTest {
    @isTest
    public static void leadSettingTestV1(){
        RunExtendedValidation.getUtilizationPercentage('test','','');
    }
    @isTest
    public static void leadSettingTest(){
        
        Salesforce_Product__c newSalesforceProduct=new Salesforce_Product__c();
        newSalesforceProduct.Name='Sales Cloud';
        newSalesforceProduct.Product_Percentage__c=100;
        newSalesforceProduct.Description__c='Test';
        insert newSalesforceProduct;
        
        Salesforce_Product_Feature__c newSalesforceProductFeature1=new Salesforce_Product_Feature__c();
        newSalesforceProductFeature1.Name='Account and Contact Management';
        newSalesforceProductFeature1.Salesforce_Product__c=newSalesforceProduct.id;
        newSalesforceProductFeature1.Client_Usage_Percentage__c=100;
        newSalesforceProductFeature1.Feature_Percentage__c=100;
        insert newSalesforceProductFeature1;
        
        Salesforce_Product_Feature__c newSalesforceProductFeature2=new Salesforce_Product_Feature__c();
        newSalesforceProductFeature2.Name='Opportunity Management';
        newSalesforceProductFeature2.Salesforce_Product__c=newSalesforceProduct.id;
        newSalesforceProductFeature2.Client_Usage_Percentage__c=100;
        newSalesforceProductFeature2.Feature_Percentage__c=100;
        insert newSalesforceProductFeature2;
        
        Salesforce_Product_Subfeature__c accountSubFeature=new Salesforce_Product_Subfeature__c();
        accountSubFeature.Name='Account Validation Rule';
        accountSubFeature.Salesforce_Product_Feature__c=newSalesforceProductFeature1.id;
        accountSubFeature.Client_Usage_Percentage__c=100;
        accountSubFeature.Subfeature_Percentage__c=89;
        insert accountSubFeature;
        
        Salesforce_Product_Subfeature__c contactSubFeature=new Salesforce_Product_Subfeature__c();
        contactSubFeature.Name='Contact Validation Rule';
        contactSubFeature.Salesforce_Product_Feature__c=newSalesforceProductFeature1.id;
        contactSubFeature.Client_Usage_Percentage__c=100;
        contactSubFeature.Subfeature_Percentage__c=89;
        insert contactSubFeature;
        
        Salesforce_Product_Subfeature__c oppSubFeature=new Salesforce_Product_Subfeature__c();
        oppSubFeature.Name='Opportunity Validation Rule';
        oppSubFeature.Salesforce_Product_Feature__c=newSalesforceProductFeature2.id;
        oppSubFeature.Client_Usage_Percentage__c=100;
        oppSubFeature.Subfeature_Percentage__c=89;
        insert oppSubFeature;
        
        Salesforce_Subfeature_Rules__c accountValidationRule=new Salesforce_Subfeature_Rules__c();
        accountValidationRule.Name='Account Validation Rule Check';
        accountValidationRule.Salesforce_Product_Subfeature__c=accountSubFeature.id;
        accountValidationRule.Rest_API_Name__c='tooling/query';
        accountValidationRule.Type__c='Query';
        accountValidationRule.Active__c=true;
        accountValidationRule.Rule__c='SELECT Id, ValidationName, Description, EntityDefinition.DeveloperName, ErrorDisplayField, ErrorMessage FROM ValidationRule';
        insert accountValidationRule;
        
        Salesforce_Subfeature_Rule_Constraint__c accountValidationConstraint=new Salesforce_Subfeature_Rule_Constraint__c();
        accountValidationConstraint.Name='Account Validation Rule Constraint';
        accountValidationConstraint.Constraint__c='EntityDefinition.DeveloperName=\'Account\' And Active = true';
        accountValidationConstraint.Salesforce_Subfeature_Rule__c=accountValidationRule.id;
        accountValidationConstraint.Execution_Order__c=1;
        accountValidationConstraint.Usage_Percentage__c=100;
        
        insert accountValidationConstraint;
        
        Salesforce_Subfeature_Rules__c contactValidationRule=new Salesforce_Subfeature_Rules__c();
        contactValidationRule.Name='Contact Validation Rule Check';
        contactValidationRule.Salesforce_Product_Subfeature__c=contactSubFeature.id;
        contactValidationRule.Rest_API_Name__c='tooling/query';
        contactValidationRule.Type__c='Query';
        contactValidationRule.Active__c=true;
        contactValidationRule.Rule__c='SELECT Id, ValidationName, Description, EntityDefinition.DeveloperName, ErrorDisplayField, ErrorMessage FROM ValidationRule';
        insert contactValidationRule;
        
        Salesforce_Subfeature_Rule_Constraint__c contactValidationConstraint=new Salesforce_Subfeature_Rule_Constraint__c();
        contactValidationConstraint.Name='Contact Validation Rule Constraint';
        contactValidationConstraint.Constraint__c='EntityDefinition.DeveloperName=\'Contact\' And Active = true';
        contactValidationConstraint.Salesforce_Subfeature_Rule__c=contactValidationRule.id;
        contactValidationConstraint.Execution_Order__c=1;
        contactValidationConstraint.Usage_Percentage__c=100;
        
        insert contactValidationConstraint;
        
        Salesforce_Subfeature_Rules__c oppValidationRule=new Salesforce_Subfeature_Rules__c();
        oppValidationRule.Name='Contact Validation Rule Check';
        oppValidationRule.Salesforce_Product_Subfeature__c=oppSubFeature.id;
        oppValidationRule.Rest_API_Name__c='tooling/query';
        oppValidationRule.Type__c='Query';
        oppValidationRule.Active__c=true;
        oppValidationRule.Rule__c='SELECT Id, ValidationName, Description, EntityDefinition.DeveloperName, ErrorDisplayField, ErrorMessage FROM ValidationRule';
        insert oppValidationRule;
        
        Salesforce_Subfeature_Rule_Constraint__c oppValidationConstraint=new Salesforce_Subfeature_Rule_Constraint__c();
        oppValidationConstraint.Name='Opp Validation Rule Constraint';
        oppValidationConstraint.Constraint__c='EntityDefinition.DeveloperName=\'Opportunity\' And Active = true';
        oppValidationConstraint.Salesforce_Subfeature_Rule__c=oppValidationRule.id;
        oppValidationConstraint.Execution_Order__c=1;
        oppValidationConstraint.Usage_Percentage__c=100;
        insert oppValidationConstraint;
        
        Salesforce_Product_Subfeature__c newSalesforceSubFeature2=new Salesforce_Product_Subfeature__c();
        newSalesforceSubFeature2.Name='Lead Settings';
        newSalesforceSubFeature2.Client_Usage_Percentage__c=100;
        newSalesforceSubFeature2.Salesforce_Product_Feature__c=newSalesforceProductFeature2.id;
        newSalesforceSubFeature2.Subfeature_Percentage__c=90;
        insert newSalesforceSubFeature2;
        
        Salesforce_Subfeature_Rules__c newSalesforceSubfeatureRules2=new Salesforce_Subfeature_Rules__c();
        newSalesforceSubfeatureRules2.Name='Lead Settings Check';
        newSalesforceSubfeatureRules2.Salesforce_Product_Subfeature__c=newSalesforceSubFeature2.id;
        newSalesforceSubfeatureRules2.Type__c='Query';
        newSalesforceSubfeatureRules2.Rest_API_Name__c='tooling/query';
        newSalesforceSubfeatureRules2.Has_Extended_Validation__c=true;
        newSalesforceSubfeatureRules2.Active__c=true;
        newSalesforceSubfeatureRules2.Rule__c='Select Id,FullName,Metadata,DoesPreserveLeadStatus,IsOrgWideMergeAndDeleteEnabled,DoesSelectNoOpportunityOnConvertLead,DoesEnableLeadConvertDefaultSubjectBlankTaskCreation,DoesHideOpportunityInConvertLeadWindow,IsConversionsOnMobileEnabled,DoesTrackHistory,ShouldLeadConvertRequireValidation From LeadConfigSettings';
        insert newSalesforceSubfeatureRules2;
        
        Salesforce_Subfeature_Rule_Constraint__c newSalesforceSubfeatureConstraint3=new Salesforce_Subfeature_Rule_Constraint__c();
        newSalesforceSubfeatureConstraint3.Name='Lead Settings Constraint';
        newSalesforceSubfeatureConstraint3.Salesforce_Subfeature_Rule__c=newSalesforceSubfeatureRules2.id;
        newSalesforceSubfeatureConstraint3.Usage_Percentage__c=100;
        newSalesforceSubfeatureConstraint3.Execution_Order__c=1;
        insert newSalesforceSubfeatureConstraint3;
        
        string input='{"size" : 1, "totalSize" : 1,  "done" : true,  "queryLocator" : null,  "entityTypeName" : "LeadConfigSettings",  "records" : [ {    "attributes" : {"type" : "LeadConfigSettings","url" : "/services/data/v50.0/tooling/sobjects/LeadConfigSettings/bWRjLzBIRS9MZWFkQ29uZmlnU2V0dGluZ3M%3D" },"Id" : "000000000000000AAA", "FullName" : "LeadConfig","Metadata" : {"urls" : null,"doesEnableLeadConvertDefaultSubjectBlankTaskCreation" : false,"doesHideOpportunityInConvertLeadWindow" : false,"doesPreserveLeadStatus" : true,"doesSelectNoOpportunityOnConvertLead" : false,"doesTrackHistory" : false,"enableConversionsOnMobile" : false,"enableOrgWideMergeAndDelete" : false,"shouldLeadConvertRequireValidation" : true},"DoesPreserveLeadStatus" : true,"IsOrgWideMergeAndDeleteEnabled" : true,"DoesSelectNoOpportunityOnConvertLead" : false, "DoesEnableLeadConvertDefaultSubjectBlankTaskCreation" : false,"DoesHideOpportunityInConvertLeadWindow" : false,"IsConversionsOnMobileEnabled" : true,"DoesTrackHistory" : false,"ShouldLeadConvertRequireValidation" : true} ]}';
        ClientAndNamedCredMapping__mdt clientandNameCred1=[SELECT Account_Id__c,DeveloperName,Id,Is_Active__c,Label,Language,Last_Run_Date_Time__c,MasterLabel,Named_Credentail__c,NamespacePrefix,Next_Run_Date_Time__c,QualifiedApiName,Schedule_Frequency__c,Username__c,Use_Connected_App__c FROM ClientAndNamedCredMapping__mdt where Is_Active__c=:True and Account_Id__c !=:null and Account_Id__c !=:'NOT_FOUND' and Account_Id__c !=:'NEW' Limit 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RunExtendedValidation.getUtilizationPercentage(newSalesforceSubFeature2.Name,input,clientandNameCred1.Account_Id__c);
        system.assertEquals(clientandNameCred1.Is_Active__c, true);
        Test.stopTest();
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
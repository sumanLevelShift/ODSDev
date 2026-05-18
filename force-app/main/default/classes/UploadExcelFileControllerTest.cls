@isTest
public class UploadExcelFileControllerTest {

    static testMethod void testMethod1()
    {
        Initiatives__c testInitiative=new Initiatives__c();
        testInitiative.Name='Test Initiative';
        testInitiative.JIRA_ID__c='JIR 34564';
        insert testInitiative;
        
        Estimate__c testEstimate=new Estimate__c();
        testEstimate.Phase__c='Development';
        testEstimate.Hours__c=7;
        testEstimate.Task_Components__c='[Custom Fields] - Quote template PDF generation';
        testEstimate.Initiative_Lookup__c=testInitiative.Id;
        insert testEstimate;
        
        Estimate__c testEstimate1=new Estimate__c();
        testEstimate1.Phase__c='Analysis';
        testEstimate1.Hours__c=15;
        testEstimate1.Task_Components__c='[Custom Fields]';
        testEstimate1.Initiative_Lookup__c=testInitiative.Id;
        insert testEstimate1;
        
        string estimateData='{"ODS Estimate":[{"Line Items":"Analysis","Percentage":"12%","Actual Hours":"10"},'+
            '{"Line Items":"Development","Percentage":"18%","Actual Hours":"20"},'+
            '{"Line Items":"Design","Percentage":"18%","Actual Hours":"20"},{"Line Items":"Deployment","Percentage":"18%","Actual Hours":"20"}],"Scope Details":['+
            '{"Sections":"Objective Statement/Acceptance Criteria","Description":"Product, Quote and Order set up (Phase 1)"}],"Inventory":['+
            '{"ColHeader0":""},{"ColHeader0":""},{"ColHeader0":""},'+
            '{"ColHeader1":"Custom Fields","ColHeader3":"Quote \\"template PDF generation","ColHeader6":"5"},{"ColHeader1":"Testing","ColHeader3":"test class","ColHeader6":"7"}]}';
        Test.StartTest();
        ApexPages.currentPage().getParameters().put('intiativeId', String.valueOf(testInitiative.Id));
		ApexPages.currentPage().getParameters().put('json_object', estimateData);
        UploadExcelFileController.saveData();
        Test.StopTest();
    }
}
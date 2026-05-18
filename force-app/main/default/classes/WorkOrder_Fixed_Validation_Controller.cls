public class WorkOrder_Fixed_Validation_Controller {
    Public boolean showErrorMessage{get;set;}
    public WorkOrder_Fixed_Validation_Controller(ApexPages.StandardController sc) {
        showErrorMessage=false;
        Work_Order__c wo=[SELECT Id,Bill_Rate__c,SubCategory__c FROM Work_Order__c WHERE ID=:ApexPages.currentPage().getParameters().get('id')];
        AggregateResult[] AggregateResultList = [select Work_Order__c,Sum(Amount__c )amt from Deliverables__c where Work_Order__c=:wo.Id group by Work_Order__c]; 
        string subCategoryVar=wo.SubCategory__c;
        if(subCategoryVar.toLowerCase().contains('fixed') && !AggregateResultList.isEmpty()){
            if(wo.Bill_Rate__c != AggregateResultList[0].get('amt')){
                showErrorMessage=true;
            }
        }
    }
}
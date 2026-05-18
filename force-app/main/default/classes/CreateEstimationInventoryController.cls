public without sharing class CreateEstimationInventoryController {
    @AuraEnabled(cacheable=false)
    public static string getStatusResult(string estimateSummaryId){
        string approved='';
        system.debug('estimateSummaryId-'+estimateSummaryId);
        List<Estimation_Summary__c> estimationSummary=[SELECT id,Status__c FROM Estimation_Summary__c WHERE (Status__c='Ready for Approval' or Status__c='Obsolete') and id=:estimateSummaryId];
        if(!estimationSummary.isEmpty()){
            approved=estimationSummary[0].Status__c;
        }
        system.debug('approved-'+approved);
        return approved;
    }
    @AuraEnabled( cacheable = true )
    public static List<String> getEffortTypePickListValue(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Estimation_Detail__c.Effort_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getValue());
        }     
        return pickListValuesList;
    }
    @AuraEnabled( cacheable = true )
    public static List<String> getComplexityPickListValue(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Estimation_Detail__c.Complexity__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getValue());
        }     
        return pickListValuesList;
    }
    @AuraEnabled( cacheable = false )
    public static list<Estimation_Detail__c> getExistEstimationDetailForInventory(string estimationSummary){
        list<Estimation_Detail__c> returnComplexityMatrix=[SELECT Assumptions__c,Quantity__c,Brief_Description__c,Complexity_Definition__c,Complexity__c,Effort_Type__c,Entity_Type__c,Estimation_Element__c,Estimation_Summary__c,Platform__c,Project_Specfic_Effort__c,Rationale_If_Different_From_Recommended__c,Recommended_Effort__c,RecordTypeId,S_No__c 
                                                           FROM Estimation_Detail__c WHERE Estimation_Summary__c=:estimationSummary AND RecordType.Name=:'Inventory' ORDER BY S_No__c ASC NULLS FIRST];
        return returnComplexityMatrix;
    }
    
    @AuraEnabled(cacheable=false)
    public static void insertInventoryRecords(String insertInventroy, string estimationSummaryId){
        String gsRecordTypeID = Schema.SObjectType.Estimation_Detail__c.getRecordTypeInfosByName().get('Inventory').getRecordTypeId();
        boolean isCodingInvoled=false;
        list<Estimation_Detail__c> insertED=new List<Estimation_Detail__c>();
        List<Object> obList = (List<object>) json.deserializeUntyped(insertInventroy);
        for(object ob : obList) 
        {
            Map<String, object> obmap = (Map<String, object>)ob;
            decimal SNO = (decimal)obmap.get('SNO');
            String PlatformValue = (String)obmap.get('PlatformValue');
            String EntityTypeValue = (String)obmap.get('EntityTypeValue');
            String EffortTypeValue = (String)obmap.get('EffortTypeValue');
            String EstimationElementValue = (String)obmap.get('EstimationElementValue');
            String BriefDescriptionValue = (String)obmap.get('BriefDescriptionValue');
            String QuantityValue = (String)obmap.get('QuantityValue');
            String ComplexityValue = (String)obmap.get('ComplexityValue');
            string RecommendedEffortValue = (string)obmap.get('RecommendedEffortValue');
            String RevisedEffortValue = (String)obmap.get('RevisedEffortValue');
            String RationalIfDifferentValue = (String)obmap.get('RationalIfDifferentValue');
            String AssumptionValue = (String)obmap.get('AssumptionValue');
            
            system.debug('RecommendedEffortValue-'+RecommendedEffortValue);
            if(!string.isBlank(ComplexityValue)){
                Estimation_Detail__c ed=new Estimation_Detail__c();
                ed.S_No__c=SNO;
                ed.Platform__c=PlatformValue;
                ed.Entity_Type__c=EntityTypeValue;
                ed.Effort_Type__c=EffortTypeValue;
                ed.Estimation_Element__c=EstimationElementValue;
                ed.Brief_Description__c=BriefDescriptionValue;
                ed.Complexity__c=ComplexityValue;
                if(string.isBlank(RecommendedEffortValue)){
                    //ed.Recommended_Effort__c=0;    
                }else{
                    ed.Recommended_Effort__c=decimal.valueOf(RecommendedEffortValue);
                }
                ed.Quantity__c=decimal.valueOf(QuantityValue);
                if(string.isBlank(RevisedEffortValue)){
                    //ed.Project_Specfic_Effort__c=0;    
                }else{
                    ed.Project_Specfic_Effort__c=decimal.valueOf(RevisedEffortValue);
                } 
                ed.Rationale_If_Different_From_Recommended__c=RationalIfDifferentValue;
                ed.Estimation_Summary__c=estimationSummaryId;
                ed.RecordTypeId=gsRecordTypeID;
                ed.Assumptions__c=AssumptionValue;
                insertED.add(ed);
                if(EffortTypeValue =='Programming'){
                    isCodingInvoled=true;
                }
            }
        }
        List<Estimation_Detail__c> existED=[Select Id FROM Estimation_Detail__c WHERE Estimation_Summary__c=:estimationSummaryId AND RecordTypeId=:gsRecordTypeID];
        if(!existED.isEmpty()){
            delete existED;
        }
        if(!insertED.isEmpty()){
            insert insertED;
            list<Estimation_Summary__c> esRecord=[SELECT id,Is_Coding_Involved__c FROM Estimation_Summary__c Where ID=:estimationSummaryId];
            if(!esRecord.isempty()){
                if(isCodingInvoled==true){
                    esRecord[0].Is_Coding_Involved__c=true;
                }else{
                    esRecord[0].Is_Coding_Involved__c=false;
                }
                update esRecord;
            }
        }
        
    }
    @AuraEnabled(cacheable=false)
    public static decimal getRecommendedEffortHours(string platform,string entityType, string effortType, string complexity,string estimationSummary){
        decimal recommendedEffort=0;
        String gsRecordTypeID = Schema.SObjectType.Estimation_Detail__c.getRecordTypeInfosByName().get('Complexity Matrix').getRecordTypeId();
        list<Estimation_Detail__c> getEstimationDetail=[SELECT Complexity__c,Effort_Type__c,Entity_Type__c,Estimation_Summary__c,Platform__c,Project_Specfic_Effort__c,Recommended_Effort__c,RecordTypeId 
                                                        FROM Estimation_Detail__c WHERE Platform__c=:platform AND Entity_Type__c=:entityType AND Effort_Type__c=:effortType AND Complexity__c=:complexity AND RecordTypeId=:gsRecordTypeID and Estimation_Summary__c=:estimationSummary and Project_Specfic_Effort__c !=null LIMIT 1];
        if(!getEstimationDetail.isEmpty()){
            recommendedEffort=getEstimationDetail[0].Project_Specfic_Effort__c;
            
        }else{
            list<Estimation_Complexity_Matrix_REF__mdt> getEstimationComplexityMatrix=[SELECT Complexity__c,Effort_Type__c,Entity_Type__c,Id,Platform__c,Recommended_Effort__c FROM Estimation_Complexity_Matrix_REF__mdt WHERE 
                                                                                       Platform__c=:platform AND Entity_Type__c=:entityType AND Effort_Type__c=:effortType AND Complexity__c=:complexity LIMIT 1];
            if(!getEstimationComplexityMatrix.isEmpty()){
                recommendedEffort=getEstimationComplexityMatrix[0].Recommended_Effort__c;
            }
        }
        return recommendedEffort;
    }
    @AuraEnabled(cacheable=true)
    public static string getRecordTypeIdForInventory(){
        String gsRecordTypeID = Schema.SObjectType.Estimation_Detail__c.getRecordTypeInfosByName().get('Inventory').getRecordTypeId();
        return gsRecordTypeID;
    }
    @AuraEnabled( cacheable = false )
    public static boolean checkExistRecordCount(string estimateSummaryId){
        boolean flag=false;
        list<Estimation_Detail__c> returnComplexityMatrix=[SELECT Quantity__c,Brief_Description__c,Complexity_Definition__c,Complexity__c,Effort_Type__c,Entity_Type__c,Estimation_Element__c,Estimation_Summary__c,Platform__c,Project_Specfic_Effort__c,Rationale_If_Different_From_Recommended__c,Recommended_Effort__c,RecordTypeId,S_No__c 
                                                           FROM Estimation_Detail__c WHERE Estimation_Summary__c=:estimateSummaryId AND RecordType.Name=:'Inventory' ORDER BY S_No__c ASC NULLS FIRST];
        if(!returnComplexityMatrix.isEmpty()){
            flag=true;
        }
        return flag;
    }
    @AuraEnabled(cacheable=false)
    public static boolean checkEstimationIsApproved(string estimateSummaryId){
        boolean approved=false;
        List<Estimation_Summary__c> estimationSummary=[SELECT id,Status__c FROM Estimation_Summary__c WHERE Status__c='Approved' and id=:estimateSummaryId];
        if(!estimationSummary.isEmpty()){
            approved=true;
        }
        return approved;
    }
    
    @AuraEnabled( cacheable = false )
    public static boolean validationForApproverButton(string summaryId){
        boolean button=false;
        List<Estimation_Summary__c> summaryList=[SELECT Program_Manager__r.Delivery_Role__c,SME_Vertical__r.Delivery_Role__c,Technical_Project_Manager__r.Delivery_Role__c,
                                                 Program_Manager__r.Full_Name__c,SME_Vertical__r.Full_Name__c,Technical_Project_Manager__r.Full_Name__c,Id,Technical_Project_Manager__c,SME_Vertical__c,Program_Manager__c,Approved_User_Track__c FROM Estimation_Summary__c where id=:summaryId AND Status__c=:'Ready for Approval' limit 1];
        if(!summaryList.isEmpty()){
            string info=summaryList[0].Approved_User_Track__c;
            List<User> currentUserList=[SELECT Id, Name ,Delivery_Role__c FROM User WHERE ID=:UserInfo.getUserId() LIMIT 1];
            string deliveryRoleUser=currentUserList[0].Delivery_Role__c;
            //TPM's
            if(summaryList[0].Technical_Project_Manager__c !=null && deliveryRoleUser.contains(summaryList[0].Technical_Project_Manager__r.Delivery_Role__c)){
                if(string.isNotBlank(info)){
                    if(!info.contains(summaryList[0].Technical_Project_Manager__r.Full_Name__c)){
                        button=true;
                    }
                }else{
                    button=true; 
                }
            }
            
            //SEM vertical Users
            if(summaryList[0].SME_Vertical__c !=null && (deliveryRoleUser.contains(summaryList[0].Technical_Project_Manager__r.Delivery_Role__c) && summaryList[0].SME_Vertical__r.Delivery_Role__c=='Program Manager')||
               (summaryList[0].SME_Vertical__r.Delivery_Role__c == currentUserList[0].Delivery_Role__c))
            {
                if(string.isNotBlank(info)){
                    if(!info.contains(summaryList[0].SME_Vertical__r.Full_Name__c)){
                        button=true;   
                    }
                }else{
                    button=true;    
                }
            }
            
            //program manager user
            if(summaryList[0].Program_Manager__c !=null && deliveryRoleUser.contains(summaryList[0].Program_Manager__r.Delivery_Role__c)){
                if(string.isNotBlank(info)){
                    if(!info.contains(summaryList[0].Program_Manager__r.Full_Name__c)){
                        button=true;
                    }
                }else{
                    button=true;
                }
            }
            
        }
        return button;
    }
}
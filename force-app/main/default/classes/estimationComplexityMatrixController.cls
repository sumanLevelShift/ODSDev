public without sharing class estimationComplexityMatrixController {
 
    @AuraEnabled( cacheable = true )
    public static list<Estimation_Complexity_Matrix_REF__mdt> getComplexityMatrixList(Integer limitSize, Integer offset){
        list<Estimation_Complexity_Matrix_REF__mdt> getECMList=new list<Estimation_Complexity_Matrix_REF__mdt>();
        system.debug('limitSize--'+limitSize);
                system.debug('offset--'+offset);

        getECMList=[SELECT Id,Complexity_Definition__c,Complexity__c,DeveloperName,Effort_Type__c,Entity_Type__c,Platform__c,Recommended_Effort__c FROM Estimation_Complexity_Matrix_REF__mdt ORDER BY DeveloperName ASC NULLS FIRST LIMIT :limitSize OFFSET :offset];
        
        return getECMList;
        
    }
    @AuraEnabled( cacheable = false )
    public static  list<Estimation_Detail__c> getExistEstimationDetailForComplexityMatrix(string estimationSummary,Integer limitSize, Integer offset){
        list<Estimation_Detail__c> returnComplexityMatrix=new list<Estimation_Detail__c>();
        
        returnComplexityMatrix=[SELECT Brief_Description__c,Complexity_Definition__c,Complexity__c,Effort_Type__c,Entity_Type__c,Estimation_Element__c,Estimation_Summary__c,Platform__c,Project_Specfic_Effort__c,Rationale_If_Different_From_Recommended__c,Recommended_Effort__c,RecordTypeId,S_No__c 
                                FROM Estimation_Detail__c WHERE Estimation_Summary__c=:estimationSummary AND RecordType.Name=:'Complexity Matrix' ORDER BY S_No__c ASC NULLS FIRST LIMIT :limitSize OFFSET :offset];   
        
        return returnComplexityMatrix;
    }
    @AuraEnabled(cacheable=false)
    public static boolean insertComplexityMatrix(String insertComplex, string estimationSummaryId){
        system.debug('insertComplex--'+insertComplex);
        String gsRecordTypeID = Schema.SObjectType.Estimation_Detail__c.getRecordTypeInfosByName().get('Complexity Matrix').getRecordTypeId();
        system.debug('gsRecordTypeID---'+gsRecordTypeID);
        Map<id,Estimation_Complexity_Matrix_REF__mdt> getECMList=new Map<id,Estimation_Complexity_Matrix_REF__mdt>([SELECT Complexity_Definition__c,Complexity__c,DeveloperName,Effort_Type__c,Entity_Type__c,Id,Label,Language,MasterLabel,NamespacePrefix,Platform__c,QualifiedApiName,Recommended_Effort__c FROM Estimation_Complexity_Matrix_REF__mdt ORDER BY Entity_Type__c ASC NULLS FIRST]);
        list<Estimation_Detail__c> insertECMList=new list<Estimation_Detail__c>();
        set<id> insertComplexityID=new set<id>();
        decimal snumber=0;
        List<Object> obList = (List<object>) json.deserializeUntyped(insertComplex);
        for(object ob : obList) 
        {
            Map<String, object> obmap = (Map<String, object>)ob;
            String ComplexityId = (String)obmap.get('ComplexityMatrixId');
            decimal SNO = (decimal)obmap.get('SNO');
            String revisedEffortValue = (String)obmap.get('RevisedEffortValue');
            String rationalIfDifferentValue = (String)obmap.get('RationalIfDifferentValue');
            system.debug('ComplexityId---'+ComplexityId);
            Estimation_Complexity_Matrix_REF__mdt eComplexityMatrix=getECMList.get(ComplexityId);
            insertComplexityID.add(ComplexityId);
            snumber=SNO;
            Estimation_Detail__c ecm=new Estimation_Detail__c();
            if(estimationSummaryId.length() !=0){
                ecm.Estimation_Summary__c=estimationSummaryId;
                ecm.RecordTypeId=gsRecordTypeID;
                ecm.S_No__c=SNO;
                ecm.Entity_Type__c=eComplexityMatrix.Entity_Type__c;
                ecm.Complexity__c=eComplexityMatrix.Complexity__c;
                ecm.Complexity_Definition__c=eComplexityMatrix.Complexity_Definition__c;
                ecm.Platform__c=eComplexityMatrix.Platform__c;
                ecm.Effort_Type__c=eComplexityMatrix.Effort_Type__c;
                ecm.Recommended_Effort__c=eComplexityMatrix.Recommended_Effort__c;
                if(revisedEffortValue.length()==0){
                    ecm.Project_Specfic_Effort__c=null;
                }else{
                    ecm.Project_Specfic_Effort__c=decimal.valueOf(revisedEffortValue);
                }
                ecm.Rationale_If_Different_From_Recommended__c=rationalIfDifferentValue;
                insertECMList.add(ecm);
            }
        }
        List<Estimation_Complexity_Matrix_REF__mdt> getECMListMissed=[SELECT Complexity_Definition__c,Complexity__c,DeveloperName,Effort_Type__c,Entity_Type__c,Id,Label,Language,MasterLabel,NamespacePrefix,Platform__c,QualifiedApiName,Recommended_Effort__c FROM Estimation_Complexity_Matrix_REF__mdt WHERE ID NOT IN : insertComplexityID ORDER BY Entity_Type__c ASC NULLS FIRST];
        for(Estimation_Complexity_Matrix_REF__mdt eComplexityMatrix:getECMListMissed){
            Estimation_Detail__c ecm=new Estimation_Detail__c();
            snumber=snumber+1;
            ecm.Estimation_Summary__c=estimationSummaryId;
            ecm.RecordTypeId=gsRecordTypeID;
            ecm.S_No__c=snumber;
            ecm.Entity_Type__c=eComplexityMatrix.Entity_Type__c;
            ecm.Complexity__c=eComplexityMatrix.Complexity__c;
            ecm.Complexity_Definition__c=eComplexityMatrix.Complexity_Definition__c;
            ecm.Platform__c=eComplexityMatrix.Platform__c;
            ecm.Effort_Type__c=eComplexityMatrix.Effort_Type__c;
            ecm.Recommended_Effort__c=eComplexityMatrix.Recommended_Effort__c;
            ecm.Project_Specfic_Effort__c=null;
            ecm.Rationale_If_Different_From_Recommended__c=null;
            insertECMList.add(ecm);  
        }
        if(!insertECMList.isEmpty()){
            List<Estimation_Detail__c> existED=[Select Id FROM Estimation_Detail__c WHERE Estimation_Summary__c=:estimationSummaryId AND RecordTypeId=:gsRecordTypeID];
            if(!existED.isEmpty()){
                delete existED;
            }
            insert insertECMList;
            String inventoryRecordTypeID = Schema.SObjectType.Estimation_Detail__c.getRecordTypeInfosByName().get('Inventory').getRecordTypeId();
            list<Estimation_Detail__c> getEstimationDetail=[SELECT Complexity__c,Effort_Type__c,Entity_Type__c,Estimation_Summary__c,Platform__c,Project_Specfic_Effort__c,Recommended_Effort__c,RecordTypeId 
                                                            FROM Estimation_Detail__c WHERE RecordTypeId=:inventoryRecordTypeID and Estimation_Summary__c=:estimationSummaryId];
            List<Estimation_Detail__c> updateEstimationDetail=new List<Estimation_Detail__c>();
            for(Estimation_Detail__c ed:getEstimationDetail){
                decimal recommendedHour=0;
                recommendedHour=getRecommendedEffortHour(ed.Platform__c,ed.Entity_Type__c,ed.Effort_Type__c,ed.Complexity__c,estimationSummaryId);
                if(recommendedHour !=0){
                    Estimation_Detail__c e=new Estimation_Detail__c();
                    e.id=ed.id;
                    e.Recommended_Effort__c=recommendedHour;
                    updateEstimationDetail.add(e);
                }
            }
            if(!updateEstimationDetail.isEmpty()){
                update updateEstimationDetail;
            }
        }
        return true;
    }
    @AuraEnabled(cacheable=false)
    public static boolean updateComplexityMatrix(String updateComplex, string estimationSummaryId){
        String gsRecordTypeID = Schema.SObjectType.Estimation_Detail__c.getRecordTypeInfosByName().get('Complexity Matrix').getRecordTypeId();
        system.debug('gsRecordTypeID---'+gsRecordTypeID);
        Map<id,Estimation_Detail__c> getECMList=new Map<id,Estimation_Detail__c>([SELECT Brief_Description__c,Complexity_Definition__c,Complexity__c,Estimation_Summary__c,Id,Project_Specfic_Effort__c,Rationale_If_Different_From_Recommended__c,RecordTypeId 
                                                                                  FROM Estimation_Detail__c WHERE Estimation_Summary__c=:estimationSummaryId AND RecordTypeId=:gsRecordTypeID]);
        list<Estimation_Detail__c> updateECMList=new list<Estimation_Detail__c>();
        system.debug('estimationSummaryId---'+estimationSummaryId);
        List<Object> obList = (List<object>) json.deserializeUntyped(updateComplex);
        for(object ob : obList) 
        {
            Map<String, object> obmap = (Map<String, object>)ob;
            String EstimationDetailId = (String)obmap.get('EstimationDetailId');
            String revisedEffortValue = (String)obmap.get('RevisedEffortValue');
            String rationalIfDifferentValue = (String)obmap.get('RationalIfDifferentValue');
            Estimation_Detail__c eComplexityMatrix=getECMList.get(EstimationDetailId);
            Estimation_Detail__c ecm=new Estimation_Detail__c();
            if(estimationSummaryId.length() !=0){
                if(eComplexityMatrix !=null){
                    ecm.id=eComplexityMatrix.id;
                    
                    if(revisedEffortValue.length()==0){
                        ecm.Project_Specfic_Effort__c=null;
                    }else{
                        ecm.Project_Specfic_Effort__c=decimal.valueOf(revisedEffortValue);
                    }
                    ecm.Rationale_If_Different_From_Recommended__c=rationalIfDifferentValue;
                    updateECMList.add(ecm);
                }
            }
        }
        
        if(!updateECMList.isEmpty()){
            
            update updateECMList;
            
            String inventoryRecordTypeID = Schema.SObjectType.Estimation_Detail__c.getRecordTypeInfosByName().get('Inventory').getRecordTypeId();
            
            list<Estimation_Detail__c> getEstimationDetail=[SELECT Complexity__c,Effort_Type__c,Entity_Type__c,Estimation_Summary__c,Platform__c,Project_Specfic_Effort__c,Recommended_Effort__c,RecordTypeId 
                                                            FROM Estimation_Detail__c WHERE RecordTypeId=:inventoryRecordTypeID and Estimation_Summary__c=:estimationSummaryId];
            system.debug('getEstimationDetail--'+getEstimationDetail);
            List<Estimation_Detail__c> updateEstimationDetail=new List<Estimation_Detail__c>();
            for(Estimation_Detail__c ed:getEstimationDetail){
                decimal recommendedHour=0;
                recommendedHour=getRecommendedEffortHour(ed.Platform__c,ed.Entity_Type__c,ed.Effort_Type__c,ed.Complexity__c,estimationSummaryId);
                if(recommendedHour !=0){
                    Estimation_Detail__c e=new Estimation_Detail__c();
                    e.id=ed.id;
                    e.Recommended_Effort__c=recommendedHour;
                    updateEstimationDetail.add(e);
                }
            }
            if(!updateEstimationDetail.isEmpty()){
                update updateEstimationDetail;
            }
        }
        return true;
    }
    public static decimal getRecommendedEffortHour(string platform,string entityType, string effortType, string complexity,string estimationSummary){
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
    @AuraEnabled( cacheable = false )
    public static list<Estimation_Detail__c> getFilterComplexityMatrixFromEstDetails(string estimationSummary,string entityType,string platform,Integer limitSize, Integer offset){
        list<Estimation_Detail__c> returnComplexityMatrix=new list<Estimation_Detail__c>();
        
            if(string.isNotBlank(entityType) && string.isNotBlank(platform)){
                returnComplexityMatrix=[SELECT Brief_Description__c,Complexity_Definition__c,Complexity__c,Effort_Type__c,Entity_Type__c,Estimation_Element__c,Estimation_Summary__c,Platform__c,Project_Specfic_Effort__c,Rationale_If_Different_From_Recommended__c,Recommended_Effort__c,RecordTypeId,S_No__c 
                                        FROM Estimation_Detail__c WHERE Estimation_Summary__c=:estimationSummary AND RecordType.Name=:'Complexity Matrix' AND ( Platform__c=:platform AND Entity_Type__c=:entityType ) ORDER BY S_No__c ASC NULLS FIRST LIMIT :limitSize OFFSET :offset];
            } else if(string.isNotBlank(platform) && string.isBlank(entityType)){
                returnComplexityMatrix=[SELECT Brief_Description__c,Complexity_Definition__c,Complexity__c,Effort_Type__c,Entity_Type__c,Estimation_Element__c,Estimation_Summary__c,Platform__c,Project_Specfic_Effort__c,Rationale_If_Different_From_Recommended__c,Recommended_Effort__c,RecordTypeId,S_No__c 
                                        FROM Estimation_Detail__c WHERE Estimation_Summary__c=:estimationSummary AND RecordType.Name=:'Complexity Matrix' AND ( Platform__c=:platform ) ORDER BY S_No__c ASC NULLS FIRST LIMIT :limitSize OFFSET :offset];
            } else if(string.isBlank(platform) && string.isBlank(entityType)){
                returnComplexityMatrix=[SELECT Brief_Description__c,Complexity_Definition__c,Complexity__c,Effort_Type__c,Entity_Type__c,Estimation_Element__c,Estimation_Summary__c,Platform__c,Project_Specfic_Effort__c,Rationale_If_Different_From_Recommended__c,Recommended_Effort__c,RecordTypeId,S_No__c 
                                        FROM Estimation_Detail__c WHERE Estimation_Summary__c=:estimationSummary AND RecordType.Name=:'Complexity Matrix' ORDER BY S_No__c ASC NULLS FIRST LIMIT :limitSize OFFSET :offset]; 
            } 
   
        return returnComplexityMatrix;
        //return returnComplexityMatrix;
    }
    @AuraEnabled( cacheable = false )
    public static list<Estimation_Complexity_Matrix_REF__mdt> getFilterComplexityMatrixFromcustomMetadata(string entityType,string platform,Integer limitSize, Integer offset ){
        list<Estimation_Complexity_Matrix_REF__mdt> getECMList =new list<Estimation_Complexity_Matrix_REF__mdt>();
            if(string.isNotBlank(entityType) && string.isNotBlank(platform)){
                getECMList=[SELECT Id,Complexity_Definition__c,Complexity__c,DeveloperName,Effort_Type__c,Entity_Type__c,Platform__c,Recommended_Effort__c 
                            FROM Estimation_Complexity_Matrix_REF__mdt WHERE  Platform__c=:platform AND Entity_Type__c=:entityType  ORDER BY DeveloperName ASC NULLS FIRST LIMIT :limitSize OFFSET :offset];  
            } else if(string.isNotBlank(platform) && string.isBlank(entityType)){
                getECMList=[SELECT Id,Complexity_Definition__c,Complexity__c,DeveloperName,Effort_Type__c,Entity_Type__c,Platform__c,Recommended_Effort__c 
                            FROM Estimation_Complexity_Matrix_REF__mdt WHERE  Platform__c=:platform  ORDER BY DeveloperName ASC NULLS FIRST LIMIT :limitSize OFFSET :offset];
            } else if(string.isBlank(platform) && string.isBlank(entityType)){
                getECMList=[SELECT Id,Complexity_Definition__c,Complexity__c,DeveloperName,Effort_Type__c,Entity_Type__c,Platform__c,Recommended_Effort__c 
                            FROM Estimation_Complexity_Matrix_REF__mdt  ORDER BY DeveloperName ASC NULLS FIRST LIMIT :limitSize OFFSET :offset];  
            }  
       
        return getECMList;
    }
}
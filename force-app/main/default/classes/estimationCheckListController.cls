public without sharing class estimationCheckListController {
    
    @AuraEnabled( cacheable = true )
    public static List<Estimation_Checklist_REF__mdt > getCheckList(string estimationSummaryId){
        String gsRecordTypeID = Schema.SObjectType.Estimation_Detail__c.getRecordTypeInfosByName().get('Inventory').getRecordTypeId();
        List<String> entityTypeList=New List<String>();
        List<Estimation_Detail__c> estimationDetailsList=[SELECT Entity_Type__c,Estimation_Summary__c,Id,RecordTypeId FROM Estimation_Detail__c WHERE RecordTypeId=:gsRecordTypeID AND Estimation_Summary__c=:estimationSummaryId ];
        For(Estimation_Detail__c ed:estimationDetailsList){
            entityTypeList.add(ed.Entity_Type__c);
        }
        
        List<Estimation_Checklist_REF__mdt > getcList=[SELECT Active__c,Activities__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,Entity_Type__c FROM Estimation_Checklist_REF__mdt where Active__c=true ORDER BY Label ASC NULLS FIRST];
        
        Set<Id> estimationCheckListId=New Set<Id>();
        for(Estimation_Checklist_REF__mdt ec:getcList){
            if(ec.Entity_Type__c=='All'){
                estimationCheckListId.add(ec.id);
            }else{
                for(String entityTypeValue:entityTypeList){
                    if(ec.Entity_Type__c.contains(entityTypeValue)) {
                        estimationCheckListId.add(ec.id);
                    }
                }
            }
        }
        List<Estimation_Checklist_REF__mdt > getcListFinal=[SELECT Active__c,Activities__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,Entity_Type__c FROM Estimation_Checklist_REF__mdt where Active__c=true AND ID=:estimationCheckListId ORDER BY Label ASC NULLS FIRST];
        system.debug('getcListFinal--'+getcListFinal);
        return getcListFinal;
    }
    @AuraEnabled(cacheable=false)
    public static boolean insertInsertCheckList(String insertCheckList, string estimationSummaryId){
        system.debug('insertCheckList--'+insertCheckList);
        Map<id,Estimation_Checklist_REF__mdt > getcList=New Map<id,Estimation_Checklist_REF__mdt >([SELECT Active__c,Activities__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,QualifiedApiName FROM Estimation_Checklist_REF__mdt where Active__c=true ORDER BY Label ASC NULLS FIRST]);
        list<Estimation_Checklist__c> insertCheck=new list<Estimation_Checklist__c>();
        
        List<Object> obList = (List<object>) json.deserializeUntyped(insertCheckList);
        if(estimationSummaryId.length() !=0){
            
            for(object ob : obList) 
            {
                Map<String, object> obmap = (Map<String, object>)ob;
                String CHECKLISTID = (String)obmap.get('CheckListIdCM');
                Decimal sno = (decimal)obmap.get('SNO');
                Boolean status = (boolean)obmap.get('Status');
                String REMARKS = (String)obmap.get('RemarkTextArea');
                Estimation_Checklist_REF__mdt ecr=getcList.get(CHECKLISTID);
                system.debug('ecr!!'+ecr);
                Estimation_Checklist__c ec=new Estimation_Checklist__c();
                ec.Remarks__c=REMARKS;
                ec.Activities__c=ecr.Activities__c;
                ec.S_No__c=sno;
                if(status){
                    ec.Status__c='Yes';
                }else{
                    ec.Status__c='No';
                }
                ec.Estimation_Summary__c=estimationSummaryId;
                //ec.Required__c=ecr.Required__c;
                insertCheck.add(ec);
            }
        }
        if(!insertCheck.isEmpty()){
            insert insertCheck;
        }
        return true;
    }
    @AuraEnabled(cacheable=false)
    public static boolean updateCheckList(String updateCheckList, string estimationSummaryId){
        
        Map<id,Estimation_Checklist__c> getExistcheckList=new Map<id,Estimation_Checklist__c>([SELECT Activities__c,Check__c,Estimation_Summary__c,Id,Remarks__c,Required__c,Status__c,S_No__c FROM Estimation_Checklist__c WHERE Estimation_Summary__c=:estimationSummaryId]);
        list<Estimation_Checklist__c> updateExistCheckList=new list<Estimation_Checklist__c>();
        List<Object> obList = (List<object>) json.deserializeUntyped(updateCheckList);
        for(object ob : obList) 
        {
            Map<String, object> obmap = (Map<String, object>)ob;
            String CheckListId = (String)obmap.get('CheckListId');
            Boolean status = (boolean)obmap.get('Status');
            String RemarkTextArea = (String)obmap.get('RemarkTextArea');
            Estimation_Checklist__c checkListRecord=getExistcheckList.get(CheckListId);
            Estimation_Checklist__c ec=new Estimation_Checklist__c();
            if(estimationSummaryId.length() !=0){
                ec.Id=checkListRecord.Id;
                ec.Remarks__c=RemarkTextArea;
                if(status){
                    ec.Status__c='Yes';
                }else{
                    ec.Status__c='No';
                }
                updateExistCheckList.add(ec);
            }
        }
        
        if(!updateExistCheckList.isEmpty()){
            
            update updateExistCheckList;
        }
        return true;
    }
  
    @AuraEnabled(cacheable=false)
    public static List<Estimation_Checklist__c> getCheckListRecord(String estimationSummaryId){
        List<Estimation_Checklist__c> insertEstimationCheckList=New List<Estimation_Checklist__c>();
        List<Estimation_Checklist_REF__mdt> estimationCheckListCustomMetadata=getCheckList(estimationSummaryId);
        Map<String,Estimation_Checklist__c> existActivitiesCheckList=New Map<String,Estimation_Checklist__c>();
        List<Estimation_Checklist__c> getcheckList=[SELECT Activities__c,Check__c,Estimation_Summary__c,Id,Remarks__c,Required__c,Status__c,S_No__c FROM Estimation_Checklist__c WHERE Estimation_Summary__c=:estimationSummaryId];
        for(Estimation_Checklist__c ec:getcheckList){
            existActivitiesCheckList.put(ec.Activities__c,ec);
        }
        decimal sno=0;
        For(Estimation_Checklist_REF__mdt checkListCustomMetadata:estimationCheckListCustomMetadata){
            sno++;
            Estimation_Checklist__c newEC=new Estimation_Checklist__c();
            if(existActivitiesCheckList.containsKey(checkListCustomMetadata.Activities__c)){
                Estimation_Checklist__c exitsEC=existActivitiesCheckList.get(checkListCustomMetadata.Activities__c);
                system.debug('exitsEC0---'+exitsEC);
                newEC.Remarks__c=exitsEC.Remarks__c;
                newEC.Activities__c=exitsEC.Activities__c;
                newEC.S_No__c=sno;
                newEC.Status__c=exitsEC.Status__c;
                newEC.Estimation_Summary__c=estimationSummaryId;
                newEC.Required__c=exitsEC.Required__c;
                newEC.Check__c=exitsEC.Check__c;
                insertEstimationCheckList.add(newEC);
                
            }else{
                newEC.Activities__c=checkListCustomMetadata.Activities__c;
                newEC.S_No__c=sno; 
                newEC.Estimation_Summary__c=estimationSummaryId;
                insertEstimationCheckList.add(newEC);
            }
        }
        if(!getcheckList.isEmpty()){
            delete getcheckList;
        }
        system.debug('insertEstimationCheckList--'+insertEstimationCheckList);
        if(!insertEstimationCheckList.isEmpty()){
            insert insertEstimationCheckList;
        }
        /* Map<string,Estimation_Checklist__c> existingEstimationCheckListRecords=New Map<string,Estimation_Checklist__c>();
String gsRecordTypeID = Schema.SObjectType.Estimation_Detail__c.getRecordTypeInfosByName().get('Inventory').getRecordTypeId();
List<String> entityTypeList=New List<String>();
List<Estimation_Detail__c> estimationDetailsList=[SELECT Entity_Type__c,Estimation_Summary__c,Id,RecordTypeId FROM Estimation_Detail__c WHERE RecordTypeId=:gsRecordTypeID AND Estimation_Summary__c=:estimationSummaryId ];
For(Estimation_Detail__c ed:estimationDetailsList){
entityTypeList.add(ed.Entity_Type__c);
}

List<Estimation_Checklist__c> getcheckList=[SELECT Activities__c,Check__c,Estimation_Summary__c,Id,Remarks__c,Required__c,Status__c,S_No__c FROM Estimation_Checklist__c WHERE Estimation_Summary__c=:estimationSummaryId];
for(Estimation_Checklist__c ec:getcheckList){
existingEstimationCheckListRecords.put(ec.Activities__c,ec);
}
decimal sno=[SELECT S_No__c FROM Estimation_Checklist__c WHERE Estimation_Summary__c = :estimationSummaryId ORDER BY S_No__c DESC NULLS FIRST limit 1].S_No__c;
List<Estimation_Checklist_REF__mdt > getcList=[SELECT Active__c,Activities__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,Entity_Type__c FROM Estimation_Checklist_REF__mdt where Active__c=true and Activities__c NOT IN:existingEstimationCheckListRecords.keySet() ORDER BY Label ASC NULLS FIRST];
List<Estimation_Checklist__c> newCheckList=New List<Estimation_Checklist__c>();
for(Estimation_Checklist_REF__mdt ec:getcList){
for(String entityTypeValue:entityTypeList){
if(ec.Entity_Type__c.contains(entityTypeValue)) {
sno++;
Estimation_Checklist__c e=new Estimation_Checklist__c();
e.Activities__c=ec.Activities__c;
e.S_No__c=sno;
e.Estimation_Summary__c=estimationSummaryId;
newCheckList.add(e);
}
}
}
if(!newCheckList.isEmpty()){
insert newCheckList;
}*/
        List<Estimation_Checklist__c> getcheckListFinal=[SELECT Activities__c,Check__c,Estimation_Summary__c,Id,Remarks__c,Required__c,Status__c,S_No__c FROM Estimation_Checklist__c WHERE Estimation_Summary__c=:estimationSummaryId ORDER BY S_No__c ASC NULLS FIRST];
        return getcheckListFinal;
    }
}
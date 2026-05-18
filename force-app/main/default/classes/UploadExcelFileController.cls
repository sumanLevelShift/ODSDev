public with sharing class UploadExcelFileController {
    //public string estimateJSON {get; set;}
    public static void saveData()
    {
        string estimateJSON=Apexpages.currentPage().getParameters().get('json_object');
        string initiativeId=Apexpages.currentPage().getParameters().get('intiativeId');
            
        if(estimateJSON == null || estimateJSON.length() == 0){
            return;
        }
        map<string,object> sheetData=(map<string,object>)system.JSON.deserializeUntyped(estimateJSON);
        //List<object> recordList=(list<object>)system.JSON.deserializeUntyped(estimateJSON);
        List<object> recordList = (List<object>)sheetData.get('ODS Estimate');
        List<object> scopeRecordList = (List<object>)sheetData.get('Scope Details');
        List<object> inventoryRecordList = (List<object>)sheetData.get('Inventory');
		saveEstimates(recordList,inventoryRecordList,initiativeId);
        saveScopeDetails(scopeRecordList,initiativeId);
    }
    
    public static void saveEstimates(List<object> recordList, List<object> inventoryRecordList, String initiativeId)
    {
        String phase;
        Decimal hours;
        Integer checker=0;
        List<Estimate__c> estimatePresentRecords= new list<Estimate__c>();
        List<Estimate__c> estimateRecordsToUpsert= new list<Estimate__c>();
        List<Estimate__c> estimateRecordsToDelete= new list<Estimate__c>();
        List<Estimate__c> estimateRecordsToInsert= new list<Estimate__c>();
        Map<string, Decimal> phaseHourMap=new map<string, Decimal>();
        Map<string,Decimal> inventoryRecords = new map<string,Decimal>();
        for(Integer i=0; i<(recordList.size()-1); i++)
        {
            map<string,object> recordMap=(map<string,object>)recordList[i];
            hours=Decimal.valueof(String.valueof(recordMap.get('Actual Hours')));
            phase=String.valueof(recordMap.get('Line Items'));
            if(phase == 'Development')
            {
            	estimateRecordsToInsert = readInventory(inventoryRecordList, initiativeId);
            }
            else
            {
               phaseHourMap.put(phase, hours); 
            }
        }
        estimatePresentRecords=[select Id, Hours__c, Phase__c, Task_Components__c, Initiative_Lookup__c From Estimate__c where Initiative_Lookup__c = :initiativeId];
        if(estimatePresentRecords.size()>0)
        {
            for(Estimate__c e:estimatePresentRecords)
            {
                if((e.Phase__c != 'Development') && (phaseHourMap.containsKey(e.Phase__c)))
                {
                        e.Hours__c=phaseHourMap.get(e.Phase__c);
                        estimateRecordsToUpsert.add(e);
                    	phaseHourMap.remove(e.Phase__c);
                }
                if((e.Phase__c == 'Development') && (estimateRecordsToInsert.size()>0))
                {
                    estimateRecordsToDelete.add(e);
                }
            }
        }  
        if(phaseHourMap.size()>0)
        {
            for(string p: phaseHourMap.keySet()) 
            {
                Estimate__c estimate=new Estimate__c();
                estimate.Phase__c=p;
                estimate.Hours__c=phaseHourMap.get(p);
                estimate.Initiative_Lookup__c=initiativeId;
                estimateRecordsToUpsert.add(estimate);
            }
        }
        try 
        {
            if(estimateRecordsToInsert.size()>0)
            {
                estimateRecordsToUpsert.addAll(estimateRecordsToInsert);
                delete estimateRecordsToDelete;
            }    
            upsert estimateRecordsToUpsert; 
        }
        catch(exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Upload Failed ' + e.getMessage()));
        }
    }
    
    public static void saveScopeDetails(List<object> scopeRecordList, String initiativeId)
    {
        String section;
        String description;
        Map<string,string> scopeRecords=new map<string,string>();
        for(Integer i=0; i<(scopeRecordList.size()); i++)
        {
            map<string,object> scopeRecordMap=(map<string,object>)scopeRecordList[i];
            section=String.valueof(scopeRecordMap.get('Sections'));
            description=String.valueof(scopeRecordMap.get('Description'));
            scopeRecords.put(section,description);
        }
        Initiatives__c currentInitiative=[select Id, Brief_Description__c from Initiatives__c where Id =:initiativeId Limit 1];
        String table  ='<table border="0.7" cellspacing="1" cellpadding="2" style="font-size:12px;">';
		table=table+'<tbody><tr><th>Sections</th><th>Description</th></tr>';
        if(scopeRecords.size()>0)
        {
            for(string r: scopeRecords.keySet()) 
            {
                string p=scopeRecords.get(r);
                if (String.isBlank(p))
                {
                  table=table + '<tr><td>' + r + '</td><td style="text-align:justify;">' + '' + '</td></tr>';  
                }
                else
                {
                  p=p.replace('\r\n', '<br/>');
                  table=table + '<tr><td>' + r + '</td><td style="text-align:justify;">' + p + '</td></tr>';  
                }
                
            }
        }
        else{
            return;
        } 
        table=table +'</tbody></table>';
        currentInitiative.Brief_Description__c = table;  
         try 
        {
             update currentInitiative;      
        }
        catch(exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Update Failed ' + e.getMessage()));
        }  
    }
    public static List<Estimate__c> readInventory (List<object> inventoryRecordList, String initiativeId)
    {
        Decimal effortHours;
        string taskComponent;
        Integer nullchecker=0;
        List<Estimate__c> estimateRecordsToInsert= new list<Estimate__c>();
        Map<string,decimal> inventoryRecords = new map<string,decimal>();
        
        for(Integer i=0; i<(inventoryRecordList.size()); i++)
        {
            map<string,object> inventoryRecordMap=(map<string,object>)inventoryRecordList[i];
            if( i >= 3 && (inventoryRecordMap.get('ColHeader1') != '')&&(inventoryRecordMap.get('ColHeader3') != '')&&(inventoryRecordMap.get('ColHeader6') != ''))
            {
                taskComponent = '['+ (String.valueof(inventoryRecordMap.get('ColHeader1'))).remove('"') + '] - ' + (String.valueof(inventoryRecordMap.get('ColHeader3'))).remove('"');
                effortHours = Decimal.valueof(String.valueof(inventoryRecordMap.get('ColHeader6')));
                inventoryRecords.put(taskComponent,effortHours);
                Estimate__c estimate=new Estimate__c();
                estimate.Phase__c='Development';
                estimate.Hours__c=effortHours;
                estimate.Task_Components__c=taskComponent;
                estimate.Initiative_Lookup__c=initiativeId;
                estimateRecordsToInsert.add(estimate);
            }
            else if(i >= 3 && (inventoryRecordMap.get('ColHeader1') == '')&&(inventoryRecordMap.get('ColHeader3') == '')&&(inventoryRecordMap.get('ColHeader6') == ''))
            {
                nullchecker=nullchecker+1;
            }
            if(nullchecker >= 3)
            {
                break;
            }
        }
        return estimateRecordsToInsert;
    }
}
public class conditionalRendererConfigController {
    @AuraEnabled (cacheable=false)
    public static List<Conditional_Renderer_Config__mdt> getExistingRecords(){
        List<Conditional_Renderer_Config__mdt> getExistingList=[SELECT Action__c,Controlling_Field__c,DeveloperName,Fields__c,Id,Label,Sobject__c,Type__c,Value__c FROM Conditional_Renderer_Config__mdt ORDER BY SystemModstamp ASC NULLS FIRST];
        return getExistingList;
    }
    @AuraEnabled (cacheable=false)
    public static boolean checkDuplicateRecords(string sObjectName, string controllingField, string value, string action, string recordId){
        Boolean duplicateFound=false;  
        string conditionalRendererId=null;
        if (string.isNotBlank(recordId) && (recordId.length() == 15 || recordId.length() == 18)) {
            conditionalRendererId=recordId;
        }
        List<Conditional_Renderer_Config__mdt> conditionalRendererRecords=[SELECT Action__c,Controlling_Field__c,DeveloperName,Fields__c,Id,Sobject__c,Type__c,Value__c FROM Conditional_Renderer_Config__mdt
                                                                           where ID=:conditionalRendererId AND Sobject__c=:sObjectName AND Controlling_Field__c=:controllingField AND Value__c=:value AND Action__c=:action];
        if(!conditionalRendererRecords.isEmpty()){
            duplicateFound=true;   
        }
        return duplicateFound;
    }
    @AuraEnabled (cacheable=true)
    public static List<String> getAllSObjects()
    {
        List<String> sObjectList = new List<String>();
        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values())
        {
            Schema.DescribeSObjectResult describeSObjectResultObj = objTyp.getDescribe();
            String name = objTyp.getDescribe().getName();
            if(!name.containsignorecase('history') && !name.containsignorecase('tag')&&
               !name.containsignorecase('share') && !name.containsignorecase('feed') && !name.containsignorecase('changeevent'))
            {
                system.debug(name);
                SobjectList.add(name);
            }
        }
        sObjectList.sort();
        return sObjectList;
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getFieldAPINames(String objectAPIName) {
        List<String> fieldAPINames = new List<String>();
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectAPIName);
        if (objectType != null) {
            Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
            for (Schema.SObjectField field : objectDescribe.fields.getMap().values()) {
                String fieldAPIName = field.getDescribe().getName();
                string fieldDataType=field.getDescribe().getType().name();
                if(fieldDataType=='BOOLEAN' || fieldDataType=='PICKLIST' || fieldDataType=='NUMBER' || fieldDataType=='TEXT' || fieldDataType=='STRING'){
                    system.debug('fieldDescribe.getType().name()-'+field.getDescribe().getType().name());
                    fieldAPINames.add(fieldAPIName);
                }
            }
        }
        fieldAPINames.sort();
        
        return fieldAPINames;
    }
    @AuraEnabled(cacheable=false)
    public static List<String> getFieldAPINamesForFields(String objectAPIName,string fieldName) {
        List<String> fieldAPINames = new List<String>();
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectAPIName);
        if (objectType != null) {
            Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
            for (Schema.SObjectField field : objectDescribe.fields.getMap().values()) {
                String fieldAPIName = field.getDescribe().getName();
                string fieldDataType=field.getDescribe().getType().name();
                if(fieldDataType=='BOOLEAN' || fieldDataType=='PICKLIST' || fieldDataType=='NUMBER' || fieldDataType=='TEXT' || fieldDataType=='STRING'){
                    if(fieldName !=fieldAPIName){
                        system.debug(objectAPIName+'---fieldAPIName-'+fieldAPIName);
                        fieldAPINames.add(fieldAPIName);
                    }
                }
            }
        }
        fieldAPINames.sort();       
        return fieldAPINames;
    }
    @AuraEnabled(cacheable=true)
    public static String getFieldType(String objectAPIName, String fieldAPIName) {
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectAPIName);
        if (objectType != null) {
            Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
            Schema.DescribeFieldResult fieldDescribe = objectDescribe.fields.getMap().get(fieldAPIName).getDescribe();
            return fieldDescribe.getType().name();
        }
        
        return null;
    }
    @AuraEnabled(cacheable=true)
    public static void insertConditionalRendererConfig(string conditionalRecords){  
        Map<Id,Conditional_Renderer_Config__mdt> getExistingMap=new Map<Id,Conditional_Renderer_Config__mdt>([SELECT Action__c,Controlling_Field__c,DeveloperName,Fields__c,Id,Label,Sobject__c,Type__c,Value__c FROM Conditional_Renderer_Config__mdt]);
        try{
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        system.debug('conditionalRecords-'+conditionalRecords);
        List<Object> obList = (List<object>) json.deserializeUntyped(conditionalRecords);
        for(object ob : obList) 
        {
            Map<String, object> obmap = (Map<String, object>)ob;
            String conditionalRendererId = (String)obmap.get('RowId');
            String sObjectValue = (String)obmap.get('SObject');
            String controllingFields = (String)obmap.get('ControllingFields');
            String typeValue = (String)obmap.get('Type');
            String value = (String)obmap.get('Value');
            String action = (String)obmap.get('Action');
            String field = (String)obmap.get('Field');    
            system.debug('field-'+field);
          

            Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
            if (string.isNotBlank(conditionalRendererId) && (conditionalRendererId.length() == 15 || conditionalRendererId.length() == 18) && getExistingMap.containsKey(conditionalRendererId)) {
                Conditional_Renderer_Config__mdt cr=getExistingMap.get(conditionalRendererId);
                customMetadata.fullName='Conditional_Renderer_Config.'+cr.DeveloperName;
            }else{
                customMetadata.fullName ='Conditional_Renderer_Config.'+'CRC_'+DateTime.now().getTime(); 
            }
            
            customMetadata.label = 'CRC_'+DateTime.now().getTime();  
            
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = 'Sobject__c';
            customField.value = sObjectValue;
            customMetadata.values.add(customField);
            mdContainer.addMetadata(customMetadata);
            
            Metadata.CustomMetadataValue customField1 = new Metadata.CustomMetadataValue();
            customField1.field = 'Controlling_Field__c';
            customField1.value = controllingFields;
            customMetadata.values.add(customField1);
            mdContainer.addMetadata(customMetadata);
            
            Metadata.CustomMetadataValue customField2 = new Metadata.CustomMetadataValue();
            customField2.field = 'Type__c';
            customField2.value = typeValue;
            customMetadata.values.add(customField2);
            mdContainer.addMetadata(customMetadata);
            
            Metadata.CustomMetadataValue customField3 = new Metadata.CustomMetadataValue();
            customField3.field = 'Value__c';
            customField3.value = value;
            customMetadata.values.add(customField3);
            mdContainer.addMetadata(customMetadata);
            
            Metadata.CustomMetadataValue customField4 = new Metadata.CustomMetadataValue();
            customField4.field = 'Action__c';
            customField4.value = action;
            customMetadata.values.add(customField4);
            mdContainer.addMetadata(customMetadata);
            
            Metadata.CustomMetadataValue customField5 = new Metadata.CustomMetadataValue();
            customField5.field = 'Fields__c';
            customField5.value = field;
            customMetadata.values.add(customField5);
            mdContainer.addMetadata(customMetadata);
            
            
        }
        id jobId=null;     
        metadataInsertUpdate callback = new metadataInsertUpdate();
        jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
        system.debug('jobId-'+jobId);

        }catch (Exception e) {
            system.debug('e-'+e.getLineNumber()+'-cause-'+e.getCause()+'---'+e.getMessage());
            ODS_ExceptionUtility.LogException(e);
        }
    }
    public class MetadataInsertUpdate implements Metadata.DeployCallback {
        public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
            if (result.status == Metadata.DeployStatus.Succeeded) {
                System.debug('success:' + result);
            } else {
                System.debug('fail:'+ result);
                ODS_ExceptionUtility.saveErrorLogs('Custom Metadata',string.valueof(result),'','');
            }
            
        }
    }
    
    
}
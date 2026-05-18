public class CustomMetaDataUpdation {
    //Update the custom metadata records from batch class
    public static String upsertMetadata(List<sObject> customMetadataList ) {
        
        //Create Deployment container for custom Metadata
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        for(sobject sObMD : customMetadataList) {
            
            //Get metadata object name and details
            String sObjectname = sObMD.getSObjectType().getDescribe().getName();
            
            //Create custom Metadata instance
            Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
            String recordName = String.valueOf(sObMD.get('DeveloperName')).replaceAll(' ','_');
            customMetadata.fullName = sObjectname +'.'+recordName;
            customMetadata.label = (String)sObMD.get('MasterLabel');
            
            //Get all fields
            schema.SObjectType sobjType = Schema.getGlobalDescribe().get(sObjectname );
            
            Map<String, Schema.sObjectField> sObjectFields = sobjType.getDescribe().fields.getMap();
            Set<String> skipFieldSet = new Set<String>{'developername','masterlabel','language','namespaceprefix', 'label','qualifiedapiname', 'id'};
                
                // Use getPopulatedFieldsAsMap to get the populate field and iterate over them
                for(String fieldName : sObMD.getPopulatedFieldsAsMap().keySet()) {
                    if(skipFieldSet.contains(fieldName.toLowerCase())|| sObMD.get(fieldName) == null)
                        continue;
                    
                    Object value = sObMD.get(fieldName);    
                    //create field instance and populate it with field API name and value
                    Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
                    customField.field = fieldName;
                    
                    Schema.DisplayType valueType = sObjectFields.get(fieldName).getDescribe().getType();
                    if (value instanceof String && valueType != Schema.DisplayType.String)
                    {
                        String svalue = (String)value;
                        
                            customField.value = svalue;
                    }
                    else
                        customField.value = value;
                    //Add fields in the object, similar to creating sObject instance
                    customMetadata.values.add(customField);
                }
            //Add metadata in container
            mdContainer.addMetadata(customMetadata);
        }
        
        // Callback class instance
        CustomMetadataCallback callback = new CustomMetadataCallback();
        
        // Enqueue custom metadata deployment
        // jobId is the deployment ID
        Id jobId=null;
        if(!Test.isRunningTest())
        jobId =Metadata.Operations.enqueueDeployment(mdContainer, callback);
        return jobId;
    }
    
    //use it to pass single metadata instance
    public static String upsertMetadata(sObject customMetadata ) {
        return upsertMetadata(new List<sObject>{customMetadata} );
    }
    
    public class CustomMetadataCallback implements Metadata.DeployCallback {
        public void handleResult(Metadata.DeployResult result,
                                 Metadata.DeployCallbackContext context) {
                                     
                                     if (result.status == Metadata.DeployStatus.Succeeded) {
                                         System.debug('success: '+ result);
                                     }                                      
                                 }
    }
}
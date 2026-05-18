@isTest  
private class MetadataServiceTest
{    
    private class WebServiceMockImpl implements WebServiceMock 
	{
		public void doInvoke(
			Object stub, Object request, Map<String, Object> response,
			String endpoint, String soapAction, String requestName,
			String responseNS, String responseName, String responseType) 
		{
			if(request instanceof MetadataService.create_element)
				response.put('response_x', new MetadataService.createResponse_element());
			else if(request instanceof MetadataService.checkStatus_element)
				response.put('response_x', new MetadataService.checkStatusResponse_element());
			
			return;
		}
	}    
    @IsTest
    private static void coverGeneratedCodeCRUDOperations()
    {	
        
        MetadataService metaDataService = new MetadataService();
        // Invoke operations     
        Test.startTest();    
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        Test.stopTest();
    }
    
    	@IsTest
    private static void coverGeneratedCodeFileBasedOperations1()
    {    	
    	// Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations    
        Test.startTest();     
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        metaDataPort.create(null);
        metaDataPort.checkStatus(null);
        Test.stopTest();
    }
    
    @IsTest
    private static void coverGeneratedCodeTypes()
    {    	       
        // Reference types
        Test.startTest();
        new MetadataService();
        new MetadataService.createResponse_element();
        new MetadataService.Metadata(); 
        new MetadataService.MetadataPort();
        new MetadataService.AsyncResult();
        new MetadataService.checkStatus_element();
        new MetadataService.checkStatusResponse_element();
        new MetadataService.PackageTypeMembers();
        new MetadataService.DebuggingHeader_element();
        new MetadataService.LogInfo();
        new MetadataService.SessionHeader_element();
        new MetadataService.retrieveResponse_element();
        new MetadataService.DebuggingInfo_element();
        new MetadataService.CallOptions_element();
        new MetadataService.checkDeployStatus_element();
        new MetadataService.create_element();
        new MetadataService.RemoteSiteSetting();
       new MetadataService.metadata();
        //new MetadataService.asyncProcessId();
        
        Test.stopTest();
    }
    
}
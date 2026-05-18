@isTest
public class ItemMasterLookupControllerTest {
    
    @testSetup
    static void setupTestData() {
        List<Item_Master__c> testItems = new List<Item_Master__c>();
        
        Item_Master__c item1 = new Item_Master__c(
            Description__c = 'Test Description 1',
            Unit_of_Measure__c = 'LICENSE',
            Tax_Rate__c = 10.50,
            Business_Unit__c='DemandDynamics',
            IsActive__c = true
        );
        testItems.add(item1);
        
        Item_Master__c item2 = new Item_Master__c(
            Description__c = 'Test Description 2',
            Unit_of_Measure__c = 'LICENSE',
            Tax_Rate__c = 15.75,
            Business_Unit__c='DemandDynamics',
            IsActive__c = true
        );
        testItems.add(item2);
        
        Item_Master__c item3 = new Item_Master__c(
            Description__c = 'Another Test Description',
            Unit_of_Measure__c = 'LICENSE',
            Tax_Rate__c = 8.25,
            Business_Unit__c='DemandDynamics',
            IsActive__c = true
        );
        testItems.add(item3);
        
        Item_Master__c item4 = new Item_Master__c(
            Description__c = 'Different Description',
            Unit_of_Measure__c = 'LICENSE',
            Tax_Rate__c = 12.00,
            Business_Unit__c='DemandDynamics',
            IsActive__c = true
        );
        testItems.add(item4);
        
        Item_Master__c inactiveItem = new Item_Master__c(
            Description__c = 'Test Description Inactive',
            Unit_of_Measure__c = 'LICENSE',
            Tax_Rate__c = 20.00,
            Business_Unit__c='DemandDynamics',
            IsActive__c = false
        );
        testItems.add(inactiveItem);
        
        insert testItems;
    }
    
    @isTest
    static void testFetchLookupDataWithSearchKey() {
        Test.startTest();
        List<sObject> result = ItemMasterLookupController.fetchLookupData(
            system.now(),
            'Test Description', 
            'Item_Master__c', 
            '', 
            'LICENSE'
        );
        List<sObject> result1 = ItemMasterLookupController.fetchEmployeeLookupData(
            system.now(),
            'Resource', 
            'Contact'
        );
        Test.stopTest();
    }
    
}
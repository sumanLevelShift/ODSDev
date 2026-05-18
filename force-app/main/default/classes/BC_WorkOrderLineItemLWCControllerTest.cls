@isTest
public class BC_WorkOrderLineItemLWCControllerTest {
    
    @TestSetup
    static void makeData() {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu', 'testuser@testmail.com', 'UTF-8', 'Indumathi', 'en_US', 'en_US', profile1.Id, 'America/Chicago', System.now().millisecond() + 'test123@testmail.com', 'Technical Account Manager', true, portalRole.Id);
        System.runAs(portalAccountOwner1) {
            
            UserRole testRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Vice_President_Sales'];
            User testUser = new User(
                Username = 'testuser@example.comVPS',
                FirstName = 'Test',
                LastName = 'User',
                Email = 'testuser@example.com',
                Alias = 'testusr',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = UserInfo.getProfileId(),
                LanguageLocaleKey = 'en_US',
                UserRoleId = testRole.Id
            );
            insert testUser;
            
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            
            Account accountObject = new Account(
                Name ='Demand Blue CLient1',
                Lead_Gen_Name__c = 'Others',             
                Industry = 'Hospitality',
                Project_Code__c ='GHT',
                Customer_Type__c= 'ABC Type',
                Account_Type__c='OTHERS'
            );
            insert accountObject;
            
            Date projStart = date.parse('11/01/2016');
            Date projEnd = date.parse('12/31/2016');
            ODS_Services__c service = ODS_DataFactory_Test_Utility.insertODSServices('DotNet', 'test', true);
            Project_Team_Member__c teamMember = ODS_DataFactory_Test_Utility.insertTeamMember('Arun', accountObject.Id, service.Id);
            User_Account__c usrAcc1 = ODS_DataFactory_Test_Utility.insertUsrAccnt(accountObject.id, 'Technical Account Manager', portalAccountOwner1.Id, service.Id);
            Account_Services__c accService = ODS_DataFactory_Test_Utility.insertAccountServices(
                accountObject.id, projStart, projEnd, 150.0, service.id, 1000, 'Monthly', 
                UserInfo.getUserId(), 'DotNet');
            Contact contactObject = new Contact(
                FirstName ='Test',
                LastName='c',
                isPrimary__c=true,
                Email='test@preludesys.com',
                AccountId=accountObject.Id,
                Lead_Gen_Name__c = 'Others'
            );
            insert contactObject;
            
            // Create work orders with different subcategories for testing
            List<Work_Order__c> workOrders = new List<Work_Order__c>();
            
            // License subcategory
            workOrders.add(new Work_Order__c(
                Client_Name__c=accountObject.Id,
                Project_Start_Date__c=system.today().addDays(5),
                Project_End_Date__c=system.today().addDays(15),
                Account_Manager_Name__c=testUser.Id,
                SubCategory__c='DemandDynamics -License Fee',
                Pay_Rate__c=85,
                Billing_Frequency__c='Milestone',
                Bill_Rate__c =12000,
                Annual_Salary__c=25000,
                PERDIEM__c=920,
                Business_Unit__c='DemandDynamics',
                Project_Name__c='TestProject License',
                LCA_Required__c=false,
                Minumim_Billable_Hours_Per_Month__c=8,
                Bill_Rate_Type__c='One Time',
                Initial_Gross_Margin__c=77.8,
                Payment_Terms_Projects__c='Net 30',
                PO_Number__c='4578',
                Subscription_Fee_Frequency__c='Monthly',
                BC_Work_Order_ID__c='1234'
            ));
            
            // KPO subcategory
            workOrders.add(new Work_Order__c(
                Client_Name__c=accountObject.Id,
                Project_Start_Date__c=system.today().addDays(5),
                Project_End_Date__c=system.today().addDays(15),
                Account_Manager_Name__c=testUser.Id,
                SubCategory__c='KPO -Consumption',
                Pay_Rate__c=85,
                Billing_Frequency__c='Milestone',
                Bill_Rate__c =12000,
                Annual_Salary__c=25000,
                Business_Unit__c='KPO',
                Project_Name__c='KPO -Consumption',
                BC_Work_Order_ID__c='5678'
            ));
            
            // Fixed Unit Price subcategory
            workOrders.add(new Work_Order__c(
                Client_Name__c=accountObject.Id,
                Project_Start_Date__c=system.today().addDays(5),
                Project_End_Date__c=system.today().addDays(15),
                Account_Manager_Name__c=testUser.Id,
                SubCategory__c='DX -Fixed Unit Price',
                Pay_Rate__c=85,
                Billing_Frequency__c='Milestone',
                Bill_Rate__c =12000,
                Annual_Salary__c=25000,
                Business_Unit__c='DX',
                Project_Name__c='TestProject FPU',
                BC_Work_Order_ID__c='9012'
            ));
            
            insert workOrders;
            
            // Create item masters
            List<Item_Master__c> itemMasters = new List<Item_Master__c>();
            for (Integer i = 1; i <= 10; i++) {
                itemMasters.add(new Item_Master__c(
                    Description__c = 'Test Description ' + i,
                    Unit_of_Measure__c = 'LICENSE',
                    Business_Unit__c='DemandDynamics'
                ));
            }
            insert itemMasters;
        }
    }
    
    @isTest
    static void testGetRecordTypes_WithLicenseSubcategory() {
        Work_Order__c testWorkOrder = [SELECT Id FROM Work_Order__c WHERE SubCategory__c LIKE '%License%' LIMIT 1];
        
        Test.startTest();
        List<BC_WorkOrderLineItemLWCController.RecordTypeOption> recordTypes = 
            BC_WorkOrderLineItemLWCController.getRecordTypes(testWorkOrder.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetRecordTypes_WithKPOSubcategory() {
        Work_Order__c testWorkOrder = [SELECT Id FROM Work_Order__c WHERE SubCategory__c = 'KPO -Consumption' LIMIT 1];
        
        Test.startTest();
        List<BC_WorkOrderLineItemLWCController.RecordTypeOption> recordTypes = 
            BC_WorkOrderLineItemLWCController.getRecordTypes(testWorkOrder.Id);
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetRecordTypes_WithFPUSubcategory() {
        Work_Order__c testWorkOrder = [SELECT Id FROM Work_Order__c WHERE SubCategory__c LIKE '%Fixed Unit Price%' LIMIT 1];
        
        Test.startTest();
        List<BC_WorkOrderLineItemLWCController.RecordTypeOption> recordTypes = 
            BC_WorkOrderLineItemLWCController.getRecordTypes(testWorkOrder.Id);
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetWorkOrder() {
        Work_Order__c testWorkOrder = [SELECT Id FROM Work_Order__c LIMIT 1];
        
        Test.startTest();
        Work_Order__c result = BC_WorkOrderLineItemLWCController.getWorkOrder(testWorkOrder.Id, System.now());
        Test.stopTest();
    }
    
    @isTest
    static void testGetRecordTypeName_WithExistingLineItems() {
        Work_Order__c testWorkOrder = [SELECT Id FROM Work_Order__c LIMIT 1];
        Item_Master__c itemMaster = [SELECT Id FROM Item_Master__c LIMIT 1];
        RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'WorkOrder_Line_Item__c' AND DeveloperName = 'License' LIMIT 1];
        
        WorkOrder_Line_Item__c lineItem = new WorkOrder_Line_Item__c(
            WorkOrder__c = testWorkOrder.Id,
            Item_Master__c = itemMaster.Id,
            Rate__c = 100,
            Quantity__c = 1,
            Unit_of_Measure__c = 'LICENSE',
            RecordTypeId = rt.Id
        );
        insert lineItem;
        
        Test.startTest();
        String recordTypeName = BC_WorkOrderLineItemLWCController.getRecordTypeName(testWorkOrder.Id, System.now());
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetRecordTypeName_WithNoLineItems() {
        Work_Order__c testWorkOrder = [SELECT Id FROM Work_Order__c LIMIT 1];
        
        Test.startTest();
        String recordTypeName = BC_WorkOrderLineItemLWCController.getRecordTypeName(testWorkOrder.Id, System.now());
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetUnitOfMeasure() {
        Test.startTest();
        String licenseUOM = BC_WorkOrderLineItemLWCController.getUnitOfMeasure('License', System.now());
        String slabRateUOM = BC_WorkOrderLineItemLWCController.getUnitOfMeasure('Slab_Rate', System.now());
        String pointsUOM = BC_WorkOrderLineItemLWCController.getUnitOfMeasure('Points', System.now());
        String kpoUOM = BC_WorkOrderLineItemLWCController.getUnitOfMeasure('KPO', System.now());
        String fpuUOM = BC_WorkOrderLineItemLWCController.getUnitOfMeasure('Fixed_Unit_Price', System.now());
        Test.stopTest();
        
    }
    
    
    @isTest
    static void testCreateWorkOrderLineItems_Success() {
        Work_Order__c testWorkOrder = [SELECT Id FROM Work_Order__c WHERE SubCategory__c LIKE '%License%' LIMIT 1];
        List<Item_Master__c> itemMasters = [SELECT Id FROM Item_Master__c LIMIT 3];
        
        List<BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper> wrappers = 
            new List<BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper>();
        
        for (Integer i = 0; i < itemMasters.size(); i++) {
            BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper wrapper = 
                new BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper();
            wrapper.itemMasterId = itemMasters[i].Id;
            wrapper.rate = 100.00 + i;
            wrapper.quantity = 2 + i;
            wrapper.taxRate = 8.5;
            wrapper.description = 'Test Line Item ' + (i + 1);
            wrapper.unitOfMeasure = 'LICENSE';
            wrapper.effectiveDate = System.today();
            wrappers.add(wrapper);
        }
        
        Test.startTest();
        List<WorkOrder_Line_Item__c> result = BC_WorkOrderLineItemLWCController.createWorkOrderLineItems(
            wrappers, testWorkOrder.Id, 'License'
        );
        Test.stopTest();
    }
    
    @isTest
    static void testCreatePointsWorkOrderLineItems_Success() {
        Work_Order__c testWorkOrder = [SELECT Id FROM Work_Order__c WHERE SubCategory__c LIKE '%License%' LIMIT 1];
        List<Item_Master__c> itemMasters = [SELECT Id FROM Item_Master__c LIMIT 2];
        
        List<BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper> wrappers = 
            new List<BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper>();
        
        for (Integer i = 0; i < itemMasters.size(); i++) {
            BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper wrapper = 
                new BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper();
            wrapper.itemMasterId = itemMasters[i].Id;
            wrapper.rate = 150.00;
            wrapper.quantity = 5;
            wrapper.description = 'Points Line Item ' + (i + 1);
            wrapper.unitOfMeasure = 'POINTS';
            wrappers.add(wrapper);
        }
        
        Test.startTest();
        List<WorkOrder_Line_Item__c> result = BC_WorkOrderLineItemLWCController.createPointsWorkOrderLineItems(
            wrappers, testWorkOrder.Id, 'Points'
        );
        Test.stopTest();
        
    }
    
    @isTest
    static void testCreateKPOWorkOrderLineItems_Success() {
        Work_Order__c testWorkOrder = [SELECT Id FROM Work_Order__c WHERE SubCategory__c = 'KPO -Consumption' LIMIT 1];
        List<Item_Master__c> itemMasters = [SELECT Id FROM Item_Master__c LIMIT 2];
        
        List<BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper> wrappers = 
            new List<BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper>();
        
        for (Integer i = 0; i < itemMasters.size(); i++) {
            BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper wrapper = 
                new BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper();
            wrapper.itemMasterId = itemMasters[i].Id;
            wrapper.rate = 200.00;
            wrapper.quantity = 10;
            wrapper.description = 'KPO Line Item ' + (i + 1);
            wrapper.description2 = 'Additional Description';
            wrapper.unitOfMeasure = 'CASES';
            wrappers.add(wrapper);
        }
        
        Test.startTest();
        List<WorkOrder_Line_Item__c> result = BC_WorkOrderLineItemLWCController.createKPOWorkOrderLineItems(
            wrappers, testWorkOrder.Id, 'KPO'
        );
        Test.stopTest();
        
    }
    
    @isTest
    static void testCreateFPUWorkOrderLineItems_Success() {
        Work_Order__c testWorkOrder = [SELECT Id FROM Work_Order__c WHERE SubCategory__c LIKE '%Fixed Unit Price%' LIMIT 1];
        List<Item_Master__c> itemMasters = [SELECT Id FROM Item_Master__c LIMIT 2];
        
        List<BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper> wrappers = 
            new List<BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper>();
        
        for (Integer i = 0; i < itemMasters.size(); i++) {
            BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper wrapper = 
                new BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper();
            wrapper.itemMasterId = itemMasters[i].Id;
            wrapper.rate = 500.00;
            wrapper.quantity = 3;
            wrapper.description = 'FPU Line Item ' + (i + 1);
            wrapper.unitOfMeasure = 'HOURS';
            wrappers.add(wrapper);
        }
        
        Test.startTest();
        List<WorkOrder_Line_Item__c> result = BC_WorkOrderLineItemLWCController.createFPUWorkOrderLineItems(
            wrappers, testWorkOrder.Id, 'Fixed_Unit_Price'
        );
        Test.stopTest();
        
    }
    
    @isTest
    static void testValidation_EmptyLineItems() {
        Work_Order__c testWorkOrder = [SELECT Id FROM Work_Order__c LIMIT 1];
        List<BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper> emptyWrappers = 
            new List<BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper>();
        
        Test.startTest();
        try {
            BC_WorkOrderLineItemLWCController.createWorkOrderLineItems(
                emptyWrappers, testWorkOrder.Id, 'License'
            );
        } catch (AuraHandledException e) {
        }
        Test.stopTest();
    }
    
    @isTest
    static void testValidation_MissingItemMaster() {
        Work_Order__c testWorkOrder = [SELECT Id FROM Work_Order__c LIMIT 1];
        
        BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper wrapper = 
            new BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper();
        wrapper.itemMasterId = null;
        wrapper.rate = 100;
        wrapper.quantity = 1;
        wrapper.unitOfMeasure = 'LICENSE';
        
        Test.startTest();
        try {
            BC_WorkOrderLineItemLWCController.createWorkOrderLineItems(
                new List<BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper>{wrapper}, 
                testWorkOrder.Id, 
                'License'
            );
        } catch (AuraHandledException e) {
        }
        Test.stopTest();
    }
    
    @isTest
    static void testValidation_InvalidRate() {
        Work_Order__c testWorkOrder = [SELECT Id FROM Work_Order__c LIMIT 1];
        Item_Master__c itemMaster = [SELECT Id FROM Item_Master__c LIMIT 1];
        
        BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper wrapper = 
            new BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper();
        wrapper.itemMasterId = itemMaster.Id;
        wrapper.rate = 0;
        wrapper.quantity = 1;
        wrapper.unitOfMeasure = 'LICENSE';
        
        Test.startTest();
        try {
            BC_WorkOrderLineItemLWCController.createWorkOrderLineItems(
                new List<BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper>{wrapper}, 
                testWorkOrder.Id, 
                'License'
            );
        } catch (AuraHandledException e) {
        }
        Test.stopTest();
    }
    
    @isTest
    static void testValidation_InvalidQuantity() {
        Work_Order__c testWorkOrder = [SELECT Id FROM Work_Order__c LIMIT 1];
        Item_Master__c itemMaster = [SELECT Id FROM Item_Master__c LIMIT 1];
        
        BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper wrapper = 
            new BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper();
        wrapper.itemMasterId = itemMaster.Id;
        wrapper.rate = 100;
        wrapper.quantity = -1;
        wrapper.unitOfMeasure = 'LICENSE';
        
        Test.startTest();
        try {
            BC_WorkOrderLineItemLWCController.createWorkOrderLineItems(
                new List<BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper>{wrapper}, 
                testWorkOrder.Id, 
                'License'
            );
        } catch (AuraHandledException e) {
        }
        Test.stopTest();
    }
    
    @isTest
    static void testValidation_MissingKPOUOM() {
        Work_Order__c testWorkOrder = [SELECT Id FROM Work_Order__c WHERE SubCategory__c = 'KPO -Consumption' LIMIT 1];
        Item_Master__c itemMaster = [SELECT Id FROM Item_Master__c LIMIT 1];
        
        BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper wrapper = 
            new BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper();
        wrapper.itemMasterId = itemMaster.Id;
        wrapper.rate = 100;
        wrapper.quantity = 1;
        wrapper.unitOfMeasure = 'CASES';
        
        Test.startTest();
        try {
            BC_WorkOrderLineItemLWCController.createKPOWorkOrderLineItems(
                new List<BC_WorkOrderLineItemLWCController.WorkOrderLineItemWrapper>{wrapper}, 
                testWorkOrder.Id, 
                'KPO'
            );
        } catch (AuraHandledException e) {
        }
        Test.stopTest();
    }
    @isTest
    static void testGetExistingFPULineItems_WithMonthsAndHours() {
        Work_Order__c testWorkOrder = [SELECT Id FROM Work_Order__c LIMIT 1];
        Item_Master__c itemMaster = [SELECT Id FROM Item_Master__c LIMIT 1];
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'WorkOrder_Line_Item__c' AND DeveloperName = 'Fixed_Unit_Price' LIMIT 1];
        
        List<WorkOrder_Line_Item__c> lineItems = new List<WorkOrder_Line_Item__c>();
        lineItems.add(new WorkOrder_Line_Item__c(
            WorkOrder__c = testWorkOrder.Id,
            Item_Master__c = itemMaster.Id,
            Rate__c = 100,
            Quantity__c = 1,
            Unit_of_Measure__c = 'MONTH',
            RecordTypeId = rt.Id
        ));
        lineItems.add(new WorkOrder_Line_Item__c(
            WorkOrder__c = testWorkOrder.Id,
            Item_Master__c = itemMaster.Id,
            Rate__c = 50,
            Quantity__c = 40,
            Unit_of_Measure__c = 'HOURS',
            RecordTypeId = rt.Id
        ));
        insert lineItems;
        
        Test.startTest();
        BC_WorkOrderLineItemLWCController.getExistingFPULineItems(testWorkOrder.Id, 'Fixed_Unit_Price', System.now());
        Test.stopTest();
    }
    
    @isTest
    static void testGetExistingFPULineItems_NoExistingItems() {
        Work_Order__c testWorkOrder = [SELECT Id FROM Work_Order__c LIMIT 1];
        
        Test.startTest();
        BC_WorkOrderLineItemLWCController.getExistingFPULineItems(testWorkOrder.Id, 'Fixed_Unit_Price', System.now());
        Test.stopTest();
    }
}
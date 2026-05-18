public with sharing class BC_WorkOrderLineItemLWCController {
    
    public class RecordTypeOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String recordTypeId;
        
        public RecordTypeOption(String label, String value, String recordTypeId) {
            this.label = label;
            this.value = value;
            this.recordTypeId = recordTypeId;
        }
    }
    
    public class WorkOrderLineItemWrapper {
        @AuraEnabled public String itemMasterId { get; set; }
        @AuraEnabled public Decimal rate { get; set; }
        @AuraEnabled public Decimal quantity { get; set; }
        @AuraEnabled public Decimal taxRate { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public String description2 { get; set; }
        @AuraEnabled public String unitOfMeasure { get; set; }
        @AuraEnabled public Date effectiveDate { get; set; }
        @AuraEnabled public String resourceId { get; set; }

    }
    public class FPULineItemsResult {
        @AuraEnabled public Boolean hasMonths { get; set; }
        @AuraEnabled public Boolean hasHours { get; set; }
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, Boolean> getExistingFPULineItems(String workOrderId,string selectedRecordType, DateTime currentDatetime) {
        Map<String, Boolean> result = new Map<String, Boolean>();
        result.put('hasMonths', false);
        result.put('hasHours', false);
        
        try {
            List<WorkOrder_Line_Item__c> existingItems = [
                SELECT Id, Unit_of_Measure__c 
                FROM WorkOrder_Line_Item__c 
                WHERE WorkOrder__c = :workOrderId 
                AND RecordType.DeveloperName = :selectedRecordType
                AND Unit_of_Measure__c IN ('MONTH', 'HOURS') 
                AND WorkOrder__r.SubCategory__c IN ('DX -Fixed Unit Price', 'DX -Fixed Unit Price-CO')
            ];
            
            for (WorkOrder_Line_Item__c item : existingItems) {
                if (item.Unit_of_Measure__c == 'MONTH') {
                    result.put('hasMonths', true);
                } else if (item.Unit_of_Measure__c == 'HOURS') {
                    result.put('hasHours', true);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error checking existing records: ' + e.getMessage());
        }
        
        return result;
    }
    // Query Methods
    @AuraEnabled(cacheable=true)
    public static List<RecordTypeOption> getRecordTypes(String workOrderId) {
        List<RecordTypeOption> options = new List<RecordTypeOption>();
        
        try {
            String subCategory = getSubCategory(workOrderId);
            List<RecordType> recordTypes = getActiveRecordTypes();
            
            for (RecordType rt : recordTypes) {
                if (shouldIncludeRecordType(rt.Name, subCategory)) {
                    options.add(new RecordTypeOption(rt.Name, rt.DeveloperName, rt.Id));
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching record types: ' + e.getMessage());
        }
        
        return options;
    }
    
    @AuraEnabled(cacheable=true)
    public static Work_Order__c getWorkOrder(String recordId, DateTime currentDatetime) {
        return [SELECT Id,SubCategory__c, Project_Start_Date__c, Project_End_Date__c, BC_Work_Order_ID__c FROM Work_Order__c WHERE Id = :recordId];
    }
    
    @AuraEnabled(cacheable=true)
    public static String getRecordTypeName(String workOrderId, DateTime currentDatetime) {
        List<WorkOrder_Line_Item__c> woli = [SELECT RecordType.DeveloperName  FROM WorkOrder_Line_Item__c WHERE WorkOrder__c = :workOrderId  ];
        return !woli.isEmpty() ? woli[0].RecordType.DeveloperName : '';
    }
    
    @AuraEnabled(cacheable=true)
    public static String getUnitOfMeasure(String selectedRecordType, DateTime currentDatetime) {
        Map<String, String> uomMap = new Map<String, String>{
            'License' => 'LICENSE',
                'Slab_Rate' => 'SLAB RATE',
                'Points' => 'POINTS',
                'KPO' => 'KPO',
                'Fixed_Unit_Price'=>'FIXED UNIT PRICE',
                'Staffing'=>'STAFFING'
                };
                    
                    return uomMap.containsKey(selectedRecordType) ? uomMap.get(selectedRecordType) : '';
    }
    
    @AuraEnabled
    public static List<WorkOrder_Line_Item__c> createWorkOrderLineItems(List<WorkOrderLineItemWrapper> lineItems,  String workOrderId, String selectedRecordType) {
        return createLineItems(lineItems, workOrderId, selectedRecordType, 'License');
    }
    
    @AuraEnabled
    public static List<WorkOrder_Line_Item__c> createPointsWorkOrderLineItems(List<WorkOrderLineItemWrapper> lineItems, String workOrderId, String selectedRecordType ) {
        return createLineItems(lineItems, workOrderId, selectedRecordType, 'Points');
    }
    
    @AuraEnabled
    public static List<WorkOrder_Line_Item__c> createKPOWorkOrderLineItems( List<WorkOrderLineItemWrapper> lineItems,  String workOrderId,String selectedRecordType) {
        return createLineItems(lineItems, workOrderId, selectedRecordType, 'KPO');
    }
    @AuraEnabled
    public static List<WorkOrder_Line_Item__c> createFPUWorkOrderLineItems( List<WorkOrderLineItemWrapper> lineItems,  String workOrderId,String selectedRecordType) {
        system.debug('-lineItems'+lineItems);
        return createLineItems(lineItems, workOrderId, selectedRecordType, 'Fixed Unit Price');
    }
    @AuraEnabled
    public static List<WorkOrder_Line_Item__c> createStaffingWorkOrderLineItems( List<WorkOrderLineItemWrapper> lineItems,  String workOrderId,String selectedRecordType) {
        return createLineItems(lineItems, workOrderId, selectedRecordType, 'Staffing');
    }
    private static String getSubCategory(String workOrderId) {
        List<Work_Order__c> wo = [ SELECT Business_Unit__c,SubCategory__c  FROM Work_Order__c  WHERE Id = :workOrderId  LIMIT 1];
        
        if (!wo.isEmpty() && wo[0].SubCategory__c != null) {
            if(wo[0].Business_Unit__c=='Staffing'){
                return wo[0].Business_Unit__c.toLowerCase(); 
            }
            return wo[0].SubCategory__c.toLowerCase();
        }
        return '';
    }
    
    private static List<RecordType> getActiveRecordTypes() {
        return [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'WorkOrder_Line_Item__c'AND IsActive = true AND Name != 'Master' ORDER BY Name];
    }
    
    private static Boolean shouldIncludeRecordType(String rtName, String subCategory) {
        if (String.isBlank(subCategory)) {
            return true;
        }
        
        if (subCategory.contains('license') && rtName == 'License') {
            return true;
        }
        
        if (subCategory.contains('kpo') && rtName == 'KPO') {
            return true;
        }
        if (subCategory.contains('fixed unit price') && rtName == 'Fixed Unit Price') {
            return true;
        }
        if (subCategory.contains('fixed points') && rtName == 'Points') {
            return true;
        }
        if (subCategory.contains('staffing') && rtName == 'Staffing') {
            return true;
        }
        return false;
    }
    
    private static List<WorkOrder_Line_Item__c> createLineItems(List<WorkOrderLineItemWrapper> lineItems, String workOrderId, String selectedRecordType,String itemType ) {
        validateInput(lineItems, workOrderId);
        
        RecordTypeInfo rtInfo = Schema.SObjectType.WorkOrder_Line_Item__c.getRecordTypeInfosByDeveloperName().get(selectedRecordType);
        
        List<WorkOrder_Line_Item__c> itemsToInsert = new List<WorkOrder_Line_Item__c>();
        
        for (WorkOrderLineItemWrapper item : lineItems) {
            validateLineItem(item, itemType);
            itemsToInsert.add(buildLineItem(item, workOrderId, rtInfo, itemType));
        }
        
        try {
            insert itemsToInsert;
            return itemsToInsert;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating line items: ' + e.getMessage());
        }
    }
    
    private static void validateInput(List<WorkOrderLineItemWrapper> lineItems, String workOrderId) {
        if (lineItems == null || lineItems.isEmpty()) {
            throw new AuraHandledException('No line items provided');
        }
        if (String.isBlank(workOrderId)) {
            throw new AuraHandledException('Work Order ID is required');
        }
    }
    
    private static void validateLineItem(WorkOrderLineItemWrapper item, String itemType) {
        if (String.isBlank(item.itemMasterId) ) {
            throw new AuraHandledException('Item Master is required for all line items');
        }
        if (item.rate == null || item.rate <= 0 ) {
            throw new AuraHandledException('Rate must be greater than 0 for all line items');
        }
        if(itemType!='Staffing'){
            if (item.quantity == null || item.quantity <= 0) {
                throw new AuraHandledException('Quantity must be greater than 0 for all line items');
            }
        }
        if (String.isBlank(item.unitOfMeasure)) {
            throw new AuraHandledException('Unit Of Measure is required.');
        }
        if (String.isBlank(item.resourceId) && itemType=='Staffing') {
            throw new AuraHandledException('Resource is required for all line items');
        }
    }
    
    private static WorkOrder_Line_Item__c buildLineItem(WorkOrderLineItemWrapper item, String workOrderId, RecordTypeInfo rtInfo,String itemType) {
        WorkOrder_Line_Item__c newItem = new WorkOrder_Line_Item__c(
            WorkOrder__c = workOrderId,
            Item_Master__c = item.itemMasterId,
            Rate__c = item.rate,
            Quantity__c = item.quantity,
            Description__c = item.description,
            Unit_of_Measure__c = item.unitOfMeasure,
            RecordTypeId = rtInfo.getRecordTypeId()
        );
        
        if (itemType == 'License') {
            newItem.Tax_Rate__c = item.taxRate;
            newItem.Effective_Date__c = item.effectiveDate;
        } else if (itemType == 'KPO') {
            newItem.Description_2__c = item.description2;
        }
        if (itemType=='Staffing') {
            newItem.Resource__c = item.resourceId;
        }
        return newItem;
    }
}
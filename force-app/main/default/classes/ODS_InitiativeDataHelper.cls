/**
 * @description Data helper class for Initiative operations
 * Handles data transformation and wrapper classes
 */
public with sharing class ODS_InitiativeDataHelper {
    
    /**
     * @description Wrapper class for save initiative request
     */
    public class SaveInitiativeRequest {
        public String initiativeData { get; set; }
        public String estimatesData { get; set; }
        public String action { get; set; }
        public String accServiceId { get; set; }
        
        public SaveInitiativeRequest() {
            // Default constructor
        }
    }
    
    /**
     * @description Wrapper class for initiative data
     */
    public class InitiativeWrapper {
        public String id { get; set; }
        public String name { get; set; }
        public String jiraId { get; set; }
        public String briefDescription { get; set; }
        public String assumption { get; set; }
        public String probableStartDate { get; set; }
        public String probableEndDate { get; set; }
        public String uatExpectedDate { get; set; }
        public String initiativeType { get; set; }
        public String programmingReason { get; set; }
        public String businessChallenge { get; set; }
        public String personasInvolved { get; set; }
        public String technologyDetails { get; set; }
        public String outcomeOfSolution { get; set; }
        public String productNames { get; set; }
        public String triggerForInitiative { get; set; }
        public String solutionArchitect { get; set; }
        public String technicalPM { get; set; }
        public String tagsAboutInitiative { get; set; }
        public String initiativeBillingType { get; set; }
        public Boolean isBucketOfHours { get; set; }
        public Decimal offshoreEstimate { get; set; }
        public Decimal probabilityPercentage { get; set; }
        public String clientContact { get; set; }
        
        public InitiativeWrapper() {
            isBucketOfHours = false;
        }
    }
    
    /**
     * @description Wrapper class for estimate data
     */
    public class EstimateWrapper {
        public String phase { get; set; }
        public String taskName { get; set; }
        public String assumption { get; set; }
        public Decimal hours { get; set; }
        
        public EstimateWrapper() {
            // Default constructor
        }
    }
    
    /**
     * @description Parse initiative data from JSON
     * @param jsonData JSON string containing initiative data
     * @return Parsed InitiativeWrapper
     */
    public static InitiativeWrapper parseInitiativeData(String jsonData) {
        Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        InitiativeWrapper wrapper = new InitiativeWrapper();
        
        wrapper.id = (String)dataMap.get('Id');
        wrapper.name = (String)dataMap.get('Name');
        wrapper.jiraId = (String)dataMap.get('JIRA_ID__c');
        wrapper.briefDescription = (String)dataMap.get('Brief_Description__c');
        wrapper.assumption = (String)dataMap.get('Assumption__c');
        wrapper.probableStartDate = (String)dataMap.get('Probable_Start_Date__c');
        wrapper.probableEndDate = (String)dataMap.get('Probable_End_Date__c');
        wrapper.uatExpectedDate = (String)dataMap.get('UAT_Expected_Date__c');
        wrapper.initiativeType = (String)dataMap.get('Initiative_Type__c');
        wrapper.programmingReason = (String)dataMap.get('Initiative_Programming_Reason__c');
        wrapper.businessChallenge = (String)dataMap.get('Business_Challenge__c');
        wrapper.personasInvolved = (String)dataMap.get('Persona_s_Involved__c');
        wrapper.technologyDetails = (String)dataMap.get('Technology_Details__c');
        wrapper.outcomeOfSolution = (String)dataMap.get('Outcome_of_our_solution__c');
        wrapper.productNames = (String)dataMap.get('Product__c');
        wrapper.triggerForInitiative = (String)dataMap.get('Trigger_For_Initiative__c');
        wrapper.solutionArchitect = (String)dataMap.get('Solution_Architect_Engineer__c');
        wrapper.technicalPM = (String)dataMap.get('Technical_Project_Manager__c');
        wrapper.tagsAboutInitiative = (String)dataMap.get('Tags_About_Initiative__c');
        wrapper.initiativeBillingType = (String)dataMap.get('Initiative_Billing_Type__c');
        wrapper.isBucketOfHours = (Boolean)dataMap.get('Is_a_bucket_of_hours_type__c');
        wrapper.clientContact = (String)dataMap.get('ClientContact');
        
        if (dataMap.containsKey('Offshore_Estimate__c') && dataMap.get('Offshore_Estimate__c') != null) {
            wrapper.offshoreEstimate = Decimal.valueOf(String.valueOf(dataMap.get('Offshore_Estimate__c')));
        }
        
        if (dataMap.containsKey('Probability_Percentage__c') && dataMap.get('Probability_Percentage__c') != null) {
            wrapper.probabilityPercentage = Decimal.valueOf(String.valueOf(dataMap.get('Probability_Percentage__c')));
        }
        
        return wrapper;
    }
    
    /**
     * @description Parse estimates data from JSON
     * @param jsonData JSON string containing estimates array
     * @return List of EstimateWrapper
     */
    public static List<EstimateWrapper> parseEstimatesData(String jsonData) {
        List<EstimateWrapper> estimates = new List<EstimateWrapper>();
        List<Object> dataList = (List<Object>)JSON.deserializeUntyped(jsonData);
        
        for (Object obj : dataList) {
            Map<String, Object> estMap = (Map<String, Object>)obj;
            EstimateWrapper wrapper = new EstimateWrapper();
            
            wrapper.phase = (String)estMap.get('Phase');
            wrapper.taskName = (String)estMap.get('TaskName');
            wrapper.assumption = (String)estMap.get('Assumption');
            
            if (estMap.get('Hours') != null) {
                wrapper.hours = Decimal.valueOf(String.valueOf(estMap.get('Hours')));
            }
            
            estimates.add(wrapper);
        }
        
        return estimates;
    }
    
    /**
     * @description Convert InitiativeWrapper to Initiatives__c SObject
     * @param wrapper InitiativeWrapper to convert
     * @param accServiceId Account Service ID
     * @return Initiatives__c record
     */
    public static Initiatives__c toInitiativeSObject(InitiativeWrapper wrapper, String accServiceId) {
        Initiatives__c initiative = new Initiatives__c();
        
        if (String.isNotBlank(wrapper.id)) {
            initiative.Id = wrapper.id;
        } else if (String.isNotBlank(accServiceId)) {
            initiative.Account_Service__c = accServiceId;
        }
        
        initiative.Name = wrapper.name;
        initiative.JIRA_ID__c = wrapper.jiraId;
        initiative.Brief_Description__c = wrapper.briefDescription;
        initiative.Assumption__c = wrapper.assumption;
        
        if (String.isNotBlank(wrapper.probableStartDate)) {
            initiative.Probable_Start_Date__c = Date.valueOf(wrapper.probableStartDate);
        }
        
        if (String.isNotBlank(wrapper.probableEndDate)) {
            initiative.Probable_End_Date__c = Date.valueOf(wrapper.probableEndDate);
        }
        
        if (String.isNotBlank(wrapper.uatExpectedDate)) {
            initiative.UAT_Expected_Date__c = Date.valueOf(wrapper.uatExpectedDate);
        }
        
        initiative.Initiative_Type__c = wrapper.initiativeType;
        initiative.Initiative_Programming_Reason__c = wrapper.programmingReason;
        initiative.Business_Challenge__c = wrapper.businessChallenge;
        initiative.Persona_s_Involved__c = wrapper.personasInvolved;
        initiative.Technology_Details__c = wrapper.technologyDetails;
        initiative.Outcome_of_our_solution__c = wrapper.outcomeOfSolution;
        initiative.Product__c = wrapper.productNames;
        initiative.Trigger_For_Initiative__c = wrapper.triggerForInitiative;
        initiative.Solution_Architect_Engineer__c = wrapper.solutionArchitect;
        initiative.Technical_Project_Manager__c = wrapper.technicalPM;
        initiative.Tags_About_Initiative__c = wrapper.tagsAboutInitiative;
        initiative.Initiative_Billing_Type__c = wrapper.initiativeBillingType;
        initiative.Is_a_bucket_of_hours_type__c = wrapper.isBucketOfHours;
        initiative.Offshore_Estimate__c = wrapper.offshoreEstimate;
        initiative.Probability_Percentage__c = wrapper.probabilityPercentage;
        
        return initiative;
    }
    
    /**
     * @description Convert EstimateWrapper to Estimate__c SObject
     * @param wrapper EstimateWrapper to convert
     * @param initiativeId Initiative ID to link to
     * @return Estimate__c record
     */
    public static Estimate__c toEstimateSObject(EstimateWrapper wrapper, String initiativeId) {
        Estimate__c estimate = new Estimate__c();
        estimate.Initiative_Lookup__c = initiativeId;
        estimate.Phase__c = wrapper.phase;
        estimate.Task_Components__c = wrapper.taskName;
        estimate.Assumptions__c = wrapper.assumption;
        estimate.Hours__c = wrapper.hours;
        return estimate;
    }
    
    /**
     * @description Get contact ID from approver name
     * @param approverName Approver full name
     * @param accountId Account ID
     * @param serviceId Service ID
     * @return Contact ID
     */
    public static String getContactIdFromApproverName(String approverName, String accountId, String serviceId) {
        if (String.isBlank(approverName)) {
            return null;
        }
        
        List<Contact_Account_Service__c> contactAccService = [
            SELECT Contact__c 
            FROM Contact_Account_Service__c
            WHERE Contact__r.Name = :approverName
            AND Account__c = :accountId
            AND ODS_Service__c = :serviceId
            LIMIT 1
        ];
        
        return !contactAccService.isEmpty() ? contactAccService[0].Contact__c : null;
    }
}
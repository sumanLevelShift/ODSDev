public class EstimationReportController {
    public String xmlheader {get;set;}
    public String fileName {get;set;}   
    
    public static List<Estimation_Summary__c> EstimationSummaryRecord {get;set;}
    public static List<Estimation_Risk_Description__c> EstimationRiskDescriptionRecord {get;set;}
    public static List<Estimation_Checklist__c> EstimationChecklistRecord {get;set;}
    public static List<Estimation_Detail__c> InventoryRecord {get;set;}
    public static List<Estimation_Detail__c> EstimationComplexityRecord {get;set;}
    public static List<SDLCPhasesWise> EffortCalculationRecord {get;set;}
    public static List<Effort_Calculation__c> EffortCalculationSDLCPhaseEffortRecord {get;set;}
    public static List<Effort_Calculation__c> EffortCalculationProjectSpecificActivitiesRecord {get;set;}
    public static List<Effort_Calculation__c> ODSEstimateRecord {get;set;}
    public static integer table1Size {get;set;}
    public static integer table2Size {get;set;}
    public static integer table3Size {get;set;}
    public static integer table4Size {get;set;}
    public decimal effortDeclarativePercentage{get;set;}
    public decimal effortProgrammingPercentage{get;set;}
    public Integer increment_serialno = 1;
    
    public EstimationReportController(){
        xmlheader ='<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
        fileName ='Estimation';      
        String AccountId = apexpages.currentpage().getparameters().get('AccountId');
        String EstimationId = apexpages.currentpage().getparameters().get('EstimationId');
        System.debug('EstimationId'+EstimationId);
        //String SDLCPhasesLabel=system.Label.SDLC_Phasewise_Effort_Distribution;
        String ComplexityMatrixRec ='Complexity Matrix';
        String InventoryRecId ='Inventory';
        String RecSDLCPhaseEffort = 'SDLC Phase Effort';
        String RecProjectSpecificActivity = 'Project Specific Activity Effort';
        String RecOtherActivityEffort = 'Other Activity Effort';
        String RecODSEstimate = 'ODS Estimate';
        
        
        table1Size=0;
        effortDeclarativePercentage=0;
        effortProgrammingPercentage=0;
        
        if(string.isNotBlank(EstimationId)){
            EstimationSummaryRecord = new List<Estimation_Summary__c>();
            EstimationRiskDescriptionRecord = new List<Estimation_Risk_Description__c>();
            EstimationChecklistRecord =  new List<Estimation_Checklist__c>();
            InventoryRecord = new List<Estimation_Detail__c>();
            EstimationComplexityRecord = new List <Estimation_Detail__c>();
            EffortCalculationRecord = new List <SDLCPhasesWise>();
            EffortCalculationSDLCPhaseEffortRecord = new List <Effort_Calculation__c>();
            EffortCalculationProjectSpecificActivitiesRecord = new List <Effort_Calculation__c>();
            ODSEstimateRecord = new List <Effort_Calculation__c>();
            
            
            EstimationSummaryRecord = [SELECT Created_By__r.Full_Name__c,Program_Manager__r.Full_Name__c,SME_Vertical__r.Full_Name__c,Status__c,Project_ID__r.JIRA_ID__c,Acceptance_Criteria__c,Assumptions__c,Total_Effort_In_Weeks__c,Total_Effort_In_Months__c,Total_Effort_In_Hours__c,CreatedById,CreatedDate,Created_By__c,Customer_Success_Manager__r.Name,Customer__r.Name,Estimation_Date__c,Has_Data_Migration__c,Id,IsDeleted,Is_Coding_Involved__c,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,Out_of_Scope__c,Project_Billing_Type__c,Project_Description__c,Project_ID__r.Name,Proposed_End_Date__c,Proposed_Start_Date__c,Revenue_Region__c,Scope__c,SystemModstamp,Team_Productivity__c,Technical_Project_Manager__r.Full_Name__c,Technology__c,Total_Base_Effort_Declarative__c,Without_Risk__c,With_Risk__c,Total_Base_Effort_Months__c,Total_Base_Effort_Programming__c,Work_Days_Per_Month__c,Work_Days_Per_Week__c,Work_Hours_Per_Day__c FROM Estimation_Summary__c WHERE Id = :EstimationId ];     
            if(!EstimationSummaryRecord.isEmpty()){
                fileName ='ODS Estimation - '+EstimationSummaryRecord[0].Customer__r.Name; 
                system.debug('EstimationSummaryRecord[0].Total_Base_Effort_Declarative__c-'+EstimationSummaryRecord[0].Total_Base_Effort_Declarative__c);
                system.debug('EstimationSummaryRecord[0].Total_Base_Effort_Programming__c-'+EstimationSummaryRecord[0].Total_Base_Effort_Programming__c);

                effortDeclarativePercentage=EstimationSummaryRecord[0].Total_Base_Effort_Declarative__c/(EstimationSummaryRecord[0].Total_Base_Effort_Declarative__c+EstimationSummaryRecord[0].Total_Base_Effort_Programming__c);
                effortProgrammingPercentage=EstimationSummaryRecord[0].Total_Base_Effort_Programming__c/(EstimationSummaryRecord[0].Total_Base_Effort_Declarative__c+EstimationSummaryRecord[0].Total_Base_Effort_Programming__c);
                effortDeclarativePercentage=effortDeclarativePercentage.setScale(2, RoundingMode.HALF_UP);
                effortProgrammingPercentage=effortProgrammingPercentage.setScale(2, RoundingMode.HALF_UP);
                system.debug('effortDeclarativePercentage-'+effortDeclarativePercentage);
                system.debug('effortProgrammingPercentage-'+effortProgrammingPercentage);
                //effortProgrammingPercentage=effortProgrammingPercentage*100;
            }
            
            EstimationRiskDescriptionRecord =[SELECT Estimation_Summary__c,Id,Risk_Boundary__c,Risk_Description__c FROM Estimation_Risk_Description__c Where Estimation_Summary__c=:EstimationId];
            EstimationChecklistRecord =[SELECT Activities__c,Check__c,CreatedById,CreatedDate,Estimation_Summary__c,Id,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,Remarks__c,Required__c,Status__c,SystemModstamp,S_No__c FROM Estimation_Checklist__c WHERE  Estimation_Summary__c=:EstimationId];
            system.debug('EstimationChecklistRecord'+EstimationChecklistRecord);
            
            EstimationComplexityRecord =[SELECT Brief_Description__c,Complexity_Definition__c,Complexity__c,Effort_Type__c,Entity_Type__c,Estimation_Element__c,Estimation_Summary__c,Platform__c,Project_Specfic_Effort__c,Rationale_If_Different_From_Recommended__c,Recommended_Effort__c,RecordTypeId,S_No__c FROM Estimation_Detail__c WHERE Estimation_Summary__c=:EstimationId AND RecordType.Name=:ComplexityMatrixRec];
            system.debug('EstimationComplexityRecord'+EstimationComplexityRecord);
            InventoryRecord =[SELECT Assumptions__c,Brief_Description__c,Complexity_Definition__c,Complexity__c,CreatedById,CreatedDate,Effort_Type__c,Entity_Type__c,Estimation_Element__c,Estimation_Summary__c,Id,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,Platform__c,Project_Specfic_Effort__c,Quantity__c,Rationale_If_Different_From_Recommended__c,Recommended_Effort__c,RecordTypeId,SystemModstamp,S_No__c FROM Estimation_Detail__c WHERE Estimation_Summary__c=:EstimationId AND RecordType.Name=:InventoryRecId];
            List<Effort_Calculation__c> EffortCalculationSLDSRecord =[SELECT Activity_Name__c,Applicable_SDLC_Phases__c,Brief_Description__c,New_Other_Value__c,Comments__c,CreatedById,CreatedDate,Estimation_Element__c,Id,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,ODS_Estimate__c,Person_Months_Effort__c,Person_Months__c,Person_Weeks_Effort__c,Person_Weeks__c,Project_Specific_Effort_Hours__c,Project_Specific__c,RecordTypeId,Remarks__c,SLDC_Phase_Name__c,SystemModstamp FROM Effort_Calculation__c WHERE ODS_Estimate__c=:EstimationId AND RecordType.Name=:RecSDLCPhaseEffort];
            table1Size=EffortCalculationSLDSRecord.size();
            system.debug('table1Size---'+table1Size);
            if(!EffortCalculationSLDSRecord.isEmpty()){
                map<string,decimal> ProjectSpecificMap=new map<string,decimal>();
                String SDLCPhasesLabel=system.Label.SDLC_Phasewise_Effort_Distribution;
                List<String> SDLCPhasesList=New List<String>();
                if(string.isNotBlank(SDLCPhasesLabel)){
                    SDLCPhasesList=SDLCPhasesLabel.split('\\|');
                }
                for(string s:SDLCPhasesList){
                    String[] splitePhases=s.split('==');
                    ProjectSpecificMap.put(splitePhases[0],Decimal.valueOf(splitePhases[1].removeEnd('%')));
                }
                map<string,SDLCPhasesWise> SDLCPhasesWiseMap=new map<string,SDLCPhasesWise>();
                for(Effort_Calculation__c ec:EffortCalculationSLDSRecord){
                    SDLCPhasesWise SDLCPhasesWiseObj=new SDLCPhasesWise();
                    SDLCPhasesWiseObj.Phases=ec.SLDC_Phase_Name__c;
                    SDLCPhasesWiseObj.Recommended=ProjectSpecificMap.get(ec.SLDC_Phase_Name__c);
                    SDLCPhasesWiseObj.ProjectSpecfic=ec.Project_Specific__c;
                    
                    
                    SDLCPhasesWiseObj.PersonMonth=ec.Person_Months__c;
                    SDLCPhasesWiseObj.PersonWeeks=ec.Person_Weeks__c;
                    SDLCPhasesWiseObj.Remarks=ec.Remarks__c;
                    EffortCalculationRecord.add(SDLCPhasesWiseObj);
                }
            }
            
            
            EffortCalculationSDLCPhaseEffortRecord =[SELECT Activity_Name__c,Applicable_SDLC_Phases__c,Brief_Description__c,Comments__c,CreatedById,CreatedDate,Estimation_Element__c,Id,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,ODS_Estimate__c,Person_Months_Effort__c,Person_Months__c,Person_Weeks_Effort__c,Person_Weeks__c,Project_Specific_Effort_Hours__c,Project_Specific__c,RecordTypeId,Remarks__c,New_Other_Value__c,SLDC_Phase_Name__c,SystemModstamp FROM Effort_Calculation__c WHERE ODS_Estimate__c=:EstimationId AND RecordType.Name=:RecProjectSpecificActivity];
            
            
            EffortCalculationProjectSpecificActivitiesRecord =[SELECT Activity_Name__c,Applicable_SDLC_Phases__c,Brief_Description__c,Comments__c,CreatedById,CreatedDate,Estimation_Element__c,Id,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,ODS_Estimate__c,Person_Months_Effort__c,Person_Months__c,Person_Weeks_Effort__c,Person_Weeks__c,Project_Specific_Effort_Hours__c,Project_Specific__c,RecordTypeId,Remarks__c,New_Other_Value__c,SLDC_Phase_Name__c,SystemModstamp FROM Effort_Calculation__c WHERE ODS_Estimate__c=:EstimationId AND RecordType.Name=:RecOtherActivityEffort];
            table2Size=EffortCalculationProjectSpecificActivitiesRecord.size();
            table3Size=EffortCalculationSDLCPhaseEffortRecord.size();
            ODSEstimateRecord =[SELECT Activity_Name__c,Applicable_SDLC_Phases__c,Brief_Description__c,Comments__c,CreatedById,CreatedDate,Estimation_Element__c,Id,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,ODS_Estimate__c,Person_Months_Effort__c,Person_Months__c,Person_Weeks_Effort__c,Person_Weeks__c,Project_Specific_Effort_Hours__c,Project_Specific__c,RecordTypeId,Remarks__c,New_Other_Value__c,SLDC_Phase_Name__c,SystemModstamp FROM Effort_Calculation__c WHERE ODS_Estimate__c=:EstimationId AND RecordType.Name=:RecODSEstimate];
            table4Size=ODSEstimateRecord.size();

            
        }
        //estimationChecklist =  BuildEstimateHtml();   
    }
    public class SDLCPhasesWise{
        public string Phases {get;set;}
        public decimal Recommended {get;set;}
        public decimal ProjectSpecfic{get;set;}
        public decimal PersonMonth {get;set;}
        Public decimal PersonWeeks {get;set;} 
        Public string Remarks {get;set;} 
    }
    
}
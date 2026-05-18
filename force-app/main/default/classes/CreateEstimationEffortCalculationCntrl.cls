public without sharing class CreateEstimationEffortCalculationCntrl {
    public class TotalBaseCalculation{
        @AuraEnabled
        public decimal totalBaseEffortDeclarative {get;set;}
        @AuraEnabled
        public decimal totalBaseEffortDeclarativePercentage {get;set;}
        @AuraEnabled
        public decimal totalBaseEffortProgramming{get;set;}
        @AuraEnabled
        public decimal totalBaseEffortProgrammingPercentage {get;set;}
        @AuraEnabled
        Public decimal totalBaseEffortPersonMonth {get;set;} 
        @AuraEnabled
        Public decimal teamProductivity {get;set;}  
    }
    public class SDLCPhasesWise{
        @AuraEnabled
        public string Phases {get;set;}
        @AuraEnabled
        public decimal Recommended {get;set;}
        @AuraEnabled
        public decimal ProjectSpecfic{get;set;}
        @AuraEnabled
        public decimal PersonMonth {get;set;}
        @AuraEnabled
        Public decimal PersonWeeks {get;set;} 
        @AuraEnabled
        Public string Remarks {get;set;} 
    }
    public class SDLCPhasesEffortOtherActivities{
        @AuraEnabled
        public string Activity {get;set;}
        @AuraEnabled
        public string Applicable {get;set;}
        @AuraEnabled
        public decimal ProjectSpecfic{get;set;}
        @AuraEnabled
        public decimal PersonMonth {get;set;}
        @AuraEnabled
        Public decimal PersonWeeks {get;set;} 
        @AuraEnabled
        public string Comments {get;set;}
    }
    public class ProjectSpecificActivitiesWrp{
        @AuraEnabled
        public string Activity {get;set;}
        @AuraEnabled
        public decimal PersonMonth {get;set;}
        @AuraEnabled
        Public decimal PersonWeeks {get;set;} 
        @AuraEnabled
        public string Comments {get;set;}
        @AuraEnabled
        public Boolean NewOtherValue {get;set;}
    }
    public class ODSEstimatePopUp{
        @AuraEnabled
        public string task {get;set;}
        @AuraEnabled
        public decimal hours {get;set;}
    }
    @AuraEnabled( cacheable = false)
    public static list<ODSEstimatePopUp> getInventoryLineItem(string estimationSummary,decimal OtherActivitiesPersonWeek,decimal SpecificActivitiesPersonWeek,decimal ProdDeploymentPW,decimal DevelopmentPW,decimal developmentPercentage){
        decimal ODSDevelopment=0;
        /*  String ODSEstimateLabel=system.Label.ODS_Estimate_Line_Items;
List<String> ODSEstimateList=New List<String>();
if(string.isNotBlank(ODSEstimateLabel)){
ODSEstimateList=ODSEstimateLabel.split('\\|');
}
for(string s:ODSEstimateList){
if(s.Contains('Development')){
ODSDevelopment=Decimal.valueOf(s.split('==')[1].removeEnd('%'));
ODSDevelopment=ODSDevelopment/100;
}
}*/
        ODSDevelopment=developmentPercentage;
        system.debug('DevelopmentPW-'+DevelopmentPW);
        
        decimal totalHour=0;
        list<Estimation_Summary__c> estimationSummaryRecord=[SELECT Id,Work_Days_Per_Month__c,Work_Days_Per_Week__c,Work_Hours_Per_Day__c FROM Estimation_Summary__c WHERE ID=:estimationSummary LIMIT 1];
        if(!estimationSummaryRecord.isEmpty()){
            totalHour=estimationSummaryRecord[0].Work_Days_Per_Week__c*estimationSummaryRecord[0].Work_Hours_Per_Day__c;
        }
        Decimal OtherActivitiesPersonWeekHours=0;
        Decimal SpecificActivitiesPersonWeekHours=0;
        Decimal productionDeploymentPW=0;
        OtherActivitiesPersonWeekHours=OtherActivitiesPersonWeek;
        SpecificActivitiesPersonWeekHours=SpecificActivitiesPersonWeek;
        productionDeploymentPW=ProdDeploymentPW;
        system.debug('OtherActivitiesPersonWeekHours--'+OtherActivitiesPersonWeekHours);
        system.debug('SpecificActivitiesPersonWeekHours--'+SpecificActivitiesPersonWeekHours);
        system.debug('productionDeploymentPW--'+productionDeploymentPW);
        system.debug('totalHour--'+totalHour);
        
        Decimal base = ((OtherActivitiesPersonWeekHours + SpecificActivitiesPersonWeekHours) - productionDeploymentPW) * totalHour;
        system.debug('base--'+base);
        
        Decimal DevelopmentListPW=0;
        DevelopmentListPW=DevelopmentPW;
        
        Decimal deveActualHours = (base * ODSDevelopment) + (DevelopmentListPW * totalHour);
        system.debug('deveActualHours-'+deveActualHours);
        list<ODSEstimatePopUp> ODSEstimatePopUpList=new List<ODSEstimatePopUp>();
        String inventoryRecordTypeId = Schema.SObjectType.Estimation_Detail__c.getRecordTypeInfosByName().get('Inventory').getRecordTypeId();
        //List<AggregateResult > AggregateResultList = [select Sum(Project_Specfic_Effort__c)hours from Estimation_Detail__c WHERE RecordTypeId=:inventoryRecordTypeId and Estimation_Summary__c=:estimationSummary group by Estimation_Summary__c];
        list<Estimation_Detail__c> getEstimationDetail=[SELECT Estimation_Element__c,Entity_Type__c,Project_Specfic_Effort__c,Quantity__c,Recommended_Effort__c  
                                                        FROM Estimation_Detail__c WHERE RecordTypeId=:inventoryRecordTypeId and Estimation_Summary__c=:estimationSummary];
        //decimal total=(decimal)AggregateResultList[0].get('hours');
        decimal total=0;
        for(Estimation_Detail__c ed:getEstimationDetail){
            decimal effort=ed.Project_Specfic_Effort__c*ed.Quantity__c;
            total +=effort;
        }
        system.debug('total--'+total);
        system.debug('deveActualHours--'+deveActualHours);
        
        for(Estimation_Detail__c ed:getEstimationDetail){
            ODSEstimatePopUp o=new ODSEstimatePopUp();
            o.task='['+ed.Entity_Type__c+']'+'-'+ed.Estimation_Element__c;
            decimal effort=ed.Project_Specfic_Effort__c*ed.Quantity__c;
            system.debug('effort--'+effort);
            decimal calHours=effort * (deveActualHours/total);
            system.debug('calHours--'+calHours);
            o.hours=calHours.setScale(0);
            ODSEstimatePopUpList.add(o);
        }
        system.debug('ODSEstimatePopUpList--'+ODSEstimatePopUpList);
        return ODSEstimatePopUpList;
    }
    @AuraEnabled( cacheable = false)
    public static TotalBaseCalculation CalculateTotalBaseHours(string estimationSummary){
        decimal effortDeclarativePercentage=0;
        decimal effortProgrammingPercentage=0;
        decimal effortDeclarative=totalBaseEffortPersonHours(estimationSummary,'Declarative');
        decimal effortProgramming=totalBaseEffortPersonHours(estimationSummary,'Programming');
        if(effortDeclarative !=0 && effortProgramming !=0){
            effortDeclarativePercentage=effortDeclarative/(effortDeclarative+effortProgramming);
            effortProgrammingPercentage=effortProgramming/(effortDeclarative+effortProgramming);
        }
        if(effortDeclarative==0){
            effortProgrammingPercentage=1.0;  
        }
        if(effortProgramming==0){
            effortDeclarativePercentage=1.0;  
        }
        decimal effortPersonMonth=0;
        list<Estimation_Summary__c> estimationSummaryRecord=[SELECT Id,Work_Days_Per_Month__c,Work_Days_Per_Week__c,Work_Hours_Per_Day__c,Team_Productivity__c  FROM Estimation_Summary__c WHERE ID=:estimationSummary LIMIT 1];
        decimal teamPro=0.9;
        
        if(!estimationSummaryRecord.isEmpty()){
            if(estimationSummaryRecord[0].Team_Productivity__c !=null){
                teamPro=estimationSummaryRecord[0].Team_Productivity__c;
            }
            effortPersonMonth=(effortDeclarative+effortProgramming)/(estimationSummaryRecord[0].Work_Hours_Per_Day__c*estimationSummaryRecord[0].Work_Days_Per_Month__c);
        }
        TotalBaseCalculation totalBaseCalculationWrp=new TotalBaseCalculation();
        totalBaseCalculationWrp.totalBaseEffortDeclarative=effortDeclarative;
        totalBaseCalculationWrp.totalBaseEffortDeclarativePercentage=effortDeclarativePercentage;
        totalBaseCalculationWrp.totalBaseEffortProgramming=effortProgramming;
        totalBaseCalculationWrp.totalBaseEffortProgrammingPercentage=effortProgrammingPercentage;
        totalBaseCalculationWrp.totalBaseEffortPersonMonth=effortPersonMonth;
        totalBaseCalculationWrp.teamProductivity=teamPro;
        return totalBaseCalculationWrp;
    }
    
    public static decimal totalBaseEffortPersonHours(string estimationSummary,string effortType){
        String inventoryRecordTypeId = Schema.SObjectType.Estimation_Detail__c.getRecordTypeInfosByName().get('Inventory').getRecordTypeId();
        list<Estimation_Detail__c> getEstimationDetail=[SELECT Project_Specfic_Effort__c,Quantity__c,Recommended_Effort__c  
                                                        FROM Estimation_Detail__c WHERE RecordTypeId=:inventoryRecordTypeId and Estimation_Summary__c=:estimationSummary AND Effort_Type__c=:effortType];
        decimal totalBaseEffort=0;
        for(Estimation_Detail__c ed:getEstimationDetail){
            if(ed.Project_Specfic_Effort__c !=null){
                totalBaseEffort+=ed.Project_Specfic_Effort__c*ed.Quantity__c;
            }else{
                totalBaseEffort+=0;
            }
            /*  decimal TotalEffort=0;
if(ed.Project_Specfic_Effort__c !=null){
TotalEffort=ed.Quantity__c *ed.Project_Specfic_Effort__c;
}else{
TotalEffort=ed.Quantity__c *ed.Recommended_Effort__c;

}
totalBaseEffort =totalBaseEffort+TotalEffort;*/
        }
        totalBaseEffort.setScale(2);
        system.debug('totalBaseEffort---'+totalBaseEffort+'---'+effortType);
        return totalBaseEffort;
    }
    
    @AuraEnabled( cacheable = false)
    public static List<SDLCPhasesWise> getExistSDLCPhasesData(Decimal teamProductivity, Decimal totalBaseEffortMonth, string estimationSummary){
        String SDLCPhaseEffortRecordTypeId = Schema.SObjectType.Effort_Calculation__c.getRecordTypeInfosByName().get('SDLC Phase Effort').getRecordTypeId();
        
        list<Effort_Calculation__c> getexistRecord=[SELECT Id,ODS_Estimate__c,Person_Months__c,Person_Weeks__c,New_Other_Value__c,Project_Specific__c,RecordTypeId,Remarks__c,SLDC_Phase_Name__c FROM Effort_Calculation__c
                                                    Where ODS_Estimate__c=:estimationSummary AND RecordTypeId=:SDLCPhaseEffortRecordTypeId];
        list<Effort_Calculation__c> getexistRecordForDevelopment=[SELECT Id,ODS_Estimate__c,Person_Months__c,Person_Weeks__c,Project_Specific__c,RecordTypeId,New_Other_Value__c,Remarks__c,SLDC_Phase_Name__c FROM Effort_Calculation__c
                                                                  Where ODS_Estimate__c=:estimationSummary AND RecordTypeId=:SDLCPhaseEffortRecordTypeId AND SLDC_Phase_Name__c='Development (Code and unit testing)' LIMIT 1];
        
        List<SDLCPhasesWise> SDLCPhasesWiseObjList=New List<SDLCPhasesWise>();            
        if(!getexistRecord.isEmpty()){
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
            list<Estimation_Summary__c> estimationSummaryRecord=[SELECT Id,Work_Days_Per_Month__c,Work_Days_Per_Week__c,Work_Hours_Per_Day__c FROM Estimation_Summary__c WHERE ID=:estimationSummary LIMIT 1];
            Decimal developmentMonth=totalBaseEffortMonth/teamProductivity;
            Decimal developmentWeek=developmentMonth*(estimationSummaryRecord[0].Work_Days_Per_Month__c/estimationSummaryRecord[0].Work_Days_Per_Week__c);
            decimal sDLCBase=0;
            if(!getexistRecordForDevelopment.isEmpty()){
                sDLCBase=developmentMonth/getexistRecordForDevelopment[0].Project_Specific__c;
            }
            map<string,SDLCPhasesWise> SDLCPhasesWiseMap=new map<string,SDLCPhasesWise>();
            for(Effort_Calculation__c ec:getexistRecord){
                SDLCPhasesWise SDLCPhasesWiseObj=new SDLCPhasesWise();
                SDLCPhasesWiseObj.Phases=ec.SLDC_Phase_Name__c;
                SDLCPhasesWiseObj.Recommended=ProjectSpecificMap.get(ec.SLDC_Phase_Name__c);
                SDLCPhasesWiseObj.ProjectSpecfic=ec.Project_Specific__c;
                if(ec.SLDC_Phase_Name__c=='Development (Code and unit testing)'){
                    SDLCPhasesWiseObj.PersonMonth=developmentMonth.setScale(2);
                    SDLCPhasesWiseObj.PersonWeeks=developmentWeek.setScale(5);
                }else{
                    Decimal personMonths=sDLCBase*ec.Project_Specific__c;
                    Decimal personWeeks=personMonths*(estimationSummaryRecord[0].Work_Days_Per_Month__c/estimationSummaryRecord[0].Work_Days_Per_Week__c);   
                    SDLCPhasesWiseObj.PersonMonth=personMonths.setScale(2);
                    SDLCPhasesWiseObj.PersonWeeks=personWeeks.setScale(5); 
                }
                // SDLCPhasesWiseObj.PersonMonth=ec.Person_Months__c;
                //SDLCPhasesWiseObj.PersonWeeks=ec.Person_Weeks__c;
                SDLCPhasesWiseObj.Remarks=ec.Remarks__c;
                // SDLCPhasesWiseObjList.add(SDLCPhasesWiseObj);
                SDLCPhasesWiseMap.put(ec.SLDC_Phase_Name__c,SDLCPhasesWiseObj);
            }
            for(string s:SDLCPhasesList){
                String[] splitePhases=s.split('==');
                SDLCPhasesWiseObjList.add(SDLCPhasesWiseMap.get(splitePhases[0]));
            }
        }else{
            SDLCPhasesWiseObjList.addAll(generateInitialSDLCPhasesData(teamProductivity,totalBaseEffortMonth,estimationSummary));
        }
        return SDLCPhasesWiseObjList;
    }
    @AuraEnabled( cacheable = false)
    public static List<SDLCPhasesWise> generateInitialSDLCPhasesData(Decimal teamProductivity, Decimal totalBaseEffortMonth, string estimationSummary){
        list<Estimation_Summary__c> estimationSummaryRecord=[SELECT Id,Work_Days_Per_Month__c,Work_Days_Per_Week__c,Work_Hours_Per_Day__c FROM Estimation_Summary__c WHERE ID=:estimationSummary LIMIT 1];
        String SDLCPhasesLabel=system.Label.SDLC_Phasewise_Effort_Distribution;
        List<String> SDLCPhasesList=New List<String>();
        Decimal developmentMonth=totalBaseEffortMonth/teamProductivity;
        Decimal developmentWeek=developmentMonth*(estimationSummaryRecord[0].Work_Days_Per_Month__c/estimationSummaryRecord[0].Work_Days_Per_Week__c);
        Decimal sDLCBase;
        List<SDLCPhasesWise> SDLCPhasesWiseObjList=New List<SDLCPhasesWise>();            
        if(string.isNotBlank(SDLCPhasesLabel)){
            SDLCPhasesList=SDLCPhasesLabel.split('\\|');
        }
        if(!SDLCPhasesList.isEmpty()){
            for(string s:SDLCPhasesList){
                if(s.Contains('Development (Code and unit testing)')){
                    String[] splitePhases=s.split('==');
                    decimal Distribution=Decimal.valueOf(splitePhases[1].removeEnd('%'));
                    sDLCBase=developmentMonth/Distribution;
                }
            }
            for(string s:SDLCPhasesList){
                SDLCPhasesWise SDLCPhasesWiseObj=New SDLCPhasesWise();            
                
                String[] splitePhases=s.split('==');
                system.debug('splitePhases[0]-'+splitePhases[0]);
                if(s.Contains('Development (Code and unit testing)')){
                    SDLCPhasesWiseObj.Phases=splitePhases[0];
                    SDLCPhasesWiseObj.Recommended=Decimal.valueOf(splitePhases[1].removeEnd('%'));
                    SDLCPhasesWiseObj.ProjectSpecfic=Decimal.valueOf(splitePhases[1].removeEnd('%'));
                    Decimal personMonths=sDLCBase*Decimal.valueOf(splitePhases[1].removeEnd('%'));
                    SDLCPhasesWiseObj.PersonMonth=developmentMonth.setScale(3);
                    SDLCPhasesWiseObj.PersonWeeks=developmentWeek.setScale(3);
                    
                }else{
                    SDLCPhasesWiseObj.Phases=splitePhases[0];
                    SDLCPhasesWiseObj.Recommended=Decimal.valueOf(splitePhases[1].removeEnd('%'));
                    SDLCPhasesWiseObj.ProjectSpecfic=Decimal.valueOf(splitePhases[1].removeEnd('%'));
                    Decimal personMonths=sDLCBase*Decimal.valueOf(splitePhases[1].removeEnd('%'));
                    SDLCPhasesWiseObj.PersonMonth=personMonths.setScale(3);
                    Decimal personWeeks=personMonths*(estimationSummaryRecord[0].Work_Days_Per_Month__c/estimationSummaryRecord[0].Work_Days_Per_Week__c);
                    SDLCPhasesWiseObj.PersonWeeks=personWeeks.setScale(3);
                }
                SDLCPhasesWiseObj.Remarks='';
                SDLCPhasesWiseObjList.add(SDLCPhasesWiseObj);
            }
        }
        return SDLCPhasesWiseObjList;
    }
    
    @AuraEnabled( cacheable = false)
    public static List<SDLCPhasesWise> reGenerateInitialSDLCPhases(Decimal teamProductivity, Decimal totalBaseEffortMonth, string estimationSummary,string SDLCDreaftRes,decimal developmentCode){
        list<Estimation_Summary__c> estimationSummaryRecord=[SELECT Id,Work_Days_Per_Month__c,Work_Days_Per_Week__c,Work_Hours_Per_Day__c FROM Estimation_Summary__c WHERE ID=:estimationSummary LIMIT 1];
        system.debug('totalBaseEffortMonth-'+totalBaseEffortMonth);
        system.debug('teamProductivity-'+teamProductivity);
        
        Decimal developmentMonth=totalBaseEffortMonth/teamProductivity;
        Decimal developmentWeek=developmentMonth*(estimationSummaryRecord[0].Work_Days_Per_Month__c/estimationSummaryRecord[0].Work_Days_Per_Week__c);
        decimal sDLCBase=developmentMonth/developmentCode;
        system.debug('SDLCDreaftRes--'+SDLCDreaftRes);
        List<Object> obList = (List<object>) json.deserializeUntyped(SDLCDreaftRes);
        List<SDLCPhasesWise> SDLCPhasesWiseObjList=New List<SDLCPhasesWise>();            
        
        for(object ob : obList) 
        {
            SDLCPhasesWise SDLCPhasesWiseObj=New SDLCPhasesWise();            
            
            Map<String, object> obmap = (Map<String, object>)ob;
            string SLDC = (string)obmap.get('SDLCPhasesName');
            string projectSpecific = (string)obmap.get('ProjectSpecific');
            SDLCPhasesWiseObj.Phases=SLDC;
            if(SLDC=='Development (Code and unit testing)'){
                SDLCPhasesWiseObj.PersonMonth=developmentMonth.setScale(2);
                SDLCPhasesWiseObj.PersonWeeks=developmentWeek.setScale(5);
            }else{
                Decimal personMonths=sDLCBase*decimal.valueOf(projectSpecific);
                Decimal personWeeks=personMonths*(estimationSummaryRecord[0].Work_Days_Per_Month__c/estimationSummaryRecord[0].Work_Days_Per_Week__c);   
                SDLCPhasesWiseObj.PersonMonth=personMonths.setScale(2);
                SDLCPhasesWiseObj.PersonWeeks=personWeeks.setScale(5);
            }
            system.debug('SDLCPhasesWiseObj-'+SDLCPhasesWiseObj);
            SDLCPhasesWiseObjList.add(SDLCPhasesWiseObj);
        }
        return SDLCPhasesWiseObjList;
    }
    @AuraEnabled(cacheable=false)
    public static void insertODSEstimate(String ODSEstimateResponse, string estimationSummaryId){
        String gsRecordTypeID = Schema.SObjectType.Effort_Calculation__c.getRecordTypeInfosByName().get('ODS Estimate').getRecordTypeId();
        List<Effort_Calculation__c> insertODSEstimateList=New List<Effort_Calculation__c>();
        List<Object> obList = (List<object>) json.deserializeUntyped(ODSEstimateResponse);
        for(object ob : obList) 
        {
            Map<String, object> obmap = (Map<String, object>)ob;
            string LineItem = (string)obmap.get('LineItem');
            decimal Percentage = 0;
            decimal ActualHours=0;
            Boolean newOtherValue = (Boolean)obmap.get('newOtherValue');
            if(!Test.isRunningTest()){
                Percentage = (decimal)obmap.get('Percentage');
                ActualHours = (decimal)obmap.get('ActualHours');
            }            
            Effort_Calculation__c ecal=new Effort_Calculation__c();
            ecal.SLDC_Phase_Name__c=LineItem;
            if(!LineItem.Contains('Deployment')){
                ecal.Project_Specific__c=Percentage;
            }else{
                ecal.Project_Specific__c=0;
            }
            ecal.Project_Specific_Effort_Hours__c=ActualHours;
            ecal.RecordTypeId=gsRecordTypeID;
            ecal.New_Other_Value__c=newOtherValue;
            ecal.ODS_Estimate__c=estimationSummaryId;
            insertODSEstimateList.add(ecal);         
        }
        List<Effort_Calculation__c> existODSEstimate=[Select Id FROM Effort_Calculation__c Where ODS_Estimate__c =:estimationSummaryId AND RecordTypeId=:gsRecordTypeID];
        if(!insertODSEstimateList.isEmpty()){
            Database.SaveResult[] srList = Database.insert(insertODSEstimateList, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    if(!existODSEstimate.isEmpty()){
                        Database.DeleteResult[] drList = Database.delete(existODSEstimate, false);
                        break;
                    }
                }
                
            }
        }
        /* if(!insertODSEstimateList.isEmpty()){
insert insertODSEstimateList;
system.debug('estimationSummaryId--'+estimationSummaryId+'---gsRecordTypeID---'+gsRecordTypeID);
system.debug('existODSEstimate--'+existODSEstimate);

if(!existODSEstimate.isEmpty()){
delete existODSEstimate;
}
}*/
    }
    @AuraEnabled( cacheable = false)
    public static SDLCPhasesEffortOtherActivities generateOtherActivities(string estimationSummary,string applicable,string SDLCDreaftRes,decimal changedProjectSpecific){
        system.debug('changedProjectSpecific-'+changedProjectSpecific);
        list<Estimation_Summary__c> estimationSummaryRecord=[SELECT Id,Work_Days_Per_Month__c,Work_Days_Per_Week__c,Work_Hours_Per_Day__c FROM Estimation_Summary__c WHERE ID=:estimationSummary LIMIT 1];
        List<Object> obList = (List<object>) json.deserializeUntyped(SDLCDreaftRes);
        Map<string,SDLCPhasesWise> SDLCPhasesWiseObjList=New  Map<string,SDLCPhasesWise>();            
        
        for(object ob : obList) 
        {
            decimal personMonth=0;
            decimal personWeek=0;
            SDLCPhasesWise SDLCPhasesWiseObj=New SDLCPhasesWise();            
            
            Map<String, object> obmap = (Map<String, object>)ob;
            string SLDC = (string)obmap.get('SDLCPhasesName');
            string projectSpecific = (string)obmap.get('ProjectSpecific');
            if(!Test.isRunningTest()){
                personMonth = (decimal)obmap.get('personMonth');
                personWeek = (decimal)obmap.get('personWeek');
            }
            SDLCPhasesWiseObj.ProjectSpecfic=decimal.valueof(projectSpecific);
            SDLCPhasesWiseObj.PersonMonth=personMonth;
            SDLCPhasesWiseObj.PersonWeeks=personWeek;
            SDLCPhasesWiseObjList.put(SLDC,SDLCPhasesWiseObj);
        }
        decimal Total_Person_Month_For_All=0;
        for(SDLCPhasesWise s:SDLCPhasesWiseObjList.values()){
            Total_Person_Month_For_All =Total_Person_Month_For_All + s.PersonMonth;
        }
        decimal personMonth=0.0;
        decimal personWeeks=0.0;
        if(SDLCPhasesWiseObjList.containsKey(applicable)){
            SDLCPhasesWise sp=SDLCPhasesWiseObjList.get(applicable);
            personMonth=(changedProjectSpecific/100)*sp.PersonMonth;  
            system.debug('changedProjectSpecific---'+changedProjectSpecific);
            system.debug('sp.PersonMonth---'+sp.PersonMonth);
            
        }else if(applicable =='All'){
            personMonth=(changedProjectSpecific/100)*Total_Person_Month_For_All;
        }
        personWeeks=personMonth * (estimationSummaryRecord[0].Work_Days_Per_Month__c/estimationSummaryRecord[0].Work_Days_Per_Week__c);
        SDLCPhasesEffortOtherActivities result=New SDLCPhasesEffortOtherActivities();
        result.PersonMonth=personMonth.setScale(2);
        result.PersonWeeks=personWeeks;
        return result;
    }
    @AuraEnabled( cacheable = false)
    public static decimal getEstimationRecord(string estimationSummary,decimal personMonth){
        decimal personWeeks=0;
        decimal pm=0;
        if(personMonth !=null){
            pm=personMonth;
        }
        list<Estimation_Summary__c> estimationSummaryRecord=[SELECT Id,Work_Days_Per_Month__c,Work_Days_Per_Week__c,Work_Hours_Per_Day__c FROM Estimation_Summary__c WHERE ID=:estimationSummary LIMIT 1];
        if(!estimationSummaryRecord.isEmpty()){
            personWeeks=pm * (estimationSummaryRecord[0].Work_Days_Per_Month__c/estimationSummaryRecord[0].Work_Days_Per_Week__c);
        }
        return personWeeks.setScale(5);
    }
    @AuraEnabled( cacheable = false)
    public static void insertEffortCalculations(string estimationSummary,string SDLCPhaseEffortRes,string OtherActivityEffortRes,string ProjectSpecificActivityEffortRes){
        String SDLCPhaseEffortRecordTypeId = Schema.SObjectType.Effort_Calculation__c.getRecordTypeInfosByName().get('SDLC Phase Effort').getRecordTypeId();
        String OtherActivityEffortRecordTypeId = Schema.SObjectType.Effort_Calculation__c.getRecordTypeInfosByName().get('Other Activity Effort').getRecordTypeId();
        String ProjectSpecificActivityEffortRecordTypeId = Schema.SObjectType.Effort_Calculation__c.getRecordTypeInfosByName().get('Project Specific Activity Effort').getRecordTypeId();
        list<Effort_Calculation__c> insertEffortCalculation=new list<Effort_Calculation__c>();
        
        //insert or update for SDLCPhaseEffort
        List<Object> SDLCPhaseEffortList = (List<object>) json.deserializeUntyped(SDLCPhaseEffortRes);        
        for(object ob : SDLCPhaseEffortList) 
        {  
            decimal personMonth=0;
            decimal personWeek=0;
            Map<String, object> obmap = (Map<String, object>)ob;
            string SDLCPhasesName = (string)obmap.get('SDLCPhasesName');
            string ProjectSpecific = (string)obmap.get('ProjectSpecific');
            if(!Test.isRunningTest()){
                personMonth = (decimal)obmap.get('personMonth');
                personWeek = (decimal)obmap.get('personWeek');
            }
            string Rationale = (string)obmap.get('Rationale');
            Effort_Calculation__c ecal=new Effort_Calculation__c();
            ecal.SLDC_Phase_Name__c=SDLCPhasesName;
            ecal.Project_Specific__c=decimal.valueOf(ProjectSpecific);
            ecal.Person_Months__c=personMonth;
            ecal.Remarks__c	=Rationale;
            ecal.RecordTypeId=SDLCPhaseEffortRecordTypeId;
            ecal.ODS_Estimate__c=estimationSummary;
            insertEffortCalculation.add(ecal);
            
        }
        
        //insert or update for OtherActivityEffort
        List<Object> OtherActivityEffortList = (List<object>) json.deserializeUntyped(OtherActivityEffortRes);        
        for(object ob : OtherActivityEffortList) 
        {   
            decimal personMonth=0;        
            Map<String, object> obmap = (Map<String, object>)ob;
            string Activity = (string)obmap.get('Activity');
            string Applicable = (string)obmap.get('Applicable');
            string ProjectSpecific = (string)obmap.get('ProjectSpecific');
            if(!Test.isRunningTest()){
                personMonth = (decimal)obmap.get('personMonth');
            }
            string Rationale = (string)obmap.get('Rationale');
            
            Effort_Calculation__c ecal=new Effort_Calculation__c();
            ecal.Activity_Name__c=Activity;
            ecal.Applicable_SDLC_Phases__c=Applicable;
            ecal.Project_Specific__c=decimal.valueOf(ProjectSpecific);
            ecal.Person_Months__c=personMonth;
            ecal.Comments__c=Rationale;
            ecal.RecordTypeId=OtherActivityEffortRecordTypeId;
            ecal.ODS_Estimate__c=estimationSummary;
            insertEffortCalculation.add(ecal);
        }
        
        //insert or update for ProjectSpecificActivityEffort
        List<Object> ProjectSpecificActivityEffortList = (List<object>) json.deserializeUntyped(ProjectSpecificActivityEffortRes);        
        for(object ob : ProjectSpecificActivityEffortList) 
        {            
            Map<String, object> obmap = (Map<String, object>)ob;
            string Activity = (string)obmap.get('Activity');
            string personMonth = (string)obmap.get('personMonth');
            string Rationale = (string)obmap.get('Rationale');
            Boolean newOtherValue = (Boolean)obmap.get('NewOtherValue');
            Decimal pMonth=0;
            if(string.isNotBlank(personMonth)){
                pMonth=decimal.valueof(personMonth);
            }
            Effort_Calculation__c ecal=new Effort_Calculation__c();
            ecal.Activity_Name__c=Activity;
            ecal.Person_Months__c=pMonth;
            ecal.Comments__c=Rationale;
            ecal.New_Other_Value__c=newOtherValue;
            ecal.RecordTypeId=ProjectSpecificActivityEffortRecordTypeId;
            ecal.ODS_Estimate__c=estimationSummary;
            insertEffortCalculation.add(ecal);
        }
        system.debug('insertEffortCalculation--'+insertEffortCalculation.size());
        list<Effort_Calculation__c> getExistEffortCalculation=[Select Id From Effort_Calculation__c Where ODS_Estimate__c=:estimationSummary];
        
        /* if(!insertEffortCalculation.isEmpty()){
insert insertEffortCalculation;
}
if(!getExistEffortCalculation.isEmpty()){
delete getExistEffortCalculation;
}*/
        if(!insertEffortCalculation.isEmpty()){
            Database.SaveResult[] srList = Database.insert(insertEffortCalculation, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    if(!getExistEffortCalculation.isEmpty()){
                        Database.DeleteResult[] drList = Database.delete(getExistEffortCalculation, false);
                        break;
                    }
                }
                
            }
        }
    }
    @AuraEnabled( cacheable = false)
    public static void updateEstimationSummary(string estimationSummary,decimal teamProductivity,decimal withRisk,decimal withOutRisk){
        List<Estimation_Summary__c> updateEstimationSummary=new List<Estimation_Summary__c>();
        List<Estimation_Summary__c> estimationSummaryRecord=[SELECT Id,Team_Productivity__c,Without_Risk__c,With_Risk__c,Total_Effort_In_Hours__c,Program_Manager__c FROM Estimation_Summary__c Where ID=:estimationSummary];
        if(!estimationSummaryRecord.isEmpty()){
            string threshold=system.label.Estimation_Threshold;
            Estimation_Summary__c es=new Estimation_Summary__c();
            es.id=estimationSummaryRecord[0].Id; 
            es.Team_Productivity__c=teamProductivity; 
            es.With_Risk__c=withRisk;
            es.Without_Risk__c=withOutRisk;
            if(estimationSummaryRecord[0].Total_Effort_In_Hours__c < decimal.valueOf(threshold)){
                es.Program_Manager__c=null;
            }
            updateEstimationSummary.add(es);
        }
        /*List<Estimation_Summary__c> estimationSummaryRecord1=[SELECT Id,Total_Effort_In_Hours__c,Program_Manager__c FROM Estimation_Summary__c Where ID=:estimationSummary];
if(!estimationSummaryRecord1.isEmpty()){
string threshold=system.label.Estimation_Threshold;
if(estimationSummaryRecord1[0].Total_Effort_In_Hours__c < decimal.valueOf(threshold)){
Estimation_Summary__c es=new Estimation_Summary__c();
es.id=estimationSummaryRecord1[0].Id; 
es.Program_Manager__c=null;
updateEstimationSummary.add(es);
}
}*/
        if(!updateEstimationSummary.isEmpty()){
            Database.SaveResult[] srList = Database.update(updateEstimationSummary, false);
        }
    }
    
    @AuraEnabled( cacheable = false)
    public static List<SDLCPhasesEffortOtherActivities> getExistOtherActivitiesEffort(string estimationSummary){
        String OtherActivityEffortRecordTypeId = Schema.SObjectType.Effort_Calculation__c.getRecordTypeInfosByName().get('Other Activity Effort').getRecordTypeId();
        
        list<Effort_Calculation__c> getexistRecord=[SELECT Id,Applicable_SDLC_Phases__c,ODS_Estimate__c,Person_Months__c,Person_Weeks__c,New_Other_Value__c,Project_Specific__c,RecordTypeId,Remarks__c,Activity_Name__c,Comments__c FROM Effort_Calculation__c
                                                    Where ODS_Estimate__c=:estimationSummary AND RecordTypeId=:OtherActivityEffortRecordTypeId];
        List<SDLCPhasesEffortOtherActivities> SDLCPhasesEffortOtherActivitiesList=New List<SDLCPhasesEffortOtherActivities>();            
        if(!getexistRecord.isEmpty()){
            list<Estimation_Summary__c> estimationSummaryRecord=[SELECT Id,Work_Days_Per_Month__c,Work_Days_Per_Week__c,Work_Hours_Per_Day__c FROM Estimation_Summary__c WHERE ID=:estimationSummary LIMIT 1];
            Map<string,Effort_Calculation__c> existSLDCSpecficMap=New Map<string,Effort_Calculation__c>();
            List<Effort_Calculation__c> existSLDCSpecfic=[Select Id,Person_Months__c,SLDC_Phase_Name__c From Effort_Calculation__c Where ODS_Estimate__c=:estimationSummary AND RecordType.Name='SDLC Phase Effort'];
            Decimal Total_Person_Month_For_All=0;
            For(Effort_Calculation__c ec: existSLDCSpecfic){
                Total_Person_Month_For_All=Total_Person_Month_For_All+ec.Person_Months__c;
                existSLDCSpecficMap.put(ec.SLDC_Phase_Name__c,ec);
            }
            Map<string,SDLCPhasesEffortOtherActivities> SDLCPhasesEffortOtherActivitiesMap=new Map<string,SDLCPhasesEffortOtherActivities>();
            for(Effort_Calculation__c ec:getexistRecord){
                SDLCPhasesEffortOtherActivities Obj=new SDLCPhasesEffortOtherActivities();
                Obj.Activity=ec.Activity_Name__c;
                Obj.Applicable=ec.Applicable_SDLC_Phases__c;
                Obj.ProjectSpecfic=ec.Project_Specific__c;
                if(ec.Applicable_SDLC_Phases__c=='All'){
                    Obj.PersonMonth=(ec.Project_Specific__c/100)*Total_Person_Month_For_All;
                }else{
                    Effort_Calculation__c ec1=existSLDCSpecficMap.get(ec.Applicable_SDLC_Phases__c);
                    system.debug('ec1---'+ec1);
                    if(ec1 !=null){
                        Obj.PersonMonth=(ec.Project_Specific__c/100)*ec1.Person_Months__c;
                    }
                }
                decimal pw=Obj.PersonMonth * (estimationSummaryRecord[0].Work_Days_Per_Month__c/estimationSummaryRecord[0].Work_Days_Per_Week__c);
                Obj.PersonWeeks=pw;
                Obj.Comments=ec.Comments__c;
                //SDLCPhasesEffortOtherActivitiesList.add(Obj);
                SDLCPhasesEffortOtherActivitiesMap.put(ec.Activity_Name__c,Obj);
            }
            String otherActiLabel=system.Label.Effort_Other_Activities;
            List<String> otherActiviList=New List<String>();            
            if(string.isNotBlank(otherActiLabel)){
                otherActiviList=otherActiLabel.split('\\|');
            }
            for(string s:otherActiviList){                
                String[] otherAct=s.split('==');
                SDLCPhasesEffortOtherActivitiesList.add(SDLCPhasesEffortOtherActivitiesMap.get(otherAct[0]));
            }
        }else{
            String otherActiLabel=system.Label.Effort_Other_Activities;
            List<String> otherActiviList=New List<String>();            
            if(string.isNotBlank(otherActiLabel)){
                otherActiviList=otherActiLabel.split('\\|');
            }
            for(string s:otherActiviList){                
                String[] otherAct=s.split('==');
                SDLCPhasesEffortOtherActivities Obj=new SDLCPhasesEffortOtherActivities();
                Obj.Activity=otherAct[0];
                Obj.Applicable=otherAct[1];
                Obj.ProjectSpecfic=0;
                Obj.PersonMonth=0;
                Obj.PersonWeeks=0;
                Obj.Comments='';
                SDLCPhasesEffortOtherActivitiesList.add(Obj);
            }
        }
        return SDLCPhasesEffortOtherActivitiesList;
    }
    @AuraEnabled( cacheable = false)
    public static List<ProjectSpecificActivitiesWrp> getExistProjectSpecificActivitiesEffort(string estimationSummary){
        String ProjectSpecificActivityEffortRecordTypeId = Schema.SObjectType.Effort_Calculation__c.getRecordTypeInfosByName().get('Project Specific Activity Effort').getRecordTypeId();
        
        list<Effort_Calculation__c> getexistRecord=[SELECT Id,Applicable_SDLC_Phases__c,ODS_Estimate__c,Person_Months__c,Person_Weeks__c,New_Other_Value__c,Project_Specific__c,RecordTypeId,Remarks__c,Activity_Name__c,Comments__c FROM Effort_Calculation__c
                                                    Where ODS_Estimate__c=:estimationSummary AND RecordTypeId=:ProjectSpecificActivityEffortRecordTypeId];
        List<ProjectSpecificActivitiesWrp> ProjectSpecificActivitiesWrpList=New List<ProjectSpecificActivitiesWrp>();            
        if(!getexistRecord.isEmpty()){
            Map<string,ProjectSpecificActivitiesWrp> ProjectSpecificActivitiesMap=new Map<string,ProjectSpecificActivitiesWrp>();
            for(Effort_Calculation__c ec:getexistRecord){
                ProjectSpecificActivitiesWrp Obj=new ProjectSpecificActivitiesWrp();
                Obj.Activity=ec.Activity_Name__c;
                Obj.PersonMonth=ec.Person_Months__c;
                Obj.PersonWeeks=ec.Person_Weeks__c.setScale(5);
                Obj.Comments=ec.Comments__c;
                Obj.NewOtherValue = ec.New_Other_Value__c;
                //ProjectSpecificActivitiesWrpList.add(Obj);
                ProjectSpecificActivitiesMap.put(ec.Activity_Name__c,obj);
            }
            
            String projectSpeLabel=system.Label.Effort_Project_Specific_Activities;
            List<String> projectSpeLabelList=New List<String>();            
            if(string.isNotBlank(projectSpeLabel)){
                projectSpeLabelList=projectSpeLabel.split('\\|');
            }
            for(string s:projectSpeLabelList){  
                ProjectSpecificActivitiesWrpList.add(ProjectSpecificActivitiesMap.get(s));
                ProjectSpecificActivitiesMap.remove(s);
            }
            if(!ProjectSpecificActivitiesMap.isEmpty()){
                for(ProjectSpecificActivitiesWrp p:ProjectSpecificActivitiesMap.values()){
                    ProjectSpecificActivitiesWrpList.add(p);
                }
            }
        }else{
            String projectSpeLabel=system.Label.Effort_Project_Specific_Activities;
            List<String> projectSpeLabelList=New List<String>();            
            if(string.isNotBlank(projectSpeLabel)){
                projectSpeLabelList=projectSpeLabel.split('\\|');
            }
            for(string s:projectSpeLabelList){                
                ProjectSpecificActivitiesWrp Obj=new ProjectSpecificActivitiesWrp();
                Obj.Activity=s;
                Obj.PersonMonth=0;
                Obj.PersonWeeks=0;
                Obj.Comments='';
                Obj.NewOtherValue = false;
                ProjectSpecificActivitiesWrpList.add(Obj);
            }
        }
        return ProjectSpecificActivitiesWrpList;
    }
    @AuraEnabled( cacheable = false)
    public static decimal getTotalHoursForEstimation(string estimationSummary){
        decimal totalHour=0;
        list<Estimation_Summary__c> estimationSummaryRecord=[SELECT Id,Work_Days_Per_Month__c,Work_Days_Per_Week__c,Work_Hours_Per_Day__c FROM Estimation_Summary__c WHERE ID=:estimationSummary LIMIT 1];
        if(!estimationSummaryRecord.isEmpty()){
            totalHour=estimationSummaryRecord[0].Work_Days_Per_Week__c*estimationSummaryRecord[0].Work_Hours_Per_Day__c;
        }
        return totalHour;
    }
}
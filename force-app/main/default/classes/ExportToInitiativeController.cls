public class ExportToInitiativeController {
    @AuraEnabled
    public static boolean CheckInitiativeIsSavedOrNot(string estimatedId){
        Boolean saved=false;
        
        List<Estimation_Summary__c> estimationSummaryRecord=[SELECT Project_ID__r.Status__c FROM Estimation_Summary__c Where 
                                                             Project_ID__r.Status__c IN ('Saved','Re-evaluate') AND ID=:estimatedId AND Status__c ='Approved' limit 1];
        if(!estimationSummaryRecord.isEmpty()){
            saved=true;
        }
        return saved;
    }
    @AuraEnabled
    public static void createEstimationElement(string estimatedId){
        decimal ODSDevelopment=0;

        List<Effort_Calculation__c> effortCalculationList=[Select Id,Project_Specific__c From Effort_Calculation__c WHERE SLDC_Phase_Name__c = 'Development (Code and unit testing)' 
                                                           AND ODS_Estimate__c =:estimatedId AND RecordType.Name='SDLC Phase Effort'];
        if(!effortCalculationList.isEmpty()){
            ODSDevelopment=effortCalculationList[0].Project_Specific__c;
            ODSDevelopment=ODSDevelopment/100;
        }
        List<Estimation_Summary__c> estimationSummaryRecord=[SELECT Acceptance_Criteria__c,Assumptions__c,Out_of_Scope__c,Scope__c,Work_Hours_Per_Day__c,Work_Days_Per_Week__c,Project_ID__c,Project_ID__r.Status__c,Total_Effort_In_Hours__c FROM Estimation_Summary__c Where
                                                             ID=:estimatedId limit 1];
        
        List<Estimate__c> insertEstimate=New List<Estimate__c>();
        if(!estimationSummaryRecord.isEmpty()){
            List<Estimate__c> existElement=[select id From Estimate__c Where Initiative_Lookup__c=:estimationSummaryRecord[0].Project_ID__c];
            String odsEstimateRecordTypeID = Schema.SObjectType.Effort_Calculation__c.getRecordTypeInfosByName().get('ODS Estimate').getRecordTypeId();
           // List<Effort_Calculation__c> getODSEstimate=[Select Id,Brief_Description__c,Activity_Name__c,New_Other_Value__c,SLDC_Phase_Name__c,Project_Specific_Effort_Hours__c From Effort_Calculation__c Where
                                                       // (RecordTypeId=:odsEstimateRecordTypeID OR New_Other_Value__c = true) AND ODS_Estimate__c=:estimatedId ];
             List<Effort_Calculation__c> getODSEstimate=[Select Id,Brief_Description__c,Activity_Name__c,New_Other_Value__c,SLDC_Phase_Name__c,Project_Specific_Effort_Hours__c From Effort_Calculation__c Where
                                                        RecordTypeId=:odsEstimateRecordTypeID  AND ODS_Estimate__c=:estimatedId ];
            
            string briefDescription='<table border="0" cellpadding="0" cellspacing="0" style="width:656px"><tbody><tr>';
            briefDescription +='<td><b>Objective Statement/ Acceptance Criteria</b></td>';
            briefDescription+='<td>'+estimationSummaryRecord[0].Acceptance_Criteria__c+'</td>';
            briefDescription +='</tr><tr><td><b>Scope</b></td>';
            briefDescription +='<td>'+estimationSummaryRecord[0].Scope__c+'</td>';
            briefDescription +='</tr><tr><td><b>Out Of Scope</b></td>';
            briefDescription +='<td>'+estimationSummaryRecord[0].Out_of_Scope__c+'</td>';
            briefDescription +='</tr><tr><td><b>Assumptions</b></td>';
            briefDescription +='<td>'+estimationSummaryRecord[0].Assumptions__c+'</td>';
            briefDescription +='</tr></tbody></table>';
            
            Decimal totalEffortHour=estimationSummaryRecord[0].Total_Effort_In_Hours__c;
            
            Initiatives__c initiativeObj=new Initiatives__c();
            initiativeObj.Id=estimationSummaryRecord[0].Project_ID__c;
            initiativeObj.Brief_Description__c=briefDescription;
            initiativeObj.Offshore_Estimate__c=totalEffortHour.round(System.RoundingMode.DOWN);
            Update initiativeObj;
            
            if(!getODSEstimate.isEmpty()){
                for(Effort_Calculation__c ec:getODSEstimate){
                    if(ec.SLDC_Phase_Name__c !='Development' && !ec.New_Other_Value__c){
                        Estimate__c e=new Estimate__c();
                        e.Initiative_Lookup__c=estimationSummaryRecord[0].Project_ID__c;
                        if(ec.SLDC_Phase_Name__c =='Production Deployment' || ec.SLDC_Phase_Name__c =='Sandbox Deployment'){
                            e.Phase__c='Deployment';   
                        }else{
                            e.Phase__c=ec.SLDC_Phase_Name__c;  
                        }
                        e.Hours__c=ec.Project_Specific_Effort_Hours__c;
                        e.Task_Components__c=ec.SLDC_Phase_Name__c;
                        insertEstimate.add(e);
                    }
                    // newly added for export Init
                     if(ec.New_Other_Value__c ){
                        Estimate__c e=new Estimate__c();
                        e.Initiative_Lookup__c=estimationSummaryRecord[0].Project_ID__c;
                        e.Phase__c='Others';
                        e.Hours__c=ec.Project_Specific_Effort_Hours__c;
                        e.Task_Components__c=ec.SLDC_Phase_Name__c;
                        insertEstimate.add(e);
                     }   
                }
            }
            Decimal totalHour=estimationSummaryRecord[0].Work_Days_Per_Week__c*estimationSummaryRecord[0].Work_Hours_Per_Day__c;

            List<AggregateResult > OtherActivitiesPersonWeek  = [select Sum(Person_Weeks__c)hours from Effort_Calculation__c  WHERE RecordType.Name=:'Other Activity Effort' and ODS_Estimate__c =:estimatedId group by ODS_Estimate__c];
            List<AggregateResult > SpecificActivitiesPersonWeek  = [select Sum(Person_Weeks__c)hours from Effort_Calculation__c  WHERE RecordType.Name=:'Project Specific Activity Effort' and ODS_Estimate__c =:estimatedId group by ODS_Estimate__c];
            //List<Effort_Calculation__c> ProductionDeployment=[SELECT Person_Weeks__c FROM Effort_Calculation__c WHERE ODS_Estimate__c = :estimatedId AND Activity_Name__c = 'Production Deployment'];
           // List<Effort_Calculation__c> sandboxDeployment=[SELECT Person_Weeks__c FROM Effort_Calculation__c WHERE ODS_Estimate__c = :estimatedId AND Activity_Name__c = 'Sandbox Deployment'];
  			List<Effort_Calculation__c> deploymentAndOthersList=[SELECT Person_Weeks__c FROM Effort_Calculation__c WHERE ODS_Estimate__c = :estimatedId AND (Activity_Name__c Like: '%Deployment%' OR New_Other_Value__c=true)];
            Decimal OtherActivitiesPersonWeekHours=0;
            Decimal SpecificActivitiesPersonWeekHours=0;
            Decimal ProductionDeploymentPW=0;
            Decimal SandboxDeploymentPW=0;

            if(!OtherActivitiesPersonWeek.isEmpty()){
                OtherActivitiesPersonWeekHours=(decimal)OtherActivitiesPersonWeek[0].get('hours');
            }
            if(!SpecificActivitiesPersonWeek.isEmpty()){
                SpecificActivitiesPersonWeekHours=(decimal)SpecificActivitiesPersonWeek[0].get('hours');
            }
           /* if(!ProductionDeployment.isEmpty()){
                ProductionDeploymentPW=ProductionDeployment[0].Person_Weeks__c;
            }
            if(!sandboxDeployment.isEmpty()){
                SandboxDeploymentPW=sandboxDeployment[0].Person_Weeks__c;
            }*/
            decimal deployment=0;
            for(Effort_Calculation__c ec:deploymentAndOthersList){
                deployment=deployment+ec.Person_Weeks__c;
            }
            Decimal base = ((OtherActivitiesPersonWeekHours + SpecificActivitiesPersonWeekHours) - deployment) * totalHour;
            List<Effort_Calculation__c> DevelopmentList=[SELECT Person_Weeks__c FROM Effort_Calculation__c WHERE ODS_Estimate__c = :estimatedId AND SLDC_Phase_Name__c = 'Development (Code and unit testing)'];
            Decimal DevelopmentListPW=0;
            if(!DevelopmentList.isEmpty()){
                DevelopmentListPW=DevelopmentList[0].Person_Weeks__c;
            }
            Decimal deveActualHours = (base * ODSDevelopment) + (DevelopmentListPW * totalHour);

            list<Estimation_Detail__c> getInevntory=[SELECT Quantity__c,Brief_Description__c,Complexity_Definition__c,Complexity__c,Effort_Type__c,Entity_Type__c,Estimation_Element__c,Estimation_Summary__c,Platform__c,Project_Specfic_Effort__c,Rationale_If_Different_From_Recommended__c,Recommended_Effort__c,RecordTypeId,S_No__c 
                                                     FROM Estimation_Detail__c WHERE Estimation_Summary__c=:estimatedId AND RecordType.Name=:'Inventory' ORDER BY S_No__c ASC NULLS FIRST];
            if(!getInevntory.isEmpty()){
                //List<AggregateResult > AggregateResultList = [select Sum(Project_Specfic_Effort__c)hours from Estimation_Detail__c WHERE RecordType.Name=:'Inventory' and Estimation_Summary__c=:estimatedId group by Estimation_Summary__c];
                //decimal total=(decimal)AggregateResultList[0].get('hours');
                decimal total=0;
                for(Estimation_Detail__c ec:getInevntory){
                    decimal effort=ec.Project_Specfic_Effort__c*ec.Quantity__c;
                    total +=effort;
                }
                for(Estimation_Detail__c ec:getInevntory){
                    Estimate__c e=new Estimate__c();
                    e.Initiative_Lookup__c=estimationSummaryRecord[0].Project_ID__c;
                    e.Phase__c='Development';
                    decimal effort=ec.Project_Specfic_Effort__c*ec.Quantity__c;
                    decimal calHours=effort * (deveActualHours/total);
                    e.Hours__c=calHours.setScale(0);
                    e.Task_Components__c='['+ec.Entity_Type__c+'] - '+ec.Estimation_Element__c;
                    e.Assumptions__c=ec.Brief_Description__c;
                    insertEstimate.add(e);
                }
            }
            system.debug('insertEstimate-'+insertEstimate);
            if(!insertEstimate.isEmpty()){
                Database.SaveResult[] srList = Database.insert(insertEstimate, false);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        if(!existElement.isEmpty()){
                        Database.DeleteResult[] drList = Database.delete(existElement, false);
                        break;
                        }
                    }
                    
                }
            }
        }
    }
}
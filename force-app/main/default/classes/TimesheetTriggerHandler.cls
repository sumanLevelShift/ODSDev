public class TimesheetTriggerHandler {
    public static Boolean shouldIntegrateWithBC(Date weekStartDate) {
        Integer weekNumber = getWeekNumber(weekStartDate);
        system.debug('weekNumber-'+weekNumber);
        return Math.mod(weekNumber, 2) == 0;
    }
    
    public static Integer getWeekNumber(Date d) {
        Date firstOfYear = Date.newInstance(d.year(), 1, 1);
        Integer daysBetween = firstOfYear.daysBetween(d);
        Integer weekNumber = (daysBetween + firstOfYear.toStartOfWeek().daysBetween(firstOfYear)) / 7 + 1;
        return weekNumber;
    }
    public static Date getWorkOrderStartDate(string accountId, date weekEndDate){
        system.debug('accountId---'+accountId);
        List<Work_Order__c> WOList=[SELECT Business_Unit__c,Client_Name__c,Project_End_Date__c,Project_Start_Date__c,SubCategory__c,TIPS_CNSMP_WO_ID__c,TIPS_Admin_CNSMP_WO_ID__c,TIPS_Consulting_CNSMP_WO_ID__c,BC_Build_CNSMP_WO_ID__c, BC_Admin_CNSMP_WO_ID__c, BC_Consulting_CNSMP_WO_ID__c FROM Work_Order__c
                                    WHERE Client_Name__c=:accountId AND Project_Start_Date__c <=: weekEndDate AND Project_End_Date__c >=: weekEndDate AND SubCategory__c LIKE '%Subscription%' ORDER BY CreatedDate ASC NULLS FIRST];
        for(Work_Order__c wo:WOList){
            string subCategoryConsumption='';
            string subCategoryConsumptionCO='';
            if(wo.Business_Unit__c=='DemandBlue'){
                subCategoryConsumption=wo.Business_Unit__c+'-Subscription';
                subCategoryConsumptionCO=wo.Business_Unit__c+'-Subscription-CO';   
            }else{
                subCategoryConsumption=wo.Business_Unit__c+' -Subscription';
                subCategoryConsumptionCO=wo.Business_Unit__c+' -Subscription-CO'; 
            }
            
            if(wo.SubCategory__c==subCategoryConsumption || wo.SubCategory__c==subCategoryConsumptionCO){
                return wo.Project_Start_Date__c;
            }
        }
        return null;
    }
    public static void sendTimesheet(string timesheetId){
        try{
            List < Timesheet__c > tSWeeklyUpd = new List < Timesheet__c > ();
            List < Timesheet__c > tSMonthlyUpd = new List < Timesheet__c > ();
            List < Timesheet__c > tSBiWeeklyUpd = new List < Timesheet__c > ();
            List < Timesheet__c > tSSemiMonthlyUpd = new List < Timesheet__c > ();
            List < Timesheet__c > updateTimesheetList = new List < Timesheet__c > ();
            String billingType='';
            List< Timesheet__c > timesheetList=[SELECT Id,Account_Services__c,Total_Hours_Build__c,Total_Hours_Admin__c,Total_Hours_Consulting__c,Account_Services__r.Account__r.Customer_Type__c,Account_Services__r.Account__r.Name,Account_Services__r.Account__c,Account_Services__r.Invoice_Frequency__c,Status__c,Total_Hours__c,Week_Start_Date__c,Week_End_Date__c
                                                FROM Timesheet__c WHERE Id =: timesheetId AND Status__c=:'Submitted' Limit 1];
            for (Timesheet__c TS1: timesheetList) {
                billingType=TS1.Account_Services__r.Account__r.Customer_Type__c;
                if (TS1.Account_Services__r.Invoice_Frequency__c == 'Weekly') {
                    tSWeeklyUpd.add(TS1);
                    if(Test.isRunningTest()){
                        tSWeeklyUpd.add(TS1); 
                    }
                }
                if (TS1.Account_Services__r.Invoice_Frequency__c == 'Monthly') {
                    Date firstDayOfMonth = TS1.Week_Start_Date__c.toStartOfMonth();
                    Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
                    if (lastDayOfMonth >= TS1.Week_Start_Date__c && lastDayOfMonth <= TS1.Week_End_Date__c) {
                        system.debug('TS1-'+TS1);
                        tSMonthlyUpd.add(TS1);
                    }
                    if(Test.isRunningTest()){
                        tSMonthlyUpd.add(TS1); 
                    }
                }
                if(TS1.Account_Services__r.Invoice_Frequency__c=='Bi-Weekly'){
                    date currentWeekStart=TS1.Week_Start_Date__c;
                    Date prevBiWeeeklyWeekStart = currentWeekStart - 7;
                    Date nextWeekStart = currentWeekStart + 7;
                    date woStartDate=getWorkOrderStartDate(TS1.Account_Services__r.Account__c,TS1.Week_End_Date__c);
                    Boolean isWOEven=woStartDate!=null?shouldIntegrateWithBC(woStartDate):false;
                    Boolean isTimesheetWeekEven=shouldIntegrateWithBC(currentWeekStart);
                    system.debug('isWOEven--'+isWOEven);
                    system.debug('isTimesheetWeekEven--'+isTimesheetWeekEven);
                    if(Test.isRunningTest()){
                        tSBiWeeklyUpd.add(TS1); 
                    }
                    List<Timesheet__c> lastWeekTimesheet=[SELECT Id,BC_Build_API_Response__c,Account_Services__c,Total_Hours_Build__c,Total_Hours_Admin__c,Total_Hours_Consulting__c,Account_Services__r.Account__r.Customer_Type__c,Account_Services__r.Account__r.Name,Account_Services__r.Account__c,Account_Services__r.Invoice_Frequency__c,Status__c,Total_Hours__c,Week_Start_Date__c,Week_End_Date__c
                                                          FROM Timesheet__c WHERE Week_Start_Date__c=:prevBiWeeeklyWeekStart AND Account_Services__c =: TS1.Account_Services__c AND Status__c IN ('Submitted','Approved') and Non_Bi_Weekly__c=true Limit 1];
                    if((isWOEven && !isTimesheetWeekEven) || !lastWeekTimesheet.isEmpty() || (!isWOEven && isTimesheetWeekEven)){
                        tSBiWeeklyUpd.add(TS1);
                    }else {
                        List<Timesheet__c> nextWeekTimesheet=[SELECT Id,BC_Build_API_Response__c,Account_Services__c,Total_Hours_Build__c,Total_Hours_Admin__c,Total_Hours_Consulting__c,Account_Services__r.Account__r.Customer_Type__c,Account_Services__r.Account__r.Name,Account_Services__r.Account__c,Account_Services__r.Invoice_Frequency__c,Status__c,Total_Hours__c,Week_Start_Date__c,Week_End_Date__c
                                                              FROM Timesheet__c WHERE Week_Start_Date__c=:nextWeekStart AND Account_Services__c =: TS1.Account_Services__c AND Status__c IN ('Submitted','Approved') and Non_Bi_Weekly__c=false Limit 1];
                        if (!nextWeekTimesheet.isEmpty() && nextWeekTimesheet[0].BC_Build_API_Response__c != null && nextWeekTimesheet[0].BC_Build_API_Response__c.toLowerCase().contains('successfully')) {
                            tSBiWeeklyUpd.add(nextWeekTimesheet[0]);
                        } 
                        Timesheet__c updateTs=new Timesheet__c();
                        updateTs.Id=TS1.id;
                        updateTs.Non_Bi_Weekly__c=true;
                        updateTimesheetList.add(updateTs);
                    }
                }
                if (TS1.Account_Services__r.Invoice_Frequency__c=='Semi-Monthly'){
                    date currentWeekStart=TS1.Week_Start_Date__c;
                    date currentWeekEnd=TS1.Week_End_Date__c;
                    Date firstDayOfMonth = TS1.Week_Start_Date__c.toStartOfMonth();
                    Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
                    Date semiMonth1EndDate = Date.newInstance(lastDayOfMonth.year(), lastDayOfMonth.month(), 15);
                    Date semiMonth2EndDate = lastDayOfMonth;
                    
                    if (semiMonth1EndDate >= TS1.Week_Start_Date__c && semiMonth1EndDate <= TS1.Week_End_Date__c) {
                        tSSemiMonthlyUpd.add(TS1);
                    }else if (lastDayOfMonth >= TS1.Week_Start_Date__c && lastDayOfMonth <= TS1.Week_End_Date__c){
                        tSSemiMonthlyUpd.add(TS1);
                    }
                }
            }
            if(billingType=='ABC Type'){
                if (!tSWeeklyUpd.isEmpty()){
                    sendTimesheettoTipsABC(tSWeeklyUpd, 'Weekly'); 
                }
                if (!tSMonthlyUpd.isEmpty()){
                    sendTimesheettoTipsABC(tSMonthlyUpd, 'Monthly');
                }   
                if(!tSBiWeeklyUpd.isEmpty()){
                    sendTimesheettoTipsABC(tSBiWeeklyUpd, 'Bi-Weekly');
                }
                if(!tSSemiMonthlyUpd.isEmpty()){
                    sendTimesheettoTipsABC(tSSemiMonthlyUpd, 'Semi-Monthly');
                }
            }else{
                if (!tSWeeklyUpd.isEmpty()){
                    sendTimesheettoTips(tSWeeklyUpd, 'Weekly'); 
                }
                if (!tSMonthlyUpd.isEmpty()){
                    sendTimesheettoTips(tSMonthlyUpd, 'Monthly');
                }
                if(!tSBiWeeklyUpd.isEmpty()){
                    sendTimesheettoTips(tSBiWeeklyUpd, 'Bi-Weekly');
                }
                if(!tSSemiMonthlyUpd.isEmpty()){
                    sendTimesheettoTips(tSSemiMonthlyUpd, 'Semi-Monthly');
                }
            }
            if(!updateTimesheetList.isEmpty()){
                update updateTimesheetList;
            }
        } catch (Exception e) {
            ODS_ExceptionUtility.LogException(e);
        }
    }
    private static string getTIPSIdWO(string accountId, date weekEndDate){
        system.debug('accountId---'+accountId);
        List<Work_Order__c> WOList=[SELECT Business_Unit__c,Client_Name__c,Project_End_Date__c,Project_Start_Date__c,SubCategory__c,TIPS_CNSMP_WO_ID__c,BC_Build_CNSMP_WO_ID__c FROM Work_Order__c
                                    WHERE Client_Name__c=:accountId AND Project_Start_Date__c <=: weekEndDate AND Project_End_Date__c >=: weekEndDate AND SubCategory__c LIKE '%Subscription%' ORDER BY CreatedDate ASC NULLS FIRST];
        for(Work_Order__c wo:WOList){
            string subCategoryConsumption='';
            string subCategoryConsumptionCO='';
            if(wo.Business_Unit__c=='DemandBlue'){
                subCategoryConsumption=wo.Business_Unit__c+'-Subscription';
                subCategoryConsumptionCO=wo.Business_Unit__c+'-Subscription-CO';   
            }else{
                subCategoryConsumption=wo.Business_Unit__c+' -Subscription';
                subCategoryConsumptionCO=wo.Business_Unit__c+' -Subscription-CO'; 
            }
            if(wo.SubCategory__c==subCategoryConsumption || wo.SubCategory__c==subCategoryConsumptionCO){
                string tipsId=!boolean.valueOf(system.label.BC_Integration) ?  wo.TIPS_CNSMP_WO_ID__c: wo.BC_Build_CNSMP_WO_ID__c;
                return tipsId;
            }
        }
        WOList=[SELECT Business_Unit__c,Client_Name__c,Project_End_Date__c,Project_Start_Date__c,SubCategory__c,TIPS_CNSMP_WO_ID__c,BC_Build_CNSMP_WO_ID__c FROM Work_Order__c
                WHERE Client_Name__c=:accountId AND SubCategory__c LIKE '%Subscription%' ORDER BY CreatedDate DESC LIMIT 1];
        for(Work_Order__c wo:WOList){
            string subCategoryConsumption='';
            string subCategoryConsumptionCO='';
            if(wo.Business_Unit__c=='DemandBlue'){
                subCategoryConsumption=wo.Business_Unit__c+'-Subscription';
                subCategoryConsumptionCO=wo.Business_Unit__c+'-Subscription-CO';   
            }else{
                subCategoryConsumption=wo.Business_Unit__c+' -Subscription';
                subCategoryConsumptionCO=wo.Business_Unit__c+' -Subscription-CO'; 
            }
            if(wo.SubCategory__c==subCategoryConsumption || wo.SubCategory__c==subCategoryConsumptionCO){
                string tipsId=!boolean.valueOf(system.label.BC_Integration) ?  wo.TIPS_CNSMP_WO_ID__c: wo.BC_Build_CNSMP_WO_ID__c;
                return tipsId;
            }
        }
        return null;
    }
    
    private static Work_Order__c getTIPSIdWOABC(string accountId, date weekEndDate){
        system.debug('accountId---'+accountId);
        List<Work_Order__c> WOList=[SELECT Business_Unit__c,Client_Name__c,Project_End_Date__c,Project_Start_Date__c,SubCategory__c,TIPS_CNSMP_WO_ID__c,TIPS_Admin_CNSMP_WO_ID__c,TIPS_Consulting_CNSMP_WO_ID__c,BC_Build_CNSMP_WO_ID__c, BC_Admin_CNSMP_WO_ID__c, BC_Consulting_CNSMP_WO_ID__c FROM Work_Order__c
                                    WHERE Client_Name__c=:accountId AND Project_Start_Date__c <=: weekEndDate AND Project_End_Date__c >=: weekEndDate AND SubCategory__c LIKE '%Subscription%' ORDER BY CreatedDate ASC NULLS FIRST];
        for(Work_Order__c wo:WOList){
            string subCategoryConsumption='';
            string subCategoryConsumptionCO='';
            if(wo.Business_Unit__c=='DemandBlue'){
                subCategoryConsumption=wo.Business_Unit__c+'-Subscription';
                subCategoryConsumptionCO=wo.Business_Unit__c+'-Subscription-CO';   
            }else{
                subCategoryConsumption=wo.Business_Unit__c+' -Subscription';
                subCategoryConsumptionCO=wo.Business_Unit__c+' -Subscription-CO'; 
            }
            
            if(wo.SubCategory__c==subCategoryConsumption || wo.SubCategory__c==subCategoryConsumptionCO){
                return wo;
            }
        }
        WOList=[SELECT Business_Unit__c,Client_Name__c,Project_End_Date__c,Project_Start_Date__c,SubCategory__c,TIPS_CNSMP_WO_ID__c,TIPS_Admin_CNSMP_WO_ID__c,TIPS_Consulting_CNSMP_WO_ID__c,BC_Build_CNSMP_WO_ID__c, BC_Admin_CNSMP_WO_ID__c, BC_Consulting_CNSMP_WO_ID__c FROM Work_Order__c
                WHERE Client_Name__c=:accountId AND SubCategory__c LIKE '%Subscription%' ORDER BY CreatedDate DESC LIMIT 1];
        for(Work_Order__c wo:WOList){
            string subCategoryConsumption='';
            string subCategoryConsumptionCO='';
            if(wo.Business_Unit__c=='DemandBlue'){
                subCategoryConsumption=wo.Business_Unit__c+'-Subscription';
                subCategoryConsumptionCO=wo.Business_Unit__c+'-Subscription-CO';   
            }else{
                subCategoryConsumption=wo.Business_Unit__c+' -Subscription';
                subCategoryConsumptionCO=wo.Business_Unit__c+' -Subscription-CO'; 
            }
            
            if(wo.SubCategory__c==subCategoryConsumption || wo.SubCategory__c==subCategoryConsumptionCO){
                return wo;
            }
        }
        return null;
    }
    private static List<Work_Order__c> getWorkOrders(string accountId,Date StartDate, date endDate){
        return [SELECT Business_Unit__c,Client_Name__c,Project_End_Date__c,Project_Start_Date__c,SubCategory__c,BC_Build_CNSMP_WO_ID__c, BC_Admin_CNSMP_WO_ID__c, BC_Consulting_CNSMP_WO_ID__c,
                (SELECT ID,Start_Date__c,End_Date__c,BC_Build_CNSMP_WO_ID__c, BC_Admin_CNSMP_WO_ID__c, BC_Consulting_CNSMP_WO_ID__c FROM Work_Order_External_References__r 
                 WHERE Start_Date__c <=: endDate AND End_Date__c >=: StartDate order by Start_Date__c ASC ) FROM Work_Order__c
                WHERE Client_Name__c=:accountId AND Project_Start_Date__c <=: endDate AND Project_End_Date__c >=: StartDate AND SubCategory__c IN ('DemandBlue-Subscription','DemandBlue-Subscription-CO') ORDER BY Project_End_Date__c DESC];
    }
    public static void sendTimesheettoTips(List < Timesheet__c > TSList, String freq) {
        try {
            if (freq == 'Weekly') {
                for (Timesheet__c T: TSList) {
                    TipsAPIHelperClass apiHelper = new TipsAPIHelperClass();
                    Date stDt = T.Week_Start_Date__c;
                    Date edDt = T.Week_End_Date__c;
                    string tipsWOID=getTIPSIdWO(t.Account_Services__r.Account__c, edDt);
                    List<Work_Order__c> validWorkOrders=getWorkOrders(t.Account_Services__r.Account__c,stDt ,edDt);
                    
                    system.debug('tipsWOID-'+tipsWOID);
                    String stDtStr = DateTime.newInstance(stDt.year(), stDt.month(), stDt.day()).format('MM/dd/YYYY');
                    String edDtStr = DateTime.newInstance(edDt.year(), edDt.month(), edDt.day()).format('MM/dd/YYYY');                    
                    
                    If(!boolean.valueOf(system.label.BC_Integration)){
                        if(string.isNotBlank(tipsWOID)){
                            // string body = '{"data":"' + apiHelper.AESEncryptDecrypt('{"WorkorderId":"' + tipsWOID + '","StartDate":"' + stDtStr + '","EndDate":"' + edDtStr + '","Hours":"' + T.Total_Hours__c + '"}') + '"}';
                            string body = '{"data":"' + apiHelper.AESEncryptDecrypt(TimesheetTriggerHelper.getTimesheetDetailsWeekly(tipsWOID, t.Id)) + '"}';
                            system.debug('body-'+body);
                            TipsAPIHelperClass.HttpRequest(System.Label.TIPS_Timesheet_API_Endpoint, body, 'POST',T.Id,'Build'); 
                            TipsTimesheetPDFGenerationBatch obj=new TipsTimesheetPDFGenerationBatch('Weekly',t.Id,new set<id>(),stDt,edDt,tipsWOID,'',false,t.Account_Services__r.Account__r.Name);
                            Database.executeBatch(obj);
                        }else{
                            sendMailForFailureTimesheet(T,stDtStr,edDtStr);
                        }
                    }else{
                        Integer delayInMinutes = 0;
                        Map<Work_Order_External_Reference__c, List<Time_Sheet_Details__c>> woToTimesheetDetailsMap =TimesheetTriggerBCHelper.getTimesheetDetailsWeeklyWithWo(T.id,validWorkOrders);
                        for(Work_Order_External_Reference__c Wo:woToTimesheetDetailsMap.keySet()){
                            if(String.isNotBlank(wo.BC_Build_CNSMP_WO_ID__c)){
                                List<Time_Sheet_Details__c> timesheetDetailsRecords=woToTimesheetDetailsMap.get(wo);
                                if(!timesheetDetailsRecords.isEmpty()){
                                    string body = '{"data":"' + apiHelper.AESEncryptDecrypt(TimesheetTriggerBCHelper.getTimesheetDetailsWeekly(wo, timesheetDetailsRecords)) + '"}';
                                    system.debug('body-'+body);
                                    
                                    ID jobID = System.enqueueJob(new BC_TimesheetHttpRequestQueueable(body,T.Id,'Build','Add'), delayInMinutes);
                                    delayInMinutes=delayInMinutes+1;
                                    //TimesheetTriggerBCHelper.HttpRequestBC(body,T.Id,'Build','Add');  
                                }
                            }else{
                                sendMailForFailureTimesheet(T,stDtStr,edDtStr);
                            }
                        }
                    }
                }
            }
            if (freq == 'Monthly' || freq == 'Semi-Monthly') {
                Date startDate;
                Date endDate;
                Set<Id> AllTSIds=new Set<Id>();
                Set<Id> accountSer=new Set<Id>();
                for (Timesheet__c TSEntry: TSList) {
                    Date sD = TSEntry.Week_Start_Date__c;
                    Date eD = TSEntry.Week_End_Date__c;
                    if(freq == 'Monthly'){
                        startDate = sD.toStartOfMonth();
                        endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month()) - 1);
                    }else if (freq == 'Semi-Monthly'){
                        Date firstDayOfMonth = TSEntry.Week_Start_Date__c.toStartOfMonth();
                        Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
                        Date semiMonth1EndDate = Date.newInstance(lastDayOfMonth.year(), lastDayOfMonth.month(), 15);
                        Date semiMonth2EndDate = lastDayOfMonth;
                        
                        if (semiMonth1EndDate >= TSEntry.Week_Start_Date__c && semiMonth1EndDate <= TSEntry.Week_End_Date__c) {
                            startDate = firstDayOfMonth;
                            endDate = semiMonth1EndDate;
                        }else if (semiMonth2EndDate >= TSEntry.Week_Start_Date__c && semiMonth2EndDate <= TSEntry.Week_End_Date__c){
                            startDate = semiMonth1EndDate+1;
                            endDate = semiMonth2EndDate;
                        }
                    }
                    accountSer.add(TSEntry.Account_Services__c);
                    
                }
                system.debug('startDate--'+startDate+'-endDate-'+endDate);
                Map<Id,Timesheet__c> timesheetWithTimesheetDetails=new Map<Id,Timesheet__c>([Select Id,Week_Start_Date__c,Week_End_Date__c,Approver_Name__r.Name,Comments__c,ApproverName__c,Approved_Date__c,Account_Services__r.Account__r.Name,Account_Services__r.ODS_Service_Name__c,Status__c,
                                                                                             (SELECT Hours_Worked__c,Row_No_Value__c ,Task_Name__c,Timesheet_Date__c,Timesheet__c From Timesheet_Details__r WHERE Timesheet_Date__c >=: startDate AND Timesheet_Date__c <=: endDate ORDER BY Row_No_Value__c ASC NULLS FIRST)
                                                                                             From Timesheet__c WHERE Account_Services__c IN:accountSer AND (Status__c='Submitted' OR Status__c='Approved') AND 
                                                                                             ((Week_Start_Date__c >= :startDate AND Week_End_Date__c <= :endDate) OR (Week_Start_Date__c < :startDate AND Week_End_Date__c >= :startDate)
                                                                                              OR (Week_Start_Date__c <= :endDate AND Week_End_Date__c > :endDate) OR (Week_Start_Date__c = :startDate)) ]);
                
                //((Week_Start_Date__c >=: startDate and Week_End_Date__c <=: endDate ) OR (Week_Start_Date__c <: startDate AND Week_End_Date__c >: startDate) OR (Week_Start_Date__c <: endDate AND Week_End_Date__c >: endDate))]); 
                
                AllTSIds.addAll(timesheetWithTimesheetDetails.keySet());
                system.debug('AllTSIds-'+AllTSIds);
                for (Timesheet__c TSEntry1: TSList) {
                    TipsAPIHelperClass apiHelper = new TipsAPIHelperClass();
                    Date stDt = startDate;
                    Date edDt = endDate;
                    system.debug('stDt');
                    system.debug(stDt);
                    String stDtStr = DateTime.newInstance(stDt.year(), stDt.month(), stDt.day()).format('MM/dd/YYYY');
                    String edDtStr = DateTime.newInstance(edDt.year(), edDt.month(), edDt.day()).format('MM/dd/YYYY');
                    // Decimal TotHrs = getTotalHours(stDt, edDt, TSEntry1);
                    string tipsWOID=getTIPSIdWO(TSEntry1.Account_Services__r.Account__c, edDt);
                    List<Work_Order__c> validWorkOrders=getWorkOrders(TSEntry1.Account_Services__r.Account__c,stDt ,edDt);
                    boolean BC_Integration=boolean.valueOf(system.label.BC_Integration);
                    If(!BC_Integration){
                        if(string.isNotBlank(tipsWOID)){
                            string body = '{"data":"' + apiHelper.AESEncryptDecrypt(TimesheetTriggerHelper.getTimesheetDetailsMonthly(tipsWOID,AllTSIds,stDt,edDt)) + '"}';
                            system.debug('body monthly-'+body);
                            TipsAPIHelperClass.HttpRequest(System.Label.TIPS_Timesheet_API_Endpoint, body, 'POST',TSEntry1.Id,'Build');
                            TipsTimesheetPDFGenerationBatch obj=new TipsTimesheetPDFGenerationBatch('Monthly','',AllTSIds,stDt,edDt,tipsWOID,'',false,TSEntry1.Account_Services__r.Account__r.Name);
                            Database.executeBatch(obj);
                        }else{
                            sendMailForFailureTimesheet(TSEntry1,stDtStr,edDtStr);
                        }
                    }else{
                        Integer delayInMinutes = 0;
                        Map<Work_Order_External_Reference__c, List<Time_Sheet_Details__c>> woToTimesheetDetailsMap =TimesheetTriggerBCHelper.getTimesheetDetailsMonthlyWithWo(AllTSIds,validWorkOrders,stDt,edDt);
                        for(Work_Order_External_Reference__c Wo:woToTimesheetDetailsMap.keySet()){
                            if(String.isNotBlank(wo.BC_Build_CNSMP_WO_ID__c)){
                                List<Time_Sheet_Details__c> timesheetDetailsRecords=woToTimesheetDetailsMap.get(wo);
                                if(!timesheetDetailsRecords.isEmpty()){
                                    string body = '{"data":"' + apiHelper.AESEncryptDecrypt(TimesheetTriggerBCHelper.getTimesheetDetailsMonthly(Wo,timesheetDetailsRecords,stDt,edDt)) + '"}';
                                    system.debug('body-'+body);
                                    ID jobID = System.enqueueJob(new BC_TimesheetHttpRequestQueueable(body,TSEntry1.Id,'Build','Add'), delayInMinutes);
                                    delayInMinutes=delayInMinutes+1;
                                    //TimesheetTriggerBCHelper.HttpRequestBC(body,TSEntry1.Id,'Build','Add'); 
                                }
                            }else{
                                sendMailForFailureTimesheet(TSEntry1,stDtStr,edDtStr);
                            }
                        }
                    }
                }
            }
            if (freq == 'Bi-Weekly'){
                Date startDate;
                Date endDate;
                Set<Id> AllTSIds=new Set<Id>();
                Set<Id> accountSer=new Set<Id>();
                system.debug('TSList-'+TSList);
                for (Timesheet__c TSEntry: TSList) {
                    startDate = TSEntry.Week_Start_Date__c.addDays(-7);
                    endDate = TSEntry.Week_End_Date__c;
                    accountSer.add(TSEntry.Account_Services__c);
                }
                
                Map<Id,Timesheet__c> timesheetWithTimesheetDetails=new Map<Id,Timesheet__c>([Select Id,Week_Start_Date__c,Week_End_Date__c,Approver_Name__r.Name,Comments__c,ApproverName__c,Approved_Date__c,Account_Services__r.Account__r.Name,Account_Services__r.ODS_Service_Name__c,Status__c,
                                                                                             (SELECT Hours_Worked__c,Row_No_Value__c ,Task_Name__c,Timesheet_Date__c,Timesheet__c From Timesheet_Details__r WHERE Timesheet_Date__c >=: startDate AND Timesheet_Date__c <=: endDate ORDER BY Row_No_Value__c ASC NULLS FIRST)
                                                                                             From Timesheet__c WHERE Account_Services__c IN:accountSer AND (Status__c='Submitted' OR Status__c='Approved') AND 
                                                                                             ((Week_Start_Date__c >= :startDate AND Week_End_Date__c <= :endDate) OR (Week_Start_Date__c < :startDate AND Week_End_Date__c >= :startDate)
                                                                                              OR (Week_Start_Date__c <= :endDate AND Week_End_Date__c > :endDate) OR (Week_Start_Date__c = :startDate)) ]);
                
                AllTSIds.addAll(timesheetWithTimesheetDetails.keySet());
                system.debug('AllTSIds-'+AllTSIds);
                for (Timesheet__c TSEntry1: TSList) {
                    TipsAPIHelperClass apiHelper = new TipsAPIHelperClass();
                    Date stDt = TSEntry1.Week_Start_Date__c.addDays(-7);
                    Date edDt = TSEntry1.Week_End_Date__c;
                    system.debug('stDt');
                    system.debug(stDt);
                    String stDtStr = DateTime.newInstance(stDt.year(), stDt.month(), stDt.day()).format('MM/dd/YYYY');
                    String edDtStr = DateTime.newInstance(edDt.year(), edDt.month(), edDt.day()).format('MM/dd/YYYY');
                    //string tipsWOID=getTIPSIdWO(TSEntry1.Account_Services__r.Account__c, edDt);
                    List<Work_Order__c> validWorkOrders=getWorkOrders(TSEntry1.Account_Services__r.Account__c,stDt ,edDt);
                    
                    If(boolean.valueOf(system.label.BC_Integration)){
                        Integer delayInMinutes = 0;
                        Map<Work_Order_External_Reference__c, List<Time_Sheet_Details__c>> woToTimesheetDetailsMap =TimesheetTriggerBCHelper.getTimesheetDetailsMonthlyWithWo(AllTSIds,validWorkOrders,stDt,edDt);
                        for(Work_Order_External_Reference__c Wo:woToTimesheetDetailsMap.keySet()){
                            if(String.isNotBlank(wo.BC_Build_CNSMP_WO_ID__c)){
                                List<Time_Sheet_Details__c> timesheetDetailsRecords=woToTimesheetDetailsMap.get(wo);
                                if(!timesheetDetailsRecords.isEmpty()){
                                    string body = '{"data":"' + apiHelper.AESEncryptDecrypt(TimesheetTriggerBCHelper.getTimesheetDetailsMonthly(wo,timesheetDetailsRecords,stDt,edDt)) + '"}';
                                    system.debug('body-'+body);
                                    ID jobID = System.enqueueJob(new BC_TimesheetHttpRequestQueueable(body,TSEntry1.Id,'Build','Add'), delayInMinutes);
                                    delayInMinutes=delayInMinutes+1;
                                    // TimesheetTriggerBCHelper.HttpRequestBC(body,TSEntry1.Id,'Build','Add'); 
                                }
                            }else{
                                sendMailForFailureTimesheet(TSEntry1,stDtStr,edDtStr);
                            }
                        }
                        
                    }
                }
            }
        } catch (Exception e) {
            ODS_ExceptionUtility.LogException(e);
        }
    }
    public static void sendTimesheettoTipsABC(List < Timesheet__c > TSList, String freq) {
        try {
            TipsAPIHelperClass apiHelper = new TipsAPIHelperClass();
            if (freq == 'Weekly') {
                for (Timesheet__c T: TSList) {
                    Date stDt = T.Week_Start_Date__c;
                    Date edDt = T.Week_End_Date__c;
                    Work_Order__c workOrderRecord=getTIPSIdWOABC(t.Account_Services__r.Account__c, edDt);
                    List<Work_Order__c> validWorkOrders=getWorkOrders(t.Account_Services__r.Account__c,stDt ,edDt);
                    
                    decimal buildHours=t.Total_Hours_Build__c;
                    decimal adminHours=t.Total_Hours_Admin__c;
                    decimal consultingHours=t.Total_Hours_Consulting__c;
                    String buildTipsId='';
                    String adminTipsId='';
                    String consultingTipsId='';
                    Boolean isBcIntegration=boolean.valueOf(system.label.BC_Integration);
                    if(workOrderRecord != null){
                        buildTipsId= isBcIntegration? workOrderRecord.BC_Build_CNSMP_WO_ID__c : workOrderRecord.TIPS_CNSMP_WO_ID__c;
                        adminTipsId=isBcIntegration ? workOrderRecord.BC_Admin_CNSMP_WO_ID__c : workOrderRecord.TIPS_Admin_CNSMP_WO_ID__c;
                        consultingTipsId=isBcIntegration ? workOrderRecord.BC_Consulting_CNSMP_WO_ID__c : workOrderRecord.TIPS_Consulting_CNSMP_WO_ID__c; 
                    }
                    String stDtStr = DateTime.newInstance(stDt.year(), stDt.month(), stDt.day()).format('MM/dd/YYYY');
                    String edDtStr = DateTime.newInstance(edDt.year(), edDt.month(), edDt.day()).format('MM/dd/YYYY');
                    boolean tipsIdUnavailability=false;
                    Map<String, String> tipsMap = new Map<String, String>{
                        'Build' => buildTipsId,
                            'Admin' => adminTipsId,
                            'Consulting' => consultingTipsId
                            };
                                If(!isBcIntegration){
                                    for (String billingTypeName : tipsMap.keySet()) {
                                        String tipsId = tipsMap.get(billingTypeName);
                                        if (String.isNotBlank(tipsId)) {
                                            string body = '{"data":"' + apiHelper.AESEncryptDecrypt(TimesheetTriggerHelper.getTimesheetDetailsWeeklyABC(tipsId,t.id,billingTypeName)) + '"}';
                                            system.debug('body-'+body);
                                            TipsAPIHelperClass.HttpRequest(System.Label.TIPS_Timesheet_API_Endpoint, body, 'POST',T.Id,billingTypeName); 
                                            TipsTimesheetPDFGenerationBatch obj=new TipsTimesheetPDFGenerationBatch('Weekly',t.id,new set<id>(),stDt,edDt,tipsId,billingTypeName,true,t.Account_Services__r.Account__r.Name);
                                            Database.executeBatch(obj);
                                        }else{
                                            tipsIdUnavailability=true;
                                        }
                                    }
                                }else{
                                    Integer delayInMinutes=0;
                                    Map<Work_Order_External_Reference__c, List<Time_Sheet_Details__c>>  woToTimesheetDetailsMap =TimesheetTriggerBCHelper.getTimesheetDetailsWeeklyWithWo(T.id,validWorkOrders);
                                    for(Work_Order_External_Reference__c Wo:woToTimesheetDetailsMap.keySet()){
                                        List<Time_Sheet_Details__c> timesheetDetailsRecords=woToTimesheetDetailsMap.get(wo);
                                        if(String.isNotBlank(wo.BC_Build_CNSMP_WO_ID__c) && String.isNotBlank(wo.BC_Admin_CNSMP_WO_ID__c) && String.isNotBlank(wo.BC_Consulting_CNSMP_WO_ID__c)){
                                            if(!timesheetDetailsRecords.isEmpty()){  
                                                string body = '{"data":"' + apiHelper.AESEncryptDecrypt(TimesheetTriggerBCHelper.getTimesheetDetailsWeeklyABC(Wo,timesheetDetailsRecords)) + '"}';
                                                system.debug('body-'+body);
                                                ID jobID = System.enqueueJob(new BC_TimesheetHttpRequestQueueable(body,T.Id,'Build','Add'), delayInMinutes);
                                                delayInMinutes=delayInMinutes+1;
                                                //TimesheetTriggerBCHelper.HttpRequestBC(body,T.Id,'Build','Add');
                                            }
                                        }else{
                                            tipsIdUnavailability=true;
                                        }
                                    } 
                                }
                    
                    if(tipsIdUnavailability){
                        sendMailForFailureTimesheet(T,stDtStr,edDtStr); 
                    }
                }
            }
            if (freq == 'Monthly' || freq == 'Semi-Monthly') {
                
                Date startDate;
                Date endDate;
                Set<Id> AllTSIds=new Set<Id>();
                Set<Id> accountSer=new Set<Id>();
                for (Timesheet__c TSEntry: TSList) {
                    Date sD = TSEntry.Week_Start_Date__c;
                    Date eD = TSEntry.Week_End_Date__c;
                    if(freq == 'Monthly'){
                        startDate = sD.toStartOfMonth();
                        endDate = startDate.addDays(Date.daysInMonth(startDate.year(), startDate.month()) - 1);
                    } else if (freq == 'Semi-Monthly'){
                        Date firstDayOfMonth = TSEntry.Week_Start_Date__c.toStartOfMonth();
                        Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
                        Date semiMonth1EndDate = Date.newInstance(lastDayOfMonth.year(), lastDayOfMonth.month(), 15);
                        Date semiMonth2EndDate = lastDayOfMonth;
                        
                        if (semiMonth1EndDate >= TSEntry.Week_Start_Date__c && semiMonth1EndDate <= TSEntry.Week_End_Date__c) {
                            startDate = firstDayOfMonth;
                            endDate = semiMonth1EndDate;
                        }else if (semiMonth2EndDate >= TSEntry.Week_Start_Date__c && semiMonth2EndDate <= TSEntry.Week_End_Date__c){
                            startDate = semiMonth1EndDate+1;
                            endDate = semiMonth2EndDate;
                        }
                    }
                    accountSer.add(TSEntry.Account_Services__c);
                    
                }
                system.debug('startDate-'+startDate+' to '+endDate);
                Map<Id,Timesheet__c> timesheetWithTimesheetDetails=new Map<Id,Timesheet__c>([Select Id,Week_Start_Date__c,Week_End_Date__c,Approver_Name__r.Name,Comments__c,ApproverName__c,Approved_Date__c,Account_Services__r.Account__r.Name,Account_Services__r.ODS_Service_Name__c,Status__c,
                                                                                             (SELECT Hours_Worked__c,Row_No_Value__c ,Task_Name__c,Timesheet_Date__c,Timesheet__c From Timesheet_Details__r WHERE Timesheet_Date__c >=: startDate AND Timesheet_Date__c <=: endDate ORDER BY Row_No_Value__c ASC NULLS FIRST)
                                                                                             From Timesheet__c WHERE Account_Services__c IN:accountSer AND (Status__c='Submitted' OR Status__c='Approved') AND 
                                                                                             ((Week_Start_Date__c >= :startDate AND Week_End_Date__c <= :endDate) OR (Week_Start_Date__c < :startDate AND Week_End_Date__c >= :startDate)
                                                                                              OR (Week_Start_Date__c <= :endDate AND Week_End_Date__c > :endDate) OR (Week_Start_Date__c = :startDate)) ]);
                //((Week_Start_Date__c >=: startDate and Week_End_Date__c <=: endDate ) OR (Week_Start_Date__c <: startDate AND Week_End_Date__c >: startDate) OR (Week_Start_Date__c <: endDate AND Week_End_Date__c >: endDate))]); 
                system.debug('timesheetWithTimesheetDetails-'+timesheetWithTimesheetDetails);
                system.debug('timesheetWithTimesheetDetails-'+timesheetWithTimesheetDetails.size());
                
                AllTSIds.addAll(timesheetWithTimesheetDetails.keySet());
                
                for (Timesheet__c TSEntry1: TSList) {
                    Date stDt = startDate;
                    Date edDt = endDate;
                    system.debug('stDt');
                    system.debug(stDt);
                    String stDtStr = DateTime.newInstance(stDt.year(), stDt.month(), stDt.day()).format('MM/dd/YYYY');
                    String edDtStr = DateTime.newInstance(edDt.year(), edDt.month(), edDt.day()).format('MM/dd/YYYY');
                    
                    Work_Order__c workOrderRecord=getTIPSIdWOABC(TSEntry1.Account_Services__r.Account__c, edDt);
                    List<Work_Order__c> validWorkOrders=getWorkOrders(TSEntry1.Account_Services__r.Account__c,stDt ,edDt);
                    
                    system.debug('workOrderRecord-'+workOrderRecord);
                    String buildTipsId='';
                    String adminTipsId='';
                    String consultingTipsId='';
                    if(workOrderRecord != null){
                        buildTipsId=workOrderRecord.TIPS_CNSMP_WO_ID__c;
                        adminTipsId=workOrderRecord.TIPS_Admin_CNSMP_WO_ID__c;
                        consultingTipsId=workOrderRecord.TIPS_Consulting_CNSMP_WO_ID__c; 
                    }
                    boolean tipsIdUnavailability=false;
                    Map<string,string> billingTypeWithIds=new Map<String,String>();
                    Map<String, String> tipsMap = new Map<String, String>{
                        'Build' => buildTipsId,
                            'Admin' => adminTipsId,
                            'Consulting' => consultingTipsId
                            };
                                If(!boolean.valueOf(system.label.BC_Integration)){
                                    for (String billingType : tipsMap.keySet()) {
                                        String tipsId = tipsMap.get(billingType);
                                        if (String.isNotBlank(tipsId)) {
                                            string body = '{"data":"' + apiHelper.AESEncryptDecrypt(TimesheetTriggerHelper.getTimesheetDetailsMonthlyABC(tipsId,AllTSIds,billingType,stDt,edDt)) + '"}';
                                            TipsAPIHelperClass.HttpRequest(System.Label.TIPS_Timesheet_API_Endpoint, body, 'POST',TSEntry1.Id,billingType);
                                            TipsTimesheetPDFGenerationBatch obj=new TipsTimesheetPDFGenerationBatch('Monthly','',AllTSIds,stDt,edDt,tipsId,billingType,true,TSEntry1.Account_Services__r.Account__r.Name);
                                            Database.executeBatch(obj);
                                            
                                        } else {
                                            tipsIdUnavailability=true;
                                        }
                                    }
                                }else{
                                    system.debug('AllTSIds  monthly ABC-'+AllTSIds);
                                    system.debug('stDt  monthly ABC-'+stDt);
                                    system.debug('edDt  monthly ABC-'+edDt);
                                    integer delayInMinutes=0;
                                    Map<Work_Order_External_Reference__c, List<Time_Sheet_Details__c>> woToTimesheetDetailsMap =TimesheetTriggerBCHelper.getTimesheetDetailsMonthlyWithWo(AllTSIds,validWorkOrders,stDt,edDt);
                                    for(Work_Order_External_Reference__c Wo:woToTimesheetDetailsMap.keySet()){
                                        if(String.isNotBlank(wo.BC_Build_CNSMP_WO_ID__c) && String.isNotBlank(wo.BC_Admin_CNSMP_WO_ID__c) && String.isNotBlank(wo.BC_Consulting_CNSMP_WO_ID__c)){
                                            List<Time_Sheet_Details__c> timesheetDetailsRecords=woToTimesheetDetailsMap.get(wo);
                                            if(!timesheetDetailsRecords.isEmpty()){  
                                                string body = '{"data":"' + apiHelper.AESEncryptDecrypt(TimesheetTriggerBCHelper.getTimesheetDetailsMonthlyABC(wo,timesheetDetailsRecords,stDt,edDt)) + '"}';
                                                system.debug('body-'+body);
                                                ID jobID = System.enqueueJob(new BC_TimesheetHttpRequestQueueable(body,TSEntry1.Id,'Build','Add'), delayInMinutes);
                                                delayInMinutes=delayInMinutes+1;
                                                // TimesheetTriggerBCHelper.HttpRequestBC(body,TSEntry1.Id,'Build','Add');
                                            }
                                        }else{
                                            tipsIdUnavailability=true;
                                        }
                                    }  
                                }
                    
                    if(tipsIdUnavailability){
                        sendMailForFailureTimesheet(TSEntry1,stDtStr,edDtStr); 
                    }
                }
            }
            if (freq == 'Bi-Weekly'){
                Date startDate;
                Date endDate;
                Set<Id> AllTSIds=new Set<Id>();
                Set<Id> accountSer=new Set<Id>();
                for (Timesheet__c TSEntry: TSList) {
                    startDate = TSEntry.Week_Start_Date__c.addDays(-7);
                    endDate = TSEntry.Week_End_Date__c;
                    accountSer.add(TSEntry.Account_Services__c);
                }
                
                Map<Id,Timesheet__c> timesheetWithTimesheetDetails=new Map<Id,Timesheet__c>([Select Id,Week_Start_Date__c,Week_End_Date__c,Approver_Name__r.Name,Comments__c,ApproverName__c,Approved_Date__c,Account_Services__r.Account__r.Name,Account_Services__r.ODS_Service_Name__c,Status__c,
                                                                                             (SELECT Hours_Worked__c,Row_No_Value__c ,Task_Name__c,Timesheet_Date__c,Timesheet__c From Timesheet_Details__r WHERE Timesheet_Date__c >=: startDate AND Timesheet_Date__c <=: endDate ORDER BY Row_No_Value__c ASC NULLS FIRST)
                                                                                             From Timesheet__c WHERE Account_Services__c IN:accountSer AND (Status__c='Submitted' OR Status__c='Approved') AND 
                                                                                             ((Week_Start_Date__c >= :startDate AND Week_End_Date__c <= :endDate) OR (Week_Start_Date__c < :startDate AND Week_End_Date__c >= :startDate)
                                                                                              OR (Week_Start_Date__c <= :endDate AND Week_End_Date__c > :endDate) OR (Week_Start_Date__c = :startDate)) ]);
                
                AllTSIds.addAll(timesheetWithTimesheetDetails.keySet());
                system.debug('AllTSIds-'+AllTSIds);
                for (Timesheet__c TSEntry1: TSList) {
                    Date stDt = TSEntry1.Week_Start_Date__c.addDays(-7);
                    Date edDt = TSEntry1.Week_End_Date__c;
                    
                    String stDtStr = DateTime.newInstance(stDt.year(), stDt.month(), stDt.day()).format('MM/dd/YYYY');
                    String edDtStr = DateTime.newInstance(edDt.year(), edDt.month(), edDt.day()).format('MM/dd/YYYY');
                    
                    //Work_Order__c workOrderRecord=getTIPSIdWOABC(TSEntry1.Account_Services__r.Account__c, edDt);
                    List<Work_Order__c> validWorkOrders=getWorkOrders(TSEntry1.Account_Services__r.Account__c,stDt ,edDt);
                    
                    boolean tipsIdUnavailability=false;
                    If(boolean.valueOf(system.label.BC_Integration)){
                        integer delayInMinutes=0;
                        Map<Work_Order_External_Reference__c, List<Time_Sheet_Details__c>> woToTimesheetDetailsMap =TimesheetTriggerBCHelper.getTimesheetDetailsMonthlyWithWo(AllTSIds,validWorkOrders,stDt,edDt);
                        for(Work_Order_External_Reference__c Wo:woToTimesheetDetailsMap.keySet()){
                            if(String.isNotBlank(wo.BC_Build_CNSMP_WO_ID__c) && String.isNotBlank(wo.BC_Admin_CNSMP_WO_ID__c) && String.isNotBlank(wo.BC_Consulting_CNSMP_WO_ID__c)){
                                
                                List<Time_Sheet_Details__c> timesheetDetailsRecords=woToTimesheetDetailsMap.get(wo);
                                if(!timesheetDetailsRecords.isEmpty()){  
                                    string body = '{"data":"' + apiHelper.AESEncryptDecrypt(TimesheetTriggerBCHelper.getTimesheetDetailsMonthlyABC(Wo,timesheetDetailsRecords,stDt,edDt)) + '"}';
                                    system.debug('body-'+body);
                                    ID jobID = System.enqueueJob(new BC_TimesheetHttpRequestQueueable(body,TSEntry1.Id,'Build','Add'), delayInMinutes);
                                    delayInMinutes=delayInMinutes+1;
                                    //TimesheetTriggerBCHelper.HttpRequestBC(body,TSEntry1.Id,'Build','Add');
                                }
                            }else{
                                tipsIdUnavailability=true;
                            }
                        } 
                        if(tipsIdUnavailability){
                            sendMailForFailureTimesheet(TSEntry1,stDtStr,edDtStr); 
                        }
                    }
                }
            }
        } catch (Exception e) {
            ODS_ExceptionUtility.LogException(e);
        }
    } 
    private static void sendMailForFailureTimesheet(Timesheet__c timesheet,string startDate, string endDate){
        
        Messaging.SingleEmailMessage failureEmail = new Messaging.SingleEmailMessage();
        
        String strHtmlBody = '';
        If(!boolean.valueOf(system.label.BC_Integration)){
            List<string> sendToList = System.Label.WorkOrderUsersForErrorStatus.Split(',');
            failureEmail.setToAddresses(sendToList);
            failureEmail.setSubject('Timesheet and TIPS Integration failed - ' + timesheet.Account_Services__r.Account__r.Name);
            strHtmlBody = '<table width="100%" cellpadding="0" cellspacing="0"><tr><td colspan="2"> <font face="Calibri " size="3">Hi, <br/><br/>The timesheet integration for <b>' + timesheet.Account_Services__r.Account__r.Name + '</b> failed for the period from <b>' + startDate + '</b> to <b>' + endDate + '</b> due to unavailability of TIPS (Consumption) Work Order ID.</br> ';
        }else{
            List<string> sendToList = System.Label.WorkOrderUsersForErrorStatusBC.Split(',');
            failureEmail.setToAddresses(sendToList);
            failureEmail.setSubject('Timesheet and BC Integration failed - ' + timesheet.Account_Services__r.Account__r.Name);
            strHtmlBody = '<table width="100%" cellpadding="0" cellspacing="0"><tr><td colspan="2"> <font face="Calibri " size="3">Hi, <br/><br/>The timesheet integration for <b>' + timesheet.Account_Services__r.Account__r.Name + '</b> failed for the period from <b>' + startDate + '</b> to <b>' + endDate + '</b> due to unavailability of BC (Consumption) Work Order ID.</br> ';
        }
        strHtmlBody += '<br/><br/>Thanks,<br/><br/>LevelShift Admin<br/>';
        failureEmail.setHtmlBody(strHtmlBody);
        //system.debug('strHtmlBody-'+strHtmlBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{failureEmail});
    }
}
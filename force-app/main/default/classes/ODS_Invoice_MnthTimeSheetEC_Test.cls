/*
*Author: Mani & Team
*Created: 01/June/2018
*/
@isTest
public class ODS_Invoice_MnthTimeSheetEC_Test 
{    
    static TestMethod void InsertTimeSheetDetail_Test()
    {
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                    'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                    'test123@testmail.com','Technical Account Manager', true,portalRole.Id);                     
        System.runAs (portalAccountOwner1) 
        {
            test.startTest(); 
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                    'California', True,2000,'9433578865', 'Others', 'ODS Project');                             
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
            contact1.Email = 'test@test.com';
            update contact1;
            portalAccount1.ODS_Invoice_Account_Number__c = 'C45';
            portalAccount1.Invoice_Type__c = 'Paper';
            portalAccount1.Primary_Customer_Contact__c = contact1.Id;
            portalAccount1.InvoiceContact__c = contact1.Id;
            portalAccount1.BillingCity = 'Chennai';
            portalAccount1.BillingStreet = 'Siruseri';
            portalAccount1.BillingState = 'Tamilnadu';            
            portalAccount1.BillingCountry = 'India';
            portalAccount1.BillingPostalcode = '640000';
            portalAccount1.ODS_Invoice_Count__c = 10;
            update portalAccount1;            
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('Salesforce','test',true);
            
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);

            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);

            string strPrjtTeaMbId = string.valueOf(ObjTeamMembr.Id);
            date strtDt =  System.Today().addYears(-1);
            date endDt = System.Today().addYears(2);
            Date Startdte = System.Today().addYears(-1);
            Date Enddte = System.Today().addYears(2);
            Date thisMonthStart = System.Today().toStartOfMonth();
            Integer thisMonthDays = Date.daysInMonth(System.Today().year(),System.Today().month());
            Date thisMonthEnd = Date.newInstance(System.Today().year(),System.Today().month(),thisMonthDays);
            
            Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(portalAccount1.id,strtDt, endDt,
                             150.0, odsSrv.id, 1000, 'Monthly', portalAccountOwner1.Id, 'Salesforce');
            accSrvc.Invoice_Frequency__c = 'Monthly';
            accSrvc.Contract_Term__c = 'Net 30';
            accSrvc.Purchase_Order__c = 'test';
            update accSrvc;
            
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            
            Estimate__c estimate = new Estimate__c();
            estimate.Hours__c = 50;
            estimate.Initiative_Lookup__c = initiative.Id;
            estimate.Phase__c = 'Analysis';
            estimate.Task_Components__c = 'Test';
            insert estimate;  
            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,thisMonthStart,thisMonthEnd,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            
            Date startOfWeek1 = thisMonthStart.toStartOfWeek();
            Date endOfWeek1 = startOfWeek1.addDays(7);
            Timesheet__c insertTimeSheetWeek1 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName1',objTmeShtCst.Id,startOfWeek1,endOfWeek1);
            insertTimeSheetWeek1.Status__c = 'Submitted';
            insertTimeSheetWeek1.Account_Services__c = accSrvc.Id;
            update insertTimeSheetWeek1;
            Date startOfWeek2 = endOfWeek1.addDays(1);
            Date endOfWeek2 = startOfWeek2.addDays(7);
            Timesheet__c insertTimeSheetWeek2 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName2',objTmeShtCst.Id,startOfWeek2,endOfWeek2);
            insertTimeSheetWeek2.Status__c = 'Submitted';
            insertTimeSheetWeek2.Account_Services__c = accSrvc.Id;
            update insertTimeSheetWeek2;
            Date startOfWeek3 = endOfWeek2.addDays(1);
            Date endOfWeek3 = startOfWeek3.addDays(7);
            Timesheet__c insertTimeSheetWeek3 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName3',objTmeShtCst.Id,startOfWeek3,endOfWeek3);
            insertTimeSheetWeek3.Status__c = 'Submitted';
            insertTimeSheetWeek3.Account_Services__c = accSrvc.Id;
            update insertTimeSheetWeek3;
            Date startOfWeek4 = endOfWeek3.addDays(1);
            Date endOfWeek4 = startOfWeek4.addDays(7);
            Timesheet__c insertTimeSheetWeek4 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName4',objTmeShtCst.Id,startOfWeek4,endOfWeek4);
            insertTimeSheetWeek4.Status__c = 'Submitted';
            insertTimeSheetWeek4.Account_Services__c = accSrvc.Id;
            update insertTimeSheetWeek4;
            Date startOfWeek5 = endOfWeek4.addDays(1);
            Date endOfWeek5 = startOfWeek5.addDays(7);
            Timesheet__c insertTimeSheetWeek5 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName5',objTmeShtCst.Id,startOfWeek5,endOfWeek5);
            insertTimeSheetWeek5.Status__c = 'Submitted';
            insertTimeSheetWeek5.Account_Services__c = accSrvc.Id;
            update insertTimeSheetWeek5;
            
            String timeSheetIds = String.valueOf(insertTimeSheetWeek1.Id+'-'+
                                insertTimeSheetWeek2.Id+'-'+
                                insertTimeSheetWeek3.Id+'-'+
                                insertTimeSheetWeek4.Id+'-'+
                                insertTimeSheetWeek5.Id+'-');
            
            List<Time_Sheet_Details__c> objTmeShtDtlList1 = new List<Time_Sheet_Details__c>();
            
            Date tdsStart1 = startOfWeek1.addDays(-1);
            for(Integer i=0; i<6; i++) {
                Time_Sheet_Details__c objTmeShtDtl = new Time_Sheet_Details__c();
                objTmeShtDtl.Hours_Worked__c = 2;
                objTmeShtDtl.Resource_Id__c = ObjTeamMembr.Id;
                objTmeShtDtl.Resource__c = ObjTeamMembr.Resource_Name__c  ;
                objTmeShtDtl.Timesheet__c = insertTimeSheetWeek1.Id;
                objTmeShtDtl.Timesheet_Date__c = tdsStart1.addDays(1);        
                objTmeShtDtlList1.add(objTmeShtDtl);
            }
            Date tdsStart2 = startOfWeek2.addDays(-1);
            for(Integer i=0; i<6; i++) {
                Time_Sheet_Details__c objTmeShtDtl = new Time_Sheet_Details__c();
                objTmeShtDtl.Hours_Worked__c = 2;
                objTmeShtDtl.Resource_Id__c = ObjTeamMembr.Id;
                objTmeShtDtl.Resource__c = ObjTeamMembr.Resource_Name__c  ;
                objTmeShtDtl.Timesheet__c = insertTimeSheetWeek2.Id;
                objTmeShtDtl.Timesheet_Date__c = tdsStart2.addDays(1);        
                objTmeShtDtlList1.add(objTmeShtDtl);
            }
            Date tdsStart3 = startOfWeek3.addDays(-1);
            for(Integer i=0; i<6; i++) {
                Time_Sheet_Details__c objTmeShtDtl = new Time_Sheet_Details__c();
                objTmeShtDtl.Hours_Worked__c = 2;
                objTmeShtDtl.Resource_Id__c = ObjTeamMembr.Id;
                objTmeShtDtl.Resource__c = ObjTeamMembr.Resource_Name__c  ;
                objTmeShtDtl.Timesheet__c = insertTimeSheetWeek3.Id;
                objTmeShtDtl.Timesheet_Date__c = tdsStart3.addDays(1);        
                objTmeShtDtlList1.add(objTmeShtDtl);
            }
            Date tdsStart4 = startOfWeek4.addDays(-1);
            for(Integer i=0; i<6; i++) {
                Time_Sheet_Details__c objTmeShtDtl = new Time_Sheet_Details__c();
                objTmeShtDtl.Hours_Worked__c = 2;
                objTmeShtDtl.Resource_Id__c = ObjTeamMembr.Id;
                objTmeShtDtl.Resource__c = ObjTeamMembr.Resource_Name__c  ;
                objTmeShtDtl.Timesheet__c = insertTimeSheetWeek4.Id;
                objTmeShtDtl.Timesheet_Date__c = tdsStart4.addDays(1);        
                objTmeShtDtlList1.add(objTmeShtDtl);
            }
            Date tdsStart5 = startOfWeek5.addDays(-1);
            for(Integer i=0; i<6; i++) {
                Time_Sheet_Details__c objTmeShtDtl = new Time_Sheet_Details__c();
                objTmeShtDtl.Hours_Worked__c = 2;
                objTmeShtDtl.Resource_Id__c = ObjTeamMembr.Id;
                objTmeShtDtl.Resource__c = ObjTeamMembr.Resource_Name__c  ;
                objTmeShtDtl.Timesheet__c = insertTimeSheetWeek5.Id;
                objTmeShtDtl.Timesheet_Date__c = tdsStart5.addDays(1);        
                objTmeShtDtlList1.add(objTmeShtDtl);
            }
            insert objTmeShtDtlList1;
            
            /*ODS_Invoice_EmailControl__c cst = new ODS_Invoice_EmailControl__c();
            cst.name = 'ccPracticeHead';
            cst.isAllowed__c = false;
            insert cst;*/
            Integer mNumb = System.Today().month();
            String mName = '';
            if(mNumb==1)mName='January';else if(mNumb==2)mName='February';
            else if(mNumb==3)mName='March';else if(mNumb==4)mName='April';
            else if(mNumb==5)mName='May';else if(mNumb==6)mName='June';
            else if(mNumb==7)mName='July';else if(mNumb==8)mName='August';
            else if(mNumb==9)mName='September';else if(mNumb==10)mName='October';
            else if(mNumb==11)mName='November';else mName='December';
            ODS_Invoice_Month__c invm = new ODS_Invoice_Month__c();
            invm.name=String.valueOf(System.Today().month());
            invm.MonthName__c=mName; 
            insert invm;
               
            ApexPages.currentPage().getParameters().put('term','Net 30');
            ApexPages.currentPage().getParameters().put('billToStr','Siruseri');
            ApexPages.currentPage().getParameters().put('billToCty','Chennai');
            ApexPages.currentPage().getParameters().put('billToStat','Tamilnadu');
            ApexPages.currentPage().getParameters().put('billToCtry','India');
            ApexPages.currentPage().getParameters().put('billToPcod','641113');                        
            ApexPages.currentPage().getParameters().put('invNumb','20180601CC');
            ApexPages.currentPage().getParameters().put('accNumb','EC45');
            ApexPages.currentPage().getParameters().put('billPerd',String.valueOf(thisMonthStart+' - '+thisMonthEnd));      
            ApexPages.currentPage().getParameters().put('AccServId',accSrvc.Id);
            ApexPages.currentPage().getParameters().put('timShtId',timeSheetIds);
            ApexPages.currentPage().getParameters().put('hrlyRate',String.valueOf(90));
            ApexPages.currentPage().getParameters().put('discFee',String.valueOf(10));
            ApexPages.currentPage().getParameters().put('startDt',String.valueOf(thisMonthStart));
            ApexPages.currentPage().getParameters().put('endDt',String.valueOf(thisMonthEnd));
            ApexPages.currentPage().getParameters().put('ref',String.valueOf(accSrvc.Purchase_Order__c));
            ApexPages.currentPage().getParameters().put('proj',String.valueOf(accSrvc.ODS_Service_Name__c));
                        
            ODS_Invoice_MnthTimeSheetEC ec = new ODS_Invoice_MnthTimeSheetEC();            
            test.stoptest();
            }
        }            
}
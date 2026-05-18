/*
--Author: Mani and Team
--Purpose: Unit test for ODS_PartnerController_Test
--Created on: 28/Jun/2018
*/
@isTest
public class ODS_PartnerController_Test
{
    static TestMethod void partner_Test()
    {
        /*Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccountWithOwner('TestAccount',
                            UserInfo.getUserId(), True,3000,'9678554553', 'Others', 'ODS Project');*/
        Account portalAccount1 = new Account();
        portalAccount1.Name = 'TestAccount';
        portalAccount1.OwnerID = UserInfo.getUserId();
        portalAccount1.Is_Portal_Access__c = true;
        portalAccount1.AnnualRevenue = 3000000;
        portalAccount1.Phone = '9678554553';
        portalAccount1.Lead_Gen_Name__c = 'Others';
        portalAccount1.If_Others_Please_Specify__c = 'ODS Project';
        portalAccount1.NumberofEmployees = 100;
        portalAccount1.Industry = 'Technology';
        portalAccount1.isPartner__c = true;
        portalAccount1.Partner_Commission__c = 10;
        insert portalAccount1;
                                         
        Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');
        
        Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
        User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                        'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                        'test12345@test.com', contact1.Id,'Partner');
         
        //fetch system admin profile
        Profile SAProfile = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        
        //Insert user
        User usrObj1 = ODS_DataFactory_Test_Utility.InsertUserWithPortalRole('batman','testuser@testmail.com','UTF-8','TestLastName',
                    'en_US','en_US',SAProfile.Id,'America/Chicago',System.now().millisecond() + 
                    'test123@testmail.com','Practice Head', true); 
        
        Account odsAcc1 = new Account();
        odsAcc1.Name = 'TestOdsAccount';
        odsAcc1.OwnerID = usrObj1.Id;
        odsAcc1.Is_Portal_Access__c = true;
        odsAcc1.AnnualRevenue = 3000000;
        odsAcc1.Phone = '9678554553';
        odsAcc1.Lead_Gen_Name__c = 'Others';
        odsAcc1.If_Others_Please_Specify__c = 'ODS Project';
        odsAcc1.NumberofEmployees = 100;
        odsAcc1.Industry = 'Technology';
        odsAcc1.Channel_Partner__c = portalAccount1.Id;
        odsAcc1.Channel_Partner_Contact__c = contact1.Id;
        insert odsAcc1;
        
        Contact odsCont1 = ODS_DataFactory_Test_Utility.InsertContact('TestOds','McTesty1', True, odsAcc1.Id, 'Others', 'ODS Project');
        
        ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNet','test',true);
        
        Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',odsAcc1.Id,odsSrv.Id);
        
        User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(odsAcc1.id,'Technical Account Manager',
                                                    usrObj1.Id,odsSrv.Id);
        
        //Custom settings for invoice related stories
        ODS_Invoice_EmailControl__c cst = new ODS_Invoice_EmailControl__c();
        cst.name = 'sendInvoiceEmail';
        cst.isAllowed__c = true;
        insert cst;
        
        ODS_Invoice_EmailControl__c cst1 = new ODS_Invoice_EmailControl__c();
        cst1.name = 'ccPracticeHead';
        cst1.isAllowed__c = false;
        insert cst1;
        
        string strPrjtTeaMbId = string.valueOf(ObjTeamMembr.Id);
        date strtDt =  System.Today().addYears(-1);
        date endDt = System.Today().addYears(2);
        Date Startdte = System.Today().addYears(-1);
        Date Enddte = System.Today().addYears(2);
        Date thisMonthStart = System.Today().toStartOfMonth();
        Integer thisMonthDays = Date.daysInMonth(System.Today().year(),System.Today().month());
        Date thisMonthEnd = Date.newInstance(System.Today().year(),System.Today().month(),thisMonthDays);
        
        Account_Services__c accSrvc = ODS_DataFactory_Test_Utility.insertAccountServices(odsAcc1.id,strtDt, endDt,
                         150.0, odsSrv.id, 100000000, 'Monthly', usrObj1.Id, 'Salesforce');
        accSrvc.Invoice_Frequency__c = 'Monthly';
        accSrvc.Contract_Term__c = 'Net 30';
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
        
        List<Time_Sheet_Details__c> objTmeShtDtlList1 = new List<Time_Sheet_Details__c>();
        List<Time_Sheet_Details__c> objTmeShtDtlList2 = new List<Time_Sheet_Details__c>();
        List<Time_Sheet_Details__c> objTmeShtDtlList3 = new List<Time_Sheet_Details__c>();
        List<Time_Sheet_Details__c> objTmeShtDtlList4 = new List<Time_Sheet_Details__c>();
        List<Time_Sheet_Details__c> objTmeShtDtlList5 = new List<Time_Sheet_Details__c>();
        
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
            objTmeShtDtlList2.add(objTmeShtDtl);
        }
        Date tdsStart3 = startOfWeek3.addDays(-1);
        for(Integer i=0; i<6; i++) {
            Time_Sheet_Details__c objTmeShtDtl = new Time_Sheet_Details__c();
            objTmeShtDtl.Hours_Worked__c = 2;
            objTmeShtDtl.Resource_Id__c = ObjTeamMembr.Id;
            objTmeShtDtl.Resource__c = ObjTeamMembr.Resource_Name__c  ;
            objTmeShtDtl.Timesheet__c = insertTimeSheetWeek3.Id;
            objTmeShtDtl.Timesheet_Date__c = tdsStart3.addDays(1);        
            objTmeShtDtlList3.add(objTmeShtDtl);
        }
        Date tdsStart4 = startOfWeek4.addDays(-1);
        for(Integer i=0; i<6; i++) {
            Time_Sheet_Details__c objTmeShtDtl = new Time_Sheet_Details__c();
            objTmeShtDtl.Hours_Worked__c = 2;
            objTmeShtDtl.Resource_Id__c = ObjTeamMembr.Id;
            objTmeShtDtl.Resource__c = ObjTeamMembr.Resource_Name__c  ;
            objTmeShtDtl.Timesheet__c = insertTimeSheetWeek4.Id;
            objTmeShtDtl.Timesheet_Date__c = tdsStart4.addDays(1);        
            objTmeShtDtlList4.add(objTmeShtDtl);
        }
        Date tdsStart5 = startOfWeek5.addDays(-1);
        for(Integer i=0; i<6; i++) {
            Time_Sheet_Details__c objTmeShtDtl = new Time_Sheet_Details__c();
            objTmeShtDtl.Hours_Worked__c = 2;
            objTmeShtDtl.Resource_Id__c = ObjTeamMembr.Id;
            objTmeShtDtl.Resource__c = ObjTeamMembr.Resource_Name__c  ;
            objTmeShtDtl.Timesheet__c = insertTimeSheetWeek5.Id;
            objTmeShtDtl.Timesheet_Date__c = tdsStart5.addDays(1);        
            objTmeShtDtlList5.add(objTmeShtDtl);
        }
        insert objTmeShtDtlList1; insert objTmeShtDtlList2; insert objTmeShtDtlList3; insert objTmeShtDtlList4; insert objTmeShtDtlList5;
                
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
                                                                    
        System.runAs (user1) 
        {                 
            test.startTest();
            PageReference pageRef = Page.Partner;
            Test.setCurrentPage(pageRef);
            ODS_PartnerController objPart =  new ODS_PartnerController();
            objPart.AccountId = 'All';
            objPart.ServiceId = 'All';
            objPart.slctdYear = '2018';
            objPart.slctdMonth = '6';
            objPart.slctdRevType = 'subscription';
            objPart.getYears();
            objPart.getMonths();
            objPart.getRevType();
            objPart.GetDashboardByAccountServiceID();
            
            PageReference pageRef1 = Page.Partner;
            Test.setCurrentPage(pageRef1);
            ODS_PartnerController objPart1 =  new ODS_PartnerController();
            objPart1.AccountId = odsAcc1.Id;
            objPart1.ServiceId = odsSrv.Id;
            objPart1.slctdYear = '2018';
            objPart1.slctdMonth = '6';
            objPart1.slctdRevType = 'subscription';
            objPart1.getYears();
            objPart1.getMonths();
            objPart1.getRevType();
            objPart1.GetDashboardByAccountServiceID();                                              
            
            PageReference pageRef2 = Page.Partner;
            Test.setCurrentPage(pageRef2);
            ODS_PartnerController objPart2 =  new ODS_PartnerController();
            objPart2.AccountId = odsAcc1.Id;
            objPart2.ServiceId = 'All';
            objPart2.slctdYear = '2018';
            objPart2.slctdMonth = '6';
            objPart2.slctdRevType = 'subscription';
            objPart2.getYears();
            objPart2.getMonths();
            objPart2.getRevType();
            objPart2.GetDashboardByAccountServiceID();                                              
            
            PageReference pageRef3 = Page.Partner;
            Test.setCurrentPage(pageRef3);
            ODS_PartnerController objPart3 =  new ODS_PartnerController();
            objPart3.AccountId = 'All';
            objPart3.ServiceId = odsSrv.Id;
            objPart3.slctdYear = '2018';
            objPart3.slctdMonth = '6';
            objPart3.slctdRevType = 'subscription';
            objPart3.getYears();
            objPart3.getMonths();
            objPart3.getRevType();
            objPart3.GetDashboardByAccountServiceID();                                              
            test.stopTest();
        }        
    }
}
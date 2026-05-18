@isTest
public class ODS_Data_Utility_Test
{
    static testMethod void checkAllReturnVals1() {            
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);
        
        system.runAs(portalAccountOwner1) {
            ODS_Data_Utility odsUtil = new ODS_Data_Utility(null);
            
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                                'California', True,2000,'9433578865', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');                      
            contact1.Is_Approver__c = True;
            update contact1;
            
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNetTest1','test',true);                        
            
            Contact_Account_Service__c cas = new Contact_Account_Service__c();
            cas.Account__c = portalAccount1.Id;
            cas.Contact__c = contact1.Id;
            cas.Is_Approver__c = true;
            cas.ODS_Service__c = odsSrv.Id;
            cas.Type_of_Engagement__c = 'ODS';
            insert cas; 
            
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            usrAcc.Role_in_Account__c = 'Account Partner';            
            update usrAcc;
            
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
            update accSrvc;
            
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            
            Estimate__c estimate = new Estimate__c();
            estimate.Hours__c = 50;
            estimate.Initiative_Lookup__c = initiative.Id;
            estimate.Phase__c = 'Analysis';
            estimate.Task_Components__c = 'Test';
            insert estimate;  
            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,thisMonthStart,thisMonthEnd,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            objTmeShtCst.Regular_Hours_New__c = 50;
            objTmeShtCst.Cost_Per_Hour__c = 100;
            update objTmeShtCst;
            
            List<Timesheet__c> timesheetsNew = new List<Timesheet__c>();
            
            Date startOfWeek1 = thisMonthStart.toStartOfWeek();
            Date endOfWeek1 = startOfWeek1.addDays(7);
            Timesheet__c insertTimeSheetWeek1 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName1',objTmeShtCst.Id,startOfWeek1,endOfWeek1);
            insertTimeSheetWeek1.Status__c = 'Submitted';
            insertTimeSheetWeek1.Account_Services__c = accSrvc.Id;
            timesheetsNew.add(insertTimeSheetWeek1);
            Date startOfWeek2 = endOfWeek1.addDays(1);
            Date endOfWeek2 = startOfWeek2.addDays(7);
            Timesheet__c insertTimeSheetWeek2 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName2',objTmeShtCst.Id,startOfWeek2,endOfWeek2);
            insertTimeSheetWeek2.Status__c = 'Submitted';
            insertTimeSheetWeek2.Account_Services__c = accSrvc.Id;
            timesheetsNew.add(insertTimeSheetWeek2);
            Date startOfWeek3 = endOfWeek2.addDays(1);
            Date endOfWeek3 = startOfWeek3.addDays(7);
            Timesheet__c insertTimeSheetWeek3 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName3',objTmeShtCst.Id,startOfWeek3,endOfWeek3);
            insertTimeSheetWeek3.Status__c = 'Submitted';
            insertTimeSheetWeek3.Account_Services__c = accSrvc.Id;
            timesheetsNew.add(insertTimeSheetWeek3);
            Date startOfWeek4 = endOfWeek3.addDays(1);
            Date endOfWeek4 = startOfWeek4.addDays(7);
            Timesheet__c insertTimeSheetWeek4 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName4',objTmeShtCst.Id,startOfWeek4,endOfWeek4);
            insertTimeSheetWeek4.Status__c = 'Submitted';
            insertTimeSheetWeek4.Account_Services__c = accSrvc.Id;
            timesheetsNew.add(insertTimeSheetWeek4);
            Date startOfWeek5 = endOfWeek4.addDays(1);
            Date endOfWeek5 = startOfWeek5.addDays(7);
            Timesheet__c insertTimeSheetWeek5 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName5',objTmeShtCst.Id,startOfWeek5,endOfWeek5);
            insertTimeSheetWeek5.Status__c = 'Submitted';
            insertTimeSheetWeek5.Account_Services__c = accSrvc.Id;
            timesheetsNew.add(insertTimeSheetWeek5);
            
            update timesheetsNew;
            
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
            
            insert objTmeShtDtlList1;                                                     
            test.startTest();                 
            User currUsr = ODS_Data_Utility.getLoggedUserdetail();
            
            List<User> userName = ODS_Data_Utility.getPortalAccessByUserName(UserInfo.getUserId());     
            
            User usrContId = ODS_Data_Utility.getuser(contact1.Id);
            
            User usr1 = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());
            
            List<Contact_Account_Service__c> cas1 = ODS_Data_Utility.fetchContactAccountService(contact1.Id,odsSrv.Id);
            
            List<Contact_Account_Service__c> cas2 = ODS_Data_Utility.fetchInitiativeContactAccountService(contact1.Id,odsSrv.Id);
            
            List<Contact_Account_Service__c> cas3 = ODS_Data_Utility.getContactAccountService(portalAccount1.Id,odsSrv.Id);
            
            List<Account_Services__c > acs1 = ODS_Data_Utility.fetchAccServcesByAcc(portalAccount1.Id);
            
            List<Account_Services__c > acs2 = ODS_Data_Utility.fetchAccServcesByAccAndSrv(portalAccount1.Id,odsSrv.Id);
            
            Account_Services__c acs3 = ODS_Data_Utility.getAccServcesByAccAndSrv(portalAccount1.Id,odsSrv.Id);
            
            List<Contact_Account_Service__c > cas4 = ODS_Data_Utility.FetchAccSerByCont(portalAccount1.Id);
            
            List<Account_Services__c > acs4 = ODS_Data_Utility.fetchAccServcesByServiceAccount(portalAccount1.Id,odsSrv.Id);
            
            List<Account_Services__c > acs5 = ODS_Data_Utility.fetchRelatedAccountService(accSrvc.Id);
            
            List<ODS_Services__c> odsserv1 = ODS_Data_Utility.fetchAccServces();
            
            List<Account> acc1 = ODS_Data_Utility.GetAllAccounts();
            
            List<ODS_Services__c> odsserv2 = ODS_Data_Utility.GetAllServices();
            
            List<Contact_Account_Service__c> cas5 = ODS_Data_Utility.GetCustomerAccService(portalAccount1.Id,contact1.Id);           
            
            List<Account> acc2 = ODS_Data_Utility.GetAccountNameById(portalAccount1.Id);
            
            List<ODS_Services__c> odsserv3 = ODS_Data_Utility.GetServiceNameById(odsSrv.Id);
            
            List<Contact> con1 = ODS_Data_Utility.GetApproverName(portalAccount1.Id);
            
            List<Contact_Account_Service__c> cas6 = ODS_Data_Utility.GetAccServiceApproverName(portalAccount1.Id,odsSrv.Id);           
            
            List<Contact> con2 = ODS_Data_Utility.FetchAccountIdByCustomer(contact1.Id);           
            
            List<Contact_Account_Service__c> cas7 = ODS_Data_Utility.FetchAccServicebyCustomer(portalAccount1.Id,odsSrv.Id);           
            
            List<Time_Sheet_Details__c> tsd1 = ODS_Data_Utility.FetchExistingTimesheetDetail(insertTimeSheetWeek1.Id);
            
            List<Time_Sheet_Details__c> tsd2 = ODS_Data_Utility.FetchExistingTimesheetDetailsforInsert(insertTimeSheetWeek1.Id);
            
            Status_Report__c sr1 = ODS_Data_Utility.insertStatusReport(system.today(),'one','two','nothing','Completed',accSrvc.Id,'Daily');
            
            Account_Services__c acs6 = ODS_Data_Utility.fetchAccServcesByAccntAndSrvce(portalAccount1.Id,odsSrv.Id);
            
            List<Time_Sheet_Details__c> tsd3 = ODS_Data_Utility.FetchTimesheetDetailsbyId(insertTimeSheetWeek1.Id);
            
            List<Estimate__c> est1 = ODS_Data_Utility.FetchInitiativeDetailsbyId(initiative.Id);
            
            List<Estimate__c> est2 = ODS_Data_Utility.FetchCustomerInitiativeDetails(initiative.Id);
            
            List<Time_Sheet_Details__c> tsd4 = ODS_Data_Utility.FetchCustomerTimesheetDetails(insertTimeSheetWeek1.Id);
            
            List<Account_Services__c> acs7 = ODS_Data_Utility.fetchTAMBySlctdId(portalAccount1.Id,odsSrv.Id);
            
            User_Account__c ua1 = ODS_Data_Utility.fetchAMBySlctdId(portalAccount1.Id);
            
            User usr2 = ODS_Data_Utility.fetchUserDetailsById(UserInfo.getUserId());
            
            Account acc3 = ODS_Data_Utility.fetchAccountDetailsById(portalAccount1.Id);
            
            List<Contact> con3 = ODS_Data_Utility.fetchContactDetailsById(portalAccount1.Id);
            
            Account_Services__c acs8 = ODS_Data_Utility.fetchServiceDetailsById(portalAccount1.Id,odsSrv.Id);
            
            List<TimeSheet__c> ts1 = ODS_Data_Utility.FetchTimesheetRecById(insertTimeSheetWeek1.Id);
            
            TimeSheet__c ts2 = ODS_Data_Utility.FetchTimesheetById(insertTimeSheetWeek1.Id);
            
            Initiatives__c init1 = ODS_Data_Utility.FetchInitiativeByID(initiative.Id);
            
            Initiatives__c init2 = ODS_Data_Utility.FetchExportInitiativeByID(initiative.Id);
            
            List<Timesheet__c> ts3 = ODS_Data_Utility.FetchTimesheetByDate(accSrvc.Id,startOfWeek1,endOfWeek1);
            
            Status_Report__c sr2 = ODS_Data_Utility.fetchStatusReportbyID(sr1.Id);
            
            Contact con4 = ODS_Data_Utility.getAccountByContactId(contact1.Id);
            
            Set<Id> sAcc = new Set<Id>();
            sAcc.add(portalAccount1.Id);
            List<User_Account__c> ua3 = ODS_Data_Utility.fetchUserAccountByAcntId(sAcc);
            
            List<Account_Services__c> acs9 = ODS_Data_Utility.fetchAccountServicesById(sAcc);
            
            AggregateResult[] tsd5 = ODS_Data_Utility.getTimesheetDetailsByMonthYear('All','All');
            AggregateResult[] tsd6 = ODS_Data_Utility.getTimesheetDetailsByMonthYear('All',odsSrv.Id);
            AggregateResult[] tsd7 = ODS_Data_Utility.getTimesheetDetailsByMonthYear(portalAccount1.Id,'All');
            AggregateResult[] tsd8 = ODS_Data_Utility.getTimesheetDetailsByMonthYear(portalAccount1.Id,odsSrv.Id);
            
            ClientQueries__c cq1 = ODS_Data_Utility.insertClientQueries(accSrvc.Id,'TestQuery',System.today(),portalAccountOwner1.Id,'test@test.com','client@test.com','clientname',portalAccount1.Id,odsSrv.Id);
            
            List<Decimal> dec1 = ODS_Data_Utility.fetchCurrentAllMthCost(portalAccount1.Id,odsSrv.Id,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            
            List<Time_Sheet_Cost__c> tmc1 = ODS_Data_Utility.fetchCurrentMthCost(portalAccount1.Id,odsSrv.Id,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            
            List<Decimal> dec2 = ODS_Data_Utility.fetchCurrentAllMthCostAccounts(portalAccount1.Id,odsSrv.Id,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            
            List<Decimal> dec3 = ODS_Data_Utility.fetchCurrentAllMthCostServices(portalAccount1.Id,odsSrv.Id,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            
            //Organization org1 = ODS_Data_Utility.fetchFiscalYrStartingMonth(UserInfo.getUserId());
            
            List<Decimal> dec4 = ODS_Data_Utility.fetchCurrentAllYearCost(portalAccount1.Id,odsSrv.Id,thisMonthStart,thisMonthEnd);
            
            List<Decimal> dec5 = ODS_Data_Utility.fetchCurrentAllYearCostAccounts(portalAccount1.Id,odsSrv.Id,thisMonthStart,thisMonthEnd);
            
            List<Decimal> dec6 = ODS_Data_Utility.fetchCurrentAllYearCostAccounts(portalAccount1.Id,odsSrv.Id,thisMonthStart,thisMonthEnd);
            
            List<Time_Sheet_Cost__c> tsc2 = ODS_Data_Utility.fetchCurrentYearCost(portalAccount1.Id,odsSrv.Id,thisMonthStart,thisMonthEnd);
            
            test.stopTest();
        }
    }
    
    static testMethod void checkAllReturnVals1_1() {            
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);
        
        system.runAs(portalAccountOwner1) {
            ODS_Data_Utility odsUtil = new ODS_Data_Utility(null);
            
            test.startTest();
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
	        insert camp;
            
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                                'California', True,2000,'9433578865', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');                      
            contact1.Is_Approver__c = True;
            update contact1;
            
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNetTest1','test',true);                        
            
            Contact_Account_Service__c cas = new Contact_Account_Service__c();
            cas.Account__c = portalAccount1.Id;
            cas.Contact__c = contact1.Id;
            cas.Is_Approver__c = true;
            cas.ODS_Service__c = odsSrv.Id;
            cas.Type_of_Engagement__c = 'ODS';
            insert cas; 
            
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            usrAcc.Role_in_Account__c = 'Account Partner';            
            update usrAcc;
            
            string strPrjtTeaMbId = string.valueOf(ObjTeamMembr.Id);
            date strtDt =  System.Today().addYears(-1);
            date endDt = System.Today().addYears(2);
            Date Startdte = System.Today().addYears(-1);
            Date Enddte = System.Today().addYears(2);
            Date thisMonthStart = System.Today().toStartOfMonth();
            Integer thisMonthDays = Date.daysInMonth(System.Today().year(),System.Today().month());
            Date thisMonthEnd = Date.newInstance(System.Today().year(),System.Today().month(),thisMonthDays);
            
            List<Decimal> dec7 = ODS_Data_Utility.fetchOdsALLTmeSht(portalAccount1.Id,odsSrv.Id,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            
            List<Decimal> dec8 = ODS_Data_Utility.fetchOdsALLTmeShtAccounts(portalAccount1.Id,odsSrv.Id,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            
            List<Decimal> dec9 = ODS_Data_Utility.fetchOdsALLTmeShtServices(portalAccount1.Id,odsSrv.Id,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            
            List<Decimal> dec10 = ODS_Data_Utility.fetchOdsALLYearTmeShtAccounts(portalAccount1.Id,odsSrv.Id,thisMonthStart,thisMonthEnd);
            
            List<Decimal> dec11 = ODS_Data_Utility.fetchOdsALLYearTmeShtServices(portalAccount1.Id,odsSrv.Id,thisMonthStart,thisMonthEnd);
            
            test.stopTest();
        }
    }    
    
    static testMethod void checkAllReturnVals1_2() {            
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);
        
        system.runAs(portalAccountOwner1) {
            ODS_Data_Utility odsUtil = new ODS_Data_Utility(null);
            
            test.startTest();
            
            UserRole userRole1 = ODS_Data_Utility.fetchUserRoleName(portalRole.Id);
            Organization orgInfo = ODS_Data_Utility.fetchFiscalYrStartingMonth(Userinfo.getOrganizationId());
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
    
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                                'California', True,2000,'9433578865', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');                      
            contact1.Is_Approver__c = True;
            update contact1;
            
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNetTest1','test',true);                        
            
            Contact_Account_Service__c cas = new Contact_Account_Service__c();
            cas.Account__c = portalAccount1.Id;
            cas.Contact__c = contact1.Id;
            cas.Is_Approver__c = true;
            cas.ODS_Service__c = odsSrv.Id;
            cas.Type_of_Engagement__c = 'ODS';
            insert cas; 
            
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            usrAcc.Role_in_Account__c = 'Account Partner';            
            update usrAcc;
            
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
            update accSrvc;
            
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            
            Estimate__c estimate = new Estimate__c();
            estimate.Hours__c = 50;
            estimate.Initiative_Lookup__c = initiative.Id;
            estimate.Phase__c = 'Analysis';
            estimate.Task_Components__c = 'Test';
            insert estimate;  
            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,thisMonthStart,thisMonthEnd,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            objTmeShtCst.Regular_Hours_New__c = 50;
            objTmeShtCst.Cost_Per_Hour__c = 100;
            update objTmeShtCst;
            
            List<Timesheet__c> timesheetsNew = new List<Timesheet__c>();
            
            Date startOfWeek1 = thisMonthStart.toStartOfWeek();
            Date endOfWeek1 = startOfWeek1.addDays(7);
            Timesheet__c insertTimeSheetWeek1 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName1',objTmeShtCst.Id,startOfWeek1,endOfWeek1);
            insertTimeSheetWeek1.Status__c = 'Submitted';
            insertTimeSheetWeek1.Account_Services__c = accSrvc.Id;
            timesheetsNew.add(insertTimeSheetWeek1);
            Date startOfWeek2 = endOfWeek1.addDays(1);
            Date endOfWeek2 = startOfWeek2.addDays(7);
            Timesheet__c insertTimeSheetWeek2 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName2',objTmeShtCst.Id,startOfWeek2,endOfWeek2);
            insertTimeSheetWeek2.Status__c = 'Submitted';
            insertTimeSheetWeek2.Account_Services__c = accSrvc.Id;
            timesheetsNew.add(insertTimeSheetWeek2);
            Date startOfWeek3 = endOfWeek2.addDays(1);
            Date endOfWeek3 = startOfWeek3.addDays(7);
            Timesheet__c insertTimeSheetWeek3 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName3',objTmeShtCst.Id,startOfWeek3,endOfWeek3);
            insertTimeSheetWeek3.Status__c = 'Submitted';
            insertTimeSheetWeek3.Account_Services__c = accSrvc.Id;
            timesheetsNew.add(insertTimeSheetWeek3);
            Date startOfWeek4 = endOfWeek3.addDays(1);
            Date endOfWeek4 = startOfWeek4.addDays(7);
            Timesheet__c insertTimeSheetWeek4 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName4',objTmeShtCst.Id,startOfWeek4,endOfWeek4);
            insertTimeSheetWeek4.Status__c = 'Submitted';
            insertTimeSheetWeek4.Account_Services__c = accSrvc.Id;
            timesheetsNew.add(insertTimeSheetWeek4);
            Date startOfWeek5 = endOfWeek4.addDays(1);
            Date endOfWeek5 = startOfWeek5.addDays(7);
            Timesheet__c insertTimeSheetWeek5 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName5',objTmeShtCst.Id,startOfWeek5,endOfWeek5);
            insertTimeSheetWeek5.Status__c = 'Submitted';
            insertTimeSheetWeek5.Account_Services__c = accSrvc.Id;
            timesheetsNew.add(insertTimeSheetWeek5);
            
            update timesheetsNew;
            
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
            
            insert objTmeShtDtlList1; 
            
            List<Decimal> allYearCost = ODS_Data_Utility.fetchCurrentAllYearCostServices(portalAccount1.Id, accSrvc.Id, Date.newInstance(System.Today().year(), 1, 1), Date.newInstance(System.Today().year(), 12, 31) );
            
            test.stopTest();
        }
    }       
    
    static testMethod void checkAllReturnVals2() {            
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);
        
        system.runAs(portalAccountOwner1) {
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
    
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                                'California', True,2000,'9433578865', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');                      
            contact1.Is_Approver__c = True;
            update contact1;
            
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNetTest1','test',true);                        
            
            Contact_Account_Service__c cas = new Contact_Account_Service__c();
            cas.Account__c = portalAccount1.Id;
            cas.Contact__c = contact1.Id;
            cas.Is_Approver__c = true;
            cas.ODS_Service__c = odsSrv.Id;
            cas.Type_of_Engagement__c = 'ODS';
            insert cas; 
            
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            usrAcc.Role_in_Account__c = 'Account Manager';            
            update usrAcc;
            
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
            update accSrvc;
            
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            
            Estimate__c estimate = new Estimate__c();
            estimate.Hours__c = 50;
            estimate.Initiative_Lookup__c = initiative.Id;
            estimate.Phase__c = 'Analysis';
            estimate.Task_Components__c = 'Test';
            insert estimate;  
            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,thisMonthStart,thisMonthEnd,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            objTmeShtCst.Regular_Hours_New__c = 50;
            objTmeShtCst.Cost_Per_Hour__c = 100;
            update objTmeShtCst;
            
            List<Timesheet__c> timesheetsNew = new List<Timesheet__c>();
            
            Date startOfWeek1 = thisMonthStart.toStartOfWeek();
            Date endOfWeek1 = startOfWeek1.addDays(7);
            Timesheet__c insertTimeSheetWeek1 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName1',objTmeShtCst.Id,startOfWeek1,endOfWeek1);
            insertTimeSheetWeek1.Status__c = 'Submitted';
            insertTimeSheetWeek1.Account_Services__c = accSrvc.Id;
            timesheetsNew.add(insertTimeSheetWeek1);
            Date startOfWeek2 = endOfWeek1.addDays(1);
            Date endOfWeek2 = startOfWeek2.addDays(7);
            Timesheet__c insertTimeSheetWeek2 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName2',objTmeShtCst.Id,startOfWeek2,endOfWeek2);
            insertTimeSheetWeek2.Status__c = 'Submitted';
            insertTimeSheetWeek2.Account_Services__c = accSrvc.Id;
            timesheetsNew.add(insertTimeSheetWeek2);
            Date startOfWeek3 = endOfWeek2.addDays(1);
            Date endOfWeek3 = startOfWeek3.addDays(7);
            Timesheet__c insertTimeSheetWeek3 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName3',objTmeShtCst.Id,startOfWeek3,endOfWeek3);
            insertTimeSheetWeek3.Status__c = 'Submitted';
            insertTimeSheetWeek3.Account_Services__c = accSrvc.Id;
            timesheetsNew.add(insertTimeSheetWeek3);
            Date startOfWeek4 = endOfWeek3.addDays(1);
            Date endOfWeek4 = startOfWeek4.addDays(7);
            Timesheet__c insertTimeSheetWeek4 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName4',objTmeShtCst.Id,startOfWeek4,endOfWeek4);
            insertTimeSheetWeek4.Status__c = 'Submitted';
            insertTimeSheetWeek4.Account_Services__c = accSrvc.Id;
            timesheetsNew.add(insertTimeSheetWeek4);
            Date startOfWeek5 = endOfWeek4.addDays(1);
            Date endOfWeek5 = startOfWeek5.addDays(7);
            Timesheet__c insertTimeSheetWeek5 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName5',objTmeShtCst.Id,startOfWeek5,endOfWeek5);
            insertTimeSheetWeek5.Status__c = 'Submitted';
            insertTimeSheetWeek5.Account_Services__c = accSrvc.Id;
            timesheetsNew.add(insertTimeSheetWeek5);
            
            update timesheetsNew;
            
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
            
            insert objTmeShtDtlList1;
            
            Invoice__c inv = new Invoice__c();
            inv.Account_Services__c = accSrvc.Id;
            Date StartDate = accSrvc.Contract_Start_Date__c; 
            String FromDate = DateTime.newInstance(StartDate.year(),StartDate.month(),StartDate.day()).format('MM/dd/yyyy');               
            Date EndDate = accSrvc.Contract_End_Date__c;
            String ToDate = DateTime.newInstance(EndDate.year(),EndDate.month(),EndDate.day()).format('MM/dd/yyyy');
            inv.Attachment_File__c = 'Test - '+System.today()+'.pdf';
            inv.Comments__c = 'Test'+String.valueOf(System.Today());
            //Custom setting to get month name 
            Integer mNumb = System.today().month();
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
            inv.Month__c = ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c;
            inv.Year__c = System.today().year();
            insert inv;                                                       
            
            
            test.startTest();
            List<Time_Sheet_Cost__c> tsc3 = ODS_Data_Utility.fetchOdsTmeSht('All','All',String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            List<Time_Sheet_Cost__c> tsc4 = ODS_Data_Utility.fetchOdsTmeSht('All',odsSrv.Id,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            List<Time_Sheet_Cost__c> tsc5 = ODS_Data_Utility.fetchOdsTmeSht(portalAccount1.Id,'All',String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            List<Time_Sheet_Cost__c> tsc6 = ODS_Data_Utility.fetchOdsTmeSht(portalAccount1.Id,odsSrv.Id,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            
            decimal ThisMonth1 = ODS_Data_Utility.fetchOdsTmeShtForMonthSubmitted('All','All',String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            decimal ThisMonth2 = ODS_Data_Utility.fetchOdsTmeShtForMonthSubmitted('All',odsSrv.Id,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            decimal ThisMonth3 = ODS_Data_Utility.fetchOdsTmeShtForMonthSubmitted(portalAccount1.Id,'All',String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            decimal ThisMonth4 = ODS_Data_Utility.fetchOdsTmeShtForMonthSubmitted(portalAccount1.Id,odsSrv.Id,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            
            List<Timesheet__c> ThisMonth5 = ODS_Data_Utility.fetchOdsTmeShtForSubmitted('All','All',String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            List<Timesheet__c> ThisMonth6 = ODS_Data_Utility.fetchOdsTmeShtForSubmitted('All',odsSrv.Id,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            List<Timesheet__c> ThisMonth7 = ODS_Data_Utility.fetchOdsTmeShtForSubmitted(portalAccount1.Id,'All',String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            List<Timesheet__c> ThisMonth8 = ODS_Data_Utility.fetchOdsTmeShtForSubmitted(portalAccount1.Id,odsSrv.Id,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            
            List<Time_Sheet_Cost__c> tsc7 = ODS_Data_Utility.fetchOdsTmeShtAllAccountService(String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            
            List<Decimal> dec12 = ODS_Data_Utility.fetchOdsALLYearTmeSht();
            
            List<Time_Sheet_Cost__c> tsc8 = ODS_Data_Utility.fetchOdsYearTmeSht('All','All',thisMonthStart,thisMonthEnd);
            List<Time_Sheet_Cost__c> tsc9 = ODS_Data_Utility.fetchOdsYearTmeSht('All',odsSrv.Id,thisMonthStart,thisMonthEnd);
            List<Time_Sheet_Cost__c> tsc10 = ODS_Data_Utility.fetchOdsYearTmeSht(portalAccount1.Id,'All',thisMonthStart,thisMonthEnd);
            List<Time_Sheet_Cost__c> tsc11 = ODS_Data_Utility.fetchOdsYearTmeSht(portalAccount1.Id,odsSrv.Id,thisMonthStart,thisMonthEnd);
            
            decimal lifeTime1 = ODS_Data_Utility.fetchOdsYearTmeShtForSubmitted('All','All',thisMonthStart,thisMonthEnd);
            decimal lifeTime2 = ODS_Data_Utility.fetchOdsYearTmeShtForSubmitted('All',odsSrv.Id,thisMonthStart,thisMonthEnd);
            decimal lifeTime3 = ODS_Data_Utility.fetchOdsYearTmeShtForSubmitted(portalAccount1.Id,'All',thisMonthStart,thisMonthEnd);
            decimal lifeTime4 = ODS_Data_Utility.fetchOdsYearTmeShtForSubmitted(portalAccount1.Id,odsSrv.Id,thisMonthStart,thisMonthEnd);
            
            List<Timesheet__c> lifeTime5 = ODS_Data_Utility.fetchOdsYearTmeShtSubmitted('All','All',thisMonthStart,thisMonthEnd);
            List<Timesheet__c> lifeTime6 = ODS_Data_Utility.fetchOdsYearTmeShtSubmitted('All',odsSrv.Id,thisMonthStart,thisMonthEnd);
            List<Timesheet__c> lifeTime7 = ODS_Data_Utility.fetchOdsYearTmeShtSubmitted(portalAccount1.Id,'All',thisMonthStart,thisMonthEnd);
            List<Timesheet__c> lifeTime8 = ODS_Data_Utility.fetchOdsYearTmeShtSubmitted(portalAccount1.Id,odsSrv.Id,thisMonthStart,thisMonthEnd);
            
            List<Aggregateresult> ar1 = ODS_Data_Utility.GetAggregateTimesheetDetails(insertTimeSheetWeek1.Id,accSrvc.Id);
            
            Set<Id> sUsr = new Set<Id>();
            sUsr.add(UserInfo.getUserId());
            List<User_Photo__c> usrp1 = ODS_Data_Utility.fetchUserPhotoByUserId(sUsr);
            
            //List<Attachment> fetchAttachmentByUserPhotoId
            
            Contact con5 = ODS_Data_Utility.fetchAttachmentByContactId(Contact1.Id);
            
            List<User> usr3 = ODS_Data_Utility.getUserdetails(UserInfo.getUserName());            
            
            Set<Id> sCon = new Set<Id>();
            sCon.add(contact1.Id);                
            List<user> usr1 = ODS_Data_Utility.getContactUserName(sCon);
            
            List<User> lUsr = new List<User>([SELECT Id,Name,UserName,isActive FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]);
            List<user> usr2 = ODS_Data_Utility.updateConUserName(lUsr);
            
            AggregateResult[] ar4 = ODS_Data_Utility.getResourceNameByAccountServiceId(portalAccount1.Id,odsSrv.Id);
            
            AggregateResult[] ar5 = ODS_Data_Utility.getInitiativeByAccountServiceId(portalAccount1.Id,odsSrv.Id);
            
            Set<Id> sAcc = new Set<Id>();
            sAcc.add(portalAccount1.Id);
            List<Initiatives__c> init1 = ODS_Data_Utility.fetchInitiativeByAcntId(sAcc);
            
            List<Project_Team_Member__c> pm1 = ODS_Data_Utility.fetchPrjctTeamMembrByAcntId(sAcc);
            
            Set<Id> sPm = new Set<Id>();
            sPm.add(ObjTeamMembr.Id);
            List<Time_Sheet_Details__c> tsd1 = ODS_Data_Utility.fetchResourceNameById(sPm);
            
            List<Time_Sheet_Details__c> tsd2 = ODS_Data_Utility.updateResourceName(objTmeShtDtlList1);
            
            Status_Report__c sr1 = ODS_Data_Utility.insertStatusReport(system.today()-1,'one','two','nothing','Completed',accSrvc.Id,'Daily');
            List<Status_Report__c> sr2 = ODS_Data_Utility.getPrevStatusRep(accSrvc.Id,system.today());
            
            List<Status_Report__c> sr3 = ODS_Data_Utility.getSRBsdOnDate(system.today()-1,accSrvc.Id);
            
            List<Timesheet__c> ts1 = ODS_Data_Utility.fetchSubmittedHrs(accSrvc.Id);
            
            List<Account_Services__c> lAcs = new List<Account_Services__c>([SELECT Id,Invoice_Frequency__c FROM Account_Services__c WHERE Id =:accSrvc.Id LIMIT 50000]);
            AggregateResult[] ar6 = ODS_Data_Utility.fetchHrsWaitingForApprovalALL(lAcs);
            
            AggregateResult[] ar7 = ODS_Data_Utility.fetchHrsWaitingForApproval(accSrvc.Id);
            
            List<Account_Services__c> acs1 = ODS_Data_Utility.fetchAllAcntSrv(portalAccount1.Id,odsSrv.Id);
            List<Account_Services__c> acs2 = ODS_Data_Utility.fetchAllAcntSrv('All',odsSrv.Id);
            List<Account_Services__c> acs3 = ODS_Data_Utility.fetchAllAcntSrv(portalAccount1.Id,'All');
            
            
            Account_Services__c acs4 = ODS_Data_Utility.fetchAcntSrv(portalAccount1.Id,odsSrv.Id);
            Account_Services__c acs5 = ODS_Data_Utility.fetchAcntSrv('All','All');
            
            
            
            List<Status_Report__c> sr5 = ODS_Data_Utility.fetchSR(accSrvc.Id,system.today()-1);
            
            Account_Services__c acs6 = ODS_Data_Utility.fetchRallyDetailsByAccountServiceId(portalAccount1.Id,odsSrv.Id);
            List<Account_Services__c> acs7 = ODS_Data_Utility.fetchAllAccServces();    
            
            List<Account_Services__c> acs8 = ODS_Data_Utility.fetchAccServcesByAccAndEngmtType(portalAccount1.Id); //Pre
            //List<Documents__c> FetchDocuments
            
            test.stopTest();
        }
    }
    
    static testMethod void checkAllReturnVals3() {            
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);
        
        system.runAs(portalAccountOwner1) {
            test.startTest();
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                                'California', True,2000,'9433578865', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');                      
            contact1.Is_Approver__c = True;
            update contact1;
            
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNetTest1','test',true);                        
            
            Contact_Account_Service__c cas = new Contact_Account_Service__c();
            cas.Account__c = portalAccount1.Id;
            cas.Contact__c = contact1.Id;
            cas.Is_Approver__c = true;
            cas.ODS_Service__c = odsSrv.Id;
            cas.Type_of_Engagement__c = 'ODS';
            insert cas; 
            
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            usrAcc.Role_in_Account__c = 'Account Manager';            
            update usrAcc;
            
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
            accSrvc.Document_Suffix__c = 'cs';
            update accSrvc;
            
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            
            Estimate__c estimate = new Estimate__c();
            estimate.Hours__c = 50;
            estimate.Initiative_Lookup__c = initiative.Id;
            estimate.Phase__c = 'Analysis';
            estimate.Task_Components__c = 'Test';
            insert estimate;  
            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,thisMonthStart,thisMonthEnd,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            objTmeShtCst.Regular_Hours_New__c = 50;
            objTmeShtCst.Cost_Per_Hour__c = 100;
            update objTmeShtCst;
            
            List<Timesheet__c> timesheetsNew = new List<Timesheet__c>();
            
            Date startOfWeek1 = thisMonthStart.toStartOfWeek();
            Date endOfWeek1 = startOfWeek1.addDays(7);
            Timesheet__c insertTimeSheetWeek1 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName1',objTmeShtCst.Id,startOfWeek1,endOfWeek1);
            insertTimeSheetWeek1.Status__c = 'Submitted';
            insertTimeSheetWeek1.Account_Services__c = accSrvc.Id;
            timesheetsNew.add(insertTimeSheetWeek1);
            Date startOfWeek2 = endOfWeek1.addDays(1);
            Date endOfWeek2 = startOfWeek2.addDays(7);
            Timesheet__c insertTimeSheetWeek2 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName2',objTmeShtCst.Id,startOfWeek2,endOfWeek2);
            insertTimeSheetWeek2.Status__c = 'Submitted';
            insertTimeSheetWeek2.Account_Services__c = accSrvc.Id;
            timesheetsNew.add(insertTimeSheetWeek2);
            Date startOfWeek3 = endOfWeek2.addDays(1);
            Date endOfWeek3 = startOfWeek3.addDays(7);
            Timesheet__c insertTimeSheetWeek3 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName3',objTmeShtCst.Id,startOfWeek3,endOfWeek3);
            insertTimeSheetWeek3.Status__c = 'Submitted';
            insertTimeSheetWeek3.Account_Services__c = accSrvc.Id;
            timesheetsNew.add(insertTimeSheetWeek3);
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
            timesheetsNew.add(insertTimeSheetWeek5);
            
            update timesheetsNew;
            
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
            
            insert objTmeShtDtlList1;                                                       
            
            Folder__c fldr = new Folder__c(Name='TestFolder',Account_Services__c=accSrvc.Id,Service_Id__c=odsSrv.Id);
            insert fldr;
            
            Invoice__c inv = new Invoice__c();
            inv.Account_Services__c = accSrvc.Id;
            Date StartDate = accSrvc.Contract_Start_Date__c; 
            String FromDate = DateTime.newInstance(StartDate.year(),StartDate.month(),StartDate.day()).format('MM/dd/yyyy');               
            Date EndDate = accSrvc.Contract_End_Date__c;
            String ToDate = DateTime.newInstance(EndDate.year(),EndDate.month(),EndDate.day()).format('MM/dd/yyyy');
            inv.Attachment_File__c = 'Test - '+System.today()+'.pdf';
            inv.Comments__c = 'Test'+String.valueOf(System.Today());
            //Custom setting to get month name 
            Integer mNumb = System.today().month();
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
            inv.Month__c = ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c;
            inv.Year__c = System.today().year();
            insert inv;
            
            Invoice__c inv1 = new Invoice__c();
            inv1.Account_Services__c = accSrvc.Id;
            Date StartDate1 = accSrvc.Contract_Start_Date__c; 
            String FromDate1 = DateTime.newInstance(StartDate1.year(),StartDate1.month(),StartDate1.day()).format('MM/dd/yyyy');               
            Date EndDate1 = accSrvc.Contract_End_Date__c;
            String ToDate1 = DateTime.newInstance(EndDate1.year(),EndDate1.month(),EndDate1.day()).format('MM/dd/yyyy');
            inv1.Attachment_File__c = 'Test - '+System.today()+'.pdf';
            inv1.Comments__c = 'Test'+String.valueOf(System.Today());                         
            inv1.Month__c = ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c;
            inv1.Year__c = System.today().year();
            insert inv1;
            
            
            Attachment att = new Attachment();
            att.Body = Blob.valueOf('TestBody');
            att.Name = 'TestDocument';
            att.ParentId = inv.Id;
            insert att;   
            
            Documents__c doc = new Documents__c();
            doc.Name = 'TestDocument';
            doc.Account__c = portalAccount1.Id;
            doc.AccountServiceId__c = accSrvc.Id;
            doc.Account_Services__c = accSrvc.Id;
            doc.Attachment_File__c = att.Id;
            doc.Attachment_Id__c = att.Id;
            doc.Comments__c = 'TestDocument';
            doc.DocumentId__c = '12345';
            doc.Document_Status__c = 'OK';
            doc.Document_Type__c = 'Design';
            doc.File_Extension__c = 'CSV';
            doc.FolderId__c = fldr.Id;
            doc.Is_Deleted__c = true;
            doc.Services__c = odsSrv.Id;
            doc.Project_Name__c = 'TestDocument';
            doc.SprintNumber__c = 12;
            doc.Uploaded_Date__c = system.today();
            insert doc;
            
            Notification__c notif = new Notification__c();
            notif.Account_Services__c = accSrvc.Id;
            notif.Key_data_Points__c = 'TestNotif';
            notif.Month__c = 'January';
            insert notif;
            
            string str1 = ODS_Data_Utility.GetAccountServiceDetails(portalAccount1.Id,odsSrv.Id);
            
            string str2 = ODS_Data_Utility.GetAccSerDetails(portalAccount1.Id,odsSrv.Id);
            
            string str3 = ODS_Data_Utility.GetAccSerDocumentPrefix(portalAccount1.Id,odsSrv.Id);
            
            string str4 = ODS_Data_Utility.InsertUpdateDocumentDetailsAttachment(portalAccount1.Id,accSrvc.Id,'Design',
                                                                                 'TestDocument','TestDocument',1.0,Blob.valueOf('TestDocument'),'TestDocument',null,fldr.Id,'csv');
            
            string str5 = ODS_Data_Utility.InsertUpdateDocumentDetailsAttachment(portalAccount1.Id,accSrvc.Id,'Design',
                                                                                 'TestDocument','TestDocument',1.0,Blob.valueOf('TestDocument'),'TestDocument',str4,fldr.Id,'csv'); 
            
            string str12 = ODS_Data_Utility.InsertUpdateDocumentDetailsAttachment(portalAccount1.Id,accSrvc.Id,'Design',
                                                                                  'TestDocument','TestDocument',1.0,Blob.valueOf('TestDocument'),'TestDocument',str4); 
            
            string str13 = ODS_Data_Utility.InsertUpdateDocumentDetailsAttachment(portalAccount1.Id,accSrvc.Id,'Design',
                                                                                  'TestDocument','TestDocument',1.0,Blob.valueOf('TestDocument'),'TestDocument1',''); 
            
            
            string str6 = ODS_Data_Utility.ValidateDocument('TestDocument',portalAccount1.Id,accSrvc.Id,'','');
            
            string str7 = ODS_Data_Utility.ValidateDocument('TestDocument',portalAccount1.Id,accSrvc.Id,'TestDocument',doc.Id);
            
            
            //string str10 = ODS_Data_Utility.GetDocumentAttachment(doc.Id,portalAccount1.Id,odsSrv.Id);
            
            
            test.stopTest();
        }
    }
    
    static testMethod void checkAllReturnVals3_1() {            
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);
        
        system.runAs(portalAccountOwner1) {
            test.startTest();
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                                'California', True,2000,'9433578865', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');                      
            contact1.Is_Approver__c = True;
            update contact1;
            
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNetTest1','test',true);                        
            
            Contact_Account_Service__c cas = new Contact_Account_Service__c();
            cas.Account__c = portalAccount1.Id;
            cas.Contact__c = contact1.Id;
            cas.Is_Approver__c = true;
            cas.ODS_Service__c = odsSrv.Id;
            cas.Type_of_Engagement__c = 'ODS';
            insert cas; 
            
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            usrAcc.Role_in_Account__c = 'Account Manager';            
            update usrAcc;
            
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
            accSrvc.Document_Suffix__c = 'cs';
            update accSrvc;
            
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            
            Estimate__c estimate = new Estimate__c();
            estimate.Hours__c = 50;
            estimate.Initiative_Lookup__c = initiative.Id;
            estimate.Phase__c = 'Analysis';
            estimate.Task_Components__c = 'Test';
            insert estimate;  
            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,thisMonthStart,thisMonthEnd,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            objTmeShtCst.Regular_Hours_New__c = 50;
            objTmeShtCst.Cost_Per_Hour__c = 100;
            update objTmeShtCst;           
            Folder__c fldr = new Folder__c(Name='TestFolder',Account_Services__c=accSrvc.Id,Service_Id__c=odsSrv.Id);
            insert fldr;
            Invoice__c inv = new Invoice__c();
            inv.Account_Services__c = accSrvc.Id;
            Date StartDate = accSrvc.Contract_Start_Date__c; 
            String FromDate = DateTime.newInstance(StartDate.year(),StartDate.month(),StartDate.day()).format('MM/dd/yyyy');               
            Date EndDate = accSrvc.Contract_End_Date__c;
            String ToDate = DateTime.newInstance(EndDate.year(),EndDate.month(),EndDate.day()).format('MM/dd/yyyy');
            inv.Attachment_File__c = 'Test - '+System.today()+'.pdf';
            inv.Comments__c = 'Test'+String.valueOf(System.Today());
            //Custom setting to get month name 
            Integer mNumb = System.today().month();
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
            inv.Month__c = ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c;
            inv.Year__c = System.today().year();
            insert inv;
            
            Attachment att = new Attachment();
            att.Body = Blob.valueOf('TestBody');
            att.Name = 'TestDocument';
            att.ParentId = inv.Id;
            insert att;   
            
            Documents__c doc = new Documents__c();
            doc.Name = 'TestDocument';
            doc.Account__c = portalAccount1.Id;
            doc.AccountServiceId__c = accSrvc.Id;
            doc.Account_Services__c = accSrvc.Id;
            doc.Attachment_File__c = att.Id;
            doc.Attachment_Id__c = att.Id;
            doc.Comments__c = 'TestDocument';
            doc.DocumentId__c = '12345';
            doc.Document_Status__c = 'OK';
            doc.Document_Type__c = 'Design';
            doc.File_Extension__c = 'CSV';
            doc.FolderId__c = fldr.Id;
            doc.Is_Deleted__c = true;
            doc.Services__c = odsSrv.Id;
            doc.Project_Name__c = 'TestDocument';
            doc.SprintNumber__c = 12;
            doc.Uploaded_Date__c = system.today();
            insert doc;
            
            Notification__c notif = new Notification__c();
            notif.Account_Services__c = accSrvc.Id;
            notif.Key_data_Points__c = 'TestNotif';
            notif.Month__c = 'January';
            insert notif;
            
            Account_Services__c[] acs1 = ODS_Data_Utility.GetAccountServiceName(portalAccount1.Id,odsSrv.Id);
            
            Documents__c[] doc2 = ODS_Data_Utility.GetAttachmentId(doc.Id);
            
            List<Contact_Account_Service__c> cas1 = ODS_Data_Utility.GetContactEmailIds(portalAccount1.Id,odsSrv.Id);
            
            List<User_Account__c> ua1 = ODS_Data_Utility.GetUserAccountEmailIds(portalAccount1.Id,odsSrv.Id);
            
            User_Account__c[] ua2 = ODS_Data_Utility.GetTechnicalAccountManager(portalAccount1.Id);
            
            Documents__c[] doc3 = ODS_Data_Utility.GetDocumentDetails(doc.Id);
            
            List<Contact_Account_Service__c> cas2 = ODS_Data_Utility.GetcontactAccSer(odsSrv.Id,contact1.Id);
            
            List<Contact_Account_Service__c> cas3 = ODS_Data_Utility.GetAccServiceByContact(contact1.Id);
            
            List<Contact_Account_Service__c> cas4 = ODS_Data_Utility.GetAccServiceByContactAndEngmtType(contact1.Id);
            
            List<Notification__c> notif1 = ODS_Data_Utility.GetNotification(accSrvc.Id,'January');
            
            list<Notification__c> notif2 = ODS_Data_Utility.GetPreviousMonthNotification(accSrvc.Id);
            
            test.stopTest();
        }
    }
    
    static testMethod void checkAllReturnVals4() {            
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);
        
        system.runAs(portalAccountOwner1) {
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
              
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                                'California', True,2000,'9433578865', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');                      
            contact1.Is_Approver__c = True;
            update contact1;
            
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNetTest1','test',true);                        
            
            Contact_Account_Service__c cas = new Contact_Account_Service__c();
            cas.Account__c = portalAccount1.Id;
            cas.Contact__c = contact1.Id;
            cas.Is_Approver__c = true;
            cas.ODS_Service__c = odsSrv.Id;
            cas.Type_of_Engagement__c = 'ODS';
            insert cas; 
            
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            usrAcc.Role_in_Account__c = 'Account Manager';            
            update usrAcc;
            
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
            accSrvc.Document_Suffix__c = 'cs';
            update accSrvc;
            
            Initiatives__c initiative = ODS_DataFactory_Test_Utility.insertIntiatives('Test Initiative', accSrvc.Id, 'Initiative Approved');
            
            Estimate__c estimate = new Estimate__c();
            estimate.Hours__c = 50;
            estimate.Initiative_Lookup__c = initiative.Id;
            estimate.Phase__c = 'Analysis';
            estimate.Task_Components__c = 'Test';
            insert estimate;  
            
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,thisMonthStart,thisMonthEnd,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            objTmeShtCst.Regular_Hours_New__c = 50;
            objTmeShtCst.Cost_Per_Hour__c = 100;
            update objTmeShtCst;
            
            List<Timesheet__c> timesheetsNew = new List<Timesheet__c>();
            
            Date startOfWeek1 = thisMonthStart.toStartOfWeek();
            Date endOfWeek1 = startOfWeek1.addDays(7);
            Timesheet__c insertTimeSheetWeek1 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName1',objTmeShtCst.Id,startOfWeek1,endOfWeek1);
            insertTimeSheetWeek1.Status__c = 'Submitted';
            insertTimeSheetWeek1.Account_Services__c = accSrvc.Id;
            timesheetsNew.add(insertTimeSheetWeek1);
            Date startOfWeek2 = endOfWeek1.addDays(1);
            Date endOfWeek2 = startOfWeek2.addDays(7);
            Timesheet__c insertTimeSheetWeek2 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName2',objTmeShtCst.Id,startOfWeek2,endOfWeek2);
            insertTimeSheetWeek2.Status__c = 'Submitted';
            insertTimeSheetWeek2.Account_Services__c = accSrvc.Id;
            timesheetsNew.add(insertTimeSheetWeek2);
            Date startOfWeek3 = endOfWeek2.addDays(1);
            Date endOfWeek3 = startOfWeek3.addDays(7);
            Timesheet__c insertTimeSheetWeek3 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName3',objTmeShtCst.Id,startOfWeek3,endOfWeek3);
            insertTimeSheetWeek3.Status__c = 'Submitted';
            insertTimeSheetWeek3.Account_Services__c = accSrvc.Id;
            timesheetsNew.add(insertTimeSheetWeek3);
            Date startOfWeek4 = endOfWeek3.addDays(1);
            Date endOfWeek4 = startOfWeek4.addDays(7);
            Timesheet__c insertTimeSheetWeek4 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName4',objTmeShtCst.Id,startOfWeek4,endOfWeek4);
            insertTimeSheetWeek4.Status__c = 'Submitted';
            insertTimeSheetWeek4.Account_Services__c = accSrvc.Id;
            timesheetsNew.add(insertTimeSheetWeek4);
            Date startOfWeek5 = endOfWeek4.addDays(1);
            Date endOfWeek5 = startOfWeek5.addDays(7);
            Timesheet__c insertTimeSheetWeek5 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName5',objTmeShtCst.Id,startOfWeek5,endOfWeek5);
            insertTimeSheetWeek5.Status__c = 'Submitted';
            insertTimeSheetWeek5.Account_Services__c = accSrvc.Id;
            timesheetsNew.add(insertTimeSheetWeek5);
            
            update timesheetsNew;
            
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
            
            insert objTmeShtDtlList1;
            
            Invoice__c inv = new Invoice__c();
            inv.Account_Services__c = accSrvc.Id;
            Date StartDate = accSrvc.Contract_Start_Date__c; 
            String FromDate = DateTime.newInstance(StartDate.year(),StartDate.month(),StartDate.day()).format('MM/dd/yyyy');               
            Date EndDate = accSrvc.Contract_End_Date__c;
            String ToDate = DateTime.newInstance(EndDate.year(),EndDate.month(),EndDate.day()).format('MM/dd/yyyy');
            inv.Attachment_File__c = 'Test - '+System.today()+'.pdf';
            inv.Comments__c = 'Test'+String.valueOf(System.Today());
            //Custom setting to get month name 
            Integer mNumb = System.today().month();
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
            inv.Month__c = ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c;
            inv.Year__c = System.today().year();
            insert inv;            
            
            Attachment att = new Attachment();
            att.Body = Blob.valueOf('TestBody');
            att.Name = 'TestDocument';
            att.ParentId = inv.Id;
            insert att;                                                        
            
            Folder__c fldr = new Folder__c(Name='TestFolder',Account_Services__c=accSrvc.Id,Service_Id__c=odsSrv.Id);
            insert fldr;
            
            Documents__c doc = new Documents__c();
            doc.Name = 'TestDocument';
            doc.Account__c = portalAccount1.Id;
            doc.AccountServiceId__c = accSrvc.Id;
            doc.Account_Services__c = accSrvc.Id;
            doc.Attachment_File__c = att.Id;
            doc.Attachment_Id__c = att.Id;
            doc.Comments__c = 'TestDocument';
            doc.DocumentId__c = '12345';
            doc.Document_Status__c = 'OK';
            doc.Document_Type__c = 'Design';
            doc.File_Extension__c = 'CSV';
            doc.FolderId__c = fldr.Id;
            doc.Is_Deleted__c = true;
            doc.Services__c = odsSrv.Id;
            doc.Project_Name__c = 'TestDocument';
            doc.SprintNumber__c = 12;
            doc.Uploaded_Date__c = system.today();
            insert doc;
            
            Documents__c doc1 = new Documents__c();
            doc1.Name = 'TestDocument1';
            doc1.Account__c = portalAccount1.Id;
            doc1.AccountServiceId__c = accSrvc.Id;
            doc1.Account_Services__c = accSrvc.Id;
            doc1.Attachment_File__c = att.Id;
            doc1.Attachment_Id__c = att.Id;
            doc1.Comments__c = 'TestDocument1';
            doc1.DocumentId__c = '12345';
            doc1.Document_Status__c = 'OK';
            doc1.Document_Type__c = 'Design';
            doc1.File_Extension__c = 'CSV';
            doc1.FolderId__c = fldr.Id;
            doc1.Is_Deleted__c = true;
            doc1.Services__c = odsSrv.Id;
            doc1.Project_Name__c = 'TestDocument1';
            doc1.SprintNumber__c = 12;
            doc1.Uploaded_Date__c = system.today();
            insert doc1;
            
            Notification__c notif = new Notification__c();
            notif.Account_Services__c = accSrvc.Id;
            notif.Key_data_Points__c = 'TestNotif';
            notif.Month__c = 'January';
            insert notif;
            test.startTest();
            string str1 = ODS_Data_Utility.ValidateFolder('TestFolder',accSrvc.Id);
            
            Folder__c fldr1 = new Folder__c(Name='TestFolder1',Account_Services__c=accSrvc.Id,Service_Id__c=odsSrv.Id);
            ODS_Data_Utility.AddNewFolder(fldr1);
            
            List<Documents__c> doc2 = ODS_Data_Utility.FetchDeletedDocuments(portalAccount1.Id,odsSrv.Id,'LastModifiedDate');
            List<Documents__c> doc3 = ODS_Data_Utility.FetchDeletedDocuments('All',odsSrv.Id,'LastModifiedDate');
            List<Documents__c> doc4 = ODS_Data_Utility.FetchDeletedDocuments(portalAccount1.Id,'All','LastModifiedDate');
            
            ODS_Data_Utility.DeleteDocument(doc1.Id);
            
            ODS_Data_Utility.RestoreDocument(doc1.Id);
            
            ODS_Data_Utility.DeleteTrashDocument(doc1.Id);
            
            List<Folder__c> fldr2 = ODS_Data_Utility.FetchFolders(portalAccount1.Id,odsSrv.Id);
            
            Documents__c doc5 = ODS_Data_Utility.InsertDocument('TestDoc4',accSrvc.Id,portalAccount1.Id,'csv',fldr.Id);
            
            Attachment att2 = ODS_Data_Utility.InsertAttachment(doc.Id,Blob.valueOf('TestAtt'),'TestDoc5');
            
            Documents__c doc6 = ODS_Data_Utility.UpdateDocument(doc.Id,att.Id);
            
            Set<string> str2 = ODS_Data_Utility.GetAllServicesForCustomer(portalAccount1.Id,contact1.Id);
            
            Set<Id> sFldr = new Set<Id>();
            sFldr.add(fldr.Id);
            List<Documents__c> doc7 = ODS_Data_Utility.GetDocuments(portalAccount1.Id,odsSrv.Id,sFldr,FromDate,ToDate,'TestDocument4');
            List<Documents__c> doc8 = ODS_Data_Utility.GetDocuments('All',odsSrv.Id,sFldr,FromDate,ToDate,'TestDocument4');
            List<Documents__c> doc9 = ODS_Data_Utility.GetDocuments(portalAccount1.Id,'All',sFldr,FromDate,ToDate,'TestDocument4');
            List<Documents__c> doc10 = ODS_Data_Utility.GetDocuments('All','All',sFldr,FromDate,ToDate,'TestDocument4');
            List<Documents__c> doc11 = ODS_Data_Utility.GetDocuments('All','All',fldr.Id,FromDate,ToDate,'TestDocument4', 'CreatedDate DESC');
            List<Documents__c> doc12 = ODS_Data_Utility.GetDocuments(portalAccount1.Id,'All',fldr.Id,FromDate,ToDate,'TestDocument4', 'CreatedDate DESC');
            List<Documents__c> doc13 = ODS_Data_Utility.GetDocuments(portalAccount1.Id,odsSrv.Id,fldr.Id,FromDate,ToDate,'TestDocument4', 'CreatedDate DESC');
            List<Documents__c> doc14 = ODS_Data_Utility.FetchDocuments(portalAccount1.Id,odsSrv.Id,FromDate,ToDate,'TestDocument4','Design' );
            List<Documents__c> doc15 = ODS_Data_Utility.FetchDocuments('All',odsSrv.Id,FromDate,ToDate,'TestDocument4','Design' );
            List<Documents__c> doc16 = ODS_Data_Utility.FetchDocuments(portalAccount1.Id,'All',FromDate,ToDate,'TestDocument4','Design' );
            
            List<Folder__c> fldr3 = ODS_Data_Utility.FetchFolders(portalAccount1.Id,odsSrv.Id);
            List<Folder__c> fldr4 = ODS_Data_Utility.FetchFolders('All',odsSrv.Id);
            List<Folder__c> fldr5 = ODS_Data_Utility.FetchFolders(portalAccount1.Id,'All');
            List<Folder__c> fldr6 = ODS_Data_Utility.FetchFolders('All','All');
            
            List<Folder__c> fldr7 = ODS_Data_Utility.FetchFolders(portalAccount1.Id,odsSrv.Id,FromDate,ToDate,'TestFolder1', 'CreatedDate DESC');
            List<Folder__c> fldr8 = ODS_Data_Utility.FetchFolders('All','All',FromDate,ToDate,'TestFolder1', 'CreatedDate DESC');
            
            string str3 = ODS_Data_Utility.ValidateDocument('TestDocument1',portalAccount1.Id,accSrvc.Id);
            
            List<Attachment> att3 = ODS_Data_Utility.FetchAttachments(att.Name);
            
            string str4 = ODS_Data_Utility.GetAccountServiceDetails(accSrvc.Id);
            
            Set<string> str5 = ODS_Data_Utility.GetAllAccountsBasedOnLoggedUser();
            
            list<Holiday> holidays = ODS_Data_Utility.getHolidaydetails();
            
            
            test.stopTest();
        }
    }
    
    static testMethod void checkAllReturnVals5() {            
        UserRole portalRole = ODS_DataFactory_Test_Utility.FetchUserRole();
        Profile profile1 = ODS_DataFactory_Test_Utility.GetProfileName('System Administrator');
        User portalAccountOwner1 = ODS_DataFactory_Test_Utility.InsertUserWithRole('indu','testuser@testmail.com','UTF-8','Indumathi',
                                                                                   'en_US','en_US',profile1.Id,'America/Chicago',System.now().millisecond() + 
                                                                                   'test123@testmail.com','Technical Account Manager', true,portalRole.Id);
        
        system.runAs(portalAccountOwner1) {
            
            test.startTest();
            Campaign camp = new Campaign(Name = 'ODSTest force.com');
            insert camp;
            Account portalAccount1 = ODS_DataFactory_Test_Utility.InsertAccount('TestAccount',
                                                                                'California', True,2000,'9433578865', 'Others', 'ODS Project');     
            Contact contact1 = ODS_DataFactory_Test_Utility.InsertContact('Test','McTesty', True, portalAccount1.Id, 'Others', 'ODS Project');                      
            contact1.Is_Approver__c = True;
            update contact1;
            
            Profile portalProfile = ODS_DataFactory_Test_Utility.GetProfileName('Customer Community');
            User user1 = ODS_DataFactory_Test_Utility.InsertUserWithContact('test123', 'test12345@test.com', 'UTF-8','McTesty',
                                                                            'en_US','en_US', portalProfile.Id, 'America/Los_Angeles', System.now().millisecond() + 
                                                                            'test12345@test.com', contact1.Id,'Customer');
            
            ODS_Services__c odsSrv = ODS_DataFactory_Test_Utility.insertODSServices('DotNetTest1','test',true);                        
            
            Contact_Account_Service__c cas = new Contact_Account_Service__c();
            cas.Account__c = portalAccount1.Id;
            cas.Contact__c = contact1.Id;
            cas.Is_Approver__c = true;
            cas.ODS_Service__c = odsSrv.Id;
            cas.Type_of_Engagement__c = 'ODS';
            insert cas; 
            
            Project_Team_Member__c ObjTeamMembr = ODS_DataFactory_Test_Utility.insertTeamMember('Arun',portalAccount1.Id,odsSrv.Id);
            
            User_Account__c usrAcc = ODS_DataFactory_Test_Utility.insertUsrAccnt(portalAccount1.id,'Technical Account Manager',portalAccountOwner1.Id,odsSrv.Id);
            usrAcc.Role_in_Account__c = 'Account Manager';            
            update usrAcc;
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
            accSrvc.Document_Suffix__c = 'cs';
            update accSrvc;
            Time_Sheet_Cost__c objTmeShtCst = ODS_DataFactory_Test_Utility.insertTimesheetCost(accSrvc.Id,300,thisMonthStart,thisMonthEnd,String.valueOf(thisMonthStart.month()),String.valueOf(thisMonthStart.year()));
            objTmeShtCst.Regular_Hours_New__c = 50;
            objTmeShtCst.Cost_Per_Hour__c = 100;
            update objTmeShtCst;
            
            Date startOfWeek1 = thisMonthStart.toStartOfWeek();
            Date endOfWeek1 = startOfWeek1.addDays(7);
            Timesheet__c insertTimeSheetWeek1 =  ODS_DataFactory_Test_Utility.insertTimesheetWithCst('TestName1',objTmeShtCst.Id,startOfWeek1,endOfWeek1);
            insertTimeSheetWeek1.Status__c = 'Submitted';
            insertTimeSheetWeek1.Account_Services__c = accSrvc.Id;
            update insertTimeSheetWeek1;
            Invoice__c inv = new Invoice__c();
            inv.Account_Services__c = accSrvc.Id;
            Date StartDate = accSrvc.Contract_Start_Date__c; 
            String FromDate = DateTime.newInstance(StartDate.year(),StartDate.month(),StartDate.day()).format('MM/dd/yyyy');               
            Date EndDate = accSrvc.Contract_End_Date__c;
            String ToDate = DateTime.newInstance(EndDate.year(),EndDate.month(),EndDate.day()).format('MM/dd/yyyy');
            inv.Attachment_File__c = 'Test - '+System.today()+'.pdf';
            inv.Comments__c = 'Test'+String.valueOf(System.Today());
            //Custom setting to get month name 
            Integer mNumb = System.today().month();
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
            inv.Month__c = ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c;
            inv.Year__c = System.today().year();
            insert inv;
            
            Invoice__c inv1 = new Invoice__c();
            inv1.Account_Services__c = accSrvc.Id;
            Date StartDate1 = accSrvc.Contract_Start_Date__c; 
            String FromDate1 = DateTime.newInstance(StartDate1.year(),StartDate1.month(),StartDate1.day()).format('MM/dd/yyyy');               
            Date EndDate1 = accSrvc.Contract_End_Date__c;
            String ToDate1 = DateTime.newInstance(EndDate1.year(),EndDate1.month(),EndDate1.day()).format('MM/dd/yyyy');
            inv1.Attachment_File__c = 'Test - '+System.today()+'.pdf';
            inv1.Comments__c = 'Test'+String.valueOf(System.Today());                         
            inv1.Month__c = ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c;
            inv1.Year__c = System.today().year();
            //inv1.Status__c = 'Submitted';
            insert inv1;
            
            
            Attachment att = new Attachment();
            att.Body = Blob.valueOf('TestBody');
            att.Name = 'TestDocument';
            att.ParentId = inv.Id;
            insert att;  
            User usr1 = ODS_Data_Utility.fetchUserById(portalAccountOwner1.Id);
            Invoice__c inv2 =   ODS_Data_Utility.InsertUpdateInvoiceDetailsAttachment(portalAccount1.Id,odsSrv.Id,'TestInv',
                                                                                      ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c,
                                                                                      System.today().year(),Blob.valueOf('Test'),'TestComments',null);
            Invoice__c inv3 =   ODS_Data_Utility.InsertUpdateInvoiceDetailsAttachment(portalAccount1.Id,odsSrv.Id,'TestInv',
                                                                                      ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c,
                                                                                      System.today().year(),Blob.valueOf('Test'),'TestComments',inv2.Id);
            Invoice__c inv4 =   ODS_Data_Utility.InsertUpdateInvoiceDetailsAttachment(portalAccount1.Id,odsSrv.Id,'TestInv',
                                                                                      ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c,
                                                                                      System.today().year(),Blob.valueOf('Test'),'TestComments',inv3.Id);
            /*Invoice__c inv5 =   ODS_Data_Utility.InsertUpdateInvoiceDetailsAttachment(portalAccount1.Id,odsSrv.Id,'sfadmin@demndblue.com','test',ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c,System.today().year(),Blob.valueOf('Test'),'sample123',Blob.valueOf('Test'),'good','',startOfWeek1,endOfWeek1);
Invoice__c inv5 =   ODS_Data_Utility.InsertUpdateInvoiceDetailsAttachment(portalAccount1.Id,odsSrv.Id,'TestInv',
ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c,
System.today().year(),Blob.valueOf('Test'),'TestComments',inv2.Id,'Submitted',startOfWeek1,endOfWeek1);*/
            //  Invoice__c inv6 =   ODS_Data_Utility.updateApprovedRejectedStatus(inv2.Id, 'Approved','It is good');
            
            list<Invoice__c> inv7 =   ODS_Data_Utility.GetInvoiceAttachmentId(inv.Id);
            string str1 =   ODS_Data_Utility.ValidateInvoice(portalAccount1.Id,odsSrv.Id,'','');
            ODS_Data_Utility.UpdateInvoiceStatus(inv.Id);
            ODS_Data_Utility.UpdateInvoiceStatusAsFalse(inv1.Id);
            string str2 =   ODS_Data_Utility.ValidateInvoice(portalAccount1.Id,odsSrv.Id,'TestDocument',inv.Id);
            // string str3 =   ODS_Data_Utility.ValidateInvoiceUpdated(portalAccount1.Id,odsSrv.Id,inv.Id,'TestDocument');
            string str4 =   ODS_Data_Utility.GetInvoiceAttachment(inv.Id);
            
            Account_Services__c[] acs1 = ODS_Data_Utility.GetAccountServiceName(portalAccount1.Id,odsSrv.Id);
            Account_Services__c[] acs2 = ODS_Data_Utility.fetchAccServcesByServiceAccount(portalAccount1.Id,odsSrv.Id);
            
            //ODS_Data_Utility.InsertUpdateInvoiceDetailsAttachment(portalAccount1.Id,odsSrv.Id,'sfadmin@demndblue.com','test',ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c,System.today().year(),Blob.valueOf('Test'),'sample123',Blob.valueOf('Test'),'good',inv2.Id,startOfWeek1,endOfWeek1);
            ODS_Data_Utility.DeleteInvoice(inv1.Id);
            //ODS_Data_Utility.InsertUpdateInvoiceDetails(accSrvc.Id,portalAccount1.Id,odsSrv.Id,ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c,System.today().year(),'ABC',inv.Id,strtDt,endDt);
            //ODS_Data_Utility.InsertUpdateInvoiceDetails(accSrvc.Id,portalAccount1.Id,odsSrv.Id,ODS_Invoice_Month__c.getValues(String.valueOf(System.today().month())).MonthName__c,System.today().year(),'ABC','',strtDt,endDt);
            test.stopTest();
        }
    }
}
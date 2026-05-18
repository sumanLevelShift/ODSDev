/*
--Author: Mani and Team
--Purpose: To display Partner dashboard
--Created on: 22/June/2018
--Test Class: ODS_PartnerController_Test
*/
public class ODS_PartnerController
{
    //Globals
    public Boolean ShowRecOutptPnl {get;set;}
    public Boolean ShowNoRedOutptPnl {get;set;} 
    public boolean ShowTMDashboard {get; set;}
    public string OdsThisMonthCost {get;set;}
    public string OdsYTDCost {get;set;}
    public string OdsLifeTimeCost {get;set;}
    public string PartnerThisMnthCost {get;set;}
    public string CurrentMonthDate {get;set;}
    public string PartnerYTDCost {get;set;}
    public string ytdDate {get;set;}
    public string partnerLifeTimeCost {get;set;}
    public string slctdYear {get;set;}
    public string slctdMonth {get;set;}
    public string slctdRevType {get;set;}
    public String CurrentDateTime {get; set;}
    public string AccountId {get;set;}
    public string ServiceId {get;set;}
    public string TimeshtJSONtoBind {get;set;}
    public string SubscJSONtoBind {get;set;}
    
    public Integer CurrentFYDays;
    public Date dtCurrentdate;
    Public Date today;
    Public Integer currentFY;
    Public Integer currentFYMonth;
    Public Integer dtCurrentYear{get;set;}
    Public Integer dtNextYear{get;set;}
    Public String strFinancialYear {get;set;}
    Public static Date FYStartDate;
    Public static Date FYEndDate;
    
    public Decimal resThisMnthCost;
    public Decimal resYTDCost;
    public Decimal resLifeTimeCost;
    public User currUser;
    public id currPartnerId;
    public Id currPartnerCont; 
        
    //Constructor
    public ODS_PartnerController() {
        ShowRecOutptPnl = true;
        ShowNoRedOutptPnl = false;
        ShowTMDashboard = true;        
        
        Datetime objDateTime = Datetime.now(); // Returns the current Datetime based on a GMT calendar.
        CurrentDateTime  = objDateTime.format('MM/dd/yyyy'); // formats the date
                
        currUser = [SELECT Id,Email,UserName,PortalUserRole__c,Contact.AccountId,ContactId FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
        currPartnerId = currUser.Contact.AccountId;
        currPartnerCont = currUser.ContactId;
    }
    
    // Bind year dropdown.
    public List<SelectOption> getYears()
    {
        List<SelectOption> yearLst = new List<SelectOption>();
        Integer startYear = Date.today().Year();
        Integer endYear = Date.today().addYears(-3).Year();
        for(integer i = startYear; i >= endYear; i--)
        {
            yearLst.add(new SelectOption(string.ValueOf(i),string.ValueOf(i))); 
        }
        return yearLst;
    }
    
    // Bind month dropdown.
    public List<SelectOption> getMonths()
    {
        List<SelectOption> monthLst = new List<SelectOption>();
        monthLst.add(new SelectOption('0', 'All'));
        monthLst.add(new SelectOption('1', 'January'));
        monthLst.add(new SelectOption('2', 'February'));
        monthLst.add(new SelectOption('3', 'March'));
        monthLst.add(new SelectOption('4', 'April'));
        monthLst.add(new SelectOption('5', 'May'));
        monthLst.add(new SelectOption('6', 'June'));
        monthLst.add(new SelectOption('7', 'July'));
        monthLst.add(new SelectOption('8', 'August'));
        monthLst.add(new SelectOption('9', 'September'));
        monthLst.add(new SelectOption('10', 'October'));
        monthLst.add(new SelectOption('11', 'November'));
        monthLst.add(new SelectOption('12', 'December'));
        
        return monthLst;
    }
    
    // Bind Revenue Type dropdown.
    public List<SelectOption> getRevType()
    {
        List<SelectOption> revTypLst = new List<SelectOption>();
        revTypLst.add(new SelectOption('subscription', 'Subscription'));
        revTypLst.add(new SelectOption('timeandmoney', 'Invoice'));
        return revTypLst;
    }
    
    //Action Function call
    public PageReference GetDashboardByAccountServiceID()   
    {  
        system.debug('@@@ GetDashboardByAccountServiceID=======Partner');
        if((AccountId == null && ServiceId == null) || (AccountId == '' && ServiceId == ''))         
        {
            ShowRecOutptPnl = false;
            ShowNoRedOutptPnl = true;          
        }
        else
        {
            ShowRecOutptPnl = true;
            ShowNoRedOutptPnl = false;
        }
        
        if(AccountId !='' && ServiceId !='' ){
            ODS_Common_Utility.upsertSessionData(AccountId,ServiceId);
            GetDashboardAll(); 
            
            getRevenueCalcForSubsChart(AccountId,ServiceId); 
            getRevenueCalcForTnMChart(AccountId,ServiceId);                      
        }
        return null;
    }
    
    public void GetDashboardAll() {
        system.debug('@@@ get dashboard all ');
        dtCurrentdate = system.today();
        Integer intMonth = dtCurrentdate.Month();
        string strMonth = string.valueof(intMonth);
        Integer intYear = dtCurrentdate.Year();
        string strYear = string.valueof(intYear);
        Integer intPrevMonth = dtCurrentdate.Month()-1;
        string strPrevMonth = string.valueof(intPrevMonth);
        
        Organization orgInfo = ODS_Data_Utility.fetchFiscalYrStartingMonth(Userinfo.getOrganizationId());
        today = system.today();
        currentFYMonth = orgInfo.FiscalYearStartMonth;
        if (today.month() >= orgInfo.FiscalYearStartMonth) 
        {
            CurrentFY = today.year();
        } 
        else 
        {
            currentFY = today.year() - 1;
        }
        dtCurrentYear = currentFY;
        dtNextYear = currentFY+1;
        strFinancialYear = 'FY'+' '+ dtCurrentYear + ' - ' + dtNextYear; 
        CurrentFYDays = date.daysInMonth(currentFY, currentFYMonth);
        FYStartDate = date.parse(CurrentFYMonth + '/' + '01' + '/' + currentFY);
        FYEndDate = FYStartDate.addYears(1).addDays(-1);
        
        ShowTMDashboard = true;
        LoadCostSavingpanel(strMonth,strPrevMonth,strYear,FYStartDate,FYEndDate);
    }
    
    //Get individual table value - inner method
    public void LoadCostSavingpanel(string strMonth,string strPrevMonth,string strYear,Date FYStartDt,Date FYEndDt)
    {
        CurrentMonthDate = currMonthCalc(date.today());
        ytdDate = ytdMonthCalc(date.today());
        calcLifeTimeAllCost();
        calcYTDCost();
        calcThisMonthCost();        
    }
    
    //Formatting currency values to Million
    public string formatCurrencyInDecimal(decimal CurrencyValue) {
        string FormattedValue = '';  
        decimal convertedValue = 0;
        
        if(CurrencyValue >= 10000000)
        {
            convertedValue  = (CurrencyValue/10000000);
            FormattedValue= RemoveTrailingZeros(convertedValue) + 'M';
        }
        else{
            
            List<String> args = new String[]{'0','number','###,###,##0'};
            String CommaAddedValue = String.format(CurrencyValue.format(), args);
            FormattedValue = CommaAddedValue ;
        }
        return FormattedValue;             
    }
    
    //Current Month calculation
    public string currMonthCalc(Date Todaydt)
    {
        string CurrentMonthName; 
        Integer CurrentMonthNameDay; 
        Integer CurrentYear;
        String CurrentDate; 
        date TodayDate = Todaydt;
        datetime TodayDateTime = Todaydt;
        Date MonthfirstDate = TodayDate.toStartOfMonth();
        Date MonthlastDate = MonthfirstDate.addDays(date.daysInMonth(TodayDate.year() , TodayDate.month())  - 1);
        CurrentMonthName = TodayDateTime.format('MMM','CDT');
        CurrentMonthNameDay = MonthfirstDate.day();
        CurrentYear = MonthlastDate.day();  
        CurrentDate = CurrentMonthName + ' ' + CurrentMonthNameDay + ' - ' + CurrentMonthName + ' ' +CurrentYear ;        
        Integer Month = Date.Today().Month()-1;
        return CurrentDate ;
    }
    
    //YTD date calculation
    public string ytdMonthCalc(Date Todaydt) {
        String returnDt;
        date TodayDate = Todaydt;
        datetime TodayDateTime = Todaydt;
        Date MonthfirstDate = TodayDate.toStartOfMonth();
        Date MonthlastDate = MonthfirstDate.addDays(date.daysInMonth(TodayDate.year() , TodayDate.month())  - 1);
        Integer CurrentYear = MonthlastDate.day();
        String CurrentMonthName = TodayDateTime.format('MMM','CDT');
        returnDt = 'JAN 1'+' - '+ CurrentMonthName + ' '+CurrentYear;

        return returnDt;
    }
    
    //Formatting currency inner method
    public string RemoveTrailingZeros(decimal value) {        
        string strValue = value.toPlainString();
        string afterdecimalvalue = '';
        string BeforeDecimalValue = '';
        String truncated = '';
        string Result = strValue ;
        
        if(strValue.indexof('.') > 0){
            string[] decimalstring =  strValue.split('\\.');
            if(decimalstring.size() > 0){
                //   truncated = decimalstring[1].substring(0,3);
                afterdecimalvalue = decimalstring[1].substring(0,2);
                BeforeDecimalValue = decimalstring[0];
                truncated += BeforeDecimalValue+'.'+afterdecimalvalue ;
                Result = truncated;
            }
        }
        
        if(afterdecimalvalue =='00'){
            Result = BeforeDecimalValue;
        }     
        return Result;          
    }
    
    /*//Parter earning date value construction
    public string formatCurrentDates (Date Todaydt)
    {
        string CurrentMonthName; 
        Integer CurrentMonthNameDay; 
        Integer CurrentYear;
        String CurrentDate; 
        date TodayDate = Todaydt;
        datetime TodayDateTime = Todaydt;
        Date MonthfirstDate = TodayDate.toStartOfMonth();
        Date MonthlastDate = MonthfirstDate.addDays(date.daysInMonth(TodayDate.year() , TodayDate.month())  - 1);
        CurrentMonthName = TodayDateTime.format('MMM','CDT');
        CurrentMonthNameDay = MonthfirstDate.day();
        CurrentYear = MonthlastDate.day();  
        CurrentDate = CurrentMonthName + ' ' + CurrentMonthNameDay + ' - ' + CurrentMonthName + ' ' +CurrentYear ;        
        Integer Month = Date.Today().Month()-1;
        return CurrentDate ;
    }*/
    
    //Calculate Life time cost
    public void calcLifeTimeAllCost() {
        Decimal subscriptionFeeTotal = 0;
        Decimal partnerSubsFeeTotal = 0;
        Decimal timesheetCostTotal = 0;
        Decimal partnerTimShetTotal = 0;
        Set<Id> sTimeShetCostIds = new Set<Id>();
        String timShtQry = '';
        String accServQry = '';
        
        if(AccountId == 'All' && ServiceId =='All') {
            timShtQry = 'SELECT Id,Timesheet__c,Timesheet__r.Account_Services__c,Timesheet__r.Time_Sheet_Cost__c FROM Time_Sheet_Details__c '+
                    'WHERE Status__c = \'Approved\'';
                    
            accServQry = 'SELECT Id,Retainer_Fee_Amount__c,Account__r.Channel_Partner__r.Partner_Commission__c,'+            
                                'Subscription_Fee_Discount__c,Contract_Start_Date__c,Contract_End_Date__c '+
                            'FROM Account_Services__c';                                                
        }else if(AccountId == 'All' && ServiceId !='All') {
            timShtQry = 'SELECT Id,Timesheet__c,Timesheet__r.Account_Services__c,Timesheet__r.Time_Sheet_Cost__c FROM Time_Sheet_Details__c '+                    
                    'WHERE Status__c = \'Approved\' AND Timesheet__r.Account_Services__r.ODS_Services__c = :ServiceId';
                    
            accServQry = 'SELECT Id,Retainer_Fee_Amount__c,Account__r.Channel_Partner__r.Partner_Commission__c,'+            
                                'Subscription_Fee_Discount__c,Contract_Start_Date__c,Contract_End_Date__c '+
                            'FROM Account_Services__c '+
                            'WHERE ODS_Services__c = :ServiceId';                    
        }else if(AccountId != 'All' && ServiceId =='All') {
            timShtQry = 'SELECT Id,Timesheet__c,Timesheet__r.Account_Services__c,Timesheet__r.Time_Sheet_Cost__c FROM Time_Sheet_Details__c '+                   
                    'WHERE Status__c = \'Approved\' AND Timesheet__r.Account_Services__r.Account__c = :AccountId';
                                
            accServQry = 'SELECT Id,Retainer_Fee_Amount__c,Account__r.Channel_Partner__r.Partner_Commission__c,'+            
                                'Subscription_Fee_Discount__c,Contract_Start_Date__c,Contract_End_Date__c '+
                            'FROM Account_Services__c '+
                            'WHERE Account__c = :AccountId';
        }else {
            timShtQry = 'SELECT Id,Timesheet__c,Timesheet__r.Account_Services__c,Timesheet__r.Time_Sheet_Cost__c FROM Time_Sheet_Details__c '+                    
                    'WHERE Status__c = \'Approved\' AND Timesheet__r.Account_Services__r.Account__c = :AccountId AND '+
                    'Timesheet__r.Account_Services__r.ODS_Services__c = :ServiceId';
                                         
            accServQry = 'SELECT Id,Retainer_Fee_Amount__c,Account__r.Channel_Partner__r.Partner_Commission__c,'+            
                                'Subscription_Fee_Discount__c,Contract_Start_Date__c,Contract_End_Date__c '+
                            'FROM Account_Services__c '+
                            'WHERE Account__c = :AccountId AND ODS_Services__c = :ServiceId';
        }
        
        if(String.valueOf(currUser.PortalUserRole__c).equalsIgnoreCase('Partner')) {
            timShtQry += ' AND Timesheet__r.Account_Services__r.Account__r.Channel_Partner__c = :currPartnerId'+
                        ' AND Timesheet__r.Account_Services__r.Account__r.Channel_Partner_Contact__c = :currPartnerCont';
            if(AccountId == 'All' && ServiceId =='All') {
                accServQry += ' WHERE Account__r.Channel_Partner__c = :currPartnerId AND Account__r.Channel_Partner_Contact__c = :currPartnerCont';
            }
            else {
                accServQry += ' AND Account__r.Channel_Partner__c = :currPartnerId AND Account__r.Channel_Partner_Contact__c = :currPartnerCont';
            }
        }
        
        timShtQry += ' ORDER BY CreatedDate DESC LIMIT 50000';
        accServQry += ' ORDER BY CreatedDate DESC LIMIT 50000';
        
        List<Time_Sheet_Details__c> lAllTimeShet = new List<Time_Sheet_Details__c>();
        lAllTimeShet = Database.query(timShtQry);
                                                
        if(!lAllTimeShet.isEmpty()) {
            System.debug('Quried timesheets: '+lAllTimeShet);
            sTimeShetCostIds.clear();                                                
            for(Time_Sheet_Details__c tm:lAllTimeShet) {
                sTimeShetCostIds.add(tm.Timesheet__r.Time_Sheet_Cost__c);
            }
        }
        
        //Subscription fee calculation
        Decimal disct = 0; 
        Date CurrMnth = Date.Today();           
        List<Account_Services__c> lAcServ = new List<Account_Services__c>();
        lAcServ = Database.query(accServQry);
        
        if(!lAcServ.isEmpty()) { 
            Integer monthsBw = 1;               
            for(Account_Services__c acs:lAcServ) {
                //Calculate months between contract start and end date
                if(acs.Contract_Start_Date__c <= CurrMnth && acs.Contract_End_Date__c <= CurrMnth)
                    monthsBw = acs.Contract_Start_Date__c.monthsBetween(acs.Contract_End_Date__c); 
                else if(acs.Contract_Start_Date__c <= CurrMnth && acs.Contract_End_Date__c >= CurrMnth)
                    monthsBw = acs.Contract_Start_Date__c.monthsBetween(CurrMnth);
                else if(acs.Contract_Start_Date__c >= CurrMnth)
                    monthsBw = 1;
                else
                    monthsBw = acs.Contract_Start_Date__c.monthsBetween(CurrMnth);
                
                if(monthsBw <= 0) monthsBw = 1;
                                        
                if(acs.Subscription_Fee_Discount__c == null)
                    disct = 0;
                else
                    disct = acs.Subscription_Fee_Discount__c;
                
                if(acs.Retainer_Fee_Amount__c != null) {
                    subscriptionFeeTotal += ((acs.Retainer_Fee_Amount__c - disct)*monthsBw); //Number of months from Contract start date
                    System.debug('Channel partner_LifetimeSuscription: '+subscriptionFeeTotal+'months bw: '+monthsBw);
                }
                if(acs.Retainer_Fee_Amount__c != null && acs.Account__r.Channel_Partner__r.Partner_Commission__c != null) {
                    partnerSubsFeeTotal += (((acs.Account__r.Channel_Partner__r.Partner_Commission__c * (acs.Retainer_Fee_Amount__c - disct))/100)*monthsBw);
                    System.debug('Channel partner_LifetimePartnerSuscription: '+partnerSubsFeeTotal);
                }
            }
        }                                                    
        
        //Timesheet details calculation
        if(!sTimeShetCostIds.isEmpty()) {
            System.debug('@@Channel Partner_LifeTimeTimShtCostIds: '+sTimeShetCostIds);           
            List<Time_Sheet_Cost__c> lTimShetCost = new List<Time_Sheet_Cost__c>([SELECT Id,ODS_Cost__c,Account_Services__r.Account__r.Channel_Partner__r.Partner_Commission__c
                                                FROM Time_Sheet_Cost__c
                                                WHERE Id IN:sTimeShetCostIds]);
            for(Time_Sheet_Cost__c tms:lTimShetCost) { 
                System.debug('@@Channel Partner_LifeTimeTimShtCost: '+tms.ODS_Cost__c);                
                if(tms.ODS_Cost__c != null) {
                    timesheetCostTotal += tms.ODS_Cost__c;
                    System.debug('Channel partner_LifetimeTimeSheet: '+timesheetCostTotal);                                    
                }
                System.debug('@@Channel Partner_LifeTimeCommission: '+tms.Account_Services__r.Account__r.Channel_Partner__r.Partner_Commission__c);
                if(tms.ODS_Cost__c != null && tms.Account_Services__r.Account__r.Channel_Partner__r.Partner_Commission__c != null) {
                    partnerTimShetTotal += ((tms.ODS_Cost__c * tms.Account_Services__r.Account__r.Channel_Partner__r.Partner_Commission__c)/100);
                    System.debug('Channel partner_LifetimePartnerTimeSheet: '+partnerTimShetTotal);
                }
            }                                                
        }
        
        Decimal lifeTimeTot = subscriptionFeeTotal + timesheetCostTotal;
        Decimal partnerLifeTimeTot = partnerSubsFeeTotal + partnerTimShetTotal;
        OdsLifeTimeCost = '$'+formatCurrencyInDecimal(lifeTimeTot); 
        partnerLifeTimeCost = '$'+formatCurrencyInDecimal(partnerLifeTimeTot);                                              
    }
    
    //Calculate YTD cost
    public void calcYTDCost() {
        Decimal subscriptionFeeTotal = 0;
        Decimal partnerSubsFeeTotal = 0;
        Decimal timesheetCostTotal = 0;
        Decimal partnerTimShetTotal = 0;
        Date currCYStartDate = Date.newInstance(Date.today().year(),1,1);
        Date todayDate = Date.today();
        Set<Id> sTimeShetCostIds = new Set<Id>();
        String timShtQry = '';
        String accServQry = '';
        
        if(AccountId == 'All' && ServiceId =='All') {
            timShtQry = 'SELECT Id,Timesheet__c,Timesheet__r.Account_Services__c,Timesheet__r.Time_Sheet_Cost__c FROM Time_Sheet_Details__c '+                    
                    'WHERE Status__c = \'Approved\''+
                    ' AND Timesheet_Date__c >= :currCYStartDate AND Timesheet_Date__c <= :todayDate';
                    
            accServQry = 'SELECT Id,Retainer_Fee_Amount__c,Account__r.Channel_Partner__r.Partner_Commission__c,'+            
                                'Subscription_Fee_Discount__c,Contract_Start_Date__c,Contract_End_Date__c '+
                            'FROM Account_Services__c ';                    
        }else if(AccountId == 'All' && ServiceId !='All') {
            timShtQry = 'SELECT Id,Timesheet__c,Timesheet__r.Account_Services__c,Timesheet__r.Time_Sheet_Cost__c FROM Time_Sheet_Details__c '+                    
                    'WHERE Status__c = \'Approved\' AND Timesheet__r.Account_Services__r.ODS_Services__c = :ServiceId'+
                    ' AND Timesheet_Date__c >= :currCYStartDate AND Timesheet_Date__c <= :todayDate';
                            
            accServQry = 'SELECT Id,Retainer_Fee_Amount__c,Account__r.Channel_Partner__r.Partner_Commission__c,'+            
                                'Subscription_Fee_Discount__c,Contract_Start_Date__c,Contract_End_Date__c '+
                            'FROM Account_Services__c '+
                            'WHERE ODS_Services__c = :ServiceId';
        }else if(AccountId != 'All' && ServiceId =='All') {
            timShtQry = 'SELECT Id,Timesheet__c,Timesheet__r.Account_Services__c,Timesheet__r.Time_Sheet_Cost__c FROM Time_Sheet_Details__c '+
                    'WHERE Status__c = \'Approved\' AND Timesheet__r.Account_Services__r.Account__c = :AccountId'+
                    ' AND Timesheet_Date__c >= :currCYStartDate AND Timesheet_Date__c <= :todayDate';
                                        
            accServQry = 'SELECT Id,Retainer_Fee_Amount__c,Account__r.Channel_Partner__r.Partner_Commission__c,'+            
                                'Subscription_Fee_Discount__c,Contract_Start_Date__c,Contract_End_Date__c '+
                            'FROM Account_Services__c '+
                            'WHERE Account__c = :AccountId';
        }else {
            timShtQry = 'SELECT Id,Timesheet__c,Timesheet__r.Account_Services__c,Timesheet__r.Time_Sheet_Cost__c FROM Time_Sheet_Details__c '+
                    'WHERE Status__c = \'Approved\' AND Timesheet__r.Account_Services__r.Account__c = :AccountId AND '+
                    'Timesheet__r.Account_Services__r.ODS_Services__c = :ServiceId'+
                    ' AND Timesheet_Date__c >= :currCYStartDate AND Timesheet_Date__c <= :todayDate';
                                                
            accServQry = 'SELECT Id,Retainer_Fee_Amount__c,Account__r.Channel_Partner__r.Partner_Commission__c,'+            
                                'Subscription_Fee_Discount__c,Contract_Start_Date__c,Contract_End_Date__c '+
                            'FROM Account_Services__c '+
                            'WHERE Account__c = :AccountId AND ODS_Services__c = :ServiceId';
        }
        
        if(String.valueOf(currUser.PortalUserRole__c).equalsIgnoreCase('Partner')) {
            timShtQry += ' AND Timesheet__r.Account_Services__r.Account__r.Channel_Partner__c = :currPartnerId'+
                        ' AND Timesheet__r.Account_Services__r.Account__r.Channel_Partner_Contact__c = :currPartnerCont';
            if(AccountId == 'All' && ServiceId =='All') {
                accServQry += ' WHERE Account__r.Channel_Partner__c = :currPartnerId AND Account__r.Channel_Partner_Contact__c = :currPartnerCont';
            }
            else {
                accServQry += ' AND Account__r.Channel_Partner__c = :currPartnerId AND Account__r.Channel_Partner_Contact__c = :currPartnerCont';
            }
        }
        
        timShtQry += ' ORDER BY CreatedDate DESC LIMIT 50000';
        accServQry += ' ORDER BY CreatedDate DESC LIMIT 50000';
        
        List<Time_Sheet_Details__c> lAllTimeShet = new List<Time_Sheet_Details__c>();
        lAllTimeShet = Database.query(timShtQry);
       
        if(!lAllTimeShet.isEmpty()) {
            sTimeShetCostIds.clear();                                                
            for(Time_Sheet_Details__c tm:lAllTimeShet) {
                sTimeShetCostIds.add(tm.Timesheet__r.Time_Sheet_Cost__c);
            }
        }
        
        //Subscription fee calculation                
        Decimal disct = 0;
        Date StartMnthOfCY = Date.newInstance(Date.today().year(),1,1); //January 1, Current year
        Date CurrMnthOfCY = Date.Today();
        
        List<Account_Services__c> lAcServ = new List<Account_Services__c>();
        lAcServ = Database.query(accServQry);
        
        if(!lAcServ.isEmpty()) {
            Integer mnthsBw = 1;
            for(Account_Services__c acs:lAcServ) {
                //Calculate whether contract end and start date resides inside curent calendar year
                if(acs.Contract_End_Date__c <= CurrMnthOfCY && acs.Contract_Start_Date__c <= StartMnthOfCY) 
                    mnthsBw = acs.Contract_Start_Date__c.monthsBetween(StartMnthOfCY);
                else if(acs.Contract_End_Date__c <= CurrMnthOfCY && acs.Contract_Start_Date__c >= StartMnthOfCY)
                    mnthsBw = acs.Contract_Start_Date__c.monthsBetween(acs.Contract_End_Date__c);
                else if(acs.Contract_End_Date__c >= CurrMnthOfCY && acs.Contract_Start_Date__c >= StartMnthOfCY)
                    mnthsBw = acs.Contract_Start_Date__c.monthsBetween(CurrMnthOfCY);                       
                else
                    mnthsBw = CurrMnthOfCY.monthsBetween(StartMnthOfCY);
                //If months between is zero,set to 1 to avoid 0 mulitiplication
                if(mnthsBw <= 0) mnthsBw = 1;
                        
                if(acs.Subscription_Fee_Discount__c == null)
                    disct = 0;
                else
                    disct = acs.Subscription_Fee_Discount__c;
                
                if(acs.Retainer_Fee_Amount__c != null) {
                    subscriptionFeeTotal += ((acs.Retainer_Fee_Amount__c - disct)*mnthsBw); //Subscription fee for current Calender year months
                    System.debug('Channel partner_YTDSuscription: '+subscriptionFeeTotal);
                }
                if(acs.Retainer_Fee_Amount__c != null && acs.Account__r.Channel_Partner__r.Partner_Commission__c != null) {
                    partnerSubsFeeTotal += (((acs.Account__r.Channel_Partner__r.Partner_Commission__c * (acs.Retainer_Fee_Amount__c - disct))/100)*mnthsBw);
                    System.debug('Channel partner_YTDPartnerSuscription: '+partnerSubsFeeTotal);
                }
            }
        }
        
        //Timesheet details calculation
        if(!sTimeShetCostIds.isEmpty()) {
            List<Time_Sheet_Cost__c> lTimShetCost = new List<Time_Sheet_Cost__c>([SELECT Id,ODS_Cost__c,Account_Services__r.Account__r.Channel_Partner__r.Partner_Commission__c
                                                FROM Time_Sheet_Cost__c
                                                WHERE Id IN:sTimeShetCostIds]);
            for(Time_Sheet_Cost__c tms:lTimShetCost) {
                System.debug('Channel partner_YTDTimShtCost: '+tms.ODS_Cost__c);
                if(tms.ODS_Cost__c != null) {
                    timesheetCostTotal += tms.ODS_Cost__c;
                    System.debug('Channel partner_YTDTimeSheet: '+timesheetCostTotal);
                }
                if(tms.ODS_Cost__c != null && tms.Account_Services__r.Account__r.Channel_Partner__r.Partner_Commission__c != null) {
                    partnerTimShetTotal += ((tms.ODS_Cost__c * tms.Account_Services__r.Account__r.Channel_Partner__r.Partner_Commission__c)/100);
                    System.debug('Channel partner_YTDPartnerTimeSheet: '+partnerTimShetTotal);
                }
            }                                                
        }
        
        Decimal ytdTot = subscriptionFeeTotal + timesheetCostTotal;
        Decimal partnerYTDTot = partnerSubsFeeTotal + partnerTimShetTotal;
        OdsYTDCost = '$'+formatCurrencyInDecimal(ytdTot); 
        PartnerYTDCost = '$'+formatCurrencyInDecimal(partnerYTDTot);                                              
    }
    
    //Calculate This month cost
    public void calcThisMonthCost() {
        Decimal subscriptionFeeTotal = 0;
        Decimal partnerSubsFeeTotal = 0;
        Decimal timesheetCostTotal = 0;
        Decimal partnerTimShetTotal = 0;        
        Date todayDate = Date.today();
        Date currMonthStartDate = todayDate.toStartOfMonth();
        Set<Id> sTimeShetCostIds = new Set<Id>();
        String timShtQry = '';
        String accServQry = '';
        
        if(AccountId == 'All' && ServiceId =='All') {
            timShtQry = 'SELECT Id,Timesheet__c,Timesheet__r.Account_Services__c,Timesheet__r.Time_Sheet_Cost__c FROM Time_Sheet_Details__c '+
                    'WHERE Status__c = \'Approved\''+
                    ' AND Timesheet_Date__c >= :currMonthStartDate AND Timesheet_Date__c <= :todayDate';
                           
            accServQry = 'SELECT Id,Retainer_Fee_Amount__c,Account__r.Channel_Partner__r.Partner_Commission__c,'+            
                                'Subscription_Fee_Discount__c,Contract_Start_Date__c,Contract_End_Date__c '+
                            'FROM Account_Services__c '; 
        }else if(AccountId == 'All' && ServiceId !='All') {
            timShtQry = 'SELECT Id,Timesheet__c,Timesheet__r.Account_Services__c,Timesheet__r.Time_Sheet_Cost__c FROM Time_Sheet_Details__c '+                    
                    'WHERE Status__c = \'Approved\' AND Timesheet__r.Account_Services__r.ODS_Services__c = :ServiceId'+
                    ' AND Timesheet_Date__c >= :currMonthStartDate AND Timesheet_Date__c <= :todayDate';
                                  
            accServQry = 'SELECT Id,Retainer_Fee_Amount__c,Account__r.Channel_Partner__r.Partner_Commission__c,'+            
                                'Subscription_Fee_Discount__c,Contract_Start_Date__c,Contract_End_Date__c '+
                            'FROM Account_Services__c '+
                            'WHERE ODS_Services__c = :ServiceId';
        }else if(AccountId != 'All' && ServiceId =='All') {
            timShtQry = 'SELECT Id,Timesheet__c,Timesheet__r.Account_Services__c,Timesheet__r.Time_Sheet_Cost__c FROM Time_Sheet_Details__c '+                    
                    'WHERE Status__c = \'Approved\' AND Timesheet__r.Account_Services__r.Account__c = :AccountId'+
                    ' AND Timesheet_Date__c >= :currMonthStartDate AND Timesheet_Date__c <= :todayDate';
                                          
            accServQry = 'SELECT Id,Retainer_Fee_Amount__c,Account__r.Channel_Partner__r.Partner_Commission__c,'+            
                                'Subscription_Fee_Discount__c,Contract_Start_Date__c,Contract_End_Date__c '+
                            'FROM Account_Services__c '+
                            'WHERE Account__c = :AccountId';
        }else {
            timShtQry = 'SELECT Id,Timesheet__c,Timesheet__r.Account_Services__c,Timesheet__r.Time_Sheet_Cost__c FROM Time_Sheet_Details__c '+                    
                    'WHERE Status__c = \'Approved\' AND Timesheet__r.Account_Services__r.Account__c = :AccountId AND '+
                    'Timesheet__r.Account_Services__r.ODS_Services__c = :ServiceId'+
                    ' AND Timesheet_Date__c >= :currMonthStartDate AND Timesheet_Date__c <= :todayDate';
                                                      
            accServQry = 'SELECT Id,Retainer_Fee_Amount__c,Account__r.Channel_Partner__r.Partner_Commission__c,'+            
                                'Subscription_Fee_Discount__c,Contract_Start_Date__c,Contract_End_Date__c '+
                            'FROM Account_Services__c '+
                            'WHERE Account__c = :AccountId AND ODS_Services__c = :ServiceId';
        }
        
        if(String.valueOf(currUser.PortalUserRole__c).equalsIgnoreCase('Partner')) {
            timShtQry += ' AND Timesheet__r.Account_Services__r.Account__r.Channel_Partner__c = :currPartnerId'+
                        ' AND Timesheet__r.Account_Services__r.Account__r.Channel_Partner_Contact__c = :currPartnerCont';
            if(AccountId == 'All' && ServiceId =='All') {
                accServQry += ' WHERE Account__r.Channel_Partner__c = :currPartnerId AND Account__r.Channel_Partner_Contact__c = :currPartnerCont';
            }
            else {
                accServQry += ' AND Account__r.Channel_Partner__c = :currPartnerId AND Account__r.Channel_Partner_Contact__c = :currPartnerCont';
            }
        }
        
        timShtQry += ' ORDER BY CreatedDate DESC LIMIT 50000';
        accServQry += ' ORDER BY CreatedDate DESC LIMIT 50000';
        
        List<Time_Sheet_Details__c> lAllTimeShet = new List<Time_Sheet_Details__c>();
        lAllTimeShet = Database.query(timShtQry);
        
        if(!lAllTimeShet.isEmpty()) {
            sTimeShetCostIds.clear();                                                
            for(Time_Sheet_Details__c tm:lAllTimeShet) {
                sTimeShetCostIds.add(tm.Timesheet__r.Time_Sheet_Cost__c);
            }
        }
        
        //Subscription fee calculation        
        Decimal disct = 0;
        List<Account_Services__c> lAcServ = new List<Account_Services__c>();
        lAcServ = Database.query(accServQry);
                                                    
        if(!lAcServ.isEmpty()) {
            for(Account_Services__c acs:lAcServ) {
                if(acs.Subscription_Fee_Discount__c == null)
                    disct = 0;
                else
                    disct = acs.Subscription_Fee_Discount__c;
                    
                if(acs.Retainer_Fee_Amount__c != null) {
                    subscriptionFeeTotal += (acs.Retainer_Fee_Amount__c - disct); //Subscription fee is always for single month
                    System.debug('Channel partner_ThisMonthSubscription: '+subscriptionFeeTotal);
                }
                if(acs.Retainer_Fee_Amount__c != null && acs.Account__r.Channel_Partner__r.Partner_Commission__c != null) {
                    partnerSubsFeeTotal += ((acs.Account__r.Channel_Partner__r.Partner_Commission__c * (acs.Retainer_Fee_Amount__c - disct))/100);
                    System.debug('Channel partner_ThisMonthPartnerSubscription: '+partnerSubsFeeTotal);
                }
            }
        } 
        
        //Timesheet details calculation
        if(!sTimeShetCostIds.isEmpty()) {
            List<Time_Sheet_Cost__c> lTimShetCost = new List<Time_Sheet_Cost__c>([SELECT Id,ODS_Cost__c,Account_Services__r.Account__r.Channel_Partner__r.Partner_Commission__c
                                                FROM Time_Sheet_Cost__c
                                                WHERE Id IN:sTimeShetCostIds]);
            for(Time_Sheet_Cost__c tms:lTimShetCost) {
                System.debug('Channel partner_MonthTimShtCost: '+tms.ODS_Cost__c);
                if(tms.ODS_Cost__c != null) {
                    timesheetCostTotal += tms.ODS_Cost__c;
                    System.debug('Channel partner_ThisMonthTimeSheet: '+timesheetCostTotal);
                }
                if(tms.ODS_Cost__c != null && tms.Account_Services__r.Account__r.Channel_Partner__r.Partner_Commission__c != null) {
                    partnerTimShetTotal += ((tms.ODS_Cost__c * tms.Account_Services__r.Account__r.Channel_Partner__r.Partner_Commission__c)/100);
                    System.debug('Channel partner_ThisMonthPartnerTimeSheet: '+partnerTimShetTotal);
                }
            }                                                
        }
        
        Decimal thisMnthTot = subscriptionFeeTotal + timesheetCostTotal;
        Decimal partnerThisMnthTot = partnerSubsFeeTotal + partnerTimShetTotal;
        OdsThisMonthCost = '$'+formatCurrencyInDecimal(thisMnthTot); 
        PartnerThisMnthCost = '$'+formatCurrencyInDecimal(partnerThisMnthTot);                                              
    }
        
    //Construct chart data for Time and Money
    public void getRevenueCalcForTnMChart(string slctdAccId, string slctdSrvceId) {
        String aggrQry = '';
        if(slctdAccId == 'All' && slctdSrvceId == 'All') {
            aggrQry = 'SELECT sum(Timesheet__r.Time_Sheet_Cost__r.ODS_Cost__c) odsCost,Timesheet_Date__c  TimesheetDate,Timesheet__r.Account_Services__r.Account__C Account,'+ 
                    'Timesheet__r.Account_Services__r.ODS_Services__c Service,min(Timesheet__r.Account_Services__r.Account__r.Channel_Partner__r.Partner_Commission__c) commission '+
                'FROM Time_Sheet_Details__c '+
                'WHERE Status__c = \'Approved\' ';
        }else if(slctdAccId == 'All' && slctdSrvceId != 'All') {
            aggrQry = 'SELECT sum(Timesheet__r.Time_Sheet_Cost__r.ODS_Cost__c) odsCost,Timesheet_Date__c  TimesheetDate,Timesheet__r.Account_Services__r.Account__C Account, '+ 
                    'Timesheet__r.Account_Services__r.ODS_Services__c Service,min(Timesheet__r.Account_Services__r.Account__r.Channel_Partner__r.Partner_Commission__c) commission '+
                'FROM Time_Sheet_Details__c  '+
                'WHERE Timesheet__r.Account_Services__r.ODS_Services__c =:slctdSrvceId '+
                    'AND Status__c = \'Approved\' ';
        }else if(slctdAccId != 'All' && slctdSrvceId == 'All') {
            aggrQry = 'SELECT sum(Timesheet__r.Time_Sheet_Cost__r.ODS_Cost__c) odsCost,Timesheet_Date__c  TimesheetDate,Timesheet__r.Account_Services__r.Account__C Account, '+
                    'Timesheet__r.Account_Services__r.ODS_Services__c Service,min(Timesheet__r.Account_Services__r.Account__r.Channel_Partner__r.Partner_Commission__c) commission '+
                'FROM Time_Sheet_Details__c '+ 
                'WHERE Timesheet__r.Account_Services__r.Account__C =:slctdAccId '+
                    'AND Status__c = \'Approved\' ';
        }else {
            aggrQry = 'SELECT sum(Timesheet__r.Time_Sheet_Cost__r.ODS_Cost__c) odsCost,Timesheet_Date__c  TimesheetDate,Timesheet__r.Account_Services__r.Account__C Account, '+ 
                    'Timesheet__r.Account_Services__r.ODS_Services__c Service,min(Timesheet__r.Account_Services__r.Account__r.Channel_Partner__r.Partner_Commission__c) commission '+
                'FROM Time_Sheet_Details__c '+
                'WHERE Timesheet__r.Account_Services__r.Account__C =:slctdAccId '+ 
                    'AND Timesheet__r.Account_Services__r.ODS_Services__c =:slctdSrvceId '+
                    'AND Status__c = \'Approved\' ';
        }
        
        if(String.valueOf(currUser.PortalUserRole__c).equalsIgnoreCase('Partner')) {
            aggrQry += ' AND Timesheet__r.Account_Services__r.Account__r.Channel_Partner__c = :currPartnerId '+
                        ' AND Timesheet__r.Account_Services__r.Account__r.Channel_Partner_Contact__c = :currPartnerCont ';               
        }
        
        aggrQry += ' GROUP BY Timesheet_Date__c,Timesheet__r.Account_Services__r.Account__C,Timesheet__r.Account_Services__r.ODS_Services__c '+                    
                   ' ORDER BY Timesheet_Date__c';
                   
        List<AggregateResult> lTsd = new List<AggregateResult>();
        lTsd = Database.query(aggrQry);
        
        List<RevenueClass> lAgrRev = new List<RevenueClass>();        
        if(!lTsd.isEmpty()) {
            for(AggregateResult agr:lTsd) {
                Decimal odsCostAggRes = (Decimal) agr.get('odsCost');
                Decimal commiAggRes = (Decimal) agr.get('commission');
                Date timshtdateAggRes = (Date) agr.get('TimesheetDate');
                String formatChartDate = timshtdateAggRes.format();
                Id accAggRes = (Id) agr.get('Account');
                Id servAggRes = (Id) agr.get('Service');
                //Confirm the partner commision is not null
                    commiAggRes = commiAggRes == null ? 0 : commiAggRes;
                Decimal partRev = ((odsCostAggRes * commiAggRes) / 100);
                lAgrRev.add(new RevenueClass(partRev,formatChartDate,accAggRes,servAggRes));
            }        
        }
        
        TimeshtJSONtoBind = JSON.serialize(lAgrRev);
        System.debug('TnMJSON: '+TimeshtJSONtoBind);
    }
    
    //Construct chart data for Subscription
    public void getRevenueCalcForSubsChart(string slctdAccId, string slctdSrvceId) {
        String accSerQry = '';
        if(slctdAccId == 'All' && slctdSrvceId == 'All') {
            accSerQry = 'SELECT Id,Retainer_Fee_Amount__c,Account__r.Channel_Partner__r.Partner_Commission__c,ODS_Services__c,Account__c, '+
                    'Subscription_Fee_Discount__c,Contract_End_Date__c,Contract_Start_Date__c '+
                'FROM Account_Services__c ';
        }else if(slctdAccId == 'All' && slctdSrvceId != 'All') {
            accSerQry = 'SELECT Id,Retainer_Fee_Amount__c,Account__r.Channel_Partner__r.Partner_Commission__c,ODS_Services__c,Account__c, '+
                    'Subscription_Fee_Discount__c,Contract_End_Date__c,Contract_Start_Date__c '+
                'FROM Account_Services__c '+
                'WHERE ODS_Services__c = :slctdSrvceId';
        }else if(slctdAccId != 'All' && slctdSrvceId == 'All') {
            accSerQry = 'SELECT Id,Retainer_Fee_Amount__c,Account__r.Channel_Partner__r.Partner_Commission__c,ODS_Services__c,Account__c, '+
                    'Subscription_Fee_Discount__c,Contract_End_Date__c,Contract_Start_Date__c '+
                'FROM Account_Services__c '+
                'WHERE Account__c = :slctdAccId';
        }else {
            accSerQry = 'SELECT Id,Retainer_Fee_Amount__c,Account__r.Channel_Partner__r.Partner_Commission__c,ODS_Services__c,Account__c, '+
                    'Subscription_Fee_Discount__c,Contract_End_Date__c,Contract_Start_Date__c '+
                'FROM Account_Services__c '+
                'WHERE Account__c = :slctdAccId AND ODS_Services__c = :slctdSrvceId';
        }
        
        if(String.valueOf(currUser.PortalUserRole__c).equalsIgnoreCase('Partner')) {
            if(slctdAccId == 'All' && slctdSrvceId == 'All') { 
                accSerQry += ' WHERE Account__r.Channel_Partner__c = :currPartnerId AND Account__r.Channel_Partner_Contact__c = :currPartnerCont';
            }else {
                accSerQry += ' AND Account__r.Channel_Partner__c = :currPartnerId AND Account__r.Channel_Partner_Contact__c = :currPartnerCont';
            }
        }
        
        List<Account_Services__c> lAccSer = new List<Account_Services__c>();
        lAccSer = Database.query(accSerQry);
        
        List<RevenueClass> lSubsRev = new List<RevenueClass>();
        //Process all Account services for subscription fee
        if(!lAccSer.isEmpty()) {
            Decimal disct = 0;
            Decimal partnerSubsFeeTotal = 0;            
            for(Account_Services__c acserv:lAccSer) {
                if(acserv.Subscription_Fee_Discount__c == null)
                    disct = 0;
                else
                    disct = acserv.Subscription_Fee_Discount__c;
                
                if(acserv.Retainer_Fee_Amount__c != null && acserv.Account__r.Channel_Partner__r.Partner_Commission__c != null) {
                    partnerSubsFeeTotal = ((acserv.Account__r.Channel_Partner__r.Partner_Commission__c * (acserv.Retainer_Fee_Amount__c - disct))/100);
                }else {
                    partnerSubsFeeTotal = 0;
                }
                
                //Loop chart date for comparison - 1st day of month is considered to avoid month and day mismatch
                Date formatLoopChartDate = Date.newInstance(acserv.Contract_Start_Date__c.year(),acserv.Contract_Start_Date__c.month(),1);
                
                //Add records for each subscription month from Contract start till end
                Date destinationDate = System.today() <= acserv.Contract_End_Date__c ? System.today() : acserv.Contract_End_Date__c; 
                //for(Date j = formatLoopChartDate; j <= acserv.Contract_End_Date__c; j = j.addMonths(1)) {
                for(Date j = formatLoopChartDate; j <= destinationDate; j = j.addMonths(1)) {
                    Date retChartDate = Date.newInstance(j.year(),j.month(),j.day());
                    String formatChartDate = retChartDate.format();
                    lSubsRev.add(new RevenueClass(partnerSubsFeeTotal,formatChartDate,acserv.Account__c,acserv.ODS_Services__c));                   
                }
            }
        }
        
        SubscJSONtoBind = JSON.serialize(lSubsRev);
        System.debug('SubscJSON: '+SubscJSONtoBind);
    }
    
    //Wrapper class for Chart data construction
    public class RevenueClass
    {
        public decimal partnerRevenue {get;set;}
        public String chartDate {get;set;}
        public Id acc {get;set;}
        public Id odsService {get;set;}
        public RevenueClass(decimal partRev,String chDate,Id ac,Id serv) {
            this.partnerRevenue = partRev;
            this.chartDate = chDate;
            this.acc = ac;
            this.odsService = serv;
        }
    }
    
}
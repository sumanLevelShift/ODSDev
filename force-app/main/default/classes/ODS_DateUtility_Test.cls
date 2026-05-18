@isTest
private class ODS_DateUtility_Test
{
    static testMethod void getDaystoAddForSundayByDoW_Test()
    {
        Test.startTest();
        ODS_DateUtility.getDaystoAddForSundayByDoW('Mon');
        ODS_DateUtility.getDaystoAddForSundayByDoW('Tue');
        ODS_DateUtility.getDaystoAddForSundayByDoW('Wed');
        ODS_DateUtility.getDaystoAddForSundayByDoW('Thu');
        ODS_DateUtility.getDaystoAddForSundayByDoW('Fri');
        ODS_DateUtility.getDaystoAddForSundayByDoW('Sat');
        ODS_DateUtility.getDaystoAddForSundayByDoW('Sun');
        Test.stopTest();
    }
    
    static testMethod void GetWeekBoundaryDatesByMonth_Test()
    {
        Test.startTest();
        DateTime startDtTme = DateTime.parse('01/11/2016 12:00 AM');
        DateTime EndDtTme = DateTime.parse('01/12/2016 12:00 AM');
        ODS_DateUtility.GetWeekBoundaryDatesByMonth(startDtTme);
        ODS_DateUtility.calculateWeekends(startDtTme,EndDtTme);
        ODS_DateUtility.getDaystoAddForSundayByDoW('Mon');
        ODS_DateUtility.getDaystoAddForSundayByDoW('Tue');
        ODS_DateUtility.getDaystoAddForSundayByDoW('Wed');
        ODS_DateUtility.getDaystoAddForSundayByDoW('Thu');
        ODS_DateUtility.getDaystoAddForSundayByDoW('Fri');
        ODS_DateUtility.getDaystoAddForSundayByDoW('Sat');
        ODS_DateUtility.getDaystoAddForSundayByDoW('Sun');
        ODS_DateUtility.getHoursByDayofDate('Mon');
        ODS_DateUtility.getHoursByDayofDate('Tue');
        ODS_DateUtility.getHoursByDayofDate('Wed');
        ODS_DateUtility.getHoursByDayofDate('Thu');
        ODS_DateUtility.getHoursByDayofDate('Fri');
        ODS_DateUtility.getHoursByDayofDate('Sat');
        ODS_DateUtility.getHoursByDayofDate('Sun');
        ODS_DateUtility.getHoursByDays(0);
        ODS_DateUtility.getHoursByDays(1);
        ODS_DateUtility.getHoursByDays(2);
        ODS_DateUtility.getHoursByDays(3);
        ODS_DateUtility.getHoursByDays(4);
        Test.stopTest();
    }
    
    static testMethod void getNextBusinessDates(){
        Date srDate = Date.newInstance(2021, 5, 28);
        Date nextBusinessDate = ODS_DateUtility.getNextBusinessDate(srDate);
        system.debug(nextBusinessDate);
        system.assertEquals(1, nextBusinessDate.day());
    }
  
    static testMethod void getSRDate(){
        Date srDate = Date.newInstance(2021, 5, 9);
        Date newSRDate = ODS_DateUtility.getSRDate('Weekly', srDate);
        system.assertEquals(3, newSRDate.day());
    }
}
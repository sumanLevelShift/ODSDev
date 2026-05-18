@isTest
public class TipsInvoiceStagingRestApiTest {
    @isTest
    public static void insertInvoiceStaging(){
        Test.startTest();
        Date startDate=system.today();
        Date endDate=startDate.addMonths(1);
        TipsInvoiceStagingRestApi.insertInvoiceStaging('08/01/2023','08/30/2023','1234','test','file.pdf');
        TipsInvoiceStagingRestApi.insertInvoiceStaging('08/01/2023','08/30/2023','1234','test','file.pdf');
        TipsInvoiceStagingRestApi.insertInvoiceStaging('08 / 01 /2023',string.valueOf(endDate),'1234','test','file.pdf');
        Test.stopTest();
    }
}
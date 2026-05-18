@isTest
public class InvoiceEmailInfoRestApiTest {
    @isTest
    public static void invoiceSubmitted(){
            Test.startTest();
            InvoiceEmailInfoRestApi.invoiceStagingEmailInfo('08/01/2023', '08/30/2023', '1234', 'test@demandblue.com', 'test@demandblue.com', 'body', 'subject');
            InvoiceEmailInfoRestApi.invoiceStagingEmailInfo('08/01/2023', '08/30/2023', '1234', 'test@demandblue.com', 'test@demandblue.com', 'body', 'subject');
            InvoiceEmailInfoRestApi.invoiceStagingEmailInfo('08 / 01 /2023', '08/30/2023', '1234', 'test@demandblue.com', 'test@demandblue.com', 'body', 'subject');
            Test.stopTest();
    }
}
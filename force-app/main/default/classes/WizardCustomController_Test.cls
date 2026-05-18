@isTest
public class WizardCustomController_Test{
    public static testmethod void testSimulation(){
        WizardCustomController wc = new WizardCustomController();
        wc.goToFirstPage();
        wc.goToSecondPage();
        wc.finish();
    }
}
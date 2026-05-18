public class WizardCustomController {

    public PageReference finish() {
        return null;
    }


    public PageReference goToFirstPage() {
        return Page.VFPage1forWizard;
    }


    public PageReference goToSecondPage() {
        return Page.VFPage2forWizard;
    }

}
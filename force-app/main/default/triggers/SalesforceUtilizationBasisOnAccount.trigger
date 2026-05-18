trigger SalesforceUtilizationBasisOnAccount on Account (after update) {
    if(Trigger.isAfter && SalesforceUtilizationBasisHelper.firstRun && Trigger.isUpdate){
        SalesforceUtilizationBasisHelper.firstRun=false;
        SalesforceUtilizationBasisHelper.updateOverAllUsage(Trigger.New);
    }
}
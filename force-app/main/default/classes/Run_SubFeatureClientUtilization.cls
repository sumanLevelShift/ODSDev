public class Run_SubFeatureClientUtilization {
    @AuraEnabled
    public static Boolean runJob()
    {
        ProdSubfeatureClientUsageSchedular subfeatureUsage = new ProdSubfeatureClientUsageSchedular(); 
        subfeatureUsage.execute(null);
        return true;
    }
}
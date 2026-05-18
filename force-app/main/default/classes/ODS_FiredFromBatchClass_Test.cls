@isTest
public class ODS_FiredFromBatchClass_Test
{
    public static testMethod void testGlobalFlag() {        
        Boolean getFlag = ODS_FiredFromBatchClass.getFiredFromBatch();
        ODS_FiredFromBatchClass.setFiredFromBatch();
        ODS_FiredFromBatchClass.resetFiredFromBatch();
    }
}
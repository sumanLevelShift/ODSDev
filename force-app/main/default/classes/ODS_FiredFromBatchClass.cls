global class ODS_FiredFromBatchClass
{ 
    @testVisible public static boolean isFiredFromBatchApex = false; 
    public static boolean getFiredFromBatch()
    { 
        return isFiredFromBatchApex; 
    }

    public static void setFiredFromBatch() 
    {   
        isFiredFromBatchApex = true;   
    }
    
    public static void resetFiredFromBatch() 
    {   
        isFiredFromBatchApex = false;   
    } 
}
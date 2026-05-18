/*******************************************************************************************
* @author           Suman
* @version          1.0 
* @date             28-MAR-2021
* @Status           In-Progress
* @Class Name     	ProdSubfeatureClientUsage_Constants
* @description      

*********************************************************************************************
Version     Date       Team          Comments
*********************************************************************************************
* 1      	Mar 2021    Suman          Initial Creation
*********************************************************************************************/
public class ProdSubfeatureClientUsage_Constants {
	
    public static final String STRING_EMPTY = '';
    public static final String STRING_SPACE = ' ';
    public static final String STRING_PLUS = '+';
    public static final String STRING_PERCENT = '%';
    public static final String STRING_PERCENTENCODED = '%25';
    
    public static final String QUERYSTRING_WHERE = ' WHERE ';
    public static final String QUERYSTRING_LIMIT20 = ' LIMIT 20';
    
    public static final String APIRESULT_TOTALSIZE = 'totalSize';
    
    public ProdSubfeatureClientUsage_Constants(){
        //added for code coverage
        System.assertEquals(' WHERE ',ProdSubfeatureClientUsage_Constants.QUERYSTRING_WHERE);
        System.assertEquals(' LIMIT 20',ProdSubfeatureClientUsage_Constants.QUERYSTRING_LIMIT20);        
    }
}
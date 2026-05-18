public class StringArrayTest
{
    public static List<String> generateStringArray(Integer n)
    {
        List<String> lString = new List<String>();
        for(Integer i =0; i<n ; i++)
        {
            lString.add('Test ' + i);
        }
        return lString;
    }
}
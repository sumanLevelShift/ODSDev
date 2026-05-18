@isTest
public class TechnologytermreportsTest {
    @isTest
    public static void testMethod1(){
        List<Technology_Terms__mdt> technologyList =[SELECT Label FROM Technology_Terms__mdt];
        List<string> nameList=New List<String>();
        List<Task> taskList=new List<Task>();
        integer i=0;
        for(Technology_Terms__mdt s:technologyList){
            nameList.add(s.Label);
            Task t=new Task();
            t.Subject='test '+i;
            t.Description=s.Label;
            taskList.add(t);
        }
        
        insert taskList;
        
        Task t1=new Task();
        t1.Subject='test Demo';
        t1.Description='CPQ';
        insert t1;
        t1.Description='FSL';
        update t1;
        
}
}
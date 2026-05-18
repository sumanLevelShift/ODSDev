@isTest
public class UpdateFieldForExistingRecordTest {
    @isTest
    public static void updatefieldtestMethod(){
        List<Technology_Terms__mdt> technologyList =[SELECT Label FROM Technology_Terms__mdt];
        List<string> nameList=New List<String>();
        List<Task> taskList=new List<Task>();
        
            integer i=0;
            for(Technology_Terms__mdt s:technologyList){
                nameList.add(s.Label);
                Task t=new Task();
                    t.Subject='SampleTest'+i;
                    t.Campaign__c = 'ODS Force.com' ;
                    t.Created_by_Rep__c ='Ilayamaran D';
                    t.Description=s.Label;
                    taskList.add(t);
                }
            
            
            insert taskList;
            
        
        Test.startTest();
        UpdateFieldForExistingRecord c = new UpdateFieldForExistingRecord();
        c.errorMap.put(taskList[0].id, 'TEstsetstss');
        Database.executeBatch(c);
        c.execute(null, taskList);
        Test.stopTest();
    }
}
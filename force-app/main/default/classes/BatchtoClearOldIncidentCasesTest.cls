@isTest
public class BatchtoClearOldIncidentCasesTest {
    @isTest
    Public static void Testone()
    {
          string old = Label.Incident_Case_Owner;
        
        Group grp =[SELECT Id,Name,DeveloperName  FROM Group WHERE Name  =:old  limit 1];
        list <case> listcas = new list<case>();
        
        Case tsObj = new Case();
        tsObj.Status = 'New';
        tsObj.Origin = 'Email';
        tsObj.Subject = 'BatchtoClearOldIncidentCasesTest';
        tsObj.OwnerId = grp.Id;
        listcas.add(tsobj);
        insert listcas;
        Datetime testday = Datetime.now().addDays(-185);
        Test.setCreatedDate(listcas[0].Id, testday); 
        update listcas;
        
        
        Test.startTest();
       
        BatchtoClearOldIncidentCasesscheduler testings = new BatchtoClearOldIncidentCasesscheduler();
        String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testings );
        
        Test.stopTest();
        
    }
}
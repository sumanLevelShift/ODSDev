@isTest
public class UpdateInstanceNameTest
{
    static testMethod void insertCase() 
	{
        
        Case c = new Case();
        C.Status = 'New';
        C.Origin = 'Email';
		c.Priority = 'Medium';
        c.subject='UPDATED - Incident 6173 - Performance Degradation - Asynchronous Processing';
		c.SuppliedEmail = 'alerts@mail.salesforce.com';
        c.Description = 'Incident Information Impacted Instances: NA73\n'+ 'Impacted Services: Core Service ';
        insert c;  
    }
}
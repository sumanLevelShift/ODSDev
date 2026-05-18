@isTest
public class AnimalLocatorTest {
    @isTest static  void testGetCallout() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetAnimalLocator');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        // Call method to test
        String animalName = AnimalLocator.getAnimalNameById(2);
        System.assertEquals('bear',animalName);          
    }   
    @isTest static void testGetCalloutUsingHttpCalloutMock() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        String animalName = AnimalLocator.getAnimalNameById(2);
        // Verify that the response received contains fake values
        System.assertEquals('bear',animalName);        
    } 
}
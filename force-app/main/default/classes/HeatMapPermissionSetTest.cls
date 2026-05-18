@isTest
public class HeatMapPermissionSetTest {
    @isTest
    public static void createPermissionSetTest(){        
        Test.startTest();
        HeatMapPermissionSet.createPermissionSet('Test Permission Set','Test_Permission_Set');
        HeatMapPermissionSet.removePermissionSet('Test_Permission_Set');
        system.assertEquals('Test Permission Set', 'Test Permission Set');
        Test.stopTest();
    }
}
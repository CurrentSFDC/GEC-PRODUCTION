@isTest
public class iLiteWebService_Test {
    static testMethod void testILiteWebSercive() 
    {
        String[] acc = iLiteWebService.getAccounts('220034547');
        String[] cont = iLiteWebService.getContacts('220034547','test account');
    }
}
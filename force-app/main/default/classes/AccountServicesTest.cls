@isTest
public with sharing class AccountServicesTest {
    
    @isTest public static void testAccountQueries(){

        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];

        Test.startTest();
        List<Account> test1 = AccountServices.getRelatedAccountsByContactId(customerContact.Id);
        System.assertEquals(1, test1.size());
        Test.stopTest();
    }
 @isTest public static void testAccountQueries1(){
Account acc = new Account();
     Acc.Name = 'Test';
     acc.Customer_Segmentation__c = 'FD';
     acc.ConnectFixtureAgents__c = 'Test1';
      insert acc; 
        Test.startTest();
        AccountServices.getConnectFixtureAgents(acc.Id);
        Test.stopTest();
 }
    
        @isTest public static void testAccountQueries2(){
Account acc = new Account();
     Acc.Name = 'Test';
     acc.Customer_Segmentation__c = 'FD';
      insert acc; 
        Test.startTest();
        AccountServices.getRelatedAccountsByAccountId(acc.Id);
        Test.stopTest();
 }
    @testSetup static void setupTestData() {
        b2bTestSetup.setupPortalUsers();
        b2bTestSetup.setupPricelist();
    }
}
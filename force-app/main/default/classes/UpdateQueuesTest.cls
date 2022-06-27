@istest
public class UpdateQueuesTest {
     @testSetup static void Testmethod1(){
        
         List<Account> acclst = new List<Account>();
        List<Account> acclst1 = new List<Account>();
         Account acc = new Account(Name = 'TestAcc');
        acc.Returns_Queue__c = 'Current Returns';
        Insert acc;
      
       Account acc1 = new Account(Name = 'TestAcc1');
       // acc1.ParentId = acc.id;
        insert acc1;
         acc.ParentId =acc1.Id;
        update acc;
      
    }
    
   /* @isTest static void test2(){
        
        Test.startTest();
         Account acc1 = new Account(Name = 'TestAcc1');
       // acc1.ParentId = acc.id;
        insert acc1;
        
       Account parAcc=[Select id,ParentId from Account where Name =: 'TestAcc'];
       parAcc.ParentId =acc1.Id;
        
       update parAcc;
      
        Test.stopTest();
    }*/
    
     @isTest static void test3(){
        
        Test.startTest();
        
       Account childAcc=[Select id,Returns_Queue__c from Account where Name =: 'TestAcc1'];
       childAcc.Returns_Queue__c ='CCS - Yellow';
        
       update childAcc;
      
        Test.stopTest();
    }
}
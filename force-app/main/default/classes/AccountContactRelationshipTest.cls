@istest 
public class AccountContactRelationshipTest {
    static testmethod void Testmethod1(){
        Test.startTest();
        AdminOverride__c adminOverride = new AdminOverride__c();
        adminOverride.Switch_Off_Trigger__c = TRUE;
        insert adminOverride;
        
      //  User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
       Contact cont1 = [Select id,AccountId From Contact Where LastName ='Test987']; 
		Account acct1 = [SELECT Id, Name,Account_Group__c FROM Account WHERE Name = 'Test1239'];
        acct1.GE_LGT_EM_SAP_Customer_Number__c='H9M';
        acct1.Account_Group__c = 'ZEAG';
		update acct1;
       
        Account acct2 = new Account();
        acct2.Name='Test1221';
        acct2.ConnectFixtureAgents__c='H9M';
        acct2.GE_LGT_EM_SAP_Customer_Number__c='H9M';
        acct2.GE_LGT_EM_CustomerActiveFlag__c=true;
		acct2.Account_Group__c = 'Z001';
		insert acct2;
       	
        String repCode = '%'+acct1.GE_LGT_EM_SAP_Customer_Number__c+'%';
       		Account acct3 = [SELECT Id, Name,Account_Group__c,GE_LGT_EM_CustomerActiveFlag__c,ConnectFixtureAgents__c,GE_LGT_EM_SAP_Customer_Number__c FROM Account WHERE Name = 'Test1221'];
        system.debug('****'+acct3);
acct3.Account_Group__c = 'Z001';
		update acct3;
Account acct4 = [SELECT Id, Name,Account_Group__c,GE_LGT_EM_CustomerActiveFlag__c,ConnectFixtureAgents__c,GE_LGT_EM_SAP_Customer_Number__c FROM Account WHERE Name = 'Test1221'];
        system.debug('****'+acct4);
        //Account accList = [SELECT Id FROM Account WHERE /*ConnectFixtureAgents__c='H9M' AND Account_Group__c = 'Z001' AND GE_LGT_EM_CustomerActiveFlag__c = true AND Id NOT IN :relationshipList*/ ]; 

        
        
        Set<Id> contactAndAccountIds = new Set<Id>();
		contactAndAccountIds.add(acct1.id);
		contactAndAccountIds.add(cont1.id);
        contactAndAccountIds.add(acct2.id);

        System.debug('contactAndAccountIds*************'+contactAndAccountIds);
	
        Set<Id> relationshipList = new Set<Id>();
		relationshipList.add(acct1.id);
        List<AccountContactRelation> ACR1 = new List<AccountContactRelation>();
        
      AccountContactRelation AccCon = [SELECT Id,AccountId,ContactId FROM AccountContactRelation WHERE (ContactId =: cont1.id AND AccountId=:acct1.id)];        
     //  AccountContactRelation relation = new AccountContactRelation(AccountId = customerContact.AccountId, contactId = customerContact.Id);
      //  ACR1.add(relation);
       ACR1.add(AccCon);
       
        System.debug('ACR1********'+ACR1);
         
      Account tempList = [SELECT Id, GE_LGT_EM_SAP_Customer_Number__c FROM Account WHERE Id IN :contactAndAccountIds AND Account_Group__c = 'z001'];
		system.debug('tempList*******'+tempList.id);
       
       Account accList = [SELECT Id FROM Account WHERE ConnectFixtureAgents__c='H9M' AND Account_Group__c = 'Z001' AND GE_LGT_EM_CustomerActiveFlag__c = true /*AND Id NOT IN :relationshipList*/ ]; 
        system.debug('accList***'+accList);
          
		AccountContactRelationship obj = new AccountContactRelationship();
		obj.assignRelationship(ACR1);
      
       
        Test.stopTest();
            
    }
    
    
    @testSetup static void setupTestData() {
        List<TriggerSwitch__c> switchList = TestDataUtil.insertTriggerSwitches();       
        insert switchList;

        b2bTestSetup.setupPortalUsers();
		b2bTestSetup.setupPricelist();
		User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];

        Account acct1  = new Account();
        acct1.Name = 'GE CURRENT - EXTERNAL';
        acct1.GE_LGT_EM_SAP_Customer_Number__c='GEC-EXTERNAL';
        insert acct1;
        
		Account acct  = new Account();
        acct.Name = 'Test1239';
        acct.Account_Group__c = 'ZEAG';
        insert acct;
        Contact cont = new Contact();
       cont.AccountId =acct.id;
        cont.FirstName = 'Test456';
         cont.LastName ='Test987';
        insert cont;

       
      AccountContactRelation relation = new AccountContactRelation(AccountId = cont.AccountId, contactId = cont.Id);
      AccountContactRelation relation2 = new AccountContactRelation(AccountId = cont.AccountId, contactId = cont.Id);
      //insert relation;
    }

    static testmethod void testConnectRelatedAccountRefresh() {        
        Test.startTest();
        BA_13_connectRelatedAccountRefresh tb = new BA_13_connectRelatedAccountRefresh();
        Id batchId = Database.executeBatch(tb);
        Test.stopTest();
    }

}
@isTest
public with sharing class BA_13_connectRelatedAccountRefresh_Test {
    static testmethod void testConnectRelatedAccountRefresh() {          
        Test.startTest();
        AdminOverride__c adminOverride = new AdminOverride__c();
        adminOverride.Switch_Off_Trigger__c = TRUE;
        insert adminOverride;

        String setDate = '2021-11-30';
        String setDate2 = '2021-11-29';

        Contact cont1 = [SELECT Id,AccountId From Contact WHERE LastName ='Test987']; 
        System.debug('TEST CLASS - Contact Retrieved: '+cont1);
        
        Contact cont2 = [SELECT Id,AccountId From Contact WHERE LastName ='Test654']; 
        System.debug('TEST CLASS - Contact 2 Retrieved: '+cont2);

        Account acct8 = [SELECT Id, Name,Account_Group__c FROM Account WHERE Name = 'GE CURRENT - EXTERNAL'];
		
        Account acct1 = [SELECT Id, Name,Account_Group__c FROM Account WHERE Name = 'Test1239'];
        acct1.GE_LGT_EM_SAP_Customer_Number__c='H9M';
        acct1.Account_Group__c = 'ZEAG';
        update acct1;
        
        Account acct9 = [SELECT Id, Name,Account_Group__c FROM Account WHERE Name = 'Test2468'];
        acct9.GE_LGT_EM_SAP_Customer_Number__c='C1M';
        acct9.Account_Group__c = 'ZEAG';
        update acct9;
        
        System.debug('TEST CLASS - Account Retrieved: '+acct1);
        
         Account acct2 = new Account();
        acct2.Name='Test1221-A';
        acct2.ConnectFixtureAgents__c='H9M';
        acct2.GE_LGT_EM_SAP_Customer_Number__c='TEST1234';
        acct2.GE_LGT_EM_CustomerActiveFlag__c=true;
		acct2.Account_Group__c = 'Z001';
		insert acct2;

        Account acct3 = new Account();
        acct3.Name='Test1221-B';
        acct3.ConnectFixtureAgents__c='H9M';
        acct3.GE_LGT_EM_SAP_Customer_Number__c='TEST5678';
        acct3.GE_LGT_EM_CustomerActiveFlag__c=true;
		acct3.Account_Group__c = 'Z001';
        insert acct3;

        Account acct4 = new Account();
        acct4.Name='Test1221-C';
        acct4.ConnectFixtureAgents__c='H9M';
        acct4.GE_LGT_EM_SAP_Customer_Number__c='TEST1234';
        acct4.GE_LGT_EM_CustomerActiveFlag__c=true;
		acct4.Account_Group__c = 'Z001';
        insert acct4;
        
        List<Connect_Direct_Account__c> cdaList1 = new List<Connect_Direct_Account__c>();
        Connect_Direct_Account__c cdacc = new Connect_Direct_Account__c ();
        cdacc.Contact__c= cont1.id;
        cdacc.Direct_Account__c=acct1.id;
        cdacc.Is_Direct__c= true ;
        cdacc.Remapped__c = true ;
        insert cdacc;
        
        List<Connect_Direct_Account__c> cdaList2 = new List<Connect_Direct_Account__c>();
        Connect_Direct_Account__c cdacc1 = new Connect_Direct_Account__c ();
        cdacc1.Contact__c= cont1.id;
        cdacc1.Direct_Account__c=acct1.id;
        cdacc1.Is_Direct__c= false ;
        cdacc1.Remapped__c = true ;
        insert cdacc1;
        
        System.debug('Connect Direct Account: '+cdacc.id);
        
        List<AccountContactRelation> ACR1 = new List<AccountContactRelation>();
        AccountContactRelation relation = new AccountContactRelation(AccountId = acct1.Id, contactId = cont1.Id);
        //insert relation; 
       // system.debug('relation'+relation);
       //  AccountContactRelation relation = new AccountContactRelation(AccountId = customerContact.AccountId, contactId = customerContact.Id);
         ACR1.add(relation);
      //    ACR1.add(relation);
 System.debug('ACR1********'+ACR1);
        insert ACR1;
        
        AccountContactRelation relation2 = new AccountContactRelation(AccountId = acct9.Id, contactId = cont1.Id, B2B_Agent_flag__c = true, B2B_flag__c = true);

    
   
        List<Account> accListToInsert = new List<Account>();
   
        for(integer i = 1; i < 50; i++){
            Account newACC = new Account();
            newACC.Name = 'Test Account - '+i;
            newACC.GE_LGT_EM_SAP_Customer_Number__c = '000123456-'+i;
            newACC.Account_Group__c = 'Z001';
            newACC.ConnectFixtureAgents__c = 'C1M';
            accListToInsert.add(newACC);
        }

        insert accListToInsert;

        
        
 //List<AccountContactRelation> acrInsertList = new List<AccountContactRelation>();
      //AccountContactRelation   acrInsert = new AccountContactRelation();
      //  acrInsert.AccountId= acct1.id;
        //acrInsert.ContactId= cont1.id;
       
       // insert acrInsert;
        //acrInsertList.add(acrInsert);
   // cdaList = [SELECT Id, Direct_Account__c, Contact__c, Is_Direct__c, Remapped__c FROM Connect_Direct_Account__c WHERE Contact__c = :cont1 AND CreatedDate = TODAY];
   // System.debug('CONNECT DIRECT ACCOUNTS: '+cdaList); 
      //  List<AccountContactRelation> ACR11 = new List<AccountContactRelation>();
        //AccountContactRelation  acrel= new AccountContactRelation();
        
        BA_13_connectRelatedAccountRefresh tb = new BA_13_connectRelatedAccountRefresh();
        Database.executeBatch(tb,50);
        
        relatedManualRefresh.getRepCodes(cont1.id, setDate);
        relatedManualRefresh.getRepCodes(cont1.id, setDate2);
        relatedManualRefresh.updateContact(cont1);
        relatedManualRefresh.insertACR(relation2);
        relatedManualRefresh.updateCDA(cdacc);
        relatedManualRefresh.getAccount();
        //relatedManualRefresh.removeACR(cont1.id, acct8.id);


        Test.stopTest();
    }

    @TestSetup
    static void makeData(){

        List<TriggerSwitch__c> switchList = TestDataUtil.insertTriggerSwitches();       
        insert switchList;

        
        //b2bTestSetup.setupPortalUsers();
		//b2bTestSetup.setupPricelist();
        //User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        
		Account acct1  = new Account();
        acct1.Name = 'GE CURRENT - EXTERNAL';
        acct1.GE_LGT_EM_SAP_Customer_Number__c='GEC-EXTERNAL';
        insert acct1;

        Account acct6  = new Account();
        acct6.Name = 'TESTACCOUNT';
        acct6.GE_LGT_EM_SAP_Customer_Number__c='TEST-ACCOUNT-1234';
        insert acct6;
        
        
        Account acct  = new Account();
        acct.Name = 'Test1239';
        acct.GE_LGT_EM_SAP_Customer_Number__c='H9M';
        acct.Account_Group__c = 'ZEAG';
        insert acct;

        System.debug('Account ID Created: '+acct.Id);
        
        Account acct2  = new Account();
        acct2.Name = 'Test2468';
        acct2.GE_LGT_EM_SAP_Customer_Number__c='C1M';
        acct2.Account_Group__c = 'ZEAG';
        insert acct2;

        System.debug('Account ID Created: '+acct.Id);

        Contact cont = new Contact();
        cont.AccountId =acct6.id;
        cont.FirstName = 'Test456';
        cont.LastName ='Test987';
        cont.Portal_User_Type__c = 'Agent'; 
        cont.New_Inactive__c = false;
        insert cont;

        System.debug('Contact ID Created: '+cont.Id);

        Contact cont2 = new Contact();
        cont2.AccountId =acct.id;
        cont2.FirstName = 'Test456';
        cont2.LastName ='Test654';
        cont2.Portal_User_Type__c = 'Agent'; 
        cont2.New_Inactive__c = false;
        insert cont2;

        System.debug('Contact ID Created: '+cont2.Id);
       
        List<Account> accListToInsert = new List<Account>();
   
        for(integer i = 1; i < 50; i++){
            Account newACC = new Account();
            newACC.Name = 'Test Account - '+i;
            newACC.GE_LGT_EM_SAP_Customer_Number__c = '000123456-'+i;
            newACC.Account_Group__c = 'Z001';
            newACC.ConnectFixtureAgents__c = 'C1M';
            accListToInsert.add(newACC);
        }

        insert accListToInsert;
        
     


          
        
    }
}
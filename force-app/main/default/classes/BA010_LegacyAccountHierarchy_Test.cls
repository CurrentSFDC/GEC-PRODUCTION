/*
Name - BA010_LegacyAccountHierarchy_Test
Author - Neel (TechM)
Purpose - Test class of BA010_LegacyAccountHierarchy and SC010_LegacyAccountHierarchy
Created Date - April -2018
*************************************************************
MODIFICATIONS CAN BE ADDED BELOW:
Modified By        Date      Comments
*/
@isTest
public class BA010_LegacyAccountHierarchy_Test {
    static testMethod void validateHierarchy(){
        
   // Account acc1 = TestDataUtil.createAccount();
   Account acc1 = new Account();
   acc1.Name='Testparent';
    acc1.Account_Group__c ='ZHN2';
    acc1.GE_LGT_EM_Sales_Org__c ='1U10';
    acc1.GE_LGT_EM_SAP_Customer_Number__c = 'Test-Parent';
    acc1.GE_LGT_EM_Language__c='English';
    insert acc1;
    
     acc1.Account_Group__c ='ZHN2';
     update acc1;
    
   // Account accChild = TestDataUtil.createAccount();
   Account accChild = new Account();
   accChild.Name='Testparent';
    accChild.Account_Group__c ='Z001';
    accChild.GE_LGT_EM_Sales_Org__c ='1U10';
    accChild.GE_LGT_EM_SAP_Customer_Number__c = 'Test-SoldTo-12345';
    accChild.SAP_Parent_Customer_No__c = 'Test-Parent';
    accChild.GE_LGT_EM_Language__c='English';
    insert accChild;
    
    accChild.Account_Group__c ='Z001';
    update accChild;
        
    //Adding above two account ids into a set, to be passed into execute()
    Set<id> accountIdSet = new Set<id>();
    accountIdSet.add(acc1.id);
    accountIdSet.add(accChild.id);
        
    String[] accountGroupsTest = new String[] {'Z001','Z002','ZHN2','ZHN3'};
        
    List<Account> accLoadList =  [Select id, Name,GE_LGT_EM_SAP_Customer_Number__c ,SAP_Parent_Customer_No__c FROM account where ID IN :accountIdSet];
    system.debug('Accounts Loaded :: '+accLoadList);    
    System.assertEquals(accLoadList.size()>0 ,TRUE);  
    
    List<Account> testacc1 =[Select id, Name,GE_LGT_EM_SAP_Customer_Number__c ,Account_Group__c,SAP_Parent_Customer_No__c FROM account];
    System.debug('test testacc1--' + testacc1[0].Account_Group__c );
     System.debug('test testacc1--' + testacc1[1].Account_Group__c );
    
   List<Account> testacc =[Select id, Name,GE_LGT_EM_SAP_Customer_Number__c ,SAP_Parent_Customer_No__c FROM account where Account_Group__c IN :accountGroupsTest];
    System.debug('test accounts--' + testacc );
    Test.startTest();
   //BA010_LegacyAccountHierarchy batchBA010=new BA010_LegacyAccountHierarchy();
     // batchBA010.start(NULL);
     // batchBA010.execute(NULL,accLoadList);
     //  batchBA010.finish(NULL);
    SC010_LegacyAccountHierarchy runTest = new SC010_LegacyAccountHierarchy();
    runTest.execute(NULL);
    //Database.executeBatch(new BA010_LegacyAccountHierarchy());
  
  
    Test.stopTest();
    
        
        
       
    
    }
    
}
@isTest
public with sharing class BA_012_TermAndPromoAgreementsCreate_Test {
   
    @TestSetup
    static void setup(){
        List<SAP_Price_Agreement__c> pa = new List<SAP_Price_Agreement__c>();
        List<SAP_Price_Agreement_Item__c> ai = new List<SAP_Price_Agreement_Item__c>();
        

        Date newDate = Date.today();

        Account acc = new Account();
        acc.Name = 'TEST ACCOUNT';
        acc.GE_LGT_EM_SAP_Customer_Number__c = '0001985500';
        insert acc;

        ccrz__E_Product__c ccProd = new ccrz__E_Product__c();
        ccProd.ccrz__SKU__c = '123456';
        ccProd.ccrz__ProductStatus__c = 'Released';
        insert ccProd;

        for (Integer i=0;i<10;i++) {
            
            pa.add(new SAP_Price_Agreement__c(name='0080000000 '+i, 
            Agreement_Type__c ='ZTRM', Customer_List__c=acc.GE_LGT_EM_SAP_Customer_Number__c, Valid_From__c = newDate, Expiration_Date__c = newDate + 45));
        }
        insert pa;

        for (SAP_Price_Agreement__c item : pa) {
            ai.add(new SAP_Price_Agreement_Item__c(Agreement_No__c=item.Name, 
            Price_Agreement__c=item.id, Material_No__c='123456', Sales_Price__c=15.23, ValidFrom__c = newDate, ValidTo__c = newDate + 45));
        }
        insert ai;
        
    }

    static testmethod void test() {        
        Test.startTest();
        BA_012_TermAndPromoAgreementsCreate tb = new BA_012_TermAndPromoAgreementsCreate();
        Id batchId = Database.executeBatch(tb);
        Test.stopTest();
    }
}
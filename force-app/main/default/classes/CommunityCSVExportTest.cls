@istest
public class CommunityCSVExportTest {
    public static testMethod void checkPAHeaderTest(){
        SAP_Price_Agreement__c sa = new SAP_Price_Agreement__c();
        sa.Name = '123456';
        sa.Expiration_Date__c = Date.Today().addDays(30);

        insert sa;

       Test.startTest();
       CommunityCSVExport.checkPAHeader('123456');
       Test.stopTest();
    }
    public static testMethod void checkPAHeaderTest1(){
        SAP_Price_Agreement__c sa = new SAP_Price_Agreement__c();
        sa.Name = '123456';
        sa.Expiration_Date__c = Date.Today();

        insert sa;

       Test.startTest();
       CommunityCSVExport.checkPAHeader('123456');
       Test.stopTest();
    }
    
    public static testMethod void checkPAItemTest(){
        SAP_Price_Agreement__c sa = new SAP_Price_Agreement__c();
        sa.Name = '123456';
        sa.Expiration_Date__c = Date.Today().addDays(30);

        insert sa;

       Test.startTest();
       CommunityCSVExport.checkPAItem('123456');
       communityOpenClass.checkPAItem('123456');
       Test.stopTest();
    }
}
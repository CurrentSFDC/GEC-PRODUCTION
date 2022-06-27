@isTest
public class GE_NAS_Quirks_Test
{
    static testMethod void quirkTest() 
    {
        List<TriggerSwitch__c> switchList=TestDataUtil.insertTriggerSwitches();
        insert switchList;
        
        Test.starttest();
        //ID recAcTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('NA Service Bill To Account').getRecordTypeId();
        //ID recAcTypeID2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('NA Service Ship To Account').getRecordTypeId();
        //ID recAcTypeID3 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('NA Service National/Parent Account').getRecordTypeId();
        ID recAcTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sunset Account').getRecordTypeId();
        ID recAcTypeID2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sunset Account').getRecordTypeId();
        ID recAcTypeID3 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sunset Account').getRecordTypeId();
        
        list<Account> Insertlist=new list<Account>();
        Account acc = TestDataUtil.createAccount();
        acc.RecordTypeId = recAcTypeID3;
        acc.CurrencyIsoCode='USD';
        acc.Name='Test Ac3';
        acc.accountnumber='985';
        Insertlist.add(Acc);
        
        Account Accid = TestDataUtil.createAccount();
        Accid.RecordTypeId = recAcTypeID3;
        Accid.CurrencyIsoCode='USD';
        Accid.Name='Test Ac3';
        Accid.accountnumber='98523131';
        Account Acc1 = TestDataUtil.createAccount();
        Acc1.RecordTypeId = recAcTypeID;
        Acc1.CurrencyIsoCode='USD';
        Acc1.Name='Test Ac';
        Acc1.accountnumber='9854678';
        Acc1.ParentID=Accid.id;
        Insertlist.add(Acc1);
        
        Account Accid1 = TestDataUtil.createAccount();
        Accid1.RecordTypeId = recAcTypeID3;
        Accid1.CurrencyIsoCode='USD';
        Accid1.Name='Test Ac3';
        Accid1.accountnumber='98523131445';
        
        Account Acc2 = TestDataUtil.createAccount();
        Acc1.RecordTypeId = recAcTypeID2;
        Acc1.CurrencyIsoCode='USD';
        Acc1.Name='Test Ac2';
        Acc1.accountnumber='98546780002';
        Acc1.ParentID=Accid1.id;
        Insertlist.add(Acc2);
        
        insert Insertlist;
        GE_NAS_Quirk__c quirk=new GE_NAS_Quirk__c(GE_NAS_Quirk__c='EliteNet Access',GE_NAS_Value__c='yes',GE_NAS_Comments__c='Contact Russell Baxley for substitutes',GE_NAS_Account__c=Accid.id);
        insert quirk;
        GE_NAS_Quirk__c quirk2=new GE_NAS_Quirk__c(GE_NAS_Quirk__c='Special Order Handling',GE_NAS_Value__c='No',GE_NAS_Comments__c='End use code M for maintenance',GE_NAS_Account__c=Accid1.id);
        insert quirk2;
        Test.stoptest();
        ApexPages.StandardController controller = new ApexPages.StandardController(Acc2);
        GE_NAS_Quirks qur1=new GE_NAS_Quirks();
        GE_NAS_Quirks qur=new GE_NAS_Quirks(controller);
        
        
        ApexPages.currentPage().getParameters().put('deleteQuirkID',quirk.Id);
        qur.deleteQuirk();
    }
}
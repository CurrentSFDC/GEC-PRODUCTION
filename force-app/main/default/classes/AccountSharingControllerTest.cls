/**
 * Created by PA on 2021. 04. 28..
 */

@IsTest
private class AccountSharingControllerTest {
    @TestSetup
    static void setup(){
        Account acc = new Account(Name = 'ContactAccountName', OwnerID = [SELECT ID FROM User WHERE UserRoleId != NULL AND Profile.Name ='System Administrator' LIMIT 1].Id);
        insert acc;
        Contact con = new Contact(FirstName = 'Test', LastName = 'Test', Email = 'Test@test.test', MobilePhone = '123456789', AccountId = acc.Id);
        insert con;

    }
    @IsTest
    static void shareChildAccountsFromAccountTrigger() {
        Contact con = [SELECT Id FROM Contact WHERE Email = 'Test@test.test'];

        User u = new User(Alias = 'test', Email='standarduser@testorg.com', communityNickname = 'test_test',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = [SELECT ID FROM Profile WHERE Name LIKE '%Agent B2B Storefront Registered Users%' LIMIT 1].Id,
                //UserRoleId = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1].Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='test@testtest.test', ContactId = con.Id);
        insert u;

        Account parentAcc = new Account(Name = 'testParent01', GE_LGT_EM_SAP_Customer_Number__c = 'testParent01');
        insert parentAcc;
        parentAcc.Account_Group__c = 'Z001';
        update parentAcc;

        AccountContactRelation acr = new AccountContactRelation(AccountId = parentAcc.Id, ContactId = con.Id);
        insert acr;

        List<Account> accs = new List<Account>();
        accs.add(new Account(Name = 'testChild01', Connect_Z002_Parents__c = 'testParent01'));
        accs.add(new Account(Name = 'testChild02', Connect_Z002_Parents__c = 'testParent01'));
        accs.add(new Account(Name = 'testChild03', Connect_Z002_Parents__c = ''));
        insert accs;

        System.assertEquals(2, [SELECT Count() FROM AccountShare WHERE RowCause = 'Manual' AND AccountId IN :accs AND UserOrGroupId = :u.Id]);
    }

    @IsTest
    static void shareChildAccountsFromAccountContactRelationInsert(){
        Contact con = [SELECT Id FROM Contact WHERE Email = 'Test@test.test'];

        User u = new User(Alias = 'test', Email='standarduser@testorg.com', communityNickname = 'test_test',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = [SELECT ID FROM Profile WHERE Name LIKE '%Agent B2B Storefront Registered Users%' LIMIT 1].Id,
                //UserRoleId = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1].Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='test@testtest.test', ContactId = con.Id);
        insert u;

        List<Account> accs = new List<Account>();
        accs.add(new Account(Name = 'testChild01', Connect_Z002_Parents__c = 'testParent01'));
        accs.add(new Account(Name = 'testChild02', Connect_Z002_Parents__c = 'testParent01'));
        accs.add(new Account(Name = 'testChild03', Connect_Z002_Parents__c = ''));
        Account parentAcc = new Account(Name = 'testParent01', GE_LGT_EM_SAP_Customer_Number__c = 'testParent01');
        accs.add(parentAcc);
        insert accs;
        parentAcc.Account_Group__c = 'Z001';
        update parentAcc;

        AccountContactRelation acr = new AccountContactRelation(AccountId = parentAcc.Id, ContactId = con.Id);
        insert acr;

        System.assertEquals(2, [SELECT Count() FROM AccountShare WHERE RowCause = 'Manual' AND AccountId IN :accs AND UserOrGroupId = :u.Id]);
    }
}
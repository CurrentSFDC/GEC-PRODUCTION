// CommunityCreateContactControllerTest class
// Test class for the CommunityCreateContactController class
// ------------------------------------------------------------------
//  Author                    Date         Description
// ------------------------------------------------------------------
//  Devang Shah	              28/10/2020   Created
//
@IsTest
private class CommunityCreateContactControllerTest {

    private static Account account = new Account();
    private static Account account2 = new Account();

    private static void setupData() {
        account = new Account(Name = 'GuestAccount', 
        ShippingStreet = 'Test Street', ShippingCity = 'Cleveland', ShippingPostalCode = '44114', ShippingCountry = 'United States');
        insert account;
        
        account2 = new Account(Name = 'GuestAccount', 
        ShippingStreet = 'Customer Way', ShippingCity = 'Cleveland', ShippingPostalCode = '44114', ShippingCountry = 'United States');
        insert account2;

        CountryState__c cs = new CountryState__c(Country__c = 'United States', CountryCode__c = 'US', State__c = 'Maryland' , StateCode__c = 'MD');
        insert cs;
    }

    @IsTest
    private static void testRegisterUser() {
        setupData();

        CommunityCreateContactController.UserWrapper userWrapper = new CommunityCreateContactController.UserWrapper();
        userWrapper.firstName = 'Test';
        userWrapper.lastName = 'Portal User';
        userWrapper.email = 'testportal@example.com';
        userWrapper.companyName = 'GE Current';
        userWrapper.phone = '07123456789';
        
        userWrapper.principle =false;
        userWrapper.designer =false; 
        userWrapper.outSales =false;
        userWrapper.techService =false;
        userWrapper.quotation =false;
        userWrapper.custService =false; 
        userWrapper.admin =false;
        userWrapper.own =false;
        userWrapper.pm =false;
        userWrapper.spec =false; 
        userWrapper.proc = false;
        

        String response = CommunityCreateContactController.registerUser(userWrapper);
        System.assertNotEquals(response, 'valid', 'The registration should not be successful');

        userWrapper.country = 'United States';
        userWrapper.registrationComments = 'test';
        userWrapper.userType = 'Agent';
        userWrapper.registrationRepCodes = 'A123';
        userWrapper.preferredLanguage = 'English';
        userWrapper.tnc = 'true';

        response = CommunityCreateContactController.registerUser(userWrapper);
        System.assertEquals(response, 'valid', 'The registration should be successful');

        Test.startTest();

        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = :userWrapper.email];
        System.assertNotEquals(contacts.isEmpty(), true, 'The user contact was not created');

        Test.stopTest();
    }

    @IsTest
    private static void testgetPrefferedLanguageSelectOptions() {
        List<String> options = CommunityCreateContactController.getPrefferedLanguageSelectOptions();
        System.debug(options);
        System.assert(options.size()>0);
    }

    @IsTest
    private static void testgetCountries() {
        setupData();
        List<String> options = CommunityCreateContactController.getCountries();
        System.debug(options);
        System.assert(options.size()>0);
    }

    @IsTest
    private static void testgetStates() {
        setupData();
        List<String> options = CommunityCreateContactController.getStates('United States');
        System.debug(options);
        System.assert(options.size()>0);
    }

    @isTest
    private static void testdoesUserEmailAddressAlreadyExist(){

        setupData();
        Contact objContact = new Contact(AccountId = account2.Id,
                                        FirstName = 'Test',
                                        LastName = 'Contact1',
                                        Email = 'test@example.com',
                                        Phone = '078694807',
                                        ccrz__CompanyName__c = 'GE Current');
        insert objContact;  

        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name = 'B2B Storefront Registered Users' LIMIT 1];
        String profileId = profiles[0].Id;

        Test.startTest();

        User user = new User(FirstName = 'Test', LastName = 'Contact1', Email = 'test@example.com', Username = 'usertest@example.com.test',
        EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', ContactId = objContact.Id, ProfileId = profileId, LocaleSidKey = 'en_GB', TimeZoneSidKey = 'Europe/London',
        Alias = 'usertest', UserRoleId = null);
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert user;
         }

        Boolean doesUserEmailAddressAlreadyExist = CommunityCreateContactController.doesUserEmailAddressAlreadyExist('test@example.com');
        System.assertEquals(doesUserEmailAddressAlreadyExist, true);
        Boolean doesUserEmailAddressAlreadyExist1 = CommunityCreateContactController.doesUserEmailAddressAlreadyExist('test1@example.com');
        System.assertEquals(doesUserEmailAddressAlreadyExist1, false);
        Test.stopTest();
    }
}
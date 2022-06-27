@IsTest
public without sharing class TestDataFactory {
    private static Map<String, Profile> profileMap = new Map<String, Profile>();
    private static Map<String, UserRole> userRoleMap = new Map<String, UserRole>();

    public static Account createAccount(String name, Boolean pCommit) {
        return createAccount(null, name, pCommit);
    }
    public static Account createAccount(Id parentId, String name, Boolean pCommit) {
        String randomStr = '1' + getRandomString(8);
        Account newRecord = new Account(Name = name, 
        GE_LGT_EM_SAP_Customer_Number__c = '080000108', GE_LGT_EM_Sales_Org__c= '1US1', GE_LGT_EM_Division__c = '10', GE_LGT_EM_Distribution_Channel__c = '20',
        Delivering_Plant__c = '1WML', Account_Group__c = 'ZEAG', GE_LGT_Rep_Code__c = '123',
        ShippingStreet = 'Test Street', ShippingCity = 'Cleveland', ShippingPostalCode = '44114', ShippingCountry = 'United States');
        if (pCommit == true) {
            insert newRecord;
        }
        return newRecord;
    }


    public static Contact createContact(String firstName, String lastName, String email, Boolean pCommit) {
        return createContact(null, firstName, lastName, email, pCommit);
    }
    public static Contact createContact(Id accountId, String firstName, String lastName, String email,
            Boolean pCommit) {
        Contact newRecord = new Contact(Portal_User_Type__c = 'Agent', AccountId = accountId, FirstName = firstName, LastName = lastName, Email = email, Phone = '0123456789',
                MailingStreet = 'Test Street', MailingCity = 'New York', MailingState = 'New York', MailingPostalCode = '12345',
                MailingCountry = 'United States', MailingLatitude = 40.11, MailingLongitude = -73.00,
                Birthdate = Date.today().addYears(-30));

        if (pCommit == true) {
            insert newRecord;
        }
        return newRecord;
    }

    public static User createUser(String firstName, String lastName, String email, String userName, String profileName, String roleName, Boolean pCommit) {
        return createUser(null, firstName, lastName, email, userName, profileName, roleName, pCommit);
    }
    public static User createCommunityUser(Id contactId, String firstName, String lastName, String email, String userName, String profileName, Boolean pCommit) {
        return createUser(contactId, firstName, lastName, email, userName, profileName, null, pCommit);
    }
    public static User createUser(Id contactId, String firstName, String lastName, String email, String userName, String profileName, String roleName, Boolean pCommit) {
        List<Profile> profiles = (profileMap.containsKey(profileName)) ? new List<Profile> { profileMap.get(profileName) }
                                : [SELECT Id, Name FROM Profile WHERE Name = :profileName LIMIT 1];
       
                                List<UserRole> userRoles = (roleName != null) ? (userRoleMap.containsKey(roleName)) ? new List<UserRole> { userRoleMap.get(roleName) }
                                : [SELECT Id, Name FROM UserRole WHERE Name = :roleName LIMIT 1] : null;
        User newRecord = new User(FirstName = firstName, LastName = lastName, Email = email, Username = userName,
                EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles');
               
        newRecord.Alias = (userName.length() > 8) ? userName.substring(0, 8) : userName;
        newRecord.CommunityNickname = newRecord.Alias;
        
        if (contactId != null) { newRecord.ContactId = contactId; }
        if (!profiles.isEmpty()) {
            newRecord.ProfileId = profiles[0].Id;
            profileMap.put(profileName, profiles[0]);
        }
        
        if (userRoles != null && !userRoles.isEmpty()) {
            newRecord.UserRoleId = userRoles[0].Id;
            userRoleMap.put(roleName, userRoles[0]);
        } 
       
        if (pCommit) {
            insert newRecord;
        }
       
        return newRecord;
    }

    public static User createUserWithAcc(Id contactId, String firstName, String lastName, String email, String userName, String profileName, String roleName, Id accId, Boolean pCommit) {
        List<Profile> profiles = (profileMap.containsKey(profileName)) ? new List<Profile> { profileMap.get(profileName) }
                : [SELECT Id, Name FROM Profile WHERE Name = :profileName LIMIT 1];

        List<UserRole> userRoles = (roleName != null) ? (userRoleMap.containsKey(roleName)) ? new List<UserRole> { userRoleMap.get(roleName) }
                : [SELECT Id, Name FROM UserRole WHERE Name = :roleName LIMIT 1] : null;
        User newRecord = new User(FirstName = firstName, LastName = lastName, Email = email, Username = userName,
                EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles');

        newRecord.Alias = (userName.length() > 8) ? userName.substring(0, 8) : userName;
        newRecord.CommunityNickname = newRecord.Alias;

        if (contactId != null) { newRecord.ContactId = contactId; }
        if (!profiles.isEmpty()) {
            newRecord.ProfileId = profiles[0].Id;
            profileMap.put(profileName, profiles[0]);
        }

        if (userRoles != null && !userRoles.isEmpty()) {
            newRecord.UserRoleId = userRoles[0].Id;
            userRoleMap.put(roleName, userRoles[0]);
        }

        if (pCommit) {
            insert newRecord;
        }

        return newRecord;
    }

    public static ccrz__E_Product__c createCCProduct(String sku, String name, Boolean pCommit) {
        ccrz__E_Product__c product = new ccrz__E_Product__c(Name = name, ccrz__SKU__c = sku,
                ccrz__StartDate__c = Date.today().addDays(-1), ccrz__EndDate__c = Date.today().addDays(10),
                ccrz__Storefront__c = b2bConstants.STOREFRONT_NAME);
        if (pCommit == true) {
            insert product;
        }

        return product;
    }

    public static ccrz__E_ProductInventoryItem__c createCCProductInvetoryItem(Id productId, Boolean pCommit) {
        ccrz__E_ProductInventoryItem__c inventoryItem = new ccrz__E_ProductInventoryItem__c(ccrz__ProductItem__c = productId,
                InventoryLocations__c = '1WML/450,1MLA/900',
                TotalQtyAvailable__c = 1350);
        if (pCommit == true) {
            insert inventoryItem;
        }
        return inventoryItem;
    }

    public static List<Pricing_UOM__c> createPricingUOM(Id productId,String sku){
        system.debug('TDBG '+productId);
        system.debug('TDBG '+sku);
        Pricing_UOM__c p1 = new Pricing_UOM__c(CC_Product__c = productId, SKU_UOM_Key__c = sku + '_PC' ,  Multiplier__c = 1,  UOM__c = 'PC', SKU__c = sku );
        Pricing_UOM__c p2 = new Pricing_UOM__c(CC_Product__c = productId, SKU_UOM_Key__c = sku + '_BX' ,  Multiplier__c = 3,  UOM__c = 'BX', SKU__c = sku );
        List<Pricing_UOM__c> pl = new List<Pricing_UOM__c>();
        pl.add(p1);
        pl.add(p2);
        insert pl;
     
        return pl;
    }
    
    public static String getRandomString(Integer pLength) {
        String oStr = EncodingUtil.convertToHex(Crypto.generateAesKey(192));
        return (pLength != null && oStr.length() > pLength) ? oStr.substring(0, pLength) : oStr;
    }

    public static String toLowerCase(String str) {
        return (str != null) ? str.toLowerCase() : str;
    }

    public static String getRandomUsername() {
        return getRandomString(8) + '@gecurrent.com.test';
    }
    
}
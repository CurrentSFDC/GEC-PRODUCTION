@isTest
public without sharing class AccountMethods_Tests {

    public static Profile testProfile;

    public static Account testAccount(string accname){

        Account thisAccount = new Account(
        Name = accname);

        return thisAccount;
    }

    static testMethod void testUpdateCustomerNumbers(){

        Account testAcc = testAccount('Test Account 1');
        testAcc.GE_LGT_EM_SAP_Customer_Number__c = '1245';
        testAcc.SAP_Parent_Customer_No__c = '0080001234';

        insert testAcc;

        Account testAccRes = [ SELECT Id, GE_LGT_EM_SAP_Customer_Number__c, SAP_Parent_Customer_No__c FROM Account WHERE Id = :testAcc.id ];

        system.assertEquals(testAccRes.GE_LGT_EM_SAP_Customer_Number__c, '0000001245');
        system.assertEquals(testAccRes.SAP_Parent_Customer_No__c, '0080001234');

        testAcc.GE_LGT_EM_SAP_Customer_Number__c = 'Z123456';
        testAcc.SAP_Parent_Customer_No__c = '01190875344';

        update testAcc;

        testAccRes = [ SELECT Id, GE_LGT_EM_SAP_Customer_Number__c, SAP_Parent_Customer_No__c FROM Account WHERE Id = :testAcc.id ];

        system.assertEquals(testAccRes.GE_LGT_EM_SAP_Customer_Number__c, 'Z123456');
        system.assertEquals(testAccRes.SAP_Parent_Customer_No__c, '01190875344');
    }
    
    static testMethod void testParentHierarchy(){
    
       Account testAcc1 = testAccount('Test Account 1');
        testAcc1.GE_LGT_EM_SAP_Customer_Number__c = '1245';
        testAcc1.Account_Group__c = 'ZSH5';
        
        Account testAcc2 = testAccount('Test Account 2');
        testAcc2.GE_LGT_EM_SAP_Customer_Number__c = '1247';
        testAcc2.SAP_Parent_Customer_No__c = '0000001245';
        testAcc2.Account_Group__c = 'ZSTG';

        Account testAcc3 = testAccount('Test Account 3');
        testAcc3.GE_LGT_EM_SAP_Customer_Number__c = '1249';
        testAcc3.SAP_Parent_Customer_No__c = '0000001245';
        testAcc3.Account_Group__c = 'ZSTG';

        List<Account> testAccList = new List<Account>{testAcc1, testAcc2, testAcc3};
        
        insert testAccList;
        
        testAcc3.SAP_Parent_Customer_No__c = '1247';
        update testAcc3;
        
        testAcc3.Account_Group__c = 'Z001';
        testAcc3.SAP_Parent_Customer_No__c = null ;
        update testAcc3;
        
        Account testAcc4 = testAccount('Test Account 4');
        testAcc4.GE_LGT_EM_SAP_Customer_Number__c = '0000001250';
        testAcc4.SAP_Parent_Customer_No__c = '0000001249';
        testAcc4.Account_Group__c = 'Z001';
        
        insert testAcc4;
        
        testAcc4.Account_Group__c = 'ZSTG';
        update testAcc4;
        
 
    }
    
    static testMethod void testParentAgentTypes(){
    
        Account testAcc1 = testAccount('Test Account 1');
        testAcc1.Account_Group__c = 'ZEAG';
        
        insert testAcc1;
        
        Account testAcc2 = testAccount('Test Account 2');
        testAcc2.Account_Group__c = 'ZEAG';
        testAcc2.ParentId = testAcc1.id;
        
        insert testAcc2;

        Account testAcc3 = testAccount('Test Account 3');
        testAcc3.Account_Group__c = 'ZEAG';
        testAcc3.ParentId = testAcc1.id;
        
        insert testAcc3;
        
        testAcc2.GE_LGT_Architecture__c = TRUE;
        testAcc2.GE_LGT_Controls__c  = FALSE;
        testAcc2.Lamp_Ballast__c  = FALSE;
        testAcc2.Others__c  = FALSE;
        testAcc2.GE_LGT_Roadway__c  = FALSE;
        testAcc2.GE_LGT_C_I__c  = FALSE;
        testAcc2.GE_LGT_Utility__c  = FALSE;
        testAcc2.GE_LGT_DOT__c  = TRUE;
        testAcc2.GE_LGT_Sports__c  = FALSE;
        
        testAcc3.GE_LGT_Architecture__c = FALSE;
        testAcc3.GE_LGT_Controls__c  = FALSE;
        testAcc3.Lamp_Ballast__c  = FALSE;
        testAcc3.Others__c  = TRUE;
        testAcc3.GE_LGT_Roadway__c  = TRUE;
        testAcc3.GE_LGT_C_I__c  = FALSE;
        testAcc3.GE_LGT_Utility__c  = FALSE;
        testAcc3.GE_LGT_DOT__c  = FALSE;
        testAcc3.GE_LGT_Sports__c  = FALSE;
                
        List<Account> testAccUpdList = new List<Account>{testAcc2, testAcc3};
                
        update testAccUpdList;
        
        Account testAccRes = [ SELECT Id, GE_LGT_C_I__c, GE_LGT_Architecture__c, GE_LGT_Controls__c , Lamp_Ballast__c, Others__c, GE_LGT_Roadway__c, GE_LGT_Sports__c, GE_LGT_DOT__c, GE_LGT_Utility__c FROM Account WHERE Id = :testAcc1.id ];
        
        system.assert(testAccRes.GE_LGT_Architecture__c == TRUE);
        system.assert(testAccRes.GE_LGT_Controls__c  == FALSE);
        system.assert(testAccRes.Lamp_Ballast__c  == FALSE);
        system.assert(testAccRes.Others__c  == TRUE);
        system.assert(testAccRes.GE_LGT_Roadway__c  == TRUE);
        system.assert(testAccRes.GE_LGT_C_I__c  == FALSE);
        system.assert(testAccRes.GE_LGT_Utility__c  == FALSE);
        system.assert(testAccRes.GE_LGT_DOT__c  == TRUE);
        system.assert(testAccRes.GE_LGT_Sports__c  == FALSE);
        
        testAcc2.GE_LGT_Controls__c  = TRUE;
        testAcc2.GE_LGT_Utility__c  = TRUE;
        testAcc3.Lamp_Ballast__c  = TRUE;
        testAcc3.GE_LGT_C_I__c  = TRUE;
        testAcc3.GE_LGT_Sports__c  = TRUE;
        
        testAccUpdList = new List<Account>{testAcc2, testAcc3};
               
        update testAccUpdList;

        testAccRes = [ SELECT Id, GE_LGT_C_I__c, GE_LGT_Architecture__c, GE_LGT_Controls__c , Lamp_Ballast__c, Others__c, GE_LGT_Roadway__c, GE_LGT_Sports__c, GE_LGT_DOT__c, GE_LGT_Utility__c FROM Account WHERE Id = :testAcc1.id ];
        
        system.assert(testAccRes.GE_LGT_Architecture__c == TRUE);
        system.assert(testAccRes.GE_LGT_Controls__c  == TRUE);
        system.assert(testAccRes.Lamp_Ballast__c  == TRUE);
        system.assert(testAccRes.Others__c  == TRUE);
        system.assert(testAccRes.GE_LGT_Roadway__c  == TRUE);
        system.assert(testAccRes.GE_LGT_C_I__c  == TRUE);
        system.assert(testAccRes.GE_LGT_Utility__c  == TRUE);
        system.assert(testAccRes.GE_LGT_DOT__c  == TRUE);
        system.assert(testAccRes.GE_LGT_Sports__c  == TRUE);
        
        delete testAcc2;
    }    
    
    static testMethod void testCustomerCodes(){

        Account testAcc = testAccount('Test Account 1');
        testAcc.GE_LGT_EM_Distribution_Channel__c = '40';
        testAcc.GE_LGT_EM_Division__c = '10';
        testAcc.GE_LGT_EM_PF_Type__c = 'DE';
        testAcc.GE_LGT_EM_Sales_Org__c = '2NL1';
        testAcc.GE_LGT_Sales_Group__c = '358';
        testAcc.GE_LGT_Sales_Office__c = 'Z109';
        testAcc.GE_LGT_Sub_Vertical__c = '57';
        testAcc.GE_LGT_Vertical__c = '55';
        testAcc.GE_NAS_Default_Distribution_Center__c = '4670';
        testAcc.GE_NAS_Domain__c = '1306';
        testAcc.GE_NAS_GE_Business_Code__c = 'CA';
        testAcc.GE_NAS_Language__c = 'E';
        testAcc.GE_NAS_National_Type__c = 'PA';
        testAcc.GE_NAS_NCSC_Component_Code__c = '4596';
        testAcc.GE_NAS_Preferred_Carrier__c = 'CWX';
        testAcc.GE_NAS_Shipping_Schedule__c = '02';
        testAcc.GE_NAS_Shipping_Type__c = 'E';

        insert testAcc;
    }

    static testMethod void testAccountOwnership(){

        testProfile = [ SELECT Id FROM Profile WHERE Name = 'System Administrator' ];

        User testUser1 = new User (
        Alias = 'tuser1',
        Email = 'testuser1@testcompany.com',
        EmailEncodingKey = 'UTF-8',
        FederationIdentifier = '212580001',
        FirstName = 'Test',
        LanguageLocaleKey = 'en_US',
        LastName = 'User I',
        LocaleSidKey = 'en_US',
        ProfileId = testProfile.id,
        TimeZoneSidKey = 'America/Los_Angeles',
        Username = 'testuser1@gelighting.testcompany.com' );

        User testUser2 = new User (
        Alias = 'tuser2',
        Email = 'testUser2@testcompany.com',
        EmailEncodingKey = 'UTF-8',
        FederationIdentifier = '212580002',
        FirstName = 'Test',
        LanguageLocaleKey = 'en_US',
        LastName = 'User II',
        LocaleSidKey = 'en_US',
        ProfileId = testProfile.id,
        TimeZoneSidKey = 'America/Los_Angeles',
        Username = 'testUser2@gelighting.testcompany.com' );

        User testUser3 = new User (
        Alias = 'tuser3',
        Email = 'testUser3@testcompany.com',
        EmailEncodingKey = 'UTF-8',
        FederationIdentifier = '212580003',
        FirstName = 'Test',
        LanguageLocaleKey = 'en_US',
        LastName = 'User III',
        LocaleSidKey = 'en_US',
        ProfileId = testProfile.id,
        TimeZoneSidKey = 'America/Los_Angeles',
        Username = 'testUser3@gelighting.testcompany.com' );

        List<User> testUserInsList = new List<User>{testUser1, testUser2, testUser3};

        insert testUserInsList;

        Account testAcc = testAccount('Test Account 1');

        testAcc.GE_LGT_EM_SAP_Customer_Number__c = '1245';
        testAcc.SAP_Parent_Customer_No__c = '0080001234';
        testAcc.Customer_Integration_Key__c = '0080001234-1XX1-00-00-00-00';
        testAcc.Owner_SSO__c = '212580001';
        testAcc.GE_LGT_Regional_Manager__c = '212580002';
        testAcc.GE_LGT_District_Manager__c = '212580003';

        insert testAcc;
        
        Account testAccRes = [ SELECT Id, Regional_Manager_Name__r.Alias, District_Manager_Name__r.Alias, Owner.Alias FROM Account WHERE Id = :testAcc.id ];
        
        system.assertEquals(testAccRes.Regional_Manager_Name__r.Alias, 'tuser2');
        system.assertEquals(testAccRes.District_Manager_Name__r.Alias, 'tuser3');        
        system.assertEquals(testAccRes.Owner.Alias, 'tuser1');  
        
    }
}
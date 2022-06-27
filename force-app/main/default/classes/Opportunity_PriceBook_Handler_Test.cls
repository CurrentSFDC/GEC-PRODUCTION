@isTest(Seealldata=True)
public class Opportunity_PriceBook_Handler_Test {
    static testMethod void myUnitTest() {
        ID userID = UserInfo.getUserID(); //[select id from user where isactive = true limit 1].id;
        ID userIDNA = [SELECT ID,GE_LGT_Business_Division__c FROM user WHERE GE_LGT_Business_Division__c='North America' limit 1 ].ID ; 
        
        
        // Id recOppTypeID_Solar = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SolarEquipmentAdvance').getRecordTypeId(); --> COMMENTED OUT BY MG: RQT-1023
        
        
        Id recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        
        /**************************************************************************************************/
        
        Account acc = TestDataUtil.createAccount();
        acc.name='Test Acc2';
        acc.RecordTypeId=recAccTypeID;
        insert acc;
        
        
        // INSERT OPPTY RECORD
        Opportunity opp = TestDataUtil.createOpportunity(acc);
        opp.Name = 'Testopp';
        opp.StageName = 'S1 Consult';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='USD';
        opp.Probability = 10;
        opp.amount = 500;
        // opp.RecordTypeId = recOppTypeID_Solar; --> COMMENTED OUT BY MG: RQT-1023
        opp.Originated_from_Lead__c = true;
        // opp.GE_LGT_Oppty_Type2__c ='Solar'; --> COMMENTED OUT BY MG: RQT-1023
        opp.CloseDate = system.today()+3;
        opp.PO_Receipt_Date__c = system.today()+3;
        insert opp;
        
        //INSERT PRODUCT   
        Product2 prod1 = new Product2(Name = 'Laptop X200', 
                                      GE_LGT_Product_Line__c='AUTOMOTIVE',
                                      GE_LGT_Product_Group__c ='LED PRODUCTS',
                                      CurrencyIsoCode='USD',
                                      CanUseQuantitySchedule=true,
                                      CanUseRevenueSchedule=true,
                                      isActive=true);
        insert prod1;
        
        //INSERT PRICE BOOK ENTRY
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = prod1.Id,
            UnitPrice = 0, 
            IsActive = true);
        
    }
    static testMethod void myUnitTest_storage() {
        ID userID = UserInfo.getUserID(); //[select id from user where isactive = true limit 1].id;
        ID userIDNA = [SELECT ID,GE_LGT_Business_Division__c FROM user WHERE GE_LGT_Business_Division__c='North America' limit 1 ].ID ; 
        
        
        Id recOppTypeID_storage = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Energy Storage').getRecordTypeId();
        
        
        Id recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        
        /**************************************************************************************************/
        
        Account acc = TestDataUtil.createAccount();
        acc.Name='Test Acc2';
        acc.RecordTypeId=recAccTypeID;
        insert acc;
        
        
        // INSERT OPPTY RECORD
        Opportunity opp2 =TestDataUtil.createOpportunity(acc);
        opp2.Name = 'Testopp2';
        opp2.StageName = 'S1 Consult';
        opp2.AccountID = acc.id;
        opp2.CurrencyIsoCode ='USD';
        opp2.Probability = 10;
        opp2.amount = 5000;
        opp2.RecordTypeId = recOppTypeID_storage;
        opp2.Originated_from_Lead__c = true;
        //opp2.GE_LGT_Oppty_Type2__c ='Storage'; // changed to Energy since EnergyStorageAdvance is inactive
        opp2.GE_LGT_Oppty_Type2__c ='ENERGY';
        opp2.CloseDate = system.today()+3;
        opp2.PO_Receipt_Date__c = system.today()+3;
        insert opp2;
        
        //INSERT PRODUCT   
        Product2 prod1 = new Product2(Name = 'Laptop X200', 
                                      GE_LGT_Product_Line__c='AUTOMOTIVE',
                                      GE_LGT_Product_Group__c ='LED PRODUCTS',
                                      CurrencyIsoCode='USD',
                                      CanUseQuantitySchedule=true,
                                      CanUseRevenueSchedule=true,
                                      isActive=true);
        insert prod1;
        
        //INSERT PRICE BOOK ENTRY
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = prod1.Id,
            UnitPrice = 0, 
            IsActive = true);
        
    } 
    static testMethod void myUnitTest_EV() {
        ID userID = UserInfo.getUserID(); //[select id from user where isactive = true limit 1].id;
        ID userIDNA = [SELECT ID,GE_LGT_Business_Division__c FROM user WHERE GE_LGT_Business_Division__c='North America' limit 1 ].ID ; 
        
        
        Id recOppTypeID_EV = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Daintree').getRecordTypeId();
        
        
        Id recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        
        /**************************************************************************************************/
        
        Account acc = TestDataUtil.createAccount();
        acc.Name='Test Acc2';
        acc.RecordTypeId=recAccTypeID;
        insert acc;
        
        
        // INSERT OPPTY RECORD
        Opportunity opp3 =TestDataUtil.createOpportunity(acc);
        opp3.Name = 'Testopp3';
        opp3.StageName = 'S1 Consult';
        opp3.AccountID = acc.id;
        opp3.CurrencyIsoCode ='USD';
        opp3.Probability = 10;
        opp3.amount = 500;
        opp3.RecordTypeId = recOppTypeID_EV;
        opp3.Originated_from_Lead__c = true; 
        //opp3.GE_LGT_Oppty_Type2__c ='EV'; This is commented out by Andras as Opptrigger helper would override to EV and it is inactive
        opp3.GE_LGT_Oppty_Type2__c ='Daintree';
        opp3.CloseDate = system.today()+4;
        opp3.PO_Receipt_Date__c = system.today()+4;
        insert opp3;
        
        //INSERT PRODUCT   
        Product2 prod1 = new Product2(Name = 'Laptop X200', 
                                      GE_LGT_Product_Line__c='AUTOMOTIVE',
                                      GE_LGT_Product_Group__c ='LED PRODUCTS',
                                      CurrencyIsoCode='USD',
                                      CanUseQuantitySchedule=true,
                                      CanUseRevenueSchedule=true,
                                      isActive=true);
        insert prod1;
        
        //INSERT PRICE BOOK ENTRY
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = prod1.Id,
            UnitPrice = 0, 
            IsActive = true);
        
    }
    static testMethod void myUnitTest_CHP() {
        ID userID = UserInfo.getUserID(); //[select id from user where isactive = true limit 1].id;
        ID userIDNA = [SELECT ID,GE_LGT_Business_Division__c FROM user WHERE GE_LGT_Business_Division__c='North America' limit 1 ].ID ; 
        
        
        Id recOppTypeID_CHP = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('StandardAdvance').getRecordTypeId();
        
        
        Id recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        
        /**************************************************************************************************/
        
        Account acc = TestDataUtil.createAccount();
        acc.Name='Test Acc2';
        acc.RecordTypeId=recAccTypeID;
        insert acc;
        
        
        // INSERT OPPTY RECORD
        Opportunity opp4 = TestDataUtil.createOpportunity(acc);
        opp4.Name = 'Testopp4';
        opp4.StageName = 'S1 Consult';
        opp4.CurrencyIsoCode ='USD';
        opp4.Probability = 10;
        opp4.amount = 500;
        opp4.RecordTypeId = recOppTypeID_CHP;
        opp4.Originated_from_Lead__c = true;
        //opp4.GE_LGT_Oppty_Type2__c ='OPS'; Andras made this to Standard since if OPS than Triggerhelper override to   OPS (solar) inactive rec type
        opp4.GE_LGT_Oppty_Type2__c ='Standard';
        opp4.CloseDate = system.today()+4;
        opp4.PO_Receipt_Date__c = system.today()+4;
        opp4.GE_LGT_Reason_Won_Lost__c='Lost to Competitor'; //Since Rashmi's ticket on 2/22/2019 value inactivated and new validations listed
        opp4.Competitor__c='Don’t know';        
        insert opp4;
        
        //INSERT PRODUCT   
        Product2 prod1 = new Product2(Name = 'Laptop X200', 
                                      GE_LGT_Product_Line__c='AUTOMOTIVE',
                                      GE_LGT_Product_Group__c ='LED PRODUCTS',
                                      CurrencyIsoCode='USD',
                                      CanUseQuantitySchedule=true,
                                      CanUseRevenueSchedule=true,
                                      isActive=true);
        insert prod1;
        
        //INSERT PRICE BOOK ENTRY
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = prod1.Id,
            UnitPrice = 0, 
            IsActive = true);
        
    }
    static testMethod void myUnitTest_standard() {
        ID userID = UserInfo.getUserID(); //[select id from user where isactive = true limit 1].id;
        ID userIDNA = [SELECT ID,GE_LGT_Business_Division__c FROM user WHERE GE_LGT_Business_Division__c='North America' limit 1 ].ID ; 
        
        
        Id recOppTypeID_standard = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        
        
        Id recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        
        /**************************************************************************************************/
        
        Account acc = TestDataUtil.createAccount();
        acc.Name='Test Acc2';
        acc.RecordTypeId=recAccTypeID;
        insert acc;
        
        
        // INSERT OPPTY RECORD
        Opportunity opp5 = TestDataUtil.createOpportunity(acc);
        opp5.Name = 'Testopp';
        opp5.StageName = 'S1 Consult';
        opp5.CurrencyIsoCode ='USD';
        opp5.Probability = 10;
        opp5.amount = 500;
        opp5.RecordTypeId = recOppTypeID_standard;
        opp5.Originated_from_Lead__c = true;
        opp5.GE_LGT_Oppty_Type2__c ='Standard';
        opp5.CloseDate = system.today()+3;
        opp5.PO_Receipt_Date__c = system.today()+3;
        insert opp5;
        
        //INSERT PRODUCT   
        Product2 prod1 = new Product2(Name = 'Laptop X200', 
                                      GE_LGT_Product_Line__c='AUTOMOTIVE',
                                      GE_LGT_Product_Group__c ='LED PRODUCTS',
                                      CurrencyIsoCode='USD',
                                      CanUseQuantitySchedule=true,
                                      CanUseRevenueSchedule=true,
                                      isActive=true);
        insert prod1;
        
        //INSERT PRICE BOOK ENTRY
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = prod1.Id,
            UnitPrice = 0, 
            IsActive = true);
        
    }
}
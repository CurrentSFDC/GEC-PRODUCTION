@isTest
private class OrderSearchControllerTest {
    
    @TestSetup
    static void setup(){

        Profile communityUserProfile = [SELECT Id FROM Profile WHERE Name = 'B2B Storefront Registered Users'
            LIMIT 1
        ];
        Map <String, Map <String, Object>> testData = new Map <String, Map <String, Object>> {
            
            ccrz.ccApiTestData.ACCOUNT_DATA => new Map <String, Object> {
                ccrz.ccApiTestData.ACCOUNT_LIST => new List <Map <String, Object>> {
                    new Map <String, Object> {
                        'name' => 'testAccount1',
                        'ccrz__dataId__c' => 'testAccount1',
                        'GE_LGT_Rep_Code__c' => 'testRepCode',
                        'GE_LGT_EM_SAP_Customer_Number__c' => 'testCustomerNo',
                        'GE_LGT_EM_SAPUniqueIdentifier__c' => 'testUniqueId'
                    },
                    new Map <String, Object> {
                        'name' => 'testAccount2',
                        'ccrz__dataId__c' => 'testAccount2'
                    }
                }
            },

            ccrz.ccApiTestData.CONTACT_DATA => new Map <String, Object> {
                ccrz.ccApiTestData.CONTACT_LIST => new List <Map <String, Object>> {
                    new Map <String, Object> {
                        'ccrz__dataId__c' => 'testContact1',
                        'account' => new Account(ccrz__dataId__c = 'testAccount1'),
                        'email' => 'testcontact1.ccrz@cloudcraze.com',
                        'lastName' => 'User1',
                        'firstName' => 'Test1'
                    },
                    new Map <String, Object> {
                        'ccrz__dataId__c' => 'testContact2',
                        'account' => new Account(ccrz__dataId__c = 'testAccount2'),
                        'email' => 'testcontact2.ccrz@cloudcraze.com',
                        'lastName' => 'User2',
                        'firstName' => 'Test2'
                    }
                }
            },
            ccrz.ccApiTestData.USER_DATA => new Map <String, Object> {
                ccrz.ccApiTestData.USER_LIST => new List <Map <String, Object>> {
                    new Map <String, Object> {
                        'ccrz__dataId__c' => 'testUser1',
                        'alias' => 'defusr1',
                        'email' => 'test.ccrz1@cloudcraze.com',
                        'lastName' => 'User1',
                        'firstName' => 'Test1',
                        'languageLocaleKey' => 'en_US',
                        'localeSIDKey' => 'en_US',
                        'emailEncodingKey' => 'UTF-8',
                        'profileId' => communityUserProfile.Id,
                        'username' => System.currentTimeMillis() + 'test1@cloudcraze.com',
                        'ccrz__CC_CurrencyCode__c' => 'EUR',
                        'contact' => new Contact(ccrz__dataId__c = 'testContact1'),
                        'timezoneSIDKey' => 'GMT'
                    },
                    new Map <String, Object> {
                        'ccrz__dataId__c' => 'testUser2',
                        'alias' => 'defusr2',
                        'email' => 'test.ccrz1@cloudcraze.com',
                        'lastName' => 'User2',
                        'firstName' => 'Test2',
                        'languageLocaleKey' => 'en_US',
                        'localeSIDKey' => 'en_US',
                        'emailEncodingKey' => 'UTF-8',
                        'profileId' => communityUserProfile.Id,
                        'username' => System.currentTimeMillis() + 'test2@cloudcraze.com',
                        'ccrz__CC_CurrencyCode__c' => 'EUR',
                        'contact' => new Contact(ccrz__dataId__c = 'testContact2'),
                        'timezoneSIDKey' => 'GMT'
                    }
                }
            }
        };

        ccrz.ccApiTestData.setupData(testData);


        //make multiple orders
        //GE Current trigger switches
        List<TriggerSwitch__c> switchList = new List<TriggerSwitch__c>{};
        switchList.add(TestDataUtil.createTriggerSwitch('OrderTrigger', False));    
        switchList.add(TestDataUtil.createTriggerSwitch('OrderLineItemUpdate', False));
        switchList.add(TestDataUtil.createTriggerSwitch('Update_Pricebook2ids', False));
        insert switchList;

        //Account/Contact setup
        Account ac = [SELECT Id FROM Account WHERE ccrz__dataId__c = 'testAccount1'];
        Account ac2 = [SELECT Id FROM Account WHERE ccrz__dataId__c = 'testAccount2'];

        Contact cont = [SELECT Id FROM Contact WHERE ccrz__dataId__c = 'testContact1'];
        AccountContactRelation acr = new AccountContactRelation(AccountId = ac2.Id, ContactId = cont.Id);
        insert acr;
 
        //GE Current order setup
        PriceBook2 pb = TestDataUtil.createPriceBook('testBook');
        insert pb;

        PriceBook2 pb2 = TestDataUtil.createPriceBook('LED');
        insert pb2;

        Order o1 = new Order(Customer_PO_Number__c = 'testPO1', GE_Order_NO__c = 'testOrderNo1', PriceBook2Id = pb.Id, Status = 'Draft', AccountId = ac.Id, Agent_Account__c = ac.Id, Sold_To__c = ac2.Id, CurrencyIsoCode = 'USD', EffectiveDate = Date.today().addDays(-1), Agent_SAPUniqueId__c = 'testUniqueId');
        insert o1;

        Order o2 = new Order(Customer_PO_Number__c = 'testPO2', GE_Order_NO__c = 'testOrderNo2', PriceBook2Id = pb.Id, Status = 'Draft', AccountId = ac2.Id, Agent_Account__c = ac2.Id, Sold_To__c = ac2.Id, CurrencyIsoCode = 'USD', EffectiveDate = Date.today().addDays(-10));
        insert o2;    
    }

    @isTest
    static void testSearchPO() {

        User u = [SELECT Id FROM User WHERE ccrz__dataId__c = 'testUser1'];

        System.runAs(u){
            Test.startTest();
            List<sObject> orderList = OrderSearchController.searchForOrders('testPO1', '1997-06-21', '3000-01-01');
            Test.stopTest();
            System.assertEquals(1, orderList.size(), 'search by PO No returned incorrect results');
            System.assertEquals('testPO1', ((Order)orderList[0]).Customer_PO_Number__c, 'search by PO No returned incorrect results');
        }
    }

    @isTest
    static void testSearchGESales() {

        User u = [SELECT Id FROM User WHERE ccrz__dataId__c = 'testUser2'];

        System.runAs(u){
            Test.startTest();
            List<sObject> orderList = OrderSearchController.searchForOrders('testOrderNo1', '1997-06-21', '3000-01-01');
            Test.stopTest();
            System.assertEquals(1, orderList.size(), 'search by GE Order Number returned incorrect results');
            System.assertEquals('testOrderNo1', ((Order)orderList[0]).GE_Order_NO__c, 'search by GE Order Number returned incorrect results');
        }
    }

    @isTest
    static void testSearchSoldTo() {

        User u = [SELECT Id FROM User WHERE ccrz__dataId__c = 'testUser2'];

        System.runAs(u){
            Test.startTest();
            List<sObject> orderList = OrderSearchController.searchForOrders('testAccount2', '1997-06-21', '3000-01-01');
            Test.stopTest();
            Account acct = [SELECT Id FROM Account WHERE Name = 'testAccount2' LIMIT 1];

            System.assertEquals(2, orderList.size(), 'search by Sold To Account returned incorrect results');
        }   
    }

    @isTest
    static void testInitDataDistributor() {

        User u = [SELECT Id FROM User WHERE ccrz__dataId__c = 'testUser2'];

        System.runAs(u){
            Test.startTest();
            List<sObject> orderList = OrderSearchController.initOrders('1997-06-21', '3000-01-01');
            Test.stopTest();
            System.assertEquals(2, orderList.size(), 'initOrdersDistributor returned incorrect results');
        }   
    }

    @isTest
    static void testInitDataAgent() {

        User u = [SELECT Id FROM User WHERE ccrz__dataId__c = 'testUser1'];

        System.runAs(u){
            Test.startTest();
            List<sObject> orderList = OrderSearchController.initOrders('1997-06-21', '3000-01-01');
            Test.stopTest();
            System.assertEquals(1, orderList.size(), 'initOrdersAgent returned incorrect results');
        }   
    }

    @isTest
    static void testSearchDates() {

        User u = [SELECT Id FROM User WHERE ccrz__dataId__c = 'testUser2'];

        String today = Datetime.now().format('yyyy-MM-dd');
        
        Datetime myDate = Datetime.now().addDays(-5);
        String dateStr = myDate.format('yyyy-MM-dd');

        System.runAs(u){
            Test.startTest();
            List<sObject> orderList = OrderSearchController.initOrders(dateStr, today);
            Test.stopTest();
            System.assertEquals(1, orderList.size(), 'initOrders returned incorrect results when testing dates');
        }
    }
}
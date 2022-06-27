/*
Class - DaintreeLicensingTests
Author - Dharmendra Oswal
Purpose - This test Class covers implementation for Daintree CSM Licensing, including the following triggers/classes:
	->CSMTrackerTriggerHelper
	->CSMTrackerTrigger
	->DaintreeProductsController
	->ViewDaintreeProductsController
	->LinkDaintreeOrders

Revision History(Date, Version, author, comments):
*******************************************************************
06 SEP 2018, Version 1.0, Dharmendra Oswal, Initial Version 
*/
@IsTest
public class DaintreeLicensingTests {
    static User testAgent;
    @testsetup static void initialSetup()
    {      
        
              
        string testNewOnCloudSKU1  = '9999999990';
     	string testNewOnCloudSKU2  = '9999999991';
    	string testNewOnCloudSKU3  = '9999999992';
     	string testNewOnPremSKU1   = '9999999993';
     	string testNewOnPremSKU2   = '9999999994';
     	string testNewOnPremSKU3   = '9999999995';
     	string testOnCloudAddonSKU = '9999999996';
     	string testOnCloudRenewSKU = '9999999997';
     	string testOnPremAddonSKU  = '9999999998';
     	string testOnPremRenewSKU  = '9999999999';
     	string testHardwareSKU1    = '8999999990';
     	string testHardwareSKU2    = '8999999991';
        
    	List<List<string>> products = new List<List<string>>
        						{new List<string>{testHardwareSKU1, testNewOnCloudSKU1, testNewOnCloudSKU2, testHardwareSKU2},
            					 new List<string>{testHardwareSKU1, testNewOnPremSKU1, testNewOnPremSKU2, testHardwareSKU2},
                                 new List<string>{testHardwareSKU1, testOnPremAddonSKU, testHardwareSKU2},
                                 new List<string>{testHardwareSKU1, testOnPremRenewSKU, testHardwareSKU2},
                                 new List<string>{testHardwareSKU1, testOnPremRenewSKU, testOnPremAddonSKU, testHardwareSKU2}
                                };
		List<List<string>> quantities = new List<List<string>>
        							{new List<string>{'1', '1', '2', '2'},
            						 new List<string>{'1', '1', '2', '4'},
                                     new List<string>{'1', '4', '2'},
                                     new List<string>{'1', '1', '2'},
                                     new List<string>{'1', '1', '6', '2'}
                                    }; 
        //List<Trigger
        //__c> switchList = TestDataUtil.insertTriggerSwitches();
        List<TriggerSwitch__c> switchList = new List<TriggerSwitch__c>{};
        switchList.add(TestDataUtil.createTriggerSwitch('OrderTrigger', False));    
        switchList.add(TestDataUtil.createTriggerSwitch('OrderLineItemUpdate', False));
        switchList.add(TestDataUtil.createTriggerSwitch('AssetTrigger', False));
        switchList.add(TestDataUtil.createTriggerSwitch('OpportunityTrigger', False));
        switchList.add(TestDataUtil.createTriggerSwitch('CSMTrackerTrigger',True));
        Insert switchList;	
       
        Daintree_Licensing__c defaultCS = Daintree_Licensing__c.getOrgDefaults();  
    	defaultCS.Access_Record_Type_ID__c = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('DainTree_Access_Records').getRecordTypeId();
    	defaultCS.Batch_Monitor_Email__c = 'dharmendra.oswal@ge.com';
    	//defaultCS.CSM_License_Creator__c = [Select Id from user where profile.name = 'GE_NAS_Support_Agent' LIMIT 1].Id;
    	//Espresso-RQT-1416 - User Separation as Current & Lightning.
        defaultCS.CSM_License_Creator__c = [Select Id from user where profile.name = 'System Administrator' LIMIT 1].Id;
    	defaultCS.Daintree_Orders_Phone__c = '(111) 111-1111';
    	defaultCS.Daintree_Support_Phone__c = '(222) 222-2222';
    	defaultCS.eLight_Order_Link_Static__c = 'https://www.google.com/';
    	defaultCS.On_Cloud_Renewal_SKU__c = testOnCloudRenewSKU;
    	defaultCS.On_Premise_Renewal_SKU__c = testOnPremRenewSKU;
    	defaultCS.Org_Wide_email_address_ID__c = [select id from OrgWideEmailAddress where address = 'apps@ge.com' LIMIT 1].Id;
    	defaultCS.Tracker_Record_Type_Id_New_CSM__c = Schema.SObjectType.Daintree_Order_Tracker__c.getRecordTypeInfosByDeveloperName().get('Daintree_New_CSM').getRecordTypeId();
    	defaultCS.Tracker_Record_Type_Id_AR__c = Schema.SObjectType.Daintree_Order_Tracker__c.getRecordTypeInfosByDeveloperName().get('Daintree_Renewals_and_Add_Ons').getRecordTypeId();
        Upsert defaultCS;
        
        List<GE_LGT_EM_MaterialMaster__c> mmList = new List<GE_LGT_EM_MaterialMaster__c>{};
        for(Integer i=0; i<10; i++)
        {
            GE_LGT_EM_MaterialMaster__c mm = TestDataUtil.createMaterialMaster('999999999'+ String.valueOf(i));
            mm.GE_LGT_EM_MaterialDescription__c = 'Daintree ' + '999999999'+ String.valueOf(i);
            mm.License_Flag_text__c = 'Daintree CSM';
            mmList.add(mm);            
        }
        for(Integer i=0; i<2; i++)
        {
            mmList.add(TestDataUtil.createMaterialMaster('899999999'+String.valueOf(i)));
        }
        Insert mmList;
        
        Account testAccount = TestDataUtil.createAccount();
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SAP_Account_Strategic').getRecordTypeId();
        Insert testAccount;
        
        PriceBook2 testPriceBook = TestDataUtil.createPriceBook('LED');
        Insert testPriceBook;
        
        Product2 testProduct = TestDataUtil.createProduct('Daintree License Product');
        Insert testProduct;
                
        PricebookEntry testPricebookEntry = [select id, pricebook2Id, currencyIsoCode from pricebookentry where pricebook2Id = :testPriceBook.Id Limit 1];
        
        ID parentRecTypeID = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('DainTree_CSM').getRecordTypeId();
        Asset onCloudAsset = new Asset(
        	name = 'CSM0001',
        	recordTypeId = parentRecTypeID,
        	GE_DT_CSM_License_Location__c = 'ON CLOUD',
        	Sales_Order_No__c = '00011110',
        	GE_DT_PO_Number__c = 'PO11110',
            GE_DT_eLight_Submitter_Email__c = 'dharmendra.oswal@ge.com',
            GE_DT_CSM_License_Domain_URL__c = 'https://www.google.com',
            GE_DT_Support_Start_Date__c = System.Today(),
            GE_DT_Support_End_Date__c = system.Today(),
            GE_DT_End_User_Co__c = 'Dominos',
            Order_Products_List__c = products[0][0] + '-' + quantities[0][0] + ',' + 
            						 products[0][1] + '-' + quantities[0][1] + ',' + 
            						 products[0][2] + '-' + quantities[0][2] + ',' +
            						 products[0][3] + '-' + quantities[0][3] 
        );
        
        Asset onPremAsset = new Asset(
        	name = 'CSM0002',
        	recordTypeId = parentRecTypeID,
        	GE_DT_CSM_License_Location__c = 'ON PREMISE',
        	Sales_Order_No__c = '00011111',
        	GE_DT_PO_Number__c = 'PO11111',
            GE_DT_eLight_Submitter_Email__c = 'dharmendra.oswal@ge.com',
            GE_DT_CSM_License_Domain_URL__c = 'https://www.google.com',
            GE_DT_Support_Start_Date__c = System.Today(),
            GE_DT_Support_End_Date__c = system.Today(),
            GE_DT_End_User_Co__c = 'Dominos',
            Order_Products_List__c = products[1][0] + '-' + quantities[1][0] + ',' + 
            						 products[1][1] + '-' + quantities[1][1] + ',' + 
            						 products[1][2] + '-' + quantities[1][2] + ',' +
            						 products[1][3] + '-' + quantities[1][3]
        );
        
        Insert (new List<Asset>{onCloudAsset, onPremAsset});
        
        onPremAsset.Sales_Order_No__c = '00011112';
        onPremAsset.GE_DT_PO_Number__c = 'PO11112';
        onPremAsset.Order_Activity__c = 'Add-On';
        onPremAsset.Order_Products_List__c = products[2][0] + '-' + quantities[2][0] + ',' + 
            						 		 products[2][1] + '-' + quantities[2][1] + ',' + 
            						 		 products[2][2] + '-' + quantities[2][2];
        Update onPremAsset;
        
        onPremAsset.Sales_Order_No__c = '00011113';
        onPremAsset.GE_DT_PO_Number__c = 'PO11113';
        onPremAsset.Order_Activity__c = 'Renewal';
        onPremAsset.Order_Products_List__c = products[3][0] + '-' + quantities[3][0] + ',' + 
            						 		 products[3][1] + '-' + quantities[3][1] + ',' + 
            						 		 products[3][2] + '-' + quantities[3][2];
        Update onPremAsset;
        
        onPremAsset.Sales_Order_No__c = '00011114';
        onPremAsset.GE_DT_PO_Number__c = 'PO11114';
        onPremAsset.Order_Activity__c = 'Renewal with Add-On';
        onPremAsset.Order_Products_List__c = products[4][0] + '-' + quantities[4][0] + ',' + 
            						 		 products[4][1] + '-' + quantities[4][1] + ',' +
                        					 products[4][2] + '-' + quantities[4][2] + ',' +
            						 		 products[4][3] + '-' + quantities[4][3];
        Update onPremAsset;
        
        onCloudAsset.Sales_Order_No__c = '00011115';
        onCloudAsset.GE_DT_PO_Number__c = 'PO11115';
        onCloudAsset.Order_Activity__c = 'Add-On';
        Update onCloudAsset;
        
        Id oppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Daintree').getRecordTypeId();
        List<opportunity> oppList = new List<opportunity>{};
        for (Integer i=0; i<products.size(); i++)
        {
            opportunity testOpp = new opportunity();
            testOpp.AccountId = testAccount.Id;
			testOpp.Name = 'Opp1111' + string.valueOf(i);
            testOpp.StageName = 'S1 Consult';
            testOpp.closeDate = System.today();
            testOpp.RecordTypeId = oppRecTypeId;
            oppList.add(testOpp);
        }
        Insert oppList;
        
        List<order> orderList = new List<Order>{};
        for (Integer i=0; i<products.size(); i++)
        {
            order testOrder = new order();
			testOrder.GE_Order_NO__c = '1111' + string.valueOf(i);
			testOrder.Customer_PO_Number__c= 'PO1111' + string.valueOf(i);
			testOrder.accountId = testAccount.Id;
			testOrder.EffectiveDate = Date.Today();
            testOrder.currencyIsocode = testPricebookEntry.currencyIsocode;
            testOrder.status='Draft';
            testOrder.pricebook2Id = testPricebookEntry.pricebook2Id;
            testOrder.OpportunityId = oppList[i].Id;
            orderList.add(testOrder);
        }
        Insert orderList;
        
        List<OrderItem> itemsList = new List<OrderItem>{};
        
        for(Integer i=0; i<products.size(); i++)
        {
            for(Integer j=0; j<products[i].size(); j++)
            {
                orderItem testOrderItem = new orderItem();
         		testOrderItem.pricebookentryid =  testPricebookEntry.Id;
           		testOrderItem.SKU__c = products[i][j];
           		testOrderItem.SKU_Description_Cat_Logic__c = 'Daintree ' + products[i][j];
           		testOrderItem.Quantity = Integer.valueOf(quantities[i][j]);
           		testOrderItem.orderId = orderList[i].Id;
                testOrderItem.unitPrice = 5;
           		itemsList.add(testOrderItem);
            }
        }
        Insert itemsList;
        
        List<Daintree_Order_Tracker__c> trackers = [select id from Daintree_Order_Tracker__c];
        system.assertEquals(6, trackers.size());
        
        
    }
    
    static void approveTracker(Id trackerId)
    {
        Id workItemId = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = :trackerId Limit 1].Id;       
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setAction('Approve');
        req.setWorkitemId(workItemId);       
        Approval.ProcessResult result =  Approval.process(req);        
    }
    
    @isTest static void test_DaintreeProductsController()
    {
        DaintreeProductsController testInstance = new DaintreeProductsController();
        testInstance.orderProductsList = '9999999990-2,8999999990-3,9999999991-1,8999999991-2';
        List<List<string>> tableElements = testInstance.getOrderProductsTable();
        system.assertEquals(2, tableElements.size());
        system.assertEquals('9999999990', tableElements[0][0]);
        system.assertEquals('2', tableElements[0][1]);
        system.assertEquals('Daintree 9999999990', tableElements[0][2]);
        system.assertEquals('9999999991', tableElements[1][0]);
        system.assertEquals('1', tableElements[1][1]);
        system.assertEquals('Daintree 9999999991', tableElements[1][2]);
    }
    
    @isTest static void test_LinkDaintreeOrders()
    {
        LinkDaintreeOrders testInstance = new LinkDaintreeOrders();
        Integer emailInvokes = 0;
        
        Test.startTest();		 
        testInstance.execute(null);
        emailInvokes = Limits.getEmailInvocations();
        Test.stopTest();
        
        system.assertEquals(1, emailInvokes);
        List<Daintree_Order_Tracker__c> trackers = [select order_flag__c, SO_Number__c, order__r.GE_Order_NO__c, 
                                                    opportunity__r.name from Daintree_Order_Tracker__c order by SO_Number__c asc];
        system.assertEquals(6, trackers.size());
        
        for(integer i=0; i<5; i++)
        {
            system.assertEquals(trackers[i].SO_Number__c, '000' + trackers[i].order__r.GE_Order_NO__c);
            system.assertEquals('Opp1111' + string.valueOf(i), trackers[i].opportunity__r.name);
            system.assertEquals(False, trackers[i].order_flag__c);            
        }
        
        system.assertEquals(NULL, trackers[5].order__r.GE_Order_NO__c);
        system.assertEquals(NULL, trackers[5].opportunity__r.name);
        system.assertEquals(True, trackers[5].order_flag__c);       
    }
    
    @isTest static void test_OrderUpdate()
    {
        Integer emailInvokes = 0;
        Asset testAsset = [Select Order_Products_List__c, Order_activity__c from asset where name = 'CSM0001'];
        //old products = '8999999990-1,9999999990-1,9999999991-2,8999999991-2'
        testAsset.Order_Products_List__c = '8999999990-1,9999999990-3,9999999992-2,8999999991-2';
        testAsset.Order_Activity__c = 'Order Update';
        
        Test.startTest();
        Update testAsset;
        emailInvokes = Limits.getEmailInvocations();
        Test.stopTest();

        system.assertEquals(1, emailInvokes);
    }    
        
    @isTest static void test_ViewDaintreeProductsController()
    {
        List<List<string>> products = new List<List<string>>
        						{new List<string>{'9999999990', '9999999991'},
            					 new List<string>{'9999999993', '9999999994'},
                                 new List<string>{'9999999998'},
                                 new List<string>{'9999999999'},
                                 new List<string>{'9999999999', '9999999998'}
                                };
		List<List<string>> quantities = new List<List<string>>
        							{new List<string>{'1', '2'},
            						 new List<string>{'1', '2'},
                                     new List<string>{'4'},
                                     new List<string>{'1'},
                                     new List<string>{'1', '6'}
                                    }; 
        Asset testAsset = [Select Id from asset where name = 'CSM0002'];
        
        LinkDaintreeOrders batchInstance = new LinkDaintreeOrders();
        Test.startTest();
        batchInstance.execute(null);
        Test.stopTest();
              
        ApexPages.StandardController sc = new ApexPages.StandardController(testAsset);
        ViewDaintreeProductsController testInstance = new ViewDaintreeProductsController(sc);
        DaintreeProducts.getSortedOrders(testAsset.Id);
        List<Order> orderTable = testInstance.getSortedOrders();
		        
	
        system.assertEquals(4, orderTable.size());
        
        for(Integer i=1; i<5; i++)
        {
            Boolean foundOrder = False;
            order thisOrder = new order();
            for(order o: orderTable)
            {   
                if(o.GE_Order_NO__c == '1111' + string.valueOf(i))
                {
                    foundOrder = True;
                    thisOrder = o;
                    system.assertEquals('PO1111' + string.valueOf(i), o.Customer_PO_Number__c);
                    break;
                }
            }
            system.assertEquals(True, foundOrder);
            List<string>skus = products[i];
            List<string>quants = quantities[i];
            system.assertEquals(skus.size(), thisOrder.orderItems.size());
            for(Integer j=0; j<skus.size(); j++)
            {
                Boolean foundOrderItem = False;
                orderItem thisOrderItem = new orderItem();
                for(orderItem oi: thisOrder.orderItems)
                {
                    if(oi.SKU__c == skus[j])
                    {
                        foundOrderItem = True;
                        system.assertEquals(double.valueOf(quants[j]), oi.Quantity);
                        system.assertEquals('Daintree ' + skus[j], oi.SKU_Description_Cat_Logic__c);
                        break;
                    }
                }
                system.assertEquals(True, foundOrderItem);
            }
        }
    }
    
    
    
    @isTest static void test_buildOnCloudNew()
    {
        Integer emailInvokes = 0;
        Daintree_Order_Tracker__c tracker = [select Id, Finish_build__c, CSM_License_Asset__c from Daintree_Order_Tracker__c where 
                                             order_type__c = 'New CSM' and CSM_License_Location__c = 'ON CLOUD' Limit 1];
        tracker.Finish_build__c = True;
        
		approveTracker(tracker.Id);
        
        List<Asset> accessRecord = [select GE_DT_CSM_Login__c, GE_DT_CSM_Password__c, Parent.name from Asset where 
                              ParentId = :tracker.CSM_License_Asset__c];
        accessRecord[0].GE_DT_CSM_Login__c = 'Masteradmin';
        accessRecord[0].GE_DT_CSM_Password__c = 'Adminmaster';
        Update accessRecord;
        
        Test.startTest();
        Update tracker;
        emailInvokes = Limits.getEmailInvocations();
        Test.stopTest();
        
        System.assertEquals(1, emailInvokes);
        Daintree_Order_Tracker__c postBuildTracker = [Select Status__c from Daintree_Order_Tracker__c where Id = :tracker.Id]; 
        System.assertEquals('Built', postBuildTracker.Status__c);        
    }
    
    @isTest static void test_buildOnPremNew()
    {
        Integer emailInvokes = 0;
        Daintree_Order_Tracker__c tracker = [select Id, Finish_build__c, CSM_License_Asset__c from Daintree_Order_Tracker__c where 
                                             order_type__c = 'New CSM' and CSM_License_Location__c = 'ON PREMISE' Limit 1];
        tracker.Finish_build__c = True;
        
        approveTracker(tracker.Id);
        
        List<Asset> accessRecord = [select GE_DT_CSM_Login__c, GE_DT_CSM_Password__c, Parent.name from Asset where 
                              ParentId = :tracker.CSM_License_Asset__c];
        accessRecord[0].GE_DT_CSM_Login__c = 'Masteradmin';
        accessRecord[0].GE_DT_CSM_Password__c = 'Adminmaster';
        Update accessRecord;
        
        Test.startTest();
        Update tracker;
        emailInvokes = Limits.getEmailInvocations();
        Test.stopTest();
        
        System.assertEquals(1, emailInvokes);
        Daintree_Order_Tracker__c postBuildTracker = [Select Status__c from Daintree_Order_Tracker__c where Id = :tracker.Id]; 
        System.assertEquals('Built', postBuildTracker.Status__c);        
    }
    
    @isTest static void test_buildOnPremAddOnWithAttach()
    {
        Integer emailInvokes = 0;
        Daintree_Order_Tracker__c tracker = [select Id, Finish_build__c, CSM_License_Asset__c from Daintree_Order_Tracker__c where 
                                             order_type__c = 'Add-On' and CSM_License_Location__c = 'ON PREMISE' Limit 1];
        tracker.Finish_build__c = True;
        tracker.Attach_License_File__c = 'YES';
                
		approveTracker(tracker.Id);
        
        Attachment licenseFile = new Attachment();
        licenseFile.Name = 'testFile.License';
        licenseFile.ParentId = tracker.Id;
        licenseFile.Body = Blob.valueOf('Sample text');
        
        Insert licenseFile;
        
        Test.startTest();
        Update tracker;
        emailInvokes = Limits.getEmailInvocations();
        Test.stopTest();
        
        System.assertEquals(1, emailInvokes);
        Daintree_Order_Tracker__c postBuildTracker = [Select Status__c from Daintree_Order_Tracker__c where Id = :tracker.Id]; 
        System.assertEquals('Built', postBuildTracker.Status__c);        
    }
    
    @isTest static void test_buildOnPremRenewWithAttach()
    {
        Integer emailInvokes = 0;
        Daintree_Order_Tracker__c tracker = [select Id, Finish_build__c, CSM_License_Asset__c from Daintree_Order_Tracker__c where 
                                             order_type__c = 'Renewal' and CSM_License_Location__c = 'ON PREMISE' Limit 1];
        tracker.Finish_build__c = True;
        tracker.Attach_License_File__c = 'YES';
                
		approveTracker(tracker.Id);
        
        Attachment licenseFile = new Attachment();
        licenseFile.Name = 'testFile.License';
        licenseFile.ParentId = tracker.Id;
        licenseFile.Body = Blob.valueOf('Sample text');
        
        Insert licenseFile;
        
        Test.startTest();
        Update tracker;
        emailInvokes = Limits.getEmailInvocations();
        Test.stopTest();
        
        System.assertEquals(1, emailInvokes);
        Daintree_Order_Tracker__c postBuildTracker = [Select Status__c from Daintree_Order_Tracker__c where Id = :tracker.Id]; 
        System.assertEquals('Built', postBuildTracker.Status__c);        
    }

    @isTest static void test_buildOnPremRenewAddOnWithAttach()
    {
        Integer emailInvokes = 0;
        Daintree_Order_Tracker__c tracker = [select Id, Finish_build__c, CSM_License_Asset__c from Daintree_Order_Tracker__c where 
                                             order_type__c = 'Renewal with Add-On' and CSM_License_Location__c = 'ON PREMISE' Limit 1];
        tracker.Finish_build__c = True;
        tracker.Attach_License_File__c = 'YES';
                
		approveTracker(tracker.Id);
        
        Attachment licenseFile = new Attachment();
        licenseFile.Name = 'testFile.License';
        licenseFile.ParentId = tracker.Id;
        licenseFile.Body = Blob.valueOf('Sample text');
        
        Insert licenseFile;
        
        Test.startTest();
        Update tracker;
        emailInvokes = Limits.getEmailInvocations();
        Test.stopTest();
        
        System.assertEquals(1, emailInvokes);
        Daintree_Order_Tracker__c postBuildTracker = [Select Status__c from Daintree_Order_Tracker__c where Id = :tracker.Id]; 
        System.assertEquals('Built', postBuildTracker.Status__c);  
        
    }    
    static testMethod void testAssetTrigger(){   
    AdminOverride__c adminOverride = new AdminOverride__c(); 
        adminOverride.Switch_Off_Trigger__c = true;
        insert adminOverride; 
        
        
       // insert new AdminOverride__c(Switch_Off_Trigger__c = True);
        List<TriggerSwitch__c> switchList = new List<TriggerSwitch__c>{};
        switchList.add(TestDataUtil.createTriggerSwitch('AssetTrigger', True));
        Insert switchList;	
        
          Asset onPremAsset = new Asset(
        	name = 'CSM0002',
        	//recordTypeId = parentRecTypeID,
        	GE_DT_CSM_License_Location__c = 'ON PREMISE',
        	Sales_Order_No__c = '00011111',
        	GE_DT_PO_Number__c = 'PO11111',
            GE_DT_eLight_Submitter_Email__c = 'dharmendra.oswal@ge.com',
            GE_DT_CSM_License_Domain_URL__c = 'https://www.google.com',
            GE_DT_Support_Start_Date__c = System.Today(),
            GE_DT_Support_End_Date__c = system.Today(),
            GE_DT_End_User_Co__c = 'Dominos'
           
        );
        
        Insert (new List<Asset>{onPremAsset});
       
}
}
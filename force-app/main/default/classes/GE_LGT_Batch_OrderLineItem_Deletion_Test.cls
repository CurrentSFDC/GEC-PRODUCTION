@isTest(seeAllData=false)
public class GE_LGT_Batch_OrderLineItem_Deletion_Test 
{
    static testmethod void method1()
    {
        List<TriggerSwitch__c> switchList=new List<TriggerSwitch__c>();
        TriggerSwitch__c triggerSwitch=TestDataUtil.createTriggerSwitch('OrderTrigger',true);
        switchList.add(triggerSwitch);
        TriggerSwitch__c triggerSwitch1=TestDataUtil.createTriggerSwitch('GE_LGT_EM_AvoidDuplicateAccount',true);
        switchList.add(triggerSwitch1);
        TriggerSwitch__c triggerSwitch2=TestDataUtil.createTriggerSwitch('GE_LGT_preventDuplicateAccount',true);
        switchList.add(triggerSwitch2);
        TriggerSwitch__c triggerSwitch3=TestDataUtil.createTriggerSwitch('GE_LGT_OpptyBefInsBefUpdtAftIns',true);
        switchList.add(triggerSwitch3);
        TriggerSwitch__c triggerSwitch4=TestDataUtil.createTriggerSwitch('OpportunityTrigger',true);
        switchList.add(triggerSwitch4);
        TriggerSwitch__c triggerSwitch5=TestDataUtil.createTriggerSwitch('OrderLineItemUpdate',true);
        switchList.add(triggerSwitch5);
        insert switchList;
        
        PriceBook2 ledPB=TestDataUtil.createPriceBook('LED');
        insert ledPB;
        
        ID userID = UserInfo.getUserID(); 
        Id recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-10-SP';
        insert acc;
        
        //Added product info on 21 Oct 20
        Product2 prod = TestDataUtil.createProduct('test');
        prod.name = 'Test Prod1';
        prod.isactive=true;
        insert prod; 
        
        //Added Pricebookentry for relating Order line item on 21 Oct 20
        ID pbet_id = [SELECT Id FROM PricebookEntry WHERE CurrencyIsoCode = 'USD' AND Product2Id =:prod.id AND Pricebook2.name = 'LED' and isactive= true LIMIT 1].ID;
        
                
        GE_LGT_EM_MaterialMaster__c matMaster=TestDataUtil.createMaterialMaster('93036710');
        insert matMaster;
                
        
         order testOrder = new order();
        testOrder.GE_Order_NO__c = '1111'  ;
        testOrder.Customer_PO_Number__c= 'PO1111' ;
        testOrder.accountId = acc.Id;
        testOrder.EffectiveDate = Date.Today();
        testOrder.currencyIsocode = 'USD';
        testOrder.status='Draft';
        //testOrder.CurrencyIsoCode = 'HUF';
        testOrder.pricebook2Id = ledPB.Id;//Changed hardcoded id on 21 Oct 2020
        //testOrder.OpportunityId = oppList[i].Id;
        insert testOrder;
                
        
        OrderItem oli=TestDataUtil.createOrderItem('9999','10');
        oli.orderId = testOrder.Id;
        oli.PricebookEntryId = pbet_id;
        oli.SAP_OrderItem_Deletion_Flag__c='Yes';
        insert oli;    
          
        Test.startTest();
        GE_LGT_Batch_OrderLineItem_Deletion orderDel=new GE_LGT_Batch_OrderLineItem_Deletion();
        id jobid =Database.executeBatch(orderDel,1);       
        Test.stopTest();
    }
}
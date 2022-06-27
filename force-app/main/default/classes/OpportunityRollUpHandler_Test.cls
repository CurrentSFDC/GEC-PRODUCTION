/*
Name - OpportunityRollUpHandler_Test
Author - Siva
Purpose - Test Class
Date - May-2016
*/  
@isTest
public class OpportunityRollUpHandler_Test {
public static Map<String,id> mapRecTypeNameID=OpportunityConstantClass.mapRecTypeNameID();


 static testmethod void rollupOnAccount_Test()
    { 
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
        
        triggerSwitches.get('OrderTrigger').isActive__c=true;
        triggerSwitches.get('AccountTrigger').isActive__c=true;
        
        insert  triggerSwitches.values();
        
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        Profile objProfile = [Select Id, Name from Profile where Name =:'EUROPE Current Super User' limit 1];
        EMEAProfiles__c emea=new EMEAProfiles__c(name=objProfile.id);
        insert emea;
        User u2=OpportunityTriggerHelper_Test.createuser(objProfile.id,'Europe',true);
        System.runAs(u2)
        {
            test.starttest();
            ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
            List<Account> accs=OpportunityTriggerHelper_Test.createAccounts(1,recAccTypeID,true);
            
            Id recoppType_StandardID = mapRecTypeNameID.get(OpportunityConstantClass.STANDARD_ADV);
            
            List<Opportunity> opps=OpportunityTriggerHelper_Test.createOpportunities(2,recoppType_StandardID,true,accs[0]);
            
            List<Order> ordList=OpportunityTriggerHelper_Test.createOrders(1,'Estimated PO',true,opps[0],accs[0]);
            //OpportunityLineItem lineitem=OpportunityTriggerHelper_Test.addOptyProduct(opps[0],ledPB.id,true);
            
            List<Account> testAcc=[select id,Sum_of_all_Open_Op_Revenues__c,Sum_of_Estimated_Orders_To_Go__c,Sum_of_SAP_Orders_Received__c from Account where id=:accs[0].id];
            list<AggregateResult> testOpp=[select sum(Total_Orders_Received_TD__c) ordtotal,sum(Estimated_Orders_to_go__c) esttotal,sum(Amount) amtotal from Opportunity where id in:opps];
            //system.assertequals(testOpp[0].get('amtotal'),testAcc[0].Sum_of_all_Open_Op_Revenues__c);
           // system.assertequals(testOpp[0].get('ordtotal'),testAcc[0].Sum_of_SAP_Orders_Received__c);
            //system.assertequals(testOpp[0].get('esttotal'),testAcc[0].Sum_of_Estimated_Orders_To_Go__c);
            
            test.stoptest();
            
            
        }
    }
    static testmethod void OrderOwnerChangeIfOptyOwnerChange_test()
    { 
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
        
        triggerSwitches.get('OrderTrigger').isActive__c=true;
        triggerSwitches.get('AccountTrigger').isActive__c=true;
        
        insert  triggerSwitches.values();
        
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        Profile objProfile = [Select Id, Name from Profile where Name =:'NA Current Super User' limit 1];
        EMEAProfiles__c emea=new EMEAProfiles__c(name=objProfile.id);
        insert emea;
        User u2=OpportunityTriggerHelper_Test.createuser(objProfile.id,'North America',true);
        User u3=OpportunityTriggerHelper_Test.createuser(objProfile.id,'North America',false);
        u3.Email= 'NorthAmerica1'+'@testorg.com';
        u3.UserName='NorthAmerica1'+'@testorg.com';
        insert u3;
        System.runAs(u2)
        {
            test.starttest();
            ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
            List<Account> accs=OpportunityTriggerHelper_Test.createAccounts(1,recAccTypeID,true);
            
            Id recoppType_StandardID = mapRecTypeNameID.get(OpportunityConstantClass.STANDARD_ADV);
            
            List<Opportunity> opps=OpportunityTriggerHelper_Test.createOpportunities(2,recoppType_StandardID,true,accs[0]);
            
            List<Order> ordList=OpportunityTriggerHelper_Test.createOrders(1,'Estimated PO',true,opps[0],accs[0]);
            opps[0].ownerId=u3.id;
            update opps[0];
            List<Opportunity> testOpps=[select id,Ownerid from opportunity where id=:opps[0].id];
            for(Order r:[select id,ownerid from Order where OpportunityId=:opps[0].id]){
                system.Assertequals(r.ownerid,testOpps[0].Ownerid);
            }
        }
    }
    static testmethod void estimatedOrderCreation_Test()
    { 
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
        
        triggerSwitches.get('OrderTrigger').isActive__c=true;
        triggerSwitches.get('AccountTrigger').isActive__c=true;
        
        insert  triggerSwitches.values();
        
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        Profile objProfile = [Select Id, Name from Profile where Name =:'NA Current Super User' limit 1];
        EMEAProfiles__c emea=new EMEAProfiles__c(name=objProfile.id);
        insert emea;
        User u2=OpportunityTriggerHelper_Test.createuser(objProfile.id,'North America',true);
        System.runAs(u2)
        {
            test.starttest();
            ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
            List<Account> accs=OpportunityTriggerHelper_Test.createAccounts(1,recAccTypeID,true);
            
            Id recoppType_StandardID = mapRecTypeNameID.get(OpportunityConstantClass.DAINTREE_ADV);
            
            List<Opportunity> opps=OpportunityTriggerHelper_Test.createOpportunities(1,recoppType_StandardID,false,accs[0]);
            opps[0].Total_Order_Amount__c=10000;
            insert opps;
           
           
            
        }
    }
    static testmethod void accountUpdateOnOrder()
    { 
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
        
        triggerSwitches.get('OrderTrigger').isActive__c=true;
        triggerSwitches.get('AccountTrigger').isActive__c=true;
        
        insert  triggerSwitches.values();
        
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        Profile objProfile = [Select Id, Name from Profile where Name =:'NA Current Super User' limit 1];
        EMEAProfiles__c emea=new EMEAProfiles__c(name=objProfile.id);
        insert emea;
        User u2=OpportunityTriggerHelper_Test.createuser(objProfile.id,'North America',true);
        User u3=OpportunityTriggerHelper_Test.createuser(objProfile.id,'North America',false);
        u3.Email= 'NorthAmerica1'+'@testorg.com';
        u3.UserName='NorthAmerica1'+'@testorg.com';
        insert u3;
        System.runAs(u2)
        {
            test.starttest();
            ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
            List<Account> accs=OpportunityTriggerHelper_Test.createAccounts(2,recAccTypeID,true);
            
            Id recoppType_StandardID = mapRecTypeNameID.get(OpportunityConstantClass.STANDARD_ADV);
            
            List<Opportunity> opps=OpportunityTriggerHelper_Test.createOpportunities(2,recoppType_StandardID,true,accs[0]);
         
            List<Order> ordList=OpportunityTriggerHelper_Test.createOrders(1,'Estimated PO',true,opps[0],accs[0]);
            opps[0].AccountId=accs[1].id;
            update opps[0];
            List<Opportunity> testOpps=[select id,AccountId from opportunity where id=:opps[0].id];
            for(Order r:[select id,AccountId from Order where OpportunityId=:opps[0].id]){
                system.Assertequals(r.AccountId,testOpps[0].AccountId);
            }
        }
    }
}
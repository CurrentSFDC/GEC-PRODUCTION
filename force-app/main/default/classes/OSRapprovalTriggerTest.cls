@isTest(seealldata=true)
public class OSRapprovalTriggerTest { 
    
       // Static ID StandardRecID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeID();

        @isTest
        static void metTest(){
            Account acc = new Account();
            acc.Name = 'Tett';
            insert acc;
                system.debug(acc);
            
            Contract ct = new Contract();
            ct.Name = 'Contract Test555';
            ct.AccountId = acc.Id;
            insert ct;
            system.debug(ct);
            
            Pricebook2 pb = new Pricebook2();
            pb.Name = 'book54';
            insert pb;
            system.debug(pb);
     
          ID rectypeOppID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('StandardAdvance').getRecordTypeId();
          List<Opportunity> oppList = new  List<Opportunity>();
            Opportunity op = new Opportunity();
            op.Name = 'opty88';
            op.AccountId = acc.Id;
            //op.RecordTypeId = '0123j000000X90Q';
            op.RecordTypeId = rectypeOppID;
            op.ContractId = ct.Id;
            op.Pricebook2Id = pb.id;
                  
            op.StageName = 'S1 Consult'; 
            op.CloseDate = date.today();
            oppList.add(op);   
            insert oppList;
           // insert op;
                system.debug(oppList);
            
        //    List<Opportunity_Support_Request__c> oList = new  List<Opportunity_Support_Request__c>();
            ID rectypeID = Schema.SObjectType.Opportunity_Support_Request__c.getRecordTypeInfosByName().get('QuickStock Request').getRecordTypeId();
         //   ID rectypeID = [select id from Opportunity_Support_Request__c where RecordType.Name = 'QuickStock Request' limit 1];
            system.debug('rectypeID'+rectypeID);
            Opportunity_Support_Request__c osr = new Opportunity_Support_Request__c();
            osr.Opportunity_Name__c = op.Id;
            osr.Sales_Region__c = 'South';
            osr.Stocking_Agent__c = 'ESU';
            osr.State_for_Product_Request__c = 'Multiple';
            osr.Status__c = 'Not Submitted';
            osr.Requested_Action__c = 'Add';
            osr.Program_Type__c = 'NPI Program';
           // osr.Requested_Date__c = date.today();
           // osr.RecordTypeId = id.valueOf('0126s0000004PEfAAM');//uat id
           // osr.RecordTypeId = '0123j000000XA4q';//prod new id
              osr.RecordTypeId = rectypeID;
            osr.Requested_Timing__c = date.today();
          //  oList.add(osr);
            insert osr;
           system.debug(osr);
            
            OSR_Product__c prod = new OSR_Product__c();
            prod.OSR_ID__c = osr.Id;
            prod.Product_Type__c = 'LED Lamp';
            prod.Requested_Stocking_Amount__c = 10;
            prod.Estimated_Annual_Usage__c = 100;
            insert prod;
                   
            osr.Status__c = 'Open';
            upsert osr; 
            
            List<Opportunity_Support_Request__c> osrList = [SELECT Opportunity_Name__c,Sales_Region__c,Stocking_Agent__c,
                                                           State_for_Product_Request__c,Status__c,Requested_Action__c,Program_Type__c,
                                                            Requested_Date__c from Opportunity_Support_Request__c];
            
            List<OSR_Product__c> prodList = [SELECT id,Product_Type__c,Requested_Stocking_Amount__c,Estimated_Annual_Usage__c FROM OSR_Product__c];
            
           // System.assertEquals(0, osrList.size());  
           
          //  Test.startTest();
            
            //Database.SaveResult result = Database.insert(op, false);
           // Database.insert(List<Opportunity> oppList) res = Database.insert(oppList, false);
          //  Test.stopTest();
         
    }
}
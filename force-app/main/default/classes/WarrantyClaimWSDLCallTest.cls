@istest
public class WarrantyClaimWSDLCallTest {
    
    static testmethod void Testmethod1(){
        Test.startTest();
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        contact ca = new contact(FirstName= 'testCon', LastName='test', Email='abc@xyz.com', AccountId= Acc.id);
        insert ca;
        
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email'); 
        cas.AccountId=Acc.id;
        cas.eLight_Address_2__c ='Test,Test1 NY 100001';
        insert cas;
        
        AdminOverride__c adminOverride = new AdminOverride__c();
        adminOverride.Switch_Off_Trigger__c = TRUE;
        insert adminOverride;
        
        Order ord = new Order();
        ord.Name = 'OrderTest';
        ord.AccountId = Acc.Id;
        ord.Sold_To__c = Acc.id;
        ord.ShipToName__c = 'Test';
        ord.ShippingCity = 'Test';
        ord.ShippingCountry = 'Test';
        ord.ShipToStreet2__c = 'Test';
        ord.Type = 'ZSAM';
        ord.Order_Req_Delivery_Date__c = date.today(); 
        ord.EffectiveDate = date.today();
        ord.Status = 'Draft';
        insert ord;
        
        ord.Name = 'order test 54';
        update ord;
                
        Dispute_Request__c disc = new   Dispute_Request__c();
        disc.Case__c = cas.id;
        disc.Status__c = 'Approved';
        disc.Transaction_ID__c= 'Return';
        disc.Original_Order__c = ord.id;
        disc.Sold_To__c=ord.Sold_To__c;
        insert disc;
        
        Shipment_Detail__c sd = new Shipment_Detail__c();
        sd.GE_NAS_Case_Number__c = cas.id;
        sd.Dispute_Request__c = disc.id;
        sd.Install_Date__c = Date.today();
        sd.Discrepancy_Qty__c = 2;
        sd.Installed_Qty__c = 2;
        insert sd;
        
        Account acc1 = new Account();
        acc1.name = 'acc54321';
        acc1.GE_LGT_EM_SAP_Customer_Number__c = ord.Sold_To__c;
        
        insert acc1;

        
        WarrantyClaimWSDLCall.getOrderDtl(disc.id);

        
    
        invocableWarrantyReplaceWSDLCall.methodInputs argument;
        argument = new invocableWarrantyReplaceWSDLCall.methodInputs();
        argument.disID = disc.Id;
        System.debug('disID is '+disc.Id);
        invocableWarrantyReplaceWSDLCall.callWarrantyReplaceWSDL(new List<invocableWarrantyReplaceWSDLCall.methodInputs>{argument});
        Test.stopTest();
        
    }
}
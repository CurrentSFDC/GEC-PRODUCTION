@istest
public class DisputeWithProductsControllerTest {
    Static testmethod void getcaseProdsTest(){
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        contact ca = new contact(FirstName= 'testCon', LastName='test', Email='abc@xyz.com', AccountId= Acc.id);
        insert ca;
        
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', Spec_Reg_Agency__c = Acc.id ); 
        insert cas;
        
        Dispute_Request__c disc = new   Dispute_Request__c();
        disc.Case__c = cas.id;
        disc.Status__c = 'Open';
        insert disc;
        
        List<Shipment_Detail__c> sl = new  List<Shipment_Detail__c>();
        Shipment_Detail__c sd = new Shipment_Detail__c();
        sd.GE_NAS_Case_Number__c = cas.id;
        sd.Unique_ID__c = 'ABC';
        sd.GE_NAS_Type_of_Problem__c = 'Return - Return';
        sd.GE_NAS_Type_of_Problem1__c = 'Return';
        sl.add(sd);
        //insert sd;
        
       insert sl;
        
        Test.startTest();
        DisputeWithProductsController obj = new DisputeWithProductsController();
        obj.getcaseProds();
        obj.getcaseDtl();
        Test.stopTest();
    }
}
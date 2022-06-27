/*
Name - InsertDisputeRequestTest
Methods - Testmethod1		  
Purpose - Test Class for 'InsertDisputeRequest' trigger
*/
@istest
public class InsertDisputeRequestTest {
    static testmethod void Testmethod1(){
        Set<String> uids = new  Set<String>();
        Id devRecordTypeId = Schema.SObjectType.Dispute_Request__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        
        
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        contact ca = new contact(FirstName= 'testCon', LastName='test', Email='abc@xyz.com', AccountId= Acc.id);
        insert ca;
        
        Date newDate = Date.today();
        GE_LGT_EM_InvoiceHeader__c invH = new GE_LGT_EM_InvoiceHeader__c();
        invH.GE_LGT_EM_Payer_SoldTo_Account_Number__c = '0000194800';
        invH.GE_LGT_EM_Invoice_Creation_Date__c = newDate;
        insert invH;
        
        GE_LGT_EM_InvoiceLineItem__c invL = new GE_LGT_EM_InvoiceLineItem__c();
        invL.GE_LGT_EM_Customer_PO_Number__c = '30804';
        invL.GE_LGT_EM_Order_Number__c = '0000890953';
        invL.GE_LGT_EM_InvoiceHeaderNumber__c = invH.id;
        insert invL;
        
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', Spec_Reg_Agency__c = Acc.id ); 
        insert cas;
        
        Dispute_Request__c disc = new   Dispute_Request__c();
        disc.Case__c = cas.id;
        disc.Status__c = 'Open';
        disc.RecordTypeId = devRecordTypeId;
        insert disc;

        TEST.startTest();
        List<Shipment_Detail__c> sl = new  List<Shipment_Detail__c>();
        Shipment_Detail__c sd = new Shipment_Detail__c();
        sd.GE_NAS_Case_Number__c = cas.id;
        sd.Unique_ID__c = 'ABC';
        sd.GE_NAS_Type_of_Problem__c = 'Return - Return';
        sd.GE_NAS_Type_of_Problem1__c = 'Return';
        sd.Invoice_Line__c = invL.id;
        sd.SFDC_Invoice__c = invH.id;
        sd.Distributor_ID__c = '0013j00002dOZH6';
        
        sl.add(sd);
        //insert sd;
        
       insert sl;


      Shipment_Detail__c sd1 = new Shipment_Detail__c();
        sd1.GE_NAS_Case_Number__c = cas.id;
        sd1.Unique_ID__c = 'ABC';
        sd1.GE_NAS_Type_of_Problem__c = 'Return - Return';
        sd1.GE_NAS_Type_of_Problem1__c = 'Return';
        //sl.add(sd);
        insert sd1;
        TEST.stopTest();
      
    }
    
    static testmethod void Testmethod2(){
        Set<String> uids = new  Set<String>();
        Id devRecordTypeId = Schema.SObjectType.Dispute_Request__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        contact ca = new contact(FirstName= 'testCon', LastName='test', Email='abc@xyz.com', AccountId= Acc.id);
        insert ca;
        
        Date newDate = Date.today();
        GE_LGT_EM_InvoiceHeader__c invH = new GE_LGT_EM_InvoiceHeader__c();
        invH.GE_LGT_EM_Payer_SoldTo_Account_Number__c = '0000194800';
        invH.GE_LGT_EM_Invoice_Creation_Date__c = newDate;
        insert invH;
        
        GE_LGT_EM_InvoiceLineItem__c invL = new GE_LGT_EM_InvoiceLineItem__c();
        invL.GE_LGT_EM_Customer_PO_Number__c = '30804';
        invL.GE_LGT_EM_Order_Number__c = '0000890953';
        invL.GE_LGT_EM_InvoiceHeaderNumber__c = invH.id;
        insert invL;
        
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', Spec_Reg_Agency__c = Acc.id ); 
        insert cas;
        
        Dispute_Request__c disc = new   Dispute_Request__c();
        disc.Case__c = cas.id;
        disc.Status__c = 'Open';
        disc.RecordTypeId = devRecordTypeId;
        insert disc;
        TEST.startTest();
        List<Shipment_Detail__c> sl = new  List<Shipment_Detail__c>();
           Shipment_Detail__c sd5 = new Shipment_Detail__c();
        sd5.GE_NAS_Case_Number__c = cas.id;
        sd5.Unique_ID__c='ABC';  
        sd5.Dispute_Request__c = disc.id;
        sd5.GE_NAS_Type_of_Problem__c = 'Return - Replacement'; 
        sd5.GE_NAS_Type_of_Problem1__c = 'Replacement';
        sd5.Invoice_Line__c = invL.id;
        sd5.SFDC_Invoice__c = invH.id;
        sd5.Distributor_ID__c = '0013j00002dOZH6';
        sl.add(sd5);
        //insert sd;
        
       insert sl;
        
        Shipment_Detail__c sd1 = new Shipment_Detail__c();
        sd1.GE_NAS_Case_Number__c = cas.id;
        sd1.Unique_ID__c = 'ABC';
        sd1.GE_NAS_Type_of_Problem__c = 'Return - Replacement';
        sd1.GE_NAS_Type_of_Problem1__c = 'Replacement';
        sd1.Invoice_Line__c = invL.id;
        sd1.SFDC_Invoice__c = invH.id;
        sd1.Distributor_ID__c = '0013j00002dOZH6';
        //sl.add(sd);
        insert sd1;
        TEST.stopTest();
      
    }
    
    
    static testmethod void Testmethod3(){
        Set<String> uids = new  Set<String>();
        Id devRecordTypeId = Schema.SObjectType.Dispute_Request__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        contact ca = new contact(FirstName= 'testCon', LastName='test', Email='abc@xyz.com', AccountId= Acc.id);
        insert ca;
        
        Date newDate = Date.today();
        GE_LGT_EM_InvoiceHeader__c invH = new GE_LGT_EM_InvoiceHeader__c();
        invH.GE_LGT_EM_Payer_SoldTo_Account_Number__c = '0000194800';
        invH.GE_LGT_EM_Invoice_Creation_Date__c = newDate;
        insert invH;
        
        GE_LGT_EM_InvoiceLineItem__c invL = new GE_LGT_EM_InvoiceLineItem__c();
        invL.GE_LGT_EM_Customer_PO_Number__c = '30804';
        invL.GE_LGT_EM_Order_Number__c = '0000890953';
        invL.GE_LGT_EM_InvoiceHeaderNumber__c = invH.id;
        insert invL;
        
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', Spec_Reg_Agency__c = Acc.id ); 
        insert cas;
        
        Dispute_Request__c disc = new   Dispute_Request__c();
        disc.Case__c = cas.id;
        disc.Status__c = 'Open';
        disc.RecordTypeId = devRecordTypeId;
        insert disc;
        TEST.startTest();
        List<Shipment_Detail__c> sl = new  List<Shipment_Detail__c>();
        Shipment_Detail__c sd11 = new Shipment_Detail__c();
        sd11.GE_NAS_Case_Number__c = cas.id;
        sd11.Unique_ID__c='ABCWC';
        sd11.GE_NAS_Type_of_Problem__c = 'Warranty - Credit';
        sd11.GE_NAS_Type_of_Problem1__c = 'Credit';
        sd11.Invoice_Line__c = invL.id;
        sd11.SFDC_Invoice__c = invH.id;
        sd11.Distributor_ID__c = '0013j00002dOZH6';
        
        sl.add(sd11);
        //insert sd;
        
       insert sl;
        
        Shipment_Detail__c sd1 = new Shipment_Detail__c();
        sd1.GE_NAS_Case_Number__c = cas.id;
        sd1.Unique_ID__c = 'ABCWC';
        sd1.GE_NAS_Type_of_Problem__c = 'Warranty - Credit';
        sd1.GE_NAS_Type_of_Problem1__c = 'Credit';
        sd1.Invoice_Line__c = invL.id;
        sd1.SFDC_Invoice__c = invH.id;
        sd1.Distributor_ID__c = '0013j00002dOZH6';
        //sl.add(sd);
        insert sd1;
        TEST.stopTest();
      
    }
    
    static testmethod void Testmethod4(){
        Set<String> uids = new  Set<String>();
        Id devRecordTypeId = Schema.SObjectType.Dispute_Request__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        contact ca = new contact(FirstName= 'testCon', LastName='test', Email='abc@xyz.com', AccountId= Acc.id);
        insert ca;
        
        Date newDate = Date.today();
        GE_LGT_EM_InvoiceHeader__c invH = new GE_LGT_EM_InvoiceHeader__c();
        invH.GE_LGT_EM_Payer_SoldTo_Account_Number__c = '0000194800';
        invH.GE_LGT_EM_Invoice_Creation_Date__c = newDate;
        insert invH;
        
        GE_LGT_EM_InvoiceLineItem__c invL = new GE_LGT_EM_InvoiceLineItem__c();
        invL.GE_LGT_EM_Customer_PO_Number__c = '30804';
        invL.GE_LGT_EM_Order_Number__c = '0000890953';
        invL.GE_LGT_EM_InvoiceHeaderNumber__c = invH.id;
        insert invL;
        
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', Spec_Reg_Agency__c = Acc.id ); 
        insert cas;
        
        Dispute_Request__c disc = new   Dispute_Request__c();
        disc.Case__c = cas.id;
        disc.Status__c = 'Open';
        disc.RecordTypeId = devRecordTypeId;
        insert disc;
        TEST.startTest();
        List<Shipment_Detail__c> sl = new  List<Shipment_Detail__c>();
        Shipment_Detail__c sd4 = new Shipment_Detail__c();
        sd4.GE_NAS_Case_Number__c = cas.id;
        sd4.Unique_ID__c='ABC1';
        sd4.GE_NAS_Type_of_Problem__c = 'Overage - Return';
        sd4.GE_NAS_Type_of_Problem1__c = 'Return';
        sd4.Invoice_Line__c = invL.id;
        sd4.SFDC_Invoice__c = invH.id;
        sd4.Distributor_ID__c = '0013j00002dOZH6';
        sl.add(sd4);
        //insert sd;
        
       insert sl;
        
         List<Shipment_Detail__c> sd5 = new List<Shipment_Detail__c>();
        Shipment_Detail__c sd1 = new Shipment_Detail__c();
        sd1.GE_NAS_Case_Number__c = cas.id;
        sd1.Unique_ID__c = 'ABC1';
         sd1.GE_NAS_Type_of_Problem__c = 'Overage - Return';
        sd1.GE_NAS_Type_of_Problem1__c = 'Return';
        sd1.Invoice_Line__c = invL.id;
        sd1.SFDC_Invoice__c = invH.id;
        sd1.Distributor_ID__c = '0013j00002dOZH6';
        sd5.add(sd1);
        insert sd5;
        TEST.stopTest();
      
    }
    
    static testmethod void Testmethod5(){
        Set<String> uids = new  Set<String>();
        Id devRecordTypeId = Schema.SObjectType.Dispute_Request__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        contact ca = new contact(FirstName= 'testCon', LastName='test', Email='abc@xyz.com', AccountId= Acc.id);
        insert ca;
        
        Date newDate = Date.today();
        GE_LGT_EM_InvoiceHeader__c invH = new GE_LGT_EM_InvoiceHeader__c();
        invH.GE_LGT_EM_Payer_SoldTo_Account_Number__c = '0000194800';
        invH.GE_LGT_EM_Invoice_Creation_Date__c = newDate;
        insert invH;
        
        GE_LGT_EM_InvoiceLineItem__c invL = new GE_LGT_EM_InvoiceLineItem__c();
        invL.GE_LGT_EM_Customer_PO_Number__c = '30804';
        invL.GE_LGT_EM_Order_Number__c = '0000890953';
        invL.GE_LGT_EM_InvoiceHeaderNumber__c = invH.id;
        insert invL;
        
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', Spec_Reg_Agency__c = Acc.id ); 
        insert cas;
        
        Dispute_Request__c disc = new   Dispute_Request__c();
        disc.Case__c = cas.id;
        disc.Status__c = 'Open';
        disc.RecordTypeId = devRecordTypeId;
        insert disc;
        TEST.startTest();
        List<Shipment_Detail__c> sl = new  List<Shipment_Detail__c>();
        Shipment_Detail__c sd6 = new Shipment_Detail__c();
        sd6.GE_NAS_Case_Number__c = cas.id;
        sd6.Unique_ID__c='ABCSR';
        sd6.GE_NAS_Type_of_Problem__c = 'Shortage - Return';
        sd6.GE_NAS_Type_of_Problem1__c = 'Return';
        sd6.Invoice_Line__c = invL.id;
        sd6.SFDC_Invoice__c = invH.id;
        sd6.Distributor_ID__c = '0013j00002dOZH6';
        sl.add(sd6);
        //insert sd;
        
       insert sl;
        
       Shipment_Detail__c sd1 = new Shipment_Detail__c();
        sd1.GE_NAS_Case_Number__c = cas.id;
        sd1.Unique_ID__c = 'ABCSR';
        sd1.GE_NAS_Type_of_Problem__c = 'Shortage - Return';
        sd1.GE_NAS_Type_of_Problem1__c = 'Return';
        sd1.Invoice_Line__c = invL.id;
        sd1.SFDC_Invoice__c = invH.id;
        sd1.Distributor_ID__c = '0013j00002dOZH6';
        //sl.add(sd);
        insert sd1;
        TEST.stopTest();
    }
    
    static testmethod void Testmethod6(){
        Set<String> uids = new  Set<String>();
        Id devRecordTypeId = Schema.SObjectType.Dispute_Request__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        contact ca = new contact(FirstName= 'testCon', LastName='test', Email='abc@xyz.com', AccountId= Acc.id);
        insert ca;
        
        Date newDate = Date.today();
        GE_LGT_EM_InvoiceHeader__c invH = new GE_LGT_EM_InvoiceHeader__c();
        invH.GE_LGT_EM_Payer_SoldTo_Account_Number__c = '0000194800';
        invH.GE_LGT_EM_Invoice_Creation_Date__c = newDate;
        insert invH;
        
        GE_LGT_EM_InvoiceLineItem__c invL = new GE_LGT_EM_InvoiceLineItem__c();
        invL.GE_LGT_EM_Customer_PO_Number__c = '30804';
        invL.GE_LGT_EM_Order_Number__c = '0000890953';
        invL.GE_LGT_EM_InvoiceHeaderNumber__c = invH.id;
        insert invL;
        
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', Spec_Reg_Agency__c = Acc.id ); 
        insert cas;
        
        Dispute_Request__c disc = new   Dispute_Request__c();
        disc.Case__c = cas.id;
        disc.Status__c = 'Open';
        disc.RecordTypeId = devRecordTypeId;
        insert disc;
        TEST.startTest();
        List<Shipment_Detail__c> sl = new  List<Shipment_Detail__c>();
        Shipment_Detail__c sd8 = new Shipment_Detail__c(); 
        sd8.GE_NAS_Case_Number__c = cas.id;
        sd8.Unique_ID__c='ABCSC';
        sd8.GE_NAS_Type_of_Problem__c = 'Shortage - Credit';
        sd8.GE_NAS_Type_of_Problem1__c = 'Credit';
        sd8.Invoice_Line__c = invL.id;
        sd8.SFDC_Invoice__c = invH.id;
        sd8.Distributor_ID__c = '0013j00002dOZH6';
        sl.add(sd8);
        //insert sd;
        
       insert sl;
        
      Shipment_Detail__c sd1 = new Shipment_Detail__c();
        sd1.GE_NAS_Case_Number__c = cas.id;
        sd1.Unique_ID__c = 'ABCSC';
        sd1.GE_NAS_Type_of_Problem__c = 'Shortage - Credit';
        sd1.GE_NAS_Type_of_Problem1__c = 'Credit';
        sd1.Invoice_Line__c = invL.id;
        sd1.SFDC_Invoice__c = invH.id;
        sd1.Distributor_ID__c = '0013j00002dOZH6';
        //sl.add(sd);
        insert sd1;
        TEST.stopTest();
    }
    
    static testmethod void Testmethod7(){
        Set<String> uids = new  Set<String>();
        Id devRecordTypeId = Schema.SObjectType.Dispute_Request__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        contact ca = new contact(FirstName= 'testCon', LastName='test', Email='abc@xyz.com', AccountId= Acc.id);
        insert ca;
        
        Date newDate = Date.today();
        GE_LGT_EM_InvoiceHeader__c invH = new GE_LGT_EM_InvoiceHeader__c();
        invH.GE_LGT_EM_Payer_SoldTo_Account_Number__c = '0000194800';
        invH.GE_LGT_EM_Invoice_Creation_Date__c = newDate;
        insert invH;
        
        GE_LGT_EM_InvoiceLineItem__c invL = new GE_LGT_EM_InvoiceLineItem__c();
        invL.GE_LGT_EM_Customer_PO_Number__c = '30804';
        invL.GE_LGT_EM_Order_Number__c = '0000890953';
        invL.GE_LGT_EM_InvoiceHeaderNumber__c = invH.id;
        insert invL;
        
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', Spec_Reg_Agency__c = Acc.id ); 
        insert cas;
        
        Dispute_Request__c disc = new   Dispute_Request__c();
        disc.Case__c = cas.id;
        disc.Status__c = 'Open';
        disc.RecordTypeId = devRecordTypeId;
        insert disc;
        TEST.startTest();
        List<Shipment_Detail__c> sl = new  List<Shipment_Detail__c>();
        Shipment_Detail__c sd1 = new Shipment_Detail__c();
        sd1.GE_NAS_Case_Number__c = cas.id;
        sd1.Unique_ID__c='ABCLDR';
        sd1.GE_NAS_Type_of_Problem__c ='Lost/Damage - Replacement';
        sd1.GE_NAS_Type_of_Problem1__c = 'Replacement';
        sd1.Invoice_Line__c = invL.id;
        sd1.SFDC_Invoice__c = invH.id;
        sd1.Distributor_ID__c = '0013j00002dOZH6';
        sl.add(sd1);
        //insert sd;
        
       insert sl;
        List<Shipment_Detail__c> sd12 = new List<Shipment_Detail__c>();
        Shipment_Detail__c sd2 = new Shipment_Detail__c();
        sd2.GE_NAS_Case_Number__c = cas.id;
        sd2.Unique_ID__c = 'ABCLDR';
        sd2.GE_NAS_Type_of_Problem__c = 'Lost/Damage - Replacement';
        sd2.GE_NAS_Type_of_Problem1__c = 'Replacement';
        sd2.Invoice_Line__c = invL.id;
        sd2.SFDC_Invoice__c = invH.id;
        sd2.Distributor_ID__c = '0013j00002dOZH6';
        sd12.add(sd2);
        insert sd12;
        TEST.stopTest();
      
    }
    
    static testmethod void Testmethod8(){
        Set<String> uids = new  Set<String>();
        Id devRecordTypeId = Schema.SObjectType.Dispute_Request__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        contact ca = new contact(FirstName= 'testCon', LastName='test', Email='abc@xyz.com', AccountId= Acc.id);
        insert ca;
        
        Date newDate = Date.today();
        GE_LGT_EM_InvoiceHeader__c invH = new GE_LGT_EM_InvoiceHeader__c();
        invH.GE_LGT_EM_Payer_SoldTo_Account_Number__c = '0000194800';
        invH.GE_LGT_EM_Invoice_Creation_Date__c = newDate;
        insert invH;
        
        GE_LGT_EM_InvoiceLineItem__c invL = new GE_LGT_EM_InvoiceLineItem__c();
        invL.GE_LGT_EM_Customer_PO_Number__c = '30804';
        invL.GE_LGT_EM_Order_Number__c = '0000890953';
        invL.GE_LGT_EM_InvoiceHeaderNumber__c = invH.id;
        insert invL;
        
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', Spec_Reg_Agency__c = Acc.id ); 
        insert cas;
        
        Dispute_Request__c disc = new   Dispute_Request__c();
        disc.Case__c = cas.id;
        disc.Status__c = 'Open';
        disc.RecordTypeId = devRecordTypeId;
        insert disc;
        TEST.startTest();
        List<Shipment_Detail__c> sl = new  List<Shipment_Detail__c>();
        Shipment_Detail__c sd1 = new Shipment_Detail__c();
        sd1.GE_NAS_Case_Number__c = cas.id;
        sd1.Unique_ID__c='ABCLD';
        sd1.GE_NAS_Type_of_Problem__c ='Lost/Damage - Return';
        sd1.GE_NAS_Type_of_Problem1__c = 'Return';
        sd1.Invoice_Line__c = invL.id;
        sd1.SFDC_Invoice__c = invH.id;
        sd1.Distributor_ID__c = '0013j00002dOZH6';
        sl.add(sd1);
        //insert sd;
        
       insert sl;
        
        Shipment_Detail__c sd2 = new Shipment_Detail__c();
        sd2.GE_NAS_Case_Number__c = cas.id;
        sd2.Unique_ID__c = 'ABCLD';
        sd2.GE_NAS_Type_of_Problem__c = 'Lost/Damage - Return';
        sd2.GE_NAS_Type_of_Problem1__c = 'Return';
        sd2.Invoice_Line__c = invL.id;
        sd2.SFDC_Invoice__c = invH.id;
        sd2.Distributor_ID__c = '0013j00002dOZH6';
        //sl.add(sd);
        insert sd2;
        TEST.stopTest();
    }
    
     static testmethod void Testmethod9(){
        Set<String> uids = new  Set<String>();
        Id devRecordTypeId = Schema.SObjectType.Dispute_Request__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        contact ca = new contact(FirstName= 'testCon', LastName='test', Email='abc@xyz.com', AccountId= Acc.id);
        insert ca;
         
         Date newDate = Date.today();
        GE_LGT_EM_InvoiceHeader__c invH = new GE_LGT_EM_InvoiceHeader__c();
        invH.GE_LGT_EM_Payer_SoldTo_Account_Number__c = '0000194800';
        invH.GE_LGT_EM_Invoice_Creation_Date__c = newDate;
        insert invH;
        
        GE_LGT_EM_InvoiceLineItem__c invL = new GE_LGT_EM_InvoiceLineItem__c();
        invL.GE_LGT_EM_Customer_PO_Number__c = '30804';
        invL.GE_LGT_EM_Order_Number__c = '0000890953';
        invL.GE_LGT_EM_InvoiceHeaderNumber__c = invH.id;
        insert invL;
        
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', Spec_Reg_Agency__c = Acc.id ); 
        insert cas;
        
        Dispute_Request__c disc = new   Dispute_Request__c();
        disc.Case__c = cas.id;
        disc.Status__c = 'Open';
        disc.RecordTypeId = devRecordTypeId;
        insert disc;
         TEST.startTest();
        List<Shipment_Detail__c> sl = new  List<Shipment_Detail__c>();
        Shipment_Detail__c sd2 = new Shipment_Detail__c();
        sd2.GE_NAS_Case_Number__c = cas.id;
        sd2.Unique_ID__c='ABC36';
        sd2.GE_NAS_Type_of_Problem__c ='Overage - Keep & Bill';
        sd2.GE_NAS_Type_of_Problem1__c = 'Keep & Bill';
         sd2.Invoice_Line__c = invL.id;
        sd2.SFDC_Invoice__c = invH.id;
        sd2.Distributor_ID__c = '0013j00002dOZH6';
        //insert sd2;
        sl.add(sd2);
        
       insert sl;
       List<Shipment_Detail__c> sd6 = new List<Shipment_Detail__c>(); 
       Shipment_Detail__c sd1 = new Shipment_Detail__c();
        sd1.GE_NAS_Case_Number__c = cas.id;
        sd1.Unique_ID__c = 'ABC36';
         sd1.GE_NAS_Type_of_Problem__c = 'Overage - Keep & Bill';
        sd1.GE_NAS_Type_of_Problem1__c = 'Keep & Bill';
         sd1.Invoice_Line__c = invL.id;
        sd1.SFDC_Invoice__c = invH.id;
        sd1.Distributor_ID__c = '0013j00002dOZH6';
        sd6.add(sd1);
        insert sd6;
         TEST.stopTest();
    }
    
     static testmethod void Testmethod10(){
        Set<String> uids = new  Set<String>();
        Id devRecordTypeId = Schema.SObjectType.Dispute_Request__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        contact ca = new contact(FirstName= 'testCon', LastName='test', Email='abc@xyz.com', AccountId= Acc.id);
        insert ca;
         
         Date newDate = Date.today();
        GE_LGT_EM_InvoiceHeader__c invH = new GE_LGT_EM_InvoiceHeader__c();
        invH.GE_LGT_EM_Payer_SoldTo_Account_Number__c = '0000194800';
        invH.GE_LGT_EM_Invoice_Creation_Date__c = newDate;
        insert invH;
        
        GE_LGT_EM_InvoiceLineItem__c invL = new GE_LGT_EM_InvoiceLineItem__c();
        invL.GE_LGT_EM_Customer_PO_Number__c = '30804';
        invL.GE_LGT_EM_Order_Number__c = '0000890953';
        invL.GE_LGT_EM_InvoiceHeaderNumber__c = invH.id;
        insert invL;
        
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', Spec_Reg_Agency__c = Acc.id ); 
        insert cas;
        
        Dispute_Request__c disc = new   Dispute_Request__c();
        disc.Case__c = cas.id;
        disc.Status__c = 'Open';
        disc.RecordTypeId = devRecordTypeId;
        insert disc;
         TEST.startTest();
        List<Shipment_Detail__c> sl = new  List<Shipment_Detail__c>();
        Shipment_Detail__c sd1 = new Shipment_Detail__c();
        sd1.GE_NAS_Case_Number__c = cas.id;
        sd1.Unique_ID__c='ABCWAR';
        sd1.GE_NAS_Type_of_Problem__c = 'Warranty - Replacement';
        sd1.GE_NAS_Type_of_Problem1__c = 'Replacement';
         sd1.Invoice_Line__c = invL.id;
        sd1.SFDC_Invoice__c = invH.id;
        sd1.Distributor_ID__c = '0013j00002dOZH6';
        sl.add(sd1);
        //insert sd;
        
       insert sl;
        
        //List<Shipment_Detail__c> sd3 = new List<Shipment_Detail__c>();
        Shipment_Detail__c sd2 = new Shipment_Detail__c();
        sd2.GE_NAS_Case_Number__c = cas.id;
        sd2.Unique_ID__c = 'ABCWAR';
        sd2.GE_NAS_Type_of_Problem__c = 'Warranty - Replacement';
        sd2.GE_NAS_Type_of_Problem1__c = 'Replacement';
         sd2.Invoice_Line__c = invL.id;
        sd2.SFDC_Invoice__c = invH.id;
        sd2.Distributor_ID__c = '0013j00002dOZH6';
        //sd3.add(sd2);
        insert sd2;
         TEST.stopTest();
      
    }

    static testmethod void Testmethod11(){
        Set<String> uids = new  Set<String>();
        Id devRecordTypeId = Schema.SObjectType.Dispute_Request__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        contact ca = new contact(FirstName= 'testCon', LastName='test', Email='abc@xyz.com', AccountId= Acc.id);
        insert ca;
         
         Date newDate = Date.today();
        GE_LGT_EM_InvoiceHeader__c invH = new GE_LGT_EM_InvoiceHeader__c();
        invH.GE_LGT_EM_Payer_SoldTo_Account_Number__c = '0000194800';
        invH.GE_LGT_EM_Invoice_Creation_Date__c = newDate;
        insert invH;
        
        GE_LGT_EM_InvoiceLineItem__c invL = new GE_LGT_EM_InvoiceLineItem__c();
        invL.GE_LGT_EM_Customer_PO_Number__c = '30804';
        invL.GE_LGT_EM_Order_Number__c = '0000890953';
        invL.GE_LGT_EM_InvoiceHeaderNumber__c = invH.id;
        insert invL;
        
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', Spec_Reg_Agency__c = Acc.id ); 
        insert cas;
        
        Dispute_Request__c disc = new   Dispute_Request__c();
        disc.Case__c = cas.id;
        disc.Status__c = 'Open';
        disc.RecordTypeId = devRecordTypeId;
        insert disc;
        TEST.startTest();
        List<Shipment_Detail__c> sl = new  List<Shipment_Detail__c>();
        Shipment_Detail__c sd1 = new Shipment_Detail__c();
        sd1.GE_NAS_Case_Number__c = cas.id;
        sd1.Unique_ID__c='ABCWAR';
        sd1.GE_NAS_Type_of_Problem__c = 'Warranty - Reutrn';
        sd1.GE_NAS_Type_of_Problem1__c = 'Return';
         sd1.Invoice_Line__c = invL.id;
        sd1.SFDC_Invoice__c = invH.id;
        sd1.Distributor_ID__c = '0013j00002dOZH6';
        sl.add(sd1);
        //insert sd;
        
       insert sl;
        
        //List<Shipment_Detail__c> sd3 = new List<Shipment_Detail__c>();
        Shipment_Detail__c sd2 = new Shipment_Detail__c();
        sd2.GE_NAS_Case_Number__c = cas.id;
        sd2.Unique_ID__c = 'ABCWAR';
        sd2.GE_NAS_Type_of_Problem__c = 'Warranty - Return';
        sd2.GE_NAS_Type_of_Problem1__c = 'Return';
         sd2.Invoice_Line__c = invL.id;
        sd2.SFDC_Invoice__c = invH.id;
        sd2.Distributor_ID__c = '0013j00002dOZH6';
        //sd3.add(sd2);
        insert sd2;
        TEST.stopTest();
    }

    static testmethod void Testmethod112(){
        Set<String> uids = new  Set<String>();
        Id devRecordTypeId = Schema.SObjectType.Dispute_Request__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        contact ca = new contact(FirstName= 'testCon', LastName='test', Email='abc@xyz.com', AccountId= Acc.id);
        insert ca;
         
         Date newDate = Date.today();
        GE_LGT_EM_InvoiceHeader__c invH = new GE_LGT_EM_InvoiceHeader__c();
        invH.GE_LGT_EM_Payer_SoldTo_Account_Number__c = '0000194800';
        invH.GE_LGT_EM_Invoice_Creation_Date__c = newDate;
        insert invH;
        
        GE_LGT_EM_InvoiceLineItem__c invL = new GE_LGT_EM_InvoiceLineItem__c();
        invL.GE_LGT_EM_Customer_PO_Number__c = '30804';
        invL.GE_LGT_EM_Order_Number__c = '0000890953';
        invL.GE_LGT_EM_InvoiceHeaderNumber__c = invH.id;
        insert invL;
        
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', Spec_Reg_Agency__c = Acc.id ); 
        insert cas;
        
        Dispute_Request__c disc = new   Dispute_Request__c();
        disc.Case__c = cas.id;
        disc.Status__c = 'Open';
        disc.RecordTypeId = devRecordTypeId;
        insert disc;
        TEST.startTest();
        List<Shipment_Detail__c> sl = new  List<Shipment_Detail__c>();
        Shipment_Detail__c sd1 = new Shipment_Detail__c();
        sd1.GE_NAS_Case_Number__c = cas.id;
        sd1.Unique_ID__c='ABCWAR';
        sd1.GE_NAS_Type_of_Problem__c = 'Warranty - Replace';
        sd1.GE_NAS_Type_of_Problem1__c = 'Replace';
         sd1.Invoice_Line__c = invL.id;
        sd1.SFDC_Invoice__c = invH.id;
        sd1.Distributor_ID__c = '0013j00002dOZH6';
        sl.add(sd1);
        //insert sd;
        
       insert sl;
        
        //List<Shipment_Detail__c> sd3 = new List<Shipment_Detail__c>();
        Shipment_Detail__c sd2 = new Shipment_Detail__c();
        sd2.GE_NAS_Case_Number__c = cas.id;
        sd2.Unique_ID__c = 'ABCWAR';
        sd2.GE_NAS_Type_of_Problem__c = 'Warranty - Replace';
        sd2.GE_NAS_Type_of_Problem1__c = 'Replace';
         sd2.Invoice_Line__c = invL.id;
        sd2.SFDC_Invoice__c = invH.id;
        sd2.Distributor_ID__c = '0013j00002dOZH6';
        //sd3.add(sd2);
        insert sd2;
        TEST.stopTest();
    }

    static testmethod void Testmethod12(){
        Set<String> uids = new  Set<String>();
        Id devRecordTypeId = Schema.SObjectType.Dispute_Request__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        contact ca = new contact(FirstName= 'testCon', LastName='test', Email='abc@xyz.com', AccountId= Acc.id);
        insert ca;
         
         Date newDate = Date.today();
        GE_LGT_EM_InvoiceHeader__c invH = new GE_LGT_EM_InvoiceHeader__c();
        invH.GE_LGT_EM_Payer_SoldTo_Account_Number__c = '0000194800';
        invH.GE_LGT_EM_Invoice_Creation_Date__c = newDate;
        insert invH;
        
        GE_LGT_EM_InvoiceLineItem__c invL = new GE_LGT_EM_InvoiceLineItem__c();
        invL.GE_LGT_EM_Customer_PO_Number__c = '30804';
        invL.GE_LGT_EM_Order_Number__c = '0000890953';
        invL.GE_LGT_EM_InvoiceHeaderNumber__c = invH.id;
        insert invL;
        
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', Spec_Reg_Agency__c = Acc.id ); 
        insert cas;
        
        Dispute_Request__c disc = new   Dispute_Request__c();
        disc.Case__c = cas.id;
        disc.Status__c = 'Open';
        disc.RecordTypeId = devRecordTypeId;
        insert disc;
        TEST.startTest();
        List<Shipment_Detail__c> sl = new  List<Shipment_Detail__c>();
        Shipment_Detail__c sd1 = new Shipment_Detail__c();
        sd1.GE_NAS_Case_Number__c = cas.id;
        sd1.Unique_ID__c='ABCWAR';
        sd1.GE_NAS_Type_of_Problem__c = 'Warranty - Return for Analysis';
        sd1.GE_NAS_Type_of_Problem1__c = 'Return for Analysis';
         sd1.Invoice_Line__c = invL.id;
        sd1.SFDC_Invoice__c = invH.id;
        sd1.Distributor_ID__c = '0013j00002dOZH6';
        sl.add(sd1);
        //insert sd;
        
       insert sl;
        
        //List<Shipment_Detail__c> sd3 = new List<Shipment_Detail__c>();
        Shipment_Detail__c sd2 = new Shipment_Detail__c();
        sd2.GE_NAS_Case_Number__c = cas.id;
        sd2.Unique_ID__c = 'ABCWAR';
        sd2.GE_NAS_Type_of_Problem__c = 'Warranty - Return for Analysis';
        sd2.GE_NAS_Type_of_Problem1__c = 'Return for Analysis';
         sd2.Invoice_Line__c = invL.id;
        sd2.SFDC_Invoice__c = invH.id;
        sd2.Distributor_ID__c = '0013j00002dOZH6';
        //sd3.add(sd2);
        insert sd2;
        TEST.stopTest();
    }
    
    
}
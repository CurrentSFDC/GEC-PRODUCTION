@istest
public class ReplaceWSDLCallDispTest {
    
    static testmethod void Testmethod1(){
       Test.startTest();
        AdminOverride__c adminOverride = new AdminOverride__c();
        adminOverride.Switch_Off_Trigger__c = TRUE;
        insert adminOverride;
        
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        contact ca = new contact();
        ca.FirstName= 'testCon';
        ca.LastName='test';
        ca.Email='abc@xyz.com';
        ca.AccountId= Acc.id;
        
        insert ca;
        System.debug('ca records :*************'+ca);
        
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email'); 
        cas.AccountId=Acc.id;
        cas.eLight_Address_2__c ='Test,Test1 NY 100001';
        cas.ContactId = ca.Id;
        insert cas;
        System.debug('cas details :************'+ca);
        
        
        
           
        Order order = new Order(Status = 'Draft');
        //order.Agent_rep_code__c = '';
        order.ShipToName__c = 'Lucas Urtiga';
        order.Type = 'ZSAM';
        order.AccountId=Acc.id;
        //order.OrderNumber = 'Ord432';
		order.RequestedDeliveryDate__c = date.today(); 
       // order.ShippingAddress = 'INDIA';
       
     //  TriggerSwitch__c.getInstance('Order').isActive__c = true;
		order.EffectiveDate= Date.today();
         Order.ShippingCity='abc';
        order.ShippingCountry='bcd';
        order.ShippingPostalCode='def';
        insert order; 
        
        
       
        Dispute_Request__c disc = new   Dispute_Request__c();
        disc.Case__c = cas.id;
        disc.Status__c = 'Approved';
        disc.Transaction_ID__c= 'Return';
        disc.Original_Order__c = order.id;
        disc.Sold_To__c = Acc.Id;
        insert disc;
        System.debug('disc details :************'+disc);
        
        GE_LGT_EM_MaterialMaster__c	 mm = new GE_LGT_EM_MaterialMaster__c();
       // mm.Name = 'MM432';
        mm.GE_LGT_EM_SAP_MaterialNumber__c = '1335691';
        mm.GE_LGT_EM_MaterialDescription__c	= 'LED10DR303/830W 120';
        insert mm;
        system.debug('mm***********'+mm);
        
        Shipment_Detail__c sd = new Shipment_Detail__c();
        sd.GE_NAS_Case_Number__c = cas.id;
        sd.Dispute_Request__c = disc.id;
        sd.Install_Date__c = Date.today();
        sd.Discrepancy_Qty__c = 2;
        sd.Installed_Qty__c = 2;
        sd.Order__c = order.id;
        sd.Material_Number__c = mm.id;
        //sd.Material_Number__r.GE_LGT_EM_SAP_MaterialNumber__c = mm.GE_LGT_EM_SAP_MaterialNumber__c;
        //sd.SAP_Material__c = '68160';
       // sd.Product_Number__c = 'a812F000000LVkzQAG'
        insert sd;
        System.debug('sd details :************'+sd);
        
        
        
        
        ccrz__E_Product__c cp = new ccrz__E_Product__c();
        cp.MaterialDescription__c = 'GELD50MV700PVNA2 MV';
        //cp.MaterialDescription__c = sd.Material_Number__c;
        cp.ccrz__SKU__c = '1335691';
        insert cp;
        System.debug('cp details :************'+cp);
        
       
        
        Address ad=order.ShippingAddress;
        system.debug('ad'+ad);
        gecurrentComCom472OrdercreateN3.GEOrderInfoWrapper ordInfWrap = new  gecurrentComCom472OrdercreateN3.GEOrderInfoWrapper();
        ordInfWrap.I_AGENT_CODE=order.Agent_rep_code__c;
		ordInfWrap.I_AGREEMENT='';
        ordInfWrap.I_BACK_ORDER_FLAG='';
        ordInfWrap.I_CARRIER_ACCOUNT='';
        //ordInfWrap.I_CONTACT_EMAIL='';
        ordInfWrap.I_CONTACT_EMAIL=ca.Email;
		//ordInfWrap.I_CONTACT_PHONE='';
		ordInfWrap.I_CONTACT_PHONE=ca.Phone;
        //ordInfWrap.I_CUSTOMER='DT5';
        ordInfWrap.I_CUSTOMER=cas.SAP_Customer_Number__c;
        //ordInfWrap.I_CUSTOMER_CONTACT='abc';
        ordInfWrap.I_CUSTOMER_CONTACT=ca.Name;
        //ordInfWrap.I_DELIVERY_BLOCK='Z3';
        ordInfWrap.I_DELIVERY_BLOCK='';
        //ordInfWrap.I_DIST_CHENNEL='';
        ordInfWrap.I_DIST_CHENNEL=acc.GE_LGT_EM_Distribution_Channel__c;
        //ordInfWrap.I_DIVISION='10';
        ordInfWrap.I_DIVISION=acc.GE_LGT_EM_Division__c;
        //ordInfWrap.I_EMAIL_ADDRESS='';
        ordInfWrap.I_EMAIL_ADDRESS=ca.Email;
        ordInfWrap.I_HEADER_TEXT='';
        //ordInfWrap.I_ORDER_FLAG='Y';
        ordInfWrap.I_ORDER_FLAG='';
        ordInfWrap.I_ORDER_NUMBER='';
        //ordInfWrap.I_ORDER_NUMBER=ord.OrderNumber;
        //ordInfWrap.I_ORDER_REASON='To Test';
        ordInfWrap.I_ORDER_REASON='';
        //ordInfWrap.I_ORDER_TYPE='ZSAM';
        ordInfWrap.I_ORDER_TYPE=disc.SAP_Doc_Type__c;
        //ordInfWrap.I_PARTIAL_SHIP='N';
        ordInfWrap.I_PARTIAL_SHIP='';
        //ordInfWrap.I_PO_NUM='PO1899';
        ordInfWrap.I_PO_NUM=disc.Customer_PO__c;
        ordInfWrap.I_PROJECT_NAME='';
        //ordInfWrap.I_REQ_DATE='2021-01-09';
        ordInfWrap.I_REQ_DATE=String.valueof(order.Order_Req_Delivery_Date__c);
        //ordInfWrap.I_SALES_ORG='1US1';
        ordInfWrap.I_SALES_ORG=acc.GE_LGT_EM_Sales_Org__c;
        ordInfWrap.I_SERIAL_NUMBER='';
        //ordInfWrap.I_SFDC_CASE_NUMBER='';
        ordInfWrap.I_SFDC_CASE_NUMBER=String.valueOf(disc.Case__c);
        ordInfWrap.I_SHIPMENT_TYPE='';
        //ordInfWrap.I_SHIPTO_ADDRESS1='9 Appold Street';
       // ordInfWrap.I_SHIPTO_ADDRESS1=ad.getStreet();
        //ordInfWrap.I_SHIPTO_ADDRESS2='';
        ordInfWrap.I_SHIPTO_ADDRESS1=order.ShipToStreet2__c;
        
        
        ordInfWrap.I_STRATEGIC_ACC='';
        ordInfWrap.I_USER_TYPE='Agent';
        
        ReplaceWSDLCallDisp.getOrderDtlreplace(disc.id);
    
        invocableReplaceWSDLCall.methodInputs argument;
        argument = new invocableReplaceWSDLCall.methodInputs();
        argument.disID = disc.Id;
        System.debug('disID is '+disc.Id);
        invocableReplaceWSDLCall.callReplaceWSDL(new List<invocableReplaceWSDLCall.methodInputs>{argument});
        Test.stopTest();
    }

}
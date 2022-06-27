@isTest
public class CaseTrigger_Test {
    @isTest
    static void checkInsert() {
        TriggerSwitch__c caseSetting = TestDataUtil.createTriggerSwitch('CaseTrigger', true);
        insert caseSetting;
        Id NE_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CaseConstants.NE_RECORD_TYPE).getRecordTypeId();
        Id SAP_RecordType = schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        
        Account acc = new Account(RecordTypeId = SAP_RecordType, GE_LGT_EM_Sales_Org__c='2HU2',GE_LGT_EM_Distribution_Channel__c='10',Name='Test Ac',CurrencyIsoCode='USD',GE_LGT_EM_Email_Address__c='anudeep@ge.com',GE_LGT_EM_SAP_Customer_Number__c ='0098546781');//GE_LGT_EM_Division__c='20',
        insert acc;
        contact cnt1 = new Contact(lastName='Michael Hoexter', Accountid=acc.ID, FirstName='Michael');
        insert cnt1;
        
        Contact cnt = new Contact(lastName='testUser', GE_LGT_Row_Id__c='1-JR6HG4', FirstName='Michael');
        insert cnt;
        NAServiceDummyContact__c dummyContact = new NAServiceDummyContact__c(AccountId__c = acc.Id, ContactId__c=cnt1.Id);
        insert dummyContact;
        
        Case c=new Case();
        c.Subject=CaseConstants.SHIPPING_SUBJECT +'TestSubject';
        c.Origin = 'Web';
        c.GE_LGT_Business__c = CaseConstants.NE_RECORD_TYPE;
        c.RecordTypeId = NE_RecordType;
        c.GE_NAS_EmailDescription__c = 'WEB #245454- SHIPPING DISCREPANCY - Account 45656000001 Contact :AndrewLoyd E-mail :aloyd@loydselectric.com Email :aloyd@loydselectric.com Fax :45321 Phone :417-334-2171 PO# :132720 PickTicket# :38707071 1.Product: 68850Qty: 36RAP Qty: 2REORDER: noUOM: each/bulbType of Discrepancy: damage 2.Product: 68052Qty: 15RAP Qty: 15REORDER: noUOM: each/bulbType of Discrepancy: damage 3.Product: 68168Qty: 24RAP Qty: 4REORDER: noUOM: each/bulbType of Discrepancy: damage Comments:';        
        insert c;
        system.assertNotEquals(null, [Select Id from Shipment_Detail__c]);
    }
    
	 @isTest
    static void checkInsertelightreturn() {
        TriggerSwitch__c caseSetting = TestDataUtil.createTriggerSwitch('CaseTrigger', true);
        insert caseSetting;
        Id NE_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CaseConstants.NE_RECORD_TYPE).getRecordTypeId();
        Id SAP_RecordType = schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        
        Account acc = new Account(RecordTypeId = SAP_RecordType, GE_LGT_EM_Sales_Org__c='2HU2',GE_LGT_EM_Distribution_Channel__c='10',Name='Test Ac',CurrencyIsoCode='USD',GE_LGT_EM_Email_Address__c='anudeep@ge.com',GE_LGT_EM_SAP_Customer_Number__c ='0098546781');//GE_LGT_EM_Division__c='20',
        insert acc;
        contact cnt1 = new Contact(lastName='Michael Hoexter', Accountid=acc.ID, FirstName='Michael');
        insert cnt1;
        
        Contact cnt = new Contact(lastName='testUser', GE_LGT_Row_Id__c='1-JR6HG4', FirstName='Michael');
        insert cnt;
        NAServiceDummyContact__c dummyContact = new NAServiceDummyContact__c(AccountId__c = acc.Id, ContactId__c=cnt1.Id);
        insert dummyContact;
        
		GE_LGT_EM_MaterialMaster__c	 mm = new GE_LGT_EM_MaterialMaster__c();
		mm.GE_LGT_EM_SAP_MaterialNumber__c='93130970t';
		mm.GE_LGT_EM_MaterialDescription__c='test1';
		mm.GE_LGT_EM_ProductHierarchy__c='test1';
		insert mm;

        Case c=new Case();
        c.Subject=CaseConstants.ELIGHT_RETURNS +'TestSubject';
        c.Origin = 'Web';
        c.GE_LGT_Business__c = CaseConstants.NE_RECORD_TYPE;
        c.RecordTypeId = NE_RecordType;
        c.GE_NAS_EmailDescription__c =  'Hybris ID: 719024 Contact Name: Marj Coffman Contact Emai: marj@digitalfilaments.com Contact Phone Number: Sales Order Number: 0000870541 Opportunity ID/Project Name: PO Number: 19357501JC1 Invoice Number 1171017129 Reason for Return Request: Standard Warranty Secondary Reason: Price Agreement: 0080151231 Sold To: 0080060377 - Lights for Less, LLC Comment: Customer has (2) defective drivers Return Processing Information: Yes Request Transaction Number: 0000878252 \n  Product Information \nProduct    Required    Price    Quantity    Comment \n93130970t    94.0    2    hello \n 	End of Products'; 
        insert c;
        system.assertNotEquals(null, [Select Id from Shipment_Detail__c]);
    }
	
	
    @isTest
    static void checkDelete() {
        Test.startTest();
        TriggerSwitch__c caseSetting = TestDataUtil.createTriggerSwitch('CaseTrigger', true);
        insert caseSetting;
        Id EME_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GE Lighting EMEA').getRecordTypeId();
        Id SAP_RecordType = schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();       
        Account acc = new Account(RecordTypeId = SAP_RecordType, GE_LGT_EM_Sales_Org__c='2HU2',GE_LGT_EM_Distribution_Channel__c='10',Name='Test Ac',CurrencyIsoCode='HUF',GE_LGT_EM_Email_Address__c='andras.arva@ge.com',GE_LGT_EM_SAP_Customer_Number__c ='0012345678');
        insert acc;
        contact cnt1 = new Contact(lastName='Test', Accountid=acc.ID, FirstName='ContactTest');
        insert cnt1;
        
        Case c=new Case();
        c.Subject='TestSubject for removal';
        c.Origin ='Email - Benelux';
        c.RecordTypeId = EME_RecordType;
        c.Contact=cnt1;
        c.Account=acc;
        insert c;
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='Integration User']; 
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@ge.com.satishdev',
                              GE_LGT_Business_Division__c='EMEA Service' );
            System.runAs ( u ) {  
                Delete c; 
                //System.assertEquals(True, ApexPages.hasMessages(),'No validation message was generated');
            }
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Only Admins/Super/LDR users can delete Cases') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
            
        }
        Test.stopTest();
    }
    
    
    
 
    @IsTest
    static void checkInsertwithParent() {
        TriggerSwitch__c caseSetting = TestDataUtil.createTriggerSwitch('CaseTrigger', true);
        insert caseSetting;
        Id NE_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CaseConstants.NE_RECORD_TYPE).getRecordTypeId();
        Id SAP_RecordType = schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        
        Account acc = new Account(RecordTypeId = SAP_RecordType, GE_LGT_EM_Sales_Org__c='2HU2',GE_LGT_EM_Distribution_Channel__c='10',Name='Test Ac',CurrencyIsoCode='USD',GE_LGT_EM_Email_Address__c='anudeep@ge.com',GE_LGT_EM_SAP_Customer_Number__c ='0098546781', accountnumber='45656000001');//GE_LGT_EM_Division__c='20',
        insert acc;
        contact cnt1 = new Contact(lastName='Michael Hoexter', Accountid=acc.ID, FirstName='Michael');
        insert cnt1;
        
        Contact cnt = new Contact(lastName='testUser', GE_LGT_Row_Id__c='1-JR6HG4', FirstName='Michael');
        insert cnt;
        NAServiceDummyContact__c dummyContact = new NAServiceDummyContact__c(AccountId__c = acc.Id, ContactId__c=cnt1.Id);
        insert dummyContact;
        
        Case c=new Case();
        c.Subject=CaseConstants.SHIPPING_SUBJECT +'TestSubject';
        c.Origin = 'Web';
        c.GE_LGT_Business__c = CaseConstants.NE_RECORD_TYPE;
        c.RecordTypeId = NE_RecordType;
        c.GE_NAS_EmailDescription__c = 'WEB #245454- SHIPPING DISCREPANCY - Account 45656000001 Contact :AndrewLoyd E-mail :aloyd@loydselectric.com Phone :417-334-2171 PO# :132720 PickTicket# :38707071 1.Product: 68850Qty: 36RAP Qty: 2REORDER: noUOM: each/bulbType of Discrepancy: damage 2.Product: 68052Qty: 15RAP Qty: 15REORDER: noUOM: each/bulbType of Discrepancy: damage 3.Product: 68168Qty: 24RAP Qty: 4REORDER: noUOM: each/bulbType of Discrepancy: damage Comments:';
        insert c;
        Shipment_Detail__c sd = new Shipment_Detail__c(GE_NAS_Case_Number__c= c.Id);
        insert sd;
        
        case ChildCase = new Case();
        ChildCase.Subject=CaseConstants.SHIPPING_SUBJECT +'TestSubject';
        ChildCase.Origin = 'Web';
        ChildCase.ParentId = c.Id;
        ChildCase.GE_LGT_Business__c = CaseConstants.NE_RECORD_TYPE;
        ChildCase.RecordTypeId = NE_RecordType;
        ChildCase.GE_NAS_EmailDescription__c = 'WEB #245454- SHIPPING DISCREPANCY - Account 45656000001 Contact :AndrewLoyd E-mail :aloyd@loydselectric.com Phone :417-334-2171 PO# :132720 PickTicket# :38707071 1.Product: 68850Qty: 36RAP Qty: 2REORDER: noUOM: each/bulbType of Discrepancy: damage 2.Product: 68052Qty: 15RAP Qty: 15REORDER: noUOM: each/bulbType of Discrepancy: damage 3.Product: 68168Qty: 24RAP Qty: 4REORDER: noUOM: each/bulbType of Discrepancy: damage Comments:';
        insert ChildCase;
        system.assertNotEquals(null, [Select Id from Shipment_Detail__c where GE_NAS_Case_Number__c =:ChildCase.Id]);
    }
    
    @isTest
    static void checkInsertWithEmailOrigin() {
        TriggerSwitch__c caseSetting = TestDataUtil.createTriggerSwitch('CaseTrigger', true);
        insert caseSetting;
        Id NE_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CaseConstants.NE_RECORD_TYPE).getRecordTypeId();
        Id NA_RecordType = schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        Id Contact_RecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('NA Service Contact').getRecordTypeId();
        
        Account acc = new Account(RecordTypeId = NA_RecordType, GE_LGT_EM_Sales_Org__c='2HU2',GE_LGT_EM_Distribution_Channel__c='10',Name='Test Ac',CurrencyIsoCode='USD',GE_LGT_EM_Email_Address__c='pavan@ge.com',GE_LGT_EM_SAP_Customer_Number__c ='0098546781');//GE_LGT_EM_Division__c='20',
        acc.accountnumber='97844010001';
        acc.GE_LGT_EM_SAP_Customer_Number__c='97844010001';
        acc.GE_NAS_NCSC_Component_Code__c='4714';
        acc.GE_NAS_AccountNo__c='97844010001';
        insert acc;
        contact cnt1 = new Contact(lastName='Hoexter', FirstName='Michael', Accountid=acc.ID, email='aloyd@loydselectric.com', recordTypeId=Contact_RecordType);
        insert cnt1;
        
        Contact cnt = new Contact(lastName='testUser', GE_LGT_Row_Id__c='1-JR6HG4', FirstName='Michael');
        insert cnt;
        NAServiceDummyContact__c dummyContact = new NAServiceDummyContact__c(AccountId__c = acc.Id, ContactId__c=cnt1.Id);
        insert dummyContact;
        NAService_AcctNumGroupMap__c newListItem = new NAService_AcctNumGroupMap__c(name='4714', Group_Name__c= 'VMI Team', Group_Id__c='00Gi0000001HuaB');
        insert newListItem;
        
        List<case> insertList = new List<case>();
        Case c1=new Case();
        c1.Subject=CaseConstants.SHIPPING_SUBJECT +'TestSubject';
        c1.Origin = CaseConstants.EMAIL;
        c1.ContactId=cnt1.Id;
        c1.GE_LGT_Business__c = CaseConstants.NE_RECORD_TYPE;
        c1.RecordTypeId = NE_RecordType;
        //c1.description = 'WEB #245454- SHIPPING DISCREPANCY - Account 97844010001 Contact :AndrewLoyd E-mail :aloyd@loydselectric.com \n Phone :417-334-2171 PO# :132720 \n PickTicket# :38707071 \nInvoice# :11123\n 1.Product: 68850Qty: 36RAP Qty: 2REORDER: noUOM: each/bulbType of Discrepancy: damage 2.Product: 68052Qty: 15RAP Qty: 15REORDER: noUOM: each/bulbType of Discrepancy: damage 3.Product: 68168Qty: 24RAP Qty: 4REORDER: noUOM: each/bulbType of Discrepancy: damage Comments:';
        c1.description = 'WEB #245454- SHIPPING DISCREPANCY - Account 97844010001 Contact :AndrewLoyd E-mail :aloyd@loydselectric.com \n Phone :417-334-2171 PO# :132720 \n BOL# :132720 \n Confirmation#:132720 \n PickTicket# :38707071 \nInvoice# :11123\n 1.Product: 68850Qty: 36RAP Qty: 2REORDER: noUOM: each/bulbType of Discrepancy: damage 2.Product: 68052Qty: 15RAP Qty: 15REORDER: noUOM: each/bulbType of Discrepancy: damage 3.Product: 68168Qty: 24RAP Qty: 4REORDER: noUOM: each/bulbType of Discrepancy: damage Comments:';
        c1.suppliedemail='pavan@ge.com';
        insertList.add(c1);
        Case c2=new Case();
        c2.Subject='Request Proof of Delivery(POD)' +'TestSubject';
        c2.Origin = 'Email';
        c2.ContactId=cnt1.Id;
        c2.GE_LGT_Business__c = CaseConstants.NE_RECORD_TYPE;
        c2.RecordTypeId = NE_RecordType;
        //c2.GE_NAS_AccountNo__c = '97844010001';
        c2.Description ='WEB #1248- Request Proof of Delivery(POD) - Account 97844010001 \n Contact :Test Service\nE-mail :aloyd@loydselectric.com\nPhone :870-449-1721\n PO# :132720 \n PickTicket# :38707071 \nInvoice# :11123\nPO# :1111456\nComments:\nTest mail for SFDC\n'; 
        c2.suppliedemail='pavan@ge.com';
        insertList.add(c2);
        //added for Billing AdjustmentEvent
        Case c3=new Case();
        c3.Subject=CaseConstants.BILLING_ADJUSTMENT +'TestSubject';
        c3.Origin = CaseConstants.EMAIL;
        c3.ContactId=cnt1.Id;
        c3.GE_LGT_Business__c = CaseConstants.NE_RECORD_TYPE;
        c3.RecordTypeId = NE_RecordType;
        c3.description = 'WEB #245454- BILLING ADJUSTMENT  - Sold To: 97844010001 Contact: Andrew Loyd \n Contact Email: aloyd@loydselectric.com \n Contact Phone Number: 417-334-2171 \n Price Agreement: 12548 \n Reason for Return Request: Shortage \n PO Number: 132720 \n Confirmation: CONF1234 \n Sales Order Number: BOL234 \n Return Processing Information: PICK123 \n Invoice Number :11123\n 1. Product: 93036899 Qty: 12 Invoiced Price: 12.0 Expected Price: 14.0 \n Price Agreement#: PA1234 \nComment:from testclass';
        c3.suppliedemail='pavan@ge.com';
        insertList.add(c3);
        //added for Stockbalancing Claim - WITH <MAILTO> IN DESCRIPTION
        Case c4 =new Case();
        c4.Subject=CaseConstants.STOCKBALANCING_CLAIM +'TestSubject';
        c4.Origin = CaseConstants.EMAIL;
        c4.ContactId=cnt1.Id;
        c4.GE_LGT_Business__c = CaseConstants.NE_RECORD_TYPE;
        c4.RecordTypeId = NE_RecordType;
        c4.description = 'Hybris ID: 250006 \n  Sold To: 97844010001 - LOYDS ELECTRIC\n Contact Name: Andrew Loyd \n Contact Email: aloyd@loydselectric.com <mailto:aloyd@loydelectric.com> \n  Contact Phone Number: 417-334-2171 \n Reason for Return Request: Annual Return \n Return Processing Information: No \n Request Transaction Number:132720 \n  1. Product: 93036899 Qty: 12 Invoiced Price: 12.0 Expected Price: 14.0 Price Agreement#: PA1234 Comment: from testclass \n Total Extended Credit Price: 2300 \n testing';
        c4.suppliedemail='pavan@ge.com';
        insertList.add(c4);
        //added for Stockbalancing Claim - WITHOUT <MAILTO> IN DESCRIPTION
        Case c5 =new Case();
        c5.Subject=CaseConstants.STOCKBALANCING_CLAIM +'TestSubject';
        c5.Origin = CaseConstants.EMAIL;
        c5.ContactId=cnt1.Id;
        c5.GE_LGT_Business__c = CaseConstants.NE_RECORD_TYPE;
        c5.RecordTypeId = NE_RecordType;
        c5.description = 'Hybris ID: 250006 \n  Sold To: 97844010001 - LOYDS ELECTRIC\n Contact Name: Andrew Loyd \n Contact Email: aloyd@loydselectric.com \n  Contact Phone Number: 417-334-2171 \n Reason for Return Request: Annual Return \n Return Processing Information: No \n Request Transaction Number:132720 \n  1. Product: 93036899 Qty: 12 Invoiced Price: 12.0 Expected Price: 14.0 Price Agreement#: PA1234 Comment: from testclass \n Total Extended Credit Price: 2300 \n testing';
        c5.suppliedemail='pavan@ge.com';
        insertList.add(c5);
        
        

        
        insert insertList;
        System.assertNotEquals(null, [SELECT Id from Case Where GE_NAS_Sub_Type__c='Damage' ]);
    }
    @isTest
    static void checkWithEmail() {
        TriggerSwitch__c caseSetting = TestDataUtil.createTriggerSwitch('CaseTrigger', true);
        insert caseSetting;
        Id NE_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CaseConstants.NE_RECORD_TYPE).getRecordTypeId();
        Id SAP_RecordType = schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        Id EMEA_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GE Lighting EMEA').getRecordTypeId();        
        Id ContactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('NA Service Contact').getRecordTypeId();
        Id NA_Service_RecordType = schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        Account acc = new Account(RecordTypeId = SAP_RecordType, GE_LGT_EM_Sales_Org__c='2HU2',GE_LGT_EM_Distribution_Channel__c='10-Con',Name='Test Ac',CurrencyIsoCode='USD',GE_LGT_EM_Email_Address__c='pavan@ge.com',GE_LGT_EM_SAP_Customer_Number__c ='0098546781');//GE_LGT_EM_Division__c='20-Components',
        acc.accountnumber='3919800';
        acc.GE_NAS_NCSC_Component_Code__c='4714';
        acc.GE_NAS_AccountNo__c='3919800';
        insert acc;
        Account acc1 = new Account(RecordTypeId = NA_Service_RecordType, GE_LGT_EM_Sales_Org__c='2HU2',GE_LGT_EM_Distribution_Channel__c='10-Cons',Name='Test Ac',CurrencyIsoCode='USD',GE_LGT_EM_Email_Address__c='pavan@ge.com',GE_LGT_EM_SAP_Customer_Number__c ='0098546781');//GE_LGT_EM_Division__c='20-Components',
        acc1.accountnumber='3919823';
        acc1.GE_NAS_NCSC_Component_Code__c='4714';
        acc1.GE_NAS_AccountNo__c='3919823';
        insert acc1;
        contact cnt1 = new Contact(lastName='Hoexter', Accountid=acc1.ID, email='Sender.Robofax@ge.com', recordTypeId=ContactRecordTypeID, FirstName='Michael');
        insert cnt1;
        
        Contact cnt = new Contact(FirstName='test', lastName='testUser', GE_LGT_Row_Id__c='1-JR6HG4', Accountid=acc1.ID, email='Sender.Robofax@ge.com');
        insert cnt;
        NAServiceDummyContact__c dummyContact = new NAServiceDummyContact__c(AccountId__c = acc.Id, ContactId__c=cnt1.Id);
        insert dummyContact;
        NAService_AcctNumGroupMap__c newListItem = new NAService_AcctNumGroupMap__c(name='4714', Group_Name__c= 'VMI Team', Group_Id__c='00Gi0000001HuaB');
        insert newListItem;
        NAService_OriginQueueMap__c queMap = new NAService_OriginQueueMap__c(Name='Email - France Strategic', Queue_Id__c='00Gi0000003C5OW', Queue_Name__c='France Strategic');
        insert queMap;
        
        List<case> insertList = new List<case>();
        Case c1=new Case();
        c1.Subject=CaseConstants.SHIPPING_SUBJECT +'TestSubject';
        c1.Origin = 'Email';
        c1.GE_LGT_Business__c = CaseConstants.NE_RECORD_TYPE;
        c1.RecordTypeId = NE_RecordType;
        c1.description = 'WEB #245454- SHIPPING DISCREPANCY - Account 45656000001 Contact :AndrewLoyd E-mail :aloyd@loydselectric.com \n Phone :417-334-2171 PO# :132720 \n PickTicket# :38707071 \nInvoice# :11123\n 1.Product: 68850Qty: 36RAP Qty: 2REORDER: noUOM: each/bulbType of Discrepancy: damage 2.Product: 68052Qty: 15RAP Qty: 15REORDER: noUOM: each/bulbType of Discrepancy: damage 3.Product: 68168Qty: 24RAP Qty: 4REORDER: noUOM: each/bulbType of Discrepancy: damage Comments:';
        c1.suppliedemail='pavan@ge.com';
        c1.GE_NAS_AccountNo__c = '3919800';
        insertList.add(c1);
        
        Case css = new Case();
        css.RecordTypeId = EMEA_RecordType;
        css.Accountid=acc.ID;
        css.Contactid=cnt1.id;
        css.Origin='Email - France Strategic';            
        css.Subject='Order Receipt: 2HU2, 10, 20, 0098546781, 49583, Test Ac';
        css.Description ='Test Class for Email2Case';
        css.suppliedemail='orders@gelightnet.com';
        css.GE_NAS_AccountNo__c = '3919800';
        css.OwnerId = UserInfo.getUserId();
        insertList.add(css);
        Case css1 = new Case();
        css1.RecordTypeId = EMEA_RecordType;
        css1.Accountid=acc.ID;
        css1.Contactid=cnt1.id;
        css1.Origin='Email - France Strategic';            
        css1.Subject='Order Receipt: 2HU2, 20, 20, 0098546781, 49583, Test Ac, Received Fax From:';
        css1.Description ='Test Class for Email2Case';
        css1.SuppliedEmail='Sender.Robofax@ge.com';
        
        insertList.add(css1);
        
        //insert insertList; commented by sai teja as insert is going on two times we are getting invalid cross reference ID
        
        insertList = new list<case>();
        Case css2 = new Case();
        css2.RecordTypeId = NE_RecordType;
        css2.Accountid=acc.ID;
        css2.Origin='Email - France Strategic';            
        css2.Subject='Order Receipt: 2HU2, 10, 20, 0098546781, 49583, Test Ac, Received Fax From:';
        css2.Description ='Test Class for Email2Case';
        css2.GE_NAS_CloneCasenumber__c = css.Id;
        insertList.add(css2);
        
        Case css3 = new Case();
        css3.RecordTypeId = NE_RecordType;
        css3.Accountid=acc.ID;
        css3.Contactid=cnt1.id;
        css3.Origin='Email - France Strategic';            
        css3.Subject='Order Receipt: 2HU2, 10, 20, 0098546781, 49583, Test Ac, Received Fax From:';
        css3.Description ='Test Class for Email2Case';
        css3.SuppliedEmail='Sender.Robofax@ge.com';
        css3.GE_NAS_CloneCasenumber__c = css.Id;
        insertList.add(css3);
        
        insert insertList;
        
        /*css1.OwnerId = UserInfo.getUserId();
        css1.ParentId = css.Id;
        update css1;*/ //commented by saiteja
        System.assertNotEquals(null, [Select Id from Case Where Team_Email__c !=null]);
    }
    @isTest
    static void checkAccounts() {
        TriggerSwitch__c caseSetting = TestDataUtil.createTriggerSwitch('CaseTrigger', true);
        insert caseSetting;
        Id NE_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CaseConstants.NE_RECORD_TYPE).getRecordTypeId();
        Id SAP_RecordType = schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        Id ContactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('NA Service Contact').getRecordTypeId();
        Id NA_Service_RecordType = schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        Id EMEA_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GE Lighting EMEA').getRecordTypeId();        
        
        Account acc = new Account(RecordTypeId = SAP_RecordType, GE_LGT_EM_Sales_Org__c='2HU2',GE_LGT_EM_Distribution_Channel__c='10',Name='Test Ac',CurrencyIsoCode='USD',GE_LGT_EM_Email_Address__c='anudeep@ge.com',GE_LGT_EM_SAP_Customer_Number__c ='0098546781');//GE_LGT_EM_Division__c='20',
        insert acc;
        contact cnt1 = new Contact(lastName='Hoexter', Accountid=acc.ID, FirstName='Michael');
        insert cnt1;
        // Account acc1 = new Account(RecordTypeId = NA_Service_RecordType, GE_LGT_EM_Sales_Org__c='2HU2',GE_LGT_EM_Distribution_Channel__c='10-Consumer',Name='Test Ac',CurrencyIsoCode='USD',GE_LGT_EM_Email_Address__c='pavan@ge.com',GE_LGT_EM_SAP_Customer_Number__c ='0098546781');//GE_LGT_EM_Division__c='20-Components',
        Account acc1 = new Account(RecordTypeId = NA_Service_RecordType, /*GE_LGT_EM_Distribution_Channel__c='10-Consumer',*/Name='Test Ac',CurrencyIsoCode='USD',GE_LGT_EM_Email_Address__c='pavan@ge.com',GE_LGT_EM_SAP_Customer_Number__c ='0098546781');//GE_LGT_EM_Division__c='20-Components',
        acc1.accountnumber='3919823';
        acc1.GE_NAS_NCSC_Component_Code__c='4714';
        acc1.GE_NAS_AccountNo__c='3919823';
        insert acc1;
        
        Contact cnt = new Contact(lastName='testUser', GE_LGT_Row_Id__c='1-JR6HG4', FirstName='Michael');
        insert cnt;
        NAServiceDummyContact__c dummyContact = new NAServiceDummyContact__c(AccountId__c = acc.Id, ContactId__c=cnt1.Id);
        insert dummyContact;
        NAService_AcctNumGroupMap__c newListItem = new NAService_AcctNumGroupMap__c(name='4714', Group_Name__c= 'VMI Team', Group_Id__c='00Gi0000001HuaB');
        insert newListItem;
        Contact cnt2 = new Contact(lastName='testUser', FirstName='Michael', Accountid=acc1.ID, email='orders@gelightnet.com', recordTypeId=ContactRecordTypeID);
        insert cnt2;
        NAService_OriginQueueMap__c queMap = new NAService_OriginQueueMap__c(Name='Email - France Strategic', Queue_Id__c='00Gi0000003C5OW', Queue_Name__c='France Strategic');
        insert queMap;
        
        List<case> caseList= new List<Case>();
        Case c=new Case();
        c.Subject=CaseConstants.SHIPPING_SUBJECT +'TestSubject';
        c.Origin = 'Web';
        c.GE_LGT_Business__c = CaseConstants.NE_RECORD_TYPE;
        c.RecordTypeId = NE_RecordType;
        c.GE_NAS_Sub_Status__c = 'cancelled';
        c.GE_NAS_EmailDescription__c = 'WEB #245454- SHIPPING DISCREPANCY - Account 45656000001 Contact :AndrewLoyd E-mail :aloyd@loydselectric.com Phone :417-334-2171 PO# :132720 PickTicket# :38707071 1.Product: 68850Qty: 36RAP Qty: 2REORDER: noUOM: each/bulbType of Discrepancy: damage 2.Product: 68052Qty: 15RAP Qty: 15REORDER: noUOM: each/bulbType of Discrepancy: damage 3.Product: 68168Qty: 24RAP Qty: 4REORDER: noUOM: each/bulbType of Discrepancy: damage Comments:';
        c.Type = 'Cancelled Case to be Deleted';
        caseList.add(c);
        Case css = new Case();
        css.RecordTypeId = EMEA_RecordType;
        css.Accountid=acc.ID;
        css.Contactid=cnt1.id;
        css.Origin='Email - France Strategic';            
        css.Subject='Order Receipt: 2HU2, 10, 20, 0098546781, 49583, Test Ac';
        css.Description ='Test Class for Email2Case';
        //css.suppliedemail='orders@gelightnet.com';
        css.GE_NAS_AccountNo__c = '3919800';
        css.OwnerId = UserInfo.getUserId();
        caseList.add(css);
        Case css3 = new Case();
        css3.RecordTypeId = EMEA_RecordType;
        css3.Accountid=acc.ID;
        css3.Contactid=cnt1.id;
        css3.Origin='Email - France Strategic';
        //css3.suppliedemail='orders@gelightnet.com';
        css3.GE_NAS_AccountNo__c = '3919800';
        css3.Subject='Order Receipt: 2HU2, 20, 30, 6781, 49583, Test Ac, Received Fax From:';
        css3.Description ='Test Class for Email2Case';
        caseList.add(css3);
        Case css5 = new Case();
        css5.RecordTypeId = EMEA_RecordType;
        css5.Accountid=acc.ID;
        css5.Contactid=cnt1.id;
        //css5.suppliedemail='orders@gelightnet.com';
        css5.GE_NAS_AccountNo__c = '3919800';
        css5.Origin='Email - France Strategic';            
        css5.Subject='Order Receipt: 2HU2, 40, 10, 81, 49583, Test Ac, Received Fax From:';
        css5.Description ='Test Class for Email2Case';
        caseList.add(css5);
        Case css6 = new Case();
        css6.RecordTypeId = EMEA_RecordType;
        css6.Accountid=acc.ID;
        css6.Contactid=cnt1.id;
        //css6.suppliedemail='orders@gelightnet.com';
        css6.GE_NAS_AccountNo__c = '3919800';
        css6.Origin='Email - France Strategic';            
        css6.Subject='Order Receipt: 2HU2, 30, 10, 1, 49583, Test Ac, Received Fax From:';
        css6.Description ='Test Class for Email2Case';
        caseList.add(css6);
        
        
        Case css7 = new Case();
        css7.RecordTypeId = NE_RecordType;
        css7.Accountid=acc.ID;
        css7.Contactid=cnt1.id;
        css7.GE_NAS_AccountNo__c = '3919800';
        css7.Origin='Email - Tech';            
        css7.Subject='Order Receipt: 2HU2, 30, 10, 1, 49583, Test Ac, Received Fax From:';
        css7.Description ='Test Class for Email2Case';
        caseList.add(css7);
        Case css8 = new Case();
        css8.RecordTypeId = NE_RecordType;
        css8.Accountid=acc.ID;
        css8.GE_NAS_AccountNo__c = '3919800';
        css8.Origin='Email - Tech';            
        css8.Subject='Order Receipt: 2HU2, 30, 10, 1, 49583, Test Ac, Received Fax From:';
        css8.Description ='Test Class for Email2Case';
        caseList.add(css8);
        case css9 = new case();
        css9.RecordTypeId = NE_RecordType;
        css9.GE_NAS_ToAddress__c='pavan@ge.com';
        caseList.add(css9);
        insert caseList;
        //System.assertEquals(8, [Select Id from Case where AccountId=null].size());
    }
    /*@IsTest
    static void checkMail() {
        TriggerSwitch__c caseSetting = TestDataUtil.createTriggerSwitch('CaseTrigger', true);
        insert caseSetting;
        Id NE_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CaseConstants.NE_RECORD_TYPE).getRecordTypeId();
        Id SAP_RecordType = schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        Id ContactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('NA Service Contact').getRecordTypeId();
        Id NA_Service_RecordType = schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        Id EMEA_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GE Lighting EMEA').getRecordTypeId();        
        
        Account acc = new Account(RecordTypeId = SAP_RecordType, GE_LGT_EM_Sales_Org__c='2HU2',GE_LGT_EM_Distribution_Channel__c='10',Name='Test Ac',CurrencyIsoCode='USD',GE_LGT_EM_Email_Address__c='anudeep@ge.com',GE_LGT_EM_SAP_Customer_Number__c ='0098546781');//GE_LGT_EM_Division__c='20',
        insert acc;
        contact cnt1 = new Contact(lastName='Hoexter', Accountid=acc.ID, FirstName='Michael');
        insert cnt1;
        Account acc1 = new Account(RecordTypeId = NA_Service_RecordType, GE_LGT_EM_Sales_Org__c='2HU2',GE_LGT_EM_Distribution_Channel__c='10-Con',Name='Test Ac',CurrencyIsoCode='USD',GE_LGT_EM_Email_Address__c='pavan@ge.com',GE_LGT_EM_SAP_Customer_Number__c ='0098546781');//GE_LGT_EM_Division__c='20-Components',
        acc1.accountnumber='3919823';
        acc1.GE_NAS_NCSC_Component_Code__c='4714';
        acc1.GE_NAS_AccountNo__c='3919823';
        insert acc1;
        
        Contact cnt = new Contact(lastName='testUser', GE_LGT_Row_Id__c='1-JR6HG4', FirstName='Michael');
        insert cnt;
        Contact anotherContact = new Contact(lastName='testUser', GE_LGT_Row_Id__c='1-4O3JE7', FirstName='Michael');
        insert anotherContact;
        NAServiceDummyContact__c dummyContact = new NAServiceDummyContact__c(AccountId__c = acc.Id, ContactId__c=cnt1.Id);
        insert dummyContact;
        NAService_AcctNumGroupMap__c newListItem = new NAService_AcctNumGroupMap__c(name='4714', Group_Name__c= 'VMI Team', Group_Id__c='00Gi0000001HuaB');
        insert newListItem;
        Contact cnt2 = new Contact(lastName='testUser', Accountid=acc1.ID, email='orders@gelightnet.com', recordTypeId=ContactRecordTypeID, FirstName='Michael');
        insert cnt2;
        NAService_OriginQueueMap__c queMap = new NAService_OriginQueueMap__c(Name='Email - France Strategic', Queue_Id__c='00Gi0000003C5OW', Queue_Name__c='France Strategic');
        insert queMap;
        
        case css9 = new case();
        css9.RecordTypeId = NE_RecordType;
        css9.GE_NAS_ToAddress__c='pavan@ge.com';
        css9.suppliedemail='test@ge.com';
        insert css9;
        GE_NAS_CaseRoutingePersonalEmails__c newMails = new GE_NAS_CaseRoutingePersonalEmails__c(name ='pavan', GE_NAS_Personal_Email__c='pavan.kumar@ge.com', GE_NAS_Case_Routing_Email__c='pavan4sfdc@ge.com', GE_NAS_Active__c=true);
        insert newMails;
        css9.GE_NAS_ToAddress__c='pavan4sfdc@ge.com';
        css9.GE_NAS_Claim__c = '12345';
        GE_NAS_Claim__c newClaim =new GE_NAS_Claim__c(GE_NAS_Claim_Number__c='12345', GE_NAS_CFS_Resolution__c = 'ASN - all other', GE_NAS_DevComments__c='newly created');
        insert newClaim;
        update css9;
        css9.GE_NAS_ToAddress__c='pavan@ge.com';
        css9.GE_NAS_EmailDescription__c = 'test';
        css9.GE_NAS_CFS_Resolution__c = 'Administrative Fees';
        update css9;
        system.assertNotEquals(0,Limits.getEmailInvocations());
    }*/
    static testmethod void caseTestmethod()
    { 
        TriggerSwitch__c caseSetting = TestDataUtil.createTriggerSwitch('CaseTrigger', true);
        insert caseSetting;
        
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-10-Z8';
        acc.RecordTypeId=recAccTypeID;
        insert acc;
        Contact cnt = new Contact(lastName='testUser', GE_LGT_Row_Id__c='1-JR6HG4', FirstName='Michael');
        insert cnt;
        Contact ct=TestDataUtil.createContact(acc);
        ct.firstname='Test';
        insert ct;
        
        ID reccaseTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('eLight').getRecordTypeId();
        system.debug('reccaseTypeID'+reccaseTypeID);
        Case cs=TestDataUtil.createCase(acc);
        //cs.RecordTypeId = reccaseTypeID;
        cs.Accountid=acc.ID;
        cs.Contactid=ct.id;
        cs.Origin='Email - Dutch team';            
        cs.Subject='Subject for Email2Case Test Class';
        cs.Description ='Test Class for Email2Case';
        cs.GE_NAS_Sub_Status__c='In Process';
        cs.GE_NAS_Customer_Impact__c='1-Customer OK';
        cs.Product_Code_1__c='Test1;Test2;test3;';
        cs.eLight_Comments__c='Test1;Test2;test3;';
        cs.eLight_Invoiced_Price_T__c='10;20;30;';
        cs.eLight_Invoiced_Price_Unit_T__c='10;20;30;';
        cs.eLight_Invoiced_UM__c='Test1;Test2;test3;';
        cs.eLight_Invoiced_Qty_T__c='10;30;';
        cs.eLight_Invoiced_Extended_Amount_T__c='10;20;30;';
        cs.eLight_Return_Qty_T__c='10;20;30;';
        cs.eLight_Return_Extended_Amount_T__c='10;20;30;';
        
        insert cs;
        // list<Product_Returns_list__c> prlist = [select id,Case__c from Product_Returns_list__c where Case__c =:cs.id];
        // system.assertNotEquals(0, prlist.size());
        
        ID reccaserTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('eLight - Return').getRecordTypeId();
        Case csr=TestDataUtil.createCase(acc);
        //csr.RecordTypeId = reccaserTypeID;
        csr.Accountid=acc.ID;
        csr.Contactid=ct.id;
        csr.GE_NAS_Sub_Status__c='In Process';
        csr.GE_NAS_Customer_Impact__c='1-Customer OK';
        csr.Product_Code_1__c='Testcase';
        csr.GE_NAS_SR_Number__c='12345567';
        csr.eLight_Comments__c='Test1';
        csr.eLight_Invoiced_Price_T__c='10';
        csr.eLight_Invoiced_Price_Unit_T__c='10';
        csr.eLight_Invoiced_UM__c='Test1';
        csr.eLight_Invoiced_Qty_T__c='10';
        csr.eLight_Invoiced_Extended_Amount_T__c='10';
        csr.eLight_Return_Qty_T__c='10';
        csr.eLight_Return_Extended_Amount_T__c='10';
        
        insert csr;
        // list<Product_Returns_list__c> prlists = [select id,Case__c from Product_Returns_list__c where Case__c =:csr.id];
        // system.assertNotEquals(0, prlists.size());
    }
    
    static testmethod void testLDRParsing()
    {
        TriggerSwitch__c caseSetting = TestDataUtil.createTriggerSwitch('CaseTrigger', true);
        insert caseSetting;
        TriggerSwitch__c opptySetting = TestDataUtil.createTriggerSwitch('OpportunityTrigger', true);
        insert opptySetting;
        ID Lighting_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GE_LGT_Design_Request').getRecordTypeId();
        ID Standard_RecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-10-Z8';
        acc.RecordTypeId=recAccTypeID;
        insert acc;
        Opportunity newOpp = new Opportunity();
        newOpp.AccountId =acc.Id;
        newOpp.RecordTypeId= Standard_RecordType;
        newOpp.Name ='test';
        newOpp.StageName = 'S1 Consult';
        newOpp.CloseDate = system.today()+7;
        insert newOpp;
        Opportunity newOpp1 = new Opportunity();
        newOpp1.AccountId =acc.Id;
        newOpp1.RecordTypeId= Standard_RecordType;
        newOpp1.Name ='test1';
        newOpp1.StageName = 'S1 Consult';
        newOpp1.CloseDate = system.today()+7;
        insert newOpp1;
        Case newCase = new Case();
        newCase.RecordTypeId = Lighting_RecordType;
        newCase.Origin = 'eLight - Daintree Request';
        newCase.Description = '@@firstName::Shared@@lastName:: elightsfdcuser @@emailAddress:: pavankumar.mudiganti@ge.com @@ssoCode::@@agency::@@country:: US @@phoneNumber::  3308374520 @@salesPerson::@@prObj:: Lighting , Lighting Control @@prObjOthDesc:: @@projName::LDR Project @@endUser::LDR sales @@endUserType::Higher Ed @@custType::Electrical Contractor @@sfdcOppId:: @@approxVal::@@dueDate:: 10/31/2017 @@addlContact::@@appType::   ParkingLot @@appTypeOthDesc::@@desServ::    Controls Layout, Lighting Layout, Spec Review / Product Info @@desServOthDesc:: Retrofit @@constrType:: Retrofit @@fixturePlace::   Existing, one for one @@projAddress1::  techm @@projAddress2::@@projCity::  hyderabad @@projState:: telangana @@projCountry::   IN @@projPostal::@@isCompInvolved::Yes @@compInvolved::@@numBuildings::3 @@squareFootage::3453 @@roomNumber::3 @@roomLength::33 @@roomWidth::44 @@roomHeight::55 @@reflCeiling::2 @@reflWalls::4 @@reflFloor::1 @@fixMountHeight::Specify @@suspPendLength::34 @@vertLevelSpec::@@obstrHeight::@@roadClass::Local @@pedestConf::Low @@laneQuality::@@roadWidth::@@poleSetback::@@layoutConfig::Staggered @@unitOfMeas::Feet/Foot Candles @@lightLevSpec::IES Recommendations (Standard) @@showLightLev::25,000 hours @@calcPointPlace::@@ambCeilingTemp::25°C (Air Conditioned Space) @@lightLevAvgMin::34 @@lightLevMaxMin::33 @@lightLevMin::33 @@spillLightLev::@@fixTechNew::@@fixTechExist::@@fixMountNew::@@fixMountExist::@@fixArmNew::@@fixArmExist::@@fixWattNew::@@fixWattExist::${ctx.gelDesignLayoutModel.existingFixtureWattage} @@fixColorNew::@@fixColorExist::@@addlInfoLLF::@@addlInfoCCT::@@addlInfoWatt::@@matchLevels::Yes @@contrLayout::true @@lightSol:: @@lightSolNewDesc:: @@currLightType::old one @@currLightContr:: @@isDimming:: @@simpWallSwitch::true @@occSensors::true @@schedTimes::true @@dayHarvest::true @@currSpUsage::false @@seqOfOps:: @@emergLightMgmt::Integrated battery backup @@solArch::Granular @@compReqs::California Title 24 @@compReqsOthDesc:: @@intOtherContr::false @@schOccEq:: @@schOccEqSumm:: @@plenumAvail:: @@intHvacContr:: @@hvacSysSumm:: @@intAirMon::false @@monAreaSumm::false @@monMetrSumm:: @@monMetrPurp:: @@intPwrMet::false @@pwrMetQty::';
        insert newCase;
        Opportunity createdOppty = [SELECT ID, GE_LGT_GE_Opportunity_Id__c from Opportunity where id = :newOpp.Id];
        newCase.eLight_Opportunity_ID__c = createdOppty.GE_LGT_GE_Opportunity_Id__c;
        //System.assertEquals(null, createdOppty.GE_LGT_GE_Opportunity_Id__c);
        CaseTriggerDispatcher.newRecord = false;
        update newCase;
        Opportunity createdOppty1 = [SELECT ID, GE_LGT_GE_Opportunity_Id__c from Opportunity where id = :newOpp1.Id];
        newCase.eLight_Opportunity_ID__c = createdOppty1.GE_LGT_GE_Opportunity_Id__c;
        update newCase;
    }
    static testmethod void testUpdateOppty()
    {
        TriggerSwitch__c caseSetting = TestDataUtil.createTriggerSwitch('CaseTrigger', true);
        insert caseSetting;
        TriggerSwitch__c opptySetting = TestDataUtil.createTriggerSwitch('OpportunityTrigger', true);
        insert opptySetting;
        ID Lighting_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GE_LGT_Design_Request').getRecordTypeId();
        ID Standard_RecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-10-Z8';
        acc.RecordTypeId=recAccTypeID;
        insert acc;
        Opportunity newOpp = new Opportunity();
        newOpp.AccountId =acc.Id;
        newOpp.RecordTypeId= Standard_RecordType;
        newOpp.Name ='test';
        newOpp.StageName = 'S1 Consult';
        newOpp.CloseDate = system.today()+7;
        newOpp.GE_LGT_GE_Opportunity_Id__c='NA0009875';
        insert newOpp;
        Opportunity newOpp1 = new Opportunity();
        newOpp1.AccountId =acc.Id;
        newOpp1.RecordTypeId= Standard_RecordType;
        newOpp1.Name ='test1';
        newOpp1.StageName = 'S1 Consult';
        newOpp1.CloseDate = system.today()+7;
        newOpp1.GE_LGT_GE_Opportunity_Id__c='NA0009875';
        insert newOpp1;
        Opportunity createdOppty1 = [SELECT ID, GE_LGT_GE_Opportunity_Id__c from Opportunity where id = :newOpp1.Id];
        Case newCase = new Case();
        newCase.RecordTypeId = Lighting_RecordType;
        newCase.Origin = 'eLight - Daintree Request';
        newCase.Description = '@@firstName::Shared@@lastName:: elightsfdcuser @@emailAddress:: pavankumar.mudiganti@ge.com @@ssoCode::@@agency::@@country:: US @@phoneNumber::  3308374520 @@salesPerson::@@prObj:: Lighting , Lighting Control @@prObjOthDesc:: @@projName::LDR Project @@endUser::LDR sales @@endUserType::Higher Ed @@custType::Electrical Contractor @@sfdcOppId::'+createdOppty1.GE_LGT_GE_Opportunity_Id__c+'@@approxVal::@@dueDate::   10/31/2017 @@addlContact::@@appType::   ParkingLot @@appTypeOthDesc::@@desServ::    Controls Layout, Lighting Layout, Spec Review / Product Info @@desServOthDesc:: Retrofit @@constrType:: Retrofit @@fixturePlace::   Existing, one for one @@projAddress1::  techm @@projAddress2::@@projCity::  hyderabad @@projState:: telangana @@projCountry::   IN @@projPostal::@@isCompInvolved::Yes @@compInvolved::@@numBuildings::3 @@squareFootage::3453 @@roomNumber::3 @@roomLength::33 @@roomWidth::44 @@roomHeight::55 @@reflCeiling::2 @@reflWalls::4 @@reflFloor::1 @@fixMountHeight::Specify @@suspPendLength::34 @@vertLevelSpec::@@obstrHeight::@@roadClass::Local @@pedestConf::Low @@laneQuality::@@roadWidth::@@poleSetback::@@layoutConfig::Staggered @@unitOfMeas::Feet/Foot Candles @@lightLevSpec::IES Recommendations (Standard) @@showLightLev::25,000 hours @@calcPointPlace::@@ambCeilingTemp::25°C (Air Conditioned Space) @@lightLevAvgMin::34 @@lightLevMaxMin::33 @@lightLevMin::33 @@spillLightLev::@@fixTechNew::@@fixTechExist::@@fixMountNew::@@fixMountExist::@@fixArmNew::@@fixArmExist::@@fixWattNew::@@fixWattExist::${ctx.gelDesignLayoutModel.existingFixtureWattage} @@fixColorNew::@@fixColorExist::@@addlInfoLLF::@@addlInfoCCT::@@addlInfoWatt::@@matchLevels::Yes @@contrLayout::true @@lightSol:: @@lightSolNewDesc:: @@currLightType::old one @@currLightContr:: @@isDimming:: @@simpWallSwitch::true @@occSensors::true @@schedTimes::true @@dayHarvest::true @@currSpUsage::false @@seqOfOps:: @@emergLightMgmt::Integrated battery backup @@solArch::Granular @@compReqs::California Title 24 @@compReqsOthDesc:: @@intOtherContr::false @@schOccEq:: @@schOccEqSumm:: @@plenumAvail:: @@intHvacContr:: @@hvacSysSumm:: @@intAirMon::false @@monAreaSumm::false @@monMetrSumm:: @@monMetrPurp:: @@intPwrMet::false @@pwrMetQty::';
        insert newCase;
        
        //newCase.eLight_Opportunity_ID__c = createdOppty1.GE_LGT_GE_Opportunity_Id__c;
        newCase.Opportunity_Name__c = newOpp1.id;
        update newCase;
        newCase.Opportunity_Name__c = newOpp.id;
        update newCase;
    }
    
     @isTest
    static void beforeUpdateinCaseTriggerDispatch() {
        TriggerSwitch__c caseSetting = TestDataUtil.createTriggerSwitch('CaseTrigger', true);
        insert caseSetting;
        Id NE_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CaseConstants.NE_RECORD_TYPE).getRecordTypeId();
        Id SAP_RecordType = schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        
        Account acc = new Account(RecordTypeId = SAP_RecordType, GE_LGT_EM_Sales_Org__c='2HU2',GE_LGT_EM_Distribution_Channel__c='10',Name='Test Ac',CurrencyIsoCode='USD',GE_LGT_EM_Email_Address__c='anudeep@ge.com',GE_LGT_EM_SAP_Customer_Number__c ='0098546781');//GE_LGT_EM_Division__c='20',
        insert acc;
        contact cnt1 = new Contact(lastName='Michael Hoexter', Accountid=acc.ID, FirstName='Michael');
        insert cnt1;
        
        Contact cnt = new Contact(lastName='testUser', GE_LGT_Row_Id__c='1-JR6HG4', FirstName='Michael');
        insert cnt;
        NAServiceDummyContact__c dummyContact = new NAServiceDummyContact__c(AccountId__c = acc.Id, ContactId__c=cnt1.Id);
        insert dummyContact;
        List<Case> newCaseList=new  List<Case>();
         List<Case> oldCaseList=new  List<Case>();
        Case newCase=new Case();
        newCase.Subject=CaseConstants.SHIPPING_SUBJECT +'TestSubject';
        newCase.Origin = 'Email';
        newCase.GE_LGT_Business__c = CaseConstants.NE_RECORD_TYPE;
        newCase.RecordTypeId = NE_RecordType;
        newCase.description = 'WEB #245454- SHIPPING DISCREPANCY - Account 45656000001 Contact :AndrewLoyd E-mail :aloyd@loydselectric.com Email :aloyd@loydselectric.com\n Fax :45321 Phone :417-334-2171\n PO# :132720\n PickTicket# :38707071\n 1.Product: 68850Qty: 36RAP Qty: 2REORDER: noUOM: each/bulbType of Discrepancy: damage 2.Product: 68052Qty: 15RAP Qty: 15REORDER: noUOM: each/bulbType of Discrepancy: damage 3.Product: 68168Qty: 24RAP Qty: 4REORDER: noUOM: each/bulbType of Discrepancy: damage Comments:';        
        newCase.GE_NAS_EmailDescription__c = 'WEB #245454- SHIPPING DISCREPANCY - Account 45656000001 Contact :AndrewLoyd E-mail :aloyd@loydselectric.com Email :aloyd@loydselectric.com\n Fax :45321 Phone :417-334-2171\n PO# :132720\n PickTicket# :38707071\n 1.Product: 68850Qty: 36RAP Qty: 2REORDER: noUOM: each/bulbType of Discrepancy: damage 2.Product: 68052Qty: 15RAP Qty: 15REORDER: noUOM: each/bulbType of Discrepancy: damage 3.Product: 68168Qty: 24RAP Qty: 4REORDER: noUOM: each/bulbType of Discrepancy: damage Comments:';        
        newCase.GE_NAS_ToAddress__c = 'Test@ge.com';
        newCase.SuppliedEmail='Test@ge.com';
        newCase.GE_NAS_Bill_of_Lading__c='tst';
        insert newCase;
        newCaseList.add(newCase);
        
       /* Case newClosedCase=new Case();
         newClosedCase.Subject=CaseConstants.SHIPPING_SUBJECT +'TestSubject';
        newClosedCase.Origin = 'Web';
        newClosedCase.GE_LGT_Business__c = CaseConstants.NE_RECORD_TYPE;
        newClosedCase.GE_NAS_Sub_Status__c = 'closed';
        newClosedCase.RecordTypeId = NE_RecordType;
        newClosedCase.GE_NAS_EmailDescription__c = 'WEB #245454- SHIPPING DISCREPANCY - Account 45656000001 Contact :AndrewLoyd E-mail :aloyd@loydselectric.com Email :aloyd@loydselectric.com Fax :45321 Phone :417-334-2171 PO# :132720 PickTicket# :38707071 1.Product: 68850Qty: 36RAP Qty: 2REORDER: noUOM: each/bulbType of Discrepancy: damage 2.Product: 68052Qty: 15RAP Qty: 15REORDER: noUOM: each/bulbType of Discrepancy: damage 3.Product: 68168Qty: 24RAP Qty: 4REORDER: noUOM: each/bulbType of Discrepancy: damage Comments:';        
        newClosedCase.GE_NAS_ToAddress__c = 'Test2@ge.com';
        newClosedCase.SuppliedEmail='Test2@ge.com';
        insert newClosedCase;
        newCaseList.add(newClosedCase);*/
        
        Case oldCase=new Case();
        oldCase.Subject='BILLING ADJUSTMENT' +'TestSubject';
        oldCase.Origin = 'Web';
        oldCase.GE_LGT_Business__c = CaseConstants.NE_RECORD_TYPE;
        oldCase.RecordTypeId = NE_RecordType;
         oldCase.description= 'Hybris ID: 419021\n Contact Name: Catherine Marsh\nContact Emai: cathy.marsh@3e-co.com\n Contact Phone Number: 3456765\n Sales Order Number: 0000512015\n Opportunity ID/Project Name: test\nPO Number: 737570-00\n Invoice Number 1170312886\n Reason for Return Request: Shortage/Overage\n Price Agreement: 0080114843\n Sold To: 0002536400 - ELECL ENGR/EQUIP-WIND\n Comment:Return Processing Information: No\n Product Information Product Required\n Price Quantity\n Comment 000000000000011918 4.42 45 Concealed shortage. end';
        oldCase.GE_NAS_EmailDescription__c= 'Hybris ID: 419021\n Contact Name: Catherine Marsh\nContact Emai: cathy.marsh@3e-co.com\n Contact Phone Number: 3456765\n Sales Order Number: 0000512015\n Opportunity ID/Project Name: test\nPO Number: 737570-00\n Invoice Number 1170312886\n Reason for Return Request: Shortage/Overage\n Price Agreement: 0080114843\n Sold To: 0002536400 - ELECL ENGR/EQUIP-WIND\n Comment:Return Processing Information: No\n Product Information Product Required\n Price Quantity\n Comment 000000000000011918 4.42 45 Concealed shortage. end';
        //oldCase.GE_NAS_EmailDescription__c = 'WEB #245454- SHIPPING DISCREPANCY - Account 45656000001 Contact :AndrewLoyd E-mail :aloyd@loydselectric.com Email :aloyd@loydselectric.com Fax :45321 Phone :417-334-2171 PO# :132720 PickTicket# :38707071 1.Product: 68850Qty: 36RAP Qty: 2REORDER: noUOM: each/bulbType of Discrepancy: damage 2.Product: 68052Qty: 15RAP Qty: 15REORDER: noUOM: each/bulbType of Discrepancy: damage 3.Product: 68168Qty: 24RAP Qty: 4REORDER: noUOM: each/bulbType of Discrepancy: damage Comments:';        
        oldCase.GE_NAS_ToAddress__c = 'Test1@ge.com';
        oldCase.SuppliedEmail='rama1@ge.com';
        insert oldCase;
        oldCaseList.add(oldCase);
        GE_NAS_CaseRoutingePersonalEmails__c newMails = new GE_NAS_CaseRoutingePersonalEmails__c(name ='pavan', GE_NAS_Personal_Email__c='pavan.kumar@ge.com', GE_NAS_Case_Routing_Email__c='Test@ge.com', GE_NAS_Active__c=true);
        insert newMails;
        //system.assertNotEquals(null, [Select Id from Shipment_Detail__c]);
        Map<Id,Case> newCaseMap = new Map<Id,Case>();
        Map<Id,Case> oldCaseMap = new Map<Id,Case>();
        for(case cnew:newCaseList)
        {
            newCaseMap.put(cnew.id,cnew);
        }
        for(case cold:oldCaseList)
        {
            oldCaseMap.put(cold.id,cold);
        }
        CaseTriggerDispatcher.beforeUpdate(newCaseList,newCaseMap,oldCaseList,oldCaseMap);    
        CaseTriggerDispatcher.beforeInsert(oldCaseList);
        
        oldCase.Subject = 'Initiate a Return';
        update oldCase;
        list<case> newcaselist1 = new list<Case>();
        newcaselist1.add(oldCase);
                CaseTriggerDispatcher.beforeInsert(newcaselist1);
        string subject = '10,20,30,40';
        CaseTriggerHelper.changeData(subject);
        
        string subject1 = '0,10,20,30';
        CaseTriggerHelper.changeData(subject1);

        string subject2 = '10,30,20,30';
        CaseTriggerHelper.changeData(subject2);
        
        string subject3 = '10,40,20,30';
        CaseTriggerHelper.changeData(subject3);
        
        string subject4 = '10,10,30,100000000';
        CaseTriggerHelper.changeData(subject4);

        string subject5 = '10,30,20,20000000';
        CaseTriggerHelper.changeData(subject5);
        
        string subject6 = '10,40,20,3000000';
        CaseTriggerHelper.changeData(subject6);
        
         string subject7 = '10,10,30,10000';
        CaseTriggerHelper.changeData(subject7);

        string subject8 = '10,30,20,2000';
        CaseTriggerHelper.changeData(subject8);
        
        string subject9 = '10,40,20,300';
        CaseTriggerHelper.changeData(subject9);
        
       CaseTriggerHelper.RepCodeLookup(newcaselist);

    } 
    
  
}
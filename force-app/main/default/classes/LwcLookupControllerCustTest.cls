/*
Name - LwcLookupControllerCustTest
Methods - findRecordsTest		  
Purpose - Test Class for LwcLookupControllerCust
*/


@istest
public class LwcLookupControllerCustTest {
    public static testMethod void findRecordsTest(){
        String searchKey = 'H';
        String objectName = 'Account';
        String filterField = 'Type';
        String filterFieldValue = 'Other';
        Account ac = new Account();
        ac.Account_Group__c='ZEAG';
		ac.Name ='cc' ;       
        insert ac;
        string searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';  
        string query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText+' LIMIT 6';
        List<sobject> obj = new List<sobject>();
        String tempNumber = 'H7C';
        List<Account> accRet = new  List<Account>();
        if((!(tempNumber.startsWith('U') && tempNumber.length() >= 6))){
            Account accNew = new  Account();
            accNew.Name=ac.Name +' '+ '(' + ac.GE_LGT_EM_SAP_Customer_Number__c+ ')';
            accNew.Id=ac.Id;
            accRet.add(accNew);
        }

        if(String.isBlank(filterField)){
       }  
       else{
           
       string filterFieldText = '\'' + String.escapeSingleQuotes(filterFieldValue) + '%\'';  
       query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText+ ' AND ' +filterField+ ' LIKE ' +filterFieldText+ ' LIMIT 6';
       }
       Test.startTest();
       LwcLookupControllerCust.findRecords(searchKey, objectName, filterField, filterFieldValue);
       Test.stopTest();
    }
    public static testMethod void findRecordsTest1(){
        String searchKey = 'H';
        //string searchText = '%'+searchKey+'%';
        String objectName = 'Account';
        String filterField = '';
        String filterFieldValue = 'Other';
        
        string searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';  
        string query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText+' LIMIT 6';
        List<sobject> obj = new List<sobject>();
        if(String.isBlank(filterField)){
       }  
       else{
           
       string filterFieldText = '\'' + String.escapeSingleQuotes(filterFieldValue) + '%\'';  
       query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText+ ' AND ' +filterField+ ' LIKE ' +filterFieldText+ ' LIMIT 6';
       }
       Test.startTest();
       LwcLookupControllerCust.findRecords(searchKey, objectName, filterField, filterFieldValue);
       Test.stopTest();
    }
    public static testMethod void findDistRecordsTest(){
        String searchKey = 'cc';
        String objectName = 'Account';
        String filterField = 'Type';
        String filterFieldValue = 'Other';
        Account acct = [SELECT Id, Name,Account_Group__c,ConnectFixtureAgents__c FROM Account WHERE ccrz__dataId__c = 'B2BContact'];
        acct.Account_Group__c='Z001';
        acct.ConnectFixtureAgents__c='Other';
		acct.Name ='cc' ;       
        update acct;
        
        Test.startTest();
       LwcLookupControllerCust.findDistRecords(searchKey, objectName, filterField, filterFieldValue);
       Test.stopTest();
    }
    
    public static testMethod void findOrderRecordsTest(){
        String searchKey = '1158';
        String objectName = 'orderExp';
        String filterFieldValue = 'DEFAULT_DIS';
        
        
        Account acct = [SELECT Id, Name,Account_Group__c FROM Account WHERE ccrz__dataId__c = 'B2BContact'];
        Order ord = [Select id,Sold_To__c,GBSTK__c,GE_Order_NO__c,Customer_PO_Number__c from Order where AccountId =: acct.id];
		ord.Customer_PO_Number__c='1158';
        ord.Sold_To__c=acct.id;
       String filterField = acct.id;
		update ord;
        Test.startTest();
       LwcLookupControllerCust.findOrderRecords(searchKey, objectName, filterField, filterFieldValue);
        LwcLookupControllerCust.findOrderRecordsNEW(searchKey, objectName, filterField, filterFieldValue);
       Test.stopTest();
    }
    public static testMethod void findOrderRecordsTest1(){
        
        String searchKey = '1158';
        String objectName = 'orderExp';
        String filterFieldValue = 'DEFAULT';
        
        Account acct = [SELECT Id, Name,Account_Group__c FROM Account WHERE ccrz__dataId__c = 'B2BContact'];
        Order ord = [Select id,Sold_To__c,GBSTK__c,GE_Order_NO__c,Customer_PO_Number__c,Agent_Account__c from Order where AccountId =: acct.id];
		ord.Customer_PO_Number__c='1158';
        ord.Agent_Account__c=acct.id;
       String filterField = acct.id;
		update ord;
        
       
        
        
        
        Test.startTest();
       LwcLookupControllerCust.findOrderRecords(searchKey, objectName, filterField, filterFieldValue);
        LwcLookupControllerCust.findOrderRecordsNEW(searchKey, objectName, filterField, filterFieldValue);
       Test.stopTest();
    }
    public static testMethod void findOrderRecordsTest2(){
        
        String searchKey = '1158';
        String objectName = 'orderExp';
        
        	Account acct = [SELECT Id, Name,Account_Group__c FROM Account WHERE ccrz__dataId__c = 'B2BContact'];
        	Order ord = [Select id,Sold_To__c,GBSTK__c,GE_Order_NO__c,Customer_PO_Number__c,Agent_Account__c from Order where AccountId =: acct.id];
			ord.Customer_PO_Number__c='1158';
        	ord.Agent_Account__c=acct.id;
        	ord.Sold_To__c=acct.id;
       		String filterField = acct.id;
            String filterFieldValue = acct.id;

			update ord;
        
        Test.startTest();
       LwcLookupControllerCust.findOrderRecords(searchKey, objectName, filterField, filterFieldValue);
        LwcLookupControllerCust.findOrderRecordsNEW(searchKey, objectName, filterField, filterFieldValue);
       Test.stopTest();
    }
    
    public static testMethod void findOrderRecordsTest3(){
        String searchKey = '1158';
        String objectName = 'orderExp';
        String filterField = 'GE_Order_NO__c';
        String filterFieldValue = 'DEFAULT_DIS';
        
        Test.startTest();
       LwcLookupControllerCust.findOrderRecords(searchKey, objectName, filterField, filterFieldValue);
        LwcLookupControllerCust.findOrderRecordsNEW(searchKey, objectName, filterField, filterFieldValue);
       Test.stopTest();
    }
    
    public static testMethod void findOrderRecordsTest4(){
        
        String objectName = 'Test';
        String searchKey = '1158';
        String filterField = 'GE_Order_NO__c';
        String filterFieldValue = 'DEFAULT_DIS';
        String searchText = '4';
        
        Account acc = new Account();
        acc.Name = 'Acc1';
        insert acc;
        
        Order ord = new Order();
        ord.GE_Order_NO__c = '474625';
        ord.Customer_PO_Number__c = '4517260492';
        ord.AccountId = acc.id;
        ord.EffectiveDate = date.today();
       // ord.Sold_To__c = filterField;
        insert ord;
        
	    Order ordNew = new  Order();
		ordNew.GE_Order_NO__c=ord.GE_Order_NO__c +' '+ '(' + ord.Customer_PO_Number__c+ ')';
		ordNew.Id=ord.Id;
            
        
       Test.startTest();
       LwcLookupControllerCust.findOrderRecords(searchKey, objectName, filterField, filterFieldValue);
        LwcLookupControllerCust.findOrderRecordsNEW(searchKey, objectName, filterField, filterFieldValue);
       Test.stopTest();
    }
    
    public static testMethod void findOrderRecordsTest10(){
        
        String searchKey = '1158';
        String objectName = '1orderExp1';
        String filterFieldValue = 'DEFAULT';
        
        Account acct = [SELECT Id, Name,Account_Group__c FROM Account WHERE ccrz__dataId__c = 'B2BContact'];
        Order ord = [Select id,Sold_To__c,GBSTK__c,GE_Order_NO__c,Customer_PO_Number__c,Agent_Account__c from Order where AccountId =: acct.id];
		ord.Customer_PO_Number__c='1158';
        ord.Agent_Account__c=acct.id;
       String filterField = acct.id;
		update ord;
        
       
        
        
        
        Test.startTest();
       LwcLookupControllerCust.findOrderRecords(searchKey, objectName, filterField, filterFieldValue);
        LwcLookupControllerCust.findOrderRecordsNEW(searchKey, objectName, filterField, filterFieldValue);
       Test.stopTest();
    }
    
    public static testMethod void findOrderRecordsTest101(){
        
        String searchKey = '1158';
        String objectName = '1orderExp1';
        String filterFieldValue = '1DEFAULT1';
        
        Account acct = [SELECT Id, Name,Account_Group__c FROM Account WHERE ccrz__dataId__c = 'B2BContact'];
        Order ord = [Select id,Sold_To__c,GBSTK__c,GE_Order_NO__c,Customer_PO_Number__c,Agent_Account__c from Order where AccountId =: acct.id];
		ord.Customer_PO_Number__c='1158';
        ord.Agent_Account__c=acct.id;
       String filterField = acct.id;
		update ord;
        
       
        
        
        
        Test.startTest();
       LwcLookupControllerCust.findOrderRecords(searchKey, objectName, filterField, filterFieldValue);
        LwcLookupControllerCust.findOrderRecordsNEW(searchKey, objectName, filterField, filterFieldValue);
       Test.stopTest();
    }
    
    public static testMethod void findAccRecordsTest(){
        //Test.startTest();

        String searchKey = 'cc';
        String objectName = 'Order';
        String filterField = 'GE_Order_NO__c';
        List<Account> acclst = new List<Account>();
        
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select Id,AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        Account acct = [SELECT Id, Name,Account_Group__c,ConnectFixtureAgents__c FROM Account WHERE ccrz__dataId__c = 'B2BContact'];
        String filterFieldValue = customerContact.Id;

        
        acct.Account_Group__c='ZAEG';
        acct.ConnectFixtureAgents__c='Other';
		acct.Name ='cc' ;       
        update acct;
       // Test.startTest();
       LwcLookupControllerCust.findAccRecords(searchKey, objectName, filterField, filterFieldValue);
      // Test.stopTest();
    }
    
     public static testMethod void findAccSpecRecordsTest(){
        //Test.startTest();

        String searchKey = 'cc';
        String objectName = 'Order';
        String filterField = 'GE_Order_NO__c';
        List<Account> acclst = new List<Account>();
         
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select Id,AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        Account acct = [SELECT Id, Name,Account_Group__c,ConnectFixtureAgents__c FROM Account WHERE ccrz__dataId__c = 'B2BContact'];
        String filterFieldValue = customerContact.Id;

        
        acct.Account_Group__c='ZEAG';
        acct.ConnectFixtureAgents__c='Other';
		acct.Name ='cc' ;       
        update acct;
       // Test.startTest();
       LwcLookupControllerCust.findAccSpecRecords(searchKey, objectName, filterField, filterFieldValue);
      // Test.stopTest();
    }
    
    @testSetup static void setupTestData() {
        List<TriggerSwitch__c> switchList = TestDataUtil.insertTriggerSwitches();
        
        insert switchList;

        b2bTestSetup.setupPortalUsers();
		b2bTestSetup.setupPricelist();
		User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        // AccountContactRelation relation = new AccountContactRelation(AccountId = customerContact.AccountId, contactId = customerContact.Id);
        // insert relation;
		Account acct = [SELECT Id, Name,Account_Group__c FROM Account WHERE ccrz__dataId__c = 'B2BContact'];
        acct.Account_Group__c='ZEAG';
		acct.Name ='cc' ;       
        update acct;
        
        Opportunity testOpportunity = new Opportunity();
        testOpportunity.Name = 'Test Opp 1';
        testOpportunity.GE_LGT_GE_Opportunity_Id__c='12EU34';
        testOpportunity.StageName = 'S1 Consult';
        testOpportunity.AccountID = acct.id;
        testOpportunity.CurrencyIsoCode ='USD';
        testOpportunity.Probability = 10;
        testOpportunity.Distribution_Channel__c ='No';
        testOpportunity.Going_through_agent__c ='No';
        testOpportunity.CloseDate = System.Today() + 20;
        testOpportunity.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 40;
        testOpportunity.GE_LGT_Expected_Ship_Date__c = System.Today() + 45;
        testOpportunity.Warranty__c = 'Standard Product Warranty';
        testOpportunity.GE_LGT_Reason_Won_Lost__c=System.Label.Customer_Cancelled;
        testOpportunity.GE_LGT_SIMPLESALES__c='Yes';
        testOpportunity.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        testOpportunity.Type = 'Daintree';
        insert testOpportunity;
        
        Order testOrder = new Order();
        testOrder.status = 'Draft';
        testOrder.EffectiveDate = Date.Today();
        testOrder.CurrencyIsoCode = 'USD';
        testOrder.OpportunityId = testOpportunity.Id;
        testOrder.AccountId = acct.id;
        
        insert testOrder;

    }
    
    @isTest
    
    static void getOrdDtlTest(){
        
        Account acc = new Account();
        acc.Name = 'Acc1';
        insert acc;
        
        Order ord = new Order();
        ord.GE_Order_NO__c = 'OrdGEC878';
        ord.Customer_PO_Number__c = '5654345';
        ord.AccountId = acc.id;
        ord.EffectiveDate = date.today();
        insert ord;
        String newData = ord.GE_Order_NO__c +' '+ '(' + ord.Customer_PO_Number__c+ ')';
        
        Test.startTest();
        LwcLookupControllerCust.getOrdDtl(ord.id);
        Test.stopTest();
        
        
    }
    
     public static testMethod void findInvRecordsTest(){
        //Test.startTest();

        String searchKey = '12345';
        String objectName = 'Invoice';
        String filterField = 'H9M';
        String filterFieldValue = 'Default';
         
        Account acct = [SELECT Id, Name,Account_Group__c FROM Account WHERE ccrz__dataId__c = 'B2BContact']; 
        GE_LGT_EM_InvoiceHeader__c iHead= new GE_LGT_EM_InvoiceHeader__c();
        iHead.GE_LGT_EM_Payer_SoldTo_Account_Number__c='H9M';
        iHead.GE_LGT_EM_SAPInvoiceNumber__c= '12345';
         insert iHead;
       Test.startTest();
       LwcLookupControllerCust.findInvRecords(searchKey, objectName, filterField, filterFieldValue);
       Test.stopTest();
    }
    
    public static testMethod void findOrderRecordsNEWTest(){
        //Test.startTest();

        String searchKey = 'cc';
        String objectName = 'Order';
        String filterField = 'GE_Order_NO__c';
        List<Account> acclst = new List<Account>();
         
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select Id,AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        Account acct = [SELECT Id, Name,Account_Group__c,ConnectFixtureAgents__c FROM Account WHERE ccrz__dataId__c = 'B2BContact'];
        String filterFieldValue = customerContact.Id;

        
        acct.Account_Group__c='ZEAG';
        acct.ConnectFixtureAgents__c='Other';
		acct.Name ='cc' ;       
        update acct;
       // Test.startTest();
       LwcLookupControllerCust.findOrderRecordsNEW(searchKey, objectName, filterField, filterFieldValue);
      // Test.stopTest();
    }
    
     @isTest
    
    static void getOrdDtlNEWTest(){
        
        Account acc = new Account();
        acc.Name = 'Acc1';
        insert acc;
        
        Order ord = new Order();
        ord.GE_Order_NO__c = 'OrdGEC878';
        ord.Customer_PO_Number__c = '5654345';
        ord.AccountId = acc.id;
        ord.EffectiveDate = date.today();
        insert ord;
        String newData = ord.GE_Order_NO__c +' '+ '(' + ord.Customer_PO_Number__c+ ')';
        
        Test.startTest();
        LwcLookupControllerCust.getOrdDtlNEW(ord.id);
        Test.stopTest();
        
        
    }
      public static testMethod void findSoldToRecordsTest(){
        String searchKey = '1158';
        String objectName = 'orderExp';
        String filterFieldValue = 'DEFAULT_DIS';
        
        
        Account acct = [SELECT Id, GE_LGT_EM_SAP_Customer_Number__c,Name,Account_Group__c FROM Account WHERE ccrz__dataId__c = 'B2BContact'];
        Order ord = [Select id,Sold_To__c,GBSTK__c,GE_Order_NO__c,Customer_PO_Number__c from Order where AccountId =: acct.id];
		ord.Customer_PO_Number__c='1158';
        ord.Sold_To__c=acct.id;
       String filterField = acct.GE_LGT_EM_SAP_Customer_Number__c;
		update ord;


        List<GE_LGT_EM_InvoiceLineItem__c> invToAdd = new List<GE_LGT_EM_InvoiceLineItem__c>();
        GE_LGT_EM_InvoiceLineItem__c newInv = new GE_LGT_EM_InvoiceLineItem__c();
        newInv.GE_LGT_EM_Customer_PO_Number__c = '1158';
        insert newInv;
        invToAdd.add(newInv);

        Test.startTest();
       LwcLookupControllerCust.preLoadLineRecords(searchKey, objectName, 'H9M', 'Agent');
       LwcLookupControllerCust.findInvLineRecords(searchKey, objectName, filterField, 'H9M');
       LwcLookupControllerCust.preLoadLineRecords(searchKey, objectName, 'H9M', 'Distributor');
       LwcLookupControllerCust.findInvLineRecords(searchKey, objectName, filterField, null);
        LwcLookupControllerCust.findSoldToRecords(searchKey, objectName,filterFieldValue);
        LwcLookupControllerCust.soldToFiltering(searchKey, filterField, invToAdd);
        LwcLookupControllerCust.orderInitiatedFiltering(searchKey, filterField, 'H9M', 'Agent');
        LwcLookupControllerCust.agentAndSoldToFiltering(filterField, 'H9M', 'Agent');
        LwcLookupControllerCust.orderInitiatedFiltering(searchKey, filterField, 'H9M', 'Distributor');
        LwcLookupControllerCust.agentAndSoldToFiltering(filterField, 'H9M', 'Distributor');
       Test.stopTest();
    }  
    
    public static testMethod void getInvLineNewListtest(){
        GE_LGT_EM_InvoiceLineItem__c inv = new GE_LGT_EM_InvoiceLineItem__c();
        inv.GE_LGT_EM_SAP_Invoice_Number__c='Test';
        inv.GE_LGT_EM_Order_Number__c ='Test';
     	inv.GE_LGT_EM_Customer_PO_Number__c='Test';
     	inv.GE_LGT_EM_Sales_Unit__c='Test';
     	//inv.GE_LGT_EM_Material_Description__c='Test';
     	//inv.GE_LGT_EM_Invoiced_Price__c ='Test';
     	inv.GE_LGT_EM_Invoiced_Quantity__c=2.0;
     	//inv.SKU__c='Test';
     	inv.GE_LGT_EM_DisputeCount__c=5.0;
     	//inv.Requested_Action_Override__c='Test';
     	inv.Total_Returned__c=10.0;
     	//inv.Available_for_Return__c='Test';
     	inv.QuickStock__c=true;
        insert inv;
        string obj = inv.id;
        Test.startTest();
       LwcLookupControllerCust.getInvLineNewList(inv.id);
        //LwcLookupControllerCust.findSoldToRecords(searchKey, objectName,filterFieldValue);
       Test.stopTest();
    }  

    public static testMethod void getAccountRecordsTest(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.GE_LGT_EM_SAP_Customer_Number__c = 'GEC1';
        acc.Customer_Segmentation__c = 'FD';
        insert acc;

        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.id;
        insert con;

        Test.startTest();
        LwcLookupControllerCust.getAccountRecords(acc.Name, con.id, 'Agent', 'false' );
        LwcLookupControllerCust.getAccountRecords(acc.Name, con.id, 'Agent', 'true' );
        LwcLookupControllerCust.getAccountRecords(acc.Name, con.id, 'Distributor', 'false' );
        LwcLookupControllerCust.getAccountRecords(acc.Name, con.id, 'Distributor', 'true' );
        Test.stopTest();
    }

    public static testMethod void findOrdersTest(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.GE_LGT_EM_SAP_Customer_Number__c = 'GEC1';
        acc.Customer_Segmentation__c = 'FD';
        insert acc;

        Account acc1 = new Account();
        acc1.Name = 'Test Distributor';
        acc1.GE_LGT_EM_SAP_Customer_Number__c = 'GEC1';
        acc1.Customer_Segmentation__c = 'FD';
        insert acc1;

        CustomerProductFamily__c cpf = new CustomerProductFamily__c();
        cpf.ProductFamily1__c = 'RLM';
        cpf.SAPCustomerNumber__c = acc.id;
        cpf.CountyCode__c = '85';
        cpf.CustomerNumberRegionCounty__c = 'GEC1_ND_085';
        cpf.CustomerNumber__c = 'GEC1';
        insert cpf;

        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.id;
        insert con;

        Test.startTest();
        LwcLookupControllerCust.findOrders('Agent', acc.Name, 'Order', acc.id, acc1.id );
        LwcLookupControllerCust.findOrders('Customer', acc.Name, 'Order', acc.id, acc1.id );
        //LwcLookupControllerCust.getProductFamilies(acc.Id);
        Test.stopTest();
    }
    
}
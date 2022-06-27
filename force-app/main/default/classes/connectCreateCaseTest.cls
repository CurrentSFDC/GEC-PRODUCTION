/*
Name - connectCreateCaseTest
        Methods - connectCreateReturnCaseTest
        getOwnerIdTest
        updateFilesTest
        updateOwnerIdTest
        getCaseNumberTest
        createCaseProductTest
        getExpOwnerIdTest
        getAccountNameTest
        getQueueIdTest
        getMarketingQueueIdTest
        getAccountManagerNameTest
Purpose - Test Class for connectCreateCase
*/

@isTest(seeAllData=false)
public class connectCreateCaseTest {
    
    /* Class: connectCreateCase, Method:connectCreateReturnCase */
    
    @isTest
    Static void connectCreateReturnCaseTest(){
        Account Acc = new Account(Name = 'TestAcc');
        // Insert Acc;
        contact ca = new contact(FirstName= 'testCon', LastName='test', Email='abc@xyz.com', AccountId= Acc.id);
        //  insert ca;
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', Spec_Reg_Agency__c = Acc.id ); 
        //  insert cas;
        
        Test.startTest();
        String s = connectCreateCase.connectCreateReturnCase(cas);
        System.assertEquals(cas.id, s);
        Test.stopTest();
        
    }
    
     
    
        /* Class: connectCreateCase, Method:getOwnerId */

    
    @isTest
    Static void getOwnerIdTest(){
        
        Account Acc1 = new Account(Name = 'TestAcc1');
        Insert Acc1;
        contact ca1 = new contact();
        ca1.AccountId= Acc1.id;
        ca1.FirstName= 'testCon';
        ca1.LastName= 'test';
        ca1.Email='abc@xyz.com';
        insert ca1;
        Case case1 = new Case(Status ='New', Priority = 'Medium', Origin = 'Email' ); 
          
        
        
        case1.Spec_Reg_Agency__c = Acc1.Id;
        case1.Type = 'Sales Support';
        case1.GE_NAS_Sub_Type__c = 'New Specification Registration';
        case1.Spec_Reg_Agency__c = Acc1.id;
        
        insert case1;	
        Test.startTest();
        String s1 = connectCreateCase.getOwnerId(case1.Spec_Reg_Agency__c);
        // System.assertEquals(case1.Spec_Reg_Agency__c, s1);
        Test.stopTest();
        
    }
    
    /*@isTest
    public static void disputeWithProductControllerTest(){
        Account Acc1 = new Account(Name = 'TestAcc2');
        Insert Acc1;
        contact ca1 = new contact();
        ca1.AccountId= Acc1.id;
        ca1.FirstName= 'testCon2';
        ca1.LastName= 'test';
        ca1.Email='abc2@xyz.com';
        insert ca1;
        Case case2 = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', AccountId = Acc1.Id ); 
        
        Dispute_Request__c newDis = new Dispute_Request__c();
        newDis.Case__c = case2.Id;
        insert newDis;
        
        Shipment_Detail__c newShip = new Shipment_Detail__c();
        newShip.GE_NAS_Case_Number__c = case2.Id;
        newShip.Dispute_Request__c = newDis.Id;
        insert newShip;
        

    }*/
    
    /* Class: connectCreateCase, Method:updateFiles */
    
    @isTest
    Static void updateFilesTest(){
          List<Id> passFiles = new List<Id>();
          List<ContentVersion> contVer1 = new List<ContentVersion>();
        List<ContentDocumentLink> contLink1 = new List<ContentDocumentLink>();
         Case cas1 = new Case(Status ='New', Priority = 'Medium', Origin = 'Email'); 
        insert cas1;
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
       //  ContentVersion contVer = new ContentVersion();
       // contVer.
        ContentDocumentLink cd = new ContentDocumentLink();
        cd.ContentDocumentId=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        cd.LinkedEntityId= cas1.id;
        insert cd;
        
        List<ContentVersion> contVer = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :passFiles];

        
        /*
        List<Id> passFiles = new List<Id>();
        
        Case cas1 = new Case(Status ='New', Priority = 'Medium', Origin = 'Email'); 
        insert cas1;
        id s = cas1.id;
        List<ContentVersion> contVer = new List<ContentVersion>();
        List<ContentDocumentLink> contLink = new List<ContentDocumentLink>();
        for(ContentVersion cv : contVer){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.LinkedEntityId = cas1.id;
            contLink.add(cdl);
        }
        insert contLink;
        
        List<Id> passFiles1 = new List<Id>();
        
        Case cas11 = new Case(Status ='New', Priority = 'Medium', Origin = 'Email'); 
        insert cas11;
        id s1 = cas11.id;
        List<ContentVersion> contVer1 = new List<ContentVersion>();
        List<ContentDocumentLink> contLink1 = new List<ContentDocumentLink>();
        for(ContentVersion cv1 : contVer){
            ContentDocumentLink cdl1 = new ContentDocumentLink();
            cdl1.ContentDocumentId = cv1.ContentDocumentId;
            cdl1.LinkedEntityId = cas11.id;
            contLink1.add(cdl1);
        }
        insert contLink1; 
*/
        Test.startTest();
        connectCreateCase.updateFiles(passFiles,cas1.id);
        
        
        Test.stopTest();   
    }
    
    @isTest
    Static void fileUploadViewControllerTest(){
        
		ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture12'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        content.IsMajorVersion = true;
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body - Document'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        
        ContentVersion contentNew =new ContentVersion(); 
        contentNew.Title='Header_Picture12'; 
        contentNew.PathOnClient='/' + contentNew.Title + '.jpg'; 
        contentNew.IsMajorVersion = true;
        Blob bodyBlob2=Blob.valueOf('Unit Test ContentVersion Body - TESTING'); 
        contentNew.VersionData=bodyBlob2; 
        //content.LinkedEntityId=sub.id;
        contentNew.origin = 'H';
        insert contentNew;
        
        List<ContentVersion> conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:content.Id];
        List<Id> passFiles = new List<Id>();
        
        for(ContentVersion c :conDoc){
            passFiles.add(c.ContentDocumentId);
        }
        String base64 = 'Test Doc';
        String filename = 'Testing';
        test.startTest();
        FileUploadViewController.getRelatedFiles(passFiles);
        FileUploadViewController.createAssetFile(passFiles);
        FileUploadViewController.getDocumentID(content.Id);
        FileUploadViewController.createDistribution(contentNew.Id);
        FileUploadViewController.createContentVersion(base64,filename);
        test.stopTest();
    }
    
    @isTest
    Static void multiObjectLookupControllerTest(){
        GE_LGT_EM_MaterialMaster__c newMaterial = new GE_LGT_EM_MaterialMaster__c();
        newMaterial.GE_LGT_EM_SAP_MaterialNumber__c	= '98765432';
        newMaterial.GE_LGT_EM_MaterialDescription__c = 'Test Material for Insert';
        insert newMaterial;
        
        String objectName = 'GE_LGT_EM_MaterialMaster__c';
        String filterField = 'GE_LGT_EM_MaterialDescription__c';
        String searchString = 'Test Material for';
        String value = newMaterial.Id;
        String value2 = '';
        
        test.startTest();
			multiObjectLookupController.fetchRecords(objectName,filterField,searchString,value);
        multiObjectLookupController.fetchRecords(objectName,filterField,searchString,value2);
        test.stopTest();
    }
    
        /* Class: connectCreateCase, Method:updateOwnerId */
    
    @isTest
    Static void updateOwnerIdTest(){
        Test.startTest();
        Account a1= new Account(Name = 'TestAcc' );
        insert a1;
        Case s11 = new Case(Status ='New', Priority = 'Medium', Origin = 'Email'); 
        List<case> ca = new List<case>();
        s11.Type='Sales Support' ;
        s11.GE_NAS_Sub_Type__c = 'New Specification Registration';
        insert s11;
        s11.OwnerId=a1.ManagerId__c;
        //update s11;
        Account a2= new Account(Name = 'TestAcc1');
        // a1.ManagerId__c = 123123;
        Case s22 = new Case(Status ='New', Priority = 'Medium', Origin = 'Email'); 
        insert s22;
        s11.OwnerId=a1.ManagerId__c;
       // update s11;
       // connectCreateCase.updateOwnerId(s11.Id);
        Test.stopTest();          
    }
    
    
    /* Class: connectCreateCase, Method:getLDRQueueId */
     
    @isTest
    static void getLDRQueueIdTest(){
        //Account acc = [Select OwnerId from Account where Id = :AccountId];
       
        /*Group grp = new Group();
        grp.Type = 'Queue';
        grp.Name = 'Lighting Design Requests Team';
        insert grp;*/
        
        Test.startTest();
        connectCreateCase.getLDRQueueId();
        Test.stopTest();
    }

   /* @isTest
    static void gpOwnerIdTest(){
    
        Account a1= new Account(Name = 'TestAcc', Growth_Partner_Queue__c = 'Growth Partners' );
        insert a1;

        Test.startTest();
        connectCreateCase.gpOwnerId(a1.Id);
        Test.stopTest();
    }*/
    
        /* Class: connectCreateCase, Method:getCaseProducts */
     
    @isTest
    static void getCaseProducts(){
        
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email'); 
        insert cas;
        
        
        Shipment_Detail__c sp = new Shipment_Detail__c();
        sp.GE_NAS_Comments__c = 'Test';
        sp.GE_NAS_Quantity_Ordered__c = '';
        sp.GE_NAS_Type_of_Problem1__c = 'Request Price Change';
        sp.Order_Qty__c = 9;
        sp.Discrepancy_Qty__c = 7;
        sp.Invoiced_Price__c = 77;
        sp.GE_NAS_Case_Number__c = cas.Id;
        //sp.Discrepancy_Total__c = 89;
       // sp.Requested_Delivery_Date__c = '2021-05-20';
        insert sp;
        
        
        Test.startTest();
        connectCreateCase.getCaseProducts(cas.Id);
        Test.stopTest();
        
        
         
      }
            /* Class: connectCreateCase, Method:getAllDisputeProducts */
    @isTest
    static void getAllDisputeProductsTest(){
        ID northAmerica=Schema.SObjectType.Case.getRecordTypeInfosByName().get('North America').getRecordTypeId();
        
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Connect', RecordTypeId = northAmerica); 
        insert cas;
        
        Case cas1 = new Case(Status ='New', Priority = 'Medium', Origin = 'Connect', RecordTypeId = northAmerica ); 
        insert cas1;
        Dispute_Request__c dr = new Dispute_Request__c();
        insert dr;
        
        Shipment_Detail__c dp = new Shipment_Detail__c();
        dp.Discrepancy_Qty__c = 1;
        dp.Invoiced_Price__c = 100;
        dp.GE_NAS_Type_of_Problem1__c = '';
        dp.GE_NAS_Case_Number__c = cas.id;
        dp.Dispute_Request__c = dr.id;


        insert dp;
        
        // Dispute_Request__c dr1 = new Dispute_Request__c();
        // insert dr1;
        
        // Shipment_Detail__c pro = new Shipment_Detail__c();
        // pro.Discrepancy_Qty__c = 1;
        // pro.Invoiced_Price__c = 100;
        // pro.GE_NAS_Type_of_Problem1__c = '';
        // pro.Dispute_Request__c = dr1.id;
        // pro.GE_NAS_Case_Number__c = cas1.id;
        // insert pro;
        
        Test.startTest();
        //connectCreateCase.getAllDisputeProducts(dr1.Id);
        connectCreateCase.getDisputeProducts(dr.Id);
        Test.stopTest();
        
        
      
  	}
    
    /* Class: connectCreateCase, Method:getCaseComments */
    
     @isTest
    static void getCaseCommentsTest(){
        
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email'); 
        insert cas;
        
        
        CaseComment co = new CaseComment();
        
        co.ParentId = cas.id;
        co.CommentBody = 'Body';
       // CreatedDate = '';
        insert co;
        
        Test.startTest();
        connectCreateCase.getCaseComments(cas.Id);
        Test.stopTest();
        
    }
    
    /* Class: connectCreateCase, Method:createCaseComment */

    @isTest
    static void createCaseCommentTest(){
        
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email'); 
        insert cas;
        
       CaseComment co = new CaseComment();
        
       co.ParentId = cas.id;
       co.CommentBody = 'Body';
       //insert co;
        
        Test.startTest();
        connectCreateCase.createCaseComment(co);
        Test.stopTest();
        
    }
    
    

    
            /* Class: connectCreateCase, Method:getCaseNumber */
    
    @isTest
    Static void getCaseNumberTest(){
        Account a5= new Account(Name = 'TestAcc5' );
        
        insert a5;
       // Case s115 = new Case(Status ='New', Priority = 'Medium', Origin = 'Email'); 
        Case s115 = new Case(Status ='New', Priority = 'Medium', Origin = 'Email'); 
        insert s115;
        
        Test.startTest();
        connectCreateCase.getCaseNumber(s115.Id);
        Test.stopTest();          
    }
    
    
    
    /* Class: connectCreateCase, Method:createCaseProduct */
    
    @isTest
    Static void createCaseProductTest(){
        ccrz__E_Product__c	p = new ccrz__E_Product__c	();
        p.Name= 'test';
        Case c1 = new Case(Status ='New', Priority = 'Medium', Origin = 'Email');
        insert c1;
        List<Shipment_Detail__c> ss= new List<Shipment_Detail__c>();
        Shipment_Detail__c sd= new Shipment_Detail__c();
        sd.CreatedDate= date.today();
        sd.GE_NAS_Case_Number__c= c1.id;
        sd.Product_Number__c = p.Id;
        ss.add(sd);
        // insert ss;
       // insert ss;
        Test.startTest();
        connectCreateCase.createCaseProduct(ss);
        Test.stopTest(); 
        
    }

	 /* Class: connectCreateCase, Method:getExpOwnerId */
    
    @isTest
    static void getExpOwnerIdTest(){
       // String AccountId = '';
        
        User us = new User();
        
        Account acc = new Account();
        acc.Name = 'Acc232';
        acc.Customer_Service_Queue__c = 'CCS - Orange';
        //acc.OwnerId = us.id;
        
        insert acc;
        
        Account acc2 = new Account();
        acc2.Name = 'Distributor - Acc2322';
        acc2.Distributor_Queue__c = 'Unrivalled';
        //acc.OwnerId = us.id;
        insert acc2;

        Account acc3 = new Account();
        acc3.Name = 'Distributor - Acc2323';
        acc3.Distributor_Queue__c = null;
        //acc.OwnerId = us.id;
        insert acc3;
        
        Contact c1 = new Contact(FirstName='Jane',LastName='Doe', Accountid=acc.id);
        insert c1;
       // System.debug(acc.OwnerId);
        
        Test.startTest();
        connectCreateCase.getCSOwnerId(acc.Id, null, 'Agent');
        connectCreateCase.getCSOwnerId(acc2.Id, null, 'Distributor');
        connectCreateCase.getCSOwnerId(null, acc3.Id, 'Distributor');
        Test.stopTest();
    }
    
    	 /* Class: connectCreateCase, Method:getAccountName */

    @isTest
    static void getAccountNameTest(){
     
        String id_dtl;
        Account acc = new Account();
        acc.Name = 'Acc232';        
        insert acc;
        
        contact ca1 = new contact();
        ca1.AccountId= acc.id;
        ca1.FirstName= 'testCon';
        ca1.LastName= 'test';
        ca1.Email='abc@xyz.com';
        insert ca1;
        
        Case case1 = new Case(Status ='New', Priority = 'Medium', Origin = 'Email' );        
        case1.Spec_Reg_Agency__c = acc.Id;
        insert case1;	
        
       // acc = [Select Name from Account where Id = :id_dtl]; 
       // System.debug(acc);
        
        Test.startTest();
        connectCreateCase.getAccountName(acc.Id);
        Test.stopTest();
        
    }
        /* Class: connectCreateCase, Method:getQueueId */

    @isTest
    static void getQueueIdTest(){
        Group gp = [Select Id from Group where Name = 'DCS'];
        
        Test.startTest();
        connectCreateCase.getDCSQueueId();
        Test.stopTest();
        
    }
    
    /* Class: connectCreateCase, Method:getMarketingQueueId */
    
    @isTest
    public static void getMarketingQueueIdTest(){

        User us = new User();
        
        Account acc = new Account();
        acc.Name = 'Acc232';
        acc.Channel_Marketing_Queue__c = 'Channel Marketing Group';
        //acc.OwnerId = us.id;
        
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name = 'Acc232';
        acc1.Channel_Marketing_Queue__c = null;
        //acc.OwnerId = us.id;
        
        insert acc1;
        
        Account acc2 = new Account();
        acc2.Name = 'Acc232';
        acc2.Distributor_Queue__c = 'Unrivalled';
        //acc.OwnerId = us.id;
        
        insert acc2;
        
        Contact c1 = new Contact(FirstName='Jane',LastName='Doe', Accountid=acc.id);
        insert c1;
        
        
        Test.startTest();
        connectCreateCase.getMarketingQueueId(acc.id, 'Agent');
        connectCreateCase.getMarketingQueueId(acc.id, 'Distributor');
        Test.stopTest();
        
    }

    @isTest
    public static void getWarrantyQueueIdTest(){
        Account acc = new Account();
        acc.Name = 'Acc232';
        acc.Warranty_Queue__c = 'Current PSO Team';
        //acc.OwnerId = us.id;
        
        insert acc;

        Account acc2 = new Account();
        acc2.Name = 'Distributor - Acc2322';
        acc2.Distributor_Queue__c = 'Unrivalled';
        //acc.OwnerId = us.id;
        insert acc2;

        Account acc3 = new Account();
        acc3.Name = 'Distributor - Acc2323';
        acc3.Distributor_Queue__c = null;
        //acc.OwnerId = us.id;
        insert acc3;
        
        Contact c1 = new Contact(FirstName='Jane',LastName='Doe', Accountid=acc.id);
        insert c1;
     
        
        Test.startTest();
        connectCreateCase.getWarrantyQueueId(acc.Id, null, 'Agent');
        connectCreateCase.getWarrantyQueueId(acc2.Id, null, 'Distributor');
        connectCreateCase.getWarrantyQueueId(null, acc3.Id, 'Distributor');
        Test.stopTest();
        
    }

    @isTest
    public static void getPricingQueueIdTest(){
        Group gp = [Select Id from Group where Name = 'Pricing Queue'];
        
        Test.startTest();
        connectCreateCase.getPricingQueueId();
        Test.stopTest();
        
    }
    
        /* Class: connectCreateCase, Method:getAccountManagerName */

    @isTest
    static void getAccountManagerNameTest(){
        Account acc = new Account();
        acc.Name = 'Acc2321';
       // acc.ManagerId__c = 'Test';
        insert acc;
       // String AccountId = '0013F00000cSSkRQAW';
      //  Account acc = [Select ManagerId__c from Account where Id = :AccountId]; 
       	
        Test.startTest();
        connectCreateCase.getAccountManagerName(acc.id);
        Test.stopTest();
        
    }
   
    
    @isTest
    static void getDisputeRequestsTest(){
        
       	 Case case1 = new Case(Status ='New', Priority = 'Medium', Origin = 'Email' ); 
                Dispute_Request__c disc = new   Dispute_Request__c();
        disc.Case__c = case1.id;
        disc.Status__c = 'Open';
        insert disc;
        Test.startTest();
        connectCreateCase.getDisputeRequests(case1.id);
        Test.stopTest();
        
    }
   
     @isTest
    static void getCaseFieldsTest(){
        
       	 Case case1 = new Case(Status ='New', Priority = 'Medium', Origin = 'Email' ); 
                Dispute_Request__c disc = new   Dispute_Request__c();
        disc.Case__c = case1.id;
        disc.Status__c = 'Open';
        insert disc;
        
        String findCase = case1.id;
    
        String fields = 'Type';
        Test.startTest();
        connectCreateCase.getCaseFields(findCase,fields);
        Test.stopTest();
        
    }
     
        @isTest
    static void getQueueIdNewTest(){
         List<Group> gd3 = new List<Group>();
         List<Group> gd2 = new List<Group>();
        string type = 'Return';
         Account acc = new Account();
        acc.Name = 'AccTest1';
        acc.Returns_Queue__c = 'Current Returns';
        insert acc;
        Account acc2 = new Account();
        acc2.Name = 'Distributor - Acc2322';
        acc2.Distributor_Queue__c = 'Unrivalled';
        //acc.OwnerId = us.id;
        insert acc2;

        Account acc3 = new Account();
        acc3.Name = 'Distributor - Acc2323';
        acc3.Distributor_Queue__c = null;
        //acc.OwnerId = us.id;
        insert acc3;
       	 Group gd = new Group();
       gd.Name='Test1';
        insert gd;
        gd2.add(gd);
        
         Group gd1 = new Group();
       gd1.Name='Test2';
        insert gd1;
        
        Test.startTest();
        
        connectCreateCase.getReturnsQueueId(acc.Id, null, 'Agent');
        connectCreateCase.getReturnsQueueId(acc3.Id, acc2.Id, 'Distributor');
        connectCreateCase.getReturnsQueueId(null, acc2.Id, 'Distributor');
        connectCreateCase.getReturnsQueueId(null, acc3.Id, 'Distributor');
        connectCreateCase.getPGCSOwnerId(acc3.Id);
        connectCreateCase.getQueueIdTS('Lighting Fixtures');
        connectCreateCase.getTSQueueId('Lighting Products Info');
        Test.stopTest();
        
    }
    
     @isTest
    static void getAgentIdTest(){
     
        String id_dtl;
        Account acc = new Account();
        acc.Name = 'Acc232';
		acc.Account_Group__c='ZEAG';        
        insert acc;
        
        contact ca1 = new contact();
        ca1.AccountId= acc.id;
        ca1.FirstName= 'testCon';
        ca1.LastName= 'test';
        ca1.Email='abc@xyz.com';
        insert ca1;
        
        
        Test.startTest();
        connectCreateCase.getAgentId(acc.Id);
        Test.stopTest();
        
    }
     @isTest
    static void getAgentIdTest1(){
     
        String id_dtl;
        Account acc = new Account();
        acc.Name = 'Acc232';
		acc.Account_Group__c='TEST';        
        insert acc;
        
        contact ca1 = new contact();
        ca1.AccountId= acc.id;
        ca1.FirstName= 'testCon';
        ca1.LastName= 'test';
        ca1.Email='abc@xyz.com';
        insert ca1;
        
        
        Test.startTest();
        connectCreateCase.getAgentId(acc.Id);
        Test.stopTest();
        
    }
    @isTest
    Static void updateInvLines(){
        
        GE_LGT_EM_InvoiceLineItem__c inv = new GE_LGT_EM_InvoiceLineItem__c(GE_LGT_EM_SAP_Invoice_Number__c = '1170899542', Requested_Action_Override__c = 'Return', GE_LGT_EM_DisputeCount__c= 10 );
        Insert inv;
       
        List<GE_LGT_EM_InvoiceLineItem__c> invList = [SELECT Id from GE_LGT_EM_InvoiceLineItem__c WHERE Id =: inv.id];
        List<Id> newList = new List<Id>();
        for(GE_LGT_EM_InvoiceLineItem__c invoice : invList){
            newList.add(invoice.Id);
        }
        
        Test.startTest();
        boolean s1 = connectCreateCase.updateInvLines(newList);
        System.assertEquals(true, s1);
        Test.stopTest();
        
    }

    @isTest
    Static void updateOrdLines(){

        Account acct = [SELECT Id, Name,Account_Group__c FROM Account WHERE Name = 'Test1239'];
        acct.GE_LGT_EM_SAP_Customer_Number__c='H9M';
        acct.Account_Group__c = 'ZEAG';
		update acct;

        //GE Current trigger switches
        List<TriggerSwitch__c> switchList = new List<TriggerSwitch__c>{};
        switchList.add(TestDataUtil.createTriggerSwitch('OrderTrigger', False));
        switchList.add(TestDataUtil.createTriggerSwitch('OrderLineItemUpdate', False));
        switchList.add(TestDataUtil.createTriggerSwitch('Update_Pricebook2ids', False));
        Insert switchList;

        PriceBook2 pb = TestDataUtil.createPriceBook('testBook');
        insert pb;

        PriceBook2 pb2 = TestDataUtil.createPriceBook('LED');
        insert pb2;

        Product2 p = TestDataUtil.createProduct('testProduct');
        insert p;

        PricebookEntry pbe = TestDataUtil.createPriceBookEntry((String)pb.Id, p);
        pbe.UseStandardPrice = false;
        insert pbe;

        Order o1 = new Order(PriceBook2Id = pb.Id, Status = 'Draft', AccountId = acct.Id, Agent_Account__c = acct.Id, Sold_To__c = acct.Id, CurrencyIsoCode = 'USD', EffectiveDate = Date.today().addDays(-1));
        insert o1;
        OrderItem oi1 = new OrderItem(OrderId = o1.Id, SKU__c = 'test1', Quantity = 1, PricebookEntryId = pbe.Id, unitPrice = 10.00, Agreement_Quote__c = 'test');
        insert oi1;
        OrderItem oi2 = new OrderItem(OrderId = o1.Id, SKU__c = 'sku', Quantity = 1, PricebookEntryId = pbe.Id, unitPrice = 10.00, Agreement_Quote__c = 'test');
        insert oi2;

       
        List<OrderItem> invList = [SELECT Id from OrderItem WHERE Id =: oi1.id];
        List<Id> newList = new List<Id>();
        for(OrderItem invoice : invList){
            newList.add(invoice.Id);
        }
        
        Test.startTest();
        boolean s1 = connectCreateCase.updateOrdLines(newList);
        System.assertEquals(true, s1);
        Test.stopTest();
        
    }
    
            static testmethod void Testmethod2(){    
        FileUploadViewController.ContentType('docx');
    }
        static testmethod void Testmethod3(){   
        FileUploadViewController.ContentType('csv');
    }  
        static testmethod void Testmethod4(){     
        FileUploadViewController.ContentType('wav');
    }
static testmethod void Testmethod5(){     
        FileUploadViewController.ContentType('wmv');
    }
    static testmethod void Testmethod6(){     
        FileUploadViewController.ContentType('mp3');
    }
    static testmethod void Testmethod7(){     
        FileUploadViewController.ContentType('mp4');
    }
    static testmethod void Testmethod8(){     
        FileUploadViewController.ContentType('png');
    }
    static testmethod void Testmethod9(){     
        FileUploadViewController.ContentType('pdf');
    }
    
 	    
    
    @isTest
    Static void getOrderStatusTest()
    {
        
        
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        Pricebook2 b = new Pricebook2(Name= 'TestBook');
        insert b;
        
        Order o = new order(name = 'abc@xyz.com', EffectiveDate = date.today(), Status = 'Draft');
        o.AccountId = Acc.Id;
        o.Pricebook2Id = b.Id;
        o.GBSTK__c = 'test';
        Insert o;
                
        Test.startTest();
        connectCreateCase.getOrderStatus(o.Id);
        Test.stopTest();
        
    }
    @isTest
    Static void getOrderNumTest()
    {
        
        
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        Pricebook2 b = new Pricebook2(Name= 'TestBook');
        insert b;
        
        Order o = new order(name = 'abc@xyz.com', EffectiveDate = date.today(), Status = 'Draft');
        o.AccountId = Acc.Id;
        o.Pricebook2Id = b.Id;
        o.GE_Order_NO__c = 'test';
        o.Sold_To__c = Acc.Id;
        
        Insert o;
                
        Test.startTest();
        connectCreateCase.getOrderNum(o.Id);
        connectCreateCase.getSoldTo(o.Id);
            connectCreateCase.getSoldToNew(o.Id);
        Test.stopTest();
        
    }
   /* @isTest
    Static void getSoldToTest()
    {
        
        
        Account Acc = new Account(Name = 'TestAcc', GE_LGT_EM_SAP_Customer_Number__c = '765432');
        Insert Acc;
        
        Pricebook2 b = new Pricebook2(Name= 'TestBook');
        insert b;
        
        Order o = new order(name = 'abc@xyz.com', EffectiveDate = date.today(), Status = 'Draft');
        o.AccountId = Acc.Id;
        o.Pricebook2Id = b.Id;
        o.Sold_To__c = Acc.Id;
        Insert o;
        
		Account Acc = new Account(Name = 'TestAcc654', GE_LGT_EM_SAP_Customer_Number__c = '765437652');
        //Acc.GE_LGT_EM_SAP_Customer_Number__c
        Insert Acc;        
                
        Test.startTest();
        connectCreateCase.getSoldToTest(o.Id);
        Test.stopTest();
        
    }*/
    
    @isTest
    Static void createReturnItemsTest(){
        

        List<Return_Order_Item__c> sortedOrders1 = new List<Return_Order_Item__c>{};
        Return_Order_Item__c r1= new Return_Order_Item__c();
        r1.SKU__c= '123456';
        r1.UnitPrice__c=1000;
        r1.Quick_Configure__c= true;
        r1.Quick_Stock__c= true;
        r1.Shipment_Date__c= date.today();
        r1.Return_Qty__c= 2;
        r1.Requested_Action_Override__c= 'Return and Replace';
        r1.Transaction_ID__c = '123456';
        //insert r;   
        sortedOrders1.add(r1);
        Test.startTest();
        connectCreateCase.createReturnItems(sortedOrders1);
        Test.stopTest();
    }
    
    @testSetup static void setupTestData() {
        List<TriggerSwitch__c> switchList = TestDataUtil.insertTriggerSwitches();       
        insert switchList;

        b2bTestSetup.setupPortalUsers();
		b2bTestSetup.setupPricelist();
		User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];

        Account acct1  = new Account();
        acct1.Name = 'GE CURRENT - EXTERNAL';
        acct1.GE_LGT_EM_SAP_Customer_Number__c='GEC-EXTERNAL';
        insert acct1;
        
		Account acct  = new Account();
        acct.Name = 'Test1239';
        acct.Account_Group__c = 'ZEAG';
        insert acct;
        Contact cont = new Contact();
       cont.AccountId =acct.id;
        cont.FirstName = 'Test456';
         cont.LastName ='Test987';
        insert cont;
    
    }
    
    
}
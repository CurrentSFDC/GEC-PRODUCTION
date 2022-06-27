/*
Name - OpportunityTriggerHelper_Test
Author - Siva,Shyam
Purpose - Test Class
Date - May-2016
*/  
@isTest
public class OpportunityTriggerHelper_Test 
{
    public static Map<String,id> mapRecTypeNameID=OpportunityConstantClass.mapRecTypeNameID();
    public static list<Account> createAccounts(integer count,id recTypeId,boolean isInsert){
        List<Account> accList=new List<Account>();
        
        for(integer i=1;i<=count;i++){
            string s1=string.valueof(i);
            Account acc=TestDataUtil.createAccount();
            acc.name='Test Account'+s1;
            acc.recordtypeid=recTypeId;
            acc.Account_Group__c ='ZSTG';
            accList.add(acc);
        }
        if(isInsert) insert accList;
        return accList;
        
        
    }
    public static list<Opportunity> createOpportunities(integer count,id recTypeId,boolean isInsert,Account acc){
        List<Opportunity> oppList=new List<Opportunity>();
        
        for(integer i=1;i<=count;i++){
            string s1=string.valueof(i);
            Opportunity opp=TestDataUtil.createOpportunity(acc);
            opp.name='Test Opportunity'+s1;
            if(i>1)
                opp.GE_LGT_GE_Opportunity_Id__c='12EU34'+s1;
            opp.recordtypeid=recTypeId;
            opp.Total_value_of_Opportunity_500K__c='No';
            opp.There_is_a_resource_implication__c='No';
            opp.There_s_a_Strategic_Value_Future_Revenue__c='No';
            oppList.add(opp);
        }
        if(isInsert) insert oppList;
        return oppList;
        
        
    }
    public static list<Order > createOrders(integer count,string type,boolean isInsert,Opportunity opp,Account acc){
        List<Order> ordList=new List<Order>();
        
        for(integer i=1;i<=count;i++){
            string s1=string.valueof(i);
            Order ord=TestDataUtil.createOrder('99999');
            ord.name='Test Order'+s1;
            if(type=='Estimated PO'){
                ord.recordtypeid=Schema.SObjectType.order.getRecordTypeInfosByName().get('Estimated PO').getRecordTypeId();
                ord.SAP_Unique_Id__c='';
                ord.Strategic_SAPUniqueId__c='';
                ord.Agent_SAPUniqueId__c='';
            }
            ord.Accountid=acc.id;
            ord.Opportunityid=opp.id;
            ord.Order_Amount__c=10000;
            ordList.add(ord);
        }
        if(isInsert) insert ordList;
        return ordList;
        
        
    }
    public static list<OpportunityContactRole> createContactRole(integer count,id oppid,id conId,string role,boolean isprimary,boolean isInsert){
        List<OpportunityContactRole > conRoleList=new List<OpportunityContactRole >();
        for(integer i=1;i<=count;i++){
            OpportunityContactRole conRole=new OpportunityContactRole();
            conRole.OpportunityId=oppid;
            conRole.ContactId=conId;
            conRole.IsPrimary=isprimary;
            conRole.Role=role;
            conRoleList.add(conRole);
            
        }
        if(isInsert) insert conRoleList;
        return conRoleList;
    }
    
    public static User  createuser(Id profileId,string division,boolean isInsert){
        
        
        User u2;
        if(division=='North America'){
            u2 = TestDataUtil.createUser(profileId, 'NorthAmerica'+'@testorg.com');
            u2.UserName='NorthAmerica'+'@testorg.com';
            u2.GE_LGT_Business_Division__c='North America';u2.GE_LGT_Region__c='NA Functional';u2.GE_LGT_Sub_Region__c='NA Other';
        }
        if(division=='Europe'){
            u2 = TestDataUtil.createUser(profileId, 'Europe'+'@testorg.com');
            u2.UserName='Europe'+'@testorg.com';
            u2.GE_LGT_Business_Division__c='Europe';u2.GE_LGT_Region__c='Europe Functional';u2.GE_LGT_Sub_Region__c='Europe Operations';
        }
        if(division=='Latin America'){
            u2 = TestDataUtil.createUser(profileId, 'LatinAmerica'+'@testorg.com');
            u2.UserName='LatinAmerica'+'@testorg.com';
            u2.GE_LGT_Business_Division__c='Latin America';u2.GE_LGT_Region__c='Leadership';u2.GE_LGT_Sub_Region__c='Other';
        }
        if(division=='MEAT'){
            u2 = TestDataUtil.createUser(profileId, 'MEAT'+'@testorg.com');
            u2.UserName='MEAT'+'@testorg.com';
            u2.GE_LGT_Business_Division__c='MEAT';u2.GE_LGT_Region__c='MEAT Functional';u2.GE_LGT_Sub_Region__c='MEAT Finance';
        }
        
        if(division=='Asia'){
            u2 = TestDataUtil.createUser(profileId, 'Asia'+'@testorg.com');
            u2.UserName='Asia'+'@testorg.com';
            u2.GE_LGT_Business_Division__c='Asia';u2.GE_LGT_Region__c='China Lighting';u2.GE_LGT_Sub_Region__c='Commercial Operations';
        }
        if(isInsert)  insert u2;
        return u2;
    }
    public static OpportunityLineItem  addOptyProduct(Opportunity opp,id PriceBook2id,boolean isinsert){
        System.debug('--------------------->');
        
        GE_LGT_EM_MaterialMaster__c mat= TestDataUtil.createMaterialMaster('124567');
        insert mat;
        product2 prod=[select id from product2];
        System.Debug(LoggingLevel.ERROR, prod);
        System.debug('--------------------->'+prod);
                System.debug('--------------------->'+prod.id);
        PriceBookEntry PricebookEntryID=[select id from PricebookEntry where Pricebook2Id=:PriceBook2id AND Product2Id=:prod.id AND ISactive=true AND CurrencyIsoCode='USD' LIMIT 1];
        OpportunityLineItem lineitem=TestDataUtil.createOpportunityLineItem(opp,PricebookEntryID,2,200);
        if(isInsert) insert lineitem;
        return lineitem;
        
    }
    
    /*static testmethod void optyOrderProductValidations_Test()
    { 
        
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
        
        triggerSwitches.get('OrderTrigger').isActive__c=true;
        triggerSwitches.get('AccountTrigger').isActive__c=true;
        
        insert  triggerSwitches.values();
        
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        Profile objProfile = [Select Id, Name from Profile where Name =:'EUROPE Current Super User' limit 1];
        User u2=createuser(objProfile.id,'Europe',true);
        System.runAs(u2)
        {
            test.starttest();
            ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
            List<Account> accs=createAccounts(1,recAccTypeID,true);
            Contact cons=TestDataUtil.createContact(accs[0]);
            insert cons;
            Id recoppType_StandardID = mapRecTypeNameID.get(OpportunityConstantClass.STANDARD_ADV);
            
            List<Opportunity> opps=createOpportunities(1,recoppType_StandardID,true,accs[0]);
            List<OpportunityContactRole> conRoles=createContactRole(1,opps[0].id,cons.id,'Influencer',false,true);
            List<Order> ordList=createOrders(1,'Estimated PO',true,opps[0],accs[0]);
            opps[0].stagename='S3 Solve';
            opps[0].Project_Management_For_Ex__c='no';
            update opps[0];
            OpportunityLineItem lineitem=addOptyProduct(opps[0],ledPB.id,true);
            opps[0].stagename='S5 Close';
            update opps[0];
            test.stoptest();
            
        }
        
        
    }*/
    static testmethod void createContactRole_Test()
    { 
        
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
        
        triggerSwitches.get('OrderTrigger').isActive__c=true;
        triggerSwitches.get('AccountTrigger').isActive__c=true;
        
        insert  triggerSwitches.values();
        
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        Profile objProfile = [Select Id, Name from Profile where Name =:'EUROPE Current Super User' limit 1];
        User u2=createuser(objProfile.id,'Europe',true);
        System.runAs(u2)
        {
            test.starttest();
            ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
            List<Account> accs=createAccounts(1,recAccTypeID,true);
            
            ID recctTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Asia Service Contact').getRecordTypeId();
            Contact ct=TestDataUtil.createContact(accs[0]);
            ct.Recordtypeid=recctTypeID;
            insert ct;
            
            Id recoppType_StandardID = mapRecTypeNameID.get(OpportunityConstantClass.STANDARD_ADV);
            
            List<Opportunity> opps=createOpportunities(1,recoppType_StandardID,true,accs[0]);
            
            List<Order> ordList=createOrders(1,'Estimated PO',true,opps[0],accs[0]);
            opps[0].Project_Management_For_Ex__c='no';
            opps[0].GE_LGT_Contact__c=ct.id;
            update opps[0];
            list<OpportunityContactRole> OppRole1 = [select id from OpportunityContactRole where OpportunityID =: opps[0].id];
            system.assert(OppRole1.size()>0);
            test.stoptest();
            
        }
        
        
    }
    
    static testmethod void mapRecordTypeToOpty_Test()
    { 
        
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
        
        triggerSwitches.get('OrderTrigger').isActive__c=true;
        triggerSwitches.get('AccountTrigger').isActive__c=true;
        
        insert  triggerSwitches.values();
        
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        Profile objProfile = [Select Id, Name from Profile where Name =:'EUROPE Current Super User' limit 1];
        User u2=createuser(objProfile.id,'Europe',true);
        System.runAs(u2)
        {
            test.starttest();
            ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
            List<Account> accs=createAccounts(1,recAccTypeID,true);
            
            ID recctTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Asia Service Contact').getRecordTypeId();
            Contact ct=TestDataUtil.createContact(accs[0]);
            ct.Recordtypeid=recctTypeID;
            insert ct;
            
            Id recoppType_StandardID = mapRecTypeNameID.get(OpportunityConstantClass.STANDARD_ADV);
            
            List<Opportunity> opps=createOpportunities(3,recoppType_StandardID,false,accs[0]);
            
            opps[0].Originated_from_Lead__c=true;
            opps[1].Originated_from_Lead__c=true;
            opps[2].Originated_from_Lead__c=true;
            opps[0].GE_LGT_Oppty_Type2__c='Standard';
            opps[1].GE_LGT_Oppty_Type2__c='Intelligent City';
            //opps[2].GE_LGT_Oppty_Type2__c='Solar'; --> COMMENTED OUT BY MG: RQT-1023
            
            insert opps;
            test.stoptest();
            
        }
        
        
    }
    
    /*static testmethod void negOptyOrderProductValidations_Test()
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
        User u2=createuser(objProfile.id,'Europe',true);
        System.runAs(u2)
        {
            
            ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
            List<Account> accs=createAccounts(1,recAccTypeID,true);
            
            Contact cons=TestDataUtil.createContact(accs[0]);
            insert cons;
            Id recoppType_StandardID = mapRecTypeNameID.get(OpportunityConstantClass.STANDARD_ADV);
            
            List<Opportunity> opps=createOpportunities(1,recoppType_StandardID,true,accs[0]);
            List<OpportunityContactRole> conRoles=createContactRole(1,opps[0].id,cons.id,'Influencer',false,true);
            opps[0].stagename='S3 Solve';
            opps[0].Project_Management_For_Ex__c='no';
            try{
                update opps[0];
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('S3 Solve – Estimated PO orders  must be Entered') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
            test.starttest();
            List<Order> ordList=createOrders(5,'Estimated PO',true,opps[0],accs[0]);
            
            integer con=[select count() from order where opportunityid=: opps[0].id ];
            system.assert(con > 0);
            opps[0].stagename='S3 Solve';
            opps[0].Project_Management_For_Ex__c='no';
            update opps[0];
            OpportunityLineItem lineitem=addOptyProduct(opps[0],ledPB.id,false);
            lineitem.SKU_Number__c=null;
            lineitem.Description=null;
            insert lineitem;
            opps[0].stagename='PO Received';
            try{
                update opps[0];
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('PO Received – Opportunity must have an SAP Order linked to it') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
            List<Order> sapordList=createOrders(5,'Received PO',true,opps[0],accs[0]);
            
            system.assert([select count() from order where opportunityid=: opps[0].id ] > 0);
            opps[0].stagename='PO Received';
            try{
                update opps[0];
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('PO Received – Cat Logic OR Product Code/SKU/Material # must be Entered') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
            
            test.stoptest();
        }
    }*/
    //************RQT-291*****************//
    static testmethod void ValidationTestClosedlostopp()  
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
        triggerSwitches.get('OrderTrigger').isActive__c=true;
        triggerSwitches.get('AccountTrigger').isActive__c=true;
        insert  triggerSwitches.values();
        
       
        Channel_Partner_Acct__c channelpartner2 =new Channel_Partner_Acct__c();
        channelpartner2.name='TRANE';
        channelpartner2.Cust_Partner_Acct__c='0013100001eDeOgAAK';
        insert channelpartner2;    
        
        ID  recOppTypeID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID  recAccTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        //Account insertion
        Test.startTest();
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAccTypeId;
        insert acc;
        //custom setting to create data for RQT-0000977
        Channel_Partner_Acct__c channelpartner =new Channel_Partner_Acct__c();
        channelpartner.name='CBRE';
        channelpartner.Cust_Partner_Acct__c=acc.id;
        insert channelpartner;
        
        // INSERT OPPTY RECORD
        Opportunity opp = TestDataUtil.createOpportunity(acc);
        opp.RecordTypeId=recOppTypeID;
        opp.GE_LGT_Reason_Won_Lost__c=System.Label.Customer_Cancelled;
        opp.GE_LGT_Reason_Won_Lost_Details__c='Testing';
        opp.Other_Partner_Type__c='CBRE';
        
        insert opp;
        GE_LGT_EM_MaterialMaster__c matrial=TestDataUtil.createMaterialMaster('99999');
        insert matrial;
        List<Order> ordList=createOrders(1,'Estimated PO',true,opp,acc);
        ordList[0].PO_Received__c=true;
        update ordList[0];
        
        try{
            if(ordList.size()>0)
            {
                opp.stagename='Closed Lost';
                opp.Other_Partner_Type__c='TRANE';
                update opp;
            }             
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Cannot mark an opportunity to Closed Lost when orders have been received') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }
    
    /**************RQT_285******************/
    static testMethod void Validation_OpportunityPO_Closedlost()
    {
        
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        triggerSwitches.get('AccountTrigger').isActive__c=False;
        insert triggerSwitches.values();
        
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        
        ID userID = UserInfo.getUserID(); 
        Id recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='EUROPE Current Sales']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@ge.com.satishdev',
                          GE_LGT_Business_Division__c='EMEA Service' );
        try{
            
            System.runAs ( u ) { 
                // INSERT ACCOUNT RECORD
                Account acc=TestDataUtil.createAccount();
                acc.RecordTypeId = recAccTypeID;
                insert acc;
                
                //Insert contact
                Contact c = new Contact();
                c.FirstName = 'satish';
                c.LastName  = 'Test';
                c.AccountId = acc.id;
                c.MailingStreet = '298 S. Ringo Street';
                c.MailingCity = 'Little Rock';
                c.MailingState = 'AR';
                c.MailingPostalCode = '72201'; 
                
                insert c;
                System.debug('created primary contact');
                
                // INSERT OPPTY RECORD
                Opportunity opp = TestDataUtil.createOpportunity(acc); 
                opp.RecordTypeId = recOppTypeId;
                opp.Name = 'Testoppty';
                opp.StageName = 'S1 Consult';
                opp.Type='End User - Retrofit';
                opp.AccountID = acc.id;
                opp.CurrencyIsoCode ='HUF';
                opp.Probability = 10;
                opp.CloseDate = Date.Today().addDays(5);
                opp.PO_Receipt_Date__c = Date.Today().addDays(5);
                opp.GE_LGT_SIMPLESALES__c='Yes';
                opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
                opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
                opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
                opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1'; 
                
                insert opp;
                system.assertEquals('Testoppty', opp.Name);
                system.assertEquals('S1 Consult', opp.StageName);
                system.assertEquals(Date.Today().addDays(5), opp.PO_Receipt_Date__c);
                
                //Now update the OCR for the primary contact
                OpportunityContactRole ocr = new OpportunityContactRole();
                ocr.ContactId = c.Id;
                ocr.OpportunityId = opp.Id;
                ocr.IsPrimary = TRUE;
                ocr.Role = 'Decision Maker';
                insert ocr;
                System.debug('created opportunity contact role for primary');
                // Create a new product 
                Product2 product = TestDataUtil.createProduct('TestProd1');
                product.name = 'TestProd1';
                product.GE_LGT_Product_Line__c='INDOOR FIXTURE - LED';
                product.GE_LGT_Product_Group__c='ALBEO LINEAR';
                product.CurrencyIsoCode='USD';
                product.Product_Hierarchy_Code__c='testproduct345';
                product.CanUseQuantitySchedule =true;
                product.CanUseRevenueSchedule=true;
                product.ProductCode ='testproduct1';
                product.Product_Hierarchy_Code__c='testproduct12';
                product.Level_1__c = 'AUT - AUTOMOTIVE';
                product.Level_2__c='AUT100 - HALOGEN COMPOSITE HEADLAMPS';
                product.isactive=true;
                insert product; 
                
                ID pbet_id = [SELECT Id FROM PricebookEntry WHERE CurrencyIsoCode =:opp.CurrencyISOCode AND Product2Id =:product.id AND Pricebook2.name='LED' and isactive= true LIMIT 1].ID;
                
                Test.startTest(); 
                List<OpportunityLineItem> oppLineItems=new List<OpportunityLineItem>();
                OpportunityLineItem lineItem1 = new OpportunityLineItem();
                lineItem1.ServiceDate = opp.closedate + 50;
                lineItem1.UnitPrice=200;
                lineItem1.Quantity=3;
                lineItem1.Description='Test33';
                lineItem1.Pricebookentryid=pbet_id;
                lineItem1.OpportunityId=opp.Id;
                lineItem1.ServiceDate= opp.closedate + 30;
                oppLineItems.add(lineItem1);
                
                OpportunityLineItem lineItem2 = new OpportunityLineItem();
                lineItem2.UnitPrice=200;
                lineItem2.Quantity=6;
                lineItem2.Description='Test33';
                lineItem2.OpportunityId=opp.Id;
                lineItem2.ServiceDate= opp.closedate + 30;
                lineItem2.Pricebookentryid=pbet_id;
                oppLineItems.add(lineItem2);
                insert oppLineItems;
                
                GE_LGT_EM_MaterialMaster__c Mn = TestDataUtil.createMaterialMaster('TEST123');
                Mn.GE_LGT_EM_SAP_MaterialNumber__c ='93022645';
                Mn.GE_LGT_EM_MaterialDescription__c= 'ABV101V571GV41BNW';
                Mn.GE_LGT_EM_ProductHierarchy__c='h012345678910123';
                Mn.Level_1__c='test00-test22-1'; 
                Mn.Level_2__c='test00012-test22-2';
                Mn.Level_3__c='test000222-test22-3'; 
                Mn.Level_4__c='test000023311-test22-4';
                Mn.Is_Active_Internal__c=true;
                insert Mn;
                
                opp.StageName = 'Closed Lost';//PO Received  Closed Lost
                update opp;
                Opportunity stagevalu =[select StageName from opportunity where Id=:opp.Id];
                System.assertEquals('Closed Lost', stagevalu.StageName);
                
                
                
                
                opp.Name = 'Testoppty123';
                update opp;
                
            }
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('User can not edit the record when Opportunity Stage is PO Received/Closed Lost') ? TRUE : FALSE;
            
            System.AssertEquals(expectedExceptionThrown, True);
            
        } 
        
        Test.stoptest();
    }
    
    
    
    /*static testmethod void generateOptyIdentifier_Test()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
        
        triggerSwitches.get('OrderTrigger').isActive__c=true;
        triggerSwitches.get('AccountTrigger').isActive__c=true;
        
        insert  triggerSwitches.values();
        Map<string,id> mapProfile = new Map<string,id>();
        for(Profile pro:[Select Id, Name from Profile]){
            mapProfile.put(pro.name,pro.id);
        }
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        Id recoppType_StandardID = mapRecTypeNameID.get(OpportunityConstantClass.STANDARD_ADV);
        
        User euUser=createuser(mapProfile.get('EUROPE Current Super User'),'Europe',true);
        
        User latamUser=createuser(mapProfile.get('LATAM Current Super User'),'Latin America',true);
        
        System.runAs(euUser)
        {
            List<Account> euaccs=createAccounts(1,recAccTypeID,true);
            List<Opportunity> euopps=createOpportunities(5,recoppType_StandardID,true,euaccs[0]);
        }
        System.runAs(latamUser)
        {
            List<Account> latamaccs=createAccounts(1,recAccTypeID,true);
            List<Opportunity> latamopps=createOpportunities(5,recoppType_StandardID,true,latamaccs[0]);
        }
        list<Opportunity> testOpps=[select id,Owner_Pole_Opp__c,GE_LGT_GE_Opportunity_Id__c from Opportunity];
        system.assert(testOpps.size()>0);
        for(Opportunity opp:testOpps){
            if(opp.Owner_Pole_Opp__c=='Europe')
                system.assert(opp.GE_LGT_GE_Opportunity_Id__c.startsWith('EU'));
            if(opp.Owner_Pole_Opp__c=='Latin America')
                system.assert(opp.GE_LGT_GE_Opportunity_Id__c.startsWith('LA'));
            
        }
        
    }*/
    
    static testmethod void preventStageAdvancement_test()
    {
        
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
        
        triggerSwitches.get('OrderTrigger').isActive__c=true;
        triggerSwitches.get('AccountTrigger').isActive__c=true;
        
        insert  triggerSwitches.values();
        
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        Profile objProfile = [Select Id, Name from Profile where Name =:'EUROPE Current Super User' limit 1];
        User u2=createuser(objProfile.id,'Europe',true);
        System.runAs(u2)
        {
            test.starttest();
            ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
            List<Account> accs=createAccounts(1,recAccTypeID,true);
            
            Id recoppType_StandardID = mapRecTypeNameID.get(OpportunityConstantClass.STANDARD_ADV);
            
            List<Opportunity> opps=createOpportunities(1,recoppType_StandardID,true,accs[0]);
            
            List<Order> ordList=createOrders(1,'Estimated PO',true,opps[0],accs[0]);
            opps[0].stagename='S3 Solve';
            opps[0].Project_Management_For_Ex__c='no';
            try{
                update opps[0];
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('You will need to add a contact') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
            
            Test.stopTest();
        }
    }
    ///RQT-0000933//
    static testmethod void ValidateClonedOppType()  
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
        
        triggerSwitches.get('AccountTrigger').isActive__c=true;
        insert  triggerSwitches.values();
        
        ID DaintreeRecId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Daintree').getRecordTypeId();
        ID StandardRecID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeID();
        ID IntEnvmtRecID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Intelligent Environments').getRecordTypeID();
        ID DaintAdvRecID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('DaintreeAdvance').getRecordTypeId();
        ID StandAdvRecID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('StandardAdvance').getRecordTypeId();
        ID IEAdvnceRecID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IntelligentEnvironmentAdvance').getRecordTypeId();
        //ID SolarEquRecID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Solar Equipment').getRecordTypeId(); --> COMMENTED OUT BY MG: RQT-1023
        //ID SolarEqAdRecID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SolarEquipmentAdvance').getRecordTypeId(); --> COMMENTED OUT BY MG: RQT-1023
        ID  recAccTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();    
        //Account insertion
        Test.startTest();
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAccTypeId;
        insert acc;
        // INSERT OPPTY RECORD
        Opportunity opp = TestDataUtil.createOpportunity(acc);
        opp.RecordTypeId=DaintreeRecId;
        insert opp;
        Opportunity cloneopp=opp.clone(false, false, false, false); 
        cloneopp.GE_LGT_Opportunity_ID__c=opp.Id;
        insert cloneopp ;
        
        cloneopp.Is_Cloned__c=true;
        update cloneopp;
        // System.assertEquals(cloneopp.Type, 'Daintree');
        
        cloneopp.RecordTypeId=StandardRecID;
        update cloneopp;
        //System.assertEquals(cloneopp.Type, 'Standard');
        
        cloneopp.RecordTypeId=IntEnvmtRecID;
        update cloneopp;
        //System.assertEquals(cloneopp.Type, 'Intelligent Environments');
        
        //cloneopp.RecordTypeId=SolarEqAdRecID; --> COMMENTED OUT BY MG: RQT-1023
        //update cloneopp; --> COMMENTED OUT BY MG: RQT-1023
        //System.assertEquals(cloneopp.Type, 'Solar');
        
        
    }
    /*
* Author : Shyam Prasad Nayakula
* Date : June - 2017
* Test method for cloneOppContactRoles() method
*/
    /*static testMethod void testCloneOppContactRoles()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        insert triggerSwitches.values();
        
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='1230011644-2FR1-20-10-Z8';
        acc.RecordTypeId=recAccTypeID;
        insert acc;
        
        Contact contVar = TestDataUtil.createContact(acc);
        insert contVar;
        
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        insert opp;
        
        Test.startTest();
        OpportunityContactRole roleVar = new OpportunityContactRole();
        roleVar.OpportunityId=opp.ID;
        roleVar.ContactId=contVar.ID;
        roleVar.Role='Agent';
        insert roleVar;
        
        System.debug('TEST CLASS::'+opp.GE_LGT_Opportunity_ID__c);
        Opportunity opp1 = [SELECT GE_LGT_Opportunity_ID__c FROM Opportunity WHERE ID=:opp.ID];
        System.debug('TEST CLASS1::'+opp1.GE_LGT_Opportunity_ID__c);
        Opportunity clonedOpp = opp.Clone(FALSE,FALSE);
        clonedOpp.GE_LGT_Opportunity_ID__c=opp1.GE_LGT_Opportunity_ID__c;
        insert clonedOpp;
        
        OpportunityContactRole roleVar1 = new OpportunityContactRole();
        roleVar1.OpportunityId=clonedOpp.ID;
        roleVar1.ContactId=contVar.ID;
        roleVar1.Role='Agent';
        insert roleVar1;
        
        List<OpportunityContactRole> contRoles = [SELECT ID,ContactID,OpportunityID,Role,IsPrimary FROM OpportunityContactRole
                                                  WHERE OpportunityID=:clonedOpp.ID];
        System.assertEquals(1, contRoles.size());
        Test.stopTest();
    }*/
    
    
    static testmethod void ISVProductivitySegmentforIEvalidationSell()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        insert triggerSwitches.values();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        ID recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IntelligentEnvironmentAdvance').getRecordTypeId();
        ID recAccAllianceTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Alliance Partner').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='123001164445-2FR1-20-10-Z8';
        acc.RecordTypeId=recAccTypeID;
        insert acc;
        
        Account acct=TestDataUtil.createAccount(); 
        acct.Alliance_Partner_Type_Primary__c ='Independent Software Vendor';
        acct.Recordtypeid=recAccAllianceTypeID;
        insert acct;
        
        Contact contVar = TestDataUtil.createContact(acc);
        insert contVar;
        
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testoppty';
        opp.StageName = 'S1 Consult';
        opp.Sell_Through__c='Yes';
        opp.Sell_With__c='Yes';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='USD';
        opp.Probability = 10;
        opp.Intelligent_Environments_Segment__c='ISV Productivity Segment';
        opp.CloseDate = Date.Today().addDays(5);
        opp.PO_Receipt_Date__c = Date.Today().addDays(5);
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';   
        opp.ISV_Partner_Notified_of_Opportunity__c='';
        insert Opp;
        try {
            opp.Intelligent_Environments_Segment__c = 'ISV Productivity Segment';
            opp.Sell_Through__c ='No';
            opp.Sell_With__c = 'No';
            opp.StageName = 'S2 Negotiate';
            update opp;
        } catch (exception e) {
            system.assertEquals(e.getMessage().contains('At least one of the two picklist fields (Sell Through and Sell With)'), false );
        }
    }
    static testmethod void ISVProductivitySegmentforIEvalidationISVPartner()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        insert triggerSwitches.values();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        ID recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IntelligentEnvironmentAdvance').getRecordTypeId();
        ID recAccAllianceTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Alliance Partner').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='123001164445-2FR1-20-10-Z8';
        acc.RecordTypeId=recAccTypeID;
        insert acc;
        
        Account acct=TestDataUtil.createAccount(); 
        acct.Alliance_Partner_Type_Primary__c ='Independent Software Vendor';
        acct.Recordtypeid=recAccAllianceTypeID;
        insert acct;
        
        Contact contVar = TestDataUtil.createContact(acc);
        insert contVar;
        
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testoppty';
        opp.StageName = 'S1 Consult';
        opp.Sell_Through__c='Yes';
        opp.Sell_With__c='Yes';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='USD';
        opp.Probability = 10;
        opp.Intelligent_Environments_Segment__c='ISV Productivity Segment';
        opp.CloseDate = Date.Today().addDays(5);
        opp.PO_Receipt_Date__c = Date.Today().addDays(5);
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';   
        insert Opp;
        try {
            opp.Intelligent_Environments_Segment__c = 'ISV Productivity Segment';
            opp.Sell_Through__c ='Yes';
            opp.Sell_With__c = 'No';
            opp.StageName = 'S2 Negotiate';
            
            update opp;
        } catch (exception e) {
            system.assertEquals(e.getMessage().contains('ISV Partner Notified of Opportunity?  is mandatory for stages S2'), true );
        }
    }
    static testmethod void ISVProductivitySegmentforIEvalidationISVPartnerNotified()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        insert triggerSwitches.values();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        ID recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IntelligentEnvironmentAdvance').getRecordTypeId();
        ID recAccAllianceTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Alliance Partner').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='123001164445-2FR1-20-10-Z8';
        acc.RecordTypeId=recAccTypeID;
        insert acc;
        
        Account acct=TestDataUtil.createAccount(); 
        acct.Alliance_Partner_Type_Primary__c ='Independent Software Vendor';
        acct.Recordtypeid=recAccAllianceTypeID;
        insert acct;
        
        Contact contVar = TestDataUtil.createContact(acc);
        insert contVar;
        
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testoppty';
        opp.StageName = 'S1 Consult';
        opp.Sell_Through__c='Yes';
        opp.Sell_With__c='Yes';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='USD';
        opp.Probability = 10;
        opp.Intelligent_Environments_Segment__c='ISV Productivity Segment';
        opp.CloseDate = Date.Today().addDays(5);
        opp.PO_Receipt_Date__c = Date.Today().addDays(5);
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';   
        insert Opp;
        try {
            opp.Intelligent_Environments_Segment__c = 'ISV Productivity Segment';
            opp.Sell_Through__c ='Yes';
            opp.Sell_With__c = 'No';
            opp.StageName = 'S2 Negotiate';
            opp.ISV_Partner_Notified_of_Opportunity__c = 'Yes';
            update opp;
        } catch (exception e) {
            system.assertEquals(e.getMessage().contains('If “Yes” is selected in the “ISV Partner Notified of Opportunity?” field, then "ISV Partner Notified Date"'), true );
        }
    }
    static testmethod void ISVProductivitySegmentforIEvalidationHeldFirstMeeting()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        insert triggerSwitches.values();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        ID recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IntelligentEnvironmentAdvance').getRecordTypeId();
        ID recAccAllianceTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Alliance Partner').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='123001164445-2FR1-20-10-Z8';
        acc.RecordTypeId=recAccTypeID;
        insert acc;
        
        Account acct=TestDataUtil.createAccount(); 
        acct.Alliance_Partner_Type_Primary__c ='Independent Software Vendor';
        acct.Recordtypeid=recAccAllianceTypeID;
        insert acct;
        
        Contact contVar = TestDataUtil.createContact(acc);
        insert contVar;
        
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testoppty';
        opp.StageName = 'S1 Consult';
        opp.Sell_Through__c='Yes';
        opp.Sell_With__c='Yes';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='USD';
        opp.Probability = 10;
        opp.Intelligent_Environments_Segment__c='ISV Productivity Segment';
        opp.CloseDate = Date.Today().addDays(5);
        opp.PO_Receipt_Date__c = Date.Today().addDays(5);
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';   
        insert Opp;
        try {
            opp.Intelligent_Environments_Segment__c = 'ISV Productivity Segment';
            opp.Sell_Through__c ='Yes';
            opp.Sell_With__c = 'No';
            opp.StageName = 'S3 Solve';
            opp.ISV_Partner_Notified_of_Opportunity__c = 'Yes';
            opp.ISV_Partner_Notified_Date__c = date.parse('3/10/2020');
            update opp;
        } catch (exception e) {
            system.assertEquals(e.getMessage().contains('Held First Meeting  is mandatory for stages S3 and above'), true );
        }
    }
    static testmethod void ISVProductivitySegmentforIEvalidationISVCommision()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        insert triggerSwitches.values();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        ID recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IntelligentEnvironmentAdvance').getRecordTypeId();
        ID recAccAllianceTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Alliance Partner').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='123001164445-2FR1-20-10-Z8';
        acc.RecordTypeId=recAccTypeID;
        insert acc;
        
        Account acct=TestDataUtil.createAccount(); 
        acct.Alliance_Partner_Type_Primary__c ='Independent Software Vendor';
        acct.Recordtypeid=recAccAllianceTypeID;
        insert acct;
        
        Contact contVar = TestDataUtil.createContact(acc);
        insert contVar;
        
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testoppty';
        opp.StageName = 'S1 Consult';
        opp.Sell_Through__c='Yes';
        opp.Sell_With__c='Yes';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='USD';
        opp.Probability = 10;
        opp.Intelligent_Environments_Segment__c='ISV Productivity Segment';
        opp.CloseDate = Date.Today().addDays(5);
        opp.PO_Receipt_Date__c = Date.Today().addDays(5);
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';   
        insert Opp;
        try {
            opp.Intelligent_Environments_Segment__c = 'ISV Productivity Segment';
            opp.Sell_Through__c ='Yes';
            opp.Sell_With__c = 'No';
            opp.StageName = 'S3 Solve';
            opp.ISV_Partner_Notified_of_Opportunity__c = 'Yes';
            opp.ISV_Partner_Notified_Date__c = date.parse('3/10/2020');
            opp.Held_First_Meeting__c= 'Yes';
            update opp;
        } catch (exception e) {
            system.assertEquals(e.getMessage().contains('ISV Commission Rate  is mandatory for stages S3 and above'), true );
        }
    }
    static testmethod void ISVProductivitySegmentforIEvalidationOthers()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        insert triggerSwitches.values();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        ID recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IntelligentEnvironmentAdvance').getRecordTypeId();
        ID recAccAllianceTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Alliance Partner').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='123001164445-2FR1-20-10-Z8';
        acc.RecordTypeId=recAccTypeID;
        insert acc;
        
        Account acct=TestDataUtil.createAccount(); 
        acct.Alliance_Partner_Type_Primary__c ='Independent Software Vendor';
        acct.Recordtypeid=recAccAllianceTypeID;
        insert acct;
        
        Contact contVar = TestDataUtil.createContact(acc);
        insert contVar;
        
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testoppty';
        opp.StageName = 'S1 Consult';
        opp.Sell_Through__c='Yes';
        opp.Sell_With__c='Yes';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='USD';
        opp.Probability = 10;
        opp.Intelligent_Environments_Segment__c='ISV Productivity Segment';
        opp.CloseDate = Date.Today().addDays(5);
        opp.PO_Receipt_Date__c = Date.Today().addDays(5);
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';   
        insert Opp;
        try {
            opp.Intelligent_Environments_Segment__c = 'ISV Productivity Segment';
            opp.Sell_Through__c ='Yes';
            opp.Sell_With__c = 'No';
            opp.StageName = 'S3 Solve';
            opp.ISV_Partner_Notified_of_Opportunity__c = 'Yes';
            opp.ISV_Partner_Notified_Date__c = date.parse('3/10/2020');
            opp.Held_First_Meeting__c= 'Yes';
            opp.ISV_Commission_Rate__c = 'Other %';
            update opp;
        } catch (exception e) {
            system.assertEquals(e.getMessage().contains('Other %  is required'), true );
        }
    }
    static testmethod void ISVProductivitySegmentforIEvalidationHeldJointMeeting()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        insert triggerSwitches.values();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        ID recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IntelligentEnvironmentAdvance').getRecordTypeId();
        ID recAccAllianceTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Alliance Partner').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='123001164445-2FR1-20-10-Z8';
        acc.RecordTypeId=recAccTypeID;
        insert acc;
        
        Account acct=TestDataUtil.createAccount(); 
        acct.Alliance_Partner_Type_Primary__c ='Independent Software Vendor';
        acct.Recordtypeid=recAccAllianceTypeID;
        insert acct;
        
        Contact contVar = TestDataUtil.createContact(acc);
        insert contVar;
        
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testoppty';
        opp.StageName = 'S1 Consult';
        opp.Sell_Through__c='Yes';
        opp.Sell_With__c='Yes';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='USD';
        opp.Probability = 10;
        opp.Intelligent_Environments_Segment__c='ISV Productivity Segment';
        opp.CloseDate = Date.Today().addDays(5);
        opp.PO_Receipt_Date__c = Date.Today().addDays(5);
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';   
        insert Opp;
        try {
            opp.Intelligent_Environments_Segment__c = 'ISV Productivity Segment';
            opp.Sell_Through__c ='Yes';
            opp.Sell_With__c = 'No';
            opp.StageName = 'S3 Solve';
            opp.ISV_Partner_Notified_of_Opportunity__c = 'Yes';
            opp.ISV_Partner_Notified_Date__c = date.parse('3/10/2020');
            opp.Held_First_Meeting__c= 'Yes';
            opp.ISV_Commission_Rate__c = 'Other %';
            opp.Held_First_Meeting__c = 'Yes';
            opp.OtherIE__c = 20;
            update opp;
        } catch (exception e) {
            system.assertEquals(e.getMessage().contains('If Yes is selected in the “Held First Meeting” field, then "Held joint First Meeting date" field will be mandatory for stages S3 and above'), True );
        }
    }
    static testmethod void ISVProductivitySegmentforIEvalidationPartnerPricing()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        insert triggerSwitches.values();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        ID recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IntelligentEnvironmentAdvance').getRecordTypeId();
        ID recAccAllianceTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Alliance Partner').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='123001164445-2FR1-20-10-Z8';
        acc.RecordTypeId=recAccTypeID;
        insert acc;
        
        Account acct=TestDataUtil.createAccount(); 
        acct.Alliance_Partner_Type_Primary__c ='Independent Software Vendor';
        acct.Recordtypeid=recAccAllianceTypeID;
        insert acct;
        
        Contact contVar = TestDataUtil.createContact(acc);
        insert contVar;
        
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testoppty';
        opp.StageName = 'S1 Consult';
        opp.Sell_Through__c='Yes';
        opp.Sell_With__c='Yes';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='USD';
        opp.Probability = 10;
        opp.Intelligent_Environments_Segment__c='ISV Productivity Segment';
        opp.CloseDate = Date.Today().addDays(5);
        opp.PO_Receipt_Date__c = Date.Today().addDays(5);
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';   
        insert Opp;
        try {
            opp.Intelligent_Environments_Segment__c = 'ISV Productivity Segment';
            opp.Sell_Through__c ='Yes';
            opp.Sell_With__c = 'No';
            opp.StageName = 'S4 Negotiate';
            opp.ISV_Partner_Notified_of_Opportunity__c = 'Yes';
            opp.ISV_Partner_Notified_Date__c = date.parse('3/10/2020');
            opp.Held_First_Meeting__c= 'Yes';
            opp.ISV_Commission_Rate__c = 'Other %';
            opp.Held_First_Meeting__c = 'Yes';
            opp.Held_joint_First_Meeting_date__c = date.parse('3/10/2020');
            opp.OtherIE__c = 20;
            opp.Partner_Pricing_Submitted_to_Customer__c= 'No';
            update opp;
        } catch (exception e) {
            system.assertEquals(e.getMessage().contains('Partner Pricing Submitted to Customer” is required for stages S4 and above'), true );
        }
    }
    static testmethod void ISVProductivitySegmentforIEvalidationQuotePricing()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        insert triggerSwitches.values();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        ID recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IntelligentEnvironmentAdvance').getRecordTypeId();
        ID recAccAllianceTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Alliance Partner').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='123001164445-2FR1-20-10-Z8';
        acc.RecordTypeId=recAccTypeID;
        insert acc;
        
        Account acct=TestDataUtil.createAccount(); 
        acct.Alliance_Partner_Type_Primary__c ='Independent Software Vendor';
        acct.Recordtypeid=recAccAllianceTypeID;
        insert acct;
        
        Contact contVar = TestDataUtil.createContact(acc);
        insert contVar;
        
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testoppty';
        opp.StageName = 'S1 Consult';
        opp.Sell_Through__c='Yes';
        opp.Sell_With__c='Yes';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='USD';
        opp.Probability = 10;
        opp.Intelligent_Environments_Segment__c='ISV Productivity Segment';
        opp.CloseDate = Date.Today().addDays(5);
        opp.PO_Receipt_Date__c = Date.Today().addDays(5);
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';   
        insert Opp;
        try {
            opp.Intelligent_Environments_Segment__c = 'ISV Productivity Segment';
            opp.Sell_Through__c ='Yes';
            opp.Sell_With__c = 'No';
            opp.StageName = 'S4 Negotiate';
            opp.ISV_Partner_Notified_of_Opportunity__c = 'Yes';
            opp.ISV_Partner_Notified_Date__c = date.parse('3/10/2020');
            opp.Held_First_Meeting__c= 'Yes';
            opp.ISV_Commission_Rate__c = 'Other %';
            opp.Held_First_Meeting__c = 'Yes';
            opp.Held_joint_First_Meeting_date__c = date.parse('3/10/2020');
            opp.OtherIE__c = 20;
            opp.Partner_Pricing_Submitted_to_Customer__c= 'Yes';
            
            update opp;
        } catch (exception e) {
            system.assertEquals(e.getMessage().contains('"Quote/Pricing Submitted date"  is required for stages S4 and above'), true );
        }
    }
    static testmethod void ISVProductivitySegmentforIEvalidationOkp()
    {
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        insert triggerSwitches.values();
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        ID recOppTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IntelligentEnvironmentAdvance').getRecordTypeId();
        ID recAccAllianceTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Alliance Partner').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='123001164445-2FR1-20-10-Z8';
        acc.RecordTypeId=recAccTypeID;
        insert acc;
        
        Account acct=TestDataUtil.createAccount(); 
        acct.Alliance_Partner_Type_Primary__c ='Independent Software Vendor';
        acct.Recordtypeid=recAccAllianceTypeID;
        insert acct;
        
        Contact contVar = TestDataUtil.createContact(acc);
        insert contVar;
        
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testoppty';
        opp.StageName = 'S1 Consult';
        opp.Sell_Through__c='Yes';
        opp.Sell_With__c='Yes';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='USD';
        opp.Probability = 10;
        opp.Intelligent_Environments_Segment__c='ISV Productivity Segment';
        opp.CloseDate = Date.Today().addDays(5);
        opp.PO_Receipt_Date__c = Date.Today().addDays(5);
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';   
        insert Opp;
        try {
            opp.Intelligent_Environments_Segment__c = 'ISV Productivity Segment';
            opp.Sell_Through__c ='Yes';
            opp.Sell_With__c = 'No';
            opp.StageName = 'S4 Negotiate';
            opp.ISV_Partner_Notified_of_Opportunity__c = 'Yes';
            opp.ISV_Partner_Notified_Date__c = date.parse('3/10/2020');
            opp.Held_First_Meeting__c= 'Yes';
            opp.ISV_Commission_Rate__c = 'Other %';
            opp.Held_First_Meeting__c = 'Yes';
            opp.Held_joint_First_Meeting_date__c = date.parse('3/10/2020');
            opp.OtherIE__c = 20;
            opp.Partner_Pricing_Submitted_to_Customer__c= 'Yes';
            opp.Quote_Pricing_Submitted_date__c = date.parse('3/10/2020');
            update opp;
        } catch (exception e) {
            system.assertEquals(e.getMessage().contains('Opportunity key players are required for stages S2 and above'), false );
        }
    }
    static testmethod void validateAllianceISVPartnerAccountName()
    {   
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('OpportunityTrigger').isActive__c=true;
        insert triggerSwitches.values();
        
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Alliance Partner').getRecordTypeId();
        ID recAccEndUserTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        
        Account acc=TestDataUtil.createAccount();
        acc.Name='Alliance account';
        acc.RecordTypeId=recAccTypeID;
        acc.Alliance_Partner_Type_Primary__c ='Independent Software Vendor';
        insert acc;
        
        Account accE=TestDataUtil.createAccount();
        accE.Name='Test account';
        accE.RecordTypeId=recAccEndUserTypeID;
        insert accE;
        
        ID recOPPTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IntelligentEnvironmentAdvance').getRecordTypeId();
        Opportunity opp = TestDataUtil.createOpportunity(accE); 
        opp.RecordTypeId = recOppTypeId;
        opp.Name = 'Testoppty';
        opp.StageName = 'S1 Consult';
        opp.Type='End User - Retrofit';
        opp.AccountID = accE.id;
        opp.CurrencyIsoCode ='HUF';
        opp.Probability = 10;
        opp.Intelligent_Environments_Segment__c='ISV Productivity Segment';
        opp.CloseDate = Date.Today().addDays(5);
        opp.PO_Receipt_Date__c = Date.Today().addDays(5);
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';  
        insert opp;
        
        CDT_Opportunity_Key_Player__c okpVar = new CDT_Opportunity_Key_Player__c();
        okpVar.Account__c=acc.id;
        okpVar.CDT_Opportunity_Name__c=opp.id;
        
        Test.startTest();
        
        insert okpVar;
        
        opportunity Parent = [select id ,Alliance_ISV_Partner_Account_Name__c, Intelligent_Environments_Segment__c, RecordTypeId from Opportunity where id=:okpVar.CDT_Opportunity_Name__c];
        Account parentAccount = [Select id, Name, Alliance_Partner_Type_Primary__c from Account where Id=:okpVar.Account__c];
        
        system.assertEquals(Parent.Alliance_ISV_Partner_Account_Name__c, 'Alliance account');
        system.assertEquals(Parent.Intelligent_Environments_Segment__c, 'ISV Productivity Segment');
        system.assertEquals(Parent.RecordTypeId, recOPPTypeID);
        system.assertEquals(parentAccount.Alliance_Partner_Type_Primary__c, 'Independent Software Vendor');
        
        Test.stopTest();
    }
}
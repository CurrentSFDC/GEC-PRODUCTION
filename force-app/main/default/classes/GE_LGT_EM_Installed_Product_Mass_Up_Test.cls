@isTest
private class GE_LGT_EM_Installed_Product_Mass_Up_Test 
{
    static testMethod void testInstalledProducts()
    {
        ID userID = UserInfo.getUserID();
        ID recopTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('StandardAdvance').getRecordTypeId();
        ID recacTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        ID recibTypeID = Schema.SObjectType.Install_Base__c.getRecordTypeInfosByName().get('Integrated').getRecordTypeId(); 
        ID reccTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('EMEA Service Contact').getRecordTypeId();
        ID estimatedOrderRecTypeID=Schema.SObjectType.Order.getRecordTypeInfosByName().get('Estimated PO').getRecordTypeId();
        
         //Custom settings Test data creation          
        TriggerSwitch__c OSRtriggerSwitch=TestDataUtil.createTriggerSwitch('OpportunitySupportRequestTrigger',true);
        insert OSRtriggerSwitch;
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
        triggerSwitches.get('OrderTrigger').isActive__c=true;
        triggerSwitches.get('AccountTrigger').isActive__c=true;
        triggerSwitches.get('Update_Pricebook2ids').isActive__c=true;
        insert  triggerSwitches.values();
         
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        
        // INSERT ACCOUTN RECORD
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recacTypeID;
        insert acc;
        
        Account accnt=TestDataUtil.createAccount();
        accnt.RecordTypeId = recacTypeID;
        insert accnt;
        
        // INSERT CONTACT RECORD
        Contact ct= TestDataUtil.createContact(acc);
        ct.RecordTypeId=reccTypeId;
        ct.OwnerID=userID;
        insert ct;
        
        Test.startTest();
        // INSERT OPPTY RECORD
        Opportunity opp = TestDataUtil.createOpportunity(acc);
        opp.RecordTypeId=recOpTypeID;
        insert opp;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = ct.Id;
        ocr.OpportunityId = opp.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        insert ocr;
        System.debug('created opportunity contact role for Opportunity');

        Order order = new Order();
        order.Accountid=acc.id;
        order.OpportunityId=opp.ID;
        order.Recordtypeid=estimatedOrderRecTypeID;
        order.SAP_Unique_Id__c='';
        order.PO_Received__c=false;
        order.Order_Amount__c=80000;
        order.Forecast__c='Stretch';
        order.EffectiveDate=system.today()+30;
        insert order;    
       
        opp.S1_Initial_consultation_meeting_complete__c=true;    
        opp.S1_Mtg_scheduled_to_audit_collect_data__c=true;
        opp.S1_Product_s_added_below_see__c=true;
        opp.S2_Audit_data_collection_complete__c=true;
        opp.S2_Ltg_Design_requested_or_started__c=true;
        Opp.Total_Order_Amount__c=10000.00;
        opp.stagename='S4 Negotiate';
        update opp;  
        
        Test.stopTest();
        Opportunity opp1 = TestDataUtil.createOpportunity(acc);
        opp1.Name = 'Venky Test1';
        opp.RecordTypeId=recOpTypeID;
        opp1.StageName = 'S1 Consult';
        opp1.Type='End User - Retrofit';
        opp1.AccountID = acc.id;
        opp1.Probability = 10;
        opp1.GE_LGT_Reason_Won_Lost__c=System.Label.Customer_Cancelled;
        opp1.CloseDate = System.Today() + 1;
        opp1.GE_LGT_SIMPLESALES__c='Yes';
        opp1.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp1.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp1.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        
        opp1.GE_LGT_GE_Opportunity_Id__c = 'test_vv';      
        Insert opp1; 

        Product2 prd = TestDataUtil.createProduct('Test1s');
        insert prd;

        
        Install_Base__c ib=new Install_Base__c(Name='TestIB',Opportunity__c=opp.id,Installation_Site_ID__c='tvenky25',File_storage__c='www.abc.com');
        insert ib;
        
        
        GE_LGT_EM_MaterialMaster__c mm = new GE_LGT_EM_MaterialMaster__c(Product_Hierarchy_Code_2__c = prd.id, GE_LGT_EM_SAP_MaterialNumber__c = '1234');
        Mm.GE_LGT_EM_SAP_MaterialNumber__c ='930227645';
        Mm.GE_LGT_EM_MaterialDescription__c= 'ABV101VTE571GV41BNW';
        Mm.GE_LGT_EM_ProductHierarchy__c='h012345678910123';
        Mm.Level_1__c='test00-test22-1'; 
        Mm.Level_2__c='test00012-test22-2';
        Mm.Level_3__c='test000222-test22-3'; 
        Mm.Level_4__c='test000023311-test22-4';
        Mm.Is_Active_Internal__c=true;
        insert mm;
        

        Installed_Product__c ip = new Installed_Product__c();
        ip.Install_Base_Name__c=ib.id;
        ip.Floor__c='test';
        ip.Area__c='TestArea';
        ip.SFDC_Material_ID__c = mm.id;
        ip.qty__c=5;
        insert ip;
        
        
        Pagereference pref=Page.GE_LGT_EM_Installed_product_Mass_Upload;
        pref.getParameters().Put('Id',ib.Id);
        Test.setCurrentPage(pref);        
        
        ApexPages.StandardController sc = new ApexPages.standardController(ib);
        GE_LGT_EM_Installed_Product_Mass_Upload control =new GE_LGT_EM_Installed_Product_Mass_Upload(sc);
        control.nameFile='UnitTestAttachment.csv';        
        control.contentFile=Blob.valueOf('SKU;Product Manual Description;Designed qty;Ordered qty;Installed qty;Product Warranty Years;Area;Floor;Room;Sales price/unit;Product Wattage;\n1234;Test Product;1;5;2;4;Hyderabd;testfloor;test;100;10\n');   
        control.ReadFile();
        
        GE_LGT_EM_Installed_Product_Mass_Upload control1 =new GE_LGT_EM_Installed_Product_Mass_Upload(sc);
        control1.nameFile='UnitTestAttachment.csv';        
        control1.contentFile=Blob.valueOf('SKU;Product Manual Description;Designed qty;Ordered qty;Installed qty;Product Warranty Years;Area;Floor;Room;Sales price/unit;Product Wattage;\n1234;Sample Product Desc2;20;0;3;4;Hyderabad;testfloor;test;100;20\n10;Sample Product Desc9;20;0;;t;Hyderabad;testfloor;test;100;10\n');   
        control1.ReadFile();
        
        GE_LGT_EM_Installed_Product_Mass_Upload control2 =new GE_LGT_EM_Installed_Product_Mass_Upload(sc);
        control2.nameFile='UnitTestAttachment.csv';        
        control2.contentFile=Blob.valueOf('SKU;Product Manual Description;Designed qty;Ordered qty;Installed qty;Product Warranty Years;Area;Floor;Room;Sales price/unit;Product Wattage;\n1234;Sample Product Desc3;20;test;5;3;Hyderabad;testfloor;test;100;14\n');    
        control2.ReadFile();
        
        GE_LGT_EM_Installed_Product_Mass_Upload control3 =new GE_LGT_EM_Installed_Product_Mass_Upload(sc);
        control3.nameFile='UnitTestAttachment.pdf';        
        control3.contentFile=Blob.valueOf('SKU;Product Manual Description;Designed qty;Ordered qty;Installed qty;Product Warranty Years;Area;Floor;Room;Sales price/unit;Product Wattage;\n');    
        control3.ReadFile();
        
        GE_LGT_EM_Installed_Product_Mass_Upload control4 =new GE_LGT_EM_Installed_Product_Mass_Upload(sc);
        control4.nameFile='UnitTestAttachment.csv';        
        control4.contentFile=Blob.valueOf('SKU;Product Manual Description;Designed qty;Ordered qty;Installed qty;Product Warranty Years;Area;Floor;Room;Sales price/unit;Product Wattage;\n10;Test Product;;;;4;Hyderabd;testfloor;test;100;5;\n');        
        control4.ReadFile();
        
        GE_LGT_EM_Installed_Product_Mass_Upload control5 =new GE_LGT_EM_Installed_Product_Mass_Upload(sc);
        control5.nameFile='UnitTestAttachment.csv';        
        control5.contentFile=Blob.valueOf('SKU;Product Manual Description;Designed qty;Ordered qty;Installed qty;Product Warranty Years;Area;Floor;Room;Sales price/unit;Product Wattage;\n');    
        control5.ReadFile();
        
        GE_LGT_EM_Installed_Product_Mass_Upload control6 =new GE_LGT_EM_Installed_Product_Mass_Upload(sc);
        control6.ReadFile();
        
        GE_LGT_EM_Installed_Product_Mass_Upload control7 =new GE_LGT_EM_Installed_Product_Mass_Upload(sc);
        control7.nameFile='UnitTestAttachment.csv';        
        control7.contentFile=Blob.valueOf('abc;def;egh;;;;;;\n');     
        control7.ReadFile();      
        
        GE_LGT_EM_Installed_Product_Mass_Upload control8 =new GE_LGT_EM_Installed_Product_Mass_Upload(sc);
        control8.nameFile='UnitTestAttachment.csv';        
        control8.contentFile=Blob.valueOf('SKU;Product Manual Description;Designed qty;Ordered qty;Installed qty;Product Warranty Years;Area;Floor;Room;Sales price/unit;Product Wattage;\n1234;Sample Product Desc2;20;0;;4;Hyderabad;testfloor;test;100;5;\n1234;Sample Product Desc9;20;0;;;Hyderabad;testfloor;test;100;5;\n');   
        control8.ReadFile();
        control8.getIPTitle();
    }
}
@isTest
private class GE_LGT_EM_InstallBase_Mass_Upload_Test {
    
    static testMethod void testAttachments() {
         Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        
        insert triggerSwitches.values();
        ID userID = UserInfo.getUserID();
        ID recopTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        ID recacTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();//SAP Account - Strategic
        ID recibTypeID = Schema.SObjectType.Install_Base__c.getRecordTypeInfosByName().get('Simple').getRecordTypeId(); //Integrated
        ID reccTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('EMEA Service Contact').getRecordTypeId();
        ID estimatedOrderRecTypeID=Schema.SObjectType.Order.getRecordTypeInfosByName().get('Estimated PO').getRecordTypeId();
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
          
         //Now update the OCR for the primary contact
    OpportunityContactRole ocr = new OpportunityContactRole();
    ocr.ContactId = ct.Id;
    ocr.OpportunityId = opp.Id;
    ocr.IsPrimary = TRUE;
    ocr.Role = 'Decision Maker';
    insert ocr;
    System.debug('created opportunity contact role for Opportunity');
        
        opp.S1_Initial_consultation_meeting_complete__c=true;    
        opp.S1_Mtg_scheduled_to_audit_collect_data__c=true;
        opp.S1_Product_s_added_below_see__c=true;
        opp.S2_Audit_data_collection_complete__c=true;
        opp.S2_Ltg_Design_requested_or_started__c=true;
        opp.stagename='S2 Audit';
        update opp;  
        Order order=TestDataUtil.createOrder('9999');
        order.GE_Opportunity_Id__c='EU34';
        order.Accountid=acc.id;
        order.OpportunityId=opp.ID;
        insert order;
        
        order.GE_Opportunity_Id__c='12EU34';
        //order.OpportunityId=opp.ID;
        order.Recordtypeid=estimatedOrderRecTypeID;
        order.SAP_Unique_Id__c='';
        order.PO_Received__c=false;
        update order;
        Test.stopTest();
        //      opp_list.add(opp);
        
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
        //opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp1.GE_LGT_GE_Opportunity_Id__c = 'test_vv';      
        insert opp1; 
        
        
        // INSERT InstallBase RECORD
        try{
            Install_Base__c ib=new Install_Base__c(Name='TestIB',recordtypeid=recIbTypeID,Opportunity__c=opp.id,Installation_Site_ID__c='tvenky',File_Storage__c='www.abc.com');
            insert ib;   
        }
        catch (exception e)  {
        }                                
        
        Pagereference pref=Page.GE_LGT_EM_InstallBase_Mass_Upload;
        pref.getParameters().Put('Id',opp.Id); 
        Test.setCurrentPage(pref);        
        
        ApexPages.StandardController sc = new ApexPages.standardController(opp);       
        
        GE_LGT_EM_InstallBase_Mass_Upload control =new GE_LGT_EM_InstallBase_Mass_Upload(sc);
        control.nameFile='UnitTestAttachment1.csv';        
        control.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Invoice number;SAP SO Number;Electrical metering;Audit Date (plan);Design Completed date (plan);Quotation issue date (plan);Equipment order date (plan);Equipment delivery date (plan);Installation Start date (plan);Installation Completion Date (plan);Installation Completion Date (actual);Warranty start date;Daily operating hours;Working days / week;Energy rate / KWh;File Storage\ntvenky;TestIB;Test;Hyderabd;500072;HYDERABAD;india;Test1;789864;tre@test.com;5;;BRICKS;;;Manual;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;;;;www.abc.com;\n');
        control.ReadFile();
        
        List<Attachment> attachments1=[select id, name from Attachment where parent.id=:opp.id];
         System.assertEquals(0, attachments1.size());
        
        control.nameFile='UnitTestAttachment16.csv';        
        control.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Invoice number;SAP SO Number;Electrical metering;Audit Date (plan);Design Completed date (plan);Quotation issue date (plan);Equipment order date (plan);Equipment delivery date (plan);Installation Start date (plan);Installation Completion Date (plan);Installation Completion Date (actual);Warranty start date;Daily operating hours;Working days / week;Energy rate / KWh;File Storage\ntvenky;TestIB;Test;Hyderabd;500072;HYDERABAD;Hungary;Test1;789864;tre@test.com;5;;BRICKS;;;Manual;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;;;;www.abc.com;\n');
        control.ReadFile();        
         List<Attachment> attachments16=[select id, name from Attachment where parent.id=:opp.id];
         System.assertEquals(0, attachments16.size());
        
        control.nameFile='UnitTestAttachment18.csv';        
        control.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Invoice number;SAP SO Number;Electrical metering;Audit Date (plan);Design Completed date (plan);Quotation issue date (plan);Equipment order date (plan);Equipment delivery date (plan);Installation Start date (plan);Installation Completion Date (plan);Installation Completion Date (actual);Warranty start date;Daily operating hours;Working days / week;Energy rate / KWh;File Storage\ntvenky;TestIB5;;Hyderabd;500072;HYDERABAD;Hungary;Test1;789864;tre@test.com;5;;BRICKS;;;Manual;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;;;;www.abc.com;\n');
        control.ReadFile();
        
         List<Attachment> attachments18=[select id, name from Attachment where parent.id=:opp.id];
         System.assertEquals(0, attachments18.size());
        
        control.nameFile='UnitTestAttachment20.csv';        
        control.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Invoice number;SAP SO Number;Electrical metering;Audit Date (plan);Design Completed date (plan);Quotation issue date (plan);Equipment order date (plan);Equipment delivery date (plan);Installation Start date (plan);Installation Completion Date (plan);Installation Completion Date (actual);Warranty start date;Daily operating hours;Working days / week;Energy rate / KWh;File Storage\ntvenky;TestIB5;Test;Hyderabd;500072;HYDERABAD;Hungary;Test1;789864;tre@test.com;5;;BRICKS;abc;;Manual;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;;;;www.abc.com;\n');
        control.ReadFile();
        
         List<Attachment> attachments20=[select id, name from Attachment where parent.id=:opp.id];
         System.assertEquals(0, attachments20.size());
        
        control.nameFile='UnitTestAttachment19.csv';        
        control.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Invoice number;SAP SO Number;Electrical metering;Audit Date (plan);Design Completed date (plan);Quotation issue date (plan);Equipment order date (plan);Equipment delivery date (plan);Installation Start date (plan);Installation Completion Date (plan);Installation Completion Date (actual);Warranty start date;Daily operating hours;Working days / week;Energy rate / KWh;File Storage\ntvenky;TestIB5;Test;Hyderabd;500072;HYDERABAD;Hungary;Test1;789864;tre@test.com;5;;BRICKS;;def;Manual;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;;;;www.abc.com;\n');
        control.ReadFile();
          /**********************/
               
         control.nameFile='UnitTestAttachment191.txt';        
         control.contentFile=Blob.valueOf('Installation Site ID,Installed Base Name,Street Address,City,Zip code,Region,Country,Site Contact Name,Site Contact Phone,Site Contact Email,Ins.Warrianty yrs,Location coordinates,Drawing number,Invoice number,SAP SO Number,Electrical metering,Audit Date (plan),Design Completed date (plan),Quotation issue date (plan),Equipment order date (plan),Equipment delivery date (plan),Installation Start date (plan),Installation Completion Date (plan),Installation Completion Date (actual),Warranty start date,Daily operating hours,Working days / week,Energy rate / KWh,File Storage\ntvenky,TestIB5,Test,Hyderabd,500072,HYDERABAD,Hungary,Test1,789864,tre@test.com,5,,BRICKS,,def,Manual,08/12/2014,08/12/2014,08/12/2014,08/12/2014,08/12/2014,08/12/2014,08/12/2014,08/12/2014,08/12/2014,,,10.23,www.abc.com,\n');
         control.ReadFile();
         List<Attachment> attachments191=[select id, name from Attachment where parent.id=:opp.id];
         System.assertEquals(0, attachments191.size());
         /* *********************/
        GE_LGT_EM_InstallBase_Mass_Upload control3 =new GE_LGT_EM_InstallBase_Mass_Upload(sc);
        control3.nameFile='UnitTestAttachment2.csv';
        control3.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Invoice number;SAP SO Number;Electrical metering;Audit Date (plan);Design Completed date (plan);Quotation issue date (plan);Equipment order date (plan);Equipment delivery date (plan);Installation Start date (plan);Installation Completion Date (plan);Installation Completion Date (actual);Warranty start date;Daily operating hours;Working days / week;Energy rate / KWh;File Storage\ntvenky1;TestIB1;Test1;Hyderabd1;500072;HYDERABAD;india;Test1;789864;tre@test.com;19;;BRICKS;;;Manual;08.12.2014;08.12.2014;08.12.2014;08.12.2014;08.12.2014;08.12.2014;08.12.2014;08/12/2014;;;;;www.abc.com;\n');
        control3.ReadFile();
         List<Attachment> attachments2=[select id, name from Attachment where parent.id=:opp.id];
         System.assertEquals(0, attachments2.size());
        
        GE_LGT_EM_InstallBase_Mass_Upload control1 =new GE_LGT_EM_InstallBase_Mass_Upload(sc);
        control1.nameFile='UnitTestAttachment3.pdf';
        control1.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Electrical metering;Audit Date (plan);Design Completed date (plan);Equipment order date (plan);Equipment delivery date (plan);Installation Start date (plan);Warranty start date;Installation Completion Date (plan);Installation Completion Date (actual);Daily operating hours;Working days / week;Energy rate / KWh;File Storage\n');
        control1.ReadFile();
         List<Attachment> attachments23=[select id, name from Attachment where parent.id=:opp.id];
         System.assertEquals(0, attachments23.size());
        
        
        GE_LGT_EM_InstallBase_Mass_Upload control5 =new GE_LGT_EM_InstallBase_Mass_Upload(sc);
        control5.nameFile='UnitTestAttachment4.csv';
        control5.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Invoice number;SAP SO Number;Electrical metering;Audit Date (plan);Design Completed date (plan);Quotation issue date (plan);Equipment order date (plan);Equipment delivery date (plan);Installation Start date (plan);Installation Completion Date (plan);Installation Completion Date (actual);Warranty start date;Daily operating hours;Working days / week;Energy rate / KWh;File Storage\ntvenkyy;TestIB;Test;Hyderabd;500072;india;Test1;789864;tre@test.com;12;;BRICKS;;;Manual;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;;;;;www.abc.com;\n');
        control5.ReadFile();
         List<Attachment> attachments4=[select id, name from Attachment where parent.id=:opp.id];
         System.assertEquals(0, attachments4.size());
        
        
        GE_LGT_EM_InstallBase_Mass_Upload control6 =new GE_LGT_EM_InstallBase_Mass_Upload(sc);
        //GE_LGT_EM_InstallBase_Mass_Upload control2 =new GE_LGT_EM_InstallBase_Mass_Upload(sc);
        control6.nameFile='UnitTestAttachment5.csv';
        control6.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Invoice number;SAP SO Number;Electrical metering;Audit Date (plan);Design Completed date (plan);Quotation issue date (plan);Equipment order date (plan);Equipment delivery date (plan);Installation Start date (plan);Installation Completion Date (plan);Installation Completion Date (actual);Warranty start date;Daily operating hours;Working days / week;Energy rate / KWh;File Storage\n');
        control6.ReadFile();        
         List<Attachment> attachments5=[select id, name from Attachment where parent.id=:opp.id];
         System.assertEquals(0, attachments5.size());
        
        
        control6.nameFile='UnitTestAttachment6.csv';
        control6.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Invoice number;SAP SO Number;Electrical metering;Audit Date (plan);Design Completed date (plan);Quotation issue date (plan);Equipment order date (plan);Equipment delivery date (plan);Installation Start date (plan);Installation Completion Date (plan);Installation Completion Date (actual);Warranty start date;Daily operating hours;Working days / week;Energy rate / KWh;File Storage\ntvenkyy;TestIB;Test;Hyderabd;500072;HYDERABAD;india;Test1;789864;tre@test.com;5;;Spades;;;Auto;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;;;;;;;;\ntvenkyy;TestIBB;Test;Hyderabd;500072;HYDERABAD;india;Test1;789864;tre@test.com;5;;Spades;;;Auto;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;;;;;;;;\n');
        control6.ReadFile();
         List<Attachment> attachments6=[select id, name from Attachment where parent.id=:opp.id];
         System.assertEquals(0, attachments6.size());
        
        
        //GE_LGT_EM_InstallBase_Mass_Upload control7 =new GE_LGT_EM_InstallBase_Mass_Upload(sc);
        control6.nameFile='UnitTestAttachment7.csv';
        control6.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Invoice number;SAP SO Number;Electrical metering;Audit Date (Actual);Design Completed date (Actual);Quotation issue date (Actual);Equipment order date (Actual);Equipment delivery date (Actual);Installation Start date (Actual);Installation Completion Date (actual);Warranty start date;Daily operating hours;Working days / week;Energy rate / KWh;File Storage\ntvenkyy;TestIBB;Test;Hyderabd;500072;EAST;india;Test1;789864;tre@test.com;25;;Spades;;;Auto;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;;;08/12/2014;;;;www.cnn.com;\ntvenkyy;TestIBB;Test;Hyderabd;500072;EAST;india;Test1;789864;tre@test.com;25;;Spades;;;Auto;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;;;08/12/2014;;;;www.cnn.com;\n');
        control6.ReadFile();
         List<Attachment> attachments7=[select id, name from Attachment where parent.id=:opp.id];
         System.assertEquals(0, attachments7.size());
        
        
        //GE_LGT_EM_InstallBase_Mass_Upload control8 =new GE_LGT_EM_InstallBase_Mass_Upload(sc);
        control6.nameFile='UnitTestAttachment8.csv';
        control6.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Invoice number;SAP SO Number;Electrical metering;Audit Date (plan);Design Completed date (plan);Quotation issue date (plan);Equipment order date (plan);Equipment delivery date (plan);Installation Start date (plan);Installation Completion Date (plan);Installation Completion Date (actual);Warranty start date;Daily operating hours;Working days / week;Energy rate / KWh;File Storage\ntvenkyy;;Test;Hyderabd;500072;ASIA;india;Test1;789864;tre@test.com;45;;Spades;;;Auto;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;;;;;;;www.cnn.com;');
        control6.ReadFile();
         List<Attachment> attachments8=[select id, name from Attachment where parent.id=:opp.id];
         System.assertEquals(0, attachments8.size());
        
        
        //GE_LGT_EM_InstallBase_Mass_Upload control9 =new GE_LGT_EM_InstallBase_Mass_Upload(sc);
        control6.nameFile='UnitTestAttachment9.csv';
        control6.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Invoice number;SAP SO Number;Electrical metering;Audit Date (plan);Design Completed date (plan);Quotation issue date (plan);Equipment order date (plan);Equipment delivery date (plan);Installation Start date (plan);Installation Completion Date (plan);Installation Completion Date (actual);Warranty start date;Daily operating hours;Working days / week;Energy rate / KWh;File Storage\ntvenkyy;;Test;Hyderabd;500072;ASIA;india;Test1;789864;tre@test.com;45;;Spades;;;Auto;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;;;;www.cnn.com;');
        control6.ReadFile();
        control6.getoptyTitle();
        control6.getShowError();
        control6.getPrerequisite();
         List<Attachment> attachments9=[select id, name from Attachment where parent.id=:opp.id];
         System.assertEquals(0, attachments9.size());
        
        
        control6.nameFile='UnitTestAttachment10.csv';     
        control6.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Invoice number;SAP SO Number;Electrical metering;Audit Date (Actual);Design Completed date (Actual);Quotation issue date (Actual);Equipment order date (Actual);Equipment delivery date (Actual);Installation Start date (Actual);Installation Completion Date (actual);Warranty start date;Daily operating hours;Working days / week;Energy rate / KWh;File Storage\ntvenkyy;TestIBB;Test;Hyderabd;500072;EAST;india;Test1;789864;tre@test.com;25;;Spades;;efx;Auto;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;;;;;www.cnn.com;\ntvenkyy;TestIBB;Test;Hyderabd;500072;EAST;india;Test1;789864;tre@test.com;25;;Spades;abc;;Auto;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;;;;;www.cnn.com;\n');
        control6.ReadFile();
         List<Attachment> attachments10=[select id, name from Attachment where parent.id=:opp.id];
         System.assertEquals(0, attachments10.size());
        
        
        control6.nameFile='UnitTestAttachment11.csv';
        control6.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Invoice number;SAP SO Number;Electrical metering;Audit Date (Actual);Design Completed date (Actual);Quotation issue date (Actual);Equipment order date (Actual);Equipment delivery date (Actual);Installation Start date (Actual);Installation Completion Date (actual);Warranty start date;Daily operating hours;Working days / week;Energy rate / KWh;File Storage\n');
        control6.ReadFile();
         List<Attachment> attachments11=[select id, name from Attachment where parent.id=:opp.id];
         System.assertEquals(0, attachments11.size());
        
        
        control6.nameFile='UnitTestAttachment12.csv';     
        control6.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Invoice number;SAP SO Number;Electrical metering;Audit Date (Actual);Design Completed date (Actual);Quotation issue date (Actual);Equipment order date (Actual);Equipment delivery date (Actual);Installation Start date (Actual);Installation Completion Date (actual);Warranty start date;Daily operating hours;Working days / week;Energy rate / KWh;File Storage\ntvenkyy;TestIBB;Test;Hyderabd;500072;EAST;india;Test1;789864;tre@test.com;ab;;Spades;;ii;Auto;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;;;;www.cnn.com;\ntvenkyy;TestIBB;Test;Hyderabd;500072;EAST;india;Test1;789864;tre@test.com;25;;Spades;abc;;Auto;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;;;;www.cnn.com;\n');
        control6.ReadFile();
         List<Attachment> attachments12=[select id, name from Attachment where parent.id=:opp.id];
         System.assertEquals(0, attachments12.size());
        
        
        control6.nameFile='UnitTestAttachment13.pdf';     
        control6.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Invoice number;SAP SO Number;Electrical metering;Audit Date (Actual);Design Completed date (Actual);Quotation issue date (Actual);Equipment order date (Actual);Equipment delivery date (Actual);Installation Start date (Actual);Installation Completion Date (actual);Warranty start date;Daily operating hours;Working days / week;Energy rate / KWh;File Storage\ntvenkyy;TestIBB;Test;Hyderabd;500072;EAST;india;Test1;789864;tre@test.com;ab;;Spades;;;Auto;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;;;;www.cnn.com;\ntvenkyy;TestIBB;Test;Hyderabd;500072;EAST;india;Test1;789864;tre@test.com;25;;Spades;abc;;Auto;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;;;;www.cnn.com;\n');
        control6.ReadFile();
         List<Attachment> attachments13=[select id, name from Attachment where parent.id=:opp.id];
         System.assertEquals(0, attachments13.size());
        
        
        GE_LGT_EM_InstallBase_Mass_Upload control4 =new GE_LGT_EM_InstallBase_Mass_Upload(sc);        
        control4.ReadFile();  
        
        Pagereference pref1=Page.GE_LGT_EM_InstallBase_Mass_Upload;
        pref1.getParameters().Put('Id',opp1.Id);
        Test.setCurrentPage(pref1); 
        
        ApexPages.StandardController sc1 = new ApexPages.standardController(opp1);//
        
        GE_LGT_EM_InstallBase_Mass_Upload control10 =new GE_LGT_EM_InstallBase_Mass_Upload(sc1);
        control10.nameFile='UnitTestAttachment1.csv';        
        control10.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Invoice number;SAP SO Number;Electrical metering;Audit Date (plan);Design Completed date (plan);Quotation issue date (plan);Equipment order date (plan);Equipment delivery date (plan);Installation Start date (plan);Installation Completion Date (plan);Installation Completion Date (actual);Warranty start date;Daily operating hours;Working days / week;Energy rate / KWh;File Storage\ntvenky;TestIB;Test;Hyderabd;500072;HYDERABAD;india;Test1;789864;tre@test.com;5;;BRICKS;123;456;Manual;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;;;;www.abc.com;\n');
        control10.ReadFile();        
        control10.getShowError();  
         List<Attachment> attachments=[select id, name from Attachment where parent.id=:opp1.id];
        System.assertEquals(0, attachments.size());
        
        /**********************/
        
        
         try
        {
        Pagereference pref12=Page.GE_LGT_EM_InstallBase_Mass_Upload;
        pref12.getParameters().Put('Id',opp1.Id);
        Test.setCurrentPage(pref12); 
        
        ApexPages.StandardController sc12 = new ApexPages.standardController(opp1);
        
        GE_LGT_EM_InstallBase_Mass_Upload control11 =new GE_LGT_EM_InstallBase_Mass_Upload(sc12);
        control11.nameFile='UnitTestAttachment102.csv';        
        control11.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Invoice number;SAP SO Number;Electrical metering;Audit Date (plan);Design Completed date (plan);Quotation issue date (plan);Equipment order date (plan);Equipment delivery date (plan);Installation Start date (plan);Installation Completion Date (plan);Installation Completion Date (actual);Warranty start date;Daily operating hours;Working days / week;Energy rate / KWh;File Storage\ntvenky;;Test;Hyderabd;500072;HYDERABAD;india;Test1;789864;tre@test.com;5;;BRICKS;445 44;45 6;Manual;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;8.00;5;;www.abc.com;\n');
        control11.ReadFile();        
       control11.getShowError();  
         }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Could not upload the file, since there are blank Installed Base Name(s) in the file') ? TRUE : FALSE;
                                       
            System.AssertEquals(expectedExceptionThrown, false);

        } 
        Pagereference pref50=Page.GE_LGT_EM_InstallBase_Mass_Upload;
        pref50.getParameters().Put('Id',opp.Id);
        Test.setCurrentPage(pref50);
        ApexPages.StandardController sctest = new ApexPages.standardController(opp);//
        
        GE_LGT_EM_InstallBase_Mass_Upload contro50 =new GE_LGT_EM_InstallBase_Mass_Upload(sctest);
        contro50.nameFile='UnitTestAttachment50.csv';        
        contro50.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Invoice number;SAP SO Number;Electrical metering;Audit Date (plan);Design Completed date (plan);Quotation issue date (plan);Equipment order date (plan);Equipment delivery date (plan);Installation Start date (plan);Installation Completion Date (plan);Installation Completion Date (actual);Warranty start date;Daily operating hours;Working days / week;Energy rate / KWh;File Storage\n tvenky;TestIB;Test;Hyderabd;500072;HYDERABAD;india;Test1;789864;tre@test.com;5;;BRICKS;123;456;Manual;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;;;;www.abc.com;\ntvenky;TestIB;Test;Hyderabd;500072;HYDERABAD;india;Test1;789864;tre@test.com;5;;BRICKS;123;456;Manual;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;;;;www.abc.com;\n');
        contro50.ReadFile();  
       
    }
     static testMethod void testAttachments1() {
         Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        
        insert triggerSwitches.values();
        ID userID = UserInfo.getUserID();
        ID recopTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        ID recacTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();//SAP Account - Strategic
        ID recibTypeID = Schema.SObjectType.Install_Base__c.getRecordTypeInfosByName().get('Simple').getRecordTypeId(); //Integrated
        ID reccTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('EMEA Service Contact').getRecordTypeId();
        ID estimatedOrderRecTypeID=Schema.SObjectType.Order.getRecordTypeInfosByName().get('Estimated PO').getRecordTypeId();
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
          
         //Now update the OCR for the primary contact
    OpportunityContactRole ocr = new OpportunityContactRole();
    ocr.ContactId = ct.Id;
    ocr.OpportunityId = opp.Id;
    ocr.IsPrimary = TRUE;
    ocr.Role = 'Decision Maker';
    insert ocr;
    System.debug('created opportunity contact role for Opportunity');
        
        opp.S1_Initial_consultation_meeting_complete__c=true;    
        opp.S1_Mtg_scheduled_to_audit_collect_data__c=true;
        opp.S1_Product_s_added_below_see__c=true;
        opp.S2_Audit_data_collection_complete__c=true;
        opp.S2_Ltg_Design_requested_or_started__c=true;
        opp.stagename='S2 Audit';
        update opp;  
        Order order=TestDataUtil.createOrder('9999');
        order.GE_Opportunity_Id__c='EU34';
        order.Accountid=acc.id;
        order.OpportunityId=opp.ID;
        insert order;
        
        order.GE_Opportunity_Id__c='12EU34';
        //order.OpportunityId=opp.ID;
        order.Recordtypeid=estimatedOrderRecTypeID;
        order.SAP_Unique_Id__c='';
        order.PO_Received__c=false;
        update order;
        Test.stopTest();
        //      opp_list.add(opp);
        
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
        //opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp1.GE_LGT_GE_Opportunity_Id__c = 'test_vv';      
        insert opp1; 
        Pagereference pref=Page.GE_LGT_EM_InstallBase_Mass_Upload;
        pref.getParameters().Put('Id',opp.Id); 
        Test.setCurrentPage(pref);        
        
        ApexPages.StandardController sc = new ApexPages.standardController(opp);       
        
        GE_LGT_EM_InstallBase_Mass_Upload control =new GE_LGT_EM_InstallBase_Mass_Upload(sc);
        try
        {
        control.nameFile='UnitTestAttachment30.csv';
        control.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Invoice number;SAP SO Number;Electrical metering;Audit Date (plan);Design Completed date (plan);Quotation issue date (plan);Equipment order date (Actual);Equipment delivery date (Actual);Installation Start date (plan);Installation Completion Date (plan);Installation Completion Date (actual);Warranty start date;Daily operating hours;Working days / week;Energy rate / KWh;File Storage\ntvenky;TestIB;Test;Hyderabd;500072;HYDERABAD;india;Test1;789864;tre@test.com;5;;BRICKS;123 test;456 test;Manual test;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;test;test;test;test;\n');
        control.ReadFile();
         
         ApexPages.StandardController sc1 = new ApexPages.standardController(opp);       
        
        GE_LGT_EM_InstallBase_Mass_Upload control1 =new GE_LGT_EM_InstallBase_Mass_Upload(sc1);
        control1.nameFile='UnitTestAttachment12.csv';     
        control1.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Invoice number;SAP SO Number;Electrical metering;Audit Date (Actual);Design Completed date (Actual);Quotation issue date (Actual);Equipment order date (Actual);Equipment delivery date (Actual);Installation Start date (Actual);Installation Completion Date (actual);Warranty start date;Daily operating hours;Working days / week;Energy rate / KWh;File Storage\ntvenkyy;;Test;Hyderabd;500072;EAST;india;Test1;789864;tre@test.com;ab;;Spades;test 123;ii 123;Auto test;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;;;;www.cnn.com;\ntvenkyy;TestIBB;Test;Hyderabd;500072;EAST;india;Test1;789864;tre@test.com;25;;Spades;abc;;Auto;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;teest;test;test;www.cnn.com;\n');
        control1.ReadFile();
         List<Attachment> attachments12=[select id, name from Attachment where parent.id=:opp.id];
         System.assertEquals(0, attachments12.size());
        }
         catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('yttttttttttt') ? TRUE : FALSE;
                                       
                                         System.AssertEquals(exp.getMessage(), 'test');
            System.AssertEquals(expectedExceptionThrown, true);

        } 
        try{
        ApexPages.StandardController sc2 = new ApexPages.standardController(opp);       
        
        GE_LGT_EM_InstallBase_Mass_Upload control1 =new GE_LGT_EM_InstallBase_Mass_Upload(sc2);
        control1.nameFile='UnitTestAttachment123.csv';     
        control1.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Invoice number;SAP SO Number;Electrical metering;Audit Date (Actual);Design Completed date (Actual);Quotation issue date (Actual);Equipment order date (Actual);Equipment delivery date (Actual);Installation Start date (Actual);Installation Completion Date (actual);Warranty start date;Daily operating hours;Working days / week;Energy rate / KWh;File Storage\n');
        control1.ReadFile();
         List<Attachment> attachments123=[select id, name from Attachment where parent.id=:opp.id];
         System.assertEquals(0, attachments123.size());
        }
         catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('yttttttttttt') ? TRUE : FALSE;
                                       
                                         System.AssertEquals(exp.getMessage(), 'test');
            System.AssertEquals(expectedExceptionThrown, true);

        } 
      
        
        
     }
      static testMethod void testAttachments12() {
         Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        
        insert triggerSwitches.values();
        ID userID = UserInfo.getUserID();
        ID recopTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        ID recacTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();//SAP Account - Strategic
        ID recibTypeID = Schema.SObjectType.Install_Base__c.getRecordTypeInfosByName().get('Simple').getRecordTypeId(); //Integrated
        ID reccTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('EMEA Service Contact').getRecordTypeId();
        ID estimatedOrderRecTypeID=Schema.SObjectType.Order.getRecordTypeInfosByName().get('Estimated PO').getRecordTypeId();
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
          
         //Now update the OCR for the primary contact
    OpportunityContactRole ocr = new OpportunityContactRole();
    ocr.ContactId = ct.Id;
    ocr.OpportunityId = opp.Id;
    ocr.IsPrimary = TRUE;
    ocr.Role = 'Decision Maker';
    insert ocr;
    System.debug('created opportunity contact role for Opportunity');
        
        opp.S1_Initial_consultation_meeting_complete__c=true;    
        opp.S1_Mtg_scheduled_to_audit_collect_data__c=true;
        opp.S1_Product_s_added_below_see__c=true;
        opp.S2_Audit_data_collection_complete__c=true;
        opp.S2_Ltg_Design_requested_or_started__c=true;
        opp.stagename='S2 Audit';
        update opp;  
        Order order=TestDataUtil.createOrder('9999');
        order.GE_Opportunity_Id__c='EU34';
        order.Accountid=acc.id;
        order.OpportunityId=opp.ID;
        insert order;
        
        order.GE_Opportunity_Id__c='12EU34';
        //order.OpportunityId=opp.ID;
        order.Recordtypeid=estimatedOrderRecTypeID;
        order.SAP_Unique_Id__c='';
        order.PO_Received__c=false;
        update order;
        Test.stopTest();
        //      opp_list.add(opp);
        
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
        //opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp1.GE_LGT_GE_Opportunity_Id__c = 'test_vv';      
        insert opp1; 
        Pagereference pref=Page.GE_LGT_EM_InstallBase_Mass_Upload;
        pref.getParameters().Put('Id',opp.Id); 
        Test.setCurrentPage(pref);        
        
        ApexPages.StandardController sc = new ApexPages.standardController(opp);       
        
     
        GE_LGT_EM_InstallBase_Mass_Upload control=new GE_LGT_EM_InstallBase_Mass_Upload(sc);
        control.nameFile='UnitTestAttachment12.csv';     
        
        control.contentFile=Blob.valueOf('Installation Site ID;Installed Base Name;Street Address;City;Zip code;Region;Country;Site Contact Name;Site Contact Phone;Site Contact Email;Ins.Warrianty yrs;Location coordinates;Drawing number;Invoice number;SAP SO Number;Electrical metering;Audit Date (Actual);Design Completed date (Actual);Quotation issue date (Actual);Equipment order date (Actual);Equipment delivery date (Actual);Installation Start date (Actual);Installation Completion Date (actual);Warranty start date;Daily operating hours;Working days / week;Energy rate / KWh;File Storage\ntvenkyy;test;Test;Hyderabd;500072;EAST;india;Test1;789864;tre@test.com;10;;Spades;123;123;Auto;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;08/12/2014;;;;www.cnn.com;\n');
         control.ReadFile();
      }


}
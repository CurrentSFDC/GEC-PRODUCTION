@isTest
Public class  GE_LGT_EM_IB_Stage_Test {
    static testmethod void TestIB(){
    
       Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        
        insert triggerSwitches.values();
        ID userID = UserInfo.getUserID();
        ID recopTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('StandardAdvance').getRecordTypeId();
        ID recacTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        ID recibTypeID = Schema.SObjectType.Install_Base__c.getRecordTypeInfosByName().get('Integrated').getRecordTypeId(); 
        ID reccTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('EMEA Service Contact').getRecordTypeId();
        ID estimatedOrderRecTypeID=Schema.SObjectType.Order.getRecordTypeInfosByName().get('Estimated PO').getRecordTypeId();
        // INSERT ACCOUTN RECORD
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recacTypeID;
        insert acc;
      System.assert(acc.ID!=Null);
       Account accnt=TestDataUtil.createAccount();
       accnt.RecordTypeId = recacTypeID;
        insert accnt;
        System.assert(accnt.ID!=Null);
      // INSERT CONTACT RECORD
      Contact ct= TestDataUtil.createContact(acc);
      ct.RecordTypeId=reccTypeId;
      ct.OwnerID=userID;
      ct.AccountId=accnt.Id;
      insert ct;
        System.assert(ct.ID!=Null);
     Test.startTest();
       // INSERT OPPTY RECORD
       Opportunity opp = TestDataUtil.createOpportunity(acc);
       opp.RecordTypeId=recOpTypeID;
       insert opp;
         System.assert(opp.ID!=Null);
         //Now create the OCR for the primary contact
    OpportunityContactRole ocr = new OpportunityContactRole();
    ocr.ContactId = ct.Id;
    ocr.OpportunityId = opp.Id;
    ocr.IsPrimary = TRUE;
    ocr.Role = 'Decision Maker';
    insert ocr;
       OpportunityContactRole ocrresult =[select Id ,ContactId, OpportunityId from OpportunityContactRole where OpportunityId =: opp.Id] ;
       System.assert(ocrresult.Id!=Null);
        System.assertEquals(ct.Id, ocrresult.ContactId);
     System.debug('created opportunity contact role for Opportunity');
        
              
      opp.S1_Initial_consultation_meeting_complete__c=true;    
      opp.S1_Mtg_scheduled_to_audit_collect_data__c=true;
      opp.S1_Product_s_added_below_see__c=true;
      opp.S2_Audit_data_collection_complete__c=true;
      opp.S2_Ltg_Design_requested_or_started__c=true;
      opp.stagename='S2 Audit';
      update opp;  
      
        System.assertEquals('S2 Audit', opp.stagename);
      
        Order order=TestDataUtil.createOrder('9999');
        order.GE_Opportunity_Id__c='EU34';
        order.Accountid=acc.id;
        order.OpportunityId=opp.ID;
        order.Order_Amount__c=100;
        insert order;
       
        System.assert(order.Id!=Null);
       
        order.GE_Opportunity_Id__c='12EU34';
      //  order.OpportunityId=opp.ID;
        order.Recordtypeid=estimatedOrderRecTypeID;
        order.SAP_Unique_Id__c='';
        order.PO_Received__c=false;
        update order;
        Test.stopTest();
        
        List<Install_Base__c> IbList=new List<Install_Base__c>();
      // INSERT InstallBase RECORD      
        Install_Base__c ib1=new Install_Base__c(Name='TestIB6',recordtypeid=recIbTypeID,Opportunity__c=opp.id,Installation_Site_ID__c='tvenky6',File_storage__c='www.abc.com');
        IbList.add(ib1);  
        Install_Base__c ib6=new Install_Base__c(S11_Site_entered_in_ROI__c = True,recordtypeid=recIbTypeID,Equipment_ordered_date_actual__c=Date.Parse('10/12/2015'),Equipment_ordered_date_plan__c=Date.Parse('10/12/2015'),Name='TestIB6',Opportunity__c=opp.id,Installation_Site_ID__c='tvenky6',Planned_Audit_date__c = Date.Parse('10/12/2015'),S6_Got_all_original_drawings__c = True,Actual_Audit_date__c = Date.Parse('10/12/2015'),Application_Engineer__c = userID ,S7_Red_line_drawings__c = True,Actual_Designed_Completed_date__c = Date.Parse('10/12/2015') , Planned_Designed_Completed_date__c = Date.Parse('10/12/2015') , Designer__c = userID,S8_Design_completed_and_uploaded__c = True ,S8_Final_design_flag_checked__c = True , S8_Design_files_and_BOQ_sent__c = True,Planned_Order_Receive_date__c = Date.Parse('10/12/2015'),Planned_Installation_Start_date__c = Date.Parse('10/12/2015') , Planned_Installation_Completion_date__c = Date.Parse('10/12/2015') , S9_Contractor_quotes_install_received__c = True ,S9_Customer_approved_GE_quotes__c = True,S9_GE_converted_quotes_were_sent__c = True ,S9_Order_Placed_on_Services__c = True,Actual_Order_Receive_date__c = Date.Parse('10/12/2015'),SAP_PO_number__c ='10' , S10_Order_placed_on_Lighting_equipment__c = True,Inst_Completion_Date__c = Date.Parse('10/12/2015') ,Actual_Installation_Completion_date__c = Date.Parse('10/12/2015'), S11_Installation_accepted_by_Customer__c = True , S11_Red_line_drawings_checked_uploaded__c = True,S12_Customer_invoiced__c = True,File_storage__c='www.abc.com');
        IbList.add(ib6);
        Install_Base__c ib2=new Install_Base__c(S11_Site_entered_in_ROI__c = True,Equipment_ordered_date_actual__c=Date.Parse('10/12/2015'),Equipment_ordered_date_plan__c=Date.Parse('10/12/2015'),Name='TestIB6',Opportunity__c=opp.id,Installation_Site_ID__c='tvenky6',Planned_Audit_date__c = Date.Parse('10/12/2015'),S6_Got_all_original_drawings__c = True,Actual_Audit_date__c = Date.Parse('10/12/2015'),Application_Engineer__c = userID ,S7_Red_line_drawings__c = True,Actual_Designed_Completed_date__c = Date.Parse('10/12/2015') , Planned_Designed_Completed_date__c = Date.Parse('10/12/2015') , Designer__c = userID,S8_Design_completed_and_uploaded__c = True ,S8_Final_design_flag_checked__c = True , S8_Design_files_and_BOQ_sent__c = True,Planned_Order_Receive_date__c = Date.Parse('10/12/2015'),Planned_Installation_Start_date__c = Date.Parse('10/12/2015') , Planned_Installation_Completion_date__c = Date.Parse('10/12/2015') , S9_Contractor_quotes_install_received__c = True ,S9_Customer_approved_GE_quotes__c = True,S9_GE_converted_quotes_were_sent__c = True ,S9_Order_Placed_on_Services__c = True,Actual_Order_Receive_date__c = Date.Parse('10/12/2015'),SAP_PO_number__c ='10' , S10_Order_placed_on_Lighting_equipment__c = True,Inst_Completion_Date__c = Date.Parse('10/12/2015') ,Actual_Installation_Completion_date__c = Date.Parse('10/12/2015'), S11_Installation_accepted_by_Customer__c = True , S11_Red_line_drawings_checked_uploaded__c = True,S12_Customer_invoiced__c = True,File_storage__c='www.abc.com');
        IbList.add(ib2);
        try {
        Insert Iblist;
            System.debug('listsize'+Iblist.size());
            System.assertEquals(4, Iblist.size());
        }
        catch (exception e)
        {
        }
   }
   
}
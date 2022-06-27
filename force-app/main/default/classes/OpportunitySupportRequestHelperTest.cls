@isTest
public class OpportunitySupportRequestHelperTest {
    public static ID userID = UserInfo.getUserID();
    public static  ID  recOppTypeID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
    public static  ID  recAccTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
    public static  ID  OppMngReviewRecID=Schema.SObjectType.Opportunity_Support_Request__c.getRecordTypeInfosByName().get('Opportunity Management Review').getRecordTypeId();
    public static ID Pricing_RecordType = Schema.SObjectType.Opportunity_Support_Request__c.getRecordTypeInfosByName().get('Pricing Request').getRecordTypeId();
                
  static testMethod void InsertOSRValidation()
    {
              
        Test.startTest();
        //Custom data creation
         
          TriggerSwitch__c OSRtriggerSwitch=TestDataUtil.createTriggerSwitch('OpportunitySupportRequestTrigger',true);
          insert OSRtriggerSwitch;
          Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
          triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
          triggerSwitches.get('OrderTrigger').isActive__c=true;
          triggerSwitches.get('AccountTrigger').isActive__c=true;
          insert  triggerSwitches.values();
       //Account insertion
         Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAccTypeId;
        insert acc;
        // INSERT OPPTY RECORD
        Opportunity opp = TestDataUtil.createOpportunity(acc);
        opp.RecordTypeId=recOppTypeID;
        
        insert opp;
        GE_LGT_EM_MaterialMaster__c matrial=TestDataUtil.createMaterialMaster('99999');
        insert matrial;
        
        // Insert OSR
        ID recordOSR2TypeId = [SELECT ID FROM RECORDTYPE WHERE SOBJECTTYPE='Opportunity_Support_Request__c' and NAME = 'Pricing Request'].ID;
        Opportunity_Support_Request__c osrequest = TestDataUtil.createOSR();
        osrequest.RecordTypeId=recordOSR2TypeId;
        osrequest.Opportunity_Name__c=opp.id;
        osrequest.EMEA_Existing_SKU_code__c=matrial.id;   
        osrequest.New_Customer__c='Yes';
        osrequest.Status__c='responded';
        osrequest.Payback_in_years__c=11.0;
        try{
            insert osrequest;
            Opportunity_Support_Request__c Testrecord= [Select ID ,Status__c from Opportunity_Support_Request__c where Id =:osrequest.id];
            System.assertEquals('Responded', Testrecord.Status__c, 'Testmethod Failed');
          
       }
        catch(Exception e){
         Boolean expectedExceptionThrown =  e.getMessage().contains('Cannot create Opportunity Support Requset, as the asociated opportunity has no product line item') ? true : false;
           System.AssertEquals(expectedExceptionThrown, false);
      }
          Test.stopTest();
    }
    static testMethod void UpdateOSRValidation()
    {
         Test.startTest();
        
         TriggerSwitch__c OSRtriggerSwitch=TestDataUtil.createTriggerSwitch('OpportunitySupportRequestTrigger',true);
         insert OSRtriggerSwitch;
         Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
         triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
        triggerSwitches.get('OrderTrigger').isActive__c=true;
        triggerSwitches.get('AccountTrigger').isActive__c=true;
        insert  triggerSwitches.values();
        //Account creation
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAccTypeId;
        insert acc;
        // INSERT OPPTY RECORD
        Opportunity opp = TestDataUtil.createOpportunity(acc);
        opp.RecordTypeId=recOppTypeID;
      
        insert opp;
        GE_LGT_EM_MaterialMaster__c matrial=TestDataUtil.createMaterialMaster('99999');
        insert matrial;
        Opportunity_Support_Request__c osrequest2 = TestDataUtil.createOSR();
        osrequest2.RecordTypeId=Pricing_RecordType;
        osrequest2.Opportunity_Name__c=opp.id;
        osrequest2.No_Yes_Not_sure__c='Yes';
        osrequest2.There_s_a_Strategic_Value_Future_Revenue__c='Yes';
        osrequest2.Total_value_of_Opporutnity_is_in_excess__c='Yes';
        osrequest2.Status__c='Not Submitted';
       try{
            insert osrequest2;
           Opportunity_Support_Request__c Testrecord= [Select ID ,Status__c from Opportunity_Support_Request__c where Id =:osrequest2.id];
            System.assertEquals('Not Submitted', Testrecord.Status__c, 'Testmethod Failed');
    
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Cannot create Opportunity Support Requset, as the asociated opportunity has no product line item') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        }
       // osrequest2.Pricing_Approver__c=='';
        osrequest2.No_Yes_Not_sure__c='Not sure';
        osrequest2.There_s_a_Strategic_Value_Future_Revenue__c='Not sure';
        osrequest2.Total_value_of_Opporutnity_is_in_excess__c='Not sure';
        osrequest2.Status__c='acknowledged';
        
        try{
           // osrequest2.Pricing_Approver__c=UserInfo.getUserId();
            Update osrequest2;
           Opportunity_Support_Request__c Testrecord= [Select ID ,Status__c from Opportunity_Support_Request__c where Id =:osrequest2.id];
           // System.assertEquals('acknowledged', Testrecord.Status__c, 'Testmethod Failed'); //rqt-1501
            System.assertEquals('Acknowledged', Testrecord.Status__c, 'Testmethod Failed');
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Cannot create Opportunity Support Requset, as the asociated opportunity has no product line item') ? true : false;
          
            System.AssertEquals(expectedExceptionThrown, false);
        }
         
          Test.stopTest();
    }
     static testMethod void DeletionOSRValidation()
    {
         Test.startTest();
        
          TriggerSwitch__c OSRtriggerSwitch=TestDataUtil.createTriggerSwitch('OpportunitySupportRequestTrigger',true);
          insert OSRtriggerSwitch;
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
        triggerSwitches.get('OrderTrigger').isActive__c=true;
        triggerSwitches.get('AccountTrigger').isActive__c=true;
        insert  triggerSwitches.values();
        //Account creation
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAccTypeId;
        insert acc;
        // INSERT OPPTY RECORD
        Opportunity opp = TestDataUtil.createOpportunity(acc);
        opp.RecordTypeId=recOppTypeID;
      
        insert opp;
        GE_LGT_EM_MaterialMaster__c matrial=TestDataUtil.createMaterialMaster('99999');
        insert matrial;
        Opportunity_Support_Request__c osrequest2 = TestDataUtil.createOSR();
        osrequest2.RecordTypeId=OppMngReviewRecID;
        osrequest2.Opportunity_Name__c=opp.id;
        osrequest2.No_Yes_Not_sure__c='Yes';
        osrequest2.There_s_a_Strategic_Value_Future_Revenue__c='Yes';
        osrequest2.Total_value_of_Opporutnity_is_in_excess__c='Yes';
        osrequest2.Status__c='acknowledged';
        insert osrequest2;
        try{
             Profile p = [SELECT Id FROM Profile WHERE Name='Integration User']; 
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@ge.com.satishdev',
             GE_LGT_Business_Division__c='EMEA Service' );
             System.runAs ( u ) {  
             Delete osrequest2; 
            // System.assertEquals(True, ApexPages.hasMessages(),'No validation message was generated');
             System.assertEquals(False, ApexPages.hasMessages(),'No validation message was generated'); //rqt-1501
             osrequest2.No_Yes_Not_sure__c='No';
             Update osrequest2;
             System.assertEquals(True, ApexPages.hasMessages(),'No validation message was generated');
                
             }
             
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Only Admins/Superusers can delete OSRs') ? true : false;
           System.AssertEquals(expectedExceptionThrown, true);
           //System.AssertEquals(expectedExceptionThrown, false); 
           
        }
         Test.stopTest();
                
    }
    static testMethod void SendEmailOSRValidation()
    {
         Test.startTest();
        
          TriggerSwitch__c OSRtriggerSwitch=TestDataUtil.createTriggerSwitch('OpportunitySupportRequestTrigger',true);
          insert OSRtriggerSwitch;
          Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
          triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
          triggerSwitches.get('OrderTrigger').isActive__c=true;
          triggerSwitches.get('AccountTrigger').isActive__c=true;
          insert  triggerSwitches.values();
        //Account creation
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAccTypeId;
        insert acc;
        // INSERT OPPTY RECORD
        Opportunity opp = TestDataUtil.createOpportunity(acc);
        opp.RecordTypeId=recOppTypeID;
      
        insert opp;
        GE_LGT_EM_MaterialMaster__c matrial=TestDataUtil.createMaterialMaster('99999');
        insert matrial;
        Opportunity_Support_Request__c osrequest3 = TestDataUtil.createOSR();
        osrequest3.RecordTypeId=OppMngReviewRecID;
        osrequest3.Opportunity_Name__c=opp.id;
        osrequest3.No_Yes_Not_sure__c='Yes';
        osrequest3.There_s_a_Strategic_Value_Future_Revenue__c='Yes';
        osrequest3.Total_value_of_Opporutnity_is_in_excess__c='Yes';
        osrequest3.Status__c='Submitted';
        insert osrequest3;
         List<OpportunityTeamMember> member_list = [SELECT User.Email,User.id FROM OpportunityTeamMember WHERE OpportunityId =:osrequest3.Opportunity_Name__c];
        if(member_list.size()>0){
            
            List<String> sendTo = new List<String>();
            for(OpportunityTeamMember OTM1 : member_list){
               sendTo.add(OTM1.User.Email);
            
            }
            String osr_url = URL.getSalesforceBaseUrl().toExternalForm() +'/' + osrequest3.Id;
            String Oppty_Name = [Select Name from Opportunity where id =:osrequest3.Opportunity_Name__c].Name;
            String body = '<html lang="ja"><body>'+ 
                +'An Opportunity Support Request was submitted for an Opportunity where you are a team member. Click here to go to the OSR record - '+'  '+osr_url+
                '<br><br>'+'Please click FOLLOW on the record to be notified of future updates.'+'</body></html>';
          
           String subject = 'OSR submitted for Opportunity : '+Oppty_Name;
            
           GE_LGT_MailerUtils.sendEmailNotification(string.valueof(subject),string.valueof(body),sendTo);
            system.assertNotEquals(0,Limits.getEmailInvocations());
             Test.stopTest();
        
        }
    }
    static testmethod void populateOsrfieldsFromOppty()
    {
        TriggerSwitch__c OSRtriggerSwitch=TestDataUtil.createTriggerSwitch('OpportunitySupportRequestTrigger',true);
         insert OSRtriggerSwitch;
         Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
         triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
        triggerSwitches.get('OrderTrigger').isActive__c=true;
        triggerSwitches.get('AccountTrigger').isActive__c=true;
        insert  triggerSwitches.values();
        
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Alliance Partner').getRecordTypeId();
        ID recAccEndUserTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        ID recAccdistributorTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        ID recSAPAccountTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.Name='Alliance account';
        acc.RecordTypeId=recAccTypeID;
        acc.Alliance_Partner_Type_Primary__c ='Independent Software Vendor';
        insert acc;
        
        Account accE=TestDataUtil.createAccount();
        accE.Name='Test account';
        accE.RecordTypeId=recAccEndUserTypeID;
        insert accE;
        
        Account accdistributor=TestDataUtil.createAccount();
        accdistributor.Name='Test accdistributor';
        accdistributor.RecordTypeId=recSAPAccountTypeID;
        insert accdistributor;
        
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
        opp.CloseDate = date.parse('3/10/2099');
        opp.PO_Receipt_Date__c = date.parse('3/10/2099');//changed on 20 Oct 20
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Distributor__c =accdistributor.id;
        opp.Distribution_Channel__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        opp.GE_LGT_GE_Opportunity_Id__c = 'test_v3sai1';  
        insert opp;
        
        CDT_Opportunity_Key_Player__c okpVar = new CDT_Opportunity_Key_Player__c();
        okpVar.Account__c=acc.id;
        okpVar.CDT_Opportunity_Name__c=opp.id;
        insert okpVar;
        test.starttest();
        ID recOsrTypeID = Schema.SObjectType.Opportunity_Support_Request__c.getRecordTypeInfosByName().get('Awaiting Acknowledgment').getRecordTypeId();
        Opportunity_Support_Request__c osrequest = TestDataUtil.createOSR();
        osrequest.RecordTypeId=recOsrTypeID;
        osrequest.Opportunity_Name__c=opp.id;
        osrequest.Status__c='Not Submitted';
        osrequest.Program_Management_Support__c='Yes';
        osrequest.Distributor_Channel__c='No';
        osrequest.Distributor__c=accdistributor.id;
        osrequest.Pricing_Request_Date__c=DateTime.newInstance(2099, 7, 13, 0, 0, 0);//changed on 20 Oct 20 as the validation rule needs time to be more than 6hrs
        insert osrequest;
        osrequest.Status__c='Submitted';
        update osrequest;

        
        list<Opportunity_Support_Request__c> osrlist = [select id,Distributor_Channel__c,Distributor__c from Opportunity_Support_Request__c where Opportunity_Name__c=:opp.id];
        system.assertequals('No',osrlist[0].Distributor_Channel__c);
        system.assertequals(accdistributor.id,osrlist[0].Distributor__c);
        system.assertequals(1,osrlist.Size());
        test.stoptest();
    }
}
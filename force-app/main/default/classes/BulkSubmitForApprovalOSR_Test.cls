@isTest
public class BulkSubmitForApprovalOSR_Test {
    //Rashmitha Changed the API vesion from 37 to 45 on 6-Mar-2019 as per 1447 request
    static testMethod void NewEMEAcreationforbulkApproval(){
        ID userID = UserInfo.getUserID();
        ID recOppTypeID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID  recAccTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        ID  recOSRTypeID=Schema.SObjectType.Opportunity_Support_Request__c.getRecordTypeInfosByName().get('EMEA New Sample Product Req').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAccTypeId;
        insert acc;
      // INSERT OPPTY RECORD
      TriggerSwitch__c triSwitch = new TriggerSwitch__c();
      triSwitch.Name = 'OpportunityTrigger';
      triSwitch.isActive__c = true;
      insert triSwitch;
        Opportunity opp = TestDataUtil.createOpportunity(acc);
        //opp.Name='OpportunityTrigger';
        opp.RecordTypeId=recOppTypeID;
        insert opp;
        GE_LGT_EM_MaterialMaster__c matrial=TestDataUtil.createMaterialMaster('99999');
        insert matrial;
        // Insert OSR
        TriggerSwitch__c trigSwitchOppReq = new TriggerSwitch__c();
        trigSwitchOppReq.Name = 'OpportunitySupportRequestTrigger';
        trigSwitchOppReq.isActive__c = true;
        insert trigSwitchOppReq;
        Opportunity_Support_Request__c osrequest = TestDataUtil.createOSR();
        osrequest.RecordTypeId=recOSRTypeID;
        osrequest.Opportunity_Name__c=opp.id;
        osrequest.EMEA_Existing_SKU_code__c=matrial.id;        
        insert osrequest;
        PageReference pageRef = Page.BulkSubmitForApprovalOSR;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(osrequest);
        ApexPages.currentPage().getParameters().put('Id',opp.id);
      
        BulkSubmitForApprovalOSR OSRNEw=new BulkSubmitForApprovalOSR(sc);
        OSRNEw.bulkapproval();
        OSRNEw.closePopup();
        OSRNEw.showPopup();
        OSRNEw.bulkapproval();
        
        
    }
    static testMethod void NewEMEAcreationforbulkApproval1(){
        ID userID = UserInfo.getUserID();
        ID recOppTypeID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID  recAccTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        ID  recOSRTypeID=Schema.SObjectType.Opportunity_Support_Request__c.getRecordTypeInfosByName().get('EMEA New Sample Product Req').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAccTypeId;
        insert acc;
      // INSERT OPPTY RECORD
       TriggerSwitch__c triSwitch = new TriggerSwitch__c();
      triSwitch.Name = 'OpportunityTrigger';
      triSwitch.isActive__c = true;
      insert triSwitch;
        Opportunity opp = TestDataUtil.createOpportunity(acc);
        opp.RecordTypeId=recOppTypeID;
        insert opp;
        GE_LGT_EM_MaterialMaster__c matrial=TestDataUtil.createMaterialMaster('99999');
        insert matrial;
        // Insert OSR
        TriggerSwitch__c trigSwitchOppReq = new TriggerSwitch__c();
        trigSwitchOppReq.Name = 'OpportunitySupportRequestTrigger';
        trigSwitchOppReq.isActive__c = true;
        insert trigSwitchOppReq;
        Opportunity_Support_Request__c osrequest = TestDataUtil.createOSR();
        osrequest.RecordTypeId=recOSRTypeID;
        osrequest.Opportunity_Name__c=opp.id;
       
        insert osrequest;
        PageReference pageRef = Page.BulkSubmitForApprovalOSR;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(osrequest);
        ApexPages.currentPage().getParameters().put('Id',opp.id);
        
        
        BulkSubmitForApprovalOSR OSRNEw=new BulkSubmitForApprovalOSR(sc);
        //OSRNEw.bulkapproval();
        OSRNEw.closePopup();
        OSRNEw.showPopup();
        //OSRNEw.bulkapproval();
        
        
    }
}
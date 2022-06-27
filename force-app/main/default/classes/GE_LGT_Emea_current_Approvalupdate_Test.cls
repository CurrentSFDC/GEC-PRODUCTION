@isTest
public class GE_LGT_Emea_current_Approvalupdate_Test {
    static testMethod void NewEMEAcreation(){
        ID userID = UserInfo.getUserID();
        ID recOppTypeID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        ID  recAccTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        ID  recOSRTypeID=Schema.SObjectType.Opportunity_Support_Request__c.getRecordTypeInfosByName().get('EMEA New Sample Product Req').getRecordTypeId();
        //Custom settings Test data creation          
        TriggerSwitch__c OSRtriggerSwitch=TestDataUtil.createTriggerSwitch('OpportunitySupportRequestTrigger',true);
        insert OSRtriggerSwitch;
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
        triggerSwitches.get('OrderTrigger').isActive__c=true;
        triggerSwitches.get('AccountTrigger').isActive__c=true;
        triggerSwitches.get('Update_Pricebook2ids').isActive__c=true;
        insert  triggerSwitches.values();
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAccTypeID;
        insert acc;
        
        Contact con = new Contact(LastName='Test AA',FirstName='FirstName',Email='andras.arva@ge.com',AccountId=acc.ID,OwnerID=userID);
        insert con;
        //Test data creation for LED pricebook
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        id  standardPb =Test.getStandardPricebookId();
        Product2 prd1 = new Product2 (Family ='Albeo',GE_LGT_Product_Line__c = 'AUTOMOTIVE',Name='Test_AA',
                                      GE_LGT_Product_Group__c='HALOGEN COMPOSITE HEADLAMPS',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        // INSERT OPPTY RECORD
        
        Opportunity opp = TestDataUtil.createOpportunity(acc);
        opp.RecordTypeId=recOppTypeId;
        
        insert opp;
        GE_LGT_EM_MaterialMaster__c matrial=TestDataUtil.createMaterialMaster('99999');
        insert matrial;
        // Insert OSR
        
        Opportunity_Support_Request__c osrequest = TestDataUtil.createOSR();
        //osrequest.RecordTypeId=recOSRTypeID;
        osrequest.Opportunity_Name__c=opp.id;
        
        osrequest.EMEA_Product_line__c='Outdoor';
        insert osrequest;
        //Create an approval request for the OSR
        List<Emea_OSR_Approving_Function__c> osrTeams=new List<Emea_OSR_Approving_Function__c>();
       
        Emea_OSR_Approving_Function__c osrApp8=new Emea_OSR_Approving_Function__c(name='Data engineers - BOM update',	Approving_Function__c='Data Engineers - N');
        osrTeams.add(osrApp8); 
        Emea_OSR_Approving_Function__c osrApp9=new Emea_OSR_Approving_Function__c(name='PM - SKU extension (indoor)',	Approving_Function__c='PM Team');
        osrTeams.add(osrApp9);
        Emea_OSR_Approving_Function__c osrApp10=new Emea_OSR_Approving_Function__c(name='PM - SKU extension (outdoor)',	Approving_Function__c='PM Team');
        osrTeams.add(osrApp10);
        Emea_OSR_Approving_Function__c osrApp11=new Emea_OSR_Approving_Function__c(name='PM - SKU identification (indoor)',	Approving_Function__c='PM Team');
        osrTeams.add(osrApp11); 
        Emea_OSR_Approving_Function__c osrApp12=new Emea_OSR_Approving_Function__c(name='PM - SKU identification (outdoor)',	Approving_Function__c='PM Team',Approving_Step_Name__c='PM - SKU identification (outdoor)');
        osrTeams.add(osrApp12);
        
        
        insert osrTeams;
        // Create an approval request for the Distributor     
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(osrequest.Id);
        
        // Submit the approval request for the Distributor  
        Approval.ProcessResult result1 = Approval.process(req1, true);      
        
        // Verify the results  
        System.assert(result1.isSuccess());
        System.assertEquals('Pending', result1.getInstanceStatus(), 'Instance Status'+result1.getInstanceStatus());
        PageReference pageRef = Page.GE_LGT_Emea_current_Approvalupdate;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(osrequest);
        ApexPages.currentPage().getParameters().put('Id',osrequest.id);
        
        
        
        GE_LGT_Emea_current_Approvalupdate OSRNEw=new GE_LGT_Emea_current_Approvalupdate(sc);
        OSRNEw.approavalfunction();
        // Approve the submitted request      
        
        // First, get the ID of the newly created item    
      
        osrequest.EMEA_Approving_Function__c='SC - A';
        Update osrequest;
        OSRNEw.approavalfunction();
      
        
        
        
    }
}
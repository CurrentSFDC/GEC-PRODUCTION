@isTest(seeAllData=false)
public class GE_LGT_NewEMEAcreation_Test1{
    static testMethod void NewEMEAcreation(){
         ID userID = UserInfo.getUserID();
         ID recOppTypeID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
         ID  recAccTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
         ID  recOSRTypeID=Schema.SObjectType.Opportunity_Support_Request__c.getRecordTypeInfosByName().get('EMEA New Sample Product Req').getRecordTypeId();
        //Custom settings data
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('AccountTrigger').isActive__c=True;
        
        insert triggerSwitches.values();
        TriggerSwitch__c OSRtriggerSwitch=TestDataUtil.createTriggerSwitch('OpportunitySupportRequestTrigger',true);
          insert OSRtriggerSwitch;
        
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
 
          Account acc=TestDataUtil.createAccount();
         acc.RecordTypeId = recAccTypeID;
        insert acc;
        
        Contact con = new Contact(LastName='Test AA',FirstName='FirstName1',Email='andras.arva@ge.com',AccountId=acc.ID,OwnerID=userID);
        insert con;
         id  standardPb =Test.getStandardPricebookId();
          Product2 prd1 = new Product2 (Family ='Albeo',GE_LGT_Product_Line__c = 'AUTOMOTIVE',Name='Test_AA',
                                      GE_LGT_Product_Group__c='HALOGEN COMPOSITE HEADLAMPS',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        // INSERT OPPTY RECORD
        Opportunity opp = new Opportunity(RecordTypeId = recOppTypeId);
        opp.Name = 'Testtandras';
        opp.StageName = 'S1 Consult';
        opp.Type='End User - Retrofit';
        opp.AccountID = acc.id;
        opp.CurrencyIsoCode ='HUF';
        opp.Probability = 10;
        opp.GE_LGT_Reason_Won_Lost__c=System.Label.Customer_Cancelled;
       
        opp.CloseDate = System.Today() + 20;
        opp.GE_LGT_SIMPLESALES__c='Yes';
        opp.GE_LGT_Utilize_Amplify_Rebate_tool__c='Yes';
        
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 40;
       
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 45;
        opp.GE_LGT_GE_Opportunity_Id__c = 'AATestID'; 
        opp.Warranty__c = 'Standard Product Warranty';   
        insert opp;
        
        // Insert OSR
        Opportunity_Support_Request__c osrequest = new Opportunity_Support_Request__c(RecordTypeId = recOSRTypeID);
        osrequest.Status__c='Not Submitted';
        osrequest.Opportunity_Name__c=opp.id;
        osrequest.use_cases__c='Test note';
        osrequest.Box_link__c='http:\\ge.com';
        osrequest.Comment_for_Legal_OSR__c='Test note';
        osrequest.Planned_duration_if_small_deployment__c='1 day';
        osrequest.Number_of_Fixtures__c=200;
        osrequest.Sub_Type__c='Agreement Request';
        osrequest.Sold_to_Account__c='Test A';
        osrequest.EMEA_Shipment_street__c='Test A';
        osrequest.EMEA_Shipment_City__c='Test A';
        osrequest.EMEA_Shipment_State_Province__c='Test A';
        osrequest.EMEA_Shipment_Zip_Postal_Code__c='Test A';
        osrequest.EMEA_Shipment_Country__c='Test A';
        osrequest.EMEA_Shipment_Mode__c='Standard';
        osrequest.Billing_address_is_same_as_shipping__c=True;
        osrequest.EMEA_Who_Pays_It__c='FOC';
        osrequest.GE_LGT_Quantity_of_Product__c=10;
        
        osrequest.EMEA_Required_Arrival_Date__c=System.Today() + 60;
        osrequest.Purpose__c='Internal Usage';
        osrequest.EMEA_Order_logic_Validation__c='xxxxxxxx';
        osrequest.EMEA_Generic_SKU__c='93011747 - OK L/1/SAMPLE';
        osrequest.EMEA_Billing_Street__c='Test A';
        osrequest.EMEA_Billing_City__c='Test A';
        osrequest.Billing_Zip_Postal_Code__c='Test A';
        osrequest.EMEA_Billing_Country__c='Test A';
        
        
        insert osrequest;
        PageReference pageRef = Page.GE_LGT_NewEMEAcreation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(osrequest);
       
        ApexPages.currentPage().getParameters().put('RecordType',recOSRTypeID);
        ApexPages.currentPage().getParameters().put('CF00Ni000000EZGnd',opp.Name);
        ApexPages.currentPage().getParameters().put('CF00Ni000000EZGnd_lkid',opp.id);
       
        GE_LGT_NewEMEAcreation OSRNEw=new GE_LGT_NewEMEAcreation(sc);
        OSRNEw.saveAndClone();
         OSRNEw.saveOSR();
        
    
    }
}
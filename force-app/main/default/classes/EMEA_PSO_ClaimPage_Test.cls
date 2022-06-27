@isTest(seeAllData=false)
public class EMEA_PSO_ClaimPage_Test {
    static testMethod void NewEMEAcreation(){
    
        TriggerSwitch__c ComplaintLineItemSetting = TestDataUtil.createTriggerSwitch('ComplaintLineItemTrigger', true);
         TriggerSwitch__c casetriggerSetting = TestDataUtil.createTriggerSwitch('CaseTrigger', true);
         insert casetriggerSetting ;
        insert ComplaintLineItemSetting ;
        ID  recAccTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        ID recOppTypeID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        Account accnt = TestDataUtil.createAccount();
        insert accnt;
        Account acc=[select id from Account where id=:accnt.id limit 1];
        system.assert(acc!=null);
        Case Caseobj=TestDataUtil.createCase(accnt);
        Caseobj.Subject='test sample data';
        insert Caseobj;
         Case Case1=[select id from Case where id=:Caseobj.id limit 1];
          system.assert(Case1!=null);
        GE_LGT_EM_ComplaintLineItem__c CLI = new GE_LGT_EM_ComplaintLineItem__c(GE_LGT_EM_Comments__c='sample data',GE_LGT_EM_CaseNumber__c=Caseobj.id,CurrencyIsoCode='USD',GE_LGT_EM_CM_DM_RO_Number__c='500',GE_LGT_EM_Status__c='002-Approved(CR/DR/RE Required)'); 
        insert CLI ;
         ApexPages.StandardController controller = new ApexPages.StandardController(CLI );
         EMEA_PSO_Claim cfsClaim=new EMEA_PSO_Claim(controller); 
         cfsClaim.saveAll();
         GE_LGT_EM_ComplaintLineItem__c testCli=[select id,GE_LGT_EM_CaseNumber__c from GE_LGT_EM_ComplaintLineItem__c where id=:CLI.id limit 1 ];
         System.assert(testCli.GE_LGT_EM_CaseNumber__c ==Case1.id);
         cfsClaim.sController=null;
          cfsClaim.saveAll();
         CLI.GE_LGT_EM_Status__c=null;
        
         ApexPages.StandardController controller1 = new ApexPages.StandardController(CLI );
         EMEA_PSO_Claim cfsClaim1=new EMEA_PSO_Claim(controller1); 
         cfsClaim1.saveAll();
    
    }
}
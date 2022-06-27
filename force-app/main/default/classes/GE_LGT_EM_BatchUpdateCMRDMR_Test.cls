@isTest
public class GE_LGT_EM_BatchUpdateCMRDMR_Test
{
    public static testmethod void compalintTest()
    {
        List<TriggerSwitch__c> switchList=TestDataUtil.insertTriggerSwitches();
        TriggerSwitch__c triggerSwitch9=TestDataUtil.createTriggerSwitch('ComplaintLineItemTrigger',true);
        switchList.add(triggerSwitch9);
        insert switchList;
        
        Account accnt = TestDataUtil.createAccount();
        insert accnt;
        
        Case Caseobj=TestDataUtil.createCase(accnt);
        Caseobj.Subject='test sample data';
        insert Caseobj;
        
        GE_LGT_EM_ComplaintLineItem__c acc  = new GE_LGT_EM_ComplaintLineItem__c(GE_LGT_EM_Comments__c='sample data',GE_LGT_EM_CaseNumber__c=Caseobj.id,CurrencyIsoCode='USD',GE_LGT_EM_CM_DM_RO_Number__c='500',GE_LGT_EM_Status__c='002-Approved(CR/DR/RE Required)'); 
        insert acc ;
        
        GE_LGT_EM_InvoiceLineItem__c newrec=new GE_LGT_EM_InvoiceLineItem__c(Name='testinvoicedata',CurrencyIsoCode='USD',GE_LGT_EM_CM_DM_RO_NO__c='5000',  GE_LGT_EM_Complaint_LineItemNo__c=acc.name);
        insert newrec; 
        newrec.GE_LGT_EM_CM_DM_RO_NO__c='1000';
        update newrec;
        
        Test.startTest();
        GE_LGT_EM_BatchUpdateCMRDMRComplaint it=new GE_LGT_EM_BatchUpdateCMRDMRComplaint();
        Database.executeBatch(it);
        Test.stopTest();
    }
}
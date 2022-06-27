@isTest
public class SAPRecordsRecycleTriggerHelper_Test
{   
    static testMethod void SAPRecordsRecycleTriggerHelp() 
    {
        test.starttest();
        SAP_Records_Recycle__c s = TestDataUtil.createSrr(); 
        insert s;
        SAP_Records_Recycle__c da = New SAP_Records_Recycle__c(); 
        da.GE_LGT_EM_SAP_Customer_Number__c = '8106131465';
        da.GE_LGT_EM_Distribution_Channel__c ='10-Consumer';
        da.GE_LGT_EM_Division__c ='10-Finished Products';
        da.GE_LGT_EM_PF_Type__c ='Z8';
        da.GE_LGT_EM_Sales_Org__c ='1CA1';
        insert da;
        System.assert(da.id !=null);
        test.stoptest();
    }
}
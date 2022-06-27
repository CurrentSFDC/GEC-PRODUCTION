@isTest
private class GE_LGT_EM_CustomerNameHeader_Test
{
    static testMethod void CustomerNameupdateUnitTest()
    {
        List<TriggerSwitch__c> switchList=TestDataUtil.insertTriggerSwitches();
        insert switchList;
        
        Test.startTest();
        GE_LGT_EM_InvoiceHeader__c newrec=new GE_LGT_EM_InvoiceHeader__c(Name='testAccountheader',CurrencyIsoCode='USD',GE_LGT_EM_Payer_SoldTo_Account_Number__c='102013');
        insert newrec;
        
        Account newacc=TestDataUtil.createAccount();
        newacc.GE_LGT_EM_SAP_Customer_Number__c='102013';
        newacc.CurrencyIsoCode='USD';
        newacc.GE_LGT_EM_Sales_Org__c=NULL;
        insert newacc;
        
        update newrec;
        
        GE_LGT_EM_BatchUpdateCustomerNameHeader it=new  GE_LGT_EM_BatchUpdateCustomerNameHeader();
        Database.BatchableContext bc;
        it.start(bc);
        List<GE_LGT_EM_InvoiceHeader__c> lsttrig=new List<GE_LGT_EM_InvoiceHeader__c>();
        lsttrig.add(newrec);
        it.execute(bc,lsttrig);
        it.finish(bc);
        Test.stopTest();
    }
}
@isTest
private class GE_LGT_EM_SAPInvoiceNumberUpdate_Test{

    static testMethod void SAPInvoiceNoUpdateUnitTest() {
    
       test.startTest();
        GE_LGT_EM_InvoiceLineItem__c newrec=new GE_LGT_EM_InvoiceLineItem__c(Name='testInvoiceLineItem',CurrencyIsoCode='USD',GE_LGT_EM_SAP_Invoice_Number__c='1102013');
        insert newrec;
        
        GE_LGT_EM_InvoiceHeader__c acc = new GE_LGT_EM_InvoiceHeader__c(Name='1140233175',CurrencyIsoCode='USD',GE_LGT_EM_SAPInvoiceNumber__c='1102013'); 
       
        insert acc ;
        
        update newrec;
        
        GE_LGT_EM_BatchUpdateSAPInvoiceNumber it=new GE_LGT_EM_BatchUpdateSAPInvoiceNumber();
        Database.BatchableContext bc;
        it.start(bc);
        List<GE_LGT_EM_InvoiceLineItem__c> lsttrig=new List<GE_LGT_EM_InvoiceLineItem__c>();
        lsttrig.add(newrec);
        it.execute(bc,lsttrig);
        it.finish(bc);
        test.stopTest();
      
    }
}
@isTest
private class GE_LGT_EM_UpdateMaterialNumber_Test
{
	static testMethod void MaterialNumberUnitTest() 
    {
		Test.startTest();
        GE_LGT_EM_InvoiceLineItem__c newrec=new GE_LGT_EM_InvoiceLineItem__c(Name='test invoice data'+'i',CurrencyIsoCode='USD',GE_LGT_EM_Customer_Material_Number__c='0456');
        insert newrec;
        
        GE_LGT_EM_MaterialMaster__c acc=TestDataUtil.createMaterialMaster('456');
        insert acc ;
        
        update newrec;
        
        GE_LGT_EM_BatchUpdateMaterialNumber it=new GE_LGT_EM_BatchUpdateMaterialNumber();
        Database.BatchableContext bc;
        it.start(bc);
        List<GE_LGT_EM_InvoiceLineItem__c> lsttrig=new List<GE_LGT_EM_InvoiceLineItem__c>();
        lsttrig.add(newrec);
        it.execute(bc,lsttrig);
        it.finish(bc);
        Test.stopTest();
    }
}
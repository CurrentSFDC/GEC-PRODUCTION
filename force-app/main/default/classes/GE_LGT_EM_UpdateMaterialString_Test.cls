@isTest
private class GE_LGT_EM_UpdateMaterialString_Test
{
    static testMethod void MaterialNumberStringUnitTest()
    {
        Test.startTest();
        GE_LGT_EM_InvoiceLineItem__c newrec=new GE_LGT_EM_InvoiceLineItem__c(Name='test invoice data',CurrencyIsoCode='USD',GE_LGT_EM_Customer_Material_Number__c='Test');
        insert newrec;
        
        GE_LGT_EM_InvoiceLineItem__c invoice=[select id,Name,GE_LGT_EM_Customer_Material_Number__c from GE_LGT_EM_InvoiceLineItem__c where id=:newrec.id];
        Set<String> lineItem_Reference1 = new Set<String>();
        system.debug('invoice----->'+invoice);
        lineItem_Reference1.add(invoice.GE_LGT_EM_Customer_Material_Number__c);
        
        GE_LGT_EM_MaterialMaster__c acc=TestDataUtil.createMaterialMaster('Test');
        insert acc ;
        
        GE_LGT_EM_MaterialMaster__c material=[select id,GE_LGT_EM_SAP_MaterialNumber__c from GE_LGT_EM_MaterialMaster__c where GE_LGT_EM_SAP_MaterialNumber__c=:lineItem_Reference1];
        system.debug('material----->'+material);
        
        invoice.GE_LGT_EM_Customer_Material_Number__c=material.GE_LGT_EM_SAP_MaterialNumber__c;
        update invoice;
        
        GE_LGT_EM_BatchUpdateMaterialNumber1 it=new GE_LGT_EM_BatchUpdateMaterialNumber1();
        Database.BatchableContext bc;
        it.start(bc);
        List<GE_LGT_EM_InvoiceLineItem__c> lsttrig=[Select id,GE_LGT_EM_Customer_Material_Number__c from GE_LGT_EM_InvoiceLineItem__c limit 200];
        lsttrig.add(newrec);
        it.execute(bc,lsttrig);
        it.finish(bc);
        Test.stopTest();
    }
}
@isTest(SeeAllData=True)
Private class GE_LGT_EM_UpdateCMRDMRComplaint_Test
{
    static testMethod void CMRDMRComplaintUnitTest() 
    {
        Test.startTest();
        Account accnt = TestDataUtil.createAccount();
        accnt.GE_LGT_EM_PF_Type__c='SP';
        insert accnt;
        
        
        Case Caseobj = TestDataUtil.createCase(accnt);
        insert Caseobj;
        
        Set<String> lineItem_Reference = new Set<String>();
        GE_LGT_EM_InvoiceLineItem__c newrec=new GE_LGT_EM_InvoiceLineItem__c(Name='testinvoicedata',CurrencyIsoCode='USD',GE_LGT_EM_CM_DM_RO_NO__c='5000');
        insert newrec;       
        
        List<GE_LGT_EM_InvoiceLineItem__c> invoice=[Select id,GE_LGT_EM_CM_DM_RO_NO__c,GE_LGT_EM_Order_Number__c from GE_LGT_EM_InvoiceLineItem__c where id=:newrec.id];
        lineItem_Reference.add(newrec.GE_LGT_EM_Complaint_LineItemNo__c); 
        
        
        GE_LGT_EM_ComplaintLineItem__c acc  = new GE_LGT_EM_ComplaintLineItem__c(GE_LGT_EM_Comments__c='sample data',GE_LGT_EM_CaseNumber__c=Caseobj.id,CurrencyIsoCode='USD',GE_LGT_EM_CM_DM_RO_Number__c='500'); 
        insert acc ;
        
        Test.setMock(WebServiceMock.class, new GE_LGT_EM_171WebServiceMockImpl_test());
        GE_LGT_EM_ComplaintLineItem__c lstComplaintItem1 =[Select id,Name from  GE_LGT_EM_ComplaintLineItem__c where id=:acc.id limit 1];
        newrec.GE_LGT_EM_Complaint_LineItemNo__c = lstComplaintItem1.Name;
        update(newrec);
        
        List<GE_LGT_EM_ComplaintLineItem__c> lstComplaintItem =[Select id,Name,GE_LGT_EM_Status__c,GE_LGT_EM_SAPInvoiceNumber__c,SAP_Order_Nr__c,GE_LGT_EM_Ref_InvoiceLineItem__c,GE_LGT_EM_CM_DM_RO_Number__c,GE_LGT_EM_CMR_DMR_RO_Number__c from  GE_LGT_EM_ComplaintLineItem__c where Name in:lineItem_Reference];
        if(newrec.GE_LGT_EM_Complaint_LineItemNo__c==acc.Name)
            acc.GE_LGT_EM_CM_DM_RO_Number__c=newrec.GE_LGT_EM_CM_DM_RO_NO__c;
        acc.GE_LGT_EM_CMR_DMR_RO_Number__c=newrec.GE_LGT_EM_Order_Number__c;
        
        update acc;
        
        GE_LGT_EM_BatchUpdateCMRDMRComplaint it=new GE_LGT_EM_BatchUpdateCMRDMRComplaint();
        Database.BatchableContext bc;
        it.start(bc);
        List<GE_LGT_EM_InvoiceLineItem__c> lsttrig=new List<GE_LGT_EM_InvoiceLineItem__c>();
        lsttrig.add(newrec);
        it.execute(bc,lsttrig);
        it.finish(bc);
        Test.stopTest();
    }
}
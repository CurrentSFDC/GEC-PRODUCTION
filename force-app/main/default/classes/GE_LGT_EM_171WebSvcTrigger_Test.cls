@isTest(SeeAllData=true)
private class GE_LGT_EM_171WebSvcTrigger_Test {
    
    private static testmethod void test() {              
        
        
        ID  recAccTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        set<string>ids=new set<string>();
        
        Test.startTest();
        
        Account ac=TestDataUtil.createAccount();
        ac.recordtypeid=recAccTypeID;
        ac.GE_LGT_EM_SAP_Customer_Number__c='302013';
        insert ac; 
        
        case c=TestDataUtil.createCase(ac);
            
        insert c;
        
        
        GE_LGT_EM_ComplaintLineItem__c cli=new GE_LGT_EM_ComplaintLineItem__c(GE_LGT_EM_Status__c='001-Open',GE_LGT_EM_Category__c='testabe',GE_LGT_EM_CaseNumber__c=c.id);
        insert cli;
        
        GE_LGT_EM_ComplaintLineItem__c listinsert=[select id,GE_LGT_EM_Status__c from GE_LGT_EM_ComplaintLineItem__c where id=:cli.id];
        
        if(listinsert.GE_LGT_EM_Status__c=='001-Open')
            ids.add(listinsert.id);
        
        system.debug('setdids---->'+ids);
        
        if(ids.size()>0) 
            Test.setMock(WebServiceMock.class, new GE_LGT_EM_171WebServiceMockImpl_test()); 
        GE_LGT_EM_CaseComplaint171Webservice.SfdcTOSapCaseComplaint171(ids);
        
        
        
        Test.stopTest();
    }  
    
    public static testmethod void afterupdatetest() {
        
        ID  recAccTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        List<GE_LGT_EM_ComplaintLineItem__c>ListUpdate=new List<GE_LGT_EM_ComplaintLineItem__c>();
        set<string>ids1=new set<string>();
        Test.startTest();
        Account ac1=TestDataUtil.createAccount();
        ac1.recordtypeid=recAccTypeID;
            ac1.GE_LGT_EM_SAP_Customer_Number__c='302013';
        insert ac1; 
        
        case c1=TestDataUtil.createCase(ac1);
        insert c1;
        
        
        GE_LGT_EM_ComplaintLineItem__c cli1=new GE_LGT_EM_ComplaintLineItem__c(GE_LGT_EM_Status__c='Open',GE_LGT_EM_Category__c='testabe',GE_LGT_EM_CaseNumber__c=c1.id);
        insert cli1;
        
        GE_LGT_EM_ComplaintLineItem__c CI=[select id,GE_LGT_EM_Doc_Type__c,GE_LGT_EM_SAPInvoiceNumber__c,GE_LGT_EM_Status__c,GE_LGT_EM_Integration_Status__c,GE_LGT_EM_CR_DR_RE_Request_Sent__c from GE_LGT_EM_ComplaintLineItem__c where id=:cli1.id];
        CI.GE_LGT_EM_Integration_Status__c='SAP Updated';
        CI.GE_LGT_EM_Status__c='002-Approved(CR/DR/RE Required)';
        CI.GE_LGT_EM_CR_DR_RE_Request_Sent__c=false;
        
        update CI;
        ids1.add(CI.id);
        CI.GE_LGT_EM_CR_DR_RE_Request_Sent__c=True;
        ListUpdate.add(CI);
        
        
        if(ids1.size()>0)
            Test.setMock(WebServiceMock.class, new GE_LGT_EM_433_WebServiceMock_test());
        GE_LGT_EM_SAPWebservice.SfdcTOSapwebservice(ids1); 
        
        
        Test.stopTest();
    }  
    
    
}
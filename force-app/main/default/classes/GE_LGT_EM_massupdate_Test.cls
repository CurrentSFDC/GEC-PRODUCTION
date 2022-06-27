@isTest
private class GE_LGT_EM_massupdate_Test 
{
    static testMethod void massedit() 
    {
        TriggerSwitch__c caseSetting = TestDataUtil.createTriggerSwitch('CaseTrigger', true);
        insert caseSetting;
        TriggerSwitch__c clswitch = TestDataUtil.createTriggerSwitch('ComplaintLineItemTrigger', true);
        insert clswitch;
        Id NE_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CaseConstants.NE_RECORD_TYPE).getRecordTypeId();
        Id SAP_RecordType = schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        
        Account acc = TestDataUtil.createAccount();
        acc.Name='testacc1';
        acc.BillingStreet='bangalore';
        acc.GE_LGT_EM_SAP_Customer_Number__c='102013';
        acc.RecordTypeid=SAP_RecordType ;
        acc.GE_LGT_EM_Sales_Org__c='2FRI';
        acc.GE_LGT_EM_Division__c='10-prod';
        acc.GE_LGT_EM_PF_Type__c='SP';
        insert acc;
        system.assertEquals('testacc1', acc.Name);
        Contact cnt = TestDataUtil.createContact(acc);
        cnt.lastName='testUser';
        insert cnt;
        system.assertEquals('testUser', cnt.lastName);
        NAServiceDummyContact__c dummyContact = new NAServiceDummyContact__c(AccountId__c = acc.Id, ContactId__c=cnt.Id);
        insert dummyContact;
        system.assertEquals(acc.Id, dummyContact.AccountId__c);
        Case Caseobj=TestDataUtil.createCase(acc);
        Caseobj.Subject=CaseConstants.SHIPPING_SUBJECT +'TestSubject';
        Caseobj.Origin = 'Web';
        Caseobj.GE_LGT_Business__c = CaseConstants.NE_RECORD_TYPE;
        Caseobj.RecordTypeId = NE_RecordType;
        Caseobj.GE_NAS_Credit_Memo__c = 'test';
        Caseobj.Credit_Amount__c = 123;
        Caseobj.GE_NAS_EmailDescription__c = 'WEB #245454- SHIPPING DISCREPANCY - Account 45656000001 Contact :AndrewLoyd E-mail :aloyd@loydselectric.com Phone :417-334-2171 PO # :132720 PickTicket # :38707071 1.Product: 68850Qty: 36RAP Qty: 2REORDER: noUOM: each/bulbType of Discrepancy: damage 2.Product: 68052Qty: 15RAP Qty: 15REORDER: noUOM: each/bulbType of Discrepancy: damage 3.Product: 68168Qty: 24RAP Qty: 4REORDER: noUOM: each/bulbType of Discrepancy: damage Comments:';
        insert Caseobj;
        system.assertEquals('Web', Caseobj.Origin);
        ApexPages.currentPage().getParameters().put('id', Caseobj.Id);
        System.currentPageReference().getParameters().put('id',Caseobj.Id);
        
        list<GE_LGT_EM_ComplaintLineItem__c>testlist=new list<GE_LGT_EM_ComplaintLineItem__c>();   
        
        GE_LGT_EM_ComplaintLineItem__c cl  = new GE_LGT_EM_ComplaintLineItem__c(GE_LGT_EM_Category__c='115-Lost in transit',GE_LGT_EM_Comments__c='sample data',GE_LGT_EM_CaseNumber__c=Caseobj.id,CurrencyIsoCode='USD',GE_LGT_EM_CM_DM_RO_Number__c='500'); 
        insert cl;
        system.assertEquals('115-Lost in transit', cl.GE_LGT_EM_Category__c);
        testlist.add(cl);
        system.debug('accsize--->'+acc.id);
        
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(testlist); 
        
        GE_LGT_EM_massupdate test1=new GE_LGT_EM_massupdate(setCon);
        test1.saveRecord();
        test1.getupdatelineItem();
        GE_LGT_EM_SAP_Authorization__c SAVar = new GE_LGT_EM_SAP_Authorization__c();
        SAVar.SAP_Username__c='GELSFDC_RFC';
        SAVar.SAP_Password__c='th66uqEs';
        SAVar.Name='th66uqEs';
        insert SAVar;
        Test.setMock(WebServiceMock.class, new GE_LGT_EM_171WebServiceMockImpl_test());
    }
}
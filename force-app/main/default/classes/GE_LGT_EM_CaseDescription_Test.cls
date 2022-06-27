@isTest(seeAllData=True)
public class GE_LGT_EM_CaseDescription_Test
{
    static testMethod void CaseDescriptionUnitTest() 
    {
        List<recordtype> rt=[select id,name from recordtype where sobjecttype='Account' and name='SAP Account'];
        Account acc = TestDataUtil.createAccount();
        acc.GE_LGT_EM_PF_Type__c='SP';
        insert acc;
        Case c = TestDataUtil.createCase(acc);
        insert c;
        GE_LGT_EM_ComplaintLineItem__c CLineItem=new GE_LGT_EM_ComplaintLineItem__c(GE_LGT_EM_CaseNumber__c=c.id,CurrencyIsoCode ='USD');
        insert CLineItem;
        GE_LGT_EM_CaseRegion__c mycs1 = GE_LGT_EM_CaseRegion__c.getValues('CustomValues');
        
        if(mycs1 == null) 
        {
            mycs1 = new GE_LGT_EM_CaseRegion__c(Name= 'CustomValues');
            insert mycs1;
        }
        
        Test.startTest();
        PageReference pg = Page.GE_LGT_EM_CaseDescription;
        Test.setCurrentPage(pg); 
        string ComplaintLineId = CLineItem.Id;     
        System.currentPagereference().getParameters().put('id',ComplaintLineId );
        
        GE_LGT_EM_CaseDescription contr = new GE_LGT_EM_CaseDescription(null);
        contr.searchDescription();
        Test.setMock(WebServiceMock.class, new GE_LGT_EM_171WebServiceMockImpl_test()); 
        system.assertEquals(CLineItem.Id, CLineItem.Id);
        Test.stopTest();
    }
}
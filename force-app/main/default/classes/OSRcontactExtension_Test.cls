@isTest(seeAllData=true)
public class OSRcontactExtension_Test 
{
    static testmethod void method()
    {
        ID recordAccTypeId = [SELECT ID FROM RECORDTYPE WHERE SOBJECTTYPE='Account' and NAME = 'End User'].ID;
        Account acc = new Account(RecordTypeId = recordAccTypeId,Name='Test Account neel 17-Feb-2014-1',GE_LGT_Vertical__c='Finan');
        acc.BillingCountry='Test';
        insert acc;
       
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Oppty Neel Test Class-17-Feb-2014-1';
        opp.StageName  = 'S1 Consult';//opp.Type = 'End User'
        opp.Type = 'End User - Retrofit';
        opp.AccountID = acc.id;//opp.RecordTypeId = recordOppTypeId;
        opp.CloseDate = System.Today() + 1;      
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;      
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
        insert opp;
        
        ID recordOSR2TypeId = [SELECT ID FROM RECORDTYPE WHERE SOBJECTTYPE='Opportunity_Support_Request__c' and NAME = 'Pricing Request'].ID;
        Opportunity_Support_Request__c osr = new Opportunity_Support_Request__c(recordTypeID = recordOSR2TypeId);
        osr.Opportunity_Name__c=opp.id;
        osr.New_Customer__c='Yes';
        osr.Status__c='Not Submitted';
        osr.Payback_in_years__c=11.0;
        insert osr;
        ApexPages.currentPage().getParameters().put('Id',osr.Id);
      
        OSRcontactExtension oce=new OSRcontactExtension(NULL);
        oce.saveAll();
        oce.cloneFun();
        oce.getSubtitle();
        oce.flag1=true;
        oce.flag2=true;
        ApexPages.currentPage().getParameters().put('Id',osr.Id);
        ApexPages.currentPage().getParameters().put('Clone','1');
        OSRcontactExtension oce1=new OSRcontactExtension(NULL);
        

        ApexPages.currentPage().getParameters().put('Clone','1');
        OSR_TAS20 tas=new OSR_TAS20(NULL);
        tas.saveAll();
        tas.getSubtitle();
        tas.flag1=true;
        tas.flag2=true;
        
    }
}
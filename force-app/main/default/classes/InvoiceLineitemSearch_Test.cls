@isTest
public class InvoiceLineitemSearch_Test 
{
    static testmethod void InsertRMALineitems()
    { 
    Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('CaseTrigger').isActive__c=true;
        insert triggerSwitches.values();
        
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        Account accVar=TestDataUtil.createAccount();
        accVar.GE_LGT_EM_SAPUniqueIdentifier__c='1230-2FR1-20-10-Z8';
        accVar.RecordTypeId=recAccTypeID;
        insert accVar;
        
        Contact ctVar=TestDataUtil.createContact(accVar);
        ctVar.firstname='Test';
        insert ctVar;
        
        //ID reccaseTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('eLight - Return').getRecordTypeId();
        Case csVar=TestDataUtil.createCase(accVar);
        //csVar.RecordTypeId = reccaseTypeID;
        csVar.Accountid=accVar.ID;
        csVar.Contactid=ctVar.id;
        csVar.Origin='Email - Dutch team';            
        csVar.Subject='Subject for Email2Case Test Class';
        csVar.Description ='Test Class for Email2Case';
        csVar.GE_NAS_Sub_Status__c='In Process';
        csVar.GE_NAS_Customer_Impact__c='1-Customer OK';
        csVar.Product_Code_1__c='Test1;Test2;test3;';
        csVar.eLight_Comments__c='Test1;Test2;test3;';
        csVar.eLight_Invoiced_Price_T__c='10;20;30;';
        csVar.eLight_Invoiced_Price_Unit_T__c='10;20;30;';
        csVar.eLight_Invoiced_UM__c='Test1;Test2;test3;';
        csVar.eLight_Invoiced_Qty_T__c='10;30;';
        csVar.eLight_Invoiced_Extended_Amount_T__c='10;20;30;';
        csVar.eLight_Return_Qty_T__c='10;20;30;';
        csVar.eLight_Return_Extended_Amount_T__c='10;20;30;';
        insert csVar;
        List<GE_LGT_EM_InvoiceLineItem__c> InvoiceList = new list<GE_LGT_EM_InvoiceLineItem__c>();
        for(Integer i=0;i<200;i++){
            GE_LGT_EM_InvoiceLineItem__c Invoice= new GE_LGT_EM_InvoiceLineItem__c();
            Invoice.GE_LGT_EM_SAP_Invoice_Number__c ='12456';
            Invoice.GE_LGT_EM_Invoiced_Quantity__c=10;
            Invoice.GE_LGT_EM_Order_Number__c ='20';
            InvoiceList.add(Invoice);
        }
        insert InvoiceList;


        //list<Product_Returns_list__c> prlists = [select id,Case__c from Product_Returns_list__c where Case__c =:csVar.id];
        //system.assertEquals(3, prlists.size());
        
        RMA__c rmVar = new RMA__c();
        rmVar.Case__c=csVar.id;
        insert rmVar;
        
        GE_NAS_RMA_Lineitem__c rmLINEVar = new GE_NAS_RMA_Lineitem__c();
        rmLINEVar.Invoiced_Price__c = 20;
        rmLINEVar.Invoiced_Qty__c = 20;
        rmLINEVar.Invoiced_Unit_Price__c = 10;
        rmLINEVar.Product_Code__c='test';
        rmLINEVar.Comments__c='test';
        rmLINEVar.Invoiced_UM__c='test';
        rmLINEVar.Invoiced_Extended_Amount__c=10;
        rmLINEVar.Return_Qty__c=10;
        rmLINEVar.GE_NAS_RMA_No__c=rmVar.id; 
        rmLINEVar.Name='test';
        Insert rmLINEVar;
        Pagereference pref=Page.InvoiceLineitemSearch;
        pref.getParameters().Put('Id',rmVar.Id);
        Test.setCurrentPage(pref);
        ApexPages.StandardController sc = new ApexPages.standardController(rmVar);
        InvoiceLineitemSearch control =new InvoiceLineitemSearch(sc);
        PageReference onLoadpageref =control.onLoadPage_Invoice();
        control.SaveRMA();
        control.searchStr = '2';
        control.searchInvoice();
        control.InvoiceSearchList[0].GE_LGT_EM_Dispute_Flag__c=true;
        control.nextcmd();
        control.lastcmd();
        control.prevcmd();
        control.firstcmd();
        control.addlines();
        PageReference pageref =control.savegtoRMA();
        control.RMAlineitemlist[0].Is_Active__c=true;
        control.DeleteRMALineitems();
        PageReference Cancelpageref =control.CancelRMA();   
        
    }
    static testmethod void InsertRMALineitemsWithoutCase()
    { 
    
        List<GE_LGT_EM_InvoiceLineItem__c> InvoiceList = new list<GE_LGT_EM_InvoiceLineItem__c>();
        for(Integer i=0;i<200;i++){
            GE_LGT_EM_InvoiceLineItem__c Invoice= new GE_LGT_EM_InvoiceLineItem__c();
            Invoice.GE_LGT_EM_SAP_Invoice_Number__c ='85456';
            Invoice.GE_LGT_EM_Invoiced_Quantity__c=10;
            Invoice.GE_LGT_EM_Order_Number__c ='20';
            InvoiceList.add(Invoice);
        }
        insert InvoiceList;
        
        RMA__c rmVar = new RMA__c();
        insert rmVar;
        
        GE_NAS_RMA_Lineitem__c rmLINEVar = new GE_NAS_RMA_Lineitem__c();
        rmLINEVar.Invoiced_Price__c = 20;
        rmLINEVar.Invoiced_Qty__c = 20;
        rmLINEVar.Invoiced_Unit_Price__c = 10;
        rmLINEVar.Product_Code__c='test';
        rmLINEVar.Comments__c='test';
        rmLINEVar.Invoiced_UM__c='test';
        rmLINEVar.Invoiced_Extended_Amount__c=10;
        rmLINEVar.Return_Qty__c=10;
        rmLINEVar.GE_NAS_RMA_No__c=rmVar.id; 
        rmLINEVar.Name='test';
        Insert rmLINEVar;
        Pagereference pref=Page.InvoiceLineitemSearch;
        pref.getParameters().Put('Id',rmVar.Id);
        Test.setCurrentPage(pref);
        ApexPages.StandardController sc = new ApexPages.standardController(rmVar);
        InvoiceLineitemSearch control =new InvoiceLineitemSearch(sc);
        PageReference onLoadpageref =control.onLoadPage_Invoice();
        control.SaveRMA();
        PageReference pageref =control.savegtoRMA();
        control.RMAlineitemlist[0].Is_Active__c=true;
        control.DeleteRMALineitems();
        PageReference Cancelpageref =control.CancelRMA();   
        
    }
}
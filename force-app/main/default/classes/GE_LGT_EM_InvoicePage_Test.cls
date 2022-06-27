@isTest
public class GE_LGT_EM_InvoicePage_Test
{
    static testmethod void testInvoice_LineItem()
    {
        TriggerSwitch__c caseSetting = TestDataUtil.createTriggerSwitch('CaseTrigger', true);
        insert caseSetting;
         TriggerSwitch__c triggerSwitch1=TestDataUtil.createTriggerSwitch('ComplaintLineItemTrigger',true);
        insert triggerSwitch1;
        PageReference pageRef = Page.GE_LGT_EM_InvoiceLineItem;
        Test.setCurrentPage(pageRef);
        
        list<GE_LGT_EM_InvoiceLineItem__c> lst_cli = new list<GE_LGT_EM_InvoiceLineItem__c>();
        list<GE_LGT_EM_InvoiceLineItem__c> lst_cli_hbp = new list<GE_LGT_EM_InvoiceLineItem__c>();
        
        lst_cli = [SELECT Id,Name FROM GE_LGT_EM_InvoiceLineItem__c LIMIT 10 ];
        id rt=Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        list<Account> acclist=new list<Account>();
        Account newacc = TestDataUtil.createAccount();
        newacc.Name='murugan';
        newacc.BillingStreet='bangalore';
        newacc.GE_LGT_EM_SAP_Customer_Number__c='102013';
        newacc.RecordTypeid=rt;
        newacc.GE_LGT_EM_Sales_Org__c='2FRI';
        newacc.GE_LGT_EM_Division__c='10-prod';
        newacc.GE_LGT_EM_PF_Type__c='SP';
        acclist.add(newacc);
        Account newaccVar = TestDataUtil.createAccount();
        newaccVar.Name='murugan';
        newaccVar.BillingStreet='bangalore';
        newaccVar.GE_LGT_EM_SAP_Customer_Number__c='1020131';
        newaccVar.RecordTypeid=rt;
        newaccVar.GE_LGT_EM_Sales_Org__c='2FRI';
        newaccVar.GE_LGT_EM_Division__c='10-prod';
        newaccVar.GE_LGT_EM_PF_Type__c='SP';
        acclist.add(newaccVar);
        insert acclist;
        
        Contact ctVar=TestDataUtil.createContact(newaccVar);
        ctVar.firstname='Test';
        insert ctVar; 
        list<Case> caselist=new list<Case>();
        ID reccaseTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('eLight - Return').getRecordTypeId();
        Case csVar=TestDataUtil.createCase(newaccVar);
        csVar.Accountid=newaccVar.ID;
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
        
        
        
        GE_LGT_EM_MaterialMaster__c Mn = TestDataUtil.createMaterialMaster('TEST123');
        Mn.GE_LGT_EM_SAP_MaterialNumber__c ='930116454';
        Mn.GE_LGT_EM_MaterialDescription__c= 'ABV101V571GV41BNW67';
        Mn.GE_LGT_EM_ProductHierarchy__c='h01234567891000';
        Mn.Level_1__c='test00-testl-1'; 
        Mn.Level_2__c='test00012-testl2-2';
        Mn.Level_3__c='test000222-testl3-3'; 
        Mn.Level_4__c='test000023311-testl4-4';
        Mn.Is_Active_Internal__c=true;
        insert Mn;
        ApexPages.currentPage().getParameters().put('id', csVar.Id);
        System.currentPageReference().getParameters().put('id',csVar.Id);
        
        
        GE_LGT_EM_InvoiceHeader__c header1 = new GE_LGT_EM_InvoiceHeader__c(GE_LGT_EM_Sales_Org__c='2FRI',GE_LGT_EM_CustomerName__c=newacc.id,name='hanu',GE_LGT_EM_Payer_SoldTo_Account_Number__c='102013');
        insert header1;
        GE_LGT_EM_InvoiceLineItem__c invlineItm = new GE_LGT_EM_InvoiceLineItem__c(GE_LGT_EM_InvoiceHeaderNumber__c=header1.id,GE_LGT_EM_Material__c=Mn.id, name='test',GE_LGT_EM_Invoiced_Quantity__c= 25.00,GE_LGT_EM_InvoicedValue__c= 100.00 );
        insert invlineItm;
        
        GE_LGT_EM_InvoiceLineItem__c invlineItm1 = new GE_LGT_EM_InvoiceLineItem__c(GE_LGT_EM_InvoiceHeaderNumber__c=header1.id,GE_LGT_EM_Material__c=Mn.id, name='test',GE_LGT_EM_Invoiced_Quantity__c= 25.00,GE_LGT_EM_InvoicedValue__c= 100.00 );
        insert invlineItm1;
        lst_cli_hbp.add(invlineItm);
        id devRecordTypeId =Schema.SObjectType.GE_LGT_EM_ComplaintLineItem__c.getRecordTypeInfosByName().get('Complaint Line Items').getRecordTypeId();     
        
        GE_LGT_EM_ComplaintLineItem__c clvar  = new GE_LGT_EM_ComplaintLineItem__c();
        clvar.GE_LGT_EM_CaseNumber__c=csVar.id;
        clvar.CurrencyIsoCode='USD';
        clvar.GE_LGT_EM_CM_DM_RO_Number__c='500'; 
        clvar.RecordTypeId =devRecordTypeId;
        clvar.GE_LGT_EM_Ref_InvoiceLineItem__c=invlineItm.id;
        clvar.GE_LGT_EM_InvoicedQuantity__c=invlineItm.GE_LGT_EM_Invoiced_Quantity__c;
        insert clvar;    
        GE_LGT_EM_SAP_Authorization__c SAVar = new GE_LGT_EM_SAP_Authorization__c();
        SAVar.SAP_Username__c='GELSFDC_RFC';
        SAVar.SAP_Password__c='th66uqEs';
        SAVar.Name='th66uqEs';
        insert SAVar;
        Test.setMock(WebServiceMock.class, new GE_LGT_EM_171WebServiceMockImpl_test());                                
        test.startTest();
        String qry = 'select Name,GE_LGT_EM_SAP_Invoice_Number__c,CurrencyIsoCode,GE_LGT_EM_Order_Number__c,GE_LGT_EM_Invoiced_Price_Unit__c,GE_LGT_EM_InvoicedValue__c,GE_LGT_EM_Invoiced_Quantity__c,GE_LGT_EM_Category__c,GE_LGT_EM_Delivery_Plant__c,GE_LGT_EM_SAP_LineItemNumber__c,GE_LGT_EM_Material__r.GE_LGT_EM_SAP_MaterialNumber__c from GE_LGT_EM_InvoiceLineItem__c where id in(SELECT GE_LGT_EM_Ref_InvoiceLineItem__c FROM GE_LGT_EM_ComplaintLineItem__c where GE_LGT_EM_CaseNumber__c='+'\''+csVar.Id+'\') Limit 2000' ;
        GE_LGT_EM_CustomIterable pgn = new GE_LGT_EM_CustomIterable(qry);
        
        ApexPages.StandardSetController ssc = new ApexPages.Standardsetcontroller(lst_cli_hbp);
        GE_LGT_EM_InvoiceLineItem_Cls invoiceobj = new  GE_LGT_EM_InvoiceLineItem_Cls(ssc);
        invoiceobj.obj=new GE_LGT_EM_CustomIterable(qry);
        invoiceobj.Invoice_id=invlineItm.id;
        invoiceobj.category_id=clvar.id;
        invoiceobj.contextItem=invlineItm.id;
        invoiceobj.save_categary(); 
        invoiceobj.doSelectItem();
        invoiceobj.processSelected();
        invoiceobj.getcatInnerObj();
        invoiceobj.BackToParent();
        invoiceobj.doDeselectItem();
        invoiceobj.Search();
        invoiceobj.save_categary();
        invoiceobj.settxtSAPNo('Test');
        string test1=invoiceobj.gettxtSAPNo();
        invoiceobj.Search();
        pgn.hasNext();
        pgn.hasPrevious();
        pgn.next();
        pgn.hasNext();
        pgn.hasPrevious();
        pgn.next();
        Test.stopTest();
    }
}
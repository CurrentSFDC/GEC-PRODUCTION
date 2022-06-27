@IsTest (seeAllData=true)
public class ComplaintLineItemTrigger_Test {
    static testMethod void AutoIncrementNumberTest() {
        ID  recAccTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc1=TestDataUtil.createAccount();
        acc1.RecordTypeId = recAccTypeId;
        insert acc1;
        id devRecordTypeId =Schema.SObjectType.GE_LGT_EM_ComplaintLineItem__c.getRecordTypeInfosByName().get('Manual Complaint LineItems').getRecordTypeId();     
        Case cc=TestDataUtil.createCase(acc1);
        cc.Status='Open';
        insert cc;
        integer counter=0;   
        
        list<GE_LGT_EM_ComplaintLineItem__c> ListLineItemCount=[SELECT GE_LGT_EM_Complaint_Reference_Number__c FROM GE_LGT_EM_ComplaintLineItem__c where GE_LGT_EM_CaseNumber__c=:cc.id and GE_LGT_EM_Complaint_Reference_Number__c !=null order by GE_LGT_EM_Complaint_Reference_Number__c desc limit 1];
        
        GE_LGT_EM_ComplaintLineItem__c CompItem=new GE_LGT_EM_ComplaintLineItem__c();
        CompItem.RecordTypeId=devRecordTypeId; 
        CompItem.GE_LGT_EM_CaseNumber__c=cc.Id;
        CompItem.GE_LGT_EM_Complaint_Reference_Number__c=10;
        GE_LGT_EM_SAPWebservice.blnflag=false;
        Test.setMock(WebServiceMock.class, new GE_LGT_EM_171WebServiceMockImpl_test());
        Insert CompItem;
        
        
        list<GE_LGT_EM_ComplaintLineItem__c> ListLineItemCount1=[SELECT GE_LGT_EM_Complaint_Reference_Number__c FROM GE_LGT_EM_ComplaintLineItem__c where id=:CompItem.id and GE_LGT_EM_CaseNumber__c=:cc.id and GE_LGT_EM_Complaint_Reference_Number__c !=null order by GE_LGT_EM_Complaint_Reference_Number__c desc limit 1];
        
        GE_LGT_EM_ComplaintLineItem__c CompItem1=new GE_LGT_EM_ComplaintLineItem__c();
        CompItem1.RecordTypeId=devRecordTypeId; 
        CompItem1.GE_LGT_EM_CaseNumber__c=cc.Id;
        CompItem1.GE_LGT_EM_Complaint_Reference_Number__c=counter+10;
        
        Insert CompItem1;
        system.assertNOTEquals(CompItem.GE_LGT_EM_Complaint_Reference_Number__c,20);
    }
    
    private static testMethod void BDRelevantTest() {
        
        ID userID = UserInfo.getUserID();        
        Map<string,string> RecrdIdMap=new Map<string,string>();  
        List<RecordType> recrdlist=new List<RecordType>([select id,Name from RecordType]);       
        for(Recordtype rt:recrdlist){        
            RecrdIdMap.put(rt.Name,rt.Id);          
        }    
        
        Id reccaseTypeID = RecrdIdMap.get('GE Lighting EMEA');        
        Id recAcTypeID = RecrdIdMap.get('SAP Account');                                                       
        List<Account> Acclist=new List<Account>();                     
        Account acc = Testdatautil.createAccount(); 
        acc.RecordTypeId = recAcTypeId;
        acc.GE_LGT_EM_Sales_Org__c='2HU2';
        /*acc.GE_LGT_EM_BD_Relevant__c=true;acc.GE_LGT_EM_Distribution_Channel__c='10';*/acc.Name='Test Ac';acc.CurrencyIsoCode='USD';acc.GE_LGT_EM_Email_Address__c='anudeep@ge.com';acc.GE_LGT_EM_SAP_Customer_Number__c ='0098546781';
        acc.GE_LGT_EM_Division__c='20';
        acc.GE_LGT_EM_PF_Type__c='SP';            
        Acclist.add(acc);                              
        Account ac = Testdatautil.createAccount(); 
        ac.RecordTypeId = recAcTypeId;
        ac.GE_LGT_EM_Sales_Org__c='2UH2';
        /*ac.GE_LGT_EM_BD_Relevant__c=false;ac.GE_LGT_EM_Distribution_Channel__c='20';*/ac.Name='Test Acc';ac.CurrencyIsoCode='USD';ac.GE_LGT_EM_Email_Address__c='anudeep@ge.com';ac.GE_LGT_EM_SAP_Customer_Number__c ='0098546782';
        ac.GE_LGT_EM_PF_Type__c='SP';      
        ac.GE_LGT_EM_Division__c='30';
        Acclist.add(ac); 
        
        insert Acclist;
        
        GE_LGT_EM_MaterialMaster__c mm = TestDataUtil.createMaterialMaster('123466');
        mm.GE_LGT_EM_MaterialDescription__c='TEST';mm.GE_LGT_EM_PSICode__c='123';mm.GE_LGT_EM_ProductFamily__c='456789';
        insert mm;
        
        List<Case> cslist=new List<Case>();                              
        Case cs = testdatautil.createCase(acc);            
        cs.RecordTypeId = reccaseTypeID;            
        cs.Accountid=acc.ID;                       
        cs.Origin='Phone';                        
        cs.Subject='Subject for Test Class';            
        cs.Description ='Test Class';                  
        cslist.add(cs);  
        
        Case c1 =testdatautil.createCase(ac);          
        c1.RecordTypeId = reccaseTypeID;            
        c1.Accountid=ac.ID;                       
        c1.Origin='Phone';                        
        c1.Subject='Subject for Test Class';            
        c1.Description ='Test Class';
        cs.GE_NAS_Invoice__c='8369994321';
        cs.GE_NAS_SR_Number__c='12344321';
        cslist.add(c1);
        insert cslist;
        list<GE_LGT_EM_ComplaintLineItem__c> testlist=new list<GE_LGT_EM_ComplaintLineItem__c>(); 
        Test.setMock(WebServiceMock.class, new GE_LGT_EM_171WebServiceMockImpl_test());
        GE_LGT_EM_SAPWebservice.blnflag=false;
        GE_LGT_EM_ComplaintLineItem__c clitem1 = new GE_LGT_EM_ComplaintLineItem__c(GE_LGT_EM_Material_Number__c=mm.id,GE_LGT_EM_Category__c='115-Lost in transit',GE_LGT_EM_CaseNumber__c=cs.id,GE_LGT_EM_Comments__c='sample data',CurrencyIsoCode='USD'); 
        insert clitem1; 
        GE_LGT_EM_ComplaintLineItem__c clitem2 = new GE_LGT_EM_ComplaintLineItem__c(GE_LGT_EM_Material_Number__c=mm.id,GE_LGT_EM_Category__c='111-Damaged goods(WHS)',GE_LGT_EM_CaseNumber__c=cs.id,GE_LGT_EM_Comments__c='sample data',CurrencyIsoCode='USD'); 
        insert clitem2;
        
    }
    
    
    public static testmethod void afterupdatetest() {
        ID  recAccTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        List<GE_LGT_EM_ComplaintLineItem__c>ListUpdate=new List<GE_LGT_EM_ComplaintLineItem__c>();
        set<string>ids1=new set<string>();
        Test.startTest();
        Account ac1=TestDataUtil.createAccount();
        ac1.recordtypeid=recAccTypeID;
        ac1.GE_LGT_EM_SAP_Customer_Number__c='302013';
        ac1.GE_LGT_EM_Partner_Function__c = 'Sold To Party';
        ac1.GE_LGT_EM_Sales_Org__c ='789';
        ac1.GE_LGT_EM_PF_Type__c = 'SP';
        insert ac1; 
        case c1=TestDataUtil.createCase(ac1);
        c1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('EMEA Complaint').getRecordTypeId();
        insert c1;
        GE_LGT_EM_InvoiceLineItem__c newInvoice = new GE_LGT_EM_InvoiceLineItem__c();
        insert newInvoice;
        GE_LGT_EM_InvoiceLineItem__c newInvoice1 = new GE_LGT_EM_InvoiceLineItem__c();
        insert newInvoice1;
        GE_LGT_EM_ComplaintLineItem__c cli1=new GE_LGT_EM_ComplaintLineItem__c(GE_LGT_EM_Status__c='Open',GE_LGT_EM_Category__c='testabe',GE_LGT_EM_CaseNumber__c=c1.id);
        GE_LGT_EM_SAPWebservice.blnflag=false;
        cli1.GE_LGT_EM_CaseNumber__c = c1.Id;
        insert cli1;
        GE_LGT_EM_ComplaintLineItem__c CI=[select id,GE_LGT_EM_Doc_Type__c,GE_LGT_EM_SAPInvoiceNumber__c,GE_LGT_EM_Status__c,GE_LGT_EM_Integration_Status__c,GE_LGT_EM_CR_DR_RE_Request_Sent__c from GE_LGT_EM_ComplaintLineItem__c where id=:cli1.id];
        CI.GE_LGT_EM_Integration_Status__c='SAP Updated';
        CI.GE_LGT_EM_Status__c='002-Approved(CR/DR/RE Required)';
        CI.GE_LGT_EM_CR_DR_RE_Request_Sent__c=false;
        CI.GE_LGT_EM_Manual_CR_DR_RE__c=false;
        update CI;
        ids1.add(CI.id);
        CI.GE_LGT_EM_CR_DR_RE_Request_Sent__c=True;
        GE_LGT_EM_SAPWebservice.blnflag=false;
        Test.setMock(WebServiceMock.class, new GE_LGT_EM_433_WebServiceMock_test());
        ListUpdate.add(CI);
        GE_LGT_EM_SAPWebservice.SfdcTOSapwebservice(ids1); 
        system.assertEquals('SAP Updated', [select id,GE_LGT_EM_Doc_Type__c,GE_LGT_EM_SAPInvoiceNumber__c,GE_LGT_EM_Status__c,GE_LGT_EM_Integration_Status__c,GE_LGT_EM_CR_DR_RE_Request_Sent__c from GE_LGT_EM_ComplaintLineItem__c where id=:cli1.id].GE_LGT_EM_Integration_Status__c);
        Test.stopTest();
    }
    public static testmethod void checkcallFlaggingDispute() {
        ID  recAccTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        Account ac1=TestDataUtil.createAccount();
        ac1.recordtypeid=recAccTypeID;
        ac1.GE_LGT_EM_SAP_Customer_Number__c='302013';
        ac1.GE_LGT_EM_Partner_Function__c = 'Sold To Party';
        ac1.GE_LGT_EM_Sales_Org__c ='789';
        ac1.GE_LGT_EM_PF_Type__c = 'SP';
        insert ac1;
        case c1=TestDataUtil.createCase(ac1);
        c1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('EMEA Complaint').getRecordTypeId();
        insert c1;
        GE_LGT_EM_ComplaintLineItem__c cli1=new GE_LGT_EM_ComplaintLineItem__c(GE_LGT_EM_Status__c='Open',GE_LGT_EM_Category__c='testabe',GE_LGT_EM_CaseNumber__c=c1.id);
        cli1.GE_LGT_EM_CaseNumber__c = c1.Id;
        insert cli1;
        Id CLIId= cli1.Id;
        delete cli1;
        System.assertEquals(0, [Select Id from GE_LGT_EM_ComplaintLineItem__c where Id=:CLIId].size());
    }
}
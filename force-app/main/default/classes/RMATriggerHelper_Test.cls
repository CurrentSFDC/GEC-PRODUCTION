@isTest
public class RMATriggerHelper_Test 
{
   static testmethod void insertRMAValidation()
    {
        RMATriggerHelper.createRMAMultipleChildRecords();
    }
    
  /*  static testmethod void insertRMAValidation()
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

        //list<Product_Returns_list__c> prlists = [select id,Case__c from Product_Returns_list__c where Case__c =:csVar.id];
        //system.assertEquals(3, prlists.size());
        
        RMA__c rmVar = new RMA__c();
        rmVar.Case__c=csVar.id;
        insert rmVar;
        
        list<GE_NAS_RMA_Lineitem__c> rmalists = [select id,GE_NAS_RMA_No__c  from GE_NAS_RMA_Lineitem__c where GE_NAS_RMA_No__c =:rmVar.id];
        //system.assertEquals(3, rmalists.size());   is down due to trigger
        system.assertEquals(0, rmalists.size());
    }
    static testmethod void UpdateRMAValidation()
    { 
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('CaseTrigger').isActive__c=true;
        insert triggerSwitches.values();
        
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        Account actVar=TestDataUtil.createAccount();
        actVar.GE_LGT_EM_SAPUniqueIdentifier__c='12301-2FR1-20-10-Z8';
        actVar.RecordTypeId=recAccTypeID;
        insert actVar;
        
        Contact ctVar=TestDataUtil.createContact(actVar);
        ctVar.firstname='Test';
        insert ctVar;
        
        //ID reccaseTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('eLight - Return').getRecordTypeId(); //eLight - Return
        Case caseVar=TestDataUtil.createCase(actVar);
        //caseVar.RecordTypeId = reccaseTypeID;
        caseVar.Accountid=actVar.ID;
        caseVar.Contactid=ctVar.id;
        caseVar.Origin='Email - Dutch team';            
        caseVar.Subject='Subject for Email2Case Test Class';
        caseVar.Description ='Test Class for Email2Case';
        caseVar.GE_NAS_Sub_Status__c='In Process';
        caseVar.GE_NAS_Customer_Impact__c='1-Customer OK';
        caseVar.Product_Code_1__c='Test_Product1;Test_Product2;Test_Product3;';
        caseVar.eLight_Comments__c='TestComment1;TestComment2;TestComment3;';
        caseVar.eLight_Invoiced_Price_T__c='10;20;30;';
        caseVar.eLight_Invoiced_Price_Unit_T__c='10;20;30;';
        caseVar.eLight_Invoiced_UM__c='Test1;Test2;test3;';
        caseVar.eLight_Invoiced_Qty_T__c='10;30;';
        caseVar.eLight_Invoiced_Extended_Amount_T__c='10;20;30;';
        caseVar.eLight_Return_Qty_T__c='10;20;30;';
        caseVar.eLight_Return_Extended_Amount_T__c='10;20;30;';
        insert caseVar;
        // list<Product_Returns_list__c> prlist = [select id,Case__c from Product_Returns_list__c where Case__c =:caseVar.id];
        // system.assertEquals(3, prlist.size());
        
        //ID reccaserTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('eLight - Return').getRecordTypeId();
        Case cVar=TestDataUtil.createCase(actVar);
        //cVar.RecordTypeId = reccaserTypeID;
        cVar.Accountid=actVar.ID;
        cVar.Contactid=ctVar.id;
        cVar.GE_NAS_Sub_Status__c='In Process';
        cVar.GE_NAS_Customer_Impact__c='1-Customer OK';
        cVar.Product_Code_1__c='TestProductcase';
        cVar.GE_NAS_SR_Number__c='12345567';
        cVar.eLight_Comments__c='Testcasecomment';
        cVar.eLight_Invoiced_Price_T__c='10';
        cVar.eLight_Invoiced_Price_Unit_T__c='10';
        cVar.eLight_Invoiced_UM__c='Test1';
        cVar.eLight_Invoiced_Qty_T__c='10';
        cVar.eLight_Invoiced_Extended_Amount_T__c='10';
        cVar.eLight_Return_Qty_T__c='10';
        cVar.eLight_Return_Extended_Amount_T__c='10';
        insert cVar;
        
        // list<Product_Returns_list__c> prlists = [select id,Case__c from Product_Returns_list__c where Case__c =:cVar.id];
        // system.assertEquals(1, prlists.size());
         
        
        RMA__c rmVar = new RMA__c(Case__c=caseVar.id);
        insert rmVar;
        
        list<GE_NAS_RMA_Lineitem__c> rmalists = [select id,GE_NAS_RMA_No__c  from GE_NAS_RMA_Lineitem__c where GE_NAS_RMA_No__c =:rmVar.id];
        //system.assertEquals(3, rmalists.size()); is down due to trigger
        system.assertEquals(0, rmalists.size());
        RMA__c rmV = new RMA__c();
        rmV.Case__c=caseVar.id;
        insert rmV;
        
        
        list<GE_NAS_RMA_Lineitem__c> rmalist = [select id,GE_NAS_RMA_No__c  from GE_NAS_RMA_Lineitem__c where GE_NAS_RMA_No__c =:rmV.id];
        //system.assertEquals(3, rmalist.size());
        system.assertEquals(0, rmalist.size());
        rmV.Case__c=cVar.id;
        update rmV;
        
        rmalist = [select id,GE_NAS_RMA_No__c  from GE_NAS_RMA_Lineitem__c where GE_NAS_RMA_No__c =:rmV.id];
        //system.assertEquals(1, rmalist.size());
        system.assertEquals(0, rmalist.size());
    }
    static testmethod void BulkInsertionRMA()
    { 
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('CaseTrigger').isActive__c=true;
        insert triggerSwitches.values();
        
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        Account actVar=TestDataUtil.createAccount();
        actVar.GE_LGT_EM_SAPUniqueIdentifier__c='12302-2FR1-20-10-Z8';
        actVar.RecordTypeId=recAccTypeID;
        insert actVar;
        
        Contact cVar=TestDataUtil.createContact(actVar);
        cVar.firstname='Test';
        insert cVar;
        
        //ID reccaseTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('eLight - Return').getRecordTypeId(); //eLight - Return
        Case caseVar=TestDataUtil.createCase(actVar);
        //caseVar.RecordTypeId = reccaseTypeID;
        caseVar.Accountid=actVar.ID;
        caseVar.Contactid=cVar.id;
        caseVar.Status='Open';
        caseVar.Origin='Email';            
        caseVar.Subject='Subject for Email2Case Test Class';
        caseVar.Description ='Test Class for Email2Case';
        caseVar.GE_NAS_Sub_Status__c='In Process';
        caseVar.GE_NAS_Customer_Impact__c='1-Customer OK';
        caseVar.Product_Code_1__c='Test_Product1;Test_Product2;Test_Product3;';
        caseVar.eLight_Comments__c='TestComment1;TestComment2;TestComment3;';
        caseVar.eLight_Invoiced_Price_T__c='10;20;30;';
        caseVar.eLight_Invoiced_Price_Unit_T__c='10;20;30;';
        caseVar.eLight_Invoiced_UM__c='Test1;Test2;test3;';
        caseVar.eLight_Invoiced_Qty_T__c='10;30;';
        caseVar.eLight_Invoiced_Extended_Amount_T__c='10;20;30;';
        caseVar.eLight_Return_Qty_T__c='10;20;30;';
        caseVar.eLight_Return_Extended_Amount_T__c='10;20;30;';
        insert caseVar;
        // list<Product_Returns_list__c> prlist = [select id,Case__c from Product_Returns_list__c where Case__c =:caseVar.id];
        // system.assertEquals(3, prlist.size());
        
         
        List<RMA__c> RMA_List = new List<RMA__c>();
        for (Integer r = 0; r< 10; r++) {
            RMA__c rmVar = new RMA__c(Case__c=caseVar.id);
            RMA_List.add(rmVar);
        system.debug('RMA inserted:'+r);
        }
        insert RMA_List;
        //list<GE_NAS_RMA_Lineitem__c> rmalists = [select id,GE_NAS_RMA_No__c  from GE_NAS_RMA_Lineitem__c where GE_NAS_RMA_No__c IN:RMA_List];
        //system.assertEquals(30, rmalists.size());  commented out as per API version cleanup 
        //since the trigger that makes the multiply is inactivated in 12.19.2017 by Satish  
        
         list<RMA__c> rmalists = [select id from RMA__c where Case__c =:caseVar.id];
         system.assertEquals(10, rmalists.size());
    }
    
    static testmethod void DeleteRMARecord()
    { 
        Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('CaseTrigger').isActive__c=true;
        insert triggerSwitches.values();
        
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        Account actVar=TestDataUtil.createAccount();
        actVar.GE_LGT_EM_SAPUniqueIdentifier__c='12303-2FR1-20-10-Z8';
        actVar.RecordTypeId=recAccTypeID;
        insert actVar;
        
        Contact cVar=TestDataUtil.createContact(actVar);
        cVar.firstname='Test';
        insert cVar;
        
        //ID reccaseTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('eLight - Return').getRecordTypeId(); //eLight - Return
        Case caseVar=TestDataUtil.createCase(actVar);
        //caseVar.RecordTypeId = reccaseTypeID;
        caseVar.Accountid=actVar.ID;
        caseVar.Contactid=cVar.id;
        caseVar.Origin='Email - Dutch team';            
        caseVar.Subject='Subject for Email2Case Test Class';
        caseVar.Description ='Test Class for Email2Case';
        caseVar.GE_NAS_Sub_Status__c='In Process';
        caseVar.GE_NAS_Customer_Impact__c='1-Customer OK';
        caseVar.Product_Code_1__c='Test_Product1;Test_Product2;Test_Product3;';
        caseVar.eLight_Comments__c='TestComment1;TestComment2;TestComment3;';
        caseVar.eLight_Invoiced_Price_T__c='10;20;30;';
        caseVar.eLight_Invoiced_Price_Unit_T__c='10;20;30;';
        caseVar.eLight_Invoiced_UM__c='Test1;Test2;test3;';
        caseVar.eLight_Invoiced_Qty_T__c='10;30;';
        caseVar.eLight_Invoiced_Extended_Amount_T__c='10;20;30;';
        caseVar.eLight_Return_Qty_T__c='10;20;30;';
        caseVar.eLight_Return_Extended_Amount_T__c='10;20;30;';
        insert caseVar;
        // list<Product_Returns_list__c> prlist = [select id,Case__c from Product_Returns_list__c where Case__c =:caseVar.id];
        // system.assertEquals(3, prlist.size());

        RMA__c rmVar = new RMA__c(Case__c=caseVar.id);
        insert rmVar;
        
        list<GE_NAS_RMA_Lineitem__c> rmalists = [select id,GE_NAS_RMA_No__c  from GE_NAS_RMA_Lineitem__c where GE_NAS_RMA_No__c =:rmVar.id];
//      system.assertEquals(3, rmalists.size()); is down because of the RMA trigger
        system.assertEquals(0, rmalists.size());
        Delete rmVar;
        system.assertEquals(0, [select id from RMA__c].size());
        
    }*/
}
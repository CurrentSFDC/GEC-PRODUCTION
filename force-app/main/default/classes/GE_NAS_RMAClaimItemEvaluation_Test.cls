@isTest
public class GE_NAS_RMAClaimItemEvaluation_Test{

    public static testMethod void RMAClaimItemEvaluation_Test(){
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
        
        ID reccaseTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('eLight - Return').getRecordTypeId();
        Case csVar=TestDataUtil.createCase(accVar);
        csVar.RecordTypeId = reccaseTypeID;
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
        
        GE_NAS_RMA_Item_Evaluation__c RIE_Var = new GE_NAS_RMA_Item_Evaluation__c(GE_NAS_RMA_Lineitem_Number__c=rmLINEVar.id,GE_NAS_Delete__c=true);
        insert RIE_Var;
        
        ApexPages.StandardController Con=new ApexPages.StandardController(rmLINEVar);
        GE_NAS_RMAClaimItemEvaluation rmaET= new GE_NAS_RMAClaimItemEvaluation(Con);
        rmaET.addLine();
        rmaET.deleteLine();
        rmaET.saveEval();
    }
}
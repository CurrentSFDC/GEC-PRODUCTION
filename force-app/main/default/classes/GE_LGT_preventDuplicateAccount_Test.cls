@isTest
public class GE_LGT_preventDuplicateAccount_Test
{   
    static testMethod void dupAcountCheck() 
    {
        ID recEDurypeID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account a = New Account();
        a.Name = 'msat';
        a.type= 'End User'; 
        a.GE_LGT_Vertical__c = 'Ed'; 
        a.Site = 'Mayfield';
        a.GE_LGT_EM_SAP_Customer_Number__c='999999';
        a.GE_LGT_EM_Sales_Org__c='1US1';
        a.GE_LGT_EM_Division__c='10';
        a.GE_LGT_EM_Distribution_Channel__c='20-Prof';
        a.GE_LGT_Rep_Code__c='0003rgd';
        a.GE_LGT_District_Manager__c='101013280';
        a.GE_LGT_FAM_AM__c='101013280';
        a.GE_LGT_Regional_Manager__c='101013280';        
        insert a;
        
        Account aDupe = new Account();
        aDupe.Name  = 'msat12';
        aDupe.type= 'End User'; 
        aDupe.GE_LGT_Vertical__c = 'Ed';
        aDupe.Site = 'Mayfield123';
        aDupe.GE_LGT_EM_SAP_Customer_Number__c='999999';
        aDupe.GE_LGT_EM_Sales_Org__c='1US1';
        aDupe.GE_LGT_EM_Division__c='10';
        aDupe.GE_LGT_EM_Distribution_Channel__c='20-Prof';
        aDupe.GE_LGT_District_Manager__c=NULL;
        aDupe.GE_LGT_FAM_AM__c=NULL;
        aDupe.GE_LGT_Regional_Manager__c=NULL;            
        insert aDupe;
        
        Account aDupe1 = new Account();
        aDupe1.Name  = 'msat890';
        aDupe1.type= 'End User'; 
        aDupe1.GE_LGT_Vertical__c = 'Ed';
        aDupe1.Site = 'Mayfield123';
        aDupe1.GE_LGT_EM_SAP_Customer_Number__c='8106131465';
        aDupe1.GE_LGT_EM_Sales_Org__c='1US1';
        aDupe1.GE_LGT_EM_Division__c='10';
        aDupe1.GE_LGT_EM_Distribution_Channel__c='20-Prof';
        aDupe1.RecordTypeid=recEDurypeID;
        aDupe1.Act_Converted_to_End_User__c=true;
        aDupe1.BillingCountry='United States';
        insert aDupe1;
        
        delete aDupe1;
        
    }
    static testMethod void insertAgentAcountCheck() 
    {
        Account a = New Account();
        a.Name = 'msat';
        a.type= 'End User'; 
        a.GE_LGT_Vertical__c = 'Ed'; 
        a.GE_LGT_EM_SAPUniqueIdentifier__c='999999-1US1-10-Z4';
        a.GE_LGT_EM_SAP_Customer_Number__c='999999';
        a.GE_LGT_EM_Sales_Org__c='1US1';
        a.GE_LGT_Rep_Code__c='501';
        a.GE_LGT_EM_Division__c='10';
        a.GE_LGT_EM_Distribution_Channel__c='20-Prof';
        a.GE_LGT_District_Manager__c='101013280';
        a.GE_LGT_FAM_AM__c='101013280';
        a.GE_LGT_Regional_Manager__c='101013280'; 
        a.Owner_SSO__c='101013280';     
        a.GE_LGT_EM_PF_Type__c='Z4';  
        a.Account_Group__c='test';
        a.GE_LGT_Sales_Group__c='test12';
        a.GE_LGT_Sales_Office__c='test13';  
        a.SAP_Fixture_Code__c='test';        
        insert a;
        a.GE_LGT_District_Manager__c=NULL;
        a.GE_LGT_FAM_AM__c=NULL;
        a.GE_LGT_Regional_Manager__c=NULL;   
        a.Owner_SSO__c=NULL;   
        a.Name = 'msat-test';  
        a.GE_LGT_Sales_Group__c='testz';
        a.GE_LGT_Sales_Office__c='testy';  
        a.SAP_Fixture_Code__c='testx';                       
        update a;
        a.GE_LGT_District_Manager__c='NotValidSSO';
        a.GE_LGT_FAM_AM__c='NotValidSSO';
        a.GE_LGT_Regional_Manager__c='NotValidSSO';   
        a.Owner_SSO__c='NotValidSSO';   
        a.Name = 'msat-test2';          
    }
    static testMethod void accountLovTestNAS()
    {
        List<GE_NAS_List_of_Value__c> lov_list=new List<GE_NAS_List_of_Value__c>();
        GE_NAS_List_of_Value__c lov1=new GE_NAS_List_of_Value__c();
        lov1.Name='GE_NAS_National_Type';
        lov1.GE_NAS_Code_Value__c='NA';
        lov1.GE_NAS_Object__c='Account';
        lov1.GE_NAS_Val__c='National';
        lov_list.add(lov1);
        
        GE_NAS_List_of_Value__c lov2=new GE_NAS_List_of_Value__c();
        lov2.Name='GE_NAS_Account_status';
        lov2.GE_NAS_Code_Value__c='I';
        lov2.GE_NAS_Object__c='Account';
        lov2.GE_NAS_Val__c='In Active';
        lov_list.add(lov2);
        
        GE_NAS_List_of_Value__c lov3=new GE_NAS_List_of_Value__c();
        lov3.Name='GE_NAS_GE_Business_Code';
        lov3.GE_NAS_Code_Value__c='CA';
        lov3.GE_NAS_Object__c='Account';
        lov3.GE_NAS_Val__c='Canada';
        lov_list.add(lov3);
        
        GE_NAS_List_of_Value__c lov4=new GE_NAS_List_of_Value__c();
        lov4.Name='GE_NAS_Language';
        lov4.GE_NAS_Code_Value__c='E';
        lov4.GE_NAS_Object__c='Account';
        lov4.GE_NAS_Val__c='English';
        lov_list.add(lov4);
        
        
        GE_NAS_List_of_Value__c lov5=new GE_NAS_List_of_Value__c();
        lov5.Name='GE_NAS_Shipping_Type';
        lov5.GE_NAS_Code_Value__c='R';
        lov5.GE_NAS_Object__c='Account';
        lov5.GE_NAS_Val__c='R - Retail Store Door Delivery';
        lov_list.add(lov5);
        
        
        GE_NAS_List_of_Value__c lov7=new GE_NAS_List_of_Value__c();
        lov7.Name='GE_NAS_Shipping_Schedule';
        lov7.GE_NAS_Code_Value__c='2';
        lov7.GE_NAS_Object__c='Account';
        lov7.GE_NAS_Val__c='Tuesday';
        lov_list.add(lov7);
        
        GE_NAS_List_of_Value__c lov8=new GE_NAS_List_of_Value__c();
        lov8.Name='GE_NAS_NCSC_Component_Code';
        lov8.GE_NAS_Code_Value__c='4726';
        lov8.GE_NAS_Object__c='Account';
        lov8.GE_NAS_Val__c='DSS West';
        lov_list.add(lov8);
        
        GE_NAS_List_of_Value__c lov9=new GE_NAS_List_of_Value__c();
        lov9.Name='GE_NAS_Default_Distribution_Center';
        lov9.GE_NAS_Code_Value__c='3343';
        lov9.GE_NAS_Object__c='Account';
        lov9.GE_NAS_Val__c='3343-Lexington, KY-PLT';
        lov_list.add(lov9);
        
        
        GE_NAS_List_of_Value__c lov10=new GE_NAS_List_of_Value__c();
        lov10.Name='GE_NAS_Preferred_Carrier';
        lov10.GE_NAS_Code_Value__c='ABFR';
        lov10.GE_NAS_Object__c='Account';
        lov10.GE_NAS_Val__c='ABFR - ABF Freight';
        lov_list.add(lov10);
        
        insert lov_list;
        
        ID BilltorecTypID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Account' AND NAME='SAP Account'].ID;
        ID NatorecTypID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Account' AND NAME='SAP Account'].ID;
        ID ShiptorecTypID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Account' AND DEVELOPERNAME='SAP_LTG_Service_Account'].ID;
        
        Test.startTest();
        Account a = New Account();
        a.Name = 'msat';
        a.type= 'End User'; 
        a.GE_LGT_Vertical__c = 'Ed'; 
        a.Site = 'Mayfield'; 
        a.GE_NAS_National_Type__c='NA';
        a.GE_NAS_Account_status__c='I';
        a.GE_NAS_GE_Business_Code__c='CA';
        a.GE_NAS_Language__c='E';
        a.GE_NAS_Shipping_Type__c='R';
        a.GE_NAS_Shipping_Schedule__c='2';
        a.GE_NAS_Preferred_Carrier__c='ABFR';
        a.GE_NAS_Default_Distribution_Center__c='3343';
        a.GE_NAS_Bill_To_Account_Number__c='2013044';
        a.GE_NAS_AccountNo__c='20130440001';
        a.GE_NAS_NCSC_Component_Code__c='4726';
        a.RecordTypeId=ShiptorecTypID; 
        insert a;
        Test.stopTest();
    }
    static testMethod void deleteDupAcountCheck() 
    {
        
        SAP_Records_Recycle__c recycleRecord = new SAP_Records_Recycle__c();
        recycleRecord.GE_LGT_EM_SAP_Customer_Number__c='999999';
        recycleRecord.GE_LGT_EM_Sales_Org__c =  '1US1'; 
        recycleRecord.GE_LGT_EM_Division__c ='10';
        recycleRecord.GE_LGT_EM_Distribution_Channel__c='20-Prof';
        recycleRecord.GE_LGT_EM_PF_Type__c='Z8';
        insert recycleRecord;
        
        ID recTypeIDZSTG =Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        Account azstg = New Account();
        azstg.Name = 'Test Account-1';
        azstg.RecordTypeId=recTypeIDZSTG;
        azstg.type= 'End User'; 
        azstg.GE_LGT_Vertical__c = 'Ed'; 
        azstg.Site = 'Mayfield';
        azstg.GE_LGT_EM_SAP_Customer_Number__c='999999';
        azstg.GE_LGT_EM_Sales_Org__c='1US1';
        azstg.GE_LGT_EM_Division__c='10';
        azstg.GE_LGT_EM_Distribution_Channel__c='20-Prof';
        azstg.GE_LGT_EM_PF_Type__c='Z8';
        insert azstg;
        
        ID recTypeIDEndUser =Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account aDupeZSTG = new Account();
        aDupeZSTG.Name  = 'Test Account-1';
        aDupeZSTG.RecordTypeId=recTypeIDEndUser;
        aDupeZSTG.type= 'End User'; 
        aDupeZSTG.GE_LGT_Vertical__c = 'Ed';
        aDupeZSTG.GE_LGT_EM_SAP_Customer_Number__c='999999';
        aDupeZSTG.GE_LGT_EM_Sales_Org__c='1US1';
        aDupeZSTG.GE_LGT_EM_Division__c='10';
        aDupeZSTG.GE_LGT_EM_Distribution_Channel__c='20-Prof';
        aDupeZSTG.GE_LGT_EM_PF_Type__c='Z8';
        aDupeZSTG.GE_LGT_EM_CustomerActiveFlag__c=false;
        aDupeZSTG.BillingCountry='United States';
        insert aDupeZSTG;
        List<Account> acct_list = new List<Account>();
        acct_list.add(azstg);
        acct_list.add(aDupeZSTG);
        
        AccountTriggerHelper obj_acct = new AccountTriggerHelper();
        obj_acct.DeleteDuplicateEdAccounts(acct_list);
        
    }
    
    /* Added by Shyam - To test the ManageCustHierarchies method in AccountTriggerHelper Class
     * Date - April - 2017
     */ 
    static testMethod void manageCustHierarchiesTest() 
    {
        //Inserting Parent Account first
        Account parentAcc=new Account();
        parentAcc.Name='Test Parent Account';
        parentacc.recordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account Strategic Pole').getRecordTypeId();        
        parentAcc.BillingCountry='United States';
        parentAcc.GE_LGT_Vertical__c='Finan';
        parentAcc.GE_LGT_EM_SAP_Customer_Number__c='Test8811';
        parentAcc.GE_LGT_EM_Sales_Org__c='1US1';
        parentAcc.GE_LGT_EM_Distribution_Channel__c='10-Con';
        parentAcc.GE_LGT_EM_Division__c='10-Fin';
        parentAcc.GE_LGT_EM_SAPUniqueIdentifier__c='Test8811-1US1-10-10';
        parentAcc.GE_LGT_EM_Partner_Function__c='Sold To Party';
        parentAcc.Account_Group__c='ZSH5';
        parentAcc.CurrencyIsoCode='USD';
        parentAcc.GE_NAS_Language__c='English';
        insert parentAcc;
        system.debug('Parent Account '+ parentAcc.Id);
        
        //Inserting Child Account
        Account acc=new Account();
        acc.recordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        acc.Name='Test Child Account';
        acc.BillingCountry='United States';
        acc.GE_LGT_Vertical__c='Finans';
        acc.GE_LGT_EM_SAP_Customer_Number__c='Test9955';
        acc.GE_LGT_EM_Sales_Org__c='1US1';
        acc.GE_LGT_EM_Distribution_Channel__c='10';
        acc.GE_LGT_EM_Division__c='10';
        acc.GE_LGT_EM_SAPUniqueIdentifier__c='Test9955-1US1-10-10';
        acc.GE_LGT_EM_Partner_Function__c='Sold To Party';
        acc.Account_Group__c='Z001';
        acc.CurrencyIsoCode='USD';  
        acc.GE_NAS_Language__c='English';
        acc.SAP_Parent_Customer_No__c='Test8811';
        insert acc;
        system.debug('Child Account '+ Acc.Id);
        system.debug('Child Accounts Parent ID is: '+ Acc.ParentId);
                        
        //Checking for Parent Account - Parent Account has to be mapped based on SAP_Parent_Customer_No__c
        List<Account> accList = [SELECT ID,ParentID FROM Account WHERE ID=:acc.ID];
        //System.assertEquals(parentAcc.ID, accList[0].ParentId); - AA commented out as per API version upd since account parenting is a batch BA10 it's not instant.               
        System.assertEquals(NULL, accList[0].ParentId);
        //Making the SAP_Parent_Customer_No__c as blank
        acc.SAP_Parent_Customer_No__c = NULL;
        update acc;
        
        //Checking for Parent Account - Parent Account has to be cleared as SAP_Parent_Customer_No__c has been made as blank
        accList = [SELECT ID,ParentID FROM Account WHERE ID=:acc.ID];
        System.assertEquals(NULL, accList[0].ParentId);
    }
}
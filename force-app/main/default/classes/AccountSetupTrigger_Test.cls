/***********************************************************************************************
*   Test Class Name      : AccountSetupTrigger_Test 
*   Date            : 7/7/2017
*   Author          : Satish Babu\Shyam
*   Purpose         : These Test Class will cover code coverage for   
*   Trigger         : AccountSetupTrigger .
*   class           : AccountSetupTriggerHelper
*   Test Class      : AccountSetupTrigger_Test
**************************************************************************************************/
@isTest(seeAllData=false)
public class AccountSetupTrigger_Test 
{
    Static ID RecordtypeId2= [Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'Change_Change_in_Owner_Legal_Name_Entity' limit 1].Id;
    //Static ID DistSolControRecID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Solutions and/or Controls Branch').getRecordTypeId(); RQT-1475
   // Static ID distRecTypeID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Solutions and Controls Distributor').getRecordTypeId();
    Static ID RecordtypeId3=[Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'Change_Change_in_Terms' limit 1].Id;
    Static ID RectypeEUchg=[Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'Europe_Change_Change_in_Terms' limit 1].Id;
    Static ID SetupDirectRecID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Direct Account Setup/Direct Account Branch Setup').getRecordTypeId();
    Static ID RecordtypeEUSoldTo=[Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'Europe_Sold_to_Account_setup' limit 1].Id;
    Static ID RecordtypeEUShipTo=[Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'Europe_Ship_to_Account' limit 1].Id;  //RQT-0001382
    Static ID RecordtypeEUBillTo=[Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'Europe_Bill_to_Account' limit 1].Id;  //RQT-0001386
    Static ID RecordtypeEUPayer=[Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'Europe_Payer_AccountSetup' limit 1].Id;  //RQT-0001401
    Static ID distRecTypeID =[Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'New_Core_Solutions_and_Controls_Distributor' limit 1].Id;  //RQT-0001481
    Static testMethod void RiskScreeningvalidation()
    {
        //ID DistNewCoreBrchRecID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Core Branch').getRecordTypeId(); //RQT-1475
        ID DistNewCoreBrchRecID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Core Branch Risk Approved').getRecordTypeId();
        Test.startTest();
        Distributor__c DistNeCoreBranch = TestDataUtil.createDistributor(DistNewCoreBrchRecID);
        DistNeCoreBranch.Status__c='In Set Up – Risk Approved';
        DistNeCoreBranch.D_B_Check__c=false;
        insert DistNeCoreBranch; 
        try
        {
            Update DistNeCoreBranch; 
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Risk Screening is mandatory to be able to approve the record') ? TRUE : FALSE;
            
            System.AssertEquals(expectedExceptionThrown, TRUE);
        } 
        Test.stopTest();
    }
    Static testMethod void RiskSabrixValidation()
    {
        ID changeInTermsRecTypeID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Change – Change in Terms').getRecordTypeId();
        Test.startTest();
        Distributor__c changeInTermsdistributor = TestDataUtil.createDistributor(SetupDirectRecID);
        insert changeInTermsdistributor;  
        changeInTermsdistributor.Status__c='In Set Up – Risk Approved';
        changeInTermsdistributor.D_B_Check__c=false;
        try
        {
            update changeInTermsdistributor;   
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Following fields are mandatory to be able to approve the record - Risk Screening, Sabrix Setup Complete, Customer Master Setup – Solutions/Controls, Account # Solutions/Controls, ') ? TRUE : FALSE;
            
            System.AssertEquals(expectedExceptionThrown, TRUE);
        }
        
        try
        {
            changeInTermsdistributor.Status__c='Core Approved';
            changeInTermsdistributor.Core_Customer_Master_setup__c=false;
            update changeInTermsdistributor;   
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Following fields are mandatory to be able to approve the record - Core Customer Master Setup, Account # Core, & Ship To Sent to GENPAC') ? TRUE : FALSE;
            System.AssertEquals(expectedExceptionThrown, TRUE);
        }
        Test.stopTest();
    }
    Static testMethod void RiskScreeningAccountvalidation()
    {
        ID DistribuNewsolTypeID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Solutions and/or Controls Distributor Approval').getRecordTypeId();
        Test.startTest();
        Distributor__c DistribuNewsol = TestDataUtil.createDistributor(DistribuNewsolTypeID);
        insert DistribuNewsol;  
        DistribuNewsol.Status__c='In Set Up – Risk Approved';
        DistribuNewsol.D_B_Check__c=false;
        try
        {
            update DistribuNewsol;   
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Following fields are mandatory to be able to approve the record - Risk Screening; Account # Solutions; Account # Controls') ? TRUE : FALSE;
            
            System.AssertEquals(expectedExceptionThrown, TRUE);
        }
        Test.stopTest();
    }
    /*************198***********************/
    Static testMethod void ElitenetRegistrationValidation()
    {
        //ID DistNewCoreBranchID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Core Branch').getRecordTypeId();
        ID DistNewCoreBranchID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Core Branch Risk Approved').getRecordTypeId();
        Test.startTest();
        Distributor__c Insetupvalidation = TestDataUtil.createDistributor(DistNewCoreBranchID);
        Insetupvalidation.Status__c='In Setup';
        insert Insetupvalidation;  
        
        try
        {
            Insetupvalidation.Status__c='In Setup';
            Insetupvalidation.Core_Customer_Master_setup__c=false ;
            update Insetupvalidation;   
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Following fields are mandatory to be able to approve the record - Core Customer Master Set up, Account # Core, EDI Setup, Elitenet Registration Sent') ? TRUE : FALSE;
            
            System.AssertEquals(expectedExceptionThrown, TRUE);
        }  
        Test.stopTest();
    }
    
    Static testMethod void ExecReviewValidation() 
    {
        ID DistNewCoreBranchRiskID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Core Distributor Risk Approved').getRecordTypeId();
        Test.startTest(); 
        Distributor__c ExecReviewValidation = TestDataUtil.createDistributor(DistNewCoreBranchRiskID);
        ExecReviewValidation.Status__c='In Setup';
        insert ExecReviewValidation;  
        try
        {
            ExecReviewValidation.Status__c='Exec Review';
            ExecReviewValidation.Core_choose_all_that_apply__c=null;
            ExecReviewValidation.Customer_On_Electronic_Funds_Tra__c=null;
            ExecReviewValidation.GE_Sales_Representative_Contact_Core__c=null ;
            update ExecReviewValidation;   
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Following Fields are mandatory -Core (choose all that apply), Requested Terms, Estimated Annual Volume in Dollars, Amount of First Order, Does Customer Have EDI Capability?, Customer On Electronic Funds Transfer?, Is the Customer Tax Exempt?, Equipped to Handle GE Product, Date of Visit by Account Manager, GE Sales Rep Contact (Core), GE Sales Rep # (Core), Region/District # (Core)') ? TRUE : FALSE;
            
            System.AssertEquals(expectedExceptionThrown, TRUE);
        }
        Test.stopTest();
    }
    
    Static testMethod void MinorChannelvalidation() 
    {
        /***********Minor Channel*********219****************/
        ID DistributorApprovalID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Solutions and/or Controls Distributor Risk Approved').getRecordTypeId();
        Test.startTest();  
        Distributor__c MinorChannelvalidation = TestDataUtil.createDistributor(DistributorApprovalID);
        // MinorChannelvalidation.Status__c='In Set Up – Risk Approved';
        insert MinorChannelvalidation;  
        
        try
        {     MinorChannelvalidation.Status__c='Exec Review';
         MinorChannelvalidation.Sales_District_Solutions__c=null;
         update MinorChannelvalidation;   
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Following Fields are mandatory - Sales Office Solutions; Sales District Solutions; Sales Group Solutions; Account Assignment Group; Major Channel; Minor Channel; Vertical') ? TRUE : FALSE;
            
            System.AssertEquals(expectedExceptionThrown, TRUE);
        }
        Test.stopTest();
    }
    
    Static testMethod void MinorChannelBranchvalidation() 
    {
        /******************* 228**Branch*************/
        ID DistSolContBrchRiskAppID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Core, Solutions and Controls Branch Risk Approved').getRecordTypeId();
        Distributor__c MinorChannelBranchvalidation = TestDataUtil.createDistributor(DistSolContBrchRiskAppID);
        insert MinorChannelBranchvalidation;  
        try
        {     MinorChannelBranchvalidation.Status__c='Exec Review';
         MinorChannelBranchvalidation.Sales_District_Solutions__c=null;
         update MinorChannelBranchvalidation;   
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Following Fields are mandatory - Sales Office Solutions; Sales District Solutions; Sales Group Solutions; Account Assignment Group; Major Channel; Minor Channel; Vertical') ? TRUE : FALSE;
            
            System.AssertEquals(expectedExceptionThrown, TRUE);
        }
    }
    
    Static testMethod void MinorChannelSolORBranch() 
    {
        /******************* 237**and/or Controls Branch*************/
        ID DistSolORContBrchRiskAppID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Solutions and/or Controls Branch Risk Approved').getRecordTypeId();
        Distributor__c MinorChannelSolORBranch = TestDataUtil.createDistributor(DistSolORContBrchRiskAppID);
        insert MinorChannelSolORBranch;  
        try
        {     MinorChannelSolORBranch.Status__c='Exec Review';
         MinorChannelSolORBranch.Sales_District_Solutions__c=null;
         MinorChannelSolORBranch.GE_LGT_Major_Channel__c=null;
         update MinorChannelSolORBranch;   
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Following Fields are mandatory - Sales Office Solutions; Sales District Solutions; Sales Group Solutions; Account Assignment Group; Major Channel; Minor Channel; Vertical') ? TRUE : FALSE;
            
            System.AssertEquals(expectedExceptionThrown, TRUE);
        }
    }
    Static testMethod void CommFinRevMailVal() 
    {
        /*********************Commercial Finance Review*****MailAddress Null***Distributor- New Solutions and/or Controls Distributor Risk Approved****/
        ID SolORContDistRiskAppID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Solutions and/or Controls Distributor Approval').getRecordTypeId();
        Distributor__c CommFinRevMailVal = TestDataUtil.createDistributor(SolORContDistRiskAppID);
        insert CommFinRevMailVal;  
        try
        {     CommFinRevMailVal.Status__c='Commercial Finance Review';
         CommFinRevMailVal.Agent_Name__c=Null ;
         CommFinRevMailVal.Agent_Rep_Code__c=Null;
         update CommFinRevMailVal;   
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Following Fields are mandatory - Mailing Address, Mailing City,Mailing State/Province,Mailing Postal Code,Mailing Contact Name, Mailing Contact Phone,Mailing Contact Email,Shipping Address,Shipping City,Shipping State/Province,Shipping Postal Code, Shipping Contact Name,Shipping Contact Phone,Shipping Contact Email,Agent Name,Agent Rep Code,Agency Contacts for Customer Connect') ? TRUE : FALSE;
            
            System.AssertEquals(expectedExceptionThrown, TRUE);
        }
    }
    
    Static testMethod void ComFinRevContBrch() 
    {
        /*********************Commercial Finance Review*****Agent Name Null***Distributor- New Solutions and/or Controls Branch****/
        //ID NeWSolOrContBrchID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Solutions and/or Controls Branch').getRecordTypeId();
        ID NeWSolOrContBrchID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Solutions and/or Controls Branch Risk Approved').getRecordTypeId();
        Distributor__c ComFinRevContBrch = TestDataUtil.createDistributor(NeWSolOrContBrchID);
        insert ComFinRevContBrch;  
        try
        {     ComFinRevContBrch.Status__c='Commercial Finance Review';
         ComFinRevContBrch.Agent_Name__c=Null;
         update ComFinRevContBrch;   
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Following Fields are mandatory - Branch #,City,Mailing Address, Mailing City,Mailing State/Province,Mailing Postal Code,Mailing Contact Name, Mailing Contact Phone,Mailing Contact Email, Shipping Address,Shipping City,Shipping State/Province,Shipping Postal Code, Shipping Contact Name,Shipping Contact Phone,Shipping Contact Email,Solutions (choose all that apply),Agency Contacts for Customer Connect, Distributor HQ Account #,GE Sales Rep # (Solutions), Agent Name,Agent Rep Code') ? TRUE : FALSE;
            
            System.AssertEquals(expectedExceptionThrown, TRUE);
        }   
    }
    
    Static testMethod void ComFinRevDstCtrl() 
    {
        /*********************Commercial Finance Review*****Agent Name Null***Distributor- New Core, Solutions and Controls Distributor****/
        ID NeWCorSolDstCtrl=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Core, Solutions and Controls Distributor').getRecordTypeId();
        Distributor__c ComFinRevDstCtrl = TestDataUtil.createDistributor(NeWCorSolDstCtrl);
        insert ComFinRevDstCtrl;  
        try
        {     ComFinRevDstCtrl.Status__c='Commercial Finance Review';
         ComFinRevDstCtrl.Agent_Name__c=Null;
         update ComFinRevDstCtrl;   
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Following Fields are mandatory - Agent Name,Agent Rep Code,Agency Contacts for Customer Connect ') ? TRUE : FALSE;
            
            System.AssertEquals(expectedExceptionThrown, TRUE);
        }
    }
    
    Static testMethod void ComFinRevBrch() 
    {
        /*********************Commercial Finance Review*****Branch__c Null****Distributor- New Core, Solutions and Controls Branch***/
        ID NewCrSolCtrlBrchID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Core, Solutions and Controls Branch').getRecordTypeId();
        Distributor__c ComFinRevBrch = TestDataUtil.createDistributor(NewCrSolCtrlBrchID);
        insert ComFinRevBrch;  
        try
        {     ComFinRevBrch.Status__c='Commercial Finance Review';
         ComFinRevBrch.Branch__c=Null;
         update ComFinRevBrch;   
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Following Fields are mandatory - Branch #,City,Mailing Address, Mailing City,Mailing State/Province,Mailing Postal Code,Mailing Contact Name, Mailing Contact Phone,Mailing Contact Email,Shipping Address,Shipping City,Shipping State/Province,Shipping Postal Code, Shipping Contact Name,Shipping Contact Phone,Shipping Contact Email,Core (choose all that apply),Solutions (choose all that apply),Agency Contacts for Customer Connect, Distributor HQ Account #, Agent Name,Agent Rep Code') ? TRUE : FALSE;
            
            System.AssertEquals(expectedExceptionThrown, TRUE);
        } 
    }
    
    
    
    
    
    Static testMethod void ChangeInTermsvalidation()
    {
        
        ID RecordtypeId3=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Change – Change in Terms').getRecordTypeId();
        Distributor__c changeInTermsdistributor = TestDataUtil.createDistributor(RecordtypeId3);
        insert changeInTermsdistributor;
        
        changeInTermsdistributor.Status__c = 'Pricing/Finance Review';
        changeInTermsdistributor.Sales_Office_Solutions__c = Null; 
        changeInTermsdistributor.Sales_District_Solutions__c = Null; 
        changeInTermsdistributor.Sales_Group_Solutions__c = Null ;  
        changeInTermsdistributor.Account_Assignment_Group__c = Null;  
        changeInTermsdistributor.KYC_Number__c = Null;  
        changeInTermsdistributor.Credit_ID_Number__c = Null ; 
        changeInTermsdistributor.Credit_Limit_Approved_USD__c = Null;  
        changeInTermsdistributor.Credit_Quality_Rating__c = Null;
        
        try
        {
            
            update changeInTermsdistributor;   
         
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Please fill information under Risk Review Section to Approve') ? TRUE : FALSE;
            
           // System.AssertEquals(expectedExceptionThrown, TRUE);
            
        }
 
         
        //ID RectypeEUchg=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Europe-Change-Change in Terms').getRecordTypeId();
        Distributor__c changeInTermsEU = TestDataUtil.createDistributor(RectypeEUchg);
        insert changeInTermsEU;
        
        changeInTermsEU.Status__c = 'Pricing/Finance Review';
        changeInTermsEU.Sales_Office_Solutions__c = Null; 
        changeInTermsEU.Sales_District_Solutions__c = Null; 
        changeInTermsEU.Sales_Group_Solutions__c = Null ;  
        changeInTermsEU.Account_Assignment_Group__c = Null;  
        changeInTermsEU.KYC_Number__c = Null;  
        changeInTermsEU.Credit_ID_Number__c = Null ; 
        changeInTermsEU.Credit_Limit_Approved_USD__c = Null;  
        changeInTermsEU.Credit_Quality_Rating__c = Null;
        
        try
        {
            
            update changeInTermsdistributor;           
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Please fill information under Risk Review Section to Approve') ? TRUE : FALSE;
            
            System.AssertEquals(expectedExceptionThrown, TRUE);
        }

Distributor__c EUSoldTo= TestDataUtil.createDistributor(RecordtypeEUSoldTo);
        insert EUSoldTo;
        
        EUSoldTo.Status__c = 'MPCOE/Account Setup';
        EUSoldTo.KYC_Number__c = Null; 
        EUSoldTo.Credit_ID_Number__c = Null; 
        EUSoldTo.Credit_Limit_Approved__c = Null ;  
        EUSoldTo.Credit_Quality_Rating__c = Null;  
        
        try
        {          
            update EUSoldTo;           
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Please fill in details for Signed Agreement if Applicable, KYC Number, Credit ID Number, Credit Limit Approved under the RISK Section') ? TRUE : FALSE;        
            System.AssertEquals(expectedExceptionThrown, TRUE);
        }
Distributor__c EUSoldTo2 = TestDataUtil.createDistributor(RecordtypeEUSoldTo);
        insert EUSoldTo2 ;
        
        EUSoldTo2 .Status__c = 'Credit Risk Review';
        EUSoldTo2 .Account_Solutions_Controls__c = Null; 
        
        try
        {          
            update EUSoldTo2 ;           
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Please fill in details for SAP Customer # under the Setup Requirements Section') ? TRUE : FALSE;        
            System.AssertEquals(expectedExceptionThrown, TRUE);
        }      
        // Europe Ship To Account Setup - RQT-0001382
        Distributor__c EUShipTo = TestDataUtil.createDistributor(RecordtypeEUShipTo);
        insert EUShipTo;
        
        EUShipTo.Status__c = 'In Setup';
        EUShipTo.Account_Solutions_Controls__c = Null; 
        
        try
        {          
            update EUShipTo ;           
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Please fill in details for SAP Customer # under the Setup Requirements Section') ? TRUE : FALSE;        
            System.AssertEquals(expectedExceptionThrown, TRUE);
        }
        
        
        //Europe Payer Account Setup - RQT-1401 for Setup
        
        Distributor__c EUPayer = TestDataUtil.createDistributor(RecordtypeEUPayer);
        insert EUPayer;
        
       // EUPayer.Status__c = 'In Setup';
          EUPayer.Status__c = 'Credit Risk Review';

        EUPayer.Account_Solutions_Controls__c = Null; 
        
        try
        {          
            update EUPayer ;           
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Please fill in details for SAP Customer # under the Setup Requirements Section') ? TRUE : FALSE;        
            System.AssertEquals(expectedExceptionThrown, TRUE);
        }
        
        Distributor__c EUPayerRisk = TestDataUtil.createDistributor(RecordtypeEUPayer);
        insert EUPayerRisk;
        //EUPayerRisk.Status__c = 'Payer';
        EUPayerRisk.Status__c = 'MPCOE/Account Setup';
        EUPayerRisk.GE_LGT_Signed_Agreement_if_Applicable__c = Null; 
        EUPayerRisk.KYC_Number__c = Null;
        EUPayerRisk.Credit_ID_Number__c = Null;
        //EUPayerRisk.Credit_Limit_Approved__c = Null;
        EUPayerRisk.Credit_Quality_Rating__c = Null;        
        
        try
        {          
            update EUPayerRisk ;           
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Please fill in details for Risk Section') ? TRUE : FALSE;        
            //System.AssertEquals(expectedExceptionThrown, FALSE);
        }
         
        
        
        
        // Europe Bill To Account Setup - RQT-0001386
        Distributor__c EUBillTo = TestDataUtil.createDistributor(RecordtypeEUBillTo);
        insert EUBillTo;
        
        EUBillTo.Status__c = 'In Setup';
        EUBillTo.Account_Solutions_Controls__c = Null; 
        
        try
        {          
            update EUBillTo ;           
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Please fill in details for SAP Customer # under the Setup Requirements Section') ? TRUE : FALSE;        
            System.AssertEquals(expectedExceptionThrown, TRUE);
        }
    }
    
    
    Static testMethod void ChangeOwnerlegalvalidation()
    {
        
        ID RecordtypeId2=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Change – Change in Owner/Legal Name/Entity').getRecordTypeId();
        Distributor__c changeInTermsdistributor = TestDataUtil.createDistributor(RecordtypeId2);
        insert changeInTermsdistributor;
        
        changeInTermsdistributor.Status__c = 'Complete';
        changeInTermsdistributor.Sales_Office_Solutions__c = Null; 
        changeInTermsdistributor.Sales_District_Solutions__c = Null; 
        changeInTermsdistributor.Sales_Group_Solutions__c = Null ;  
        changeInTermsdistributor.Account_Assignment_Group__c = Null;  
        changeInTermsdistributor.KYC_Number__c = Null;  
        changeInTermsdistributor.Credit_ID_Number__c = Null ; 
        changeInTermsdistributor.Credit_Limit_Approved_USD__c = Null;  
        changeInTermsdistributor.Credit_Quality_Rating__c = Null;
        
        try
        {
            
            update changeInTermsdistributor;   
            
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Please fill information under Risk Review Section to Approve') ? TRUE : FALSE;
            
            System.AssertEquals(expectedExceptionThrown, TRUE);
        }
        
        
        
    }
    Static testMethod void ReactivationValidation()
    {
        
        ID RecordtypeId6=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Change – Reactivation').getRecordTypeId();
        Distributor__c changeInTermsdistributor = TestDataUtil.createDistributor(RecordtypeId6);
        insert changeInTermsdistributor;
        
        changeInTermsdistributor.Status__c = 'Compliance Review';
        changeInTermsdistributor.Sales_Office_Solutions__c = Null; 
        changeInTermsdistributor.Sales_District_Solutions__c = Null; 
        changeInTermsdistributor.Sales_Group_Solutions__c = Null ;  
        changeInTermsdistributor.Account_Assignment_Group__c = Null;  
        changeInTermsdistributor.KYC_Number__c = Null;  
        changeInTermsdistributor.Credit_ID_Number__c = Null ; 
        changeInTermsdistributor.Credit_Limit_Approved_USD__c = Null;  
        changeInTermsdistributor.Credit_Quality_Rating__c = Null;
        
        try
        {
            
            update changeInTermsdistributor;   
            
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Please fill information under Risk Review Section to Approve') ? TRUE : FALSE;
            
            System.AssertEquals(expectedExceptionThrown, TRUE);
        }
        
        
        
    }
    
    Static testMethod void EuropeApprovalProcess()
    {
        
        ID RecordtypeId8=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Europe Change – Increase in Credit Amount').getRecordTypeId();
        Distributor__c europechangeInTerms = TestDataUtil.createDistributor(RecordtypeId8);
        insert europechangeInTerms;
        
        europechangeInTerms.Status__c = 'Risk Changes';
        europechangeInTerms.Recommended_Credit_Line__c = Null; 
        europechangeInTerms.Account_Currency_Recommended_Credit_Line__c  = Null; 
        europechangeInTerms.Financials_Avaliable__c = Null ;  
        europechangeInTerms.Requires_DOA_Approval__c = Null;  
        
        try
        {   
            update europechangeInTerms;   
        }
        catch(Exception exp)
        {
            Boolean expectedExceptionThrown =  exp.getMessage().contains('Please fill in details for Recommended Credit Line, Account Currency, Financials Available and Requires DOA Approvals under the Credit Assesment Section') ? TRUE : FALSE;
            
            System.AssertEquals(expectedExceptionThrown, TRUE);
        }   
    }
    
    
    /*Static testMethod void testUpdateApprovalHistory()
    {
       // ID distRecTypeID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Solutions and Controls Distributor').getRecordTypeId();
        ID distRecTypeID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Core, Solutions and Controls Distributor').getRecordTypeId();
        Test.startTest();
        Distributor__c distributor = TestDataUtil.createAccountsetup();
        distributor.RecordTypeId=distRecTypeID;
        distributor.Mail_To_Same_as_Bill_To__c = true;
        distributor.Shipping_Information_Same_as_Bi__c=true;
        distributor.Core_choose_all_that_apply__c='Sensors'; //multi-select picklist
        distributor.Solutions_choose_all_that_apply__c='Traffic Products'; ////multi-select picklist
        distributor.Requested_Terms__c = 'Standard';  
        distributor.Does_Customer_Have_EDI_Capability__c='Yes';
        distributor.Customer_On_Electronic_Funds_Tra__c = 'No';
        distributor.Is_the_Customer_Tax_Exempt__c='No';
        distributor.Equipped_to_Handle_GE_Product__c = 'Yes';
        distributor.Existing_Distributor_Application__c='Yes';
        distributor.Existing_Distributor_Agreement__c='Yes';
        distributor.Existing_Multi_Tax_Form_or_State_For_del__c='Yes';
        distributor.Canadian_Documents__c='Yes';
        distributor.IFL_INDOOR_FIXTURE_LED__c='Arch ONLY: IFL-110';
        distributor.RDL_RETAIL_DISPLAY_LIGHTING__c=false;
        distributor.SGN_SIGNAGE__c='All';
        distributor.TRN_TRANSPORTATION__c=true;
        distributor.LCT_LIGHTING_CONTROLS__c=true;
        distributor.Contract_Signer_Channel_Partner_Name__c = 'Matthew Gugumuck'; // RQT-1679: CONGA-OCTIV INTEGRATION
        distributor.Contract_Signer_Channel_Partner_Email__c = 'matthew.gugumuck@ge.com'; // RQT-1679: CONGA-OCTIV INTEGRATION
        distributor.Contract_Start_Date__c = date.today(); // RQT-1679: CONGA-OCTIV INTEGRATION
        distributor.Contract_End_Date__c = date.today(); // RQT-1679: CONGA-OCTIV INTEGRATION
        distributor.Region__c = 'UNITED STATES'; // RQT-1679: CONGA-OCTIV INTEGRATION
        distributor.Territory__c = 'VIRGINIA'; // RQT-1679: CONGA-OCTIV INTEGRATION
        distributor.Contract_Duration__c = '1 Yr'; // RQT-1679: CONGA-OCTIV INTEGRATION
        distributor.Billing_Country__c = 'UNITED STATES'; // RQT-1679: CONGA-OCTIV INTEGRATION
		distributor.Status__c ='Not Submitted';
		distributor.Approver__c=userinfo.getCurrentUserId();
        
        
        Try{
            insert distributor;    
            Distributor__c retDistributor = [SELECT ID,Mailing_City__c FROM Distributor__c WHERE ID=:distributor.ID];
            System.assertEquals(distributor.Billing_City__c, retDistributor.Mailing_City__c); 
        }
        Catch(Exception exp)
        {
            
        }
        // Create an approval request for the Distributor     
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(distributor.Id);
        
        // Submit the approval request for the Distributor  
        Approval.ProcessResult result1 = Approval.process(req1);      
        
        // Verify the results  
        System.assert(result1.isSuccess());
        System.assertEquals('Pending', result1.getInstanceStatus(), 'Instance Status'+result1.getInstanceStatus());
        
        // Approve the submitted request      
        // First, get the ID of the newly created item    
        List<Id> newWorkItemIds = result1.getNewWorkitemIds();
        
        // Instantiate the new ProcessWorkitemRequest object and populate it  
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        
        // Use the ID from the newly created item to specify the item to be worked  
        req2.setWorkitemId(newWorkItemIds[0]);
        
        // Submit the request for approval  
        Approval.ProcessResult result2 =  Approval.process(req2);
        distributor.LCT_LIGHTING_CONTROLS__c=True;
        update distributor;
        System.assert(result2.isSuccess());
        System.assertEquals('Pending', result2.getInstanceStatus(), 'Instance Status'+result2.getInstanceStatus());
        Test.stopTest();
        
    }*/
    /*Static testMethod void testAutoSubmitToProcess()
    {
        ID distRecTypeID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('LATAM - Temporary Account Activation/Deactivation').getRecordTypeId();
        Test.startTest();
        Distributor__c distributor = TestDataUtil.createAccountsetup();
        distributor.RecordTypeId=distRecTypeID;
        distributor.LATAM_Country__c='Brazil';
        distributor.ERP_Customer_Branch_Number__c='123456';
        insert distributor;     
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(distributor.Id);  
        // Submit the approval request for the Distributor  
        system.debug('****Approval Process Name***'+req1);
        Approval.ProcessResult result1 = Approval.process(req1); 
        System.assert(result1.isSuccess());
        
        System.assertEquals('Pending', result1.getInstanceStatus(), 'Instance Status'+result1.getInstanceStatus());
        
        
        List<Id> newWorkItemIds = result1.getNewWorkitemIds();
        
        // Instantiate the new ProcessWorkitemRequest object and populate it  
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Reject request.');
        req2.setAction('Reject');
        
        // Use the ID from the newly created item to specify the item to be worked  
        req2.setWorkitemId(newWorkItemIds[0]);
        
        // Submit the request for approval  
        Approval.ProcessResult result2 =  Approval.process(req2); 
        Distributor__c retDistributor = [SELECT ID,status__c FROM Distributor__c WHERE ID=:distributor.ID]; 
        System.assertEquals(retDistributor.status__c, 'Rejected');  
        Test.stopTest();
    }*/
}
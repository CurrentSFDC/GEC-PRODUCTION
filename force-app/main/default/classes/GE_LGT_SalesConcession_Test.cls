@isTest
Public class GE_LGT_SalesConcession_Test{
    static testMethod void checkSalesConcessionPositive(){
        TriggerSwitch__c caseSetting = TestDataUtil.createTriggerSwitch('CaseTrigger', true);
        insert caseSetting;
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAccTypeID;
        insert acc;
        
        List <GROUP> Queuelist = [select id from Group where Type = 'Queue' AND DeveloperName = 'GE_NAS_Support_Team'];
        
        
        Sales_Concession_Request__c sales_conc = new Sales_Concession_Request__c();
        sales_conc.GE_LGT_Concession_Status__c = 'Not Submitted';
        sales_conc.Concession_Type__c = 'Back Charges/Labor';
        //sales_conc.GE_LGT_Concession_Amount__c = 'Below $1K';
        sales_conc.GE_LGT_Concession_Amount__c = 'Below or equal to $1000';
        sales_conc.GE_LGT_Actual_Amount__c = 500;
        sales_conc.Agent_Comission_Paid__c = 'No';
        sales_conc.GE_LGT_Root_Cause_Error__c = 'Customer Error';
        //sales_conc.Select_Required_Approver__c = 'No Approval Required';
        sales_conc.GE_LGT_Project_Name__c = 'Test Project';
        sales_conc.GE_LGT_Distributor__c = 'Test Distributor' ;
        sales_conc.GE_LGT_Fixture_Agency__c = 'Test Fixture Agency' ;
        sales_conc.Select_Root_Cause_Issue_s__c = 'Incorrect SKU entered';  
        sales_conc.Account_Name__c=acc.id;
        sales_conc.Region_of_Requestor__c = 'North America';
       
        
        Test.startTest();
        
        insert sales_conc;
        Case cse = new Case();
        cse.subject='test';
        cse.Description='test';
        cse.type='Sales Concession';
        cse.origin='Sales Concession';
        cse.Accountid  =sales_conc.Account_Name__c;
        insert cse;
        
        List<Sales_Concession_Request__c> SCID =[Select Id from Sales_Concession_Request__c where ID=:sales_conc.ID];
        system.assertEquals(1, SCID.size());
        
        list<Case> CVar = [select id,subject,Description,Type,Origin,Accountid  from case where Accountid =:sales_conc.Account_Name__c AND OwnerId=:Queuelist[0].ID];
     
      
        //system.assertEquals(0, CVar.size());
        
        system.assertEquals('Sales Concession',  cse.type);
        
        system.assertEquals(sales_conc.Account_Name__c, cse.Accountid);
        
        system.assertEquals('Sales Concession', cse.origin);
        
        
        
        Test.stopTest();   
        
    }
    static testMethod void checkSalesConcessionNegative(){
        TriggerSwitch__c caseSetting = TestDataUtil.createTriggerSwitch('CaseTrigger', true);
        insert caseSetting;
        
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAccTypeID;
        acc.Name='TestaccountNegative';
        insert acc;

        Sales_Concession_Request__c salesconc = new Sales_Concession_Request__c();
        salesconc.GE_LGT_Concession_Status__c = 'Not Submitted'; 
        salesconc.Concession_Type__c = 'Back Charges/Labor'; 
        //salesconc.GE_LGT_Concession_Amount__c ='Below $1K';
        salesconc.GE_LGT_Concession_Amount__c ='Below or equal to $1000';
        salesconc.GE_LGT_Actual_Amount__c =600;
        salesconc.Agent_Comission_Paid__c = 'No';
        salesconc.GE_LGT_Root_Cause_Error__c = 'GE Error - Sales';
        salesconc.Select_Required_Approver__c = 'No Approval Required';
        salesconc.GE_LGT_Project_Name__c = 'Test Project';
        salesconc.GE_LGT_Distributor__c = 'Test Distributor' ;
        salesconc.GE_LGT_Fixture_Agency__c = 'Test Fixture Agency' ;
        salesconc.Select_Root_Cause_Issue_s__c = 'Incorrect price provided to customer';
        salesconc.GE_LGT_PO_Number__c= 'Test';
        salesconc.GE_LGT_Comments__c= 'Test';
        salesconc.Region_of_Requestor__c = 'North America';
                       
        Test.startTest();
        
        insert salesconc;
        
        List<Case> CaseVar = [select id,subject,Description,Type,Origin  from case where subject=:salesconc.Name AND RecordTypeID=:Schema.SObjectType.Case.getRecordTypeInfosByName().get('North America').getRecordTypeId()];
        
        system.assertEquals(0,CaseVar.size());

        Test.stopTest(); 
         
        
    }
    
}
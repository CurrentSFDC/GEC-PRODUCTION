@isTest(Seealldata=true)
Public class TaskTriggerHelperTest
{
    public static  ID  recOppTypeID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
    public static  ID recAcTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
    Public Static Id AEAssignmentTaskId =Schema.SObjectType.Task.getRecordTypeInfosByName().get('SE Assignment Task').getRecordTypeId();
    static testMethod void AssignCasetoTask(){
        
        Id Taskrecdty = Schema.SObjectType.Task.getRecordTypeInfosByName().get('GE_LGT_EM_TaskLayout').getRecordTypeId();
        ID userID = UserInfo.getUserID();
        ID recAcTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        ID reccTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('EMEA Service Contact').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAcTypeID;
        insert acc;
        
        List<Task> task_lst = new List<Task>();
        Contact ct= TestDataUtil.createContact(acc);
        ct.RecordTypeId=reccTypeId;
        ct.OwnerID=userID;
        insert ct; 
        Task tsk=TestDataUtil.createTask();  
        tsk.RecordTypeId=Taskrecdty;
        tsk.Whatid=acc.id;
        tsk.WhoId=ct.id;
        insert tsk;
        tsk.GE_LGT_EM_Case_Status__c='closed';
        update tsk;
    }
    static testMethod void AssignCasetoTask_updatewhoid(){
        
        Id Taskrecdty = Schema.SObjectType.Task.getRecordTypeInfosByName().get('GE_LGT_EM_TaskLayout').getRecordTypeId();
        ID userID = UserInfo.getUserID();
        ID recAcTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        ID reccTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('EMEA Service Contact').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAcTypeID;
        insert acc;
        Account accnt=TestDataUtil.createAccount();
        accnt.RecordTypeId = recAcTypeID;
        insert accnt;
        List<Task> task_lst = new List<Task>();
        Contact ct= TestDataUtil.createContact(acc);
        ct.RecordTypeId=reccTypeId;
        ct.OwnerID=userID;
        insert ct; 
        // Insert Task
        Task tsk=TestDataUtil.createTask();  
        tsk.RecordTypeId=Taskrecdty;
        tsk.Whatid=acc.id;
        tsk.whoid=ct.id;
        insert tsk;
        // Insert Task one more
        Task tk=TestDataUtil.createTask();  
        tk.RecordTypeId=Taskrecdty;
        tk.whoid=ct.id;
        
        tk.GE_LGT_EM_Case_Status__c='test';
        insert tk;
    }
    static testMethod void AssignCasetoTask_updatewhoid1(){
        
        Id Taskrecdty = Schema.SObjectType.Task.getRecordTypeInfosByName().get('GE_LGT_EM_TaskLayout').getRecordTypeId();
        ID userID = UserInfo.getUserID();
        ID recAcTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        ID reccTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('EMEA Service Contact').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAcTypeID;
        insert acc;
        Account accnt=TestDataUtil.createAccount();
        accnt.RecordTypeId = recAcTypeID;
        insert accnt;
        List<Task> task_lst = new List<Task>();
        Contact ct= TestDataUtil.createContact(acc);
        ct.RecordTypeId=reccTypeId;
        ct.OwnerID=userID;
        insert ct; 
        // Insert Task
        Task tsk=TestDataUtil.createTask();  
        tsk.RecordTypeId=Taskrecdty;
        tsk.Whatid=null;
        tsk.whoid=null;
        insert tsk;
        delete tsk;
        // Insert Task one more
        Task tk=TestDataUtil.createTask();  
        tk.RecordTypeId=Taskrecdty;
        tk.whoid=ct.id;
        
        tk.GE_LGT_EM_Case_Status__c='test';
        insert tk;
        
        
        Task task1=TestDataUtil.createtask();  
        task1.RecordTypeId=Taskrecdty;
        task1.Whatid=null;
        task1.whoid=null;
        task1.Type='Call - Inbound';
        task1.Subject='Call - Inbound';
        task1.GE_LGT_EM_Case_Status__c='closed';
        Try{
            insert task1;
        }
        Catch(Exception exc1){
            Boolean expectedExceptionThrown =  exc1.getMessage().contains('Account/Contact is mandatory for an Activity with Case Status as Closed') ? true: false;
            System.AssertEquals(expectedExceptionThrown, True);
            
        }
        
    }
    static testMethod void AssignCasetoTask1(){
        
        Id Taskrecdty = Schema.SObjectType.Task.getRecordTypeInfosByName().get('GE_LGT_EM_TaskLayout').getRecordTypeId();
        ID userID = UserInfo.getUserID();
        ID recAcTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        ID reccTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('EMEA Service Contact').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAcTypeID;
        insert acc;
        
        List<Task> task_lst = new List<Task>();
        Contact ct= TestDataUtil.createContact(acc);
        ct.RecordTypeId=reccTypeId;
        ct.OwnerID=userID;
        insert ct; 
        Task tsk=TestDataUtil.createTask();  
        tsk.RecordTypeId=Taskrecdty;
        tsk.Whatid=acc.id;
        tsk.WhoId=null;
        tsk.Task_cost__c=100;
        insert tsk;
        tsk.GE_LGT_EM_Case_Status__c='closed';
        update tsk;
    }
    static testmethod void createTaskTest1()
    {
        TriggerSwitch__c triSwitch=new TriggerSwitch__c(Name='TaskTrigger',isActive__c=True);
        //  insert triSwitch;
        ID reqRecTypeID= Schema.SObjectType.Task.getRecordTypeInfosByName().get('Contract Task').getRecordTypeId();
        ID AE_AssignRecID= Schema.SObjectType.Task.getRecordTypeInfosByName().get('SE Assignment Task').getRecordTypeId();
        //ID AE_AssignRecID= Schema.SObjectType.Task.getRecordTypeInfosByName().get('AE Assignment Task').getRecordTypeId();
        System.debug('assignid'  + AE_AssignRecID);
        
        Task task=new Task(RecordTypeID=reqRecTypeID,subject='Test');
        task.Sales_AE_Requestor__c=userinfo.getuserId();
        task.status = 'Not Started';  
      
            insert task;
        
        Task task1=new Task(RecordTypeID=AE_AssignRecID, subject='Call');
        task1.status = 'Not Started'; 
        task1.Sales_AE_Requestor__c=userinfo.getuserId();
        insert task1;
        task1.status ='Completed';
        
        update task1;
        
        
    }
    static testMethod void ValidateAcctAndCont(){
        
        Id Taskrecdty = Schema.SObjectType.Task.getRecordTypeInfosByName().get('GE_LGT_EM_TaskLayout').getRecordTypeId();
        ID userID = UserInfo.getUserID();
        ID reccTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('EMEA Service Contact').getRecordTypeId();
        Contact ct = new Contact();
        ct.LastName='Test AA';
        ct.FirstName='Hello';
        ct.Email='saikrishna@ge.com';
        ct.Phone='8106131465';
        ct.RecordTypeId=reccTypeId;
        ct.OwnerID=userID;
        insert ct; 
        Task task1=TestDataUtil.createtask();  
        task1.RecordTypeId=Taskrecdty;
        task1.Whatid=null;
        task1.whoid=null;
        task1.Type='Call - Inbound';
        task1.Subject='Call - Inbound';
        task1.GE_LGT_EM_Case_Status__c='closed';
        Try{
            insert task1;
        }
        Catch(Exception exc1){
            Boolean expectedExceptionThrown =  exc1.getMessage().contains('Account/Contact is mandatory for an Activity with Case Status as Closed') ? true: false;
            System.AssertEquals(expectedExceptionThrown, True);
            
        }
        Try{
            task1.WhoId=ct.Id;
            insert task1;
        }
        Catch(Exception exc1){
            Boolean expectedExceptionThrown =  exc1.getMessage().contains('There is no Account associated with the Contact present in the Activity') ? true: false;
            System.AssertEquals(expectedExceptionThrown, True);
            
        }
        
    }
    static testMethod void AssignCasetoTask3(){
        ID Caserecdty =Schema.SObjectType.Case.getRecordTypeInfosByName().get('GE Lighting EMEA').getRecordTypeId();
        Id Taskrecdty = Schema.SObjectType.Task.getRecordTypeInfosByName().get('GE_LGT_EM_TaskLayout').getRecordTypeId();
        ID userID = UserInfo.getUserID();
        ID recAcTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        ID reccTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('EMEA Service Contact').getRecordTypeId();
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAcTypeID;
        acc.GE_LGT_EM_PF_Type__c='SP';
        insert acc;
        String skuNum='545655';
        GE_LGT_EM_MaterialMaster__c MM= TestDataUtil.createMaterialMaster(skuNum);
        Insert MM;
        //Case creation
        Case cs= new Case();                         
        cs.AccountId=acc.id;                  
        cs.status='Open';
        cs.subject='Call - Inbound';
        cs.Description='Call - Inbound';
        cs.Origin='Phone';
        // cs.Type=t.GE_LGT_EM_Call_Reason__c; 
        cs.ownerid=userinfo.getUserId();
        cs.recordtypeid=Caserecdty;
        insert cs;
        //case creation ended
        //Complaint line item creation
        GE_LGT_EM_ComplaintLineItem__c cmpl = new GE_LGT_EM_ComplaintLineItem__c();
        cmpl.GE_LGT_EM_CaseNumber__c=cs.Id;
        cmpl.GE_LGT_EM_Material_Number__c=MM.Id;
        cmpl.GE_LGT_EM_Category__c='129-Input of wrong quantity-No return';
        cmpl.GE_LGT_EM_ApprovalProcessSteps__c='129-CRC';
        cmpl.CurrencyIsoCode='USD';
        cmpl.GE_LGT_EM_Complaint_Reference_Number__c=10;
        GE_LGT_EM_SAPWebservice.blnflag=false;
        Test.setMock(WebServiceMock.class, new GE_LGT_EM_171WebServiceMockImpl_test());
        Insert cmpl;
        
        
        List<Task> task_lst = new List<Task>();
        Contact ct= TestDataUtil.createContact(acc);
        ct.RecordTypeId=reccTypeId;
        ct.OwnerID=userID;
        insert ct; 
        Task tsk=TestDataUtil.createTask();  
        tsk.RecordTypeId=Taskrecdty;
        tsk.Whatid=cmpl.GE_LGT_EM_CaseNumber__c;
        tsk.WhoId=null;
        tsk.Subject='Call - Inbound';
        tsk.Task_cost__c=100;
        insert tsk;
        //  System.assert(false,'Listtask--' +tsk);
        tsk.GE_LGT_EM_Case_Status__c='closed';
        update tsk;
    }
    static testmethod void AssignOpptoTask()
    {
        TriggerSwitch__c triSwitch=new TriggerSwitch__c(Name='TaskTrigger',isActive__c=True);
        //  insert triSwitch;
        ID reqRecTypeID= Schema.SObjectType.Task.getRecordTypeInfosByName().get('Contract Task').getRecordTypeId();
        ID AE_AssignRecID= Schema.SObjectType.Task.getRecordTypeInfosByName().get('SE Assignment Task').getRecordTypeId();
        //ID AE_AssignRecID= Schema.SObjectType.Task.getRecordTypeInfosByName().get('AE Assignment Task').getRecordTypeId();
        System.debug('assignid'  + AE_AssignRecID);
        
        Account acc=TestDataUtil.createAccount();
        acc.RecordTypeId = recAcTypeID;
        acc.GE_LGT_EM_PF_Type__c='SP';
        insert acc;
        // INSERT OPPTY RECORD
        Opportunity opp = TestDataUtil.createOpportunity(acc);
        opp.RecordTypeId=recOppTypeID;
        
        insert opp;
        GE_LGT_EM_MaterialMaster__c matrial=TestDataUtil.createMaterialMaster('99999');
        insert matrial;
        
        Task task=new Task(RecordTypeID=AEAssignmentTaskId,subject='Test');
        task.Sales_AE_Requestor__c=userinfo.getuserId();
        task.status = 'Not Started';  
         task.GE_LGT_Task_type__c = 'Design';
        task.ActivityDate = System.Today()+3;
  
        
        Task task1=new Task(RecordTypeID=AE_AssignRecID, subject='Call');
        task1.status = 'Not Started'; 
        task1.Sales_AE_Requestor__c=userinfo.getuserId();
        
        Try{
            insert task;
        }
        Catch(Exception exc1){
            Boolean expectedExceptionThrown =  exc1.getMessage().contains('The Due Date on task cannot be within 7 days from today ') ? true: false;
            System.AssertEquals(expectedExceptionThrown, True);
            
        }
        
       
        
    }
    
}
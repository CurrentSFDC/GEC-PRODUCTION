@isTest(Seealldata=true)
    Public class GE_LGT_EM_AssignCase_Test
    {
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
        }
    }
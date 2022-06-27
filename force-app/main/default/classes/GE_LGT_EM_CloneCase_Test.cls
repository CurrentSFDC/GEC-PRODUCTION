@isTest
public class GE_LGT_EM_CloneCase_Test 
{
    static testmethod void testCloneCase()
    {
       /* List<TriggerSwitch__c> switchList=TestDataUtil.insertTriggerSwitches();
        insert switchList;*/
        TriggerSwitch__c taskTrig = new TriggerSwitch__c();
        taskTrig.Name='TaskTrigger';
        taskTrig.TriggerName__c = 'TaskTrigger';
        taskTrig.isActive__c = true;
        insert taskTrig;
        Map<string,string> RecrdIdMap=new Map<string,string>(); 
        List<RecordType> recrdlist=new List<RecordType>([select id,Name from RecordType]); 
        for(Recordtype rt:recrdlist)
        {
            RecrdIdMap.put(rt.Name,rt.Id);      
        }
        
        Id recAcTypeID = RecrdIdMap.get('SAP Account');
        Account acc = TestDataUtil.createAccount();
        acc.RecordTypeId = recAcTypeId;
        acc.GE_LGT_EM_PF_Type__c='SP';
        insert acc;
        Case cs = TestDataUtil.createCase(acc);
        cs.Origin='Email';            
        cs.Subject='Subject for Test Class';
        cs.Description ='Test Class';            
        insert cs; 
        
        Emailmessage emm=new Emailmessage();
        emm.Incoming = true;
        emm.status='0';
        emm.subject='Email Message Test Class';            
        emm.parentid=cs.id;
        emm.textbody='Unit Test';
        insert emm;
        ApexPages.currentPage().getParameters().put('id',cs.Id);
        Test.startTest();
        GE_LGT_EM_CloneCase cloneCase=new GE_LGT_EM_CloneCase();
        cloneCase.cloneCase();
        Test.stopTest();
    }
    static testmethod void testCloneCase1()
    {
        /*List<TriggerSwitch__c> switchList=TestDataUtil.insertTriggerSwitches();
        insert switchList;*/
         TriggerSwitch__c taskTrig = new TriggerSwitch__c();
        taskTrig.Name='TaskTrigger';
        taskTrig.TriggerName__c = 'TaskTrigger';
        taskTrig.isActive__c = true;
        insert taskTrig;
        Map<string,string> RecrdIdMap=new Map<string,string>(); 
        List<RecordType> recrdlist=new List<RecordType>([select id,Name from RecordType]); 
        for(Recordtype rt:recrdlist)
        {
            RecrdIdMap.put(rt.Name,rt.Id);      
        }
        
        Id recAcTypeID = RecrdIdMap.get('SAP Account');
        Account acc = TestDataUtil.createAccount();
        acc.RecordTypeId = recAcTypeId;
        acc.GE_LGT_EM_PF_Type__c='SP';
        insert acc;
        Case cs = TestDataUtil.createCase(acc);
        cs.Origin='Email';            
        cs.Subject='Subject for Test Class';
        cs.Description ='Test Class';            
        insert cs; 
        
        Emailmessage emm=new Emailmessage();
        emm.Incoming = true;
        emm.status='0';
        emm.subject='Email Message Test Class';            
        emm.parentid=cs.id;
        emm.textbody='Unit Test';
        insert emm;
        List<Emailmessage> elist=new List<Emailmessage>();
        elist.add(emm);
        ApexPages.currentPage().getParameters().put('id',cs.Id);
        Test.startTest();
        GE_LGT_EM_CloneCase cloneCase=new GE_LGT_EM_CloneCase();
        GE_LGT_EM_CloneCase.EmailMessageWrapper emw=new GE_LGT_EM_CloneCase.EmailMessageWrapper(emm,true);
        List<GE_LGT_EM_CloneCase.EmailMessageWrapper> emwWrapper=new List<GE_LGT_EM_CloneCase.EmailMessageWrapper>();
        emwWrapper.add(emw);
        clonecase.EmailMsgWrapper=emwWrapper;
        cloneCase.cloneCase();
        cloneCase.close();
        Test.stopTest();
    }
}
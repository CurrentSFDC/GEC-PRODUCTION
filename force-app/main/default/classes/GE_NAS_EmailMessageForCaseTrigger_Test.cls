@isTest
public class GE_NAS_EmailMessageForCaseTrigger_Test
{
    static testMethod void GE_NAS_EmailMessageForCaseTrigger()   
    {    
        /*List<TriggerSwitch__c> switchList=TestDataUtil.insertTriggerSwitches();
        insert switchList;*/
         TriggerSwitch__c taskTrig = new TriggerSwitch__c();
        taskTrig.Name='TaskTrigger';
        taskTrig.TriggerName__c = 'TaskTrigger';
        taskTrig.isActive__c = true;
        insert taskTrig;
        
        ID userID = UserInfo.getUserID();
        ID recAcTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Account' AND NAME='SAP Account'].ID;
        ID reccTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Contact' AND NAME='NA Service Contact'].ID;
        ID reccaseTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Case' AND NAME='North America'].ID;
        
       
        Account acc = TestDataUtil.createAccount();
        acc.RecordTypeId = recAcTypeId;
        acc.GE_LGT_EM_PF_Type__c='SP';
        acc.Name='Test Ac';
        acc.CurrencyIsoCode='USD';
        acc.accountnumber='9854678';
        insert acc;
        
        
        Contact ct=TestDataUtil.createContact(acc);
        ct.RecordTypeId = reccTypeId;
        ct.LastName='Contact';
        ct.FirstName='Claim';
        ct.Email='sai1@ge.com';
        ct.OwnerID=userID;
        ct.GE_LGT_Row_Id__c='1-JR6HG4';
        insert ct;       
        
        Case cs = new Case();
        cs.RecordTypeId = reccaseTypeID;
        cs.Accountid=acc.ID;
        cs.Contactid=ct.id;
        cs.Origin='Phone';
        cs.GE_LGT_Business__c='North America';
        cs.Subject='Test';
        cs.Status='Closed';
        cs.GE_NAS_NCSC_Resolution__c = 'Answered';
        insert cs;
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(cs.Id, yesterday);
        
        
        GE_NAS_CaseRoutingePersonalEmails__c csroutemail=new GE_NAS_CaseRoutingePersonalEmails__c();
        csroutemail.name='test user';
        csroutemail.GE_NAS_Case_Routing_Email__c='TestEmail.vuddanti@ge.com';
        csroutemail.GE_NAS_Personal_Email__c='TestEmail1.vuddanti@ge.com';
        csroutemail.GE_NAS_Active__c = true;
        insert csroutemail;
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'fromme@ge.org', Incoming = True, ToAddress= 'toyou@ge.com',CCAddress='TestEmail.vuddanti@ge.com', Subject = 'Test email',TextBody = '23456 ', ParentId = cs.Id)); 
        insert newEmail;
        test.starttest();
        case testcase=[select Id,Status, GE_NAS_Sub_Status__c from case where id=:cs.id limit 1];
        System.assertEquals('Open', testcase.Status);
        System.assertEquals('Reopened', testcase.GE_NAS_Sub_Status__c);
        
        EmailMessage[] newEmail1 = new EmailMessage[0];
        newEmail1.add(new EmailMessage(FromAddress = 'fromme@ge.org', Incoming = false, ToAddress= 'toyou@ge.com',CCAddress='TestEmail.vuddanti@ge.com', Subject = 'Test email', TextBody = '23456 ', ParentId = cs.Id)); 
        insert newEmail1;
        EmailMessage TestEmailMsg= [SELECT ID,Incoming,MessageDate FROM EMAILMESSAGE WHERE INCOMING=false and PARENTID = :cs.ID limit 1];
        case testcase1=[select Id,CreatedDate,GE_NAS_FirstResponseHrs__c, GE_NAS_FirstResponseMins__c from case where id=:cs.id limit 1];
        long responseMilliSecs = TestEmailMsg.MessageDate.getTime() - testcase1.CreatedDate.getTime();
        System.assertEquals(Integer.valueOf(responseMilliSecs/(1000*60*60)), testcase1.GE_NAS_FirstResponseHrs__c);
        System.assertEquals(Integer.valueOf(math.mod((responseMilliSecs/(1000*60)),60)), testcase1.GE_NAS_FirstResponseMins__c);
        Profile objProfile = [Select Id, Name from Profile where Name =:'EUROPE Current Super User' limit 1];
        User u2=OpportunityTriggerHelper_Test.createuser(objProfile.id,'Europe',true);
        System.runAs(u2){
            try{
                delete newEmail1;
            }
             catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('INSUFFICIENT_ACCESS_OR_READONLY') ? true : false;
                System.AssertEquals(false, expectedExceptionThrown);
            }
        }
        test.stoptest();
        delete newEmail1;
        EmailMessage[] newEmail2 = new EmailMessage[0];
        newEmail2.add(new EmailMessage(FromAddress = 'fromme@ge.org', Incoming = True, ToAddress= 'toyou@ge.com;TestEmail.vuddanti@ge.com;TestEmail.vuddanti@ge.com;TestEmail.vuddanti@ge.com;TestEmail.vuddanti@ge.com;TestEmail.vuddanti@ge.com;TestEmail.vuddanti@ge.com;TestEmail.vuddanti@ge.com;TestEmail.vuddanti@ge.com;TestEmail.vuddanti@ge.com;TestEmail.vuddanti@ge.com;TestEmail.vuddanti@ge.com',CCAddress='TestEmail.vuddanti@ge.com', Subject = 'Test email', TextBody = '23456 ', ParentId = cs.Id)); 
        insert newEmail2;
        
        
    }
}
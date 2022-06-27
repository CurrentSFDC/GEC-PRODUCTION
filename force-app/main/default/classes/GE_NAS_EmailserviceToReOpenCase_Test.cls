@isTest
Public class GE_NAS_EmailserviceToReOpenCase_Test
{   
    //Rashmitha Changed the API vesion from 29 to 45 on 6-Mar-2019 as per 1447 request
    static testMethod void EmailserviceToReOpenCase()   
    {
        List<TriggerSwitch__c> switchList=TestDataUtil.insertTriggerSwitches();
        insert switchList;
        
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope(); 
        ID userID = UserInfo.getUserID();
        ID recAcTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Account' AND NAME='SAP Account'].ID;
        ID reccTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Contact' AND NAME='NA Service Contact'].ID;
        ID reccaseTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Case' AND NAME='North America'].ID;
        
        Account acc = TestDataUtil.createAccount();
    acc.RecordTypeId = recAcTypeId;
        acc.GE_LGT_EM_PF_Type__c='SP';
     acc.Name='Test Ac';
        acc.CurrencyIsoCode='USD';
        insert acc;
        
       
        Contact ct=TestDataUtil.createContact(acc);
        ct.RecordTypeId = reccTypeId;
        ct.LastName='Test Cont2';
        ct.Email='sai1@ge.com';
        ct.OwnerID=userID;
        insert ct;
        
        Case c1 = new Case();
        c1.RecordTypeId = reccaseTypeID;
        c1.Accountid=acc.ID;
        c1.Contactid=ct.id;
        c1.Subject='TEST1';
        c1.Type='Account Management';
        c1.GE_NAS_Sub_Type__c='CPRD Maintenance';
        c1.Priority='Medium';
        c1.Status='Open';
        insert c1;
        email.plainTextBody = 'This is a note';
        email.fromAddress ='test@test.com';
        String contactEmail = 'sai1@ge.com';
        email.ccAddresses = new String[] {'sai1 <' + contactEmail + '>'};
            email.subject = 'test 123';
        
        Case c2= new case();
        c2 = [SELECT ID,STATUS,GE_NAS_Sub_Status__c FROM CASE WHERE Subject='TEST1'];  
        C2.Status = 'Open';  
        c2.GE_NAS_Sub_Status__c = 'In Process'; 
        update C2;
        GE_NAS_EmailserviceToReOpenCase emailServiceObj = new GE_NAS_EmailserviceToReOpenCase(); 
        email.subject = 'REOPEN:' + C1.ID; 
        emailServiceObj.handleInboundEmail(email, env );                       
    }
}
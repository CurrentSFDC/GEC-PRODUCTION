@isTest
Public class GE_LGT_EM_UpdateNewEmailStatus_Test
{
    static testMethod void UpdateCaseStatusFlags()
    {
        List<TriggerSwitch__c> switchList=TestDataUtil.insertTriggerSwitches();
        insert switchList;
        
        ID userID = UserInfo.getUserID();
        Map<string,string> RecrdIdMap=new Map<string,string>(); 
        List<RecordType> recrdlist=new List<RecordType>([select id,Name from RecordType]); 
        for(Recordtype rt:recrdlist)
        {
            RecrdIdMap.put(rt.Name,rt.Id);      
        }
        Id reccaseTypeID = RecrdIdMap.get('GE Lighting EMEA');
        Id reccTypeID = RecrdIdMap.get('EMEA Service Contact');
        Id recAcTypeID = RecrdIdMap.get('SAP Account');
        
        //Account acc = new Account(RecordTypeId = recAcTypeId,Name='Test Ac',CurrencyIsoCode='USD',GE_LGT_EM_SAP_Customer_Number__c ='0098546781');
        Account acc = TestDataUtil.createAccount();
        acc.GE_LGT_EM_PF_Type__c='SP';
        acc.RecordTypeId = recAcTypeId;
        acc.Name='Test Ac';
        acc.CurrencyIsoCode='USD';
        acc.GE_LGT_EM_SAP_Customer_Number__c ='0098546781';
        insert acc;
        
        Contact ct=TestDataUtil.createContact(acc);
        ct.RecordTypeId = reccTypeId;
        ct.LastName='Test';
        ct.FirstName='Hello';
        ct.Email='anudeep@ge.com';
        ct.OwnerID=userID;
        ct.Phone='8008913597';
        insert ct;  
        
        //Profile p = [SELECT Id FROM Profile WHERE Name='GE Lighting EMEA']; 
        //Profile p = [SELECT Id FROM Profile WHERE Name='GE_LGT_Customer_Service_EMEA']; 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@ge.com.sitna');
        
        Case cs = new Case();
        cs.RecordTypeId = reccaseTypeID;
        cs.Accountid=acc.ID;
        cs.Contactid=ct.id;
        cs.Origin='Email Test';            
        cs.Subject='Subject for Test Class';
        cs.Description ='Updating new email flag and hasattachment flag for case';
        insert cs;
        
        Emailmessage em=new Emailmessage();
        em.Incoming = true;
        em.status='0';
        em.subject='Email Message Test Class';            
        em.parentid=cs.id;
        em.textbody='Unit Test';
        insert em;
        
        
        Attachment at=new Attachment();
        at.parentid=em.id;                        
        at.name='Test Att';
        at.body=Blob.valueOf('Unit Test Attachment Body');   
        insert at; 
        try
        {
            System.runAs(u) 
            {                                              
                System.debug('Current User: ' + UserInfo.getUserName());
                System.debug('Current Profile: ' + UserInfo.getProfileId()); 
                delete em;                         
            }
        }
        catch(Exception ee)
        {
            System.debug('Error Message: ' + ee.getmessage());  
        }           
    }        
}
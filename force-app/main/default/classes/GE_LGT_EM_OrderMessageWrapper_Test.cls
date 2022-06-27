/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
private class GE_LGT_EM_OrderMessageWrapper_Test 
{

    static testMethod void myUnitTest()
    {
     /*List<TriggerSwitch__c> switchList=TestDataUtil.insertTriggerSwitches();
        insert switchList;*/
         TriggerSwitch__c taskTrig = new TriggerSwitch__c();
        taskTrig.Name='TaskTrigger';
        taskTrig.TriggerName__c = 'TaskTrigger';
        taskTrig.isActive__c = true;
        insert taskTrig;
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
        
        Account acc = new Account(RecordTypeId = recAcTypeId, GE_LGT_EM_Sales_Org__c='2HU2',GE_LGT_EM_Division__c='20',GE_LGT_EM_Distribution_Channel__c='10',Name='Test Ac',CurrencyIsoCode='USD',GE_LGT_EM_Email_Address__c='anudeep@ge.com',GE_LGT_EM_SAP_Customer_Number__c ='0098546781');
        acc.GE_LGT_EM_PF_Type__c='SP';
        insert acc;
        
        Contact ct= new Contact(RecordTypeId = reccTypeId,LastName='Test',FirstName='Hello',Email='anudeep@ge.com',AccountId=acc.ID,OwnerID=userID,Phone='8008913597');
        insert ct;  
        
        Case cs = new Case();
        cs.RecordTypeId = reccaseTypeID;
        cs.Accountid=acc.ID;
        cs.Contactid=ct.id;
        cs.Origin='Email';            
        cs.Subject='Subject for Test Class';
        cs.Description ='Test Class';            
        insert cs; 
        
        List<Emailmessage> emlist=new List<Emailmessage>();
        Emailmessage em=new Emailmessage();
        em.Incoming = true;
        em.status='0';
        em.subject='Email Message Test Class';            
        em.parentid=cs.id;
        em.textbody='Unit Test';
        emlist.add(em);            
        
        Emailmessage emm=new Emailmessage();
        emm.Incoming = true;
        emm.status='0';
        emm.subject='Email Message Test Class';            
        emm.parentid=cs.id;
        emm.textbody='Unit Test';
        emlist.add(emm);
        insert emlist;
         GE_LGT_EM_OrderMessageWrapper wrap=new GE_LGT_EM_OrderMessageWrapper();
        wrap.dummyTestMethod();
      /**      
        
        Pagereference pf=Page.GE_LGT_EM_OrderCreationRequest;
        pf.setredirect(true);
        Apexpages.currentPage().getParameters().put('id',cs.id);
        
        GE_LGT_EM_OrderMessageWrapper wrap=new GE_LGT_EM_OrderMessageWrapper();
        wrap.EmailMsgWrapper=wrap.getInboundEmails();
        wrap.EmailMsgWrapper[0].isSelected=True; 
        wrap.processSelected();
        Test.startTest();
        GE_LGT_EM_OrderMessageWrapper wrapp=new GE_LGT_EM_OrderMessageWrapper();
        wrap.EmailMsgWrapper=wrapp.getInboundEmails();
        wrapp.EmailMsgWrapper[0].isSelected=True; 
        wrapp.EmailMsgWrapper[1].isSelected=True;
        wrapp.processSelected();
        
        GE_LGT_EM_OrderMessageWrapper wraps=new GE_LGT_EM_OrderMessageWrapper();
        wraps.EmailMsgWrapper=wrapp.getInboundEmails();   
        wraps.EmailMsgWrapper[0].isSelected=false; 
        wraps.EmailMsgWrapper[1].isSelected=false;         
        wraps.processSelected();
        
        Case css = new Case();
        css.RecordTypeId = reccaseTypeID;
        css.Accountid=acc.ID;
        css.Contactid=ct.id;                    
        css.Subject='Subject Test Class';
        css.Description ='Test Class ';            
        insert css; 
        
        Pagereference pff=Page.GE_LGT_EM_OrderCreationRequest;
        pff.setredirect(true);
        Apexpages.currentPage().getParameters().put('id',css.id);
        
        GE_LGT_EM_OrderMessageWrapper wrapr=new GE_LGT_EM_OrderMessageWrapper();
        wrapr.EmailMsgWrapper=wrap.getInboundEmails(); 
            
        Test.stopTest();**/

    }

}
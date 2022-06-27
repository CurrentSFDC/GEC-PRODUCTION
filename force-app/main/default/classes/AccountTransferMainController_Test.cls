@isTest(seealldata=true)
public class AccountTransferMainController_Test {
    //Rashmitha Changed the API vesion from 34 to 45 on 6-Mar-2019 as per 1447 request
    static testMethod void AccountTransfer(){
        //Create test data
        
        //Grab standard user profile id
        Profile p = [SELECT Id FROM Profile WHERE Name='NA Current Super User'];
         ID  recAccTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();  
         ID  recAccendTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
       //ID  recAccTypeIDagent=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Daintree Reseller').getRecordTypeId();
      	ID  recAccTypeIDagent=Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Agent').getRecordTypeId();
          List<Account> accList = new List<Account>();           
        //ID  recAccTypeIDagent=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
       
        Account AccountOnOpportnity =TestDataUtil.createAccount();  
        AccountOnOpportnity.Name='Test Account';
        AccountOnOpportnity.RecordTypeId=recAccendTypeID;
        AccountOnOpportnity.GE_LGT_EM_CustomerActiveFlag__c=true;
        AccountOnOpportnity.type='End User';
        Account oldAccount =TestDataUtil.createAccount(); 
        oldAccount.RecordTypeId=recAccTypeID;
        oldAccount.type='Distributor';
        Account newSAPAccount = TestDataUtil.createAccount();
        newSAPAccount.Name='SAP Account';
        newSAPAccount.RecordTypeId=recAccTypeIDagent;
          newSAPAccount.type='End User';
           newSAPAccount.GE_LGT_EM_CustomerActiveFlag__c=true;
        accList.add(AccountOnOpportnity);
        accList.add(oldAccount);
        accList.add(newSAPAccount);
       
        Test.startTest();
        insert accList;
        
        User TestUser =TestDataUtil.createUser(p.id,'tom.riley@ge.com');
        
        TestUser.FirstName='Tom';TestUser.LastName='Riley';TestUser.isActive=true;TestUser.Alias='TomR';TestUser.Email='tom.riley@ge.com';TestUser.Username='tom.riley@ge.com.aluat';TestUser.CommunityNickname='Tommy';TestUser.TimeZoneSidKey='America/New_York';TestUser.LocaleSidKey='en_US';TestUser.EmailEncodingKey='ISO-8859-1';TestUser.LanguageLocaleKey='en_US';
        TestUser.GE_LGT_Business_Division__c='MEAT';
        insert TestUser;
         AccountTeamMember newTeam = new AccountTeamMember(AccountId = oldAccount.ID,TeamMemberRole = 'Technical Sales',UserId = TestUser.ID);
        insert newTeam;
        
        //bulkification by Neel
        List<Opportunity> oppList = new List<Opportunity>();
     
           
            ID  recOppTypeID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
            Opportunity OldDistributorOpp = TestDataUtil.createOpportunity(AccountOnOpportnity);
            OldDistributorOpp.Name='Distributor Opportunity11';OldDistributorOpp.StageName = 'S1 Consult';OldDistributorOpp.CurrencyIsoCode='USD';OldDistributorOpp.Probability=20;OldDistributorOpp.CloseDate=System.Today()+1 ;OldDistributorOpp.GE_LGT_Distributor__c = oldAccount.id;
            OldDistributorOpp.RecordTypeId=recOppTypeID;
            insert OldDistributorOpp;
            Opportunity OldAgentOpp = TestDataUtil.createOpportunity(newSAPAccount);
            OldAgentOpp.RecordTypeId=recOppTypeID;
        system.debug('newSAPAccount.Id'+newSAPAccount.Id);
            OldAgentOpp.Name='Agent Opportunity2';OldAgentOpp.StageName = 'S1 Consult';OldAgentOpp.CurrencyIsoCode='USD';OldAgentOpp.Probability=10;OldAgentOpp.CloseDate=System.Today()+1 ;OldAgentOpp.GE_LGT_Agent__c = newSAPAccount.Id;
            insert OldAgentOpp;
            
            Partner Partner1 = new Partner(OpportunityId= OldDistributorOpp.Id, AccountToId=oldAccount.Id);
            insert Partner1;
            
            //Test Contacts
            //bulkification by Neel
            List<Contact> contList = new List<Contact>();
            Contact Contact1 =TestDataUtil.createContact(oldAccount);
            Contact1.FirstName='Test';Contact1.LastName='Contact1';Contact1.Phone= '123-456-7890';
            Contact Contact2 = TestDataUtil.createContact(oldAccount);
            Contact2.FirstName='Test';Contact2.LastName='Contact2';Contact2.Phone= '123-456-7890';
            contList.add(Contact1);
            contList.add(Contact2);
            
            
            insert contList;
            Test.stopTest();
            
            
            //Test AccountTeamMembers
            
            AccountTeamMember TeamMember = new AccountTeamMember(AccountId=oldAccount.Id, UserId=TestUser.Id);
            insert TeamMember;
            
            AccountTeamMember testTM=[select id,Accountid,userid from AccountTeamMember where id=:TeamMember.id limit 1];
            system.assert(testTM!=null);
            system.assertEquals(testTM.Accountid,oldAccount.Id);
            system.assertEquals(testTM.userid ,TestUser.Id);
            PageReference pageReftemp = Page.AccountTransferPopup;
            system.Test.setCurrentPage(pageReftemp); 
            ApexPages.currentPage().getParameters().put('id', oldAccount.Id);
            AccountTransferMainController Atmc = new AccountTransferMainController();
            atmc.autoRun();
            system.assertEquals(Atmc.oldAccount.name,oldAccount.name);
            atmc.accountId = newSAPAccount.Id;
            atmc.oldAccountId = oldAccount.Id;
           
            PageReference p1 = atmc.TransferData();
            atmc.oldAccountId = newSAPAccount.Id;
            PageReference p2 = atmc.TransferData();
       
    }
}
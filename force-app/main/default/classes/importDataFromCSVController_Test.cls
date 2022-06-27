@isTest
public class importDataFromCSVController_Test 
{
    static testMethod void MergeAccounts()
    {
        List<TriggerSwitch__c> switchList=TestDataUtil.insertTriggerSwitches();
        insert switchList;
        
        //Grab standard user profile id
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        ID distributorRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();//Distributor
        ID agentRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();     //SAP Account - Fixture Agent   
        id opprecordtypid= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        // Test Accounts to use for transfer, oldAccount will be the old Account that the data is associated to now, after script runs 
        // newSAPAccount will be the account all records are associated to
        List<Account> accList=new List<Account>();
        Account AccountOnOpportnity = TestDataUtil.createAccount();
        AccountOnOpportnity.Name='Test Account';
        
        Account oldAccount = TestDataUtil.createAccount();
        oldAccount.RecordTypeId = distributorRecTypeId;
        oldAccount.Type = 'Distributor';
        
        Account newSAPAccount = TestDataUtil.createAccount();
        newSAPAccount.RecordTypeId = agentRecTypeId;
        newSAPAccount.GE_LGT_EM_CustomerActiveFlag__c=true;
        newSAPAccount.GE_LGT_EM_CustomerActiveFlag__c = True;
        accList.add(AccountOnOpportnity);
        accList.add(oldAccount);
        accList.add(newSAPAccount);
        //Test User
        User TestUser = new User(FirstName='Tom', LastName='Riley',isActive=true,Alias='TomR',Email='tom.riley@ge.com',Username='tom.riley@ge.com.aluat',CommunityNickname='Tommy', TimeZoneSidKey='America/New_York', LocaleSidKey='en_US',EmailEncodingKey='ISO-8859-1',ProfileId=p.Id,LanguageLocaleKey='en_US',GE_LGT_Business_Division__c='Europe',GE_LGT_Region__c='Europe Functional',GE_LGT_Sub_Region__c='Europe Operations');
        insert TestUser;
            system.runas(TestUser){
        insert accList;
        
        
    
        //Test Opportunities
        Opportunity OldDistributorOpp =TestDataUtil.createOpportunity(AccountOnOpportnity);
        OldDistributorOpp.Name='Distributor Opportunity';
        OldDistributorOpp.StageName = 'S1 Consult';
        OldDistributorOpp.CurrencyIsoCode='USD';
       OldDistributorOpp.RecordTypeId=opprecordtypid;
        OldDistributorOpp.Probability=20;
        OldDistributorOpp.CloseDate=system.today()+4;
        OldDistributorOpp.GE_LGT_Distributor__c=oldAccount.Id;
        
        Opportunity OldAgentOpp =TestDataUtil.createOpportunity(AccountOnOpportnity);
        OldAgentOpp.Name='Agent Opportunity';
        OldAgentOpp.StageName = 'S1 Consult';
        OldAgentOpp.CurrencyIsoCode='USD';
         OldAgentOpp.RecordTypeId=opprecordtypid;
        OldAgentOpp.Probability=20;
        OldAgentOpp.CloseDate=system.today()+4;
        OldAgentOpp.GE_LGT_Distributor__c=oldAccount.Id;
        
        insert OldDistributorOpp;
        insert OldAgentOpp;
       
       
        
        //Test Contacts
        Contact contact1=TestDataUtil.createContact(oldAccount);
        contact1.FirstName='Test';
        contact1.LastName='Contact1';
        contact1.Phone='123-456-7890';
        
        Contact contact2=TestDataUtil.createContact(oldAccount);
        contact2.FirstName='Test';
        contact2.LastName='Contact2';
        contact2.Phone='123-456-7890';
        
        List<Contact> contList=new List<Contact>();
        contList.add(contact1);
        contList.add(contact2);
        insert contList;
        
        //Test AccountTeamMembers
        AccountTeamMember TeamMember = new AccountTeamMember(AccountId=oldAccount.Id, UserId=TestUser.Id);
        insert TeamMember;
        
        String testAccounts = oldAccount + ',' + newSAPAccount;
        Blob body = Blob.valueOf(testAccounts);
        
        PageReference pageReftemp = Page.ExcelAccountMapping;
        system.Test.setCurrentPage(pageReftemp);
        importDataFromCSVController idfc = new importDataFromCSVController();
        idfc.csvFileBody = body;
        idfc.OldAcc = newSAPAccount;
        idfc.SAPAcc = oldAccount;
        idfc.importCSVFile();
         }
    }
}
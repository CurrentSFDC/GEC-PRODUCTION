@isTest
public class caseNotesTimeTracking_Test {
    
    @testSetup static void createCase(){
        //CREATE NEW ACCOUNT
        Id recordTypeAccountId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('GE_LGT_EM_Account').getRecordTypeId();
        User Usr = new User();
        Usr = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        
        Account newAccount = new Account();
        newAccount.Name = 'Current Tech Support';
        newAccount.GE_LGT_EM_SAP_Customer_Number__c = 'TEST-123456789';
        newAccount.GE_LGT_EM_Partner_Function__c = 'Payer';
        newAccount.RecordTypeId = recordTypeAccountId;
        //newAccount.OwnerId = '005i0000003cGvaAAE';
        newAccount.OwnerId = Usr.Id;
        insert newAccount;
        
        //System.debug('Account Name: '+ newAccount.Name ' and ID:' + newAccount.Id);
        
        // CREATE NEW CASE
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Current_Tech_Support').getRecordTypeId();
        
        Case newCase = new Case();
        newCase.RecordTypeId = recordTypeId;
        newCase.End_User_Company__c = newAccount.Id;
        newCase.Product_Area__c = 'IMS';
        //newCase.OwnerId = '005i0000003cGvaAAE';
        newCase.OwnerId = Usr.Id;
        insert newCase; 
        
        
        
        Case_Notes__c newNote = new Case_Notes__c();
        newNote.Case__c = newCase.Id;
        newNOte.Note__c = 'This is a Test Note';
        newNote.Note_Type__c = 'Update Note';
        newNote.Subject__c = 'Testing 1234';
        insert newNote; 
      
    }
    
    static testMethod void testGetAllNotes(){
        Case getCase = [SELECT id from Case];
        CaseNotes.getAllNotes(getCase.id);
    }
    
    static testMethod void testGetTimeTrackers(){
        Case getCase = [SELECT id from Case];
        CaseTimeTracking.getTimeTrackers(getCase.id);
    }
    
    
    
    
}
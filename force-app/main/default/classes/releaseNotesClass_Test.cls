@isTest
public with sharing class releaseNotesClass_Test {
    @isTest
    public static void testReleaseNotes() {

        Connect_Release_Notes__c relnote = new Connect_Release_Notes__c();
            relnote.Release_Date__c = date.today();
            relnote.Revision__c = '1';
            relnote.Category__c = 'Standard Release';
            relnote.User_Description__c = 'TEST NOTE';
            relnote.Show_In_Connect__c = true;
            relnote.Current_Version__c = true;
            insert relnote;

        Connect_Release_Note_Item__c crni = new Connect_Release_Note_Item__c();
        crni.Connect_Release_Note__c = relnote.id;
        insert crni;


        releaseNotesClass.getReleaseNotes(relnote.Show_In_Connect__c, relnote.Current_Version__c, relnote.Category__c);
        releaseNotesClass.getNoteItems(crni.Id); 

        

    }
}
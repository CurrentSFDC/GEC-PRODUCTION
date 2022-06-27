@isTest(seealldata=true)
public class eMailMessageTrigger_Test {
    @isTest
    public static void testUpdateCaseDescription()
    {
        User Usr = new User();
        Usr = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        /*TriggerSwitch__c caseSetting = TestDataUtil.createTriggerSwitch('CaseTrigger', true);
        insert caseSetting;*/
        Id Lighting_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GE_LGT_Design_Request').getRecordTypeId();
        case newCase = new case(subject='test');
        newCase.RecordTypeId = Lighting_RecordType;
        newCase.Origin ='eLight - Daintree Request';
        newCase.OwnerId = Usr.id;
        //newCase.OwnerId = '00G31000004poJM';
        insert newCase;
        EmailMessage newIncomingMail = new EmailMessage();
        newIncomingMail.FromAddress = 'LDRReply@ge.com';
        newIncomingMail.TextBody = '@@firstName::Shared';
        newIncomingMail.Subject = 'test for LDR mail; Case : ref:oldCase';
        newIncomingMail.ParentId = newCase.Id;
        newIncomingMail.Incoming = true;
        insert newIncomingMail;
        EmailMessage newMessage = [Select Id, textBody, parentId from EmailMessage where id= :newIncomingMail.Id];
        system.assertNotEquals(null, newMessage);
    }
}
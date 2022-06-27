public with sharing class ExceptionLogger {

    public static void newExceptionLog(System.CalloutException ex, String className, String methodName) {
        ExceptionLoggingFramework__c elf = [SELECT Id, Enabled__c, EmailNotificationEnabled__c, Emails__c, SAP_Integration_User_Id__c FROM ExceptionLoggingFramework__c];
        if (elf.Enabled__c) {
            ExceptionLog__c eLog = new ExceptionLog__c();
            eLog.Message__c = ex.getMessage();
            eLog.Type__c = ex.getTypeName();
            eLog.StackTrace__c = ex.getStackTraceString();
            eLog.Debug_Level__c = 'Error';
            eLog.Source__c = className;
            eLog.SourceMethod__c = methodName;
            insert eLog;
            if (elf.EmailNotificationEnabled__c) {
                OrgWideEmailAddress owa = [
                        SELECT Id,
                                DisplayName,
                                Address
                        FROM OrgWideEmailAddress
                        WHERE DisplayName = 'NoReply'
                        LIMIT 1
                ];
                EmailTemplate template = [
                        SELECT Id
                        FROM EmailTemplate
                        WHERE DeveloperName = 'Exception_Email'
                ];
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                //User sapIntegrationUser=[Select Id From User Where Name ='SAP Integration'];
                User u = [SELECT Id,ContactId FROM User WHERE Id = :UserInfo.getUserId()];
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(template.Id);
                //mail.setTargetObjectId(u.ContactId);
                mail.setSaveAsActivity(false);
                mail.setOrgWideEmailAddressId(owa.Id);
                mail.setToAddresses(elf.Emails__c.split(';'));
                mail.setWhatId(eLog.Id);
                allmsg.add(mail);
                Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsg, false);
                System.debug(results);
            }
        }
    }

}
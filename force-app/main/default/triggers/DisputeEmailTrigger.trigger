trigger DisputeEmailTrigger on Dispute_Request__c (after insert, after update) {
    
     if(CaseTriggerHandler.isFirstTime){ 
    CaseTriggerHandler.isFirstTime = false;   
    System.debug('isFirstTime *******'+CaseTriggerHandler.isFirstTime);
    Group Grp = [Select Id, Email from Group where Name='GE_NAS_PSO_Queue' and type='Queue']; 
    EmailTemplate emailtemp = [Select id,Subject,HtmlValue from EmailTemplate where name = 'Warranty Return VF Email']; 
    System.debug('email template *******'+emailtemp);
    
    System.debug('Test1');
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for (Dispute_Request__c dr : trigger.new) {
           if(dr.Status__c == 'Approved' && dr.Case_Type__c == 'Warranty'){
            List<String> sendTo = new List<String>();
            String disIdValue = dr.Id;
            sendTo.add(dr.Case__r.SuppliedEmail);
            system.debug('Email*******'+dr.Case__r.SuppliedEmail);
            Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
            CaseNotificationmail.setToAddresses(new List<String> {Grp.Email} );        
            System.debug('CaseNotificationmail********'+CaseNotificationmail);
        
        CaseNotificationmail.setTargetObjectId(dr.OwnerId);
        //CaseNotificationmail.setReplyTo('no.reply@gecurrent.com');
       //CaseNotificationmail.getToAddresses('no.reply@gecurrent.com');
        CaseNotificationmail.setUseSignature(false);
        CaseNotificationmail.setInReplyTo('no.reply@gecurrent.com');
        CaseNotificationmail.setBccSender(false);
        CaseNotificationmail.setTemplateId(emailtemp.Id);
        CaseNotificationmail.setWhatId(disIdValue);
        
        CaseNotificationmail.setSaveAsActivity(false);
        CaseNotificationmail.setReplyTo('no.reply@gecurrent.com');
        CaseNotificationmail.setSenderDisplayName('No Reply <no.reply@gecurrent.com>'); 
       // CaseNotificationmail.setHtmlBody(emailtemp.HtmlValue); //new line added 
       mails.add(CaseNotificationmail); 
       System.debug('mails *******'+mails);
                
            }
        }
        
     System.debug('Total mails *******'+mails);
    Messaging.sendEmail(mails);
    
    }

}
trigger GE_NAS_EmailMessageForCaseTrigger on EmailMessage (after insert,before delete) {
    //Rashmitha Changed the API vesion from 30 to 45 on 5-Mar-2019 as per 1447 request
    ////****START FOR AFTER INSERT
   AdminOverride__c AdminOverrideUser = AdminOverride__c.getInstance(UserInfo.getUserId());
    System.debug('AdminOverrideUser: '+ AdminOverrideUser + 'Switch Status: '+ AdminOverrideUser.Switch_Off_Trigger__c);
    if(AdminOverrideUser.Switch_Off_Trigger__c == False) {
        TriggerSwitch__c EmailSetting = TriggerSwitch__c.getInstance('GE_NAS_EmailMessageForCaseTrigger');
         if(!(EmailSetting != NULL && EmailSetting.isActive__c == False)){
    if(trigger.isAfter && trigger.isInsert) {
        set<Id> caseIds = new set<Id>();
        set<Id> caseForUpdateHrsIds = new set<Id>();
        Map<ID,String> msgDetails = new Map<ID,String>();
        String toAddress;
        String ccAddress;
        for(EmailMessage message : trigger.new){
            if(message.Incoming == true){
                caseIds.add(message.ParentId);
                toAddress = message.ToAddress;
                try {
                    if(toAddress.length()>3999)
                        message.ToAddress = toAddress.substring(0,3999);
                    if(toAddress.length()>254) {
                        try {
                            toAddress =toAddress.substring(0,254);
                            msgDetails.put(message.ParentId,toAddress);
                        }
                        catch (Exception ex) {
                            msgDetails.put(message.ParentId,'too long...');
                        }
                    }
                    else
                        msgDetails.put(message.ParentId,toAddress);
                }
                catch(Exception ex){}
            }
            else
                caseForUpdateHrsIds.add(message.ParentID);
        }
        //START FOR REOPOENING THE CASE
        list<Case> casesToReOpen = [Select Id, Status, GE_NAS_Sub_Status__c, GE_NAS_NCSC_Resolution__c From Case Where (status='Closed' or status='Cancelled') and HybrisID__c = null and Id in: caseIds];
        for(Case c : casesToReOpen){
            c.Status = 'Open';
            c.GE_NAS_Sub_Status__c = 'Reopened';
        }
        if(casesToReOpen.size()>0)
            update casesToReOpen;
        //END FOR REOPOENING THE CASE
        
        //START FOR UPDATING FIRST RESPONSE HRS/MINS FOR THE CASE
        list<Case> casesToUpdateHrs = [Select Id, CreatedDate, GE_NAS_FirstResponseHrs__c,GE_NAS_FirstResponseMins__c From Case Where GE_NAS_FirstResponseHrs__c = null and Id in :caseForUpdateHrsIds];
        if(casesToUpdateHrs.size()>0) {
            Long responseMilliSecs;
            Integer caseHrs;
            //system.debug('SAISAI:INSIDESIZE:' + casesToUpdateHrs.size() + 'SAISAI');
            for(Case cse :casesToUpdateHrs) {
                try {
                    List<EmailMessage> lstEmailMsg= [SELECT ID,Incoming,MessageDate FROM EMAILMESSAGE WHERE INCOMING=false and PARENTID = :cse.ID and MessageDate > :cse.CreatedDate order by MessageDate ASC limit 2];
                    if(Integer.valueOf((lstEmailMsg[0].MessageDate.getTime() - cse.CreatedDate.getTime()))>10000)                    
                        responseMilliSecs = lstEmailMsg[0].MessageDate.getTime() - cse.CreatedDate.getTime();
                    //caseHrs = Integer.valueOf((lstEmailMsg[0].MessageDate.getTime() - cse.CreatedDate.getTime())/(1000*60*60));
                    else
                        responseMilliSecs = lstEmailMsg[1].MessageDate.getTime() - cse.CreatedDate.getTime();
                    //caseHrs = Integer.valueOf((lstEmailMsg[1].MessageDate.getTime() - cse.CreatedDate.getTime())/(1000*60*60));
                    cse.GE_NAS_FirstResponseHrs__c = Integer.valueOf(responseMilliSecs/(1000*60*60));
                    cse.GE_NAS_FirstResponseMins__c = Integer.valueOf(math.mod((responseMilliSecs/(1000*60)),60));
                }
                catch (Exception ex) {}
            }
            update casesToUpdateHrs;
        }
        //END FOR UPDATING FIRST RESPONSE HRS/MINS FOR THE CASE
        
        //START FOR UPDATING TOADDRESS IN THE CASE RECORD
        list<Case> casesToUpdate = [Select Id, GE_NAS_ToAddress__c From Case Where GE_NAS_ToAddress__c = null and Id in: caseIds];
        for(Case c : casesToUpdate){
            c.GE_NAS_ToAddress__c = msgDetails.get(c.ID);
        }
        if(casesToUpdate.size()>0)
            update casesToUpdate;
        //END FOR UPDATING TOADDRESS IN THE CASE RECORD
        // CODE TO SEND EMAIL TO 'TOADDRESS' FIELD TO PERSONAL OUTLOOK  -- START
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Map<String,String> mapPersonalEmails = new Map<String,String>();
        String newTo = '';
        for(GE_NAS_CaseRoutingePersonalEmails__c em :[SELECT GE_NAS_Case_Routing_Email__c,GE_NAS_Personal_Email__c FROM GE_NAS_CaseRoutingePersonalEmails__c WHERE GE_NAS_Active__c = true]) {
            mapPersonalEmails.put(em.GE_NAS_Case_Routing_Email__c,em.GE_NAS_Personal_Email__c);
        }
        for(integer i=0; i<trigger.new.size(); i++){
            try {
                if(trigger.new[i].ccAddress != null) {
                    newTo = '';
                    for(String cc :trigger.new[i].ccAddress.split(';')) {
                        if(mapPersonalEmails.containsKey(cc))
                            newTo = newTo + mapPersonalEmails.get(cc) + ';';
                    }
                    newTo = newTo.substring(0,newTo.length()-1);
                    mail = new Messaging.SingleEmailMessage();
                    if(newTo != '') {
                        //mail.setToAddresses(new String[] {'saikrishna.vuddanti@techmahindra.com'});
                        mail.setToAddresses(newTo.split(';'));
                        mail.setSubject(trigger.new[i].Subject);
                        mail.setBccSender(false);
                        mail.setUseSignature(false);
                        if(trigger.new[i].HasAttachment)
                            mail.setHtmlBody('This email is auto forwarded from 1s email and came with attachements.<br></br>please click to veiw attachements: ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + trigger.new[i].Id + '<br></br>' + trigger.new[i].HtmlBody);
                        else
                            mail.setHtmlBody('This email is auto forwarded from 1s email. <p></p>' + trigger.new[i].HtmlBody);
                        
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    }
                }
            } catch(Exception ex){}
        }
        // CODE TO SEND EMAIL TO 'TOADDRESS' FIELD TO PERSONAL OUTLOOK  -- END
    }
    //****END FOR AFTER INSERT
    
    //****START FOR BEFORE DELETE
    if(trigger.isBefore && trigger.isDelete) {
        ID sysAdminProfileID = [select id from profile where name='System Administrator'].id;
        if(UserInfo.getProfileId() != sysAdminProfileID) {
            for(EmailMessage message : trigger.old) {
                message.addError('you have no access to delete messages');
            }
        }
    }
    //****END FOR BEFORE DELETE
    
         }
    }
}
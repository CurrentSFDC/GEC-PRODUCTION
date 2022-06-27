/*
Name - BA011_DynamicEmailQuoteSync
Test Class - BA011_DynamicEmailQuoteSync_Test
Author - Satish
Purpose - To Send Dynamic Emails for Quote Sync
Opportunity Owner to be notified of when changes are made in SAP to quote records on opportunities
PriceAgreements-->Quote-->Opportunities.
Created Date - July-2018 : This batch should run before the PA2Q batch.
*/
global  class BA011_DynamicEmailQuoteSync implements Database.Batchable<sobject> ,Database.Stateful
{
    
    global String [] email = new String[] {System.label.rashmiEmailId,System.label.satishEmailId};
    global integer NoofEmailsSent=0;
    global string batchuser=System.label.batchUserlabel;
  
        
        global Database.QueryLocator Start(Database.BatchableContext BC){
                        
        Set<ID> oppownerid = new Set<ID>();
        
        Integer LastNDays =Integer.valueOf(System.label.Last_N_Days_Quote_update_to_Opp);
        
        //for Test code coverage make the LastNDays to '0' in the custome label in the above then code is covered 100%
        date TodayorFuturedate = system.today()+ LastNDays;
        //The below query for opportunity owners and opportunity team members.
        /*Map<Id,Opportunity> oppmap =new   Map<Id,Opportunity> ([Select ownerId ,(select UserId from OpportunityTeamMembers) from Opportunity where ID In 
            (Select OpportunityID From Quote where LastModifiedDate =YESTERDAY)]);*/
        //The below query only for Opportunity owners
        Map<Id,Opportunity> oppmap =new   Map<Id,Opportunity> ([Select ownerId from Opportunity where ID In 
                                                                (Select OpportunityID From Quote where (LastModifiedDate>=YESTERDAY And Agreement_No__c!=null and IsSyncing=TRUE and (LastModifiedBy.Name='SAP Integration' or LastModifiedBy.Name=: batchuser) ) OR LastModifiedDate>=:TodayorFuturedate   )]);
        
        for(Opportunity opp :oppmap.values())
        {
            System.debug('Opp owner--' +opp.ownerid);
            oppownerid.add(opp.ownerid);
            /*for(OpportunityTeamMember optm :opp.OpportunityTeamMembers)
{
System.debug('Opp team members--' +optm.UserId);
oppownerid.add(optm.UserId);
}*/
        }
       // System.debug('Set of ownerids--'+oppownerid);
        return Database.getQueryLocator('select id ,Email,firstName from USer where isactive=true and Id In : oppownerid');
    }
    
    global void execute(Database.BatchableContext BC ,List<USer> Userslist)
    {
        // Set<Id> OppOwnerIds = new Set<ID>();
        //  List < String > toAddresses = new List < String > ();
        List<contact> contactlist = new List<contact>();
        contactlist.clear();

        For(User user: Userslist)
        {
            contact con = new contact();
            con.FirstName=user.firstName;
            con.LastName=user.firstName;
            con.Email =user.Email;
            contactlist.add(con);
            
        }
        insert contactlist;
        //System.debug('contact ids--' + contactlist);
        
        for(Contact  users: contactlist)
        {
            //system.debug('users.id1====='+users.id);
           // system.debug('users.Email1====='+users.Email);
            //toAddresses.add(users.Email);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setReplyTo('noreplyge@ge.com');
            mail.setSenderDisplayName('UpdatetoOpportunity');
            mail.setTreatTargetObjectAsRecipient(true);
            mail.setTargetObjectId(users.id);
            mail.setTemplateId(System.label.QuoteSynctoOpp);
            //mail.setOrgWideEmailAddressId(owea.get(0).Id);
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});
            NoofEmailsSent=NoofEmailsSent+1;
            //System.debug('mail body- '+users.Email + NoofEmailsSent+'--'+ mail);
            //toAddresses.clear();
        }
        Delete contactlist;
        //Messaging.sendEmail(mailList); 
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        AsyncApexJob a = [Select a.TotalJobItems, a.Status, a.NumberOfErrors, a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById, a.CompletedDate From AsyncApexJob a WHERE id = :BC.getJobId()];
        System.debug('$$$ Jobid is'+BC.getJobId());
        Messaging.SingleEmailMessage finishmail = new Messaging.SingleEmailMessage();
        finishmail.setToAddresses(email);
        finishmail.setReplyTo('NoReplyto@ge.com');
        finishmail.setSenderDisplayName('Dynamic Email to opp onwers');
        finishmail.setSubject('Dynamic Email to Opp Owners: '+ a.Status);
        finishmail.setPlainTextBody('Dear Satish/Rashmi Dynamic Emails to SAP update to Opportunity onwers is  summarized below:' + '\n ' + '1.Batches== ' + a.TotalJobItems + '\n ' + '2.Errors== ' + a.NumberOfErrors + '\n ' + '3.Items Processed== ' + a.JobItemsProcessed +'\n' +'4.No of Emails Sent=' +NoofEmailsSent);
        Messaging.sendEmail(new Messaging.Singleemailmessage [] {finishmail});
    }
}
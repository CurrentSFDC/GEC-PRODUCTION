//Batch for emails for the new orders to the Owners.
//Developer:Roja Velpuri.
//Date : 01/04/2019.

global class DynamicEmailOrder implements Database.Batchable <sobject>,Database.Stateful {
	global String [] email = new String[] {System.label.rashmiEmailId,System.label.RojaMailId,System.label.GETeam};
    global integer NoofEmailsSent=0;
    global string batchuser=System.label.batchUserlabel;
            
        global Database.QueryLocator Start(Database.BatchableContext BC){
    					
        Set<ID> oppownerid = new Set<ID>();
        
        
        //The below query only for Opportunity owners
        Map<Id,Opportunity> oppmap =new   Map<Id,Opportunity> ([Select ownerId,Name,Id from Opportunity where ID In 
                                                                (Select OpportunityID From Order where (
                                                                    									LastModifiedDate > YESTERDAY and                                                    
                                                                                                        LastModifiedBy.Name ='SAP Integration' and
                                                                                                        RecordType.Name = 'Received PO' and
                                                                                                        GE_Opportunity_Id__c like '%NA%' and
                                                                                                        Stage__c NOT IN('PO Received','Closed Lost')) )]);
        
        for(Opportunity opp :oppmap.values())
        {
            System.debug('Opp owner--' +opp.ownerid + opp.name);
            oppownerid.add(opp.ownerid);
            
        }
        return Database.getQueryLocator('select id ,Email,firstName from User where isactive=true and Id In : oppownerid');
    }
    
    global void execute(Database.BatchableContext BC ,List<User> Userslist)
    {
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
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(Contact  users: contactlist)
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setReplyTo('noreplyge@ge.com');
            mail.setSenderDisplayName('UpdatetoOpportunity');
            mail.setTreatTargetObjectAsRecipient(true);
            mail.setTargetObjectId(users.id);
            mail.setTemplateId(System.label.OrderSynctoOpp);
            mail.setSaveAsActivity(false);
            mails.add(mail);
            NoofEmailsSent = NoofEmailsSent+1;
        }
        Messaging.sendEmail(mails);
        Delete contactlist;
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        AsyncApexJob a = [Select a.TotalJobItems, a.Status, a.NumberOfErrors, a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById, a.CompletedDate From AsyncApexJob a WHERE id = :BC.getJobId()];
        System.debug('$$$ Jobid is'+BC.getJobId());
        Messaging.SingleEmailMessage finishmail = new Messaging.SingleEmailMessage();
        finishmail.setToAddresses(email);
        finishmail.setReplyTo('NoReplyto@ge.com');
        finishmail.setSenderDisplayName('Dynamic Email to opp owners');
        finishmail.setSubject('Dynamic Email to Opp Owners: '+ a.Status);
        finishmail.setPlainTextBody('Hi Team, Dynamic Emails to SAP update to Opportunity onwers is  summarized below:' + '\n ' + '1.Batches== ' + a.TotalJobItems + '\n ' + '2.Errors== ' + a.NumberOfErrors + '\n ' + '3.Items Processed== ' + a.JobItemsProcessed +'\n' +'4.No of Emails Sent=' +NoofEmailsSent);
        Messaging.sendEmail(new Messaging.Singleemailmessage [] {finishmail});
       
    }
}
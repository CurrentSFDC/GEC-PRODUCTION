/*---------------------------------------------------------------------------------
Name:       Sched_PageLabelCacheRefresh
Purpose:    Schedulable Page Label Cache.
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          20-Dec-2020             Initial Development 
---------------------------------------------------------------------------------*/

global class Sched_PageLabelCacheRefresh implements  Schedulable {

    /*
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
    }
    */

	global void execute(SchedulableContext sc) {
        try {
            //if(!Test.isRunningTest()){				
                (new ccrz.ccPageLabelCacheBuilder()).build(new Map<String,Object>());
            //}       
            /*
            AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:sc.getTriggerId()];
      
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Page Label Cache ' + a.Status);
            mail.setPlainTextBody('records processed ' + a.TotalJobItems +   'with '+ a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            */

        } catch(Exception e) {
            System.debug(e);
        }		
    }    

}
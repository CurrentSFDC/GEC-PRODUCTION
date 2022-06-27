/*---------------------------------------------------------------------------------
Name:       Sched_ProductSpecRefresh
Purpose:    Schedulable Product Spec.
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          20-Dec-2020             Initial Development 
---------------------------------------------------------------------------------*/

global class Sched_ProductSpecRefresh implements Schedulable {
	global void execute(SchedulableContext sc) {        
        Database.executeBatch(new ccrz.cc_job_LoadProductSpecIndex('SELECT Id, ccrz__ParentProduct__c, ccrz__FilterData__c FROM ccrz__E_Product__c'));
	}
}
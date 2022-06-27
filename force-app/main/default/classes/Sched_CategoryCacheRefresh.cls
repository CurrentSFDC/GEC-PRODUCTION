/*---------------------------------------------------------------------------------
Name:       Sched_CategoryCacheRefresh
Purpose:    Schedulable Category Cache.
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          20-Dec-2020             Initial Development 
---------------------------------------------------------------------------------*/

global class Sched_CategoryCacheRefresh implements Schedulable {
	global void execute(SchedulableContext sc) {

        List<String> storefrontNames = (Label.List_of_Storefront_Names).split(',');
        for (String name: storefrontNames) {
            if(!Test.isRunningTest()){
                (new ccrz.ccCategoryCacheBuilder()).build(new Map<String,Object>{ccrz.ccCategoryCacheBuilder.STOREFRONT => name});
            }
        }
	}
}
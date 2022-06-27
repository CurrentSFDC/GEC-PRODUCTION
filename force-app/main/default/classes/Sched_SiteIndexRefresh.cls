/*---------------------------------------------------------------------------------
Name:       Sched_SiteIndexRefresh
Purpose:    Schedulable Site  Index.
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          20-Dec-2020             Initial Development 
---------------------------------------------------------------------------------*/

global class Sched_SiteIndexRefresh implements Schedulable {
	global void execute(SchedulableContext sc) {
		List<String> storefrontNames = (Label.List_of_Storefront_Names).split(',');
		for (String name: storefrontNames) {
			if(!Test.isRunningTest()){
				ccrz.ccSiteIndexBuilder.build(new Map<String,Object>{ccrz.ccSiteIndexBuilder.STOREFRONT => name});
			}
		}
	}
}
/*---------------------------------------------------------------------------------
Name:       Sched_ProductIndexRefresh
Purpose:    Schedulable Product Index.
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          20-Dec-2020             Initial Development 
---------------------------------------------------------------------------------*/

global class Sched_ProductIndexRefresh implements Schedulable {
	global void execute(SchedulableContext sc) {
		ccrz.ccProductIndexBuilder.build(new Map<String,Object>{
			ccrz.ccAPIProductIndex.LOCALES => new Set<String>{'en_US','en'},
			ccrz.ccAPIProductIndex.CLEAN_ONLY => FALSE
        });
	}
}
/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_agf_ADM_WorkTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_agf_ADM_WorkTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new agf__ADM_Work__c());
    }
}
/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Return_Order_ItemTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Return_Order_ItemTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Return_Order_Item__c());
    }
}
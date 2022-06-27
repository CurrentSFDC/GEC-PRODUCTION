@isTest
public class TestDataUtil_Test 
{
    static testmethod void createRecordsTest()
    {
        TestDataUtil.insertTriggerSwitches();
        TestDataUtil.insertTriggerSwitchesMAP();
        TestDataUtil.createAccount();
        TestDataUtil.createPriceBook('Test');
        TestDataUtil.createProduct('Test');
        TestDataUtil.createMaterialMaster('222');
       // TestDataUtil.createSAPQuote('222');
       // TestDataUtil.createSAPQuoteLineItem('222','222');
        TestDataUtil.createQuoteItem('222','222');
        TestDataUtil.createMaterialMaster('222');
        TestDataUtil.createOrder('222');
        TestDataUtil.createOrderItem('222','222');
        TestDataUtil.createAccountsetup();
        TestDataUtil.createOSR();
        TestDataUtil.createtask();
        TestDataUtil.createAccountsetup();
        TestDataUtil.createAccountsetup();
        TestDataUtil.createAccountsetup();
        TestDataUtil.createAccountsetup();
        TestDataUtil.createAccountsetup();
        TestDataUtil.createsrr();
        ID recTypeID;
        TestDataUtil.createDistributor(recTypeID);
    }
    
    static testmethod void createRecordsTest1()
    {
        TestDataUtil.insertTriggerSwitches();
        TestDataUtil.insertTriggerSwitchesMAP();
        Account acc=TestDataUtil.createAccount();
        Opportunity opp=TestDataUtil.createOpportunity(acc);
        TestDataUtil.createQuote('Test',opp);
        TestDataUtil.createFundRequest(acc);
        TestDataUtil.createSample(opp);
        TestDataUtil.createCase(acc);
        
        StaticVariables.sendEmail = TRUE;
        StaticVariables.doNotSetActualHours = TRUE;
        StaticVariables.deleteOpptyProduct = TRUE;
        StaticVariables.insertTeamMemberFromOpp = TRUE;
        StaticVariables.aggsRunningFromRelComp = TRUE;
        StaticVariables.aggsRunningFromDelTsk = TRUE;
        StaticVariables.aggsRunningFromRequest = TRUE;
        StaticVariables.settingReleaseFromRequest = TRUE;
        StaticVariables.runningQuoteItemBatch = TRUE;
    }
}
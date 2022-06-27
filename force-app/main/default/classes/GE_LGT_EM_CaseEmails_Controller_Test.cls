@isTest
public class GE_LGT_EM_CaseEmails_Controller_Test 
{
    static testmethod void testCaseEmail()
    {
        TriggerSwitch__c caseSetting = TestDataUtil.createTriggerSwitch('CaseTrigger', true);
        insert caseSetting;
        Case c=new Case();
        c.status='New';
        insert c;
        System.currentPageReference().getParameters().put('ID',c.id);
        GE_LGT_EM_CaseEmails_Controller ge=new GE_LGT_EM_CaseEmails_Controller();
    }
}
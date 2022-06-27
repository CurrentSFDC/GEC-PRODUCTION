@isTest
public class GE_LGT_inlinecontrol_childacc_Test {
    static testMethod void myUnitTest_childacc() {
            ID userID = UserInfo.getUserID();
            ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Agent Parent').getRecordTypeId();
            ID recAcc1TypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Agent').getRecordTypeId();

            Account acc=TestDataUtil.createAccount();
            acc.RecordTypeId = recAccTypeID;
            acc.IsGlobalParentActive__c = false;
            insert acc;
          
            Account accnt=TestDataUtil.createAccount();
            accnt.RecordTypeId = recAcc1TypeID;
            accnt.ParentId = acc.ID;
            accnt.GE_LGT_EM_CustomerActiveFlag__c = true;
            insert accnt;
            
            Account accntt=TestDataUtil.createAccount();
            accntt.RecordTypeId = recAcc1TypeID;
            accntt.ParentId = acc.ID;
            accntt.GE_LGT_EM_CustomerActiveFlag__c = false;
            insert accntt;
            
          
           ApexPages.StandardController sc = new ApexPages.standardController(acc);       
           ApexPages.currentPage().getParameters().put('Id',acc.id);

           GE_LGT_inlinecontrol_childacc il=new GE_LGT_inlinecontrol_childacc(sc);        
 
    }
}
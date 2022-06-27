@isTest
public class GE_LGT_setTeamMemberInOppty_Test
{   
    static testMethod void opptyAddTeamMember()   
    {
          Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        triggerSwitches.get('GE_LGT_EM_AvoidDuplicateAccount').isActive__c=False;
        triggerSwitches.get('GE_LGT_preventDuplicateAccount').isActive__c=False;
        triggerSwitches.get('OppPusher').isActive__c=False;
        triggerSwitches.get('GE_LGT_AddOptyTeamFromAccOwner').isActive__c=False;
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=False;
        triggerSwitches.get('GE_LGT_OpportunityInsertUpdateDelete').isActive__c=False;
        
        insert triggerSwitches.values();
        ID userID = UserInfo.getUserID();
        
        ID recAccTypeID =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc = TestDataUtil.createAccount();
        acc.RecordTypeId = recAccTypeId;acc.Name='Test Acc';acc.Type='End User';acc.BillingCountry='canada';acc.GE_LGT_Vertical__c='Fin';    
        insert acc;
        
        Opportunity opp = TestDataUtil.createOpportunity(acc);
        opp.Name = 'Sai Test Oppty';      
        opp.StageName = 'S1 Consult';  
        opp.Type='End User - Retrofit';  
        opp.AccountID = acc.id;      
        opp.CloseDate = System.Today() + 1;      
        opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 2;      
        opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 3;
       
        insert opp;
        
        OpportunityTeamMember ot = new OpportunityTeamMember();
        ot.OpportunityID= opp.ID;
        ot.UserID=userID;
        
        insert ot;
        
    }
    
}
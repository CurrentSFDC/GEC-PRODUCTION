@isTest
public class GE_LGT_Portfolioinlinecontrol_Test {
static testMethod void myUnitTest() {
    ID userID = UserInfo.getUserID(); //[select id from user where isactive = true limit 1].id;
    ID recOppTypeID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
    ID  recAccTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
    //Custom settings Test data creation          
        TriggerSwitch__c OSRtriggerSwitch=TestDataUtil.createTriggerSwitch('OpportunitySupportRequestTrigger',true);
          insert OSRtriggerSwitch;
          Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
          triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
          triggerSwitches.get('OrderTrigger').isActive__c=true;
          triggerSwitches.get('AccountTrigger').isActive__c=true;
          triggerSwitches.get('Update_Pricebook2ids').isActive__c=true;
          insert  triggerSwitches.values();
    
    Account acc = TestDataUtil.createAccount();
   acc.Name='Test Acc2';
   acc.recordtypeid=recAccTypeID;
insert acc;
  Account acc2 = TestDataUtil.createAccount();
   acc2.Name='Test Acc212';
  acc2.recordtypeid=recAccTypeID;
insert acc2;
  
  // INSERT CONTACT RECORD
  Contact con = new Contact(LastName='Test Cont1', FirstName='FirstName1',Email='sai@ge.com',AccountId=acc.ID,OwnerID=userID);
  insert con;
  
  // INSERT Portfolio__c RECORD
   Portfolio__c p = new Portfolio__c();
    p.Name = 'sample';
    p.Account__c = acc.Id;
    p.CurrencyIsoCode ='USD';
    insert p;
    
  // INSERT OPPTY RECORD
  Opportunity opp = TestDataUtil.createOpportunity(acc);
  opp.Name = 'Testopp';
  opp.StageName = 'S1 Consult';
 opp.recordtypeid=recOppTypeID;
  opp.CurrencyIsoCode ='USD';
  opp.Probability = 10;
  opp.Portfolio__c =p.id;
  opp.amount = 500;
  opp.CloseDate = system.today()+4;
  insert opp;
    
  // INSERT OPPTY TEAM MEMBER RECORD
  OpportunityTeamMember optm = new OpportunityTeamMember();
  optm.OpportunityId = opp.id;
  optm.OpportunityAccessLevel ='Edit';
  optm.TeamMemberRole = 'Application Engineer';
  optm.UserId = con.OwnerID;
  insert optm;
    System.currentPageReference().getParameters().put('id', p.id);

  GE_LGT_Portfolioinlinecontrol ge=new GE_LGT_Portfolioinlinecontrol(null);
    
}
}
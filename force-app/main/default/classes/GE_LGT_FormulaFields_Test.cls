@isTest
private class GE_LGT_FormulaFields_Test {
    //Rashmitha Changed the API vesion from 35 to 45 on 6-Mar-2019 as per 1447 request
public static Map<String,id> mapRecTypeNameID=OpportunityConstantClass.mapRecTypeNameID();
static testMethod void formulaFields()
{

 Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
        
        
        triggerSwitches.get('AccountTrigger').isActive__c=true;
        
        insert  triggerSwitches.values();
        
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        Profile objProfile = [Select Id, Name from Profile where Name =:'EUROPE Current Super User' limit 1];
        EMEAProfiles__c emea=new EMEAProfiles__c(name=objProfile.id);
        insert emea;
        User u2=OpportunityTriggerHelper_Test.createuser(objProfile.id,'Europe',true);
        System.runAs(u2)
        {
            test.starttest();
            ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
            List<Account> accs=OpportunityTriggerHelper_Test.createAccounts(1,recAccTypeID,true);
            
            Id recoppType_StandardID = mapRecTypeNameID.get(OpportunityConstantClass.STANDARD_ADV);
            
            List<Opportunity> opps=OpportunityTriggerHelper_Test.createOpportunities(2,recoppType_StandardID,true,accs[0]);
        
          
          // INSERT CONTACT RECORD
          Contact con = new Contact(firstname='test',LastName='Test Con1986',Email='test.gelegt@ge.com',AccountId=accs[0].ID);
          insert con;
          
           
            
        
         
  
            
               PageReference pageRef = Page.GE_LGT_FormulaFields;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.standardController(opps[0]);       
            ApexPages.currentPage().getParameters().put('Id',opps[0].id);
            system.debug('&&&&id' + opps[0].id);
            GE_LGT_FormulaFields il=new GE_LGT_FormulaFields(sc);
            il.hasNA=false;
}
}


}
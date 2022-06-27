@isTest
private class Opportunity_Portfolio_Handler_Test {
     public static Map<String,id> mapRecTypeNameID=OpportunityConstantClass.mapRecTypeNameID();
    public static Opportunity createOpportunities(string name,id recTypeId,boolean isInsert,Account acc,id Portid){
       
        
      
           
            Opportunity opp=TestDataUtil.createOpportunity(acc);
            opp.name=name;
            opp.Portfolio__c =Portid;
            opp.amount = 500;
            opp.recordtypeid=recTypeId;
            opp.Total_value_of_Opportunity_500K__c='No';
            opp.There_is_a_resource_implication__c='No';
            opp.There_s_a_Strategic_Value_Future_Revenue__c='No';
            
      
        if(isInsert) insert opp;
        return opp;
        
        
    }
    static testMethod void myUnitTest() {
         
        Id recOppTypestorage = mapRecTypeNameID.get(OpportunityConstantClass.ENERGY_ADV);      
            
        Id recOppTypeIDStdAdvance = mapRecTypeNameID.get(OpportunityConstantClass.STANDARD_ADV);          
        
        Id recOppTypestandrad = mapRecTypeNameID.get(OpportunityConstantClass.STANDARD);        
        
        Id recOppTypeIDEV = mapRecTypeNameID.get(OpportunityConstantClass.EV_ADV);
           
        
        //Id recOppTypeIDsolor = mapRecTypeNameID.get(OpportunityConstantClass.SOLAR_ADV); --> COMMENTED OUT BY MG: RQT-1023
        
        
        Id recOppTypeIDOPS =  mapRecTypeNameID.get(OpportunityConstantClass.OPS_ADV);
        
        
        Id recAccTypeEndID =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId(); 
        ID recAccTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        
        
       Map<string,TriggerSwitch__c> triggerSwitches = TestDataUtil.insertTriggerSwitchesMAP();
        
        triggerSwitches.get('GE_LGT_EM_OppProductHistory').isActive__c=true;
        
        triggerSwitches.get('OrderTrigger').isActive__c=true;
        triggerSwitches.get('AccountTrigger').isActive__c=true;
        
        insert  triggerSwitches.values();
        
        PriceBook2 ledPB = TestDataUtil.createPriceBook('LED');
        insert ledPB;
        Profile objProfile = [Select Id, Name from Profile where Name =:'NA Current Super User' limit 1];
        EMEAProfiles__c emea=new EMEAProfiles__c(name=objProfile.id);
        insert emea;
        User u2=OpportunityTriggerHelper_Test.createuser(objProfile.id,'North America',true);
        System.runAs(u2)
       {
            test.starttest();
           List<Account> testaccs =new  List<Account>();
            List<Account> accs=OpportunityTriggerHelper_Test.createAccounts(1,recAccTypeEndID,false);
            testaccs.addall(accs);
            List<Account> accs1=OpportunityTriggerHelper_Test.createAccounts(1,recAccTypeID,false);
             testaccs.addall(accs1);
             insert testaccs;
             Portfolio__c p = new Portfolio__c();
             p.Name = 'sample';
            p.Account__c =accs[0].id;
            p.CurrencyIsoCode ='USD';
            insert p;
            
            Id recoppType_StandardID = mapRecTypeNameID.get(OpportunityConstantClass.STANDARD_ADV);
            List<Opportunity> oppList=new List<Opportunity>();
           
            Opportunity StandardOpp=createOpportunities('StandardOpp',recOppTypestandrad,false,accs1[0],p.id);
            oppList.add(StandardOpp);
          
            /*Opportunity solarOpp=createOpportunities('solarOpp',recOppTypeIDsolor,false,accs[0],p.id);
            oppList.add(solarOpp);*/ //COMMENTED OUT BY MG: RQT-1023
         
            
            insert oppList;
            for(Opportunity assertopp1:[select id from Opportunity where id in:oppList]){
            system.assert(assertopp1.id!=null);
        }
            
            
        }
        
        
    }
}
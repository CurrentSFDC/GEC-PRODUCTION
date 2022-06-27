trigger OSRapprovalTrigger on Opportunity_Support_Request__c (before insert,before update,after update, after insert)//before insert
{      
  //  Opportunity_Support_Request__c obj = new Opportunity_Support_Request__c();
   // List <OSR_Product__c> SampleProductList = [Select CAT_logic_Description__c,Material_Description__c from OSR_Product__c where OSR_ID__c =: obj.Id ];//

    
    if(trigger.isUpdate && trigger.isBefore)
    {        
        for(Opportunity_Support_Request__c s : Trigger.new){                        
            if(s.Status__c == 'Open' )
            {
                
                //Get list of osr products
                List <OSR_Product__c> SampleProductList = [Select id from OSR_Product__c where OSR_ID__c =: s.id ];//
                if(SampleProductList.size() == 0)
                {
                   // if(!Test.isRunningTest())
                        s.addError('You must add at least one OSR Product to your Request.');
                    
                }
                else
                {
                    System.debug('Record successfully submitted for approval.');
                }
            }
        }        
	}
          
}
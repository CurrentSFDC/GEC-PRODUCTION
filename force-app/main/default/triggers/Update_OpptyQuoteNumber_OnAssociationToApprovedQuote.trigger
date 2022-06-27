/*
TriggerName - Update_OpptyQuoteNumber_OnAssociationToApprovedQuote
Date - June18,2014
Author - Neel Kamal Singh(TechMahindra)
Purpose - This trigger will populate Oppty.QuoteNumber when an opportunity is associated to an Approved Quote
Final output will be - Oppty.QuoteNumber = ApprovedQuote.QuoteNumber

*/


trigger Update_OpptyQuoteNumber_OnAssociationToApprovedQuote on ApprovedQuote__c (before update) {
    //Rashmitha Changed the API vesion from 30 to 45 on 5-Mar-2019 as per 1447 request
  for (ApprovedQuote__c AppQuote : Trigger.new)
  {
  system.debug('ApprovedQuote trigger begins');
    if(AppQuote.Associated_Opportunity__c !=null){
     system.debug('Associated Opportunity = '+AppQuote.Associated_Opportunity__c);
     
     List<Opportunity> OpptyList = new List<Opportunity>();
     OpptyList = [SELECT Id,GE_LGT_Quote_No__c FROM Opportunity WHERE Id = :AppQuote.Associated_Opportunity__c];
     
         if(OpptyList[0].GE_LGT_Quote_No__c==null){
         system.debug('Opportunity has no quote number');
         OpptyList[0].GE_LGT_Quote_No__c=AppQuote.Name; // AppQuote.Name is renamed as AppQuote.QuoteNumber on layout
         system.debug('Populating Opportunity Quote Number = '+AppQuote.Name);         
              
         }else{
         system.debug('Quote Number on Oppty already exists : '+OpptyList[0].GE_LGT_Quote_No__c);
         }
     Update OpptyList;
          
     }else{
     system.debug('Approved Quote does not have Associated Opportunity');
     }
   
  }

}
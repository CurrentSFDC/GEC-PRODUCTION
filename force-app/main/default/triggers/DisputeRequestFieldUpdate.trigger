trigger DisputeRequestFieldUpdate on Dispute_Request__c (after update, after insert) {
    
  /*  List<Dispute_Request__c> toUpdDis=new List<Dispute_Request__c>();
    
    for(Dispute_Request__c s : Trigger.new){                        
        if(s.Status__c == 'Approved' && s.Transaction_ID__c.ContainsIgnoreCase('Return'))
        {
            system.debug(s.name);
           //s.Order__c = string.valueOf(ReturnWSDLCallDisp.getOrderDtl(s));
           toUpdDis.add(s);
        }
    }*/
   
    //Database.update(toUpdDis);
}
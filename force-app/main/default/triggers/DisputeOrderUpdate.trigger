trigger DisputeOrderUpdate on Dispute_Request__c (After update) {
    system.debug(RecursiveTriggerHandler.isFirstTime);
    if(RecursiveTriggerHandler.isFirstTime){
        RecursiveTriggerHandler.isFirstTime = false;
    for(Dispute_Request__c s : Trigger.new){
        if (s.Status__c == 'Approved' && (s.Case_Subtype__c == 'Quick Stock Return' || s.Case_Subtype__c == 'Stock Balancing Return')) {
            StockBalancingReturnWSDLController.createOrderInSAP(s.Id);
            continue;
        }
        if(s.Status__c == 'Approved' && s.SAP_Doc_Type__c=='ZRE')
        {
            system.debug(s.name);
            //Dispute_Request__c dispute=new Dispute_Request__c(ID=s.ID);
            ReturnWSDLCallDisp.getOrderDtl(s.Id);
           
            //toUpdDis.add(dispute);
        }
        
        else if (s.Status__c == 'Approved' && s.SAP_Doc_Type__c=='ZOR'){
            
		 system.debug(s.name);
		 ReplaceWSDLCallDisp.getOrderDtlreplace(s.Id);            
        }
        
        else if (s.Status__c == 'Approved' && s.Case_Type__c=='Warranty' && s.SAP_Doc_Type__c=='ZFDD'){
            
		 system.debug(s.name);
		 WarrantyClaimWSDLCall.getOrderDtl(s.Id);            
        }
    }
    }
   
  //  Database.update(toUpdDis);
    
    
}
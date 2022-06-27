/*
###########################################################################
# File..................:GE_LGT_EM_UnderInvoiceHeaderUnflag
# Version...............: 1.0
# Created by............:Murugan
# Created Date..........: 
# Description...........:This trigger used for,Disputeflag updating,when opening a first complaint of under invoce header flag is checked.   
#                         and also calculating the child object(InvoiceLineItem)records count.
#               
*/

trigger GE_LGT_EM_UnderInvoiceHeaderUnflag on GE_LGT_EM_InvoiceLineItem__c(before update,after update) {

    set<Id> parentList= new set<Id>();
    List <GE_LGT_EM_InvoiceHeader__c> HeaderCountUpdate = new List<GE_LGT_EM_InvoiceHeader__c>();
    List <AggregateResult> AggregateRes = new List<AggregateResult>();
  
      if (Trigger.isupdate && Trigger.isAfter) {
        for (GE_LGT_EM_InvoiceLineItem__c c : Trigger.new) {
        if(c.GE_LGT_EM_InvoiceHeaderNumber__c <> null){
            parentList.add(c.GE_LGT_EM_InvoiceHeaderNumber__c);
            }
         }
    
    HeaderCountUpdate = [Select Id,GE_LGT_EM_DisputeCountHeader__c From GE_LGT_EM_InvoiceHeader__c Where Id In :parentList];
    system.debug('HeaderCountUpdate--->'+HeaderCountUpdate.size());
    
    //*******Under invoiceheader all invoice line item counting and update to counter field here*******//
    AggregateRes = [Select count(id),GE_LGT_EM_InvoiceHeaderNumber__c From GE_LGT_EM_InvoiceLineItem__c Where GE_LGT_EM_InvoiceHeaderNumber__c IN:parentList group by GE_LGT_EM_InvoiceHeaderNumber__c];
    system.debug('AggregateRes--->'+AggregateRes.size());
    for(AggregateResult ar: AggregateRes ){
        for(GE_LGT_EM_InvoiceHeader__c p:HeaderCountUpdate){
            if(ar.get('GE_LGT_EM_InvoiceHeaderNumber__c') == p.Id){
                p.GE_LGT_EM_DisputeCountHeader__c = Decimal.ValueOf(String.ValueOf(ar.get('expr0')));
            }
        }
    }
    update(HeaderCountUpdate);
}
/////********When we are Opening the First Complaint line item under(headerinvoice)when Dispute falg is checked******/
     List <GE_LGT_EM_InvoiceHeader__c> Invoiceheaderlist = new List<GE_LGT_EM_InvoiceHeader__c>();                
     set<Id> Invheaderids= new set<Id> (); 
    if(Trigger.isUpdate && Trigger.isAfter){
                   for (GE_LGT_EM_InvoiceLineItem__c flag:Trigger.new) {
             
                   if(flag.GE_LGT_EM_InvoiceHeaderNumber__c !=null && flag.GE_LGT_EM_Dispute_Flag__c==true && flag.GE_LGT_EM_DisputeCount__c==1 ){
                    Invheaderids.add(flag.GE_LGT_EM_InvoiceHeaderNumber__c);
                    system.debug('id invoiceheader--->'+Invheaderids);
                    }
                }
            }
     Invoiceheaderlist=[Select Id,GE_LGT_EM_Disputed_Flag__c from GE_LGT_EM_InvoiceHeader__c where id In:Invheaderids];
        for(GE_LGT_EM_InvoiceHeader__c Invheaderflag:Invoiceheaderlist){
                if(Invheaderflag.GE_LGT_EM_Disputed_Flag__c==false)
                    Invheaderflag.GE_LGT_EM_Disputed_Flag__c=true;
           }
    
    update(Invoiceheaderlist);

/****************will get a count for under All Invoice Line Item flagging are UnChecked ************/  
    set<Id> parentList1= new set<Id>();

    List <GE_LGT_EM_InvoiceHeader__c> InvoiceAllUncheckedFlagUpdate = new List<GE_LGT_EM_InvoiceHeader__c>();
    List <AggregateResult> AggregateRes1 = new List<AggregateResult>();
    
      if(Trigger.isUpdate && Trigger.isAfter){
        for (GE_LGT_EM_InvoiceLineItem__c flagupdate :Trigger.new) {
        GE_LGT_EM_InvoiceLineItem__c oldInvoice = Trigger.oldMap.get(flagupdate.ID);
               if(flagupdate.GE_LGT_EM_InvoiceHeaderNumber__c !=null && flagupdate.GE_LGT_EM_Dispute_Flag__c!=oldInvoice.GE_LGT_EM_Dispute_Flag__c){
                parentList1.add(flagupdate.GE_LGT_EM_InvoiceHeaderNumber__c);
                system.debug('parentList invoice item--->'+parentList1);
          
                
                }
            }
      }
    
    InvoiceAllUncheckedFlagUpdate = [Select Id,GE_LGT_EM_DisputeFlagheader__c From GE_LGT_EM_InvoiceHeader__c Where Id IN:parentList1];
    system.debug('InvoiceAllUncheckedFlagUpdate--->'+InvoiceAllUncheckedFlagUpdate.size());
         
    AggregateRes1 = [Select count(id),GE_LGT_EM_InvoiceHeaderNumber__c From GE_LGT_EM_InvoiceLineItem__c Where GE_LGT_EM_InvoiceHeaderNumber__c IN:parentList1 and GE_LGT_EM_Dispute_Flag__c=false and id in(SELECT GE_LGT_EM_Ref_InvoiceLineItem__c FROM GE_LGT_EM_ComplaintLineItem__c where GE_LGT_EM_Status__c IN('003-Rejected','006-CM/DM/RE Created - Invoice is created','007-Closed Manual CN Required'))group by GE_LGT_EM_InvoiceHeaderNumber__c];
     system.debug('AggregateRes1--->'+AggregateRes1.size());
         for(AggregateResult arg: AggregateRes1 ){
            for(GE_LGT_EM_InvoiceHeader__c pp:InvoiceAllUncheckedFlagUpdate){
                if(arg.get('GE_LGT_EM_InvoiceHeaderNumber__c') == pp.Id){
                system.debug('flag count--->'+Decimal.ValueOf(String.ValueOf(arg.get('expr0'))));
                    pp.GE_LGT_EM_DisputeFlagheader__c = Decimal.ValueOf(String.ValueOf(arg.get('expr0')));
                }
            }
        }
        update(InvoiceAllUncheckedFlagUpdate);
}
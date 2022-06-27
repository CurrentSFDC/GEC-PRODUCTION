/*
###########################################################################
# File..................:GE_LGT_EM_BatchUpdateSAPInvoiceNumber
# Version...............: 1.0
# Created by............:Jojan,Murugan,Snehil
# Created Date..........:
# Description...........:This Batch class is used to create for bulk updating InvoiceHeaderNumber field(lookup) in InvoiceLineItem object.
#                        1.Once we get the record from SAP,for this objects InvoiceHeader & InvoiceLineItem.we need to compare
#                          two fields in SAPInvoiceNumber & SAPInvoiceNumber,both fields values are same,then executing 
#                          this batch and updating field.                                 
#               
*/


global class GE_LGT_EM_BatchUpdateSAPInvoiceNumber implements Database.batchable<SObject>, Database.Stateful{ 

// ***********Start Method***********

    global Database.QueryLocator start(Database.BatchableContext info){
            
    return Database.getQueryLocator([Select id,GE_LGT_EM_SAP_Invoice_Number__c from GE_LGT_EM_InvoiceLineItem__c where CreatedDate = Today limit 500000]);
    
    }

// ***********Execute Logic Method ***********   
    global void execute(Database.BatchableContext info, List<GE_LGT_EM_InvoiceLineItem__c> scope){
    
        Map<string,GE_LGT_EM_InvoiceLineItem__c> InvoiceObjMap = new Map<string,GE_LGT_EM_InvoiceLineItem__c>();
        
       // List<GE_LGT_EM_InvoiceLineItem__c> updateSAPInvoiceNo = new List<GE_LGT_EM_InvoiceLineItem__c>();
        map<id,GE_LGT_EM_InvoiceLineItem__c> updateSAPInvoiceNo =new map<id,GE_LGT_EM_InvoiceLineItem__c>(); 
        Set<string> lineItem_Reference = new Set<string>();
    
    
            if(scope != null && scope.size() >0){
                   
                for(GE_LGT_EM_InvoiceLineItem__c IH : scope){
               
                    InvoiceObjMap.put(IH.GE_LGT_EM_SAP_Invoice_Number__c,IH );
                    lineItem_Reference.add(IH.GE_LGT_EM_SAP_Invoice_Number__c);
                    system.debug('InvoiceObjMap-------->'+InvoiceObjMap.get(IH.GE_LGT_EM_SAP_Invoice_Number__c));
                  
                }
            }
    
        List<GE_LGT_EM_InvoiceHeader__c> HeaderList =[Select id,name,GE_LGT_EM_SAPInvoiceNumber__c from GE_LGT_EM_InvoiceHeader__c where GE_LGT_EM_SAPInvoiceNumber__c in:lineItem_Reference];
        
        system.debug('HeaderList -------->'+HeaderList.size() );
    
        if(HeaderList !=null && HeaderList.size() >0){
            for(GE_LGT_EM_InvoiceLineItem__c compt:scope){
          
                for(GE_LGT_EM_InvoiceHeader__c InvHeader:HeaderList){
             
                    if(compt.GE_LGT_EM_SAP_Invoice_Number__c==InvHeader.GE_LGT_EM_SAPInvoiceNumber__c && InvoiceObjMap.ContainsKey(compt.GE_LGT_EM_SAP_Invoice_Number__c)){
                    
                     compt.GE_LGT_EM_InvoiceHeaderNumber__c=InvHeader.id; 
                                       
                     updateSAPInvoiceNo.put(compt.Id,compt);
           
                } 
              }
            } 
        
            if(updateSAPInvoiceNo.size()>0){
                system.debug('Final UpdateList-------->'+updateSAPInvoiceNo.size());
                Update updateSAPInvoiceNo.values();
            }
     }
    
  }  
// *************Logic to be Executed at finish***************  
    global void finish(Database.BatchableContext info){  
    
    } 
}
/*
###########################################################################
# File..................:GE_LGT_EM_BatchUpdateCustomerNameHeader
# Version...............: 1.0
# Created by............:Jojan,Murugan,Snehil
# Created Date..........:
# Description...........:This Batch class is used to create for bulk updating CustomerName field(lookup) in InvoiceHeader object.
#                        1.Once we get the record from SAP,for this objects InvoiceHeader & account .we need to compare
#                          two fields in SAP_Customer_Number & Payer_SoldTo_Account_Number,both fields values are same,then executing 
#                          this batch and updating field.                                 
#               
*/

global class GE_LGT_EM_BatchUpdateCustomerNameHeader implements Database.Batchable<sObject>{        


// ***********Start Method***********
        string query = 'SELECT Id,GE_LGT_EM_CustomerName__c,GE_LGT_EM_Payer_SoldTo_Account_Number__c,GE_LGT_EM_Sales_Org__c from GE_LGT_EM_InvoiceHeader__c Where CreatedDate = Today limit 500000 '; 
        
        global Database.QueryLocator start(Database.BatchableContext BC){
      
            return Database.getQueryLocator(query);
        }
// ***********Execute Logic Method ***********   

        global void execute(Database.BatchableContext BC,List<GE_LGT_EM_InvoiceHeader__c> scope) {
        
             Map<String, GE_LGT_EM_InvoiceHeader__c> HeaderMapAccountNo  = new Map<String, GE_LGT_EM_InvoiceHeader__c>();
             Map<String, GE_LGT_EM_InvoiceHeader__c> HeaderSalesOrg  = new Map<String, GE_LGT_EM_InvoiceHeader__c>();
             //list<GE_LGT_EM_InvoiceHeader__c> UpdateInvHeader = new list<GE_LGT_EM_InvoiceHeader__c>();
             map<Id, GE_LGT_EM_InvoiceHeader__c> UpdateInvHeader = new map<id, GE_LGT_EM_InvoiceHeader__c>();
             set<string>Invheader1=new set<string>();
             set<string>Invheader2=new set<string>();
             
             for(GE_LGT_EM_InvoiceHeader__c HeaderUpdate : scope){
               
             HeaderMapAccountNo.put(HeaderUpdate.GE_LGT_EM_Payer_SoldTo_Account_Number__c,HeaderUpdate);
             HeaderSalesOrg.put(HeaderUpdate.GE_LGT_EM_Sales_Org__c,HeaderUpdate);
             Invheader1.add(HeaderUpdate.GE_LGT_EM_Payer_SoldTo_Account_Number__c);
             Invheader2.add(HeaderUpdate.GE_LGT_EM_Sales_Org__c);  
             
             }    
                   
            list<account> AccObj=[select id,GE_LGT_EM_SAP_Customer_Number__c,GE_LGT_EM_Sales_Org__c from account where GE_LGT_EM_SAP_Customer_Number__c IN:Invheader1 and GE_LGT_EM_Sales_Org__c IN:Invheader2];  
            system.debug('AccObj------->'+AccObj.size()); 
            
             for(GE_LGT_EM_InvoiceHeader__c HeaderUpdate1 :scope){   
              
                  for(account acc:AccObj){
                                   
                       if(acc.GE_LGT_EM_SAP_Customer_Number__c==HeaderUpdate1.GE_LGT_EM_Payer_SoldTo_Account_Number__c  && acc.GE_LGT_EM_Sales_Org__c==HeaderUpdate1.GE_LGT_EM_Sales_Org__c ){
                          HeaderUpdate1.GE_LGT_EM_CustomerName__c=acc.id;
                           UpdateInvHeader.put(HeaderUpdate1.Id,HeaderUpdate1);
                       }
                   }   
             }
               
                if(UpdateInvHeader.size()>0){
                system.debug('UpdateInvHeader------->'+UpdateInvHeader.size());         
                update UpdateInvHeader.values();
                }   
    }          
     
  // *************Logic to be Executed at finish***************        
        global void finish(Database.BatchableContext BC){
                 
        }       
}
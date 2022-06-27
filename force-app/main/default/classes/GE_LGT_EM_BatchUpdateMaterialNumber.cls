/*
###########################################################################
# File..................:GE_LGT_EM_BatchUpdateMaterialNumber
# Version...............: 1.0
# Created by............:Murugan
# Created Date..........:
# Description...........:This Batch class is used to create for bulk updating material lookup field in InvoiceLineItem object.
#                        1.Once we get the record from SAP,for this objects MaterialMaster,InvoiceLineItem.we need to compare
#                          two fields in SAPMaterialNumber & Customer Material No,both fields values are same,then executing 
#                          this batch and updating field.                                 
#               
*/

global class GE_LGT_EM_BatchUpdateMaterialNumber implements Database.batchable<SObject>, Database.Stateful{ 
    
    // ***********Start Method***********
    
    global Database.QueryLocator start(Database.BatchableContext bc){
         Datetime last7dayz = datetime.now().addhours(-1680); 
        return Database.getQueryLocator([Select id,GE_LGT_EM_Customer_Material_Number__c
                                         //from GE_LGT_EM_InvoiceLineItem__c where CreatedDate = Today limit 500000]);
         								   from GE_LGT_EM_InvoiceLineItem__c Where GE_LGT_EM_Material__c= null AND CreatedDate >: last7dayz]);
        
    }
    
    // ***********Execute Logic Method ***********   
    global void execute(Database.BatchableContext bc, List<GE_LGT_EM_InvoiceLineItem__c> scope){
        
        
        map<id,GE_LGT_EM_InvoiceLineItem__c> updateMaterialNo = new map<id,GE_LGT_EM_InvoiceLineItem__c>();
        
        
        Set<String> lineItem_Reference = new Set<String>();
        
        if(scope != null && scope.size() >0){
            
            for(GE_LGT_EM_InvoiceLineItem__c Inv:scope){
                
                
                string s=Inv.GE_LGT_EM_Customer_Material_Number__c;
                if(s!=null && s.isNumeric()){
                    integer a = integer.valueof(s);
                    string m=string.valueOf(a);
                    system.debug('------------>'+a);
                    system.debug('------------>'+m);
                    updateMaterialNo.put(Inv.Id,Inv);
                    lineItem_Reference.add(m);
                }
                
                
            }     
        }
        
        List<GE_LGT_EM_MaterialMaster__c> MMList =[Select id,name,GE_LGT_EM_SAP_MaterialNumber__c
                                                   from GE_LGT_EM_MaterialMaster__c where GE_LGT_EM_SAP_MaterialNumber__c in:lineItem_Reference];
        
        if(MMList !=null && MMList.size() >0){
            string m;
            
            for(GE_LGT_EM_InvoiceLineItem__c compt:updateMaterialNo.values()){
                
                string s=compt.GE_LGT_EM_Customer_Material_Number__c;
                if(s!=null && s.isNumeric()){
                    integer a = integer.valueof(s);
                    m=string.valueOf(a);
                    system.debug('after int------------>'+a);
                    system.debug('after string------------>'+m);
                }
                
                for(GE_LGT_EM_MaterialMaster__c MMaster:MMList){
                    
                    if(m==MMaster.GE_LGT_EM_SAP_MaterialNumber__c){
                        system.debug('Number removezero***');
                        compt.GE_LGT_EM_Material__c =MMaster.id; 
                        //updateMaterialNo.put(compt.Id,compt);
                        system.debug('Final number update-------->'+updateMaterialNo.size());
                    }
                    
                } 
            }
            
            if(updateMaterialNo.size()>0 ){
                system.debug('Final UpdatenumberList-------->'+updateMaterialNo.size());
                Update updateMaterialNo.values();
                
            }     
            
        }
        
    }  
    
    // *************Logic to be Executed at finish***************  
    
    global void finish(Database.BatchableContext bc){  
        
    } 
}
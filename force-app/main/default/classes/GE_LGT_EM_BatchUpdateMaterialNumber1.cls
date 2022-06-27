/*
###########################################################################
# File..................:GE_LGT_EM_BatchUpdateMaterialNumber
# Version...............: 1.0
# Created by............:Jojan,Murugan,Snehil
# Created Date..........:
# Description...........:This Batch class is used to create for bulk updating material lookup field in InvoiceLineItem object.
#                        1.Once we get the record from SAP,for this objects MaterialMaster,InvoiceLineItem.we need to compare
#                          two fields in SAPMaterialNumber & Customer Material No,both fields values are same,then executing 
#                          this batch and updating field.                                 
#               
*/

global class GE_LGT_EM_BatchUpdateMaterialNumber1 implements Database.batchable<SObject>, Database.Stateful{ 
    
    // ***********Start Method***********
  
    global Database.QueryLocator start(Database.BatchableContext bc){
     Datetime last7dayz = datetime.now().addhours(-1680); 
        return Database.getQueryLocator([Select id,GE_LGT_EM_Customer_Material_Number__c
                                         //from GE_LGT_EM_InvoiceLineItem__c Where CreatedDate = Today limit 500000]);
        from GE_LGT_EM_InvoiceLineItem__c Where GE_LGT_EM_Material__c= null AND CreatedDate >: last7dayz]);
    }
    
    // ***********Execute Logic Method ***********   
    global void execute(Database.BatchableContext bc, List<GE_LGT_EM_InvoiceLineItem__c> scope){
        
        // Map<String,GE_LGT_EM_InvoiceLineItem__c> MaterialNumber  = new Map<String,GE_LGT_EM_InvoiceLineItem__c>();
        
        map<id,GE_LGT_EM_InvoiceLineItem__c> updateMaterialNo1 = new map<id,GE_LGT_EM_InvoiceLineItem__c>();
        
        
        Set<String> lineItem_Reference1 = new Set<String>();
        
        
        if(scope != null && scope.size() >0){
            
            for(GE_LGT_EM_InvoiceLineItem__c Inv:scope){
                
                //MaterialNumber.put(Inv.GE_LGT_EM_Customer_Material_Number__c,Inv );
                string s=Inv.GE_LGT_EM_Customer_Material_Number__c;
                if(s!= null && !(s.isNumeric())){
                    lineItem_Reference1.add(s);
                    updateMaterialNo1.put(Inv.Id,Inv);
                    system.debug('string material number----->'+lineItem_Reference1.size());
                }
            }     
        }
        
        List<GE_LGT_EM_MaterialMaster__c> MMList =[Select id,name,GE_LGT_EM_SAP_MaterialNumber__c
                                                   from GE_LGT_EM_MaterialMaster__c where GE_LGT_EM_SAP_MaterialNumber__c in:lineItem_Reference1];
        
        if(MMList !=null && MMList.size() >0){
            string ss;
            for(GE_LGT_EM_InvoiceLineItem__c compt:updateMaterialNo1.values()){
                
                string s=compt.GE_LGT_EM_Customer_Material_Number__c;
                if(s!= null && !(s.isNumeric())){
                    ss=s;
                }
                
                for(GE_LGT_EM_MaterialMaster__c MMaster:MMList){
                    
                    if(ss==MMaster.GE_LGT_EM_SAP_MaterialNumber__c){
                        system.debug('string vsalues come here');
                        compt.GE_LGT_EM_Material__c =MMaster.id; 
                        //updateMaterialNo1.put(compt.Id,compt);
                        system.debug('UpdatestringList-------->'+updateMaterialNo1.size());
                    }
                    
                    
                } 
            }
            
            if(updateMaterialNo1.size()>0 ){
                system.debug('Final update string-------->'+updateMaterialNo1.size());
                Update updateMaterialNo1.values();
                
            }     
            
        }
        
    }  
    
    // *************Logic to be Executed at finish***************  
    
    global void finish(Database.BatchableContext bc){  
        
    } 
}
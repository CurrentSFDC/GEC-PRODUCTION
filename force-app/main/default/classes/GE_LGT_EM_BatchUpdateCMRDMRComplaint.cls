/*
###########################################################################
# File..................:GE_LGT_EM_BatchUpdateCMRDMRComplaint
# Version...............: 1.0
# Created by............:Jojan,Murugan,Snehil
# Created Date..........: 
# Description...........: This Batch class is used to create for bulk updating DMRO Number field in ComplaintLineItem object.
#                        1.Once we get the record from SAP,for this objects ComplaintLineItem & InvoiceLineItem.we need to compare
#                          two fields in Complaint_LineItemNo & Complaint_LineItemNo__c,both fields values are same,then executing 
#                          this batch and updating field.
*/

global class GE_LGT_EM_BatchUpdateCMRDMRComplaint implements Database.batchable<SObject>, Database.Stateful
{ 
    
    // ***********Start Method***********
    global Database.QueryLocator start(Database.BatchableContext info)
    {
        Datetime last9hours = datetime.now().addhours(-9);
        return Database.getQueryLocator([Select Id,GE_LGT_EM_Order_Number__c,GE_LGT_EM_Complaint_LineItemNo__c,GE_LGT_EM_SAP_Invoice_Number__c,GE_LGT_EM_CM_DM_RO_NO__c,GE_LGT_EM_CMR_DMR_RE_No__c from GE_LGT_EM_InvoiceLineItem__c Where LastModifiedDate >: last9hours]);
	}
    
    // ***********Execute Logic Method ***********   
    global void execute(Database.BatchableContext info, List<GE_LGT_EM_InvoiceLineItem__c>scope)
    {
        map<id,GE_LGT_EM_ComplaintLineItem__c> updateComplaint = new map<id,GE_LGT_EM_ComplaintLineItem__c>();
        Set<String> lineItem_Reference = new Set<String>();
        if(scope != null && scope.size() >0)
        {
            for(GE_LGT_EM_InvoiceLineItem__c CItem : scope)
            {
                lineItem_Reference.add(CItem.GE_LGT_EM_Complaint_LineItemNo__c);
            }
        }
        List<GE_LGT_EM_ComplaintLineItem__c> lstComplaintItem =[Select id,Name,GE_LGT_EM_Status__c,GE_LGT_EM_SAPInvoiceNumber__c,SAP_Order_Nr__c,GE_LGT_EM_Ref_InvoiceLineItem__c,GE_LGT_EM_CM_DM_RO_Number__c,GE_LGT_EM_CMR_DMR_RO_Number__c from  GE_LGT_EM_ComplaintLineItem__c 
                                                                where Name in:lineItem_Reference];
        system.debug('lstComplaintItem -------->'+lstComplaintItem);
        if(lstComplaintItem !=null && lstComplaintItem.size() >0)
        {
            for(GE_LGT_EM_InvoiceLineItem__c compt:scope)
            {
                for(GE_LGT_EM_ComplaintLineItem__c LineItem:lstComplaintItem)
                {
                    if(compt.GE_LGT_EM_Complaint_LineItemNo__c==LineItem.Name)
                    {
                        LineItem.GE_LGT_EM_CM_DM_RO_Number__c=compt.GE_LGT_EM_CM_DM_RO_NO__c;
                        LineItem.GE_LGT_EM_CMR_DMR_RO_Number__c=compt.GE_LGT_EM_Order_Number__c;
                        LineItem.GE_LGT_EM_Status__c='006-CM/DM/RE Created - Invoice is created'; 
                        LineItem.GE_LGT_EM_CountFlag__c=1;
                        //   system.debug('saporderNo-------->'+LineItem.SAP_Order_Nr__c);             
                        updateComplaint.put(LineItem.id,LineItem);
                        
                    } 
                }
            } 
            
            if(updateComplaint.size()>0)
            {
                system.debug('Final UpdateList-------->'+updateComplaint.size());
                Database.Update(updateComplaint.values(),false);
            }
        }
        
    }  
    // *************Logic to be Executed at finish***************  
    global void finish(Database.BatchableContext info)
    {  
      
    } 
}
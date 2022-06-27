/***********************************************************************************************
*   Class Name      : ComplaintLineItemHelper 
*   Date            : 6/21/2017
*   Author          : Pavan Kumar
*   Object          : ComplaintLineItem
*   Purpose         : These methods fire on ComplaintLineItem.
*   Test Class      : ComplaintLineItemHelper_Test
**************************************************************************************************/
public class ComplaintLineItemHelper {
    
    /***********************************************************************************************
    *   Method Name     : updateComplaintReferenceNumber 
    *   Old Name        : GE_LGT_EM_AutoIncrementNumber --Trigger 
    *   Purpose         : This method is to update GE_LGT_EM_Complaint_Reference_Number__c based on the largest GE_LGT_EM_Complaint_Reference_Number__c
    *   Input           : using Trigger.new 
    *   Return          : N/A
    **************************************************************************************************/
    public static void updateComplaintReferenceNumber (List<GE_LGT_EM_ComplaintLineItem__c > newCLIList) {
        Set<Id> caseId = new Set<Id>();
        integer counter=0;   
        id MANUAL_COMPLAINT_RecordType =Schema.SObjectType.GE_LGT_EM_ComplaintLineItem__c.getRecordTypeInfosByName().get('Manual Complaint LineItems').getRecordTypeId();   
        for (GE_LGT_EM_ComplaintLineItem__c eachCLI : newCLIList) {
            if(eachCLI .RecordTypeId== MANUAL_COMPLAINT_RecordType ) {
                caseId.add(eachCLI .GE_LGT_EM_CaseNumber__c);
            }  
        }
        list<GE_LGT_EM_ComplaintLineItem__c> ListLineItemCount=[SELECT GE_LGT_EM_Complaint_Reference_Number__c FROM GE_LGT_EM_ComplaintLineItem__c where GE_LGT_EM_CaseNumber__c=:Caseid and GE_LGT_EM_Complaint_Reference_Number__c !=null order by GE_LGT_EM_Complaint_Reference_Number__c desc limit 1];
        if(ListLineItemCount.size()>0) {
            for(GE_LGT_EM_ComplaintLineItem__c eachCLI :ListLineItemCount) {
                counter = integer.valueof(eachCLI.GE_LGT_EM_Complaint_Reference_Number__c );
            }
        }     
        for(GE_LGT_EM_ComplaintLineItem__c eachCLI :newCLIList) {
            if(counter==0) {
                counter=10;
            } else {
                counter=counter+10;
            }
            if(eachCLI.GE_LGT_EM_CaseNumber__c!=null && eachCLI.RecordTypeId== MANUAL_COMPLAINT_RecordType ) {
                eachCLI.GE_LGT_EM_Complaint_Reference_Number__c=counter;
            }
        }
    }
    
    /***********************************************************************************************
    *   Method Name     : checkRelevant 
    *   Old Name        : GE_LGT_EM_BDRelevantCheck --Trigger 
    *   Purpose         : This method is to update GE_LGT_EM_BD_Relevant_Warning__c based on GE_LGT_EM_BD_Relevant__c in account
    *   Input           : using Trigger.new, Trigger.NewMap, Trigger.Old and Trigger.OldMap
    *   Return          : N/A
    **************************************************************************************************/
    public static void checkRelevant (List<GE_LGT_EM_ComplaintLineItem__c > newCLIList, Map<Id,GE_LGT_EM_ComplaintLineItem__c > newCLIMap,List<GE_LGT_EM_ComplaintLineItem__c > oldCLIList, Map<Id,GE_LGT_EM_ComplaintLineItem__c > oldCLIMap) {
 /**  Commented out after Tungsram separation
        List<Account> AccountList= new List<Account>(); 
        set<Id> CaseIds= new set<Id>();
        List<Case> CaseList = new List<Case>();
        Map<Id,Id> AccountCaseMap = new Map<Id,Id>();
        Map<Id,String> CustomerFlagMap = new Map<Id,String>();
        for (GE_LGT_EM_ComplaintLineItem__c clitem : newCLIList) {      
            CaseIds.add(clitem.GE_LGT_EM_CaseNumber__c);           
        }
        CaseList=[Select Id,AccountId from Case where Id in :CaseIds];
        for(Case c : CaseList){
            AccountCaseMap.put(c.Id,c.AccountId);    
        }
        AccountList=[select id,GE_LGT_EM_BD_Relevant__c from Account where id in :AccountCaseMap.Values()];
        for(Account a:AccountList){
            CustomerFlagMap.put(a.Id,string.valueof(a.GE_LGT_EM_BD_Relevant__c));               
        }
        Set<String> CategorySet = new Set<String>{'111-Damaged goods(WHS)','137-Damaged goods-No Return','138-Damaged goods(TRN)','152-Damaged goods-Return(TRN)','158-Defective-CRC','403-damaged goods return ( whs)'};
        for (GE_LGT_EM_ComplaintLineItem__c eachCLI : newCLIList) {
            if(CustomerFlagMap.get(AccountCaseMap.get(eachCLI.GE_LGT_EM_CaseNumber__c)) == String.valueof(True)) {
                if(CategorySet.contains(eachCLI.GE_LGT_EM_Category__c)) {
                    eachCLI.GE_LGT_EM_BD_Relevant_Warning__c = true;
                } else {
                    eachCLI.GE_LGT_EM_BD_Relevant_Warning__c = false;
                }
            } else if(CustomerFlagMap.get(AccountCaseMap.get(eachCLI.GE_LGT_EM_CaseNumber__c)) == String.valueof(False)){        
                eachCLI.GE_LGT_EM_BD_Relevant_Warning__c = false;        
            }
            
        }  
        **/
    }
    
    /***********************************************************************************************
    *   Method Name     : updateInvoiceLineItem 
    *   Old Name        : GE_LGT_EM_DisputeUpdateInvoice --Trigger 
    *   Purpose         : This trigger used for,Disputeflag updating,when opening a first complaint of under Invoice line item/invoce header,dispute flag should be checked.
    *                     and also calculating the child object(ComplaintLineItem)records count. 
    *   Input           : using Trigger.new, Trigger.NewMap, Trigger.Old and Trigger.isInsert
    *   Return          : N/A
    **************************************************************************************************/
    public static void updateInvoiceLineItem(List<GE_LGT_EM_ComplaintLineItem__c > CLIList, Map<Id,GE_LGT_EM_ComplaintLineItem__c> CLIMap, List<GE_LGT_EM_ComplaintLineItem__c> oldList, boolean isInsert){
        set<Id> parentList= new set<Id> ();
        set<Id> newParentList= new set<Id> ();
        List <GE_LGT_EM_InvoiceLineItem__c> countupdate = new List<GE_LGT_EM_InvoiceLineItem__c>();
        List <AggregateResult> AggregateRes = new List<AggregateResult>();
        
        for (GE_LGT_EM_ComplaintLineItem__c eachCLI : CLIList) {
            if(eachCLI.GE_LGT_EM_Ref_InvoiceLineItem__c != null) {
                parentList.add(eachCLI.GE_LGT_EM_Ref_InvoiceLineItem__c);
                newParentList.add(eachCLI.GE_LGT_EM_Ref_InvoiceLineItem__c);
            }
        }
        if(oldList !=null) {
            for (GE_LGT_EM_ComplaintLineItem__c c : oldList) {
                if(c.GE_LGT_EM_Ref_InvoiceLineItem__c != null) {
                    parentList.add(c.GE_LGT_EM_Ref_InvoiceLineItem__c);
                }
            }
        }
        countupdate = [Select Id,GE_LGT_EM_Dispute_Flag__c,GE_LGT_EM_DisputeCount__c From GE_LGT_EM_InvoiceLineItem__c Where Id In :parentList];
        AggregateRes = [Select count(id),GE_LGT_EM_Ref_InvoiceLineItem__c From GE_LGT_EM_ComplaintLineItem__c Where GE_LGT_EM_Ref_InvoiceLineItem__c IN:parentList group by GE_LGT_EM_Ref_InvoiceLineItem__c];
        
        for(AggregateResult ar :AggregateRes ) {
            for(GE_LGT_EM_InvoiceLineItem__c eachILI :countupdate) {
                if(ar.get('GE_LGT_EM_Ref_InvoiceLineItem__c') == eachILI.Id) {
                    eachILI.GE_LGT_EM_DisputeCount__c = Decimal.ValueOf(String.ValueOf(ar.get('expr0')));
                }
            }
        }
        update(countupdate);
      
        if (oldList !=null) {
            List <GE_LGT_EM_InvoiceLineItem__c> Closedcountupdate = [Select Id,GE_LGT_EM_DisputeClosedcount__c From GE_LGT_EM_InvoiceLineItem__c Where Id In :newParentList];
            List <AggregateResult> AggregateRes1 = [Select count(id),GE_LGT_EM_Ref_InvoiceLineItem__c From GE_LGT_EM_ComplaintLineItem__c Where GE_LGT_EM_Ref_InvoiceLineItem__c IN :newParentList and GE_LGT_EM_Status__c IN('003-Rejected','006-CM/DM/RE Created - Invoice is created','007-Closed Manual CN Required') group by GE_LGT_EM_Ref_InvoiceLineItem__c];
            for(AggregateResult arg: AggregateRes1 ) {
                for(GE_LGT_EM_InvoiceLineItem__c eachILI :Closedcountupdate) {
                    if(arg.get('GE_LGT_EM_Ref_InvoiceLineItem__c') == eachILI.Id) {
                        eachILI.GE_LGT_EM_DisputeClosedcount__c = Decimal.ValueOf(String.ValueOf(arg.get('expr0')));
                    }
                }
            }
            update(Closedcountupdate);
        }
    }
    
    /***********************************************************************************************
    *   Method Name     : callCrediCardDemo 
    *   Old Name        : GE_LGT_EM_callwebservice --Trigger 
    *   Purpose         : This class is used to based on criteria immediatelly sending to Credit demo request(433).
    *   Input           : using Trigger.new, Trigger.NewMap, Trigger.Old and Trigger.OldMap
    *   Return          : N/A
    **************************************************************************************************/
    
    public static void callCrediCardDemo (List<GE_LGT_EM_ComplaintLineItem__c > newCLIList, Map<Id,GE_LGT_EM_ComplaintLineItem__c > newCLIMap,List<GE_LGT_EM_ComplaintLineItem__c > oldCLIList, Map<Id,GE_LGT_EM_ComplaintLineItem__c > oldCLIMap) {
        set<string> LineItemid = new set<string>();
        List<GE_LGT_EM_ComplaintLineItem__c> ListToUpdate=new List<GE_LGT_EM_ComplaintLineItem__c>();
        for(GE_LGT_EM_ComplaintLineItem__c eachCLI :[select id,GE_LGT_EM_Doc_Type__c,GE_LGT_EM_SAPInvoiceNumber__c,GE_LGT_EM_Status__c,GE_LGT_EM_Integration_Status__c,GE_LGT_EM_CR_DR_RE_Request_Sent__c,GE_LGT_EM_Manual_CR_DR_RE__c from GE_LGT_EM_ComplaintLineItem__c where id IN:newCLIMap.keySet()]){
            system.debug('*****'+eachCLI);
            if(eachCLI.GE_LGT_EM_Integration_Status__c=='SAP Updated'&& eachCLI.GE_LGT_EM_CR_DR_RE_Request_Sent__c==false && eachCLI.GE_LGT_EM_Manual_CR_DR_RE__c ==false) {
                LineItemid.add(eachCLI.id);
                eachCLI.GE_LGT_EM_CR_DR_RE_Request_Sent__c = true;
                ListToUpdate.add(eachCLI);
            }
        }
        update ListToUpdate;
        if(LineItemid.size() > 0) {
            GE_LGT_EM_SAPWebservice.SfdcTOSapwebservice(LineItemid);
            List<GE_LGT_EM_ComplaintLineItem__c> ReocrdsentToSAPList=[select id,Name,GE_LGT_EM_SAPInvoiceNumber__c,GE_LGT_EM_Manual_Invoice_Number__c from GE_LGT_EM_ComplaintLineItem__c where id in:LineItemid];
            list<GE_LGT_EM_ErrorLog__c> errorLogs =new list<GE_LGT_EM_ErrorLog__c>();
            for(GE_LGT_EM_ComplaintLineItem__c each: ReocrdsentToSAPList) {
                GE_LGT_EM_ErrorLog__c SAPSentRecord=new GE_LGT_EM_ErrorLog__c();
                SAPSentRecord.GE_LGT_EM_ComplaintNo__c=each.Name;
                SAPSentRecord.GE_LGT_EM_IntegrationStatus__c='433 Integration-Successfully sent this record';
                if(each.GE_LGT_EM_Manual_Invoice_Number__c==Null) {
                    SAPSentRecord.GE_LGT_EM_SAPInvoiceNumber__c=each.GE_LGT_EM_SAPInvoiceNumber__c;
                } else {
                    SAPSentRecord.GE_LGT_EM_SAPInvoiceNumber__c=each.GE_LGT_EM_Manual_Invoice_Number__c;
                }
                errorLogs.add(SAPSentRecord);
            }
            insert errorLogs;
        }
    }
    
    /***********************************************************************************************
    *   Method Name     : callFlaggingDispute 
    *   Old Name        : GE_LGT_EM_callwebservice --Trigger 
    *   Purpose         : This class is used to based on criteria immediatelly sending to Flaging(Dispute 171).
    *   Input           : using Trigger.new and Trigger.NewMap
    *   Return          : N/A
    **************************************************************************************************/
    public static void callFlaggingDispute (List<GE_LGT_EM_ComplaintLineItem__c > newCLIList, Map<Id,GE_LGT_EM_ComplaintLineItem__c > newCLIMap) {
        set<string>ComplationLineItemid=new set<string>();
        for(GE_LGT_EM_ComplaintLineItem__c eachCLI :newCLIList) {
            if(eachCLI.GE_LGT_EM_Status__c=='001-Open') {
                ComplationLineItemid.add(eachCLI.id);
            }
        }
        if(ComplationLineItemid.size()>0) {
            GE_LGT_EM_CaseComplaint171Webservice.SfdcTOSapCaseComplaint171(ComplationLineItemid);
            List<GE_LGT_EM_ComplaintLineItem__c> sentToSAPList=[select id,Name,GE_LGT_EM_SAPInvoiceNumber__c,GE_LGT_EM_Manual_Invoice_Number__c from GE_LGT_EM_ComplaintLineItem__c where id in:ComplationLineItemid];
            list<GE_LGT_EM_ErrorLog__c> errorLogs =new list<GE_LGT_EM_ErrorLog__c>();
            for(GE_LGT_EM_ComplaintLineItem__c each: sentToSAPList) {
                GE_LGT_EM_ErrorLog__c errRecord=new GE_LGT_EM_ErrorLog__c();
                errRecord.GE_LGT_EM_ComplaintNo__c=each.Name;
                errRecord.GE_LGT_EM_IntegrationStatus__c='171 Integration-Successfully sent this record';
                errRecord.GE_LGT_EM_SAPInvoiceNumber__c =each.GE_LGT_EM_SAPInvoiceNumber__c;
                errorLogs.add(errRecord);
            }
            insert errorLogs;
        }
    }
}
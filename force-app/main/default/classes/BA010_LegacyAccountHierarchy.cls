/*
Name - BA010_LegacyAccountHierarchy 
Test Class - BA010_LegacyAccountHierarchy_Test
Author - Neel
Purpose - To Process hierarchical relationship for legacy accounts (Account Group:'Z001','Z002','ZHN2','ZHN3')
Created Date - March-2018
*/
global class BA010_LegacyAccountHierarchy implements Database.Batchable<sobject>
{    
    global String [] email = new String[] {System.label.rashmiEmailId,System.label.satishEmailId};
        //Start method will load all the legacy accounts into query cursor
        global Database.Querylocator start (Database.BatchableContext BC) 
    {
        String[] accountGroups = new String[] {'Z001','Z002','ZHN2','ZHN3'};
        //String[] SAPCustNos = new String[] {'1111222232','1111222233'};
                // return Database.getQueryLocator('Select id, Name FROM account where Account_Group__c ='ZNH2'\' ') ');
                // return Database.getQueryLocator('Select id, Name,GE_LGT_EM_SAP_Customer_Number__c ,SAP_Parent_Customer_No__c FROM account where Account_Group__c IN :accountGroups AND GE_LGT_EM_SAP_Customer_Number__c IN:SAPCustNos' );
            // return Database.getQueryLocator('Select id, Name,GE_LGT_EM_SAP_Customer_Number__c ,SAP_Parent_Customer_No__c FROM account where GE_LGT_EM_SAP_Customer_Number__c IN:SAPCustNos' );
             return Database.getQueryLocator('Select id, Name,GE_LGT_EM_SAP_Customer_Number__c ,SAP_Parent_Customer_No__c FROM account where Account_Group__c IN :accountGroups ' );
    }
    global void execute (Database.BatchableContext BC, List<Account> legacyAcctHierList ) 
    {
        // Store Parent CustomerNumber in a set, to be used in query
        system.debug('legacyAcctHierList :: '+legacyAcctHierList);
        Set<String> CustNumberSet = new Set<String>();
        for ( Account legacyAcctVar : legacyAcctHierList ){
            CustNumberSet.add(legacyAcctVar.GE_LGT_EM_SAP_Customer_Number__c);
            system.debug('Customer Number :: '+legacyAcctVar.GE_LGT_EM_SAP_Customer_Number__c);
            
            if( legacyAcctVar.SAP_Parent_Customer_No__c!=null )
                CustNumberSet.add(legacyAcctVar.SAP_Parent_Customer_No__c);
            system.debug('CustNumberSet :: '+CustNumberSet);
            
        }
        Map<String, Account> existingAccountMap = new Map<String, Account>();
        if(!CustNumberSet.isEmpty()) {
            // accountIdNumberMap = new Map<Id, Account>([Select id, GE_LGT_EM_SAP_Customer_Number__c ,SAP_Parent_Customer_No__c FROM Account where GE_LGT_EM_SAP_Customer_Number__c in : CustNumberSet]);
            for ( Account acctVar : [Select id, GE_LGT_EM_SAP_Customer_Number__c FROM Account where GE_LGT_EM_SAP_Customer_Number__c in : CustNumberSet] ) {
                //existingAccountMap.put(acctVar.id , acctVar);
                if(acctVar.GE_LGT_EM_SAP_Customer_Number__c!=null || acctVar.GE_LGT_EM_SAP_Customer_Number__c!='' )
                    existingAccountMap.put(acctVar.GE_LGT_EM_SAP_Customer_Number__c, acctVar);
                
            }
        }
        
        // If parent customer number is not null then update field 'ParentAccount'
        List<Account> accountListToBeUpdated = new List<Account>();
        for ( Account legacyAcctVar : legacyAcctHierList ){
            if(legacyAcctVar.SAP_Parent_Customer_No__c!=null && !existingAccountMap.isEmpty() && existingAccountMap.containsKey(legacyAcctVar.SAP_Parent_Customer_No__c) ) {
                
                legacyAcctVar.parentid=existingAccountMap.get(legacyAcctVar.SAP_Parent_Customer_No__c).id;
                accountListToBeUpdated.add(legacyAcctVar);
            }
        }
        
        // Update accountListToBeUpdated list
        if( !accountListToBeUpdated.isEmpty() ) {
            UPDATE accountListToBeUpdated;
        }
        
        
    }
    global void finish(Database.BatchableContext BC)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        AsyncApexJob a = [Select a.TotalJobItems, a.Status, a.NumberOfErrors, a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById, a.CompletedDate From AsyncApexJob a WHERE id = :BC.getJobId()];
        System.debug('$$$ Jobid is'+BC.getJobId());
        mail.setToAddresses(email);
        mail.setReplyTo('neel.singh@ge.com');
        mail.setSenderDisplayName('Account hierarchy - legacy accounts');
        mail.setSubject('Account hierarchy - legacy accounts (Z001/Z002/ZHN2/ZHN3) Processing: '+ a.Status);
        mail.setPlainTextBody('Account hierarchy - legacy accounts (Z001/Z002/ZHN2/ZHN3) completed for today. The results are summarized below:' + '<br>' + 'Batches: ' + a.TotalJobItems + '<br>' + 'Errors: ' + a.NumberOfErrors + '<br>' + 'Items Processed: ' + a.JobItemsProcessed);
        Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});
        
    }
}
/*
ClassName - AccountConvertZSTGToEnduserBatch
Test class - AccountConvertZSTGToEnduserBatch_Test
Purpose - This calss will convert 'ZSTG' rectype Accounts (Inactive=true) into 'End User' rectype record
Author - Sai
*/
global class AccountConvertZSTGToEnduserBatch implements Database.Batchable<SObject> 
{
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        ID recSASID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        return Database.getQueryLocator([SELECT RecordTypeId, id,GE_LGT_EM_CustomerActiveFlag__c,GE_LGT_EM_SAPUniqueIdentifier__c FROM Account  WHERE RecordTypeId=:recSASID  and GE_LGT_EM_CustomerActiveFlag__c=false ]);
    }
    global void execute(Database.BatchableContext BC, List<SObject> batchRecords) 
    {
        system.debug('Queryid++++++++++++'+batchRecords);
        List<Account> updateAccount = new List<Account>();
        ID recEUID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        
        try
        {
            for(SObject a : batchRecords) 
            {
                Account acc = (Account)a;
                
                if(acc.GE_LGT_EM_CustomerActiveFlag__c==false) 
                {
                    acc.RecordTypeid = recEUID;
                    acc.Act_Converted_to_End_User__c=true;
                    acc.Act_Converted_Date_to_End_User__c=System.Today();
                    system.debug('acc.RecordTypeid'+ acc.RecordTypeid);
                    acc.GE_LGT_EM_CustomerActiveFlag__c=true;
                    acc.GE_LGT_EM_SAPUniqueIdentifier__c=acc.GE_LGT_EM_SAPUniqueIdentifier__c.replace('Z8','EU');
                    updateAccount.add(acc);
                }
                
            }
            system.debug('updateAccountbefore'+ updateAccount);
            update updateAccount;
            system.debug('updateAccount'+ updateAccount);
        }
        catch(Exception e)
        { 
            system.debug('Unable to convert ZSTG Account to End User....'+ e);
        }
    }
    global void finish(Database.BatchableContext BC) 
    {
    }
}
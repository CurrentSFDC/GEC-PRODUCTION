public class GE_LGT_EM_deleteduplicateaccount{

//Specify the method to make the callout to external systems executed asynchronously.
@future
public static void Dupdeleteaccount(set<string>aids){

//List<recordtype> rt=[select id,name from recordtype where sobjecttype='Account' and name='SAP Account'];

//list<Account> acc1=[SELECT id,GE_LGT_EM_SAP_Customer_Number__c FROM Account WHERE id in:aids limit 50];
list<Account> acc1=[SELECT id,GE_LGT_EM_SAP_Customer_Number__c FROM Account WHERE id in:aids];
   
delete acc1; 
  }
}
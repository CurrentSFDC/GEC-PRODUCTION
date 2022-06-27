/***********************************************************************************************
*   Class Name      : AccountRollupHandler 
*   Date            : 
*   Author          : 
*   Object          : Opportunity
*   Purpose         : These methods fire on Opportunity.
*   Test Class      :OpportunityRollUpHandler_Test
**************************************************************************************************/
global class AccountRollupHandler 
{
    @future
    public static void setRollupsOnAccountFuture(Set<Id> accountIds)
    {
        setRollupsOnAccount(accountIds);
    }
    
    public static void setRollupsOnAccount(Set<Id> accountIds)
    {
        UtilityClass carrancyConverter=new UtilityClass();
        Map<String,NA_Profiles__c> profiles_NA = NA_Profiles__c.getAll();
        
        //getting Account object record type ids and adding into a set
        Set<Id> accRecTypeIds=new Set<Id>();
        ID recSATypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
        accRecTypeIds.add(recSATypeID);
        //ID recsSAATypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Agent').getRecordTypeId();
        //accRecTypeIds.add(recsSAATypeID);
        ID recSAFATypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Agent').getRecordTypeId();
        accRecTypeIds.add(recSAFATypeID);
        ID recSASTypeID=Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Strategic').getRecordTypeId();
        accRecTypeIds.add(recSASTypeID);
        
        //fetching Accounts with related Opportunities
        Map<id,Account> accMapOfOptys=new Map<id,Account>([select id,Recordtypeid,CurrencyIsoCode,Owner.profileid,Sum_of_all_Open_Op_Revenues__c,Sum_of_Estimated_Orders_To_Go__c,Sum_of_SAP_Orders_Received__c,(select id,stagename,CurrencyIsoCode,Amount,Total_Order_Amount__c,Estimated_Orders_to_go__c,Total_Orders_Received_TD__c from Opportunities) from Account where id in:accountIds and Recordtypeid in:accRecTypeIds]);
        
        System.debug('###accMapOfOptys.keyset().size():'+accMapOfOptys.keyset().size());
        if(!accMapOfOptys.isEmpty()){
            //below list contain accounts which whic need to updated the rollups 
            List<Account> rollupACTUpdate=new list<Account>();
            
            for(id accId:accMapOfOptys.keySet()){
                decimal opptyAmount=0;
                decimal opptySAPorders_TD=0;
                decimal opptyTotalEtimatedorders_TD=0;
                //iterating Optys under Account
                for(Opportunity opp:accMapOfOptys.get(accId).Opportunities){
                    System.debug('###opp.stagename:'+opp.stagename);
                    
                    //calculation for  Sum_of_all_Open_Op_Revenues__c
                    if(opp.Amount!=null && (opp.stagename !='PO Received' && opp.stagename !='Closed Lost'))
                        opptyAmount+=carrancyConverter.convertCurrencyMethod(opp.CurrencyIsoCode,accMapOfOptys.get(accId).CurrencyIsoCode,opp.Amount);
                    
                    //calculation for  Sum_of_SAP_Orders_Received__c
                    if(opp.Total_Orders_Received_TD__c!=null)
                        opptySAPorders_TD+=carrancyConverter.convertCurrencyMethod(opp.CurrencyIsoCode,accMapOfOptys.get(accId).CurrencyIsoCode,opp.Total_Orders_Received_TD__c);
                    
                    //calculation for Sum_of_Estimated_Orders_To_Go__c
                    if(opp.Estimated_Orders_to_go__c!=null)
                        opptyTotalEtimatedorders_TD+=carrancyConverter.convertCurrencyMethod(opp.CurrencyIsoCode,accMapOfOptys.get(accId).CurrencyIsoCode,opp.Estimated_Orders_to_go__c);
                    
                    System.debug('###opptyAmount:'+opptyAmount); 
                    System.debug('###opptySAPorders_TD:'+opptySAPorders_TD); 
                    System.debug('###opptyTotalEtimatedorders_TD:'+opptyTotalEtimatedorders_TD); 
                }// end of 2nd for loop
                
                System.debug('###Is NA profile:'+profiles_NA.containskey(accMapOfOptys.get(accId).owner.profileid));
                //checking owner profile is NA or not
                if(profiles_NA.containskey(accMapOfOptys.get(accId).owner.profileid)){
                    accMapOfOptys.get(accId).Sum_of_all_Open_Op_Revenues__c=opptyTotalEtimatedorders_TD;
                }
                else{
                    accMapOfOptys.get(accId).Sum_of_all_Open_Op_Revenues__c=opptyAmount;  
                }
                accMapOfOptys.get(accId).Sum_of_SAP_Orders_Received__c=opptySAPorders_TD;
                accMapOfOptys.get(accId).Sum_of_Estimated_Orders_To_Go__c=opptyTotalEtimatedorders_TD;
                
                System.debug('###accMapOfOptys.get(accId):'+accMapOfOptys.get(accId)); 
                
                
                rollupACTUpdate.add(accMapOfOptys.get(accId));
                
            }// end of 1st for loop
            
            update rollupACTUpdate;
        }
    }  
}
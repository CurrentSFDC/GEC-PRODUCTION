/*
Name - OpportunityTrigger
Test Class - OrderTriggerHelperForRollupAcc_Test
Author -Sivateja
Purpose - Handler on roll up stratigic  ammount on Account.
Date - sept-2016
*/
public class OrderTriggerHelperForRollupAcc {
    public static UtilityClass carrancyconverter=new UtilityClass();
    public static void rollupOnAcc(List<Order> orderList)
    {
        ID recOrderTypeID=Schema.SObjectType.order.getRecordTypeInfosByName().get('Received PO').getRecordTypeId();
        list<id> straticgicAcc=new list<id>();
        for(Order Ord:orderList){
            
            if( Ord.RecordTypeid==recOrderTypeID && Ord.Strategic_Account__c != null){
                 
                straticgicAcc.add(Ord.Strategic_Account__c);
            }
        }
        if(!straticgicAcc.isEmpty()){
           
            map<id,Account> strAccs=new map<id,Account>([select id,CurrencyIsoCode,Sum_of_Sap_Strategic_Amounts__c,(select id,TotalAmount,CurrencyIsoCode,PO_Received_Formula__c from Orders__r where RecordTypeid=:recOrderTypeID)from Account where id in:straticgicAcc]);
            list<Account> AccountUpdatedlist=new list<Account>();
            for(id Accid:strAccs.keySet()){
                decimal OrderAmount=0;
                for(Order Ord:strAccs.get(Accid).Orders__r){
                    if(Ord.TotalAmount != null)
                        OrderAmount+=carrancyconverter.convertCurrencyMethod(Ord.CurrencyIsoCode,strAccs.get(Accid).CurrencyIsoCode,Ord.TotalAmount);
                    
                }
                
                strAccs.get(Accid).Sum_of_Sap_Strategic_Amounts__c=OrderAmount;
                AccountUpdatedlist.add(strAccs.get(Accid));
            }
            try{
            if(!AccountUpdatedlist.isEmpty())
                update AccountUpdatedlist;
            }
            catch(exception e){
                
            }
        }
        
    }
}
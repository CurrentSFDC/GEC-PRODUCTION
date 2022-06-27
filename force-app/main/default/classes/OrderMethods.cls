/***********************************************************************************************
*   Class Name      : OrderMethods 
*   Date            : 
*   Author          : 
*   Object          : Order
*   Purpose         : These methods fire on Order.
*   Test Class      : OrderTriggerHelper_Test
**************************************************************************************************/

  /*
@Request No   ::
@Description  :: Rolling up Amounts and Po Date on Opportunity
@Author       ::
@Event        :: after insert,after update,after delete
*/
public with sharing class OrderMethods {

    public static void updateOptyFromOrder ( List<Order> oldOrderList, List<Order> newOrderList, Map<id, Order> oldOrderMap, Map<id, Order> newOrderMap ) {
        if(StaticvariablesForOrder.OrderOwnerChangeIfOptyOwnerChange){
        set<id> oppIdSet = new Set<id>();
        Map<id,Opportunity> OppUpdMap = new Map<id,Opportunity>();
        Map<id,Opportunity> OppamountUpdMap = new Map<id,Opportunity>();
        List<Order> orderList=new List<Order>();
        ID estimatedOrderRecTypeID=Schema.SObjectType.Order.getRecordTypeInfosByName().get('Estimated PO').getRecordTypeId();
        ID receivedOrderRecTypeID=Schema.SObjectType.Order.getRecordTypeInfosByName().get('Received PO').getRecordTypeId();
         Map<id,string> optyWithError=new map<id,String>();
           
            List<Opportunity> opptiesToUpdate=new List<Opportunity>();
            
       if ( trigger.isInsert ) {
            for ( Order ord : newOrderList ) {
                if(ord.OpportunityId!=NULL)
                    oppIdSet.add(ord.OpportunityId);
                    orderList.add(ord);
            }
        }

        if ( trigger.isUpdate ){
            for ( Order ord : newOrderList ) {
                 orderList.add(ord);
                if ( (oldOrderMap.get(ord.id).EffectiveDate != newOrderMap.get(ord.id).EffectiveDate)||((ord.recordtypeId==estimatedOrderRecTypeID  && oldOrderMap.get(ord.id).Order_Amount__c != newOrderMap.get(ord.id).Order_Amount__c)||(ord.recordtypeId==receivedOrderRecTypeID )) )
                { 
                    oppIdSet.add(ord.OpportunityId);
                }
            }
        }

        if ( trigger.isDelete ) {
            for ( Order oldOrd : OldOrderList ){
                if(oldOrd.OpportunityId!=NULL)
                     orderList.add(oldOrd);
                    oppIdSet.add(oldOrd.OpportunityId);
            }
        }
        OppamountUpdMap=updateAmountsOpportunity(orderList);
        
        if ( oppIdSet.size() > 0 ) {
          OppUpdMap=updatePoDateFromOrder(oppIdSet);
           
        }
        
        for(Id oppid:OppamountUpdMap.keyset()){
            if(OppUpdMap.containskey(oppid)){
                OppamountUpdMap.get(oppid).PO_Receipt_Date__c=OppUpdMap.get(oppid).PO_Receipt_Date__c;
            }
            
            opptiesToUpdate.add(OppamountUpdMap.get(oppid));
        }
        
         Set<GE_LGT_EM_ErrorLog__c> errorLogList=new Set<GE_LGT_EM_ErrorLog__c>();
            Database.SaveResult[] srList = Database.update(opptiesToUpdate,False);
            //update opptiesToUpdate;
            for(Integer i=0;i<srList.size();i++)
            {
                if (srList.get(i).isSuccess()) 
                {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted account. Account ID: ' + srList.get(i).getId());
                }
                else
                {
                    // Operation failed, so get all errors into ErrorLog object                
                    for(Database.Error err : srList.get(i).getErrors()) 
                    {
                        GE_LGT_EM_ErrorLog__c errorLog=new GE_LGT_EM_ErrorLog__c();
                        errorLog.ID__c=opptiesToUpdate.get(i).ID;
                        errorLog.GE_LGT_EM_Object__c='Opportunity';
                        errorLog.GE_LGT_EM_IntegrationStatus__c='Order-Opportunity Updation Error';
                        errorLog.GE_LGT_EM_Description__c=err.getMessage();
                        errorLog.User__c=UserInfo.getUserId();
                        errorLogList.add(errorLog);
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                        //Below will display error message on screen. Exception-SAP Integration User
                        if(userinfo.getProfileId()!='00e31000001XT6nAAG'){
                           optyWithError.put(opptiesToUpdate.get(i).id,string.valueof(err.getMessage()));
                        
                        }
                    }
                }
            }
            System.debug('errorLogList:'+errorLogList);
            List<GE_LGT_EM_ErrorLog__c> errorLogListToInsert=new List<GE_LGT_EM_ErrorLog__c>();
            if(!errorLogList.isEmpty())
            {
                errorLogListToInsert.addAll(errorLogList);
                Database.insert(errorLogListToInsert,false);
            }
            if(!optyWithError.isempty()){
                for(Order ord:orderList){
                    if(optyWithError.containskey(ord.OpportunityId)){
                        ord.addError(optyWithError.get(ord.OpportunityId));
                    }
                }
            }
        }
    }
    //Helper method to roll up PO Date on Opty
     public static  Map<id,Opportunity> updatePoDateFromOrder (Set<Id> oppIdSet ) {
         
        ID estimatedOrderRecTypeID=Schema.SObjectType.Order.getRecordTypeInfosByName().get('Estimated PO').getRecordTypeId();
        ID receivedOrderRecTypeID=Schema.SObjectType.Order.getRecordTypeInfosByName().get('Received PO').getRecordTypeId();
        Map<id,Opportunity> OppUpdMap = new Map<id,Opportunity>();

      //  Map<id, Date> minOrderStartMap = new Map<id, Date>();
        Map<id, Date> maxOrderStartMap = new Map<id, Date>();
        Map<id, Date> maxZeroOrderStartMap = new Map<id, Date>();
        
         //AggregateResult[] orderAggList = [ SELECT  OpportunityId id, MAX(EffectiveDate) maxdate, MIN(EffectiveDate) mindate FROM Order WHERE OpportunityId!=NULL AND OpportunityId in :oppIdSet AND RecordTypeID=:estimatedOrderRecTypeID GROUP BY OpportunityId ];
                                               
         AggregateResult[] orderAggList =[SELECT  OpportunityId id, MAX(EffectiveDate) maxdate FROM Order WHERE OpportunityId!=NULL AND OpportunityId in :oppIdSet AND ((RecordTypeID=:receivedOrderRecTypeID AND TotalAmount>0 ) OR (RecordTypeID=:estimatedOrderRecTypeID AND Order_Amount__c>0.0)) GROUP BY OpportunityId] ;                                        
          
            for ( AggregateResult orderAgg : orderAggList ){
                //minOrderStartMap.put((Id)orderAgg.get('id'),(Date)orderAgg.get('mindate'));
                
                maxOrderStartMap.put((Id)orderAgg.get('id'),(Date)orderAgg.get('maxdate'));
            }
            Set<Id> Opp0AmtSet=new set<Id>(oppIdSet);
                    Opp0AmtSet.removeAll(maxOrderStartMap.Keyset());    
            if(Opp0AmtSet.size()>0){
             AggregateResult[] zeroOrderAggList =[SELECT  OpportunityId id, MAX(EffectiveDate) maxdate FROM Order WHERE OpportunityId!=NULL AND OpportunityId in :Opp0AmtSet AND ((RecordTypeID=:receivedOrderRecTypeID ) OR (RecordTypeID=:estimatedOrderRecTypeID)) GROUP BY OpportunityId] ;
             for ( AggregateResult orderAgg : zeroOrderAggList ){
                //minOrderStartMap.put((Id)orderAgg.get('id'),(Date)orderAgg.get('mindate'));
                
                maxOrderStartMap.put((Id)orderAgg.get('id'),(Date)orderAgg.get('maxdate'));
            }
             
            }       

            Opportunity[] oppList = [ SELECT Id,PO_Receipt_Date__c,Owner_Pole_Opp__c,Owner.ProfileID FROM Opportunity  WHERE Id in :oppIdSet ];

            for ( Opportunity opp : oppList ) {
                    Date newPOReceiptDate = maxOrderStartMap.get(opp.id) != null ? maxOrderStartMap.get(opp.id) : opp.PO_Receipt_Date__c ;
                    
                    if ( opp.PO_Receipt_Date__c != newPOReceiptDate ) {
                        opp.PO_Receipt_Date__c = newPOReceiptDate ;
                        OppUpdMap.put(opp.id,opp);
                    }
              }

            if ( !OppUpdMap.isempty() ){
                return OppUpdMap;
            }
            return OppUpdMap;
     }  
       //Helper method to roll up amounts on Opty 
    public static Map<Id,Opportunity> updateAmountsOpportunity(List<Order> orderList)
    {
        
            System.debug('BEFORE IF');
            UtilityClass currencyConverter=new UtilityClass();
            Set<ID> orderIDSet=new Set<ID>();
            Set<ID> oppamountIDSet=new Set<ID>();
           Map<id,Opportunity> OppUpdMap = new Map<id,Opportunity>();
            for(Order order:orderList)
            {
                if(order.OpportunityId!=NULL)
                {
                    oppamountIDSet.add(order.OpportunityId);
                    
                }
            }
            System.debug('BEFORE IF1');
            ID recoppTypeID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('StandardAdvance').getRecordTypeId();
            ID recoppStandardTypeID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
            ID DainTreeTypeID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Daintree').getRecordTypeId();
            ID DainTreeAdvanceTypeID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('DaintreeAdvance').getRecordTypeId();
            ID estimatedOrderRecTypeID=Schema.SObjectType.Order.getRecordTypeInfosByName().get('Estimated PO').getRecordTypeId();
            ID receivedPOOrderRecTypeID=Schema.SObjectType.Order.getRecordTypeInfosByName().get('Received PO').getRecordTypeId();
            ID IntelligentEnvironmentTypeID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Intelligent Environments').getRecordTypeId();
            ID IntelligentEnvironmentAdvID=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IntelligentEnvironmentAdvance').getRecordTypeId();
            System.debug('BEFORE IF2');
          
            List<Order> orderList1=[SELECT PO_Received_Formula__c,CurrencyIsoCode,EffectiveDate,Order_Amount__c,TotalAmount,RecordTypeid,opportunityid,Forecast__c,PO_Received__c FROM Order WHERE OpportunityID IN:oppamountIDSet];
            Map<ID,List<Order>> orderMap=new Map<ID,List<Order>>();
            for(Order order:orderList1)
            {
                if(!orderMap.containsKey(order.OpportunityId))
                {
                    List<Order> orders=new List<Order>();
                    orders.add(order);
                    orderMap.put(order.OpportunityId,orders);
                }
                else
                {
                    List<Order> orders= orderMap.get(order.OpportunityId);
                    orders.add(order);
                    orderMap.put(order.OpportunityId,orders);
                }
            }
            for(Opportunity opp:[SELECT ID,CurrencyIsoCode,Owner.ProfileID,RecordTypeID FROM Opportunity WHERE ID IN:oppamountIDSet ])
            
            {
                Decimal totalReceivedPO=0;
                Decimal totalEstimatedPO=0;
                List<Order> oppOrderList=orderMap.get(opp.ID);
                List<Date> orderStartdates=new List<Date>();
                if(oppOrderList!=NULL && !oppOrderList.isEmpty())
                {
                    Integer i=0;
                    Integer NumberOfTooEarly=0;
                    Integer NumberOfCommited=0;
                    for(Order order:oppOrderList)
                    {
                        if(order.RecordTypeID==estimatedOrderRecTypeID)
                        {
                            i++;                       
                            opp.Number_of_Orders__c=oppOrderList.size();
                            if(order.Forecast__c=='Too Early to Indicate') // Adding statistic for RQT-0001156
                            {
                            NumberOfTooEarly++;
                            }
                            if(order.Forecast__c=='Commitment' && (order.PO_Received_Formula__c==False && order.PO_Received__c==False) )
                            {
                            NumberOfCommited++;
                            }
                            opp.Number_of_EstOrders__c=i;
                            opp.Number_of_TooEarly__c=NumberOfTooEarly;
                            opp.Number_of_Commited__c=NumberOfCommited;
                         }
                    }
                    if(i>0)
                        opp.hasOrders__c=true;
                    else
                        opp.hasOrders__c=false;
               
                   if(( ( opp.RecordTypeID==recoppTypeID||opp.RecordTypeID==recoppStandardTypeID ||    
                           opp.RecordTypeID==IntelligentEnvironmentTypeID||opp.RecordTypeID==IntelligentEnvironmentAdvID ) ) ||
                      (opp.RecordTypeID==DainTreeTypeID||opp.RecordTypeID==DainTreeAdvanceTypeID)
                      )
                    {
                        for(Order order:oppOrderList)
                        {
                            if(order.PO_Received_Formula__c)
                            {
                                if(order.TotalAmount!=NULL && order.CurrencyIsoCode != opp.CurrencyIsoCode) 
                                    totalReceivedPO+=currencyConverter.convertCurrencyMethod(order.CurrencyIsoCode,opp.CurrencyIsoCode,order.TotalAmount,order.EffectiveDate);
                                 else if(order.TotalAmount!=NULL)
                                    totalReceivedPO+=order.TotalAmount;
                                if(order.Order_Amount__c!=NULL && order.CurrencyIsoCode != opp.CurrencyIsoCode)
                                    totalReceivedPO+=currencyConverter.convertCurrencyMethod(order.CurrencyIsoCode,opp.CurrencyIsoCode,order.Order_Amount__c,order.EffectiveDate);
                                else if(order.Order_Amount__c!=NULL)
                                    totalReceivedPO+=order.Order_Amount__c;
                            }
                            else {
                                if(order.Order_Amount__c!=NULL && order.CurrencyIsoCode != opp.CurrencyIsoCode) 
                                    totalEstimatedPO+=currencyConverter.convertCurrencyMethod(order.CurrencyIsoCode,opp.CurrencyIsoCode,order.Order_Amount__c);
                                else if(order.Order_Amount__c!=NULL)
                                    totalEstimatedPO+=order.Order_Amount__c;
                                if(order.EffectiveDate!=null)
                                    orderStartdates.add(order.EffectiveDate);
                            }
                        }
                        System.debug('BEFORE IF3');
                        opp.Total_Order_Amount__c=totalReceivedPO+totalEstimatedPO;
                        opp.Estimated_Orders_to_go__c=totalEstimatedPO;
                        opp.Total_Orders_Received_TD__c=totalReceivedPO;
                        System.debug('BEFORE IF4');
                        if(orderStartdates.size()!=0)
                        {
                            System.debug('orderStartdates:'+orderStartdates);
                            orderStartdates.sort(); 
                            System.debug('DATE:'+OrderStartdates[OrderStartdates.size()-1]);
                            opp.Closed_Date_Duplicate__c=OrderStartdates[OrderStartdates.size()-1];
                        }
                    }
             
                    /******** Added by Shyam - KAFZY-1996 & KAFZY-1998 - END   *********/
                    OppUpdMap.put(opp.id,opp);
                }
                else{
                    opp.hasOrders__c=false;
                    opp.Number_of_Orders__c=0;
                    opp.Total_Order_Amount__c=0;
                    opp.Estimated_Orders_to_go__c=0;
                    opp.Total_Orders_Received_TD__c=0;
                    OppUpdMap.put(opp.id,opp);
                }
            }
           
        return OppUpdMap;
    }   
}
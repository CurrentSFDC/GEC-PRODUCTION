/***********************************************************************************************
*   Class Name      : OpportunityRollUpHandler 
*   Date            : 
*   Author          : 
*   Object          : Opportunity
*   Purpose         : These methods fire on Opportunity.
*   Test Class      : OpportunityRollUpHandler_Test
**************************************************************************************************/
public without sharing class OpportunityRollUpHandler {
    
    //utility variable contain currency conversion rates
    public static UtilityClass carrancyConverter=new UtilityClass();
    
    //utility variable contain NA Profile ids getting from custom setting
    public static Map<String,NA_Profiles__c> profiles_NA = NA_Profiles__c.getAll();
    
    //getting all record types of Opportunity with name as key and value as ID
    public static Map<String,id> mapRecTypeNameID=OpportunityConstantClass.mapRecTypeNameID();
    
    
    //<==========================rollupOnAccount()==========================>// 
    
    /*
@Request No   ::
@Description  :: Updating Sum_of_all_Open_Op_Revenues__c,Sum_of_SAP_Orders_Received__c,Sum_of_Estimated_Orders_To_Go__c on Account based on 
Total_Orders_Received_TD__c,Estimated_Orders_to_go__c,Total_Order_Amount__c fields of Opportunity
@Author       ::
@Event        :: AfterInsert,AfterDelete
*/ 
    public static void rollupOnAccount(List<Opportunity> newOppList)
    {
        // Below List contain Account id of optys 
        set<Id> accIds=new set<Id>();
        
        for(Opportunity Opp:newOppList){
            System.debug('###Opp.AccountId:'+Opp.AccountId);
            if( Opp.AccountId != null){
                accIds.add(Opp.AccountId);
                
            }
        }
        System.debug('###accIds.size():'+accIds.size());
        if(accIds.size()>0)
        {
            if(System.isFuture() || System.isBatch())
            {
                AccountRollupHandler.setRollupsOnAccount(accIds);
            }
            else
            {
                AccountRollupHandler.setRollupsOnAccountFuture(accIds);//calling Future Helper method to calculate roll up summery
            }
        }
        
    }
    
    
    //<==========================rollupOnAccountAtOptyupdate()==========================>// 
    
    /*
@Request No   ::
@Description  :: Updating Sum_of_all_Open_Op_Revenues__c,Sum_of_SAP_Orders_Received__c,Sum_of_Estimated_Orders_To_Go__c on Account based on 
Total_Orders_Received_TD__c,Estimated_Orders_to_go__c,Total_Order_Amount__c fields of Opportunity
@Author       ::
@Event        :: After Update
*/ 
    public static void rollupOnAccountAtOptyupdate(List<Opportunity> newOppList,Map<id,Opportunity> oldOppMap)
    {
        // Below List contain Account id of optys which account of opty have changed
        Set<Id> accIds=new set<Id>();
        
        for(Opportunity Opp:newOppList){
            
            System.debug('###Opp.AccountId:'+Opp.AccountId);
            
            if( Opp.AccountId != null){
                //checking whether Account on Opty changed or Not
                if( Opp.AccountId != oldOppMap.get(Opp.id).AccountId){
                    System.debug('###1st if condition:');
                    accIds.add(Opp.AccountId);
                    accIds.add(oldOppMap.get(Opp.id).AccountId);
                }
                //if Account not changed either fields changed or not
                else if(oldOppMap.get(Opp.id).stagename!=Opp.stagename ||oldOppMap.get(Opp.id).Amount!=Opp.Amount||oldOppMap.get(Opp.id).Estimated_Orders_to_go__c!=Opp.Estimated_Orders_to_go__c||oldOppMap.get(Opp.id).Total_Orders_Received_TD__c!=Opp.Total_Orders_Received_TD__c)
                {
                    System.debug('###2nd if condition:');
                    accIds.add(Opp.AccountId);
                }               
                
            }
        }
        System.debug('###accIds.size():'+accIds.size());
        if(accIds.size()>0)
        {
            if(System.isFuture() || System.isBatch())
            {
                AccountRollupHandler.setRollupsOnAccount(accIds);
            }
            else
            {
                AccountRollupHandler.setRollupsOnAccountFuture(accIds);//calling Future Helper method to calculate roll up summery
            }
        }
        
    }
    
    //<==========================handlePortfolio()<==========================>// 
    
    /*
@Request No   ::
@Description  :: summary values for the fields on 'Portfolio' object : Portfolio Revenue,Closed Date,LED Revenue,EnergyStorageRevenue,
SolarEquipmentRevenue,CHP Revenue,EV Revenue,Intelligent Cities Revenue
@Author       ::
@support Class:: Opportunity_Portfolio_Handler
@Event        :: AfterInsert,AfterDelete,AfterUndelete

*/
    
    public static void handlePortfolio(List<Opportunity> OppList)
    {
        //below list contain Portfolio ids which need update from Opty
        Set<id> portfolioIds=new Set<id>();
        for(Opportunity opp:OppList){
            if(opp.Portfolio__c!=null)
                portfolioIds.add(opp.Portfolio__c);
        }
        System.debug('###portfolioIds.size() :'+portfolioIds.size());
        if(portfolioIds.size()>0)
            Opportunity_Portfolio_Handler.summaryFields(portfolioIds);// calling handler method to summarise the fields  
        
    }
    
    //<==========================handlePortfolioInUpdate()<==========================>// 
    
    /*
@Request No   ::
@Description  :: summary values for the fields on 'Portfolio' object : Portfolio Revenue,Closed Date,LED Revenue,EnergyStorageRevenue,
SolarEquipmentRevenue,CHP Revenue,EV Revenue,Intelligent Cities Revenue
@Author       ::
@support Class:: Opportunity_Portfolio_Handler
@Event        :: AfterUpdate
*/
    
    public static void handlePortfolioInUpdate(List<Opportunity> newOppList,Map<id,Opportunity> oldOppMap)
    {
        //below list contain Portfolio ids which need update from Opty
        Set<id> portfolioIds=new Set<id>();
        for(Opportunity opp:newOppList){
            if(opp.Portfolio__c!=null){
                System.debug('###opp.Portfolio__c :'+opp.Portfolio__c);
                //checking whether  Portfolio__c is changed or not
                if(oldOppMap.get(opp.id).Portfolio__c!=opp.Portfolio__c){
                    portfolioIds.add(opp.Portfolio__c);
                    portfolioIds.add(oldOppMap.get(opp.id).Portfolio__c);
                }
                //checking PO_Receipt_Date__c and Amount  is changed on Opty or not
                else if(oldOppMap.get(opp.id).PO_Receipt_Date__c!=opp.PO_Receipt_Date__c||oldOppMap.get(opp.id).amount!=opp.amount){
                    portfolioIds.add(opp.Portfolio__c);
                }
            }
        }
        System.debug('###portfolioIds.size() :'+portfolioIds.size());
        if(portfolioIds.size()>0)
            Opportunity_Portfolio_Handler.summaryFields(portfolioIds);// calling handler method to summarise the fields  
    }
    
    //<==========================accountUpdateOnOrder()==========================>// 
    
    /*
@Request No   ::
@Description  :: Updating account on Orders under Opty if account of Opty changed    
@Author       ::
@Event        :: After Update
*/ 
    public static void accountUpdateOnOrder(map<id,Opportunity> OptyNewMap,map<id,Opportunity> OptyOldMap){
        
        //below map contain key as Opty id and value as Account id 
        Map<id,id> optyidwithAccountids=new map<id,id>();
        
        for(Opportunity opp:OptyNewMap.values()){
            //checking whether Account on Opty changed or Not
            if(opp.accountid !=OptyOldMap.get(opp.id).accountid){
                optyidwithAccountids.put(opp.id,opp.accountid);
            }
            
        }
        System.debug('###optyidwithAccountids.isEmpty():'+!optyidwithAccountids.isEmpty());
        if(!optyidwithAccountids.isEmpty()){
            //below List contain Orders which need to update the Account id
            List<order> OrderToupdateList=new list<order>();
            //getting orders which are under Optys
            for(order ord: [select id,Accountid,Opportunityid from Order where opportunityid in:optyidwithAccountids.keyset()]){
                ord.accountid=optyidwithAccountids.get(ord.Opportunityid);
                OrderToupdateList.add(ord);
            }
            //updating orders with new Accounts
            System.debug('###OrderToupdateList.isEmpty():'+!OrderToupdateList.isEmpty());
            if(!OrderToupdateList.isEmpty())
                update OrderToupdateList;
        }
        
    }  
    
    
    
    //<==========================orderOwnerChangeIfOptyOwnerChange()==========================>// 
    /*
@Request No   :: KAFZY-2037
@Description  :: To update the order owner to match the opportunity owner 
@Author       ::
@Event        :: After Insert
*/ 
    public static void OrderOwnerChangeIfOptyOwnerChange(map<id,opportunity> newMapOptys,map<id,Opportunity> oldMapOptys){
        
        ID estimatedOrderRecTypeID=Schema.SObjectType.Order.getRecordTypeInfosByName().get('Estimated PO').getRecordTypeId();
        //list contain Optyids which have changed ownerid 
        Set<id> optyIds=new set<id>();
        //getting Opty ids which  owner of the opty will change
        for(id Oppid:newMapOptys.keyset()){
            if(newMapOptys.get(oppid).ownerid != oldMapOptys.get(oppid).ownerid){
                optyIds.add(Oppid);
            }
        }
        System.debug('###optyIds.size():'+optyIds.size());
        if(optyIds.size()>0){
            //list to update new orders with opty owner ids
            list<order> orderOwnerstoUpdate=new list<order>();
            //getting orders which need to change the Owners
            list<Order> optyOrders=[select id,ownerid,Opportunityid from Order where Opportunityid in:optyIds and recordtypeid=:estimatedOrderRecTypeID];
            if(optyOrders.size()>0){
                //if Order owner not equals to Opty owner changing as Opty Owner
                for(Order ord:optyOrders){
                    if(ord.ownerid != newMapOptys.get(ord.Opportunityid).ownerid){
                        
                        ord.ownerid=newMapOptys.get(ord.Opportunityid).ownerid;
                        
                        orderOwnerstoUpdate.add(ord);
                        
                    }
                }
                System.debug('###orderOwnerstoUpdate.size():'+orderOwnerstoUpdate.size());
                if(orderOwnerstoUpdate.size()>0){
                    //static variable to make false to should not execute OrderTriggerHelper.updateOpportunity method on order object
                    StaticvariablesForOrder.OrderOwnerChangeIfOptyOwnerChange=false;
                    update orderOwnerstoUpdate;
                }
                
            }
        }
    }
    
    
}
/*
Name - OrderTriggerHelper
Test Class - OrderTriggerHelper_Test
Author - Shyam Prasad Nayakula
Purpose - Helper class of OrderTrigger
Date - May-2016
*/
public class OrderTriggerHelper
{
    public static void updateOrderDetails(List<Order> orderList,Map<ID,Order> oldOrderHeaderMap)
    {
        system.debug('Inside class OrderTriggerHelper 1');
        Set<String> geOppIDs=new Set<String>();
        Set<String> sapAccNums=new Set<String>();
        set<String> sapSTZacctNums = new set<String>();
        set<String> sapAgentAcctNums = new set<String>();
        ID recvdPORecTypeID = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Received PO').getRecordTypeId();
        for(Order o:orderList) 
        {
            system.debug('Inside for loop class OrderTriggerHelper 2');
            if(o.GE_Opportunity_Id__c!=NULL)
                geOppIDs.add(o.GE_Opportunity_Id__c);
            if(o.SAP_Unique_Id__c!=NULL)
                sapAccNums.add(o.SAP_Unique_Id__c.subStringBeforeLast('-')+'%');
            if(o.Strategic_SAPUniqueId__c!=null)
                sapAccNums.add(o.Strategic_SAPUniqueId__c.subStringBeforeLast('-')+'%');
            if(o.Agent_SAPUniqueId__c!=null)
                sapAccNums.add(o.Agent_SAPUniqueId__c.subStringBeforeLast('-')+'%');           
            system.debug('Inside Agent logic class OrderTriggerHelper 3');
            
        }
        List<Opportunity> oppList=[SELECT ID,PriceBook2Id,GE_LGT_GE_Opportunity_Id__c FROM Opportunity WHERE GE_LGT_GE_Opportunity_Id__c IN:geOppIDs];
        List<Account> accList=[SELECT ID,GE_LGT_EM_SAPUniqueIdentifier__c,GE_LGT_EM_PF_Type__c,GE_LGT_EM_Division__c FROM Account WHERE GE_LGT_EM_SAPUniqueIdentifier__c LIKE:sapAccNums];
        Map<String,Opportunity> oppMap=new Map<String,Opportunity>();
        Map<String,Account> accMap=new Map<String,Account>();
        for(Opportunity o:oppList) 
        {
            oppMap.put(o.GE_LGT_GE_Opportunity_Id__c,o);
        }
        for(Account a:accList) 
        {
            accMap.put(a.GE_LGT_EM_SAPUniqueIdentifier__c,a);
            system.debug('SAP Identifier Test:: '+a.GE_LGT_EM_SAPUniqueIdentifier__c);
            
        }
        List<PriceBook2> pb=[SELECT ID FROM PriceBook2 WHERE Name='LED'];
        System.debug('Acc Map:'+accMap);
        set<String> mismatchCurr = new set<String>();
        for(Order o:orderList) 
        {
            try
            {
                o.status='Draft';
                if(o.GE_Opportunity_Id__c!=NULL && oppMap.containsKey(o.GE_Opportunity_Id__c)) 
                {
                    o.Pricebook2Id=oppMap.get(o.GE_Opportunity_Id__c).PriceBook2Id;
                    o.OpportunityId=oppMap.get(o.GE_Opportunity_Id__c).Id;
                    
                }
                else if(o.Pricebook2Id==NULL) 
                {
                    if(pb!=NULL)
                        o.Pricebook2Id=pb[0].ID;
                }
                if(oldOrderHeaderMap!=NULL && o.Pricebook2Id != oldOrderHeaderMap.get(o.ID).Pricebook2Id && o.RecordTypeId == recvdPORecTypeID)
                {
                    o.isPriceBookNotInSync__c=TRUE;
                    mismatchCurr.add(o.ID);
                }
                if(o.SAP_Unique_Id__c!=NULL && accMap.containsKey(o.SAP_Unique_Id__c)) 
                {
                    o.AccountId=accMap.get(o.SAP_Unique_Id__c).Id;
                    o.Sold_To__c=accMap.get(o.SAP_Unique_Id__c).Id;
                }
                if(o.Strategic_SAPUniqueId__c!=NULL && accMap.containsKey(o.Strategic_SAPUniqueId__c)) 
                {
                    o.Strategic_Account__c=accMap.get(o.Strategic_SAPUniqueId__c).Id;
                }
                else
                {
                    o.Strategic_Account__c=null;
                }
                if(o.Agent_SAPUniqueId__c!=NULL && accMap.containsKey(o.Agent_SAPUniqueId__c)) 
                {
                    o.Agent_Account__c=accMap.get(o.Agent_SAPUniqueId__c).Id;
                }
                else
                {
                    o.Agent_Account__c=null;
                }
                if(!mismatchCurr.isEmpty())
                {
                    List<string> SendToList = new List<string>();
                    SendToList.add('shyamprasad.nayakula@ge.com');
                    SendToList.add('neel.singh@ge.com');
                    String subject='Pricebook mismatch found!!';
                    String Body='Pricebook mismatch observed - details !!'+mismatchCurr;
                    
                }
            }
            catch(Exception e)
            {
                System.debug('IN Exception');
                GE_LGT_EM_ErrorLog__c newexc=new GE_LGT_EM_ErrorLog__c();
                newexc.GE_LGT_EM_Description__c=e.getMessage();
                insert newexc; 
            }
        }
    }
    public static void updateRecordTypeForSAPOrders(List<Order> orderList)
    {
        id recordTypeIDs = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Received PO').getRecordTypeId();
        
       
        if(recordTypeIDs!=NULL)
        {
            for(Order order:orderList)
            {
                if(order.SAP_Unique_Id__c!=NULL)
                {
                    order.RecordTypeId=recordTypeIDs;
                }
                
            }
        }
    }
    /*order owner must as opportunity owner for ticket NO:1953*/
    public static void updateRecordOwnerAsOptyOwner(List<Order> orderList)
    {
        Set<String> OppIDs=new Set<String>();
        Map<ID,Opportunity> oppMap;
        ID estimatedOrderRecTypeID=Schema.SObjectType.Order.getRecordTypeInfosByName().get('Estimated PO').getRecordTypeId();
        ID receivedPOOrderRecTypeID=Schema.SObjectType.Order.getRecordTypeInfosByName().get('Received PO').getRecordTypeId();
        for(Order order:orderList)
        {
            if(order.OpportunityID!=NULL)
                OppIDs.add(order.OpportunityID);
            
        }
        if(oppIDs.size()>0){
            oppMap=new Map<ID,Opportunity>([SELECT ID,ownerid,Accountid FROM Opportunity WHERE ID IN:oppIDs]);
            
            
            for(Order order:orderList)
            {
                if( oppMap.containsKey(order.OpportunityId) && order.recordtypeid !=null && order.recordtypeid==estimatedOrderRecTypeID && oppMap.get(order.OpportunityId).ownerid != order.ownerid){
                    order.ownerid = oppMap.get(order.OpportunityId).ownerid;    
                }
        if( order.OpportunityId!=null && order.recordtypeid !=null && order.recordtypeid==receivedPOOrderRecTypeID && oppMap.get(order.OpportunityId).Accountid != order.Accountid){
                    order.Accountid = oppMap.get(order.OpportunityId).Accountid;    
                }
            }
        }
    }
    public static void updateGEOppID(List<Order> orderList,Map<ID,Order> oldOrderMap)
    {
        Set<String> OppIDs=new Set<String>();
        Set<String> geOppIDs=new Set<String>();
        ID estimatedOrderRecTypeID=Schema.SObjectType.Order.getRecordTypeInfosByName().get('Estimated PO').getRecordTypeId();
        for(Order order:orderList)
        {
            if(order.OpportunityID!=NULL)
                OppIDs.add(order.OpportunityID);
            if(order.GE_Opportunity_Id__c!=NULL)
                geOppIDs.add(order.GE_Opportunity_Id__c);
        }
        Map<ID,Opportunity> oppMap=new Map<ID,Opportunity>([SELECT ID,GE_LGT_GE_Opportunity_Id__c,ownerid FROM Opportunity WHERE ID IN:oppIDs]);
        List<Opportunity> oppList=[SELECT ID,PriceBook2Id,GE_LGT_GE_Opportunity_Id__c FROM Opportunity WHERE GE_LGT_GE_Opportunity_Id__c IN:geOppIDs];
        Map<String,Opportunity> oppMapOnGEID=new Map<String,Opportunity>();
        for(Opportunity opp:oppList) 
        {
            oppMapOnGEID.put(opp.GE_LGT_GE_Opportunity_Id__c,opp);
        }
        for(Order order:orderList)
        {
            if(oppMap!=NULL && oppMap.containsKey(order.OpportunityId) && (order.OpportunityId!=oldOrderMap.get(order.ID).OpportunityId || oldOrderMap.get(order.ID).GE_Opportunity_Id__c==NULL) )
            {
                order.GE_Opportunity_Id__c=oppMap.get(order.OpportunityId).GE_LGT_GE_Opportunity_Id__c;
                
            }
            else if(oppMapOnGEID!=NULL && !oppMapOnGEID.containsKey(order.GE_Opportunity_Id__c) && order.OpportunityID!=NULL)
            {
                order.GE_Opportunity_Id__c=oldOrderMap.get(order.ID).GE_Opportunity_Id__c;
            }
            /*order owner must as opportunity owner for ticket NO:1953*/
            if( oppMap.containsKey(order.OpportunityId) && order.recordtypeid !=null && order.recordtypeid==estimatedOrderRecTypeID && oppMap.get(order.OpportunityId).ownerid != order.ownerid){
                order.ownerid = oppMap.get(order.OpportunityId).ownerid;
            }
        }
    }
    
    //For ticket No:KAFZY-1851
    //Need update Po-reciecved Estiamted oreders to Forecast as Commitment
    public static void POrecievedEstiamtedorderstoCommit(List<Order> orderList)
    {
        ID estimatedOrderRecTypeID=Schema.SObjectType.Order.getRecordTypeInfosByName().get('Estimated PO').getRecordTypeId();
        for(Order order:orderList)
        {
            if(order.RecordTypeid !=null)
                if(order.RecordTypeid==estimatedOrderRecTypeID && order.PO_Received__c==true){
                    order.Forecast__c='Commitment';
                }
            
        }
    }
    
    //***********************Method will check for cuurency miss match on order,if true then flag will be set to true (KAFZY-1900)***************/
    public static void checkCurrencyMismatch(List<Order> orderHeaderList,Map<ID,Order> oldOrderHeaderMap)
    {
        system.debug('Curerncy mismatch started:::');
        id recTypeRecvdPOiDs = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Received PO').getRecordTypeId();
        Set<String> CurrencyCodes=new Set<String>();
        set<String> mismatchCurr = new set<String>();
        
        for(Order orderVar : orderHeaderList)
        {
           
            if(orderVar.currencyISOCode!=oldOrderHeaderMap.get(orderVar.id).currencyISOCode && orderVar.RecordTypeId==recTypeRecvdPOiDs)
            {
                system.debug('Currency mismatch exists ::::');
               
                //Delete Order using future method,and also send email to Neel/Shyam/Justin
                mismatchCurr.add(orderVar.id);
                orderVar.SAP_New_Currency__c=orderVar.currencyISOCode;
                orderVar.SAP_Currency_Mismatch__c =true;
                if(orderVar.RecordTypeId==recTypeRecvdPOiDs)
                    orderVar.currencyISOCode=oldOrderHeaderMap.get(orderVar.id).currencyISOCode;
                system.debug('Currency new value::::::: '+orderVar.currencyISOCode);
            }
        }
        if(!mismatchCurr.isEmpty())
        {
            List<string> SendToList = new List<string>();
            SendToList.add('shyamprasad.nayakula@ge.com');
            SendToList.add('neel.singh@ge.com');
            String subject='Order currency mismatch found!!';
            String Body='Order currency mismatch observed - details !!'+mismatchCurr;
            //GE_LGT_MailerUtils.sendEmailNotification(subject,Body,SendToList);
        }
    }
    public static void checkOrderIdSetOnCase(List<Order> newOrders){
        List<Order> affectedOrders = new List<Order>();
        for (Order o : newOrders){
            if (o.RelatedCaseId__c != null) {
                affectedOrders.add(o);
            }
        }
        if (!affectedOrders.isEmpty()) {
            BatchableSetOrderNoOnCase b = new BatchableSetOrderNoOnCase(affectedOrders);
            Database.executeBatch(b);
        }
    }
}
global class Optyupdation implements Database.Batchable<SObject>
{
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        
        
        return Database.getQueryLocator([SELECT ID,createddate,PO_Receipt_Date__c,closedate,True_Stage__c,GE_LGT_Closed_Status_Date__c FROM opportunity]);   
    }
    global void execute(Database.BatchableContext bc,List<opportunity> Scope)
    {
        system.debug('Scope:'+Scope.size());
        set<id> oppSet = new Set<id>();
        Map<id, Date> maxOrderStartMap = new Map<id, Date>();
        list<opportunity> updationlist=new list<opportunity>();
        ID estimatedOrderTypeID=Schema.SObjectType.Order.getRecordTypeInfosByName().get('Estimated PO').getRecordTypeId();
        date stndardDate  = Date.newInstance(2013, 01, 30);
        for(opportunity OPP:Scope){
            if(Opp.createddate>=stndardDate)
                oppSet.add(OPP.id);
        }
        if(oppSet.size()>0){
            AggregateResult[] orderAggList = [ SELECT  OpportunityId id, MAX(EffectiveDate) maxdate FROM Order WHERE OpportunityId!=NULL AND OpportunityId in :oppSet AND RecordTypeID=:estimatedOrderTypeID GROUP BY OpportunityId ];
            for ( AggregateResult orderAgg : orderAggList ){
                
                maxOrderStartMap.put((Id)orderAgg.get('id'),(Date)orderAgg.get('maxdate'));
            }
        }
        for(opportunity OPP:Scope){
            if(Opp.createddate>=stndardDate && maxOrderStartMap.containskey(opp.id)){
                opp.PO_Receipt_Date__c=maxOrderStartMap.get(opp.id);
            }
            else{
                opp.PO_Receipt_Date__c=opp.closedate;
            }
            if(opp.GE_LGT_Closed_Status_Date__c !=null &&(opp.True_Stage__c == 'Closed Won' ||  opp.True_Stage__c == 'Closed Lost')){
                opp.closedate=opp.GE_LGT_Closed_Status_Date__c;
                 system.debug('closedate:'+opp.closedate);
                
            }
            
            updationlist.add(opp);
            system.debug('opppty:'+opp);
            
        }
        update updationlist;
        
    }
    global void finish(Database.BatchableContext bc)
    {
        
    }
}
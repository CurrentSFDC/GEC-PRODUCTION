global class GE_LGT_EM_UnfollowRecords implements Database.Batchable<SObject>
{
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
       return Database.getQueryLocator([Select ID,ParentId FROM EntitySubscription]); 
    }
    global void execute(Database.BatchableContext bc,List<EntitySubscription> esList)
    {
        List<ID> toBeDelted=new List<ID>();
        Map<ID,ID> entSubMap=new Map<ID,ID>();
        for(EntitySubscription es:esList)
        {
            if(String.valueOf(es.parentId).contains('006'))
            {
                entSubMap.put(es.ParentId, es.ID);
            }
        }
        List<Opportunity> oppList=[SELECT ID,StageName,PO_Receipt_Date__c,GE_LGT_Expected_PO_Receipt_Date__c,Last_Ship_Date__c  
                                   FROM Opportunity WHERE ID IN:entSubMap.keySet()];
        for(Opportunity opp:oppList)
        {
            if(opp.StageName!=NULL)
            {
                if(opp.StageName=='PO Received'&&opp.Last_Ship_Date__c!=NULL&&opp.Last_Ship_Date__c<Date.today())
                {
                    toBeDelted.add(entSubMap.get(opp.Id));
                }
                else if(opp.StageName=='Closed Lost')
                {
                    Date tempDate;
                    if(opp.PO_Receipt_Date__c!=NULL && opp.GE_LGT_Expected_PO_Receipt_Date__c!=NULL && opp.PO_Receipt_Date__c > opp.GE_LGT_Expected_PO_Receipt_Date__c)
                    {
                        tempDate = opp.PO_Receipt_Date__c;
                    }
                    else if(opp.GE_LGT_Expected_PO_Receipt_Date__c!=NULL)
                    {
                        tempDate = opp.GE_LGT_Expected_PO_Receipt_Date__c;
                    }
                    if(tempDate!=NULL && tempDate+90 < Date.today())
                    {
                        toBeDelted.add(entSubMap.get(opp.Id));
                        tempDate=NULL;
                    }
                }
            }
        }
        Database.delete(toBeDelted);
    }
    global void finish(Database.BatchableContext bc)
    {
        
    }

}
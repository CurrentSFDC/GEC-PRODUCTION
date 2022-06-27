/***********************************************************************************************
*   Class Name      : OptyLineItemTriggerHelper 
*   Date            : 
*   Author          : 
*   Object          : OpportunityLineItem
*   Purpose         : These methods fire on OpportunityLineItem.
*   Test Class      : GE_LGT_EM_OppProductHistory_Test
**************************************************************************************************/
public class OptyLineItemTriggerHelper {
    
    public static Map<String,id> mapRecTypeNameID=OpportunityConstantClass.mapRecTypeNameID();
    
    /*
@Request No   ::
@Description  ::Updating service date and checking validation for Stanadrd Opty line items
@Author       ::
@Event        :: BeforeInsert,BeforeUpdate
*/ 
    
    public static void populateServicedate(List<OpportunityLineItem> newLineItems)
    {
        //Opty ids of from line items
        Set<ID> oppIDs = new Set<ID>();
        for(OpportunityLineItem oppLine:newLineItems){
            oppIDs.add(oppLine.OpportunityID);
        }
        //geting NA Profiles
        Map<String,NA_Profiles__c> profiles_NA = NA_Profiles__c.getAll();
        //querying opty fileds 
        Map<id,Opportunity> mapOppty = New Map<id,Opportunity>([SELECT ID, RecordTypeId, owner.profileid,StageName,PO_Receipt_Date__c, GE_LGT_Expected_PO_Receipt_Date__c, GE_LGT_Expected_Ship_Date__c, hasSchedule__c FROM OPPORTUNITY WHERE ID IN :oppIDs]);
        //getting Opty recordtype ids
        Id recOppTypeOPS_ID = mapRecTypeNameID.get(OpportunityConstantClass.OPS_ADV);
        Id recOppTypeEV_ID = mapRecTypeNameID.get(OpportunityConstantClass.EV_ADV);
        
        // Id recOppTypeSOLAR_ID = mapRecTypeNameID.get(OpportunityConstantClass.SOLAR_ADV); --> COMMENTED OUT BY MG: RQT-1023
        
        Id recOppTypeSTORAGE_ID = mapRecTypeNameID.get(OpportunityConstantClass.ENERGY_ADV);
        
        Id recoppType_StandardID = mapRecTypeNameID.get(OpportunityConstantClass.STANDARD_ADV);
        
        for ( OpportunityLineItem opptyItem : newLineItems ){
            if ( mapOppty.get(opptyItem.OpportunityID).RecordTypeId == recOppTypeOPS_ID || 
                /*mapOppty.get(opptyItem.OpportunityID).RecordTypeId == recOppTypeSOLAR_ID ||*/ //--> COMMENTED OUT BY MG: RQT-1023 
                mapOppty.get(opptyItem.OpportunityID).RecordTypeId == recOppTypeSTORAGE_ID || 
                mapOppty.get(opptyItem.OpportunityID).RecordTypeId == recOppTypeEV_ID ){
                    //assigning PO_Receipt_Date__c to the service date
                    opptyItem.ServiceDate = mapOppty.get(opptyItem.OpportunityID).PO_Receipt_Date__c+1;
                }
            
            
        }
    }

}
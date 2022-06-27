/***********************************************************************************************
*   Class Name      : Opportunity_PriceBook_Handler 
*   Date            : 
*   Author          :
*   Description     : This class will map the pricebook to the Opportunity based up on the record type
*   Object          : Opportunity
*   Purpose         : This is support class of OpportunityTriggerHelper.
*   Test Class      :OpportunityTriggerHelper_Test
**************************************************************************************************/

public class Opportunity_PriceBook_Handler
{
    //Reusable method in Both update and Insertion of Optys to set PriceBookid
    public static void setPriceBook(list<Opportunity> newOppList)
    {
        //getting all record types of Opportunity with name as key and value as ID
        map<String,id> mapRecTypeNameID=OpportunityTriggerHelper.mapRecTypeNameID;
        //getting All price books in to the MAP  
        Map<String,Id> mapPB1 =OpportunityConstantClass.returnPricebookNameIdMap();
        for(Opportunity opp:newOppList){
            System.debug('###opp.RecordTypeId:'+opp.RecordTypeId);
            
            //for Daintree RecordType Opportunities adding price book as standard for ticket:1986
            if( opp.RecordTypeId==mapRecTypeNameID.get(OpportunityConstantClass.STANDARD) || opp.RecordTypeId==mapRecTypeNameID.get(OpportunityConstantClass.STANDARD_ADV) || opp.RecordTypeId==mapRecTypeNameID.get(OpportunityConstantClass.INTELLIGENT) ||  opp.RecordTypeId==mapRecTypeNameID.get(OpportunityConstantClass.INTELLIGENT_ADV) ||opp.RecordTypeId==mapRecTypeNameID.get(OpportunityConstantClass.DAINTREE)||opp.RecordTypeId==mapRecTypeNameID.get(OpportunityConstantClass.DAINTREE_ADV) || opp.RecordTypeId==mapRecTypeNameID.get(OpportunityConstantClass.DAINTREE_RENEWALS)){
                opp.PriceBook2Id = mapPB1.get('LED');
            }
            if(opp.RecordTypeId==mapRecTypeNameID.get(OpportunityConstantClass.EV) || opp.RecordTypeId==mapRecTypeNameID.get(OpportunityConstantClass.EV_ADV)){
                opp.PriceBook2Id = mapPB1.get('EV');
            }
            if(opp.RecordTypeId==mapRecTypeNameID.get(OpportunityConstantClass.OPS) || opp.RecordTypeId==mapRecTypeNameID.get(OpportunityConstantClass.OPS_ADV)){
                opp.PriceBook2Id = mapPB1.get('OPS');
            }
            if(opp.RecordTypeId==mapRecTypeNameID.get(OpportunityConstantClass.ENERGY) || opp.RecordTypeId==mapRecTypeNameID.get(OpportunityConstantClass.ENERGY_ADV)){
                opp.PriceBook2Id = mapPB1.get('Storage');
            }
            /*if(opp.RecordTypeId==mapRecTypeNameID.get(OpportunityConstantClass.SOLAR) || opp.RecordTypeId==mapRecTypeNameID.get(OpportunityConstantClass.SOLAR_ADV)){
                opp.PriceBook2Id = mapPB1.get('Solar');
            }*/ //--> COMMENTED OUT BY MG: RQT-1023
            System.debug('###opp.PriceBook2Id :'+opp.PriceBook2Id);
        }
    }
}
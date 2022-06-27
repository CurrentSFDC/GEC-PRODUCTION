/***********************************************************************************************
*   Class Name      : Opportunity_Portfolio_Handler 
*   Date            : 
*   Author          :
*   Description     : This class provides the summary values for the fields on 'Portfolio' object : Portfolio Revenue,Closed Date,LED Revenue,Energy
                      StorageRevenue,Solar Equipment Revenue,CHP Revenue,EV Revenue,Intelligent Cities Revenue on the porfolio object.
*   Object          : Opportunity
*   Purpose         : This is support class of OpportunityTriggerHelper.
*   Test Class      :Opportunity_Portfolio_Handler_Test
**************************************************************************************************/

public class Opportunity_Portfolio_Handler
{
    public static void summaryFields(set<id> PortfolioIds)
    {
         //getting all record types of Opportunity with name as key and value as ID
        map<String,id> mapRecTypeNameID=OpportunityTriggerHelper.mapRecTypeNameID;
        //getting all Portfolio records which have Optys
        list<Portfolio__c> portfolio_List=[select id,Portfolio_Revenue__c,Closed_Date__c,CHP_Revenue__c,
                                           Energy_Storage_Revenue__c,EV_Revenue__c,Intelligent_Cities_Revenue__c,
                                           LED_Revenue__c,Solar_Equipment_Revenue__c,
                                           (select id,amount,PO_Receipt_Date__c,RecordTypeId from opportunities__r )
                                           from Portfolio__c 
                                           where id in:PortfolioIds];
        
        list<Date> poDates = new list<Date>();
        for(Portfolio__c port : portfolio_List) 
        {
            decimal revenue=0;
            decimal led_Rev1=0;
            decimal energy_Rev2=0;
            //decimal solar_Rev3=0; - RQT-1023: MG
            decimal ops_Rev4=0;
            decimal ev_Rev5=0;
            decimal intelligent_Rev6=0;
            if (!port.opportunities__r.isEmpty()){
                for(Opportunity op : port.opportunities__r){//iterating Optys under Portfolio
                    System.debug('###op.PO_Receipt_Date__c:'+op.PO_Receipt_Date__c);
                    if( op.PO_Receipt_Date__c != null)
                    {
                        poDates.add(op.PO_Receipt_Date__c);
                    } 
                    System.debug('###op.amount:'+op.amount);
                    if(op.amount != null)
                    {
                        revenue=revenue+op.amount;
                        System.debug('###revenue:'+revenue);
                        
                        //checking Record type if Standard,StandardAdvance
                        if(op.RecordTypeId == mapRecTypeNameID.get(OpportunityConstantClass.STANDARD) || op.RecordTypeId == mapRecTypeNameID.get(OpportunityConstantClass.STANDARD_ADV) )
                        {
                            led_Rev1=led_Rev1+op.amount; 
                            System.debug('###led_Rev1:'+led_Rev1);
                        }
                        //checking Record type if Energy Storage ,EnergyStorageAdvance
                        else if(op.RecordTypeId == mapRecTypeNameID.get(OpportunityConstantClass.ENERGY) || op.RecordTypeId == mapRecTypeNameID.get(OpportunityConstantClass.ENERGY_ADV) )
                        {
                            energy_Rev2=energy_Rev2+op.amount; 
                            System.debug('###energy_Rev2:'+energy_Rev2);
                        }
                        //checking Record type if Solar Equipment ,SolarEquipmentAdvance - BLOCK COMMENT BY MG --> RQT-1023
                       /*else if(op.RecordTypeId == mapRecTypeNameID.get(OpportunityConstantClass.SOLAR) || op.RecordTypeId == mapRecTypeNameID.get(OpportunityConstantClass.SOLAR_ADV) )
                        {
                            solar_Rev3=solar_Rev3+op.amount; 
                            System.debug('###solar_Rev3:'+solar_Rev3);
                        }*/ 
                        //checking Record type if OPS ,OPSAdvance
                        else if(op.RecordTypeId == mapRecTypeNameID.get(OpportunityConstantClass.OPS) || op.RecordTypeId == mapRecTypeNameID.get(OpportunityConstantClass.OPS_ADV) )
                        {
                            ops_Rev4=ops_Rev4+op.amount;
                            System.debug('###ops_Rev4:'+ops_Rev4);                          
                        }
                        //checking Record type if EV ,EVAdvance
                        else if(op.RecordTypeId == mapRecTypeNameID.get(OpportunityConstantClass.EV) || op.RecordTypeId == mapRecTypeNameID.get(OpportunityConstantClass.EV_ADV) )
                        {
                            ev_Rev5=ev_Rev5+op.amount; 
                            System.debug('###ev_Rev5:'+ev_Rev5);    
                        }
                        //checking Record type if 'Intelligent Environments' ,IntelligentEnvironmentAdvance
                        else if(op.RecordTypeId == mapRecTypeNameID.get(OpportunityConstantClass.INTELLIGENT) || op.RecordTypeId == mapRecTypeNameID.get(OpportunityConstantClass.INTELLIGENT_ADV) )
                        {
                            intelligent_Rev6=intelligent_Rev6+op.amount; 
                            System.debug('###intelligent_Rev6:'+intelligent_Rev6);
                        }
                    }
                    
                }//end of 2nd for loop
            }
            port.Portfolio_Revenue__c=revenue; 
            port.LED_Revenue__c =led_Rev1;
            port.Energy_Storage_Revenue__c=energy_Rev2;
            //port.Solar_Equipment_Revenue__c=solar_Rev3;
            port.CHP_Revenue__c=ops_Rev4;
            port.EV_Revenue__c=ev_Rev5;
            port.Intelligent_Cities_Revenue__c=intelligent_Rev6;
            if(poDates.size()>0){
                poDates.sort();
                //Updating latest date of PO date of Optys to the closed date of Portfolio
                port.Closed_Date__c =poDates.get(poDates.size()-1);
            }   
            poDates.clear();            
        }//end 1st for loop 
        
        //updating Portfolio records
        update portfolio_List;      
        
    }
    
}
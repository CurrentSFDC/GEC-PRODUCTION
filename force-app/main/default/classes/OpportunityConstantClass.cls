/*
@Class        :: OpportunityConstantClass
@Description  :: In this class all contsats which are related to Opportunity will define here
@Author       ::
@Note         :: This is support class of OpportunityTriggerHelper 

*/
public class OpportunityConstantClass {
    //defining all record types as final varibles
    Public static final string STANDARD    ='Standard';
    Public static final string STANDARD_ADV='StandardAdvance';
    Public static final string DAINTREE='Daintree';
    Public static final string DAINTREE_ADV='DaintreeAdvance';
    Public static final string EV='EV';
    Public static final string EV_ADV='EVAdvance';
    Public static final string ENERGY='Energy Storage';
    Public static final string ENERGY_ADV='EnergyStorageAdvance';
    Public static final string INTELLIGENT='Intelligent Environments';
    Public static final string INTELLIGENT_ADV='IntelligentEnvironmentAdvance';
    Public static final string OPS='OPS';
    Public static final string OPS_ADV='OPSAdvance';
    Public static final string DAINTREE_RENEWALS='Daintree Renewals';
    //Public static final string SOLAR='Solar Equipment'; --> COMMENTED OUT BY MG: RQT-1023
    //Public static final string SOLAR_ADV='SolarEquipmentAdvance'; --> COMMENTED OUT BY MG: RQT-1023
    Public static final string STANDARD_FLOW='Standard-Flow';
    
    Public Static map<String,id> mapRecTypeNameID(){
        Map<String,Id> map_RecType1 = new Map<String,Id>();
        Map<Id,Schema.RecordTypeInfo> recTypemap = Opportunity.sObjectType.getDescribe().getRecordTypeInfosById();
        for(id rectype : recTypemap.keyset()){
            map_RecType1.put(recTypemap.get(rectype).getName(),rectype);
        }
        return map_RecType1;
    }
    Public Static map<String,id> returnPricebookNameIdMap(){
        List<Pricebook2> customPBL1 =  [select id,Name from Pricebook2 where IsActive = TRUE];
        Map<String,Id> mapPB1 = new Map<String,Id>();
        for(Pricebook2 pb2 : customPBL1 ){
            mapPB1.put(pb2.Name, pb2.Id);
        }
        return mapPB1;
    }
}
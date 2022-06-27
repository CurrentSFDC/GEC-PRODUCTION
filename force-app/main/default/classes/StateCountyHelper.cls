public class StateCountyHelper {
    private List<String> atoMStates;
    private List<String> ntoZStates;
    private List<StateCounty__c> sPCListAtoM;
    private List<StateCounty__c> sPCListNtoZ;
    public List<String> stateCodeList;
    public map<String,List<String>> sPCMap;
    
    public StateCountyHelper(){
        init();
    }
    
    private void init(){
        atoMstates = new List<String>{'AB','AL','AK','AZ','AR','AS','AZ','BC','CA','CO','CT','DC','DE',
            'FL','GA','GU','HI','ID','IL','IN','IA','KS','KY',
            'LA','MB','ME','MD','MA','MI','MN','MS','MO','MT','MP','MS'};
                ntoZStates = new List<String>{'NB','NE','NV','NH','NJ','NM','NY','NC','ND','NS','NT','NU',
                    'OH','OK','ON','OR','PA','PE','PR','QC','RI','SC','SD','SK','TN',
                    'TX','UT','VT','VI','VA','WA','WV','WI','WY','YT'};
                        atoMStates.sort();
        ntoZStates.sort();                             
        sPCListAtoM = new List<StateCounty__c>();
        sPCListNtoZ = new List<StateCounty__c>();
        sPCMap = new map<String,List<String>>();
        getAllCounties();
        allStates();
    } 
    
    private void getAllCounties(){
        sPCListAtoM = [Select State_Province_Code__c,County__c from StateCounty__c 
                       where State_Province_Code__c IN: atoMstates];
        sPCListNtoZ = [Select State_Province_Code__c,County__c from StateCounty__c 
                       where State_Province_Code__c IN: ntoZStates];
        for(String state:atoMstates ){
            List<String> counties = new List<String>();
            for(StateCounty__c spc: sPCListAtoM){
                if(state.equals(spc.State_Province_Code__c)){
                    counties.add(spc.County__c);
                }
            }
            sPCMap.put(state,counties);
        }
        for(String state:ntoZstates ){
            List<String> counties = new List<String>();
            for(StateCounty__c spc: sPCListNtoZ){
                if(state.equals(spc.State_Province_Code__c)){
                    counties.add(spc.County__c);
                }
            }
            sPCMap.put(state,counties);
        }
        
        
        
    } 
    private void allStates(){
        stateCodeList = new List<String>();
        for(AggregateResult spcc: [Select State_Province_Code__c from StateCounty__c 
                                   Group By State_Province_Code__c]){
                                       stateCodeList.add(spcc.get('State_Province_Code__c')+'');
                                   }
    }
    public map<String,List<String>> getStateCounties(){
        return sPCMap;
    }
    public List<String> getAllStateCode(){
        return stateCodeList;
    }
}
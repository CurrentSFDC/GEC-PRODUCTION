public class StateCountyControllerforDistributor {
    
    
    Set<String> originalvalues = new Set<String>();
    public String state {get;set;}
    public Boolean isState {get;set;}
    public String isAllCounties {get;set;}
    public List<String> leftselected{get;set;}
    public List<String> rightselected{get;set;}
    public Set<String> leftvalues = new Set<String>();
    public Set<String> rightvalues = new Set<String>();
    public Boolean showAddNew {get;set;}
    public Boolean showStateCountyItems {get;set;}
    public Boolean showState1 {get;set;}
    public Boolean showState2 {get;set;}
    public Boolean showState3 {get;set;}
    public Boolean showState4 {get;set;}
    public String comment {get;set;}
    public List<String> isAllCountiesList;
    public List<String> stateCodeList;
    public static String CoversEntireState = 'Covers Entire State';
    
    public String stateNumber {get;set;}
    
    public Boolean edit;
    
    public Distributor__c agent {get;set;}
    
    StateCountyHelper spch;
    
    ApexPages.StandardController stdCrtl;
    
    public StateCountyControllerforDistributor (ApexPages.StandardController crtl){
        isState = true;
        spch = new StateCountyHelper();
        agent = new Distributor__c();
        leftselected = new List<String>();
        rightselected = new List<String>();
        isAllCountiesList = new List<String>();
        stateCodeList = new List<String>();
        leftvalues.addAll(spch.getStateCounties().get('AB'));
        showAddNew = false;
        showState1 = false;
        showState2 = false;
        showState3 = false;
        showState4 = false;
        edit = false;
        showStateCountyItems = true;
        isAllCountiesList.add('--None--');
        isAllCountiesList.add('Yes');
        isAllCountiesList.add('No');
        this.stdCrtl = crtl;
        init();    
    }
    
    
    public void init(){
        agent = [Select State_Province_1__c, Counties_State_1__c,Comment_State_1__c from Distributor__c where Id=:stdCrtl .getId() LIMIT 1];
        
        if((agent.State_Province_1__c != null && agent.Counties_State_1__c != null))
            showState1 = true;
        else
            showState1 = false;
        
    }
    
    public List<SelectOption> getStateCodes(){
        List<SelectOption> options = new List<SelectOption>();
        
        stateCodeList = spch.getAllStateCode();
        for(String stateCodesHolder: stateCodeList ){
            options.add(new SelectOption(stateCodesHolder,stateCodesHolder));
        }
        return options;
    }
    
    public List<SelectOption> getIsAllCountiesSelect(){
        List<SelectOption> options = new List<SelectOption>();
        for(String opt: isAllCountiesList){
            options.add((new SelectOption(opt,opt)));
        }
        return options;
    }
    
    //use similar for showing selected in edit
    public PageReference selectclick(){
        rightselected.clear();
        for(String s : leftselected){
            leftvalues.remove(s);
            rightvalues.add(s);
        }
        return null;
    }
    
    public PageReference unselectclick(){
        leftselected.clear();
        for(String s : rightselected){
            rightvalues.remove(s);
            leftvalues.add(s);
        }
        return null;
    }
    
    public List<SelectOption> getCountyCodes(){
        List<SelectOption> options = new List<SelectOption>();
        for(String countyCodesHolder: leftselected){
            options.add(new SelectOption(countyCodesHolder,countyCodesHolder));
        }
        return options;
    }
    
    public PageReference selectedState(){
        
        leftvalues.clear();
        leftvalues.addAll(spch.getStateCounties().get(state));
        rightvalues.clear();
        isState = true;
        return null;
    }
    
    public PageReference selectedCounties(){
        
        return null;
    }
    
    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }
    
    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightvalues);
        tempList.sort();
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;
    }
    
    
    
    public PageReference selectAllValues(){
        if(isAllCounties.equals('Yes')){
            List<SelectOption> options1 = new List<SelectOption>();
            List<string> tempList = new List<String>();
            rightselected.clear();
            tempList.addAll(spch.getStateCounties().get(state));
            for(String s : tempList){
                rightvalues.add(s);
                leftvalues.remove(s);
            }
        }
        else if(isAllCounties.equals('No')){
            List<SelectOption> options1 = new List<SelectOption>();
            List<string> tempList = new List<String>();
            leftselected.clear();
            tempList.addAll(spch.getStateCounties().get(state));
            for(String s : tempList){
                leftvalues.add(s);
                rightvalues.remove(s);
            }
        }
        return null;
    }
    
    public PageReference saveStateAndCounties(){
        if(rightvalues.size()>0){
            if(edit == false){
                if((agent.State_Province_1__c == null && agent.Counties_State_1__c == null)){
                    agent.State_Province_1__c = state;
                    String counties = '';
                    if(isAllCounties.equals('Yes')){
                        agent.Counties_State_1__c = CoversEntireState ;
                    }
                    else{
                        
                        for(String str: rightvalues){
                            if(counties.equals('')){
                                counties = str;
                            }
                            else{
                                counties = counties + ' ; ' + str;               
                                System.debug('############### Right Selected Value: '+str);
                            }
                        } 
                        
                        agent.Counties_State_1__c = counties;                                    
                    }                                                   
                    agent.Comment_State_1__c = comment;                
                }              
                
                
            }
            if(edit == true){
                if(stateNumber.equals('1')){
                    agent.State_Province_1__c = state;
                    String counties = '';
                    
                    for(String str: rightvalues){
                        if(counties.equals('')){
                            counties = str;
                        }
                        else 
                            counties = counties + ' ; ' + str;               
                        //System.debug('############### Right Selected Value: '+str);
                    }
                    if(isAllCounties.equals('Yes')){
                        agent.Counties_State_1__c = CoversEntireState;
                    }
                    else{
                        agent.Counties_State_1__c= counties;
                    }
                    agent.Comment_State_1__c = comment;
                }              
                
                edit=false;
            }
            showAddNew = false;
            showStateCountyItems = true;
            update agent;
            
        }
        init();
        return null;
    }
    
    public PageReference deleteState(){
        Distributor__c upAgent;
        if(stateNumber.equals('1')){
            upAgent= [Select State_Province_1__c, Counties_State_1__c from Distributor__c where Id=:stdCrtl.getId() LIMIT 1];
            upAgent.State_Province_1__c = ''; 
            upAgent.Counties_State_1__c = '';
            agent.Comment_State_1__c = '';
        }
        
        
        try{
            update upAgent;
        }
        catch(Exception e){}
        init();
        return null;
    }
    
    public PageReference editState(){
        
        agent = [Select State_Province_1__c, Counties_State_1__c, Comment_State_1__c from Distributor__c where Id=:stdCrtl.getId() LIMIT 1];
        leftvalues.clear();   
        List<String> countiesList = new List<String>();    
        if(stateNumber.equals('1') && agent.State_Province_1__c != null){
            leftvalues.addAll(spch.getStateCounties().get(agent.State_Province_1__c));
            rightselected.clear();     
            if(agent.Counties_State_1__c.equals(CoversEntireState)){
                countiesList.addAll(spch.getStateCounties().get(agent.State_Province_1__c));
                isAllCounties = 'Yes';
            }
            else{       
                countiesList.addAll(agent.Counties_State_1__c.split(';'));
                isAllCounties = 'No';
            }
            state = agent.State_Province_1__c;
            comment = agent.Comment_State_1__c;
        }
        
        for(String s : countiesList){
            leftvalues.remove(s);
            rightvalues.add(s);
        }  
        
        edit = true;
        showAddNew = true;
        showStateCountyItems = false;
        return null;
    }
    
    public PageReference showAddNewBlock(){
        leftselected.clear();
        leftvalues.clear();
        rightvalues.clear();
        rightselected.clear();
        isAllCounties = '--None--';
        state='AB';
        leftvalues.addAll(spch.getStateCounties().get(state));
        if((agent.State_Province_1__c == null && agent.Counties_State_1__c == null)){
            showAddNew = true;
            showStateCountyItems = false;
        }
        else 
            showAddNew = false;
        
        return null;
    }
    
    
    public PageReference hideAddNewBlock(){
        rightSelected.clear();
        showAddNew = false;
        showStateCountyItems = true;
        return null;
    }
    
}
public class GE_LGT_Emea_current_Approvalupdate {
    public static boolean recursivehandler=true;
    public Id recordId {get; private set;}
    public string message{set;get;}
    public string message1{set;get;}
    public list<Opportunity_Support_Request__c> osrs {set;get;}
    
    public GE_LGT_Emea_current_Approvalupdate(ApexPages.StandardController controller) {
        recordId=ApexPages.currentPage().getParameters().get('id');
    }
    
    public void approavalfunction(){
        
        try{
            
            osrs=new list<Opportunity_Support_Request__c>();
            map<id,Opportunity_Support_Request__c> getOsrs=new map<id,Opportunity_Support_Request__c>([select id,EMEA_Approving_Function__c from Opportunity_Support_Request__c where id =:recordId limit 1]);
            
            map<id,ProcessInstance> PIlist = new map<id,ProcessInstance>([SELECT CompletedDate,CreatedById,CreatedDate,ElapsedTimeInDays,ElapsedTimeInHours,ElapsedTimeInMinutes,Id,IsDeleted,LastActorId,LastModifiedById,LastModifiedDate,ProcessDefinitionId,Status,SubmittedById,SystemModstamp,TargetObjectId FROM ProcessInstance where TargetObjectId =:recordId AND Status='Pending']);
            if(!PIlist.isEmpty()){
                
                map<id,ProcessInstanceNode> stepInstanceNodes=new map<id,ProcessInstanceNode>([SELECT CompletedDate,CreatedById,CreatedDate,ElapsedTimeInDays,
                                                                                               ElapsedTimeInHours,ElapsedTimeInMinutes,Id,IsDeleted,LastActorId,LastModifiedById,
                                                                                               LastModifiedDate,NodeStatus,ProcessInstanceId,ProcessNodeId,ProcessInstance.TargetObjectId,ProcessInstance.ProcessDefinition.name,ProcessNodeName FROM ProcessInstanceNode where ProcessInstanceId in:PIlist.keyset() AND NodeStatus='Pending'  order by CreatedDate DESC]);
                List<Emea_OSR_Approving_Function__c> customOsrs = Emea_OSR_Approving_Function__c.getall().values();
                map<string,string> stepapprovingfunction =new map<string,string>();
                for(Emea_OSR_Approving_Function__c osr:customOsrs){
                    stepapprovingfunction.put(osr.Approving_Step_Name__c,osr.Approving_Function__c);
                }
                
                for(id nodeid:stepInstanceNodes.keyset()){
                    system.debug('Testttt'+'_____'+stepInstanceNodes.get(nodeid).ProcessNodeName);
                    if(getOsrs.get(stepInstanceNodes.get(nodeid).ProcessInstance.TargetObjectId).EMEA_Approving_Function__c !=stepapprovingfunction.get(stepInstanceNodes.get(nodeid).ProcessNodeName).trim()){
                        
                        
                        if(getOsrs.get(stepInstanceNodes.get(nodeid).ProcessInstance.TargetObjectId).EMEA_Approving_Function__c!= stepapprovingfunction.get(stepInstanceNodes.get(nodeid).ProcessNodeName)){
                            getOsrs.get(stepInstanceNodes.get(nodeid).ProcessInstance.TargetObjectId).EMEA_Approving_Function__c = stepapprovingfunction.get(stepInstanceNodes.get(nodeid).ProcessNodeName);
                            osrs.add(getOsrs.get(stepInstanceNodes.get(nodeid).ProcessInstance.TargetObjectId));
                        }
                        
                        message1= stepapprovingfunction.get(stepInstanceNodes.get(nodeid).ProcessNodeName);
                    }
                    
                }
                
                message ='Current approving function:'+message1;
                
            }
            
            if(!osrs.isEmpty()){
                update osrs;
                
            }
            else{
                osrs.add(getOsrs.get(recordId));
            }
            
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        
    }  
}
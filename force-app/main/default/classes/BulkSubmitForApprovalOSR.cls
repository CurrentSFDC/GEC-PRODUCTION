public class BulkSubmitForApprovalOSR {
    //Rashmitha Changed the API vesion from 37 to 45 on 6-Mar-2019 as per 1447 request
    public Id recordId {get; private set;}
    public string message{set;get;}
    public BulkSubmitForApprovalOSR(ApexPages.StandardController controller) {
        recordId=ApexPages.currentPage().getParameters().get('id');
    }
    public void bulkapproval(){
        id recordtypeid=Schema.SObjectType.Opportunity_Support_Request__c.getRecordTypeInfosByName().get('EMEA New Sample Product Req').getRecordTypeId();
        set<id> PIids=new set<id>();
        map<id,Opportunity_Support_Request__c> osrlist=new map<id,Opportunity_Support_Request__c>([select id,name,Status__c,EMEA_Approving_Function__c from Opportunity_Support_Request__c where Status__c='Not Submitted'and recordtypeid=:recordtypeid and Opportunity_Name__c=:recordId]);
        list<ProcessInstanceWorkitem> PIW=[SELECT Id,ProcessInstanceId,ProcessInstance.targetobjectId FROM ProcessInstanceWorkitem where ProcessInstance.targetobjectId in:osrlist.keyset()];
        set<id> osrpendingids=new set<id>();
        for(ProcessInstanceWorkitem pw:PIW){
            osrpendingids.add(pw.ProcessInstance.targetobjectId);
        }
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
        for (id osrId: osrlist.keyset()) {
            if(!osrpendingids.contains(osrId)){                   
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval ');
                req1.setObjectId(osrId);
                requests.add(req1);
            }
        }
        displayPopup = true; 
        
        Approval.ProcessResult[] processResults = null;
        try {
            if(!requests.isEmpty()){
                processResults = Approval.process(requests, true);
                message=' OSR Records  submited for Approval successfully';
                for(Approval.ProcessResult pr:processResults){
                    PIids.add(pr.getInstanceId());
                }
                
                
                map<id,ProcessInstanceNode> stepInstanceNodes=new map<id,ProcessInstanceNode>([SELECT Id,IsDeleted,LastActorId,LastModifiedById,
                                                                                               NodeStatus,ProcessInstanceId,ProcessNodeId,ProcessInstance.TargetObjectId,
                                                                                               ProcessInstance.ProcessDefinition.name,ProcessNodeName FROM ProcessInstanceNode where ProcessInstanceId in:PIids AND NodeStatus='Pending'  order by CreatedDate DESC]);
                List<Emea_OSR_Approving_Function__c> customOsrs = Emea_OSR_Approving_Function__c.getall().values();
                map<string,string> stepapprovingfunction =new map<string,string>();
                for(Emea_OSR_Approving_Function__c osr:customOsrs){
                    stepapprovingfunction.put(osr.Approving_Step_Name__c,osr.Approving_Function__c);
                }
                list<Opportunity_Support_Request__c> osrs=new list<Opportunity_Support_Request__c>();
                for(id nodeid:stepInstanceNodes.keyset()){
                    if(osrlist.get(stepInstanceNodes.get(nodeid).ProcessInstance.TargetObjectId).EMEA_Approving_Function__c !=stepapprovingfunction.get(stepInstanceNodes.get(nodeid).ProcessNodeName).trim()){
                        
                        Opportunity_Support_Request__c OSR=new Opportunity_Support_Request__c(id=osrlist.get(stepInstanceNodes.get(nodeid).ProcessInstance.TargetObjectId).id,EMEA_Approving_Function__c=stepapprovingfunction.get(stepInstanceNodes.get(nodeid).ProcessNodeName));
                        
                        osrs.add(OSR);
                        
                        
                    }
                    
                }
                if(!osrs.isEmpty()){
                    update osrs;
                }
                
            }
            else{
                message='No OSR Records to submit for Approval';
            }
        }catch (System.DmlException e) {
            
           if(processResults != null && processResults.size() > 0){
           for ( Integer x=0;x<processResults.size();x++){
                if(!processResults[x].isSuccess()){
                    system.debug(requests[x].getObjectId()); //this debugs the record ID that was submitted causing the error. you can do whatever you need to besides debug
                    message='Below records are not submitted <br/>'+osrlist.get(requests[x].getObjectId()).name+'=>'+processResults[x].geterrors()+'<br/>';
                }
            }
            System.debug('Exception Is ' + e.getMessage());
           
           } 
            
        }
    }
    public boolean displayPopup {get; set;}    
    
    public void closePopup()
    {       
        displayPopup = false;   
    }    
    public void showPopup()
    {       
        displayPopup = true;   
    }   
}
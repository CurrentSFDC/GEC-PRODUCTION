public class GE_LGT_EM_ApproveReject 
{
    List<PendingAppRecs>ProsInsts{get;set;}
    public List<ProcessInstance>prosInslist{get;set;}
    public string comments{get;set;}
    public List<GE_LGT_EM_ComplaintLineItem__c> selProsInss{get;set;}
    private List<ProcessInstanceWorkitem>  prosInsWrkItms1 = new List<ProcessInstanceWorkitem>(); 
    set<string>cliids=new set<string>();
    set<string>PIids=new set<string>();
    private List<Id> prosInsIds = new List<Id>();    
    Id Caseid = System.currentPageReference().getParameters().get('id');
    
   
   public GE_LGT_EM_ApproveReject(ApexPages.StandardSetController controller) {
   
        prosInslist= new List<ProcessInstance>();
        selProsInss = new List<GE_LGT_EM_ComplaintLineItem__c>();
             
        prosInslist=[Select Id, TargetObjectId, isDeleted,TargetObject.Type,Status,(Select Id, ProcessInstanceId, ActorId, Actor.Name, StepStatus, Comments From StepsAndWorkItems Where StepStatus = 'Pending')From ProcessInstance Where isDeleted = false and Status = 'Pending' and TargetObject.Type='GE_LGT_EM_ComplaintLineItem__c'];
        for(ProcessInstance PIns:prosInslist){
        cliids.add(PIns.TargetObject.id);
        PIids.add(PIns.id);
         prosInsIds.add(PIns.Id);

        }
     
       }
       
    public ApexPages.StandardSetController standardSetCon{
    get {
    if(standardSetCon == null) {
        standardSetCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id,Name,GE_LGT_EM_SAPInvoiceNumber__c,GE_LGT_EM_ApprovingFunction__c,GE_LGT_EM_Category__c,GE_LGT_EM_ApprovedQuantity__c,GE_LGT_EM_Status__c,GE_LGT_EM_ApprovedUnitPrice__c,GE_LGT_EM_ApprovedValue__c,GE_LGT_EM_SAP_Material_Number__c,CreatedDate FROM GE_LGT_EM_ComplaintLineItem__c where GE_LGT_EM_Status__c in('001-Open','002-Approved(CR/DR/RE Required)') and id=:cliids and GE_LGT_EM_CaseNumber__c=:Caseid ]));
        // sets the number of records in each page set
        standardSetCon.setPageSize(300);
    }
    return standardSetCon ;
    }
    set;

    }
 public void appRej(String appRej)
    {
            list<id>proinsid=new list<id>();             
            for(ProcessInstance  pwi :prosInslist)
            {
            
                for(GE_LGT_EM_ComplaintLineItem__c pi :selProsInss)
            
                {
            
                    if(pwi.TargetObject.Id==pi.Id)
                    {
                        proinsid.add(pwi.id);
                    }
                }  
            }   
            
           List<ProcessInstanceWorkitem> procWrkItms = new List<ProcessInstanceWorkitem>();
           procWrkItms  = [Select Id from ProcessInstanceWorkitem where ProcessInstance.Id =:proinsid];  
           system.debug('ApprovalprocWrkItms--->'+procWrkItms.size());
           Approval.ProcessWorkitemRequest[] req = new Approval.ProcessWorkitemRequest[]{};
           
            for(ProcessInstanceWorkitem procWrkItms1:procWrkItms){
                    
                    Approval.ProcessWorkitemRequest req1 = new Approval.ProcessWorkitemRequest();
                    req1.setComments(Comments);
                    req1.setAction(appRej);
                    if(appRej == 'Approve')
                      
                    req1.setNextApproverIds(null); 
                    
                    system.debug('procWrkItms--->'+procWrkItms1);                 
                                       
                    req1.setWorkitemId(procWrkItms1.Id); 
                    req.add(req1);      
  
             } 

                           // Submit the request for approval    
                    Approval.ProcessResult[] result2 =  Approval.process(req);
       
    }
    
    
    public pagereference approveAll()
    {
        appRej('Approve');
        Pagereference pg = new pagereference('/'+Caseid);
        pg.setredirect(true);
        return pg;
    }

    public pagereference rejectAll()
    {
        appRej('Reject');
        Pagereference pg = new pagereference('/'+Caseid);
        pg.setredirect(true);
        return pg;
    }

    public pagereference cancel()
    {        Pagereference pg = new pagereference('/apex/rejectApprove?id='+Caseid+'');
            pg.setredirect(true);
            return pg;
   }
    public PageReference BackToParent(){

   PageReference reference= new PageReference('/'+Caseid);   
    reference.setRedirect(true);
    return reference;

}
    
    public pagereference selRecs(){
   
            for(PendingAppRecs pendApp:ProsInsts) 
            {
                if(pendApp.selected == true) 
                {
                    selProsInss.add(pendApp.proInstce);
                }
            }   
                     return null;
            
    }
  
  public List<PendingAppRecs> getProsInsts() {
    
        if (ProsInsts== null) {
            ProsInsts= new List<PendingAppRecs>(); 
            } 
         else {
            ProsInsts.clear();
        }
        
        for(sObject pins :standardSetCon.getRecords()){
        GE_LGT_EM_ComplaintLineItem__c p = (GE_LGT_EM_ComplaintLineItem__c)pins;
             ProsInsts.add(new PendingAppRecs(p));
            }
        
        return ProsInsts;
    }
    
     //wrapper class
    public class PendingAppRecs
    {
        public GE_LGT_EM_ComplaintLineItem__c proInstce{get; set;}
        public Boolean selected {get; set;}
      
        public PendingAppRecs(GE_LGT_EM_ComplaintLineItem__c p) 
        {
        proInstce = p;
        selected = false;
        
        }
    }  
}
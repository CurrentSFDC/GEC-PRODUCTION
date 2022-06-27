public with sharing class wrapperClassController {
    
    set<string>cliids=new set<string>();
    private Set<GE_LGT_EM_ComplaintLineItem__c> selectedContactIds;
    @TestVisible private List<cContact> row{get;set;}   
    Id Caseid = System.currentPageReference().getParameters().get('id');
    public wrapperClassController(ApexPages.StandardSetController controller) {
        
        system.debug('Caseid---->'+Caseid);
        row= new List<cContact>();
        selectedContactIds= new set<GE_LGT_EM_ComplaintLineItem__c>();
        
        List<GE_LGT_EM_ComplaintLineItem__c> complaintLineItemList=[select Id from GE_LGT_EM_ComplaintLineItem__c where GE_LGT_EM_CaseNumber__c=:Caseid];
        List<ProcessInstance>prosInslist=[Select Id, TargetObjectId, isDeleted,TargetObject.Type,Status,(Select Id, ProcessInstanceId, ActorId, Actor.Name, StepStatus, Comments From StepsAndWorkItems
                                                                                                         Where StepStatus = 'Pending')From ProcessInstance Where isDeleted = false and Status IN('Pending','Approved','Rejected') and TargetObject.Type='GE_LGT_EM_ComplaintLineItem__c' AND TargetObjectID IN:complaintLineItemList];
        for(ProcessInstance PIns:prosInslist)
        {
            cliids.add(PIns.TargetObject.id); 
        }
        System.debug('cliids:'+cliids);
    }
    
    public ApexPages.StandardSetController standardSetCon{
        get {
            if(standardSetCon == null) {
                standardSetCon = new ApexPages.StandardSetController(Database.getQueryLocator([select Id,Name,GE_LGT_EM_SAPInvoiceNumber__c,GE_LGT_EM_Status__c,GE_LGT_EM_Category__c,GE_LGT_EM_ApprovingFunction__c from GE_LGT_EM_ComplaintLineItem__c where GE_LGT_EM_Status__c='001-Open'and GE_LGT_EM_CaseNumber__c=:Caseid and id Not in:cliids]));
                // sets the number of records in each page set
                standardSetCon.setPageSize(100);
            }
            return standardSetCon ;
        }
        set;
    }
    
    //This method uses a simple SOQL query to return a List of complaint
    public List<cContact>getContacts(){
        
        getSelected();
        row = new list<cContact>();
        
        for(sObject cliList:standardSetCon.getRecords()){ 
            
            GE_LGT_EM_ComplaintLineItem__c c = (GE_LGT_EM_ComplaintLineItem__c)cliList;
            
            if(this.selectedContactIds.contains(c)){
                row.add(new cContact(c,'true'));
            }
            else{
                row.add(new cContact(c));
            }
            
        }
        
        system.debug('selected cli'+row.size());
        
        return row;
        
    }  
    
    public PageReference getSelected()
    {
        
        for(cContact accwrapper : row)
            if(accwrapper.selected == true){
                selectedContactIds.add(accwrapper.CLItem);
            }
        else{
            if(selectedContactIds.contains(accwrapper.CLItem ))
                selectedContactIds.remove(accwrapper.CLItem );
        }
        system.debug('selected--->'+selectedContactIds.size());
        return null;
    }    
    
    public PageReference processSelected() {
        
        for(cContact Slist:row){
            if(Slist.selected==true){
                selectedContactIds.add(Slist.CLItem );
            }
            
        }
        system.debug('selected record process count---->'+selectedContactIds.size());  
        
        
        Approval.ProcessSubmitRequest[] req = New Approval.ProcessSubmitRequest[]{};
            for(GE_LGT_EM_ComplaintLineItem__c con:selectedContactIds) 
        {
            
            system.debug('selected cli ids---->'+con.id); 
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Mass records Submitted from visulaforce Page! ');
            req1.setObjectId(con.id);
            req.add(req1);
            
        }
        System.debug('Submitted ---->'+req.size());
        if(req.size()>0){     
            System.debug('casereturn id---->'+Caseid);                    
            // submit the approval request for processing          
            Approval.ProcessResult[] results = Approval.process(req);    
            
            System.debug('casereturn id---->'+Caseid);
            PageReference reference1= new PageReference('/'+Caseid);   
            reference1.setRedirect(true);
            return reference1;
        } else{
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Please select atleast one record'));
            return null;
        }
        
        return null;      
        
    }  
    
    public PageReference BackToParent(){
        System.debug('casereturn id---->'+Caseid);
        PageReference reference= new PageReference('/'+Caseid);   
        reference.setRedirect(true);
        return reference;
        
    }
    
    public Integer getSelectedCount(){
        system.debug('selected count'+selectedContactIds.size());
        return this.selectedContactIds.size();
        
        
    }   
    // This is our wrapper/container class. A container class is a class
    public class cContact {
        public GE_LGT_EM_ComplaintLineItem__c CLItem {get; set;}
        public Boolean selected {get; set;}
        
        //This is the contructor method. 
        public cContact(GE_LGT_EM_ComplaintLineItem__c c) {
            CLItem = c;
            selected = false;
        }
        public cContact(GE_LGT_EM_ComplaintLineItem__c c,string s){
            CLItem = c;
            selected = true;
            
        } 
    }
    
}
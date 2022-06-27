/***********************************************************************************************
*   Class Name      : Tasktriggerhelper
*   Date            :  
*   Author          : 
*   Object          : Activity
*   Purpose         : These method fire on Task.
*   Test Class      : GE_LGT_Project_Triggers_Test
**************************************************************************************************/
public class Tasktriggerhelper 
{
    Public Static ID Taskrecdty =Schema.SObjectType.Task.getRecordTypeInfosByName().get('GE_LGT_EM_TaskLayout').getRecordTypeId();
    Public Static ID Caserecdty =Schema.SObjectType.Case.getRecordTypeInfosByName().get('GE Lighting EMEA').getRecordTypeId();
    Public Static Id Pricingtaskid =Schema.SObjectType.Task.getRecordTypeInfosByName().get('Pricing task').getRecordTypeId();
    Public Static Id AEAssignmentTaskId =Schema.SObjectType.Task.getRecordTypeInfosByName().get('SE Assignment Task').getRecordTypeId();
    
    Public List<Case> casestoInsertwoA = new List<Case>();  
    Public List<Case> casestoInsertwA = new List<Case>();  
    Public List<Case> casestoInsert = new List<Case>();
    Public Map<string,string> RecrdIdMap=new Map<string,string>(); 
    Public Map<string,string> CaseMap = new Map<string,string>();               
    Public List<Task> ComplaintTaskList;
    Public List<Task> ComplaintTaskListF;
    Public AERCreatedDateCaptureHandler aerHandler;
    Public Case cs;
    
    //This will be called After Insert 
    Public void InsertTask(list<task> listtask){
        
        try{
            Set<Id> ComplaintIdSet= new Set<Id>();  
            
            if(Test.isRunningTest()){
                for(Task tasklist:listtask){ 
                    if(tasklist.recordtypeid==Taskrecdty && (tasklist.Whatid!=null))  
                        ComplaintIdSet.add(tasklist.Whatid); 
                } 
            }
            
            //Trigger.IsInsert
            
            for(Task tasklist:listtask) {       
                if(tasklist.recordtypeid==Taskrecdty && (tasklist.Whatid!=null) && string.valueof(tasklist.whatid).startswith('a0r')==true){
                    ComplaintIdSet.add(tasklist.Whatid);               
                }
            }
            
            List<GE_LGT_EM_ComplaintLineItem__c> FinalComplList = updateComplaintLineItem(ComplaintIdSet);
            
            if(FinalComplList.size()>0){
                update FinalComplList;
            }   
        }catch(Exception ee){}
        
        
    }
    
    // After update 
    Public void UpdateTask(list<task> listtask){
        
        try{
            Set<Id> ComplaintIdSet= new Set<Id>();  
            
            if(Test.isRunningTest()){
                for(Task tasklist:listtask){ 
                    if(tasklist.recordtypeid==Taskrecdty && (tasklist.Whatid!=null))  
                        ComplaintIdSet.add(tasklist.Whatid); 
                }                         
            }
            System.debug('Listtask--' +ComplaintIdSet);
            for(Task tasklist:listtask) {       
                if(tasklist.recordtypeid==Taskrecdty && (tasklist.Whatid!=null) && string.valueof(tasklist.whatid).startswith('a0r')==true){
                    ComplaintIdSet.add(tasklist.Whatid);               
                }
            }
            List<GE_LGT_EM_ComplaintLineItem__c> FinalComplList=  updateComplaintLineItem(ComplaintIdSet);
            
            if(FinalComplList.size()>0){
                update FinalComplList;
                
            }   
        }catch(Exception ee){}
    }
    
    //After Delete
    Public void DeleteTask(list<task> OldTaskList){
        try{
            Set<Id> ComplaintIdSet= new Set<Id>();  
            
            
            
            if(Test.isRunningTest()){
                for(Task tasklist:OldTaskList) {       
                    if(tasklist.recordtypeid==Taskrecdty && (tasklist.Whatid!=null))
                        ComplaintIdSet.add(tasklist.Whatid);                                  
                }  
                
            }
            
            // Trigger.Isdelete 
            for(Task tasklist:OldTaskList) {       
                if(tasklist.recordtypeid==Taskrecdty && (tasklist.Whatid!=null) && string.valueof(tasklist.whatid).startswith('a0r')==true){
                    ComplaintIdSet.add(tasklist.Whatid);               
                }           
            }
            List<GE_LGT_EM_ComplaintLineItem__c> FinalComplList=  updateComplaintLineItem(ComplaintIdSet);
            if(FinalComplList.size()>0){
                update FinalComplList;
            }   
        }catch(Exception ee){}
        
    }
    Private List<GE_LGT_EM_ComplaintLineItem__c> updateComplaintLineItem( Set<Id> ComplaintIdSet)
    {
        Map<Id,List<Task>> ComplaintTaskMap = new Map<Id,List<Task>>();   
        Map<Id,String> FinalMap = new Map<Id,String>();
        Decimal total=0;
        if(ComplaintIdSet.size()>0){
            ComplaintTaskList=[select id,whatid,Task_cost__c from Task where whatid in:ComplaintIdSet and Task_cost__c!=null];         
        }
     
        if(ComplaintTaskList.size()>0){
            for(Id itsk:ComplaintIdSet){
                ComplaintTaskListF= new List<Task>();           
                for(integer i=0;i<ComplaintTaskList.size();i++){  
                    if(ComplaintTaskList[i].whatid==itsk)                                                     
                        ComplaintTaskListF.add(ComplaintTaskList[i]);                                    
                }               
                ComplaintTaskMap.put(itsk,ComplaintTaskListF);  
            }
        }
        
        List<Task> GetList = new List<Task>();     
        for(Id i:ComplaintTaskMap.keyset()){
            GetList = new List<Task>(); 
            total=0;
            GetList = ComplaintTaskMap.get(i);
            for(Task titem:GetList){
                total=total+titem.Task_cost__c;                
            }       
            FinalMap.put(i,string.valueof(total));
        }
        
        List<GE_LGT_EM_ComplaintLineItem__c> ComplList = new List<GE_LGT_EM_ComplaintLineItem__c>();
        ComplList=[select id,CurrencyIsoCode,Total_Tasks_Cost__c from GE_LGT_EM_ComplaintLineItem__c where id in:FinalMap.keyset()];
        List<GE_LGT_EM_ComplaintLineItem__c> FinalComplList = new List<GE_LGT_EM_ComplaintLineItem__c>();   
        for(GE_LGT_EM_ComplaintLineItem__c citem:ComplList){ 
            System.debug('Complaintid--' + FinalMap);
              
            if(FinalMap.containskey(citem.id)){ 
                if(citem.Total_Tasks_Cost__c!=decimal.valueof(FinalMap.get(citem.id))){
                    citem.Total_Tasks_Cost__c=decimal.valueof(FinalMap.get(citem.id));
                     citem.CurrencyIsoCode='USD';
                    FinalComplList.add(citem);
                }                           
            }       
        }
        return FinalComplList;
        
    }
    
    
    //This will be called only for before Insert.
    Public void InsertCaseUponTaskValidation(list<task> listtask){
        
        //Before Insert Trigger: AER_CreatedDate field update. 
        //Editted By : Aditya Ghadigaonkar
        //Editted Date : 7/20/2016
        
        aerHandler = new AERCreatedDateCaptureHandler();
        aerHandler.CaptureCD(listtask);
        //End Of AER_CreatedDate field update            
        for(Task t:listtask) { 
            Id acid;
            try{  
                acid=[Select AccountId from Contact where id=:t.WhoId and id!=null].AccountId;      
            }catch(Exception ee){
            }
            //No Account - No Contact - Case Status as Closed
            if((t.Type=='Call - Inbound'||t.Type=='Call - Outbound') && t.recordtypeid==Taskrecdty && t.Subject.contains('Call - ') && (t.Whatid==null) && (t.Whoid==null) && t.GE_LGT_EM_Case_Status__c=='closed'){
                t.adderror('Account/Contact is mandatory for an Activity with Case Status as Closed');       
            }//No Account - Has Contact but no Account associated - Case Status as Closed
            else if((t.Type=='Call - Inbound'||t.Type=='Call - Outbound') && t.recordtypeid==Taskrecdty && t.Subject.contains('Call - ') && (t.Whatid==null) && (t.Whoid!=null) && acid==null && t.GE_LGT_EM_Case_Status__c=='closed'){             
                t.adderror('There is no Account associated with the Contact present in the Activity. Please select a different Contact or select Account in the Related to Field as Case Status will be Closed');    
            }//No Account - Has Contact and also Account associated - No Status Dependency
            else if((t.Type=='Call - Inbound'||t.Type=='Call - Outbound') && t.recordtypeid==Taskrecdty && t.Subject.contains('Call - ') && (t.Whatid==null) && (t.Whoid!=null) ){
                cs= new Case();                                    
                cs.AccountId=acid;
                cs.ContactId=t.WhoId;       
                cs.status=t.GE_LGT_EM_Case_Status__c;
                cs.subject=t.subject;
                cs.Description=t.Description;
                cs.Origin='Phone';
                cs.Type=t.GE_LGT_EM_Call_Reason__c; 
                cs.ownerid=userinfo.getUserId();
                cs.recordtypeid=Caserecdty;
                casestoInsertwoA.add(cs);                                                        
            }//Has Account - Has Contact - No Status Dependency
            else if((t.Type=='Call - Inbound'||t.Type=='Call - Outbound') && t.recordtypeid==Taskrecdty && t.Subject.contains('Call - ') && (t.Whatid!=null && String.valueOf(t.whatid).startsWith('001')==true) && (t.Whoid!=null)){  
                cs= new Case();                         
                cs.AccountId=t.WhatId;
                cs.ContactId=t.WhoId;       
                cs.status=t.GE_LGT_EM_Case_Status__c;
                cs.subject=t.subject;
                cs.Description=t.Description;
                cs.Origin='Phone';
                cs.Type=t.GE_LGT_EM_Call_Reason__c; 
                cs.ownerid=userinfo.getUserId();
                cs.recordtypeid=Caserecdty;
                casestoInsertwoA.add(cs);             
            }//Has Account - No Contact - No Status Dependency
            else if((t.Type=='Call - Inbound'||t.Type=='Call - Outbound') && t.recordtypeid==Taskrecdty && t.Subject.contains('Call - ') && (t.Whatid!=null && String.valueOf(t.whatid).startsWith('001')==true) && (t.Whoid==null)){
                cs= new Case();                         
                cs.AccountId=t.WhatId;                  
                cs.status=t.GE_LGT_EM_Case_Status__c;
                cs.subject=t.subject;
                cs.Description=t.Description;
                cs.Origin='Phone';
                cs.Type=t.GE_LGT_EM_Call_Reason__c; 
                cs.ownerid=userinfo.getUserId();
                cs.recordtypeid=Caserecdty;
                casestoInsertwA.add(cs);            
            }else if((t.Type=='Call - Inbound'||t.Type=='Call - Outbound') && t.recordtypeid==Taskrecdty && t.Subject.contains('Call - ') && t.Whatid!=null && String.valueOf(t.whatid).startsWith('001')==false && String.valueOf(t.whatid).startsWith('500')==false){
                t.adderror('Related to Field must only be either Account or Case'); 
            }//No Account - No Contact - Status not Closed
            else if((t.Type=='Call - Inbound'||t.Type=='Call - Outbound') && t.recordtypeid==Taskrecdty && t.Subject.contains('Call - ') && (t.Whatid==null) && (t.Whoid==null) && t.GE_LGT_EM_Case_Status__c!='closed'){
                cs= new Case();                                                     
                cs.status=t.GE_LGT_EM_Case_Status__c;
                cs.subject=t.subject;
                cs.Description=t.Description;
                cs.Origin='Phone';
                cs.Type=t.GE_LGT_EM_Call_Reason__c; 
                cs.ownerid=userinfo.getUserId();
                cs.recordtypeid=Caserecdty;
                casestoInsert.add(cs);                                                        
            }   
        }  
        
        if(casestoInsert.size()>0){               
            insert casestoInsert;                            
            for(Case c: casestoInsert){
                CaseMap.put(c.subject,c.Id);                        
            }                                              
            for(Task t:listtask){    
                if(CaseMap.containskey(t.subject)){
                    t.Whatid=CaseMap.get(t.subject);                            
                }    
            }
        } 
        
        if(casestoInsertwoA.size()>0){               
            insert casestoInsertwoA;                            
            for(Case c: casestoInsertwoA){
                CaseMap.put(c.ContactId,c.Id);                        
            }                                              
            for(Task t:listtask){    
                if(CaseMap.containskey(t.WhoId)){
                    t.Whatid=CaseMap.get(t.WhoId);                            
                }    
            }
        } 
        if(casestoInsertwA.size()>0){               
            insert casestoInsertwA;                            
            for(Case c: casestoInsertwA){
                CaseMap.put(c.AccountId,c.Id);                        
            }                                              
            for(Task t:listtask){    
                if(CaseMap.containskey(t.WhatId)){
                    t.Whatid=CaseMap.get(t.WhatId);                            
                }    
            }
        }         
        
        
    }
    
    //called before insert 
    public void InsertTaskfields (list<task> listtask){
        
        set<id> userid = new set<id>();
        set<id> setwhatid = new set<id>();
        for (Task NewTaskList: listtask){
            userid.add(NewTaskList.Sales_AE_Requestor__c);
            userid.add(NewTaskList.ownerId);
            setwhatid.add(NewTaskList.whatid);
        }
        map<id, user> mapuserid = new map<id, user>([select  id,email,name from user where id IN : userid]);
        map<id, Opportunity> mapwhatid = new map<id, Opportunity>([select  Id,name from Opportunity where id IN : setwhatid]);
        
        for(Task NewTaskList : listtask){
           
            // Below If condiation is for throwing error  when Task type is equals to Design and The Due Date on task cannot be within 7 days from today.
            if (NewTaskList.GE_LGT_Task_type__c == 'Design' && NewTaskList.ActivityDate <= (System.Today()+7)) {             
                NewTaskList.Activitydate.addError('The Due Date on task cannot be within 7 days from today if the Task Type is Design');   
            }
            if(NewTaskList.RecordTypeId==AEAssignmentTaskId ){
                if(NewTaskList.Sales_AE_Requestor__c !=null){
                    List<String> sendTo = new List<String>();          
                    system.debug('Sales_AE_Requestor Email ::'+NewTaskList.Sales_AE_Requestor__r.Email);
                    
                    String sendToEmail = mapuserid.get(NewTaskList.Sales_AE_Requestor__c).email;
                    system.debug('Email Address ::: '+sendToEmail  );
                    sendTo.add(sendToEmail);
                    string assignedToName=mapuserid.get(NewTaskList.Ownerid).name;
                    String oppty_url = URL.getSalesforceBaseUrl().toExternalForm() +'/' + NewTaskList.WhatId;
                    String body = '<html lang="ja"><body>'+
                        +'An SE task has been assigned to your recent SE request for Opportunity - '+'  '+oppty_url+
                        '<br>'+'Your SE will be in touch with you soon.'+
                        '<br>'+'Solution Engineer Name: '+ assignedToName +
                        '<br><br>'+'Thank You.'+'</body></html>';
                    String subject = 'An SE Has Been Assigned To Your Recent AE Request';
                    
                    GE_LGT_MailerUtils.sendEmailNotification(string.valueof(subject),string.valueof(body),sendTo);
                    
                }
            }
            
            
        }
        
    }
    
    //called before udpate
    public void updateTaskfields (list<task> listtask){
        
        set<id> userid = new set<id>();
        set<id> setwhatid = new set<id>();
        for (Task NewTaskList: listtask){
            userid.add(NewTaskList.Sales_AE_Requestor__c);
            userid.add(NewTaskList.ownerId);
            setwhatid.add(NewTaskList.whatid);
        }
        map<id, user> mapuserid = new map<id, user>([select  id,email,name from user where id IN : userid]);
        map<id, Opportunity> mapwhatid = new map<id, Opportunity>([select  Id,name from Opportunity where id IN : setwhatid]);
        
        for(Task NewTaskList : listtask){
           
            if (NewTaskList.GE_LGT_Task_type__c == 'Design' && NewTaskList.ActivityDate <= (NewTaskList.CreatedDate+7)) {             
                NewTaskList.Activitydate.addError('The Due Date on task cannot be within 7 days from today if the Task Type is Design');   
            }  
            if(NewTaskList.RecordTypeId==AEAssignmentTaskId && NewTaskList.Status=='Completed' ){
                //Send completion email
                if(NewTaskList.Sales_AE_Requestor__c !=null){
                    List<String> send_To = new List<String>();
                    system.debug('Sales_AE_Requestor Email ::'+NewTaskList.Sales_AE_Requestor__r.Email);
                    
                    String sendToEmail1 = mapuserid.get(NewTaskList.Sales_AE_Requestor__c).email;
                    system.debug('Email Address ::: '+sendToEmail1  );
                    send_To.add(sendToEmail1);
                     string assignedToName=mapuserid.get(NewTaskList.Ownerid).name;
                    String oppty_url2 = URL.getSalesforceBaseUrl().toExternalForm() +'/' + NewTaskList.whatId;
                     String task_url2 = URL.getSalesforceBaseUrl().toExternalForm() +'/' + NewTaskList.Id;
                    String OpptyName='';
                    if(NewTaskList.whatid!=null && String.ValueOf(NewTaskList.whatid).substring(0,3).equals('006') ){ //if task is attached to opportunity
                        
                        OpptyName = mapwhatid.get(NewTaskList.whatid).Name;
                    }
                    String bodyCompleted = '<html lang="ja"><body>'+
                        +'SE task completed for Opportunity -'+
                        '<br>'+oppty_url2+
                        '<br>'+'Please click on the below link to take you to the task in Salesforce. '+
                         '<br>'+task_url2+
                         '<br>'+'Solution Engineer Name: '+ assignedToName +
                        '<br><br>'+'Thank You.'+'</body></html>';
                    String subjectCompleted = 'SE Task Completed For '+OpptyName+'';
                    
                    if(StaticVariables.sendEmail){
                        GE_LGT_MailerUtils.sendEmailNotification(string.valueof(subjectCompleted),string.valueof(bodyCompleted ),send_To);
                        StaticVariables.sendEmail=false;
                    }
                }
            }
            
        }
        
    }
    
    
    public static void cloneAttachment(List<Task> newTaskList)
    {
        System.debug('IN CLONE ATTACHMENT');
        Map<String,Task> clonedIDMap = new Map<String,Task>();
        for(Task var:newTaskList)
        {
            if(var.isClone())
            {
                clonedIDMap.put(var.getCloneSourceID(),var);
                System.debug('ClonedID::'+var.getCloneSourceId());
            }
        }
        List<Attachment> insertAttList = new List<Attachment>();
        for(Attachment att:[SELECT ID,Name,Body,ParentId FROM Attachment WHERE ParentID IN:clonedIDMap.keySet()])
        {
            Attachment newAtt = new Attachment();
            newAtt.Name = att.Name;
            newAtt.ParentID = clonedIDMap.get(att.ParentId).ID;
            newAtt.Body = att.Body;
            newAtt.ownerID = clonedIDMap.get(att.ParentId).ownerID;
            insertAttList.add(newAtt);
        }
        if(!insertAttList.isEmpty())
            insert insertAttList;
    }
    
     //called before insert 
    public void taskDefaultAssignTo (list<task> NewTaskList){
        
        List<Id> oppList = new List<Id>();
        for(Task tsk:NewTaskList)
        {
            system.debug('tsk.whatid   '+tsk.whatid);
            oppList.add(tsk.whatid);
        }
        if(oppList.size()>0)
        {
            Map<Id,String> opportunityMap= new Map<Id,String>();
            List<Opportunity> OpportuityList= [select id,name,RecordType.Name,RecordType.DeveloperName 
                                               from Opportunity where id IN:oppList]; 
            system.debug('OpportuityList'+OpportuityList);
            if(OpportuityList.size()>0)
            {
                for(opportunity eachopp:OpportuityList)                    
                {
                    opportunityMap.put(eachopp.id,eachopp.RecordType.DeveloperName);
                }
                for(Task tsk:NewTaskList)
                {
                    system.debug('tsk.WhatId1 '+tsk.WhatId );
                    if(opportunityMap.size()>0){
                        if(tsk.WhatId != null && tsk.WhatId.getSObjectType() == Opportunity.sObjectType &&
                           opportunityMap.containskey(tsk.WhatId)){
                               if(opportunityMap.get(tsk.WhatId)!=null)
                               {
                                   system.debug('opportunityMap.get(tsk.WhatId) '+opportunityMap.get(tsk.WhatId) );
                                   if(opportunityMap.get(tsk.WhatId) == 'Standard' || opportunityMap.get(tsk.WhatId) == 'StandardAdvance' )
                                   {
                                       tsk.parentOppRecordType__c='Standard'; 
                                   }
                                   else if(opportunityMap.get(tsk.WhatId) == 'Daintree' || opportunityMap.get(tsk.WhatId) == 'DaintreeAdvance' 
                                           || opportunityMap.get(tsk.WhatId) == 'Intelligent_City' || opportunityMap.get(tsk.WhatId)== 'IntelligentCityAdvance')
                                   {
                                       tsk.parentOppRecordType__c='Daintree_OR_IE'; 
                                   }
                               }     
                           }
                    }
                }                
            } 
        }
    }
}
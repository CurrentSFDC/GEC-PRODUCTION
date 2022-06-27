trigger GE_LGT_EM_AssignCase on Task (before insert,after insert,after update,after delete) {
    
    Public List<Case> casestoInsertwoA = new List<Case>();  
    Public List<Case> casestoInsertwA = new List<Case>();  
    Public List<Case> casestoInsert = new List<Case>();
    Map<string,string> RecrdIdMap=new Map<string,string>(); 
    Public Map<string,string> CaseMap = new Map<string,string>();               
    Case cs;
    Public List<Task> ComplaintTaskList;
    Public List<Task> ComplaintTaskListF;
    AERCreatedDateCaptureHandler aerHandler;
    
    List<RecordType> recrdlist=new List<RecordType>([select id,Name from RecordType]); 
    for(Recordtype rt:recrdlist){
        RecrdIdMap.put(rt.Name,rt.Id);      
    }   
    Id Taskrecdty = RecrdIdMap.get('GE_LGT_EM_TaskLayout');
    Id Caserecdty = RecrdIdMap.get('GE Lighting EMEA');
    
    if(Trigger.Isbefore){
        //Before Insert Trigger: AER_CreatedDate field update. 
        //Editted By : Aditya Ghadigaonkar
        //Editted Date : 7/20/2016
        if(Trigger.isInsert){
            aerHandler = new AERCreatedDateCaptureHandler();
            aerHandler.CaptureCD(trigger.new);
        }//End Of AER_CreatedDate field update            
        for(Task t:Trigger.New) { 
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
            for(Task t:Trigger.New){    
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
            for(Task t:Trigger.New){    
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
            for(Task t:Trigger.New){    
                if(CaseMap.containskey(t.WhatId)){
                    t.Whatid=CaseMap.get(t.WhatId);                            
                }    
            }
        }         
    }
    if(Trigger.IsAfter){    
        try{
            Set<Id> ComplaintIdSet= new Set<Id>();  
            Map<Id,List<Task>> ComplaintTaskMap = new Map<Id,List<Task>>();   
            Map<Id,String> FinalMap = new Map<Id,String>();
            Decimal total=0;
            
            
            if(Test.isRunningTest()){
                if(Trigger.IsInsert || Trigger.IsUpdate){  
                    for(Task t:Trigger.New){ 
                        if(t.recordtypeid==Taskrecdty && (t.Whatid!=null))  
                            ComplaintIdSet.add(t.Whatid); 
                    } 
                }
                if(Trigger.Isdelete) {
                    for(Task t:Trigger.Old) {       
                        if(t.recordtypeid==Taskrecdty && (t.Whatid!=null))
                            ComplaintIdSet.add(t.Whatid);                                  
                    }  
                }
            }
            
            if(Trigger.IsInsert || Trigger.IsUpdate){
                for(Task t:Trigger.New) {       
                    if(t.recordtypeid==Taskrecdty && (t.Whatid!=null) && string.valueof(t.whatid).startswith('a0ri')==true){
                        ComplaintIdSet.add(t.Whatid);               
                    }
                }
            }
            
            if(Trigger.Isdelete) {
                for(Task t:Trigger.Old) {       
                    if(t.recordtypeid==Taskrecdty && (t.Whatid!=null) && string.valueof(t.whatid).startswith('a0ri')==true){
                        ComplaintIdSet.add(t.Whatid);               
                    }           
                }
            }
            
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
                if(FinalMap.containskey(citem.id)){             
                    if(citem.Total_Tasks_Cost__c!=decimal.valueof(FinalMap.get(citem.id))){
                        citem.Total_Tasks_Cost__c=decimal.valueof(FinalMap.get(citem.id));
                        citem.CurrencyIsoCode='USD';
                        FinalComplList.add(citem);
                    }                           
                }       
            }
            if(FinalComplList.size()>0){
                update FinalComplList;
            }   
        }catch(Exception ee){}
    }   
}
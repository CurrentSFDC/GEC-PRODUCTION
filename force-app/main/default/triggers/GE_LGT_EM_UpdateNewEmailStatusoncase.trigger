trigger GE_LGT_EM_UpdateNewEmailStatusoncase on EmailMessage (after insert,before delete) {
    
    AdminOverride__c AdminOverrideUser = AdminOverride__c.getInstance(UserInfo.getUserId());
    System.debug('AdminOverrideUser: '+ AdminOverrideUser + 'Switch Status: '+ AdminOverrideUser.Switch_Off_Trigger__c);
    if(AdminOverrideUser.Switch_Off_Trigger__c == False) {
        TriggerSwitch__c EmailTrigger = TriggerSwitch__c.getInstance('GE_LGT_EM_UpdateNewEmailStatusoncase');
        if(!(EmailTrigger != NULL && EmailTrigger.isActive__c == False)){
    
    //****START FOR AFTER INSERT
    Map<string,string> RecrdIdMap=new Map<string,string>(); 
    List<RecordType> recrdlist=new List<RecordType>([select id,Name from RecordType]); 
    for(Recordtype rt:recrdlist){
        RecrdIdMap.put(rt.Name,rt.Id);      
    }
    
    Id ComplaintRecId = RecrdIdMap.get('EMEA Complaint');
    Id recordtID = RecrdIdMap.get('GE Lighting EMEA'); 
    
    if(trigger.isAfter && trigger.isInsert) {
    
        set<Id> caseIds = new set<Id>();        
        set<Id> caseIdsWOA = new set<Id>();
        Set<Id> CountcaseId = new Set<Id>();
        Set<Id> CountFinalId = new Set<Id>();
        List<Case> CaseList= new List<Case>();
        Map<Id,Datetime> DateMap= new Map<Id,Datetime>();
        Map<Id,String> SubjectMap= new Map<Id,String>();
        Map<String,String> CaseCountMap = new Map<String,String>();
        Map<Id,Id> EmailCaseMap = new Map<Id,Id>();
        
        for(EmailMessage message : trigger.new){
        
            if((message.Incoming == true || message.Incoming == false) && message.parentid != null && string.valueof(message.parentid).startswith('500')==true){
                CountcaseId.add(message.ParentId);                  
            }
            
            if(message.Incoming == true && message.status=='0' && message.hasAttachment==true && string.valueof(message.parentid).startswith('500')==true){
                caseIds.add(message.ParentId);   
                EmailCaseMap.put(message.Id,message.parentId);                
                DateMap.put(message.ParentId,message.MessageDate);  
                SubjectMap.put(message.ParentId,message.Subject);               
            }
            
            if(message.Incoming == true && message.status=='0' && message.hasAttachment==false && string.valueof(message.parentid).startswith('500')==true){
                caseIdsWOA.add(message.ParentId);                      
                DateMap.put(message.ParentId,message.MessageDate);  
                SubjectMap.put(message.ParentId,message.Subject);   
            }                      
        }     

        list<Case> casesToUpdateWOA = new list<Case>();
        list<Case> casesToUpdateAtt = new list<Case>();
        

        if(caseIdsWOA.size()>0)
        casesToUpdateWOA = [Select Id,GE_LGT_EM_New_Email__c,GE_LGT_EM_Email_Subject__c,GE_LGT_EM_Email_Received_Date__c From Case Where Id in: caseIdsWOA and (recordtypeid=: recordtID OR recordtypeid=:ComplaintRecId)];
        
        if(caseIds.size()>0){
        casesToUpdateAtt = [Select Id,GE_LGT_EM_New_Email__c,GE_LGT_EM_Email_Subject__c,GE_LGT_EM_Email_Attachment__c,GE_LGT_EM_Email_Received_Date__c,GE_LGT_EM_Has_Attachment__c From Case Where Id in: caseIds and (recordtypeid=: recordtID OR recordtypeid=:ComplaintRecId)];        
        }   
                    
        if(casesToUpdateWOA.size()>0){
            for(Case c : casesToUpdateWOA){
                c.GE_LGT_EM_New_Email__c= true;           
                c.GE_LGT_EM_Email_Received_Date__c=DateMap.get(c.Id);  
                c.GE_LGT_EM_Email_Subject__c=SubjectMap.get(c.Id); 
            }
        }       
        
        if(casesToUpdateWOA.size()>0)
        update casesToUpdateWOA;        
        
        if(casesToUpdateAtt.size()>0){
            for(Case c : casesToUpdateAtt){
                c.GE_LGT_EM_New_Email__c= true;
                c.GE_LGT_EM_Has_Attachment__c= true;        
                c.GE_LGT_EM_Email_Received_Date__c=DateMap.get(c.Id);  
                c.GE_LGT_EM_Email_Subject__c=SubjectMap.get(c.Id);                 
            }
        }
        
        if(casesToUpdateAtt.size()>0)
        update casesToUpdateAtt; 
                        
        CaseList= [select Id,recordtypeid,GE_LGT_EM_Email_Count__c from case where id in:CountcaseId and (recordtypeid=: recordtID OR recordtypeid=:ComplaintRecId)];            
        
        for(Case c:CaseList){
        CountFinalId.add(c.Id);        
        }         
         
        list<AggregateResult> caseEmailCount = new list<AggregateResult>();    
        if(CountFinalId.size()>0)
        caseEmailCount = [Select ParentId,Count(Id) recordCount from Emailmessage Where ParentId in: CountFinalId and ParentId!=null GROUP BY ParentId];
        
        
        for (AggregateResult ar : caseEmailCount) {
            CaseCountMap.put(String.valueof(ar.get('ParentId')),string.valueof(ar.get('recordCount')));
        } 
        
        for(Case c:CaseList){
            if(CaseCountMap.containskey(c.Id)){
                c.GE_LGT_EM_Email_Count__c=Decimal.valueof(CaseCountMap.get(c.Id));            
            }        
        }
        if(CaseList.size()>0){
            update CaseList;
        } 
        
        if(Test.isRunningTest()){
            for(EmailMessage message : trigger.new){
                           
                if(message.Incoming == true && message.status=='0' && message.parentid!=null){    
                if(string.valueof(message.parentid).startswith('500')==true){
                EmailCaseMap.put(message.Id,message.parentId);  
                }
                
                }    
            }
        if(!EmailCaseMap.isEmpty()){    
        GE_LGT_EM_UpdateEmailAttachment.UpdateAttachmentLink(EmailCaseMap);  
        }
        }
        
        if(caseIds.size()>0){
        GE_LGT_EM_UpdateEmailAttachment.UpdateAttachmentLink(EmailCaseMap);
        }
    }  

          
    //****START FOR BEFORE DELETE
    if(trigger.isBefore && trigger.isDelete) {
        ID sysAdminProfileID = [select id from profile where name='System Administrator'].id;
        if(UserInfo.getProfileId() != sysAdminProfileID) {
            for(EmailMessage message : trigger.old) {
                message.addError('you have no access to delete messages');
            }
        }
    }    
    //****END FOR BEFORE DELETE        
            }
            }
}
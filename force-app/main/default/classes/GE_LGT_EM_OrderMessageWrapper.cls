public class GE_LGT_EM_OrderMessageWrapper{
    public void dummyTestMethod(){   }
/** Inactivated after Tungsram carve out

public Set<String> selctdEmailMsg {get;set;}
public string Caseid=ApexPages.currentPage().getParameters().get('id');
public string Error{get;set;}
public List<EmailMessageWrapper> EmailMsgWrapper {get; set;}
private final Case cse;
Public Case c;

Public GE_LGT_EM_OrderMessageWrapper(){        
        getInboundEmails();                           
    }
    
public List<EmailMessageWrapper> getInboundEmails(){    
        if(EmailMsgWrapper==null){
        EmailMsgWrapper = new List<EmailMessageWrapper>();        
        for(EmailMessage EMesg: [select id,hasAttachment,PARENTID,SUBJECT,FROMNAME,FROMADDRESS,MessageDate,INCOMING,STATUS,HTMLBODY,TEXTBODY from EmailMessage where parentid=:Caseid and Incoming=true order by createddate DESC]) {
        EmailMsgWrapper.add(new EmailMessageWrapper(EMesg));         
      }
       if(EmailMsgWrapper.size()==0)
       Error='There are no Inbound Emails with Order/Attachments for this Case'; 
       else
       return EmailMsgWrapper;       
   }    
   return EmailMsgWrapper;
}    
    
    
public void processSelected() {
    list<EmailMessage> SelctdEmail=new list<EmailMessage>();
    for(EmailMessageWrapper EMesg: EmailMsgWrapper){
    if(EMesg.isSelected==true){
        SelctdEmail.add(EMesg.cEmailMsg);   
        }    
    }
    if(SelctdEmail.size()==1){
    
    Case cs=[select GE_LGT_EM_Order_Creation_Request_Date__c,GE_LGT_EM_Order_Email__c from case where id=:SelctdEmail[0].ParentId];
    cs.GE_LGT_EM_Order_Creation_Request_Date__c=SelctdEmail[0].Messagedate;
    cs.GE_LGT_EM_Order_Email__c=URL.getSalesforceBaseUrl().toExternalForm() + '/' + SelctdEmail[0].Id;
    update cs;
    Error='Order Date Updated';
    }
    else if(SelctdEmail.size()==0){
    Error='Please select the Email that is appropriate and click "Update Order Date" Button';    
    }
    else{
    Error='Only one Email should be Selected!';    
    }     
}   
        
public class EmailMessageWrapper{
     public Boolean isSelected {get;set;}
     public EmailMessage cEmailMsg {get;set;}

     public EmailMessageWrapper(EmailMessage cEmailMsg){
          this.cEmailMsg= cEmailMsg;    
          this.isSelected=false;      
     }
}   **/   
}
public with sharing class GE_LGT_EM_CloneCase 
{
    public Set<String> selctdEmailMsg {get;set;}
    public string Caseid=ApexPages.currentPage().getParameters().get('id');
    public string Error{get;set;}
    public List<EmailMessageWrapper> EmailMsgWrapper {get; set;}
    private final Case cse;
    Public Case c;
    public List<EmailMessage> SelctdEmail=new list<EmailMessage>();
    
    Public GE_LGT_EM_CloneCase()
    {        
        getInboundEmails();                           
    }
    
    public List<EmailMessageWrapper> getInboundEmails()
    {    
        if(EmailMsgWrapper==null)
        {
            EmailMsgWrapper = new List<EmailMessageWrapper>();        
            for(EmailMessage EMesg: [select id,hasAttachment,PARENTID,SUBJECT,FROMNAME,FROMADDRESS,MessageDate,INCOMING,STATUS,HTMLBODY,TEXTBODY from EmailMessage where parentid=:Caseid order by createddate DESC]) 
            {
                EmailMsgWrapper.add(new EmailMessageWrapper(EMesg,false));         
            }
            if(EmailMsgWrapper.size()==0)
                Error='There are no Inbound Emails with Order/Attachments for this Case'; 
            else
                return EmailMsgWrapper;       
        }    
        return EmailMsgWrapper;
    }    
    public class EmailMessageWrapper
    {
        public Boolean isSelected {get;set;}
        public EmailMessage cEmailMsg {get;set;}
        public EmailMessageWrapper(EmailMessage cEmailMsg,Boolean selFlag)
        {
            this.cEmailMsg= cEmailMsg;    
            this.isSelected=selFlag;      
        }
    }
    public PageReference cloneCase()
    {
        SelctdEmail=new list<EmailMessage>();
        for(EmailMessageWrapper EMesg: EmailMsgWrapper)
        {
            if(EMesg.isSelected==true)
            {
                SelctdEmail.add(EMesg.cEmailMsg);   
            }    
        }
        if(SelctdEmail.size()==1)
        {
            try
            {
            Error='';
            Map<String, String> labelMap = new Map<String, String>();
            Schema.DescribeSObjectResult objectDescribe  = Case.SObjectType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
            System.debug('Fields:'+fieldMap.keySet());
            List<String> fields = new List<String>(Case.SObjectType.getDescribe().fields.getMap().keySet());
            String soql = ''
                + ' SELECT  ' + String.join(fields, ',')
                + ' FROM Case'
                + ' WHERE ID=:Caseid';
            //Case oldCase=[SELECT ID,Origin,AccountID,RecordTypeID FROM Case WHERE ID=:Caseid];
            Case oldCase=Database.query(soql);
            Case newCase=oldCase.Clone(false, true, false, false);
            //newCase.ClosedDate=NULL;
            newCase.status='Open';
            newCase.suppliedEmail=NULL;
            System.debug('BeforeInsert'+newCase);
            System.debug('BeforeInsert1'+newCase.AccountID);
            insert newCase;
            System.debug('AfterInsert');
            newCase.ownerID=UserInfo.getUserID();
            newCase.suppliedEmail=oldCase.suppliedEmail;
            update newCase;
            
            Attachment[] insertAttList = new Attachment[]{};
            EmailMessage EMesg = [select id,ToAddress,hasAttachment,PARENTID,SUBJECT,FROMNAME,FROMADDRESS,MessageDate,INCOMING,STATUS,HTMLBODY,TEXTBODY from EmailMessage where ID=: SelctdEmail[0].Id];
            EmailMessage em = new EmailMessage();
            em.FromAddress = EMesg.FromAddress ;
            em.Incoming = EMesg.Incoming ;
            em.ToAddress = EMesg.ToAddress ;
            em.Subject = EMesg.Subject ;
            em.TextBody = EMesg.TextBody ;
            em.ParentId = newCase.Id;
            em.status='0';
            insert em;
            Id emailID=SelctdEmail[0].Id;
            List<String> Attfields = new List<String>(Attachment.SObjectType.getDescribe().fields.getMap().keySet());
            String Attsoql = ''
                + ' SELECT  ' + String.join(Attfields, ',')
                + ' FROM Attachment'
                + ' WHERE parentid =:emailID';
            List<Attachment> attachments=Database.query(Attsoql);
            for(Attachment a: attachments)
            {
                Attachment att = new Attachment(name = a.name, body = a.body, parentid = em.ID);
                insertAttList.add(att);
            }
            if(insertAttList.size() > 0)
            {
                insert insertAttList;
            }
            PageReference ref=new PageReference('/'+newCase.ID);
            return ref;
            }
            Catch(Exception e)
            {
                return NULL;
            }
        }
        else if(SelctdEmail.size()==0)
        {
            Error='Please select the Email that is appropriate and click "Clone" Button';
            return null;    
        }
        else{
            Error='Only one Email should be Selected!';
            return null;    
        }   
        
    }
    public PageReference close()
    {
        PageReference ref=new PageReference('/'+Caseid);
        return ref;
    }
    
    
}
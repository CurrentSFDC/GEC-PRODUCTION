public class GE_LGT_EM_CaseEmails_Controller 
{
    public string Caseid=ApexPages.currentPage().getParameters().get('id');
    public List<EmailMessage> emails{get;set;}
    
    public GE_LGT_EM_CaseEmails_Controller()
    {
        emails = [SELECT id,hasAttachment,PARENTID,SUBJECT,FROMNAME,FROMADDRESS,MessageDate,INCOMING,STATUS,HTMLBODY,TEXTBODY FROM EmailMessage WHERE parentid=:Caseid order by createddate DESC];
    }
}
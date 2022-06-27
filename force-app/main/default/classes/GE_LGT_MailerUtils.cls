/* This is a utility class which can send email(SingleEmailMessage).
This needs 3 parameters-subject,body,SentTo
Author - Neel(TechMahindra)
Creation - Aug-2015
*/

public class GE_LGT_MailerUtils {
    
    public static void sendEmailNotification(string subject ,string body,List<String> sendTo){
    
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(sendTo);

        mail.setSubject(subject);

        mail.setUseSignature(false);
        mail.setHtmlBody(body);

        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }
}
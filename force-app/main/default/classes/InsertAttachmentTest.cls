@isTest
public class InsertAttachmentTest {
static testMethod void handleInboundEmailTest() {
    
    Test.startTest();
    
  
      // Create a new email and envelope object.
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
        // Test with the subject that matches the unsubscribe statement.
        email.subject = 'test unsubscribe test';
    //email.textAttachments ='test.pdf';
        env.fromAddress = 'user@acme.com';
    
    
     // add an Binary attachment
      Messaging.InboundEmail.BinaryAttachment attachment2 = new Messaging.InboundEmail.BinaryAttachment();
      attachment2.body = blob.valueOf('my attachment text');
      attachment2.fileName = 'textfileone.txt';
     // attachment.mimeTypeSubType = 'text/plain';
    //  attachment.ParentId = c1.id;
      email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment2 };
      
      
  
      // add an Text atatchment
  /*
      Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
      attachmenttext.body = 'my attachment text';
      attachmenttext.fileName = 'textfiletwo3.txt';
     // attachmenttext.mimeTypeSubType = 'texttwo/plain';
      //attachment.ParentId = c1.id;
      email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
        // Call the class and test it with the data in the testMethod.
*/
        InsertAttachment attach=  new InsertAttachment();
        attach.handleInboundEmail(email, env);
        Test.stopTest();  
    
}
    
    static testMethod void handleInboundEmailTest11() {
     Messaging.InboundEmail email1  = new Messaging.InboundEmail();
       Messaging.InboundEnvelope env1 = new Messaging.InboundEnvelope();
      
       // Set up your data if you need to
      
       // Create the email body
       email1.plainTextBody = 'This should become a note';
       email1.subject = 'test unsubscribe test';
    //email.textAttachments ='test.pdf';
        email1.fromAddress = 'user@acme.com';
      // String contactEmail = 'jsmith@salesforce.com';
      // email.ccAddresses = new String[] {'Jon Smith <' + contactEmail + '>'};
      // email.subject = 'Dummy Account Name 123';
        
        Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();
		textAttachment.Filename = 'test.json';
        textAttachment.body = String.valueOf('my attachment text');
        //binaryattachment.mimeTypeSubType = 'text/plain';
        email1.textAttachments = new Messaging.inboundEmail.TextAttachment[] { textAttachment }; 
        
       InsertAttachment edr = new InsertAttachment();
        
	   JSON_Attachment__c ja1= new JSON_Attachment__c();
       ja1.Name='JSON File';
        
       insert ja1; 
       
       JSON_Attachment__c parentRecord = [select ID from JSON_Attachment__c LIMIT 1];

       Test.startTest();
       Messaging.InboundEmailResult result = edr.handleInboundEmail(email1, env1);
       Test.stopTest();
    
    }
    
    static testMethod void handleInboundEmailTest22() {
     Messaging.InboundEmail email2  = new Messaging.InboundEmail();
       Messaging.InboundEnvelope env2 = new Messaging.InboundEnvelope();
      
       // Set up your data if you need to
      
       // Create the email body
       email2.plainTextBody = 'This should become a note';
       email2.subject = 'test unsubscribe test';
    //email.textAttachments ='test.pdf';
        email2.fromAddress = 'user@acme.com';
      // String contactEmail = 'jsmith@salesforce.com';
      // email.ccAddresses = new String[] {'Jon Smith <' + contactEmail + '>'};
      // email.subject = 'Dummy Account Name 123';
         Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'test.json';
        binaryAttachment.body = blob.valueOf('my attachment text');
        email2.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryAttachment }; 
       // Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();
		//textAttachment.Filename = 'test.json';
       // textAttachment.body = String.valueOf('my attachment text');
        //binaryattachment.mimeTypeSubType = 'text/plain';
       // email2.textAttachments = new Messaging.inboundEmail.TextAttachment[] { textAttachment }; 
        
       InsertAttachment edr = new InsertAttachment();
        
	   JSON_Attachment__c ja2= new JSON_Attachment__c();
       ja2.Name='JSON File';
        
       insert ja2; 
       
       JSON_Attachment__c parentRecord = [select ID from JSON_Attachment__c LIMIT 1];

       Test.startTest();
       Messaging.InboundEmailResult result = edr.handleInboundEmail(email2, env2);
       Test.stopTest();
    
    }
    
    
}
public class SalsifyMetadata {
    
    @future(callout=true)
    public static void Salsify(id newAttach)
    {   
        try{
            Attachment at = [select id,body,name from Attachment where id =:newAttach order by createddate desc LIMIT 1] ;
            String fName=at.name;
            String jsonInput = at.body.toString();
            at=null;
            jsonInput='{"TEST":'+jsonInput+'}';
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
            jsonInput=Null;
            
            //system.debug(results.get('TEST'));
            List<Object> wholejson =  (List<Object>)results.get('TEST');
            results=Null;
            //List<Object> aSKU = new List<Object>();
            List<Object> aFamily = new List<Object>(); 
            Map<String, Object> prod1;
            Map<String, Object> a11;
            List<Object> a;
            for(object whole1:wholejson ){
                //  List<Object> aSKU = new List<Object>();
                //  List<Object> aFamily = new List<Object>(); 
                 prod1 = (Map<String, Object>)whole1;   
                 a =  (List<Object>)prod1.get('SKU or Family');
                // system.debug(wholejson.size());
                // system.debug(a.size());
                
                 a11 = (Map<String, Object>)a[0]; 
                //  system.debug(a11.get('external_id'));
                
                 if(a11.get('external_id') == 'Family'){
                    aFamily.add(whole1);
                    //system.debug(aFamily);   
                }
                 
            }
            wholejson=Null;
            a11=Null;
            a=Null;
            
            String fam;
            Integer count=0;
            //  string s= string.valueOf(aFamily);
             system.debug(aFamily.size());
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            Metadata.DeployContainer mdContainer2 = new Metadata.DeployContainer();

            for(object family1 :aFamily){
                
                
                prod1 = (Map<String, Object>)family1;   
                //fam=(((String.valueOf(prod1.get('Catalog Logic'))).removeStart('(')).removeEnd(')'));
                fam=(((String.valueOf(prod1.get('Family'))).removeStart('(')).removeEnd(')'));
                fam = ((fam.replace('<', 'LT')).replace('>', 'GT'));
                fam = ((fam.replace(' ', 'Z')).replace('1', 'A'));
   				 fam = ((fam.replace('2', 'B')).replace('3', 'C'));
   				 fam = ((fam.replace('4', 'D')).replace('5', 'E'));
    			fam = ((fam.replace('6', 'F')).replace('7', 'G'));
   			 fam = ((fam.replace('8', 'H')).replace('9', 'I'));
   				 fam = ((fam.replace('0', 'J')));
                if (fam.length() > 40)
				{
                fam = fam.substring(0, 39);
				}
                // system.debug(f2.size());
                // system.debug(String.valueOf(f1.get('Family').replace(' ','-')));
                // string str =
                //system.debug(f2[0]);
                // system.debug(family1);
                // string s= string.valueOf(family1);
                // system.debug(family1);
                Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
                system.debug(fam);
                customMetadata.fullName = ('Salsify_Family__mdt.'+fam.replaceAll('[^a-zA-Z0-9]', '').removeStart('480'));
                //customMetadata.fullName = ('Family_Record__mdt.'+String.valueOf(f2[0]).deleteWhitespace()+String.valueOf(f2[0]).replaceAll('[^a-zA-Z0-9\\s+]', ''));
                //customMetadata.fullName = ('Family_Record__mdt special characters removed'+String.replaceAll('[^a-zA-Z0-9\\s+]', ''));
                customMetadata.label = fam.replaceAll('[^a-zA-Z0-9]', '');
               // customMetadata.label = (String.valueOf(f2[0]).deleteWhitespace()+String.valueOf(f2[0]).replaceAll('[^a-zA-Z0-9\\s+]', ''));
                system.debug(customMetadata.fullName);
                system.debug(customMetadata.label); 
                Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
                customField.field = 'Data__c';
                // customField.value = string.valueOf(family1);
                customField.value = string.valueOf(JSON.serialize(family1));
                customMetadata.values.add(customField);
               if(Count<170){ 
                mdContainer.addMetadata(customMetadata);
                    count++;
                }
                else{
                     mdContainer2.addMetadata(customMetadata);
                    count++; 
                }
            }            
            
            System.debug(count);
            aFamily=Null;
           
            
            
      
    
            //CustomMetadataCallback callback2 = new CustomMetadataCallback();
            //Id jobId2 = Metadata.Operations.enqueueDeployment(mdContainer2,Null);
           
        
           // SalsifySendLogs.MetaUpd(mdContainer2);
            
            // CustomMetadataCallback callback = new CustomMetadataCallback();
             Id jobId = Metadata.Operations.enqueueDeployment(mdContainer,null);
           // SendLog();
           // SalsifySendLogs.SendLog();
            
         /*  ApexLog al = [SELECT Id, LogUserId, LogUser.Name, Request, Operation, Application, Status, StartTime, Location,LogLength FROM ApexLog WHERE Operation = 'QueueableHandler'order by LastModifiedDate desc LIMIT 1];

            // Set HTTPRequest Method
            HttpRequest req = new HttpRequest();
            req.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v45.0/sobjects/ApexLog/' + al.id + '/Body');
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            
            // Execute web service call
            Http http = new Http();
            HTTPResponse res = http.send(req);
            String str = String.valueOf(res.getBody());
            
            //System.debug(res.getBody());
            System.debug('str************'+str);*/
          /*  
            messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] {'ravi.singh@gecurrent.com','sagar.suryawanshi@gecurrent.com','deepika.sinha@gecurrent.com'};
            message.optOutPolicy = 'FILTER';
            message.subject = 'Custom metadata updates from Salsify JSON feed: Successful';
            message.plainTextBody = 'Custom metadata Family records have been successfully updated as per latest JSON feed: '+fName;
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] result1 = Messaging.sendEmail(messages);
        */    
        }
        
        catch (Exception e){
            messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            //message.toAddresses = new String[] {'ravi.singh@gecurrent.com','sagar.suryawanshi@gecurrent.com','deepika.sinha@gecurrent.com'};
            message.toAddresses = new String[] {'salsify.support@gecurrent.com'};
            message.optOutPolicy = 'FILTER';
            message.subject = 'Custom metadata updates from Salsify JSON feed: JOB ABORTED!!!';
            message.plainTextBody = 'The following exception has occurred:' + e.getMessage();
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] result1 = Messaging.sendEmail(messages);
        }
        /*
Family_Record__mdt rec= [select id,Record__c from Family_Record__mdt where MasterLabel='ABC'];
// String record1 = rec.Record__c.toString();
Map<String, Object> rec1= (Map<String, Object>) JSON.deserializeUntyped(rec.Record__c);
system.debug(rec1);
system.debug(rec1.get('Website Link'));
system.debug(rec1.get('Associated Parts'));
system.debug(rec1.get('Manufacturer'));

*/
        
    }
   /* public static void SendLog(){
        ApexLog al = [SELECT Id, LogUserId, LogUser.Name, Request, Operation, Application, Status, StartTime, Location,LogLength FROM ApexLog WHERE Operation = 'QueueableHandler'order by LastModifiedDate desc LIMIT 1];

            // Set HTTPRequest Method
            HttpRequest req = new HttpRequest();
            req.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v45.0/sobjects/ApexLog/' + al.id + '/Body');
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            
            // Execute web service call
            Http http = new Http();
            HTTPResponse res = http.send(req);
            String str = String.valueOf(res.getBody());
            
            //System.debug(res.getBody());
            System.debug('str************'+str);
        
            messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] {'ravi.singh@gecurrent.com','sagar.suryawanshi@gecurrent.com','deepika.sinha@gecurrent.com'};
            message.optOutPolicy = 'FILTER';
            message.subject = 'Custom metadata updates from Salsify JSON feed: Successful';
            message.plainTextBody = 'Custom metadata Family records have been successfully updated as per latest JSON feed: '+str;
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] result1 = Messaging.sendEmail(messages);
        
        
    } */

    
    
}
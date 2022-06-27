@IsTest 
/*   Called from GE_LGT_EM_EmailserviceToCase - opting out since Tungsram exit
*/
private class GE_LGT_EM_EmailServiceSibelToCase_Test
{
    static testMethod void EmailToCaseTestMethod()
    {
        List<TriggerSwitch__c> switchList=TestDataUtil.insertTriggerSwitches();
        insert switchList;
        
        //Creating testing instance for inbound email and Envelop.
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
 /*
        Account acc=new Account(name='test ABC',GE_LGT_EM_SAP_Customer_Number__c='7777',GE_LGT_EM_Sales_Org__c='2BE1'); 
        insert acc;
        Account acc1=new Account(name='test ABC',GE_LGT_EM_SAP_Customer_Number__c='007777',GE_LGT_EM_Sales_Org__c='2BE1'); 
        insert acc1;
        // Set up your test data if you need to 
        
        email.fromname = 'FirstName LastName';
        env.fromAddress = 'someaddress@email.com';
        env.toAddress= 'geemea@email.com';
        string mToAddressBefore = env.toAddress.subString(0,env.toAddress.indexOf('@'));
        email.plainTextBody='[THREAD ID:THID00123]; SAP Customer Number:7777; Siebel Complaint Number:SB00123; Sales Organization:2BE1;';
        string  myPlainText = email.plainTextBody;
        
        string ThreadId =myPlainText.substringafter('[THREAD ID:').trim();
        string Tid=ThreadId.subString(0,ThreadId.indexOf(']')); 
        system.debug('Tid----->'+Tid);
        
        string SAPId =myPlainText.substringafter('SAP Customer Number:').trim();
        string SAid=SAPId.subString(0,SAPId.indexOf(';')); 
        system.debug('SAid----->'+SAid);
        string leadingwithzero='00'+SAid;
        
        string SiebelId =myPlainText.substringafter('Siebel Complaint Number:').trim();
        string Sid=SiebelId.subString(0,SiebelId.indexOf(';')); 
        system.debug('Sid----->'+Sid);
        
        string SalesOrg=myPlainText.substringafter('Sales Organization:').trim();
        string Sorg=SalesOrg.subString(0,SalesOrg.indexOf(';')); 
        system.debug('Sorg----->'+Sorg);
        
        string concatSAidSorg=SAid+Sorg;
        
        Account accobj=[Select id,name from account where id=:acc.id ]; 
        
        
        // Custom settings test 
        GE_LGT_EM_CaseRegion__c customObj=new GE_LGT_EM_CaseRegion__c();
        customObj.name='geemea';
        insert customObj;
        
        customObj.name=mToAddressBefore;
        RecordType rt = [Select id,DeveloperName From RecordType  Where SobjectType = 'Case' and DeveloperName=:customObj.name]; 
        // insert test data in case object
        Case CaseObj=new case(Status='new',
                              Origin='Email',
                              RecordTypeid=rt.id,
                              AccountId=accobj.id,
                              Subject = email.subject,
                              GE_LGT_EM_FromName__c=email.fromname,
                              Description=email.plainTextBody, 
                              GE_LGT_EM_Salesorg__c=Sorg,
                              GE_LGT_EM_SeibelComplaintId__c=Sid,
                              GE_LGT_EM_SiebelThreadID__c=Tid,
                              GE_LGT_EM_ToAddress__c=env.toAddress,
                              GE_LGT_EM_FromAddress__c=env.fromAddress);
        insert CaseObj;
        
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf(myPlainText );
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
            Attachment att=new attachment();
        att.ParentId=CaseObj.Id;
        att.Name = attachment.fileName; 
        att.Body = attachment.body; 
        insert att;
        Account testacc=[select id,GE_LGT_EM_SAP_Customer_Number__c from Account where id=:acc.id limit 1];
         System.assertEquals('7777',testacc.GE_LGT_EM_SAP_Customer_Number__c);
*/       
        // setup controller object
        GE_LGT_EM_EmailserviceToCase edr = new GE_LGT_EM_EmailserviceToCase();
        Messaging.InboundEmailResult result = edr.handleInboundEmail(email, env);
    }  
}
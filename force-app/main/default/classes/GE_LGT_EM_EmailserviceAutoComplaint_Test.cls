@IsTest
private class GE_LGT_EM_EmailserviceAutoComplaint_Test
{
    static testMethod void AutoEmailToCaseTestMethod()
    {
        List<TriggerSwitch__c> switchList=TestDataUtil.insertTriggerSwitches();
        insert switchList;
        
        //Creating testing instance for inbound email and Envelop.
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // Set up your test data if you need to 
 /*       
        email.fromname = 'FirstName LastName';
        email.subject='Auto complaint to SFDC - DTL';
        env.fromAddress = 'someaddress@email.com';
        env.toAddress= 'geemea@email.com';
        string mToAddressBefore = env.toAddress.subString(0,env.toAddress.indexOf('@'));
        email.plainTextBody='[Case ID:0000123; Disputed amount:5483.100; Sales Org:2FR1; Customer number:302013; Document number:912035; Currency:EUR; FSCM Contact:4589555; Company code:E90;]';
        string  myPlainText = email.plainTextBody;
        
        // Tracking values from email body   
        string CaseID =myPlainText.substringafter('Case ID:').trim();
        string Cid=CaseID.subString(0,CaseID.indexOf(';')); 
        system.debug('Cid----->'+Cid);
        
        string Salesorg =myPlainText.substringafter('Sales Org:').trim();
        string Sorg=Salesorg.subString(0,Salesorg.indexOf(';')); 
        system.debug('Sorg----->'+Sorg);
        
        string CustomerNo =myPlainText.substringafter('Customer number:').trim();
        string CNo=CustomerNo.subString(0,CustomerNo.indexOf(';')); 
        system.debug('CNo----->'+CNo);
        
        string DocNumber =myPlainText.substringafter('Document number:').trim();
        string DNo=DocNumber.subString(0,DocNumber.indexOf(';')); 
        system.debug('DNo----->'+DNo);
        
        string IsoCurrency =myPlainText.substringafter('Currency:').trim();
        string Curr=IsoCurrency .subString(0,IsoCurrency.indexOf(';')); 
        system.debug('Curr----->'+Curr);
        
        string FSCMContact=myPlainText.substringafter('FSCM Contact:').trim();
        string FSCM=FSCMContact.subString(0,FSCMContact.indexOf(';')); 
        system.debug('FSCM----->'+FSCM);
        
        string Companycode=myPlainText.substringafter('Company code:').trim();
        string Ccode=Companycode.subString(0,Companycode.indexOf(';')); 
        system.debug('Ccode----->'+Ccode);
        
        string Disuptedamount =myPlainText.substringafter('Disputed amount:').trim();
        string Damount=Disuptedamount.subString(0,Disuptedamount.indexOf(';')); 
        system.debug('Damount----->'+Damount);
        
        string mail='@mail.ad.ge.com';
        string FSCMemailAdd=FSCM+mail;  
        system.debug('FSCMemailAdd----->'+FSCMemailAdd);
        
        
        string sub=email.subject;
        string FSCMCatagory=sub.substringafter('Auto complaint to SFDC -').trim();
        system.debug('FSCMCatagory----->'+FSCMCatagory);
        string catval='DTL';
        string catval2='ITS';
        
        //concatenate in customer number and sales org for find unique values in account object.
      
        
        Account acc = TestDataUtil.createAccount();
        acc.name='test123';
        acc.GE_LGT_EM_SAP_Customer_Number__c='302013';
        acc.GE_LGT_EM_Sales_Org__c='2FR1';
        insert acc;    
        
        GE_LGT_EM_InvoiceHeader__c inv=new GE_LGT_EM_InvoiceHeader__c(GE_LGT_EM_Payer_SoldTo_Account_Number__c='302013',GE_LGT_EM_SAPInvoiceNumber__c='912035');      
        insert inv;
        
        
        Account accobj=[Select id,GE_LGT_EM_Sales_Org__c,GE_LGT_EM_SAP_Customer_Number__c,name,GE_LGT_EM_Company_Code__c from account where id=:acc.id limit 1];
        System.assertEquals('0000302013',accobj.GE_LGT_EM_SAP_Customer_Number__c);
        GE_LGT_EM_InvoiceHeader__c headerobj=[Select id,GE_LGT_EM_CaseID__c,GE_LGT_EM_Payer_SoldTo_Account_Number__c,GE_LGT_EM_SAPInvoiceNumber__c,GE_LGT_EM_FSCM_Contact__c from GE_LGT_EM_InvoiceHeader__c where GE_LGT_EM_Payer_SoldTo_Account_Number__c=:CNo and GE_LGT_EM_SAPInvoiceNumber__c=:DNo limit 1];
        if(headerobj.GE_LGT_EM_Payer_SoldTo_Account_Number__c==CNo && headerobj.GE_LGT_EM_SAPInvoiceNumber__c==DNo)
        {
            headerobj.GE_LGT_EM_CaseID__c=Cid;
            headerobj.GE_LGT_EM_FSCM_Contact__c=FSCMemailAdd;
        }
        Update headerobj;
        
       
        RecordType rt = [Select id,DeveloperName From RecordType Where SobjectType = 'Case' and DeveloperName='GE_LGT_EM_EMEA_Auto_Complaint'];        
        case Caseobj= new case(); 
        
        if(rt.DeveloperName=='GE_LGT_EM_EMEA_Auto_Complaint')
        {
            Caseobj.Status='new';
            Caseobj.Origin='Email';
            Caseobj.RecordTypeid=rt.id;
            Caseobj.AccountId=accobj.id;
            Caseobj.Subject = email.subject;
            Caseobj.GE_LGT_EM_FromName__c=email.fromname;
            Caseobj.Description=email.plainTextBody; 
            Caseobj.GE_LGT_EM_Salesorg__c=Sorg;
            Caseobj.GE_LGT_EM_Customer_Reference_Number__c=CNo;
            Caseobj.GE_LGT_EM_Document_Number__c=DNo;
            Caseobj.GE_LGT_EM_FSCM_Contact__c=FSCMemailAdd; 
            Caseobj.GE_LGT_EM_Disputed_Amount__c=Decimal.valueof(Damount);
            Caseobj.CurrencyIsoCode=Curr;
            Caseobj.GE_LGT_EM_ToAddress__c=env.toAddress;
            Caseobj.GE_LGT_EM_FromAddress__c=env.fromAddress;
            if(FSCMCatagory.equals(catval))
            {
                Caseobj.FSCM_Category__c=catval; 
                system.debug('FSCMCatagoryval----->'+Caseobj.FSCM_Category__c);
            }
            else if(FSCMCatagory.equals(catval2))
            {
                Caseobj.FSCM_Category__c=catval2;
                system.debug('FSCMCatagoryval2----->'+Caseobj.FSCM_Category__c);
            }
            else
            {
                
            }
            insert CaseObj;
        } 
        // add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[]{ attachment };
            
            Attachment att=new attachment();
        att.ParentId=CaseObj.Id;
        att.Name = attachment.fileName; 
        att.Body = attachment.body; 
        insert att;
        
        // setup controller object
*/
        GE_LGT_EM_EmailserviceAutoComplaint edr = new GE_LGT_EM_EmailserviceAutoComplaint();
        Messaging.InboundEmailResult result = edr.handleInboundEmail(email,env);
    }  
}
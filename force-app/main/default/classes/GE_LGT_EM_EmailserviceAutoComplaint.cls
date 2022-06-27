/*
###########################################################################
### turned out as after Tungsram carve out it is not in use (not used since 2017)
# File..................:GE_LGT_EM_EmailserviceAutoComplaint
# Version...............: 1.0
# Created by............:Murugan
# Created Date..........: 
# Description...........: This class is used to create for Case creation from SAP using email services.  
#                         1) It has tracking email body,from address and attachments.
#  Example:
Case ID: 3000204;
Sales Org: 2ES1;
Customer number: 0043014600;
Document number: 1144000027;
Disputed amount: 2940.88;
Currency: EUR;
Company code: E4C;
Date created: 28.02.2014 06:37:21;
FSCM Contact: 212309663@mail.ad.ge.com;
            
*/

global class GE_LGT_EM_EmailserviceAutoComplaint implements Messaging.InboundEmailHandler {
 /*
 //**** declaration part Starts here ****
 
        String mFromEmail;
        String mCaseObject;
        String m_Toaddress;
        String EMfromName;
        case Caseobj= new case();
        list<Case>insertObj=new list<Case>(); 
        Map<Id,GE_LGT_EM_InvoiceHeader__c> insertFscmemail=new Map<Id,GE_LGT_EM_InvoiceHeader__c>();
        String mToAddressBefore;
                
        String myPlainText= '';
        
   //**** declaration end here ****     
 */  
        global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
        Messaging.InboundEnvelope envelope) {
        
            Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
 /*
            mToAddressBefore = envelope.toAddress.subString(0,envelope.toAddress.indexOf('@'));
            m_Toaddress = mToAddressBefore;
            mFromEmail = envelope.fromAddress;
            myPlainText = email.plainTextBody;//email body getting here
            EMfromName=email.fromName;
            system.debug('EMfromName----> '+EMfromName);
            system.debug('Toaddress ----> '+m_Toaddress);
            system.debug('mFromEmail ----> '+mFromEmail );
            
            // Tracking values from email body   
            string CaseID =myPlainText.substringafter('Case ID:').trim();
            string Cid=CaseID.subString(0,CaseID.indexOf(';')); 
            system.debug('Cid----->'+Cid);
           
          // string Dupcid=CaseID ;
            string cidnew=Cid.substring(0,7);
            string Salesorg =myPlainText.substringafter('Sales Org:').trim();
            string Sorg=Salesorg.subString(0,Salesorg.indexOf(';')); 
            system.debug('Sorg----->'+Sorg);
            
            string CustomerNo =myPlainText.substringafter('Customer number:').trim();
            string CNo=CustomerNo.subString(0,CustomerNo.indexOf(';')); 
            system.debug('CNo----->'+CNo);
            
            string DocNumber =myPlainText.substringafter('Document number:').trim();
            string DNo=DocNumber.subString(0,DocNumber.indexOf(';')); 
            system.debug('DNo----->'+DNo);
            
            string Disuptedamount =myPlainText.substringafter('Disputed amount:').trim();
            string Damount=Disuptedamount.subString(0,Disuptedamount.indexOf(';')); 
            system.debug('Damount----->'+Damount);
                       
            string IsoCurrency =myPlainText.substringafter('Currency:').trim();
            string Curr=IsoCurrency .subString(0,IsoCurrency.indexOf(';')); 
            system.debug('Curr----->'+Curr);
            
            string FSCMContact=myPlainText.substringafter('FSCM Contact:').trim();
            string FSCM=FSCMContact.subString(0,FSCMContact.indexOf(';')); 
            system.debug('FSCM----->'+FSCM);
            
            string Companycode=myPlainText.substringafter('Company code:').trim();
            string Ccode=Companycode.subString(0,Companycode.indexOf(';')); 
            system.debug('Ccode----->'+Ccode);
            
            string mail='@mail.ad.ge.com';
            string FSCMemailAdd=FSCM+mail;   
            
            string sub=email.subject;
            string FSCMCatagory=sub.substringafter('Auto complaint to SFDC -').trim();
            system.debug('FSCMCatagory----->'+FSCMCatagory);
            string catval='DTL';
            string catval2='ITS';
            
            
            
            //concatenate in customer number and sales org for find unique values in account object.
             //string concatCusNoSorg=CNo+Sorg;
             
            //system.debug('concatCusNoSorg----->'+concatCusNoSorg);
        
             Account accobj=[Select id,name,GE_LGT_EM_Sales_Org__c,GE_LGT_EM_Company_Code__c from account where GE_LGT_EM_SAP_Customer_Number__c =:CNo and GE_LGT_EM_Company_Code__c=:Ccode limit 1];
             System.debug('accobj------>>>'+accobj.name);
             System.debug('accobj------>>>'+accobj.GE_LGT_EM_Sales_Org__c);
             
            list<GE_LGT_EM_InvoiceHeader__c> headerobj=[Select id,GE_LGT_EM_CaseID__c,GE_LGT_EM_Payer_SoldTo_Account_Number__c,GE_LGT_EM_SAPInvoiceNumber__c,GE_LGT_EM_FSCM_Contact__c from GE_LGT_EM_InvoiceHeader__c where GE_LGT_EM_Payer_SoldTo_Account_Number__c=:CNo and GE_LGT_EM_SAPInvoiceNumber__c=:DNo limit 1];
            System.debug('headerobj----->'+headerobj);
            list<case>dupcaseid=[Select GE_LGT_EM_CaseID__c from Case where GE_LGT_EM_CaseID__c=:cidnew];
            System.debug('dupcaseid----->'+dupcaseid.size());
            for(GE_LGT_EM_InvoiceHeader__c IH:headerobj){
                if(IH.GE_LGT_EM_Payer_SoldTo_Account_Number__c==CNo && IH.GE_LGT_EM_SAPInvoiceNumber__c==DNo){
                    IH.GE_LGT_EM_CaseID__c=Cid;
                    IH.GE_LGT_EM_FSCM_Contact__c=FSCMemailAdd;
                    insertFscmemail.put(IH.id,IH);
                }
            }
            if(dupcaseid.size()==0) { 
            if(insertFscmemail.size()>0){
                System.debug('insertFscmemail----->'+insertFscmemail.size());
                 update insertFscmemail.values();
            }
           } 
            
            id devRecordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByName().get('FSCM Auto Complaint EMEA').getRecordTypeId();  
            System.debug('caseRecordtype----->'+devRecordTypeId);
                  
                if(devRecordTypeid != null){
                   
                    Caseobj.Status='Open';
                    Caseobj.Origin='Email';
                    Caseobj.RecordTypeid=devRecordTypeId;
                    Caseobj.AccountId=accobj.Id;
                    //Caseobj.GE_LGT_EM_CaseID__c=Cid;
                    Caseobj.Subject=email.subject;
                    Caseobj.GE_LGT_EM_FromName__c=EMfromName;
                    Caseobj.Description=myPlainText; 
                    if(Sorg=='' || Sorg==null ){
                    Caseobj.GE_LGT_EM_Salesorg__c=accobj.GE_LGT_EM_Sales_Org__c;
                    }else
                    {
                    Caseobj.GE_LGT_EM_Salesorg__c=Sorg;
                    }
                    Caseobj.GE_LGT_EM_Customer_Reference_Number__c=CNo;
                    Caseobj.GE_LGT_EM_Document_Number__c=DNo;
                    Caseobj.GE_LGT_EM_Disputed_Amount__c=Decimal.valueof(Damount);
                    Caseobj.CurrencyIsoCode=Curr;
                    Caseobj.GE_LGT_EM_ToAddress__c=m_Toaddress;
                    Caseobj.GE_LGT_EM_FromAddress__c=mFromEmail;
                    Caseobj.GE_LGT_EM_FSCM_Contact__c=FSCMemailAdd; 
                    if(FSCMCatagory.equals(catval)){
                    Caseobj.FSCM_Category__c=catval; 
                    system.debug('FSCMCatagoryval----->'+Caseobj.FSCM_Category__c);
                    }
                    else if(FSCMCatagory.equals(catval2))
                    {
                    Caseobj.FSCM_Category__c=catval2;
                    system.debug('FSCMCatagoryval2----->'+Caseobj.FSCM_Category__c);
                    }
                    else{}
                          
                    System.debug('case----->'+Caseobj);
                          
                    insertObj.add(Caseobj);// adding all values in the list of collection
                                 
                   }
             if(dupcaseid.size()==0) {                  
                if(insertObj.size()>0){
                   
                    insert insertObj ;//insert data to case object
                 }                           
          }
          
           //*** Save any Binary Attachment ***/////
 /*        if (email.binaryAttachments != null){
         
            for(Messaging.Inboundemail.BinaryAttachment bAttachment :email.binaryAttachments){ 
            Attachment attachment = new Attachment(); 
               // if(bAttachment.filename.endsWith('.pdf'))
                    attachment.Name = bAttachment.fileName; 
                    attachment.Body = bAttachment.body; 
                    attachment.ParentId = Caseobj.Id; 
                    System.debug('BinaryAttachment ----->'+bAttachment);    
                    insert attachment; //Insert attachment for particular case.
             } 
           
         }          
   */           
            result.success = true;
            return result;  
           
  }

     
}
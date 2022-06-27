/*
###########################################################################
## this is turned off as part of Tungsram exit
# File..................:GE_LGT_EM_EmailserviceToCase
# Version...............: 1.0
# Created by............:Murugan
# Created Date..........: 
# Description...........: This class is used to create for Case creation from Siebel using email services.  
#                         1) It has tracking email body,from address and attachments.
#               
*/

global class GE_LGT_EM_EmailserviceToCase implements Messaging.InboundEmailHandler {
 
 
 //**** declaration part Starts here ****
        String mFromEmail;
        String mCaseObject;
        String m_Toaddress;
        String EMfromName;
        
        String mToAddressBefore;
        case Caseobj= new case();
        list<Case>insertObj=new list<Case>(); 
        List<String> countryNames = new List<String>();
        String myPlainText= '';
        
//**** declaration ends Starts here **** 
     
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
            string ThreadId =myPlainText.substringafter('[THREAD ID:').trim();
            string Tid=ThreadId.subString(0,ThreadId.indexOf(']')); 
            system.debug('Tid----->'+Tid);
            
            string SAPId =myPlainText.substringafter('SAP Customer Number:').trim();
            string SAid=SAPId.subString(0,SAPId.indexOf(';')); 
            system.debug('SAid----->'+SAid);
             string leadingwithzero='00'+SAid;
              system.debug('leadingwithzero----->'+leadingwithzero);
            
            string SiebelId =myPlainText.substringafter('Siebel Complaint Number:').trim();
            string Sid=SiebelId.subString(0,SiebelId.indexOf(';')); 
            system.debug('Sid----->'+Sid);
           
            
            string SalesOrg=myPlainText.substringafter('Sales Organization:').trim();
            string Sorg=SalesOrg.subString(0,SalesOrg.indexOf(';')); 
            system.debug('Sorg----->'+Sorg);
            
            //concatenate in customer number and sales org for find unique values in account object.
            string concatSAidSorg=SAid+Sorg;
            system.debug('Sorgcon----->'+concatSAidSorg);
            
            map<string,GE_LGT_EM_CaseRegion__c> CaseRegionmap=GE_LGT_EM_CaseRegion__c.getall();
            Account accobj=[Select id,name,GE_LGT_EM_Sales_Org__c,GE_LGT_EM_SAP_Customer_Number__c from account where GE_LGT_EM_SAP_Customer_Number__c =:leadingwithzero limit 1];
            System.debug('accobj------>>>'+accobj.name);
            countryNames.addAll(CaseRegionmap.keySet());              
          
            for (String countryName : countryNames){ 
                        
                        if(countryName==m_Toaddress){
                        
                            RecordType rt = [Select id,DeveloperName From RecordType  Where SobjectType = 'Case' and DeveloperName=:countryName ]; 
                            Caseobj.Status='Open';
                            Caseobj.Origin='Email';
                            Caseobj.RecordTypeid=rt.id;
                            Caseobj.AccountId=accobj.Id;
                            Caseobj.Subject=email.subject;
                            Caseobj.GE_LGT_EM_FromName__c=EMfromName;
                            Caseobj.Description=myPlainText; 
                             if(Sorg=='' || Sorg==null ){
                               Caseobj.GE_LGT_EM_Salesorg__c=accobj.GE_LGT_EM_Sales_Org__c;
                             }
                             else{
                            Caseobj.GE_LGT_EM_Salesorg__c=Sorg;
                            }
                            Caseobj.GE_LGT_EM_SeibelComplaintId__c=Sid;
                            Caseobj.GE_LGT_EM_SiebelThreadID__c=Tid;
                            Caseobj.GE_LGT_EM_ToAddress__c=m_Toaddress;
                            Caseobj.GE_LGT_EM_FromAddress__c=mFromEmail; 
                            
                            insertObj.add(Caseobj);// adding all values in the list of collection
                                 
                   }
                
                }
                        if(insertObj.size()>0){
                             insert insertObj ;//Insert data into case object
                            }
                           
       
          
/** Save any Binary Attachment ***/////
/*         if (email.binaryAttachments != null){
         
            for(Messaging.Inboundemail.BinaryAttachment bAttachment :email.binaryAttachments){ 
            Attachment attachment = new Attachment(); 
                 
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
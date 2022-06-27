/*
###########################################################################
# File..................:GE_LGT_EM_CaseComplaint171Webservice
# Version...............: 1.0
# Created by............:Murugan
# Created Date..........: 
# Description...........: This class is used to send Flaging(Dispute)from SFDC to SAP using Soap based webservices integration.  
#                         
#               
*/

public class GE_LGT_EM_CaseComplaint171Webservice{
    
    //Specify the method to make the callout to external systems executed asynchronously.
    @future(callout = true)
    public static void SfdcTOSapCaseComplaint171(set<string>cid){
        try{
            GE_LGT_EM_ComplaintLineItem__c CLIObj=[select id,Name,
                                                   GE_LGT_EM_CaseNumber__r.GE_LGT_EM_CaseID__c,
                                                   GE_LGT_EM_SAPInvoiceNumber__c,
                                                   GE_LGT_EM_CaseNumber__r.Account.GE_LGT_EM_SAP_Customer_Number__c,
                                                   GE_LGT_EM_CaseNumber__r.Account.GE_LGT_EM_Company_Code__c,
                                                   CreatedDate
                                                   from GE_LGT_EM_ComplaintLineItem__c where Id=:cid];
            
            //call your webservice method and pass all parameters to it
            
            gelightingComFi171SfdcComplaintcase.SI_SFDC_ComplaintCases_171_OB_ASYNCPort mainclass = new gelightingComFi171SfdcComplaintcase.SI_SFDC_ComplaintCases_171_OB_ASYNCPort();
            
            gelightingComFi171SfdcComplaintcase.DT_SFDC_ComplaintCases caseRequest= new gelightingComFi171SfdcComplaintcase.DT_SFDC_ComplaintCases();
            gelightingComFi171SfdcComplaintcase.RecordSet_element RecordSetEle = new gelightingComFi171SfdcComplaintcase.RecordSet_element();
            List<gelightingComFi171SfdcComplaintcase.RecordSet_element> RecordSetResponse = new List<gelightingComFi171SfdcComplaintcase.RecordSet_element>();
            List<gelightingComFi171SfdcComplaintcase.RecordSet_element> ListRecordSet = new List<gelightingComFi171SfdcComplaintcase.RecordSet_element>();
            mainclass.inputHttpHeaders_x = new Map<String, String>();
            mainclass.clientCertName_x='GE_Lighting_EMEA_CA';
            mainclass.inputHttpHeaders_x = new Map<String, String>();
            
            //from custom settings getting username&password data
            
            GE_LGT_EM_SAP_Authorization__c myCS1 = GE_LGT_EM_SAP_Authorization__c.getall().values();
            String myCCVal = myCS1.SAP_Password__c;
            String myCCVa2 = myCS1.SAP_Username__c;
            system.debug('-------->'+myCCVal);
            system.debug('-------->'+myCCVa2);
            Blob headerValue = Blob.valueOf(myCCVa2+':'+myCCVal);
            String authorizationHeader = 'Basic ' +EncodingUtil.base64Encode(headerValue);
            system.debug('-------->'+authorizationHeader);
            
            mainclass.inputHttpHeaders_x.put('Authorization',authorizationHeader);
            mainclass.timeout_x=120000; 
            
            Datetime myDT =CLIObj.CreatedDate;
            String myDate = myDT.format('yyyy');
            system.debug('------>'+myDate);
            
            //SAP all parameter mapping to SFDC  
            
            RecordSetEle.CaseType='Z_CC';
            
            string s=CLIObj.GE_LGT_EM_CaseNumber__r.GE_LGT_EM_CaseID__c+CLIObj.name;
            system.debug('string------>'+s);
            // s=s.substring(3);
            RecordSetEle.CaseIDNumber=s;
            RecordSetEle.DocumentNumber=CLIObj.GE_LGT_EM_SAPInvoiceNumber__c;
            RecordSetEle.CustomerNumber=CLIObj.GE_LGT_EM_CaseNumber__r.Account.GE_LGT_EM_SAP_Customer_Number__c;
            RecordSetEle.CompanyCode=CLIObj.GE_LGT_EM_CaseNumber__r.Account.GE_LGT_EM_Company_Code__c;
            RecordSetEle.FiscalYear=myDate; 
            ListRecordSet.add(RecordSetEle);
            
            caseRequest.RecordSet=ListRecordSet;
            system.debug('RequestRecordSet --------------->'+ caseRequest.RecordSet);
            RecordSetResponse=mainclass.SI_SFDC_ComplaintCases_171_OB_ASYNC(ListRecordSet);
            system.debug('Response --------------->'+RecordSetResponse);
            
        }
        catch(CalloutException e){
            
            //if we getting any webservices callout errors to insert in errorlog object
            GE_LGT_EM_ErrorLog__c newexc=new GE_LGT_EM_ErrorLog__c();
            
            newexc.GE_LGT_EM_Description__c=e.getMessage();
            
            insert newexc; 
            
        }
    }
}
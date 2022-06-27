/*
###########################################################################
# File..................:GE_LGT_EM_SAPWebservice
# Version...............: 1.0
# Created by............:Murugan
# Created Date..........: 
# Description...........:433-Integration-(This class is used for send Credit and Debit memo request from SFDC to SAP using Soap based webservices integration).  
#                         
#               
*/

public class GE_LGT_EM_SAPWebservice{
    
    public static boolean blnflag=false; 
    
    //Specify the method to make the callout to external systems executed asynchronously.
    @future(callout = true)
    public static void SfdcTOSapwebservice(set<string>cid)
    {  
        try{
            List<GE_LGT_EM_ComplaintLineItem__c> CLIObjList=[select id,
                                                             GE_LGT_EM_CaseNumber__r.GE_LGT_EM_CaseID__c,
                                                             Name,
                                                             GE_LGT_EM_SAPInvoiceNumber__c,
                                                             GE_LGT_EM_Ref_InvoiceLineItem__r.GE_LGT_EM_SAP_LineItemNumber__c,
                                                             GE_LGT_EM_ApprovedQuantity__c,
                                                             GE_LGT_EM_InvoicedPrice__c,
                                                             GE_LGT_EM_ApprovedUnitPrice__c,
                                                             GE_LGT_EM_CaseNumber__r.Account.GE_LGT_EM_SAP_Customer_Number__c,
                                                             GE_LGT_EM_CaseNumber__r.Account.GE_LGT_EM_Distribution_Channel__c, 
                                                             GE_LGT_EM_CaseNumber__r.Account.GE_LGT_EM_Division__c,
                                                             GE_LGT_EM_Ref_InvoiceLineItem__r.GE_LGT_EM_InvoiceHeaderNumber__r.GE_LGT_EM_Distribution_Channel__c,
                                                             GE_LGT_EM_Ref_InvoiceLineItem__r.GE_LGT_EM_InvoiceHeaderNumber__r.GE_LGT_EM_Division__c,
                                                             GE_LGT_EM_Doc_Type__c,
                                                             GE_LGT_EM_Category__c,
                                                             GE_LGT_EM_Sales_Org__c,
                                                             GE_LGT_EM_Block_CR__c,
                                                             GE_LGT_EM_Rejection_Code__c,
                                                             GE_LGT_EM_SAP_Material_Number__c,
                                                             GE_LGT_EM_Approved_Price_Unit__c, 
                                                             GE_LGT_EM_Manual_Invoice_Number__c   
                                                             from GE_LGT_EM_ComplaintLineItem__c where Id in:cid];
            
            //call your webservice method and pass all parameters to it
            
            gelightingComCom433Crdbmemorequest.SI_SFDC_CrDbMemoRequest_433_OB_ASYNCPort GELGTmainclass = new gelightingComCom433Crdbmemorequest.SI_SFDC_CrDbMemoRequest_433_OB_ASYNCPort();
            
            gelightingComCom433Crdbmemorequest.DT_SFDC_CrDbMemoRequest DtCrdbRequest= new gelightingComCom433Crdbmemorequest.DT_SFDC_CrDbMemoRequest();
            gelightingComCom433Crdbmemorequest.RecordSet_element RecordSet1; 
            List<gelightingComCom433Crdbmemorequest.RecordSet_element> RecordSetResponse = new List<gelightingComCom433Crdbmemorequest.RecordSet_element>();
            List<gelightingComCom433Crdbmemorequest.RecordSet_element> ListRecordSet = new List<gelightingComCom433Crdbmemorequest.RecordSet_element>();
            GELGTmainclass.inputHttpHeaders_x = new Map<String, String>();
            GELGTmainclass.clientCertName_x='GE_Lighting_EMEA_CA';
            GELGTmainclass.inputHttpHeaders_x = new Map<String, String>();
            
            //from custom settings getting username&password data
            
            GE_LGT_EM_SAP_Authorization__c myCS1 = GE_LGT_EM_SAP_Authorization__c.getall().values();
            String myCCVal = myCS1.SAP_Password__c;
            String myCCVa2 = myCS1.SAP_Username__c;
            system.debug('-------->'+myCCVal);
            system.debug('-------->'+myCCVa2);
            Blob headerValue = Blob.valueOf(myCCVa2+':'+myCCVal);
            String authorizationHeader = 'Basic ' +EncodingUtil.base64Encode(headerValue);
            system.debug('-------->'+authorizationHeader);
            
            GELGTmainclass.inputHttpHeaders_x.put('Authorization',authorizationHeader);
            GELGTmainclass.timeout_x=120000; 
            
            //SAP all parameter mapping to SFDC
            for(GE_LGT_EM_ComplaintLineItem__c clitem : CLIObjList)
            {
                RecordSet1 = new gelightingComCom433Crdbmemorequest.RecordSet_element();   
                RecordSet1.ComplaintNumber=clitem.GE_LGT_EM_CaseNumber__r.GE_LGT_EM_CaseID__c;
                RecordSet1.ComplaintLineItemNo=clitem.Name;
                if(clitem.GE_LGT_EM_Manual_Invoice_Number__c==Null){
                    RecordSet1.SAPInvoiceNumber=clitem.GE_LGT_EM_SAPInvoiceNumber__c;
                }
                else{
                    RecordSet1.ManualInvoiceNo=clitem.GE_LGT_EM_Manual_Invoice_Number__c ;
                }
                RecordSet1.SAPInvoiceLineItemNo=String.valueOf(clitem.GE_LGT_EM_Ref_InvoiceLineItem__r.GE_LGT_EM_SAP_LineItemNumber__c);
                RecordSet1.ApprovedQuantity=String.valueOf(clitem.GE_LGT_EM_ApprovedQuantity__c);
                
                if(clitem.GE_LGT_EM_Category__c=='102-Valid SPA not avaible'|| clitem.GE_LGT_EM_Category__c=='103-Wrong price on replacement'||clitem.GE_LGT_EM_Category__c=='105-System prices accepted by customer'||clitem.GE_LGT_EM_Category__c=='146-SAP Missing Price-Sap System processin'||clitem.GE_LGT_EM_Category__c=='149-ORDER NOT BLOCKED-CRC'||clitem.GE_LGT_EM_Category__c=='150-ORDER NOT BLOCKED-STRATEGIC'||clitem.GE_LGT_EM_Category__c=='210-Special price existing but not applied d'||clitem.GE_LGT_EM_Category__c=='211-Current conditions missing'||clitem.GE_LGT_EM_Category__c=='212-Current conditions expired'||clitem.GE_LGT_EM_Category__c=='213-Current conditions wrong'||clitem.GE_LGT_EM_Category__c=='214-Wrong account number used-Price cplt'||clitem.GE_LGT_EM_Category__c=='215-Price increase issue'||clitem.GE_LGT_EM_Category__c=='216-Promotion prices not applied'||clitem.GE_LGT_EM_Category__c=='605-Pricing error'||clitem.GE_LGT_EM_Category__c=='401-INCORRECT SPA APPLIED'){
                    RecordSet1.ApprovedPrice=String.valueOf(math.ABS(clitem.GE_LGT_EM_InvoicedPrice__c - clitem.GE_LGT_EM_ApprovedUnitPrice__c));
                }else{
                    RecordSet1.ApprovedPrice=String.valueOf(clitem.GE_LGT_EM_ApprovedUnitPrice__c);
                }
                RecordSet1.ApprovedPriceUnit=String.valueOf(clitem.GE_LGT_EM_Approved_Price_Unit__c);
                RecordSet1.SAPCustomerNumber=clitem.GE_LGT_EM_CaseNumber__r.Account.GE_LGT_EM_SAP_Customer_Number__c;
                RecordSet1.DocType=clitem.GE_LGT_EM_Doc_Type__c;
                RecordSet1.CategoryCode=clitem.GE_LGT_EM_Category__c;
                RecordSet1.SalesOrg=clitem.GE_LGT_EM_Sales_Org__c;
                if(clitem.GE_LGT_EM_Ref_InvoiceLineItem__r.GE_LGT_EM_InvoiceHeaderNumber__r.GE_LGT_EM_Division__c==Null && clitem.GE_LGT_EM_Ref_InvoiceLineItem__r.GE_LGT_EM_InvoiceHeaderNumber__r.GE_LGT_EM_Distribution_Channel__c==Null)
                {
                    system.debug('from account division--->');
                    system.debug('from account channel--->');
                    RecordSet1.Division=clitem.GE_LGT_EM_CaseNumber__r.Account.GE_LGT_EM_Division__c;
                    RecordSet1.DistributionChannel=clitem.GE_LGT_EM_CaseNumber__r.Account.GE_LGT_EM_Distribution_Channel__c;
                }
                else
                {
                    system.debug('from Header division--->');
                    RecordSet1.Division=clitem.GE_LGT_EM_Ref_InvoiceLineItem__r.GE_LGT_EM_InvoiceHeaderNumber__r.GE_LGT_EM_Division__c;
                    RecordSet1.DistributionChannel=clitem.GE_LGT_EM_Ref_InvoiceLineItem__r.GE_LGT_EM_InvoiceHeaderNumber__r.GE_LGT_EM_Distribution_Channel__c;
                }
                
                RecordSet1.RejectCode=clitem.GE_LGT_EM_Rejection_Code__c;
                RecordSet1.BlockCR=clitem.GE_LGT_EM_Block_CR__c;
                RecordSet1.MaterialNumber=clitem.GE_LGT_EM_SAP_Material_Number__c;
                
                ListRecordSet.add(RecordSet1);
            }
            
            DtCrdbRequest.RecordSet=ListRecordSet;
            system.debug('DtCrdbRequestRecordSet --------------->'+ DtCrdbRequest.RecordSet);
            
            RecordSetResponse=GELGTmainclass.SI_SFDC_CrDbMemoRequest_433_OB_ASYNC(ListRecordSet);
            
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
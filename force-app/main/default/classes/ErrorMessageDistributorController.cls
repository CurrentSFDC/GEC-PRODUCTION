public class ErrorMessageDistributorController{
    
    ApexPages.StandardController stdCrtl;
    private static String EXECUTIVEREVIEW = 'Executive Review';
    Distributor__c agent;

    public Boolean showMessage {get;set;}
    public String message {get;set;}
    private static String SR = 'Latam - Sales Rep';
    private static String DEC = 'Latam - Distributor - End Customer';
    private static String SOLAR = 'Solar Account Setup';
    public ErrorMessageDistributorController(ApexPages.StandardController crtl){
           agent = new Distributor__c ();
           Map<ID, Schema.RecordTypeInfo> recordTypeMap;
           String recordType = '';
           stdCrtl = crtl;
           showMessage = true;
           agent = [Select RecordTypeId,State_Province_1__c, Counties_State_1__c,
                       Comment_State_1__c, Status__c, Sales_Office_Solutions__c,
                         Sales_District_Solutions__c, Sales_Group_Solutions__c,
                             Existing_Multi_Tax_Form_or_State_For_del__c, KYC_Number__c,Account_Core__c,
                                 Master_Contract_ID__c, Addendum_ID__c,Account_Solutions_Controls__c,Account_Assignment_Group__c,
                                     Customer_Rating__c, Credit_Score__c, Credit_line_approved_USD__c, Payment_Term_approved_days__c, 
                                        Credit_ID_Number__c, Credit_Limit_Approved_USD__c, Credit_Quality_Rating__c, Is_the_contract_attached__c     
                                            from Distributor__c where Id=:stdCrtl.getId() LIMIT 1];
          recordTypeMap = Schema.SObjectType.Distributor__c.getRecordTypeInfosById();
          recordType = recordTypeMap.get(agent.RecordTypeId).getName();
          
          if(recordType == SR ){
              if(complianceErrorMsgSR(agent)){}
              else
                  message = '';
          }
          else if(recordType == DEC){
              if(complianceErrorMsgSR(agent)){}
              else if(riskReviewErrorMsgDEC(agent)){}
              else
                  message = '';
          }
          else if(recordType == SOLAR){
                if(solarRiskReview(agent)){}
                else if(riskSetup(agent)){}
          }
          
          else{
          //if(coverageErrorMsg(agent)){}          
          if(legalReview(agent)){}
          //else if(riskReview(agent)){}
          else if(acctSetup(agent)){}
          else
              message = '';                                                            
          }
    }
     
     /*public Boolean coverageErrorMsg(Distributor__c agent){
          if(agent.State_Province_1__c ==null && agent.Counties_State_1__c==null){
                showMessage = true;
                message = 'Please complete the COVERAGE section and hit submit for approval for your request to go to the next step. Ignore if completed.';
                return true;
          }
          return false;
     }
     
     public Boolean riskReview(Distributor__c agent){
        if(agent.Status__c=='Risk Review'  && (agent.Sales_Office_Solutions__c == null || agent.Sales_District_Solutions__c  == null || agent.Sales_Group_Solutions__c == null || agent.Existing_Multi_Tax_Form_or_State_For_del__c == null || agent.KYC_Number__c == null || agent.Credit_ID_Number__c == null || agent.Credit_Limit_Approved_USD__c == null || agent.Credit_Quality_Rating__c == null)){
                message = 'Please fill information under the Risk Section & Setup Requirement Section to move to the next step in approval. Ignore if completed.';
                return true;
         }
         return false; 
     }*/
     
     public Boolean legalReview(Distributor__c agent){
         if(agent.Status__c== 'Legal Review' && (agent.Is_the_contract_attached__c == null)){
                showMessage = true;
                message = 'Please check the boxes in the under Legal Review section if the agreement is attached to move on to the next step. Ignore if completed.';
                return true;
         }
         return false;
     }
     
     public Boolean complianceErrorMsgSR(Distributor__c agent){
          if(agent.Status__c== 'Compliance Review' && (agent.Master_Contract_ID__c == null || agent.Addendum_ID__c == null)){
                showMessage = true;
                message = 'Please complete the Compliance Information section and hit submit for approval for your request to go to the next step. Ignore if completed.';
                return true;
          }
          return false;
     }
     
     public Boolean riskSetup(Distributor__c agent){
         if(agent.Status__c == 'Risk Setup' && agent.Account_Solutions_Controls__c == null){
                 showMessage = true;
                 message = 'Please complete the Setup Requirements section. Ignore if completed.';
                 return true;
         }
         return false;
     }
     
     public Boolean acctSetup(Distributor__c agent){
         if(agent.Status__c == 'Legal Approved' && agent.Account_Core__c == null){
                 showMessage = true;
                 message = 'Please complete the Setup Requirements section. Ignore if completed.';
                 return true;
         }
         return false;
     }
     
      public Boolean solarRiskReview(Distributor__c agent){
        if(agent.Status__c=='Risk Review'  && (agent.Sales_Office_Solutions__c == null || agent.Sales_District_Solutions__c  == null || agent.Sales_Group_Solutions__c == null || agent.Account_Assignment_Group__c==null)){
                message = 'Please fill information under the Risk Section & Setup Requirement Section to move to the next step in approval. Ignore if completed.';
                return true;
         }
         return false; 
     }
     
     public Boolean riskReviewErrorMsgDEC(Distributor__c agent){
         if(agent.Status__c == 'Credit/Risk Review' && (agent.Customer_Rating__c == null || agent.Credit_Score__c == null || agent.Credit_Line_Approved_Number__c == null || agent.Payment_Term_approved_days__c == null)){
               showMessage = true;
               message = 'Please complete information under Credit/Risk Section. Ignore message if completed';
               return true;
           }
           return false;
     }
     
    

       
}
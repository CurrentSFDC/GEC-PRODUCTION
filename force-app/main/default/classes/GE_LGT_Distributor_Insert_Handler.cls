/**https://gelighting--aluat.cs67.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#
* Created by: Aditya Ghadigaonkar
* Object: Account Setup
* Trigger: GE_LGT_Distributor_Insert
* Test Class: GE_LGT_Distributor_Insert_Handler_Test
*/


public class GE_LGT_Distributor_Insert_Handler{
   private static String LDNCSACD = 'LATAM-Distributor- New Core, Solutions and Controls Distributor'; //RQT-1619
   private static String LDNCSACB = 'LATAM-Distributor- New Core, Solutions and Controls Branch';
       
//private static String NSAOCD ='Distributor- New Solutions and/or Controls Distributor';     
//private static String NSAOCB = 'Distributor- New Solutions and/or Controls Branch'; RQT-1475
//private static String NCSACD = 'Distributor- New Solutions and Controls Distributor';
//private static String NCSACB = 'Distributor- New Solutions and Controls Branch';
private static String NCSACD = 'Distributor- New Core, Solutions and Controls Distributor';
private static String NCSACB = 'Distributor- New Core, Solutions and Controls Branch';
//private static String NCD = 'Distributor- New Core Distributor';
//private static String NCB = 'Distributor- New Core Branch'; RQT-1475
private static String DA = 'Direct Account Setup/Direct Account Branch Setup';
private static String SR = 'Latam - Sales Rep';
private static String DEC = 'Latam - Distributor - End Customer';
//private static String SOLAR = 'Solar Account Setup'; --> COMMENTED OUT BY MG: RQT-1023
private static String CICA = 'Change  - Increase in Credit Amount';

Map<ID, Schema.RecordTypeInfo> recordTypeMap;
String recordType = '';

public void afterUpdateValidation(List<Distributor__c> distList){
    recordTypeMap = Schema.SObjectType.Distributor__c.getRecordTypeInfosById();
    for(Distributor__c  distributor : distList){
         recordType = recordTypeMap.get(distributor.RecordTypeId).getName();
         //6.25 - MG -  Removed recordType == NCSACD from the IF Statement below, COVERAGE SECTION IS NO LONGER REQUIRED
         //7.2 - MG -  Removed recordType == NCSACB from the IF Statement below, COVERAGE SECTION IS NO LONGER REQUIRED       
         //Validation for field to be populated by the Risk Team before approval for Distributor- New Core, Solutions and/or Controls Distributor
         if(/*recordType == NSAOCD || recordType == NSAOCB || recordType == NCSACD || recordType == NCSACB || */ recordType == LDNCSACD || /*recordType == NCD || recordType == NCB ||*/ recordType == DA){
            if((distributor.Status__c == 'Exec Review') && distributor.State_Province_1__c ==null && distributor.Counties_State_1__c==null){
                distributor.addError('Please fill information under Coverage section to submit for approval.');   
            }
         }
       
         /*------------------Distributor- New Core, Solutions and Controls Distributor || Branch--------------------------*/
         //Validation for field to be populated by the Risk Team before approval for Distributor- New Core, Solutions and Controls Distributor
         //6.25 - MG -  Removed recordType == NCSACD from the IF Statement below, these fields are no longer on the layout for the record type, thus removing.
          if(recordType == NCSACB){ 
            //if((distributor.Status__c == 'Compliance Review') && (distributor.Sales_Office_Solutions__c == null || distributor.Sales_District_Solutions__c == null ||  distributor.Sales_Group_Solutions__c == null || distributor.Account_Assignment_Group__c == null || distributor.KYC_Number__c == null || distributor.Credit_ID_Number__c == null || distributor.Credit_Limit_Approved_USD__c == null || distributor.Credit_Quality_Rating__c == null ||/* distributor.Core_Customer_Master_setup__c == false ||*/ distributor.Account_Core__c == null || distributor.QAD_Account_Number__c == null || /*distributor.QAD_Account_Controls__c == null || distributor.EDI_Setup__c==false|| distributor.Elitenet_Registration_Sent__c==false*/)){
            if((distributor.Status__c == 'Compliance Review') && (distributor.Sales_Office_Solutions__c == null || distributor.Sales_District_Solutions__c == null ||  distributor.Sales_Group_Solutions__c == null || distributor.Account_Assignment_Group__c == null || distributor.KYC_Number__c == null || distributor.Credit_ID_Number__c == null || distributor.Credit_Limit_Approved_USD__c == null || distributor.Credit_Quality_Rating__c == null  )){
                distributor.addError('Please fill information under Risk Review Section and Setup Requirement section to Approve.');   
            }
         
         //Validation for field to be populated by the LegalTeam before approval for Distributor- New Core, Solutions and Controls Distributor

            else if((distributor.Status__c == 'Legal Approved') && (distributor.Is_the_contract_attached__c == null )){
                distributor.addError('Please attach contract to move to the next step in approval.');   
            }
            
           if( distributor.Status__c == 'Ship To' && (distributor.Account_Core__c == null || distributor.QAD_Account_Number__c == null)){
               distributor.addError('Please complete information under the Setup Requirement Section'); 
           }
          }
        
        /*------------------Distributor- New Core, Solutions and/or Controls Distributor || Branch--------------------------*/
         //Validation for field to be populated by the Risk Team before approval for Distributor- New Core, Solutions and/or Controls Distributor
        //Comment the code due to inactive the record types RQT-1475
        /*else if(recordType == NSAOCD || recordType == NSAOCB)
        {*/
            //if((distributor.Status__c == 'Compliance Review') && (distributor.Sales_Office_Solutions__c == null || distributor.Sales_District_Solutions__c == null ||  distributor.Sales_Group_Solutions__c == null || distributor.Account_Assignment_Group__c == null || distributor.KYC_Number__c == null || distributor.Credit_ID_Number__c == null || distributor.Credit_Limit_Approved_USD__c == null || distributor.Credit_Quality_Rating__c == null /*|| distributor.EDI_Setup__c==false|| distributor.Elitenet_Registration_Sent__c==false*/)){
              //  distributor.addError('Please fill information under Risk Review Section and Setup Requirement section to Approve.');   
            //}
         //Validation for field to be populated by the LegalTeam before approval for Distributor- New Core, Solutions and/or Controls Distributor
           /* else if(recordType == NSAOCD && (distributor.Status__c == 'Legal Approved') && (distributor.Is_the_contract_attached__c == null )){
                distributor.addError('Please attach contract to move to the next step in approval.');   
            }
            
            else if((distributor.Status__c == 'Complete') && ( distributor.QAD_Account_Number__c == null || distributor.QAD_Account_Controls__c == null)){
                distributor.addError('Please complete information under the Setup Requirement Section');
            }
         }*/
            
         /*----------------------------Distributor- New Core Distributor || Branch----------------------------------*/
         
        // else if(recordType == NCD || recordType == NCB ){
         //Validation for field to be populated by the Risk Team before approval for Distributor- New Core Distributor
          // if((distributor.Status__c == 'Compliance Review') && ( distributor.KYC_Number__c == null || distributor.Credit_ID_Number__c == null || distributor.Credit_Limit_Approved_USD__c == null || distributor.Credit_Quality_Rating__c == null /*|| distributor.Core_Customer_Master_setup__c == false || distributor.EDI_Setup__c==false|| distributor.Elitenet_Registration_Sent__c==false */ ) ){
             //   distributor.addError('Please fill information under Risk Review Section and Setup Requirement section to Approve.');   
           // }   
         //Validation for field to be populated by the LegalTeam before approval for Distributor- New Core Distributor
         /* else if((distributor.Status__c == 'Legal Approved') && (distributor.Is_the_contract_attached__c == null )){
                distributor.addError('Please attach contract to move to the next step in approval.');   
            }
            
          else if((distributor.Status__c == 'Ship To') && distributor.Account_Core__c == null ) {
                distributor.addError('Please complete information under the Setup Requirement Section'); 
           }
         }*/ 
         
         /*--------------------------Direct Account--------------------------------*/
         //Validation for field to be populated by the Risk Team before approval for Direct Account
         else if(recordType == DA){
    
           //KAFZY-1977 
           //if(distributor.Status__c=='Risk Approved' && (/*distributor.Sales_Office_Solutions__c ==null || distributor.Sales_District_Solutions__c==null || distributor.Sales_Group_Solutions__c==null || distributor.Account_Assignment_Group__c==null ||  distributor.D_B_Check__c==false || distributor.GE_LGT_Sabrix_Setup_Complete__c==false || distributor.Customer_Master_Setup_Solutions_Controls__c==false ||*/ distributor.Account_Solutions_Controls__c==''  ||/* distributor.Core_Customer_Master_setup__c==false ||*/ distributor.Account_Core__c ==null || /*distributor.Ship_To_Sent_to_GENPAC__c ==false*/)){
             if(distributor.Status__c=='Risk Approved' && (distributor.Sales_Office_Solutions__c ==null || distributor.Sales_District_Solutions__c==null || distributor.Sales_Group_Solutions__c==null || distributor.Account_Assignment_Group__c==null )){
                 distributor.addError('Please Complete Information under the Risk Review and Setup Requirement Sections.');
            }
          
            //else if(distributor.Status__c=='Risk Approved' && distributor.Type_of_Setup__c=='Contract' && (distributor.GE_LGT_Signed_Agreement_if_Applicable__c==null || distributor.Address_Verification_Required__c  ==null  ) ){
             else if(distributor.Status__c=='Risk Approved' && distributor.Type_of_Setup__c=='Contract' && (distributor.GE_LGT_Signed_Agreement_if_Applicable__c==null)){
                 distributor.addError('Following fields are mandatory : Signed Agreement if Applicable,  Address Verification Required');
             }
             
            else if(distributor.Status__c == 'Complete' && (distributor.Account_Solutions_Controls__c=='' || distributor.Account_Core__c == null)){
                  distributor.addError('Please complete information under the Setup Requirement Section');
            }
            if(distributor.Status__c == 'Ship To' && (distributor.Account_Solutions_Controls__c=='' || distributor.Account_Core__c == null)){
                  distributor.addError('Please complete information under the Setup Requirement Section');
            }           
         }
         
         //LATAM enhancement for furture release. 
         /*--------------------------Sales Rep--------------------------------*/
        if(recordType == SR /*|| recordType == DEC*/){
             
             if(distributor.Status__c == 'Compliance Approved' && (distributor.Master_Contract_ID__c == null || distributor.Addendum_ID__c == null)){
                  distributor.addError('Please complete information under Compliance section');
             }
             
         }
         
       /*------------------------------Latam - Distributor - End Customer-----------------------------*/
       if(recordType == DEC){
           if(distributor.Status__c == 'Risk Approved' && (distributor.Customer_Rating__c == null || distributor.Credit_Score__c == null || distributor.Credit_Line_Approved_Number__c == null || distributor.Payment_Term_approved_days__c == null)){
               distributor.addError('Please complete information under Credit/Risk Section.');
           }
          if(distributor.Status__c == 'Compliance Approved' && ( distributor.DUNS__c == null )){
               distributor.addError('Please complete information under Compliance Information Section.');
           }
       }   
      
      /*if(recordType == SOLAR){
          if(distributor.Status__c == 'Commercial Finance Review' && (distributor.Sales_Office_Solutions__c ==null || distributor.Sales_District_Solutions__c==null || distributor.Sales_Group_Solutions__c==null || distributor.Account_Assignment_Group__c==null )){
              distributor.addError('Please Complete Information under the Risk Review and Setup Requirement Sections.');
          }
          else if(distributor.Status__c == 'Complete' && (distributor.Account_Solutions_Controls__c == null)){
               distributor.addError('Please complete information under the Setup Requirement Section');
          }
      }*/ //--> COMMENTED OUT BY MG: RQT-1023 
      
      /*---------------------------Change - Increase in Credit Amount ----------------------------*/
      if(recordType == CICA && distributor.Status__c == 'Complete' && (distributor.Recommended_Credit_Line__c == null || distributor.Account_Currency_Recommended_Credit_Line__c == null || distributor.Financials_Avaliable__c == null || distributor.Requires_DOA_Approval__c == null)){
         distributor.addError('Please fill in details for Recommended Credit Line, Account Currency, Financials Available and Requires DOA Approvals under the Credit Assesment Section');
      }
      
    
        /*------------------LATAM Distributor- New Core, Solutions and/or Controls Distributor || Branch--------------------------*/
        //Validation for field to be populated by the Risk Team before approval for LATAMDistributor- New Core, Solutions and/or Controls Distributor ||branch
        //This is coded based on RQT-1619
        if(recordType == LDNCSACD || recordType == LDNCSACB)
        {
 
            if((distributor.Status__c == 'Compliance Review') && (distributor.Sales_Office_Solutions__c == null ||distributor.Sales_District_Solutions__c == null || distributor.Sales_Group_Solutions__c == null || distributor.Account_Assignment_Group__c== null || distributor.Existing_Multi_Tax_Form_or_State_For_del__c== null || distributor.KYC_Number__c == null || distributor.Credit_ID_Number__c == null||distributor.Credit_Limit_Approved_USD__c == null || distributor.Credit_Quality_Rating__c== null))
            {
                distributor.addError('Please fill information under "Risk Review – Documentation Requirements" Section.');   
            }
            
            if((distributor.Status__c == 'Legal Approved') && (distributor.Legal_Review_comments__c== null || distributor.Is_the_contract_attached__c== null ))
            {
                distributor.addError('Please fill information under "Legal Review" Section.');   
            }
             
            if((distributor.Status__c == 'Complete') && (distributor.QAD_Account_Number__c== null|| distributor.Account_Core__c== null ))
            {
                distributor.addError('Please fill information under "Setup Requirement" Section.');   
            }
        }
        
    }
    
    }
   
}
/*
Trigger Name - Agent_Approval_Validation_AutoSubmit
Author - Neel (TechMahindra)
Purpose - Generally during apprval process records are locked, and validation rules do not fire.
This trigger has validation rules which are essential when a record in under approval process.
Test Class Name - GE_LGT_AGENT_PREVENT_APPROVAL_Test   
Month/Year - Dec-2014

*/

trigger Agent_Approval_Validation_AutoSubmit on Agent__c (after update) {
    //Rashmitha Changed the API vesion from 32 to 45 on 5-Mar-2019 as per 1447 request
    Id RecordtypeId1 = [Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'Change_Owner_Legal_Name_Entity' limit 1].Id;
    Id RecordtypeId2 = [Select Id,DEVELOPERNAME, Name from RecordType where DEVELOPERNAME = 'Change_Territory_Product_Line' limit 1].Id;
    
    //Change by Aditya 8/17/2016 
    // Refer AgentApprovalValidationTriggerHandler class
    Id agentOnbrdRecordtypeId = [Select Id,DEVELOPERNAME, Name from RecordType 
                                 where DEVELOPERNAME = 'Agent_Onboarding' limit 1].Id;
    
    AgentApprovalValidationTriggerHandler aavth = new AgentApprovalValidationTriggerHandler();
    aavth.ValidateMarketSection(trigger.New); 
    
    //End of Agent onboarding and termination approval process validation changes by Aditya
    
    for(Agent__c agent :trigger.New){
        system.debug('Trigger Agent_Prevent_Approval Begins');
        //system.debug('Agent approval status : '+agent.Approval_Status__c);
        if(trigger.isUpdate) {
            system.debug('Trigger Agent_Prevent_Approval called');
            if(agent.RecordTypeId != RecordtypeId1 && agent.RecordTypeId != RecordtypeId2){
                if(agent.Approval_Status__c == 'Contract - Finance Review' && agent.Dually_Executed_Contract_Attached_Y_N__c ==false ){
                    // system.debug('Please attach Dually Executed Contract and set the corresponding checkbox to TRUE');
                    agent.addError('Please attach Dually Executed Contract and set the corresponding checkbox to TRUE');
                }
                
                if(agent.Approval_Status__c == 'RM Review' ){ //mandatory conditions for Approval Status=RM Review 
                    system.debug('Inside RM Review if loop');
                    if((agent.Sales_Office_Solutions__c == null || agent.Sales_District_Solutions__c == null )|| agent.Sales_Group_Solutions__c==null|| agent.Account_Assignment_Group__c==null || agent.Major_Channel__c==null || agent.Minor_Channel__c==null|| agent.Vertical__c==null  ){
                        //system.debug('Inside Commission rate Standard loop');
                        agent.addError('Following fields are mandatory : Sales Office Solutions, Sales District Solutions,Sales Group Solutions, Account Assignment Group, Major Channel, Minor Channel, Vertical,');
                    }
                } 
                //Filter condition updated by Aditya 08/17/2016 to exclude Agent_Onboading recordtype records
                if(agent.Approval_Status__c == 'Executive Review' && agent.RecordTypeId != agentOnbrdRecordtypeId 
                   && (agent.Newly_Created_Contract_Attached_Y_N__c =='No' ||agent.Newly_Created_Contract_Attached_Y_N__c ==null) ){ //
                       agent.addError('Please select YES for Newly Created Contract Attached Y/N field');
                   }
                
                if(agent.Approval_Status__c == 'Legal Review' && (agent.Candidate_s_Reputation_Reviewed_Y_N__c==null || agent.Due_Diligence_Complete_Yes_No__c==null )){ //Fields in RM section are mandatory
                    agent.addError('Missing value for: Candidate’s Reputation Reviewed? Y/N, Due Diligence Complete Yes/No ');
                }
                //}
                //Below validations are added for 'KAFZY-199' July-release (Requested by Allison)
                //Filter condition updated by Aditya 08/17/2016 to exclude Agent_Onboading recordtype records
                
                if(agent.Approval_Status__c == 'In Setup' &&  agent.Account_Released__c ==false ){ //
                    agent.addError('Following field(s) are mandatory : Account Released');
                }
                if(agent.Approval_Status__c == 'SAP Setup' &&  (agent.GE_LGT_AGENT_Risk_has_completed_set_up__c ==false || agent.GE_LGT_AGENT_Account_Number_s__c ==null || agent.Account_Blocked__c==false ) ){ //
                    agent.addError('Following field(s) are mandatory :  Risk has completed setup, Account Numbers (Rep Code), Account Blocked');
                }
                
            }
            // Agent Termination Approval logic : starts (January-2015)
            
            //Modified by Aditya, Date : 08/22/2016, Change request by Shalini Singh
            //Refer AgentApprovalValidationTriggerHandler class
            
            
            
            if(agent.Termination_Status__c=='Legal Review' && agent.Agreement_Attached_Y_N__c==false){
                agent.addError('Can not approve unless Agreement Attached? Y/N is set to TRUE');
            }
            
            
            
            
            // Agent Termination Approval logic : ends
            
            
            
            //Auto Submit record for Legal approval
            
            // Agent Change – Territory/ Product Line  and Change – Owner/Legal Name/ Entity Approval Logic : (Sep-2015)
            if(agent.RecordTypeId == RecordtypeId1){
                if(agent.Approval_Status__c == 'Risk Review' &&  agent.Existing_Application__c ==false &&  agent.Existing_Agreement__c ==false && agent.Existing_W9__c ==false &&  agent.Address_Verification_Required__c ==false &&  agent.Canadian_Documents__c ==false){ //
                    agent.addError('Following field(s) are mandatory : Existing application, Existing agreement,  Existing W9, Address verification required, Canadian documents');
                }
                if(agent.Approval_Status__c == 'Owner Next Steps' && agent.Legal_Review_comments__c ==Null){
                    agent.addError('Following field(s) are mandatory : Legal Review (comments)');
                }
            }
            if(agent.RecordTypeId == RecordtypeId2){
                if(agent.Approval_Status__c == 'Exec Addendum Review' && agent.Legal_Review_comments__c ==Null){
                    agent.addError('Following field(s) are mandatory : Legal Review (comments)');
                }
            }
            
            
        }}}
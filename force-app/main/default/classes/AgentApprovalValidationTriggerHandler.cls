/**Author: Aditya Ghadigaonkar
* Checklist validation for various stages of Onboarding and Termination approval processes.
* Trigger: Agent_Approval_Validation_AutoSubmit
* 
*/
public class AgentApprovalValidationTriggerHandler{
	//Rashmitha Changed the API vesion from 37 to 45 on 6-Mar-2019 as per 1447 request
    private static String COMPLETE = 'Complete';
    private static String EXECUTIVEREVIEW = 'Executive Review';
    private static String NOTSUBMITTED = 'Not Submitted';
    private static String AWAITINGCONTRACT = 'Awaiting Contract';
    
    public void ValidateMarketSection(List<Agent__c> newList){
        
       Id agentOnbrdRecordtypeId = [Select Id,DEVELOPERNAME, Name from RecordType  where DEVELOPERNAME = 'Agent_Onboarding' limit 1].Id;
       Id agentTerminationRecordtypeId = [Select Id,DEVELOPERNAME, Name from RecordType  where DEVELOPERNAME = 'Agent_Termination' limit 1].Id;                            
       Id agentTerritoryRecordtypeId = [Select Id,DEVELOPERNAME, Name from RecordType  where DEVELOPERNAME = 'Change_Territory_Product_Line' limit 1].Id;
       for(Agent__c agent:newList){
           //Agent Onboarding - Risk final steps valildation
            if(agent.Approval_Status__c == COMPLETE &&  agent.RecordTypeId == agentOnbrdRecordtypeId && (agent.Sales_Office_Solutions__c ==null || agent.Sales_District_Solutions__c==null ||  agent.Sales_Group_Solutions__c==null || agent.Account_Assignment_Group__c==null ||agent.GE_LGT_AGENT_Risk_has_completed_set_up__c == false ||agent.GE_LGT_AGENT_Account_Number_s__c == null) ){
                agent.addError('Following fields are mandatory : Sales Office Solutions,'+ 
                                    'Sales District Solutions, Sales Group Solutions,'+ 
                                       'Account Assignment Group, Risk has completed setup? & Rep Code(s).');
            }
            //Agent Onboarding - Coverage Validation
            else if(agent.Approval_Status__c == EXECUTIVEREVIEW  && agent.RecordTypeId == agentOnbrdRecordtypeId  && ((agent.State_Province_1__c ==null && agent.Counties_State_1__c==null) && (agent.State_Province_2__c ==null && agent.Counties_State_2__c==null) && (agent.State_Province_3__c ==null && agent.Counties_State_3__c==null) && (agent.State_Province_4__c ==null && agent.Counties_State_4__c==null)) ){
                agent.addError('Add atleast one State - County under the Coverage section');
            }
            //Agent Territory - Coverage Validation
            else if(agent.Approval_Status__c == AWAITINGCONTRACT && agent.RecordTypeId == agentTerritoryRecordtypeId && ((agent.State_Province_1__c ==null && agent.Counties_State_1__c==null) && (agent.State_Province_2__c ==null && agent.Counties_State_2__c==null) && (agent.State_Province_3__c ==null && agent.Counties_State_3__c==null) && (agent.State_Province_4__c ==null && agent.Counties_State_4__c==null)) ){
                agent.addError('Add atleast one State - County under the Coverage section');
            }
            //Agent Termination - Coverage Validation
            else if(agent.Termination_Status__c == EXECUTIVEREVIEW && agent.RecordTypeId == agentTerminationRecordtypeId && ((agent.State_Province_1__c ==null && agent.Counties_State_1__c==null) && (agent.State_Province_2__c ==null && agent.Counties_State_2__c==null) && (agent.State_Province_3__c ==null && agent.Counties_State_3__c==null) && (agent.State_Province_4__c ==null && agent.Counties_State_4__c==null)) ){             
                agent.addError('Add atleast one State - County under the Coverage section');
            }
           //Agent Termination           
           else if(agent.Termination_Status__c == 'RM/DM Review' && agent.RecordTypeId == agentTerminationRecordtypeId && (agent.Termination_Letter_Attached_Y_N__c == false || agent.Instructions_for_Termination_Attached__c == false)){
                 agent.addError('Please check the box in the under Legal Review section if the agreement is attached to move on to the next step.');
           }
           //Agent Termination
           else if(agent.Termination_Status__c == 'Risk Review' && agent.RecordTypeId == agentTerminationRecordtypeId && (agent.Termination_Letter_Sent_Y_N__c == false || agent.Termination_Letter_Faxed_Y_N__c == false || agent.Date_of_Termination__c==null )){
                agent.addError('Please fill information under the Termination Details section.');
          }
          //Agent Termination
          else if(agent.Termination_Status__c == 'Complete' && agent.RecordTypeId == agentTerminationRecordtypeId && (agent.Internal_Communication_Complete_Y_N__c == false || agent.Risk_Steps_Complete__c  == false || agent.Date_Set_to_Remove_from_Suppler_Master__c == null || agent.Supplier_Master_Steps_Complete__c == false)){               
                agent.addError('Please fill information under the Administrative Details section to complete the final approval.');
          }
            
       }
    }  
}
public class ErrorMessageController{
    
    ApexPages.StandardController stdCrtl;
    private static String EXECUTIVEREVIEW = 'Executive Review';
    Agent__c agent;
    public Boolean showMessage {get;set;}
    public String message {get;set;}
    public ErrorMessageController(ApexPages.StandardController crtl){
        agent = new Agent__c();
        stdCrtl = crtl;
        showMessage = true;
        agent = [Select State_Province_1__c, Counties_State_1__c,
                 State_Province_2__c, Counties_State_2__c, 
                 State_Province_3__c, Counties_State_3__c,
                 State_Province_4__c, Counties_State_4__c,
                 Comment_State_1__c, Comment_State_2__c,
                 Comment_State_3__c, Comment_State_4__c,
                 Approval_Status__c , Termination_Status__c,
                 Termination_Letter_Attached_Y_N__c, 
                 Instructions_for_Termination_Attached__c,
                 Termination_Letter_Sent_Y_N__c, Date_of_Termination__c,
                 Termination_Letter_Faxed_Y_N__c, Internal_Communication_Complete_Y_N__c,
                 Risk_Steps_Complete__c, Date_Set_to_Remove_from_Suppler_Master__c,
                 Supplier_Master_Steps_Complete__c, Sales_Office_Solutions__c,
                 Sales_District_Solutions__c, Sales_Group_Solutions__c,
                 Account_Assignment_Group__c, GE_LGT_AGENT_Risk_has_completed_set_up__c,
                 GE_LGT_AGENT_Account_Number_s__c
                 from Agent__c where Id=:stdCrtl.getId() LIMIT 1];
        if(coverageErrorMsg(agent)){}          
        else if(terminationLegalReview(agent)){}
        else if (terminationRMReview(agent)){}
        else if (terminationRiskReview(agent)){}
        else if (terminationLegalApproved(agent)){}
        else
            message = '';                                                            
    }
    
    public Boolean coverageErrorMsg(Agent__c agent){
        if(((agent.State_Province_1__c ==null && agent.Counties_State_1__c==null) && (agent.State_Province_2__c ==null && agent.Counties_State_2__c==null) && (agent.State_Province_3__c ==null && agent.Counties_State_3__c==null) && (agent.State_Province_4__c ==null && agent.Counties_State_4__c==null)) ){
            showMessage = true;
            message = 'Please complete the COVERAGE section and hit submit for approval for your request to go to the next step. Ignore if completed.';
            return true;
        }
        return false;
    }
    public Boolean terminationLegalReview(Agent__c agent){
        if(agent.Termination_Status__c == 'Legal Review' && (agent.Termination_Letter_Attached_Y_N__c == false || agent.Instructions_for_Termination_Attached__c == false)){
            showMessage = true;
            message = 'Please check the boxes in the under Legal Review section if the agreement is attached to move on to the next step. Ignore if completed.';
            return true;
        }
        return false;
    }
    public Boolean terminationRMReview(Agent__c agent){
        if(agent.Termination_Status__c=='RM/DM Review' && (agent.Termination_Letter_Sent_Y_N__c == false|| agent.Date_of_Termination__c == null || agent.Termination_Letter_Faxed_Y_N__c == false)){
            message = 'Please fill information under the Termination Details section in order to submit for approval. Ignore if completed.';
            return true;
        }
        return false;
    }
    public Boolean terminationRiskReview(Agent__c agent){
        if(agent.Termination_Status__c=='Risk Review'  && (agent.Internal_Communication_Complete_Y_N__c == false || agent.Risk_Steps_Complete__c  == false || agent.Date_Set_to_Remove_from_Suppler_Master__c == null || agent.Supplier_Master_Steps_Complete__c == false)){
            message = 'Please fill information under the Administrative Details section to complete the final approval. Ignore if completed.';
            return true;
        }
        return false; 
    }
    public Boolean terminationLegalApproved(Agent__c agent){
        if(agent.Approval_Status__c == 'Legal Approved' && (agent.Sales_Office_Solutions__c ==null || agent.Sales_District_Solutions__c==null ||  agent.Sales_Group_Solutions__c==null || agent.Account_Assignment_Group__c==null ||agent.GE_LGT_AGENT_Risk_has_completed_set_up__c == false ||agent.GE_LGT_AGENT_Account_Number_s__c == null) ){
            message = 'Please fill out information under the Checklist for Agent Set up section. Ignore if completed.';
            return true;
        }
        return false;
    }
    
}
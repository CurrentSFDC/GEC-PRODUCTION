@isTest
public class ErrorMessageControllerTest{

    public static testMethod void testValidation(){
        ID agentRecTyp = [SELECT Id,Name FROM RecordType WHERE SobjectType='Agent__c' and Name='Agent Onboarding'].Id;
        ID agentTerminationRecordtypeId = [Select Id, Name from RecordType  where DEVELOPERNAME = 'Agent_Termination' limit 1].Id;
        ID agentTerritoryRecordtypeId = [Select Id,DEVELOPERNAME, Name from RecordType  where DEVELOPERNAME = 'Change_Territory_Product_Line' limit 1].Id;
        ID userID = UserInfo.getUserID();
               
        //Inserting Agent
        Agent__c agent2 = new Agent__c(RecordTypeId=agentTerminationRecordtypeId);
        agent2.Agent_Name_Legal_Name__c = 'Test Agent#1';
        agent2.Address__c = 'Test Address';
        agent2.City__c = 'Test City';
        agent2.State__c = 'Test State';
        agent2.Zip__c = '99999';
        agent2.Phone__c = '0000000000';
        agent2.GE_LGT_Fax_Number__c = '0000000000';
        agent2.GE_LGT_Contact_Name__c = 'Test Contact Name';
        agent2.Email__c = 'test@test.com';
        agent2.Website__c = 'www.testagent2.com';
        agent2.GE_LGT_Requestor__c = userID ;
        agent2.Is_new_agent_replacing_an_old_agent__c = 'No';
        agent2.Termination_Status__c = 'Executive Review';
        agent2.Region_Manager__c = userID;
        agent2.Candidate_s_Reputation_Reviewed_Y_N__c = 'Yes';
        agent2.Sources__c = 'test source';
        agent2.Due_Diligence_Complete_Yes_No__c = 'Yes';
        agent2.Major_Channel__c = '10 Automotive';
        agent2.Minor_Channel__c = '10 Automotive AM';
        agent2.Vertical__c = '10 Residential';
        agent2.DOT_Roadway__c = true;
        agent2.IFN_INDOOR_FIXTURE_NON_LED__c = true;
        agent2.State_Province_1__c = 'CA';
        agent2.Counties_State_1__c = 'Covers Entire State';
        agent2.Have_other_firms_been_considered__c = 'No';
        agent2.Num_of_employees__c = 00000;
        agent2.Num_of_Outside_sales_reps__c = 00000;
        agent2.Reputation_see_help_for_detail__c = 'test';
        agent2.Describe_government_relationships__c = 'test';
        agent2.GE_LGT_AGENT_Risk_has_completed_set_up__c = true;
        agent2.Rep_Code_s__c = '00000';
        agent2.Sales_District_Solutions__c = 'test';
        agent2.Sales_Group_Solutions__c = 'test';
        agent2.Sales_Office_Solutions__c = 'test';
        agent2.Account_Assignment_Group__c = 'test';
        agent2.territory__c = 'test';
        insert agent2;
        PageReference pageRef = Page.ErrorMessageDisplay;
        Test.setCurrentPage(pageRef);
       
        //agent2.Approval_Status__c = 'Executive Review';
        agent2.State_Province_1__c = null;
        agent2.Counties_State_1__c = null;
        pageRef.getParameters().put('id',agent2.id);
        ApexPages.StandardController sc = new ApexPages.standardController(agent2);
        ErrorMessageController emc = new ErrorMessageController(sc);
        emc.coverageErrorMsg(agent2);

        agent2.Termination_Status__c = 'Legal Review';
        agent2.Termination_Letter_Attached_Y_N__c = false;
        agent2.Instructions_for_Termination_Attached__c = false;
        agent2.State_Province_1__c = 'CA';
        agent2.Counties_State_1__c = 'Covers Entire State';
        emc.terminationLegalReview(agent2);

        agent2.Termination_Status__c = 'RM/DM Review';
        agent2.Termination_Letter_Sent_Y_N__c = false;
        agent2.Date_of_Termination__c = null;
        agent2.Termination_Letter_Faxed_Y_N__c = false;
        agent2.Termination_Letter_Attached_Y_N__c = true;
        agent2.Instructions_for_Termination_Attached__c = true;
        emc.terminationRMReview(agent2);
        
        agent2.Termination_Status__c = 'Risk Review'; 
        agent2.Termination_Letter_Sent_Y_N__c = false; 
        agent2.Termination_Letter_Faxed_Y_N__c = false;
        agent2.Date_of_Termination__c = null;
        agent2.Termination_Letter_Attached_Y_N__c = true;
        agent2.Instructions_for_Termination_Attached__c = true;
        agent2.State_Province_1__c = 'CA';
        agent2.Counties_State_1__c = 'Covers Entire State';       
        emc.terminationRiskReview(agent2);
        
        agent2.Termination_Status__c = 'Risk Review';
        agent2.Sales_Office_Solutions__c = null;
        agent2.Sales_District_Solutions__c= null;
        agent2.Sales_Group_Solutions__c = null;
        agent2.Account_Assignment_Group__c = null;
        agent2.GE_LGT_AGENT_Risk_has_completed_set_up__c = false;
        agent2.GE_LGT_AGENT_Account_Number_s__c = null;
        emc.terminationLegalApproved(agent2);
        
    }
    
    
}
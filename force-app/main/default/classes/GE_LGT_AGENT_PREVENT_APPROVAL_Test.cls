@isTest(seeAllData=true)
Public Class GE_LGT_AGENT_PREVENT_APPROVAL_Test{
    
    //Updated by : Aditya Ghadigaonkar | 08/29/2016
    //Commented because the conditions have been changed and the test is covered in AgentApprovalValidtnTrgrHndlrTest test class
    
   
    static testMethod void preventApproval1(){
        ID recAgentTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Agent__c' AND DEVELOPERNAME = 'Change_Owner_Legal_Name_Entity'].ID;
        Agent__c agent = new Agent__c(RecordTypeId=recAgentTypeID);
        agent.USA_or_Canada__c = 'USA';
        agent.Agent_Name_Text__c= 'TestTandra';
        agent.Termination_C_I__c = 'TestTermination';
        agent.Change_Type__c = 'Owner';
        agent.Reason_for_the_change__c = 'testchange';
        agent.Roadway__c='testroadway';
        agent.Termination_Controls__c ='testcontrols';
        agent.Other__c ='other';
        agent.Approval_Status__c = 'Not Submitted';
        agent.Existing_Application__c =false;
        agent.Existing_Agreement__c =false;
       
        agent.Existing_W9__c =false;
        agent.Address_Verification_Required__c =false;
        agent.Canadian_Documents__c =false;
        agent.Legal_Review_comments__c ='';
        agent.territory__c = 'test';
        insert agent;
        try
        {
            agent.Approval_Status__c='Risk Review';
            agent.Agreement_Attached_Y_N__c=false;
            update agent; 
        }catch(Exception exce){
            //Boolean expectedExceptionThrown4 =  exce.getMessage().contains('Can not approve unless Agreement Attached? Y/N is set to TRUE') ? true : false;
            system.debug(exce.getMessage());
        }
        try
        {
            agent.Approval_Status__c='Owner Next Steps';
           
            update agent; 
        }catch(Exception exce){
            //Boolean expectedExceptionThrown4 =  exce.getMessage().contains('Can not approve unless Agreement Attached? Y/N is set to TRUE') ? true : false;
        }
    }
    static testMethod void preventApproval2(){
        ID recAgentTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Agent__c' AND DEVELOPERNAME = 'Change_Territory_Product_Line'].ID;
        Agent__c agent = new Agent__c(RecordTypeId=recAgentTypeID);
        agent.USA_or_Canada__c = 'USA';
        agent.Agent_Name_Text__c= 'TestTandra';
        agent.Termination_C_I__c = 'TestTermination';
        agent.Change_Type__c = 'Owner';
        agent.Reason_for_the_change__c = 'testchange';
        agent.Roadway__c='testroadway';
        agent.Termination_Controls__c ='testcontrols';
        agent.Other__c ='other';
        agent.Approval_Status__c = 'Complete';
        agent.What_is_the_new_territory_and_or_p__c ='testtandra';
        agent.Legal_Review_comments__c ='';
        agent.territory__c = 'test';
        insert agent;
        agent.Approval_Status__c = 'Not Submitted';
        try
        {
            agent.Approval_Status__c='Exec Addendum Review';
         
            update agent; 
        }catch(Exception exce){
            //Boolean expectedExceptionThrown4 =  exce.getMessage().contains('Can not approve unless Agreement Attached? Y/N is set to TRUE') ? true : false;
        }
    }
    static testMethod void preventApproval3(){
        ID recAgentTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Agent__c' AND DEVELOPERNAME = 'Change_Address'].ID;
        Agent__c agent = new Agent__c(RecordTypeId=recAgentTypeID);
        agent.USA_or_Canada__c = 'USA';
        agent.Agent_Name_Text__c= 'TestTandra';
        agent.Termination_C_I__c = 'TestTermination';
        agent.Change_Type__c = 'Owner';
        agent.Reason_for_the_change__c = 'testchange';
        agent.Roadway__c='testroadway';
        agent.Termination_Controls__c ='testcontrols';
        agent.Other__c ='other';
        agent.Approval_Status__c = 'Not Submitted';
        agent.Existing_Application__c =false;
        agent.Existing_Agreement__c =false;
      
        agent.Existing_W9__c =false;
        agent.Address_Verification_Required__c =false;
        agent.Canadian_Documents__c =false;
        agent.Legal_Review_comments__c ='';
        agent.territory__c = 'test';
        insert agent;
        try
        {
            agent.Approval_Status__c='Risk Review';
            update agent; 
            agent.Approval_Status__c='RM Review';
            update agent;
            agent.Approval_Status__c='Legal Review';
            update agent;
            agent.Approval_Status__c='Executive Review';
            update agent;
            
        }
        catch(Exception exce)
        {
            Boolean expectedExceptionThrown4 =  exce.getMessage().contains('Sales Office Solutions, Sales District Solutions,Sales Group Solutions, Account Assignment Group, Major Channel, Minor Channel, Vertical') ? true : false;
            system.assertEquals(true,expectedExceptionThrown4);
        }
        try
        {
            agent.Approval_Status__c='Owner Next Steps';
            update agent; 
        }catch(Exception exce)
        {
            Boolean expectedExceptionThrown5 =  exce.getMessage().contains('Can not approve unless Agreement Attached? Y/N is set to TRUE') ? true : false;
             system.assertEquals(true,expectedExceptionThrown5);
        }
        try
        {
            agent.Approval_Status__c='Executive Review';
            update agent; 
        }catch(Exception exce)
        {
            Boolean expectedExceptionThrown6 =  exce.getMessage().contains('Please select YES for Newly Created Contract Attached Y/N field') ? true : false;
             system.assertEquals(true,expectedExceptionThrown6);
        }
        
    }
}
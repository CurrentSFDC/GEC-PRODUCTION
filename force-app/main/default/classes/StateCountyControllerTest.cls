@isTest(seeAllData=true)
public class StateCountyControllerTest{
       
    public static testMethod void testAddingStateCounty(){
        ID agentRecTyp = [SELECT Id,Name FROM RecordType WHERE SobjectType='Agent__c' and Name='Onboarding Approval'].Id;
        ID userID = UserInfo.getUserID();
        test.startTest();
        //Inserting Agent
        Agent__c agent = new Agent__c(RecordTypeId=agentRecTyp);
        agent.Agent_Name_Legal_Name__c = 'Test Agent#1';
        agent.Address__c = 'Test Address';
        agent.City__c = 'Test City';
        agent.State__c = 'Test State';
        agent.Zip__c = '99999';
        agent.Phone__c = '0000000000';
        agent.GE_LGT_Fax_Number__c = '0000000000';
        agent.GE_LGT_Contact_Name__c = 'Test Contact Name';
        agent.Email__c = 'test@test.com';
        agent.Website__c = 'www.testagent.com';
        agent.GE_LGT_Requestor__c = userID ;
        agent.Is_new_agent_replacing_an_old_agent__c = 'No';
        agent.Approval_Status__c = 'Risk Approved';
        agent.Region_Manager__c = userID;
        agent.Candidate_s_Reputation_Reviewed_Y_N__c = 'Yes';
        agent.Sources__c = 'test source';
        agent.Due_Diligence_Complete_Yes_No__c = 'Yes';
        agent.Major_Channel__c = '10 Automotive';
        agent.Minor_Channel__c = '10 Automotive AM';
        agent.Vertical__c = '10 Residential';
        agent.territory__c = 'test';
        
        insert agent;
        
        PageReference pageRef = Page.StateCountySelectorPage;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',agent.id);
        ApexPages.StandardController sc = new ApexPages.standardController(agent);
        StateCountyController sCC = new StateCountyController(sc);
        sCC.showAddNewBlock();
        sCC.hideAddNewBlock();
        sCC.getStateCodes();
        sCC.getIsAllCountiesSelect();
        sCC.selectclick();
        sCC.unselectclick();
        sCC.getCountyCodes();
        sCC.selectedState();
        sCC.selectedCounties();
        sCC.getunSelectedValues();
        sCC.getSelectedValues();
        sCC.isAllCounties = 'Yes';
        PageReference selectAllValues =sCC.selectAllValues();
       
        StateCountyHelper sch = new StateCountyHelper();
        
        //Saving State Counties
        // Coditions: isAllCounties = false; Edit = false;
        for(Integer i=0;i<4;i++){
            sCC.edit = false;
            sCC.state = 'AS';
            sCC.isAllCounties = 'No';
            sCC.rightValues.add('American Somoa - AS01');
            sCC.saveStateAndCounties();   
        }
        
         //Editing State Counties
        // Coditions: isAllCounties = false; Edit = true;
        for(Integer i=0;i<4;i++){
            sCC.edit = true;
            sCC.stateNumber = ''+i;
            sCC.state = 'PR';
            sCC.rightValues.add('Puerto Rico - PR01');
            sCC.isAllCounties = 'No';
            sCC.saveStateAndCounties();
        }
        
        for(Integer i=0;i<4;i++){
            sCC.stateNumber = ''+i;
            sCC.agent.State_Province_4__c='Covers Entire State';
            sCC.editState();
        }
        
        sCC.stateNumber ='4';
        sCC.Agent.State_Province_4__c ='Covers Entire State';
        sCC.editState();
        
        for(Integer i=0;i<4;i++){
            sCC.stateNumber = ''+i;
            sCC.deleteState();
        }

        test.stopTest();

    }
    public static testMethod void testAddingStateCountyWithAllselected(){
        ID agentRecTyp = [SELECT Id,Name FROM RecordType WHERE SobjectType='Agent__c' and Name='Onboarding Approval'].Id;
        ID userID = UserInfo.getUserID();
        test.startTest();
        //Inserting Agent
        Agent__c agent = new Agent__c(RecordTypeId=agentRecTyp);
        agent.Agent_Name_Legal_Name__c = 'Test Agent#1';
        agent.Address__c = 'Test Address';
        agent.City__c = 'Test City';
        agent.State__c = 'Test State';
        agent.Zip__c = '99999';
        agent.Phone__c = '0000000000';
        agent.GE_LGT_Fax_Number__c = '0000000000';
        agent.GE_LGT_Contact_Name__c = 'Test Contact Name';
        agent.Email__c = 'test@test.com';
        agent.Website__c = 'www.testagent.com';
        agent.GE_LGT_Requestor__c = userID ;
        agent.Is_new_agent_replacing_an_old_agent__c = 'No';
        agent.Approval_Status__c = 'Risk Approved';
        agent.Region_Manager__c = userID;
        agent.Candidate_s_Reputation_Reviewed_Y_N__c = 'Yes';
        agent.Sources__c = 'test source';
        agent.Due_Diligence_Complete_Yes_No__c = 'Yes';
        agent.Major_Channel__c = '10 Automotive';
        agent.Minor_Channel__c = '10 Automotive AM';
        agent.Vertical__c = '10 Residential';
        agent.territory__c = 'test';
        
        insert agent;
        
        PageReference pageRef = Page.StateCountySelectorPage;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',agent.id);
        ApexPages.StandardController sc = new ApexPages.standardController(agent);
        StateCountyController sCC = new StateCountyController(sc);
        sCC.showAddNewBlock();
        sCC.hideAddNewBlock();
        sCC.getStateCodes();
        sCC.getIsAllCountiesSelect();
        sCC.selectclick();
        sCC.unselectclick();
        sCC.getCountyCodes();
        sCC.selectedState();
        sCC.selectedCounties();
        sCC.getunSelectedValues();
        sCC.getSelectedValues();
        sCC.isAllCounties = 'No';
        PageReference selectAllValues =sCC.selectAllValues();
       
        StateCountyHelper sch = new StateCountyHelper();
        
        //Saving State Counties
        // Coditions: isAllCounties = false; Edit = false;
        for(Integer i=0;i<4;i++){
            sCC.edit = false;
            sCC.state = 'AS';
            sCC.isAllCounties = 'Yes';
            sCC.rightValues.add('American Somoa - AS01');
            sCC.saveStateAndCounties();   
        }
        
         //Editing State Counties
        // Coditions: isAllCounties = false; Edit = true;
        for(Integer i=0;i<4;i++){
            sCC.edit = true;
            sCC.stateNumber = ''+i;
            sCC.state = 'PR';
            sCC.rightValues.add('Puerto Rico - PR01');
            sCC.isAllCounties = 'Yes';
            sCC.saveStateAndCounties();
        }
        
        for(Integer i=0;i<4;i++){
            sCC.stateNumber = ''+i;
            sCC.agent.State_Province_4__c='Covers Entire State';
            sCC.editState();
        }
        
        sCC.stateNumber ='4';
        sCC.Agent.State_Province_4__c ='Covers Entire State';
        sCC.editState();
        
        for(Integer i=0;i<4;i++){
            sCC.stateNumber = ''+i;
            sCC.deleteState();
        }

        test.stopTest();

    }
 
}
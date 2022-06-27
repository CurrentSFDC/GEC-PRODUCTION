/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root
 */

@isTest
public with sharing class TestSetOpportunityProbabilityController {
    
    @testSetup
    static void setupData(){
        
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Daintree').getRecordTypeId();
        TriggerSwitch__c taskT=new TriggerSwitch__c(name='OpportunityTrigger',isActive__c=true);
        insert taskT;
          Account a = new Account(Name = 'Test Account');
        insert a;
        
        Opportunity newOpp = new Opportunity();
        newOpp.AccountId =a.id;
        newOpp.RecordTypeId= devRecordTypeId ;
        newOpp.Name ='Test Opportunity For Unit Test Purposes';
        newOpp.StageName = 'S1 Consult';
        newOpp.CloseDate = system.today()+7;
        newOpp.GE_LGT_GE_Opportunity_Id__c='NA0009875';
        insert newOpp;

        Opportunity o2 = new Opportunity();
        o2.Amount = 2000.00;
        o2.Name = 'Another Test Opportunity For Unit Test Purposes';
         o2.AccountId =a.id;
        o2.CloseDate = Date.Today().addDays(5);
        o2.RecordTypeId = devRecordTypeId ;
        o2.StageName = 'S1 Consult';
        o2.Description = 'Test Data';
        insert o2;
        
     
    }

    @isTest
    static void updateHighProbability(){
        Opportunity op = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity For Unit Test Purposes'];
        Test.startTest();
        SetOpportunityProbabilityController.updateProbability(op.Id, '3');
        Test.stopTest();
        Opportunity updatedOp = [SELECT Id, Probability FROM Opportunity WHERE Name = 'Test Opportunity For Unit Test Purposes'];
        System.assertEquals(80.0, updatedOp.Probability);
    }

    @isTest
    static void updateMediumProbability(){
        Opportunity op = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity For Unit Test Purposes'];
        Test.startTest();
        SetOpportunityProbabilityController.updateProbability(op.Id, '2');
        Test.stopTest();
        Opportunity updatedOp = [SELECT Id, Probability FROM Opportunity WHERE Name = 'Test Opportunity For Unit Test Purposes'];
        System.assertEquals(50.0, updatedOp.Probability);
    }

    @isTest
    static void updateLowProbability(){
        Opportunity op = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity For Unit Test Purposes'];
        Test.startTest();
        SetOpportunityProbabilityController.updateProbability(op.Id, '1');
        Test.stopTest();
        Opportunity updatedOp = [SELECT Id, Probability FROM Opportunity WHERE Name = 'Test Opportunity For Unit Test Purposes'];
        System.assertEquals(20.0, updatedOp.Probability);
    }

}
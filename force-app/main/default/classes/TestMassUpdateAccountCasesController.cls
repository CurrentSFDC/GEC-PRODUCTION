/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root
 */

@isTest
public with sharing class TestMassUpdateAccountCasesController {
    
    @testSetup
    static void setupData(){
        
        TriggerSwitch__c triggerSwitch=TestDataUtil.createTriggerSwitch('CaseTrigger',true);
        insert triggerswitch;
        
        
        Account a = new Account();
        a.Name = 'Test Account For Unit Test Purposes';
        a.BillingStreet = '350 Mission St';
        a.BillingCity = 'San Francisco';
        a.BillingState = 'CA';
        a.BillingCountry = 'US';
        a.ShippingStreet = '1095 Avenue of the Americas, 6th Ave';
        a.ShippingCity = 'New York';
        a.ShippingState = 'NY';
        a.ShippingCountry = 'US';
        insert a;
        

        Case c1 = new Case();
        c1.Status = 'New';
        c1.Origin = 'Phone';
        c1.Priority = 'High';
        c1.AccountId = a.Id;
        insert c1;

        Case c2 = new Case();
        c2.Status = 'New';
        c2.Origin = 'Phone';
        c2.Priority = 'Medium';
        c2.AccountId = a.Id;
        insert c2;
        
        // for validation rule
        Account a2 = new Account();
        a2.Name = 'Test Account For Unit Test Purposes1';
        a2.BillingStreet = '350 Mission St';
        a2.BillingCity = 'Francisco';
        a2.BillingState = 'CA';
        a2.BillingCountry = 'US';
        a2.ShippingStreet = 'Americas, 6th Ave';
        a2.ShippingCity = 'New York';
        a2.ShippingState = 'NY';
        a2.ShippingCountry = 'US';
        a2.GE_LGT_EM_PF_Type__c = 'SP';
        insert a2;
        

        Case c11 = new Case();
        c11.Status = 'New';
        c11.Origin = 'Web';
        c11.Priority = 'High';
        c11.AccountId = a2.Id;
        insert c11;

        Case c12 = new Case();
        c12.Status = 'New';
        c12.Origin = 'Web';
        c12.Priority = 'Medium';
        c12.AccountId = a2.Id;
        insert c12;
        
        
        
    }

    @isTest
    static void massUpdateAccountCases(){
        //Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account For Unit Test Purposes'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account For Unit Test Purposes1'];
        Test.startTest();
        MassUpdateAccountCasesController.massUpdateAccountCases(acc.Id);
        Test.stopTest();
        //List<Case> casesFromAccount = [SELECT Id, Status, Description, Priority FROM Case WHERE Account.Name = 'Test Account For Unit Test Purposes' LIMIT 2];
        List<Case> casesFromAccount = [SELECT Id, Status, Description, Priority FROM Case WHERE Account.Name = 'Test Account For Unit Test Purposes1' LIMIT 2];
        for(Case c : casesFromAccount){
            System.assertEquals('Closed', c.Status);
            System.assertEquals('Low', c.Priority);
            System.assertEquals('Case Closed.', c.Description);
        }
    }
}
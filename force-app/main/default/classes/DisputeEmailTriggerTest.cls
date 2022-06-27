@isTest
public class DisputeEmailTriggerTest {
   
    @isTest     
    static void DisputeEmailTriggerTestMet(){
  
        Account acc = new account();
        acc.Name = 'Acc1';
        insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        //con.Name = 'Con1';
        con.Email = 'con1@gecurrent.com';
        con.LastName = 'ConTest';
        con.FirstName = 'conFi';
        insert con;
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.Type = 'Warranty';
        ca.Status = 'Approved';
        
        insert ca;
        Order oo = new Order();
        oo.AccountId = acc.id;
        oo.EffectiveDate = Date.today();
        oo.Status = 'Draft';
        
       // insert oo;
        CaseTriggerHandler.isFirstTime=True;
        Dispute_Request__c dr = new Dispute_Request__c();
        dr.Case__c = ca.Id;
        dr.Status__c = 'Approved';
        insert dr;
  	   
    }
        
}
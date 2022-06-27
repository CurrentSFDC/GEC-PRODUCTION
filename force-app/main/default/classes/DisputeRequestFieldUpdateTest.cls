/*
Name - DisputeRequestFieldUpdateTest
Methods - Testmethod1		  
Purpose - Test Class for 'DisputeRequestFieldUpdate' trigger
*/

@istest(SeeAllData=true)
public class DisputeRequestFieldUpdateTest {
    
    static testmethod void Testmethod1(){
        Account Acc = new Account(Name = 'TestAcc');
        Insert Acc;
        
        contact ca = new contact(FirstName= 'testCon', LastName='test', Email='abc@xyz.com', AccountId= Acc.id);
        insert ca;
        
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email', Spec_Reg_Agency__c = Acc.id ); 
        insert cas;
        
        Dispute_Request__c disc = new   Dispute_Request__c();
        disc.Case__c = cas.id;
        disc.Status__c = 'Approved';
        disc.Transaction_ID__c= 'Return';
        insert disc;
    }
}
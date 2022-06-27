/*
Trigger Name - RevisionBeforeInsertUpdate
Purpose - This trigger wil pull email id from 'OSR.Pricing_Approver__c', and populate the same on 'Revision.OSR_Pricing_Approver_Email__c'
Test Class Name - GE_LGT_OSR_Revision_Test
Author - Neel
Creation - April-2015
*/

trigger RevisionBeforeInsertUpdate on Revision__c (Before Insert, Before Update) {
    if(trigger.isBefore) {
      for(Revision__c revisionVar : Trigger.New){
          if(revisionVar.Opportunity_Support_Request__r.Status__c=='In Progress' && revisionVar.Opportunity_Support_Request__r.Pricing_Approver__c<>''){
          revisionVar.OSR_Pricing_Approver_Email__c=revisionVar.Opportunity_Support_Request__r.Pricing_Approver__r.Email;
          }
       }
     }
}
trigger NewApprover on Sales_Concession_Request__c (before insert, before update) {

UpdateApprover.ChangeApprover();


}
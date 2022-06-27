trigger SalesConcession_Auto_CaseCreation on Sales_Concession_Request__c (before update, after update,after insert) {
    If((Trigger.isInsert||Trigger.isUpdate) && Trigger.isAfter){
      SalesConcessionAutoCaseCreationhelper.AutoCaseCreation(trigger.new);
     }
}
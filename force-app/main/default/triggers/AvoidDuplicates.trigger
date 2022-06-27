trigger AvoidDuplicates on SAP_Records_Recycle__c (After insert) {
  SAPRecordsRecycleTriggerHelper deh = new SAPRecordsRecycleTriggerHelper();
  deh.DeleteDuplicateEdcr(Trigger.new);
}
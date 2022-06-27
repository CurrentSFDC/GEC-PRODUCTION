/**
 * Created by PA on 2021. 06. 03..
 */

trigger CustomerProductFamilyTrigger on CustomerProductFamily__c (before insert, before update, after insert, after update) {
    if (Trigger.isInsert && Trigger.isBefore) {
        new CustomerProductFamilyController().setAccountLookup(Trigger.new);
    }
    if (Trigger.isUpdate && Trigger.isBefore) {
        new CustomerProductFamilyController().setAccountLookup(Trigger.new);
    }
}
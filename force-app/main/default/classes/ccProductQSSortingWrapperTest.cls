/**
 * Created by david on 2021. 12. 07..
 */

@IsTest
private class ccProductQSSortingWrapperTest {
    @IsTest
    static void testBehaviorDESC() {
        ccProductQSSortingWrapper[] qsProdList = new List<ccProductQSSortingWrapper>();
        qsProdList.add(new ccProductQSSortingWrapper(new ccrz__E_Product__c(Inventory_Available__c = 500),'DESC'));
        qsProdList.add(new ccProductQSSortingWrapper(new ccrz__E_Product__c(Inventory_Available__c = 100),'DESC'));
        qsProdList.add(new ccProductQSSortingWrapper(new ccrz__E_Product__c(Inventory_Available__c = 200),'DESC'));
        qsProdList.add(new ccProductQSSortingWrapper(new ccrz__E_Product__c(Inventory_Available__c = 0),'DESC'));
        qsProdList.add(new ccProductQSSortingWrapper(new ccrz__E_Product__c(Inventory_Available__c = null),'DESC'));

        qsProdList.sort();
    }

    @IsTest
    static void testBehaviorASC() {
        ccProductQSSortingWrapper[] qsProdList = new List<ccProductQSSortingWrapper>();
        qsProdList.add(new ccProductQSSortingWrapper(new ccrz__E_Product__c(Inventory_Available__c = 500),'ASC'));
        qsProdList.add(new ccProductQSSortingWrapper(new ccrz__E_Product__c(Inventory_Available__c = 100),'ASC'));
        qsProdList.add(new ccProductQSSortingWrapper(new ccrz__E_Product__c(Inventory_Available__c = 200),'ASC'));
        qsProdList.add(new ccProductQSSortingWrapper(new ccrz__E_Product__c(Inventory_Available__c = 0),'ASC'));
        qsProdList.add(new ccProductQSSortingWrapper(new ccrz__E_Product__c(Inventory_Available__c = null),'ASC'));

        qsProdList.sort();
    }
}
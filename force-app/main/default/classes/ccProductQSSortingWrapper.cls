/**
 * Created by david on 2021. 11. 17..
 */

global class ccProductQSSortingWrapper implements Comparable {

    public ccrz__E_Product__c product;
    String order = 'ASC';

    // Constructor
    public ccProductQSSortingWrapper(ccrz__E_Product__c prod, String ord) {
        product = prod;
        order = ord;
    }
    // Compare opportunities based on the opportunity amount.
    global Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityWrapper
        ccProductQSSortingWrapper compareToProd = (ccProductQSSortingWrapper)compareTo;
        system.debug('ORDER '+order);
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (order == 'ASC') {
            if (product.Inventory_Available__c > compareToProd.product.Inventory_Available__c) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (product.Inventory_Available__c < compareToProd.product.Inventory_Available__c) {
                // Set return value to a negative value.
                returnValue = -1;
            } else if ((product.Inventory_Available__c == null) && (compareToProd.product.Inventory_Available__c != null)) {
                // nulls-first implementation
                returnValue = -1;
            } else if ((product.Inventory_Available__c != null) && (compareToProd.product.Inventory_Available__c == null)) {
                // nulls-first implementation
                returnValue = 1;
            }
        } else {
            if (product.Inventory_Available__c < compareToProd.product.Inventory_Available__c) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (product.Inventory_Available__c > compareToProd.product.Inventory_Available__c) {
                // Set return value to a negative value.
                returnValue = -1;
            } else if ((product.Inventory_Available__c == null) && (compareToProd.product.Inventory_Available__c != null)) {
                // nulls-first implementation
                returnValue = -1;
            } else if ((product.Inventory_Available__c != null) && (compareToProd.product.Inventory_Available__c == null)) {
                // nulls-first implementation
                returnValue = 1;
            }
        }
        return returnValue;
    }
}
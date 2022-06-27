global with sharing class ccCartService extends ccrz.ccServiceCart {
	global virtual override Map <String, Object> getFieldsMap(Map <String, Object> inputData) {
        //system.debug('Sub Prod Term');
        inputData = super.getFieldsMap(inputData);
        String objectFields = (String) inputData.get(ccrz.ccService.OBJECTFIELDS);
        objectFields += ', Delivery_Contact_Name__c, Delivery_Contact_Phone__c, Agreement_Number__c, Partial_Ship__c, Order_Type__c, Carrier_Account__c, Delivery_Block__c, Requested_Delivery_Date__c, Shipping_Instructions__c, Sample_Order__c, Order_Reason__c, Strategic_Account_L__c, Serial_Number__c, Project_Name__c, Project_Description__c, Project_Country__c, Project_State__c, Project_City__c, Project_Postal_Code__c, Sold_To_Account__r.Name,Z002Address__c, Lot_Pricing__c, Lot_Pricing_Amount__c, Valid_From__c, Valid_To__c,ShippingType__c,Ship_Not_Before_Date__c,Ship_Complete__c';
        return new Map <String, Object> {ccrz.ccService.OBJECTFIELDS => objectFields};
    }

}
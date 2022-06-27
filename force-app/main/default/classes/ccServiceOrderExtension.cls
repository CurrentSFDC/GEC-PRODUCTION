global with sharing class ccServiceOrderExtension extends ccrz.ccServiceOrder {
	global virtual override Map<String,Object> getFieldsMap(Map<String,Object> inputData){

        inputData = super.getFieldsMap(inputData);
        String objectFields = (String) inputData.get(ccrz.ccService.OBJECTFIELDS);
        objectFields += ',SAP_Order_Number__c, Agreement_Number__c, Revise_Agreement_Number__c, Order_Type__c,ShippingType__c,Z002Address__c';
        
        return new Map<String,Object> {ccrz.ccService.OBJECTFIELDS => objectFields};
    }
}
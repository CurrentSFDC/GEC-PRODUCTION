global with sharing class ccServiceCartExtension extends ccrz.ccServiceCart {
    global virtual override Map<String,Object> getFieldsMap(Map<String,Object> inputData){
        
        inputData = super.getFieldsMap(inputData);
        String objectFields = (String) inputData.get(ccrz.ccService.OBJECTFIELDS);
        objectFields += ',Order_Type__c, Sold_To_Account__r.Name';

        return new Map<String,Object> {ccrz.ccService.OBJECTFIELDS => objectFields};
    }
}
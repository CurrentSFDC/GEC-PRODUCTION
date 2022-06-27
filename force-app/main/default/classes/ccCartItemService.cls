global class ccCartItemService extends ccrz.ccServiceCartItem {
	global override Map<String, Object> getFieldsMap(Map<String, Object> inputData) {
		ccrz.ccLog.log(LoggingLevel.INFO, 'M:E', 'b2b_CartItemService:getFieldsMap');

		inputData = super.getFieldsMap(inputData);
		String objectFields = (String) inputData.get(ccrz.ccService.OBJECTFIELDS);
		objectFields += ', Type_Marks__c, Requested_Delivery_Date__c, Reorder_Agreement_Invalid__c, Agreement_Number__c';

		ccrz.ccLog.log(LoggingLevel.INFO, 'M:X', 'b2b_CartItemService:getFieldsMap');
		return new Map<String, Object>{ ccrz.ccService.OBJECTFIELDS => objectFields };
	}
}
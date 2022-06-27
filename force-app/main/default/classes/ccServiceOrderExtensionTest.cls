@isTest
public class ccServiceOrderExtensionTest {
	@isTest
	public static void getFieldsMap_ContainsCustomFields() {
			String expected = 'SAP_Order_Number__c';
			
			Test.startTest();
			ccServiceOrderExtension service = new ccServiceOrderExtension();
				Map<String, Object> output = service.getFieldsMap(new Map<String, Object> {

				});

				String actual = (String) output.get(ccrz.ccService.OBJECTFIELDS);
			Test.stopTest();

			System.debug(LoggingLevel.ERROR, actual);
			System.assert(actual.contains(expected), 'Custom fields missing from Query SELECT');
	}
}
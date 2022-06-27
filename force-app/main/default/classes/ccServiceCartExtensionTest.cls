@isTest
public class ccServiceCartExtensionTest {
    
    @isTest public static void testGetFieldsMap(){
        ccServiceCartExtension instance = new ccServiceCartExtension();
        Map<String, Object> result = instance.getFieldsMap(new Map<String, Object>{
            ccrz.ccService.OBJECTFIELDS => 'Id'
        });
        System.assertNotEquals(null, result);
    }
}
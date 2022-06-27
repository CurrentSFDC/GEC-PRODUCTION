@isTest
public class ccCartServiceTest {
    
    @isTest public static void testGetFieldsMap(){
        ccCartService instance = new ccCartService();
        Map<String, Object> result = instance.getFieldsMap(new Map<String, Object>{
            ccrz.ccService.OBJECTFIELDS => 'Id'
        });
        System.assertNotEquals(null, result);
    }
}
@isTest
public class ccCartItemServiceTest {
    
    @isTest public static void testGetFieldsMap(){
        ccCartItemService instance = new ccCartItemService();
        //ccrz.cc_CallContext.currUIKey = 'plp';
        Map<String, Object> result = instance.getFieldsMap(new Map<String, Object>{
            ccrz.ccService.OBJECTFIELDS => 'Id'
        });
        System.assertNotEquals(null, result);
    }
}
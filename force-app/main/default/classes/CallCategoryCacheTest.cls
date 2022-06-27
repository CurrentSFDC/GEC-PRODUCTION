/*---------------------------------------------------------------------------------
Name:       CallCategoryCacheTest.cls
Purpose:    Test Class to call CallCategoryCache.
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          06-Dec-2020             Initial Development 
---------------------------------------------------------------------------------*/
@isTest
public class CallCategoryCacheTest {

    private static void setupData() {
        ccrz.ccApiTestData.setupData(new Map<String,Map<String,Object>>{
            ccrz.ccApiTestData.STOREFRONT_SETTINGS => new Map<String,Object> {
                    'DefaultStore' => new Map<String,Object> {}
            },
            ccrz.ccApiTestData.APPLICATION_SETTINGS => new Map<String, Object> {}
        });
    }

    public static testMethod void getCategory() {

        setupData();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/commerce/category';
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');

        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        CallCategoryCache.doGet();
        Test.stopTest();
    }

    
    public static testMethod void createCategoryCache() {

        setupData();
        Test.startTest();
        CallCategoryCache.createCategoryCache();
        Test.stopTest();
    }

}
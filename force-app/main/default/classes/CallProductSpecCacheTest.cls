/*---------------------------------------------------------------------------------
Name:       CallProductSpecCacheTest.cls
Purpose:    Test Class to call Product Spec Cache.
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          06-Dec-2020             Initial Development 
---------------------------------------------------------------------------------*/
@isTest
public class CallProductSpecCacheTest {

    private static void setupData() {
        ccrz.ccApiTestData.setupData(new Map<String,Map<String,Object>>{
            ccrz.ccApiTestData.STOREFRONT_SETTINGS => new Map<String,Object> {
                    'DefaultStore' => new Map<String,Object> {}
            },
            ccrz.ccApiTestData.APPLICATION_SETTINGS => new Map<String, Object> {}
        });
    }

    public static testMethod void getProductSpec() {

        setupData();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/commerce/productspec';
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');

        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        CallProductSpecCache.doGet();
        Test.stopTest();
    }

    
    public static testMethod void createProductSpecIndex() {

        setupData();
        Test.startTest();
        CallProductSpecCache.createProductSpecIndex();
        Test.stopTest();
    }
}
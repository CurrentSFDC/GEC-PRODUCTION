/**
 * Created by PA on 2021. 04. 28..
 */

@IsTest
private class MaterialMasterLoaderTest {
    @IsTest
    static void testBehavior() {
        Account acc = new Account(Name='test');
        insert acc;
        GE_LGT_EM_MaterialMaster__c mat = new GE_LGT_EM_MaterialMaster__c(GE_LGT_EM_MaterialDescription__c = 'test', GE_LGT_EM_SAP_MaterialNumber__c = 'test', Level_1__c = 'IFLtest');
        insert mat;
        ccrz__E_Product__c ccProd= new ccrz__E_Product__c(ccrz__SKU__c = 'test');
        insert ccProd;
        Pricing_UOM__c pricingUOM = new Pricing_UOM__c(Name = 'TestCV', SKU__c = 'test', CC_Product__c = ccProd.Id, SKU_UOM_Key__c = 'CV');
        insert pricingUOM;
        Pricing_UOM__c pricingUOM2 = new Pricing_UOM__c(Name = 'TestBX', SKU__c = 'test', CC_Product__c = ccProd.Id, SKU_UOM_Key__c = 'BX');
        insert pricingUOM2;

        List<String> prodFamilyList = new List<String>{'IFL','HID', 'IFN'};
        MaterialMasterLoader.loadMaterialMastersFromDatabase(prodFamilyList, 'test', 'QuickStockReturn');
        MaterialMasterLoader.loadMaterialMastersFromDatabase(prodFamilyList, 'test', 'stockAccomodationReturn');
        MaterialMasterLoader.loadMaterialMastersFromDatabase(prodFamilyList, 'test', 'Warranty');
        MaterialMasterLoader.loadMaterialMastersFromDatabase(prodFamilyList, 'test', 'claimBack');
        MaterialMasterLoader.loadMaterialMastersFromDatabase(prodFamilyList, 'test', 'Default');
    }
}
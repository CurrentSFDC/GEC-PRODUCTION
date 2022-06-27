/**
 * Created by Dezső on 2022. 03. 11..
 */

@IsTest
private class UOMServicesTest {

    @IsTest
    static void testBehavior() {
        ccrz__E_Product__c prod1 = TestDataFactory.createCCProduct('9999999', 'TestItem1', true);
        ccrz__E_Product__c prod2 = TestDataFactory.createCCProduct('8888888', 'TestItem2', true);
        TestDataFactory.createPricingUOM(prod1.Id, prod1.ccrz__SKU__c);
        TestDataFactory.createPricingUOM(prod2.Id, prod2.ccrz__SKU__c);
        Pricing_UOM__c p1 = new Pricing_UOM__c(CC_Product__c = prod1.Id, SKU_UOM_Key__c = prod1.ccrz__SKU__c + '_EA' ,  Multiplier__c = 1,  UOM__c = 'EA', SKU__c = prod1.ccrz__SKU__c );
        Pricing_UOM__c p2 = new Pricing_UOM__c(CC_Product__c = prod1.Id, SKU_UOM_Key__c = prod1.ccrz__SKU__c + '_NL' ,  Multiplier__c = 3,  UOM__c = 'NL', SKU__c = prod1.ccrz__SKU__c, EAN_ID_Type__c = 'ZU' );
        List<Pricing_UOM__c> pl = new List<Pricing_UOM__c>();
        pl.add(p1);
        pl.add(p2);
        insert pl;
        List<String> prods = new List<String>{prod1.ccrz__SKU__c, prod2.ccrz__SKU__c};
        Test.startTest();
        List<Pricing_UOM__c> uoms = UOMServices.getUOMsForProducts(prods);
        Test.stopTest();
        System.assertEquals(4, uoms.size());
        for (Pricing_UOM__c uom : uoms) {
            if (uom.CC_Product__c == prod1.Id && uom.Multiplier__c == 1) {
                System.assertEquals('EA', uom.UOM__c);
            } else
            if (uom.CC_Product__c == prod1.Id && uom.Multiplier__c == 3) {
                System.assertEquals('NL', uom.UOM__c);
            } else
            if (uom.CC_Product__c == prod2.Id && uom.Multiplier__c == 1) {
                System.assertEquals('PC', uom.UOM__c);
            } else
            if (uom.CC_Product__c == prod2.Id && uom.Multiplier__c == 3) {
                System.assertEquals('BX', uom.UOM__c);
            } else {
                throw new TypeException('Bad UOM passed through!');
            }
        }
    }

}
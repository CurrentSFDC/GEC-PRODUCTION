@IsTest 
public with sharing class ccLogicProductPricingExtensionTest {

    @IsTest public static void testProduct(){

        Decimal qty = 100;

            Map<String, Object> input = new Map<String, Object> {
                'productList' => new List<Map<String, Object>> {
                    new Map<String, Object> {
                        'SKU' => 'SKU1234',
                        'productType' => 'Product',
                        'productId' => 'SKU1234-1234',
                        'basePrice' => 10,
                        'price' => 7,
                        'savings' => 3,
                        'sfid' => 'mockid',
                        'productInventoryItemsS' => new List<Map<String,Object>>{
                            new Map<String, Object>{
                                'qtyAvailable' => qty
                            }
                        }
                    }
                },
                ccrz.ccApiProduct.PRODUCTPRICINGDATA => new Map<String, Object> {
                    'mockid' => new Map<String, Object> {
                        'savings' => 3,
                        'basePrice' => new Map<String,Object> {
                            'subTotal' => 1,
                            'quantity' => 2
                        },
                        'productPrice' => new Map<String,Object> {
                            'subTotal' => 1,
                            'quantity' => 2						
                        }
                    }
                }
            };

            ccLogicProductPricingExtension ccLog = new ccLogicProductPricingExtension();
            ccLog.evaluatePricing(input);

    }
}
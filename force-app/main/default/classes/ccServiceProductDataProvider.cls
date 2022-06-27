/********************************************************************
Purpose: Extend ccServiceProduct to include custom fields, needed to display these fields in the storefront UI

History:
--------
VERSION  AUTHOR       DATE         DESCRIPTION
1.0      Alex Bowser  20-OCT-2020  Created
*/
global with sharing class ccServiceProductDataProvider extends ccrz.ccServiceProduct {


    global virtual override Map<String, Object> getFieldsMap(Map<String, Object> inputData) {
        inputData = super.getFieldsMap(inputData);
        //System.debug(LoggingLevel.FINE, 'getFieldsMap input' + JSON.serializePretty(inputData));
        String objectFields = (String) inputData.get(ccrz.ccService.OBJECTFIELDS);
        objectFields += ', SKU_24_48hr__c, lastModifiedDate, MaterialType__c, MaterialDescription__c, Product_Family__c, UPC__c,Quickship__c, Total_Standard_Inventory__c, Inventory_Available__c, ECommItemName__c';

        return new Map<String, Object>{
                ccrz.ccService.OBJECTFIELDS => objectFields
        };
    }

    global override Map<String, Object> getFilterMap(Map<String, Object> inp) {
        inp = super.getFilterMap(inp);
        //System.debug(LoggingLevel.FINE, 'getFilterMap input' + JSON.serializePretty(inp));
        return inp;
    }

    global override Map<String, Object> getOrderByMap(Map<String, Object> inp) {
        inp = super.getOrderByMap(inp);
        System.debug(LoggingLevel.FINE, 'getOrderByMap input' + JSON.serializePretty(inp));
        return inp;
    }

    global override Map<String, Object> transformOut(Map<String, Object> inp) {
        inp = super.transformOut(inp);
        //System.debug(LoggingLevel.FINE, 'transformOut input' + JSON.serializePretty(inp));
        return inp;
    }

    global override Map<String, Object> prepReturn(Map<String, Object> inp) {
        inp = super.prepReturn(inp);
        //System.debug(LoggingLevel.FINE, 'prepReturn input' + JSON.serializePretty(inp));
        return inp;
    }

    global virtual override Map<String, Object> fetch(Map<String, Object> inputData) {

        inputData = super.fetch(inputData);
        system.debug('inputData before '+JSON.serializePretty((List<Map<String,Object>>)inputData.get('productList')));
        inputData = mergeOtherData(inputData);
        try {
            //System.debug(LoggingLevel.FINE, 'fetch input' + JSON.serializePretty(inputData));
            System.debug('inputdata.size: ' + inputData.size());
            for (String str : inputData.keySet()) {
                System.debug(str);
            }
            List<Map<String,Object>> myMap = (List<Map<String,Object>>)inputData.get('productList');
            for (Map<String, Object> innerMap : myMap) {
                System.debug(innerMap.keySet());
            }
        } catch (Exception e) {
            System.debug(e);
        }
        return inputData;
    }

     

    global override Map<String, Object> getSubQueryMap(Map<String, Object> input) {
        input = super.getSubQueryMap(input);
        input.put('Pricing_UOM__r', '(SELECT Id,Multiplier__c,UOM__c,SKU__c FROM Pricing_UOM__r)');
        return input;
    }

    global override Map<String, Object> getFindFieldsClauseMap(Map<String, Object> inp) {
        inp = super.getFindFieldsClauseMap(inp);
        //System.debug(LoggingLevel.FINE, 'getFindFieldsClauseMap input' + JSON.serializePretty(inp));
        return inp;
    }

    global override Map<String, Object> getReturnClauseMap(Map<String, Object> inp) {
        inp = super.getReturnClauseMap(inp);
        //System.debug(LoggingLevel.FINE, 'getReturnClauseMap input' + JSON.serializePretty(inp));
        return inp;
    }

    global override Map<String, Object> processSearchResult(Map<String, Object> inp) {
        inp = super.processSearchResult(inp);
        //System.debug(LoggingLevel.FINE, 'processSearchResult input' + JSON.serializePretty(inp));
        System.debug('processSearchResult input size: ' + inp.size());
        return inp;
    }

    global override Map<String,Object> runQuery(Map<String,Object> inp) {
        System.debug(LoggingLevel.FINE, 'runQuery input' + inp.get('queryString'));
        System.debug(LoggingLevel.FINE, 'runQuery input' + JSON.serializePretty(inp));
        String queryString = String.ValueOf(inp.get('queryString'));
        system.debug('queryStringTest'+queryString);
        queryString = queryString.replaceAll('ORDER BY  Id','ORDER BY Total_Standard_Inventory__c DESC NULLS LAST');
        system.debug('queryString '+queryString);
        //inp.put('queryString',queryString);
        System.debug(LoggingLevel.FINE, 'runQuery input' + inp.get('queryString'));

        inp = super.runQuery(inp);

        try {
            System.debug('runQuery input size: ' + inp.size());
            for (String str : inp.keySet()) {
                System.debug(str);
            }
            System.debug(((List<ccrz__E_Product__c>)inp.get('queryResults')).size());
            System.debug(((List<ccrz__E_Product__c>)inp.get('queryResults')));
//        System.debug('runQuery products: ' + inp.get('productList'));
        } catch (Exception e) {
            System.debug(e);
        }
        return inp;
    }

    global override Map<String, Object> search(Map<String, Object> inp) {
        inp = super.search(inp);
        //System.debug(LoggingLevel.FINE, 'search input' + JSON.serializePretty(inp));
        return inp;
    }

    @TestVisible
    private Map<String, Object> mergeOtherData(Map<String, Object> inputData) {
        System.debug('mergeOtherData inputData\n' + JSON.serializePretty(inputData));
        Id userId = UserInfo.getUserId();
        String perSet = 'Default_Profile';
        try {
            Account currentAccount = [SELECT Id, GE_LGT_Rep_Code__c,Delivering_Plant__c, Account_Group__c,GE_LGT_EM_Sales_Org__c FROM Account WHERE Id = :ccrz.cc_CallContext.currAccountId];
            Account effectiveAccount = [SELECT Id, GE_LGT_Rep_Code__c, Account_Group__c, Delivering_Plant__c FROM Account WHERE Id = :ccrz.cc_CallContext.effAccountId];

            List<Map<String, Object>> products = (List<Map<String, Object>>) inputData.get(ccrz.ccAPIProduct.PRODUCTLIST);
            System.debug('ccrz.ccAPIProduct.PRODUCTLIST ' + inputData.get(ccrz.ccAPIProduct.PRODUCTLIST));
            Map<Id, Map<String, Object>> productsByIds = new Map<Id, Map<String, Object>>();
            Map<String, Map<String, Object>> productsByMaterialNumber = new Map<String, Map<String, Object>>();
            //system.debug('TDBG '+JSON.serializePretty(products));
            for (Map<String, Object> product : products) {
                productsByIds.put(String.valueOf(product.get('sfid')), product);
                system.debug('TDBG SKU '+product.get('SKU'));
                system.debug('TDBG SKU '+product);
                if (product.get('SKU') != null) {
                    productsByMaterialNumber.put(String.valueOf(product.get('SKU')), product);
                }
            }
            system.debug('TDBG so '+currentAccount.GE_LGT_EM_Sales_Org__c);
            system.debug('TDBG cc prod '+productsByIds.keySet());
            for (Sales_Org_Product__c salesOrgProduct : [
                    SELECT Id,CC_Product__c,Minimum_Order_Quantity_in_PC__c
                    FROM Sales_Org_Product__c
                    WHERE CC_Product__c IN :productsByIds.keySet() AND Sales_Org_Agent__c = :currentAccount.GE_LGT_EM_Sales_Org__c
            ]) {
                productsByIds.get(salesOrgProduct.CC_Product__c).put('salesOrgProduct', salesOrgProduct);
            }

            Map<String,Warehouse__mdt> whMap = new Map<String,Warehouse__mdt>();

            for (Warehouse__mdt wh : Warehouse__mdt.getAll().values()) {
                whMap.put(wh.Code__c,wh);
            }
            system.debug('TDBG products '+productsByMaterialNumber.keySet());
            //fixvalue test
            integer i=0;
            /*
            for (String key : productsByMaterialNumber.keySet()) {
                productsByMaterialNumber.get(key).put('inventoryAvailable',(decimal)i);
                productsByMaterialNumber.get(key).put('totalStandardInventory',(decimal)i);
                i++;
            }
            
             */
            for (Map<String, Object> product : products) {
                product.put('inventoryAvailable', 0);
                product.put('totalStandardInventory', 0);
            }

            for (Inventory__c inventory : [
                    SELECT Id,QuickStock__c,Plant__c, Stock__c,Material_Master__r.GE_LGT_EM_SAP_MaterialNumber__c, CC_Product__c
                    FROM Inventory__c
                    WHERE CC_Product__c IN:productsByIds.keySet() //Material_Master__r.GE_LGT_EM_SAP_MaterialNumber__c IN :productsByMaterialNumber.keySet()
            ]) {
                Map<String, Object> product = productsByIds.get(inventory.CC_Product__c);
                //Map<String, Object> product = productsByMaterialNumber.get(inventory.Material_Master__r.GE_LGT_EM_SAP_MaterialNumber__c);
                if (product.get('inventories') == null) {
                    product.put('inventories', new List<Inventory__c>{
                            inventory
                    });
                } else {
                    List<Inventory__c> inventories = (List<Inventory__c>) product.get('inventories');
                    inventories.add(inventory);
                }
                if (inventory.Stock__c != null && (whMap.containsKey(inventory.Plant__c) && (whMap.get(inventory.Plant__c).Standard__c == true || whMap.get(inventory.Plant__c).Code__c == effectiveAccount.Delivering_Plant__c))) {
                    if (product.get('totalStandardInventory') == null) {
                        product.put('totalStandardInventory', (Decimal) inventory.Stock__c);
                    } else {
                        product.put('totalStandardInventory', (Decimal) product.get('totalStandardInventory') + inventory.Stock__c);
                    }
                }
                system.debug('TDBG '+inventory.Stock__c);
                system.debug('quickship '+product.get('quickship'));
                system.debug('effectiveAccount '+effectiveAccount);
                system.debug('currentAccount '+currentAccount);

                if (product.get('quickship') == true && inventory.Stock__c != null && effectiveAccount.Delivering_Plant__c == inventory.Plant__c) {
                    system.debug('TDBG '+product.get('quickship'));
                    if (product.get('QuickStock__c') == null) {
                        product.put('inventoryAvailable', inventory.Stock__c);
                    } else {
                        product.put('inventoryAvailable', (Decimal) product.get('inventoryAvailable') + inventory.Stock__c);
                    }
                }
                if (product.get('quickship') == false) {
                    product.put('inventoryAvailable', 0);
                }
            }
            


            //Changed done for the AGENT permission set and profile check
            User u = [SELECT Id, Profile.Name, Name FROM User WHERE Id = :userId];
            List<PermissionSetAssignment> psa = [
                    SELECT Id, AssigneeId, Assignee.Name, Assignee.Profile.Name, PermissionSet.IsOwnedByProfile, PermissionSetId,PermissionSet.Name
                    FROM PermissionSetAssignment
                    WHERE PermissionSet.Name = 'View_PLP_and_PDP_Prices'
                    AND AssigneeId IN (SELECT Id FROM User WHERE Id = :userId)
            ];
            for (PermissionSetAssignment psa1 : psa) {
                if (psa1.PermissionSet.Name == 'View_PLP_and_PDP_Prices') {
                    perSet = 'View_PLP_and_PDP_Prices';
                } else {
                    perSet = 'Default_Profile';
                }
            }
            //End
            Set<String> currUIKeys = new Set<String>{
                    ccrz.cc_CallContext.currUIKey, ccrz.cc_CallContext.currPageUIKey
            };

            Set<String> skus = new Set<String>();
            System.debug(currUIKeys);
            if (currUIKeys.contains('plp') || currUIKeys.contains('pdp') || Test.isRunningTest()) {
                System.debug('products length' + products.size());
                for (Map<String, Object> product : products) {
                    skus.add(String.valueOf(product.get('SKU')));
                }
                List<Pricing_UOM__c> validUomsByNewLogic = UOMServices.getUOMsForProducts(skus);
                for (Map<String, Object> product : products) {
                    System.debug('Extending product: ' + product.get('SKU'));
                    product.put('repCode', currentAccount.GE_LGT_Rep_Code__c);
                    product.put('GEAccountGroup', currentAccount.Account_Group__c);
                    product.put('EffectiveGEAccountGroup', effectiveAccount.Account_Group__c);
                    product.put('EffectiveRepCode', effectiveAccount.Account_Group__c);
                    product.put('priceUpdate', false);
                    product.put('priceAgreement', '');
                    product.put('approvedPriceAgreementPresent', false);
                    product.put('profileName', u.Profile.Name);
//                    product.put('isUserAgent',new Set<String>{'Agent Read Only B2B Storefront Registered Users', 'Agent B2B Storefront Registered Users'}.contains(u.Profile.Name) );
                    product.put('isUserAgent', currentAccount.Account_Group__c == 'ZEAG');
                    product.put('permissionSet', perSet);
                    if (product.containsKey('pricingUOMS')) {
                        product.put('piecesPerUnit', null);
                        product.put('unitOfMeasure', null);
                        List<Object> pricingUOMS = (List<Object>) product.get('pricingUOMS');
                        if (pricingUOMS.size() > 0) {
                            System.debug('pricing uom size: ' + pricingUOMS.size());
                            if (product.containsKey('salesOrgProduct')) {
                                //Sales_Org_Product__c salesOrgProduct = (Sales_Org_Product__c) product.get('salesOrgProduct');
                                Map<String, Map<String, Object>> pricingUOMsByUOM = new Map<String, Map<String, Object>>();
                                    for (Object pricingUOM : (List<Object>) pricingUOMS) {
                                        Map<String, Object> uomMap = (Map<String, Object>) pricingUOM;
                                        for (Pricing_UOM__c validUOM : validUomsByNewLogic) {
                                            if (validUOM.SKU__c == String.valueOf(product.get('SKU')) && validUOM.UOM__c == String.valueOf(uomMap.get('UOM'))) {
                                                pricingUOMsByUOM.put(String.valueOf(uomMap.get('UOM')), (Map<String, Object>) pricingUOM);
                                                break;
                                            }
                                        }
                                    }

                                /*if (pricingUOMsByUOM.containsKey('EA') && pricingUOMsByUOM.containsKey('PC')
                                        && pricingUOMsByUOM.get('EA').get('multiplier') == pricingUOMsByUOM.get('PC').get('multiplier')) {
                                    pricingUOMsByUOM.remove('PC');
                                }
                                if (pricingUOMsByUOM.containsKey('CV') && pricingUOMsByUOM.containsKey('BX')
                                        && pricingUOMsByUOM.get('CV').get('multiplier') == pricingUOMsByUOM.get('BX').get('multiplier')) {
                                    pricingUOMsByUOM.remove('BX');
                                }*/
                                product.put('pricingUOMS', pricingUOMsByUOM.values());

                                /*for (Map<String, Object> pricingUOM : pricingUOMsByUOM.values()) {
                                    Decimal multiplier = (Decimal) pricingUOM.get('multiplier');
                                    if (multiplier != null && salesOrgProduct.Minimum_Order_Quantity_in_PC__c == multiplier) {
                                        product.put('piecesPerUnit', pricingUOM.get('multiplier'));
                                        product.put('unitOfMeasure', pricingUOM.get('UOM'));
                                        break;
                                    }
                                }*/
                                
                                //Logic change for defaulting UOM
                                 for (Map<String, Object> pricingUOM : pricingUOMsByUOM.values()) {
                                    Decimal multiplier = (Decimal) pricingUOM.get('multiplier');
                                    if (multiplier != null && pricingUOM.get('UOM')=='PC') {
                                        product.put('piecesPerUnit', pricingUOM.get('multiplier'));
                                        product.put('unitOfMeasure', pricingUOM.get('UOM'));
                                        break;
                                    }
                                    else if(multiplier != null && pricingUOM.get('UOM')=='EA'){
                                        product.put('piecesPerUnit', pricingUOM.get('multiplier'));
                                        product.put('unitOfMeasure', pricingUOM.get('UOM'));
                                    }
                                }

                                if (product.get('piecesPerUnit') == null && product.get('unitOfMeasure') == null && pricingUOMsByUOM.values().size() > 0) {
                                    product.put('piecesPerUnit', pricingUOMsByUOM.values()[0].get('multiplier'));
                                    product.put('unitOfMeasure', pricingUOMsByUOM.values()[0].get('UOM'));
                                }
                                //System.debug('pricingUOMS:\n' + JSON.serializePretty(product.get('pricingUOMS')));
                            }
                        }
                    }
                }
                System.debug('plp skus=' + skus);
                Map<String, Boolean> mapSkuPA = PriceAgreementServices.isPriceAgreementValidForTheseProducts(ccrz.cc_CallContext.effAccountId, skus);
                if (mapSkuPA != null) {
                    for (String sku : mapSkuPA.keySet()) {
                        System.debug('plp skus=****' + sku);
                        if (mapSkuPA.get(sku) == true) {
                            for (Map<String, Object> product : products) {
                                if (sku == product.get('SKU')) {
                                    product.put('approvedPriceAgreementPresent', true);
                                    System.debug('plp skus=****approvedPriceAgreementPresent true' + sku);
                                }
                            }
                        }
                    }
                }
                inputData.put(ccrz.ccAPIProduct.PRODUCTLIST, products);
            }
        } catch (Exception ex) {
            System.debug(ex);
            System.debug(ex.getStackTraceString());
            ccrz.ccLog.log(LoggingLevel.ERROR, 'DEV:ccServiceProductDataProvider.mergeOtherData - Error:', ex.getMessage());
        }
        //system.debug('DEBUG productlist '+JSON.serializePretty((List<Map<String,Object>>)inputData.get('productList')));
        return inputData;
    }
}
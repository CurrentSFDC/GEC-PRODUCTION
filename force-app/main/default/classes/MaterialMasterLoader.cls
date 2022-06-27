public without sharing class MaterialMasterLoader {

    static List<Object> wrappedMaterialMasters = new List<Object>();

    @AuraEnabled
    public static List<Object> loadMaterialMastersFromDatabase(List<Object> productFamilies, String searchText, String returnType) {
        if (productFamilies.isEmpty()) { return wrappedMaterialMasters;}
        switch on returnType{
            when 'QuickStockReturn'{
                quickStockReturnLogic(productFamilies, searchText);
            }
            when 'stockAccomodationReturn'{
                stockAccomodationReturnLogic(productFamilies, searchText);
            }
            when 'claimBack'{
                claimBackLogic(productFamilies, searchText);
            }
            when 'Warranty'{
                warrantyLogic(productFamilies, searchText);
                System.debug('EXECUTING WARRANTY BRANCH...');
            }
            when 'Default'{
                warrantyLogic(productFamilies, searchText);
                System.debug('EXECUTING DEFAULT BRANCH...');
            }
        }
        return wrappedMaterialMasters;
    }

    private static void warrantyLogic(List<Object> productFamilies, String searchText){
        wrappedMaterialMasters.addAll(getWarrantyMaterials(productFamilies, searchText));

    }

    private static void claimBackLogic(List<Object> productFamilies, String searchText){
        wrappedMaterialMasters.addAll(getMaterials(productFamilies, searchText, null));

    }

    private static void stockAccomodationReturnLogic(List<Object> productFamilies, String searchText) {

        List<GE_LGT_EM_MaterialMaster__c> materialMasters = getMaterials(productFamilies, searchText, null);

        List<String> materialNumbers = new List<String>();
        for (GE_LGT_EM_MaterialMaster__c mat : materialMasters) {
            materialNumbers.add(mat.GE_LGT_EM_SAP_MaterialNumber__c);
        }

        Map<String, String> UOMByMatNumber = new Map<String, String>();
        Map<String, String> ccProdIdByMatNumber = new Map<String, String>();
        Set<String> trueSKU24_48_ccProdIds = new Set<String>();
        for (Pricing_UOM__c uom : UOMServices.getUOMsForProducts(materialNumbers)) {
            if (UOMByMatNumber.containsKey(uom.SKU__c)) {
                UOMByMatNumber.put(uom.SKU__c, UOMByMatNumber.get(uom.SKU__c) + ';' + uom.UOM__c);
            } else {
                UOMByMatNumber.put(uom.SKU__c, uom.UOM__c);
                ccProdIdByMatNumber.put(uom.SKU__c, uom.CC_Product__c);
                if (uom.CC_Product__r.SKU_24_48hr__c) {
                    trueSKU24_48_ccProdIds.add(uom.CC_Product__c);
                }
            }
        }

        for (GE_LGT_EM_MaterialMaster__c materialMaster : materialMasters) {
            System.debug(materialMaster.GE_LGT_EM_SAP_MaterialNumber__c);
            Map<String, Object> deserializedMaterialMasters = materialMaster.getPopulatedFieldsAsMap().clone();
            if (UOMByMatNumber.containsKey(materialMaster.GE_LGT_EM_SAP_MaterialNumber__c)) {
                deserializedMaterialMasters.put('uomOptions', ComboboxOptionBuilder.buildOptions(UOMByMatNumber.get(materialMaster.GE_LGT_EM_SAP_MaterialNumber__c).split(';')));
                deserializedMaterialMasters.put('ccProductId', ccProdIdByMatNumber.get(materialMaster.GE_LGT_EM_SAP_MaterialNumber__c));
            }
            wrappedMaterialMasters.add(deserializedMaterialMasters);
        }
    }

    private static void quickStockReturnLogic(List<Object> productFamilies, String searchText){
        searchText = '%' + searchText.trim() + '%';
        String query = 'SELECT Id, Product_Line__c, ccrz__SKU__c, ' +
                '(SELECT UOM__c FROM Pricing_UOM__r) ' +
                'FROM ccrz__E_Product__c ';
        query += 'WHERE (Quickship__c = TRUE) AND (MaterialDescription__c LIKE :searchText OR ccrz__SKU__c LIKE :searchText) AND (';

        List<String> familiesToSearch = new List<String>();
        for (Object prodFam : productFamilies){
            familiesToSearch.add(String.valueOf(prodFam) + '%');
        }

        query += 'Product_Line__c LIKE :familiesToSearch';
        query += ') LIMIT 20';

        System.debug(query);
        List<ccrz__E_Product__c> ccProducts = Database.query(query);
        Map<String, String> ccProdIdBySkuNumbers = new Map<String, String>();
        Map<String,String> uomBySkuNumber = new Map<String, String>();
        for (ccrz__E_Product__c ccProd : ccProducts){
            ccProdIdBySkuNumbers.put(ccProd.ccrz__SKU__c, ccProd.Id);
            for (Pricing_UOM__c uom : UOMServices.getUOMsForProduct(ccProd.ccrz__SKU__c, ccProd.Pricing_UOM__r)){
                if (uomBySkuNumber.containsKey(ccProd.ccrz__SKU__c)) {
                    uomBySkuNumber.put(ccProd.ccrz__SKU__c, uomBySkuNumber.get(ccProd.ccrz__SKU__c) + ';' + uom.UOM__c);
                } else {
                    uomBySkuNumber.put(ccProd.ccrz__SKU__c, uom.UOM__c);
                }
            }
        }
        for (GE_LGT_EM_MaterialMaster__c materialMaster : getMaterials(productFamilies, null, new List<String>(ccProdIdBySkuNumbers.keySet()))){
            Map<String, Object> deserializedMaterialMasters = materialMaster.getPopulatedFieldsAsMap().clone();
            if (uomBySkuNumber.containsKey(materialMaster.GE_LGT_EM_SAP_MaterialNumber__c)) {
                deserializedMaterialMasters.put('uomOptions', ComboboxOptionBuilder.buildOptions(uomBySkuNumber.get(materialMaster.GE_LGT_EM_SAP_MaterialNumber__c).split(';')));
                deserializedMaterialMasters.put('ccProductId', ccProdIdBySkuNumbers.get(materialMaster.GE_LGT_EM_SAP_MaterialNumber__c));
            }
            wrappedMaterialMasters.add(deserializedMaterialMasters);
        }
    }

    private static List<GE_LGT_EM_MaterialMaster__c> getMaterials(List<Object> productFamilies, String searchText, List<String> skuNumbers){
        String matMasterQuery = 'SELECT Id,Name,GE_LGT_EM_SAP_MaterialNumber__c,GE_LGT_EM_MaterialDescription__c,Quantity_per_Unit__c,CurrencyIsoCode ' +
                'FROM GE_LGT_EM_MaterialMaster__c ';
        if (searchText != null) {
            searchText = '%' + searchText.trim() + '%';
            matMasterQuery += 'WHERE GE_LGT_EM_Distribution_Chain_Status__c = \'02\' AND (Name LIKE:searchText OR GE_LGT_EM_MaterialDescription__c LIKE :searchText OR GE_LGT_EM_SAP_MaterialNumber__c LIKE :searchText) AND (';
        }
        if (skuNumbers != null) {
            matMasterQuery += 'WHERE (GE_LGT_EM_SAP_MaterialNumber__c IN :skuNumbers) AND (';
        }

        List<String> familiesToSearch = new List<String>();
        for (Object prodFam : productFamilies){
            familiesToSearch.add(String.valueOf(prodFam) + '%');
        }

        matMasterQuery += 'Level_1__c LIKE :familiesToSearch';
        matMasterQuery += ') LIMIT 20';
        system.debug('familiesToSearch '+familiesToSearch);
        System.debug(matMasterQuery);
        return Database.query(matMasterQuery);
    }

    private static List<GE_LGT_EM_MaterialMaster__c> getWarrantyMaterials(List<Object> productFamilies, String searchText){
        String matMasterQuery = 'SELECT Id,Name,GE_LGT_EM_SAP_MaterialNumber__c,GE_LGT_EM_MaterialDescription__c,Quantity_per_Unit__c,CurrencyIsoCode ' +
                'FROM GE_LGT_EM_MaterialMaster__c ';
        if (searchText != null) {
            searchText = '%' + searchText.trim() + '%';
            matMasterQuery += 'WHERE GE_LGT_EM_Distribution_Chain_Status__c = \'02\' AND (Name LIKE:searchText OR GE_LGT_EM_MaterialDescription__c LIKE :searchText OR GE_LGT_EM_SAP_MaterialNumber__c LIKE :searchText) AND (';
        }
        /*if (skuNumbers != null) {
            matMasterQuery += 'WHERE (GE_LGT_EM_SAP_MaterialNumber__c IN :skuNumbers) AND (';
        }*/

        List<String> familiesToSearch = new List<String>();
        for (Object prodFam : productFamilies){
            familiesToSearch.add(String.valueOf(prodFam) + '%');
            System.debug('Families to Search: '+familiesToSearch);
        }

        matMasterQuery += 'Level_1__c LIKE :familiesToSearch';
        matMasterQuery += ') LIMIT 20';

        System.debug(matMasterQuery);
        return Database.query(matMasterQuery);
    }
}
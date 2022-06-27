/**
 * Created by Dezső on 2022. 03. 04..
 */

public with sharing class UOMServices {

    public static List<Pricing_UOM__c> getUOMsForProducts(List<String> skus) {
        Set<String> skuSet = new Set<String>();
        skuSet.addAll(skus);
        return getUOMsForProducts(skuSet);
    }

    public static List<Pricing_UOM__c> getUOMsForProducts(Set<String> skus) {
        List<Pricing_UOM__c> result = new List<Pricing_UOM__c>();
        Map<String, List<Pricing_UOM__c>> uomsBySku = new Map<String, List<Pricing_UOM__c>>();
        List<Pricing_UOM__c> allUoms = [SELECT Id, SKU__c, UOM__c, Multiplier__c, EAN_ID_Type__c, CC_Product__c, CC_Product__r.SKU_24_48hr__c, CurrencyIsoCode FROM Pricing_UOM__c WHERE SKU__c IN :skus];
        for (Pricing_UOM__c uom : allUoms) {
            if (uomsBySku.containsKey(uom.SKU__c)) {
                uomsBySku.get(uom.SKU__c).add(uom);
            } else {
                List<Pricing_UOM__c> uomList = new List<Pricing_UOM__c>();
                uomList.add(uom);
                uomsBySku.put(uom.SKU__c, uomList);
            }
        }
        for (String sku : skus) {
            result.addAll(getUOMsForProduct(sku, uomsBySku.get(sku)));
        }
        return result;
    }

    public static List<Pricing_UOM__c> getUOMsForProduct(String sku, List<Pricing_UOM__c> preloadedUomList) {
        Map<Decimal, List<Pricing_UOM__c>> uomsByMultiplier = new Map<Decimal, List<Pricing_UOM__c>>();
        List<Pricing_UOM__c> uomsList;
        if (preloadedUomList != null) {
            uomsList = preloadedUomList;
        } else {
            uomsList = [SELECT Id, SKU__c, UOM__c, Multiplier__c, EAN_ID_Type__c, CC_Product__c, CC_Product__r.SKU_24_48hr__c, CurrencyIsoCode FROM Pricing_UOM__c WHERE SKU__c = :sku];
        }
        for (Pricing_UOM__c uom : uomsList) {
            if (uomsByMultiplier.containsKey(uom.Multiplier__c)) {
                uomsByMultiplier.get(uom.Multiplier__c).add(uom);
            } else {
                List<Pricing_UOM__c> uoms = new List<Pricing_UOM__c>();
                uoms.add(uom);
                uomsByMultiplier.put(uom.Multiplier__c, uoms);
            }
        }
        List<Pricing_UOM__c> result = new List<Pricing_UOM__c>();
        for (List<Pricing_UOM__c> uoms : uomsByMultiplier.values()) {
            if (uoms.size() > 1) {
                Boolean hasEA = false;
                Boolean hasZU = false;
                for (Pricing_UOM__c uom : uoms) {
                    if (uom.EAN_ID_Type__c != null && uom.EAN_ID_Type__c.toUpperCase() == 'ZU') {
                        hasZU = true;
                        result.add(uom);
                        break;
                    }
                    if (uom.UOM__c == 'EA') {
                        hasEA = true;
                    }
                }
                if (hasEA && !hasZU) {
                    for (Pricing_UOM__c uom : uoms) {
                        if (uom.UOM__c == 'EA') {
                            result.add(uom);
                            break;
                        }
                    }
                }
                if (!hasEA && !hasZU) {
                    result.addAll(uoms);
                }
            } else {
                result.addAll(uoms);
            }
        }
        return sortByMultiplier(result);
    }

    private static List<Pricing_UOM__c> sortByMultiplier(List<Pricing_UOM__c> input) {
        List<Pricing_UOM__c> result = new List<Pricing_UOM__c>();
        while (!input.isEmpty()) {
            Decimal minMultiplier = 999999999;
            Integer idx = -1;
            for (Integer i = 0; i<input.size(); i++) {
                if (input.get(i).Multiplier__c < minMultiplier) {
                    idx = i;
                    minMultiplier = input.get(i).Multiplier__c;
                }
            }
            result.add(input.get(idx));
            input.remove(idx);
        }
        return result;
    }

}
global class ProductListActions {

    @RemoteAction
    global static ccrz.cc_RemoteActionResult customOrderBy(ccrz.cc_RemoteActionContext ctx, String orderDirection,
            String orderCriteria, Map<String,String> filterMap,Integer renderCount, String searchString, String prodCategoryId, Integer offset) {
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        res.success = true;

        List<String> prodIds = new List<String>();
        Map<String,ccrz__e_productindex__c> indexMap = new Map<String,ccrz__E_ProductIndex__c>();

        Set<Id> priceLists = getPriceLists();
        String priceListString = '(';
        for (Id id : priceLists) {
            priceListString += ('\'' + id + '\',');
        }
        priceListString = priceListString.removeEnd(',');
        priceListString += ')';

        String filterString ='';
        system.debug('filterMap '+filterMap);

        if (filterMap.size() > 0) {
            filterString = 'AND  ccrz__Product__c IN (\n' +
                    '        SELECT ccrz__Product__c\n' +
                    '        FROM ccrz__E_ProductSpec__c\n' +
                    '        WHERE (\n';
            for (String spec : filterMap.keySet()) {
                String escapedSpec = String.escapeSingleQuotes(filterMap.get(spec));
                filterString += '(ccrz__SpecValue__c = \'' + escapedSpec + '\'\n';
                filterString += 'AND ccrz__Spec__c = \'' + spec + '\')\nOR\n';
            }
            filterString = filterString.removeEnd('OR\n');
            filterString += '))\n';
        }
        String productIndexString = 'SELECT\n' +
                '        id,\n' +
                '        ccrz__Product__c,\n' +
                '        ccrz__Locale__c,\n' +
                '        ccrz__ProductName__c,\n' +
                '        ccrz__IndexPrice__c,\n' +
                '        ccrz__ProductCategory__c,\n' +
                '        ccrz__ProductStartDate__c,\n' +
                '        ccrz__ProductCategorySequence__c\n' +
                'FROM     ccrz__e_productindex__c\n' +
                'WHERE    ccrz__locale__c = \'en_US\'\n' +
        'AND      ccrz__active__c = true\n' +
        'AND      ccrz__productstartdate__c <= today\n' +
        'AND      ccrz__productenddate__c >= today\n' +
        'AND      (\n' +
        '        ccrz__productstatus__c = \'Released\'\n' +
        '        OR       ccrz__productstatus__c = \'Not Orderable\')\n' +
        'AND      ccrz__categorystartdate__c <= today\n' +
        'AND      ccrz__categoryenddate__c >= today\n' +
        'AND      ccrz__productcategorystartdate__c <= today\n' +
        'AND      ccrz__productcategoryenddate__c >= today\n' +
        'AND      ccrz__indexcurrency__c IN (\'USD\')\n' +
        'AND      ccrz__product__c       IN\n' +
        '(\n' +
        '        SELECT ccrz__product__c\n' +
        '        FROM   ccrz__e_pricelistitem__c\n' +
        '        WHERE  ccrz__startdate__c <= today\n' +
        '        AND    ccrz__enddate__c >= today\n' +
        '        AND    ccrz__pricelist__c IN ' + priceListString + '\n' +
        '        AND    ccrz__pricelist__r.ccrz__enabled__c = true)\n' +
        'AND      ccrz__storefront__c includes (\'DefaultStore\')\n' +
        filterString +
        + (String.isNotEmpty(searchString) ? ' AND ccrz__productname__c LIKE \''+ searchString +'%\'' : ' AND (ccrz__category__c=\'' + prodCategoryId + '\' )') +
        ' ORDER BY ccrz__productname__c';

        System.debug('QUERY' + productIndexString);

        if(TEST.isRunningTest()) {
            system.debug('qry  '+[SELECT Id FROM   ccrz__e_productindex__c
            WHERE    ccrz__locale__c = 'en_US'
            AND      ccrz__active__c = true
            AND      ccrz__productstartdate__c <= today
            AND      ccrz__productenddate__c >= today
            AND      (
                    ccrz__productstatus__c = 'Released'
                    OR       ccrz__productstatus__c = 'Not Orderable')
            AND      ccrz__categorystartdate__c <= today
            AND      ccrz__categoryenddate__c >= today
            AND      ccrz__productcategorystartdate__c <= today
            AND      ccrz__productcategoryenddate__c >= today
            AND      ccrz__indexcurrency__c IN ('USD')]);
        }

        List<ccrz__e_productindex__c> indexlist = database.query(productIndexString);

        //Filtering
        Set<Id> prodIdSet = new Set<Id>();
        for (ccrz__e_productindex__c prod : indexlist) {
            prodIdSet.add(prod.ccrz__Product__c);
        }
        List<ccrz__E_ProductSpec__c> specList =
            [SELECT ccrz__Product__c,ccrz__Spec__c,ccrz__SpecValue__c
            FROM ccrz__E_ProductSpec__c
            WHERE ccrz__Spec__c IN :filterMap.keySet()
                AND ccrz__Product__c IN :prodIdSet];
        for (ccrz__e_productindex__c index : indexlist) {
            Integer filtersPassed = 0;
            for (ccrz__E_ProductSpec__c spec : specList) {
                if (index.ccrz__Product__c == spec.ccrz__Product__c){
                    if(spec.ccrz__SpecValue__c == filterMap.get(spec.ccrz__Spec__c)) {
                        filtersPassed++;
                    }
                }
            }
            if (filtersPassed == filterMap.size()) {
                prodIds.add(index.ccrz__product__c);
                indexMap.put(index.ccrz__product__c,index);
            }
        }
        system.debug('prodIds '+prodIds);

        String productQueryString = '';
        List<ccrz__E_Product__c> prodlist = new List<ccrz__E_Product__c>();
        if (orderCriteria!='SKU_24_48hr__c') {
            prodlist = getProductsByTotalInventory(prodIds, orderDirection, renderCount, offset);
        } else {
            prodlist = getProductsByQuickstock(prodIds, orderDirection, renderCount, offset);
        }

        res.data = new ccServiceProductDataProvider().fetch(formatProducts(prodlist));
        return res;
    }

    private static List<ccrz__E_Product__c> getProductsByQuickstock(List<String> prodIds,String orderDirection, Integer renderCount, Integer offset) {
        Account effectiveAccount = [SELECT Id, GE_LGT_Rep_Code__c, Account_Group__c, Delivering_Plant__c FROM Account WHERE Id =:ccrz.cc_CallContext.effAccountId];
        String plant = effectiveAccount.Delivering_Plant__c;
        String productQueryString = 'SELECT\n' +
                '                        ccrz__ShortDesc__c,\n' +
                '                        CurrencyIsoCode,\n' +
                '                        Total_Standard_Inventory__c,\n' +
                '                        Inventory_Available__c,\n' +
                '                        Quickship__c,\n' +
                '                        Product_Family__c,\n' +
                '                        MaterialDescription__c,\n' +
                '                        LastModifiedDate,\n' +
                '                        SKU_24_48hr__c,\n' +
                '                        ccrz__UnitOfMeasure__c,\n' +
                '                        ccrz__StartDate__c,\n' +
                '                        ccrz__ProductType__c,\n' +
                '                        ccrz__ProductStatus__c,\n' +
                '                        ccrz__Storefront__c,\n' +
                '                        ccrz__SKU__c,\n' +
                '                        OwnerId,\n' +
                '                        Name,\n' +
                '                        Id,\n' +
                '                        ECommItemName__c,\n' +
                '                        (SELECT Id,Multiplier__c,UOM__c,SKU__c, CC_Product__c, CurrencyIsoCode, EAN_ID_Type__c   FROM Pricing_UOM__r pricingUOMS),' +
                '                        (SELECT Id,QuickStock__c,Plant__c, Stock__c,Material_Master__r.GE_LGT_EM_SAP_MaterialNumber__c FROM Inventories__r WHERE Plant__c =\''+plant +'\' AND Stock__c!=null AND Stock__c!=0),\n' +
                ' (SELECT Id, Name, RecordTypeId, ccrz__Product__c, ccrz__AltMessage__c, ccrz__Enabled__c, ccrz__EndDate__c, ccrz__FilePath__c, ccrz__Locale__c, ' +
        '                       ccrz__MediaType__c, ccrz__ProductDescription__c, ccrz__ProductMediaId__c, ccrz__ProductMediaSource__c, ccrz__Sequence__c, ccrz__StartDate__c, ' +
        '                       ccrz__StaticResourceName__c, ccrz__URI__c  FROM ccrz__E_ProductMedias__r WHERE  (ccrz__Locale__c = \'en_US\' OR ccrz__Locale__c = \'en_US\' OR ccrz__Locale__c = \'en_US\' OR ccrz__Locale__c = null) AND (ccrz__StartDate__c <=TODAY AND ccrz__EndDate__c >= TODAY) AND ccrz__Enabled__c = TRUE AND ccrz__MediaType__c = \'Product Search Image\' ORDER BY ccrz__Sequence__c ASC)\n' +

                '                FROM ccrz__E_Product__c\n' +
                '                WHERE\n' +
                '                ccrz__Storefront__c includes (\'DefaultStore\')\n' +
                '                AND  (ccrz__ProductStatus__c = \'Released\' OR ccrz__ProductStatus__c = \'Not Orderable\')\n' +
                '                AND  (ccrz__StartDate__c = null or ccrz__StartDate__c <= TODAY)\n' +
                '                AND (ccrz__EndDate__c = null or ccrz__EndDate__c >= TODAY)\n' +
                '                AND id in:prodIds order by Quickship__c desc';

        List<ccrz__E_Product__c> prodlist = database.query(productQueryString);
        List<ccrz__E_Product__c> zeroQSProdlist = new List<ccrz__E_Product__c>();

        ccProductQSSortingWrapper[] qsProdList = new List<ccProductQSSortingWrapper>();

        for (ccrz__E_Product__c prod : prodlist) {
            prod.Inventory_Available__c = 0;
            if (TEST.isRunningTest()) system.debug('inventories '+prod.Inventories__r);
            if (prod.Inventories__r!=null && prod.Quickship__c == true) {
                for (Inventory__c inventory : prod.Inventories__r) {
                    if (prod.Inventory_Available__c == null) {
                        prod.Inventory_Available__c = inventory.Stock__c;
                    } else {
                        prod.Inventory_Available__c += inventory.Stock__c;
                    }
                }
            }

            if (prod.Inventory_Available__c != null && prod.Inventory_Available__c != 0) {
                qsProdList.add(new ccProductQSSortingWrapper(prod,orderDirection));
            } else {
                zeroQSProdlist.add(prod);
            }
        }

        qsProdList.sort();
        List<ccrz__E_Product__c> fullProdlist = new List<ccrz__E_Product__c>();
        List<ccrz__E_Product__c> offsetProdlist = new List<ccrz__E_Product__c>();

        if (orderDirection == 'desc') {

            for (ccProductQSSortingWrapper prod : qsProdList) {
                fullProdlist.add(prod.product);
            }

            fullProdlist.addAll(zeroQSProdlist);

            for (Integer i=offset; i<offset+renderCount && i<fullProdlist.size(); i++) {
                offsetProdlist.add(fullProdlist[i]);
            }
        } else {

            fullProdlist.addAll(zeroQSProdlist);

            for (ccProductQSSortingWrapper prod : qsProdList) {
                fullProdlist.add(prod.product);
            }

            for (Integer i=offset; i<offset+renderCount && i<fullProdlist.size(); i++) {
                offsetProdlist.add(fullProdlist[i]);
            }
        }
        return offsetProdlist;
    }

    private static List<ccrz__E_Product__c> getProductsByTotalInventory(List<String> prodIds,String orderDirection, Integer renderCount, Integer offset) {

        Account effectiveAccount = [SELECT Id, GE_LGT_Rep_Code__c, Account_Group__c, Delivering_Plant__c FROM Account WHERE Id =:ccrz.cc_CallContext.effAccountId];
        String plant = effectiveAccount.Delivering_Plant__c;
        String productQueryString = 'SELECT\n' +
                '                        ccrz__ShortDesc__c,\n' +
                '                        CurrencyIsoCode,\n' +
                '                        Total_Standard_Inventory__c,\n' +
                '                        Inventory_Available__c,\n' +
                '                        Quickship__c,\n' +
                '                        Product_Family__c,\n' +
                '                        MaterialDescription__c,\n' +
                '                        LastModifiedDate,\n' +
                '                        SKU_24_48hr__c,\n' +
                '                        ccrz__UnitOfMeasure__c,\n' +
                '                        ccrz__StartDate__c,\n' +
                '                        ccrz__ProductType__c,\n' +
                '                        ccrz__ProductStatus__c,\n' +
                '                        ccrz__Storefront__c,\n' +
                '                        ccrz__SKU__c,\n' +
                '                        OwnerId,\n' +
                '                        Name,\n' +
                '                        Id,\n' +
                '                        ECommItemName__c,\n' +
                '                        (SELECT Id,Multiplier__c,UOM__c,SKU__c, CC_Product__c, CurrencyIsoCode, EAN_ID_Type__c  FROM Pricing_UOM__r pricingUOMS),' +
                '                        (SELECT Id,QuickStock__c,Plant__c, Stock__c,Material_Master__r.GE_LGT_EM_SAP_MaterialNumber__c FROM Inventories__r WHERE Stock__c!=null AND Stock__c!=0),\n' +
                ' (SELECT Id, Name, RecordTypeId, ccrz__Product__c, ccrz__AltMessage__c, ccrz__Enabled__c, ccrz__EndDate__c, ccrz__FilePath__c, ccrz__Locale__c, ' +
                '                       ccrz__MediaType__c, ccrz__ProductDescription__c, ccrz__ProductMediaId__c, ccrz__ProductMediaSource__c, ccrz__Sequence__c, ccrz__StartDate__c, ' +
                '                       ccrz__StaticResourceName__c, ccrz__URI__c  FROM ccrz__E_ProductMedias__r WHERE  (ccrz__Locale__c = \'en_US\' OR ccrz__Locale__c = \'en_US\' OR ccrz__Locale__c = \'en_US\' OR ccrz__Locale__c = null) AND (ccrz__StartDate__c <=TODAY AND ccrz__EndDate__c >= TODAY) AND ccrz__Enabled__c = TRUE AND ccrz__MediaType__c = \'Product Search Image\' ORDER BY ccrz__Sequence__c ASC)\n' +

                '                FROM ccrz__E_Product__c\n' +
                '                WHERE\n' +
                '                ccrz__Storefront__c includes (\'DefaultStore\')\n' +
                '                AND  (ccrz__ProductStatus__c = \'Released\' OR ccrz__ProductStatus__c = \'Not Orderable\')\n' +
                '                AND  (ccrz__StartDate__c = null or ccrz__StartDate__c <= TODAY)\n' +
                '                AND (ccrz__EndDate__c = null or ccrz__EndDate__c >= TODAY)\n' +
                '                AND id in:prodIds\n' +
                '                ORDER BY  Total_Standard_Inventory__c '  + orderDirection + ' NULLS LAST';

        List<ccrz__E_Product__c> prodlist = database.query(productQueryString);
        List<ccrz__E_Product__c> zeroQSProdlist = new List<ccrz__E_Product__c>();

        ccProductQSSortingWrapper[] qsProdList = new List<ccProductQSSortingWrapper>();

        Map<String,Warehouse__mdt> whMap = new Map<String,Warehouse__mdt>();

        for (Warehouse__mdt wh : Warehouse__mdt.getAll().values()) {
            whMap.put(wh.Code__c,wh);
        }

        for (ccrz__E_Product__c prod : prodlist) {
            prod.Inventory_Available__c = 0;

            if (prod.Inventories__r!=null) {
                for (Inventory__c inventory : prod.Inventories__r) {

                    if ((whMap.containsKey(inventory.Plant__c) && (whMap.get(inventory.Plant__c).Standard__c == true || whMap.get(inventory.Plant__c).Code__c == effectiveAccount.Delivering_Plant__c))) {
                        if (prod.Inventory_Available__c == null) {
                            prod.Inventory_Available__c = inventory.Stock__c;
                        } else {
                            prod.Inventory_Available__c += inventory.Stock__c;
                        }
                    }
                }
            }

            if (prod.Inventory_Available__c != null && prod.Inventory_Available__c != 0) {
                qsProdList.add(new ccProductQSSortingWrapper(prod,orderDirection));
            } else {
                zeroQSProdlist.add(prod);
            }
        }

        qsProdList.sort();
        List<ccrz__E_Product__c> fullProdlist = new List<ccrz__E_Product__c>();
        List<ccrz__E_Product__c> offsetProdlist = new List<ccrz__E_Product__c>();

        if (orderDirection == 'desc') {

            for (ccProductQSSortingWrapper prod : qsProdList) {
                fullProdlist.add(prod.product);
            }

            fullProdlist.addAll(zeroQSProdlist);

            for (Integer i=offset; i<offset+renderCount && i<fullProdlist.size(); i++) {
                offsetProdlist.add(fullProdlist[i]);
            }
        } else {

            fullProdlist.addAll(zeroQSProdlist);

            for (ccProductQSSortingWrapper prod : qsProdList) {
                fullProdlist.add(prod.product);
            }

            for (Integer i=offset; i<offset+renderCount && i<fullProdlist.size(); i++) {
                offsetProdlist.add(fullProdlist[i]);
            }
        }
        return offsetProdlist;
    }
    @testVisible
    private static Set<Id> getPriceLists() {
        Account currentAcc = [SELECT ccrz__E_AccountGroup__c FROM Account WHERE Id = :ccrz.cc_CallContext.effAccountId];

        Set<Id> accountGroupPriceListIDS = new Set<Id>();
        for (ccrz__E_AccountGroupPriceList__c accgpl : [SELECT ccrz__Pricelist__c FROM ccrz__E_AccountGroupPriceList__c WHERE ccrz__AccountGroup__c = :currentAcc.ccrz__E_AccountGroup__c]) {
            if (accgpl.ccrz__Pricelist__c!=null) accountGroupPriceListIDS.add(accgpl.ccrz__Pricelist__c);
        }

        return accountGroupPriceListIDS;
    }


    private static Map<Id, Object> getPricingDataMapping(List<ccrz__E_Product__c> prodList) {
        Map<Id, Object> pricingDataMapping = new Map<Id, Object>();

        Set<Id> productIds = new Set<Id>();
        for (ccrz__E_Product__c prod : prodList) {
            productIds.add(prod.Id);
        }
        Set<Id> priceLists = getPriceLists();
        List<ccrz__E_PriceListItem__c> priceListItems = [SELECT ccrz__Price__c
                                                                ,ccrz__Product__c
                                                                ,ccrz__Pricelist__c
                                                           FROM ccrz__E_PriceListItem__c
                                                          WHERE ccrz__Pricelist__c IN :priceLists
                                                            AND ccrz__Product__c IN :productIds];
        for (Id prodId : productIds) {
            Boolean prodFound = false;
            for (Integer i = 0; i < priceListItems.size() && !prodFound; i++) {
                if (priceListItems[i].ccrz__Product__c == prodId) {
                    prodFound = true;
                    pricingDataMapping.put(prodId, new Map<String, Object>{
                            'price' => priceListItems[i].ccrz__Price__c,
                            'priceList' => priceListItems[i].ccrz__Pricelist__c,
                            'sfid' => prodId
                    });
                }
            }
            if (!prodFound) {
                pricingDataMapping.put(prodId, new Map<String, Object>{
                        'price' => 0,
                        'priceList' => '',
                        'sfid' => prodId
                });
            }
        }

        return pricingDataMapping;
    }

    private static Map<String, Object> formatProducts(List<ccrz__E_Product__c> prodList) {
        Map<Id, Object> pricingDataMapping = getPricingDataMapping(prodList);
        List<Map<String, Object>> objectList = new List<Map<String, Object>>();
        for (ccrz__E_Product__c prod : prodList) {
            List<Map<String, Object>> mediaList = new List<Map<String, Object>>();
            if (prod.ccrz__E_ProductMedias__r!=null && prod.ccrz__E_ProductMedias__r.size()>0) mediaList.add(new Map<String, Object>{
                    'sfdcCurrencyISOCode' => prod.CurrencyIsoCode,
                    'URI' => prod.ccrz__E_ProductMedias__r[0].ccrz__URI__c,
                    'startDate' => prod.ccrz__E_ProductMedias__r[0].ccrz__StartDate__c,
                    'sequence' => prod.ccrz__E_ProductMedias__r[0].ccrz__Sequence__c,
                    'productMediaSource' => prod.ccrz__E_ProductMedias__r[0].ccrz__ProductMediaSource__c,
                    'mediaType' => prod.ccrz__E_ProductMedias__r[0].ccrz__MediaType__c,
                    'locale' => prod.ccrz__E_ProductMedias__r[0].ccrz__Locale__c,
                    'endDate' => prod.ccrz__E_ProductMedias__r[0].ccrz__EndDate__c,
                    'enabled' => prod.ccrz__E_ProductMedias__r[0].ccrz__Enabled__c,
                    'sfdcName' => prod.ccrz__E_ProductMedias__r[0].ccrz__StaticResourceName__c,
                    'sfid' => prod.Id,
                    'product' => prod.ccrz__E_ProductMedias__r[0].Id

            });
            List<Object> uomObj = new List<Object>();
            for (Pricing_UOM__c uom : UOMServices.getUOMsForProduct(prod.ccrz__SKU__c, prod.Pricing_UOM__r)) {
                uomObj.add(
                        new Map<String, Object> {
                                'CCProduct' => uom.CC_Product__c,
                                'SKU' => uom.SKU__c,
                                'UOM' => uom.UOM__c,
                                'multiplier' => uom.Multiplier__c,
                                'sfdcCurrencyISOCode' => uom.CurrencyIsoCode,
                                'sfid' => uom.Id
                        }
                );
            }
            if (prod.ccrz__E_ProductMedias__r!=null && prod.ccrz__E_ProductMedias__r.size()>0) String uri = prod.ccrz__E_ProductMedias__r[0].ccrz__URI__c;
            objectList.add(new Map<String, Object> {
                    'shortDesc' => prod.ccrz__ShortDesc__c,
                    'sfdcCurrencyISOCode' => prod.CurrencyIsoCode,
                    'totalStandardInventory' => prod.Total_Standard_Inventory__c,
                    'quickship' => prod.Quickship__c,
                    'productFamily' => prod.Product_Family__c,
                    'materialDescription' => prod.MaterialDescription__c,
                    'lastModifiedDate' => prod.LastModifiedDate,
                    'SKU2448hr' => true,
                    'unitOfMeasure' => prod.ccrz__UnitOfMeasure__c,
                    'startDate' => prod.ccrz__StartDate__c,
                    'productType' => prod.ccrz__ProductType__c,
                    'productStatus' => prod.ccrz__ProductStatus__c,
                    'storefront' => prod.ccrz__Storefront__c,
                    'SKU' => prod.ccrz__SKU__c,
                    'ownerId' => prod.OwnerId,
                    'sfdcName' => prod.Name,
                    'sfid' => prod.Id,
                    'canAddtoCart' => true,
                    'pricingUOMS' => (prod.Pricing_UOM__r!=null ? uomObj : null),
                    'productPricingData' => (new Map<String,Object> {'productPrice' =>
                            pricingDataMapping.get(prod.Id)
                        }),
                    'EProductMediasS' => mediaList,
                    'ECommItemName' => prod.ECommItemName__c
            });
        }

        return new Map<String, Object>{'productList' => objectList };
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult addInvalidSku(ccrz.cc_RemoteActionContext ctx, String sku, Decimal productPrice, Integer quantity, String typeMark,String cartId, String externalSKU) {

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        res.success = false;
        res.inputContext = ctx;
        String unitOfMeasure='PC';

        try {
            //Getting the current Cart.
            List<ccrz__E_Cart__c> currentCart = [
                    SELECT Id
                    FROM ccrz__E_Cart__c
                    WHERE ccrz__EncryptedId__c = :cartId
            ];
            String standardCardId = currentCart[0].Id;
            Id requestedSku;
            List<ccrz__E_Product__c> reqSKU=[select id from ccrz__E_Product__c where ccrz__SKU__c='requestedSku' LIMIT 1];
            if(reqSKU.size()>0){
                requestedSku=reqSKU[0].Id;
            }


            ccrz__E_CartItem__c cartItem = null;
            ccrz__E_CartItem__c sameTypeMarkItem = null;
            List<ccrz__E_CartItem__c> cartItems = retrieveMTOCartItem(cartId, sku, externalSKU);
            if (!cartItems.isEmpty()) {
                for (ccrz__E_CartItem__c aItem : cartItems) {
                    if(aItem.ccrz__UnitOfMeasure__c == unitOfMeasure) {
                        if(String.isEmpty(aItem.Type_Marks__c) && String.isEmpty(typeMark)) {
                            cartItem = aItem;
                            sameTypeMarkItem = aItem;
                        }
                        if (!String.isEmpty(aItem.Type_Marks__c) && aItem.Type_Marks__c.equals(typeMark)) {
                            cartItem = aItem;
                            sameTypeMarkItem = aItem;
                        }
                    }
                }
            }
            if (cartItem != null && sameTypeMarkItem != null) {
                Decimal sumOfQuantities = 0;
                sumOfQuantities = (quantity != null ? quantity : 0) + cartItem.ccrz__Quantity__c;
                sameTypeMarkItem.ccrz__Price__c = productPrice;
                sameTypeMarkItem.ccrz__Quantity__c = sumOfQuantities;
                sameTypeMarkItem.ccrz__SubAmount__c = (productPrice * sumOfQuantities).setScale(2);

                update sameTypeMarkItem;
            }
            else {
                List<ccrz__E_CartItem__c> newCartItems = new List<ccrz__E_CartItem__c>();
                ccrz__E_CartItem__c newCartItem = new ccrz__E_CartItem__c();
                newCartItem.ccrz__Cart__c = currentCart[0].Id;
                newCartItem.ccrz__ExtSKU__c = externalSKU;
                newCartItem.ccrz__ExtName__c = sku;
                newCartItem.ccrz__Quantity__c = quantity;
                newCartItem.ccrz__Price__c = productPrice;
                newCartItem.ccrz__SubAmount__c = productPrice * quantity;
                newCartItem.ccrz__UnitOfMeasure__c = unitOfMeasure;
                newCartItem.Type_Marks__c = typeMark;
                newCartItem.ccrz__ItemStatus__c = 'Available';
                newCartItem.ccrz__PricingType__c = 'external';
                newCartItem.ccrz__ProductType__c = 'Product';
                newCartItem.ccrz__StoreID__c = 'DefaultStore';
                newCartItem.ccrz__RequestDate__c = Date.today();
                newCartItem.ccrz__Product__c = requestedSku;
                newCartItems.add(newCartItem);
                insert newCartItems;
            }

            res.success = true;
            res.data = cartId;

            Map<String, Object> cartToSave = new Map<String, Object>{
                    ccrz.ccApiCart.CART_ID => cartId,
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
            };

            System.debug('nalamo'+cartToSave);

            Map<String, Object> cartSaveResult = ccrz.ccApiCart.saveCart(cartToSave);

        } catch (Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'Err', e);
        } finally {
            ccrz.ccLog.close(res);
        }
        return res;
    }


    @RemoteAction
    global static ccrz.cc_RemoteActionResult addExtPricedItem(ccrz.cc_RemoteActionContext ctx, String cartId, String sku, String productId, Decimal quantity, Decimal productPrice, String typeMark, String unitOfMeasure) {

        System.debug('cartId: ' + cartId);
        System.debug('sku: ' + sku);
        System.debug('productId: ' + productId);
        System.debug('quantity: ' + quantity);
        System.debug('productPrice: ' + productPrice);
        System.debug('typeMark: ' + typeMark);
        System.debug('unitOfMeasure: ' + unitOfMeasure);

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        res.success = false;
        res.inputContext = ctx;
        try {

            //Getting the current Cart.
            List<ccrz__E_Cart__c> currentCart = [
                    SELECT Id
                    FROM ccrz__E_Cart__c
                    WHERE ccrz__EncryptedId__c = :cartId
            ];
            String standardCardId = currentCart[0].Id;

            ccrz__E_CartItem__c cartItem = null;
            ccrz__E_CartItem__c sameTypeMarkItem = null;
            System.debug('TDBG');
            List<ccrz__E_CartItem__c> cartItems = retrieveCartItem(cartId, productId);
            if (!cartItems.isEmpty()) {
                for (ccrz__E_CartItem__c aItem : cartItems) {
                    if(aItem.ccrz__UnitOfMeasure__c == unitOfMeasure) {
                        System.debug('viewtypemark'+aItem.Type_Marks__c+','+typeMark);
                        if(String.isEmpty(aItem.Type_Marks__c) && String.isEmpty(typeMark)) {
                            cartItem = aItem;
                            sameTypeMarkItem = aItem;
                        }
                        if (!String.isEmpty(aItem.Type_Marks__c) && aItem.Type_Marks__c.equals(typeMark)) {
                            cartItem = aItem;
                            sameTypeMarkItem = aItem;
                        }
                    }
                }
            }
            System.debug('TDBG cartItem ' + cartItem);
            System.debug('TDBG sameTypeMarkItem ' + sameTypeMarkItem);

            if (cartItem != null && sameTypeMarkItem == null) {
                /*
				Decimal sumOfQuantities = 0;
                sumOfQuantities = (quantity != null ? quantity : 0) + cartItem.ccrz__Quantity__c;
                cartItem.ccrz__Price__c = productPrice;
                cartItem.ccrz__Quantity__c = sumOfQuantities;
                //cartItem.ccrz__SubAmount__c = (productPrice * quantity).setScale(2);
                update cartItem;

                //System.debug('cartItem.Type_Marks__c: ' + cartItem.Type_Marks__c + ' typeMark: ' + typeMark);

                Map<String, Object> cartItemGroupToCreate = new Map<String, Object>{
                        'cart' => standardCardId
                };
                Map<String, Object> cartItemGroupCreateInputData = new Map<String, Object>{
                        ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                        'ECartItemGroupsS' => new List<Map<String, Object>>{
                                cartItemGroupToCreate
                        }
                };
                Map<String, Object> createCartItemGroupResults = ccrz.ccApiCart.createCartItemGroup(cartItemGroupCreateInputData);
                String newItemGroupId = (String) createCartItemGroupResults.get(ccrz.ccApiCart.ITEMGROUPID);

                Map<String, Object> cartItemsToMove = new Map<String, Object>{
                        ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                        ccrz.ccApiCart.CART_ENCID => cartId,
                        ccrz.ccApiCart.TARGETGROUP => newItemGroupId,
                        ccrz.ccApiCart.MERGELINES => false,
                        ccrz.ccApiCart.MOVEDATA => new List<Map<String, Object>>{
                                new Map<String, Object>{
                                        ccrz.ccApiCart.ITEMID => cartItem.Id,
                                        ccrz.ccApiCart.TARGETQTY => (quantity != null ? quantity : 0)
                                }
                        }
                };
                Map<String, Object> processItemGroupsResults = ccrz.ccApiCart.processItemGroups(cartItemsToMove);

                List<ccrz__E_CartItem__c> cartItemToUpdate = [
                        SELECT Type_Marks__c
                        FROM ccrz__E_CartItem__c
                        WHERE ccrz__CartItemGroup__c = :newItemGroupId
                ];

                cartItemToUpdate[0].Type_Marks__c = String.isEmpty(typeMark) ? '' : typeMark;
                update cartItemToUpdate[0];

                List<ccrz__E_CartItem__c> currentCartItems = [
                        SELECT Id
                        FROM ccrz__E_CartItem__c
                        WHERE ccrz__Cart__r.ccrz__EncryptedId__c = :cartId
                ];
				*/
            } else if (cartItem != null && sameTypeMarkItem != null) {
                System.debug('TDBG quantity' + quantity);
                System.debug('TDBG cartItem.ccrz__Quantity__c' + cartItem.ccrz__Quantity__c);
                System.debug('TDBG productPrice' + productPrice);
                Decimal sumOfQuantities = 0;
                sumOfQuantities = (quantity != null ? quantity : 0) + cartItem.ccrz__Quantity__c;
                sameTypeMarkItem.ccrz__Price__c = productPrice;
                sameTypeMarkItem.ccrz__Quantity__c = sumOfQuantities;
                sameTypeMarkItem.ccrz__SubAmount__c = (productPrice * sumOfQuantities).setScale(2);

                update sameTypeMarkItem;
            } else {
                List<ccrz__E_CartItem__c> newCartItems = new List<ccrz__E_CartItem__c>();
                ccrz__E_CartItem__c newCartItem = new ccrz__E_CartItem__c();
                newCartItem.ccrz__Cart__c = currentCart[0].Id;
                newCartItem.ccrz__ExtSKU__c = sku;
                newCartItem.ccrz__Quantity__c = quantity;
                newCartItem.ccrz__Price__c = productPrice;
                newCartItem.ccrz__SubAmount__c = productPrice * quantity;
                newCartItem.ccrz__UnitOfMeasure__c = unitOfMeasure;
                newCartItem.Type_Marks__c = typeMark;
                newCartItem.ccrz__ItemStatus__c = 'Available';
                newCartItem.ccrz__PricingType__c = 'external';
                newCartItem.ccrz__ProductType__c = 'Product';
                newCartItem.ccrz__StoreID__c = 'DefaultStore';
                newCartItem.ccrz__RequestDate__c = Date.today();
                newCartItem.ccrz__Product__c = productId;
                newCartItems.add(newCartItem);
                insert newCartItems;

                /*Set<Id> existingCartItemIds = new Set<Id>();

                //TODO: create Item Group

                List<ccrz__E_CartItemGroup__c> groups = [
                        SELECT Id
                        FROM ccrz__E_CartItemGroup__c
                        WHERE ccrz__Cart__r.ccrz__EncryptedId__c = :cartId
                ];

                //Checking if there are existing cart items
                //if not, initing a new cart item group
                List<ccrz__E_CartItem__c> currentCartItems = [
                        SELECT Id
                        FROM ccrz__E_CartItem__c
                        WHERE ccrz__Cart__r.ccrz__EncryptedId__c = :cartId
                ];
                if (!currentCartItems.isEmpty()) {
                    for (ccrz__E_CartItem__c item : currentCartItems) {
                        existingCartItemIds.add(item.Id);
                    }
                } else {
                    *//*Map<String, Object> groupsToDelete = new Map<String, Object>{
                            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                            ccrz.ccApiCart.ITEMGROUPLIST => groups
                    };
                    Map<String, Object> deleteResult = ccrz.ccApiCart.removeCartItemGroup(groupsToDelete);
                    System.debug('success?: ' + deleteResult.get(ccrz.ccApi.SUCCESS));*//*
                    delete groups;
                    List<ccrz__E_CartItemGroup__c> groupsAfterDelete = [
                            SELECT Id
                            FROM ccrz__E_CartItemGroup__c
                            WHERE ccrz__Cart__r.ccrz__EncryptedId__c = :cartId
                    ];
                }

                //Creating new cartItemGroup.
                Map<String, Object> cartItemGroupToCreate = new Map<String, Object>{
                        'cart' => standardCardId
                };
                Map<String, Object> cartItemGroupCreateInputData = new Map<String, Object>{
                        ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                        'ECartItemGroupsS' => new List<Map<String, Object>>{
                                cartItemGroupToCreate
                        }
                };
                system.debug('TDBG');
                Map<String, Object> createCartItemGroupResults = ccrz.ccApiCart.createCartItemGroup(cartItemGroupCreateInputData);
                String newItemGroupId = (String) createCartItemGroupResults.get(ccrz.ccApiCart.ITEMGROUPID);

                //Adding
                //END TODO

                List<Map<String, Object>> lineData = new List<Map<String, Object>>();

                lineData.add(
                        new Map<String, Object>{
                                ccrz.ccApiCart.LINE_DATA_SKU => sku,
                                ccrz.ccApiCart.LINE_DATA_QUANTITY => (quantity != null ? quantity : 0),
                                ccrz.ccApiCart.LINE_DATA_PRICE => productPrice
                        }
                );

                System.debug(lineData.size());

                Map<String, Object> cartItemsToAdd = new Map<String, Object>{
                        ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                        ccrz.ccApiCart.CART_ID => cartId,
                        ccrz.ccApiCart.LINE_DATA => lineData
                };

                System.debug('cartItemsToAdd\n'+JSON.serializePretty(cartItemsToAdd));

                Map<String, Object> addToCartResults = ccrz.ccApiCart.addTo(cartItemsToAdd);

                if (addToCartResults.containsKey(ccrz.ccApiCart.PRODSADDEDTOCART)) {
                    List<String> ids = (List<String>) addToCartResults.get(ccrz.ccApiCart.PRODSADDEDTOCART);
                    System.debug(ids);
                }

                Id newCartItemId = null;
                system.debug('TDBG '+cartId);
                List<ccrz__E_CartItem__c> postoperativeItems = [
                        SELECT Id, ccrz__Quantity__c, Type_Marks__c
                        FROM ccrz__E_CartItem__c
                        WHERE ccrz__Cart__r.ccrz__EncryptedId__c = :cartId
                ];
                System.debug('size2: ' + postoperativeItems.size());

                for (ccrz__E_CartItem__c postItem : postoperativeItems) {
                    if (!existingCartItemIds.contains(postItem.Id)) {
                        newCartItemId = postItem.Id;
                    }
                }
                system.debug('TDBG');
                //Moving to cartItemGroup- START
                Map<String, Object> cartItemsToMove = new Map<String, Object>{
                        ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                        ccrz.ccApiCart.CART_ENCID => cartId,
                        ccrz.ccApiCart.TARGETGROUP => newItemGroupId,
                        ccrz.ccApiCart.MERGELINES => false,
                        ccrz.ccApiCart.MOVEDATA => new List<Map<String, Object>>{
                                new Map<String, Object>{
                                        ccrz.ccApiCart.ITEMID => newCartItemId,
                                        ccrz.ccApiCart.TARGETQTY => (quantity != null ? quantity : 0)
                                }
                        }
                };
                system.debug('TDBG '+JSON.serializePretty(cartItemsToMove));
                Map<String, Object> processItemGroupsResults = ccrz.ccApiCart.processItemGroups(cartItemsToMove);
                //Moving to cartItemGroup - END
                system.debug('newItemGroupId '+newItemGroupId);
                List<ccrz__E_CartItem__c> cartItemToUpdate = [
                        SELECT Type_Marks__c
                        FROM ccrz__E_CartItem__c
                        WHERE ccrz__CartItemGroup__c = :newItemGroupId
                ];
                if (cartItemToUpdate.size()>0) {
                    cartItemToUpdate[0].Type_Marks__c = String.isEmpty(typeMark) ? '' : typeMark;
                    update cartItemToUpdate[0];
                }

                Map<String, Object> cartToSave = new Map<String, Object>{
                        ccrz.ccApiCart.CART_ID => cartId,
                        ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                };
                if(!Test.isRunningTest()){
                    Map<String, Object> cartSaveResult = ccrz.ccApiCart.saveCart(cartToSave);
                }*/

                /*ccrz__E_CartItem__c cartItemToUpdate = retrieveCartItemToUpdateTypeMark(cartId, productId, quantity);
                //System.debug(cartItemToUpdate.ccrz__Quantity__c);
                if (cartItemToUpdate != null) {
                    cartItemToUpdate.Type_Marks__c = typeMark;
                    update cartItemToUpdate;
                }*/
            }

            res.success = true;
            res.data = cartId;
        } catch (Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'Err', e);
            System.debug(e.getStackTraceString() + ' ' + e.getMessage() + ' line: ' + e.getLineNumber());
            System.debug(e.getStackTraceString());
            res.data = e.getStackTraceString() + ' ' + e.getMessage() + ' line: ' + e.getLineNumber();
            res.success = false;
        } finally {
            ccrz.ccLog.close(res);
        }
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult addExtPricedItemForCommisionWidget(ccrz.cc_RemoteActionContext ctx, String cartId, String sku, String productId, Decimal quantity, Decimal productPrice, String typeMark, String unitOfMeasure) {

        System.debug('addExtPricedItem unitOfMeasure ' + unitOfMeasure);

        System.debug('PROD ID ' + productId);

        System.debug('cartId: ' + cartId);
        System.debug('sku: ' + sku);
        System.debug('productId: ' + productId);
        System.debug('quantity: ' + quantity);
        System.debug('productPrice: ' + productPrice);
        System.debug('typeMark: ' + typeMark);
        System.debug('unitOfMeasure: ' + unitOfMeasure);

        List<ccrz__E_CartItem__c> cartItemList = [
                SELECT Id, ccrz__Quantity__c, Type_Marks__c, ccrz__UnitOfMeasure__c
                FROM ccrz__E_CartItem__c
                WHERE ccrz__Cart__r.ccrz__EncryptedId__c = :cartId
        ];

        System.debug('CART ITEMS' + cartItemList);

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        res.success = false;
        res.inputContext = ctx;
        try {

            //Getting the current Cart.
            List<ccrz__E_Cart__c> currentCart = [
                    SELECT Id
                    FROM ccrz__E_Cart__c
                    WHERE ccrz__EncryptedId__c = :cartId
            ];
            String standardCardId = currentCart[0].Id;

            ccrz__E_CartItem__c existingCartItemWithSameProductId = null;
            ccrz__E_CartItem__c sameTypeMarkItem = null;
            ccrz__E_CartItem__c perfectMatch = null;
            List<ccrz__E_CartItem__c> eCartItems = retrieveCartItemWithSameProductId(cartId, productId);
            if (!eCartItems.isEmpty()) {
                existingCartItemWithSameProductId = eCartItems[0];
                for (ccrz__E_CartItem__c aItem : eCartItems) {
                    if (!String.isEmpty(aItem.Type_Marks__c)) {
                        if (aItem.Type_Marks__c.equals(typeMark)) {
                            sameTypeMarkItem = aItem;
                            if (aItem.ccrz__UnitOfMeasure__c == unitOfMeasure) {
                                perfectMatch = aItem;
                                break;
                            }
                        }
                    }
                    if (String.isEmpty(aItem.Type_Marks__c) && String.isEmpty(typeMark)) {
                        sameTypeMarkItem = aItem;
                        if (aItem.ccrz__UnitOfMeasure__c == unitOfMeasure) {
                            perfectMatch = aItem;
                            break;
                        }
                    }

                }
            }
            System.debug('TDBG existingCartItemWithSameProductId ' + existingCartItemWithSameProductId);
            System.debug('TDBG sameTypeMarkItem ' + sameTypeMarkItem);
            System.debug('TDBG sameTypeMarkItem2 ' + existingCartItemWithSameProductId?.ccrz__UnitOfMeasure__c);
            //  System.debug('TDBG sameTypeMarkItem2 ' + existingCartItemWithSameProductId.ccrz__UnitOfMeasure__c);
            System.debug('TDBG sameTypeMarkItem3 ' + unitOfMeasure);

            if (existingCartItemWithSameProductId != null && sameTypeMarkItem == null && existingCartItemWithSameProductId.ccrz__UnitOfMeasure__c == unitOfMeasure) {

                System.debug('gg1 cart item present =***** ' + existingCartItemWithSameProductId.ccrz__Quantity__c);

                Decimal sumOfQuantities = 0;
                sumOfQuantities = (quantity != null ? quantity : 0) + existingCartItemWithSameProductId.ccrz__Quantity__c;
                existingCartItemWithSameProductId.ccrz__Price__c = productPrice;
                existingCartItemWithSameProductId.ccrz__Quantity__c = sumOfQuantities;
                //existingCartItemWithSameProductId.ccrz__SubAmount__c = (productPrice * quantity).setScale(2);
                update existingCartItemWithSameProductId;

                //System.debug('existingCartItemWithSameProductId.Type_Marks__c: ' + existingCartItemWithSameProductId.Type_Marks__c + ' typeMark: ' + typeMark);

                Map<String, Object> cartItemGroupToCreate = new Map<String, Object>{
                        'cart' => standardCardId
                };
                Map<String, Object> cartItemGroupCreateInputData = new Map<String, Object>{
                        ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                        'ECartItemGroupsS' => new List<Map<String, Object>>{
                                cartItemGroupToCreate
                        }
                };
                Map<String, Object> createCartItemGroupResults = ccrz.ccApiCart.createCartItemGroup(cartItemGroupCreateInputData);
                String newItemGroupId = (String) createCartItemGroupResults.get(ccrz.ccApiCart.ITEMGROUPID);

                Map<String, Object> cartItemsToMove = new Map<String, Object>{
                        ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                        ccrz.ccApiCart.CART_ENCID => cartId,
                        ccrz.ccApiCart.TARGETGROUP => newItemGroupId,
                        ccrz.ccApiCart.MERGELINES => false,
                        ccrz.ccApiCart.MOVEDATA => new List<Map<String, Object>>{
                                new Map<String, Object>{
                                        ccrz.ccApiCart.ITEMID => existingCartItemWithSameProductId.Id,
                                        ccrz.ccApiCart.TARGETQTY => (quantity != null ? quantity : 0)
                                }
                        }
                };
                Map<String, Object> processItemGroupsResults = ccrz.ccApiCart.processItemGroups(cartItemsToMove);

                System.debug('newidrrrr'+newItemGroupId);

                List<ccrz__E_CartItem__c> cartItemToUpdate = [
                        SELECT Type_Marks__c
                        FROM ccrz__E_CartItem__c
                        WHERE ccrz__CartItemGroup__c = :newItemGroupId
                ];

                cartItemToUpdate[0].Type_Marks__c = String.isEmpty(typeMark) ? '' : typeMark;
                update cartItemToUpdate[0];

                List<ccrz__E_CartItem__c> currentCartItems = [
                        SELECT Id
                        FROM ccrz__E_CartItem__c
                        WHERE ccrz__Cart__r.ccrz__EncryptedId__c = :cartId
                ];
                System.debug('in existing: ' + currentCartItems.size());

            } else if (perfectMatch != null) {

                Decimal sumOfQuantities = 0;
                sumOfQuantities = (quantity != null ? quantity : 0) + perfectMatch.ccrz__Quantity__c;
                perfectMatch.ccrz__Price__c = productPrice;
                perfectMatch.ccrz__Quantity__c = sumOfQuantities;
                perfectMatch.ccrz__SubAmount__c = (productPrice * sumOfQuantities).setScale(2);

                update perfectMatch;
            } else {

                System.debug('in else ');
                Map<Id, ccrz__E_CartItem__c> existingCartItems = new Map<Id, ccrz__E_CartItem__c>([
                        SELECT Id
                        FROM ccrz__E_CartItem__c
                        WHERE ccrz__Cart__r.ccrz__EncryptedId__c = :cartId
                ]);

                //TODO: create Item Group

                List<ccrz__E_CartItemGroup__c> groups = [
                        SELECT Id
                        FROM ccrz__E_CartItemGroup__c
                        WHERE ccrz__Cart__r.ccrz__EncryptedId__c = :cartId
                ];
                System.debug('item groups: ' + groups.size());

                //Checking if there are existing cart items
                //if not, initing a new cart item group
                if (existingCartItems.isEmpty()) {
                    /*Map<String, Object> groupsToDelete = new Map<String, Object>{
                            ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                            ccrz.ccApiCart.ITEMGROUPLIST => groups
                    };
                    Map<String, Object> deleteResult = ccrz.ccApiCart.removeCartItemGroup(groupsToDelete);
                    System.debug('success?: ' + deleteResult.get(ccrz.ccApi.SUCCESS));*/
                    delete groups;
                    List<ccrz__E_CartItemGroup__c> groupsAfterDelete = [
                            SELECT Id
                            FROM ccrz__E_CartItemGroup__c
                            WHERE ccrz__Cart__r.ccrz__EncryptedId__c = :cartId
                    ];
                    System.debug('after delete ' + groupsAfterDelete.size());
                }

                //Creating new cartItemGroup.
                Map<String, Object> cartItemGroupToCreate = new Map<String, Object>{
                        'cart' => standardCardId
                };
                Map<String, Object> cartItemGroupCreateInputData = new Map<String, Object>{
                        ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                        'ECartItemGroupsS' => new List<Map<String, Object>>{
                                cartItemGroupToCreate
                        }
                };
                Map<String, Object> createCartItemGroupResults = ccrz.ccApiCart.createCartItemGroup(cartItemGroupCreateInputData);
                String newItemGroupId = (String) createCartItemGroupResults.get(ccrz.ccApiCart.ITEMGROUPID);

                //Adding
                //END TODO

                List<Map<String, Object>> lineData = new List<Map<String, Object>>();

                lineData.add(
                        new Map<String, Object>{
                                ccrz.ccApiCart.LINE_DATA_SKU => sku,
                                ccrz.ccApiCart.LINE_DATA_QUANTITY => (quantity != null ? quantity : 0),
                                ccrz.ccApiCart.LINE_DATA_PRICE => productPrice
                        }
                );

                System.debug(lineData.size());

                Map<String, Object> cartItemsToAdd = new Map<String, Object>{
                        ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                        ccrz.ccApiCart.CART_ID => cartId,
                        ccrz.ccApiCart.LINE_DATA => lineData

                };

                System.debug('cartItemsToAdd\n' + JSON.serializePretty(cartItemsToAdd));

                Map<String, Object> addToCartResults = ccrz.ccApiCart.addTo(cartItemsToAdd);

                System.debug('addToCartResults\n' + JSON.serializePretty(addToCartResults));

                if (addToCartResults.containsKey(ccrz.ccApiCart.PRODSADDEDTOCART)) {
                    List<String> ids = (List<String>) addToCartResults.get(ccrz.ccApiCart.PRODSADDEDTOCART);
                    System.debug(ids);
                }

                Id newCartItemId = null;
                List<ccrz__E_CartItem__c> newCartItems = [
                        SELECT Id, ccrz__Quantity__c, Type_Marks__c
                        FROM ccrz__E_CartItem__c
                        WHERE ccrz__Cart__r.ccrz__EncryptedId__c = :cartId AND (NOT Id IN:existingCartItems.keySet())
                ];
                System.debug('newCartItems\n'+JSON.serializePretty(newCartItems));
                if (newCartItems.size() > 0) {
                    update new ccrz__E_CartItem__c(Id = newCartItems[0].Id, ccrz__UnitOfMeasure__c = unitOfMeasure, Type_Marks__c = typeMark);
                }
                System.debug('TDBG');
                //Moving to cartItemGroup- START
                Map<String, Object> cartItemsToMove = new Map<String, Object>{
                        ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                        ccrz.ccApiCart.CART_ENCID => cartId,
                        ccrz.ccApiCart.TARGETGROUP => newItemGroupId,
                        ccrz.ccApiCart.MERGELINES => false,
                        ccrz.ccApiCart.MOVEDATA => new List<Map<String, Object>>{
                                new Map<String, Object>{
                                        ccrz.ccApiCart.ITEMID => newCartItemId,
                                        ccrz.ccApiCart.TARGETQTY => (quantity != null ? quantity : 0)
                                }
                        }
                };
                System.debug('TDBG ' + JSON.serializePretty(cartItemsToMove));
                Map<String, Object> processItemGroupsResults = ccrz.ccApiCart.processItemGroups(cartItemsToMove);
                //Moving to cartItemGroup - END
                System.debug('newItemGroupId ' + newItemGroupId);
                List<ccrz__E_CartItem__c> cartItemToUpdate = [
                        SELECT Type_Marks__c
                        FROM ccrz__E_CartItem__c
                        WHERE ccrz__CartItemGroup__c = :newItemGroupId
                ];
                if (cartItemToUpdate.size() > 0) {
                    cartItemToUpdate[0].Type_Marks__c = String.isEmpty(typeMark) ? '' : typeMark;
                    update cartItemToUpdate[0];
                }

                Map<String, Object> cartToSave = new Map<String, Object>{
                        ccrz.ccApiCart.CART_ID => cartId,
                        ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                };

                System.debug('nalamo'+cartToSave);

                Map<String, Object> cartSaveResult = ccrz.ccApiCart.saveCart(cartToSave);

                /*ccrz__E_CartItem__c cartItemToUpdate = retrieveCartItemToUpdateTypeMark(cartId, productId, quantity);
                //System.debug(cartItemToUpdate.ccrz__Quantity__c);
                if (cartItemToUpdate != null) {
                    cartItemToUpdate.Type_Marks__c = typeMark;
                    update cartItemToUpdate;
                }*/
            }

            res.success = true;
            res.data = cartId;
        } catch (Exception e) {
            ccrz.ccLog.log(LoggingLevel.ERROR, 'Err', e);
            System.debug(e.getStackTraceString() + ' ' + e.getMessage() + ' line: ' + e.getLineNumber());
            res.success = false;
            res.data = e.getStackTraceString() + ' ' + e.getMessage();
        } finally {
            ccrz.ccLog.close(res);
        }
        return res;
    }

    public static List<ccrz__E_CartItem__c> retrieveCartItemWithSameProductId(String cartId, String productId) {
        List<ccrz__E_CartItem__c> cartItemList = [
                SELECT Id, ccrz__Quantity__c, Type_Marks__c, ccrz__UnitOfMeasure__c
                FROM ccrz__E_CartItem__c
                WHERE ccrz__Cart__r.ccrz__EncryptedId__c = :cartId AND ccrz__Product__c = :productId
        ];

        return cartItemList;
    }

    public static List<ccrz__E_CartItem__c> retrieveCartItem(String cartId, String productId) {
        List<ccrz__E_CartItem__c> cartItemList = [
                SELECT Id, ccrz__Quantity__c, Type_Marks__c, ccrz__UnitOfMeasure__c
                FROM ccrz__E_CartItem__c
                WHERE ccrz__Cart__r.ccrz__EncryptedId__c = :cartId AND ccrz__Product__c = :productId
        ];

        return cartItemList;
    }

    public static List<ccrz__E_CartItem__c> retrieveMTOCartItem(String cartId, String extSKU, String externalSKU) {
        List<ccrz__E_CartItem__c> cartItemList = [
                SELECT Id, ccrz__Quantity__c, Type_Marks__c, ccrz__UnitOfMeasure__c
                FROM ccrz__E_CartItem__c
                WHERE ccrz__Cart__r.ccrz__EncryptedId__c = :cartId AND ccrz__ExtName__c = :extSKU AND ccrz__ExtSKU__c = :externalSKU 
        ];
        
        return cartItemList;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult addBatchPricedItem(ccrz.cc_RemoteActionContext ctx, String cartId, String sku, String attr) {

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        res.success = false;
        res.inputContext = ctx;

        System.debug('step');
        System.debug(sku);
        System.debug(cartId);
        System.debug(attr);

        String jsonAttr = '{ "batchitems":' + attr + '}';
        System.debug(jsonAttr);

        BatchJSON bsj = (BatchJSON) System.JSON.deserialize(jsonAttr, BatchJSON.class);
        System.debug(bsj);
        // Query every uom code and label
        Set<String> measurekeyWords = new Set<String>();
        for (Object uomObject : HeaderActions.getUomCodeLabelMap(ctx)) {
            UOM_Mapping__mdt uomMdt = (UOM_Mapping__mdt) uomObject;
            measurekeyWords.add(uomMdt.Label);
            measurekeyWords.add(uomMdt.Code__c);
        }

        for (Batchitems bs : bsj.batchitems) {
            System.debug(bs.sku);
            System.debug(bs.qty);
            System.debug(bs.price);
            System.debug(bs.total);
            for (Attrs a : bs.attrs) {
                if (a.sfid == bs.hash) {
                    bs.sfid = a.sfid;
                    bs.attrId = a.attrId;
                    String measure = a.displayName.replace('<p>', '');
                    measure = measure.replace('</p>', '');
                    if (measurekeyWords.contains(measure)) {
                        bs.uom = measure;
                    }
                }
            }
            System.debug(bs.sfid);
            System.debug(bs.attrId);
            System.debug(bs.uom);
        }

        ccrz__E_Cart__c cart = [select Id FROM ccrz__E_Cart__c where ccrz__EncryptedId__c = :cartId];

        List<ccrz__E_CartItem__c > cartItems = [
                SELECT Id,
                        ccrz__cartItemType__c,
                        ccrz__Price__c,
                        ccrz__Quantity__c,
                        ccrz__ItemTotal__c,
                        ccrz__SubAmount__c,
                        ccrz__Product__r.ccrz__SKU__c,
                        ccrz__Product__r.MaterialDescription__c,
                        ccrz__UnitOfMeasure__c,
                        ccrz__PricingType__c,
                        ccrz__SelectedAttr__c,
                        ccrz__ExtName__c,
                        ccrz__ExtSKU__c
                FROM ccrz__E_CartItem__c
                WHERE ccrz__Cart__c = :cart.Id
                AND ccrz__cartItemType__c = 'Minor'
                AND ccrz__Product__r.ccrz__SKU__c = :sku
        ];

        List<ccrz__E_CartItem__c> duplicateCartItems = new List<ccrz__E_CartItem__c>();
        Set <String> skuPricingTypeExtPresent = new Set <String>();


        if (cartItems != null && cartItems.size() > 0) {
            System.debug('cartItem size ****' + cartItems.size());

            //Check for sku with external pricing, if present update it with qty and price
            for (ccrz__E_CartItem__c cti : cartItems) {
                for (Batchitems bs : bsj.batchitems) {
                    System.debug('cti.ccrz__PricingType__c ****' + cti.ccrz__PricingType__c);
                    System.debug('bs.sfid ****' + bs.sfid);
                    System.debug('cti.ccrz__SelectedAttr__c ****' + cti.ccrz__SelectedAttr__c);
                    if (cti.ccrz__SelectedAttr__c.contains(bs.sfid) && cti.ccrz__PricingType__c == 'external'
                            && cti.ccrz__UnitOfMeasure__c == bs.uom) {
                        Decimal qty = cti.ccrz__Quantity__c + bs.qty;
                        cti.ccrz__Price__c = bs.price;
                        cti.ccrz__ExtSKU__c = cti.ccrz__Product__r.ccrz__SKU__c;
                        cti.ccrz__ExtName__c = cti.ccrz__Product__r.ccrz__SKU__c;
                        cti.ccrz__Quantity__c = qty;
                        cti.ccrz__SubAmount__c = bs.price * qty;
                        cti.ccrz__PricingType__c = 'external';
                        cti.ccrz__UnitOfMeasure__c = bs.uom;
                        System.debug('cartItem price 2 ****' + cti.ccrz__Price__c);
                        System.debug('cartItem sub amount 2 ****' + cti.ccrz__SubAmount__c);
                        skuPricingTypeExtPresent.add(bs.uom);
                    }
                }
            }


            //Check for sku with if still not marked as an external (means its still auto), make it external
            for (ccrz__E_CartItem__c cti : cartItems) {
                for (Batchitems bs : bsj.batchitems) {
                    System.debug('cti.ccrz__PricingType__c ****' + cti.ccrz__PricingType__c);
                    System.debug('bs.sfid ****' + bs.sfid);
                    System.debug('cti.ccrz__SelectedAttr__c ****' + cti.ccrz__SelectedAttr__c);
                    if (cti.ccrz__SelectedAttr__c.contains(bs.sfid) && cti.ccrz__PricingType__c == 'auto' && !skuPricingTypeExtPresent.contains(bs.uom)) {
                        Decimal qty = bs.qty;
                        cti.ccrz__Price__c = bs.price;
                        cti.ccrz__ExtSKU__c = cti.ccrz__Product__r.ccrz__SKU__c;
                        cti.ccrz__ExtName__c = cti.ccrz__Product__r.ccrz__SKU__c;
                        cti.ccrz__Quantity__c = qty;
                        cti.ccrz__SubAmount__c = bs.price * qty;
                        cti.ccrz__PricingType__c = 'external';
                        cti.ccrz__UnitOfMeasure__c = bs.uom;
                        System.debug('cartItem price ****' + cti.ccrz__Price__c);
                        System.debug('cartItem sub amount ****' + cti.ccrz__SubAmount__c);
                        skuPricingTypeExtPresent.add(bs.uom);
                    }
                }
            }

            // external is present and auto is not needed, delete it.
            for (ccrz__E_CartItem__c cti : cartItems) {
                //if(cti.ccrz__PricingType__c == 'auto' && skuPricingTypeExtPresent.contains(cti.ccrz__UnitOfMeasure__c)){
                if (cti.ccrz__PricingType__c == 'auto') {
                    ccrz__E_CartItem__c ctd = new ccrz__E_CartItem__c();
                    ctd.Id = cti.Id;
                    duplicateCartItems.add(ctd);
                }
            }

            update cartItems;


            try {
                if (duplicateCartItems != null && duplicateCartItems.size() > 0) {
                    delete duplicateCartItems;
                }
            } catch (DmlException e) {
                // Process exception here
            }

        }

        res.success = true;
        return res;
    }

    public class BatchJSON {
        public Batchitems[] batchitems;
    }
    public class Batchitems {
        public Attrs[] attrs;
        public String sku;    //34289
        public Decimal qty;    //1
        public Decimal price;    //9
        public Decimal total;    //9
        public String hash;    //a6m2D00000059c2QAA
        public String uom;
        public String sfid;
        public String attrId;

    }
    public class Attrs {
        public String sfid;    //a6m2D00000059c2QAA
        public String attrId;    //a6m2D00000059bxQAA-EA_attr
        public String displayName;    //<p>EA</p>
    }

    //Persona Changes
    public Boolean isFirst { get; set; }

    public ProductListActions() {
        isFirst = false;
        Id userId = UserInfo.getUserId();


        User u = [SELECT Id, Profile.Name, Name FROM User WHERE Id = :userId];


        if (u.Profile.Name == 'Agent B2B Storefront Registered Users' || u.Profile.Name == 'Distributor B2B Storefront Registered Users') {
            system.debug('Inside 1****');
            isFirst = true;
        } else if (u.Profile.Name != 'Agent B2B Storefront Registered Users') {
            List<PermissionSetAssignment> psa = [
                    SELECT Id, AssigneeId, Assignee.Name, Assignee.Profile.Name, PermissionSet.IsOwnedByProfile, PermissionSetId,PermissionSet.Name
                    FROM PermissionSetAssignment
                    where PermissionSet.Name = 'View_PLP_and_PDP_Prices' and AssigneeId IN (SELECT Id FROM User WHERE Id = :userId)
            ];
            for (PermissionSetAssignment psa1 : psa) {
                if (psa1.PermissionSet.Name == 'View_PLP_and_PDP_Prices') {
                    System.debug('Inside 2****');
                    isFirst = true;
                } else {
                    System.debug('Inside 3****');
                    isFirst = false;
                }
            }
        }
    }


}
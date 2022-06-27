global class ccCSVUploadController {
    @RemoteAction
    global static ccrz.cc_RemoteActionResult parseCSV(final ccrz.cc_RemoteActionContext ctx, String csvBlob, Boolean newCart) {
        ccrz.cc_RemoteActionResult resp = ccrz.cc_CallContext.init(ctx);

        Map<String, String> acceptableUOMMap = new Map<String, String>();
        for (Object uomObject : HeaderActions.getUomCodeLabelMap(ctx)) {
            UOM_Mapping__mdt uomMdt = (UOM_Mapping__mdt) uomObject;
            acceptableUOMMap.put(uomMdt.Label, uomMdt.Code__c);
        }

        try {
            List<Map<String, Object>> lineData = new List<Map<String, Object>>{
            };
            System.debug(csvBlob);
            System.debug('in parse CSV');
            List<String> unfilteredlines = csvBlob.split('\n');
            unfilteredlines.remove(0);
            Map<String, List<String>> linesAfterFilter = lineFilter(unfilteredlines);
            String invaildCats = linesAfterFilter.get('invalidLines').get(0);
            List<String> lines = linesAfterFilter.get('filteredLines');

            if (lines == null || lines.isEmpty()) {
                resp.success = false;
                resp.data = new Map<String, Object>{
                        'uomError' => 'The uploaded file is either empty or contains only invalid catalog numbers.<br/>Please update your file, re-select the file, and try to upload again.<br/><br/>If you are having difficulty with the catalog number, please <a href="/s/connect-platform-support?type=upload_error">send us a message</a>.'
                };
                return resp;
            }

            Set<String> productEntry = new Set<String>();
            for (String singleLine : lines) {
                List<String> values = parseCSVLine(singleLine);
                if (values[0] != null) {
                    productEntry.add(filterCSVInput(values[0]));
                }
            }
            System.debug(productEntry);
            Set<String> skus = new Set<String>();
            Set<String> catNumbers = new Set<String>();
            Set<String> prodId = new Set<String>();
            Map<String, ccrz__E_Product__c> catNumberToProduct = new Map<String, ccrz__E_Product__c>();
            for (ccrz__E_Product__c p : [
                    SELECT Id, ccrz__SKU__c, MaterialDescription__c, ccrz__PrimaryAttr__c
                    FROM ccrz__E_Product__c
                    WHERE MaterialDescription__c IN :productEntry OR ccrz__SKU__c IN :productEntry
            ]) {
                catNumberToProduct.put(p.MaterialDescription__c, p);
                catNumberToProduct.put(p.ccrz__SKU__c, p);
                skus.add(p.ccrz__SKU__c);
                catNumbers.add(p.MaterialDescription__c);
                prodId.add(p.Id);
            }

            for (String s : catNumberToProduct.keySet()) {
                System.debug('primaryAttribute: ' + catNumberToProduct.get(s).ccrz__PrimaryAttr__c + ', ' + catNumberToProduct.get(s).ccrz__SKU__c);
            }

            if (productEntry.size() > catNumbers.size()) {
                for (String catVal : productEntry) {
                    if (!catNumbers.contains(catVal) && !skus.contains(catVal)) {
                        invaildCats += catVal + ': Invalid catalog number<br/>';
                    }
                }
            }

            Map<String, String> UOMAttIdbySKU = new Map<String, String>();
            List<Pricing_UOM__c> uoms = [
                    SELECT Id, Multiplier__c, UOM__c, SKU__c
                    FROM Pricing_UOM__c
                    WHERE SKU__c IN:skus
            ];
            Set<String> UOMSet = new Set<String>();
            Map<String, String> uomNameWithSku = new Map<String, String>();
            for (Pricing_UOM__c uom : uoms) {
                UOMSet.add(uom.UOM__c);
                uomNameWithSku.put(uom.SKU__c + ':' + uom.UOM__c + ':' + uom.Multiplier__c, uom.SKU__c);
            }
            List<ccrz__E_Attribute__c> uomsAttrs = [SELECT Id, Name FROM ccrz__E_Attribute__c WHERE Name IN:UOMSet];
            Map<String, String> UOMAttIdbyUOM = new Map<String, String>();
            for (ccrz__E_Attribute__c attr : uomsAttrs) {
                UOMAttIdbyUOM.put(attr.Name, attr.Id);
            }
            for (String uomWithSKU : uomNameWithSku.keySet()) {
                String sku = uomWithSKU.split(':')[0];
                String uomText = uomWithSKU.split(':')[1];
                if (UOMAttIdbyUOM.containsKey(uomText)) {
                    UOMAttIdbySKU.put(sku, UOMAttIdbyUOM.get(uomText));
                }
            }
            Map<String, Decimal> priceBySKU = new Map<String, Decimal>();

            Map<String, Object> productFetchQuery = new Map<String, Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                    ccrz.ccAPIProduct.PRODUCTIDLIST => prodId,
                    ccrz.ccAPIProduct.PARAM_INCLUDE_PRICING => true,
                    ccrz.ccAPIProduct.INCLUDE_ATTRIBUTE_PRICING => true,
                    ccrz.ccApi.SIZING => new Map<String, Object>{
                            ccrz.ccAPIProduct.ENTITYNAME => new Map<String, Object>{
                                    ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_S
                            }
                    }
            };

            try {
                Map<String, Object> productFetchData = ccrz.ccAPIProduct.fetch(productFetchQuery);
                if (productFetchData.get(ccrz.ccAPIProduct.PRODUCTLIST) != null) {
                    List<Map<String, Object>> myProductDataList = (List<Map<String, Object>>) productFetchData.get(ccrz.ccAPIProduct.PRODUCTLIST);
                    System.debug(myProductDataList.size());
                    for (Map<String, Object> mso : myProductDataList) {
                        priceBySKU.put((String) mso.get('SKU'), (Decimal) mso.get('price'));
                    }
                }
            } catch (Exception e) {
                System.debug(e);
            }

            Map<CartItemDetailWrapper, String> typeMarksByProducts = new Map<ccCSVUploadController.CartItemDetailWrapper, String>();

            System.debug(catNumberToProduct);
            Integer tmpCounter = 1;
            List<ccrz__E_CartItem__c> newCartItems = new List<ccrz__E_CartItem__c>();
            System.debug('acceptableUOMMap\n'+JSON.serializePretty(acceptableUOMMap));
            for (String singleLine : lines) {
                List<String> values = parseCSVLine(singleLine);
                System.debug(values);
                if (values[0] != null) {
                    ccrz.ccApiCart.LineData lineToAdd = new ccrz.ccApiCart.LineData();
                    String catNumber = filterCSVInput(values[0]);
                    String sku;
                    Integer qty = 0;
                    Decimal price = 1;
                    String uom = '';
                    String typeMarks = '';
                    try {
                        if (values.size() == 1 || String.isEmpty(values[1]) || String.isBlank(values[1]) || Integer.valueOf(filterCSVInput(values[1])) < 1) {
                            throw new TypeException('Invalid quantity');
                        } else {
                            qty = Integer.valueOf(filterCSVInput(values[1]));
                        }
                    } catch (Exception e) {
                        invaildCats += filterCSVInput(values[0]) + ': Invalid quantity</br>';
                        continue;
                    }
                    if (catNumberToProduct.containsKey(catNumber)) {
                        sku = catNumberToProduct.get(catNumber).ccrz__SKU__c;
                    }
                    if (values.size() >= 3 && !String.isEmpty(values[2])) {
                        String uomType = formatUOM(filterCSVInput(values[2]));

                        if (!acceptableUOMMap.containsKey(uomType)) {
                            /*resp.success = false;
                            resp.data = new Map<String, Object>{
                                    'uomError' => 'Incorrect UOM for the chosen product.'
                            };
                            return resp;*/
                            invaildCats += filterCSVInput(values[0]) + ': Invalid UOM</br>';
                            continue;
                        }
                        uom = acceptableUOMMap.get(uomType);
                        Boolean isUOMCorrect = false;
                        for (String uomWithSKU : uomNameWithSku.keySet()) {
                            String uomText = uomWithSKU.split(':')[1];
                            String skuToCheck = uomWithSKU.split(':')[0];
                            if (uomText.equals(uom) && skuToCheck.equals(sku)) {
                                /*Integer expectedQty = Integer.valueOf(uomWithSKU.split(':')[2]);
                                if (Math.mod(qty, expectedQty) != 0) {
                                    resp.success = false;
                                    resp.data = new Map<String, Object>{
                                            'uomError' => 'Incorrect quantity for the chosen UOM.'
                                    };
                                    return resp;
                                }*/
                                isUOMCorrect = true;
                                break;
                            }
                        }
                        if (!isUOMCorrect) {
                            /*resp.success = false;
                            resp.data = new Map<String, Object>{
                                    'uomError' => 'Incorrect UOM for the chosen product.'
                            };
                            return resp;*/
                            invaildCats += filterCSVInput(values[0]) + ': UOM not available for this product</br>';
                            continue;
                        }
                        if (values.size() >= 4 && String.isNotBlank(values[3])) {
                            if (filterCSVInput(values[3]).length() > 8) {
                                invaildCats += filterCSVInput(values[0]) + ': Type Mark is limited to 8 characters</br>';
                                continue;
                            }
                            typeMarks = filterCSVInput(values[3]);
                        }
                    }

                    System.debug(catNumberToProduct.containsKey(catNumber));
                    System.debug(catNumberToProduct.get(catNumber));
                    System.debug(qty);

                    if (values.size() == 4 && !String.isEmpty(values[3])) {
                        typeMarksByProducts.put(new CartItemDetailWrapper(sku, qty), filterCSVInput(values[3]));
                    }

                    if (!String.isEmpty(sku)) {
                        if (priceBySKU.containsKey(sku)) {
                            price = priceBySKU.get(sku);
                        }
                        System.debug(UOMAttIdbySKU);
                        if (!String.isEmpty(catNumberToProduct.get(catNumber).ccrz__PrimaryAttr__c)) {
                            lineData.add(new Map<String, Object>{
                                    ccrz.ccApiCart.LINE_DATA_SKU => sku,
                                    ccrz.ccApiCart.LINE_DATA_QUANTITY => qty,
                                    ccrz.ccApiCart.LINE_DATA_PRICE => price,
                                    ccrz.ccApiCart.LINE_DATA_ATTRIBUTE_LIST => new List<Id>{
                                            UOMAttIdbySKU.get(sku)
                                    }
                            });
                        } else {
                            lineData.add(new Map<String, Object>{
                                    ccrz.ccApiCart.LINE_DATA_SKU => sku,
                                    ccrz.ccApiCart.LINE_DATA_QUANTITY => qty,
                                    ccrz.ccApiCart.LINE_DATA_PRICE => price
                            });
                        }
                        ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
                        cartItem.ccrz__ExtSKU__c = sku;
                        cartItem.ccrz__Quantity__c = qty;
                        cartItem.ccrz__Price__c = price;
                        cartItem.ccrz__SubAmount__c = price * qty;
                        cartItem.ccrz__UnitOfMeasure__c = uom;
                        cartItem.Type_Marks__c = typeMarks;
                        cartItem.ccrz__ItemStatus__c = 'Available';
                        cartItem.ccrz__PricingType__c = 'external';
                        cartItem.ccrz__ProductType__c = 'Product';
                        cartItem.ccrz__StoreID__c = 'DefaultStore';
                        cartItem.ccrz__RequestDate__c = Date.today();
                        cartItem.ccrz__Product__c = catNumberToProduct.get(catNumber).Id;
                        newCartItems.add(cartItem);
                    }
                    tmpCounter += 1;
                }
            }

            String encryptedCartId = ctx.currentCartId;
            System.debug(encryptedCartId);
            if (newCart || String.isEmpty(encryptedCartId)) {
                Map<String, Object> createResults = ccrz.ccApiCart.create(
                        new Map<String, Object>{
                                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                                ccrz.ccApiCart.CART_OBJLIST => new List<Map<String, Object>>{
                                        new Map<String, Object>()
                                }
                        }
                );

                encryptedCartId = (String) createResults.get(ccrz.ccApiCart.CART_ENCID);
                System.debug(encryptedCartId);
            }
            System.debug(lineData);
            System.debug(lineData.size());
            Id cartId = [SELECT Id FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c = :encryptedCartId].Id;
            delete [SELECT Id FROM ccrz__E_CartItem__c WHERE ccrz__Cart__c = :cartId];
            for (ccrz__E_CartItem__c cartItem : newCartItems) {
                cartItem.ccrz__Cart__c = cartId;
            }
            insert newCartItems;
            resp.success = true;
            resp.data = new Map<String, Object>{
                    'encryptedCartId' => encryptedCartId,
                    'newCartItems' => newCartItems,
                    'numOfItems' => lineData.size(),
                    'invaildCats' => invaildCats
            };

            /*if (lineData.size() > 0) {
                Map<String, Object> addResults = ccrz.ccApiCart.addTo(new Map<String, Object>{
                        ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                        ccrz.ccApiCart.CART_ENCID => encryptedCartId,
                        ccrz.ccApiCart.LINE_DATA => lineData,
                        ccrz.ccApiCart.ISSKIPPRICING => true
                });
                System.debug(addResults);
                resp.success = (Boolean) addResults.get(ccrz.ccApi.SUCCESS);

                Map<String, Object> priceResults = ccrz.ccApiCart.price(new Map<String, Object>{
                        ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                        ccrz.ccApiCart.CART_ENCID => encryptedCartId
                });

                Map<String, Object> cartToSave = new Map<String, Object>{
                        ccrz.ccApiCart.CART_ID => encryptedCartId,
                        ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                };
                Map<String, Object> cartSaveResult = ccrz.ccApiCart.saveCart(cartToSave);
                System.debug('cartSaveResult\n'+JSON.serializePretty(cartSaveResult));
                System.debug(addResults.get(ccrz.ccApiCart.PRODSADDEDTOCART));

                List<ccrz__E_CartItem__c> itemsToUpdate = new List<ccrz__E_CartItem__c>();
                List<ccrz__E_CartItem__c> cartItems = [
                        SELECT Id, ccrz__Quantity__c, ccrz__Product__r.ccrz__SKU__c, ccrz__Product__r.MaterialDescription__c, ccrz__Cart__r.ccrz__EncryptedId__c
                        FROM ccrz__E_CartItem__c
                        WHERE ccrz__Cart__r.ccrz__EncryptedId__c = :encryptedCartId
                ];
                for (ccrz__E_CartItem__c item : cartItems) {
                    String sku = item.ccrz__Product__r.ccrz__SKU__c;
                    Integer qty = (Integer) item.ccrz__Quantity__c;
                    CartItemDetailWrapper tmpWrapper = new CartItemDetailWrapper(sku, qty);
                    if (typeMarksByProducts.containsKey(tmpWrapper)) {
                        String typeMark = typeMarksByProducts.get(tmpWrapper);
                        item.Type_Marks__c = typeMark;
                        itemsToUpdate.add(item);
                    }
                }

                update itemsToUpdate;

                resp.data = new Map<String, Object>{
                        'encryptedCartId' => encryptedCartId,
                        'ccrz.ccAPICart.PRODSADDEDTOCART' => addResults.get(ccrz.ccApiCart.PRODSADDEDTOCART),
                        'ccrz.ccAPICart.INELIGIBLEPRODUCTS' => addResults.get(ccrz.ccApiCart.INELIGIBLEPRODUCTS),
                        'ccrz.ccApi.MESSAGES' => addResults.get(ccrz.ccApi.MESSAGES),
                        'numOfItems' => lineData.size(),
                        'invaildCats' => invaildCats
                };
                System.debug(resp.data);
            }*/
        } catch (Exception err) {
            System.debug(err.getMessage());
            System.debug(err.getStackTraceString());
            ccrz.ccLog.log(System.LoggingLevel.ERROR, 'EXCEPTION: ', err.getMessage() + err.getStackTraceString());
            throw err;
        } finally {
            ccrz.ccLog.close(resp);
        }
        System.debug(resp);

        return resp;
    }

    public Boolean isFirst { get; set; }

    public ccCSVUploadController() {
        isFirst = false;
        Id userId = UserInfo.getUserId();


        List<PermissionSetAssignment> psa = [
                SELECT Id, AssigneeId, Assignee.Name, Assignee.Profile.Name, PermissionSet.IsOwnedByProfile, PermissionSetId,PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE PermissionSet.Name = 'View_PLP_and_PDP_Prices' AND AssigneeId IN (SELECT Id FROM User WHERE Id = :userId)
        ];
        for (PermissionSetAssignment psa1 : psa) {
            if (psa1.PermissionSet.Name == 'View_PLP_and_PDP_Prices') {
                isFirst = true;
            } else {
                isFirst = false;
            }
        }

    }

    private class CartItemDetailWrapper {
        public String sku;
        public Integer qty;

        public CartItemDetailWrapper(String sku, Integer qty) {
            this.sku = sku;
            this.qty = qty;
        }

        private Boolean equals(Object obj) {
            if (obj instanceof CartItemDetailWrapper) {
                CartItemDetailWrapper p = (CartItemDetailWrapper) obj;
                return (sku.equals(p.sku)) && (qty == p.qty);
            }
            return false;
        }

        private override Integer hashCode() {
            return (31 * sku.hashCode()) ^ qty;
        }
    }

    private static Map<String, List<String>> lineFilter(List<String> lines) {
        Account currentAcc = [SELECT ccrz__E_AccountGroup__c FROM Account WHERE Id = :ccrz.cc_CallContext.effAccountId];

        Set<Id> accountGroupPriceListIDS = new Set<Id>();
        List<String> filteredlines = new List<String>();
        String badLines = '';
        Set<String> filteredProducts = new Set<String>();
        Set<String> unfilteredProducts = new Set<String>();

        for (ccrz__E_AccountGroupPriceList__c accgpl : [SELECT ccrz__Pricelist__c FROM ccrz__E_AccountGroupPriceList__c WHERE ccrz__AccountGroup__c = :currentAcc.ccrz__E_AccountGroup__c]) {
            accountGroupPriceListIDS.add(accgpl.ccrz__Pricelist__c);
        }
        System.debug(accountGroupPriceListIDS);

        for (String singleLine : lines) {
            List<String> values = parseCSVLine(singleLine);
            unfilteredProducts.add(filterCSVInput(values[0]));
        }
        System.debug(unfilteredProducts);
        for (ccrz__E_PriceListItem__c pli : [SELECT Id,ccrz__Product__r.Name,ccrz__Product__r.ccrz__SKU__c FROM ccrz__E_PriceListItem__c WHERE ccrz__Pricelist__c IN:accountGroupPriceListIDS AND (ccrz__Product__r.Name IN:unfilteredProducts OR ccrz__Product__r.ccrz__SKU__c IN:unfilteredProducts)]) {
            filteredProducts.add(pli.ccrz__Product__r.Name);
            filteredProducts.add(pli.ccrz__Product__r.ccrz__SKU__c);
        }
        System.debug(filteredProducts);

        for (String singleLine : lines) {
            List<String> values = parseCSVLine(singleLine);
            if (filteredProducts.contains(filterCSVInput(values[0]))) {
                filteredlines.add(singleLine);
            } else {
                badLines += filterCSVInput(values[0]) + ': Invalid catalog number<br/>';
            }
        }
        System.debug(lines);
        System.debug(filteredlines);

        return new Map<String, List<String>>{
                'filteredLines' => filteredlines,
                'invalidLines' => new List<String>{badLines}
        };
    }

    public static String filterCSVInput(String s) {
        String result = s.indexOf('"') > -1 ? s.substringBetween('"') : s;
        return result.trim();
    }

    private static String formatUOM(String uom) {
        String formattedUom = '';
        for (String uomPart : uom.split(' ')) {
            formattedUom += uomPart.substring(0,1).toUpperCase() + uomPart.substring(1).toLowerCase() + ' ';
        }
        return formattedUom.trim();
    }

    public static List<String> parseCSVLine(String line) {
        List<String> result = line.split(',');
        for (Integer i = 0; i < result.size(); i++) {
            if (result.get(i).trim().startsWith('"') && !result.get(i).trim().endsWith('"')) {
                do {
                    String currentColumn = result.get(i) + ',' + result.get(i + 1);
                    result.remove(i);
                    result.add(i, currentColumn);
                    result.remove(i + 1);
                } while (!result.get(i).trim().endsWith('"'));
            }
        }
        return result;
    }

}
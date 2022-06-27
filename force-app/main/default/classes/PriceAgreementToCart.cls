public class PriceAgreementToCart {

    String REVISED = 'Revise Price Agreement';
    String priceAgreementNo;
    SAP_Price_Agreement__c priceAgreement;
    List<SAP_Price_Agreement_Item__c> priceAgreementItems;
    Account soldTo;
    List<String> skus = new List<String>();
    Map<String, Id> uomToAttrId = new Map<String, Id>();
    String url;
    String userAccount;

    public PriceAgreementToCart(String priceAgreementNo) {
        User u = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        Contact c = [SELECT AccountId FROM Contact WHERE Id = :u.ContactId];
        userAccount = c.AccountId;
        priceAgreement = [SELECT Id,Name,Bill_To_Customer_No__c, Agreement_No__c,Extended_Description__c,Fixture_Agent__c FROM SAP_Price_Agreement__c WHERE Agreement_No__c = :priceAgreementNo];
        System.debug(priceAgreement);
        if (!String.isEmpty(priceAgreement.Bill_To_Customer_No__c)) {
            try {
                soldTo = [SELECT Id FROM Account WHERE GE_LGT_EM_SAP_Customer_Number__c = :priceAgreement.Bill_To_Customer_No__c];
            } catch (Exception e) {
                System.debug(e);
            }
        }

        this.priceAgreementNo = priceAgreementNo;

        List<ccrz__E_Attribute__c> uoms = [SELECT Id, Name FROM ccrz__E_Attribute__c WHERE ccrz__ParentAttribute__r.Name = 'Unit of Measure' OR Name = 'Unit of Measure'];
        for (ccrz__E_Attribute__c uom : uoms) {
            uomToAttrId.put(uom.Name, uom.Id);
        }

        if (Test.isRunningTest()) {
            this.url = 'test.com';
        } else {
            List<Network> domain = [SELECT Id FROM Network WHERE Name = 'Current'];
            ConnectApi.Community myCommunity = ConnectApi.Communities.getCommunity(domain[0].Id);
            this.url = myCommunity.siteUrl;
        }
    }

    public String toUrl(Boolean isRevise) {
        this.priceAgreementItems = PriceAgreementServices.getItemsByAgreementNo(priceAgreementNo);

        this.url = this.url + '/ccrz__Cart?revisePA=' + priceAgreementNo + '&name=' + priceAgreement.Name + '&isRevise=' + isRevise +
                '&uom=' +((priceAgreementItems!=null && priceAgreementItems.size()>0) ? priceAgreementItems[0].UOM__c : '') +
                '&description=' + (priceAgreement.Extended_Description__c !=null ? EncodingUtil.urlEncode(priceAgreement.Extended_Description__c, 'UTF-8') : '')  + '&reload=true';
        return this.url;
    }

    public String toCart(Boolean isRevise) {
        this.priceAgreementItems = PriceAgreementServices.getItemsByAgreementNo(priceAgreementNo);
        String cartId = getActiveCart();
        this.url = this.url + '/ccrz__Cart?cartId=' + cartId + '&revisePA=' + priceAgreementNo + '&name=' + priceAgreement.Name + '&isRevise=' + isRevise +
                '&uom=' +((priceAgreementItems!=null && priceAgreementItems.size()>0) ? priceAgreementItems[0].UOM__c : '') +
                '&description=' + (priceAgreement.Extended_Description__c !=null ? EncodingUtil.urlEncode(priceAgreement.Extended_Description__c, 'UTF-8') : '');
        CartServices.changeAgreementNumber(cartId, priceAgreementNo);
        if (soldTo != null) {
            try {
                CartServices.changeSoldTo(cartId, soldTo.Id);
            } catch (Exception e) {
            }
        }
        if (isRevise) {
            CartServices.changeOrderTypeWithOrigin(cartId, REVISED, 'Modify');
            CartServices.changeAccount(cartId,priceAgreement.Fixture_Agent__c);
            CartServices.setValidDates(cartId);
        } else {
            CartServices.changeOrderTypeWithOrigin(cartId, 'Purchase Order', 'Convert');
        }

        return this.url;
    }

    public String toCart(List<String> skus) {
        this.priceAgreementItems = PriceAgreementServices.getItemsByAgreementNoAndSkus(priceAgreementNo, skus);
        String cartId = getActiveCart();
        this.url = this.url + '/ccrz__Cart?cartId=' + cartId + '&revisePA=' + priceAgreementNo + '&name=' + priceAgreement.Name +
                '&uom=' + priceAgreementItems[0].UOM__c +
                '&description=' + (priceAgreement.Extended_Description__c !=null ? EncodingUtil.urlEncode(priceAgreement.Extended_Description__c, 'UTF-8') : '');
        CartServices.changeAgreementNumber(cartId, priceAgreementNo);
        if (soldTo != null) {
            try {
                CartServices.changeSoldTo(cartId, soldTo.Id);
            } catch (Exception e) {
            }
        }
        CartServices.changeOrderType(cartId, REVISED);
        return this.url;
    }

    private String getActiveCart() {

        Map<String, Object> getCartInputData = new Map<String, Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                ccrz.ccApi.SIZING => new Map<String, Object>{
                        ccrz.ccApiCart.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccApi.SZ_REFETCH => true
                        }
                }
        };

        Map<String, Object> getCartResults;
        if (Test.isRunningTest()) {
            getCartResults = new Map<String, Object>{
                    ccrz.ccApiCart.CART_OBJLIST => new List<Object>{
                            new Map<String, Object>{
                                    'sfid' => [SELECT Id FROM ccrz__E_Cart__c WHERE ccrz__Name__c = 'testCart'][0].Id
                            }
                    }
            };
        } else {
            getCartResults = ccrz.ccApiCart.getActive(getCartInputData);
        }

        List<Object> getCartList = (List<Object>) getCartResults.get(ccrz.ccApiCart.CART_OBJLIST);
        System.debug('Cartlist '+getCartList);
        String cartId = '';

        if (getCartList != null) {
            Map<String, Object> activeCart = (Map<String, Object>) getCartList[0];
            cartId = (String) activeCart.get('sfid');
            System.debug(activeCart.get('ECartItemsS'));
            if (activeCart.get('ECartItemsS') != null) {
                String clearReturn = clearCart(cartId, (List<Map<String, Object>>) activeCart.get('ECartItemsS'));
            }
        }

        return addItems(cartId);
    }


    public String clearCart(String cartId, List<Map<String, Object>> activeCart) {

        List<ccrz.ccApiCart.LineData> cartLineData = new List<ccrz.ccApiCart.LineData>();
        ccrz.ccApiCart.LineData lineData;
        for (Map<String, Object> cartItem : activeCart) {
            lineData = new ccrz.ccApiCart.LineData();
            lineData.sfid = (Id) cartItem.get('sfid');
            cartLineData.add(lineData);
        }

        Map<String, Object> cartRemoveFromData = new Map<String, Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                ccrz.ccApiCart.CART_ID => cartId,
                ccrz.ccApiCart.LINE_DATA => cartLineData
        };

        Map<String, Object> cartRemoveFromResults = ccrz.ccApiCart.removeFrom(cartRemoveFromData);
        return((String) cartRemoveFromResults.get(ccrz.ccApiCart.CART_ENCID));
    }


    private String addItems(String cartId) {

        List<Map<String, Object>> lineData = generateLineData();
        Map<String, Object> cartItemsToAdd;

        if (cartId == '') {
            cartItemsToAdd = new Map<String, Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                    ccrz.ccApiCart.LINE_DATA => lineData
            };
        } else {
            cartItemsToAdd = new Map<String, Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                    ccrz.ccApiCart.CART_ID => cartId,
                    ccrz.ccApiCart.LINE_DATA => lineData
            };
        }
        System.debug('cartChange '+cartItemsToAdd);
        Map<String, Object> addToCartResults = ccrz.ccApiCart.addTo(cartItemsToAdd);
        System.debug('addToCartResults '+addToCartResults);
        String results = ((String) addToCartResults.get(ccrz.ccApiCart.CART_ENCID));
        System.debug('results '+results);
        return results;
    }

    private List<Map<String, Object>> generateLineData() {
        System.debug(priceAgreementItems);
        for (SAP_Price_Agreement_Item__c item : priceAgreementItems) {
            skus.add(item.Material_No__c);
        }

        List<Map<String, Object>> lineData = new List<Map<String, Object>>();
        System.debug(skus);
        List<String> attrSkus = new List<String>();
        List<String> validSkus = new List<String>();
        List<ccrz__E_Product__c> attrProds = [SELECT Id, ccrz__PrimaryAttr__r.Name, ccrz__SKU__c FROM ccrz__E_Product__c WHERE ccrz__SKU__c IN :skus AND ccrz__ProductStatus__c = 'Released' AND (ccrz__StartDate__c = null or ccrz__StartDate__c <= TODAY) AND (ccrz__EndDate__c = null or ccrz__EndDate__c >= TODAY)];
        System.debug(attrProds);
        for (ccrz__E_Product__c prod : attrProds) {
            if (prod.ccrz__PrimaryAttr__r.Name == 'Unit of Measure') {
                attrSkus.add(prod.ccrz__SKU__c);
            }
            validSkus.add(prod.ccrz__SKU__c);
        }


        Map<String, Decimal> uomToPrice;
        for (SAP_Price_Agreement_Item__c item : this.priceAgreementItems) {

            uomToPrice = new Map<String, Decimal>();

            uomToPrice.put('BX', item.Price_Per_BX__c);
            uomToPrice.put('CV', item.Price_Per_CV__c);
            uomToPrice.put('EA', item.Price_Per_EA__c);
            uomToPrice.put('ICV', item.Price_Per_ICV__c);
            uomToPrice.put('PC', item.Price_Per_PC__c);


            System.debug(uomToAttrId);
            System.debug(uomToPrice);
            if (attrSkus.contains(item.Material_No__c)) {
                //Replace uomToAttrId for loop with the following once UnitOfMeasure__c starts coming from SAP
                /*
                if(uomToPrice.get(uom) != null && uomToPrice.get(uom)!=0.0){
                        Map<String, Object> currentItem = new Map<String, Object> {
                            ccrz.ccApiCart.LINE_DATA_SKU => item.Material_No__c,
                            ccrz.ccApiCart.LINE_DATA_QUANTITY => item.Quantity__c,
                            ccrz.ccApiCart.LINE_DATA_PRICE => uomToPrice.get(item.UnitOfMeasure__c),
                            ccrz.ccApiCart.LINE_DATA_ATTRIBUTE_LIST => new List<Id>{uomToAttrId.get(item.UnitOfMeasure__c)}
                        };
                        lineData.add(currentItem);
                    }
                */
                for (String uom : uomToAttrId.keySet()) {
                    if (uomToPrice.get(uom) != null && uomToPrice.get(uom) != 0.0) {
                        Map<String, Object> currentItem = new Map<String, Object>{
                                ccrz.ccApiCart.LINE_DATA_SKU => item.Material_No__c,
                                ccrz.ccApiCart.LINE_DATA_QUANTITY => item.Quantity__c,
                                ccrz.ccApiCart.LINE_DATA_PRICE => uomToPrice.get(uom),
                                ccrz.ccApiCart.LINE_DATA_ATTRIBUTE_LIST => new List<Id>{
                                        uomToAttrId.get(uom)
                                }
                        };
                        lineData.add(currentItem);
                    }

                }
            } else if (validSkus.contains(item.Material_No__c)) {
                Map<String, Object> currentItem = new Map<String, Object>{
                        ccrz.ccApiCart.LINE_DATA_SKU => item.Material_No__c,
                        ccrz.ccApiCart.LINE_DATA_QUANTITY => item.Quantity__c,
                        ccrz.ccApiCart.LINE_DATA_PRICE => item.Sales_Price__c
                };
                lineData.add(currentItem);
            } else {
                Map<String, Object> currentItem = new Map<String, Object>{
                        ccrz.ccApiCart.LINE_DATA_SKU => 'requestedSku',
                        ccrz.ccApiCart.LINE_DATA_QUANTITY => item.Quantity__c,
                        ccrz.ccApiCart.LINE_DATA_PRICE => item.Sales_Price__c,
                        ccrz.ccApiCart.LINE_DATA_EXT_NAME => item.Item_Description__c,
                        ccrz.ccApiCart.LINE_DATA_EXT_SKU => item.Material_No__c
                };
                lineData.add(currentItem);
            }
        }
        System.debug(lineData);
        return lineData;
    }
}
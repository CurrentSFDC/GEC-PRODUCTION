public with sharing class CommunityCaseProcessLibrary {
    //Callout: COM_485_ReturnRequest
    @AuraEnabled (Cacheable=true)
    public static String getNoOfRemainingReturns(String account){
        String receivedNumber = 'test return number';
        Map<String, String> accountMap = (Map<String,String>) JSON.deserialize(account, Map<String,String>.class);

        String requestBody =
                '<?xml version="1.0" encoding="UTF-8"?>' +
                        '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
                        '<soap:Body>' +
                        '<ns0:_-GEL_-SFB2B_RETURN_REQUEST xmlns:ns0="urn:sap-com:document:sap:rfc:functions">' +
                        '<I_CUSTOMER_NUMBER>' + accountMap.get('GE_LGT_EM_SAP_Customer_Number__c') + '</I_CUSTOMER_NUMBER>' +
                        '<I_DIST_CHENNEL>' + accountMap.get('GE_LGT_EM_Distribution_Channel__c') + '</I_DIST_CHENNEL>' +
                        '<I_DIVISION>' + accountMap.get('GE_LGT_EM_Division__c') + '</I_DIVISION>' +
                        '<I_SALES_ORG>' + accountMap.get('GE_LGT_EM_Sales_Org__c') + '</I_SALES_ORG>' +
                        '</ns0:_-GEL_-SFB2B_RETURN_REQUEST>'+
                        '</soap:Body>' +
                        '</soap:Envelope>';

        HttpRequest req = new HttpRequest();
        req.setBody(requestBody);
        System.debug(req.getBody());
        req.setHeader('Content-Length', String.valueOf(req.getBody().length()));
        req.setEndpoint('callout:SAP_SOAP/XISOAPAdapter/MessageServlet?senderParty=&senderService=BC_SFB2B&receiverParty=&receiverService=&interface=SI_SFB2B_ReturnRequest_485_OB_SYNC&interfaceNamespace=urn:gecurrent.com:COM_485:ReturnRequest');
        req = pimpMyHttpRequest(req);

        try {
            HttpResponse resp = new Http().send(req);
            if (resp.getBody().contains('E_RET_REMAINING')) {
                receivedNumber = resp.getBody().substringBetween('<E_RET_REMAINING>', '</E_RET_REMAINING>').removeStart('0');
            } else {
                receivedNumber = 'No Data';
            }
        } catch (Exception e){
            receivedNumber = 'No Data (Callout Error)';
        }

        return receivedNumber;
    }

    //Callout: COM 475_AgreementPrice
    @AuraEnabled (Cacheable=true)
    public static List<Object> getAgreedProductPrices(List<Object> productList, String soldToAccount, String currentUserAccountId){
        PriceAgreementController.PriceAgreementRequest req = new PriceAgreementController.PriceAgreementRequest();
        Map<String, String> accountMap = (Map<String,String>) JSON.deserialize(soldToAccount, Map<String,String>.class);
        Account currentUserAcc = [SELECT Account_group__c, GE_LGT_Rep_Code__c FROM Account WHERE Id = :currentUserAccountId];

        req.agrDate = String.valueOf(System.today());
        req.distChannel = accountMap.get('GE_LGT_EM_Distribution_Channel__c');
        req.division = accountMap.get('GE_LGT_EM_Division__c');
        req.extAgent = currentUserAcc.Account_group__c == 'ZEAG' ? currentUserAcc.GE_LGT_Rep_Code__c : '';
        req.salesOrg = accountMap.get('GE_LGT_EM_Sales_Org__c');
        req.soldTo = accountMap.get('GE_LGT_EM_SAP_Customer_Number__c');
        req.userType = getUserType(currentUserAcc);
        req.priceAgreementItemList = getItemList(productList);

        if (!Test.isRunningTest()) {
            return handleCom475Response(new SAPGateway().priceAgreementValidate(req));
        } else {
            return new List<Object>{'Tested'};
        }
    }

    @TestVisible
    private static List<Object> handleCom475Response(PriceAgreementController.PriceAgreementResponse resp){
        List<Object> returnProductList = new List<Object>();

        Map<String, Object> wrappedGeneralMessage = new Map<String, Object>();
        wrappedGeneralMessage.put('lineNumber', '000000');
        wrappedGeneralMessage.put('ErrorMessage', resp.errMessage);
        returnProductList.add(wrappedGeneralMessage);

        for (PriceAgreementController.PriceAgreementItem item : resp.priceAgreementItemList){
            Map<String, Object> wrappedProduct = new Map<String, Object>();
            wrappedProduct.put('productNumber', item.material);
            wrappedProduct.put('currency', item.currencyISOCode);

            String stringLineNo = '';
            for (Integer i = 0; i<6-String.valueOf(item.lineNumber).length(); i++){
                stringLineNo += '0';
            }
            stringLineNo += String.valueOf(item.lineNumber);
            wrappedProduct.put('lineNumber', stringLineNo);

            wrappedProduct.put('returnQuantity', String.valueOf(item.quantity));
            String lineMessage = item.message != null ? item.message : '';
            if (item.lineComments != null) {
                linemessage += lineMessage != '' ? ' - ' + item.lineComments : item.lineComments;
            }
            wrappedProduct.put('validationComment', lineMessage);
            wrappedProduct.put('status', item.message);
            wrappedProduct.put('transactionId', Datetime.now().millisecond());
            Decimal price = item.priceAgreementValue > 0 ? item.priceAgreementValue : item.bookPrice;
            wrappedProduct.put('price', String.valueOf(price));
            wrappedProduct.put('totalPrice', String.valueOf(price * item.quantity) + ' ' + item.currencyISOCode);
            returnProductList.add(wrappedProduct);
        }
        return returnProductList;
    }

    private static List<PriceAgreementController.PriceAgreementItem> getItemList(List<Object> productList){
        List<PriceAgreementController.PriceAgreementItem> priceAgreementList = new List<PriceAgreementController.PriceAgreementItem>();

        for (Object product : productList){
            Map<String, String> productMap = (Map<String,String>) JSON.deserialize((String) product, Map<String,String>.class);
            PriceAgreementController.PriceAgreementItem pai = new PriceAgreementController.PriceAgreementItem();
            pai.lineNumber = Integer.valueOf(productMap.get('lineNo'));
            pai.material = productMap.get('itemNo');
            pai.description = productMap.get('itemDesc');
            pai.quantity = Integer.valueOf(productMap.get('qty'));
            pai.UOM = productMap.get('uom');
            priceAgreementList.add(pai);
        }

        return priceAgreementList;
    }

    private static HttpRequest pimpMyHttpRequest(HttpRequest req){
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setHeader('Content-Type','text/xml;charset=utf-8');
        req.setHeader('Accept-Encoding','gzip,deflate');
        req.setHeader('Content-Length', String.valueOf(req.getBody().length()));
        return req;
    }

    private static String getUserType(Account account){
        if (UserInfo.getUserType() == 'Standard') {
            return 'GEInternal';
        }
        switch on account.Account_group__c {
            when 'ZEAG' {return 'Agent';}
            when 'Z001' {return 'Customer';}
        }
        return '';
    }

    @AuraEnabled (Cacheable=true)
    public static List<Object> getProductListFromFile(Id idContentDocument){
        List<Object> wrappedProductList = new List<Object>();
        if(idContentDocument == null) {return new List<Object>();}
        ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument];

        Set<String> productNumbers = new Set<String>();
        for (String line : objVersion.VersionData.toString().split('\n')){
            System.debug('nilike'+line);
            productNumbers.add(line.split(',')[6]);
        }

        Map<String, GE_LGT_EM_MaterialMaster__c> materialByMatNumber = new Map<String, GE_LGT_EM_MaterialMaster__c>();
        for (GE_LGT_EM_MaterialMaster__c material : [
                SELECT Id,Name,GE_LGT_EM_SAP_MaterialNumber__c,GE_LGT_EM_MaterialDescription__c
                FROM GE_LGT_EM_MaterialMaster__c
                WHERE GE_LGT_EM_SAP_MaterialNumber__c IN :productNumbers]){
            materialByMatNumber.put(material.GE_LGT_EM_SAP_MaterialNumber__c, material);
        }

        for(String line : objVersion.VersionData.toString().split('\n')){
            List<String> csvRowData = line.split(',');
            Map<String, Object> wrappedProduct = new Map<String, Object>();
            String matNumber = csvRowData[6];
            if (materialByMatNumber.containsKey(matNumber)) {
                GE_LGT_EM_MaterialMaster__c mat = materialByMatNumber.get(matNumber);
                wrappedProduct.put('materialMaster', mat);
                wrappedProduct.put('materialName', mat.GE_LGT_EM_SAP_MaterialNumber__c + ' - ' + mat.GE_LGT_EM_MaterialDescription__c);
                wrappedProduct.put('validationComment', '');
            } else {
                wrappedProduct.put('materialMaster', new Map<String,Object>{'GE_LGT_EM_SAP_MaterialNumber__c' => csvRowData[6], 'GE_LGT_EM_MaterialDescription__c' => 'Unidentified product'});
                wrappedProduct.put('validationComment', 'Please select a valid product');
            }
            wrappedProduct.put('lineNumber', '');
            wrappedProduct.put('returnQuantity', csvRowData[7]);
            List<Map<String, Object>> uomOptions = ComboboxOptionBuilder.buildOptions(new List<String>{csvRowData[8]});

            wrappedProduct.put('uomOptions', uomOptions);
            wrappedProduct.put('uom', String.valueOf(uomOptions[0].get('value')));
            wrappedProduct.put('uomLabel', String.valueOf(uomOptions[0].get('label')));
            wrappedProduct.put('totalPrice', '');

            Integer lineNo = wrappedProductList.size()+1;
            String stringLineNo = '';
            for (Integer i = 0; i<5-String.valueOf(lineNo).length(); i++){
                stringLineNo += '0';
            }
            stringLineNo += String.valueOf(lineNo) + '0';
            wrappedProduct.put('lineNumber', stringLineNo);

            wrappedProductList.add(wrappedProduct);
        }

        return wrappedProductList;
    }

    @AuraEnabled
    public static String connectCreateReturnCase(Case newCase){
        newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('North America').getRecordTypeId();
        insert newCase;
        return newCase.Id;
    }

    @AuraEnabled
    public static List<String> getProductFamilies(Id soldToAccId, Id agentAccId){
        Set<String> returnProdFamilies = new Set<String>();

        List<Set<String>> prodFamiliesList = new List<Set<String>>();
        for (CustomerProductFamily__c family : [SELECT ProductFamily1__c,ProductFamily2__c,ProductFamily3__c,
                ProductFamily4__c,ProductFamily5__c,ProductFamily6__c,ProductFamily7__c,ProductFamily8__c,
                ProductFamily9__c,ProductFamily10__c,ProductFamily11__c,ProductFamily12__c,ProductFamily13__c,
                ProductFamily14__c,ProductFamily15__c,ProductFamily16__c,ProductFamily17__c,ProductFamily18__c,
                ProductFamily19__c,ProductFamily20__c
        FROM CustomerProductFamily__c
        WHERE SAPCustomerNumber__c = :soldToAccId OR SAPCustomerNumber__c = :agentAccId]){
            Set<String> prodFamilies = new Set<String>();
            for (String fieldName : family.getPopulatedFieldsAsMap().keySet()){
                if (fieldName.startsWith('ProductFamily')
                        && family.get(fieldName) != null) {
                    prodFamilies.add((String) family.get(fieldName));
                }
            }
            prodFamiliesList.add(prodFamilies);
        }

        if (prodFamiliesList.size()<2) {return new List<String>();}

        for (String family : prodFamiliesList[0]){
            if (prodFamiliesList[1].contains(family)) {
                returnProdFamilies.add(family);
            }
        }

        System.debug(returnProdFamilies);
        return new List<String>(returnProdFamilies);
    }
}
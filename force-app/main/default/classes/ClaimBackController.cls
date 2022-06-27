public with sharing class ClaimBackController {
    
    @AuraEnabled
    public static List<Object> getPriceAgreements(String agentId) {
        system.debug('agentId '+agentId);

        List<SAP_Price_Agreement__c> paList = new List<SAP_Price_Agreement__c>();
        for(SAP_Price_Agreement__c sapPriceAgreement : [
                SELECT
                        Id,
                        Agreement_No__c,
                        Customer_List__c

                FROM SAP_Price_Agreement__c
                WHERE Agreement_Type__c = 'ZCLB'
                AND Valid_From__c <= TODAY
                AND Expiration_Date__c >= TODAY
                ORDER BY Expiration_Date__c
                        DESC
                //LIMIT 5
        ]){
            if (String.isNotBlank(sapPriceAgreement.Customer_List__c)) {
                List<String> customerNumbers = sapPriceAgreement.Customer_List__c.split(',');
                if (customerNumbers.contains(agentId)) {
                    paList.add(sapPriceAgreement);

                }
            }
        }

        return paList;

        //return [SELECT Agreement_No__c FROM SAP_Price_Agreement__c WHERE Agreement_Type__c = 'ZCLB' AND Customer_List__c LIKE: customerNumber  AND Valid_From__c <= TODAY AND Expiration_Date__c >= TODAY];
    }

    @AuraEnabled
    public static List<Map<String, Object>> processInvoiceFile(String contentDocumentId, String paNumbers){
        try {
            List<Map<String, Object>> returnData = new List<Map<String, Object>>();

            ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId LIMIT 1];
            System.debug(cv.VersionData);
            Map<String, Map<String, Object>> invoiceData = new Map<String, Map<String, Object>>();
            List<String> invoiceDataFromFile = cv.VersionData.toString().remove('\\r').split('\\n');
            invoiceDataFromFile.remove(0);
            System.debug(invoiceDataFromFile);
            Map<String, GE_LGT_EM_MaterialMaster__c> materialMastersByName = getMaterials(invoiceDataFromFile);
            Integer currentInvoiceId = 1;
            Boolean inInvoiceProcessMode = true;
            List<String> paNumbersList = paNumbers.split('-');
            for(Integer i = 0; i < invoiceDataFromFile.size(); i++) {
                if (invoiceDataFromFile.get(i).isWhitespace()) {
                    continue;
                }
                List<String> rowData = ccCSVUploadController.parseCSVLine(invoiceDataFromFile.get(i));
                if (ccCSVUploadController.filterCSVInput(rowData[0]).isWhitespace()) {
                    throw new TypeException((inInvoiceProcessMode ? 'Catalog Number' : 'End Customer Account Number') + 'is empty in line ' + (i + 1));
                }
                if (inInvoiceProcessMode) {
                    if (ccCSVUploadController.filterCSVInput(rowData[0]) != 'Catalog Number/SKU') {
                        invoiceData.put(String.valueOf(i + 1), getNewInvoiceData(rowData, i + 1));
                    } else {
                        inInvoiceProcessMode = false;
                    }
                } else {
                    if (ccCSVUploadController.filterCSVInput(rowData[0]) != 'Catalog Number/SKU') {
                        //String qty = Integer.valueOf(ccCSVUploadController.filterCSVInput(rowData[1])) > 0 ? ccCSVUploadController.filterCSVInput(rowData[1]) : '1';
                        String qty = ccCSVUploadController.filterCSVInput(rowData[1]);
                        String paNumber = ccCSVUploadController.filterCSVInput(rowData[2]);
                        String gecPrice = ccCSVUploadController.filterCSVInput(rowData[3]);
                        String paPrice = ccCSVUploadController.filterCSVInput(rowData[4]);
                        String creditPerUnit = String.valueOf((Decimal.valueOf(ccCSVUploadController.filterCSVInput(rowData[3])) - Decimal.valueOf(ccCSVUploadController.filterCSVInput(rowData[4]))) * Integer.valueOf(qty));
                        if (!gecPrice.contains('.')) {
                            gecPrice = gecPrice + '.';
                        }
                        if (!paPrice.contains('.')) {
                            paPrice = paPrice + '.';
                        }
                        if (!creditPerUnit.contains('.')) {
                            creditPerUnit = creditPerUnit + '.';
                        }
                        while (gecPrice.indexOf('.') > gecPrice.length() - 3) {
                            gecPrice = gecPrice + '0';
                        }
                        while (paPrice.indexOf('.') > paPrice.length() - 3) {
                            paPrice = paPrice + '0';
                        }
                        while (creditPerUnit.indexOf('.') > creditPerUnit.length() - 3) {
                            creditPerUnit = creditPerUnit + '0';
                        }
                        while (paNumber.length() < 10) {
                            paNumber = '0' + paNumber;
                        }
                        if (materialMastersByName.containsKey(ccCSVUploadController.filterCSVInput(rowData[0]))) {
                            Map<String, Object> currentProduct = new Map<String, Object>{
                                    'productId' => String.valueOf(((List<Map<String, Object>>) invoiceData.get(String.valueOf(currentInvoiceId)).get('products')).size() + 1),
                                    'materialMaster' => materialMastersByName.get(ccCSVUploadController.filterCSVInput(rowData[0])),
                                    'materialName' => materialMastersByName.get(ccCSVUploadController.filterCSVInput(rowData[0])).GE_LGT_EM_SAP_MaterialNumber__c + ' - ' + materialMastersByName.get(ccCSVUploadController.filterCSVInput(rowData[0])).GE_LGT_EM_MaterialDescription__c,
                                    'quantity' => qty,
                                    'gecPrice' => gecPrice,
                                    'priceAgreementNumber' => paNumbersList.contains(paNumber) ? paNumber : 'badPaNo',
                                    'priceAgreementPrice' => paPrice,
                                    'creditPerUnit' => creditPerUnit,
                                    'qtyPerUnit' => 1,
                                    'currencyIsoCode' => materialMastersByName.get(ccCSVUploadController.filterCSVInput(rowData[0])).CurrencyIsoCode != null ? materialMastersByName.get(ccCSVUploadController.filterCSVInput(rowData[0])).CurrencyIsoCode : 'USD',
                                    'validationWarning' => paNumbersList.contains(paNumber) ? '' : '<span style="font-family:wingdings; color:red; font-size:28px;">û</span>'
                            };
                            ((List<Map<String, Object>>) invoiceData.get(String.valueOf(currentInvoiceId)).get('products')).add(currentProduct);
                        } else {
                            Map<String, Object> currentProduct = new Map<String, Object>{
                                    'productId' => String.valueOf(((List<Map<String, Object>>) invoiceData.get(String.valueOf(currentInvoiceId)).get('products')).size() + 1),
                                    'materialMaster' => new GE_LGT_EM_MaterialMaster__c(
                                            GE_LGT_EM_MaterialDescription__c = 'Invalid Catalog Number: ' + ccCSVUploadController.filterCSVInput(rowData[0])
                                    ),
                                    'materialName' => 'Invalid Catalog Number: ' + ccCSVUploadController.filterCSVInput(rowData[0]),
                                    'quantity' => qty,
                                    'gecPrice' => gecPrice,
                                    'priceAgreementNumber' => paNumbersList.contains(paNumber) ? paNumber : 'badPaNo',
                                    'priceAgreementPrice' => paPrice,
                                    'creditPerUnit' => creditPerUnit,
                                    'qtyPerUnit' => 1,
                                    'currencyIsoCode' =>  'USD',
                                    'validationWarning' => '<span style="font-family:wingdings; color:red; font-size:28px;">û</span>'
                            };
                            ((List<Map<String, Object>>) invoiceData.get(String.valueOf(currentInvoiceId)).get('products')).add(currentProduct);
                        }
                    } else {
                        currentInvoiceId++;
                    }
                }
/*                Map<String, Object> currentInvoiceData;
                List<String> rowData = invoiceDataFromFile[i].split(',');
                System.debug(rowData);
                if(invoiceData.containsKey(rowData[6])){
                    currentInvoiceData = invoiceData.get(rowData[6]);
                }
                else{
                    currentInvoiceData = getNewInvoiceData(rowData, nextInvoiceId);
                    returnData.add(currentInvoiceData);
                    invoiceData.put(rowData[6], currentInvoiceData);
                    nextInvoiceId += 1;
                }

                if(String.isNotBlank(rowData[11]) && materialMastersByName.containsKey(rowData[11])){
                    Decimal quantity = Decimal.valueOf(rowData[14]);
                    Decimal gecPrice = Decimal.valueOf(rowData[16]);
                    Decimal priceAgreementPrice = Decimal.valueOf(rowData[17]);

                    Map<String, Object> currentProduct = new Map<String, Object>{
                        'productId' => String.valueOf(((List<Map<String, Object>>)currentInvoiceData.get('products')).size() + 1),
                        'materialMaster' => materialMastersByName.get(rowData[11]),
                        'materialName' => materialMastersByName.get(rowData[11]).GE_LGT_EM_SAP_MaterialNumber__c + ' - ' + materialMastersByName.get(rowData[11]).GE_LGT_EM_MaterialDescription__c,
                        'quantity' => quantity,
                        'gecPrice' => gecPrice,
                        'priceAgreementNumber' => rowData[10],
                        'priceAgreementPrice' => priceAgreementPrice,
                        'creditPerUnit' => String.valueOf((gecPrice - priceAgreementPrice) * quantity)
                    };
                    ((List<Map<String, Object>>)currentInvoiceData.get('products')).add(currentProduct);
                }*/
            }

            ContentDocument cd = [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId];
            delete cd;

            for (String invoice : invoiceData.keySet()) {
                returnData.add(invoiceData.get(invoice));
            }

            return returnData;
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String sendClaimToSAP(Map<String, Object> invoiceData){
        system.debug('invoiceData '+JSON.serializePretty(invoiceData));
        Set<Id> accountIds = invoiceData.get('soldToAccountId') != '' ? new Set<Id>{(Id)invoiceData.get('accountID'), (Id)invoiceData.get('soldToAccountId')} : new Set<Id>{(Id)invoiceData.get('accountID')};
        Account mainAccount;
        Account soldToAccount;
        for(Account acc : [
            SELECT Id, 
                Name,
                GE_LGT_EM_Distribution_Channel__c, 
                GE_LGT_EM_Division__c, 
                GE_LGT_EM_SAP_Customer_Number__c,
                GE_LGT_Sales_Group__c,
                GE_LGT_EM_Sales_Org__c
            FROM Account
            WHERE Id IN :accountIds
        ]){
            if(acc.Id == (Id)(invoiceData.get('accountID'))){
                mainAccount = acc;
            }
            else{
                soldToAccount = acc;
            }
        }
//        System.debug(mainAccount);
//        System.debug(soldToAccount);
//        System.debug(JSON.serializePretty(invoiceData));
//        System.debug(invoiceData.get('invoices'));
//        System.debug(invoiceData.get('products'));

        List<Object> objectList = (List<Object>)invoiceData.get('invoices');
        List<Map<String,Object>> invoices = new List<Map<String, Object>>();
        for (Object obj : objectList) {
            Map<Object, Object> objectMap = (Map<Object, Object>)obj;
            Map<String, Object> invoiceMap = new Map<String, Object>();
            for (Object key : objectMap.keySet()) {
                invoiceMap.put((String)key, objectMap.get(key));
            }
            invoices.add(invoiceMap);
        }
//        List<Map<String,Object>> invoices = (List<Map<String,Object>>)invoiceData.get('invoices');
        system.debug('invoices '+JSON.serializePretty(invoices));

        ClaimBackController.ClaimBackHeader headerInfo = new ClaimBackController.ClaimBackHeader();
        headerInfo.billingDate = formatDate(System.today(), '');
        headerInfo.claimSubmittedBy = (mainAccount!=null ? mainAccount.GE_LGT_EM_SAP_Customer_Number__c : soldToAccount.GE_LGT_EM_SAP_Customer_Number__c);
        headerInfo.soldToNumber = (soldToAccount!=null ? soldToAccount.GE_LGT_EM_SAP_Customer_Number__c : mainAccount.GE_LGT_EM_SAP_Customer_Number__c);
        headerInfo.referenceNumber = (String)invoiceData.get('returnRefNumber');
        headerInfo.accountCurrency = (String)invoiceData.get('currency');
        headerInfo.salesOrg = (soldToAccount!=null ? soldToAccount.GE_LGT_EM_Sales_Org__c : mainAccount.GE_LGT_EM_Sales_Org__c);
        headerInfo.distributionChannel = (soldToAccount!=null ? soldToAccount.GE_LGT_EM_Distribution_Channel__c : mainAccount.GE_LGT_EM_Distribution_Channel__c);
        headerInfo.division = (soldToAccount!=null ? soldToAccount.GE_LGT_EM_Division__c : mainAccount.GE_LGT_EM_Division__c);
        headerInfo.jobName = (String)invoices[0].get('jobName');
        headerInfo.agentCode = mainAccount.GE_LGT_EM_SAP_Customer_Number__c;
        
        List<ClaimBackController.ClaimBackItem> claimBackItems = new List<ClaimBackController.ClaimBackItem>();       
        Decimal totalReturnAmount = 0;
        Integer itemNumber = 1;
        for(Object i : invoices){
            Map<String, Object> currentInvoice = (Map<String, Object>)i;

            List<Object> pobjectList = (List<Object>)currentInvoice.get('products');
            List<Map<String,Object>> products = new List<Map<String, Object>>();
            for (Object obj : pobjectList) {
                Map<Object, Object> objectMap = (Map<Object, Object>)obj;
                Map<String, Object> productMap = new Map<String, Object>();
                for (Object key : objectMap.keySet()) {
                    productMap.put((String)key, objectMap.get(key));
                }
                products.add(productMap);
            }

//            List<Map<String,Object>> products = (List<Map<String,Object>>)currentInvoice.get('products');
            for(Map<String,Object> prod : products){
                totalReturnAmount += Decimal.valueOf((String)(prod.get('creditPerUnit')));
                ClaimBackController.ClaimBackItem claimBackItem = new ClaimBackController.ClaimBackItem();
                claimBackItem.lineNumber = itemNumber + '0';
                itemNumber += 1;
                claimBackItem.invoiceNumber = (String)currentInvoice.get('invoiceId') + '0';
                claimBackItem.quantity = (String)prod.get('quantity');
                claimBackItem.invoiceDate = (String)currentInvoice.get('invoiceDate');
                claimBackItem.invoiceDate = claimBackItem.invoiceDate.replace('.','').replace('-','');
                claimBackItem.priceAgreementNumber = (String)prod.get('priceAgreementNumber');
                claimBackItem.endCustomerNumber = (String)currentInvoice.get('endCustomerAccountNum');
                Map<Object, Object> ecaniObjMap = (Map<Object, Object>)currentInvoice.get('endCustomerAccountNumInfo');
                Map<String, Object> ecaniStringMap = new Map<String, Object>();
                for (Object key : ecaniObjMap.keySet()) {
                    ecaniStringMap.put((String)key, ecaniObjMap.get(key));
                }
                claimBackItem.endCustomerName = (String)(ecaniStringMap.get('ecaname'));
                claimBackItem.shippingType = (String)currentInvoice.get('shipmentType') == 'regular' ? 'S' : 'D';
                claimBackItem.GEInvoiceNumber = (String)currentInvoice.get('gecInvoice');
                Map<Object, Object> materialMasterObjMap = (Map<Object, Object>)prod.get('materialMaster');
                Map<String, Object> materialMasterStringMap = new Map<String, Object>();
                for (Object key : materialMasterObjMap.keySet()) {
                    materialMasterStringMap.put((String)key, materialMasterObjMap.get(key));
                }
                claimBackItem.materialNumber = (String)materialMasterStringMap.get('GE_LGT_EM_SAP_MaterialNumber__c');
//                claimBackItem.materialNumber = ((GE_LGT_EM_MaterialMaster__c)prod.get('materialMaster')).GE_LGT_EM_SAP_MaterialNumber__c;
                claimBackItem.endCustomerInvoiceNumber = (String)currentInvoice.get('invoiceNumber');
                claimBackItem.accountType = 'AG'; //TODO create for Agents as well.
                claimBackItem.requestedCreditPerUnit = String.valueOf(Decimal.valueOf((String)(prod.get('gecPrice'))) - Decimal.valueOf((String)(prod.get('priceAgreementPrice'))));
                claimBackItem.replacementPricePerUnit = (String)prod.get('gecPrice');
                claimBackItem.priceAgreementPricePerUnit = (String)prod.get('priceAgreementPrice');
                claimBackItem.requestedCredit = (String)prod.get('creditPerUnit'); //Due to modifications, the creditPerUnit stores the creditAmount (per unit * quantity)
                claimBackItems.add(claimBackItem);
            }
        }
        headerInfo.totalReturnAmount = totalReturnAmount + '';

        SAPGateway gateway = new SAPGateway();
        System.debug(headerInfo);
        System.debug(claimBackItems);
        ClaimBackController.ClaimBackCreateResponse response = gateway.sendClaimBackToSap(headerInfo, claimBackItems);
        System.debug(response);

        return response.returnValue;
    }

    private static Map<String, Object> getNewInvoiceData(List<String> rowData, Integer nextInvoiceId){
        List<String> dateInput = ccCSVUploadController.filterCSVInput(rowData[3]).split('/');
        if (dateInput.size() != 3 || dateInput[2].length() != 4 || dateInput[0].length() > 2 || dateInput[0].length() == 0 || dateInput[1].length() > 2 || dateInput[1].length() == 0) {
            throw new TypeException('Date format is invalid in line ' + (nextInvoiceId + 1) + ', please use MM/DD/YYYY format.');
        }
        String dateFormatted = dateInput[2] + '-' + (dateInput[0].length() < 2 ? '0' + dateInput[0] : dateInput[0]) + '-' + (dateInput[1].length() < 2 ? '0' + dateInput[1] : dateInput[1]);
        if (ccCSVUploadController.filterCSVInput(rowData[4]).toLowerCase() != 'regular' && ccCSVUploadController.filterCSVInput(rowData[4]).toLowerCase() != 'drop ship' && ccCSVUploadController.filterCSVInput(rowData[4]).toLowerCase() != 'dropship') {
            throw new TypeException('Shipment type is invalid in line ' + (nextInvoiceId + 1) + ', must be either Regular or Drop Ship.');
        }
        return new Map<String, Object>{
            'invoiceId' => String.valueOf(nextInvoiceId),
            'endCustomerAccountNumDomId' => 'eca' + nextInvoiceId,
            'gecInvoiceNumRequired' => false,
            'invoiceNumber' => ccCSVUploadController.filterCSVInput(rowData[2]),
            'invoiceDate' => dateFormatted,
            'shipmentType' => (ccCSVUploadController.filterCSVInput(rowData[4]).toLowerCase() == 'regular' ? 'regular' : 'dropship'),
            'shipmentTypeLabel' => (ccCSVUploadController.filterCSVInput(rowData[4]).toLowerCase() == 'regular' ? 'Regular' : 'Drop Ship'),
            'gecInvoiceNumRequired' => (ccCSVUploadController.filterCSVInput(rowData[4]).toLowerCase() != 'regular'),
            'gecInvoice' => ccCSVUploadController.filterCSVInput(rowData[5]),
            'jobName' => ccCSVUploadController.filterCSVInput(rowData[6]),
            'creditRequestReferenceNum' => '',
            'endCustomerAccountNum' => ccCSVUploadController.filterCSVInput(rowData[0]) + '--' + ccCSVUploadController.filterCSVInput(rowData[1]) + '--',
            'endCustomerAccountNumInfo' => new Map<String, Object>{
                'ecaAccountNumber' => ccCSVUploadController.filterCSVInput(rowData[0]),
                'ecaname' => ccCSVUploadController.filterCSVInput(rowData[1]),
                'ecaAddress1' => '',
                'ecaAddress2' => '',
                'ecaPostalCode' => '',
                'ecaCity' => '',
                'ecaCountry' => '',
                'ecaState' => ''
            },
            'products' => new List<Map<String, Object>>()
        };
    }

    private static Map<String, GE_LGT_EM_MaterialMaster__c> getMaterials(List<String> invoiceData){
        Set<String> materialNames = new Set<String>();
        for(Integer i = 0; i < invoiceData.size(); i++){
            List<String> rowData = invoiceData[i].split(',');
            if(String.isNotBlank(ccCSVUploadController.filterCSVInput(rowData[0]))) materialNames.add(ccCSVUploadController.filterCSVInput(rowData[0]));
        }
        System.debug(materialNames);

        Map<String, GE_LGT_EM_MaterialMaster__c> materialMastersByName = new Map<String, GE_LGT_EM_MaterialMaster__c>();
        if(!materialNames.isEmpty()){
            System.debug('mattttt'+materialNames);
            for(GE_LGT_EM_MaterialMaster__c materialMaster : [
                SELECT Id, Name, GE_LGT_EM_SAP_MaterialNumber__c, GE_LGT_EM_MaterialDescription__c, Quantity_per_Unit__c, CurrencyIsoCode
                FROM GE_LGT_EM_MaterialMaster__c
                WHERE GE_LGT_EM_MaterialDescription__c IN :materialNames
                OR GE_LGT_EM_SAP_MaterialNumber__c IN :materialNames]
            ){
                materialMastersByName.put(materialMaster.GE_LGT_EM_MaterialDescription__c, materialMaster);
                materialMastersByName.put(materialMaster.GE_LGT_EM_SAP_MaterialNumber__c, materialMaster);
            }
        }

        return materialMastersByName;
    }

    private static String formatDate(Date dateToFormat, String separator){
        String returnString = dateToFormat.year() + separator;
        if(dateToFormat.month() < 10) returnString += '0';
        returnString += dateToFormat.month() + separator;
        if(dateToFormat.day() < 10) returnString += '0';
        returnString += dateToFormat.day();
        return returnString;
    }

    public class ClaimBackHeader{
        public String billingDate;
        public String claimSubmittedBy;
        public String soldToNumber;
        public String referenceNumber;
        public String totalReturnAmount;
        public String accountCurrency;
        public String salesOrg;
        public String distributionChannel;
        public String division;
        public String jobName;
        public String agentCode;
    }

    public class ClaimBackItem{
        public String lineNumber;
        public String invoiceNumber;
        public String quantity;
        public String invoiceDate;
        public String priceAgreementNumber;
        public String endCustomerNumber;
        public String endCustomerName;
        public String shippingType;
        public String GEInvoiceNumber;
        public String materialNumber;
        public String endCustomerInvoiceNumber;
        public String accountType;
        public String requestedCreditPerUnit;
        public String replacementPricePerUnit;
        public String priceAgreementPricePerUnit;
        public String requestedCredit;
    }

    public class ClaimBackCreateResponse{
        public String returnValue;
    }
}
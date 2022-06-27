/**
 * Created by PA on 2021. 04. 28..
 */

@IsTest
private class StockBalancingReturnLwcControllerTest {
    @IsTest
    static void getNoOfRemainingReturns() {
        Map<String, String> newAccount = new Map<String, String>
            {'GE_LGT_EM_SAP_Customer_Number__c' => 'test',
            'GE_LGT_EM_Distribution_Channel__c' => 'test',
            'GE_LGT_EM_Division__c' => 'test',
            'GE_LGT_EM_Sales_Org__c' => 'test'
            };
        string jsonAccount = JSON.serialize(newAccount);
        System.assertEquals('No Data (Callout Error)', StockBalancingReturnLwcController.getNoOfRemainingReturns(jsonAccount));

    }
    @IsTest
    static void getAgreedProductPrices() {
        Map<String,String> soldToAccountMap = new Map<String, String>{
                'GE_LGT_EM_Distribution_Channel__c' => 'Test',
                'GE_LGT_EM_Division__c' => 'Test',
                'GE_LGT_EM_Sales_Org__c' => 'Test',
                'GE_LGT_EM_SAP_Customer_Number__c' => 'Test'
        };
        String soldToAccountJson = JSON.serialize(soldToAccountMap);

        Account currentUserAcc = new Account(Name = 'Test');
        insert currentUserAcc;

        List<Object> productsJson = new List<Object>();
        Map<String,String> productMap = new Map<String, String>{
                'lineNo' => '000010',
                'itemNo' => '0000001',
                'itemDesc' => 'test1',
                'qty' => '10',
                'uom' => 'BX'
        };
        productsJson.add(JSON.serialize(productMap));

        System.assertEquals('Tested', (String) StockBalancingReturnLwcController.getAgreedProductPrices(productsJson , soldToAccountJson, currentUserAcc.Id)[0]);
    }

    @IsTest
        static void handleCom475Response(){

        PriceAgreementController.PriceAgreementItem newItem = new PriceAgreementController.PriceAgreementItem();
        newItem.lineNumber = 10;
        newItem.material = 'test';
        newItem.currencyISOCode = 'USD';
        newItem.message = 'test';
        newItem.quantity = 10;
        newItem.lineComments = 'test';
        newItem.priceAgreementValue = 0;
        newItem.bookPrice = 1;

        PriceAgreementController.PriceAgreementResponse resp = new PriceAgreementController.PriceAgreementResponse();
        resp.errMessage = 'TestError';
        resp.priceAgreementItemList = new List<PriceAgreementController.PriceAgreementItem>{newItem};

        Map<String,Object> returnError =  (Map<String,Object>) StockBalancingReturnLwcController.handleCom475Response(resp)[0];
        System.equals('TestError', (String) returnError.get('ErrorMessage'));

        Map <String,Object> returnProduct = (Map<String,Object>) StockBalancingReturnLwcController.handleCom475Response(resp)[1];
        System.equals('000010', (String) returnProduct.get('lineNumber'));
    }

    @IsTest
    static void getProductListFromFile() {
        String csvContent = 'Product No.,Quantity,UOM,Agent Code\n' +
                    '93029237,7,Piece,H4A';

        GE_LGT_EM_MaterialMaster__c newMat = new GE_LGT_EM_MaterialMaster__c(GE_LGT_EM_SAP_MaterialNumber__c = '98765', GE_LGT_EM_MaterialDescription__c = 'test');
        insert newMat;

        ContentVersion ContVerFile = new ContentVersion();
        ContVerFile.VersionData = Blob.valueOf(csvContent);
        ContVerFile.Title = 'TestCsv';
        ContVerFile.ContentLocation= 's';
        ContVerFile.PathOnClient='testCsv.csv';
        insert ContVerFile;

        Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :ContVerFile.Id].ContentDocumentId;

        System.debug(StockBalancingReturnLwcController.getProductListFromFile(contentDocId));

    }

//    @IsTest
//    static void createCaseProduct() {
//        Case c = new Case();
//        insert c;
//
//        StockBalancingReturnLwcController.createCaseProduct(new List<Shipment_Detail__c>{new Shipment_Detail__c(GE_NAS_Case_Number__c = c.Id)});
//        System.assertEquals(1, [SELECT count() FROM Shipment_Detail__c]);
//    }

    @IsTest
    static void connectCreateReturnCase() {
        System.assertNotEquals(null, StockBalancingReturnLwcController.connectCreateReturnCase(new Case()));
    }

    @IsTest
    static void getCaseNumber() {
        Case c = new Case();
        insert c;
        System.assertNotEquals(null, StockBalancingReturnLwcController.getCaseNumber(c.Id));
    }

    @IsTest
    static void getAccountName() {
        Account acc = new Account(Name = 'test');
        insert acc;
        System.assertEquals(acc.Name, StockBalancingReturnLwcController.getAccountName(acc.Id));
    }
    @IsTest
    static void getProductFamilies(){
        Account a1 = new Account(Name = 'Test1',
                GE_LGT_EM_Sales_Org__c = '10HU',
                GE_LGT_EM_Distribution_Channel__c = '20',
                GE_LGT_EM_Division__c = '10',
                GE_LGT_EM_SAP_Customer_Number__c = 'TestCustN1');
        insert a1;

        CustomerProductFamily__c c1 = new CustomerProductFamily__c(
                Name = a1.Name,
                SalesOrganization__c = a1.GE_LGT_EM_Sales_Org__c,
                DistributionChannel__c = a1.GE_LGT_EM_Distribution_Channel__c,
                Division__c = a1.GE_LGT_EM_Division__c,
                CustomerNumber__c = a1.GE_LGT_EM_SAP_Customer_Number__c,
                CustomerNumberRegionCounty__c = 'HU',
                ProductFamily1__c = 'test',
                ProductFamily2__c = 'noTest'
        );
        insert c1;

        Account a2 = new Account(Name = 'Test1',
                GE_LGT_EM_Sales_Org__c = '20HU',
                GE_LGT_EM_Distribution_Channel__c = '10',
                GE_LGT_EM_Division__c = '20',
                GE_LGT_EM_SAP_Customer_Number__c = 'TestCustN2');
        insert a2;

        CustomerProductFamily__c c2 = new CustomerProductFamily__c(
                Name = a2.Name,
                SalesOrganization__c = a2.GE_LGT_EM_Sales_Org__c,
                DistributionChannel__c = a2.GE_LGT_EM_Distribution_Channel__c,
                Division__c = a2.GE_LGT_EM_Division__c,
                CustomerNumber__c = a2.GE_LGT_EM_SAP_Customer_Number__c,
                CustomerNumberRegionCounty__c = 'US',
                ProductFamily3__c = 'test',
                ProductFamily4__c = 'noTest2'
        );
        insert c2;
        StockBalancingReturnLwcController.getProductFamilies(a1.Id, a2.Id);
        //System.assertEquals(c1.ProductFamily1__c, StockBalancingReturnLwcController.getProductFamilies(a1.Id, a2.Id)[0]);
    }

    @IsTest
    static void getAgentNames() {
        Account a = new Account(Name = 'Test1',
                GE_LGT_EM_Sales_Org__c = '10HU',
                GE_LGT_EM_Distribution_Channel__c = '20',
                GE_LGT_EM_Division__c = '10',
                GE_LGT_EM_SAP_Customer_Number__c = 'TestCustN1',
                GE_LGT_Rep_Code__c = 'TST');
        insert a;
        String s = StockBalancingReturnLwcController.getAgentNames('TST');
        System.assertEquals('TST - Test1',s);
    }
}
/**
 * Created by Tamas on 7/14/2021.
 */

@IsTest
private class TestCommunityCaseProcessLibrary {
    @IsTest
    static void getNoAccBalancing() {
        Map<String, String> newAccount = new Map<String, String>
        {'GE_LGT_EM_SAP_Customer_Number__c' => 'test',
        'GE_LGT_EM_Distribution_Channel__c' => 'test',
        'GE_LGT_EM_Division__c' => 'test',
        'GE_LGT_EM_Sales_Org__c' => 'test'
        };
        string jsonAccount = JSON.serialize(newAccount);
        CommunityCaseProcessLibrary.getNoOfRemainingReturns(jsonAccount);

    }
    @IsTest
    static void getAccountMixture(){
        Pricebook2 b = new Pricebook2(Name= 'LED');
        insert b;

        Map<String, String> newAccount = new Map<String, String>
        {'GE_LGT_EM_SAP_Customer_Number__c' => 'test',
        'GE_LGT_EM_Distribution_Channel__c' => 'test',
        'GE_LGT_EM_Division__c' => 'test',
        'GE_LGT_EM_Sales_Org__c' => 'test'
        };
        string jsonAccount = JSON.serialize(newAccount);

        Map<String, String> newAccount1 = new Map<String, String>
        {'GE_LGT_EM_SAP_Customer_Number__c' => 'test1',
        'GE_LGT_EM_Distribution_Channel__c' => 'test1',
        'GE_LGT_EM_Division__c' => 'test1',
        'GE_LGT_EM_Sales_Org__c' => 'test1'
        };
        string jsonAccount1 = JSON.serialize(newAccount1);

        Product2 product = TestDataUtil.createProduct('tandrasai');
        product.name = 'Test Prod72';
        product.GE_LGT_Product_Line__c='INDOOR FIXTURE - LED';
        product.GE_LGT_Product_Group__c='ALBEO LINEAR';
        product.CurrencyIsoCode='USD';
        product.Product_Hierarchy_Code__c='testproduct345';
        product.CanUseQuantitySchedule =true;
        product.CanUseRevenueSchedule=true;
        product.ProductCode ='testproduct1';
        product.Product_Hierarchy_Code__c='testproduct12';
        product.Level_1__c = 'AUT - AUTOMOTIVE';
        product.Level_2__c='AUT100 - HALOGEN COMPOSITE HEADLAMPS';
        product.isactive=true;
        insert product;

        Map<String, String> newProd = new Map<String, String>
        {'name' => 'test',
        'GE_LGT_Product_Line__c' => 'INDOOR FIXTURE - LED',
        'GE_LGT_Product_Group__c' => 'ALBEO LINEAR',
        'Level_1__c' => 'AUT - AUTOMOTIVE',
        'lineNo' => '12',
        'itemNo' => '13',
        'itemDesc' => 'AUT - AUTOMOTIVE',
        'qty' => '12',
        'uom' => '13'
        };
        string jsonProd = JSON.serialize(newProd);

        List<Object> pros = new List<Object>();
        pros.add(jsonProd);

        Account parentAcc=new Account();
        parentAcc.Name='Test Account';
        parentAcc.BillingCountry='United States';
        parentAcc.GE_LGT_Vertical__c='Fin';
        parentAcc.GE_LGT_EM_SAP_Customer_Number__c='Test8811';
        parentAcc.GE_LGT_EM_Sales_Org__c='1US1';
        parentAcc.GE_LGT_EM_Distribution_Channel__c='10-Cons';
        parentAcc.GE_LGT_EM_Division__c='10-Fin';
        parentAcc.GE_LGT_EM_SAPUniqueIdentifier__c='Test8811-1US1-10-10';
        parentAcc.GE_LGT_EM_Partner_Function__c='Sold To Party';
        parentAcc.Account_Group__c='ZSH5';
        parentAcc.CurrencyIsoCode='USD';
        parentAcc.GE_NAS_Language__c='English';
        insert parentAcc;

        CommunityCaseProcessLibrary.getAgreedProductPrices(pros,jsonAccount,parentAcc.Id);

    }
    @IsTest
    static void testResponse(){
        Test.setMock(WebServiceMock.class, new SAPGatewayTest.PricingMock());

        List<PriceAgreementController.PriceAgreementItem> pai = new List<PriceAgreementController.PriceAgreementItem>();

        PriceAgreementController.PriceAgreementItem pii = new PriceAgreementController.PriceAgreementItem();
        pii.lineNumber = 55;
        pii.quantity = 5;
        pii.currencyISOCode = 'EUR';
        pii.priceAgreementValue = 0;
        pii.bookPrice = 5;

        pai.add(pii);

        PriceAgreementController.PriceAgreementResponse response = new PriceAgreementController.PriceAgreementResponse();
        response.agent = 'DT5';
        response.extAgent = 'DT5';
        response.distChannel = '20';
        response.customer = '0800';
        response.division = '10';
        response.orderType = 'N';
        response.poNumber = '123';
        response.poType = '';
        response.agrDate = '20201127';
        response.userType = '';
        response.salesOrg = '1US1';
        response.division = '10';
        response.SKU = '12377';
        response.agreement = '123';
        response.userType = 'Agent';
        response.orderFlag = 'N';
        response.orderReason = 'Test';
        response.priceAgreementItemList =pai;

        CommunityCaseProcessLibrary.handleCom475Response((PriceAgreementController.PriceAgreementResponse) response);

    }

    @IsTest
    static void testcdocFile(){

        ContentVersion content=new ContentVersion();
        content.Title='Header_Picture12';
        content.PathOnClient='/' + content.Title + '.jpg';
        content.IsMajorVersion = true;
        Blob bodyBlob=Blob.valueOf('Uni 1,2,3,4,5,6,7,8,9 \n Uni  1,2,3,4,5,6,7,8,8,9');
        content.VersionData=bodyBlob;
        insert content;

        ContentVersion conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:content.Id];

        CommunityCaseProcessLibrary.getProductListFromFile(conDoc.ContentDocumentId);



    }

    @IsTest
    static void getRuui(){
        Account a1 = new Account(Name = 'Test1',
                GE_LGT_EM_Sales_Org__c = '10HU',
                GE_LGT_EM_Distribution_Channel__c = '20',
                GE_LGT_EM_Division__c = '10',
                GE_LGT_EM_SAP_Customer_Number__c = 'TestCustN1');
        insert a1;

        Account a2 = new Account(Name = 'Test2',
                GE_LGT_EM_Sales_Org__c = '10HU',
                GE_LGT_EM_Distribution_Channel__c = '20',
                GE_LGT_EM_Division__c = '10',
                GE_LGT_EM_SAP_Customer_Number__c = 'TestCustN1');
        insert a2;

        CustomerProductFamily__c c1 = new CustomerProductFamily__c(
                Name = a1.Name,
                SalesOrganization__c = a1.GE_LGT_EM_Sales_Org__c,
                DistributionChannel__c = a1.GE_LGT_EM_Distribution_Channel__c,
                Division__c = a1.GE_LGT_EM_Division__c,
                CustomerNumber__c = a1.GE_LGT_EM_SAP_Customer_Number__c,
                CustomerNumberRegionCounty__c = 'HU',
                SAPCustomerNumber__c = a1.Id
        );
        insert c1;

        CommunityCaseProcessLibrary.getProductFamilies(a1.Id,a2.Id);
    }
}
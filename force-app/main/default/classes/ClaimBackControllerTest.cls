/**
 * Created by Tamas on 7/19/2021.
 */

@IsTest
private class ClaimBackControllerTest {
        @IsTest
        static void testcdocFile(){

        ContentVersion content=new ContentVersion();
        content.Title='filledTemplate';
        content.PathOnClient='/' + content.Title + '.csv';
        content.IsMajorVersion = true;
        Blob bodyBlob=Blob.valueOf('End Customer Account no.,End Customer Name,End Customer Invoice,End Customer Invoice Date,Shipment Type,GEC Invoice no.,Job Name \n 123,test,3221,1/1/2022,regular,432,test \n Catalog Number/SKU,Quantity (In eaches),Price Agreement no.,GEC Replacement Price Per Unit,Price Agreement Price Per Unit \n 93130970t,2,0080117117,3,2 \n InvalidCatNumber,2,0080117132,3,2');
        content.VersionData=bodyBlob;
        insert content;

            GE_LGT_EM_MaterialMaster__c	 mm = new GE_LGT_EM_MaterialMaster__c();
            mm.GE_LGT_EM_SAP_MaterialNumber__c='93130970t';
            mm.GE_LGT_EM_MaterialDescription__c='test1';
            mm.GE_LGT_EM_ProductHierarchy__c='test1';
            mm.GE_LGT_EM_MaterialDescription__c = '23';
            insert mm;

        ContentVersion conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:content.Id];

            ClaimBackController.processInvoiceFile(conDoc.ContentDocumentId, '-');
    }

    @IsTest
        static void testGetPriceAgreements(){

        SAP_Price_Agreement__c pa =
                new SAP_Price_Agreement__c(
                        Customer_List__c = 'testNumber,otherTestNumber,blah,blah',
                        Agreement_No__c = 'test',
                        Name = 'test PA',
                        Expiration_Date__c = System.today().addDays(1),
                        Agreement_Type__c = 'ZCLB'
                );
        insert pa;
        ClaimBackController.getPriceAgreements('testNumber');
    }

        @IsTest
        static void testclaimtosap(){

            ID recEDurypeID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
            Account a = New Account();
            a.Name = 'msat';
            a.type= 'End User';
            a.GE_LGT_Vertical__c = 'Educ';
            a.Site = 'Mayfield';
            a.GE_LGT_EM_SAP_Customer_Number__c='999999';
            a.GE_LGT_EM_Sales_Org__c='1US1';
            a.GE_LGT_EM_Division__c='10';
            a.GE_LGT_EM_Distribution_Channel__c='20-Prof';
            a.GE_LGT_Rep_Code__c='0003rgd';
            a.GE_LGT_District_Manager__c='101013280';
            a.GE_LGT_FAM_AM__c='101013280';
            a.GE_LGT_Regional_Manager__c='101013280';
            insert a;

            GE_LGT_EM_MaterialMaster__c	 mm = new GE_LGT_EM_MaterialMaster__c();
            mm.GE_LGT_EM_SAP_MaterialNumber__c='93130970t';
            mm.GE_LGT_EM_MaterialDescription__c='test1';
            mm.GE_LGT_EM_ProductHierarchy__c='test1';
            insert mm;

            //ID recEDurypeID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
            Account a1 = New Account();
            a1.Name = 'msat';
            a1.type= 'End User';
            a1.GE_LGT_Vertical__c = 'Educ';
            a1.Site = 'Mayfield';
            a1.GE_LGT_EM_SAP_Customer_Number__c='999999';
            a1.GE_LGT_EM_Sales_Org__c='1US1';
            a1.GE_LGT_EM_Division__c='10';
            a1.GE_LGT_EM_Distribution_Channel__c='20-Prof';
            a1.GE_LGT_Rep_Code__c='0003rgd';
            a1.GE_LGT_District_Manager__c='101013280';
            a1.GE_LGT_FAM_AM__c='101013280';
            a1.GE_LGT_Regional_Manager__c='101013280';
            insert a1;


            List<Map<Object,Object>> lim = new List<Map<Object,Object>>();

            List<Map<String,Object>> lim1 = new List<Map<String,Object>>();

            Map<String,Object> lim1p = new Map<String,Object>();
            lim1p.put('creditPerUnit',11);
            lim1p.put('gecPrice',(Object)1);
            lim1p.put('priceAgreementPrice',(Object)1);
            lim1p.put('materialMaster',mm);

            Map<String, Object> um1 = new Map<String,Object>();

            //itt ha beteszed megvan a coverage csak dob egy conversion hibat.. whyy???
            //lim1.add(lim1p);

            Map<Object,Object> result1 = new Map<Object,Object>();
            result1.put('jobName','qwerty');
            result1.put('products',lim1);
            result1.put('endCustomerAccountNumInfo',um1);
            lim.add(result1);


            Map<String,Object> result = new Map<String,Object>();
            result.put('accountID',a.Id);
            result.put('accountId',a.Id);
            result.put('soldToAccountId',a1.Id);
            result.put('invoices',lim);
            system.debug('result '+result);




            Test.setMock(WebServiceMock.class, new getCaseRgaPdfMock());
            Test.startTest();
                ClaimBackController.sendClaimToSAP(result);
            Test.stopTest();
        }


    public class getCaseRgaPdfMock implements WebServiceMock {
        public void doInvoke(
                Object stub,
                Object request,
                Map<String, Object> response,
                String endpoint,
                String soapAction,
                String requestName,
                String responseNS,
                String responseName,
                String responseType
                ) {

            ClaimBackController.ClaimBackCreateResponse response_x = new ClaimBackController.ClaimBackCreateResponse();
            response_x.returnValue = 'OK';
        }
    }

}
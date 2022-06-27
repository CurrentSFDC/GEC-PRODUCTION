/********************************************************************
Purpose: Controller for invoiceSelectinComponent component. Searches for Invoice records based on search string. 
        

History:
--------
VERSION  AUTHOR       DATE         DESCRIPTION
1.0      Nate Kanyok  15-Dec-2020  Created
*/

@isTest
public class InvoiceSelectionControllerTest {

    @TestSetup
    static void setupTestData(){
        b2bTestSetup.setupPortalUsers();
        b2bTestSetup.setupPricelist();

        Account acct = [SELECT Id FROM Account WHERE ccrz__dataId__c = 'B2BContact'];
        acct.GE_LGT_EM_SAP_Customer_Number__c = '0000000123';
        update acct;

        Date creationDate = Date.valueOf('2019-12-15');
        Date billingDate = Date.valueOf('2019-12-16');



        GE_LGT_EM_InvoiceHeader__c invoice = new GE_LGT_EM_InvoiceHeader__c(Name='test invoice',
                                                                            // Id='123', 
                                                                            GE_LGT_EM_Sold_to_Account_Number__c='43211', 
                                                                            GE_LGT_EM_SAPInvoiceNumber__c='123', 
                                                                            GE_LGT_EM_Billing_Date__c=billingDate, 
                                                                            // CurrencyIsoCode='1', 
                                                                            // GE_LGT_EM_CustomerName__c='1234', 
                                                                            GE_LGT_EM_Invoice_Creation_Date__c=creationDate, 
                                                                            GE_LGT_EM_Net_value__c='77', 
                                                                            GE_LGT_EM_Tax_Number_1__c='2', 
                                                                            Invoice_Currency__c='USD');
        insert invoice;

    }


    @isTest
    static void testInvoiceInit() {
        
        Account acct = [SELECT Id FROM Account WHERE ccrz__dataId__c = 'B2BContact'];


        Test.startTest();
        List<GE_LGT_EM_InvoiceHeader__c> invoices = InvoiceSelectionController.initInvoices('1969-12-31', '2069-12-31');
        System.assertEquals(1, invoices.size());
        Test.stopTest();

    }

    @isTest
    static void testInvoiceSearch() {
        Account acct = [SELECT Id FROM Account WHERE ccrz__dataId__c = 'B2BContact'];


        Test.startTest();
        List<GE_LGT_EM_InvoiceHeader__c> invoices = InvoiceSelectionController.searchForInvoice('123','1969-12-31', '2069-12-31');
        System.assertEquals(1, invoices.size());
        Test.stopTest();
    }



}
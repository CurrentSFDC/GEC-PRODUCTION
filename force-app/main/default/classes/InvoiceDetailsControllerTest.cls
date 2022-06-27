@isTest
public with sharing class InvoiceDetailsControllerTest {

    @TestSetup
    private static void setupData(){
        b2bTestSetup.setupPortalUsers();
        b2bTestSetup.setupPricelist();

        Account acct = [SELECT Id FROM Account WHERE ccrz__dataId__c = 'B2BContact'];
        acct.GE_LGT_EM_SAP_Customer_Number__c = '0000000123';
        update acct;

        Date creationDate = Date.valueOf('2019-12-15');
        Date billingDate = Date.valueOf('2019-12-16');



        GE_LGT_EM_InvoiceHeader__c invoice = new GE_LGT_EM_InvoiceHeader__c(Name='test invoice',
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

        GE_LGT_EM_InvoiceLineItem__c invoiceLineItem = new GE_LGT_EM_InvoiceLineItem__c(Name='Invoice Test',
                                                                                        GE_LGT_EM_InvoiceHeaderNumber__c=invoice.Id, 
                                                                                        GE_LGT_EM_SAP_Invoice_Number__c='1234');
        insert invoiceLineItem;

    }

    @isTest
    private static void testGetInvoiceDetails() {
        
        GE_LGT_EM_InvoiceHeader__c header = [SELECT Id FROM GE_LGT_EM_InvoiceHeader__c WHERE GE_LGT_EM_SAPInvoiceNumber__c = '123'];

        Test.startTest();
        System.assertNotEquals(null, InvoiceDetailsController.getInvoiceDetails(header.Id), 'Failed Test Mate');
        Test.stopTest();

    }

}
@IsTest
public class ReportSubscriptionControllerTest {
    private static Account account = new Account();
    private static Contact contact = new Contact();
    private static User user = new User();


    @TestSetup
    static void setupData(){
        b2bTestSetup.setupPortalUsers();
        b2bTestSetup.setupPricelist();
        ExceptionLoggingFramework__c elf = new ExceptionLoggingFramework__c();
		elf.Enabled__c=true;
		elf.EmailNotificationEnabled__c=true;
		insert elf;
    }

    @isTest
    private static void testQueryReportSubscriptionsExistingRecord() {
        String customernum1='H9M';
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select Id From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        system.debug(customerContact);
        system.runAs(testUser){
            Report_Subscription__c rs = new Report_Subscription__c(
                Contact__c = customerContact.Id,
                Cut_Order_Report__c = false,
                Daily_Commission_Report__c = false,
                Due_DT_CGE_Report__c = false,
                Invoice_By_Bill__c = false,
                Monthly_Commission_Report__c = false,
                Open_Order_Report__c = false,
                Order_Line_Report__c = false,
                Order_Ship_Report__c = false,
                Price_Mismatch__c = false
            );
        
            insert rs;
            system.debug(rs);
        }
        Report_Subscription__c reportSubscriptions = new Report_Subscription__c();
        system.debug(testUser);
        system.runAs(testUser){
            Test.startTest();
            reportSubscriptions = ReportSubscriptionController.queryReportSubscriptions(customernum1);
            Test.stopTest();
        }
     //   System.assertNotEquals(null, reportSubscriptions);
    }

    @isTest
    private static void testSetReportSubscriptionsNewRecord() {
        Boolean checkCutOrderReport = false; 
        Boolean checkDailyCommissionReport = false;
        Boolean checkDueDtCGEReport = false;
        Boolean checkMonthlyCommissionReport = false;
        Boolean checkOpenOrderReport = false;
        Boolean checkOrderLineReport = false; 
        Boolean checkOrderShipReport = false;
        Boolean checkInvoiceByBill = false; 
        Boolean checkPriceMismatch = true;
        String customernum = 'H9M';
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        system.debug(testUser);
        system.runAs(testUser){
            Test.startTest();
            Test.setMock(WebServiceMock.class, new MockSAPGateway());
            ReportSubscriptionController.Response response  = ReportSubscriptionController.setReportSubscriptions(checkDueDtCGEReport, checkMonthlyCommissionReport, checkOpenOrderReport, checkOrderLineReport, checkOrderShipReport, customernum);
            Test.stopTest();

            System.assertNotEquals(null, response);
        }
    }


    @isTest
    private static void testSetReportSubscriptionsExistingRecord(){
        User testUser = [Select Id From User Where Email = 'b2b.contact@gecurrent.com.acumen'];
        Contact customerContact = [Select Id From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id)];
        system.debug(customerContact);
        system.runAs(testUser){
            Report_Subscription__c rs = new Report_Subscription__c(
                Contact__c = customerContact.Id,
                Cut_Order_Report__c = false,
                Daily_Commission_Report__c = false,
                Due_DT_CGE_Report__c = false,
                Invoice_By_Bill__c = false,
                Monthly_Commission_Report__c = false,
                Open_Order_Report__c = false,
                Order_Line_Report__c = false,
                Order_Ship_Report__c = false,
                Price_Mismatch__c = false
            );
        
            insert rs;
            system.debug(rs);
        }
        Boolean checkCutOrderReport = true; 
        Boolean checkDailyCommissionReport = true;
        Boolean checkDueDtCGEReport = true;
        Boolean checkMonthlyCommissionReport = true;
        Boolean checkOpenOrderReport = true;
        Boolean checkOrderLineReport = true; 
        Boolean checkOrderShipReport = true;
        Boolean checkInvoiceByBill = true; 
        Boolean checkPriceMismatch = true;
        String customernum='H9M';
        system.runAs(testUser){
            Test.startTest();
            Test.setMock(WebServiceMock.class, new MockSAPGateway());
            ReportSubscriptionController.Response response  = ReportSubscriptionController.setReportSubscriptions(checkDueDtCGEReport, checkMonthlyCommissionReport, checkOpenOrderReport, checkOrderLineReport, checkOrderShipReport,customernum);
            Test.stopTest();

            System.assertNotEquals(null, response);
        }

    }

    private class MockSAPGateway implements WebServiceMock {
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {
        sapComSapRfcFunctionsRprtSub.x_xGEL_xSFB2B_REPORT_SUBSCRIPT3_Response_element response_x = new sapComSapRfcFunctionsRprtSub.x_xGEL_xSFB2B_REPORT_SUBSCRIPT3_Response_element();
        response_x.E_MESSAGE = 'S';
        response_x.E_XXSSO_GESSOUID = 'b2b.contact@gecurrent.com.acumen';
                response.put('response_x', response_x);
        }
        
	}






}
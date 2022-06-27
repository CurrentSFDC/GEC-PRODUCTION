/*----------------------------------------------------------------------
Name:       ReportSubscriptionController.cls
Purpose:    Call SAP for subscriptions
------------------------------History----------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          ------------------
1.0         Nate Kanyok     25-Jan-2021             Initial Development 
----------------------------------------------------------------------*/

public class ReportSubscriptionController {

    public static final String markSubscription = 'X';
    @AuraEnabled(cacheable=false)
    public static Response setReportSubscriptions(Boolean checkDueDTCGEReport, Boolean checkMonthlyCommissionReport,
                                                                        Boolean checkOpenOrderReport,
                                                                        Boolean checkOrderLineReport, Boolean checkOrderShipReport, String customernum){
       
        User u = [SELECT Id, ContactId, Email, Account.Id FROM User WHERE Id = : UserInfo.getUserId()];
          
        System.Debug('step' + u.ContactId );   
        System.Debug('step' + checkDueDTCGEReport );                                                                     
		system.debug('customernum'+customernum);
		
        Report_Subscription__c hasSubscriptions = queryReportSubscriptions(customernum);
        Report_Subscription__c rs;
        rs = new Report_Subscription__c(
                Contact__c = u.ContactId,
               // Cut_Order_Report__c = checkCutOrderReport,
               // Daily_Commission_Report__c = checkDailyCommissionReport,
                Due_DT_CGE_Report__c = checkDueDTCGEReport,
               // Invoice_By_Bill__c = checkInvoiceByBill,
                Monthly_Commission_Report__c = checkMonthlyCommissionReport,
                Open_Order_Report__c = checkOpenOrderReport,
                Order_Line_Report__c = checkOrderLineReport,
                Order_Ship_Report__c = checkOrderShipReport,
            SAP_Customer_Number_Report__c = customernum
               // Price_Mismatch__c = checkPriceMismatch
            );
        if(hasSubscriptions!=null){     
            rs.Id=hasSubscriptions.Id;                                                         
        }

        upsert rs;

        System.Debug('step' + rs.Id );   

 
        createReportSubscriptionFuture(rs.Id,customernum);
        
        return new Response();
    }   

    @future(callout=true)
    private static void createReportSubscriptionFuture(String subscriptionId, String customernum){
        Id userId = UserInfo.getUserId();
       
        User u = [SELECT Id, ContactId, Email, Account.Id FROM User WHERE Id = : userId];

        Account account = [
            SELECT Id,
                    Name,
                    GE_LGT_EM_SAP_Customer_Number__c
            FROM Account 
            WHERE Id = :u.Account.Id
        ];
        Report_Subscription__c rs = queryReportSubscriptions(customernum);

        Request request = new Request();

       request.ssoAcct = rs.SAP_Customer_Number_Report__c;
        request.ssoEmail = u.Email;
        //Need to check sso-uid
       request.ssoGESSOUID = rs.Name;
        
        
/*
        if(rs.Cut_Order_Report__c) {
            request.cutOrdRep = markSubscription;
        }
        if(rs.Daily_Commission_Report__c) {
            request.dailyCommReport = markSubscription;
        }
*/
        if(rs.Due_DT_CGE_Report__c) {
            request.dueDtCGEReport = markSubscription;
        }
/*
        if(rs.Invoice_By_Bill__c) {
            request.invByBill = markSubscription;
        }
        if(rs.Price_Mismatch__c) {
            request.priceMismatch = markSubscription;
        }
*/
        if(rs.Open_Order_Report__c) {
            request.openOrdRep = markSubscription;
        }
        if(rs.Monthly_Commission_Report__c) {
            request.monthlyCommReport = markSubscription;
        }
        if(rs.Order_Line_Report__c) {
            request.orderLineReport = markSubscription;
        }
        if(rs.Order_Ship_Report__c) {
            request.orderShipReport = markSubscription;
        } 
        if(rs.Due_DT_CGE_Report__c || rs.Open_Order_Report__c|| rs.Monthly_Commission_Report__c|| rs.Order_Line_Report__c|| rs.Order_Ship_Report__c){
            request.modType = 'U';
        }
        else{
            request.modType = 'D';
        }
        // set request id
        System.Debug('step' + u.ContactId );   
        SAPGateway service = new SAPGateway();
        Response response = service.getReportSubscriptionsSAP(request);  
    }

    /*public static string getrepcode(ccrz.cc_RemoteActionContext ctx){
        //ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        Id accountId = Id.valueOf(ctx.effAccountId);
        Account effectiveAcct = [SELECT GE_LGT_Rep_Code__c from Account Where Id =: accountId];
        String repCode = effectiveAcct.GE_LGT_Rep_Code__c;
        return repCode;
    }*/
    @AuraEnabled
    public static Report_Subscription__c queryReportSubscriptions(String customernum1)  {
       
        User u = [SELECT Id, ContactId, Email, Account.Id FROM User WHERE Id = : UserInfo.getUserId()];
        system.debug(u.ContactId);
        List<Report_Subscription__c>  reportSubscriptions = [SELECT Id, Name,
                                            Cut_Order_Report__c,
                                            Daily_Commission_Report__c,
                                            Due_DT_CGE_Report__c,
                                            Invoice_By_Bill__c,
                                            Monthly_Commission_Report__c,
                                            Open_Order_Report__c,
                                            Order_Line_Report__c,
                                            Order_Ship_Report__c,
                                            Price_Mismatch__c,
                                            SAP_Customer_Number_Report__c
                                    FROM Report_Subscription__c
                                    WHERE Contact__c = :u.ContactId and SAP_Customer_Number_Report__c =: customernum1 Limit 1];
        system.debug(reportSubscriptions);
        if(!reportSubscriptions.isEmpty()){
            return reportSubscriptions.get(0);
        }

        return null;
    }


    public class Request {
        @AuraEnabled
        public String cutOrdRep {get; set;}
        @AuraEnabled
        public String dailyCommReport {get; set;}        
        @AuraEnabled
        public String dueDtCGEReport {get; set;}
        @AuraEnabled
        public String invByBill {get; set;}
        @AuraEnabled
        public String modType {get; set;} 
        @AuraEnabled
        public String monthlyCommReport {get; set;}
        @AuraEnabled
        public String openOrdRep {get; set;}
        @AuraEnabled
        public String orderLineReport {get; set;}
        @AuraEnabled
        public String orderShipReport {get; set;}
        @AuraEnabled
        public String priceMismatch {get; set;}
        @AuraEnabled
        public String ssoAcct {get; set;}
        @AuraEnabled
        public String ssoEmail {get; set;}
        @AuraEnabled
        public String ssoGESSOUID {get; set;}

    }


    public class Response {
        @AuraEnabled
        public String message {get;set;}
        @AuraEnabled
        public String ssoGESSOUID {get;set;}
    }

}
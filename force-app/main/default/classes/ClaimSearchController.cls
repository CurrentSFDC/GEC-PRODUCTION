public with sharing class ClaimSearchController {

    @AuraEnabled
    public static ClaimSearchController.ClaimSearchResponse searchClaims(ClaimSearchController.ClaimSearchRequest request){

        request.formatRequestParameters();
        System.debug('ClaimSearchRequest\n'+JSON.serializePretty(request));

        SAPGateway gateway = new SAPGateway();
        ClaimSearchController.ClaimSearchResponse response = gateway.searchClaims(request);
        return response;
    }

    public class ClaimSearchRequest{
        @AuraEnabled
        public String dateFrom {get;set;}
        @AuraEnabled
        public String dateTo {get;set;}
        @AuraEnabled
        public String materialNumber {get;set;}
        @AuraEnabled
        public String soldToNumber {get;set;}
        @AuraEnabled
        public String salesOrg {get;set;}
        @AuraEnabled
        public String distributionChannel {get;set;}
        @AuraEnabled
        public String division {get;set;}
        @AuraEnabled
        public String claimNumber {get;set;}
        @AuraEnabled
        public String referenceNumber {get;set;}

        private void formatRequestParameters(){

            system.debug('dateFrom '+dateFrom);
            system.debug('dateTo '+dateTo);
            if(String.isNotEmpty(dateFrom)) {
                Datetime dateFromDT = Datetime.newInstance(Integer.valueOf(dateFrom.split('-')[0]), Integer.valueOf(dateFrom.split('-')[1]), Integer.valueOf(dateFrom.split('-')[2]));
                dateFrom = dateFromDT.format('yyyyMMdd');
            }
            if(String.isNotEmpty(dateTo)) {
                Datetime dateToDT = Datetime.newInstance(Integer.valueOf(dateTo.split('-')[0]), Integer.valueOf(dateTo.split('-')[1]), Integer.valueOf(dateTo.split('-')[2]));
                dateTo = dateToDT.format('yyyyMMdd');
            }
            if(String.isNotEmpty(materialNumber)) {
                materialNumber = materialNumber.leftPad(10, '0');
            }
            if(String.isNotEmpty(soldToNumber)) {
                soldToNumber = soldToNumber.leftPad(10, '0');
            }
        }
    }

    public class ClaimSearchResponse{
        @AuraEnabled
        public String message;
        @AuraEnabled
        public List<ClaimSearchController.ClaimSearchResponseItem> claims = new List<ClaimSearchController.ClaimSearchResponseItem>();
    }

    public class ClaimSearchResponseItem{
        @AuraEnabled
        public String jobName;
        @AuraEnabled
        public Decimal submittedAmount;
        @AuraEnabled
        public String salesOrg;
        @AuraEnabled
        public String distributionChannel;
        @AuraEnabled
        public String division;
        @AuraEnabled
        public String referenceNumber;
        @AuraEnabled
        public Date invoiceDate;
        @AuraEnabled
        public Decimal invoiceAmount;
        @AuraEnabled
        public String invoiceNum;
        @AuraEnabled
        public String soldToNumber;
        @AuraEnabled
        public Decimal claimedTotalAmount;
        @AuraEnabled
        public String claimNumber;
        @AuraEnabled
        public Date claimDate;
    }
}
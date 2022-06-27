public without sharing class CommunityOpenReturnsController {

    @AuraEnabled(Cacheable = true)
    public static List<Order> getOpenReturns(OrderQuery orderQuery) {
        System.debug('orderQuery\n' + JSON.serializePretty(orderQuery));
        if (orderQuery.isQueryValid == false || orderQuery.queryOffset > 2000) {
            return null;
        }
        String query = 'SELECT SFDC_Order_number__c, GE_Order_NO__c, Sold_To__r.Name, Agent_Account__r.Name, Order_Req_Delivery_Date__c,GE_Opportunity_Id__c, GBSTK__c, Customer_PO_Number__c,TotalAmount, CurrencyIsoCode, EffectiveDate, Type , Grand_Total__c FROM Order ' + orderQuery.whereClause;
        System.debug('getOpenReturns query ' + query);
        return Database.query(query);
    }

    public class OrderQuery {
        @AuraEnabled
        public Id accountId { get; set; }
        @AuraEnabled
        public Id soldToId { get; set; }
        @AuraEnabled
        public String searchText { get; set; }
        @AuraEnabled
        public Date fromDate { get; set; }
        @AuraEnabled
        public Date toDate { get; set; }
        @AuraEnabled
        public Integer queryLimit {
            get {
                if (queryLimit == null) {
                    queryLimit = Limits.getLimitQueryRows();
                }
                return queryLimit;
            }
            set;
        }
        @AuraEnabled
        public Integer queryOffset {
            get {
                if (queryOffset == null) {
                    queryOffset = 0;
                }
                return queryOffset;
            }
            set;
        }
        public String whereClause {
            get {
                List<String> queryParts = new List<String>();

                if (accountId != null && soldToId != null){ // AGENT AND DISTRIBUTOR
                    queryParts.add('(Sold_To__c = \'' + soldToId + '\' AND Agent_Account__c = \'' + accountId + '\')');
                    queryParts.add('(Type = \'ZRE\')');
                    
                } else if (accountId != null && soldToId == null){ //AGENT ONLY
                    queryParts.add('(Sold_To__c = \'' + accountId + '\' OR Agent_Account__c = \'' + accountId + '\')');
                    queryParts.add('(Type = \'ZRE\')');
                    
                } else { //DISTRIBUTOR ONLY
                    queryParts.add('(Sold_To__c = \'' + soldToId +'\')');
                    queryParts.add('(Type = \'ZRE\')');
                    
                }


                
                if (String.isNotBlank(searchText)) {
                    String text = '\'%' + searchText + '%\'';
                    List<String> nameQueryFragment = new List<String>();
                    nameQueryFragment.add('Name LIKE ' + text );
                    nameQueryFragment.add('Account.Name LIKE ' + text );
                    nameQueryFragment.add('Sold_To__r.Name LIKE ' + text );
                    nameQueryFragment.add('Customer_PO_Number__c LIKE ' + text );
                    nameQueryFragment.add('GE_Order_NO__c LIKE ' + text );
                    nameQueryFragment.add('GBSTK__c LIKE ' + text );
                    nameQueryFragment.add('GE_Opportunity_Id__c LIKE ' + text );
                    nameQueryFragment.add('CurrencyIsoCode LIKE ' + text );
                    queryParts.add('('+String.join(nameQueryFragment, ' OR ') + ')');
                }
                /*if (fromDate == null && toDate == null) {
                    queryParts.add('(EffectiveDate >= LAST_N_DAYS:365)');
                }*/
                if (fromDate != null && toDate != null) {
                    queryParts.add('(EffectiveDate >= ' + String.valueOf(fromDate) + ' AND EffectiveDate <= ' + String.valueOf(toDate) + ')');
                } else if (toDate != null) {
                    //queryParts.add('(EffectiveDate >= :LAST_N_DAYS:365 AND EffectiveDate <= ' + String.valueOf(toDate) + ')');
                   queryParts.add('(EffectiveDate <= ' + String.valueOf(toDate) + ')');

                } else if (fromDate != null) {
                    queryParts.add('(EffectiveDate >= ' + String.valueOf(fromDate) + ')');
                }
                return ' WHERE ' + String.join(queryParts, ' AND ') + 'ORDER BY EffectiveDate DESC' + ' LIMIT ' + queryLimit + ' OFFSET ' + queryOffset;
            }
        }

        public Boolean isQueryValid {
            get {
                return (this.accountId != null || this.soldToId !=null);
            }
        }
    }
}
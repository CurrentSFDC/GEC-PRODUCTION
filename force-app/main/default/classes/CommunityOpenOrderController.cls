public without sharing class CommunityOpenOrderController {

    public class CommunityOpenOrderControllerException extends Exception {
    }

    @AuraEnabled(Cacheable=true)
    public static List<Order> getOrders(OrderQuery orderQuery) {
        System.debug('orderQuery\n' + JSON.serializePretty(orderQuery));
        if (orderQuery == null || !orderQuery.isQueryValid) {
            throw new CommunityOpenOrderControllerException('Invalid orderQuery: ' + JSON.serialize(orderQuery));
        }
        if(orderQuery.queryOffset > 2000){
            return null;
        }
        String orderQueryString = 'SELECT Id, Account.Name, Sold_To__r.Name,Order_Req_Delivery_Date__c,GE_Opportunity_Id__c, Agent_Account__r.Name, SFDC_Order_number__c, GE_Order_NO__c, Customer_PO_Number__c, Status, CurrencyIsoCode, GBSTK__c,' +
                'TotalAmount, EffectiveDate, Type ,Grand_Total__c FROM Order ' + orderQuery.whereClause;
        System.debug('orderQueryString ' + orderQueryString);
        List<Order> orders = Database.query(orderQueryString);
        System.debug('orders\n' + JSON.serializePretty(orders));
        return orders;
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
        public Integer queryLimit { get; set; }
        @AuraEnabled
        public Integer queryOffset { get; set; }

        public String whereClause {
            get {
                List<String> queryParts = new List<String>();
                if (accountId != null && soldToId != null){ //AGENT AND DISTRIBUTOR
                    queryParts.add('(Sold_To__c = \'' + soldToId + '\' AND Agent_Account__c = \'' + accountId + '\')');
                    queryParts.add('(Type != \'ZRE\')');
                    queryParts.add('(GBSTK__c != NULL)');
                    queryParts.add('(TotalAmount > 0.00)');
                } else if (accountId != null && soldToId == null){ // AGENT ONLY
                    queryParts.add('(Sold_To__c = \'' + accountId + '\' OR Agent_Account__c = \'' + accountId + '\')');
                    queryParts.add('(Type != \'ZRE\')');
                    queryParts.add('(GBSTK__c != NULL)');
                    queryParts.add('(TotalAmount > 0.00)');
                } else { //DISTRIBUTOR ONLY
                    queryParts.add('(Sold_To__c = \'' + soldToId +'\')');
                    queryParts.add('(Type != \'ZRE\')');
                    queryParts.add('(GBSTK__c != NULL)');
                    queryParts.add('(TotalAmount > 0.00)');
                }

                if (String.isNotBlank(searchText)) {
                    String text = '\'%' + searchText + '%\'';
                    List<String> nameQueryFragment = new List<String>();
                    nameQueryFragment.add('Name LIKE ' + text );
                    nameQueryFragment.add('Account.Name LIKE ' + text );
                    nameQueryFragment.add('Sold_To__r.Name LIKE ' + text );
                    nameQueryFragment.add('Customer_PO_Number__c LIKE ' + text );
                    nameQueryFragment.add('GE_Order_NO__c LIKE ' + text );
                    nameQueryFragment.add('GE_Opportunity_Id__c LIKE ' + text );
                    nameQueryFragment.add('GBSTK__c LIKE ' + text );
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
                return (this.accountId != null || this.soldToId != null);
            }
        }

    }
}
public without sharing class CommunityNotificationsClass {

     //USED TO FETCH OPEN ORDERS FOR THE OPEN ORDERS WIDGET IN COMMUNITY   
   @AuraEnabled(Cacheable=true)
   public static List<Connect_Notification__c> getNotifications(String accountId, String distributorId, String userType){
    String portalType = userType;


        if(portalType == 'Agent' && (distributorId == ' ' || distributorId == null)){
        List<Connect_Notification__c> orderList  =  [SELECT Agent__c, Id, Records_ID__c,
        Name, Date__c, Description__c , Distributor__c,Notification__c, Source__c FROM Connect_Notification__c WHERE (Agent__c =: accountId OR Bypass_Logic__c = true) ORDER BY Date__c DESC LIMIT 5];
        return orderList;
            
        } else if(portalType == 'Agent' && (distributorId != ' ' || distributorId != null)){
            List<Connect_Notification__c> orderList  =  [SELECT Agent__c, Id, Records_ID__c,
            Name, Date__c, Description__c , Distributor__c,Notification__c, Source__c FROM Connect_Notification__c WHERE ((Distributor__c =: distributorId AND Agent__c =: accountId) OR Bypass_Logic__c = true ) ORDER BY Date__c DESC LIMIT 5];
                return orderList;
                
        } else {
            List<Connect_Notification__c> orderList  =  [SELECT Agent__c, Id, Records_ID__c,
            Name, Date__c, Description__c , Distributor__c,Notification__c, Source__c FROM Connect_Notification__c WHERE (Distributor__c =: distributorId OR Bypass_Logic__c = true) ORDER BY Date__c DESC LIMIT 5];
            return orderList;
        }
        
    }

    public class CommunityNotificationsClassException extends Exception {
    }



    @AuraEnabled(Cacheable=true)
    public static List<Connect_Notification__c> getAllNotifications(OrderQuery notificationQuery) {
        System.debug('notificationQuery\n' + JSON.serializePretty(notificationQuery));
        if (notificationQuery == null || !notificationQuery.isQueryValid) {
            throw new CommunityNotificationsClassException('Invalid notificationQuery: ' + JSON.serialize(notificationQuery));
        }
        if(notificationQuery.queryOffset > 2000){
            return null;
        }
        String notificationQueryString = 'SELECT Agent__r.Name, Id, Records_ID__c, Name, Date__c, Description__c , Distributor__r.Name,Notification__c, Source__c FROM Connect_Notification__c ' + notificationQuery.whereClause;
        System.debug('notificationQueryString ' + notificationQueryString);
        List<Connect_Notification__c> orders = Database.query(notificationQueryString);
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
        public String source { get; set; }
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
                    queryParts.add( '( Bypass_Logic__c = true OR (Distributor__c = \'' + soldToId + '\' AND Agent__c = \'' + accountId + '\'))');
                  
                } else if (accountId != null && soldToId == null){ // AGENT ONLY
                    queryParts.add('( Bypass_Logic__c = true OR (Distributor__c = \'' + accountId + '\' OR Agent__c = \'' + accountId + '\'))');
                
                } else { //DISTRIBUTOR ONLY
                    queryParts.add('( Bypass_Logic__c = true OR  (Distributor__c = \'' + soldToId +'\'))');
                
                }

                if (String.isNotBlank(searchText)) {
                    String text = '\'%' + searchText + '%\'';
                    List<String> nameQueryFragment = new List<String>();
                    nameQueryFragment.add('Notification__c LIKE ' + text );
                    nameQueryFragment.add('Description__c LIKE ' + text );
                    nameQueryFragment.add('Name LIKE ' + text );
                    queryParts.add('('+String.join(nameQueryFragment, ' OR ') + ')');
                }
                if (String.isNotBlank(source)) {
                    String text = '\'%' + source + '%\'';
                    List<String> nameQueryFragment = new List<String>();
                    nameQueryFragment.add('Source__c LIKE ' + text );
                    queryParts.add('('+String.join(nameQueryFragment, ' OR ') + ')');
                }
                /*if (fromDate == null && toDate == null) {
                    queryParts.add('(EffectiveDate >= LAST_N_DAYS:365)');
                }*/
                if (fromDate != null && toDate != null) {
                    queryParts.add('(Date__c >= ' + String.valueOf(fromDate) + ' AND Date__c <= ' + String.valueOf(toDate) + ')');
                } else if (toDate != null) {
                    //queryParts.add('(EffectiveDate >= :LAST_N_DAYS:365 AND EffectiveDate <= ' + String.valueOf(toDate) + ')');
                    queryParts.add('(Date__c <= ' + String.valueOf(toDate) + ')');
                } else if (fromDate != null) {
                    queryParts.add('(Date__c >= ' + String.valueOf(fromDate) + ')');
                }
                return ' WHERE ' + String.join(queryParts, ' AND ') + 'ORDER BY Date__c DESC' + ' LIMIT ' + queryLimit + ' OFFSET ' + queryOffset;
            }
        }

        public Boolean isQueryValid {
            get {
                return (this.accountId != null || this.soldToId != null);
            }
        }

    }
}
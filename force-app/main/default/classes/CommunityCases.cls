public without sharing class CommunityCases {
    @AuraEnabled(Cacheable=true)
    public static List<Case> getCases(CaseQuery caseQuery) {
        if (caseQuery.isQueryValid == false || caseQuery.queryOffset > 2000) {
            return null;
        }
        Set<Id> caseIds = caseQuery.caseProducts;

        System.debug('caseQuery\n'+JSON.serializePretty(caseQuery));
        String query = 'SELECT CaseNumber, Number_of_PO_s__c, CreatedDate, Contact.Name, Account.Name, Sold_To_Account__r.Name, GE_NAS_Purchase_Order__c, GE_NAS_Sub_Type__c, Type, Status, Origin FROM Case ' + caseQuery.whereClause;
        System.debug('getOpenCases query ' + query);
        return Database.query(query);
    }

    public class CaseQuery {
        @AuraEnabled
        public Id accountId { get; set; }
        @AuraEnabled
        public Id soldToId { get; set; }
        @AuraEnabled
        public Date fromDate { get; set; }
        @AuraEnabled
        public Date toDate { get; set; }
        @AuraEnabled
        public String searchText { get; set; }
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
        public Boolean isQueryValid {
            get {
                return (this.accountId != null || this.soldToId != null);
            }
        }

        public Set<Id> caseProducts{
            get {
                    List<Shipment_Detail__c> caseProducts = [SELECT Id, GE_NAS_Case_Number__r.Id, Distributor_ID__c FROM Shipment_Detail__c WHERE GE_NAS_Case_Number__r.AccountId =: accountId AND Distributor_ID__c =: soldToId];
                    Set<Id> caseIds = new Set<Id>();
                
                        for(Shipment_Detail__c sd : caseProducts){
                        caseIds.add(sd.GE_NAS_Case_Number__r.Id);
                        }
                        System.debug('Case Products: '+caseProducts);
                        return caseIds;
                    }   
                          
        }

        public String whereClause {
            get {
                List<String> queryParts = new List<String>();

                if (accountId != null && soldToId != null){ //AGENT AND DISTRIBUTOR

                    List<Shipment_Detail__c> caseProducts = [SELECT Id, GE_NAS_Case_Number__r.Id, Distributor_ID__c FROM Shipment_Detail__c WHERE GE_NAS_Case_Number__r.AccountId =: accountId AND Distributor_ID__c =: soldToId];
                    Set<Id> caseIds = new Set<Id>();
                
                        for(Shipment_Detail__c sd : caseProducts){
                        caseIds.add(sd.GE_NAS_Case_Number__r.Id);
                        }
                        System.debug('Case Products: '+caseProducts);
            
                    if (caseProducts.size() > 0){
                        
                        queryParts.add('(Id IN :caseIds OR Sold_To_Account__c = \'' + soldToId + '\')');
                        queryParts.add('(GE_NAS_Sub_Type__c = \'' + 'Warranty Claim'+ 
                        '\' OR GE_NAS_Sub_Type__c = \'' + 'New Spec Registration'+
                        '\' OR GE_NAS_Sub_Type__c = \'' + 'New RGA'+  
                         '\' OR GE_NAS_Sub_Type__c = \'' + 'Connect Platform Support'+
                         '\' OR GE_NAS_Sub_Type__c = \'' + 'Stock Balancing Return'+  
                         '\' OR GE_NAS_Sub_Type__c = \'' + 'When Can I Get It?'+ 
                         '\' OR GE_NAS_Sub_Type__c = \'' + 'Pricing Inquiry'+ 
                         '\' OR GE_NAS_Sub_Type__c = \'' + 'Lighting Application'+ 
                         '\' OR GE_NAS_Sub_Type__c = \'' + 'Marketing Collateral'+ 
                         '\' OR GE_NAS_Sub_Type__c = \'' + 'Lighting Application'+ 
                         '\' OR GE_NAS_Sub_Type__c = \'' + 'Expedite'+ 
                         '\' OR GE_NAS_Sub_Type__c = \'' + 'Change Request'+ 
                         '\' OR GE_NAS_Sub_Type__c = \'' + 'Overage'+ 
                         '\' OR GE_NAS_Sub_Type__c = \'' + 'Shortage'+
                         '\' OR GE_NAS_Sub_Type__c = \'' + 'Lost/Damaged'+
                         '\' OR GE_NAS_Sub_Type__c = \'' + 'Technical Service'+
                         '\' OR GE_NAS_Sub_Type__c = \'' + 'Credits / Debits'+'\')');
                        

                    } else {
                        queryParts.add('(Sold_To_Account__c = \'' + soldToId + '\' AND AccountId = \'' + accountId + '\')');
                        queryParts.add('(GE_NAS_Sub_Type__c = \'' + 'Warranty Claim'+ 
                        '\'OR GE_NAS_Sub_Type__c = \'' + 'New Spec Registration'+
                        '\' OR GE_NAS_Sub_Type__c = \'' + 'New RGA'+   
                        '\' OR GE_NAS_Sub_Type__c = \'' + 'Connect Platform Support'+
                        '\' OR GE_NAS_Sub_Type__c = \'' + 'Pricing Inquiry'+ 
                        '\' OR GE_NAS_Sub_Type__c = \'' + 'Stock Balancing Return'+   
                        '\' OR GE_NAS_Sub_Type__c = \'' + 'When Can I Get It?'+ 
                        '\' OR GE_NAS_Sub_Type__c = \'' + 'Lighting Application'+ 
                        '\' OR GE_NAS_Sub_Type__c = \'' + 'Marketing Collateral'+ 
                        '\' OR GE_NAS_Sub_Type__c = \'' + 'Lighting Application'+ 
                        '\' OR GE_NAS_Sub_Type__c = \'' + 'Expedite'+ 
                        '\' OR GE_NAS_Sub_Type__c = \'' + 'Change Request'+ 
                        '\' OR GE_NAS_Sub_Type__c = \'' + 'Overage'+ 
                        '\' OR GE_NAS_Sub_Type__c = \'' + 'Shortage'+
                        '\' OR GE_NAS_Sub_Type__c = \'' + 'Lost/Damaged'+
                        '\' OR GE_NAS_Sub_Type__c = \'' + 'Technical Service'+
                        '\' OR GE_NAS_Sub_Type__c = \'' + 'Credits / Debits'+'\')');
                    }

                    //queryParts.add('(Sold_To_Account__c = \'' + soldToId + '\' AND AccountId = \'' + accountId + '\')');
                    //queryParts.add('(Status != \'' + 'Closed' + '\' )');
                    //queryParts.add('(Origin = \'' + 'Connect' + '\' )');

                } else if (accountId != null && soldToId == null){ // AGENT ONLY
                    queryParts.add('(Sold_To_Account__c = \'' + accountId + '\' OR AccountId = \'' + accountId + '\')');
                    //queryParts.add('(Status != \'' + 'Closed' + '\' )');
                    //queryParts.add('(Origin = \'' + 'Connect' + '\' )');
                    queryParts.add('(GE_NAS_Sub_Type__c = \'' + 'Warranty Claim'+ 
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'New Spec Registration'+ 
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'New RGA'+  
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Connect Platform Support'+
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Pricing Inquiry'+ 
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Stock Balancing Return'+   
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'When Can I Get It?'+ 
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Lighting Application'+ 
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Marketing Collateral'+ 
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Lighting Application'+ 
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Expedite'+ 
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Change Request'+ 
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Overage'+ 
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Shortage'+
                     '\' OR GE_NAS_Sub_Type__c = \'' + 'Technical Service'+
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Lost/Damaged'+
                                   
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Credits / Debits'+'\')');
                } else { //DISTRIBUTOR ONLY
                    queryParts.add('(Sold_To_Account__c = \'' + soldToId + '\' OR AccountId = \'' + soldToId + '\')');
                    //queryParts.add('(Status != \'' + 'Closed' + '\' )');
                    queryParts.add('(GE_NAS_Sub_Type__c = \'' + 'Warranty Claim'+ 
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'New Spec Registration'+ 
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'New RGA'+  
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Connect Platform Support'+
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Pricing Inquiry'+ 
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Stock Balancing Return'+   
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'When Can I Get It?'+ 
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Lighting Application'+ 
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Marketing Collateral'+ 
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Lighting Application'+ 
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Expedite'+ 
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Change Request'+ 
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Overage'+ 
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Shortage'+
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Lost/Damaged'+
                     '\' OR GE_NAS_Sub_Type__c = \'' + 'Technical Service'+
                    '\' OR GE_NAS_Sub_Type__c = \'' + 'Credits / Debits'+'\')');                    //queryParts.add('(Origin = \'' + 'Connect' + '\' )');
                }




                
                if (String.isNotBlank(searchText)) {
                    String text = '\'%' + searchText + '%\'';
                    List<String> nameQueryFragment = new List<String>();
                    nameQueryFragment.add('CaseNumber LIKE ' + text);
                    nameQueryFragment.add('Subject LIKE ' + text);
                    nameQueryFragment.add('Sold_To_Account__r.Name LIKE ' + text);
                    nameQueryFragment.add('GE_NAS_Sub_Type__c LIKE ' + text);
                    nameQueryFragment.add('GE_NAS_Purchase_Order__c LIKE ' + text);
                    nameQueryFragment.add('Status LIKE ' + text);
                    nameQueryFragment.add('Origin LIKE ' + text);
                   
                    queryParts.add('(' + String.join(nameQueryFragment, ' OR ') + ')');
                }
                /*if (fromDate == null && toDate == null) {
                    queryParts.add('(EffectiveDate >= LAST_N_DAYS:365)');
                }*/
                if (fromDate != null && toDate != null) {
                    queryParts.add('(DAY_ONLY(CreatedDate) >= ' + String.valueOf(fromDate) + 'AND DAY_ONLY(CreatedDate) <= ' + String.valueOf(toDate) + ')');
                } else if (toDate != null) {
                    //queryParts.add('(EffectiveDate >= :LAST_N_DAYS:365 AND EffectiveDate <= ' + String.valueOf(toDate) + ')');
                    queryParts.add('(DAY_ONLY(CreatedDate) <= ' + String.valueOf(toDate) + ')');
                } else if (fromDate != null) {
                    queryParts.add('(DAY_ONLY(CreatedDate) >= ' + String.valueOf(fromDate) + ')');
                }
                return ' WHERE ' + String.join(queryParts, ' AND ') + 'ORDER BY CreatedDate DESC' + ' LIMIT ' + queryLimit + ' OFFSET ' + queryOffset;
            }
        }
    }
}
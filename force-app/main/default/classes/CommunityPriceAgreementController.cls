public without sharing class CommunityPriceAgreementController {
    @AuraEnabled(Cacheable=true)
    public static List<SAP_Price_Agreement__c> getPriceAgreements(Integer queryLimit) {
        if (queryLimit == null) {
            queryLimit = Limits.getLimitQueryRows();
        }
        User u = [
            SELECT Id,
            ContactId,
            Account.GE_LGT_Rep_Code__c,
            AccountId
            FROM User
            WHERE Id = :UserInfo.getUserId()
            //WHERE ContactId = '0032F00000e7iVvQAI'
        ];
        if (u.AccountId == null) {
            return new List<SAP_Price_Agreement__c>();
        }
        System.debug('u: ' + u);
        System.debug('u.Account.GE_LGT_Rep_Code__c: ' + u.Account.GE_LGT_Rep_Code__c);
        if (String.isEmpty(u.Account.GE_LGT_Rep_Code__c)) {
            return getPriceAgreementsByCustomerNumber(u.AccountId, 10000);
        } else {
            return getPriceAgreementsByAgent(u.AccountId, queryLimit);
        }
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<SAP_Price_Agreement__c> getPriceAgreementsv2(String accountId, String distributorId, String userType, String distributorNumber){
        String portalType = userType;
        String Segmentation;
        Date tMinus30Days = Date.today().addDays(-30);
        if(accountId != ' ' && accountId != null && accountId != 'undefined'){
            Account Acc = [select Customer_Segmentation__c from Account where id=:accountId limit 1];
            Segmentation= Acc.Customer_Segmentation__c;
        }
        if(portalType == 'Agent' && (distributorId == ' ' || distributorId == 'undefined' || distributorId == null)){
            List<SAP_Price_Agreement__c> paList  =  [
                SELECT
                Id,
                Agreement_No__c,
                Agent_Name__c,
                Agreement_Type__c,
                CurrencyIsoCode,
                Customer_Name__c,
                Agreement_Subtotal__c,
                Description__c,
                Extended_Description__c,
                Customer_List__c,
                Expiration_Date__c
                FROM SAP_Price_Agreement__c
                WHERE
                Fixture_Agent__c = :accountId AND
                Release_Status__c!='Blocked' AND
                Expiration_Date__c >= :tMinus30Days
                ORDER BY Expiration_Date__c
                DESC
                //LIMIT 5
            ];
            
            return paList;
            
        } else if(portalType == 'Agent' && (distributorId != ' ' || distributorId != null) && (Segmentation== 'FD' || Segmentation == 'Fixture')){
            List<SAP_Price_Agreement__c> paList = new List<SAP_Price_Agreement__c>();
            for(SAP_Price_Agreement__c sapPriceAgreement : [
                SELECT
                Id,
                Agreement_No__c,
                Agent_Name__c,
                Agreement_Type__c,
                Agreement_Subtotal__c,
                CurrencyIsoCode,
                Customer_Name__c,
                Description__c,
                Extended_Description__c,
                Customer_List__c,
                Expiration_Date__c
                FROM SAP_Price_Agreement__c
                WHERE
                Fixture_Agent__c = :accountId AND
                Release_Status__c!='Blocked' AND
                /*(Bill_To_Customer_No__c =:distributorNumber AND Fixture_Agent__c = :accountId AND*/
                Expiration_Date__c >= :tMinus30Days
                ORDER BY Expiration_Date__c
                DESC
                //LIMIT 5
            ]){
                if (String.isNotBlank(sapPriceAgreement.Customer_List__c)) {
                    List<String> customerNumbers = sapPriceAgreement.Customer_List__c.split(',');
                    if (customerNumbers.contains(distributorNumber)) {
                        paList.add(sapPriceAgreement);
                        
                    }
                }
            }
            
            return paList;
            
        }
        else if(portalType == 'Agent' && (distributorId != ' ' || distributorId != null) && (Segmentation== 'LB' || Segmentation.toLowerCase() == 'lamp')){
            return getPriceAgreementsByCustomerNumber(distributorId, 10000);
        }
        else if(portalType == 'Distributor'){
            return getPriceAgreementsByCustomerNumber(distributorId, 10000);
        }
        return null;
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<SAP_Price_Agreement__c> getPriceAgreementsforWidget(String accountId, String distributorId, String userType, String distributorNumber){
        String portalType = userType;
        Date tMinus30Days = Date.today().addDays(-30);
        String Segmentation;
        if(accountId != ' ' && accountId != null && accountId != 'undefined'){
       		 Account Acc = [select Customer_Segmentation__c from Account where id=:accountId limit 1];
        	 Segmentation= Acc.Customer_Segmentation__c;
        }
        if(portalType == 'Agent' && (distributorId == ' ' || distributorId == 'undefined' || distributorId == null)){
            List<SAP_Price_Agreement__c> paList  =  [
                SELECT
                Id,
                Agreement_No__c,
                Agent_Name__c,
                Agreement_Type__c,
                CurrencyIsoCode,
                Customer_Name__c,
                Agreement_Subtotal__c,
                Description__c,
                Extended_Description__c,
                Customer_List__c,
                Expiration_Date__c
                FROM SAP_Price_Agreement__c
                WHERE
                Fixture_Agent__c = :accountId AND
                Release_Status__c!='Blocked' AND
                Expiration_Date__c >= :tMinus30Days
                ORDER BY Expiration_Date__c
                DESC
                LIMIT 5
            ];
            
            return paList;
            
        } else if(portalType == 'Agent' && (distributorId != ' ' || distributorId != null) && (Segmentation== 'FD' || Segmentation == 'Fixture')){
            List<SAP_Price_Agreement__c> paList = new List<SAP_Price_Agreement__c>();
            for(SAP_Price_Agreement__c sapPriceAgreement : [
                SELECT
                Id,
                Agreement_No__c,
                Agent_Name__c,
                Agreement_Type__c,
                Agreement_Subtotal__c,
                CurrencyIsoCode,
                Customer_Name__c,
                Description__c,
                Extended_Description__c,
                Customer_List__c,
                Expiration_Date__c
                FROM SAP_Price_Agreement__c
                WHERE
                Fixture_Agent__c = :accountId AND
                Release_Status__c!='Blocked' AND
                /*(Bill_To_Customer_No__c =:distributorNumber AND Fixture_Agent__c = :accountId AND*/
                Expiration_Date__c >= :tMinus30Days
                ORDER BY Expiration_Date__c
                DESC
                //LIMIT 5
            ]){
                if (String.isNotBlank(sapPriceAgreement.Customer_List__c)) {
                    List<String> customerNumbers = sapPriceAgreement.Customer_List__c.split(',');
                    if (customerNumbers.contains(distributorNumber)) {
                        paList.add(sapPriceAgreement);
                        if (paList.size() == 5) {
                            break;
                            
                        }
                    }
                }
            }
            
            return paList;
            
        }
        else if(portalType == 'Agent' && (distributorId != ' ' || distributorId != null) && (Segmentation== 'LB' || Segmentation.toLowerCase() == 'lamp')){
            return getPriceAgreementsByCustomerNumber(distributorId, 5);   
        }
        else if(portalType == 'Distributor'){
            return getPriceAgreementsByCustomerNumber(distributorId, 5);
        }
        return null;
    }
    
    private static List<SAP_Price_Agreement__c> getPriceAgreementsByCustomerNumber(Id accountId, Integer queryLimit) {
        Account acct = [SELECT GE_LGT_EM_SAP_Customer_Number__c, SAP_Parent_Customer_No__c FROM Account WHERE Id = :accountId];
        String sapParentCustomerNumber;
        if (String.isNotBlank(acct.SAP_Parent_Customer_No__c)) {
            sapParentCustomerNumber = acct.SAP_Parent_Customer_No__c.split('_')[0];
        }
        List<SAP_Price_Agreement__c> validAgreements = new List<SAP_Price_Agreement__c>();
        Date tMinus30Days = Date.today().addDays(-30);
        for (SAP_Price_Agreement__c sapPriceAgreement : [
            SELECT Id, Agreement_No__c, Agent_Name__c, Agreement_Type__c, CurrencyIsoCode, Customer_Name__c, Description__c,Extended_Description__c,Customer_List__c,Agreement_Subtotal__c,Expiration_Date__c
            FROM SAP_Price_Agreement__c
            WHERE Expiration_Date__c >= :tMinus30Days AND
            Release_Status__c!='Blocked'
            ORDER BY Expiration_Date__c DESC
            //LIMIT :queryLimit
        ]) {
            if (String.isNotBlank(sapPriceAgreement.Customer_List__c)) {
                List<String> customerNumbers = sapPriceAgreement.Customer_List__c.split(',');
                if (customerNumbers.contains(acct.GE_LGT_EM_SAP_Customer_Number__c) || customerNumbers.contains(sapParentCustomerNumber)) {
                    validAgreements.add(sapPriceAgreement);
                    if (validAgreements.size() == queryLimit) {
                        break;
                        
                    }
                }
            }
        }
        return validAgreements;
    }
    
    private static List<SAP_Price_Agreement__c> getPriceAgreementsByAgent(Id accountId, Integer queryLimit) {
        if (queryLimit == null) {
            queryLimit = Limits.getLimitQueryRows();
        }
        Date tMinus30Days = Date.today().addDays(-30); //Removed as it would show current date and above //W-000623 //added back
        //Date tMinus30Days = Date.today();
        return [
            SELECT Id, Agreement_No__c, Agent_Name__c, Agreement_Type__c, CurrencyIsoCode, Customer_Name__c, Description__c,Customer_List__c,Expiration_Date__c
            FROM SAP_Price_Agreement__c
            WHERE Fixture_Agent__c = :accountId
            AND Expiration_Date__c >= :tMinus30Days
            ORDER BY Expiration_Date__c DESC
            LIMIT :queryLimit
        ];
    }
    
    @AuraEnabled
    public static String modify(String priceAgreementNum, Boolean isRevise) {
        PriceAgreementToCart priceAgreement = new PriceAgreementToCart(priceAgreementNum);
        String url = priceAgreement.toUrl(isRevise);
        system.debug('TDBG url '+url);
        return url;
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<SAP_Price_Agreement__c> getPriceAgreementByAccountSelector (String accountId, String distributorId, String userType, String distributorNumber, Integer queryLimit){
        List<SAP_Price_Agreement__c> priceAgreementReturnList = new List<SAP_Price_Agreement__c>();
        if (queryLimit == null) {queryLimit = Limits.getLimitQueryRows();}
        Date tMinus30Days = Date.today().addDays(-30);
        
        switch on userType{
            when 'Agent'{
                if(accountId == null){return priceAgreementReturnList;}
                priceAgreementReturnList = [
                    SELECT Id, Valid_From__c, Agreement_No__c, Agent_Name__c, Agreement_Type__c, CurrencyIsoCode, Customer_Name__c, Description__c,Customer_List__c,Expiration_Date__c,Agreement_Subtotal__c
                    FROM SAP_Price_Agreement__c
                    WHERE Fixture_Agent__c = :accountId
                    AND Expiration_Date__c >= :tMinus30Days
                    ORDER BY Expiration_Date__c DESC
                    LIMIT :queryLimit];
            }
            when 'Distributor'{
                if(distributorNumber == null){return priceAgreementReturnList;}
                priceAgreementReturnList = [
                    SELECT Id, Valid_From__c, Agreement_No__c, Agent_Name__c, Agreement_Type__c, CurrencyIsoCode, Customer_Name__c, Description__c,Customer_List__c,Expiration_Date__c,Agreement_Subtotal__c
                    FROM SAP_Price_Agreement__c
                    WHERE Bill_To_Customer_No__c = :distributorNumber
                    AND Expiration_Date__c >= :tMinus30Days
                    ORDER BY Expiration_Date__c DESC
                    LIMIT :queryLimit];
            }
        }
        
        return priceAgreementReturnList;
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<SAP_Price_Agreement__c> getPriceAgreementDetail(String agreementID){
        
        Map<String, String> getUOMMapping = new Map<String, String>();
        for(UOM_Mapping__mdt um:[SELECT Code__c, DeveloperName FROM UOM_Mapping__mdt]){
            getUOMMapping.put(um.Code__c,um.DeveloperName);
        }
        
        List<SAP_Price_Agreement__c> result=[SELECT Id,
                                             Agreement_No__c,
                                             Agreement_Type__c,
                                             Valid_From__c,
                                             Expiration_Date__c,
                                             Agent_Name__c,
                                             Agent_Number__c,
                                             Fixture_Agent__r.name,
                                             Fixture_Agent__r.ShippingAddress,
                                             Extended_Description__c,
                                             Description__c,
                                             Release_Status__c,
                                             Grand_Total__c,
                                             Bill_To_Customer_No__c,
                                             Customer_Name__c,
                                             CurrencyIsoCode,                           
                                             (SELECT Id,Item_Description__c,Quantity__c,Sales_Price__c,Material_No__c,UOM__c,
                                              ValidFrom__c,ValidTo__c
                                              FROM SAP_Price_Agreement_Items__r WHERE ValidTo__c >= TODAY AND DeletionFlag__c !='X' ORDER BY Condition_No__c)
                                             FROM SAP_Price_Agreement__c WHERE id=:agreementID];
        
        
        for(SAP_Price_Agreement__c head: result){
            for(SAP_Price_Agreement_Item__c item:head.SAP_Price_Agreement_Items__r){
                
                item.UOM__c=getUOMMapping.get(item.UOM__c);
            }
            
        }
        
        return result;
        
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<Account> getCustListDetail(String agreementID, String userType , String userDetail){
        
        List<Account> result = new List<Account>();
        List<Account> allrelatedAccObj = new List<Account>();
        Set<String> allrelatedAccNum = new Set<String>();
        Set<String> matchedAccount = new Set<String>();
        
        
        List<String> customerNos = new List<String>();
        SAP_Price_Agreement__c PA=[Select id,Customer_List__c From SAP_Price_Agreement__c where id=:agreementID LIMIT 1];
        
        if(PA.Customer_List__c != null){ 
            customerNos = PA.Customer_List__c.split(',');
        }   
        
        if(userType=='Agent'){
            String likeString = '%'+userDetail+'%';
            //Changes by Ravi Singh for CON-280
            allrelatedAccObj=[Select id,GE_LGT_EM_SAP_Customer_Number__c From Account where ConnectFixtureAgents__c  LIKE: likeString or Connect_Share_with_Account_PartA__c LIKE: likeString or Connect_Share_with_Account_PartB__c LIKE: likeString or Connect_Share_with_Account_PartC__c LIKE:likeString];
            for(Account ac:allrelatedAccObj){
                allrelatedAccNum.add(ac.GE_LGT_EM_SAP_Customer_Number__c);                
            }
            allrelatedAccObj.clear();
            for(String temp: customerNos){
                if(allrelatedAccNum.contains(temp)){
                    matchedAccount.add(temp);
                }
                
            }
            customerNos.clear(); 
            result=[Select id,Name,Customer_Segmentation__c,GE_LGT_EM_SAP_Customer_Number__c,ShippingAddress from Account where GE_LGT_EM_SAP_Customer_Number__c IN:matchedAccount and GE_LGT_EM_Sales_Org__c in ('1US1','1CA1')] ;
        }
        else if (userType=='Distributor'){
            //CON-231 changes by Ravi Singh for Distributor login
            for (AccountContactRelation relList : [SELECT account.GE_LGT_EM_SAP_Customer_Number__c FROM AccountContactRelation WHERE ContactId =: userDetail ]){
                allrelatedAccNum.add(relList.account.GE_LGT_EM_SAP_Customer_Number__c);
            }
            
            for(String temp: customerNos){
                if(allrelatedAccNum.contains(temp)){
                    matchedAccount.add(temp);
                }
                
            }
            customerNos.clear(); 
            result=[Select id,Name,Customer_Segmentation__c,GE_LGT_EM_SAP_Customer_Number__c,ShippingAddress from Account where GE_LGT_EM_SAP_Customer_Number__c IN:matchedAccount and GE_LGT_EM_Sales_Org__c in ('1US1','1CA1')] ;
            
        }
        
        
        
        return result;
        
    }
}
public class PriceAgreementServices {
    public static List<SAP_Price_Agreement__c> searchPriceAgreementAgent(String accountId){

        Date today = Date.today();
        return [SELECT Id, Fixture_Agent__c,
                Agent_Name__c,
                Name,
                Agreement_No__c,
                Agreement_Type__c,
                Created_Date_Time__c,
                CurrencyIsoCode,
                Customer_Name__c,
                Description__c,
                End_User_Customer_No__c,
                Expiration_Date__c,
                Extended_Description__c,
                Grand_Total__c,
                Last_Modified_DateTime__c,
                Opportunity_Name__c,
                Agent_Number__c,
                Strategic_Account__c,
                Strategic_Partner_Name__c,
                Valid_From__c,
                Fixture_Agent_Integration_Key__c,
                Agreement_Subtotal__c,
                Bill_To_Customer_No__c,
                CreatedById,
                Currency_ISO__c,
                Customer_List__c,
                (SELECT Material_No__c, Agreement_No__c, Expiration_Date__c,
                Price_Per_BX__c, Price_Per_CV__c, Price_Per_EA__c,
                Price_Per_ICV__c, Price_Per_PC__c, Sales_Price__c FROM SAP_Price_Agreement_Items__r)
                FROM SAP_Price_Agreement__c WHERE Fixture_Agent__c =: accountId AND Expiration_Date__c >=: today];
    }

    public static List<SAP_Price_Agreement_Item__c> getValidPriceAgreementItems(String agreementNo, String description){
         //CON-246 changes by Ravi Singh for material desc
        System.debug('Inside getValidPriceAgreementItems, Before executing query: '+System.now().format('yyyy-dd-mm HH:mm:ss'));
        system.debug('agreementNo '+agreementNo);
        system.debug('description '+description);
        return [SELECT Id, Agreement_No__c, Sales_Price__c, Price_Per_BX__c, Price_Per_CV__c, Price_Per_EA__c, Price_Per_ICV__c,Price_Per_PC__c,Price_Per_NL__c,Price_Per_NP__c FROM SAP_Price_Agreement_Item__c WHERE Agreement_No__c =: agreementNo AND Item_Description__c =: description AND ValidFrom__c<= TODAY AND ValidTo__c >= TODAY AND DeletionFlag__c !='X' ORDER BY Condition_No__c];
    }

    public static List<SAP_Price_Agreement__c> searchPriceAgreementCustomer(String accountId){

        Date today = Date.today();
        Account acct = [SELECT GE_LGT_EM_SAP_Customer_Number__c FROM Account WHERE Id =: accountId];

        List<SAP_Price_Agreement__c> validAgreements = new List<SAP_Price_Agreement__c>();

        List<String> customerNos = new List<String>();

        for(SAP_Price_Agreement__c agreement : [SELECT Id,
                                    Agreement_No__c,
                                    Customer_List__c
                                    FROM SAP_Price_Agreement__c 
                                    WHERE 
                                        (Agreement_Type__c='ZPRJ' OR Agreement_Type__c='ZOTP') 
                                        AND Release_Status__c!='Blocked' 
                                        AND Expiration_Date__c >=: today]){
            if(agreement.Customer_List__c != null){
                customerNos = agreement.Customer_List__c.split(',');
                if(customerNos.contains(acct.GE_LGT_EM_SAP_Customer_Number__c)){
                    validAgreements.add(agreement);
                }
            }
        }
        return validAgreements;
    }

    public static List<SAP_Price_Agreement__c> searchPriceAgreementCustomerOld(String accountId){

        return [SELECT Id, Agreement_No__c,
                (SELECT Id, Material_No__c, Sales_Price__c FROM SAP_Price_Agreement_Items__r)
                FROM SAP_Price_Agreement__c
                WHERE Id IN (SELECT SAP_Price_Agreement__c FROM SAP_Price_Agreement_Customers__c WHERE Account__c =: accountId)];
    }

    public static List<SAP_Price_Agreement_Item__c> getItemsByAgreementNoAndSkus(String agreementNo, List<String> skus){

        return [SELECT Id, Sales_Price__c, Material_No__c, Quantity__c, Price_Per_BX__c, Price_Per_CV__c, Price_Per_EA__c,
                            Price_Per_ICV__c, Price_Per_PC__c, UnitOfMeasure__c,UOM__c,Item_Description__c FROM SAP_Price_Agreement_Item__c WHERE Agreement_No__c =: agreementNo AND Material_No__c IN :skus ORDER BY Condition_No__c];
    }

    public static List<SAP_Price_Agreement_Item__c> getItemsByAgreementNo(String agreementNo){
        Date today = Date.today();
        SAP_Price_Agreement__c agreement = [SELECT Expiration_Date__c FROM SAP_Price_Agreement__c WHERE Agreement_No__c = :agreementNo];
        Date expirationDate = agreement.Expiration_Date__c;
        List<SAP_Price_Agreement_Item__c> response;
        if(expirationDate >= today) {
            // present or future
            // Bring only those line items into the cart, which have (Valid From as today or past) AND (Valid to as today or future)
            response = [SELECT Id, Sales_Price__c, Material_No__c, Quantity__c, Price_Per_BX__c, Price_Per_CV__c, Price_Per_EA__c,
            Price_Per_ICV__c, Price_Per_PC__c, UnitOfMeasure__c,UOM__c,Item_Description__c FROM SAP_Price_Agreement_Item__c WHERE Agreement_No__c = :agreementNo and (ValidFrom__c <= :today and ValidTo__c >= :today ) and DeletionFlag__c !='X' ORDER BY Condition_No__c];
        } else {
            // past
            // Bring only those line items into the cart, which have same expiration date as the header
            response = [SELECT Id, Sales_Price__c, Material_No__c, Quantity__c, Price_Per_BX__c, Price_Per_CV__c, Price_Per_EA__c,
            Price_Per_ICV__c, Price_Per_PC__c, UnitOfMeasure__c,UOM__c,Item_Description__c FROM SAP_Price_Agreement_Item__c WHERE Agreement_No__c = :agreementNo and ValidTo__c = :expirationDate and DeletionFlag__c !='X' ORDER BY Condition_No__c];
        }
        return response;
        //return [SELECT Id, Sales_Price__c, Material_No__c, Quantity__c, Price_Per_BX__c, Price_Per_CV__c, Price_Per_EA__c,
        //                    Price_Per_ICV__c, Price_Per_PC__c, UnitOfMeasure__c,UOM__c,Item_Description__c FROM SAP_Price_Agreement_Item__c WHERE Agreement_No__c =: agreementNo];
    }

    public static Map<String,Boolean> isPriceAgreementValidForTheseProducts(String accountId, Set<String> skus){
        System.debug('isPriceAgreementValidForTheseProducts' + accountId);

        Account acc = [
            SELECT Id, GE_LGT_EM_SAP_Customer_Number__c, Account_Group__c, GE_LGT_Rep_Code__c
            FROM Account
            WHERE Id = :accountId
        ];

        System.debug('isPriceAgreementValidForTheseProducts' + skus);
        Map<String,Boolean>  mapSkuPA = new Map<String,Boolean>();
        Set<String> lpanos = new Set<String>();
        for (String s : skus){
            mapSkuPA.put(s, false);
        }
        List<SAP_Price_Agreement__c> lpa = new List<SAP_Price_Agreement__c>();

        if(String.isNotBlank(acc.Account_Group__c) && acc.Account_Group__c == 'ZEAG'){
            System.debug('isPriceAgreementValidForTheseProducts for agent' + acc.GE_LGT_EM_SAP_Customer_Number__c);
            //lpa = searchPriceAgreementAgent(accountId);
        } else {
            System.debug('isPriceAgreementValidForTheseProducts for distributor' + acc.GE_LGT_EM_SAP_Customer_Number__c);
            //lpa = searchPriceAgreementCustomer(accountId);
        }

        System.debug('isPriceAgreementValidForTheseProducts' + lpa);
        System.debug('isPriceAgreementValidForTheseProducts' + lpa.size());
        /*if(lpa != null && lpa.size() > 0){
            for (SAP_Price_Agreement__c pa : lpa){
                lpanos.add(pa.Agreement_No__c);
            }
            System.debug('isPriceAgreementValidForTheseProducts' + lpanos);
            for (String pa : lpanos){
                System.debug('isPriceAgreementValidForTheseProducts pa=' + pa);
            }

            List<SAP_Price_Agreement_Item__c> paiList = getItemsByAgreementNoAndSkus(lpanos, skus);
            System.debug('isPriceAgreementValidForTheseProducts paiList=' + paiList.size());
            if(paiList != null && paiList.size() > 0){
                for (String s : skus){
                    for(SAP_Price_Agreement_Item__c pai: paiList){
                        if(pai.Material_No__c == s){
                            System.debug('isPriceAgreementValidForTheseProducts pa=' + pai.Material_No__c + '****' + s);
                            mapSkuPA.put(s, true);
                        }
                    }
                }
            }
        }*/

        return mapSkuPA;
    }

    public static List<SAP_Price_Agreement_Item__c> getItemsByAgreementNoAndSkus(Set<String> agreementNos, Set<String> skus){
        return [SELECT Id, Sales_Price__c, Material_No__c,Item_Description__c FROM SAP_Price_Agreement_Item__c WHERE Agreement_No__c IN :agreementNos AND Material_No__c IN :skus  ORDER BY Condition_No__c];
    }
}
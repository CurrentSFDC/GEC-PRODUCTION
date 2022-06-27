/********************************************************************
Purpose: Controller for priceAgreementSelection component. Searches for Price Agreement records based on search string,
            and populates price agreement table.

History:
--------
VERSION  AUTHOR       DATE         DESCRIPTION
1.0      Nate Kanyok  11-Dec-2020  Created
*/
public class PASelectionController {
    @AuraEnabled
    public static List<sObject> searchForPAs(String searchText) {

        Id userId = UserInfo.getUserId();
        User u = [SELECT Id, ContactId, Account.GE_LGT_Rep_Code__c, Account.Id FROM User WHERE Id = : userId];
        Id getContactId = u.contactId;

        String searchString = '%'+searchText+'%';
        List<sObject> results = new List<sObject>();
        List<sObject> resultsWithFilterDescription = new List<sObject>();
        for(SAP_Price_Agreement__c sapPA:(List<SAP_Price_Agreement__c>)initPriceAgreements()){
            if(!String.isEmpty(sapPA.Description__c) && (sapPA.Description__c.toLowerCase().contains(searchText.toLowerCase()) || sapPA.Description__c.toLowerCase()==searchText.toLowerCase())){
                resultsWithFilterDescription.add(sapPA);
            }
        }

        if(String.isEmpty(u.Account.GE_LGT_Rep_Code__c)){
            //user is distributor
            results = [SELECT Id, Fixture_Agent__c,
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
            FROM SAP_Price_Agreement__c
                            WHERE (Name LIKE :searchString
                                    OR Agent_Name__c LIKE: searchString
                                    OR Agreement_No__c LIKE :searchString
                                    OR Agreement_Type__c LIKE :searchString
                                    OR Customer_Name__c LIKE :searchString) AND Expiration_Date__c >=:Date.today()];
        }
        else{
            //user is agent
            results = [SELECT Id, Fixture_Agent__c,
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
            FROM SAP_Price_Agreement__c
                            WHERE (Name LIKE :searchString
                                    OR Agent_Name__c LIKE: searchString
                                    OR Agreement_No__c LIKE :searchString
                                    OR Agreement_Type__c LIKE :searchString
                                    OR Customer_Name__c LIKE :searchString)
                                AND Fixture_Agent__c =: u.Account.Id AND Expiration_Date__c >=:Date.today()];
        }

        Set<Id> resultsIds=new Set<Id>();
        for(Sobject resultValue:results){
            resultsIds.add(resultValue.Id);
        }



        if(!resultsWithFilterDescription.isEmpty()){
            for(Sobject pa:resultsWithFilterDescription)
            {
                if(!resultsIds.contains(pa.Id)){
                    results.add(pa);
                }
            }
        }
        results.sort();
        system.debug(results);
        return results;
    }

    @AuraEnabled
    public static List<sObject> initPriceAgreements(){

        Id userId = UserInfo.getUserId();
        User u = [SELECT Id,
                         ContactId,
                         Account.GE_LGT_Rep_Code__c,
                         Account.Id
                 FROM User
                 WHERE Id = : userId];
        Id accountId = u.Account.Id;


        List<sObject> results = new List<sObject>();
        if(String.isEmpty(u.Account.GE_LGT_Rep_Code__c)){
            results = PriceAgreementServices.searchPriceAgreementCustomer((String)accountId);
        }
        else{
            results = PriceAgreementServices.searchPriceAgreementAgent((String)accountId);
        }
        return results;
    }

    @AuraEnabled
    public static String modify(String priceAgreementNum, Boolean isRevise){
        PriceAgreementToCart priceAgreement = new PriceAgreementToCart(priceAgreementNum);
        String url = priceAgreement.toCart(isRevise);
        return url;
    }
}
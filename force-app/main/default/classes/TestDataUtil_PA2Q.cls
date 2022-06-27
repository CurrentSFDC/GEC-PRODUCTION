public class TestDataUtil_PA2Q 
{
    public static List<Account> createAccounts(Integer noOfAccounts)
    {
        List<Account> accList = new List<Account>();
        for(Integer i=0;i<noOfAccounts;i++)
        {
            Account acc=new Account();
            acc.Name='Test Account-'+i;
            acc.BillingCountry='United States';
            acc.ShippingCountry='United States';
            acc.GE_LGT_EM_Sales_Org__c='1HU1';
            acc.GE_LGT_EM_Partner_Function__c='Sold To Party';
            acc.CurrencyIsoCode='USD';
            acc.GE_LGT_EM_Distribution_Channel__c='10';
            acc.GE_LGT_EM_Division__c='10';
            acc.GE_NAS_Language__c='English';
            acc.Account_Group__c = 'ZSTG';
            accList.add(acc);
        }
        return accList;
    }
    public static List<Opportunity> createOpportunities(Integer noOfOppties,Account acc)
    {
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i=0;i<noOfOppties;i++)
        {
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Oppty-'+i;
            opp.StageName = 'S1 Consult';
            opp.AccountID = acc.id;
            opp.CurrencyIsoCode ='USD';
            opp.Probability = 10;
            opp.Distribution_Channel__c ='No';
            opp.Going_through_agent__c ='No';
            opp.CloseDate = System.Today() + 20;
            opp.PO_Receipt_Date__c = System.Today() + 20;
            opp.GE_LGT_Expected_PO_Receipt_Date__c = System.Today() + 40;
            opp.GE_LGT_Expected_Ship_Date__c = System.Today() + 45;
            opp.Warranty__c = 'Standard Product Warranty';
            opp.GE_LGT_Reason_Won_Lost__c='Customer Cancelled';
            opp.GE_LGT_SIMPLESALES__c='Yes';
            oppList.add(opp);
        }
        return oppList;
    }
    
    public static List<SAP_Price_Agreement__c> createPriceAgreements(Integer noOfAgreements,Integer startNum)
    {
        List<SAP_Price_Agreement__c> agreementList = new List<SAP_Price_Agreement__c>();
        for(Integer i=0;i<noOfAgreements;i++)
        {
            SAP_Price_Agreement__c agreement = new SAP_Price_Agreement__c();
            agreement.Name = String.valueOf(startNum+i);
            agreement.Agreement_No__c = String.valueOf(startNum+i);
            agreement.Expiration_Date__c = Date.today()+10;
            agreement.Last_Modified_DateTime__c = DateTime.now();
            agreementList.add(agreement);
        }
        return agreementList;
    }
    
    public static List<SAP_Price_Agreement_Item__c> createPriceAgreementItems(Integer noOfAgreementItems,Integer startNum)
    {
        List<SAP_Price_Agreement_Item__c> agreementItemList = new List<SAP_Price_Agreement_Item__c>();
        for(Integer i=0;i<noOfAgreementItems;i++)
        {
            SAP_Price_Agreement_Item__c agreementItem = new SAP_Price_Agreement_Item__c();
            agreementItem.Name = String.valueOf(startNum+i);
            agreementItem.Quantity__c = 20;
            agreementItem.Sales_Price__c = 20;
            agreementItem.Condition_No__c = String.valueOf(startNum+i);
            agreementItemList.add(agreementItem);
        }
        return agreementItemList;
    }
    
    public static List<Quote> createQuotes(Integer noOfQuotes,Integer quoteNum)
    {
        List<Quote> quoteList = new List<Quote>();
        for(Integer i=0;i<noOfQuotes;i++)
        {
            Quote quote=new Quote();
            quote.Name= 'Quote Name-'+quoteNum+i;
            quote.ExpirationDate=Date.today()+5;
            quoteList.add(quote);
        }
        return quoteList;
    }
    public static QuoteLineItem createQuoteItem(String quoteNum,String quoteItemNum)
    {
        QuoteLineItem quoteItem=new QuoteLineItem();
        quoteItem.Quote_Number__c=quoteNum;
        quoteItem.Quote_Item_Number__c=quoteItemNum;
        quoteItem.SKU__c='93036710';
        quoteItem.SKU_Description_Cat_Logic__c='35-963370-15';
        quoteItem.UnitPrice=200;
        quoteItem.Quantity=500;
        quoteItem.Quote_Item_External_ID__c=quoteNum+quoteItemNum;
        return quoteItem;
    }
}
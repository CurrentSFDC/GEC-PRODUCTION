/*
Name - BA_012_TermAndPromoAgreementsCreate
Test Class - BA007_ProcessAgreementItems_Test
Author - Matthew Gugumuck
Purpose - To Create both Term and Promo CC Price Lists from SAP Price Agreement Header
Created Date - Sep-2017
*/
global class BA_012_TermAndPromoAgreementsCreate implements Database.Batchable<sobject>
{    
    global String [] email = new String[] {'salesforcesupport@gecurrent.com'};
    global Database.Querylocator start (Database.BatchableContext BC) 
    {
        System.debug('STEP 1: GETTING ALL SAP PRICE AGREEMENTS THAT ARE ZTRM OR ZPRO....');
        return Database.getQueryLocator('Select id, Name, Agreement_Type__c, Expiration_Date__c, CurrencyIsoCode, Valid_From__c, Customer_List__c FROM SAP_Price_Agreement__c where Agreement_Type__c = \'ZTRM\' OR Agreement_Type__c = \'ZPRO\'');
    }
    global void execute (Database.BatchableContext BC, List<SAP_Price_Agreement__c> itemList ) 
    {
        StaticVariables.runningQuoteItemBatch = true;
       
        //PRE PROCESSING SOQL QUERIES

            //PRICE AGREEMENT ITEM MAP
           /* Map<Id, String> paMap = new Map<Id, String>();
            List<SAP_Price_Agreement_Item__c> priceItems = [SELECT Id FROM SAP_Price_Agreement_Item__c WHERE Price_Agreement__c IN :itemList ];
                for (SAP_Price_Agreement_Item__c pa : priceItems){
                    paMap.put(pa.Id ,String.ValueOf(pa.Price_Agreement__c));
                }
            System.debug('Map of SAP Price Agreement Lines: '+paMap);*/

            //ACCOUNT MAP
            /*Map<Id, String> accMap = new Map<Id, String>();
            List<Account> acc = [SELECT Id, GE_LGT_EM_SAP_Customer_Number__c FROM Account WHERE GE_LGT_EM_CustomerActiveFlag__c = true];
                for (Account acr : acc){
                    accMap.put(acr.Id ,String.ValueOf(acr.GE_LGT_EM_SAP_Customer_Number__c));
                }
            System.debug('Map of Accounts: '+accMap);*/

            //CC PRODUCT MAP
            Map<String, Id> ccMap = new Map<String, Id>();
            List<ccrz__E_Product__c> ccProd = [SELECT Id, ccrz__SKU__c FROM ccrz__E_Product__c WHERE ccrz__ProductStatus__c = 'Released'];
                for (ccrz__E_Product__c acr : ccProd){
                    ccMap.put(String.ValueOf(acr.ccrz__SKU__c), acr.Id);
                }
            System.debug('Map of CC Products: '+ccMap);

        //CREATE EMPTY LISTS FOR INSERT AND DELETE OPERATIONS -- USED FOR END OF PROCESS    
        List<ccrz__E_PriceList__c> ccPriceListToDelete = new List<ccrz__E_PriceList__c>();
        List<SAP_Price_Agreement__c> agreementsToDelete = new List<SAP_Price_Agreement__c>();
        List<SAP_Price_Agreement_Item__c> linesToDelete = new List<SAP_Price_Agreement_Item__c>();
        List<ccrz__E_PriceListItem__c> ccPLToAdd = new List<ccrz__E_PriceListItem__c>();
        List<ccrz__E_AccountGroupPriceList__c> agPLToAdd = new List<ccrz__E_AccountGroupPriceList__c>();

        


        // LOOK FOR EXISTING CC PRICE LISTS
        //String agreementCat = item.Name + ' - ' + item.Agreement_Type__c;
       /* System.debug('STEP 2: GETTING ALL EXISTING CC PRICE LISTS THAT ARE ZTRM OR ZPRO....');
        List<ccrz__E_PriceList__c> getExisting = [Select Id FROM ccrz__E_PriceList__c WHERE Processed__c = false AND (AgreementType__c = 'ZTRM' OR AgreementType__c = 'ZPRO')];
        if(getExisting.size() > 0){
            ccPriceListToDelete.addAll(getExisting);
            delete ccPriceListToDelete;
            System.debug('Price Lists to Delete: '+ccPriceListToDelete);
            System.debug('STEP 3: DELETING ALL PRICE LISTS.....');

        }*/

        
        
        Set<String> conditionNumSet = new Set<String>();
        for (SAP_Price_Agreement__c item : itemList ) 
        {

            System.debug('Current SAP Price Agreement: '+item.Name);
            String agreementCat = item.Name + ' - ' + item.Agreement_Type__c;

            System.debug('STEP 2: GETTING ALL EXISTING CC PRICE LISTS THAT ARE ZTRM OR ZPRO....');
            List<ccrz__E_PriceList__c> getExisting = [Select Id FROM ccrz__E_PriceList__c WHERE Processed__c = false AND (AgreementType__c = 'ZTRM' OR AgreementType__c = 'ZPRO') AND Name =: agreementCat];
            if(getExisting.size() > 0){
                ccPriceListToDelete.addAll(getExisting);
                delete ccPriceListToDelete;
                System.debug('Price Lists to Delete: '+ccPriceListToDelete);
                System.debug('STEP 3: DELETING ALL PRICE LISTS.....');

            }

            Date isExpired = Date.Today() - 30;
            System.debug('Running on Date: '+isExpired);

            if(item.Expiration_Date__c < isExpired){
                agreementsToDelete.add(item);
            } else {

                //SPLIT PRICE AGREEMENT HEADER CUSTOMER LIST TO NEW STRING
                System.debug('STEP 4: PARSING OUT CURRENT PRICE AGREEMENT ' + item.Name + ' CUSTOMER LIST....');
                
                if (item.Customer_List__c != null){
                    List<String> tempCustomerList = item.Customer_List__c.split(',');
                    System.debug('PRICE AGREEMENT CUSTOMER LIST: '+tempCustomerList);
                

                    /*System.debug('Current SAP Price Agreement: '+item.Name);
                    String agreementCat = item.Name + ' - ' + item.Agreement_Type__c;*/
                    
                   
                        System.debug('STEP 5: CREATING CC PRICE LIST FOR ' + item.Name+'....');
                        //Create CC Price List From Price Agreement Header
                        ccrz__E_PriceList__c newCPL = new ccrz__E_PriceList__c();
                        newCPL.AgreementType__c = item.Agreement_Type__c;
                        newCPL.ccrz__StartDate__c = item.Valid_From__c;
                        newCPL.ccrz__EndDate__c = item.Expiration_Date__c;
                        newCPL.ccrz__Storefront__c = 'DefaultStore';
                        newCPL.Name = agreementCat;
                        newCPL.Processed__c = true;
                        newCPL.ccrz__CurrencyISOCode__c = item.CurrencyIsoCode;
                        newCPL.CustomerList__c = item.Customer_List__c;
                        System.debug('Price List to Insert: '+newCPL);
                        insert newCPL;

                        //LOOP OVER PRICE AGREEMENT LINES 
                        /* This will then check to see if the current line is Expired and a CC Product Exists
                        */
                        List<SAP_Price_Agreement_Item__c> priceItems = [SELECT Id, ValidTo__c, Sales_Price__c, CurrencyIsoCode, DeletionFlag__c, ValidFrom__c, Material_No__c FROM SAP_Price_Agreement_Item__c WHERE Price_Agreement__c =: item.Id ];
                        System.debug('Agreement Lines for this Agreement: '+priceItems);
                        System.debug('# of Agreement Lines: '+priceItems.size());
                        System.debug('STEP 6: LOOPING PRICE AGREEMENT ' + item.Name + '....');
                        for(SAP_Price_Agreement_Item__c paItem : priceItems){
                            //Check to see if the Line is Expired or Deletion Flag is true
                            if (paItem.ValidTo__c < isExpired || paItem.DeletionFlag__c == 'X' || (paItem.ValidFrom__c == null && paItem.ValidTo__c == null)){
                                linesToDelete.add(paItem);
                            } else { 
                                //Checks to see if the Line Material has a corresponding CC Product in the Map
                                if(ccMap.containsKey(paItem.Material_No__c)){
                                Id ccId = ccMap.get(paItem.Material_No__c);
                                System.debug('ID of the CC Product: '+ccId);
                                System.debug('STEP 7: CREATING PRICE LIST ITEM FOR CURRENT PRICE AGREEMENT ITEM....');
                                ccrz__E_PriceListItem__c ccpli = new ccrz__E_PriceListItem__c();
                                ccpli.ccrz__Pricelist__c = newCPL.Id;
                                ccpli.ccrz__Product__c = ccId;
                                ccpli.ccrz__StartDate__c = paItem.ValidFrom__c;
                                ccpli.ccrz__EndDate__c = paItem.ValidTo__c;
                                ccpli.ccrz__Price__c = paItem.Sales_Price__c;
                                ccpli.CurrencyIsoCode = paItem.CurrencyIsoCode;
                                ccPLToAdd.add(ccpli);
                                }
                            }
                        }
                        System.debug('Price List Items to ADD: '+ccPLToAdd);
                        //upsert ccPLToAdd;
                        System.debug('STEP 8: GETTING ACCOUNT DATA - IF ACCOUNT GROUP IS NOT NULL....');
                        List<Account> getCustList = [SELECT Id, Name, GE_LGT_EM_SAP_Customer_Number__c, ccrz__E_AccountGroup__c FROM Account WHERE GE_LGT_EM_SAP_Customer_Number__c IN :tempCustomerList AND ccrz__E_AccountGroup__c != null AND GE_LGT_EM_CustomerActiveFlag__c = true];
                        System.debug('Accounts from Customer List: '+getCustList);
                        for (Account acc : getCustList){
                            System.debug('STEP 9: CREATING ACCOUNT GROUP PRICE LIST FOR CURRENT ACCOUNT RECORD....');
                            ccrz__E_AccountGroupPriceList__c newAGL = new ccrz__E_AccountGroupPriceList__c();
                            newAGL.ccrz__AccountGroup__c = acc.ccrz__E_AccountGroup__c;
                            newAGL.ccrz__Pricelist__c = newCPL.Id;
                            agPLToAdd.add(newAGL);
                        }
                        System.debug('Account Group Price Lists to Add: '+agPLToAdd);
                        //upsert agPLToAdd;
                    
                }
            }
            System.debug('MOVING TO NEXT PRICE AGREEMENT....: ');
        }

        // ---------DELETION METHODS BEGIN ----------------------

        if(agreementsToDelete.size() > 0) {
            System.debug('STEP 10: DELETING EXPIRED PRICE AGREEMENTS....');
            delete agreementsToDelete;
            System.debug('Agreements to Delete: '+agreementsToDelete);
        }

        if(linesToDelete.size() > 0){
            System.debug('STEP 11: DELETING EXPIRED AGREEMENT LINES....');
            delete linesToDelete;
            System.debug('Agreement Lines to Delete: '+linesToDelete);
        }            
        
        //-------------DELETION METHOD ENDS ------------------------


        // ---------- INSERT METHODS BEGIN ------------------------
        System.debug('STEP 12: INSERTING CC PRICE LIST ITEMS....');
        Database.insert(ccPLToAdd);

        System.debug('STEP 13: INSERTING ACCOUNT GROUP PRICE LISTS....');
        System.debug('Account Group Price List Size: '+agPLToAdd.size());
        Database.insert(agPLToAdd);
        
    
    }
    global void finish(Database.BatchableContext BC)
    {
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        AsyncApexJob a = [Select a.TotalJobItems, a.Status, a.NumberOfErrors, a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById, a.CompletedDate From AsyncApexJob a WHERE id = :BC.getJobId()];
        System.debug('$$$ Jobid is'+BC.getJobId());
        mail.setToAddresses(email);
        mail.setReplyTo('no.reply@gecurrent.com');
        mail.setSenderDisplayName('TERM and PROMO Agreements Batch Process');
        mail.setSubject('TERM and PROMO Agreements Batch Process: '+ a.Status);
        mail.setPlainTextBody('TERM and PROMO Agreements Batch Process has completed. The results are summarized below:' + '<br/>' + 'Batches: ' + a.TotalJobItems + '<br/>' + 'Errors: ' + a.NumberOfErrors + '<br/>' + 'Items Processed: ' + a.JobItemsProcessed);
        Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});
       
       //BA009_SyncQuoteToOppty syncQuoteToOppty = new BA009_SyncQuoteToOppty();
       //Database.executeBatch(syncQuoteToOppty); 
    }
}
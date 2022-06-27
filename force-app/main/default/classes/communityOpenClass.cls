public without sharing class communityOpenClass {
    @AuraEnabled(Cacheable=true)
    public static List<Account> getRelatedAccounts(String contactId, String userType){
        
        List<AccountContactRelation> acrList = [SELECT AccountId FROM AccountContactRelation WHERE ContactId =: contactId];
        List<Id> accList = new List<Id>();
        for(AccountContactRelation a :acrList){
            accList.add(a.AccountId);
        }

        /*List<Account> accountList = [SELECT Id, Name, ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,GE_LGT_EM_SAP_Customer_Number__c, Customer_Segmentation__c FROM Account WHERE Id IN :accList ORDER BY Name ASC];

        if (accountList != null & accountList.size() > 0){
            return accountList;
        }
      return null;*/

       String portalType = userType;

        if (portalType == 'Agent'){

            List<Account> accountList = [SELECT Id, Name, ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,GE_LGT_EM_SAP_Customer_Number__c, Customer_Segmentation__c, GE_LGT_EM_Order_Block__c,
            GE_LGT_Rep_Code__c FROM Account WHERE Account_Group__c = 'ZEAG' AND Id IN :accList ORDER BY Name ASC];

                if (accountList != null & accountList.size() > 0){
                    return accountList;
                }
        return null;
        } else {

        List<Account> accountList = [SELECT Id, Name, ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,GE_LGT_EM_SAP_Customer_Number__c, Customer_Segmentation__c, GE_LGT_EM_Order_Block__c FROM Account WHERE Id IN :accList ORDER BY Name ASC];

                if (accountList != null & accountList.size() > 0){
                    return accountList;
                }
        return null;
            }
    }

    @AuraEnabled(Cacheable = true)
    public static List<Account> getAgentAccounts(String contactId){

        List<AccountContactRelation> acrList = [SELECT AccountId FROM AccountContactRelation WHERE ContactId =: contactId];
        List<Id> accList = new List<Id>();
        for(AccountContactRelation a :acrList){
            accList.add(a.AccountId);
        }

    
        List<Account> accountList = [SELECT Id, Name, ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,GE_LGT_EM_SAP_Customer_Number__c, Customer_Segmentation__c FROM Account WHERE Id IN :accList AND Account_Group__c = 'ZEAG' ORDER BY Name ASC];

                if (accountList != null & accountList.size() > 0){
                    return accountList;
                }
        return null;
        

    }

    @AuraEnabled(Cacheable = true)
    public static List<Account> getSoldToAccounts(String accountId){
        String accCode = '%'+accountId+'%';
    
        List<Account> accountList = [SELECT Id, Name, ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,GE_LGT_EM_SAP_Customer_Number__c, Customer_Segmentation__c, GE_LGT_EM_Order_Block__c FROM Account WHERE Account_Group__c = 'Z001'AND 
        (ConnectFixtureAgents__c LIKE :accCode OR Connect_Share_with_Account_PartA__c LIKE :accCode  OR Connect_Share_with_Account_PartB__c LIKE :accCode OR Connect_Share_with_Account_PartC__c LIKE :accCode)  ORDER BY Name ASC];

        if (accountList != null & accountList.size() > 0){
            return accountList;
        }
        return null;

    }


    @AuraEnabled
    public static List<Account> getAccountName(String accountId){
        return [SELECT Name, GE_LGT_EM_SAP_Customer_Number__c, Customer_Segmentation__c, GE_LGT_EM_Order_Block__c FROM Account WHERE Id =:accountId];
    }

    @AuraEnabled(Cacheable=true)
    public static List<Community_Content__c> fetchCommunityContentData(String userType, String listingType){
        System.debug('userType' +userType);
       List<Community_Content__c> communityContentList  =  [SELECT Hyperlink__c, Image_URL__c, Listing_End_Date__c, Listing_Start_Date__c, Persona__c,Title__c, Content_Type__c, Description__c, Display_Date__c,
                                                            Image_Alternate_Text__c, IMG_URL__c FROM Community_Content__c WHERE (Persona__c =:userType OR Persona__c = 'All') AND Listing_Type__c =: listingType
                                                            AND Listing_Start_Date__c <= TODAY AND Listing_End_Date__c >= TODAY ORDER BY Display_Date__c ASC];
        System.debug('communityContentList' +communityContentList);
         return communityContentList;
     }
     @AuraEnabled(Cacheable=true)
    public static List<Community_Content__c> fetchAlertBar(String listingType, String userType){

       List<Community_Content__c> communityContentList  =  [SELECT Alert_Bar_Message__c, Show_Alert_Bar__c
                                                            FROM Community_Content__c WHERE Listing_Type__c =: listingType AND Persona__c =: userType AND Show_Alert_Bar__c = TRUE ];
        System.debug('communityContentList' +communityContentList);
         return communityContentList;
     }

     //USED TO FETCH THE OPEN CASES FOR THE OPEN CASES WIDGET IN COMMUNITY
     @AuraEnabled(Cacheable=true)
     public static List<Case> getOpenCases(String accountId, String distributorId, String userType){
        //accountId = Agent Account selected in the Account Selector
        //distributorId = Distributor Account selected in the Account Selector
        //userType = the type of portal user in Community (Agent, Customer, etc)

        String portalType = userType;
        String disID = distributorId;

        //List<Shipment_Detail__c> caseProducts = [SELECT Distributor_ID__c FROM Shipment_Detail__c WHERE GE_NAS_Case_Number__r.AccountId =: accountId];

        if(portalType == 'Agent' && (distributorId == ' ' || distributorId == null)){
            List<Case> caseList  =  [SELECT CaseNumber, CreatedDate, Contact.Name, GE_NAS_Sub_Type__c, Type, Status
            FROM Case WHERE AccountId = :accountId  AND (Status = 'Open' OR Status = 'In Progress') AND 
            (GE_NAS_Sub_Type__c = 'Warranty Claim'
            OR GE_NAS_Sub_Type__c = 'New Spec Registration'
            OR GE_NAS_Sub_Type__c = 'Pricing Inquiry'
            OR GE_NAS_Sub_Type__c = 'New RGA'   
            OR GE_NAS_Sub_Type__c = 'Stock Balancing Return' 
            OR GE_NAS_Sub_Type__c = 'Connect Platform Support'
            OR GE_NAS_Sub_Type__c = 'When Can I Get It?' 
            OR GE_NAS_Sub_Type__c = 'Lighting Application' 
            OR GE_NAS_Sub_Type__c = 'Marketing Collateral' 
            OR GE_NAS_Sub_Type__c = 'Lighting Application' 
            OR GE_NAS_Sub_Type__c = 'Expedite' 
            OR GE_NAS_Sub_Type__c = 'Change Request' 
            OR GE_NAS_Sub_Type__c = 'Overage' 
            OR GE_NAS_Sub_Type__c = 'Shortage'
            OR GE_NAS_Sub_Type__c = 'Lost/Damaged'
              OR GE_NAS_Sub_Type__c = 'Technical Service'
            OR GE_NAS_Sub_Type__c = 'Credits / Debits') ORDER BY CreatedDate DESC LIMIT 5];
            return caseList;
        } else if(portalType == 'Agent' && (distributorId != ' ' || distributorId != null)){

            List<Shipment_Detail__c> caseProducts = [SELECT Id, GE_NAS_Case_Number__r.Id, Distributor_ID__c FROM Shipment_Detail__c WHERE GE_NAS_Case_Number__r.AccountId =: accountId AND Distributor_ID__c =: distributorId];
            Set<Id> caseIds = new Set<Id>();
                for(Shipment_Detail__c sd : caseProducts){
                    caseIds.add(sd.GE_NAS_Case_Number__r.Id);
                }
            System.debug('Case Products: '+caseProducts);
            
            if (caseProducts.size() > 0){
                
                System.debug('caseIds List Size: '+caseIds.size());
                System.debug('caseIds In THE LIST: '+caseIds);
                List<Case> caseList  =  [SELECT Id, CaseNumber, CreatedDate, Contact.Name, GE_NAS_Sub_Type__c, Type, Status
                FROM Case WHERE (Id IN :caseIds OR Sold_To_Account__c =: distributorId) AND (Status = 'Open' OR Status = 'In Progress') AND 
                (GE_NAS_Sub_Type__c = 'Warranty Claim'
                OR GE_NAS_Sub_Type__c = 'Pricing Inquiry'
                OR GE_NAS_Sub_Type__c = 'New RGA'  
                OR GE_NAS_Sub_Type__c = 'New Spec Registration' 
                OR GE_NAS_Sub_Type__c = 'Connect Platform Support'
                OR GE_NAS_Sub_Type__c = 'Stock Balancing Return' 
                OR GE_NAS_Sub_Type__c = 'When Can I Get It?' 
                OR GE_NAS_Sub_Type__c = 'Lighting Application' 
                OR GE_NAS_Sub_Type__c = 'Marketing Collateral' 
                OR GE_NAS_Sub_Type__c = 'Lighting Application'
                OR GE_NAS_Sub_Type__c = 'Expedite'
                OR GE_NAS_Sub_Type__c = 'Change Request' 
                OR GE_NAS_Sub_Type__c = 'Overage' 
                OR GE_NAS_Sub_Type__c = 'Shortage'
                OR GE_NAS_Sub_Type__c = 'Lost/Damaged'
                 OR GE_NAS_Sub_Type__c = 'Technical Service'
                OR GE_NAS_Sub_Type__c = 'Credits / Debits') ORDER BY CreatedDate LIMIT 5];                
                System.debug('Total Cases Returned: '+caseList.size());

                return caseList;
                

            } else {
                List<Case> caseList  =  [SELECT CaseNumber, CreatedDate, Contact.Name, GE_NAS_Sub_Type__c, Type, Status
                FROM Case WHERE (AccountId =: accountId AND Sold_To_Account__c =: distributorId) AND (Status = 'Open' OR Status = 'In Progress') AND 
                (GE_NAS_Sub_Type__c = 'Warranty Claim'
                OR GE_NAS_Sub_Type__c = 'New Spec Registration'
                OR GE_NAS_Sub_Type__c = 'Pricing Inquiry'
                OR GE_NAS_Sub_Type__c = 'New RGA'     
                OR GE_NAS_Sub_Type__c = 'Connect Platform Support'
                OR GE_NAS_Sub_Type__c = 'Stock Balancing Return' 
                OR GE_NAS_Sub_Type__c = 'When Can I Get It?' 
                OR GE_NAS_Sub_Type__c = 'Lighting Application' 
                OR GE_NAS_Sub_Type__c = 'Marketing Collateral' 
                OR GE_NAS_Sub_Type__c = 'Lighting Application' 
                OR GE_NAS_Sub_Type__c = 'Expedite'
                OR GE_NAS_Sub_Type__c = 'Change Request'
                OR GE_NAS_Sub_Type__c = 'Overage' 
                OR GE_NAS_Sub_Type__c = 'Shortage'
                OR GE_NAS_Sub_Type__c = 'Lost/Damaged'
                 OR GE_NAS_Sub_Type__c = 'Technical Service'
                OR GE_NAS_Sub_Type__c = 'Credits / Debits') ORDER BY CreatedDate LIMIT 5];                   
                return caseList;
            }
        
          
        } else {
            List<Case> caseList  =  [SELECT CaseNumber, CreatedDate, Contact.Name, GE_NAS_Sub_Type__c, Type, Status
            FROM Case WHERE (AccountId =: distributorId OR Sold_To_Account__c =: distributorId) AND (Status = 'Open' OR Status = 'In Progress') AND 
            (GE_NAS_Sub_Type__c = 'Warranty Claim'
            OR GE_NAS_Sub_Type__c = 'New Spec Registration'
            OR GE_NAS_Sub_Type__c = 'Pricing Inquiry'
            OR GE_NAS_Sub_Type__c = 'New RGA'   
            OR GE_NAS_Sub_Type__c = 'Stock Balancing Return' 
            OR GE_NAS_Sub_Type__c = 'Connect Platform Support'
            OR GE_NAS_Sub_Type__c = 'When Can I Get It?' 
            OR GE_NAS_Sub_Type__c = 'Lighting Application' 
            OR GE_NAS_Sub_Type__c = 'Marketing Collateral' 
            OR GE_NAS_Sub_Type__c = 'Lighting Application' 
            OR GE_NAS_Sub_Type__c = 'Expedite' 
            OR GE_NAS_Sub_Type__c = 'Change Request' 
            OR GE_NAS_Sub_Type__c = 'Overage' 
            OR GE_NAS_Sub_Type__c = 'Shortage'
            OR GE_NAS_Sub_Type__c = 'Lost/Damaged'
             OR GE_NAS_Sub_Type__c = 'Technical Service'
            OR GE_NAS_Sub_Type__c = 'Credits / Debits') ORDER BY CreatedDate LIMIT 5];               
            return caseList;
        }
        
      
      }
   
   //USED TO FETCH OPEN ORDERS FOR THE OPEN ORDERS WIDGET IN COMMUNITY   
   @AuraEnabled(Cacheable=true)
   public static List<Order> getOpenOrders(String accountId, String distributorId, String userType){
    String portalType = userType;


        if(portalType == 'Agent' && (distributorId == ' ' || distributorId == null)){
        List<Order> orderList  =  [SELECT SFDC_Order_number__c, GE_Order_NO__c, Customer_PO_Number__c,
        TotalAmount, EffectiveDate, Type , Grand_Total__c,CurrencyIsoCode FROM Order WHERE Agent_Account__c =: accountId AND Type != 'ZRE' AND GBSTK__c != 'Complete' ORDER BY EffectiveDate DESC LIMIT 5];
        return orderList;
            
        } else if(portalType == 'Agent' && (distributorId != ' ' || distributorId != null)){
            List<Order> orderList  =  [SELECT SFDC_Order_number__c, GE_Order_NO__c, Customer_PO_Number__c,
                TotalAmount, EffectiveDate, Type , Grand_Total__c,CurrencyIsoCode FROM Order WHERE (Sold_To__c =: distributorId AND Agent_Account__c =: accountId) AND Type != 'ZRE' AND GBSTK__c != 'Complete' ORDER BY EffectiveDate DESC LIMIT 5];
                return orderList;
                
        } else {
            List<Order> orderList  =  [SELECT SFDC_Order_number__c, GE_Order_NO__c, Customer_PO_Number__c,
            TotalAmount, EffectiveDate, Type , Grand_Total__c,CurrencyIsoCode FROM Order WHERE Sold_To__c =: distributorId AND Type != 'ZRE' AND GBSTK__c != 'Complete' ORDER BY EffectiveDate DESC LIMIT 5];
            return orderList;
        }
        
    }


     //USED TO FETCH OPEN ORDERS FOR THE OPEN ORDERS WIDGET IN COMMUNITY   
   /*@AuraEnabled(Cacheable=true)
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
        
    }*/


    @AuraEnabled(Cacheable=true)
    public static List<Order> getAllOpenOrders(String accountId){
       List<Order> allOrderList  =  [SELECT Id, Account.Name, Sold_To__r.Name, Agent_Account__r.Name, SFDC_Order_number__c, GE_Order_NO__c, Customer_PO_Number__c, Status, GBSTK__c,
       TotalAmount, EffectiveDate, Type FROM Order WHERE (Sold_To__c =:accountId OR Agent_Account__c =: accountId) AND Type != 'ZRE' AND EffectiveDate >= LAST_N_DAYS:365 AND GBSTK__c != '' ORDER BY EffectiveDate DESC];

         return allOrderList;
     }

     //------- WHEN A PARENT ACCOUNT IS SELECTED IN THE COMMUNITY ACCOUNT SELECTOR ------------
     @AuraEnabled(Cacheable=true)
     public static List<Order> getParentOrders(String accountId){
        List<Order> allParentOrders = [SELECT Id, Account.Name, Sold_To__r.Name, Agent_Account__r.Name, SFDC_Order_number__c, GE_Order_NO__c, Customer_PO_Number__c, Status, GBSTK__c,
       TotalAmount, EffectiveDate, Type FROM Order WHERE (Sold_To__r.ParentId =: accountId OR Agent_Account__r.ParentId =: accountId) AND Type != 'ZRE'AND GBSTK__c != '' ORDER BY EffectiveDate DESC LIMIT 5];

       return allParentOrders;
     }

     @AuraEnabled(Cacheable=true)
     public static List<Order> getAllParentOrders(String accountId){
        List<Order> allParentOrders = [SELECT Id, Account.Name, Sold_To__r.Name, Agent_Account__r.Name, SFDC_Order_number__c, GE_Order_NO__c, Customer_PO_Number__c, Status, GBSTK__c,
       TotalAmount, EffectiveDate, Type FROM Order WHERE (Sold_To__r.ParentId =: accountId OR Agent_Account__r.ParentId =: accountId) AND Type != 'Return' AND EffectiveDate >= LAST_N_DAYS:365 AND GBSTK__c != '' ORDER BY EffectiveDate DESC];

       return allParentOrders;
     }

     //------------ END PARENT ACCOUNT SOQL QUERIES --------------------------------------------

    @AuraEnabled(Cacheable=false)
    public static List<Order> getAllOpenOrdersWithLimitAndOffset(String accountId, Integer offset, Integer queryLimit){
        List<Order> allOrderList = [
                SELECT Id, Account.Name, Sold_To__r.Name, Agent_Account__r.Name, SFDC_Order_number__c, GE_Order_NO__c, Customer_PO_Number__c, Status, GBSTK__c,
                        TotalAmount, EffectiveDate, Type
                FROM Order
                WHERE (Sold_To__c = :accountId OR Agent_Account__c = :accountId) AND Type != 'ZRE' AND EffectiveDate >= LAST_N_DAYS:365 AND GBSTK__c != ''
                ORDER BY EffectiveDate DESC
                LIMIT :queryLimit
                OFFSET :offset
        ];
        return allOrderList;
     }

     //USED TO FETCH OPEN PRICE AGREEMENTS FOR THE OPEN PRICE AGREEMENTS WIDGET
     @AuraEnabled(Cacheable=true)
     public static List<SAP_Price_Agreement__c> getPriceAgreements(String accountId, String distributorId, String userType, String distributorNumber){
          Date tMinus30Days = Date.today().addDays(-30);
          //String disNumber = '%'+distributorNumber+'%';
          String portalType = userType;
          if(portalType == 'Agent' && (distributorId == ' ' || distributorId == 'undefined' || distributorId == null)){
              List<SAP_Price_Agreement__c> paList  =  [SELECT Valid_From__c, Agreement_No__c, Agreement_Type__c,
              Agreement_Subtotal__c, Expiration_Date__c FROM SAP_Price_Agreement__c WHERE Fixture_Agent__c = :accountId AND Expiration_Date__c >= :tMinus30Days  ORDER BY Expiration_Date__c DESC LIMIT 5];
  
                  return paList;
          
          } else if(portalType == 'Agent' && (distributorId != ' ' || distributorId != null)){ 
            List<SAP_Price_Agreement__c> paList = new List<SAP_Price_Agreement__c>();
              for(SAP_Price_Agreement__c sapPriceAgreement : [SELECT Id, Valid_From__c, Agreement_No__c, Agreement_Type__c,
              Agreement_Subtotal__c, Customer_List__c, Expiration_Date__c FROM SAP_Price_Agreement__c WHERE  Expiration_Date__c >= TODAY ORDER BY Expiration_Date__c DESC]) {
                    //String disNumber = '%'+distributorNumber+'%';
                    if (String.isNotBlank(sapPriceAgreement.Customer_List__c)) {
                        List<String> customerNumbers = sapPriceAgreement.Customer_List__c.split(',');
                        if (customerNumbers.contains(distributorNumber)) {
                            paList.add(sapPriceAgreement);
                        }
                    }
                      
              }
              
              /*List<SAP_Price_Agreement__c> paList  =  [SELECT Valid_From__c, Agreement_No__c, Agreement_Type__c,
                  Agreement_Subtotal__c, Expiration_Date__c FROM SAP_Price_Agreement__c WHERE Id IN :filteredaccounts AND Expiration_Date__c >= TODAY  ORDER BY Expiration_Date__c DESC LIMIT 5];
  
                  return paList;*/
                   // String disID = '%'+distributorId+'%';
                 
                   //List<SAP_Price_Agreement__c> paList  =  [SELECT Valid_From__c, Agreement_No__c, Agreement_Type__c,
                  //Agreement_Subtotal__c, Expiration_Date__c FROM SAP_Price_Agreement__c WHERE Id IN :filteredaccounts AND Expiration_Date__c >= :tMinus30Days  ORDER BY Expiration_Date__c DESC LIMIT 5];
  
                  return paList;
              
          } else {
            String disID = '%'+distributorId+'%';
            List<SAP_Price_Agreement__c> paList  =  [SELECT Valid_From__c, Agreement_No__c, Agreement_Type__c,
            Agreement_Subtotal__c, Expiration_Date__c FROM SAP_Price_Agreement__c WHERE Bill_To_Customer_No__c =: distributorNumber AND Expiration_Date__c >= TODAY  ORDER BY Expiration_Date__c DESC LIMIT 5];

            return paList;
          }
          
  
        /*List<SAP_Price_Agreement__c> paList  =  [SELECT Valid_From__c, Agreement_No__c, Agreement_Type__c,
        Agreement_Subtotal__c, Expiration_Date__c FROM SAP_Price_Agreement__c WHERE Fixture_Agent__c = :accountId AND Expiration_Date__c >= TODAY  ORDER BY Expiration_Date__c DESC LIMIT 5];
  
          return paList;*/
      }
  

   // USED TO FETCH OPEN RETURNS FOR THE OPEN RETURNS WIDGET IN COMMUNITY 
   @AuraEnabled(Cacheable=true)
   public static List<Order> getOpenReturns(String accountId, String distributorId, String userType){
    String portalType = userType;


        if(portalType == 'Agent' && (distributorId == ' ' || distributorId == null)){
        List<Order> orderList  =  [SELECT SFDC_Order_number__c, GE_Order_NO__c, Customer_PO_Number__c,CurrencyIsoCode,
        TotalAmount, EffectiveDate, Type , Grand_Total__c FROM Order WHERE Agent_Account__c =: accountId AND Type = 'ZRE' AND GBSTK__c != 'Complete' ORDER BY EffectiveDate DESC LIMIT 5];
        return orderList;
            
        } else if(portalType == 'Agent' && (distributorId != ' ' || distributorId != null)){
            List<Order> orderList  =  [SELECT SFDC_Order_number__c, GE_Order_NO__c, Customer_PO_Number__c,CurrencyIsoCode,
                TotalAmount, EffectiveDate, Type , Grand_Total__c FROM Order WHERE (Sold_To__c =:distributorId AND Agent_Account__c =: accountId) AND Type = 'ZRE' AND GBSTK__c != 'Complete' ORDER BY EffectiveDate DESC LIMIT 5];
                return orderList;
                
        } else {
            List<Order> orderList  =  [SELECT SFDC_Order_number__c, GE_Order_NO__c, Customer_PO_Number__c,CurrencyIsoCode,
                TotalAmount, EffectiveDate, Type , Grand_Total__c FROM Order WHERE Sold_To__c =:distributorId AND Type = 'ZRE' AND GBSTK__c != 'Complete' ORDER BY EffectiveDate DESC LIMIT 5];
                return orderList;
        }
        
    }
    
  @AuraEnabled(Cacheable=false)
    public static String checkPAHeader(String priceId){
        String checkflag;
        Date todaysDate = System.today();
        system.debug('todaysDate' + todaysDate);
      	//String todaysDateStr = todaysDate.format('yyyy-MM-dd');
        //system.debug('todaysDateStr' + todaysDateStr);
        SAP_Price_Agreement__c head =[Select Id, Expiration_Date__c from SAP_Price_Agreement__c where name = :priceId ];
        system.debug('Expiration_Date__c' + head.Expiration_Date__c);
        if(head.Expiration_Date__c >= todaysDate){
          checkflag='N';  
        }
        else{
         checkflag='Y';   
        }
        system.debug(checkflag);
        return checkflag;
    }
    
    @AuraEnabled(Cacheable=false)
    public static List<SAP_Price_Agreement__c> checkPAItem(String priceId){
         Map<String, String> getUOMMapping = new Map<String, String>();
        for(UOM_Mapping__mdt um:[SELECT Code__c, DeveloperName FROM UOM_Mapping__mdt]){
            getUOMMapping.put(um.Code__c,um.DeveloperName);
        }
        
       List<SAP_Price_Agreement__c> result = new List<SAP_Price_Agreement__c>();
        SAP_Price_Agreement__c PriceAgreementList = [Select Name, Agent_Name__c,CurrencyIsoCode, Customer_Name__c, Bill_To_Customer_No__c, Opportunity_Name__r.name, Agreement_Type__c, Agreement_Subtotal__c, Extended_Description__c, Strategic_Partner_Name__c, Valid_From__c, Expiration_Date__c,  Agent_Number__c,  (select Material_No__c, Item_Description__c, Quantity__c, UOM__c, ValidFrom__c, ValidTo__c, Sales_Price__c, Hierarchy_Level_1_Description__c from SAP_Price_Agreement_Items__r where ValidTo__c >= Today and DeletionFlag__c<>'X'  ) from SAP_Price_Agreement__c where name = :priceId];
		List<String> accList = new List<String>();
        for(SAP_Price_Agreement_Item__c a :PriceAgreementList.SAP_Price_Agreement_Items__r){
            accList.add(a.Material_No__c);
        }
        Map<String, String> getMaterialUPC = new Map<String, String>();
		for(GE_LGT_EM_MaterialMaster__c a :[SELECT GE_LGT_EM_SAP_MaterialNumber__c, UPC_Code__c FROM GE_LGT_EM_MaterialMaster__c WHERE GE_LGT_EM_SAP_MaterialNumber__c IN: accList]){
			getMaterialUPC.put(a.GE_LGT_EM_SAP_MaterialNumber__c,a.UPC_Code__c);
		}
		for(SAP_Price_Agreement_Item__c a :PriceAgreementList.SAP_Price_Agreement_Items__r){
			a.Hierarchy_Level_1_Description__c=getMaterialUPC.get(a.Material_No__c);
            a.UOM__c = getUOMMapping.get(a.UOM__c);
            system.debug('UOM__c'+a.UOM__c);
		}
		result.add(PriceAgreementList);
		return result;
    	}

    @AuraEnabled(Cacheable=false)
    
    public static String getUserType(String UserId){
        User us = [Select User_Type__c from User where Id= :UserId]; 
        
        return us.User_Type__c;
    }

     @AuraEnabled(Cacheable=false)
    public static String getUserProfile(String UserId){
       User us = [SELECT Id, Profile.Name FROM User WHERE Id = :UserId];        
       return us.Profile.Name;
   }

    @AuraEnabled(Cacheable=false)
     public static List<String> getUserPerMissionSet(String UserId){
         List<String> permissionSet= new List<String>();
 		List<PermissionSetAssignment> psa = [SELECT Id,PermissionSet.Name
                    FROM PermissionSetAssignment
                    where AssigneeId IN (SELECT Id FROM User WHERE Id = :UserId)
            ];
         for(PermissionSetAssignment psa1 : psa) {
             permissionSet.add(psa1.PermissionSet.Name);     
         }
         return permissionSet;
    }
    
   @AuraEnabled( cacheable = true )    
    public static Boolean loggedInAsUserCheck() { 
    
        Boolean loggedInAsUserBool = false;        
        Map < String, String > currentSessionInfo = Auth.SessionManagement.getCurrentSession();
        
        if ( currentSessionInfo.get( 'LoginHistoryId' ) == null &&
           currentSessionInfo.get( 'LoginType' ) == 'Unknown' &&
           currentSessionInfo.get( 'LogoutUrl' ) == null ) {
               
           loggedInAsUserBool = true;
           
       }

       return loggedInAsUserBool;
        
    }

    @AuraEnabled(Cacheable=false)
    public static List<Connect_Logins__c> connectLogins(String contactId){
        DateTime timeNow = System.now();
        
        DateTime startTime = timeNow.addMinutes(-1);
        DateTime endTime = timeNow.addMinutes(1);
        System.debug('START: '+startTime);
        System.debug('END: '+endTime);
        return  [SELECT Id, Delegated_User__r.Username, Delegated_User__r.Name, Delegated_User__r.Phone, Delegated_User__r.FirstName, Delegated_User__r.LastName FROM Connect_Logins__c WHERE Contact__c =: contactId AND (Login_Date_Time__c >= :startTime AND Login_Date_Time__c <= :endTime)];

       
    }

    @AuraEnabled(cacheable=false)
    public static string updateContactInfo(Contact data) {
        
        upsert data Id;
        return 'Success: Line Item Modified';
    }

    @AuraEnabled(Cacheable=true)
    public static List<ContentDistribution> getPdfDownloadLink(List<String> contentDocumentsId){
        List<String> listURLs = new List<String>();
        try {
                List<ContentDistribution> contentDistributions = [
                    SELECT Id, ContentDownloadUrl, DistributionPublicUrl
                    FROM ContentDistribution
                    WHERE ContentDocumentId in :contentDocumentsId
                ];
            return contentDistributions;
        } catch (Exception e) {
           System.debug('Some excellent error messaging');
        }
       return null;
    }
}
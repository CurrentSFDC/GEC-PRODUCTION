public without sharing class LwcLookupControllerCust {
    @AuraEnabled(cacheable=true)  
    public static List<Account> findRecords(String searchKey, String objectName, String filterField, String filterFieldValue) {  
        //string searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';  
        //string query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText+' LIMIT 6';
        //if(String.isBlank(filterField)){
        //   return Database.query(query);
        // }  
        // else{
        
        //   string filterFieldText = '\'' + String.escapeSingleQuotes(filterFieldValue) + '%\'';  
        //  query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText+ ' AND ' +filterField+ ' LIKE ' +filterFieldText+ ' LIMIT 6';
        // return Database.query(query);
        // }
        string searchText = '%'+searchKey+'%'; 
        string filterFieldText = '%'+filterFieldValue+'%';  
        System.debug(searchText);
        List<Account> acc =  [SELECT Name, GE_LGT_EM_SAP_Customer_Number__c FROM Account WHERE Account_Group__c='ZEAG' AND (Name LIKE :searchText OR GE_LGT_EM_SAP_Customer_Number__c LIKE :searchText)  ];
        List<Account> accRet = new  List<Account>();
        for(Account accnt : acc){
            String tempNumber = accnt.GE_LGT_EM_SAP_Customer_Number__c;
            if((!(tempNumber.startsWith('U') && tempNumber.length() >= 6))){
                Account accNew = new  Account();
                accNew.Name=accnt.Name +' '+ '(' + accnt.GE_LGT_EM_SAP_Customer_Number__c+ ')';
                accNew.Id=accnt.Id;
                accRet.add(accNew);
            }
        }  
        system.debug(accRet);
        return accRet;
        
    }  
    
    
    
    
    
    @AuraEnabled 
    public static List<Account> findDistRecords(String searchKey, String objectName, String filterField, String filterFieldValue) {  
        string searchText = '%'+searchKey+'%'; 
        string filterFieldText = '%'+filterFieldValue+'%';  
        
        List<Account> acc =  [SELECT Name, GE_LGT_EM_SAP_Customer_Number__c FROM Account WHERE Account_Group__c='Z001' AND ConnectFixtureAgents__c LIKE :filterFieldText AND Name LIKE :searchText];
        List<Account> accRet = new  List<Account>();
        for(Account accnt : acc){
            Account accNew = new  Account();
            accNew.Name=accnt.Name +' '+ '(' + accnt.GE_LGT_EM_SAP_Customer_Number__c+ ')';
            accNew.Id=accnt.Id;
            accRet.add(accNew);
        }   
        system.debug(accRet);
        return accRet;    
        
    }  
    
    @AuraEnabled 
    public static List<Order> findOrderRecords(String searchKey, String objectName, String filterField, String filterFieldValue) {  
        string searchText = '%'+searchKey+'%';
        if(objectName=='orderExp'){    
            if(filterFieldValue=='DEFAULT_DIS'){
                List<Order> ord = [Select GE_Order_NO__c, Customer_PO_Number__c from Order where  Sold_To__c=:filterField and GBSTK__c !='Complete' and (GE_Order_NO__c LIKE :searchText OR Customer_PO_Number__c LIKE :searchText) LIMIT 6];
                List<Order> ordRet = new  List<Order>();
                for(Order ords : ord){
                    Order ordNew = new  Order();
                    ordNew.GE_Order_NO__c=ords.GE_Order_NO__c +' '+ '(' + ords.Customer_PO_Number__c+ ')';
                    ordNew.Id=ords.Id;
                    ordRet.add(ordNew);
                }   
                return ordRet;
            }
            else if (filterFieldValue=='DEFAULT'){
                List<Order> ord = [Select GE_Order_NO__c, Customer_PO_Number__c from Order where  Agent_Account__c=:filterField and GBSTK__c !='Complete' and (GE_Order_NO__c LIKE :searchText OR Customer_PO_Number__c LIKE :searchText) LIMIT 6];
                List<Order> ordRet = new  List<Order>();
                for(Order ords : ord){
                    Order ordNew = new  Order();
                    ordNew.GE_Order_NO__c=ords.GE_Order_NO__c +' '+ '(' + ords.Customer_PO_Number__c+ ')';
                    ordNew.Id=ords.Id;
                    ordRet.add(ordNew);
                }   
                return ordRet;
            }
            else{
                List<Order> ord = [Select GE_Order_NO__c, Customer_PO_Number__c from Order where  Agent_Account__c=:filterField and GBSTK__c !='Complete' and Sold_To__c=:filterFieldValue and  (GE_Order_NO__c LIKE :searchText OR Customer_PO_Number__c LIKE :searchText) LIMIT 6]; 
                List<Order> ordRet = new  List<Order>();
                for(Order ords : ord){
                    Order ordNew = new  Order();
                    ordNew.GE_Order_NO__c=ords.GE_Order_NO__c +' '+ '(' + ords.Customer_PO_Number__c+ ')';
                    ordNew.Id=ords.Id;
                    ordRet.add(ordNew);
                }   
                return ordRet;
                
            }
        }
        else{
            if(filterFieldValue=='DEFAULT_DIS'){
                List<Order> ord = [Select GE_Order_NO__c, Customer_PO_Number__c from Order where  Sold_To__c=:filterField and (GE_Order_NO__c LIKE :searchText OR Customer_PO_Number__c LIKE :searchText) LIMIT 6];
                List<Order> ordRet = new  List<Order>();
                for(Order ords : ord){
                    Order ordNew = new  Order();
                    ordNew.GE_Order_NO__c=ords.GE_Order_NO__c +' '+ '(' + ords.Customer_PO_Number__c+ ')';
                    ordNew.Id=ords.Id;
                    ordRet.add(ordNew);
                }   
                return ordRet;
                
            }
            else if (filterFieldValue=='DEFAULT'){
                List<Order> ord = [Select GE_Order_NO__c, Customer_PO_Number__c from Order where  Agent_Account__c=:filterField and (GE_Order_NO__c LIKE :searchText OR Customer_PO_Number__c LIKE :searchText) LIMIT 6];
                List<Order> ordRet = new  List<Order>();
                for(Order ords : ord){
                    Order ordNew = new  Order();
                    ordNew.GE_Order_NO__c=ords.GE_Order_NO__c +' '+ '(' + ords.Customer_PO_Number__c+ ')';
                    ordNew.Id=ords.Id;
                    ordRet.add(ordNew);
                }   
                return ordRet;
                
            }
            else{
                List<Order> ord = [Select GE_Order_NO__c, Customer_PO_Number__c from Order where  Agent_Account__c=:filterField and Sold_To__c=:filterFieldValue and  (GE_Order_NO__c LIKE :searchText OR Customer_PO_Number__c LIKE :searchText) LIMIT 6]; 
                List<Order> ordRet = new  List<Order>();
                for(Order ords : ord){
                    Order ordNew = new  Order();
                    ordNew.GE_Order_NO__c=ords.GE_Order_NO__c +' '+ '(' + ords.Customer_PO_Number__c+ ')';
                    ordNew.Id=ords.Id;
                    ordRet.add(ordNew);
                }   
                return ordRet;
            }
        }
        
    }
    
    @AuraEnabled 
    public static List<Account> findAccRecords(String searchKey, String objectName, String filterField, String filterFieldValue) {  
        string searchText = '%'+searchKey+'%'; 
        string filterFieldText = '%'+filterFieldValue+'%'; 
        string newAcc;
        //string query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE  Account_Group__c = ' +filterField+ ' AND ConnectFixtureAgents__c LIKE '+filterFieldText+ 'AND Name LIKE' +searchText+ ' LIMIT 6';
        List<Account> acc =  [SELECT  Name, GE_LGT_EM_SAP_Customer_Number__c FROM Account WHERE Id IN (SELECT AccountId FROM AccountContactRelation where contactId= :filterFieldValue) AND Name LIKE :searchText];
        List<Account> accRet = new  List<Account>();
        for(Account accnt : acc){
            Account accNew = new  Account();
            accNew.Name=accnt.Name +' '+ '(' + accnt.GE_LGT_EM_SAP_Customer_Number__c+ ')';
            accNew.Id=accnt.Id;
            accRet.add(accNew);
        }   
        return accRet;
        
    } 
    
    @AuraEnabled 
    public static List<GE_LGT_EM_InvoiceHeader__c> findInvRecords(String searchKey, String objectName, String filterField, String filterFieldValue) {  
        string searchText = '%'+searchKey+'%'; 
        string filterFieldText = '%'+filterFieldValue+'%'; 
        string newInv;
        //string query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE  Account_Group__c = ' +filterField+ ' AND ConnectFixtureAgents__c LIKE '+filterFieldText+ 'AND Name LIKE' +searchText+ ' LIMIT 6';
        List<GE_LGT_EM_InvoiceHeader__c> inv =  [SELECT  Name, GE_LGT_EM_SAPInvoiceNumber__c FROM GE_LGT_EM_InvoiceHeader__c WHERE GE_LGT_EM_Sold_to_Account_Number__c= :filterField AND GE_LGT_EM_SAPInvoiceNumber__c LIKE :searchText];
        List<GE_LGT_EM_InvoiceHeader__c> incRet = new  List<GE_LGT_EM_InvoiceHeader__c>();
        for(GE_LGT_EM_InvoiceHeader__c invHead : inv){
            GE_LGT_EM_InvoiceHeader__c invnew = new  GE_LGT_EM_InvoiceHeader__c();
            invnew.Name=invHead.GE_LGT_EM_SAPInvoiceNumber__c +' '+ '(' + invHead.Name + ')';
            invnew.Id=invHead.Id;
            incRet.add(invnew);
        }   
        system.debug('Return Data :' +incRet);
        return incRet;
        
    } 
    
    @AuraEnabled 
    public static List<Account> findAccSpecRecords(String searchKey, String objectName, String filterField, String filterFieldValue) {  
        string searchText = '%'+searchKey+'%'; 
        string filterFieldText = '%'+filterFieldValue+'%'; 
        string newAcc;
        //string query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE  Account_Group__c = ' +filterField+ ' AND ConnectFixtureAgents__c LIKE '+filterFieldText+ 'AND Name LIKE' +searchText+ ' LIMIT 6';
        List<Account> acc =  [SELECT  Name, GE_LGT_EM_SAP_Customer_Number__c FROM Account WHERE Id IN (SELECT AccountId FROM AccountContactRelation where contactId= :filterFieldValue) AND Account_Group__c='ZEAG' AND Name LIKE :searchText];
        List<Account> accRet = new  List<Account>();
        for(Account accnt : acc){
            Account accNew = new  Account();
            accNew.Name=accnt.Name +' '+ '(' + accnt.GE_LGT_EM_SAP_Customer_Number__c+ ')';
            accNew.Id=accnt.Id;
            accRet.add(accNew);
        }   
        return accRet;
        
    }
    
    @AuraEnabled
    
    public static String getOrdDtl(String ordId){
        Order ord = [Select GE_Order_NO__c, Customer_PO_Number__c from Order where Id = :ordId AND GBSTK__c != 'Complete']; 
        String newData = ord.GE_Order_NO__c +' '+ '(' + ord.Customer_PO_Number__c+ ')';
        return newData;
    }
    
    @AuraEnabled
    public static List<Order> getOrdDtlNEW(String ordId){
        List<Order> ord = [Select GE_Order_NO__c, Customer_PO_Number__c, EffectiveDate from Order where Id = :ordId AND GBSTK__c != 'Complete']; 
        
        return ord;
    }
    
    @AuraEnabled 
    public static List<Order> findOrderRecordsNEW(String searchKey, String objectName, String filterField, String filterFieldValue) {  
        string searchText = '%'+searchKey+'%';
        if(objectName=='orderExp'){    
            if(filterFieldValue=='DEFAULT_DIS'){
                List<Order> ord = [Select GE_Order_NO__c, Customer_PO_Number__c, EffectiveDate from Order where  Sold_To__c=:filterField and GBSTK__c !='Complete' and (GE_Order_NO__c LIKE :searchText OR Customer_PO_Number__c LIKE :searchText) LIMIT 6];
                
                return ord;
            }
            else if (filterFieldValue=='DEFAULT'){
                List<Order> ord = [Select GE_Order_NO__c, Customer_PO_Number__c, EffectiveDate from Order where  Agent_Account__c=:filterField and GBSTK__c !='Complete' and (GE_Order_NO__c LIKE :searchText OR Customer_PO_Number__c LIKE :searchText) LIMIT 6];
                
                return ord;
            }
            else{
                List<Order> ord = [Select GE_Order_NO__c, Customer_PO_Number__c, EffectiveDate from Order where  Agent_Account__c=:filterField and GBSTK__c !='Complete' and Sold_To__c=:filterFieldValue and  (GE_Order_NO__c LIKE :searchText OR Customer_PO_Number__c LIKE :searchText) LIMIT 6]; 
                
                
                return ord;
                
            }
        }
        else{
            if(filterFieldValue=='DEFAULT_DIS'){
                List<Order> ord = [Select GE_Order_NO__c, Customer_PO_Number__c, EffectiveDate from Order where  Sold_To__c=:filterField and (GE_Order_NO__c LIKE :searchText OR Customer_PO_Number__c LIKE :searchText) LIMIT 6];
                
                return ord;
                
            }
            else if (filterFieldValue=='DEFAULT'){
                List<Order> ord = [Select GE_Order_NO__c, Customer_PO_Number__c, EffectiveDate from Order where  Agent_Account__c=:filterField and (GE_Order_NO__c LIKE :searchText OR Customer_PO_Number__c LIKE :searchText) LIMIT 6];
                
                return ord;
                
            }
            else{
                List<Order> ord = [Select GE_Order_NO__c, Customer_PO_Number__c, EffectiveDate from Order where  Agent_Account__c=:filterField and Sold_To__c=:filterFieldValue and  (GE_Order_NO__c LIKE :searchText OR Customer_PO_Number__c LIKE :searchText) LIMIT 6]; 
                
                return ord;
            }
        }
        
    }
    //--------------------------------------------------------------------------------------------------------------------------------------------
    @AuraEnabled(Cacheable=true)
    public static List<Account> getAccountRecords(String searchKey, String contactId, String userType, String allAgents){
        string searchTerm = '%'+searchKey+'%';
        string searchAll = allAgents;
        List<AccountContactRelation> acrList = [SELECT AccountId FROM AccountContactRelation WHERE ContactId =: contactId];
        List<Id> accList = new List<Id>();
        for(AccountContactRelation a :acrList){
            accList.add(a.AccountId);
        }
        
        String portalType = userType;
        
        if (portalType == 'Agent' && searchAll == 'false'){
            
            List<Account> accountList = [SELECT Id, Name, 
                                         GE_LGT_EM_SAP_Customer_Number__c, 
                                         Customer_Segmentation__c 
                                         FROM Account 
                                         WHERE Account_Group__c = 'ZEAG' AND Id IN :accList AND
                                         (Name LIKE :searchTerm OR 
                                          GE_LGT_EM_SAP_Customer_Number__c LIKE :searchTerm)
                                         ORDER BY Name ASC];
            
            if (accountList != null & accountList.size() > 0){
                return accountList;
            }
            return null;
        } else if (portalType == 'Distributor' && searchAll == 'false'){
            
            List<Account> accountList = [SELECT Id, Name,
                                         GE_LGT_EM_SAP_Customer_Number__c, 
                                         Customer_Segmentation__c 
                                         FROM Account WHERE Id IN :accList AND 
                                         (Name LIKE :searchTerm OR 
                                          GE_LGT_EM_SAP_Customer_Number__c LIKE :searchTerm)
                                         ORDER BY Name ASC];
            
            if (accountList != null & accountList.size() > 0){
                return accountList;
            }
            return null;
        } else if (searchAll == 'true'){
            List<Account> accountList = [SELECT Id, Name, 
                                         GE_LGT_EM_SAP_Customer_Number__c, 
                                         Customer_Segmentation__c 
                                         FROM Account 
                                         WHERE Account_Group__c = 'ZEAG' AND
                                         (Name LIKE :searchTerm OR 
                                          GE_LGT_EM_SAP_Customer_Number__c LIKE :searchTerm)
                                         ORDER BY Name ASC];
            
            if (accountList != null & accountList.size() > 0){
                return accountList;
            }
            return null;
        }
        return null;
    }

        @AuraEnabled(Cacheable=true)
    public static List<Account> getAgencyAccountRecords(String searchKey, String contactId, String userType){
        string searchTerm = '%'+searchKey+'%';
        
            List<Account> accountList = [SELECT Id, Name, 
                                         GE_LGT_EM_SAP_Customer_Number__c, 
                                         Customer_Segmentation__c 
                                         FROM Account 
                                         WHERE Account_Group__c = 'ZEAG' AND
                                         (Name LIKE :searchTerm OR 
                                          GE_LGT_EM_SAP_Customer_Number__c LIKE :searchTerm)
                                         ORDER BY Name ASC];
            
            if (accountList != null & accountList.size() > 0){
                return accountList;
            }
            return null;
      
    }
    
    
    @AuraEnabled(Cacheable=true)
    public static List<Account> findSoldToRecords(String searchKey, String objectName, String filterFieldName) {
        String searchTerm = '%'+searchKey+'%';
        String repCode = '%'+filterFieldName+'%';
        System.debug('searchText ' + searchTerm);
        
        List<Account> obj = [SELECT Id, Name, 
                             Customer_Segmentation__c,
                             GE_LGT_EM_SAP_Customer_Number__c, 
                             ConnectFixtureAgents__c,
                             Account_Group__c
                             FROM Account
                             WHERE
                             Account_Group__c = 'Z001' AND 
                             (Name LIKE :searchTerm OR 
                              GE_LGT_EM_SAP_Customer_Number__c LIKE :searchTerm) AND
                             ConnectFixtureAgents__c LIKE :repCode
                             
                            ];
        
        
        /*String query = 'SELECT Id,Name,Customer_Integration_Key__c,BillingAddress,ShippingAddress,GE_LGT_EM_SAP_Customer_Number__c,GE_LGT_Sales_Group__c,GE_LGT_EM_Sales_Org__c,' +
'GE_LGT_EM_Distribution_Channel__c, CurrencyIsoCode,' +
'GE_LGT_EM_Division__c, ' +
'ConnectFixtureAgents__c ' +
'FROM Account ' +
'WHERE ' +
'Account_Group__c = \'Z001\' AND ' +
'ConnectFixtureAgents__c LIKE :filterFieldName AND ' +
//'AND GE_LGT_EM_Sales_Org__c IN (\'1U10\', \'1C10\', \'1u10\', \'1c10\') AND ' +
'(Name LIKE :searchTerm OR ' +
'GE_LGT_EM_SAP_Customer_Number__c LIKE :searchTerm) ' +
'LIMIT 30';
System.debug('findSoldToRecords query ' + query);
return Database.query(query);*/
        return obj;
    }
    
    
    
    
    // NEW INVOICE LINE SEARCH FOR CASE TYPES
    @AuraEnabled 
    public static List<GE_LGT_EM_InvoiceLineItem__c> findInvLineRecords(String searchKey, String objectName, String filterField, String agentNumber) {  
        string searchText = '%'+searchKey+'%'; 
        //string filterFieldText = '%'+filterFieldValue+'%'; 
        //string newInv;
        //string query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE  Account_Group__c = ' +filterField+ ' AND ConnectFixtureAgents__c LIKE '+filterFieldText+ 'AND Name LIKE' +searchText+ ' LIMIT 6';
        
        if(agentNumber != null){
            List<GE_LGT_EM_InvoiceLineItem__c> inv =  [SELECT
                                                    Id,
                                                    GE_LGT_EM_InvoiceHeaderNumber__r.Name,
                                                    GE_LGT_EM_InvoiceHeaderNumber__c,   
                                                    GE_LGT_EM_SAP_Invoice_Number__c, 
                                                    GE_LGT_EM_Order_Number__c, 
                                                    GE_LGT_EM_Customer_PO_Number__c,
                                                    GE_LGT_EM_Sales_Unit__c,
                                                    GE_LGT_EM_Material_Description__c, 
                                                    GE_LGT_EM_Invoiced_Price__c, 
                                                    GE_LGT_EM_Invoiced_Quantity__c,
                                                    GE_LGT_EM_SAP_LineItemNumber__c, 
                                                    SKU__c,
                                                    GE_LGT_EM_DisputeCount__c,
                                                    Requested_Action_Override__c,
                                                    Total_Returned__c,
                                                    Available_for_Return__c,
                                                    QuickStock__c,
                                                    No_Of_Products_Failed__c,
                                                    Installed_Qty__c,
                                                    Date_Installed__c,
                                                    Price_Agreement__c,
                                                    Comment__c,
                                                    Invoiced_Amount__c,
                                                    Minimum_Order_Qty__c,
                                                    GE_LGT_EM_Material__c,
                                                    GE_LGT_EM_InvoiceHeaderNumber__r.Agent__c,
                                                    GE_LGT_EM_InvoiceHeaderNumber__r.GE_LGT_EM_Doc_Type__c,
                                                    GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c,
                                                    GE_LGT_EM_Material__r.Id  
                                                    FROM GE_LGT_EM_InvoiceLineItem__c 
                                                    WHERE (GE_LGT_EM_Payer_Sold_to_Account_Number__c= :filterField AND GE_LGT_EM_InvoiceHeaderNumber__r.Agent__c =:agentNumber) AND GE_LGT_EM_InvoiceHeaderNumber__r.GE_LGT_EM_Doc_Type__c = 'F2-Invoice'
                                                    AND (GE_LGT_EM_Order_Number__c LIKE :searchText OR GE_LGT_EM_Customer_PO_Number__c LIKE :searchText OR GE_LGT_EM_SAP_Invoice_Number__c LIKE :searchText)];
            
            
            system.debug('Return Data :' +inv);
            return inv;
        } else {
            List<GE_LGT_EM_InvoiceLineItem__c> inv =  [SELECT
                                                    Id,
                                                    GE_LGT_EM_InvoiceHeaderNumber__r.Name,
                                                    GE_LGT_EM_InvoiceHeaderNumber__c,   
                                                    GE_LGT_EM_SAP_Invoice_Number__c, 
                                                    GE_LGT_EM_Order_Number__c, 
                                                    GE_LGT_EM_Customer_PO_Number__c,
                                                    GE_LGT_EM_Sales_Unit__c,
                                                    GE_LGT_EM_Material_Description__c, 
                                                    GE_LGT_EM_Invoiced_Price__c, 
                                                    GE_LGT_EM_Invoiced_Quantity__c,
                                                    GE_LGT_EM_SAP_LineItemNumber__c, 
                                                    SKU__c,
                                                    GE_LGT_EM_DisputeCount__c,
                                                    Requested_Action_Override__c,
                                                    Total_Returned__c,
                                                    Available_for_Return__c,
                                                    QuickStock__c,
                                                    No_Of_Products_Failed__c,
                                                    Installed_Qty__c,
                                                    Date_Installed__c,
                                                    Price_Agreement__c,
                                                    Comment__c,
                                                    Invoiced_Amount__c,
                                                    Minimum_Order_Qty__c,
                                                    GE_LGT_EM_Material__c,
                                                    GE_LGT_EM_InvoiceHeaderNumber__r.GE_LGT_EM_Doc_Type__c,
                                                    GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c,
                                                    GE_LGT_EM_Material__r.Id  
                                                    FROM GE_LGT_EM_InvoiceLineItem__c 
                                                    WHERE GE_LGT_EM_Payer_Sold_to_Account_Number__c= :filterField AND GE_LGT_EM_InvoiceHeaderNumber__r.GE_LGT_EM_Doc_Type__c = 'F2-Invoice'
                                                    AND (GE_LGT_EM_Order_Number__c LIKE :searchText OR GE_LGT_EM_Customer_PO_Number__c LIKE :searchText OR GE_LGT_EM_SAP_Invoice_Number__c LIKE :searchText)];
            
            
            system.debug('Return Data :' +inv);
            return inv;
        }
        
    } 

    // NEW INVOICE LINE PRELOAD FOR CASE TYPES - STEP 1: FILTER BASED ON AGENT CODE SELECTED
    @AuraEnabled(cacheable=true) 
    public static List<GE_LGT_EM_InvoiceLineItem__c> preLoadLineRecords(String searchKey, String objectName, String filterField, String userType) {  
        string searchText = '%'+searchKey+'%'; 
        //string filterFieldText = '%'+filterFieldValue+'%'; 
        //string newInv;
        //string query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE  Account_Group__c = ' +filterField+ ' AND ConnectFixtureAgents__c LIKE '+filterFieldText+ 'AND Name LIKE' +searchText+ ' LIMIT 6';
        
        if(userType == 'Agent'){
        List<GE_LGT_EM_InvoiceLineItem__c> inv =  [SELECT
                                                   Id,
                                                   GE_LGT_EM_InvoiceHeaderNumber__r.Name,
                                                   GE_LGT_EM_InvoiceHeaderNumber__c,   
                                                   GE_LGT_EM_SAP_Invoice_Number__c, 
                                                   GE_LGT_EM_Order_Number__c, 
                                                   GE_LGT_EM_Customer_PO_Number__c,
                                                   GE_LGT_EM_Sales_Unit__c,
                                                   GE_LGT_EM_Material_Description__c, 
                                                   GE_LGT_EM_Invoiced_Price__c, 
                                                   GE_LGT_EM_Invoiced_Quantity__c,
                                                   GE_LGT_EM_SAP_LineItemNumber__c, 
                                                   SKU__c,
                                                   GE_LGT_EM_DisputeCount__c,
                                                   Requested_Action_Override__c,
                                                   Total_Returned__c,
                                                   Available_for_Return__c,
                                                   QuickStock__c,
                                                   No_Of_Products_Failed__c,
                                                   GE_LGT_EM_Payer_Sold_to_Account_Number__c,
                                                   Installed_Qty__c,
                                                   Date_Installed__c,
                                                   Price_Agreement__c,
                                                   Comment__c,
                                                   Invoiced_Amount__c,
                                                   Minimum_Order_Qty__c,
                                                   GE_LGT_EM_Material__c,
                                                   GE_LGT_EM_InvoiceHeaderNumber__r.Agent__c,
                                                   GE_LGT_EM_InvoiceHeaderNumber__r.GE_LGT_EM_Doc_Type__c, 
                                                   GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c,
                                                   GE_LGT_EM_Material__r.Id  
                                                   FROM GE_LGT_EM_InvoiceLineItem__c 
                                                   WHERE GE_LGT_EM_InvoiceHeaderNumber__r.GE_LGT_EM_Doc_Type__c = 'F2-Invoice' AND GE_LGT_EM_InvoiceHeaderNumber__r.Agent__c = :filterField ];
        
        
        system.debug('Return Data :' +inv);
        return inv;
        } else {
            List<GE_LGT_EM_InvoiceLineItem__c> inv =  [SELECT
                                                   Id,
                                                   GE_LGT_EM_InvoiceHeaderNumber__r.Name,
                                                   GE_LGT_EM_InvoiceHeaderNumber__c,   
                                                   GE_LGT_EM_SAP_Invoice_Number__c, 
                                                   GE_LGT_EM_Order_Number__c, 
                                                   GE_LGT_EM_Customer_PO_Number__c,
                                                   GE_LGT_EM_Sales_Unit__c,
                                                   GE_LGT_EM_Material_Description__c, 
                                                   GE_LGT_EM_Invoiced_Price__c, 
                                                   GE_LGT_EM_Invoiced_Quantity__c,
                                                   GE_LGT_EM_SAP_LineItemNumber__c, 
                                                   SKU__c,
                                                   GE_LGT_EM_DisputeCount__c,
                                                   Requested_Action_Override__c,
                                                   Total_Returned__c,
                                                   Available_for_Return__c,
                                                   QuickStock__c,
                                                   No_Of_Products_Failed__c,
                                                   GE_LGT_EM_Payer_Sold_to_Account_Number__c,
                                                   Installed_Qty__c,
                                                   Date_Installed__c,
                                                   Price_Agreement__c,
                                                   Comment__c,
                                                   Invoiced_Amount__c,
                                                   Minimum_Order_Qty__c,
                                                   GE_LGT_EM_Material__c,
                                                   GE_LGT_EM_InvoiceHeaderNumber__r.Agent__c,
                                                   GE_LGT_EM_InvoiceHeaderNumber__r.GE_LGT_EM_Doc_Type__c, 
                                                   GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c,
                                                   GE_LGT_EM_Material__r.Id  
                                                   FROM GE_LGT_EM_InvoiceLineItem__c 
                                                   WHERE GE_LGT_EM_InvoiceHeaderNumber__r.GE_LGT_EM_Doc_Type__c = 'F2-Invoice' AND GE_LGT_EM_Payer_Sold_to_Account_Number__c = :filterField ];
        
        
        system.debug('Return Data :' +inv);
        return inv;
        }
        
    } 


    //NEW INVOICE LINE SEARCH FOR CASE TYPES - STEP 2: FILTER BASED ON SOLD TO SELECTED
    @AuraEnabled (cacheable=true)
    public static List<GE_LGT_EM_InvoiceLineItem__c> soldToFiltering(String searchKey, String soldTo, List<GE_LGT_EM_InvoiceLineItem__c> invLines) {  
        string searchText = '%'+searchKey+'%'; 
        string soldToNum = soldTo;
        
        List<GE_LGT_EM_InvoiceLineItem__c> sortedLines = new List<GE_LGT_EM_InvoiceLineItem__c>();

        for( GE_LGT_EM_InvoiceLineItem__c inv : invLines){
            if(inv.GE_LGT_EM_Payer_Sold_to_Account_Number__c == soldToNum){
                sortedLines.add(inv);
            }
        }

        return sortedLines;
                   
    } 

    // NEW INVOICE LINE SEARCH FOR CASE TYPES - IF INITIATED FROM AN ORDER
    @AuraEnabled 
    public static List<GE_LGT_EM_InvoiceLineItem__c> orderInitiatedFiltering(String searchKey, String soldTo, String agentNumber, String userType) {  
        string searchText = '%'+searchKey+'%'; 
        System.Debug('Search Text: '+searchText);
        System.Debug('Sold To: '+soldTo);
        System.Debug('Agent Number: '+agentNumber);
        System.Debug('User Type: '+userType);
        
        //string filterFieldText = '%'+filterFieldValue+'%'; 
        //string newInv;
        //string query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE  Account_Group__c = ' +filterField+ ' AND ConnectFixtureAgents__c LIKE '+filterFieldText+ 'AND Name LIKE' +searchText+ ' LIMIT 6';
        
        if(userType == 'Agent'){
            List<GE_LGT_EM_InvoiceLineItem__c> inv =  [SELECT
                                                    Id,
                                                    GE_LGT_EM_InvoiceHeaderNumber__r.Name,
                                                    GE_LGT_EM_InvoiceHeaderNumber__c,   
                                                    GE_LGT_EM_SAP_Invoice_Number__c, 
                                                    GE_LGT_EM_Order_Number__c, 
                                                    GE_LGT_EM_Customer_PO_Number__c,
                                                    GE_LGT_EM_Sales_Unit__c,
                                                    GE_LGT_EM_Material_Description__c, 
                                                    GE_LGT_EM_Invoiced_Price__c, 
                                                    GE_LGT_EM_Invoiced_Quantity__c,
                                                    GE_LGT_EM_SAP_LineItemNumber__c, 
                                                    SKU__c,
                                                    GE_LGT_EM_DisputeCount__c,
                                                    Requested_Action_Override__c,
                                                    Total_Returned__c,
                                                    Available_for_Return__c,
                                                    QuickStock__c,
                                                    No_Of_Products_Failed__c,
                                                    Installed_Qty__c,
                                                    Date_Installed__c,
                                                    Price_Agreement__c,
                                                    Comment__c,
                                                    Invoiced_Amount__c,
                                                    Minimum_Order_Qty__c,
                                                    GE_LGT_EM_Material__c,
                                                    GE_LGT_EM_InvoiceHeaderNumber__r.Agent__c,
                                                    GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c,
                                                    GE_LGT_EM_Material__r.Id  
                                                    FROM GE_LGT_EM_InvoiceLineItem__c 
                                                    WHERE (GE_LGT_EM_Payer_Sold_to_Account_Number__c= :soldTo AND GE_LGT_EM_InvoiceHeaderNumber__r.Agent__c =:agentNumber AND GE_LGT_EM_Order_Number__c LIKE :searchText)];
            
            
            system.debug('Return Data :' +inv);
            return inv;
        } else {
            List<GE_LGT_EM_InvoiceLineItem__c> inv =  [SELECT
                                                    Id,
                                                    GE_LGT_EM_InvoiceHeaderNumber__r.Name,
                                                    GE_LGT_EM_InvoiceHeaderNumber__c,   
                                                    GE_LGT_EM_SAP_Invoice_Number__c, 
                                                    GE_LGT_EM_Order_Number__c, 
                                                    GE_LGT_EM_Customer_PO_Number__c,
                                                    GE_LGT_EM_Sales_Unit__c,
                                                    GE_LGT_EM_Material_Description__c, 
                                                    GE_LGT_EM_Invoiced_Price__c, 
                                                    GE_LGT_EM_Invoiced_Quantity__c,
                                                    GE_LGT_EM_SAP_LineItemNumber__c, 
                                                    SKU__c,
                                                    GE_LGT_EM_DisputeCount__c,
                                                    Requested_Action_Override__c,
                                                    Total_Returned__c,
                                                    Available_for_Return__c,
                                                    QuickStock__c,
                                                    No_Of_Products_Failed__c,
                                                    Installed_Qty__c,
                                                    Date_Installed__c,
                                                    Price_Agreement__c,
                                                    Comment__c,
                                                    Invoiced_Amount__c,
                                                    Minimum_Order_Qty__c,
                                                    GE_LGT_EM_Material__c,
                                                    GE_LGT_EM_InvoiceHeaderNumber__r.Agent__c,
                                                    GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c,
                                                    GE_LGT_EM_Material__r.Id 
                                                    FROM GE_LGT_EM_InvoiceLineItem__c 
                                                    WHERE GE_LGT_EM_Payer_Sold_to_Account_Number__c= :soldTo
                                                    AND GE_LGT_EM_Order_Number__c LIKE :searchText];
            
            
            system.debug('Return Data :' +inv);
            return inv;
        }
        
    } 

    // NEW INVOICE LINE SEARCH FOR CASE TYPES - IF AGENT AND SOLD TO SELECTED IN ACCOUNT SELECTOR
    @AuraEnabled 
    public static List<GE_LGT_EM_InvoiceLineItem__c> agentAndSoldToFiltering(String soldTo, String agentNumber, String userType) {  
        //string searchText = '%'+searchKey+'%'; 
        System.Debug('Sold To: '+soldTo);
        System.Debug('Agent Number: '+agentNumber);
        System.Debug('User Type: '+userType);
        
       if(userType == 'Agent'){
            List<GE_LGT_EM_InvoiceLineItem__c> inv =  [SELECT
                                                    Id,
                                                    GE_LGT_EM_InvoiceHeaderNumber__r.Name,
                                                    GE_LGT_EM_InvoiceHeaderNumber__c,   
                                                    GE_LGT_EM_SAP_Invoice_Number__c, 
                                                    GE_LGT_EM_Order_Number__c, 
                                                    GE_LGT_EM_Customer_PO_Number__c,
                                                    GE_LGT_EM_Sales_Unit__c,
                                                    GE_LGT_EM_Material_Description__c, 
                                                    GE_LGT_EM_Invoiced_Price__c, 
                                                    GE_LGT_EM_Invoiced_Quantity__c,
                                                    GE_LGT_EM_SAP_LineItemNumber__c, 
                                                    SKU__c,
                                                    GE_LGT_EM_DisputeCount__c,
                                                    Requested_Action_Override__c,
                                                    Total_Returned__c,
                                                    Available_for_Return__c,
                                                    QuickStock__c,
                                                    No_Of_Products_Failed__c,
                                                    Installed_Qty__c,
                                                    Date_Installed__c,
                                                    Price_Agreement__c,
                                                    Comment__c,
                                                    Invoiced_Amount__c,
                                                    Minimum_Order_Qty__c,
                                                    GE_LGT_EM_Material__c,
                                                    GE_LGT_EM_InvoiceHeaderNumber__r.GE_LGT_EM_Doc_Type__c,
                                                    GE_LGT_EM_InvoiceHeaderNumber__r.Agent__c,
                                                    GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c,
                                                    GE_LGT_EM_Material__r.Id  
                                                    FROM GE_LGT_EM_InvoiceLineItem__c 
                                                    WHERE GE_LGT_EM_InvoiceHeaderNumber__r.GE_LGT_EM_Doc_Type__c = 'F2-Invoice' AND GE_LGT_EM_Payer_Sold_to_Account_Number__c =:soldTo AND GE_LGT_EM_InvoiceHeaderNumber__r.Agent__c =:agentNumber];
            
            
            system.debug('Return Data :' +inv);
            return inv;
        } else {
            List<GE_LGT_EM_InvoiceLineItem__c> inv =  [SELECT
                                                    Id,
                                                    GE_LGT_EM_InvoiceHeaderNumber__r.Name,
                                                    GE_LGT_EM_InvoiceHeaderNumber__c,   
                                                    GE_LGT_EM_SAP_Invoice_Number__c, 
                                                    GE_LGT_EM_Order_Number__c, 
                                                    GE_LGT_EM_Customer_PO_Number__c,
                                                    GE_LGT_EM_Sales_Unit__c,
                                                    GE_LGT_EM_Material_Description__c, 
                                                    GE_LGT_EM_Invoiced_Price__c, 
                                                    GE_LGT_EM_Invoiced_Quantity__c,
                                                    GE_LGT_EM_SAP_LineItemNumber__c, 
                                                    SKU__c,
                                                    GE_LGT_EM_DisputeCount__c,
                                                    Requested_Action_Override__c,
                                                    Total_Returned__c,
                                                    Available_for_Return__c,
                                                    QuickStock__c,
                                                    No_Of_Products_Failed__c,
                                                    Installed_Qty__c,
                                                    Date_Installed__c,
                                                    Price_Agreement__c,
                                                    Comment__c,
                                                    Invoiced_Amount__c,
                                                    Minimum_Order_Qty__c,
                                                    GE_LGT_EM_Material__c,
                                                    GE_LGT_EM_InvoiceHeaderNumber__r.GE_LGT_EM_Doc_Type__c,
                                                    GE_LGT_EM_Material__r.GE_LGT_EM_Distribution_Chain_Status__c,
                                                    GE_LGT_EM_Material__r.Id  
                                                    FROM GE_LGT_EM_InvoiceLineItem__c 
                                                    WHERE GE_LGT_EM_InvoiceHeaderNumber__r.GE_LGT_EM_Doc_Type__c = 'F2-Invoice' AND GE_LGT_EM_Payer_Sold_to_Account_Number__c= :soldTo];
            
            
            system.debug('Return Data :' +inv);
            return inv;
        }
        
    } 


    
    @AuraEnabled 
    public static List<GE_LGT_EM_InvoiceLineItem__c> getInvLineNewList(String transId) {  
        
        return [SELECT
                Id,
                GE_LGT_EM_InvoiceHeaderNumber__r.Name,
                GE_LGT_EM_InvoiceHeaderNumber__c,   
                GE_LGT_EM_SAP_Invoice_Number__c, 
                GE_LGT_EM_Order_Number__c, 
                GE_LGT_EM_Customer_PO_Number__c,
                GE_LGT_EM_Sales_Unit__c,
                GE_LGT_EM_Material_Description__c, 
                GE_LGT_EM_Invoiced_Price__c, 
                GE_LGT_EM_Invoiced_Quantity__c,
                GE_LGT_EM_SAP_LineItemNumber__c, 
                SKU__c,
                GE_LGT_EM_DisputeCount__c,
                Requested_Action_Override__c,
                Total_Returned__c,
                Available_for_Return__c,
                QuickStock__c,
                No_Of_Products_Failed__c,
                Installed_Qty__c,
                Date_Installed__c,
                Price_Agreement__c,
                Comment__c,
                Invoiced_Amount__c,
                GE_LGT_EM_Material__c 
                FROM GE_LGT_EM_InvoiceLineItem__c 
                WHERE Id =: transId];
        
        
        
        
    } 
    
    @AuraEnabled
    public static List<Order> findOrders(String portalUser, String searchKey, String objectName, String filterFieldName, String distributorID) {
        String portalType = portalUser;
        String soldTo = distributorID;
        String searchTerm = '%'+searchKey+'%';
        String filter = filterFieldName; 
        System.debug('searchText ' + searchTerm);
        System.debug('Filter Field: '+filter);
        System.debug('User Type: '+portalType);
        System.debug('Sold To: '+soldTo);
        
        if(portalType == 'Agent' && (distributorID == null || distributorID == '')){
            List<Order> obj = [SELECT Id, Name, 
                               GE_Order_NO__c,
                               Customer_PO_Number__c,
                               Sold_To__c,
                               Agent_Account__c
                               FROM Order
                               WHERE
                               Agent_Account__c =: filter  AND 
                               (GE_Order_NO__c LIKE :searchTerm OR 
                                Customer_PO_Number__c LIKE :searchTerm) 
                               
                              ];
            return obj;
        }
        
        if(portalType == 'Agent' && (distributorID != null || distributorID != '')){
            List<Order> obj = [SELECT Id, Name, 
                               GE_Order_NO__c,
                               Customer_PO_Number__c,
                               Sold_To__c,
                               Agent_Account__c
                               FROM Order
                               WHERE
                               Agent_Account__c =: filter  AND Sold_To__c =: soldTo AND
                               (GE_Order_NO__c LIKE :searchTerm OR 
                                Customer_PO_Number__c LIKE :searchTerm) 
                               
                              ];
            return obj;
        }
        
        if(portalType == 'Distributor' || portalType == 'Customer'){
            
            List<Order> obj = [SELECT Id, Name, 
                               GE_Order_NO__c,
                               Customer_PO_Number__c,
                               Sold_To__c,
                               Agent_Account__c
                               FROM Order
                               WHERE
                               Sold_To__c =: filter  AND 
                               (GE_Order_NO__c LIKE :searchTerm OR 
                                Customer_PO_Number__c LIKE :searchTerm) 
                               
                              ];
            return obj;
        }
        
        return null;
    }
    
    @AuraEnabled(cacheable=false)
    public static string updateInvItem(GE_LGT_EM_InvoiceLineItem__c data) {
        
        upsert data Id;
        return 'Success: Line Item Modified';
    }
    
   /* @AuraEnabled
    public static List<CustomerProductFamily__c> getProductFamilies(Id soldToAccId, Id agentAccountId){
        
        System.debug('Agent ID Passed to Apex: '+ agentAccountId);
        System.debug('SOLD TO ID Passed to Apex: '+ soldToAccId);


       Set<String> returnProdFamilies = new Set<String>();
        List<String> prodFamiliesReturn = new List<String>();
        List<Set<String>> prodFamiliesList = new List<Set<String>>();


                    List<CustomerProductFamily__c> testFamily = [SELECT ProductFamily1__c,ProductFamily2__c,ProductFamily3__c,
                        ProductFamily4__c,ProductFamily5__c,ProductFamily6__c,ProductFamily7__c,ProductFamily8__c,
                        ProductFamily9__c,ProductFamily10__c,ProductFamily11__c,ProductFamily12__c,ProductFamily13__c,
                        ProductFamily14__c,ProductFamily15__c,ProductFamily16__c,ProductFamily17__c,ProductFamily18__c,
                        ProductFamily19__c,ProductFamily20__c
                        FROM CustomerProductFamily__c
                        WHERE SAPCustomerNumber__c = :soldToAccId OR SAPCustomerNumber__c =:agentAccountId];

                        system.debug('TEST FAMILY RESULTS: '+testFamily);
            
                   return testFamily;
        
    }*/
    @AuraEnabled
    public static List<State__mdt> findStateRecords(String searchKey, String objectName, String filterField, String filterFieldValue) {
        string searchText = +searchKey+'%';
        List<State__mdt> state = [SELECT MasterLabel FROM State__mdt where MasterLabel LIKE :searchText ORDER BY MasterLabel ASC ];
        system.debug(state);
        return state;
    }
    
}
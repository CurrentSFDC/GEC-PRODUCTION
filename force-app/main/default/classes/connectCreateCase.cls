public without sharing class connectCreateCase {
    @AuraEnabled
    public static String connectCreateReturnCase(Case newCase){
        insert newCase;
        return newCase.Id;    
    } 
    
     @AuraEnabled
    public static String getCaseNumber(Id CaseId){

         Case cs =[Select CaseNumber from Case where Id=:CaseId];
        return cs.CaseNumber;    
    } 
    
    // SETS THE OWNER ID FOR CASE TYPE NEW SPEC REGISTRATION
    @AuraEnabled
    public static void updateOwnerId(Id CaseId){
        Case cs = [Select Id, Type, GE_NAS_Sub_Type__c,OwnerId,Spec_Reg_Agency__c from Case where id = :CaseId];
        
		if(cs.Type == 'Sales Support' && cs.GE_NAS_Sub_Type__c == 'New Specification Registration'){
       		 Account acc = [Select ManagerId__c from Account where Id = :cs.Spec_Reg_Agency__c];        	 
            
        	 cs.OwnerId = acc.ManagerId__c;
            	update cs;
        }
    }
    
     @AuraEnabled
    
    public static String getOwnerId(String Spec_Reg_Agency){
        Account acc = [Select OwnerId from Account where Id = :Spec_Reg_Agency]; 
        //User us = [Select Name from User where id = : acc.OwnerId]; //Was ManagerId
        
        return acc.OwnerId;
    }
    
    // GET QUEUE ID FOR EXPEDITE, CHANGE REQUEST, CREDIT, AND WHEN CAN I GET IT? CASE TYPES
    @AuraEnabled
    public static String getCSOwnerId(Id accountId, Id distributorId, String userType){

        System.debug('Account ID: '+accountId); 
            // IF USER TYPE IS AGENT --> PULL CUSTOMER SERVICE QUEUE FROM AGENT ACCOUNT
            if(userType == 'Agent'){
                List<Account> acc = [Select Id, Customer_Service_Queue__c from Account where Id = :accountId];
                
                if(acc.size() > 0) {
                    String queueName = acc[0].Customer_Service_Queue__c; 
                    System.debug('Queue Name: '+queueName);
                    if(queueName != null){
                        Group csQId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name =: queueName];
                        return csQId.Id;
                    } else {
                        Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
                        return gpID.Id;
                    }
                } else {
                    //Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
                    //return gpID.Id;
                    return null;
                }
            //IF USER TYPE IS DISTRIBUTOR AND THE ORDER AGENT IS NOT NULL
            } else if (userType == 'Distributor' && accountId != null){
                List<Account> acc = [Select Id, Customer_Service_Queue__c from Account where Id = :accountId];
                
                if(acc.size() > 0) {
                    String queueName = acc[0].Customer_Service_Queue__c; 
                    System.debug('Queue Name: '+queueName);
                    if(queueName != null){
                        Group csQId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name =: queueName];
                        return csQId.Id;
                    } else {
                        Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
                        return gpID.Id;
                    }
                } else {
                    //Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
                    //return gpID.Id;
                    return null;
                }
            // IF USER TYPE IS DISTRIBUTOR AND THE ORDER AGENT IS NULL    
            }else if (userType == 'Distributor' && accountId == null && distributorId != null) {
                List<Account> acc = [Select Id, Customer_Service_Queue__c from Account where Id = :distributorId];
                
                if(acc.size() > 0) {
                    String queueName = acc[0].Customer_Service_Queue__c; 
                    System.debug('Queue Name: '+queueName);
                    if(queueName != null){
                        Group csQId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name =: queueName];
                        return csQId.Id;
                    } else {
                        Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
                        return gpID.Id;
                    }
                } else {
                    //Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
                    //return gpID.Id;
                    return null;
                }
            } else {
                Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
                return gpID.Id;
            }


    }

    // GET QUEUE ID FOR THE TECHNICAL SERVICE CASES - LAMP & BALLAST AND LED DRIVERS
    @AuraEnabled
    public static String getPGCSOwnerId(Id accountId){

        System.debug('Account ID: '+accountId); 
            // IF USER TYPE IS AGENT --> PULL CUSTOMER SERVICE QUEUE FROM AGENT ACCOUNT
            
                List<Account> acc = [Select Id, Customer_Service_Queue__c from Account where Id = :accountId];
                
                if(acc.size() > 0) {
                    String queueName = acc[0].Customer_Service_Queue__c; 
                    System.debug('Queue Name: '+queueName);
                    if(queueName != null){
                        Group csQId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name =: queueName];
                        return csQId.Id;
                    } else {
                        Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
                        return gpID.Id;
                    }
                } else {
                    Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
                    return gpID.Id;
                   
                }
            


    }

    // GET QUEUE ID FOR LIGHTING DESIGN REQUEST CASE TYPE
    @AuraEnabled
    public static String getLDRQueueId(){
        //Account acc = [Select OwnerId from Account where Id = :AccountId];
       
        Group ldr = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Lighting Design Requests Team'];
        
        return ldr.Id;
    }
    
    // GET QUEUE ID FOR CONNECT PLATFORM SUPPORT CASE TYPE
    @AuraEnabled
    public static string getDCSQueueId(){
        Group gp = [Select Id from Group where Name = 'DCS'];
        
        return gp.Id;
    }
    
    // GET QUEUE ID FOR TECHNICAL SUPPORT CASE TYPE
   /* @AuraEnabled
    public static string getTSQueueId(){
        Group ts = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Current Technical Support' limit 1];
        
        return ts.Id;
    }*/
    
     @AuraEnabled
    public static string getQueueIdTS(String productgroup){
		Connect_Queue_Assignments__mdt queuename = [SELECT Queue_Name__c FROM Connect_Queue_Assignments__mdt where Product_Group__c =:productgroup];
		
        return queuename.Queue_Name__c;
	
    }
    
    @AuraEnabled
    public static string getTSQueueId(String Queuename){
        Group ts = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name =: Queuename limit 1];
        
        return ts.Id;
    }


  

    // GET QUEUE ID FOR PRICING INQUIRY CASE TYPE
    @AuraEnabled
    public static string getPricingQueueId(){
        Group priceId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Pricing Queue' limit 1];
        
        return priceId.Id;
    }
    
    // GET QUEUE ID FOR MARKETING COLLATERAL CASE TYPE
    @AuraEnabled
    public static string getMarketingQueueId(String accountId, String userType){
            
        System.debug('Account ID: '+accountId); 
        if(userType == 'Agent'){
            List<Account> accAgent = [Select Id, toLabel(Channel_Marketing_Queue__c) from Account where Id = :accountId];
            
            if(accAgent.size() > 0) {
                String queueName = accAgent[0].Channel_Marketing_Queue__c; 
                System.debug('Queue Name: '+queueName);
                if(queueName != null){
                    Group returnQId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name =: queueName];
                    return returnQId.Id;
                } else {
                    Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
                    return gpID.Id;
                }
            } else {
                //Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
                //return gpID.Id;
                return null;
            }
        } else {

            List<Account> accDisOne = [Select Id, toLabel(Channel_Marketing_Queue__c) from Account where Id = :accountId];
            
            if(accDisOne.size() > 0) {
                String queueName = accDisOne[0].Channel_Marketing_Queue__c; 
                System.debug('Queue Name: '+queueName);
                if(queueName != null){
                    Group returnQId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name =: queueName];
                    return returnQId.Id;
                } else {
                    Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
                    return gpID.Id;
                }

            } else {


                List<Account> accDisTwo = [Select Id, toLabel(Distributor_Queue__c) from Account where Id = :accountId];
            
                    if(accDisTwo.size() > 0) {
                        String queueName = accDisTwo[0].Distributor_Queue__c; 
                        System.debug('Queue Name: '+queueName);
                        if(queueName != null){
                            Group returnQId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name =: queueName];
                            return returnQId.Id;
                        } else {
                            Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
                            return gpID.Id;
                        }
                    }

                //Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
                //return gpID.Id;
                return null;
            }
        }

        

    }

    // GET QUEUE ID FOR WARRANTY CASE TYPE
    @AuraEnabled
    public static string getWarrantyQueueId(Id accountId, Id distributorId, String userType){

        System.debug('Account ID: '+accountId); 
            // IF USER TYPE IS AGENT --> PULL CUSTOMER SERVICE QUEUE FROM AGENT ACCOUNT
            if(userType == 'Agent'){
                List<Account> acc = [Select Id, Warranty_Queue__c from Account where Id = :accountId];
                
                if(acc.size() > 0) {
                    String queueName = acc[0].Warranty_Queue__c; 
                    System.debug('Queue Name: '+queueName);
                    if(queueName != null){
                        Group csQId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name =: queueName];
                        return csQId.Id;
                    } else {
                        Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Current PSO Team'];
                        return gpID.Id;
                    }
                } else {
                    //Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
                    //return gpID.Id;
                    return null;
                }
            //IF USER TYPE IS DISTRIBUTOR AND THE INVOICE AGENT IS NOT NULL
            } else if (userType == 'Distributor' && accountId != null){
                List<Account> acc = [Select Id, Warranty_Queue__c from Account where Id = :accountId];
                
                if(acc.size() > 0) {
                    String queueName = acc[0].Warranty_Queue__c; 
                    System.debug('Queue Name: '+queueName);
                    if(queueName != null){
                        Group csQId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name =: queueName];
                        return csQId.Id;
                    } else {
                        Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Current PSO Team'];
                        return gpID.Id;
                    }
                } else {
                    //Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
                    //return gpID.Id;
                    return null;
                }
            // IF USER TYPE IS DISTRIBUTOR AND THE INVOICE AGENT IS NULL    
            }else if (userType == 'Distributor' && accountId == null && distributorId != null) {
                List<Account> acc = [Select Id, Warranty_Queue__c from Account where Id = :distributorId];
                
                if(acc.size() > 0) {
                    String queueName = acc[0].Warranty_Queue__c; 
                    System.debug('Queue Name: '+queueName);
                    if(queueName != null){
                        Group csQId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name =: queueName];
                        return csQId.Id;
                    } else {
                        Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Current PSO Team'];
                        return gpID.Id;
                    }
                } else {
                    //Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
                    //return gpID.Id;
                    return null;
                }
            } else {
                Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Current PSO Team'];
                return gpID.Id;
            }


    }
    
    // GET QUEUE ID FOR RETURN AND SHIPPING ISSUES (OVERAGE, SHORTAGE, LOST/DAMAGED) CASE TYPES
    @AuraEnabled
    public static String getReturnsQueueId(Id accountId, Id distributorId, String userType){
        System.debug('Account ID: '+accountId); 
        // IF USER TYPE IS AGENT --> PULL CUSTOMER SERVICE QUEUE FROM AGENT ACCOUNT
        if(userType == 'Agent'){
            List<Account> acc = [Select Id, Returns_Queue__c from Account where Id = :accountId];
            
            if(acc.size() > 0) {
                String queueName = acc[0].Returns_Queue__c; 
                System.debug('Queue Name: '+queueName);
                if(queueName != null){
                    Group csQId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name =: queueName];
                    return csQId.Id;
                } else {
                    Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
                    return gpID.Id;
                }
            } else {
                //Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
                //return gpID.Id;
                return null;
            }
        //IF USER TYPE IS DISTRIBUTOR AND THE INVOICE AGENT IS NOT NULL
        } else if (userType == 'Distributor' && accountId != null){
            List<Account> acc = [Select Id, Returns_Queue__c from Account where Id = :accountId];
            
            if(acc.size() > 0) {
                String queueName = acc[0].Returns_Queue__c; 
                System.debug('Queue Name: '+queueName);
                if(queueName != null){
                    Group csQId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name =: queueName];
                    return csQId.Id;
                } else {
                    Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
                    return gpID.Id;
                }
            } else {
                //Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
                //return gpID.Id;
                return null;
            }
        // IF USER TYPE IS DISTRIBUTOR AND THE INVOICE AGENT IS NULL    
        }else if (userType == 'Distributor' && accountId == null && distributorId != null) {
            List<Account> acc = [Select Id, Returns_Queue__c from Account where Id = :distributorId];
            
            if(acc.size() > 0) {
                String queueName = acc[0].Returns_Queue__c; 
                System.debug('Queue Name: '+queueName);
                if(queueName != null){
                    Group csQId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name =: queueName];
                    return csQId.Id;
                } else {
                    Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
                    return gpID.Id;
                }
            } else {
                //Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
                //return gpID.Id;
                return null;
            }
        } else {
            Group gpID = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Unrivalled'];
            return gpID.Id;
        }
    } 

     /*
     // GET QUEUE ID FOR WHEN CAN I GET IT
     @AuraEnabled
     public static String gpOwnerId(String AccountId){
         //Account acc = [Select OwnerId from Account where Id = :AccountId];
         System.debug('Account ID: '+AccountId); 
         Account acc = [Select toLabel(Growth_Partner_Queue__c) from Account where Id = :AccountId];
         String queueName = acc.Growth_Partner_Queue__c; 
         System.debug('Queue Name: '+queueName);
         Group whenId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name =: queueName];
         
         return whenId.Id;
     }*/
    
    
     @AuraEnabled
    
    public static String getAccountName(String id_dtl){
        Account acc = [Select Name from Account where Id = :id_dtl]; 
        
        return acc.Name;
    }

    @AuraEnabled
    
    public static String getOrderStatus(String orderId){
        Order order = [Select GBSTK__c from Order where Id = :orderId];
        
        String orderStatus = order.GBSTK__c;
        return orderStatus;
    }
    
    @AuraEnabled
    
    public static String getOrderNum(String orderId){
        Order order = [Select GE_Order_NO__c from Order where Id = :orderId];
        
         
        return order.GE_Order_NO__c;
    }
    
     @AuraEnabled
    
    public static String getSoldTo(String orderId){
        Order order = [Select Sold_To__c from Order where Id = :orderId];
        
        Account acc = [Select GE_LGT_EM_SAP_Customer_Number__c from Account where Id = : order.Sold_To__c];
         
        String soldTo =  acc.GE_LGT_EM_SAP_Customer_Number__c;   
        return soldTo;
    }

    @AuraEnabled
    
    public static String getSoldToNew(String orderId){
        Order order = [Select Sold_To__c from Order where Id = :orderId];
        
       Account acc = [Select Name, GE_LGT_EM_SAP_Customer_Number__c, Customer_Segmentation__c from Account where Id = : order.Sold_To__c];
           String accNew = acc.Name + ' - ' + acc.GE_LGT_EM_SAP_Customer_Number__c + ' - ' + acc.Customer_Segmentation__c;
        return accNew;
    }
    
    @AuraEnabled
    
    public static String getAccountManagerName(String AccountId){
        Account acc = [Select OwnerId from Account where Id = :AccountId]; 
        User us = [Select FirstName, LastName from User where id = : acc.OwnerId]; //Was ManagerId
        
        String FullName = us.FirstName + ' ' +us.LastName;
        return FullName;
    }
    
    @AuraEnabled
    public static void updateFiles(List<Id> passFiles, Id CaseId){
        System.Debug('List of IDs: ' + passFiles);
        System.Debug('Case ID: '+ CaseId);
        List<ContentVersion> contVer = new List<ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :passFiles]);
        System.Debug('List of Content Version' + contVer);

        List<ContentDocumentLink> contLink = new List<ContentDocumentLink>();

        for(ContentVersion cv : contVer){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.LinkedEntityId = CaseId;
            cdl.Visibility = 'AllUsers';
            contLink.add(cdl);
        }
       insert contLink; 
    } 
       
    @AuraEnabled
    public static void createCaseProduct(List<Shipment_Detail__c> newCaseProduct){
		insert newCaseProduct;
        /*system.debug('CaseNumber11');
        System.Debug('List of IDs: ' + orderLines);
        Case caseList = [Select Id, Type, GE_NAS_Sub_Type__c, Product_SKU__c from Case where type = 'Returns' and GE_NAS_Sub_Type__c = 'New RGA'
            			 and Id = :CaseNumber];
        system.debug('CaseNumber' +CaseNumber);
        
        List<Return_Order_Item__c> returnOrder = new List<Return_Order_Item__c>([select Id, Name, Product_Name__c, Quantity__c,Return_Qty__c, SKU__c, 
                                                                                 UnitPrice__c, Requested_Action_Override__c, Shipment_Date__c from Return_Order_Item__c
                                           										 where id =: orderLines]);
        
        List<Shipment_Detail__c> caseProductList = new List<Shipment_Detail__c>();
        
        for(OrderItem roi : orderLines){
            Shipment_Detail__c caseProd = new Shipment_Detail__c();
            caseProd.GE_NAS_Case_Number__c = caseList.Id;
            caseProd.Product_Number__c = roi.Product_Name__c;
            caseProd.GE_NAS_Type_of_Problem1__c = roi.Requested_Action_Override__c;
            caseProd.Invoiced_Price__c = roi.UnitPrice__c;
            caseProductList.add(caseProd);                        
        }
        
        insert caseProductList;*/
        	
      }

      @AuraEnabled
    public static Boolean createReturnItems(List<Return_Order_Item__c> newRI){
		insert newRI;
        	return true;
      }


      @AuraEnabled(cacheable=true)
      public static List<Shipment_Detail__c> getCaseProducts(String caseId){
          List<Shipment_Detail__c> productList = [SELECT GE_NAS_Comments__c, PO__c, Installed_Qty__c, Install_Date__c, No_Cat_Number__c, No_Cat__c, QuickStock__c, Material_Description__c, GE_NAS_Unit_of_Measure__c, SAP_Material__c, GE_NAS_Quantity_Ordered__c,GE_NAS_Type_of_Problem1__c,Order_Qty__c,Non_Finished_Good_SKU__c,Discrepancy_Qty__c,Invoiced_Price__c,Discrepancy_Total__c,Requested_Delivery_Date__c
           FROM Shipment_Detail__c WHERE GE_NAS_Case_Number__c =: caseId];
          return productList; 
      }

      @AuraEnabled(cacheable=true)
      public static List<Case> getCaseFields(String caseId, String caseFields){
        
        String findCase = caseId;
    
        String fields = caseFields;
        
        return Database.query('SELECT ' +fields+ ' FROM Case WHERE Id = :findCase');

        //return caseList;


        //String resolvedField1 = myVariable.field1__c;
        //List<sObject> sobjList = Database.query('SELECT Id FROM MyCustomObject__c WHERE field1__c =  :resolvedField1');
      }

      
      @AuraEnabled(cacheable=true)
      public static List<Dispute_Request__c> getDisputeRequests(String caseId){
          List<Dispute_Request__c> disputes = [SELECT Id, (select Id, Install_Date__c,Non_Finished_Good_SKU__c, QuickStock__c, Installed_Qty__c, SAP_Material__c, Discrepancy_Qty__c, GE_NAS_Unit_of_Measure__c, Material_Description__c, Invoiced_Price__c, Discrepancy_Total__c, GE_NAS_Type_of_Problem1__c
          FROM Case_Products__r ) Name, Sold_To__r.Name, CreatedDate, Customer_PO__c, Connect_Request__c, Original_Order__c, Status__c, Type__c, Discrepancy_Total__c, Case__c, Order__c, Invoice__c, Current_Order__c, Site_Contact_Address__c FROM Dispute_Request__c WHERE Case__c =: caseId];
           return disputes;
    }

    
    /*@AuraEnabled(cacheable=true)
    public static List<Shipment_Detail__c> getAllDisputeProducts(String disputeID){
        List<Shipment_Detail__c> products = [SELECT Id, SAP_Material__c, PO__c,GE_NAS_Unit_of_Measure__c, QuickStock__c, Non_Finished_Good_SKU__c, Discrepancy_Qty__c, Material_Description__c, Invoiced_Price__c, Discrepancy_Total__c, GE_NAS_Type_of_Problem1__c, Requested_Delivery_Date__c
        FROM Shipment_Detail__c WHERE Dispute_Request__c =: disputeID]; 
        return products;
  }*/


    
    @AuraEnabled
    
    public static String getAgentId(String AccountId){
        Account acc = [Select Account_Group__c,GE_LGT_EM_SAP_Customer_Number__c	 from Account where Id = :AccountId]; 
        String agtype;
        if(acc.Account_Group__c=='ZEAG'){
            agtype = acc.GE_LGT_EM_SAP_Customer_Number__c;
        }
        else
        {
          agtype='N'; 
        }
        return agtype;
    }

    // USED TO GET THE CASE COMMENTS ON VIEWED CASE
    @AuraEnabled
    public static List<CaseComment> getCaseComments(String caseId){
        List<CaseComment> comments = [SELECT Id, ParentId, CommentBody, CreatedDate, CreatedById, CreatedBy.Name FROM CaseComment WHERE ParentId =: caseId ORDER BY CreatedDate DESC];
        return comments;
    }

    @AuraEnabled
    public static String createCaseComment(CaseComment newComment){
        insert newComment;
        return newComment.Id;    
    }

    @AuraEnabled
    public static Boolean updateInvLines(List<Id> lines){
        List<GE_LGT_EM_InvoiceLineItem__c> getInv = [SELECT Id, GE_LGT_EM_DisputeCount__c, Requested_Action_Override__c FROM GE_LGT_EM_InvoiceLineItem__c WHERE Id IN :lines ];
        List<GE_LGT_EM_InvoiceLineItem__c> updInv = new List<GE_LGT_EM_InvoiceLineItem__c>();
        for(GE_LGT_EM_InvoiceLineItem__c inv : getInv){
            inv.GE_LGT_EM_DisputeCount__c = null;
            inv.Requested_Action_Override__c = null;
            inv.No_Of_Products_Failed__c = null;
            inv.Date_Installed__c = null;
            inv.Installed_Qty__c = null;
            inv.Comment__c = null;
            updInv.add(inv);
        }
        update updInv;
       return true;
        
    }

    @AuraEnabled
    public static Boolean updateOrdLines(List<Id> lines){
        List<OrderItem> getInv = [SELECT Id, Reason_for_Change__c, Category_Of_Change__c,New_Shipment_Date__c FROM OrderItem WHERE Id IN :lines ];
        System.debug('Order Lines in APEX to Update: '+lines);
        List<OrderItem> updInv = new List<OrderItem>();
        for(OrderItem inv : getInv){
            inv.Reason_for_Change__c = null;
            inv.Category_Of_Change__c = null;
            inv.New_Shipment_Date__c = null;
            updInv.add(inv);
        }
        update updInv;
       return true;
        
    }

    // THIS IS USED TO APPROVE CASE PRODUCTS ON THE DISPUTE REQUEST
    @AuraEnabled(cacheable=true)
    public static List<Shipment_Detail__c> getDisputeProducts(String disId){
        List<Shipment_Detail__c> prod = [SELECT SAP_Material__c,
        Material_Description__c,
        PO__c,
        Discrepancy_Total__c,
        Discrepancy_Qty__c,
        GE_NAS_Unit_of_Measure__c,
        QuickStock__c,
        No_Cat_Number__c,
        Approved__c,
        No_Cat__c,
        GE_NAS_Product_Code__c,
        Invoiced_Price__c,
        Install_Date__c, 
        Installed_Qty__c, 
        GE_NAS_Type_of_Problem1__c,
        GE_NAS_Type_of_Problem__c,
        Order_Qty__c,
        GE_NAS_Comments__c,
        In_Approval_Process__c,
        is_Warranty__c,
        Non_Finished_Good_SKU__c
        FROM Shipment_Detail__c
        WHERE
        Dispute_Request__c =: disId];
        System.debug('Products Retrieved '+prod);
        return prod;
        
    }
    

}
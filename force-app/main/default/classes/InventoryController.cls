/*----------------------------------------------------------------------
Name:       InventoryController.cls
Purpose:    Call SAP For Inventory Availability
------------------------------History----------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          ------------------
1.0         Devang          07-Nov-2020           Initial Development 
----------------------------------------------------------------------*/

global with sharing class InventoryController {
    
    public static final String UOM_PC = 'PC';
    @testVisible private static SAPGatewayInterface service = new SAPGateway();
    
    @TestVisible private static Account getAccount(){
        Id userId = UserInfo.getUserId();
        User u = [SELECT Id, ContactId,  Account.Id FROM User WHERE Id = : userId];
        
        Account account = [
            SELECT Id,
            Name,
            GE_LGT_EM_SAP_Customer_Number__c,
            GE_LGT_EM_Sales_Org__c,
            GE_LGT_EM_Division__c,
            GE_LGT_EM_Distribution_Channel__c,
            Delivering_Plant__c,
            Account_Group__c,
            GE_LGT_Rep_Code__c
            FROM Account 
            WHERE Id = :u.Account.Id
        ];
        return account;
        
    } 
    
    @TestVisible private static Account getEffectiveAccount(String effectiveAccountId){
        
        Account account = [
            SELECT Id,
            Name,
            GE_LGT_EM_SAP_Customer_Number__c,
            GE_LGT_EM_Sales_Org__c,
            GE_LGT_EM_Division__c,
            GE_LGT_EM_Distribution_Channel__c,
            Delivering_Plant__c,
            Account_Group__c,
            Customer_Segmentation__c,
            GE_LGT_Rep_Code__c
            FROM Account 
            WHERE Id = :effectiveAccountId
        ];
        return account;        
    } 
    
    
    public static List<DefaultWarehouseInventory> get2448HrAvailability(String invLocation, List<Id> ids){
        String quantity = '';
        String delimiter = '/';
        List<DefaultWarehouseInventory> dwList = new List<DefaultWarehouseInventory>();
        List<ccrz__E_ProductInventoryItem__c> lstInvItem = [SELECT ccrz__ProductItem__c, InventoryLocations__c,  TotalQtyAvailable__c FROM ccrz__E_ProductInventoryItem__c WHERE ccrz__ProductItem__c IN :ids];
        if(lstInvItem != null){
            for(ccrz__E_ProductInventoryItem__c inv: lstInvItem){
                List<String> res = inv.InventoryLocations__c.split(',');
                for(String s : res){
                    String firstSplit = s.substringBefore(delimiter);
                    String lastSplits = s.substringAfter(delimiter); 
                    if(firstSplit == invLocation){
                        quantity = lastSplits;
                        break;
                    }
                }
                DefaultWarehouseInventory dInv = new DefaultWarehouseInventory();
                dInv.productId = inv.ccrz__ProductItem__c;
                dInv.totalQuantity = Integer.valueOf(lstInvItem[0].TotalQtyAvailable__c);
                dInv.defaultWarehouseQuantity = quantity;
                dwList.add(dInv);
            }
        }
        return dwList;
    }
    
    public static String get2448HrAvailability(String invLocation, ID ProductId){
        String quantity = '';
        String delimiter = '/';
        List<ccrz__E_ProductInventoryItem__c> lstInvItem = [SELECT InventoryLocations__c FROM ccrz__E_ProductInventoryItem__c WHERE ccrz__ProductItem__c=:ProductId LIMIT 1];
        if(lstInvItem != null && lstInvItem[0].InventoryLocations__c != null){
            
            List<String> res = lstInvItem[0].InventoryLocations__c.split(',');
            for(String s : res){
                String firstSplit = s.substringBefore(delimiter);
                String lastSplits = s.substringAfter(delimiter); 
                if(firstSplit.equals(invLocation)){
                    quantity = lastSplits;
                    break;
                }
            }
        }
        return quantity;
    }
    
    public static List<Inventory> getInventoryAvailabilityInAllLocations(ID ProductId){
        String quantity = '';
        String delimiter = '/';
        List<Inventory> invList = new List<Inventory>();
        List<ccrz__E_ProductInventoryItem__c> lstInvItem = [SELECT InventoryLocations__c, TotalQtyAvailable__c FROM ccrz__E_ProductInventoryItem__c WHERE ccrz__ProductItem__c=:ProductId LIMIT 1];
        if(lstInvItem != null && lstInvItem[0].InventoryLocations__c != null){
            List<String> res = lstInvItem[0].InventoryLocations__c.split(',');
            for(String s : res){
                String firstSplit = s.substringBefore(delimiter);
                String lastSplits = s.substringAfter(delimiter); 
                Inventory inv =  new Inventory();
                inv.warehouseCode = firstSplit;
                inv.warehouseName = lastSplits;
                inv.totalQuantity = Integer.valueOf(lstInvItem[0].TotalQtyAvailable__c);
                inv.quantity = Integer.valueOf(lstInvItem[0].TotalQtyAvailable__c);
                invList.add(inv);
            }
        }
        return getWarehouseNames(invList);
    }
    
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getInventoryAvailability(ccrz.cc_RemoteActionContext ctx, String skusJson, String productsJson, String agentID, String CustID) {
        list<String> skuList =(List<String>)System.JSON.deserialize(skusJson,List<String>.class);
        list<String> ids =(List<String>)System.JSON.deserialize(productsJson,List<String>.class);
        Date dateToday = Date.today();
       
        //String sToday = String.valueof(dateToday.year()) + String.valueof(dateToday.month()) + String.valueof(dateToday.day());     
        String sToday = Datetime.now().format('yyyyMMdd');        
        Account effAcc;
        System.debug('ids size =' + ids.size());
        System.debug('ids =' + ids);
        System.debug('sku List size ' + skuList.size());
        System.debug('sku List =' + skuList);
        System.debug('agentID =' + agentID);
        System.debug('CustID =' + CustID);
        
        
        if(!Test.isRunningTest()) {
            ccrz.cc_CallContext.initRemoteContext(ctx);
        }
        ccrz.cc_RemoteActionResult res = new ccrz.cc_RemoteActionResult();
        res.success = false;
        res.inputContext = ctx;
        Account acc = getAccount();
        
        
        System.debug('account data = ' +  acc.GE_LGT_EM_SAP_Customer_Number__c + '|' + acc.GE_LGT_EM_Division__c + '|' +  acc.GE_LGT_EM_Distribution_Channel__c + '|' +  acc.GE_LGT_EM_Sales_Org__c + '|'  +  acc.Delivering_Plant__c);
        
        InventoryRequest req = new InventoryRequest();
         req.IsQuickstock = true;
        req.customer = '';
        req.agent = '';
        if(String.isNotBlank(agentID)){
            effAcc = getEffectiveAccount(agentID);
            req.defaultWarehouseCode = effAcc.Delivering_Plant__c;
            if(String.isNotBlank(effAcc.Account_Group__c) && effAcc.Account_Group__c == 'ZEAG' && effAcc.Customer_Segmentation__c=='FD'){
                req.agent = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
            }   
        }
        else if(String.isNotBlank(CustID)){
            effAcc = getEffectiveAccount(CustID);
            if(effAcc.Account_Group__c == 'ZEAG' && effAcc.Customer_Segmentation__c=='FD') {
                req.agent = effAcc.GE_LGT_EM_SAP_Customer_Number__c;   
            }   
        }
        
        
        if(String.isNotBlank(CustID)){
            
            effAcc = getEffectiveAccount(CustID);
            req.defaultWarehouseCode = effAcc.Delivering_Plant__c;
            
            if(effAcc.Account_Group__c == 'Z001') {
                req.customer = effAcc.GE_LGT_EM_SAP_Customer_Number__c;   
            }     
        }
        
        /*effAcc = getEffectiveAccount(ccrz.cc_CallContext.effAccountId);
if(effAcc.Account_Group__c == 'ZEAG'){
req.userType = 'Agent';
}else if(effAcc.Account_Group__c=='Z001'){
req.userType = 'Customer';
} else {
req.userType = '';
}*/
        /*if(ccrz.cc_CallContext.currAccountId != ccrz.cc_CallContext.effAccountId){
//Get Effective Account Customer Number 
effAcc = getEffectiveAccount(ccrz.cc_CallContext.effAccountId);
if (effAcc != null && String.isNotBlank(effAcc.GE_LGT_EM_SAP_Customer_Number__c)){
req.customer = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
System.debug('Customer SAP Number ' + req.customer);
}
}*/
        
        Id userId = UserInfo.getUserId();
        User effUser=[Select id,User_Type__c from user where id=:userId];
        
        if(effUser!=null){
            if(effUser.User_Type__c=='Agent'){
                req.userType = 'AGENT';
            } 
            else if(effUser.User_Type__c=='Distributor'){
                req.userType = 'CUSTOMER';                    
            }
            else {
                req.userType = '';
            }
            
        }
        req.reqDelDate = sToday;
        req.poleType = '1';
        req.agreement = '';
        req.spart = acc.GE_LGT_EM_Division__c;        
        req.salesOrg = acc.GE_LGT_EM_Sales_Org__c;
        req.division = acc.GE_LGT_EM_Division__c;
        req.distChannel = acc.GE_LGT_EM_Distribution_Channel__c;
        
        /*if(String.isNotBlank(acc.Account_Group__c) && acc.Account_Group__c == 'ZEAG' && String.isNotBlank(acc.GE_LGT_Rep_Code__c) ){
req.agent = acc.GE_LGT_EM_SAP_Customer_Number__c;
} else {
req.agent = '';
}*/        
        
        /*if(String.isNotBlank(acc.Delivering_Plant__c)){
req.defaultWarehouseCode = acc.Delivering_Plant__c;
} else {
req.defaultWarehouseCode = '';
}*/        
        
        List<Inventory> inventoryList = new List<Inventory>();
        integer lineNumebr = 0;
        for(String sku: skuList){
            Inventory inv = new Inventory();
            System.debug('sku=' + sku);           
            lineNumebr += 10;
            inv.material = sku;                
            inv.quantity = 1;
            inv.lineItem = lineNumebr;
            inv.UOM = UOM_PC;            
            inventoryList.add(inv);
        }      
        req.inventoryList = inventoryList;
      
        ccrz__E_Product__c quickship = new ccrz__E_Product__c();
        if(!ids.contains('materialdescription')){
            quickship = [SELECT Quickship__c FROM ccrz__E_Product__c WHERE ccrz__SKU__c=:inventoryList[0].material LIMIT 1];
        }
        if((quickship!=null && quickship.Quickship__c ==false) || ids.contains('materialdescription')){
           // req.defaultWarehouseCode ='';
          req.IsQuickstock = false;
            
        }
        System.debug('request=' +  req);
        //SAPGateway sg = new SAPGateway();    
        //InventoryResponse  resp = sg.getInventoryAvailability(req);
        
        InventoryResponse  resp = service.getInventoryAvailability(req);
        System.debug('response=' +  resp);
        res.data = resp;
        res.success = true;
        return res;
    }
    
    //Changes by Ravi Singh for Inventory SAP call from Community
    @AuraEnabled(Cacheable=true)
    public static InventoryResponse getInventoryAvailabilityForComm(String sku, String agentID, String CustID) {
        //string effProd = sku;
        //system.debug('effProd'+effProd);
        //list<String> skuList =(List<String>)System.JSON.deserialize(skusJson,List<String>.class);
        //list<String> ids =(List<String>)System.JSON.deserialize(productsJson,List<String>.class);
        Date dateToday = Date.today();
        //String sToday = String.valueof(dateToday.year()) + String.valueof(dateToday.month()) + String.valueof(dateToday.day());     
        String sToday = Datetime.now().format('yyyyMMdd');        
        Account effAcc;
        //System.debug('ids size =' + ids.size());
        //System.debug('ids =' + ids);
        //System.debug('sku List size ' + skuList.size());
        //System.debug('sku List =' + skuList);
        System.debug('agentID =' + agentID);
        System.debug('CustID =' + CustID);
        
        
        
        /*if(!Test.isRunningTest()) {
ccrz.cc_CallContext.initRemoteContext(ctx);
}*/
        //ccrz.cc_RemoteActionResult res = new ccrz.cc_RemoteActionResult();
        //res.success = false;
        //res.inputContext = ctx;
        Account acc = getAccount();
        
        
        System.debug('account data = ' +  acc.GE_LGT_EM_SAP_Customer_Number__c + '|' + acc.GE_LGT_EM_Division__c + '|' +  acc.GE_LGT_EM_Distribution_Channel__c + '|' +  acc.GE_LGT_EM_Sales_Org__c + '|'  +  acc.Delivering_Plant__c);
        
        InventoryRequest req = new InventoryRequest();
        req.customer = '';
        req.agent = '';
        if(String.isNotBlank(agentID)){
            effAcc = getEffectiveAccount(agentID);
            req.defaultWarehouseCode = effAcc.Delivering_Plant__c;
            if(String.isNotBlank(effAcc.Account_Group__c) && effAcc.Account_Group__c == 'ZEAG' && effAcc.Customer_Segmentation__c=='FD'){
                req.agent = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
            }   
        }
        else if(String.isNotBlank(CustID)){
            effAcc = getEffectiveAccount(CustID);
            if(effAcc.Account_Group__c == 'ZEAG' && effAcc.Customer_Segmentation__c=='FD') {
                req.agent = effAcc.GE_LGT_EM_SAP_Customer_Number__c;   
            }   
        }
        
        
        if(String.isNotBlank(CustID)){
            
            effAcc = getEffectiveAccount(CustID);
            req.defaultWarehouseCode = effAcc.Delivering_Plant__c;
            
            if(effAcc.Account_Group__c == 'Z001') {
                req.customer = effAcc.GE_LGT_EM_SAP_Customer_Number__c;   
            }     
        }
        
        /*effAcc = getEffectiveAccount(ccrz.cc_CallContext.effAccountId);
if(effAcc.Account_Group__c == 'ZEAG'){
req.userType = 'Agent';
}else if(effAcc.Account_Group__c=='Z001'){
req.userType = 'Customer';
} else {
req.userType = '';
}*/
        /*if(ccrz.cc_CallContext.currAccountId != ccrz.cc_CallContext.effAccountId){
//Get Effective Account Customer Number 
effAcc = getEffectiveAccount(ccrz.cc_CallContext.effAccountId);
if (effAcc != null && String.isNotBlank(effAcc.GE_LGT_EM_SAP_Customer_Number__c)){
req.customer = effAcc.GE_LGT_EM_SAP_Customer_Number__c;
System.debug('Customer SAP Number ' + req.customer);
}
}*/
        
        Id userId = UserInfo.getUserId();
        User effUser=[Select id,User_Type__c from user where id=:userId];
        
        if(effUser!=null){
            if(effUser.User_Type__c=='Agent'){
                req.userType = 'AGENT';
            } 
            else if(effUser.User_Type__c=='Distributor'){
                req.userType = 'CUSTOMER';                    
            }
            else {
                req.userType = '';
            }
            
        }
        req.reqDelDate = sToday;
        req.poleType = '1';
        req.agreement = '';
        req.spart = acc.GE_LGT_EM_Division__c;        
        req.salesOrg = acc.GE_LGT_EM_Sales_Org__c;
        req.division = acc.GE_LGT_EM_Division__c;
        req.distChannel = acc.GE_LGT_EM_Distribution_Channel__c;
        
        /*if(String.isNotBlank(acc.Account_Group__c) && acc.Account_Group__c == 'ZEAG' && String.isNotBlank(acc.GE_LGT_Rep_Code__c) ){
req.agent = acc.GE_LGT_EM_SAP_Customer_Number__c;
} else {
req.agent = '';
}*/        
        
        /*if(String.isNotBlank(acc.Delivering_Plant__c)){
req.defaultWarehouseCode = acc.Delivering_Plant__c;
} else {
req.defaultWarehouseCode = '';
}*/        
        
        List<Inventory> inventoryList = new List<Inventory>();
        integer lineNumebr = 0;
        //for(String sku: skuList){
        Inventory inv = new Inventory();
        System.debug('sku=' + sku);           
        lineNumebr += 10;
        inv.material = sku;                
        inv.quantity = 1;
        inv.lineItem = lineNumebr;
        inv.UOM = UOM_PC;            
        inventoryList.add(inv);
        //}      
        req.inventoryList = inventoryList;
        
       /*
        // This block is for handling CC Product and Non-CC Product seniario for setting 'defaultWarehouseCode' flag
        ccrz__E_Product__c quickship = new  ccrz__E_Product__c();
        Integer ccprodcount= [select count() from ccrz__E_Product__c where ccrz__SKU__c=:effProd and ccrz__ProductStatus__c='Released' ];
        system.debug('ccprodcount'+ccprodcount);
        if(ccprodcount == 1){
            system.debug('checkpoint');
            quickship = [SELECT Quickship__c FROM ccrz__E_Product__c WHERE ccrz__SKU__c=:inventoryList[0].material LIMIT 1];
            if(quickship!=null && quickship.Quickship__c ==false){
                req.defaultWarehouseCode ='';
                
            }
        }
        else{
            req.defaultWarehouseCode ='';  
        }*/
        
        //req.defaultWarehouseCode ='';  
        System.debug('request=' +  req);
        //SAPGateway sg = new SAPGateway();    
        //InventoryResponse  resp = sg.getInventoryAvailability(req);
        
        InventoryResponse  resp = service.getInventoryAvailability(req);
        System.debug('response=' +  resp);
        
        
        Map<String,List<Inventory>> inventoryIntMap=resp.inventoryMap;
        Map<String,List<Inventory>> inventoryResMap=new Map<String,List<Inventory>>();
        
        For(String a: inventoryIntMap.keyset()){
            
            inventoryResMap.put('0',inventoryIntMap.get(a));
        }
        
        resp.inventoryMap=inventoryResMap;
        
        //res.data = resp;
        //res.success = true;
        return resp;
    }
    
    public static List<Inventory> getWarehouseNames(List<Inventory> invList){      
        Warehouse__mdt[] warehouseRecords = [Select Code__c, Order_Cutoff__c, Location__c from Warehouse__mdt];
        
        System.debug('invList***' + invList.size());
        integer totalQuantity = 0;
        for(Inventory inv: invList){
            inv.isDisplay = false;            
            for(Warehouse__mdt record:warehouseRecords) {                
                if(inv.warehouseCode == record.Code__c){
                    inv.warehouseName = record.Location__c;
                    inv.orderCutoff = record.Order_Cutoff__c;
                    totalQuantity += inv.quantity;
                    inv.isDisplay = true;
                    break;
                }                       
            }
            inv.totalQuantity = totalQuantity;     
        }
        System.debug('invList****' + invList.size());
        return invList;
    }
    
    public class DefaultWarehouseInventory{
        public Id productId {get; set;}
        public String SKU {get; set;}
        public String defaultWarehouseQuantity{get; set;}
        public Integer totalQuantity{get; set;}
    }
    
    public class Inventory{
        @AuraEnabled
        public String SKU {get; set;}
        @AuraEnabled
        public String material {get; set;}
        @AuraEnabled
        public String warehouseCode {get; set;}
        @AuraEnabled
        public String warehouseName {get; set;}
        @AuraEnabled
        public Decimal quantityOnHand{get; set;}
        @AuraEnabled
        public Integer standardPackQty{get; set;}
        @AuraEnabled
        public Decimal totalQuantity{get; set;}
        @AuraEnabled
        public Integer quantity{get; set;}
        @AuraEnabled
        public Integer lineItem {get; set;}
        @AuraEnabled
        public String UOM {get; set;}
        @AuraEnabled
        public String description {get; set;}
        @AuraEnabled
        public String leadTime {get; set;}
        @AuraEnabled
        public Integer reqQty{get; set;}
        @AuraEnabled
        public Integer roundedQty{get; set;}
        @AuraEnabled
        public Decimal unitPrice{get; set;}
        @AuraEnabled
        public Decimal maxPrice{get; set;}
        @AuraEnabled
        public Decimal adpPrice{get; set;}
        @AuraEnabled
        public Decimal priceAgreementValue{get; set;}
        @AuraEnabled
        public String priceAgreement {get; set;}
        @AuraEnabled
        public String currencyISOCode {get; set;}
        @AuraEnabled
        public String orderCutoff {get; set;}
        @AuraEnabled
        public Boolean isDisplay {get; set;}
        @AuraEnabled
        public Boolean isDefaultWarehouse {get; set;}
          @AuraEnabled
        public Boolean IsQuickstock {get; set;}
    }
    
    public class InventoryRequest{
        public String SKU {get; set;}     
        public String agent {get; set;}
        public String agreement {get; set;}
        public String customer {get; set;}
        public String agrDate {get; set;}
        public String distChannel {get; set;} 
        public String poleType {get; set;}
        public String reqDelDate {get; set;}
        public String spart {get; set;}
        public String userType {get; set;}
        public String orderType {get; set;}
        public String division {get; set;}
        public String poNumber {get; set;}
        public String poType {get; set;}
        public String salesOrg {get; set;}        
        public String defaultWarehouseCode {get; set;}
        @AuraEnabled
        public Boolean IsQuickstock {get; set;}
        public List<Inventory> inventoryList {get; set;}
    }
    
    public class InventoryResponse{
        @AuraEnabled
        public String SKU {get; set;}
        @AuraEnabled
        public String agent {get; set;}
        @AuraEnabled
        public String customer {get; set;}
        @AuraEnabled
        public String customerName {get; set;}
        @AuraEnabled
        public String message {get; set;}
        @AuraEnabled
        public String poleType {get; set;}
        @AuraEnabled
        public String description {get; set;}
        @AuraEnabled
        public String orderType {get; set;}
        @AuraEnabled
        public String poNumber {get; set;}
        @AuraEnabled
        public String poType {get; set;}
        @AuraEnabled
        public String reqDelDate {get; set;}
        @AuraEnabled
        public String spart {get; set;}
        @AuraEnabled
        public String userType {get; set;}
        @AuraEnabled
        public String division {get; set;}
        @AuraEnabled
        public String salesOrg {get; set;}
        @AuraEnabled
        public String UOM {get; set;}
        @AuraEnabled
        public Integer reqQty{get; set;}
        @AuraEnabled
        public Integer roundedQty{get; set;}
        @AuraEnabled
        public Decimal unitPrice{get; set;}
        @AuraEnabled
        public Decimal maxPrice{get; set;}
        @AuraEnabled
        public Decimal adpPrice{get; set;}
        @AuraEnabled        
        public List<Inventory> inventoryList {get; set;}
         @AuraEnabled    
         public Boolean IsQuickstock {get; set;}
        @AuraEnabled
        public Map<String,List<Inventory>> inventoryMap {get; set;}
    }
}
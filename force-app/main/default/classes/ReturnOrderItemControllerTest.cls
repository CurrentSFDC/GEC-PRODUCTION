/*
Name - ReturnOrderItemControllerTest
Methods- ReturnOrderItemControllerTest
         getPickListTest
         lookUpTest
         lookUpTest2
         lookUpTest3
		 fetchRecordsTest
		 fetchRecordsTest2
		 Records
		 updReturnOrderItemsTest
		 getMaterial
Purpose - Test Class for ReturnOrderItemController
*/ 


@isTest
public class ReturnOrderItemControllerTest {
    
    @isTest
    static void createReturnTest(){
        //List<Return_Order_Item__c> accounts = new List<Return_Order_Item__c>();
        Return_Order_Item__c accounts = new Return_Order_Item__c();
       // accounts.add(obj);
        if(accounts != null)
        {
           // insert accounts;
          
        }
        
        Test.startTest();
        ReturnOrderItemController.createReturnOrderItems(accounts);
        Test.stopTest();
    } 
    
     @isTest
    static void createReturnTest1(){
        //List<Return_Order_Item__c> accounts = new List<Return_Order_Item__c>();
        Return_Order_Item__c accounts = new Return_Order_Item__c();
       // accounts.add(obj);
        if(accounts != null)
        {
           // insert accounts;
          
        }
        
        Test.startTest();
        ReturnOrderItemController.updReturnOrderItems(accounts);
        Test.stopTest();
    } 
    
    
    
    
    @isTest
    static void getPickListTest() {
    String objectName = 'GE_LGT_EM_MaterialMaster__c';
    String fieldName = 'Product_Status__c';
    List<String> values = new List<String>();
        
    List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{objectName});
        for(Schema.DescribeSobjectResult res : results) {

            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    values.add(entry.getValue());
                }
            }           
        }      
       Test.startTest();
       ReturnOrderItemController.getPickList(objectName, fieldName);
       Test.stopTest();
    }
    
    @isTest
    static void lookUpTest() {
        String searchTerm = 'ma';
        String myObject = 'GE_LGT_EM_MaterialMaster__c'; 
        String filter;
        String myQuery = null;
         
        if(filter != null && filter != ''){
            myQuery = 'Select Id, GE_LGT_EM_SAP_MaterialNumber__c from '+myObject+' Where GE_LGT_EM_SAP_MaterialNumber__c Like  \'%' + searchTerm + '%\' AND '+filter+' LIMIT  5'; 
        }
        else {
            if(searchTerm == null || searchTerm == ''){
                myQuery = 'Select Id, GE_LGT_EM_SAP_MaterialNumber__c from '+myObject+' Where LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT  5'; 
            }
            else {
                myQuery = 'Select Id, GE_LGT_EM_SAP_MaterialNumber__c from '+myObject+' Where GE_LGT_EM_SAP_MaterialNumber__c Like  \'%' + searchTerm + '%\' LIMIT  5';
            }
        }
        List<sObject> lookUpList = database.query(myQuery);
        
       Test.startTest();
       ReturnOrderItemController.lookUp(searchTerm, myObject, filter);
       Test.stopTest();
       
    }
 
    @isTest
    static void lookUpTest2() {
        String searchTerm;
        String myObject = 'GE_LGT_EM_MaterialMaster__c'; 
        String filter;
        String myQuery = null;
        
        if(filter != null && filter != ''){
            myQuery = 'Select Id, GE_LGT_EM_SAP_MaterialNumber__c from '+myObject+' Where GE_LGT_EM_SAP_MaterialNumber__c Like  \'%' + searchTerm + '%\' AND '+filter+' LIMIT  5'; 
        }
        else {
            if(searchTerm == null || searchTerm == ''){
                myQuery = 'Select Id, GE_LGT_EM_SAP_MaterialNumber__c from '+myObject+' Where LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT  5'; 
            }
            else {
                myQuery = 'Select Id, GE_LGT_EM_SAP_MaterialNumber__c from '+myObject+' Where GE_LGT_EM_SAP_MaterialNumber__c Like  \'%' + searchTerm + '%\' LIMIT  5';
            }
        }
        List<sObject> lookUpList = database.query(myQuery);
        
       Test.startTest();
       ReturnOrderItemController.lookUp(searchTerm, myObject, filter);
       Test.stopTest();
       
    }
    
     @isTest
    static void lookUpTest3() {
        String searchTerm = '3';
        String myObject = 'GE_LGT_EM_MaterialMaster__c'; 
        String filter ;
        String myQuery = null;
         
        if(filter != null && filter != ''){
            myQuery = 'Select Id, GE_LGT_EM_SAP_MaterialNumber__c from '+myObject+' Where GE_LGT_EM_SAP_MaterialNumber__c Like  \'%' + searchTerm + '%\' AND '+filter+' LIMIT  5'; 
        }
        else {
            if(searchTerm == null || searchTerm == ''){
                myQuery = 'Select Id, GE_LGT_EM_SAP_MaterialNumber__c from '+myObject+' Where LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT  5'; 
            
            }
            else {
                myQuery = 'Select Id, GE_LGT_EM_SAP_MaterialNumber__c from '+myObject+' Where GE_LGT_EM_SAP_MaterialNumber__c Like  \'%' + searchTerm + '%\' LIMIT  5';
            
            }
        }
        List<sObject> lookUpList = database.query(myQuery);
        
       Test.startTest();
       ReturnOrderItemController.lookUp(searchTerm, myObject, filter);
       Test.stopTest();
       
    }
   
    @isTest
     static void fetchRecordsTest() {
         
        String objectName = 'GE_LGT_EM_MaterialMaster__c';
        String field='Name';
        String searchString = 'ma';
        Integer NumRecords = 5;
      sObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;
        ReturnOrderItemController.Records obj = new ReturnOrderItemController.Records();
         obj.Id = '';
         obj.val = '';
        
        List<Records> recordsList = new List<Records>();
         try {
	        String query = 'SELECT Id,GE_LGT_EM_MaterialDescription__c,' + field + ' FROM '+ objectName + ' WHERE '+ field +' LIKE ' +
             '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\'' + ' LIMIT ' + NumRecords;
             for(SObject s : Database.query(query)){
	            Records record = new Records();
	            record.Id = String.valueOf(s.get('id'));
	            record.val = String.valueOf(s.get(field));
	            recordsList.add(record);
	        }
             } 
         catch (Exception err) {	    	
           //   throw new AuraHandledException(err.getMessage());
       }
         
       Test.startTest();
       ReturnOrderItemController.fetchRecords(ObjectName, field, searchString, NumRecords);
       Test.stopTest();
    }
     
    @isTest
     static void fetchRecordsTest2() {
         
        String objectName;
        String field;
        String searchString;
        Integer NumRecords;
        List<Records> recordsList = new List<Records>();
         try {
	        String query = 'SELECT Id, ' + field + ' FROM '+ objectName + ' WHERE '+ field +' LIKE ' +
             '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\'' + ' LIMIT ' + NumRecords;
             for(SObject s : Database.query(query)){
	            Records record = new Records();
	            record.Id = String.valueOf(s.get('id'));
	            record.val = String.valueOf(s.get(field));
	            recordsList.add(record);
	        }
             } catch (Exception err) {	    	
            //  throw new AuraHandledException(err.getMessage());
        }
         
       Test.startTest();
      // ReturnOrderItemController.fetchRecords(ObjectName, field, searchString, NumRecords);
       Test.stopTest();
    }
    public class Records{
        public String Id {get;set;}
        public String val {get;set;}
		// String Id = '4585jhgbjk';
         //String val = 'OOP';
       // ReturnOrderItemController.Records obj = new ReturnOrderItemController.Records(Id,val);
        

    }
    @isTest
    static void updReturnOrderItemsTest() {
        
        String data = 'a3j3F00000098aIQAQ';
       // upsert data;
       
        Test.startTest();       
       // ReturnOrderItemController.updReturnOrderItems(data);
        Test.stopTest();
     
        
    }
    @isTest
    static void getMaterial(){
       // String matId = 'a2z3F000000d48jQAA';
        //GE_LGT_EM_MaterialMaster__c mat = [Select GE_LGT_EM_MaterialDescription__c from GE_LGT_EM_MaterialMaster__c where Id = :matId]; 
        
        GE_LGT_EM_MaterialMaster__c mat = new GE_LGT_EM_MaterialMaster__c();
        mat.GE_LGT_EM_MaterialDescription__c = 'Test Data';
        insert mat;
        
        
       // return mat.GE_LGT_EM_MaterialDescription__c;
        Test.startTest();       
        ReturnOrderItemController.getMaterial(mat.id);
        Test.stopTest();
    }
 
}
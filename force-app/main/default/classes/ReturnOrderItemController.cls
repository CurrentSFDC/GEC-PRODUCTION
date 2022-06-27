public without sharing class ReturnOrderItemController {
    @AuraEnabled
    public static String createReturnOrderItems(Return_Order_Item__c accounts) {
        
        
            Insert accounts ;
            return accounts.Id;
     
        
    }
    
     @AuraEnabled
    public static String updReturnOrderItems(Return_Order_Item__c data) {
        
        
            upsert data Id;
            return data.Id;
     
        
    }
    
    @AuraEnabled
    public static List<String> getPickList(String objectName, String fieldName) {
        List<String> values = new List<String>();
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{objectName});
        
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    values.add(entry.getValue());
                }
            }
        }
        return values;
    }

    @AuraEnabled(cacheable=true)
    public static List<sObject> lookUp(String searchTerm, string myObject, String filter) {
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

        return lookUpList;  
    }

    @AuraEnabled(cacheable=true)
    public static List<Records> fetchRecords( String ObjectName, String field, String searchString, Integer NumRecords ) {
        List<Records> recordsList = new List<Records>();

        try {
	        String query = 'SELECT Id, GE_LGT_EM_MaterialDescription__c, ' + field + ' FROM '+ objectName + ' WHERE '+ field +' LIKE ' +
             '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\'' + ' LIMIT ' + NumRecords;
			System.debug(query);
	        for(SObject s : Database.query(query)){
	            Records record = new Records();
	            record.Id = String.valueOf(s.get('id'));
                record.val = String.valueOf(s.get(field));
                //record.description = String.valueOf(s.get('GE_LGT_EM_MaterialDescription__c'));
	            recordsList.add(record);
	        } 
	    } catch (Exception err) {	    	
                throw new AuraHandledException(err.getMessage());
        }
        
        return recordsList;
    }  
    
    public class Records{
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String val {get;set;}
       // @AuraEnabled public String description {get;set;}
    }

    @AuraEnabled
    
    public static List<GE_LGT_EM_MaterialMaster__c> getMaterial(String matId){
        List<GE_LGT_EM_MaterialMaster__c> mat = [Select GE_LGT_EM_MaterialDescription__c, GE_LGT_EM_SAP_MaterialNumber__c
        from GE_LGT_EM_MaterialMaster__c where Id = :matId LIMIT 1]; 
        
        return mat;
    }
}
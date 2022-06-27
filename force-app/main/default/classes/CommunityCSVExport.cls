public without sharing class CommunityCSVExport {
    @AuraEnabled
    public static String checkPAHeader(String priceId){
        String checkflag;
        Date todaysDate = System.today();
        system.debug('todaysDate' + todaysDate);
      	//String todaysDateStr = todaysDate.format('yyyy-MM-dd');
        //system.debug('todaysDateStr' + todaysDateStr);
        SAP_Price_Agreement__c head =[Select Id, Expiration_Date__c from SAP_Price_Agreement__c where name = :priceId ];
        system.debug('Expiration_Date__c' + head.Expiration_Date__c);
        if(head.Expiration_Date__c > todaysDate){
          checkflag='N';  
        }
        else{
         checkflag='Y';   
        }
        system.debug(checkflag);
        return checkflag;
    }
    
    @AuraEnabled
    public static List<SAP_Price_Agreement__c> checkPAItem(String priceId){
        
        List <SAP_Price_Agreement__c> sap =  [Select Name, Agent_Name__c, Opportunity_Name__c, Agreement_Type__c, Agreement_Subtotal__c, Extended_Description__c, Strategic_Partner_Name__c, Valid_From__c, Expiration_Date__c,  Agent_Number__c,  (select Material_No__c, Item_Description__c, Quantity__c, UnitOfMeasure__c, ValidFrom__c, ValidTo__c from SAP_Price_Agreement_Items__r where ValidTo__c > Today ) from SAP_Price_Agreement__c where name = :priceId];

        system.debug('PA Item List Check' + sap);
        return [Select Name, Agent_Name__c, Opportunity_Name__c, Agreement_Type__c, Agreement_Subtotal__c, Extended_Description__c, Strategic_Partner_Name__c, Valid_From__c, Expiration_Date__c,  Agent_Number__c,  (select Material_No__c, Item_Description__c, Quantity__c, UnitOfMeasure__c, ValidFrom__c, ValidTo__c from SAP_Price_Agreement_Items__r where ValidTo__c > Today ) from SAP_Price_Agreement__c where name = :priceId];

    }

}
public class GE_LGT_FormulaFields {
    //Rashmitha Changed the API vesion from 37 to 45 on 6-Mar-2019 as per 1447 request
    Public List<Opportunity> opptylist{get;set;}
    Public boolean hasNA{get;set;}
    public GE_LGT_FormulaFields(ApexPages.StandardController controller) {
        opptylist =new list<Opportunity>();
        Map<String,NA_Profiles__c> NAprofiles = NA_Profiles__c.getAll();
        if(ApexPages.currentPage().getParameters().get('id') != null) {  
            opptylist = [select id,StageName,Next_Steps__c,Info__c,hasOrders__c,Owner_Pole_Opp__c,RecordType.Name, (Select id from OpportunityContactRoles where Role!=NULL) childContacts from Opportunity where id = :ApexPages.currentPage().getParameters().get('id') LIMIT 1];
            
            
        }
    }
}
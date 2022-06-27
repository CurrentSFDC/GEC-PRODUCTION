/*
Purpose - This controller for(GE_LGT_NewEMEAcreation) page will open if  new OSR Record recordtype select 'EMEA New Sample Product Req'
Author - Sivateja (TechMahindra)
Creation - 7/19/2016
Test ClassName - GE_LGT_NewEMEAcreation_Test1(created)  
Modification History:
*/
public class GE_LGT_NewEMEAcreation {
    public Opportunity_Support_Request__c OSR{set;get;}
    public  static Opportunity_Support_Request__c cloneOSR;
    
    public GE_LGT_NewEMEAcreation (ApexPages.StandardController controller)
    { 
        
        if(cloneOSR == null){
            id recordtypeid=ApexPages.currentPage().getParameters().get('RecordType');
            OSR=new Opportunity_Support_Request__c();
            OSR.recordtypeid=recordtypeid;
            string param1= '';
            Map<String, String> strMap = ApexPages.currentPage().getParameters();
            string prefixOpty = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getKeyPrefix();
            string fieldid='';
            string fieldidVal='';
            for (String key : strMap.keySet()) {
                if (key.startsWith('CF') && key.endsWith('lkid')) {
                    String val = strMap.get(key);
                    if (val.startsWith(prefixOpty)) {
                        fieldid=key;
                        fieldidVal=key.substringBefore('_');
                    }
                    
                }
            }
            
            if(fieldid != ''){
                OSR.Opportunity_Name__c=ApexPages.currentPage().getParameters().get(fieldid);
            }
            
        }
        else{
            OSR=cloneOSR.clone(true,false,false,false);
            
            
        }
    }
    public pagereference saveAndClone(){
        Savepoint sp = Database.setSavepoint();
        
        try {
            Opportunity_Support_Request__c OSR1 =OSR.clone(true,false,false,false);
            
            
            insert OSR1;
            
            
            
            cloneOSR=OSR.clone(true,false,false,false);
            
        }
        catch(Exception e){
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
        }
        return ApexPages.currentpage();
    }
    public pagereference saveOSR(){
        Opportunity_Support_Request__c OSR1 =OSR.clone(true,false,false,false);
        Savepoint sp = Database.setSavepoint();
        try {
            insert OSR1;
        }
        catch(Exception e){
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
        }           
        return new PageReference('/'+OSR1.id);
    }
    
}
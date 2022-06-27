/*
Purpose - This controller for(GE_LGT_OSRNewPage)  will override the OSR standard New Button, 
Author - Sivateja (TechMahindra)
Creation - 7/19/2016
Test ClassName - GE_LGT_OSRNewPage_Test(created)  
Modification History:
*/
public class GE_LGT_OSRNewPage
{
    Public string strRecTypeName {get; set; }
    Public String prefixOpty ;
    Public id recordtypeid;
    Public id pagerecordtype;
    private ApexPages.StandardController controller = null;
    public GE_LGT_OSRNewPage (ApexPages.StandardController controller)
    {
        this.controller = controller;
        recordtypeid=Schema.SObjectType.Opportunity_Support_Request__c.getRecordTypeInfosByName().get('EMEA New Sample Product Req').getRecordTypeId();
        pagerecordtype=ApexPages.currentPage().getParameters().get('RecordType');
    }
    public pagereference GE_LGT_Redirect()
    {
        
        if(recordtypeid !=pagerecordtype){
            String prefix = Opportunity_Support_Request__c.SObjectType.getDescribe().getKeyPrefix();
            String param = getParameters();
            String param1=getparent();
            pagereference pageref1 = new PageReference('/'+prefix+'/e?nooverride=1&'+param1+param); 
            pageref1.setredirect(true);
            return pageref1;
        }
        else{
            String param = getParameters();
            String param1=getparent();
            string url='apex/GE_LGT_NewEMEAcreation?'+param1+param;
            pagereference pageref = new pagereference('/'+url);
            pageref.setredirect(true);
            return pageref;
        }
    }
    private String getParameters(){
        string param = '';
        
        Map<String, String> strMap = ApexPages.currentPage().getParameters();
        String[] keys = new String[]{'RecordType', 'retURL', 'cancelURL'};
            for(String s : keys){
                if(strMap.containsKey(S)) 
                    param += s + '=' + EncodingUtil.urlEncode(strMap.get(s),'UTF-8') + '&';
                
            }
        
        if(param.length() > 0) param = param.substring(0, param.length()-1);
        return param;
    }
    private String getparent(){
        string param1= '';
        Map<String, String> strMap = ApexPages.currentPage().getParameters();
        prefixOpty = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getKeyPrefix();
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
        if(fieldid !='' && fieldidVal !=''){
            if(recordtypeid !=pagerecordtype){
                param1= fieldid + '=' + EncodingUtil.urlEncode(strMap.get(fieldid),'UTF-8') + '&';
                param1= param1+fieldidVal + '=' + EncodingUtil.urlEncode(strMap.get(fieldidVal),'UTF-8') + '&';
            }
            else{
                param1=fieldid + '=' + EncodingUtil.urlEncode(strMap.get(fieldid),'UTF-8') + '&';
                param1=param1 + fieldidVal + '=' + EncodingUtil.urlEncode(strMap.get(fieldidVal),'UTF-8') + '&';
            }
        }
        
        return param1;
    }
}
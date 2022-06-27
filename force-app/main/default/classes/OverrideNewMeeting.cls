/*
Name - OverrideNewMeeting
Test Class - OverrideNewMeeting_Test
Author - Shyam Prasad Nayakula
Purpose - To override the new button of Meeting Object- RQT-0000064
Date - May-2017
*/
public class OverrideNewMeeting 
{
    public String URL{get;set;}
    public pageReference cView{get;set;}
    public String retURL{get;set;}
    public Account acc{get;set;}
    public string BaseURL{get;set;}
  
    String lookupName;
    String lookupValue;
    public OverrideNewMeeting(ApexPages.StandardController controller) 
    {
        URL = ApexPages.currentPage().getUrl();
        BaseURL = ApexPages.currentPage().getHeaders().get('Host');
        retURL  = ApexPages.currentPage().getParameters().get('retURL');
        
        
    }
    public Pagereference overridePage()
    {
        ID stdRecordTypeID = Schema.SObjectType.Meeting__c.getRecordTypeInfosByName().get('StandardRecordType').getRecordTypeId();
        ID withMettingObjRecordTypeID = Schema.SObjectType.Meeting__c.getRecordTypeInfosByName().get('WithMeetingObjective').getRecordTypeId();
        ID withoutMettingObjRecordTypeID = Schema.SObjectType.Meeting__c.getRecordTypeInfosByName().get('WithoutMeetingObjective').getRecordTypeId();   
        Schema.DescribeSObjectResult describeTask = Meeting__c.sObjectType.getDescribe();
        String keyPrefix = describeTask.getKeyPrefix();
        if(retURL!=NULL && retURL.contains('/001'))
        {
          
            Pagereference retPR = new Pagereference('https://'+BaseURL+'/'+keyPrefix+'/e'+URL.subStringAfter('/apex/OverrideNewMeeting')+'&nooverride=1');
            String accIDHelper = retURL.subStringAfter('/');
            String accID = accIDHelper.substring(0,15);
            acc = [SELECT ID,RecordType.Name FROM Account WHERE ID=:accID];
            List<Account> accList = [SELECT ID,RecordType.Name FROM Account WHERE ID=:accID];
            if(!accList.isEmpty())
            {
                acc = accList[0];
                if(acc!=NULL && (acc.RecordType.Name=='Agent - Lamp & Ballast' || acc.RecordType.Name=='Distributor' || acc.RecordType.Name=='NA Service Bill To Account' 
                                || acc.RecordType.Name=='NA Service Ship To Account' || acc.RecordType.Name=='SAP Account' || acc.RecordType.Name=='SAP Account - Fixture Agent'))
                                
                {
                    retPR.getParameters().put('RecordType',withMettingObjRecordTypeID);
                }
                else
                {
                    retPR.getParameters().put('RecordType',withoutMettingObjRecordTypeID);
                }
            }
            return retPR;
        }
        else
        {
            Pagereference retPR1 = new Pagereference('https://'+BaseURL+'/'+keyPrefix+'/e'+URL.subStringAfter('/apex/OverrideNewMeeting')+'&nooverride=1');
            retPR1.getParameters().put('RecordType',stdRecordTypeID);
            retPR1.getParameters().remove('save_new');
            System.debug('RetPR1:'+retPR1);
            return retPR1;
        }
        return NULL;
    }

}
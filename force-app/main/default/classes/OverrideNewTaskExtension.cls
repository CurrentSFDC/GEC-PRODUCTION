/*
Name - OverrideNewTaskExtension
Test Class - OverrideNewTaskExtension_Test
Author - Shyam Prasad Nayakula
Purpose - Controller of OverrideNewTaskExtension
Date - Sept-2016
*/
public class OverrideNewTaskExtension 
{
    public String recordTypeId{get;set;}
    public String retURL;
    
    public OverrideNewTaskExtension(ApexPages.StandardController controller) 
    {
        
    }
    public Pagereference prepopulateValues()
    {
        Schema.DescribeSObjectResult describeTask = Task.sObjectType.getDescribe();
        String keyPrefix = describeTask.getKeyPrefix();
        Id sERequestTaskId =Schema.SObjectType.Task.getRecordTypeInfosByName().get('SE Request Task').getRecordTypeId();
        recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
        retURL  = ApexPages.currentPage().getParameters().get('retURL');
        String whoID = ApexPages.currentPage().getParameters().get('who_id');
        String whatID = ApexPages.currentPage().getParameters().get('what_id');
        String tsk1 = ApexPages.currentPage().getParameters().get('tsk1');
        String tsk12 = ApexPages.currentPage().getParameters().get('tsk12');
        String tsk5 = ApexPages.currentPage().getParameters().get('tsk5');
        String email = ApexPages.currentPage().getParameters().get('email');
        Pagereference pf;
        System.debug('Record Type ID:'+recordTypeId);
        pf = new Pagereference('/'+keyPrefix+'/e?retURL='+retURL+'&nooverride=1');
        pf.getParameters().put('RecordType',recordTypeId); 
        
        if(sERequestTaskId==recordTypeId){
            system.debug('retURL'+retURL);
            system.debug('retURL.left(4)'+retURL.left(4));
            if(retURL.left(4)=='/006'){
                String oppid=retURL.right(15);
                system.debug('oppid'+oppid);
                Opportunity opp=[select id,name,RecordType.Name,RecordType.DeveloperName from Opportunity where id=:oppid limit 1]; 
                system.debug('opp'+opp);
                system.debug('opp'+opp.RecordType.DeveloperName);
                /*if(opp.RecordType.DeveloperName == 'Standard' || opp.RecordType.DeveloperName == 'StandardAdvance' )
                {
                    tsk1='Walter Pidgeon';
                    tsk12='Open';   
                }
                else */
                if(opp.RecordType.DeveloperName == 'Daintree' || opp.RecordType.DeveloperName == 'DaintreeAdvance' 
                        || opp.RecordType.DeveloperName == 'Intelligent_City' || opp.RecordType.DeveloperName == 'IntelligentCityAdvance')
                {
                    tsk1='Omar Tabba';
                    tsk12='Open';
                }
                else{
                    tsk1='Walter Pidgeon';
                    tsk12='Open';
                }
            }  
            else{
                tsk1='Walter Pidgeon';
                tsk12='Open'; 
            }
                            }
        if(whoID!=NULL)
        {
            pf.getParameters().put('who_id',whoID); 
        }
        if(whatID!=NULL)
        {
            pf.getParameters().put('what_id',whatID); 
        }
        if(tsk1!=NULL)
        {
            pf.getParameters().put('tsk1',tsk1); 
        }
        if(tsk12!=NULL)
        {
            pf.getParameters().put('tsk12',tsk12); 
        }
        if(tsk5!=NULL)
        {
            pf.getParameters().put('tsk5',tsk5); 
        }
        if(email!=NULL)
        {
            pf.getParameters().put('email',email); 
        }
        List<Configurable_Constants__mdt> userDetailList = [Select DeveloperName,MasterLabel,ID,User_Name__c from Configurable_Constants__mdt 
                                                            WHERE DeveloperName='Contract_Task_Owner'];
        
        Map<Id,Schema.RecordTypeInfo> recTypemap = Task.sObjectType.getDescribe().getRecordTypeInfosById();
        if(recordTypeId!=NULL && (recTypemap.get(recordTypeId).getName()=='Account Contract Task'
                                  || recTypemap.get(recordTypeId).getName()=='Contract Task' 
                                  || recTypemap.get(recordTypeId).getName()=='Opportunity Contract Task'))
        {  
            List<User> userList = new List<User>();
            if(!userDetailList.isEmpty())
                userList=[SELECT ID,Name FROM User WHERE userName=:UserDetailList[0].User_Name__c];
            if(userList!=NULL && !userList.isEmpty())
            {
                pf.getParameters().put('tsk1',userList[0].Name);
                pf.getParameters().put('tsk1_lkid',userList[0].ID);
            }
            String contractMainTaskFieldID = Label.contractMainTaskFieldID;
            if(retURL!=NULL && retURL.contains('home'))
            {
                pf.getParameters().put(contractMainTaskFieldID,'Home');
            }
            else if(retURL!=NULL && retURL.contains('/006'))
            {
                pf.getParameters().put(contractMainTaskFieldID,'Opportunity');
            }
            else if(retURL!=NULL && retURL.contains('/001'))
            {
                pf.getParameters().put(contractMainTaskFieldID,'Account');
            }
        }
        return pf;
    }
}
public with sharing class GE_LGT_EM_CEMSurvey_Extension 
{
    private ApexPages.StandardController sController;
    public String subtitle{get;set;}
    public String getSubtitle()
    {
        return subtitle;
    }
    ID var=null;
    public Boolean flag1{get;set;}
    public Boolean flag2{get;set;}
    public GE_LGT_EM_CEMSurvey_Extension(ApexPages.StandardController controller) 
    {
        sController=controller;
        NPS_Survey__c nps=Null;
        var= ApexPages.currentPage().getParameters().get('Id');
        String clone= ApexPages.currentPage().getParameters().get('Clone');
        System.debug('Clone Value:'+clone);
        if(var==null || clone=='1')
        {
           subtitle='New CEM Survey';
           if(var!=null)
           {
               nps=[SELECT Name,Survey_status__c FROM NPS_Survey__c WHERE ID=:var];
           }
        }
        else
        {
            nps=[SELECT Name,Survey_status__c FROM NPS_Survey__c WHERE ID=:var];
            subtitle=nps.name;
        }
        if(var!=NULL && nps.Survey_status__c != NULL && nps.Survey_status__c=='Completed')
        {
            flag1=true;
            flag2=false;
        }
        else
        {
            flag1=false;
            flag2=true;
         } 

    }
    public PageReference saveAndNew()
    {
        try
        {
            sController.save();
            Schema.DescribeSObjectResult describeResult = sController.getRecord().getSObjectType().getDescribe();  
            PageReference pr=new PageReference('/' + describeResult.getKeyPrefix() +'/e');
            pr.setRedirect(true);
            return pr;
        }
        catch(Exception e) 
        {   
            ApexPages.addMessages(e);  
            return null;  
        }  
    }
    public PageReference cloneFun()
    {
         PageReference pr=new PageReference('/' + var +'/e?clone=1');
         pr.setRedirect(true);
         return pr;
    }

}
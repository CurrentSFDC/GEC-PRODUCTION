public with sharing class OSRcontactExtension
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
    public OSRcontactExtension (ApexPages.StandardController controller) 
    {
        sController=controller;
        Opportunity_Support_Request__c nps=Null;
        var= ApexPages.currentPage().getParameters().get('Id');
        String clone= ApexPages.currentPage().getParameters().get('Clone');
        System.debug('Clone Value:'+clone);
        if(var==null || clone=='1')
        {
            subtitle='New OSR Contact';
            if(var!=null)
            {
                nps=[SELECT Name FROM Opportunity_Support_Request__c WHERE ID=:var];
            }
        }
        else
        {
            nps=[SELECT Name FROM Opportunity_Support_Request__c WHERE ID=:var];
            subtitle=nps.name;
        }
        
    }
    public PageReference saveAll()
    {
        try
        {
            sController.save();
            return null;  
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
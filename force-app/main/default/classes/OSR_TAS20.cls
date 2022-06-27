public with sharing class OSR_TAS20
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
    public OSR_TAS20(ApexPages.StandardController controller) 
    {
        sController=controller;
        var= ApexPages.currentPage().getParameters().get('Id');
        String clone= ApexPages.currentPage().getParameters().get('Clone');
        System.debug('Clone Value:'+clone);
        
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

    
}
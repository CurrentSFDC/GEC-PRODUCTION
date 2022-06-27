public with sharing class EMEA_PSO_Claim
{
   
    @TestVisible private ApexPages.StandardController sController;
    ID var=null;
    public EMEA_PSO_Claim(ApexPages.StandardController controller) 
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
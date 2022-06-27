/*
###########################################################################
# File..................:GE_LGT_EM_CategoryInner
# Version...............: 1.0
# Created by............:Jojan,Murugan,Snehil
# Created Date..........: 
# Description...........:This is our wrapper/container class. A container class is a class  
#               
*/
global Class GE_LGT_EM_CategoryInner
{
    //**** This is our wrapper/container class. A container class is a class**** 
    
    public boolean isSelected {get;set;}
    public GE_LGT_EM_InvoiceLineItem__c cat{get;set;}
    
     //****This is the contructor method**** 
     //****When we create a new GE_LGT_EM_CategoryInner_Cls object we pass a InvoiceLineItem that is set to the Cat property**** 
  
    public GE_LGT_EM_CategoryInner(boolean isSelected, GE_LGT_EM_InvoiceLineItem__c cat)
    {
        this.isSelected = isSelected;
        this.cat= cat;
    }
}
public  class GE_LGT_inlinecontrol_childacc {
Public list<Account> acclist {get;set;}
   public GE_LGT_inlinecontrol_childacc(ApexPages.StandardController controller) {
       acclist = new List<Account>();
       acclist = [SELECT ID,ParentId,Recordtype.Name,Name,GE_LGT_EM_CustomerActiveFlag__c FROM Account where ParentId=:ApexPages.currentPage().getParameters().get('id')];
   }
}
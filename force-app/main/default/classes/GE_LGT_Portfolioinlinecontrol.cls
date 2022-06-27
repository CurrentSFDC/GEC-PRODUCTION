/* Class Name : GE_LGT_Portfolioinlinecontrol
 * Test class Name :GE_LGT_Portfolioinlinecontrol_Test
 */
public  class GE_LGT_Portfolioinlinecontrol {

Public list<Opportunity> opptylist{get;set;}

Public list<OpportunityTeamMember> opptteamlist {get;set;}

   public GE_LGT_Portfolioinlinecontrol(ApexPages.StandardController controller) {
   opptteamlist = new List<OpportunityTeamMember>();
  if(ApexPages.currentPage().getParameters().get('id') != null) {  
  opptylist = [select id,Name,Portfolio__r.id,(SELECT CreatedById,CreatedDate,CurrencyIsoCode,Id,IsDeleted,LastModifiedById,LastModifiedDate,Name,OpportunityAccessLevel,OpportunityId,PhotoUrl,SystemModstamp,TeamMemberRole,UserId FROM OpportunityTeamMembers) from Opportunity where Portfolio__r.id = :ApexPages.currentPage().getParameters().get('id') ];
  
  if(opptylist.size()>0)
  
  opptteamlist = [SELECT Opportunity.NAME,CreatedById,User.NAME,CreatedDate,CurrencyIsoCode,Id,IsDeleted,LastModifiedById,LastModifiedDate,Name,OpportunityAccessLevel,OpportunityId,PhotoUrl,SystemModstamp,TeamMemberRole,UserId FROM OpportunityTeamMember where OPPORTUNITYID in:opptylist];
       }
}
}
trigger GE_LGT_setTeamMemberInOppty on OpportunityTeamMember (after insert,after update, after delete) {
  AdminOverride__c AdminOverrideUser = AdminOverride__c.getInstance(UserInfo.getUserId());
   
   if(!AdminOverrideUser.Switch_Off_Trigger__c)
   {
    String OpptyID;
    String TeamMemberNames='';
    Set<ID> setOppty = new Set<ID>();
    if(trigger.IsInsert || trigger.IsUpdate)
    {
    for(OpportunityTeamMember tm :trigger.new)
    {
        setOppty.add(tm.OpportunityID);
    }
    }
    if(trigger.IsDelete)
    {
    for(OpportunityTeamMember tm :trigger.old)
    {
        setOppty.add(tm.OpportunityID);
    }    
    }
    List<Opportunity> lstOppty = [SELECT ID,GE_LGT_TeamMember__c FROM OPPORTUNITY WHERE ID IN:setOppty];
    list<OpportunityTeamMember> teammebers=[select OpportunityID,User.Name from OpportunityTeamMember where OpportunityID in:setOppty];
    map<id,list<OpportunityTeamMember>> optywithteam=new map<id,list<OpportunityTeamMember>>();
     for(OpportunityTeamMember oppteam :teammebers){
        if(optywithteam.containskey(oppteam.OpportunityID)){
            optywithteam.get(oppteam.OpportunityID).add(oppteam);
        } 
        else{
            optywithteam.put(oppteam.OpportunityID,new list<OpportunityTeamMember>());
            optywithteam.get(oppteam.OpportunityID).add(oppteam);
        }
     }
    
    for(Opportunity oppt :lstOppty)
    {
        TeamMemberNames=' ';
        if(optywithteam.containsKey(oppt.ID)){
        for(OpportunityTeamMember tm :optywithteam.get(oppt.ID))
        {
            TeamMemberNames = TeamMemberNames + tm.User.Name + ', ';
        } 
        }
        oppt.GE_LGT_TeamMember__c = TeamMemberNames ;
    }
    
    database.update(lstOppty,false);
    }
    
}
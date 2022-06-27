/****************************************************************************************************************************************************************************************************
*   Class Name      : OpportunityKeyPlayerTriggerhelper
*   Date            : 
*   Author          : 
*   Object          : Opportunity Key Player
*   Purpose         : This method is to Update Opportunity record once Opportunity Key Player is created/Update/delete 
*   Test Class      : OpportunityKeyPlayerTriggerhelper_Test
*********************************************************************************************************/
public class OpportunityKeyPlayerTriggerhelper {
public static void opportunityfieldUpdate(list <CDT_Opportunity_Key_Player__c> newOkpList){
    Map<ID, Opportunity> parentOpps = new Map<ID, Opportunity>();
    Map<ID, Account> parentAccs = new Map<ID, Account>();
    set<Id> oppSetId = new set<Id>();
    set<Id> accSetId = new set<Id>();
    for(CDT_Opportunity_Key_Player__c childObj : newOkplist) {
        oppSetId.add(childObj.CDT_Opportunity_Name__c);
        accSetId.add(childObj.Account__c);
    }
    ID recOPPTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IntelligentEnvironmentAdvance').getRecordTypeId();
    parentOpps = new Map<Id,Opportunity>([SELECT id, Name,Alliance_ISV_Partner_Account_Name__c,Intelligent_Environments_Segment__c, recordtypeId, (SELECT ID,Account__r.Name,Account__r.Alliance_Partner_Type_Primary__c FROM Opportunity_Key_Players__r) FROM Opportunity WHERE ID IN :oppSetId AND Recordtypeid=:recOPPTypeID]);
    parentAccs = new Map<id, Account>([SELECT id, Name, Alliance_Partner_Type_Primary__c from Account Where Id in :accSetId]);
    for (CDT_Opportunity_Key_Player__c okpVar : newOkpList){
        Opportunity myParentOpp = parentOpps.get(okpVar.CDT_Opportunity_Name__c);
        Account parentAcc = parentAccs.get(okpVar.Account__c);
        If(parentAcc.Alliance_Partner_Type_Primary__c =='Independent Software Vendor' && myParentOpp.Intelligent_Environments_Segment__c=='ISV Productivity Segment'&& myParentOpp.RecordTypeId == recOppTypeId) {
            myParentOpp.Alliance_ISV_Partner_Account_Name__c = okpVar.Account__r.Name;
        }  
    }
    if (!parentOpps.isEmpty())
    update parentOpps.values();
 }
 public static void opportunityfieldupdatewithNull(list <CDT_Opportunity_Key_Player__c> OldOkpList){
    Map<ID, Opportunity> MappdeleteOpps = new Map<ID, Opportunity>();  
    set<Id> oppSetId = new set<Id>();
    for(CDT_Opportunity_Key_Player__c childObj : OldOkpList) {
        oppSetId.add(childObj.CDT_Opportunity_Name__c);
    }
    list<opportunity> updatelist = new list<opportunity>();
    ID recOPPTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IntelligentEnvironmentAdvance').getRecordTypeId();
    MappdeleteOpps = new Map<Id,Opportunity>([SELECT id,RecordTypeId, Name,Intelligent_Environments_Segment__c,(SELECT ID,Account__r.Name,Account__r.Alliance_Partner_Type_Primary__c FROM Opportunity_Key_Players__r where Account__r.Alliance_Partner_Type_Primary__c ='Independent Software Vendor') FROM Opportunity WHERE ID IN :oppSetId AND Recordtypeid=:recOPPTypeID]);
    system.debug('TestMapp'+ MappdeleteOpps);
    for(CDT_Opportunity_Key_Player__c okpVar : OldOkpList){
        Opportunity myParentOpp = MappdeleteOpps.get(okpVar.CDT_Opportunity_Name__c);
        If(myParentOpp.Intelligent_Environments_Segment__c=='ISV Productivity Segment'&& myParentOpp.RecordTypeId == recOppTypeId) {
            myParentOpp.Alliance_ISV_Partner_Account_Name__c = null;
            updatelist.add(myParentOpp);
            system.debug('TestUpdate'+ updatelist[0].Alliance_ISV_Partner_Account_Name__c);
        } 
    }
    update updatelist;
 }
}
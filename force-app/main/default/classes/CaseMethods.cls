/***********************************************************************************************
*   Class Name      : CaseMethods 
*   Date            : 5/5/2017
*   Author          : Pavan Kumar
*   Object          : Case
*   Purpose         : These methods fire on Case.
*   Test Class      : CaseTrigger_Test
**************************************************************************************************/

public class CaseMethods {

    //Contain methods to invoke "before insert" Event On Case
    public static void methodsToInvokeOnBeforeInsert(List<Case> newCaseList){
        CaseTriggerHelper.beforeInsert(newCaseList);
        CaseTriggerDispatcher.beforeInsert(newCaseList);
        CaseTriggerDispatcher.parseEmailtoCase(newCaseList);
       
    }
    //Contain methods to invoke "Before delete" Event On Case
    public  static void methodsToInvokeOnBeforeDelete(List<case> oldCaseList){
    system.debug('***Before delete event in Method*****');
        CaseTriggerHelper CaseHelper = new CaseTriggerHelper();
       CaseHelper.CaseBeforeDeleteValidation(oldCaseList);
        //caseTriggerDispatcher.CaseBeforeDeleteValidation(oldCaseList);
        
        
    }
    //Contain methods to invoke "before update" Event On Case
    public static void methodsToInvokeOnBeforeUpdate(List<Case> newCaseList,Map<Id,Case> newCaseMap,List<Case> oldCaseList,Map<Id,Case> oldCaseMap ){
        CaseTriggerHelper.beforeUpdate(newCaseList, newCaseMap, oldCaseList, oldCaseMap);
        CaseTriggerDispatcher.beforeUpdate(newCaseList, newCaseMap, oldCaseList, oldCaseMap);
        caseTriggerDispatcher.updateGEOppValue(newCaseList, oldCaseMap); 
             
    }
    //Contain methods to invoke "after insert" Event On Case
    public static void methodsToInvokeOnAfterInsert(List<Case> newCaseList,Map<Id,Case> newCaseMap){
        CaseTriggerHelper.createShipmentDetails(newCaseList, newCaseMap);
        //CaseTriggerHelper.createMultipleChildRecords(newCaseList);
        //caseTriggerDispatcher.sendConfirmationEmail(newCaseList);
    }
    //Contain methods to invoke "after update" Event On Case
    public static void methodsToInvokeOnAfterUpdate(List<Case> newCaseList,Map<Id,Case> newCaseMap,List<Case> oldCaseList,Map<Id,Case> oldCaseMap ){
        
    }
}
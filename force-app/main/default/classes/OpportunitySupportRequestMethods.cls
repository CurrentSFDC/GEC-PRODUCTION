/***********************************************************************************************
*   Class Name      : OpportunitySupportRequestMethods
*   Date            : 7/03/2017
*   Author          : Satish Babu
*   Object          : Opportunity_Support_Request__c
*   Purpose         : These methods fire on OpportunitySupportRequest.
*   Test Class      : OpportunitySupportRequestHelperTest
**************************************************************************************************/
public class OpportunitySupportRequestMethods {
    
    
    //Contain methods to invoke "before insert" Event On OpportunitySupportRequest
    public  void methodsToInvokeOnBeforeInsert(List<Opportunity_Support_Request__c> NewOSRList){
        OpportunitySupportRequestHelper OSRHelper = new OpportunitySupportRequestHelper();
        OSRHelper.UpdateOSRResourceRevenueExcess(NewOSRList);
    }
    //Contain methods to invoke "before update" Event On OpportunitySupportRequest
    public void methodsToInvokeOnBeforeUpdate(List<Opportunity_Support_Request__c> NewOSRList ,Map<Id,Opportunity_Support_Request__c> OldOSRMap ){
        OpportunitySupportRequestHelper OSRHelper = new OpportunitySupportRequestHelper();
        OSRHelper.BeforeUpdateOSRResourceRevenueExcess(NewOSRList,OldOSRMap);
        OSRHelper.sharingOSRrecord(NewOSRList);
        OSRHelper.SendEmailOnOSRSubmitted(NewOSRList);
        OSRHelper.showErrorMessages(NewOSRList);
       // OpportunitySupportRequestHelper.assignOwnerForOSR(NewOSRList,OldOSRMap);
        OpportunitySupportRequestHelper.createQuoteFromOSR(NewOSRList,OldOSRMap);
    }
    //Contain methods to invoke "after insert" Event On OpportunitySupportRequest
    public  void methodsToInvokeOnAfterInsert(List<Opportunity_Support_Request__c> NewOSRList){
        OpportunitySupportRequestHelper OSRHelper = new OpportunitySupportRequestHelper();
        OSRHelper.sharingOSRrecord(NewOSRList);
        
    }
    //Contain methods to invoke "after update" Event On OpportunitySupportRequest
    public  void methodsToInvokeOnAfterUpdate(){
        
    }
    //Contain methods to invoke "Before delete" Event On OpportunitySupportRequest
    public  void methodsToInvokeOnBeforeDelete(List<Opportunity_Support_Request__c> OldOSRList){
        OpportunitySupportRequestHelper OSRHelper = new OpportunitySupportRequestHelper();
        OSRHelper.OSRBeforeDeleteValidation(OldOSRList);
        
        
    }
    //Contain methods to invoke "after delete" Event On OpportunitySupportRequest
    // public static void methodsToInvokeOnAfterDelete(){
    //}
    
}
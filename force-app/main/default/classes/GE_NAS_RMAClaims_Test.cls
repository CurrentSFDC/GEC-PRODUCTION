@isTest
public class GE_NAS_RMAClaims_Test{

    public static testMethod void RMAClaimTest() {
        GE_NAS_RMA_Claim__c clm = new GE_NAS_RMA_Claim__c();
        clm.GE_NAS_ComplaintReason__c = 'Failed driver';
        clm.GE_NAS_Logged_By__c = 'Michael Brown';
        clm.GE_NAS_Reported_By__c = 'Michael Brown';
        clm.GE_NAS_RMA_No__c = '16789';
        clm.GE_NAS_ConfirmedOrder__c = 'Yes';
        insert clm;
        
        GE_NAS_RMA_Lineitem__c lns = new GE_NAS_RMA_Lineitem__c();
        lns.GE_NAS_RMA_Claim__c = clm.ID;
        lns.GE_NAS_Item__c = 1;
        insert lns;
        
        ApexPages.StandardController x = new ApexPages.StandardController(new GE_NAS_RMA_Claim__c());
        GE_NAS_RMAClaims objClaimsEx = new GE_NAS_RMAClaims(x);
        ApexPages.StandardController y = new ApexPages.StandardController(clm);
        GE_NAS_RMAClaims objClaims = new GE_NAS_RMAClaims(y);
        objClaims.saveClaim();
        objClaims.saveLineItems();
        objClaims.confirmOrder();
        objClaims.unConfirmOrder();
        objClaims.addLine();
        objClaims.claimLines[0].GE_NAS_Delete__c = true;
        objClaims.deleteLine();
        
    }
}
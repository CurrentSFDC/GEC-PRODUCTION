public with sharing class GE_NAS_RMAClaims {
    public GE_NAS_RMA_Claim__c claim {get;set;}
    public boolean showConfirmOrder {get;set;}
    public boolean showClaimLines {get;set;}
    public List<GE_NAS_RMA_Lineitem__c> claimLines {get;set;}
    public GE_NAS_RMA_Claim__c tempClaim  = new GE_NAS_RMA_Claim__c();
    public GE_NAS_RMAClaims(ApexPages.StandardController controller) {
        this.tempClaim = (GE_NAS_RMA_Claim__c)controller.getRecord();
        try {
            claim = [SELECT ID,Name,GE_NAS_BIRDIN_Word__c, GE_NAS_ComplaintReason__c, GE_NAS_Logged_By__c, GE_NAS_Customer__c, GE_NAS_DateLoged__c, GE_NAS_JobSite__c, GE_NAS_Memo__c, GE_NAS_Original_Reqn__c, GE_NAS_PartsRun__c, GE_NAS_Reported_By__c, GE_NAS_RMA_No__c, GE_NAS_ReplacementOrder__c,GE_NAS_Ship_Month__c, GE_NAS_ShipYear__c,GE_NAS_ConfirmedOrder__c,GE_NAS_Claim_Status__c,GE_NAS_Customer_Name__c,GE_NAS_Customer_Number__c,GE_NAS_Address__c,GE_NAS_City__c,GE_NAS_State__c,GE_NAS_Zip_Code__c FROM GE_NAS_RMA_Claim__c WHERE ID=:tempClaim.ID];
            claimLines = [SELECT ID,NAME,GE_NAS_Item__c,GE_NAS_CAT_NO__c,GE_NAS_Cost__c, GE_NAS_MfgNo__c, GE_NAS_TotalCost__c, GE_NAS_ProdLine__c, GE_NAS_PRODU__c, GE_NAS_Reason__c,GE_NAS_QTY__c, GE_NAS_RMA_Claim__c, GE_NAS_RMA_No__c,GE_NAS_RMA_Type__c,GE_NAS_Delete__c FROM GE_NAS_RMA_Lineitem__c WHERE GE_NAS_RMA_Claim__c=:claim.ID ORDER BY GE_NAS_Item__c ASC];
            showClaimLines = true;
        }
        catch(Exception ex) {
            claim = new GE_NAS_RMA_Claim__c();
            showClaimLines = false;
            showConfirmOrder = false;
        }
        if(claim.GE_NAS_ConfirmedOrder__c == 'Yes')
            showConfirmOrder = false;
        else
            showConfirmOrder = true;
    }
    
    public PageReference saveClaim() {
        
        upsert claim;
        try{
            upsert claimLines;
        }catch(Exception ex){}
        refreshLines();
        return new PageReference(System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/GE_NAS_RMAClaims?id=' + claim.Id);
    }
    
    public PageReference saveLineItems() {
        
        upsert claimLines;
        refreshLines();
        return null;
    }
    
    public PageReference confirmOrder() {
        claim.GE_NAS_ConfirmedOrder__c = 'Yes';
        update claim;
        refreshClaim();
        return null;
    }
    
    public PageReference unConfirmOrder() {
        claim.GE_NAS_ConfirmedOrder__c = 'No';
        update claim;
        refreshClaim();
        return null;
    }
    
    public void refreshLines() {
        claimLines = [SELECT ID,GE_NAS_Item__c,NAME,GE_NAS_CAT_NO__c,GE_NAS_Cost__c, GE_NAS_MfgNo__c, GE_NAS_TotalCost__c, GE_NAS_Reason__c,GE_NAS_ProdLine__c, GE_NAS_PRODU__c, GE_NAS_QTY__c, GE_NAS_RMA_Claim__c, GE_NAS_RMA_No__c,GE_NAS_RMA_Type__c,GE_NAS_Delete__c FROM GE_NAS_RMA_Lineitem__c WHERE GE_NAS_RMA_Claim__c=:claim.ID ORDER BY GE_NAS_Item__c ASC];    
    }
    public void refreshClaim() {
        claim = [SELECT ID,Name,GE_NAS_BIRDIN_Word__c, GE_NAS_ComplaintReason__c, GE_NAS_Logged_By__c, GE_NAS_Customer__c, GE_NAS_DateLoged__c, GE_NAS_JobSite__c, GE_NAS_Memo__c, GE_NAS_Original_Reqn__c, GE_NAS_PartsRun__c, GE_NAS_Reported_By__c, GE_NAS_RMA_No__c, GE_NAS_ReplacementOrder__c,GE_NAS_Ship_Month__c, GE_NAS_ShipYear__c,GE_NAS_ConfirmedOrder__c,GE_NAS_Claim_Status__c,GE_NAS_Customer_Name__c,GE_NAS_Customer_Number__c,GE_NAS_Address__c,GE_NAS_City__c,GE_NAS_State__c,GE_NAS_Zip_Code__c FROM GE_NAS_RMA_Claim__c WHERE ID=:Claim.ID];
        if(claim.GE_NAS_ConfirmedOrder__c == 'Yes')
            showConfirmOrder = false;
        else
            showConfirmOrder = true;
    }
    public void addLine() {
        GE_NAS_RMA_Lineitem__c eval = new GE_NAS_RMA_Lineitem__c();
        eval.GE_NAS_RMA_Claim__c= claim.ID;
        eval.GE_NAS_Item__c = claimLines.size()+1;
        claimLines .add(eval);
    }
    public void deleteLine() {
        List<GE_NAS_RMA_Lineitem__c> delLines = new List<GE_NAS_RMA_Lineitem__c>();
        for(GE_NAS_RMA_Lineitem__c val :claimLines) {
            if (val.GE_NAS_Delete__c && val.ID != null)
                delLines.add(val);
        }
        if(delLines.size()>0)
            delete delLines;
        refreshLines();
    }
}
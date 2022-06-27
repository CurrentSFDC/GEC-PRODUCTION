trigger GE_NAS_UpdateRMAClaimsFromLines on GE_NAS_RMA_Lineitem__c (after insert,after update) {
    //Rashmitha Changed the API vesion from 31 to 45 on 6-Mar-2019 as per 1447 request
    Set<ID> setClaimIDs = new Set<ID>();
    Map<ID,String> mapClaimProdLines = new Map<ID,String>();
    
    for(GE_NAS_RMA_Lineitem__c line :trigger.new) {
        if(line.GE_NAS_Item__c == 1) {
            try {
                mapClaimProdLines.put(line.GE_NAS_RMA_Claim__c,line.GE_NAS_ProdLine__c);
            }
            catch(Exception ex) {}
        }
    }
    List<GE_NAS_RMA_Claim__c> lstClaims = [SELECT ID,GE_NAS_ProdLine__c FROM GE_NAS_RMA_Claim__c WHERE ID IN :mapClaimProdLines.keySet()];
    if(lstClaims.size()>0) {
        for(GE_NAS_RMA_Claim__c clm :lstClaims) {
            clm.GE_NAS_ProdLine__c = mapClaimProdLines.get(clm.ID);
        }
        update lstClaims;
    }
}
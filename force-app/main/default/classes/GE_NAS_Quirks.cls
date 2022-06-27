public class GE_NAS_Quirks {
    Public Account accCurrent{get;set;}
    Public Account temp{get;set;}
    Public Boolean hasQuirks {get;set;}
    Public String strOrgValue {get;set;}
    Public String deleteQuirkID {get;set;}
    Public ID accCurrID {get;set;}
    Public String accName {get;set;}
    Public ID accParentID1 {get;set;}
    Public ID accParentID2 {get;set;}
    Public Set<ID> setAccIDs = new Set<ID>();
    Public List<GE_NAS_Quirk__c> lstQuirks {get;set;}
    public GE_NAS_Quirks(){
    }
      public GE_NAS_Quirks(ApexPages.StandardController controller) {
        hasQuirks = false;
        if(URL.getSalesforceBaseUrl().toExternalForm().contains('gelighting.my'))
            strOrgValue = 'CF00Ni000000CNJaL';
        else
            strOrgValue = 'CF00Ni000000CNJaL';
        this.temp= (Account)controller.getRecord();
        this.accCurrent = [SELECT NAME,ID FROM ACCOUNT WHERE ID=:temp.ID];
        accName = accCurrent.Name;
        setAccIDs.add(accCurrent.ID);
        accParentID1 = [SELECT PARENTID FROM ACCOUNT WHERE ID=:accCurrent.ID].PARENTID;
        if(accParentID1 != null) {
            setAccIDs.add(accParentID1);
            accParentID2 = [SELECT PARENTID FROM ACCOUNT WHERE ID=:accParentID1].PARENTID;
            if(accParentID2 != null)
                setAccIDs.add(accParentID2);
        }
        lstQuirks = [SELECT NAME,GE_NAS_Account__c,GE_NAS_Comments__c,GE_NAS_Quirk__c,GE_NAS_Value__c FROM GE_NAS_QUIRK__C WHERE GE_NAS_Account__c IN :setAccIDs];
        if(lstQuirks.size()>0)
            hasQuirks = true;
        
    }
    
 Public PageReference deleteQuirk() {
        deleteQuirkID=System.currentPageReference().getParameters().get('deleteQuirkID');
               if(deleteQuirkID != null) {
            try {
            GE_NAS_Quirk__c qrk = [SELECT ID FROM GE_NAS_Quirk__c WHERE ID=:deleteQuirkID];
            delete qrk;
            }
            catch (Exception ex) {}
        }
        return null;  
          }
 
}
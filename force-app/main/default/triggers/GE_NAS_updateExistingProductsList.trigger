Trigger GE_NAS_updateExistingProductsList on Shipment_Detail__c (after insert,after update,after delete) {
    
        //below CustomSetting will help us get downtime for a given user during business hours
    AdminOverride__c AdminOverrideUser = AdminOverride__c.getInstance(UserInfo.getUserId());
    System.debug('AdminOverrideUser: '+ AdminOverrideUser + 'Switch Status: '+ AdminOverrideUser.Switch_Off_Trigger__c);
    if(AdminOverrideUser.Switch_Off_Trigger__c == False) {
    
        TriggerSwitch__c caseProductSetting = TriggerSwitch__c.getInstance('GE_NAS_updateExistingProductsList');
        if(!(caseProductSetting != NULL && caseProductSetting.isActive__c == False)){
            
    List<Case> lstCse = new List<Case>();
    List<Shipment_Detail__c> caseproducts=new List<Shipment_Detail__c>();
    Set<ID> cseID = new Set<ID>();
    Map<String,String> mapCseExistingProds = new Map<String,String>();
    if(trigger.isdelete) {
        for(Shipment_Detail__c sd :trigger.old) {
            cseID.add(sd.GE_NAS_Case_Number__c);
        }
    }
    else {
        for(Shipment_Detail__c sd :trigger.new) {
            cseID.add(sd.GE_NAS_Case_Number__c);
        }
    }
    system.debug('SAIASIcseID:' + cseID);
    
    String tempVal = '';
    lstCse = [SELECT ID,GE_NAS_ExistingProductsList__c FROM CASE WHERE ID IN :cseID];
    system.debug('SAIASIlstCse :' + lstCse );
    caseproducts=[SELECT SAP_Material__c,GE_NAS_Case_Number__c,GE_NAS_RAP_Qty__c,GE_NAS_Unit_of_Measure1__c,GE_NAS_Type_of_Problem1__c,GE_NAS_Reorder1__c FROM Shipment_Detail__c WHERE GE_NAS_Case_Number__c in :cseID];
    system.debug('SAIASIcaseproducts:' + caseproducts);
    String tempCase;
    for (Shipment_Detail__c cseProd :caseproducts) {
        if(mapCseExistingProds.containsKey(cseProd.GE_NAS_Case_Number__c)) {
            tempCase = mapCseExistingProds.get(cseProd.GE_NAS_Case_Number__c);
            tempCase = tempCase + 'Product: ' + cseProd.SAP_Material__c +'\nQty: ' + cseProd.GE_NAS_RAP_Qty__c+'\nUOM: ' + cseProd.GE_NAS_Unit_of_Measure1__c +'\nDiscrepancy Type: ' + cseProd.GE_NAS_Type_of_Problem1__c+'\nReorder: ' + cseProd.GE_NAS_Reorder1__c + '\n\n';
            mapCseExistingProds.put(cseProd.GE_NAS_Case_Number__c,tempCase);
        }
        else {
            tempCase = 'Product: ' + cseProd.SAP_Material__c +'\nQty: ' + cseProd.GE_NAS_RAP_Qty__c+'\nUOM: ' + cseProd.GE_NAS_Unit_of_Measure1__c +'\nDiscrepancy Type: ' + cseProd.GE_NAS_Type_of_Problem1__c+'\nReorder: ' + cseProd.GE_NAS_Reorder1__c + '\n\n';
            mapCseExistingProds.put(cseProd.GE_NAS_Case_Number__c,tempCase);
        }
        tempCase = '';
    }
    for(Case cs :lstCse) {
        if(mapCseExistingProds.containsKey(cs.ID)) {
            cs.GE_NAS_ExistingProductsList__c = mapCseExistingProds.get(cs.ID);
        }
    }
    system.debug('SAIASIAfterlstCse:' + lstCse);
    update lstCse;
        }
    }
}
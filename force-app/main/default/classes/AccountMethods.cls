public without sharing class AccountMethods {
    
    public static List<User> userList = new List<User>();
    public static List<SAP_Customer_Code__mdt> codeList = new List<SAP_Customer_Code__mdt>();

    public static void updateCustomerNumbers ( List<Account> accList ){

        for ( Account acc : accList ){

            if ( acc.SAP_Parent_Customer_No__c != AccountUtils.normalizeCustomerNumber(acc.SAP_Parent_Customer_No__c) ){
                acc.SAP_Parent_Customer_No__c =AccountUtils.normalizeCustomerNumber(acc.SAP_Parent_Customer_No__c);
            }

            if ( acc.GE_LGT_EM_SAP_Customer_Number__c != AccountUtils.normalizeCustomerNumber(acc.GE_LGT_EM_SAP_Customer_Number__c) ){
                acc.GE_LGT_EM_SAP_Customer_Number__c = AccountUtils.normalizeCustomerNumber(acc.GE_LGT_EM_SAP_Customer_Number__c);
            }
        }
    } 

    public static void updateCustomerCodes ( Map<id, Account> oldAccMap, Map<id, Account> newAccMap, List<Account> accList ){
        
        Map<string, string> codemap = new Map<string, string>();
        
        if ( codeList.size() == 0 ){
            codeList = [ SELECT MasterLabel, DeveloperName, Code__c, Is_Active__c FROM SAP_Customer_Code__mdt ];
        }

        for ( SAP_Customer_Code__mdt cd : codeList ){
            codeMap.put(cd.DeveloperName, cd.MasterLabel);
        }

        for ( Account acc : accList ){
            String vertical=acc.GE_LGT_Vertical__c==null?'Manual Test':acc.GE_LGT_Vertical__c;
            String subVertical=acc.GE_LGT_Sub_Vertical__c==null?'Manual Test':acc.GE_LGT_Sub_Vertical__c;
            string chanCode = acc.GE_LGT_EM_Distribution_Channel__c != null ? 'DC' + '_' + acc.GE_LGT_EM_Distribution_Channel__c : null ;
            string divCode = acc.GE_LGT_EM_Division__c != null ? 'DV' + '_' + acc.GE_LGT_EM_Division__c : null ;
            string pfCode = acc.GE_LGT_EM_PF_Type__c != null ? 'PF' + '_' + acc.GE_LGT_EM_PF_Type__c : null ;
            string distCode = acc.GE_LGT_Sales_District__c != null ? 'SD' + '_' + acc.GE_LGT_Sales_District__c : null ; //was GE_NAS_Domain__c replaced by AA Request No.   RQT-0000613
            string grpCode = acc.GE_LGT_Sales_Group__c != null ? 'SG' + '_' + acc.GE_LGT_Sales_Group__c : null ;
            string offCode = acc.GE_LGT_Sales_Office__c != null ? 'SO' + '_' + acc.GE_LGT_Sales_Office__c : null ;
            string orgCode = acc.GE_LGT_EM_Sales_Org__c != null ? 'SR' + '_' + acc.GE_LGT_EM_Sales_Org__c : null ;
            string svertCode = acc.GE_LGT_Sub_Vertical__c != null ? 'SV' + '_' + acc.GE_LGT_Sub_Vertical__c : null ;
            string vertCode = acc.GE_LGT_Vertical__c != null ? 'VT' + '_' + acc.GE_LGT_Vertical__c : null ;
            string busCode = acc.GE_NAS_GE_Business_Code__c != null ? 'GB' + '_' + acc.GE_NAS_GE_Business_Code__c : null ;
            string dCentCode = acc.GE_NAS_Default_Distribution_Center__c != null ? 'DE' + '_' + acc.GE_NAS_Default_Distribution_Center__c : null ;
            string langCode = acc.GE_NAS_Language__c != null ? 'LA' + '_' + acc.GE_NAS_Language__c : null ;
            string ntypeCode = acc.GE_NAS_National_Type__c != null ? 'NT' + '_' + acc.GE_NAS_National_Type__c : null ;
            string compCode = acc.GE_NAS_NCSC_Component_Code__c != null ? 'NC' + '_' + acc.GE_NAS_NCSC_Component_Code__c : null ;
            string carrCode = acc.GE_NAS_Preferred_Carrier__c != null ? 'PC' + '_' + acc.GE_NAS_Preferred_Carrier__c : null ;
            string schedCode = acc.GE_NAS_Shipping_Schedule__c != null ? 'SS' + '_' + acc.GE_NAS_Shipping_Schedule__c : null ;
            string stypeCode = acc.GE_NAS_Shipping_Type__c != null ? 'ST' + '_' + acc.GE_NAS_Shipping_Type__c : null ;

            acc.Distribution_Channel_Description__c  = acc.Distribution_Channel_Description__c  != ( chanCode != null ? codeMap.get(chanCode) : null ) ? ( chanCode != null ? codeMap.get(chanCode) : null ) : acc.Distribution_Channel_Description__c  ;
            acc.Division_Description__c  = acc.Division_Description__c  != ( divCode != null ? codeMap.get(divCode) : null ) ? ( divCode != null ? codeMap.get(divCode) : null ) : acc.Division_Description__c  ;
            acc.PF_Description__c  = acc.PF_Description__c  != ( pfCode != null ? codeMap.get(pfCode) : null ) ? ( pfCode != null ? codeMap.get(pfCode) : null ) : acc.PF_Description__c  ;
            acc.Sales_District_Description__c  = acc.Sales_District_Description__c  != ( distCode != null ? codeMap.get(distCode) : null ) ? ( distCode != null ? codeMap.get(distCode) : null ) : acc.Sales_District_Description__c  ;
            acc.Sales_Group_Description__c  = acc.Sales_Group_Description__c  != ( grpCode != null ? codeMap.get(grpCode) : null ) ? ( grpCode != null ? codeMap.get(grpCode) : null ) : acc.Sales_Group_Description__c  ;
            acc.Sales_Office_Description__c  = acc.Sales_Office_Description__c  != ( offCode != null ? codeMap.get(offCode) : null ) ? ( offCode != null ? codeMap.get(offCode) : null ) : acc.Sales_Office_Description__c  ;
            acc.Sales_Org_Description__c  = acc.Sales_Org_Description__c  != ( orgCode != null ? codeMap.get(orgCode) : null ) ? ( orgCode != null ? codeMap.get(orgCode) : null ) : acc.Sales_Org_Description__c  ;
            //Added code to reistrict auto update if sub Vertical don't have code
            acc.Sub_Vertical_Description__c  = subVertical.isNumeric()?(acc.Sub_Vertical_Description__c  != ( svertCode != null ? codeMap.get(svertCode) : null ) ? ( svertCode != null ? codeMap.get(svertCode) : null ) : acc.Sub_Vertical_Description__c):acc.Sub_Vertical_Description__c  ;
            //Added code to reistrict auto update if Vertical don't have code
            acc.Vertical_Description__c  = vertical.isNumeric()?(acc.Vertical_Description__c  != ( vertCode != null ? codeMap.get(vertCode) : null ) ? ( vertCode != null ? codeMap.get(vertCode) : null ) : acc.Vertical_Description__c ):acc.Vertical_Description__c ;
            acc.GE_NAS_Business_Code_Description__c = acc.GE_NAS_Business_Code_Description__c != ( busCode != null ? codeMap.get(busCode) : null ) ? ( busCode != null ? codeMap.get(busCode) : null ) : acc.GE_NAS_Business_Code_Description__c ;
            acc.GE_NAS_Distribution_Center_Desc__c = acc.GE_NAS_Distribution_Center_Desc__c != ( dCentCode != null ? codeMap.get(dCentCode) : null ) ? ( dCentCode != null ? codeMap.get(dCentCode) : null ) : acc.GE_NAS_Distribution_Center_Desc__c ;
            acc.GE_NAS_Language_Description__c = acc.GE_NAS_Language_Description__c != ( langCode != null ? codeMap.get(langCode) : null ) ? ( langCode != null ? codeMap.get(langCode) : null ) : acc.GE_NAS_Language_Description__c ;
            acc.GE_NAS_National_Type_Desc__c = acc.GE_NAS_National_Type_Desc__c != ( ntypeCode != null ? codeMap.get(ntypeCode) : null ) ? ( ntypeCode != null ? codeMap.get(ntypeCode) : null ) : acc.GE_NAS_National_Type_Desc__c ;
            acc.GE_NAS_NCSC_Component_Description__c = acc.GE_NAS_NCSC_Component_Description__c != ( compCode != null ? codeMap.get(compCode) : null ) ? ( compCode != null ? codeMap.get(compCode) : null ) : acc.GE_NAS_NCSC_Component_Description__c ;
            acc.GE_NAS_Preferred_Carrier_Desc__c = acc.GE_NAS_Preferred_Carrier_Desc__c != ( carrCode != null ? codeMap.get(carrCode) : null ) ? ( carrCode != null ? codeMap.get(carrCode) : null ) : acc.GE_NAS_Preferred_Carrier_Desc__c ;
            acc.GE_NAS_Shipping_Schedule_Desc__c = acc.GE_NAS_Shipping_Schedule_Desc__c != ( schedCode != null ? codeMap.get(schedCode) : null ) ? ( schedCode != null ? codeMap.get(schedCode) : null ) : acc.GE_NAS_Shipping_Schedule_Desc__c ;
            acc.GE_NAS_Shipping_Type_Desc__c = acc.GE_NAS_Shipping_Type_Desc__c != ( stypeCode != null ? codeMap.get(stypeCode) : null ) ? ( stypeCode != null ? codeMap.get(stypeCode) : null ) : acc.GE_NAS_Shipping_Type_Desc__c ;

        }
 
    }

    public static void updateAccountOwners ( Map<id, Account> oldAccMap, Map<id, Account> newAccMap, List<Account> accList ){

        Map<string, string> ssoMap = new Map<string, string>();
        
        if ( userList.size() == 0 ){
            userList = [ SELECT Id, FederationIdentifier FROM User WHERE FederationIdentifier != null AND UserType = 'Standard' ] ;
        }

        for ( User u : userList ){
            ssoMap.put(u.FederationIdentifier, u.id);
        }

        for ( Account acc : accList ){

            string ownerSso = acc.Owner_SSO__c != AccountUtils.normalizeSso(acc.Owner_SSO__c) ? AccountUtils.normalizeSso(acc.Owner_SSO__c) : acc.Owner_SSO__c;
            string rmSso = acc.GE_LGT_Regional_Manager__c != AccountUtils.normalizeSso(acc.GE_LGT_Regional_Manager__c) ? AccountUtils.normalizeSso(acc.GE_LGT_Regional_Manager__c) : acc.GE_LGT_Regional_Manager__c;
            string dmSso = acc.GE_LGT_District_Manager__c != AccountUtils.normalizeSso(acc.GE_LGT_District_Manager__c) ? AccountUtils.normalizeSso(acc.GE_LGT_District_Manager__c) : acc.GE_LGT_District_Manager__c;

            acc.Owner_SSO__c = ownerSso ;
            acc.GE_LGT_Regional_Manager__c = rmSso;
            acc.GE_LGT_District_Manager__c = dmSso;
            
            if ( acc.Customer_Integration_Key__c != null ){

                acc.OwnerId = ownerSso != null && ssoMap.get(ownerSso) != null ? ( acc.OwnerId != ssoMap.get(ownerSso) ? ssoMap.get(ownerSso) : acc.OwnerId ) : acc.OwnerId ;
                acc.Regional_Manager_Name__c = rmSso != null && ssoMap.get(rmSso) != null ? ( acc.Regional_Manager_Name__c != ssoMap.get(rmSso) ? ssoMap.get(rmSso) : acc.Regional_Manager_Name__c ) : null ;
                acc.District_Manager_Name__c = dmSso != null && ssoMap.get(dmSso) != null ? ( acc.District_Manager_Name__c != ssoMap.get(dmSso) ? ssoMap.get(dmSso) : acc.District_Manager_Name__c ) : null ; 
            }
        }
    }

    public static void updateParentAgentTypes ( set<id> parAgentSet ){

        set<id> newParAccIdSet = new Set<id>();

        set<id> archSet = new Set<id>();
        set<id> contSet = new Set<id>();
        set<id> lampSet = new Set<id>();
        set<id> othSet = new Set<id>();
        set<id> roadSet = new Set<id>();
        set<id> ciSet = new Set<id>();
        set<id> utilSet = new Set<id>();
        set<id> dotSet = new Set<id>();
        set<id> sportSet = new Set<id>();

        List<Account> parAccUpdList = new List<Account>();

        Account[] childAccList = [ SELECT Id, ParentId, GE_LGT_Architecture__c, GE_LGT_Controls__c, Lamp_Ballast__c, Others__c, GE_LGT_Roadway__c, GE_LGT_C_I__c, GE_LGT_Utility__c, GE_LGT_DOT__c, GE_LGT_Sports__c FROM Account WHERE ParentId in :parAgentSet  ] ;       

        for ( Account acc : childAccList ){

            if ( acc.GE_LGT_Architecture__c ){
                archSet.add(acc.ParentId);
            }

            if ( acc.GE_LGT_Controls__c ){ 
                contSet.add(acc.ParentId);
            }

            if( acc.Lamp_Ballast__c ){ 
                lampSet.add(acc.ParentId);
            }

            if( acc.Others__c ){ 
                othSet.add(acc.ParentId);
            }

            if( acc.GE_LGT_Roadway__c ){ 
                roadSet.add(acc.ParentId);
            }

            if( acc.GE_LGT_C_I__c ){ 
                ciSet.add(acc.ParentId);
            }

            if( acc.GE_LGT_Utility__c ){ 
                utilSet.add(acc.ParentId);
            }

            if( acc.GE_LGT_DOT__c ){ 
                dotSet.add(acc.ParentId);
            }

            if( acc.GE_LGT_Sports__c ){ 
                sportSet.add(acc.ParentId);
            }
        }

        newParAccIdSet.addAll(archSet);
        newParAccIdSet.addAll(contSet);
        newParAccIdSet.addAll(lampSet);
        newParAccIdSet.addAll(othSet);
        newParAccIdSet.addAll(roadSet);     
        newParAccIdSet.addAll(ciSet);
        newParAccIdSet.addAll(utilSet);
        newParAccIdSet.addAll(dotSet);
        newParAccIdSet.addAll(sportSet);

        List<Account> parAccList = [ SELECT Id, ParentId FROM Account WHERE Id in :newParAccIdSet ];

        for ( Account acc : parAccList ){
            acc.GE_LGT_Architecture__c = archSet.contains( acc.id) ? true : false ;
            acc.GE_LGT_Controls__c = contSet.contains( acc.id) ? true : false ;
            acc.Lamp_Ballast__c = lampSet.contains( acc.id) ? true : false ;
            acc.Others__c = othSet.contains( acc.id) ? true : false ;
            acc.GE_LGT_Roadway__c = roadSet.contains( acc.id) ? true : false ;
            acc.GE_LGT_C_I__c = ciSet.contains( acc.id) ? true : false ;
            acc.GE_LGT_Utility__c = utilSet.contains( acc.id) ? true : false ;
            acc.GE_LGT_DOT__c = dotSet.contains( acc.id) ? true : false ;
            acc.GE_LGT_Sports__c = sportSet.contains( acc.id) ? true : false ;
            parAccUpdList.add(acc);
        }

        if ( parAccUpdList.size() > 0 ){
            update parAccUpdList;
        }
    }

    public static void updateStrategicHierarchy(Set<String> custnoSet, Set<Id> hierarchySet) {
        List<Account> accUpdList = new List<Account>();

        Map<String, Account> stratAccMap = new Map<String, Account>();

        Account[] stratAccList = [
                SELECT Id, ParentId, SAP_Parent_Customer_No__c, GE_LGT_EM_SAP_Customer_Number__c, Account_Group__c, Customer_Integration_Key__c
                FROM Account
                WHERE Account_Group__c != NULL AND Customer_Integration_Key__c IN :custnoSet
        ] ;

        for (Account acc : stratAccList) {
            //String custno = AccountUtils.normalizeCustomerNumber(acc.GE_LGT_EM_SAP_Customer_Number__c);
            stratAccMap.put(acc.Customer_Integration_Key__c, acc);
        }
        for (Account acc : stratAccList) {

            if (custnoSet.contains(acc.Customer_Integration_Key__c)) {

                String parCustNo = acc.SAP_Parent_Customer_No__c;

                Id parId = (parCustNo != null && stratAccMap.get(parCustNo) != null) ? stratAccMap.get(parCustNo).Id : null ;

                if (parId != acc.ParentId) {
                    acc.ParentId = parId ;
                    system.debug('TDBG '+acc.ParentId);
                    accUpdList.add(acc);
                }
            }
        }

        if (accUpdList.size() > 0) {
            update accUpdList;
        }
    }
    
     public static void UpdateIsGlobalParentActiveOnGlobalAccount(List<Account> globalAccList,map<id,Account> allAccOldMAp){
    //ID recGAtypeID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Agent Parent').getRecordTypeId();
    ID recSAPtypeID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account').getRecordTypeId();
    ID recSAPFAAgentypeID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('SAP Account - Agent').getRecordTypeId();
   // ID recAgentypeFixAgentID =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent - Lamp & Ballast').getRecordTypeId();
    set <ID> setidsSAFA = new set <ID>();
    set <ID> setidsSAP = new set <ID>();
    set <ID> setidsGAP = new set <ID>();
    for(Account acc:globalAccList){
        System.debug('trigger.isupdate:'+trigger.isupdate);
        if(trigger.isInsert){
            if(acc.parentid!=null && (acc.Recordtypeid==recSAPFAAgentypeID ) && acc.GE_LGT_EM_CustomerActiveFlag__c) {
                    setidsSAFA.add(acc.parentid);
            }
        } 
        if(trigger.isupdate){
            if (acc.Recordtypeid==recSAPFAAgentypeID) {
                if (acc.parentid != allAccOldMAp.get(acc.Id).parentid || acc.GE_LGT_EM_CustomerActiveFlag__c!=allAccOldMAp.get(acc.Id).GE_LGT_EM_CustomerActiveFlag__c) {
                    if (acc.parentid != null){
                            setidsSAFA.add(acc.parentid);
                    }
                            setidsSAFA.add(allAccOldMAp.get(acc.Id).parentid);
                }else if(acc.GE_LGT_EM_CustomerActiveFlag__c != allAccOldMAp.get(acc.Id).GE_LGT_EM_CustomerActiveFlag__c) {
                            setidsSAFA.add(acc.parentid);
                    }
            }

            //ADDED - MG - 6/23/2022
            if (acc.Recordtypeid==recSAPtypeID) {
                if (acc.parentid != allAccOldMAp.get(acc.Id).parentid || acc.GE_LGT_EM_CustomerActiveFlag__c!=allAccOldMAp.get(acc.Id).GE_LGT_EM_CustomerActiveFlag__c) {
                    if (acc.parentid != null){
                        setidsSAP.add(acc.parentid);
                    }
                        setidsSAP.add(allAccOldMAp.get(acc.Id).parentid);
                }else if(acc.GE_LGT_EM_CustomerActiveFlag__c != allAccOldMAp.get(acc.Id).GE_LGT_EM_CustomerActiveFlag__c) {
                        setidsSAP.add(acc.parentid);
                    }
            }
        }   
        if(trigger.isdelete){
            if (allAccOldMAp.get(acc.id).Recordtypeid==recSAPFAAgentypeID) {
                if (allAccOldMAp.get(acc.id).parentid != null && allAccOldMAp.get(acc.id).GE_LGT_EM_CustomerActiveFlag__c) {
                        setidsSAFA.add(allAccOldMAp.get(acc.id).parentid);
                }
            }
        }
        if(trigger.isundelete){
            if (acc.Recordtypeid==recSAPFAAgentypeID) {
                if (acc.parentid != null && acc.GE_LGT_EM_CustomerActiveFlag__c) {
                    //setidsSAFA.add(allAccOldMAp.get(acc.id).parentid);
                      setidsSAFA.add(acc.parentid);
                }
            }
        }
    }
    System.debug('setidsSAFA.size():'+setidsSAFA.size());
    if(setidsSAFA.size()>0){
        list<Account> acclist =new list<Account>();
        
            for(account a : [select id,IsGlobalParentActive__c,GE_LGT_EM_CustomerActiveFlag__c,(select id from ChildAccounts where GE_LGT_EM_CustomerActiveFlag__c=:true AND (recordTypeId =:recSAPFAAgentypeID ))from account where id IN:setidsSAFA AND Recordtypeid =:recSAPtypeID]){
                    System.debug('ChildAccount1:'+a.ChildAccounts.size());
                    if(a.ChildAccounts.size()>0){
                        //a.IsGlobalParentActive__c=true;
                        a.GE_LGT_EM_CustomerActiveFlag__c = true;
                        acclist.add(a);
                    }else {
                        //a.IsGlobalParentActive__c=false;
                        a.GE_LGT_EM_CustomerActiveFlag__c = false;
                        acclist.add(a);
                    }
        }
        System.debug('acclist.size():'+acclist.size());
                    if(acclist.size()>0)
                    update acclist;
                    System.debug('UpdateSAccount1:'+acclist);
    }

    //ADDED - MG - 6/23/2022
    System.debug('setidsSAP.size():'+setidsSAP.size());
    if(setidsSAP.size()>0){
        list<Account> acclistSAP =new list<Account>();
        
            for(account a : [select id,IsGlobalParentActive__c,GE_LGT_EM_CustomerActiveFlag__c,(select id from ChildAccounts where GE_LGT_EM_CustomerActiveFlag__c=:true AND (recordTypeId =:recSAPtypeID ))from account where id IN:setidsSAP AND Recordtypeid =:recSAPtypeID]){
                    System.debug('ChildAccount1:'+a.ChildAccounts.size());
                    if(a.ChildAccounts.size()>0){
                        //a.IsGlobalParentActive__c=true;
                        a.GE_LGT_EM_CustomerActiveFlag__c = true;
                        acclistSAP.add(a);
                    }else {
                        //a.IsGlobalParentActive__c=false;
                        a.GE_LGT_EM_CustomerActiveFlag__c = false;
                        acclistSAP.add(a);
                    }
        }
        System.debug('acclistSAP.size():'+acclistSAP.size());
                    if(acclistSAP.size()>0)
                    update acclistSAP;
                    System.debug('UpdateSAccount1:'+acclistSAP);
    }
} 
}
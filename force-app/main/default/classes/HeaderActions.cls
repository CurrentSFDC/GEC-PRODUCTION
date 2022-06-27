global class HeaderActions {
    @RemoteAction
    global static List<Object> getUomCodeLabelMap(ccrz.cc_RemoteActionContext ctx) {
        List<UOM_Mapping__mdt> uom = [SELECT Code__c, Label, Order__c FROM UOM_Mapping__mdt ORDER BY Order__c NULLS LAST ];
        return uom;
    }

    @RemoteAction
    global static Object getRepCode(ccrz.cc_RemoteActionContext ctx, String accountId) {
        Account ac = [SELECT Id, Name, AccountNumber, Connect_Z002_Parents__c, GE_LGT_Rep_Code__c, Account_Group__c FROM Account WHERE Id = :accountId];
        return ac;
    }

    @RemoteAction
    global static ccrz__E_Cart__c getCart(ccrz.cc_RemoteActionContext ctx, String cartId){

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        ccrz__E_Cart__c cart;
        try{
            cart =CartServices.getCartById(cartId);
            return cart;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return cart;
    }

    /*@RemoteAction
    global static ccrz__E_Cart__c getCartByEffAcc(ccrz.cc_RemoteActionContext ctx, String effAccId){

        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        ccrz__E_Cart__c cart;
        try{
            cart =CartServices.getCartByEffAcc(effAccId);
            return cart;
        }catch(Exception e){
            ccrz.ccLog.log(LoggingLevel.ERROR,'Err',e);
        }finally{
            ccrz.ccLog.close(res);
        }
        return cart;
    }*/

    @RemoteAction
    global static Object getProfId(ccrz.cc_RemoteActionContext ctx, String userConId) {

        User us = [SELECT Id, Profile.Name,Account.GE_LGT_Rep_Code__c,Account.Account_Group__c FROM User WHERE Id = :userConId];

        return us;

    }

    @RemoteAction
    global static Object getPerSet(ccrz.cc_RemoteActionContext ctx, String userConId) {
        Id userId = UserInfo.getUserId();
        String perSet = 'Default_Profile';


        List<PermissionSetAssignment> psa = [
                SELECT Id, AssigneeId, Assignee.Name, Assignee.Profile.Name, PermissionSet.IsOwnedByProfile, PermissionSetId,PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE PermissionSet.Name = 'View_Commissions_Set_Price' AND AssigneeId IN (SELECT Id FROM User WHERE Id = :userId)
        ];
        for (PermissionSetAssignment psa1 : psa) {
            if (psa1.PermissionSet.Name == 'View_Commissions_Set_Price') {
                perSet = 'View_Commissions_Set_Price';
            } else {
                perSet = 'Default_Profile';
            }
        }

        return perSet;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult getRelatedAccountsOfUser(ccrz.cc_RemoteActionContext ctx) {
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
        Map<String, Object> data = new Map<String, Object>();
        result.success = false;
        result.inputContext = ctx;
        List<Contact> contacts = [SELECT Id,Portal_User_Type__c FROM Contact WHERE Id = :ccrz.cc_CallContext.currUser.ContactId LIMIT 1];
        if (contacts.size() == 0) {
            return result;
        }
        Contact contact = contacts.get(0);
        data.put('userType', contact.Portal_User_Type__c);
        if(String.isNotBlank(ccrz.cc_CallContext.effAccountId)) {
            List<Account> accounts = [
                    SELECT Id,Name, AccountNumber, GE_LGT_EM_SAP_Customer_Number__c, ShippingAddress, Customer_Segmentation__c,Account_Group__c,
                            ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, RecordTypeId, GE_LGT_EM_Order_Block__c
                    FROM Account
                    WHERE Id =:ccrz.cc_CallContext.effAccountId LIMIT 1];
            if(accounts.size() == 1){
                data.put(
                        'workingEffectiveAccount',
                        new Map<String, Object>{
                                'Id' => accounts[0].Id,
                                'Name' => accounts[0].Name,
                                'AccountNumber' => accounts[0].AccountNumber,
                                'GE_LGT_EM_SAP_Customer_Number__c' => accounts[0].GE_LGT_EM_SAP_Customer_Number__c,
                                'ShippingAddress' => new Map<String, String>{
                                        'street' => accounts[0].ShippingStreet,
                                        'city' => accounts[0].ShippingCity,
                                        'state' => accounts[0].ShippingState,
                                        'postalCode' => accounts[0].ShippingPostalCode,
                                        'country' => accounts[0].ShippingCountry
                                },
                                'GE_LGT_EM_Order_Block__c' => accounts[0].GE_LGT_EM_Order_Block__c,
                                'Customer_Segmentation__c' => accounts[0].Customer_Segmentation__c,
                                'Account_Group__c' => accounts[0].Account_Group__c,
                                'RecordTypeId' => accounts[0].RecordTypeId,
                                'sfid' => accounts[0].Id
                        }
                );

            }
        }
        List<AccountContactRelation> accountContactRelations = [SELECT AccountId FROM AccountContactRelation WHERE ContactId = :contact.Id];
        Set<Id> accountIds = new Set<Id>();
        for (AccountContactRelation a : accountContactRelations) {
            accountIds.add(a.AccountId);
        }
        if (contact.Portal_User_Type__c == 'Agent') {
            system.debug('accountIds  '+accountIds);
            List<Account> agents = [
                    SELECT Id, Name, GE_LGT_EM_SAP_Customer_Number__c, ShippingAddress, Customer_Segmentation__c,RecordTypeId, GE_LGT_EM_Order_Block__c
                    FROM Account
                    WHERE Account_Group__c = 'ZEAG' AND Id IN :accountIds AND GE_LGT_EM_CustomerActiveFlag__c = TRUE
                    AND ((Customer_Segmentation__c != 'LB' AND Customer_Segmentation__c != 'Lamp') OR
                    ((Customer_Segmentation__c = 'LB' OR Customer_Segmentation__c = 'Lamp') AND (NOT GE_LGT_Rep_Code__c LIKE 'U%')))
                    AND (NOT Name LIKE '%- PARENT')
                    ORDER BY Name ASC
            ];
            if (agents.size() > 0) {
                result.success = true;
                Set<String> agentSAPCustomerNumbers = new Set<String>();
                for (Account agent : agents) {
                    if (String.isNotBlank(agent.GE_LGT_EM_SAP_Customer_Number__c)) {
                        agentSAPCustomerNumbers.add('%' + agent.GE_LGT_EM_SAP_Customer_Number__c + '%');
                    }
                }
                List<Account> customerAccounts = [
                        SELECT Id, Name, ShippingAddress,GE_LGT_EM_SAP_Customer_Number__c, Customer_Segmentation__c,ConnectFixtureAgents__c,RecordTypeId, GE_LGT_EM_Order_Block__c
                        FROM Account
                        WHERE ConnectFixtureAgents__c LIKE :agentSAPCustomerNumbers
                ];
                List<Object> agentsData = new List<Object>();
                List<Object> customerAccountsData = new List<Object>();
                for (Account agent : agents) {
                    Map<String, Object> agentMap = agent.getPopulatedFieldsAsMap().clone();
                    agentMap.put('sfid', agentMap.get('Id'));
                    agentMap.put('customerAccountIds', new List<String>());
                    for (Account customerAccount : customerAccounts) {
                        if(customerAccount.ConnectFixtureAgents__c.contains(agent.GE_LGT_EM_SAP_Customer_Number__c)){
                            ((List<String>)agentMap.get('customerAccountIds')).add(customerAccount.Id);
                        }
                    }
                    agentsData.add(agentMap);
                }
                for (Account customerAccount : customerAccounts) {
                    Map<String, Object> customerAccountMap = customerAccount.getPopulatedFieldsAsMap().clone();
                    customerAccountMap.put('sfid', customerAccountMap.get('Id'));
                    customerAccountsData.add(customerAccountMap);
                }
                data.put('agents',agentsData);
                data.put('customerAccounts',customerAccountsData);
                result.data = data;
            } else {
                ccrz.cc_bean_Message message = new ccrz.cc_bean_Message();
                message.message = 'Agents not found';
                result.messages.add(message);
            }
        } else {
            List<Account> accountList = [
                    SELECT Id, Name, GE_LGT_EM_SAP_Customer_Number__c,ShippingAddress, Customer_Segmentation__c,RecordTypeId, GE_LGT_EM_Order_Block__c
                    FROM Account
                    WHERE Id IN :accountIds AND GE_LGT_EM_CustomerActiveFlag__c = TRUE
                    ORDER BY Name ASC
            ];
            if (accountList.size() > 0) {
                List<Object> customerAccountsData = new List<Object>();
                for (Account account : accountList) {
                    Map<String, Object> customerAccountMap = account.getPopulatedFieldsAsMap().clone();
                    customerAccountMap.put('sfid', customerAccountMap.get('Id'));
                    customerAccountsData.add(customerAccountMap);
                }
                result.success = true;
                data.put('customerAccounts', customerAccountsData);
                result.data = data;
            } else {
                ccrz.cc_bean_Message message = new ccrz.cc_bean_Message();
                message.message = 'Customer accounts not found';
                result.messages.add(message);
            }
        }
        return result;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult getSAPOrderNo(ccrz.cc_RemoteActionContext ctx,String orderID){
        return CheckoutActions.getSAPOrderNo(ctx, orderID);
    }

    // @RemoteAction
    // global static Object getRepCodeNew(ccrz.cc_RemoteActionContext ctx){
    //     User u = [SELECT contact.AccountId FROM user WHERE id =: Userinfo.getUserid()];
    //     Account ac = [SELECT Id, GE_LGT_Rep_Code__c, Account_Group__c FROM Account WHERE Id =: u.contact.AccountId];
    //     return ac;
    // }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult resetImpersonateFlag(ccrz.cc_RemoteActionContext ctx, String contactID){
        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
        result.success=true;
        result.data='';
        Contact updateContact = [Select id From Contact Where id = :contactID]; 
        updateContact.Impersonate_Mode__c = false;
        update updateContact;
        return result;
    }
}
global class MyAccountActions {
    @RemoteAction
    global static ccrz.cc_RemoteActionResult updateAddress(ccrz.cc_RemoteActionContext ctx, String jsonString){
        
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        Id accountId = Id.valueOf(ctx.effAccountId);
        Map<String, Object> addressData = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        try{
            Map<String, Object> bean = (Map<String, Object>) addressData.get('addressBean');
            String address1 = (String) bean.get('address1');
            String city = (String) bean.get('city');
            String companyName = (String) bean.get('companyName');
            String country = (String) bean.get('country');
            String countryCode = (String) bean.get('countryCode');
            String firstName = (String) bean.get('firstName');
            String lastName = (String) bean.get('lastName');
            String partnerId = (String) bean.get('partnerId');
            String phone = (String) bean.get('phone');
            String postalCode = (String) bean.get('postalCode');
            String sfid = (String) bean.get('sfid');
            String state = (String) bean.get('state');

            Boolean isDefault = Boolean.valueOf(addressData.get('isDefault'));
            String bookId = (String) addressData.get('bookSfid');

            if(!String.isBlank(sfid)){
                try{
                    ccrz__E_ContactAddr__c existingAddress = [SELECT Id FROM ccrz__E_ContactAddr__c WHERE Id =: Id.valueOf(sfid)];
                    ccrz__E_AccountAddressBook__c existingBook = [SELECT Id FROM ccrz__E_AccountAddressBook__c WHERE Id =: Id.valueOf(bookId)];
                    delete existingAddress;
                    delete existingBook;
                }catch(Exception e){
                    res.success=false;
                    return res; 
                }
            }

                ccrz__E_ContactAddr__c newAddress = new ccrz__E_ContactAddr__c();
                newAddress.ccrz__AddressFirstline__c=address1;
                newAddress.ccrz__City__c=city;
                newAddress.ccrz__CompanyName__c=companyName;
                newAddress.ccrz__Country__c=country;
                newAddress.ccrz__CountryISOCode__c=countryCode;
                newAddress.ccrz__FirstName__c=firstName;
                newAddress.ccrz__LastName__c=lastName;
                newAddress.ccrz__Partner_Id__c=partnerId;
                newAddress.ccrz__DaytimePhone__c=phone;
                newAddress.ccrz__PostalCode__c=postalCode;
                newAddress.ccrz__State__c=state;
                //newAddress.OwnerId = userId;
                insert newAddress;

                ccrz__E_AccountAddressBook__c bookEntry = new ccrz__E_AccountAddressBook__c();
                bookEntry.ccrz__Account__c = accountId;
                bookEntry.ccrz__AccountId__c = String.valueOf(accountId);
                bookEntry.ccrz__AddressType__c = 'Shipping';
                bookEntry.ccrz__Default__c = isDefault;
                bookEntry.ccrz__E_ContactAddress__c = newAddress.Id;
                //bookEntry.Name = 'a';
                insert bookEntry;

            res.success=true;
        }
        catch(Exception e){
            res.success = false;
            res.data = e;
        }
        return res;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult getPhone(ccrz.cc_RemoteActionContext ctx, String jsonString){
        
        ccrz.cc_RemoteActionResult res = ccrz.cc_CallContext.init(ctx);
        List<Object> addressData = (List<Object>)JSON.deserializeUntyped(jsonString);

        Map<String, String> idToPhoneMap = new Map<String, String>();
        Map<String,Object> addrMap;
        List<ccrz__E_ContactAddr__c> contactAddrs;
        for(Object addr : addressData){
            addrMap = (Map<String,Object>) addr;
            idToPhoneMap.put((String)addrMap.get('sfid'), null);
        }
        
        contactAddrs = [SELECT ccrz__DaytimePhone__c FROM ccrz__E_ContactAddr__c WHERE Id IN :idToPhoneMap.keySet()];
        for(ccrz__E_ContactAddr__c addr : contactAddrs){
            idToPhoneMap.put(addr.id, addr.ccrz__DaytimePhone__c);
        }
        res.data=idToPhoneMap;
        res.success=true;
        return res;
    }
}
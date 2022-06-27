// CommunityCreateContactController class
// Controller class for the CommunityPortalSelfRegister component
// ------------------------------------------------------------------
//  Author                    Date         Description
// ------------------------------------------------------------------
//  Devang Shah	              22/10/2020   Created
//

public without sharing class CommunityCreateContactController {

    private static String DummyAccountName = 'GuestAccount';
    private static List<String> ProfileNames = new List<String>{'B2B Storefront Registered Users'};

	private static Map<String, String> b2bSettingMap {
		get
		{
			Map<String, String> b2bSettingMap = new Map<String, String>();
			for(B2B_Setting__mdt b2b:[SELECT MasterLabel, Value__c FROM B2B_Setting__mdt]){
				b2bSettingMap.put(b2b.MasterLabel,b2b.Value__c);
			}
			return b2bSettingMap;
		}
		set;
    }
    

    @AuraEnabled
    public static String registerUser(UserWrapper userData) {
                   
        DummyAccountName = b2bSettingMap.get('GuestAccount');
        //System.debug('DummyAccountName =' + DummyAccountName);
        //System.debug('AgentProfiles =' + b2bSettingMap.get('AgentProfiles'));
        //System.debug('DistributorProfiles =' + b2bSettingMap.get('DistributorProfiles'));
        String profilesToCheck  = b2bSettingMap.get('AgentProfiles') + ',' + b2bSettingMap.get('DistributorProfiles');
        //System.debug('profilesToCheck =' + profilesToCheck);
        List<String> profilesToCheckList = profilesToCheck.split(',');
        ProfileNames = profilesToCheckList;
        //System.debug('ProfileNames =' + ProfileNames);

        if (userData == null || String.isBlank(userData.firstName) || String.isBlank(userData.lastName) || String.isBlank(userData.phone)
        || String.isBlank(userData.email ) || String.isBlank(userData.companyName) || String.isBlank(userData.country ) || String.isBlank(userData.userType )) { return 'invalid'; }
        
        if(userData.userType == 'Agent' && String.isBlank(userData.registrationRepCodes)){
            return 'invalid';
        }
        if(userData.userType == 'Distributor' && String.isBlank(userData.registrationAccounts)){
            return 'invalid';
        }
        if(userData.userType == 'Other' && String.isBlank(userData.registrationComments)){
            return 'invalid';
        }

        if(userData.tnc == 'false'){ return 'tnctosign'; }

        String query = 'SELECT Id, Name ' +
                'FROM Account ' +
                'WHERE Name =: DummyAccountName LIMIT 1';
        
        
        List<Account> accounts = Database.query(query);
        if (!accounts.isEmpty()) {           
            userData.accountId = accounts[0].Id;
        }
       
        if (String.isBlank(userData.accountId)) { return 'Invalid-Account'; }

        if(doesUserEmailAddressAlreadyExist(userData.email)){
            return 'existing-user';
        }
        
        if(doesContactEmailAddressAlreadyExist(userData.email, userData.accountId)){
            return 'existing-contact';
        }
        else
            return createContact(userData.firstName, userData.lastName, userData.email, userData.phone, userData.companyName, 
                 userData.accountId, userData.country, userData.address1, userData.address2, userData.city, userData.state, userData.preferredLanguage, userData.userType,userData.principle,userData.designer,userData.outSales,userData.techService,userData.quotation,userData.custService,userData.admin,userData.own,userData.pm,userData.spec,userData.proc, userData.registrationComments, userData.registrationAccounts, userData.registrationRepCodes, userData.postalCode );
        
    }

    public static String createContact(String firstName, String lastName, String email, String phone, String companyName, String accountID, 
                                        String country, String address1, String address2, String city, String state, String preferredLanguage, String userType, Boolean principle,Boolean designer,Boolean outSales,Boolean techService,Boolean quotation,Boolean custService,Boolean admin,Boolean own,Boolean pm, Boolean spec, Boolean proc, String registrationComments, String registrationAccounts, String registrationRepCodes, String postalcode ) {
        
        String registrationInformation = '';
        if(userType == 'Agent'){
            registrationInformation = registrationRepCodes;
        }
        if(userType == 'Distributor'){
            registrationInformation = registrationAccounts;
        }   //Added for W-000476
        if(userType == 'Other'){
            registrationInformation = registrationAccounts;
        }                                    

        String title='';

        if(userType == 'Agent' ) {
            if(principle){
	            title='Principal';
            } else if (outSales){
	            title='Outside Sales';
            } else if (techService){
	            title='Technical Service';
            } else if (designer){
	            title='Designer';
            } else if (quotation){
	            title='Quotations';
            } else if (custService){
	            title='Customer Service';
            } else if (admin){
	            title='Administration';
            }
        } else {
            if(own){
	            title='Owner/Multi-Location Manager';
            } else if (outSales){
	            title='Outside Sales';
            } else if (pm){
	            title='Project Manager';
            } else if (spec){
	            title='Specifications';
            } else if (quotation){
	            title='Quotations';
            } else if (proc){
	            title='Procurement';
            }
        }
    
        Contact contact = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                AccountId = accountID,
                Phone = phone,
                //MobilePhone = phone,// Removed as Phone number shud be part of Phone only as part of defect W-000669 "Map phone number to "Phone" instead of Mobile on the contact record"
                MailingStreet  = address1, 
                MailingCity = city,
                MailingState = state,
                MailingCountry = country,
                MailingPostalCode = postalcode,
                Registration_Comment__c = registrationComments,
                Registration_Information__c = registrationInformation,
                Portal_User_Type__c = userType,
                Preferred_Language__c = preferredLanguage,
            	Principal__c = principle,
            	Designer__c = designer,
            	Outside_Sales__c = outSales,
            	Technical_Service__c = techService,
            	Quotations__c = quotation,
            	Customer_Service__c = custService,
            	Administration__c = admin,
            	Owner_Multi_Location_Manager__c = own,
            	Project_Manager__c = pm,
            	Specifications__c = spec,
            	Procurement__c = proc,
            	Title=title,
                Terms_Condition_Accepted_Date__c = Date.today(),
                ccrz__CompanyName__c = companyName

        );
		system.debug('contact'+contact);
        //Assign configured owner id for the newly created contact record        
        if(String.isNotBlank(b2bSettingMap.get('NewRegisteredContactOwnerId'))){
            contact.OwnerId = b2bSettingMap.get('NewRegisteredContactOwnerId');
        }

        try {
            Database.insert(contact);
        } catch (Exception e){
            return 'Exception';
        }
        return 'valid';
    }

    public static Boolean doesContactEmailAddressAlreadyExist(String emailAddress, String accountId) {
        String query = 'SELECT Id, Email FROM Contact WHERE Email = \'' + String.escapeSingleQuotes(emailAddress) + '\'';
        List<Contact> contactList = Database.query(query);
        if(contactList.size() > 0)
            return true;
        else
            return false;        
    }

    public static Boolean doesUserEmailAddressAlreadyExist(String emailAddress) {
        String query = 'SELECT Id, Name, Profile.Name FROM User WHERE Email = \'' + String.escapeSingleQuotes(emailAddress) + '\'' +
                        ' AND Profile.Name IN: ProfileNames';
                        
        List<User> userList = Database.query(query);
        if(userList.size() > 0)
            return true;
        else
            return false;        
    }

    @AuraEnabled
    public static List <String> getPrefferedLanguageSelectOptions() {
       
        List <String> allOpts = new list <String>();

        Schema.sObjectType objType = Contact.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map <String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();

        List <Schema.PicklistEntry> values =
                fieldMap.get('Preferred_Language__c').getDescribe().getPickListValues();

        for (Schema.PicklistEntry a: values) {
            if(a.getValue() != 'French'){
                allOpts.add(a.getValue());
            } else {
                System.debug('Language Dropdown - Skipping Language: '+a.getValue());
            }
        }
        allOpts.sort();
        return allOpts;
    }

        
    @AuraEnabled
    public static List <String> getCountries() {
                
        Map <String,List<String>> csMap = getCountryStates();
        List<String> countries = new List<String>(); 
        
        if(csMap != null){
            for (String country : csMap.keySet()){
                countries.add(country);
            }       
        }
        
        return countries;
    }

    @AuraEnabled
    public static List<String> getStates(String country) {
        Map <String,List<String>> csMap = getCountryStates();        
        List<String> states = new List<String>();
        if(csMap != null){
            states  = csMap.get(country);
        }
        return states;
    }


    @TestVisible 
    private static Map <String,List<String>> getCountryStates() {
        
        Map <String,List<String>> csMap = new Map <String,List<String>>();
        List<CountryState__c> CountryStateList = new List<CountryState__c>();
        CountryStateList =  [SELECT Country__c, CountryCode__c, State__c , StateCode__c FROM CountryState__c  ];

        for(CountryState__c cs : CountryStateList){
            if(csMap.containsKey(cs.Country__c)){
                List<String> ls  = csMap.get(cs.Country__c);
                ls.add(cs.State__c);
            } else {
                List<String> ls  = new List<String>();                
                ls.add(cs.State__c);
                csMap.put(cs.Country__c, ls);
            } 
        }
        
        return csMap;
    }
   
    public class UserWrapper {
        @AuraEnabled public String accountId {get; set;}
        @AuraEnabled public String firstName {get; set;}
        @AuraEnabled public String lastName {get; set;}
        @AuraEnabled public String phone { get; set; }
        @AuraEnabled public String email {get; set;}
        @AuraEnabled public String companyName {get; set;}
        @AuraEnabled public String country {get; set;}
        @AuraEnabled public String address1 {get; set;}
        @AuraEnabled public String address2 {get; set;}
        @AuraEnabled public String city {get; set;} 
        @AuraEnabled public String state {get; set;} 
        @AuraEnabled public String postalCode {get; set;} 
        @AuraEnabled public String preferredLanguage {get; set;}  
        @AuraEnabled public String userType {get; set;} 
        
         @AuraEnabled public Boolean principle {get; set;}
         @AuraEnabled public Boolean designer {get; set;} 
         @AuraEnabled public Boolean outSales {get; set;}
         @AuraEnabled public Boolean techService {get; set;} 
         @AuraEnabled public Boolean quotation {get; set;}
         @AuraEnabled public Boolean custService {get; set;} 
         @AuraEnabled public Boolean admin {get; set;}
         @AuraEnabled public Boolean own {get; set;} 
         @AuraEnabled public Boolean pm {get; set;}
         @AuraEnabled public Boolean spec {get; set;} 
         @AuraEnabled public Boolean proc {get; set;}
        
        @AuraEnabled public String registrationComments {get; set;}
        @AuraEnabled public String registrationAccounts {get; set;}
        @AuraEnabled public String registrationRepCodes {get; set;}
        @AuraEnabled public String tnc {get; set;}  
        
    }
    
}
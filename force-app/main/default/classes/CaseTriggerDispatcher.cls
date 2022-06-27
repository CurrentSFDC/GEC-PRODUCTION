/***********************************************************************************************
*   Class Name      : CaseTriggerDispatcher 
*   Date            : 5/5/2017
*   Author          : Pavan Kumar
*   Object          : Case
*   Purpose         : These methods fire on Case.
*   Test Class      : CaseTrigger_Test
**************************************************************************************************/
public class CaseTriggerDispatcher {
    public static Boolean newRecord =false;
    public static Map<String,Super_Admin_Profiles__c> Profiles_Super =Super_Admin_Profiles__c.getAll();
    
    /***********************************************************************************************
*   Method Name     : beforeUpdate
*   Old Name        : Elitenet2SFDCBeforeUpdate
*   Purpose         : to update response mins
*                     to Send EMAIL TO 'TOADDRESS'
*                     to Updating CFS RESOLUTION in CLAIM object
*   Input           : Trigger.new, Trigger.newList, Trigger.Old, Trigger.oldMap
*   Return          : N/A
**************************************************************************************************/
    public static void beforeUpdate(List<Case> newCaseList,Map<Id,Case> newCaseMap,List<Case> oldCaseList,Map<Id,Case> oldCaseMap ) {
        Id NA_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('North America').getRecordTypeId();
        /*List<Id> invoiceList = new List<Id>();
        for(case eachCase:newCaseList)  {
            if(eachCase.GE_NAS_PRO_New__c == null && eachCase.NAS_WS_Invoice__c != null && eachCase.RecordTypeID==NA_RecordType) {
                invoiceList.add(eachCase.NAS_WS_Invoice__c);
            }
        }
        Map<Id,NAS_WS_Invoice__c> invoiceMap = new Map<Id, NAS_WS_Invoice__c>([SELECT ID,NAS_WS_PRONumber__c FROM NAS_WS_Invoice__c WHERE ID in :invoiceList]);*/
        for(case eachCase:newCaseList)  {
            if(eachCase.RecordTypeID==NA_RecordType && eachCase.GE_NAS_Sub_Status__c=='cancelled')                             
                eachCase.status='cancelled';      
            if(eachCase.RecordTypeID==NA_RecordType && (eachCase.GE_NAS_Sub_Status__c=='closed'||eachCase.GE_NAS_Sub_Status__c=='Closed on First Contact'))                             
                eachCase.status='Closed';     
            /*if(eachCase.GE_NAS_PRO_New__c == null && eachCase.NAS_WS_Invoice__c != null && eachCase.RecordTypeID==NA_RecordType) {
                try {
                    eachCase.GE_NAS_PRO_New__c = invoiceMap.get(eachCase.NAS_WS_Invoice__c).NAS_WS_PRONumber__c;
                } catch(Exception ex){}
            }  */  
            if(eachCase.Type=='Cancelled Case to be Deleted' && eachCase.RecordTypeID==NA_RecordType) {                
                eachCase.status='cancelled';
                eachCase.GE_NAS_Sub_Status__c='cancelled';    
            }
            
            //CODE TO UPDATE CASE RESPONSE MINS -- START
            if((eachCase.status=='Closed' || eachCase.status=='Cancelled') && eachCase.GE_NAS_Case_Response_Mins__c == null && eachCase.RecordTypeID==NA_RecordType) {
                try {
                    if(eachCase.ClosedDate == null) {
                        if((DateTime.Now().getTime() - eachCase.CreatedDate.getTime())>60000)                    
                            eachCase.GE_NAS_Case_Response_Mins__c = Integer.valueOf((DateTime.Now().getTime() - eachCase.CreatedDate.getTime())/(1000*60));
                        else
                            eachCase.GE_NAS_Case_Response_Mins__c = 1;
                    }
                    else {
                        if((eachCase.ClosedDate.getTime() - eachCase.CreatedDate.getTime())>60000)                    
                            eachCase.GE_NAS_Case_Response_Mins__c = Integer.valueOf((eachCase.ClosedDate.getTime() - eachCase.CreatedDate.getTime())/(1000*60));
                        else
                            eachCase.GE_NAS_Case_Response_Mins__c = 1;
                    }
                }
                catch (Exception ex) {
                    eachCase.GE_NAS_Case_Response_Mins__c = 0;
                }
            }
            //CODE TO UPDATE CASE RESPONSE MINS -- END
        }
        // CODE TO SEND EMAIL TO 'TOADDRESS' FIELD TO PERSONAL OUTLOOK  -- START
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Map<String,String> mapPersonalEmails = new Map<String,String>();
        for(GE_NAS_CaseRoutingePersonalEmails__c each :[SELECT GE_NAS_Case_Routing_Email__c,GE_NAS_Personal_Email__c FROM GE_NAS_CaseRoutingePersonalEmails__c WHERE GE_NAS_Active__c = true]) {
            mapPersonalEmails.put(each.GE_NAS_Case_Routing_Email__c,each.GE_NAS_Personal_Email__c);
        }
        for(integer i=0; i<newCaseList.size(); i++){
            try {
                if(newCaseList[i].SuppliedEmail != null) {
                    if(newCaseList[i].GE_NAS_ToAddress__c !=oldCaseList[i].GE_NAS_ToAddress__c) {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        if(mapPersonalEmails.containsKey(newCaseList[i].GE_NAS_ToAddress__c)) {
                            List<String> toAddressArray = mapPersonalEmails.get(newCaseList[i].GE_NAS_ToAddress__c).split(';');
                            mail.setToAddresses(toAddressArray);
                            mail.setReplyTo(newCaseList[i].SuppliedEmail);
                            mail.setSubject('Case # ' + newCaseList[i].CaseNumber + ' has been created');
                            mail.setBccSender(false);
                            mail.setUseSignature(false);
                            if(newCaseList[i].GE_NAS_EmailDescription__c == null)
                                mail.setHtmlBody('New Case # ' + newCaseList[i].CaseNumber + ' has been created. click to veiw Case details ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + newCaseList[i].Id + '<br></br>' + newCaseList[i].description);
                            else
                                mail.setHtmlBody('New Case # ' + newCaseList[i].CaseNumber + ' has been created. click to veiw Case details ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + newCaseList[i].Id + '<br></br>' + newCaseList[i].GE_NAS_EmailDescription__c);
                            mails.add(mail);
                        }
                    }
                }
            } catch(Exception ex){}
        }
        if (mails.size() > 0) {
            Messaging.sendEmail(mails);
        }
        // CODE TO SEND EMAIL TO 'TOADDRESS' FIELD TO PERSONAL OUTLOOK  -- END
        
        //FOR UPDATING CFS RESOLUTION IN CLAIM OBJECT ---START
        try {
            List<GE_NAS_Claim__c> lstClm;
            Map<String,String> claimResolutionMap = new Map<String,String>();
            for(Case eachCase :newCaseList) {
                if(eachCase.Type == 'Claim' && eachCase.RecordTypeID==NA_RecordType)
                    claimResolutionMap.put(eachCase.GE_NAS_Claim__c,eachCase.GE_NAS_CFS_Resolution__c);
            }
            lstClm = [SELECT ID,GE_NAS_Claim_Number__c,GE_NAS_CFS_Resolution__c,GE_NAS_DevComments__c from GE_NAS_Claim__c where GE_NAS_Claim_Number__c in :claimResolutionMap.KeySet()];
            for(GE_NAS_Claim__c cl :lstClm) {
                cl.GE_NAS_CFS_Resolution__c=claimResolutionMap.get(cl.GE_NAS_Claim_Number__c);
                cl.GE_NAS_DevComments__c = 'fromCase';
            }
            update lstClm ;
        } catch (Exception ex) {}
        //FOR UPDATING CFS RESOLUTION IN CLAIM OBJECT ---END
        Set<String> accountNumberSet = new Set<String>();
        Map<String,ID> accountNumberIdMap = new Map<String,ID>();
        for (Case cs:newCaseList)     {
            if(cs.GE_NAS_AccountNo__c!=null){
                accountNumberSet.add(cs.GE_NAS_AccountNo__c);
            }
        }
        if(accountNumberSet.size()>0) {
            for(account acc :[SELECT ID,GE_NAS_AccountNo__c,GE_NAS_NCSC_Component_Code__c FROM ACCOUNT WHERE GE_NAS_AccountNo__c != NULL AND GE_NAS_AccountNo__c IN :accountNumberSet])        {
                accountNumberIdMap.put(acc.GE_NAS_AccountNo__c,acc.ID);
            }
        }
        for(Case newCase: newCaseList) {
            try{
                if(newCase.GE_NAS_AccountNo__c!=null){
                    newCase.AccountID = accountNumberIdMap.get(newCase.GE_NAS_AccountNo__c);
                    newCase.Priority = 'Medium';
                }
            }
            catch(Exception e){
                system.debug(e.getmessage());
            }
        }
    }
    
    /***********************************************************************************************
*   Method Name     : beforeInsert
*   Old Name        : Elitenet2SFDCBeforeInsert
*   Purpose         : change account Id, status
*                     and updata some of the fields in case using data in field 'GE_NAS_EmailDescription__c'
*   Input           : Trigger.new
*   Return          : N/A
**************************************************************************************************/
    public static void beforeInsert(List<Case> newCaseList){
        system.debug('@@Initial line 151');
        
        Id LightGrid_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GE LGT LightGrid Support').getRecordTypeId();
        Id Contact_RecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('NA Service Contact').getRecordTypeId();
        Id NA_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('North America').getRecordTypeId();
        List<Contact> RGA_Contact =[SELECT ID FROM Contact WHERE GE_LGT_Row_Id__c='1-JR6HG4' LIMIT 1];
        //ID RGA_ContactId =[SELECT ID FROM Contact WHERE GE_LGT_Row_Id__c='1-JR6HG4' LIMIT 1].ID;
        
        Map<String,String> accountNumberIdMap = new Map<String,String>();
        map<string,string> accountNumberCodeMap = new Map<string, string>();
        Set<String> accountNumberSet = new Set<String>();
        List<String> invoiceIds = new List<string>();
        List<String> contactIds = new List<String>();
        List<String> emailList = new List<String>();
        List<String> accountNumbers = new List<string>();
        List<String> shippingDiscrepancyAccNumbers = new List<string>();
        
        for (Case eachCase:newCaseList) {
            
             system.debug('@@ line 170');
            
            if(eachCase.GE_NAS_AccountNo__c!=null){
                accountNumberSet.add(eachCase.GE_NAS_AccountNo__c);
            }   
            //invoiceIds.add(eachCase.NAS_WS_Invoice__c);
            contactIds.add(eachCase.ContactId);
            system.debug('@@ line 177'+eachCase.Origin+' '+eachCase.RecordTypeID+' ' +eachCase.parentid+' '+NA_RecordType);
            if(eachCase.Origin=='Email' && eachCase.RecordTypeID==NA_RecordType && eachCase.parentid==null) {
                system.debug('@@line 179');
                if(eachCase.Subject!=null) {
                    if(eachCase.Subject.Contains('Request Proof of Delivery(POD)')) {
                        if (eachCase.Description.Contains('E-mail')){
                            string tempemail=eachCase.Description.substringBetween('E-mail','\n');
                            emailList.add(tempemail.substringAfter(':'));
                            accountNumbers.add(eachCase.Description.substringBetween('Account','\n').trim());
                        }
                    }
                    if(eachCase.Subject.Contains('SHIPPING DISCREPANCY')) {
                        eachCase.GE_NAS_EmailDescription__c = eachCase.description;
                        if (eachCase.GE_NAS_EmailDescription__c.Contains('Email')){
                            string tempemail=eachCase.GE_NAS_EmailDescription__c.substringBetween('Email','\n');
                            emailList.add(tempemail.substringAfter(':').trim());
                            System.debug('EMailfrombody--'+emailList);
                            shippingDiscrepancyAccNumbers.add(eachCase.Description.substringBetween('Account','-').trim());
                            System.debug('shippingDiscrepancyAccNumbers--' +shippingDiscrepancyAccNumbers);
                            }
                    }
                    if((eachCase.Subject.Contains(CaseConstants.BILLING_ADJUSTMENT))||(eachCase.Subject.Contains('BILLING ADJUSTMENT')) ||
                    (eachCase.Subject.Contains(CaseConstants.ELIGHT_RETURNS))) {
                    System.debug('description--' +eachCase.description);
                        eachCase.GE_NAS_EmailDescription__c = eachCase.description;
                        System.debug('eachCase.GE_NAS_EmailDescription__c --' +eachCase.GE_NAS_EmailDescription__c );
                        if (eachCase.GE_NAS_EmailDescription__c.Contains('Contact Emai:')){
                        System.debug('test--');
                            string tempemail=eachCase.GE_NAS_EmailDescription__c.substringBetween('Contact Emai','\n');
                            System.debug('tempemail--' +tempemail);
                            emailList.add(tempemail.substringAfter(':').trim());
                            System.debug('EMailfrombody--'+emailList);
                            System.debug('accountNumbers--' +accountNumbers);
                                String s1 = eachCase.Description.substringBetween('Sold To:','-').trim();
                                String regExp = '[a-zA-Z-,.#&]';
                                String replacement = '';
                                String s2 = s1.replaceAll(regExp, replacement);
                                accountNumbers.add(s2.trim());
                                System.debug('accountNumbers--' +accountNumbers);
                        }
                    }           
                    if((eachCase.Subject.Contains(CaseConstants.STOCKBALANCING_CLAIM))) {
                        eachCase.GE_NAS_EmailDescription__c = eachCase.description;
                        if(eachCase.GE_NAS_EmailDescription__c.Contains('<mailto:')){
                             string tempemail=eachCase.GE_NAS_EmailDescription__c.substringBetween('Contact Email','<mailto:');
                            emailList.add(tempemail.substringAfter(':').trim());
                            System.debug('EMailfrombody--'+emailList);
                                String s1 = eachCase.Description.substringBetween('Sold To:','-').trim();   //MG - Changed to select between Sold To and '-'
                                String regExp = '[a-zA-Z-]';
                                String replacement = '';
                                String s2 = s1.replaceAll(regExp, replacement);
                                accountNumbers.add(s2.trim());
                                System.debug('accountNumbers--' +accountNumbers);
                               
                        }
                        else if (eachCase.GE_NAS_EmailDescription__c.Contains('Contact Email')){
                            string tempemail=eachCase.GE_NAS_EmailDescription__c.substringBetween('Contact Email','\n');
                            emailList.add(tempemail.substringAfter(':').trim());
                            System.debug('EMailfrombody--'+emailList);
                            String s1 = eachCase.Description.substringBetween('Sold To:','-').trim();
                                String regExp = '[a-zA-Z-]';
                                String replacement = '';
                                String s2 = s1.replaceAll(regExp, replacement);
                                accountNumbers.add(s2.trim());
                                System.debug('accountNumbers--' +accountNumbers);
                        }
                    }
                }
            }
        }
        
        
        //not used bulk operations below because there is no unique field to identify in before insert and these cases comes one at a time from email to case
        
        system.debug('shippingDiscrepancyAccNumbers'+shippingDiscrepancyAccNumbers);
        Account[] accID1 = [SELECT Id FROM Account WHERE GE_LGT_EM_SAP_Customer_Number__c IN :shippingDiscrepancyAccNumbers];
        system.debug('accID1'+accID1);
        Contact[] con1 = [SELECT Id FROM contact WHERE email IN :emailList];
        system.debug('con1'+con1);
        for (Case eachCase:newCaseList) {
            system.debug('eachCase'+eachCase);
            if(accID1.size() > 0){
                system.debug('accID1[0].Id'+accID1[0].Id);  //As these type of cases creates only from email to case one at a time.
                eachcase.AccountId = accID1[0].Id; //assign the retrieved accountId from the List above. 
            }
            if(con1.size() > 0){
                system.debug('con1[0].Id'+con1[0].Id);  //As these type of cases creates only from email to case one at a time.
                eachcase.ContactId = con1[0].Id; //assign the retrieved accountId from the List above. 
            }
        }
        
        
        
        // Map<Id, NAS_WS_Invoice__c> invoiceMap = new Map<Id, NAS_WS_Invoice__c>([SELECT ID,NAS_WS_PRONumber__c FROM NAS_WS_Invoice__c WHERE ID in :invoiceIds]);
        Map<Id, Contact> contactMap = new Map<Id, Contact>([Select Id, RecordTypeId from Contact where Id in :contactIds]);
        NAServiceDummyContact__c dummyContact = NAServiceDummyContact__c.getOrgDefaults();
        
        if(accountNumberSet.size()>0) {
         
            
            
            for(account acc :[SELECT ID,GE_NAS_AccountNo__c,GE_NAS_NCSC_Component_Code__c FROM ACCOUNT WHERE GE_NAS_AccountNo__c != NULL AND GE_NAS_AccountNo__c IN :accountNumberSet])        {
                accountNumberIdMap.put(acc.GE_NAS_AccountNo__c,acc.ID);
                accountNumberCodeMap.put(acc.GE_NAS_AccountNo__c,acc.GE_NAS_NCSC_Component_Code__c);
            }
        }
        List<String> EmailContains = new List<String>();
        
        for (case cs:newCaseList) {
            if (cs.Origin !=null) {
                if (cs.GE_NAS_CloneCasenumber__c == null && cs.Origin.Contains('Email -') && (cs.RecordTypeID == NA_RecordType || cs.RecordTypeID == LightGrid_RecordType)) {
                    if (cs.ContactId == null) {
                        EmailContains.add(cs.SuppliedEmail);
                    } else {
                        if (!contactMap.isEmpty()&& contactMap.containsKey(cs.ContactId)){
                            Id tempId =contactMap.get(cs.ContactId).RecordTypeID;
                            if (Contact_RecordType != tempId) {
                                EmailContains.add(cs.SuppliedEmail);
                            }
                        }
                    }
                }
            }
        }
        List<Contact> containsMap = [Select Id,Email,accountid From Contact Where RecordTypeId = :Contact_RecordType and Email in:EmailContains and Email!=null order by accountid desc];
        List<Contact> contactList = [Select Id,Email,Name, Account.AccountNumber From Contact Where RecordTypeId = :Contact_RecordType and Email in :emailList and Account.AccountNumber in:accountNumbers];
        Map<string,Contact> EmailContainsMap = new Map<string, Contact>();
        for (Contact c :containsMap) {
            if (!EmailContainsMap.containskey(c.Email)){
                EmailContainsMap.put(c.Email, c);
            }
        }
        Map<String, Map<string, Contact>> emailAccountNumberMap = new Map<String, Map<String, Contact>>();
        for (Contact c : contactList) {
            if (!emailAccountNumberMap.containskey(c.Email)) {
                Map<string, Contact> tempMap = new Map<string, Contact>();
                tempMap.put(c.Account.AccountNumber, c);
                emailAccountNumberMap.put(c.Email, tempMap);
                System.debug('emailAccountNumberMap--' +c.Email);
            }
            else {
                emailAccountNumberMap.get(c.Email).put(c.account.AccountNumber,c);
            }
        }
        for(case eachCase:newCaseList) {
            if(eachCase.RecordTypeID==NA_RecordType && eachCase.GE_NAS_CloneCasenumber__c!=null) {           
                eachCase.status='Open';
                eachCase.GE_NAS_Sub_Status__c='In Process';
                eachCase.GE_NAS_NCSC_Resolution__c='In Progress';     //      
            }
            if(eachCase.RecordTypeID==NA_RecordType && eachCase.GE_NAS_CloneCasenumber__c==null && eachCase.GE_NAS_Sub_Status__c=='cancelled')                             
                eachCase.status='cancelled';      
            if(eachCase.RecordTypeID==NA_RecordType && eachCase.GE_NAS_CloneCasenumber__c==null && (eachCase.GE_NAS_Sub_Status__c=='closed'||eachCase.GE_NAS_Sub_Status__c=='Closed on First Contact'))                             
                eachCase.status='Closed';     
            if(eachCase.Type=='Cancelled Case to be Deleted' && eachCase.GE_NAS_CloneCasenumber__c==null && eachCase.RecordTypeID==NA_RecordType) {               
                eachCase.status='cancelled';
                eachCase.GE_NAS_Sub_Status__c='cancelled';
            }   
            /*if(eachCase.GE_NAS_PRO_New__c == null && eachCase.NAS_WS_Invoice__c != null && eachCase.RecordTypeID==NA_RecordType) {
                try {
                    eachCase.GE_NAS_PRO_New__c = invoiceMap.get(eachCase.NAS_WS_Invoice__c).NAS_WS_PRONumber__c;
                } catch(Exception ex){}
            } */
            if(eachCase.Origin!=null) {
                if(eachCase.Origin.contains('Email -') && (eachCase.RecordTypeID==NA_RecordType ||eachCase.RecordTypeID==LightGrid_RecordType) && eachCase.GE_NAS_CloneCasenumber__c==null)    {
                    if(eachCase.contactid!=null) {
                        Id tempId = contactMap.get(eachCase.ContactId).RecordTypeId;
                        if(tempId != Contact_RecordType) {                              
                            eachCase.AccountId = null;
                            eachCase.contactid = null;
                        }
                    }
                    else {
                        eachCase.AccountId = null;
                        eachCase.contactid = null;
                    }
                    if(EmailContainsMap.size() !=0 && EmailContainsMap.containskey(eachCase.SuppliedEmail)) {                          
                        eachCase.AccountId = EmailContainsMap.get(eachCase.SuppliedEmail).accountid;
                        eachCase.contactid = EmailContainsMap.get(eachCase.SuppliedEmail).Id;
                    } else {
                        //If Case Origin is Email - Tech and there are no contacts found, set contact and account to End User and Dummy Account
                        if(eachCase.Origin == 'Email - Tech') {
                            eachCase.AccountID=dummyContact.AccountId__c;
                            eachCase.ContactID = dummyContact.ContactId__c;
                        }
                    }
                    eachCase.GE_NAS_EmailDescription__c = eachCase.description;  
                    system.debug('First Occurrence at 355');                    
                    eachCase.description='';                       
                }
                if(eachCase.Origin=='Email' && eachCase.RecordTypeID==NA_RecordType && eachCase.parentid==null) {
                    if(eachCase.Subject!=null){
                        string sub=eachCase.Subject;
                        string str1='Request Proof of Delivery(POD)'; 
                        string str2='SHIPPING DISCREPANCY';  
                        string str3='Billing Adjustment';
                        string str33='BILLING ADJUSTMENT';  //added RQT-0001073
                        string str4='Stockbalancing claim'; //added RQT-0001056
                        string str5=CaseConstants.ELIGHT_RETURNS;
                        string accNumber = '';
                        if(sub.Contains(str1)){
                            eachCase.GE_NAS_EmailDescription__c = eachCase.description;
                            system.debug('second Occurrence at 370');
                            //eachCase.description='';
                            string str= eachCase.GE_NAS_EmailDescription__c;  
                            if(str.contains('Account')) {
                                accNumber = str.substringBetween('Account','\n').trim();
                            }
                            if(str.contains('Contact'))               {
                                string tempcon=str.substringBetween('Contact','\n');
                                string con=tempcon.substringAfter(':');
                            }
                            if(str.contains('E-mail'))               {
                                string tempemail=str.substringBetween('E-mail','\n');
                                string email=tempemail.substringAfter(':');
                                Set<String> emailAddresses= new Set<String>(); 
                                if(eachCase.contactid==null)  
                                    emailAddresses.add(email);    
                                if (emailAccountNumberMap.containsKey(email)) {
                                    Map<string, Contact> tempMap = new Map<string, Contact>();
                                    tempMap = emailAccountNumberMap.get(email);
                                    if (tempMap.containsKey(accNumber)){
                                        eachCase.contactID=tempMap.get(accNumber).id;
                                        if(eachCase.SuppliedEmail.contains('rs-elitenetrap@ge.com')) {
                                            eachCase.SuppliedEmail = email;
                                        }
                                    }
                                }
                            }
                            if(str.contains('Invoice#'))               {
                                string tempinv=str.substringBetween('Invoice#','\n');
                                string inv=tempinv.substringAfter(':');
                                eachCase.GE_NAS_Invoice__c=inv;
                            }
                            if(str.contains('PO#'))               {
                                string temppo=str.substringBetween('PO#','\n');
                                string po=temppo.substringAfter(':');
                                eachCase.GE_NAS_Purchase_Order__c=po;
                            }
                            if(str.contains('Comments'))               {
                                try {
                                    eachCase.description=str.substringAfter('Comments:');
                                } catch(exception ex){}
                            }
                            if(str.contains('PickTicket#'))               {
                                string temppckt=str.substringBetween('PickTicket#','\n');
                                string pckt=temppckt.substringAfter(':');
                                eachCase.GE_NAS_Pick_Ticket__c=pckt;
                            }
                            eachCase.Type='Request for Documentation';
                            eachCase.GE_NAS_Sub_Type__c='POD';
                            eachCase.Origin = 'Web';
                        } else if(sub.Contains(str2)) {
                            eachCase.GE_NAS_EmailDescription__c = eachCase.description;
                            system.debug('third Occurrence at 421');
                            //eachCase.description='';
                            string str= eachCase.GE_NAS_EmailDescription__c;
                            if(str.contains('Account')) {
                                accNumber = str.substringBetween('Account','\n').trim();
                            }
                            if(str.contains('Phone'))               {
                                string tempPhone=str.substringBetween('Phone','\n');
                                string ePhone=tempPhone.substringAfter(':');
                                eachcase.eLight_Requestor_Phone__c=ePhone;
                            }
                            if(str.contains('Fax'))               {
                                string tempFax=str.substringBetween('Fax','\n');
                                string eFax=tempFax.substringAfter(':');
                                eachcase.GE_LGT_EM_Fax_Number__c=eFax;
                            }
                            if(str.contains('Email'))               {
                                string tempemail=str.substringBetween('Email','\n');
                                string email=tempemail.substringAfter(':').trim();
                                System.debug('email--'+email);
                                eachCase.SuppliedEmail = email;
                                Set<String> emailAddresses= new Set<String>(); 
                                if(eachCase.contactid==null)  
                                    emailAddresses.add(email);    
                                if (emailAccountNumberMap.containsKey(email)) {
                                    Map<string, Contact> tempMap = new Map<string, Contact>();
                                    tempMap = emailAccountNumberMap.get(email);
                                    if (tempMap.containsKey(accNumber)){
                                        eachCase.contactID=tempMap.get(accNumber).id;
                                        System.debug('contactname--'+ eachCase.contactID );
                                        //if(eachCase.SuppliedEmail.contains('rs-elitenetrap@ge.com')) {
                                          //  eachCase.SuppliedEmail = email;
                                        //}
                                    }
                                }
                            }
                            if(str.contains('Invoice#'))               {
                                string tempinv=str.substringBetween('Invoice#','\n');
                                string inv=tempinv.substringAfter(':');
                                eachCase.GE_NAS_Invoice__c=inv;
                            }
                            if(str.contains('PO#'))               {
                                string temppo=str.substringBetween('PO#','\n');
                                string po=temppo.substringAfter(':');
                                eachCase.GE_NAS_Purchase_Order__c=po;
                            }
                            if(str.contains('Comments'))               {
                                try {
                                    eachCase.eLight_Comments__c=str.substringBetween('Comments:', '\n');
                                } catch(exception ex){}
                            }
                            if(str.contains('PickTicket#'))               {
                                string temppckt=str.substringBetween('PickTicket#','\n');
                                string pckt=temppckt.substringAfter(':');
                                eachCase.GE_NAS_Pick_Ticket__c=pckt;
                            }  
                            if(str.contains('BOL#'))               {
                                string tempBol=str.substringBetween('BOL#','\n');
                                string Bol=tempBol.substringAfter(':');
                                eachCase.GE_NAS_Bill_of_Lading__c=Bol;
                            }  
                            if(str.contains('Confirmation#'))               {
                                string tempconfirm=str.substringBetween('Confirmation#','\n');
                                string confirmationno=tempconfirm.substringAfter(':');
                                eachCase.GE_NAS_Confirmation__c=confirmationno;
                            }  
                            //eachCase.GE_NAS_Bill_of_Lading__c='00000';
                             
                                     eachCase.Type='Shipping';
                                    eachCase.GE_NAS_Sub_Type__c='Lost/Damaged';
                                
                            eachCase.RecordTypeid=NA_RecordType;
                            eachCase.Origin = 'Web';
                        }
                        else if((sub.Contains(str3)) ||(sub.Contains(str33)) ||(sub.Contains(str5)) ){//BILLING ADJUSTMENT
                            system.debug('@@line 497');
                             eachCase.GE_NAS_EmailDescription__c = eachCase.description;
                             system.debug('fourth Occurrence at 498');
                            //eachCase.description='';
                            string str= eachCase.GE_NAS_EmailDescription__c;
                           if(str.contains('Sold To:')) {
                                
                                String s1 = str.substringBetween('Sold To:','-').trim();
                                String regExp = '[a-zA-Z-]';
                                String replacement = '';
                                String s2 = s1.replaceAll(regExp, replacement);
                                accNumber = s2.trim();
                                 eachcase.eLight_Sold_To__c=accNumber;
                                 system.debug('accountNumbers'+accountNumbers);
                                 //Account[] accID = [SELECT Id,GE_LGT_EM_SAP_Customer_Number__c FROM Account where id='0013j00002dOVFx'];                  
                                Account[] accID = [SELECT Id FROM Account WHERE GE_LGT_EM_SAP_Customer_Number__c IN :accountNumbers];
                                system.debug('accIDsize'+accID.size());
                                system.debug('accID'+accID);
                                  if(accID.size() > 0){
                                      system.debug('accID[0].Id'+accID[0].Id);
                                eachcase.AccountId = accID[0].Id; //assign the retrieved accountId from the List above. 
                                system.debug('eachcase'+eachcase);
                                  }
                               
                            }
                            if(str.contains('Contact'))               {
                                string tempcon=str.substringBetween('Contact','\n');
                                string con=tempcon.substringAfter(':');
                            }
                           if(str.contains('Contact Emai:')){
                                string tempemail=str.substringBetween('Contact Emai','\n');
                                string email=tempemail.substringAfter(':');
                                eachCase.SuppliedEmail = email;
                                Set<String> emailAddresses= new Set<String>(); 
                                if(eachCase.contactid==null)  
                                    emailAddresses.add(email);    
                                if (emailAccountNumberMap.containsKey(email)) {
                                    Map<string, Contact> tempMap = new Map<string, Contact>();
                                    tempMap = emailAccountNumberMap.get(email);
                                    if (tempMap.containsKey(accNumber)){
                                        eachCase.contactID=tempMap.get(accNumber).id;
                                        //if(eachCase.SuppliedEmail.contains('rs-elitenetrap@ge.com')) {
                                         //   eachCase.SuppliedEmail = email;
                                        //}
                                    }
                                }
                            }
                            if(str.contains('Invoice Number'))               {
                                string tempinv=str.substringBetween('Invoice Number','\n');
                                //string inv=tempinv.substringAfter(':');
                                eachCase.GE_NAS_Invoice__c=tempinv;
                            }
                             if(str.contains('Return Processing Information:'))               {
                                string tempinv=str.substringBetween('Return Processing Information:','\n');
                                //string inv=tempinv.substringAfter(':');
                                eachCase.elight_Return_Processing_Information__c=tempinv;
                            }
                            if(str.contains('PO Number:'))               {
                                string temppo=str.substringBetween('PO Number','\n');
                                string po=temppo.substringAfter(':');
                                eachCase.GE_NAS_Purchase_Order__c=po;
                            }
                            if(str.contains('Comment'))               {
                                try {
                                    eachCase.eLight_Comments__c=str.substringBetween('Comment:','\n');
                                } catch(exception ex){}
                            }
                            if(str.contains('Contact Phone Number'))               {
                                string temppckt=str.substringBetween('Contact Phone Number','\n');
                                string pckt=temppckt.substringAfter(':');
                                eachCase.eLight_Requestor_Phone__c=pckt;
                            }  
                            
                            if(str.contains('Price Agreement:'))               {
                                string temppckt=str.substringBetween('Price Agreement','\n');
                                string pckt=temppckt.substringAfter(':');
                                eachCase.eLight_Price_Agreement__c=pckt;
                            } 
                            
                            if(str.contains('Sales Order Number'))               {
                                string tempBol=str.substringBetween('Sales Order Number','\n');
                                string Bol=tempBol.substringAfter(':');
                                eachCase.Sales_order_number__c=Bol;
                            }  
                           if(str.contains('Reason for Return Request:'))               {
                                string tempconfirm=str.substringBetween('Reason for Return Request','\n');
                                string confirmationno=tempconfirm.substringAfter(':');
                                eachCase.eLight_Reason_for_Return__c=confirmationno;
                            }  
                            //eachCase.GE_NAS_Bill_of_Lading__c='00000';
                            eachCase.Type='Pricing';
                            eachCase.GE_NAS_Sub_Type__c='Credits/Debits';    
                            eachCase.RecordTypeid=NA_RecordType;
                            eachCase.Origin = 'Web'; 
                            if(sub.Contains(str5)){
                                string opptyId=str.substringBetween('Opportunity ID/Project Name','\n');
                                string GEOpptyId=opptyId.substringAfter(':');
                                eachCase.eLight_Opportunity_ID__c=GEOpptyId;
                                
                                string hybris=str.substringBetween('Hybris ID','\n');
                                string hybrisId=hybris.substringAfter(':');
                                eachCase.HybrisID__c=hybrisId;
                                
                                eachCase.Type='Returns';
                                eachCase.GE_NAS_Sub_Type__c='New RGA';
                                eachCase.eLight_Form_Type__c ='Return';
                                //eachCase.Origin = 'Phone';
                                eachCase.Origin = CaseConstants.ELIGHT_ORIGIN;
                            }
                        
                        }
                        else if(sub.Contains(str4)){
                            
                            //MG - LIST ACCOUNT ID where the SAP Cust Number is in the accountNumbers List 

                             eachCase.GE_NAS_EmailDescription__c = eachCase.description;
                            //eachCase.description='';
                            string str= eachCase.GE_NAS_EmailDescription__c;
                            //string str=eachCase.Subject;
                              if(str.contains('Sold To:')) {
                                  
                                String s1 = str.substringBetween('Sold To:','-').trim();
 
                                String regExp = '[-.*]';
                                String replacement = '';
                                  
                                String s2 = s1.replaceAll(regExp, replacement);
                                accNumber = s2.trim();
                                eachcase.eLight_Sold_To__c=accNumber;
                                Account[] accID = [SELECT Id FROM Account WHERE GE_LGT_EM_SAP_Customer_Number__c IN :accountNumbers];
                                  if(accID.size() > 0){
                                eachcase.AccountId = accID[0].Id; //assign the retrieved accountId from the List above. 
                                  }
                            }
                            
                            if( str.contains('<mailto:'))
                            {
                                 string tempemail=str.substringBetween('Contact Email','<mailto:');
                                string email=tempemail.substringAfter(':').trim();
                                eachcase.SuppliedEmail=email;
                                Set<String> emailAddresses= new Set<String>(); 
                                if(eachCase.contactid==null)  
                                    emailAddresses.add(email);    
                                if (emailAccountNumberMap.containsKey(email)) {
                                    Map<string, Contact> tempMap = new Map<string, Contact>();
                                    tempMap = emailAccountNumberMap.get(email);
                                    if (tempMap.containsKey(accNumber)){
                                        eachCase.contactID=tempMap.get(accNumber).id;
                                        //if(eachCase.SuppliedEmail.contains('rs-elitenetrap@ge.com')) {
                                           // eachCase.SuppliedEmail = email;
                                       // }
                                    }
                                }
                            }
                            else if(str.contains('Contact Email:'))               {
                                string tempemail=str.substringBetween('Contact Email','\n');
                                string email=tempemail.substringAfter(':').trim();
                                eachcase.SuppliedEmail=email;
                                System.debug('email no htmal==' +email);
                                Set<String> emailAddresses= new Set<String>(); 
                                if(eachCase.contactid==null)  
                                    emailAddresses.add(email);    
                                if (emailAccountNumberMap.containsKey(email)) {
                                    Map<string, Contact> tempMap = new Map<string, Contact>();
                                    tempMap = emailAccountNumberMap.get(email);
                                    if (tempMap.containsKey(accNumber)){
                                        eachCase.contactID=tempMap.get(accNumber).id;
                                        //if(eachCase.SuppliedEmail.contains('rs-elitenetrap@ge.com')) {
                                           // eachCase.SuppliedEmail = email;
                                       // }
                                    }
                                }
                            }
                            
                            if(str.contains('Total Extended Credit Price:')) {
                                System.debug('YEs credit price is there in mail');
                                string tempcredit=str.substringBetween('Credit Price:', '\n').trim();
                                double returnvalue=0.0;
                                if (tempcredit!='') 
                                    returnvalue=Decimal.valueOf(tempcredit);                           
                                else
                                    returnvalue=0.0;
                                
                                eachcase.eLight_Return_Total_Amount__c=returnvalue;
                                
                                System.debug('Total Extended Credit Price=='+tempcredit+'=='+eachcase.eLight_Return_Total_Amount__c);
                            
                                }
                             if(str.contains('Request Transaction Number:'))    {
                                System.debug('Request Transaction Number:');
                                string tempcredit=str.substringBetween('Request Transaction Number','\n');
                                string Extprice=tempcredit.substringAfter(':');
                                //eachcase.Sales_Order_Number__c=Extprice; AA change on 10/18
                                eachcase.GE_NAS_Purchase_Order__c=Extprice;
                                    //System.debug('Extended price=='+tempcredit+'=='+eachcase.eLight_Return_Total_Amount__c);
                            
                                    }
                             if(str.contains('Hybris ID:'))    {
                                System.debug('Hybris ID::');
                                string HybrisID=str.substringBetween('Hybris ID:','\n').trim();
                                //string SalesOrderNo=HybrisID.substringAfter(':');
                                eachcase.HybrisID__c=HybrisID;
                                    System.debug('Sales_Order_Number__c=='+HybrisID+'=='+eachcase.Sales_Order_Number__c);
                            
                                   }
                                   if(str.contains('Comment'))               {
                                try {
                                    eachCase.eLight_Comments__c=str.substringBetween('Comment:','\n');
                                } catch(exception ex){}
                            }
                             if(str.contains('Reason for Return Request:'))    {
                                //System.debug('Reason for Return Request::');
                                string RetrunReason=str.substringBetween('Reason for Return Request:','\n').trim();
                                //string SalesOrderNo=HybrisID.substringAfter(':');
                                eachcase.eLight_Reason_for_Return__c=RetrunReason;
                                    System.debug('Reason for Return Request::=='+RetrunReason+'=='+eachcase.eLight_Reason_for_Return__c);
                            
                                   }
                                    if(str.contains('Price Agreement:'))               {
                                string temppckt=str.substringBetween('Price Agreement','\n');
                                string pckt=temppckt.substringAfter(':');
                                eachCase.eLight_Price_Agreement__c=pckt;
                            } 
                             if(str.contains('Contact Phone Number'))               {
                                string temppckt=str.substringBetween('Contact Phone Number','\n');
                                string pckt=temppckt.substringAfter(':');
                                eachCase.eLight_Requestor_Phone__c=pckt;
                            }  
                            if(str.contains('Return Processing Information:'))    {
                                System.debug('Return Processing Information::');
                                string RetrunProcess=str.substringBetween('Return Processing Information:','\n').trim();
                                //string SalesOrderNo=HybrisID.substringAfter(':');
                                eachcase.eLight_Return_Processing_Information__c=RetrunProcess;
                                    System.debug('Reason for Return Request::=='+RetrunProcess+'=='+eachcase.eLight_Return_Processing_Information__c);
                            
                                   }
                                //eachCase.GE_NAS_Bill_of_Lading__c='00000';
                                eachCase.Type='Return';
                                eachCase.GE_NAS_Sub_Type__c='New RGA';    
                                eachCase.RecordTypeid=NA_RecordType;
                                eachCase.Origin = 'elight Core Returns';
                        
                        }
                         /*else if(sub.Contains(str5)){
                             eachCase.GE_NAS_EmailDescription__c = eachCase.description;
                             string str= eachCase.GE_NAS_EmailDescription__c;
                            if(str.contains('E-mail'))               {
                                string tempemail=str.substringBetween('E-mail','\n');
                                string email=tempemail.substringAfter(':').trim();
                                    if(eachCase.SuppliedEmail !=null) {
                                            eachCase.SuppliedEmail = email;
                                        }
                                        eachCase.Origin = 'eLight';
                            }           
                        }*/
                    }
                }
            
                
            }
            if(eachCase.GE_NAS_AccountNo__c!=null){
                eachCase.AccountID = accountNumberIdMap.get(eachCase.GE_NAS_AccountNo__c);
                if (RGA_Contact != null) {
                    eachCase.ContactID = RGA_Contact[0].Id;
                }
                eachCase.Subject = 'Batch RGA #'+eachCase.GE_NAS_SR_Number__c;
                eachCase.Type = 'Returns';
                eachCase.Status = 'Open';
                eachCase.Origin='RGA';
                eachCase.GE_NAS_Sub_Status__c='In Process';  
                eachCase.Priority = 'Medium';
                eachCase.RecordTypeid = NA_RecordType;
                eachCase.GE_NAS_Sub_Type__c = 'PR Status';
                If(NAService_AcctNumGroupMap__c.getInstance(accountNumberCodeMap.get(eachCase.GE_NAS_AccountNo__c)) != null){
                    eachCase.OwnerId = NAService_AcctNumGroupMap__c.getInstance(accountNumberCodeMap.get(eachCase.GE_NAS_AccountNo__c)).Group_Id__c;
                }
                
            }
        }
        
        CaseTriggerDispatcher ctd= new CaseTriggerDispatcher();
       
            ctd.setCaseSubType(newCaseList);
        
    }
    /***********************************************************************************************
*   Method Name     : parseEmailtoCase
*   Purpose         : Parsing the incoming email and check the orgin and record type, based on the it will
*                     load the Case fields with Email body (parsing delimeter is "|^")
*   Input           : Trigger.new
*   Return          : N/A
**************************************************************************************************/
    public static void parseEmailtoCase(List<Case> newCaseList)
    {
        newRecord=true;
        Id Lighting_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GE_LGT_Design_Request').getRecordTypeId();
        List<LDR_Data_Mapping__mdt> dataMapping = [SELECT eLight_Name__c, Data_Type__c, SFDC_Name__c from LDR_Data_Mapping__mdt];
        Map<string, string> dataMap =  new Map<string, string>();
        Map<string, string> dataTypeMap =  new Map<string, string>();
        for (LDR_Data_Mapping__mdt each : dataMapping)
        {
            dataMap.put(each.eLight_Name__c, each.SFDC_Name__c);
            dataTypeMap.put(each.eLight_Name__c, each.Data_Type__c);
        }
        Map<String, Schema.SObjectField>  fields = Schema.SObjectType.Case.fields.getMap();
        Map<string, string> opptyIdMap = new Map<string, string>();
        Set<string> opptyIdList =  new Set<String>();
        Map<id,opportunity> opptyMap = new Map<Id,opportunity>();
        for (Case eachCase :newCaseList)
        {
            if (eachCase.Origin=='eLight - Daintree Request' && eachCase.RecordTypeID==Lighting_RecordType)
            {
                if (eachCase.Description != null)
                {
                    string s = eachCase.Description;
                    if (s.contains('sfdcOppId'))
                    {
                        string opptyId = s.substringBetween('sfdcOppId::', '@@');
                        if (opptyId!= null && opptyId != '')
                            opptyIdList.add(opptyId.trim());
                    }
                }
            }
        }
        if (!opptyIdList.isEmpty())
        {
            //system.assert(false, opptyIdList);
            opptyMap = new Map<id, Opportunity>([SELECT Id, GE_LGT_GE_Opportunity_Id__c, AccountId, Account.Name from Opportunity where GE_LGT_GE_Opportunity_Id__c in : opptyIdList]);
            for (Id eachId : opptyMap.keySet())
            {
                opptyIdMap.put(opptyMap.get(eachId).GE_LGT_GE_Opportunity_Id__c, eachId);
            }
        }
        for (Case eachCase :newCaseList)
        {
            if (eachCase.Origin=='eLight - Daintree Request' && eachCase.RecordTypeID==Lighting_RecordType)
            {
                string emailData = eachCase.Description;
                if (emailData != null && emailData != '')
                {
                    string fieldsData = emailData.substringAfter('@@');
                    if (fieldsData != null && fieldsData != '')
                    {
                        List<string> dataTest = fieldsData.split('@@');
                        if (!dataTest.isEmpty())
                        {
                            for (string each : dataTest)
                            {
                                if (each!=null)
                                {
                                    List<string> fieldsMap = each.split('::');
                                    if (!fieldsMap.isEmpty() && fieldsMap.size() >1)
                                    {
                                        string s1 = dataMap.get(fieldsMap[0].trim());
                                        string s2 = fieldsMap[1];
                                        string s3 = dataTypeMap.get(fieldsMap[0].trim());
                                        if (s3 != null)
                                        {
                                            if (s3.toUpperCase() == 'STRING')
                                                try{
                                                    eachCase.put(s1,s2);
                                                }catch(exception e){}
                                            if (s3.toUpperCase() == 'NUMBER'){
                                                try {
                                                    eachCase.put(s1, Integer.valueOf(s2.trim()));
                                                }catch (exception e){}
                                            }
                                            if (s3.toUpperCase() == 'DATE')
                                            {
                                                try{
                                                    string s= s2.trim();
                                                    List<string> dateComponents = s.split('/');
                                                    eachCase.put(s1, Date.newInstance(Integer.valueOf(dateComponents[2]),Integer.valueOf(dateComponents[0]),Integer.valueOf(dateComponents[1])));
                                                }catch(exception e){}
                                            }
                                            if (s3.toUpperCase() == 'BOOLEAN')
                                            {
                                                try {
                                                    if (s2.trim() == 'true')
                                                        eachCase.put(s1, true);
                                                    else
                                                        eachCase.put(s1, false);
                                                }catch (exception e){}
                                            }
                                            if (s1 == 'eLight_Opportunity_ID__c')
                                            {
                                                string OpptyId = opptyIdMap.get(s2.trim());
                                                try{
                                                    eachCase.Opportunity_Name__c = opptyId;
                                                    if(opptyId !=null)
                                                    {
                                                        Opportunity parent = opptyMap.get(opptyId);
                                                        if (parent.AccountId != null)
                                                        {
                                                            eachCase.End_User_Name__c = parent.account.Name;
                                                        }
                                                    }
                                                }catch(exception e){}
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        //eachCase.Description = '';
                    }
                }
            }
        }
    }
    
    /*****************************************************************************************************************
*   Method Name     : updateOpptyValue
*   Purpose         : updating the Opportunity relationship with the case base on the "eLight_Opportunity_ID__c"
*   Input           : Trigger.new, Trigger.oldMap
*   Return          : N/A
******************************************************************************************************************/
    /* public static void updateOpptyValue(List<Case> newCaseList,Map<Id, Case> oldCaseMap)
{
Id Lighting_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GE_LGT_Design_Request').getRecordTypeId();
set<string> caseOpptys = new set<string>();
map<string, string> opptysMap = new map<string, string>();
for (case eachCase: newCaseList){
if (eachCase.eLight_Opportunity_ID__c != null && eachcase.eLight_Opportunity_ID__c != '' && eachCase.Origin=='eLight - Daintree Request' && eachCase.RecordTypeID==Lighting_RecordType)
{
caseOpptys.add(eachCase.eLight_Opportunity_ID__c);
}
}
if (!caseOpptys.isEmpty())
{
list<opportunity> caseOpportunities = [select id, GE_LGT_GE_Opportunity_Id__c from Opportunity where GE_LGT_GE_Opportunity_Id__c in :caseOpptys];
if (!caseOpportunities.isEmpty())
{
for (opportunity eachoppty: caseOpportunities)
{
opptysMap.put(eachoppty.GE_LGT_GE_Opportunity_Id__c, eachoppty.Id);
}
try {
for (case eachCase: newCaseList)
{
if (eachCase.Origin=='eLight - Daintree Request' && eachCase.RecordTypeID==Lighting_RecordType)
{
Id oldOpptyId = oldCaseMap.get(eachCase.Id).eLight_Opportunity_ID__c;
if (eachCase.eLight_Opportunity_ID__c != null && eachCase.eLight_Opportunity_ID__c != '')
{
if(oldOpptyId != null && oldOpptyId != '')
{
if(opptysMap.containsKey(eachCase.eLight_Opportunity_ID__c))
{
if (oldOpptyId!=eachCase.eLight_Opportunity_ID__c)
{
eachCase.Opportunity_Name__c = opptysMap.get(eachCase.eLight_Opportunity_ID__c);
}
}
}
else
{
if(opptysMap.containsKey(eachCase.eLight_Opportunity_ID__c))
{
eachCase.Opportunity_Name__c = opptysMap.get(eachCase.eLight_Opportunity_ID__c);
}
}
}
}
}
}catch(exception e){}
}
}
}*/
    /*****************************************************************************************************************
*   Method Name     : update GE Opportunity ID on Case
*   Purpose         : updating the Opportunity ID based on Opportunity_Name__c
*   Input           : Trigger.new
*   Return          : N/A
******************************************************************************************************************/
    public static void updateGEOppValue(List<Case> newCaseList,Map<Id, Case> oldCaseMap)
    {
        Id Lighting_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GE_LGT_Design_Request').getRecordTypeId();
        set<string> caseOpptys = new set<string>();
        map<Id, string> opptysMap = new map<Id, string>();
        for (case eachCase: newCaseList){
            if (eachCase.Opportunity_Name__c != null && eachCase.RecordTypeID==Lighting_RecordType && eachCase.Origin=='eLight - Daintree Request')
            {
                caseOpptys.add(eachCase.Opportunity_Name__c);
            }
        }
        
        if (!caseOpptys.isEmpty())
        {
            list<opportunity> caseOpportunities = [select id, GE_LGT_GE_Opportunity_Id__c from Opportunity where Id in :caseOpptys];
            if (!caseOpportunities.isEmpty())
            {
                for (opportunity eachoppty: caseOpportunities)
                {
                    opptysMap.put(eachoppty.Id, eachoppty.GE_LGT_GE_Opportunity_Id__c);
                }
                try {
                    for (case eachCase: newCaseList)
                    {
                        
                        if (eachCase.RecordTypeID==Lighting_RecordType && eachCase.Origin=='eLight - Daintree Request' )
                        {
                            
                            Id oldOpptyId = oldCaseMap.get(eachCase.Id).Opportunity_Name__c;
                            String GEOpptyId = oldCaseMap.get(eachCase.Id).eLight_Opportunity_ID__c;
                            
                            if (eachCase.Opportunity_Name__c!=null)
                            {
                                
                                if(opptysMap.containsKey(eachCase.Opportunity_Name__c))
                                {
                                    
                                    if (oldOpptyId!=eachCase.Opportunity_Name__c)
                                    {
                                        
                                        eachCase.eLight_Opportunity_ID__c = opptysMap.get(eachCase.Opportunity_Name__c);
                                        System.debug('GE Opp id ' + opptysMap.get(eachCase.Opportunity_Name__c));
                                        
                                    }
                                    else
                                        if( GEOpptyId==Null||GEOpptyId=='')
                                    {
                                        eachCase.eLight_Opportunity_ID__c = opptysMap.get(eachCase.Opportunity_Name__c);
                                        
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                    }
                }catch(exception e){}
            }
        }
        
    }
    
   /***********************************************************************************************
*   Method Name     : setCaseSubType 
*   Purpose         : This method is to update Case SubType Field based on case products Discrepancy Type.If there are multiple product discrepancies,
we do with the first in list? If not, just default all to ‘damage’. 
*   Input           : using Trigger.new and trigger.newMap  
*   Return          : N/A
**************************************************************************************************/
    
    
    public void  setCaseSubType(List<Case> newCaseList) {
        List<Shipment_Detail__c> details = new List<Shipment_Detail__c>();
        try{
        details =CaseTriggerHelper.prepareShipmentDetails(newCaseList);
         }catch(NullPointerException ee){ }
        if(details.size()>0)
        {
            Map<Id,List<Shipment_Detail__c>> CaseWithCaseProductsMap =  new Map<Id,List<Shipment_Detail__c>>();
            List<case> updateCasesList =new List<case>();       
            for(Shipment_Detail__c caseProduct :details) {
                if(CaseWithCaseProductsMap.containsKey(caseProduct.GE_NAS_Case_Number__c)) {
                    List<Shipment_Detail__c> caseProducttsList = CaseWithCaseProductsMap.get(caseProduct.GE_NAS_Case_Number__c);
                    caseProducttsList.add(caseProduct);
                    CaseWithCaseProductsMap.put(caseProduct.GE_NAS_Case_Number__c, caseProducttsList);
                } else {
                    CaseWithCaseProductsMap.put(caseProduct.GE_NAS_Case_Number__c, new List<Shipment_Detail__c> {caseProduct });
                }
            }
            system.debug('CaseWithCaseProductsMap'+CaseWithCaseProductsMap);
            for(case eachCase:newCaseList) {
                system.debug('eachCase.id'+eachCase.id);
                if(CaseWithCaseProductsMap.size()>0){
                    if(CaseWithCaseProductsMap.containsKey(eachCase.id)){  
                        system.debug('CaseWithCaseProductsMap.get(eachCase.id)'+CaseWithCaseProductsMap.get(eachCase.id));
                        List<Shipment_Detail__c> allCaseProductsList = CaseWithCaseProductsMap.get(eachCase.id);
                         system.debug('allCaseProductsList'+allCaseProductsList);
                         system.debug('allCaseProductsList[0].GE_NAS_Type_of_Problem1__c'+allCaseProductsList[0].GE_NAS_Type_of_Problem1__c);
                         system.debug('eachCase.Subject'+eachCase.Subject);
                        if(eachCase.Subject!=null){
                        if(allCaseProductsList[0].GE_NAS_Type_of_Problem1__c != null && (!eachCase.Subject.Contains(CaseConstants.ELIGHT_RETURNS))){
                            system.debug('allCaseProductsList[0].GE_NAS_Type_of_Problem1__c'+allCaseProductsList[0].GE_NAS_Type_of_Problem1__c);
                            eachCase.GE_NAS_Sub_Type__c=allCaseProductsList[0].GE_NAS_Type_of_Problem1__c;
                            //system.debug(' updateCasesList1'+updateCasesList);
                            // updateCasesList.add(eachCase);  
                        }
                        }
                        
                    } 
                }
            }
            //system.debug('updateCasesList2'+updateCasesList);
            //update updateCasesList;
        }
        
    }
       
}
trigger caseEmailTrigger on Case (after update) {
    
  if(CaseTriggerHandler.isFirstTime){ 

    CaseTriggerHandler.isFirstTime = false;   
    System.debug('isFirstTime *******'+CaseTriggerHandler.isFirstTime);
      
      
      EmailTemplate emailPricingOpen = [Select id,Subject,HtmlValue from EmailTemplate where name = 'Pricing Request - New Message']; 
      
      EmailTemplate emailPricingOpen1 = [Select id,Subject,HtmlValue from EmailTemplate where name = 'Pricing Request - Pricing Analyst']; 
  
      
      EmailTemplate emailPricingClose = [Select id,Subject,HtmlValue from EmailTemplate where name = 'Pricing Request - Pricing Provided']; 
   
      
      EmailTemplate emailPricingReassign = [Select id,Subject,HtmlValue from EmailTemplate where name = 'Pricing Request - Case Reassignment']; 

      
      EmailTemplate emailWCIGOpen = [Select id,Subject,Markup from EmailTemplate where name = 'CaseProductTemp']; 

      EmailTemplate emailNSROpen = [Select id,Subject,HtmlValue from EmailTemplate where name = 'New Spec Registration Case Creation']; 
 
      
      EmailTemplate emailNSRClose = [Select id,Subject,HtmlValue from EmailTemplate where name = 'New Specification Registration - Closed']; 

      
      EmailTemplate emailNSRRej = [Select id,Subject,HtmlValue from EmailTemplate where name = 'New Specification Registration - Rejection']; 
 
      
       EmailTemplate emailNSRJob1 = [Select id,Subject,HtmlValue from EmailTemplate where name = 'New Spec 30 Days']; 

      
      EmailTemplate emailNSRLost = [Select id,Subject,HtmlValue from EmailTemplate where name = 'New Specification Registration - Lost']; 
   
      
      EmailTemplate emailNSRJob2 = [Select id,Subject,HtmlValue from EmailTemplate where name = 'New Specification Registration - Job Timing Notice #2']; 
    //System.debug('emailNSRJob2 *******'+emailNSRJob2);
      

    //List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
   
   // Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id,Name, OwnerId,Owner.Email FROM Account WHERE Id In :accIds]);
   //TO CHECK OWNER NAME OF THE CASE
      Map<String,String> ownerMap1 = new Map<String,String>();
      
    //Orgwise email
    OrgWideEmailAddress lstOrgWideEmailId = [Select Id from OrgWideEmailAddress where displayname='Noreply'];  
      
      

    for (Case c : trigger.new) {
        
        String account_id1='';
        String account_id2='';
        String account_id3='';
        String account_id4;
        String contact_id;
        //Changes to restrict duplicate emails
        List<Shipment_Detail__c> cnt=[select id from Shipment_Detail__c where  GE_NAS_Case_Number__c=:c.id];
        system.debug('count of case products: '+cnt.size());
            
        if(cnt.size()==0){
            
            continue;
        }
        
        
        if(c.Spec_Reg_Agency__c==c.Ordering_Agency__c && c.Ordering_Agency__c==c.Delivery_Agency__c){
        account_id1=c.Spec_Reg_Agency__c;
        }
        else if (c.Spec_Reg_Agency__c!=c.Ordering_Agency__c && c.Ordering_Agency__c==c.Delivery_Agency__c){
          account_id1=c.Spec_Reg_Agency__c;
          account_id2=c.Ordering_Agency__c;
        }
        else if (c.Spec_Reg_Agency__c!=c.Ordering_Agency__c && c.Ordering_Agency__c!=c.Delivery_Agency__c){
           account_id1=c.Spec_Reg_Agency__c;
           account_id2=c.Ordering_Agency__c;
           account_id3=c.Delivery_Agency__c;
        } 
        
        if(c.AccountId != NULL){
            account_id4=c.AccountId;
        }
        
        contact_id=c.ContactId;
        
        system.debug('AccountId'+account_id4);
        system.debug('ContactId'+contact_id);
    List<Account> accMap= [SELECT Id,Name,Owner.Email, Pricing_Analyst__r.Email FROM Account WHERE Id IN  (:account_id1,:account_id2,:account_id3, :account_id4)];
        
    List<Account> aMap =  [SELECT Id,Name, Owner.Email,Pricing_Analyst__r.Email FROM Account WHERE Id IN  (:account_id4)];  
        
    List<Contact> conMap = [SELECT AccountId,Name,Title,Email from Contact 
                                                   where Title LIKE '%Principal%' AND AccountId IN  (:account_id1,:account_id2,:account_id3)
                           AND Email!=Null and AccountId!=Null];
        
    List<Contact> cMap = [SELECT AccountId,Name,Title,Email from Contact 
                                                   where id IN (:contact_id)];
    
        
   // List<Shipment_Detail__c> cp = [Select Id, GE_NAS_Product_Code__c from Shipment_Detail__c where GE_NAS_Case_Number__c=:c.CaseNumber]; 
    
    System.debug('accMap************'+accMap);
    System.debug('aMap************'+aMap);
    System.debug('conMap************'+conMap);
    System.debug('cMap************'+cMap);
    //System.debug('ProductDtl************'+cp);    
        //String oldStatus = trigger.oldMap.get(c.id).status;
       // System.debug('oldStatus************'+oldStatus);
       
        //String oldStatus = trigger.oldMap.get(c.id).status;
        String oldStatus = NULL;
        System.debug('oldStatus***************'+oldStatus);
        
        
        /*Sending email template when status of Pricing case is open */ 
        if(c.GE_NAS_Sub_Type__c == 'Pricing Request' && c.Status == 'Open'){
            
        for(Account relatedCaseAccount:accMap){
            
            System.debug('relatedCaseContact**********'+relatedCaseAccount);
            Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
            CaseNotificationmail.setToAddresses(new List<String> { relatedCaseAccount.Owner.Email});
                    
            String subject = emailPricingOpen.Subject;
            String htmlBody = emailPricingOpen.HtmlValue;
            
            htmlBody = htmlBody.replace('{!Case.CaseNumber}', c.CaseNumber);
            htmlBody = htmlBody.replace('{!Case.Account}', relatedCaseAccount.Name);
            CaseNotificationmail.setTargetObjectId(relatedCaseAccount.OwnerId);
            CaseNotificationmail.setReplyTo('no.reply@gecurrent.com');
            //CaseNotificationmail.getToAddresses('no.reply@gecurrent.com');
            CaseNotificationmail.setUseSignature(false);
            CaseNotificationmail.setBccSender(false);
            CaseNotificationmail.setTemplateId(emailPricingOpen.Id);
            CaseNotificationmail.setSubject(subject);
            CaseNotificationmail.setHtmlBody(htmlBody);
            System.debug('CaseNotificationmail********'+CaseNotificationmail);
    
            CaseNotificationmail.setSaveAsActivity(false);
            //CaseNotificationmail.setSenderDisplayName('No Reply <no.reply@gecurrent.com>');    
            
            CaseNotificationmail.setOrgWideEmailAddressId(lstOrgWideEmailId.Id);

            mails.add(CaseNotificationmail); 
            System.debug('mails *******'+mails);
                                
            }
            
        System.debug('*******'+c.AccountId);
         
        
           
        //Contact relatedCaseCon = conMap.get(c.AccountId);
        for(Contact relatedCaseCon: cMap){
        System.debug('relatedCaseCon**********'+relatedCaseCon);
       
        Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
        CaseNotificationmail.setToAddresses(new List<String> { relatedCaseCon.Email });

        String subject = emailPricingOpen.Subject;
        String htmlBody = emailPricingOpen.HtmlValue;
            
        htmlBody = htmlBody.replace('{!Case.CaseNumber}', c.CaseNumber);
        htmlBody = htmlBody.replace('{!Case.Account}', relatedCaseCon.Name);
        CaseNotificationmail.setTargetObjectId(relatedCaseCon.Id);
        CaseNotificationmail.setReplyTo('no.reply@gecurrent.com');
       // CaseNotificationmail.getToAddresses('no.reply@gecurrent.com');
        CaseNotificationmail.setUseSignature(false);
        CaseNotificationmail.setBccSender(false);

        CaseNotificationmail.setTemplateId(emailPricingOpen.Id);
        CaseNotificationmail.setSubject(subject);
        CaseNotificationmail.setHtmlBody(htmlBody);
        System.debug('CaseNotificationmail********'+CaseNotificationmail);

        CaseNotificationmail.setSaveAsActivity(false);
        //CaseNotificationmail.setSenderDisplayName('No Reply <no.reply@gecurrent.com>'); 
            
        CaseNotificationmail.setOrgWideEmailAddressId(lstOrgWideEmailId.Id);

        mails.add(CaseNotificationmail); 
        System.debug('mails *******'+mails);
            
        }
    }
        
        /*Sending email template when status of Pricing case is Open and being sent to pricing Analyst */ 
        if(c.GE_NAS_Sub_Type__c == 'Pricing Request' && c.Status == 'Open'){

        
        for(Account relatedCaseAccount:aMap){
            
            System.debug('relatedCaseContact**********'+relatedCaseAccount);
            Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
            CaseNotificationmail.setToAddresses(new List<String> { relatedCaseAccount.Pricing_Analyst__r.Email});
                    
            String subject = emailPricingOpen1.Subject;
            String htmlBody = emailPricingOpen1.HtmlValue;
            
            htmlBody = htmlBody.replace('{!Case.CaseNumber}', c.CaseNumber);
            htmlBody = htmlBody.replace('{!Case.Account}', relatedCaseAccount.Name);
            CaseNotificationmail.setTargetObjectId(relatedCaseAccount.OwnerId);
            CaseNotificationmail.setReplyTo('no.reply@gecurrent.com');
            //CaseNotificationmail.getToAddresses('no.reply@gecurrent.com');
            CaseNotificationmail.setUseSignature(false);
            CaseNotificationmail.setBccSender(false);
            CaseNotificationmail.setTemplateId(emailPricingOpen.Id);
            CaseNotificationmail.setSubject(subject);
            CaseNotificationmail.setHtmlBody(htmlBody);
            System.debug('CaseNotificationmail********'+CaseNotificationmail);
    
            CaseNotificationmail.setSaveAsActivity(false);
            //CaseNotificationmail.setSenderDisplayName('No Reply <no.reply@gecurrent.com>'); 
            
            CaseNotificationmail.setOrgWideEmailAddressId(lstOrgWideEmailId.Id);

            mails.add(CaseNotificationmail); 
            System.debug('mails *******'+mails);
                                
            }
        }
        
        /*Sending email template when status of Pricing case is close */ 
        if(c.GE_NAS_Sub_Type__c == 'Pricing Request' && c.Status == 'Closed'){
            
        for(Account relatedCaseAccount:accMap){
            //for(Shipment_Detail__c cpNew: cp){
            
            System.debug('relatedCaseContact**********'+relatedCaseAccount);
            Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
            CaseNotificationmail.setToAddresses(new List<String> { relatedCaseAccount.Owner.Email });
            
            String subject = emailPricingClose.Subject;
            String htmlBody = emailPricingClose.HtmlValue;
            //htmlBody = htmlBody.replace('{!Case.CreatedBy}', c.GE_NAS_Created_By__c);
            Shipment_Detail__c cp = [Select GE_NAS_Product_Code__c from Shipment_Detail__c where GE_NAS_Case_Number__c=:c.Id LIMIT 1];
            
            if(cp.GE_NAS_Product_Code__c!=Null){
            htmlBody = htmlBody.replace('{!Shipment_Detail__c.GE_NAS_Product_Code__c}', cp.GE_NAS_Product_Code__c);
            }
            else{
             htmlBody = htmlBody.replace('{!Shipment_Detail__c.GE_NAS_Product_Code__c}', 'N/A');   
            }
        
            if(c.eLight_Comments__c!=Null){
            htmlBody = htmlBody.replace('{!Case.eLight_Comments__c}', c.eLight_Comments__c);
            }
            else{
             htmlBody = htmlBody.replace('{!Case.eLight_Comments__c}', 'N/A');   
            }
            CaseNotificationmail.setTargetObjectId(relatedCaseAccount.OwnerId);
            CaseNotificationmail.setReplyTo('no.reply@gecurrent.com');
            //CaseNotificationmail.getToAddresses('no.reply@gecurrent.com');
            CaseNotificationmail.setUseSignature(false);
            CaseNotificationmail.setBccSender(false);
            CaseNotificationmail.setTemplateId(emailPricingClose.Id);
            CaseNotificationmail.setSubject(subject);
            CaseNotificationmail.setHtmlBody(htmlBody);
            System.debug('CaseNotificationmail********'+CaseNotificationmail);
    
            CaseNotificationmail.setSaveAsActivity(false);
            //CaseNotificationmail.setSenderDisplayName('No Reply <no.reply@gecurrent.com>');            
            
            CaseNotificationmail.setOrgWideEmailAddressId(lstOrgWideEmailId.Id);

            mails.add(CaseNotificationmail); 
            System.debug('mails *******'+mails);
                                
           // }
        }
            
        System.debug('*******'+c.AccountId);
            
       for(Account relatedCaseAccount:aMap){
            //for(Shipment_Detail__c cpNew: cp){
            
            System.debug('relatedCaseContact**********'+relatedCaseAccount);
            Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
            CaseNotificationmail.setToAddresses(new List<String> { relatedCaseAccount.Pricing_Analyst__r.Email});
            
            String subject = emailPricingClose.Subject;
            String htmlBody = emailPricingClose.HtmlValue;
            //htmlBody = htmlBody.replace('{!Case.CreatedBy}', c.GE_NAS_Created_By__c);
            Shipment_Detail__c cp = [Select GE_NAS_Product_Code__c from Shipment_Detail__c where GE_NAS_Case_Number__c=:c.Id LIMIT 1];
            
            if(cp.GE_NAS_Product_Code__c!=Null){
            htmlBody = htmlBody.replace('{!Shipment_Detail__c.GE_NAS_Product_Code__c}', cp.GE_NAS_Product_Code__c);
            }
            else{
             htmlBody = htmlBody.replace('{!Shipment_Detail__c.GE_NAS_Product_Code__c}', 'N/A');   
            }
        
            if(c.eLight_Comments__c!=Null){
            htmlBody = htmlBody.replace('{!Case.eLight_Comments__c}', c.eLight_Comments__c);
            }
            else{
             htmlBody = htmlBody.replace('{!Case.eLight_Comments__c}', 'N/A');   
            }
            CaseNotificationmail.setTargetObjectId(relatedCaseAccount.OwnerId);
            CaseNotificationmail.setReplyTo('no.reply@gecurrent.com');
            //CaseNotificationmail.getToAddresses('no.reply@gecurrent.com');
            CaseNotificationmail.setUseSignature(false);
            CaseNotificationmail.setBccSender(false);
            CaseNotificationmail.setTemplateId(emailPricingClose.Id);
            CaseNotificationmail.setSubject(subject);
            CaseNotificationmail.setHtmlBody(htmlBody);
            System.debug('CaseNotificationmail********'+CaseNotificationmail);
    
            CaseNotificationmail.setSaveAsActivity(false);
            //CaseNotificationmail.setSenderDisplayName('No Reply <no.reply@gecurrent.com>');  
           
            CaseNotificationmail.setOrgWideEmailAddressId(lstOrgWideEmailId.Id);

            mails.add(CaseNotificationmail); 
            System.debug('mails *******'+mails);
                                
           // }
        }
        
        //Contact relatedCaseCon = conMap.get(c.AccountId);
        for(Contact relatedCaseCon: cMap){
        System.debug('relatedCaseCon**********'+relatedCaseCon);
           // for(Shipment_Detail__c cpNew: cp){
       
        Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
        CaseNotificationmail.setToAddresses(new List<String> { relatedCaseCon.Email });

        String subject = emailPricingClose.Subject;
        String htmlBody = emailPricingClose.HtmlValue;
        //htmlBody = htmlBody.replace('{!Case.CreatedBy}', c.GE_NAS_Created_By__c);
        Shipment_Detail__c cp = [Select GE_NAS_Product_Code__c from Shipment_Detail__c where GE_NAS_Case_Number__c=:c.Id LIMIT 1];
            if(cp.GE_NAS_Product_Code__c!=Null){
             htmlBody = htmlBody.replace('{!Shipment_Detail__c.GE_NAS_Product_Code__c}', cp.GE_NAS_Product_Code__c);
             }
             else{
             htmlBody = htmlBody.replace('{!Shipment_Detail__c.GE_NAS_Product_Code__c}', 'N/A');   
            }
        if(c.eLight_Comments__c!=Null){
            htmlBody = htmlBody.replace('{!Case.eLight_Comments__c}', c.eLight_Comments__c);
            }
            else{
             htmlBody = htmlBody.replace('{!Case.eLight_Comments__c}', 'N/A');   
            }
        CaseNotificationmail.setTargetObjectId(relatedCaseCon.Id);
        CaseNotificationmail.setReplyTo('no.reply@gecurrent.com');
       // CaseNotificationmail.getToAddresses('no.reply@gecurrent.com');
        CaseNotificationmail.setUseSignature(false);
        CaseNotificationmail.setBccSender(false);

        CaseNotificationmail.setTemplateId(emailPricingClose.Id);
        CaseNotificationmail.setSubject(subject);
        CaseNotificationmail.setHtmlBody(htmlBody);
        System.debug('CaseNotificationmail********'+CaseNotificationmail);

        CaseNotificationmail.setSaveAsActivity(false);
        //CaseNotificationmail.setSenderDisplayName('No Reply <no.reply@gecurrent.com>');  
            
        CaseNotificationmail.setOrgWideEmailAddressId(lstOrgWideEmailId.Id);

        mails.add(CaseNotificationmail); 
        System.debug('mails *******'+mails);
            
       // }
        }
    }
         Group grp = [SELECT Id from Group where Name = 'Pricing Queue'];
        
        /*Sending email template when Pricing case owner is changed*/ 
        if(c.GE_NAS_Sub_Type__c == 'Pricing Request' && c.OwnerId != grp.id){
            
            System.debug('c.Owner.Name*****************'+c.Owner.Name+c.OwnerId+c.Owner);
            System.debug('c.OwnerId*****************'+c.OwnerId);
            

            
        for(Account relatedCaseAccount:accMap){
            
            System.debug('relatedCaseContact**********'+relatedCaseAccount);
            Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
            CaseNotificationmail.setToAddresses(new List<String> { relatedCaseAccount.Owner.Email });
                    
            String subject = emailPricingReassign.Subject;
            String htmlBody = emailPricingReassign.HtmlValue;
            htmlBody = htmlBody.replace('{!Case.Account}', relatedCaseAccount.Name);
            if(c.eLight_Price_Agreement__c !=Null){
            htmlBody = htmlBody.replace('{!Case.eLight_Price_Agreement__c}', c.eLight_Price_Agreement__c);
            }
            else{
             htmlBody = htmlBody.replace('{!Case.eLight_Price_Agreement__c}', 'N/A');   
            }
            
            if(c.GE_NAS_Created_By__c !=Null){
            htmlBody = htmlBody.replace('{!Case.CreatedBy}', c.GE_NAS_Created_By__c);
            }
            else{
                 htmlBody = htmlBody.replace('{!Case.CreatedBy}', 'N/A');
            }
            CaseNotificationmail.setTargetObjectId(relatedCaseAccount.OwnerId);
            CaseNotificationmail.setReplyTo('no.reply@gecurrent.com');
            //CaseNotificationmail.getToAddresses('no.reply@gecurrent.com');
            CaseNotificationmail.setUseSignature(false);
            CaseNotificationmail.setBccSender(false);
            CaseNotificationmail.setTemplateId(emailPricingReassign.Id);
            CaseNotificationmail.setSubject(subject);
            CaseNotificationmail.setHtmlBody(htmlBody);
            System.debug('CaseNotificationmail********'+CaseNotificationmail);
    
            CaseNotificationmail.setSaveAsActivity(false);
            //CaseNotificationmail.setSenderDisplayName('No Reply <no.reply@gecurrent.com>');  
            
            CaseNotificationmail.setOrgWideEmailAddressId(lstOrgWideEmailId.Id);

            mails.add(CaseNotificationmail); 
            System.debug('mails *******'+mails);
                                
            }
            
        System.debug('*******'+c.AccountId);
            
        for(Account relatedCaseAccount:aMap){
            
            System.debug('relatedCaseContact**********'+relatedCaseAccount);
            Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
            CaseNotificationmail.setToAddresses(new List<String> { relatedCaseAccount.Pricing_Analyst__r.Email });
                    
            String subject = emailPricingReassign.Subject;
            String htmlBody = emailPricingReassign.HtmlValue;
            htmlBody = htmlBody.replace('{!Case.Account}', relatedCaseAccount.Name);
            if(c.eLight_Price_Agreement__c !=Null){
            htmlBody = htmlBody.replace('{!Case.eLight_Price_Agreement__c}', c.eLight_Price_Agreement__c);
            }
            else{
             htmlBody = htmlBody.replace('{!Case.eLight_Price_Agreement__c}', 'N/A');   
            }
            
            if(c.GE_NAS_Created_By__c !=Null){
            htmlBody = htmlBody.replace('{!Case.CreatedBy}', c.GE_NAS_Created_By__c);
            }
            else{
                 htmlBody = htmlBody.replace('{!Case.CreatedBy}', 'N/A');
            }
            CaseNotificationmail.setTargetObjectId(relatedCaseAccount.OwnerId);
            CaseNotificationmail.setReplyTo('no.reply@gecurrent.com');
            //CaseNotificationmail.getToAddresses('no.reply@gecurrent.com');
            CaseNotificationmail.setUseSignature(false);
            CaseNotificationmail.setBccSender(false);
            CaseNotificationmail.setTemplateId(emailPricingReassign.Id);
            CaseNotificationmail.setSubject(subject);
            CaseNotificationmail.setHtmlBody(htmlBody);
            System.debug('CaseNotificationmail********'+CaseNotificationmail);
    
            CaseNotificationmail.setSaveAsActivity(false);
            //CaseNotificationmail.setSenderDisplayName('No Reply <no.reply@gecurrent.com>');            
            
			CaseNotificationmail.setOrgWideEmailAddressId(lstOrgWideEmailId.Id);            

            mails.add(CaseNotificationmail); 
            System.debug('mails *******'+mails);
                                
            }
        //Contact relatedCaseCon = conMap.get(c.AccountId);
        for(Contact relatedCaseCon: cMap){
        System.debug('relatedCaseCon**********'+relatedCaseCon);
       
        Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
        CaseNotificationmail.setToAddresses(new List<String> { relatedCaseCon.Email });

        String subject = emailPricingReassign.Subject;
        String htmlBody = emailPricingReassign.HtmlValue;
        htmlBody = htmlBody.replace('{!Case.Account}', relatedCaseCon.Name);
        if(c.eLight_Price_Agreement__c !=Null){
            htmlBody = htmlBody.replace('{!Case.eLight_Price_Agreement__c}', c.eLight_Price_Agreement__c);
            }
            else{
             htmlBody = htmlBody.replace('{!Case.eLight_Price_Agreement__c}', 'N/A');   
            }
            
            if(c.GE_NAS_Created_By__c !=Null){
            htmlBody = htmlBody.replace('{!Case.CreatedBy}', c.GE_NAS_Created_By__c);
            }
            else{
                 htmlBody = htmlBody.replace('{!Case.CreatedBy}', 'N/A');
            }
        CaseNotificationmail.setTargetObjectId(relatedCaseCon.Id);
        CaseNotificationmail.setReplyTo('no.reply@gecurrent.com');
       // CaseNotificationmail.getToAddresses('no.reply@gecurrent.com');
        CaseNotificationmail.setUseSignature(false);
        CaseNotificationmail.setBccSender(false);

        CaseNotificationmail.setTemplateId(emailPricingReassign.Id);
                    
        CaseNotificationmail.setSubject(subject);
        CaseNotificationmail.setHtmlBody(htmlBody);
        System.debug('CaseNotificationmail********'+CaseNotificationmail);

        CaseNotificationmail.setSaveAsActivity(false);
        //CaseNotificationmail.setSenderDisplayName('No Reply <no.reply@gecurrent.com>');            

            
        CaseNotificationmail.setOrgWideEmailAddressId(lstOrgWideEmailId.Id);
        mails.add(CaseNotificationmail); 
        System.debug('mails *******'+mails);
            
        }
    }
        
         /*Sending email template when status of New Spec Registration case status is changed to Open */ 
        if(c.GE_NAS_Sub_Type__c == 'New Specification Registration' && c.Status == 'Open'){
            
        for(Account relatedCaseAccount:accMap){
            
            System.debug('relatedCaseContact**********'+relatedCaseAccount);
            Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
            CaseNotificationmail.setToAddresses(new List<String> { relatedCaseAccount.Owner.Email });
                    
            String subject = emailNSROpen.Subject;
            String htmlBody = emailNSROpen.HtmlValue;  
            
            htmlBody = htmlBody.replace('{!Case.CaseNumber}', c.CaseNumber);
            if(c.Spec_Reg_Agency__c!=Null){
             Account spc = [Select Name from Account where Id=:c.Spec_Reg_Agency__c];
            htmlBody = htmlBody.replace('{!Case.Spec_Reg_Agency__c}', spc.Name);
            }
            else{
             htmlBody = htmlBody.replace('{!Case.Spec_Reg_Agency__c}', 'N/A');   
            }
            
            if(c.Job_Name__c!=Null){
                htmlBody = htmlBody.replace('{!Case.Job_Name__c}', c.Job_Name__c);
            }
            else{
               htmlBody = htmlBody.replace('{!Case.Job_Name__c}', 'N/A'); 
            }
            htmlBody = htmlBody.replace('{!Case.Estimated_bidding_ordering_Start_Date__c}', String.valueOf(c.Estimated_bidding_ordering_Start_Date__c));
            htmlBody = htmlBody.replace('{!Case.Estimated_bidding_ordering_End_Date__c}', String.valueOf(c.Estimated_bidding_ordering_End_Date__c));
            //htmlBody = htmlBody.replace('{!Case.Link}', 'N/A');
            CaseNotificationmail.setTargetObjectId(relatedCaseAccount.OwnerId);
            CaseNotificationmail.setReplyTo('no.reply@gecurrent.com');
            //CaseNotificationmail.getToAddresses('no.reply@gecurrent.com');
            CaseNotificationmail.setUseSignature(false);
            CaseNotificationmail.setBccSender(false);
            CaseNotificationmail.setTemplateId(emailNSROpen.Id);
            CaseNotificationmail.setSubject(subject);
            CaseNotificationmail.setHtmlBody(htmlBody);   
            String s = htmlBody.escapeHtml4();
            System.debug('CaseNotificationmail********'+CaseNotificationmail);
    
            CaseNotificationmail.setSaveAsActivity(false);
            
            CaseNotificationmail.setOrgWideEmailAddressId(lstOrgWideEmailId.Id);
			          

            mails.add(CaseNotificationmail); 
            System.debug('mails *******'+mails);
                                
            }
            
        System.debug('*******'+c.AccountId);
        //Contact relatedCaseCon = conMap.get(c.AccountId);
        for(Contact relatedCaseCon: conMap){
        System.debug('relatedCaseCon**********'+relatedCaseCon);
       
        Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
        CaseNotificationmail.setToAddresses(new List<String> { relatedCaseCon.Email });

            String subject = emailNSROpen.Subject;
            String htmlBody = emailNSROpen.HtmlValue;
              htmlBody = htmlBody.replace('{!Case.CaseNumber}', c.CaseNumber);
            if(c.Spec_Reg_Agency__c!=Null){
             Account spc = [Select Name from Account where Id=:c.Spec_Reg_Agency__c];
            htmlBody = htmlBody.replace('{!Case.Spec_Reg_Agency__c}', spc.Name);
            }
            else{
             htmlBody = htmlBody.replace('{!Case.Spec_Reg_Agency__c}', 'N/A');   
            }
            
            if(c.Job_Name__c!=Null){
                htmlBody = htmlBody.replace('{!Case.Job_Name__c}', c.Job_Name__c);
            }
            else{
               htmlBody = htmlBody.replace('{!Case.Job_Name__c}', 'N/A'); 
            }
            htmlBody = htmlBody.replace('{!Case.Estimated_bidding_ordering_Start_Date__c}', String.valueOf(c.Estimated_bidding_ordering_Start_Date__c));
            htmlBody = htmlBody.replace('{!Case.Estimated_bidding_ordering_End_Date__c}', String.valueOf(c.Estimated_bidding_ordering_End_Date__c));
            //htmlBody = htmlBody.replace('{!Case.Link}', 'N/A');
            
        CaseNotificationmail.setTargetObjectId(relatedCaseCon.Id);
        CaseNotificationmail.setReplyTo('no.reply@gecurrent.com');
       // CaseNotificationmail.getToAddresses('no.reply@gecurrent.com');
        CaseNotificationmail.setUseSignature(false);
        CaseNotificationmail.setBccSender(false);

        CaseNotificationmail.setTemplateId(emailNSROpen.Id);
        CaseNotificationmail.setSubject(subject);
        CaseNotificationmail.setHtmlBody(htmlBody);    
            String s = htmlBody.escapeHtml4();
        System.debug('CaseNotificationmail********'+CaseNotificationmail);

        CaseNotificationmail.setSaveAsActivity(false);
       // CaseNotificationmail.setSenderDisplayName('No Reply <no.reply@gecurrent.com>'); 
        CaseNotificationmail.setOrgWideEmailAddressId(lstOrgWideEmailId.Id);           

        mails.add(CaseNotificationmail); 
        System.debug('mails *******'+mails);
            
        }
    }
        /*Sending email template when status of New Spec Registration case status is changed to Closed*/ 
        if(c.GE_NAS_Sub_Type__c == 'New Specification Registration' && c.Status == 'Closed'){
            
        for(Account relatedCaseAccount:accMap){
            
            System.debug('relatedCaseContact**********'+relatedCaseAccount);
            Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
            CaseNotificationmail.setToAddresses(new List<String> { relatedCaseAccount.Owner.Email });
                    
            String subject = emailNSRClose.Subject;
            String htmlBody = emailNSRClose.HtmlValue;
            if(c.Spec_Reg_Agency__c!=Null){
             Account spc1 = [Select Name from Account where Id=:c.Spec_Reg_Agency__c];
            htmlBody = htmlBody.replace('{!Case.Spec_Reg_Agency__c}', spc1.Name);
            }
            else{
             htmlBody = htmlBody.replace('{!Case.Spec_Reg_Agency__c}', 'N/A');   
            }
             if(c.Job_Name__c!=Null){
            htmlBody = htmlBody.replace('{!Case.Job_Name__c}', c.Job_Name__c);
             }
            else{
              htmlBody = htmlBody.replace('{!Case.Job_Name__c}', 'N/A');  
            }
            if(c.eLight_Comments__c!=Null){
            htmlBody = htmlBody.replace('{!Case.eLight_Comments__c}', c.eLight_Comments__c);
            }
            else{
            htmlBody = htmlBody.replace('{!Case.eLight_Comments__c}', 'N/A');    
            }
              
            CaseNotificationmail.setTargetObjectId(relatedCaseAccount.OwnerId);
            CaseNotificationmail.setReplyTo('no.reply@gecurrent.com');
            //CaseNotificationmail.getToAddresses('no.reply@gecurrent.com');
            CaseNotificationmail.setUseSignature(false);
            CaseNotificationmail.setBccSender(false);
            CaseNotificationmail.setTemplateId(emailNSRClose.Id);
            CaseNotificationmail.setSubject(subject);
            CaseNotificationmail.setHtmlBody(htmlBody);
            String s = htmlBody.escapeUnicode();
            System.debug('CaseNotificationmail********'+CaseNotificationmail);
    
            CaseNotificationmail.setSaveAsActivity(false);
            //CaseNotificationmail.setSenderDisplayName('No Reply <no.reply@gecurrent.com>');            
			CaseNotificationmail.setOrgWideEmailAddressId(lstOrgWideEmailId.Id);
            mails.add(CaseNotificationmail); 
            System.debug('mails *******'+mails);
                                
            }
            
        System.debug('*******'+c.AccountId);
        //Contact relatedCaseCon = conMap.get(c.AccountId);
        for(Contact relatedCaseCon: conMap){
        System.debug('relatedCaseCon**********'+relatedCaseCon);
       
        Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
        CaseNotificationmail.setToAddresses(new List<String> { relatedCaseCon.Email });

        String subject = emailNSRClose.Subject;
        String htmlBody = emailNSRClose.HtmlValue;           
      if(c.Spec_Reg_Agency__c!=Null){
          Account spc1 = [Select Name from Account where Id=:c.Spec_Reg_Agency__c];
            htmlBody = htmlBody.replace('{!Case.Spec_Reg_Agency__c}', spc1.Name);
            }
            else{
             htmlBody = htmlBody.replace('{!Case.Spec_Reg_Agency__c}', 'N/A');   
            }
             if(c.Job_Name__c!=Null){
            htmlBody = htmlBody.replace('{!Case.Job_Name__c}', c.Job_Name__c);
             }
            else{
              htmlBody = htmlBody.replace('{!Case.Job_Name__c}', 'N/A');  
            }
            if(c.eLight_Comments__c!=Null){
            htmlBody = htmlBody.replace('{!Case.eLight_Comments__c}', c.eLight_Comments__c);
            }
            else{
            htmlBody = htmlBody.replace('{!Case.eLight_Comments__c}', 'N/A');    
            }
        CaseNotificationmail.setTargetObjectId(relatedCaseCon.Id);
        CaseNotificationmail.setReplyTo('no.reply@gecurrent.com');
       // CaseNotificationmail.getToAddresses('no.reply@gecurrent.com');
        CaseNotificationmail.setUseSignature(false);
        CaseNotificationmail.setBccSender(false);

        CaseNotificationmail.setTemplateId(emailNSRClose.Id);
        CaseNotificationmail.setSubject(subject);
        CaseNotificationmail.setHtmlBody(htmlBody);
            String s = htmlbody.escapeHtml4();
            
            
        System.debug('CaseNotificationmail********'+CaseNotificationmail);

        CaseNotificationmail.setSaveAsActivity(false);
        //CaseNotificationmail.setSenderDisplayName('No Reply <no.reply@gecurrent.com>');            
		CaseNotificationmail.setOrgWideEmailAddressId(lstOrgWideEmailId.Id);
        mails.add(CaseNotificationmail); 
        System.debug('mails *******'+mails);
            
        }
    }
        /*Sending email template when status of New Spec Registration case status is changed to Lost*/ 
        if(c.GE_NAS_Sub_Type__c == 'New Specification Registration' && c.Status == 'Lost'){
            
        for(Account relatedCaseAccount:accMap){
            
            System.debug('relatedCaseContact**********'+relatedCaseAccount);
            Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
            CaseNotificationmail.setToAddresses(new List<String> { relatedCaseAccount.Owner.Email });
                    
            String subject = emailNSRLost.Subject;
            String htmlBody = emailNSRLost.HtmlValue;
            htmlBody = htmlBody.replace('{!Case.CaseNumber}', c.CaseNumber);
            if(c.Job_Name__c!=Null){
            htmlBody = htmlBody.replace('{!Case.Job_Name__c}', c.Job_Name__c);
            }
            else{
              htmlBody = htmlBody.replace('{!Case.Job_Name__c}', 'N/A');  
            }
            CaseNotificationmail.setTargetObjectId(relatedCaseAccount.OwnerId);
            CaseNotificationmail.setReplyTo('no.reply@gecurrent.com');
            //CaseNotificationmail.getToAddresses('no.reply@gecurrent.com');
            CaseNotificationmail.setUseSignature(false);
            CaseNotificationmail.setBccSender(false);
            CaseNotificationmail.setTemplateId(emailNSRLost.Id);
            CaseNotificationmail.setSubject(subject);
            CaseNotificationmail.setHtmlBody(htmlBody);
            System.debug('CaseNotificationmail********'+CaseNotificationmail);
    
            CaseNotificationmail.setSaveAsActivity(false);
           // CaseNotificationmail.setSenderDisplayName('No Reply <no.reply@gecurrent.com>');            
			CaseNotificationmail.setOrgWideEmailAddressId(lstOrgWideEmailId.Id);
            mails.add(CaseNotificationmail); 
            System.debug('mails *******'+mails);
                                
            }
            
        System.debug('*******'+c.AccountId);
        //Contact relatedCaseCon = conMap.get(c.AccountId);
        for(Contact relatedCaseCon: conMap){
        System.debug('relatedCaseCon**********'+relatedCaseCon);
       
        Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
        CaseNotificationmail.setToAddresses(new List<String> { relatedCaseCon.Email });

            String subject = emailNSRLost.Subject;
            String htmlBody = emailNSRLost.HtmlValue;
            htmlBody = htmlBody.replace('{!Case.CaseNumber}', c.CaseNumber);
            if(c.Job_Name__c!=Null){
            htmlBody = htmlBody.replace('{!Case.Job_Name__c}', c.Job_Name__c);
            }
            else{
              htmlBody = htmlBody.replace('{!Case.Job_Name__c}', 'N/A');  
            }
        CaseNotificationmail.setTargetObjectId(relatedCaseCon.Id);
        CaseNotificationmail.setReplyTo('no.reply@gecurrent.com');
       // CaseNotificationmail.getToAddresses('no.reply@gecurrent.com');
        CaseNotificationmail.setUseSignature(false);
        CaseNotificationmail.setBccSender(false);

        CaseNotificationmail.setTemplateId(emailNSRLost.Id);
        CaseNotificationmail.setSubject(subject);
        CaseNotificationmail.setHtmlBody(htmlBody);    
        System.debug('CaseNotificationmail********'+CaseNotificationmail);

        CaseNotificationmail.setSaveAsActivity(false);
       // CaseNotificationmail.setSenderDisplayName('No Reply <no.reply@gecurrent.com>');            
		CaseNotificationmail.setOrgWideEmailAddressId(lstOrgWideEmailId.Id);
        mails.add(CaseNotificationmail); 
        System.debug('mails *******'+mails);
            
        }
    }
        /*Sending email template when status of New Spec Registration case status is changed to Cancelled*/ 
        if(c.GE_NAS_Sub_Type__c == 'New Specification Registration' && c.Status == 'Cancelled'){
            
        for(Account relatedCaseAccount:accMap){
            
            System.debug('relatedCaseContact**********'+relatedCaseAccount);
            Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
            CaseNotificationmail.setToAddresses(new List<String> { relatedCaseAccount.Owner.Email });
                    
            String subject = emailNSRRej.Subject;
            String htmlBody = emailNSRRej.HtmlValue;
            htmlBody = htmlBody.replace('{!Case.CaseNumber}', c.CaseNumber);
            if(c.Job_Name__c!=NUll){
            htmlBody = htmlBody.replace('{!Case.Job_Name__c}', c.Job_Name__c);
            }
            else{
              htmlBody = htmlBody.replace('{!Case.Job_Name__c}', 'N/A');  
            }
            if(c.eLight_Comments__c!=NUll){
            htmlBody = htmlBody.replace('{!Case.eLight_Comments__c}', c.eLight_Comments__c);
            }
            else{
              htmlBody = htmlBody.replace('{!Case.eLight_Comments__c}', 'N/A');  
            }
            CaseNotificationmail.setTargetObjectId(relatedCaseAccount.OwnerId);
            CaseNotificationmail.setReplyTo('no.reply@gecurrent.com');
            //CaseNotificationmail.getToAddresses('no.reply@gecurrent.com');
            CaseNotificationmail.setUseSignature(false);
            CaseNotificationmail.setBccSender(false);
            CaseNotificationmail.setTemplateId(emailNSRRej.Id);
            CaseNotificationmail.setSubject(subject);
            CaseNotificationmail.setHtmlBody(htmlBody);
            System.debug('CaseNotificationmail********'+CaseNotificationmail);
    
            CaseNotificationmail.setSaveAsActivity(false);
           // CaseNotificationmail.setSenderDisplayName('No Reply <no.reply@gecurrent.com>');            
			CaseNotificationmail.setOrgWideEmailAddressId(lstOrgWideEmailId.Id);
            mails.add(CaseNotificationmail); 
            System.debug('mails *******'+mails);
                                
            }
            
        System.debug('*******'+c.AccountId);
        //Contact relatedCaseCon = conMap.get(c.AccountId);
        for(Contact relatedCaseCon: conMap){
        System.debug('relatedCaseCon**********'+relatedCaseCon);
       
        Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
        CaseNotificationmail.setToAddresses(new List<String> { relatedCaseCon.Email });

            String subject = emailNSRRej.Subject;
            String htmlBody = emailNSRRej.HtmlValue;
            htmlBody = htmlBody.replace('{!Case.CaseNumber}', c.CaseNumber);
             if(c.Job_Name__c!=NUll){
            htmlBody = htmlBody.replace('{!Case.Job_Name__c}', c.Job_Name__c);
            }
            else{
              htmlBody = htmlBody.replace('{!Case.Job_Name__c}', 'N/A');  
            }
            if(c.eLight_Comments__c!=NUll){
            htmlBody = htmlBody.replace('{!Case.eLight_Comments__c}', c.eLight_Comments__c);
            }
            else{
              htmlBody = htmlBody.replace('{!Case.eLight_Comments__c}', 'N/A');  
            }
        CaseNotificationmail.setTargetObjectId(relatedCaseCon.Id);
        CaseNotificationmail.setReplyTo('no.reply@gecurrent.com');
       // CaseNotificationmail.getToAddresses('no.reply@gecurrent.com');
        CaseNotificationmail.setUseSignature(false);
        CaseNotificationmail.setBccSender(false);

        CaseNotificationmail.setTemplateId(emailNSRRej.Id);
        CaseNotificationmail.setSubject(subject);
        CaseNotificationmail.setHtmlBody(htmlBody);
        System.debug('CaseNotificationmail********'+CaseNotificationmail);

        CaseNotificationmail.setSaveAsActivity(false);
       // CaseNotificationmail.setSenderDisplayName('No Reply <no.reply@gecurrent.com>');            
		CaseNotificationmail.setOrgWideEmailAddressId(lstOrgWideEmailId.Id);
        mails.add(CaseNotificationmail); 
        System.debug('mails *******'+mails);
            
        }
    }
        
    }
      
    
     System.debug('Total mails *******'+mails);
    Messaging.sendEmail(mails);
        
    }
}
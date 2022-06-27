@isTest
public class caseEmailTriggerTest {
    
    @testSetup static void Testmethod12(){ 
        
       // CaseTriggerHandler.isFirstTime=False;
       
        List<Account> acclst = new List<Account>();
        List<Account> acclst1 = new List<Account>();
        List<Contact> conList = new List<Contact>();
        List<Contact> conList1 = new List<Contact>();
     
        User testUser = [Select Id, Email From User Where Email = 'deepika.sinha@gecurrent.com' limit 1];
        system.debug('mail*****'+testUser);
      //  Contact con = [Select AccountId From Contact Where ID IN(Select ContactId From User Where Id =: testUser.Id) limit 1];
        // system.debug('contact*****'+con);
         Account acc9 = new Account(Name = 'TestAcc124');
        acc9.Returns_Queue__c = 'Current Returns';
        acc9.OwnerId = testUser.Id;
        //acc9.Owner.Email = testUser.Email;
        //acc9.Pricing_Analyst__r.Email = 'pmaiil@ge.com';
        acc9.Owner=testUser;
        acc9.Pricing_Analyst__c=testUser.id;
        
        Insert acc9;
       
        Contact con = new Contact();
        con.AccountId = acc9.Id;
        //con.Name = 'Con1';
       // con.Email = 'con1@gecurrent.com';
        con.LastName = 'ConTest';
        con.FirstName = 'conFi';
        con.Title = 'Principal';
      con.Email = testUser.Email;
        insert con;
     
     
    }
    
    
@isTest
    static void emailTest(){
        CaseTriggerHandler.isFirstTime=True;
       
        Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'Pricing Request';
        ca.Status = 'Open';
        ca.eLight_Comments__c = 'Test';
        insert ca;
       
        Shipment_Detail__c sh1=new Shipment_Detail__c();
        sh1.GE_NAS_Case_Number__c=ca.id;
        insert sh1;
        
       case ca1 =new Case(Id=ca.id);
       ca1.eLight_Comments__c = 'Test';
	   update ca1; 
        
        
        Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
        CaseNotificationmail.setToAddresses(new List<String> { 'sa@ge.com' });
	       
    }
    
    
    @isTest
    static void emailTest1(){
        CaseTriggerHandler.isFirstTime=True;
       
        Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'Credit / Debit';
        ca.Status = 'Closed';
        ca.eLight_Comments__c = 'Test';
        insert ca;
       
    }
    
    @isTest
    static void emailTest2(){
        CaseTriggerHandler.isFirstTime=True;
     
        Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'Lost/Damaged';
        ca.Status = 'Open';
                ca.eLight_Comments__c = 'Test';

        insert ca;
        
    }
        @isTest
    static void emailTest3(){
        CaseTriggerHandler.isFirstTime=True;
      
         Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'Lost/Damaged';
        ca.Status = 'Closed';
                ca.eLight_Comments__c = 'Test';

        insert ca;
        
    }
        
        @isTest
    static void emailTest4(){
        CaseTriggerHandler.isFirstTime=True;
       
         Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'Shortage';
        ca.Status = 'Open';
                ca.eLight_Comments__c = 'Test';

       // insert ca;
        
    }
         @isTest
    static void emailTest5(){
        CaseTriggerHandler.isFirstTime=True;
     
         Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'Shortage';
        ca.Status = 'Closed';
                ca.eLight_Comments__c = 'Test';

        insert ca;
        
    }
         @isTest
    static void emailTest6(){
        CaseTriggerHandler.isFirstTime=True;
       
         Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'Overage';
        ca.Status = 'Open';
                ca.eLight_Comments__c = 'Test';

        insert ca;
        
    }
         @isTest
    static void emailTest7(){
        CaseTriggerHandler.isFirstTime=True;
      
         Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'Overage';
        ca.Status = 'Closed';
                ca.eLight_Comments__c = 'Test';

        insert ca;
        
    }
         @isTest
    static void emailTest8(){
    
         Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'Expedites';
        ca.Status = 'Open';
                ca.eLight_Comments__c = 'Test';

        insert ca;
        
    }
         @isTest
    static void emailTest9(){
        
   
         Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'Expedites';
        ca.Status = 'Closed';
                ca.eLight_Comments__c = 'Test';

        insert ca;
        
    }
      @isTest
    static void emailTest10(){
        
     
         Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'Change Request';
        ca.Status = 'Open';
                ca.eLight_Comments__c = 'Test';

        insert ca;
        
    }

       @isTest
    static void emailTest11(){
     
         Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'Change Request';
        ca.Status = 'Closed';
                ca.eLight_Comments__c = 'Test';

        insert ca;
        
    }

      @isTest
    static void emailTest12(){
        
      
         Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'Pricing Request';
       // insert ca;

        ca.Status = 'Open';
                ca.eLight_Comments__c = 'Test';

      //  update ca;
       insert ca; 
    }
   @isTest
    static void emailTest13(){
     
        CaseTriggerHandler.isFirstTime=True;
        Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'Pricing Request';
        ca.Status = 'Closed';
        ca.eLight_Comments__c = 'Test';
        

        insert ca;
      
        Shipment_Detail__c sh1=new Shipment_Detail__c();
        sh1.GE_NAS_Case_Number__c=ca.id;
        sh1.GE_NAS_Product_Code__c = 'test654';
        insert sh1;
        
       case ca1 =new Case(Id=ca.id);
       ca1.eLight_Comments__c = '';
	   update ca1; 
        
        
        Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
        CaseNotificationmail.setToAddresses(new List<String> { 'sa@ge.com' });
        
    }
    
    @isTest
    static void emailTest13_1(){
     
        CaseTriggerHandler.isFirstTime=True;
        Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'Pricing Request';
        ca.Status = 'Closed';
        ca.eLight_Comments__c = 'Test';

        insert ca;
      
        Shipment_Detail__c sh1=new Shipment_Detail__c();
        sh1.GE_NAS_Case_Number__c=ca.id;
        insert sh1;
        
       case ca1 =new Case(Id=ca.id);
       ca1.eLight_Comments__c = 'Test';
	   update ca1; 
        
        
        Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
        CaseNotificationmail.setToAddresses(new List<String> { 'sa@ge.com' });
        
    }
    
    
   @isTest
    static void emailTest14(){
    
         Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'Pricing Request';
      //  ca.Owner.Name = 'Test';
       // ca.OwnerId = 
        insert ca;
        
    }
    
    @isTest
    static void emailTest15(){
        

         Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'When Can I Get It?';
        ca.Status = 'Open';
      //  ca.Owner.Name = 'Test';
       // ca.OwnerId = 
       // insert ca;
        
    }
    
        @isTest
    static void emailTest16(){
        
     
         Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'When Can I Get It?';
        ca.Status = 'Closed';
      //  ca.Owner.Name = 'Test';
       // ca.OwnerId = 
        insert ca;
        
        Shipment_Detail__c sh1=new Shipment_Detail__c();
        sh1.GE_NAS_Case_Number__c=ca.id;
        insert sh1;
        
       case ca1 =new Case(Id=ca.id);
       ca1.eLight_Comments__c = 'Test';
	   update ca1; 
        
        
        Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
        CaseNotificationmail.setToAddresses(new List<String> { 'sa@ge.com' });
        
    }
    
    
        @isTest
    static void emailTest17(){
        
  
         Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'Marketing Collateral';
        ca.Status = 'Open';
      //  ca.Owner.Name = 'Test';
       // ca.OwnerId = 
        insert ca;
        
        Shipment_Detail__c sh1=new Shipment_Detail__c();
        sh1.GE_NAS_Case_Number__c=ca.id;
        insert sh1;
        
       case ca1 =new Case(Id=ca.id);
       ca1.eLight_Comments__c = 'Test';
	   update ca1; 
        
        
        Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
        CaseNotificationmail.setToAddresses(new List<String> { 'sa@ge.com' });
        
    }
    
    
    
       @isTest
    static void emailTest18(){
        
     
         Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'Marketing Collateral';
        ca.Status = 'Closed';
      //  ca.Owner.Name = 'Test';
       // ca.OwnerId = 
        insert ca;
        
        Shipment_Detail__c sh1=new Shipment_Detail__c();
        sh1.GE_NAS_Case_Number__c=ca.id;
        insert sh1;
        
       case ca1 =new Case(Id=ca.id);
       ca1.eLight_Comments__c = 'Test';
	   update ca1; 
        
        
        Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
        CaseNotificationmail.setToAddresses(new List<String> { 'sa@ge.com' });
        
    }
    
    
       @isTest
    static void emailTest19(){
        
    	CaseTriggerHandler.isFirstTime=True;
         Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'New Specification Registration';
        ca.Status = 'Open';
      //  ca.Owner.Name = 'Test';
       // ca.OwnerId = 
        insert ca;
        
        Shipment_Detail__c sh1=new Shipment_Detail__c();
        sh1.GE_NAS_Case_Number__c=ca.id;
        //insert sh1;
        
       case ca1 =new Case(Id=ca.id);
       ca1.eLight_Comments__c = 'Test';
	   update ca1; 
        
        
        Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
        CaseNotificationmail.setToAddresses(new List<String> { 'sa@ge.com' });
        
    }
    
         @isTest
    static void emailTest20(){
        
    	CaseTriggerHandler.isFirstTime=True;
        Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];       
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'New Specification Registration';
        ca.Status = 'Closed';
        ca.Spec_Reg_Agency__c = acc.id;
      //  ca.Owner.Name = 'Test';
       // ca.OwnerId = 
        insert ca;
     
        Shipment_Detail__c sh1=new Shipment_Detail__c();
        sh1.GE_NAS_Case_Number__c=ca.id;
        insert sh1;
        
       case ca1 =new Case(Id=ca.id);
       ca1.eLight_Comments__c = 'Test';
	   update ca1; 
        
        
        Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
        CaseNotificationmail.setToAddresses(new List<String> { 'sa@ge.com' });
        
    }
    
    
    
    @isTest
    static void emailTest21(){
        
    	CaseTriggerHandler.isFirstTime=True;
        Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'New Specification Registration';
        ca.Status = 'Lost';
        ca.Job_Name__c = 'job';
        ca.Spec_Reg_Agency__c = acc.id;
      //  ca.Owner.Name = 'Test';
       // ca.OwnerId = 
        insert ca;
        
        Shipment_Detail__c sh1=new Shipment_Detail__c();
        sh1.GE_NAS_Case_Number__c=ca.id;
        insert sh1;
        
       case ca1 =new Case(Id=ca.id);
       ca1.eLight_Comments__c = 'Test';
	   update ca1; 
        
        
        Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
        CaseNotificationmail.setToAddresses(new List<String> { 'sa@ge.com' });
        
    }
    
    
    
    @isTest
    static void emailTest22(){
        
     	CaseTriggerHandler.isFirstTime=True;
        Account acc =[Select id from Account where Name =: 'TestAcc124'];
        Contact con=[Select id from Contact where FirstName =: 'conFi'];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.ContactId = con.id;
        ca.GE_NAS_Sub_Type__c = 'New Specification Registration';
        ca.Status = 'Cancelled';
        ca.Spec_Reg_Agency__c = acc.id;
      //  ca.Owner.Name = 'Test';
       // ca.OwnerId = 
        insert ca;
        
        Shipment_Detail__c sh1=new Shipment_Detail__c();
        sh1.GE_NAS_Case_Number__c=ca.id;
        insert sh1;
        
       case ca1 =new Case(Id=ca.id);
       ca1.eLight_Comments__c = 'Test';
        ca1.Job_Name__c = 'job';
	   update ca1; 
        
        
        Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();  
        CaseNotificationmail.setToAddresses(new List<String> { 'sa@ge.com' });
        
    }

}
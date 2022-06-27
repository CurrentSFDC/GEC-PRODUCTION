@isTest
public class ErrorMessageDistributorControllerTest{

    public static testMethod void testValidation(){
        
        ID userID = UserInfo.getUserID();
               
        //Inserting Agent
        //ID recDirAccTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Distributor__c' AND NAME='Distributor- New Solutions and/or Controls Branch'].ID;  RQT-1475
        ID recDirAccTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Distributor__c' AND NAME='Distributor- New Solutions and/or Controls Branch Approval'].ID;    
        Distributor__c dstr_var = new Distributor__c(RecordTypeId=recDirAccTypeID);
        dstr_var.Customer_Legal_Name__c = 'Test Distributor';
        dstr_var.Billing_Address__c = 'Test Address';
        dstr_var.Billing_City__c = 'Test City';
        dstr_var.Billing_State__c = 'Test State';
        dstr_var.Billing_Postal_Code__c = '11111';
        dstr_var.Billing_Contact_Name__c = 'Test Contact';
        dstr_var.Billing_Contact_Phone__c = '23456' ;
        dstr_var.Billing_Contact_Email__c = 'test@test.com';
        dstr_var.GE_Sales_Contact__c = userID; 
        dstr_var.Status__c = 'Not Submitted';
        dstr_var.Mail_To_Same_as_Bill_To__c = true;
        dstr_var.Shipping_Information_Same_as_Bi__c=true;
        dstr_var.Core_choose_all_that_apply__c='Sensors'; 
        dstr_var.Solutions_choose_all_that_apply__c='Traffic Products'; 
        dstr_var.Requested_Terms__c = 'Standard';  
        dstr_var.Estimated_Annual_Volume_in_Dollars__c = 123;
        dstr_var.Amount_of_First_Order__c=234;
        dstr_var.Does_Customer_Have_EDI_Capability__c='Yes';
        dstr_var.Customer_On_Electronic_Funds_Tra__c = 'No';
        dstr_var.Is_the_Customer_Tax_Exempt__c='No';
        dstr_var.Equipped_to_Handle_GE_Product__c = 'Yes';
        date myDate = date.today();
        dstr_var.Date_of_Visit_by_Account_Manager__c = myDate ;
        dstr_var.GE_Sales_Representative_Contact_Core__c =userID; 
        dstr_var.GE_Sales_Representative_Core__c = 'test';
        dstr_var.Region_District_Core__c = 'test';
        dstr_var.GE_Sales_Rep_Contact_Solutions__c=userID; 
        dstr_var.GE_Sales_Rep_Solutions__c = 'test';
        dstr_var.Region_District_Solutions__c = 'test'; 
        dstr_var.LAMP_BALLAST__c = true;
        dstr_var.Account_Released__c=False;
        test.startTest();      
        insert dstr_var;
         Distributor__c testDstr=[select id,Customer_Legal_Name__c,Status__c from Distributor__c  where id=:dstr_var.id limit 1];
        System.assertEquals(dstr_var.Customer_Legal_Name__c,testDstr.Customer_Legal_Name__c);
        System.assertEquals(dstr_var.Status__c ,testDstr.Status__c );
        
        PageReference pageRef = Page.ErrorMessageDistributorDisplay;
        Test.setCurrentPage(pageRef);      
        
        dstr_var.State_Province_1__c = null;
        dstr_var.Counties_State_1__c = null;
        dstr_var.Status__c = 'Not Submitted';
        pageRef.getParameters().put('id',dstr_var.id);
        ApexPages.StandardController sc = new ApexPages.standardController(dstr_var);
        ErrorMessageDistributorController emc = new ErrorMessageDistributorController(sc);
        //emc.coverageErrorMsg(dstr_var);

        dstr_var.Status__c = 'Risk Review';
        dstr_var.State_Province_1__c = 'AB';
        dstr_var.Counties_State_1__c = 'Alberta - C01';
        dstr_var.Sales_Office_Solutions__c = null;
        //emc.riskReview(dstr_var);
        
        dstr_var.Status__c = 'Legal Review';
        dstr_var.Is_the_contract_attached__c = null;
        emc.legalReview(dstr_var);
        dstr_var.Status__c = 'test';
        emc.legalReview(dstr_var);
        //emc.riskReview(dstr_var);
        test.stopTest();
    }
    
    
    public static testMethod void testValidation2(){
        
        ID userID = UserInfo.getUserID();
               
        //Inserting Agent
        //ID recDirAccTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Distributor__c' AND NAME='Distributor- New Solutions and/or Controls Branch'].ID; RQT-1475
        ID recDirAccTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Distributor__c' AND NAME='Distributor- New Solutions and/or Controls Branch Approval'].ID;
        Distributor__c dstr_var = new Distributor__c(RecordTypeId=recDirAccTypeID);
        dstr_var.Customer_Legal_Name__c = 'Test Distributor';
        dstr_var.Billing_Address__c = 'Test Address';
        dstr_var.Billing_City__c = 'Test City';
        dstr_var.Billing_State__c = 'Test State';
        dstr_var.Billing_Postal_Code__c = '11111';
        dstr_var.Billing_Contact_Name__c = 'Test Contact';
        dstr_var.Billing_Contact_Phone__c = '23456' ;
        dstr_var.Billing_Contact_Email__c = 'test@test.com';
        dstr_var.GE_Sales_Contact__c = userID; 
        dstr_var.Status__c = 'Not Submitted';
        dstr_var.Mail_To_Same_as_Bill_To__c = true;
        dstr_var.Shipping_Information_Same_as_Bi__c=true;
        dstr_var.Core_choose_all_that_apply__c='Sensors'; 
        dstr_var.Solutions_choose_all_that_apply__c='Traffic Products'; 
        dstr_var.Requested_Terms__c = 'Standard';  
        dstr_var.Estimated_Annual_Volume_in_Dollars__c = 123;
        dstr_var.Amount_of_First_Order__c=234;
        dstr_var.Does_Customer_Have_EDI_Capability__c='Yes';
        dstr_var.Customer_On_Electronic_Funds_Tra__c = 'No';
        dstr_var.Is_the_Customer_Tax_Exempt__c='No';
        dstr_var.Equipped_to_Handle_GE_Product__c = 'Yes';
        date myDate = date.today();
        dstr_var.Date_of_Visit_by_Account_Manager__c = myDate ;
        dstr_var.GE_Sales_Representative_Contact_Core__c =userID; 
        dstr_var.GE_Sales_Representative_Core__c = 'test';
        dstr_var.Region_District_Core__c = 'test';
        dstr_var.GE_Sales_Rep_Contact_Solutions__c=userID; 
        dstr_var.GE_Sales_Rep_Solutions__c = 'test';
        dstr_var.Region_District_Solutions__c = 'test'; 
        dstr_var.LAMP_BALLAST__c = true;
        dstr_var.Account_Released__c=False;
        dstr_var.State_Province_1__c = 'CA';
        test.startTest();      
        insert dstr_var;
        
         Distributor__c testDstr=[select id,Customer_Legal_Name__c,Status__c from Distributor__c  where id=:dstr_var.id limit 1];
        System.assertEquals(dstr_var.Customer_Legal_Name__c,testDstr.Customer_Legal_Name__c);
        System.assertEquals(dstr_var.Status__c ,testDstr.Status__c );
        PageReference pageRef = Page.ErrorMessageDistributorDisplay;
        Test.setCurrentPage(pageRef);      
        

        dstr_var.Counties_State_1__c = null;
        dstr_var.Status__c = 'Not Submitted';
        pageRef.getParameters().put('id',dstr_var.id);
        ApexPages.StandardController sc = new ApexPages.standardController(dstr_var);
        ErrorMessageDistributorController emc = new ErrorMessageDistributorController(sc);
        //emc.coverageErrorMsg(dstr_var);

        dstr_var.Status__c = 'Risk Review';
        dstr_var.State_Province_1__c = 'AB';
        dstr_var.Counties_State_1__c = 'Alberta - C01';
        dstr_var.Sales_Office_Solutions__c = null;
        //emc.riskReview(dstr_var);
        
        dstr_var.Status__c = 'Legal Review';
        dstr_var.Is_the_contract_attached__c = null;
        emc.legalReview(dstr_var);
        dstr_var.Status__c = 'test';
        emc.legalReview(dstr_var);
        //emc.riskReview(dstr_var);
        test.stopTest();
    }
    
    
    public static testMethod void testDECValidations(){              
        //Inserting Agent
        ID userID = UserInfo.getUserID();
        ID recdaTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Distributor__c' AND DEVELOPERNAME='Distributor_End_Customer'].ID;
        Distributor__c dstr = new Distributor__c(RecordTypeId=recdaTypeID);
        dstr.Status__c = 'Not Submitted';
        dstr.Account_Type__c = 'End Customer';
        dstr.Customer_Legal_Name__c = 'test';
        dstr.Additional_Information__c = 'test';
        dstr.Country__c='US';
        dstr.Address__c = 'test';
        dstr.State_Province__c  ='test';
        dstr.City__c = 'test';
        dstr.Zip_Postal_Code__c = '12345';
        dstr.Website__c = 'www.test.com';
        dstr.Sales_Channel__c = 'PREJECT RETAIL';
        dstr.Customer_Classification__c = 'A';
        dstr.Intercompany__c = 'Yes';
        dstr.Sales_Channel_Leader__c = UserInfo.getUserId();
        dstr.Sales_GE__c = UserInfo.getUserId();
        dstr.Requested_Credit_Line_USD__c = '123';
        dstr.Requested_Payment_Term_days__c = '5';
        dstr.Is_Financial_Statement_Attached__c = 'Yes';
        dstr.Is_Act_of_Constitution_Attached__c = 'Yes';
        dstr.Is_Channel_Partner_Request_Form_Attached__c = 'Yes';
        dstr.IFN_INDOOR_FIXTURE_NON_LED__c = true;
        dstr.Automotive_Applications_Only__c=true;
        insert dstr;
         Distributor__c testDstr=[select id,Customer_Legal_Name__c,Status__c from Distributor__c  where id=:dstr.id limit 1];
        System.assertEquals(dstr.Customer_Legal_Name__c,testDstr.Customer_Legal_Name__c);
        System.assertEquals(dstr.Status__c ,testDstr.Status__c );
        dstr.Status__c = 'Compliance Review';
        PageReference pageRef = Page.ErrorMessageDistributorDisplay;
        Test.setCurrentPage(pageRef);      
        
        pageRef.getParameters().put('id',dstr.id);
        ApexPages.StandardController sc = new ApexPages.standardController(dstr);
        ErrorMessageDistributorController emc = new ErrorMessageDistributorController(sc);
        dstr.Master_Contract_ID__c = null;
        dstr.Status__c = 'Compliance Review';
        //emc.complianceErrorMsgSR(dstr);
        
        dstr.Status__c = 'Credit/Risk Review';
        dstr.Customer_Rating__c = null;
        emc.riskReviewErrorMsgDEC(dstr);
    }
    
        public static testMethod void testSRValidations(){              
        //Inserting Agent
        ID userID = UserInfo.getUserID();
        ID recdaTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Distributor__c' AND DEVELOPERNAME='Sales_Rep'].ID;
        Distributor__c dstr = new Distributor__c(RecordTypeId=recdaTypeID);
        dstr.Status__c = 'Not Submitted';
        dstr.Account_Type__c = 'Sales Rep';
        dstr.Customer_Legal_Name__c = 'test';
        dstr.Additional_Information__c = 'test';
        dstr.Country__c='US';
        dstr.Address__c = 'test';
        dstr.State_Province__c  ='test';
        dstr.City__c = 'test';
        dstr.Zip_Postal_Code__c = '12345';
        dstr.Website__c = 'www.test.com';
        dstr.Sales_Channel__c = 'PREJECT RETAIL';
        dstr.Customer_Classification__c = 'A';
        dstr.Intercompany__c = 'Yes';
        dstr.Sales_Channel_Leader__c = UserInfo.getUserId();
        dstr.Sales_GE__c = UserInfo.getUserId();
        dstr.Requested_Credit_Line_USD__c = '123';
        dstr.Requested_Payment_Term_days__c = '5';
        dstr.Is_Financial_Statement_Attached__c = 'Yes';
        dstr.Is_Act_of_Constitution_Attached__c = 'Yes';
        dstr.Is_Channel_Partner_Request_Form_Attached__c = 'Yes';
        dstr.IFN_INDOOR_FIXTURE_NON_LED__c = true;
         dstr.Automotive_Applications_Only__c=true;
        insert dstr; 
        
         Distributor__c testDstr=[select id,Customer_Legal_Name__c,Status__c from Distributor__c  where id=:dstr.id limit 1];
        System.assertEquals(dstr.Customer_Legal_Name__c,testDstr.Customer_Legal_Name__c);
        System.assertEquals(dstr.Status__c ,testDstr.Status__c );
        dstr.Status__c = 'Compliance Review';
        PageReference pageRef = Page.ErrorMessageDistributorDisplay;
        Test.setCurrentPage(pageRef);       
        pageRef.getParameters().put('id',dstr.id);
        ApexPages.StandardController sc = new ApexPages.standardController(dstr);
        ErrorMessageDistributorController emc = new ErrorMessageDistributorController(sc);
        dstr.Master_Contract_ID__c = null;
        dstr.Status__c = 'Compliance Review';
        emc.complianceErrorMsgSR(dstr);
    }
    
    
      public static testMethod void solarAccountSetupTest(){
        //Distributor- New Solutions and/or Controls Branch test 
        test.startTest();
        //ID recdaTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Distributor__c' AND DEVELOPERNAME='Solar_Account_Setup'].ID;
        ID recdaTypeID = Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Solar Account Setup').getRecordTypeId();
        Distributor__c dstr_var = new Distributor__c();//RecordTypeId=recdaTypeID
        dstr_var.Customer_Legal_Name__c = 'Test Distributor';
        dstr_var.Type_of_Setup__c = 'Contract';
        dstr_var.Customer_DBA_Name__c = 'Test';
        dstr_var.Billing_Address__c = 'Test Address ';
        dstr_var.Billing_City__c = 'Test City';
        dstr_var.Billing_State__c = 'Test State';
        dstr_var.Billing_Postal_Code__c = '11111';
        dstr_var.Billing_Contact_Name__c = 'Test Contact';
        dstr_var.Billing_Contact_Phone__c = '23456' ;
        dstr_var.Billing_Contact_Email__c = 'test@test123.com';
        dstr_var.Status__c = 'test';
        dstr_var.Mail_To_Same_as_Bill_To__c = true;
        dstr_var.Shipping_Information_Same_as_Bi__c=true;
        dstr_var.Contract_Agreement_Attached__c = 'Yes';
        dstr_var.Invoices_statements_to_be_emailed_faxed__c = 'faxed';
        dstr_var.GE_LGT_Contact_Information__c = 'test';
       // dstr_var.What_currency_are_we_billing__c = 'USD';
        dstr_var.All_product_lines_except_Automotive__c = true;
        dstr_var.LTGRAP_Reference_Applications__c = true;
        System.debug('dstr_var::::::::::::::::::::::'+dstr_var.id);
        insert dstr_var;    
        Distributor__c testDstr=[select id,Customer_Legal_Name__c,Status__c from Distributor__c  where id=:dstr_var.id limit 1];
        System.assertEquals(dstr_var.Customer_Legal_Name__c,testDstr.Customer_Legal_Name__c);
        //System.assertEquals(dstr_var.Status__c ,testDstr.Status__c );
        PageReference pageRef = Page.ErrorMessageDistributorDisplay;
        Test.setCurrentPage(pageRef);      
        
        pageRef.getParameters().put('id',dstr_var.id);
        ApexPages.StandardController sc = new ApexPages.standardController(dstr_var);
        ErrorMessageDistributorController emc = new ErrorMessageDistributorController(sc);
        dstr_var.Sales_Office_Solutions__c = null;
        dstr_var.Status__c = 'Risk Review'; 
        emc.solarRiskReview(dstr_var);

        dstr_var.Account_Solutions_Controls__c = null;
        dstr_var.Status__c = 'Risk Setup';
        emc.riskSetup(dstr_var);

    }
    
}
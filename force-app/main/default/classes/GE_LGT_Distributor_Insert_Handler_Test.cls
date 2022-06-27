@isTest/*(seeAllData=true)*/
Public Class GE_LGT_Distributor_Insert_Handler_Test{
    
    static testMethod void distNeWSolAndOrCntrlBranchDistTest(){
        //Distributor- New Solutions and/or Controls Branch test 
        test.startTest();
        //ID recDirAccTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Distributor__c' AND NAME='Distributor- New Solutions and/or Controls Branch'].ID;    
        ID recDirAccTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Distributor__c' AND NAME='Distributor- New Core Branch Approvals'].ID;
        Distributor__c dstr_var = new Distributor__c(RecordTypeId=recDirAccTypeID);
        dstr_var.Customer_Legal_Name__c = 'Test Distributor';
        dstr_var.Billing_Address__c = 'Test Address ';
        dstr_var.Billing_City__c = 'Test City';
        dstr_var.Billing_State__c = 'Test State';
        dstr_var.Billing_Postal_Code__c = '11111';
        dstr_var.Billing_Contact_Name__c = 'Test Contact';
        dstr_var.Billing_Contact_Phone__c = '23456' ;
        dstr_var.Billing_Contact_Email__c = 'test@test123.com';
        dstr_var.GE_Sales_Contact__c=UserInfo.getUserId();
        dstr_var.Status__c = 'test';
        dstr_var.Mail_To_Same_as_Bill_To__c = true;
        dstr_var.Shipping_Information_Same_as_Bi__c=true;
        dstr_var.Core_choose_all_that_apply__c='Sensors'; //multi-select picklist
        dstr_var.Solutions_choose_all_that_apply__c='Traffic Products'; ////multi-select picklist
        dstr_var.Requested_Terms__c = 'Standard';  
        dstr_var.Estimated_Annual_Volume_in_Dollars__c = 123;
        dstr_var.Amount_of_First_Order__c=234;
        dstr_var.Does_Customer_Have_EDI_Capability__c='Yes';
        dstr_var.Customer_On_Electronic_Funds_Tra__c = 'No';
        dstr_var.Is_the_Customer_Tax_Exempt__c='No';
        dstr_var.Equipped_to_Handle_GE_Product__c = 'Yes';
        date myDate = date.today();
        dstr_var.Date_of_Visit_by_Account_Manager__c = myDate ;
        dstr_var.GE_Sales_Representative_Contact_Core__c  =UserInfo.getUserId();
        dstr_var.GE_Sales_Representative_Core__c = 'test';
        dstr_var.Region_District_Core__c = 'test neel';
        dstr_var.GE_Sales_Rep_Contact_Solutions__c= UserInfo.getUserId();
        dstr_var.GE_Sales_Rep_Solutions__c = 'test';
        dstr_var.Region_District_Solutions__c = 'test';
        dstr_var.Account_Released__c=False;
        dstr_var.IFN_INDOOR_FIXTURE_NON_LED__c = true;
        insert dstr_var;    
        dstr_var.Status__c = 'Exec Review'; 
        dstr_var.State_Province_1__c =null; 
        dstr_var.Counties_State_1__c='';   
        try{  
            update dstr_var;
        }
        catch(exception e){}
        dstr_var.Status__c = 'Legal Approved';
        dstr_var.Is_the_contract_attached__c = null;
        try{  
            update dstr_var;
        }
        catch(exception e){}
        dstr_var.Status__c = 'Compliance Review';
        dstr_var.Sales_Office_Solutions__c = null;
        try{  
            update dstr_var;
            
        }
        catch(Exception exc10210){
            Boolean expectedExceptionThrown10210 =  exc10210.getMessage().contains('Please fill information under Coverage section to submit for approval.') ? true : false;
            System.AssertEquals(expectedExceptionThrown10210, false);
        }    
        try{  
            
            dstr_var.Status__c = 'Complete';
            update dstr_var;   
        }
        catch(Exception exc10210){
            Boolean expectedExceptionThrown10210 =  exc10210.getMessage().contains('Please complete information under the Setup Requirement Section') ? true : false;
            System.AssertEquals(expectedExceptionThrown10210, true);
        }  
    }
    
    static testMethod void distNewCoreSolAndCntrlsBranchDistTest(){
        //Distributor- New Core, Solutions and Controls Branch test 
        ID recNewCoreSolutionsandControlsBranchTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Distributor__c' AND NAME='Distributor- New Core, Solutions and Controls Branch'].ID;
        Distributor__c dstr_var = new Distributor__c(RecordTypeId=recNewCoreSolutionsandControlsBranchTypeID);
        dstr_var.Customer_Legal_Name__c = 'Test Distributor';
        dstr_var.Billing_Address__c = 'Test Address';
        dstr_var.Billing_City__c = 'Test City';
        dstr_var.Billing_State__c = 'Test State';
        dstr_var.Billing_Postal_Code__c = '11111';
        dstr_var.Billing_Contact_Name__c = 'Test Contact';
        dstr_var.Billing_Contact_Phone__c = '23456' ;
        dstr_var.Billing_Contact_Email__c = 'test@test123.com';
        dstr_var.GE_Sales_Contact__c= UserInfo.getUserId();
        dstr_var.Status__c = 'Test';
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
        dstr_var.GE_Sales_Rep_Contact_Solutions__c= UserInfo.getUserId();
        dstr_var.GE_Sales_Rep_Solutions__c = 'test';
        dstr_var.Region_District_Solutions__c = 'test';
        dstr_var.Account_Released__c=False;
        dstr_var.IFN_INDOOR_FIXTURE_NON_LED__c = true;
        insert dstr_var;
        try{
            dstr_var.Status__c='Exec Review';
            update dstr_var;
        }
        catch(Exception exc10210){
            Boolean expectedExceptionThrown10210 =  exc10210.getMessage().contains('Following fields are mandatory') ? true : false;
            System.AssertEquals(expectedExceptionThrown10210, false);    
        }
        
        try{   
            dstr_var.Status__c='Compliance Review';
            update dstr_var;
        }
        catch(Exception exc10210){
            Boolean expectedExceptionThrown10210 =  exc10210.getMessage().contains('Following fields are mandatory') ? true : false;
            System.AssertEquals(expectedExceptionThrown10210, false);    
        }
        try{
            dstr_var.Status__c= 'Legal Approved';
            update dstr_var;
        }
        catch(Exception exc10210){
            Boolean expectedExceptionThrown10210 =  exc10210.getMessage().contains('Following fields are mandatory') ? true : false;
           // Boolean expectedExceptionThrown10210 =  exc10210.getMessage().contains('Please attach contract to move to the next step in approval.') ? true : false;            
            System.AssertEquals(expectedExceptionThrown10210, false);    
        }
        try{
            dstr_var.Status__c = 'Complete';
            update dstr_var;
        }
        catch(Exception exc10210){
            Boolean expectedExceptionThrown10210 =  exc10210.getMessage().contains('Following fields are mandatory') ? true : false;
            System.AssertEquals(expectedExceptionThrown10210, false);    
        }
        
        try{
            dstr_var.Status__c = 'Ship To';
            update dstr_var;
        }
        catch(Exception exc10210){
            Boolean expectedExceptionThrown10210 =  exc10210.getMessage().contains('Please complete information under the Setup Requirement Section') ? true : false;
            //System.AssertEquals(expectedExceptionThrown10210, false);    
        }
        
        
        
    }
    
    static testMethod void getDistributorAddress4(){
        //New Direct Account Setup/Direct Account Branch Setup test code begins
        ID recdaTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Distributor__c' AND NAME='Direct Account Setup/Direct Account Branch Setup'].ID;
        Distributor__c dstr_var4 = new Distributor__c(RecordTypeId=recdaTypeID);
        dstr_var4.Customer_Legal_Name__c = 'Test Distributor';
        dstr_var4.Billing_Address__c = 'Test Address';
        dstr_var4.Billing_City__c = 'Test City';
        dstr_var4.Billing_State__c = 'Test State';
        dstr_var4.Billing_Postal_Code__c = '11111';
        dstr_var4.Billing_Contact_Name__c = 'Test Contact';
        dstr_var4.Billing_Contact_Phone__c = '23456' ;
        dstr_var4.Billing_Contact_Email__c = 'test@test123.com';
        dstr_var4.GE_Sales_Contact__c= UserInfo.getUserId() ;
        dstr_var4.Status__c = 'Test';
        dstr_var4.GE_LGT_Minor_Channel__c ='';
        dstr_var4.GE_LGT_Vertical__c='';
        dstr_var4.Mail_To_Same_as_Bill_To__c = true;
        dstr_var4.Shipping_Information_Same_as_Bi__c=true;
        dstr_var4.Core_choose_all_that_apply__c='Sensors'; 
        dstr_var4.Solutions_choose_all_that_apply__c='Traffic Products';
        dstr_var4.Requested_Terms__c = 'Standard';  
        dstr_var4.Estimated_Annual_Volume_in_Dollars__c = 123;
        dstr_var4.Amount_of_First_Order__c=234;
        dstr_var4.Does_Customer_Have_EDI_Capability__c='Yes';
        dstr_var4.Customer_On_Electronic_Funds_Tra__c = 'No';
        dstr_var4.Is_the_Customer_Tax_Exempt__c='No';
        dstr_var4.Equipped_to_Handle_GE_Product__c = 'Yes';
        date myDate1 = date.today();
        dstr_var4.Date_of_Visit_by_Account_Manager__c = myDate1 ;
        dstr_var4.GE_Sales_Representative_Contact_Core__c =UserInfo.getUserId();
        dstr_var4.GE_Sales_Representative_Core__c = 'test neel';
        dstr_var4.Region_District_Core__c = 'test neel';
        dstr_var4.GE_Sales_Rep_Contact_Solutions__c=UserInfo.getUserId(); 
        dstr_var4.GE_Sales_Rep_Solutions__c = 'test neel';
        dstr_var4.Region_District_Solutions__c = 'test neel'; 
        dstr_var4.Account_Released__c=True;
        dstr_var4.GE_LGT_Minor_Channel__c='';
        dstr_var4.Type_of_Setup__c='Contract';
        dstr_var4.Channel__c='Utility';
        dstr_var4.GE_LGT_GM_Region_Exec__c=UserInfo.getUserId();
        dstr_var4.GE_LGT_Product_Line__c='Solutions';
        dstr_var4.IFN_INDOOR_FIXTURE_NON_LED__c = true;
        insert dstr_var4;        
        test.startTest();          
        try{            
            dstr_var4.Status__c = 'Compliance Review';
            update dstr_var4;
        }
        catch(Exception exc10210){
            Boolean expectedExceptionThrown10210 =  exc10210.getMessage().contains('Following fields are mandatory') ? true : false;
            System.AssertEquals(expectedExceptionThrown10210, false);    
        }
        try{
            dstr_var4.Status__c = 'Compliance Approved';
            update dstr_var4;
        }
        catch(Exception exc10210){
            Boolean expectedExceptionThrown10210 =  exc10210.getMessage().contains('Following fields are mandatory') ? true : false;
            System.AssertEquals(expectedExceptionThrown10210, false);    
        }
        try{
            dstr_var4.Status__c = 'Complete';
            update dstr_var4; 
        }
        catch(Exception exc10210){
            Boolean expectedExceptionThrown10210 =  exc10210.getMessage().contains('Following fields are mandatory') ? true : false;
            System.AssertEquals(expectedExceptionThrown10210, false);    
        }   
        
        /*try{
            dstr_var4.Status__c = 'Risk Approved';
            update dstr_var4; 
        }
        catch(Exception exc10210){
            Boolean expectedExceptionThrown10210 =  exc10210.getMessage().contains('Please Complete Information under the Risk Review and Setup Requirement Sections.') ? true : false;
            System.AssertEquals(expectedExceptionThrown10210, false);    
        }*/
        
        try{
            dstr_var4.Status__c = 'Ship To';
            update dstr_var4; 
        }
        catch(Exception exc10210){
            Boolean expectedExceptionThrown10210 =  exc10210.getMessage().contains('Please complete information under the Setup Requirement Section') ? true : false;
           // System.AssertEquals(expectedExceptionThrown10210, false);    
        }   
        test.stopTest();
    }
    
    
    static testMethod void getDistributorAddress17()
    {    test.startTest(); 
     //New Direct Account Setup/Direct Account Branch Setup test code begins
     ID userID = UserInfo.getUserID();
     //ID recdaTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Distributor__c' AND DEVELOPERNAME='New_Core_Distributor'].ID; RQT0-1475
     ID recdaTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Distributor__c' AND DEVELOPERNAME='New_Core_Solutions_and_Controls_Distributor'].ID;
     Distributor__c dstr_var4 = new Distributor__c(RecordTypeId=recdaTypeID);
     dstr_var4.Customer_Legal_Name__c = 'Test Distributor';
     dstr_var4.Billing_Address__c = 'Test Address';
     dstr_var4.Billing_City__c = 'Test City';
     dstr_var4.Billing_State__c = 'Test State';
     dstr_var4.Billing_Postal_Code__c = '11111';
     dstr_var4.Billing_Contact_Name__c = 'Test Contact';
     dstr_var4.Billing_Contact_Phone__c = '23456' ;
     dstr_var4.Billing_Contact_Email__c = 'test@test123.com';
     dstr_var4.GE_Sales_Contact__c= UserInfo.getUserId();
     dstr_var4.Status__c = 'Test';
     dstr_var4.GE_LGT_Minor_Channel__c ='';
     dstr_var4.GE_LGT_Vertical__c='';
     dstr_var4.Mail_To_Same_as_Bill_To__c = true;
     dstr_var4.Shipping_Information_Same_as_Bi__c=true;
     dstr_var4.Core_choose_all_that_apply__c='Sensors'; 
     dstr_var4.Solutions_choose_all_that_apply__c='Traffic Products'; 
     dstr_var4.Requested_Terms__c = 'Standard';  
     dstr_var4.Estimated_Annual_Volume_in_Dollars__c = 123;
     dstr_var4.Amount_of_First_Order__c=234;
     dstr_var4.Does_Customer_Have_EDI_Capability__c='Yes';
     dstr_var4.Customer_On_Electronic_Funds_Tra__c = 'No';
     dstr_var4.Is_the_Customer_Tax_Exempt__c='No';
     dstr_var4.Equipped_to_Handle_GE_Product__c = 'Yes';
     date myDate1 = date.today();
     dstr_var4.Date_of_Visit_by_Account_Manager__c = myDate1 ;
     dstr_var4.GE_Sales_Representative_Contact_Core__c = UserInfo.getUserId();
     dstr_var4.GE_Sales_Representative_Core__c = 'test neel';
     dstr_var4.Region_District_Core__c = 'test neel';
     dstr_var4.GE_Sales_Rep_Contact_Solutions__c = userID;       
     dstr_var4.GE_Sales_Rep_Solutions__c = 'test neel';
     dstr_var4.Region_District_Solutions__c = 'test neel';
     dstr_var4.Account_Released__c=True;
     dstr_var4.GE_LGT_Minor_Channel__c='';
     dstr_var4.Type_of_Setup__c='Contract';
     dstr_var4.Channel__c='Utility';
     dstr_var4.D_B_Check__c=false;
     dstr_var4.GE_LGT_Sabrix_Setup_Complete__c=false;
     dstr_var4.GE_LGT_GM_Region_Exec__c= UserInfo.getUserId();
     dstr_var4.LAMP_BALLAST__c = true; 
     dstr_var4.Status__c = 'Exec Review';
     insert dstr_var4;
     try
     { 
         dstr_var4.Status__c ='Compliance Review';
         update dstr_var4;
     }
     catch(Exception exc10210){
         Boolean expectedExceptionThrown10210 =  exc10210.getMessage().contains('Following fields are mandatory') ? true : false;
         System.AssertEquals(expectedExceptionThrown10210, false);    
     } 
     try{
         dstr_var4.Status__c = 'Legal Approved';
         update dstr_var4;
     }
     catch(Exception exc10210){
         Boolean expectedExceptionThrown10210 =  exc10210.getMessage().contains('Following fields are mandatory') ? true : false;
         System.AssertEquals(expectedExceptionThrown10210, false);    
     } 
     try{
         dstr_var4.Status__c = 'Complete';
         update dstr_var4; 
     }        
     catch(Exception exc10210){
         Boolean expectedExceptionThrown10210 =  exc10210.getMessage().contains('Following fields are mandatory') ? true : false;
         System.AssertEquals(expectedExceptionThrown10210, false);    
     } 
     
     test.stopTest();
    }
    
    
    static testMethod void latamDistributorEndUser_CustomerTest()
    {    test.startTest(); 
     //New Direct Account Setup/Direct Account Branch Setup test code begins
     ID userID = UserInfo.getUserID();
     ID recdaTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Distributor__c' AND DEVELOPERNAME='Distributor_End_Customer'].ID;
     Distributor__c dstr = new Distributor__c(RecordTypeId=recdaTypeID);
     dstr.Status__c = 'Test';
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
     dstr.All_product_lines_except_Automotive__c = TRUE;
     dstr.Automotive_Applications_Only__c  = TRUE;
     insert dstr;
     
     try
     { 
         dstr.Status__c = 'Compliance Approved';
         dstr.Master_Contract_ID__c = ''; 
         update dstr;
         
     }        
     catch(exception e)
     {
     }
     
     try{
         dstr.Status__c ='Risk Approved';
         update dstr;
     }
     catch(Exception e){}
     
     test.stopTest();
    }
    
    /*static testMethod void distNeWSolarTest()
    {
        //--> COMMENTED OUT BY MG: RQT-1023
        //Distributor- New Solutions and/or Controls Branch test 
        test.startTest();
        ID recDirAccTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Distributor__c' AND NAME='Solar Account Setup'].ID;    
        Distributor__c dstr_var = new Distributor__c(RecordTypeId=recDirAccTypeID);
        dstr_var.Customer_Legal_Name__c = 'Test Distributor';
        dstr_var.Billing_Address__c = 'Test Address ';
        dstr_var.Billing_City__c = 'Test City';
        dstr_var.Billing_State__c = 'Test State';
        dstr_var.Billing_Postal_Code__c = '11111';
        dstr_var.Billing_Contact_Name__c = 'Test Contact';
        dstr_var.Billing_Contact_Phone__c = '23456' ;
        dstr_var.Billing_Contact_Email__c = 'test@test123.com';
        dstr_var.GE_Sales_Contact__c=UserInfo.getUserId();
        dstr_var.Status__c = 'test';
        dstr_var.Mail_To_Same_as_Bill_To__c = true;
        dstr_var.Shipping_Information_Same_as_Bi__c=true;
        dstr_var.Core_choose_all_that_apply__c='Sensors'; //multi-select picklist
        dstr_var.Solutions_choose_all_that_apply__c='Traffic Products'; ////multi-select picklist
        dstr_var.Requested_Terms__c = 'Standard';  
        dstr_var.Estimated_Annual_Volume_in_Dollars__c = 123;
        dstr_var.Amount_of_First_Order__c=234;
        dstr_var.Does_Customer_Have_EDI_Capability__c='Yes';
        dstr_var.Customer_On_Electronic_Funds_Tra__c = 'No';
        dstr_var.Is_the_Customer_Tax_Exempt__c='No';
        dstr_var.Equipped_to_Handle_GE_Product__c = 'Yes';
        date myDate = date.today();
        dstr_var.Date_of_Visit_by_Account_Manager__c = myDate ;
        dstr_var.GE_Sales_Representative_Contact_Core__c  =UserInfo.getUserId();
        dstr_var.GE_Sales_Representative_Core__c = 'test';
        dstr_var.Region_District_Core__c = 'test neel';
        dstr_var.GE_Sales_Rep_Contact_Solutions__c= UserInfo.getUserId();
        dstr_var.GE_Sales_Rep_Solutions__c = 'test';
        dstr_var.Region_District_Solutions__c = 'test';
        dstr_var.Account_Released__c=False;
        dstr_var.IFN_INDOOR_FIXTURE_NON_LED__c = true;
        insert dstr_var;    
        dstr_var.State_Province_1__c =null; 
        dstr_var.Counties_State_1__c=''; 
        try
        {  
            dstr_var.Status__c = 'Complete';
            update dstr_var;
        }
        catch(exception exc)
        {
            Boolean expectedExceptionThrown10210 =  exc.getMessage().contains('Please fill in details for Recommended Credit Line, Account Currency, Financials Available and Requires DOA Approvals under') ? true : false;
            System.AssertEquals(expectedExceptionThrown10210, false);
        }
        try
        {  
            dstr_var.Status__c = 'Commercial Finance Review';
            update dstr_var;
        }
        catch(exception exc)
        {
            Boolean expectedExceptionThrown10210 =  exc.getMessage().contains('Please Complete Information under the Risk Review and Setup Requirement Sections.') ? true : false;
            System.AssertEquals(expectedExceptionThrown10210, true);
        }
    }*/ //--> COMMENTED OUT BY MG: RQT-1023
    
    static testMethod void distLatamSalesTest()
    {
        //Distributor- New Solutions and/or Controls Branch test 
        test.startTest();
        ID recDirAccTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Distributor__c' AND NAME='Latam - Sales Rep'].ID;    
        Distributor__c dstr_var = new Distributor__c(RecordTypeId=recDirAccTypeID);
        dstr_var.Customer_Legal_Name__c = 'Test Distributor';
        dstr_var.Billing_Address__c = 'Test Address ';
        dstr_var.Billing_City__c = 'Test City';
        dstr_var.Billing_State__c = 'Test State';
        dstr_var.Billing_Postal_Code__c = '11111';
        dstr_var.Billing_Contact_Name__c = 'Test Contact';
        dstr_var.Billing_Contact_Phone__c = '23456' ;
        dstr_var.Billing_Contact_Email__c = 'test@test123.com';
        dstr_var.GE_Sales_Contact__c=UserInfo.getUserId();
        dstr_var.Status__c = 'test';
        dstr_var.Mail_To_Same_as_Bill_To__c = true;
        dstr_var.Shipping_Information_Same_as_Bi__c=true;
        dstr_var.Core_choose_all_that_apply__c='Sensors'; //multi-select picklist
        dstr_var.Solutions_choose_all_that_apply__c='Traffic Products'; ////multi-select picklist
        dstr_var.Requested_Terms__c = 'Standard';  
        dstr_var.Estimated_Annual_Volume_in_Dollars__c = 123;
        dstr_var.Amount_of_First_Order__c=234;
        dstr_var.Does_Customer_Have_EDI_Capability__c='Yes';
        dstr_var.Customer_On_Electronic_Funds_Tra__c = 'No';
        dstr_var.Is_the_Customer_Tax_Exempt__c='No';
        dstr_var.Equipped_to_Handle_GE_Product__c = 'Yes';
        date myDate = date.today();
        dstr_var.Date_of_Visit_by_Account_Manager__c = myDate ;
        dstr_var.GE_Sales_Representative_Contact_Core__c  =UserInfo.getUserId();
        dstr_var.GE_Sales_Representative_Core__c = 'test';
        dstr_var.Region_District_Core__c = 'test neel';
        dstr_var.GE_Sales_Rep_Contact_Solutions__c= UserInfo.getUserId();
        dstr_var.GE_Sales_Rep_Solutions__c = 'test';
        dstr_var.Region_District_Solutions__c = 'test';
        dstr_var.Account_Released__c=False;
        dstr_var.IFN_INDOOR_FIXTURE_NON_LED__c = true;
        dstr_var.All_product_lines_except_Automotive__c  = TRUE;
        dstr_var.Automotive_Applications_Only__c = TRUE;
        insert dstr_var;    
        dstr_var.State_Province_1__c =null; 
        dstr_var.Counties_State_1__c=''; 
        try
        {  
            dstr_var.Status__c = 'Compliance Approved';
            update dstr_var;
        }
        catch(exception exc)
        {
            Boolean expectedExceptionThrown10210 =  exc.getMessage().contains('Please complete information under Compliance section') ? true : false;
            System.AssertEquals(expectedExceptionThrown10210, true);
        }
    }


// Roja Velpuri

    static testMethod void getSolutionsDistributor()
    {    test.startTest(); 
     //Distributor - New Solutions and Controls Distributor AccountSetup test code begins
     ID userID = UserInfo.getUserID();
     ID recdaTypeID = [SELECT ID FROM RecordType WHERE SOBJECTTYPE='Distributor__c' AND DEVELOPERNAME='New_Core_Solutions_and_Controls_Distributor'].ID;
     Distributor__c dstr_var10 = new Distributor__c(RecordTypeId=recdaTypeID);
     dstr_var10.Customer_Legal_Name__c = 'Test Distributor';
     dstr_var10.Billing_Address__c = 'Test Address';
     dstr_var10.Billing_City__c = 'Test City';
     dstr_var10.Billing_State__c = 'Test State';
     dstr_var10.Billing_Postal_Code__c = '11111';
     dstr_var10.Billing_Contact_Name__c = 'Test Contact';
     dstr_var10.Billing_Contact_Phone__c = '23456' ;
     dstr_var10.Billing_Contact_Email__c = 'test@test123.com';
     dstr_var10.GE_Sales_Contact__c= UserInfo.getUserId();
     dstr_var10.Status__c = 'Test';
     dstr_var10.GE_LGT_Minor_Channel__c ='';
     dstr_var10.GE_LGT_Vertical__c='';
     dstr_var10.Mail_To_Same_as_Bill_To__c = true;
     dstr_var10.Shipping_Information_Same_as_Bi__c=true;
     dstr_var10.Core_choose_all_that_apply__c='Sensors'; 
     dstr_var10.Solutions_choose_all_that_apply__c='Traffic Products'; 
     dstr_var10.Requested_Terms__c = 'Standard';  
     dstr_var10.Estimated_Annual_Volume_in_Dollars__c = 123;
     dstr_var10.Amount_of_First_Order__c=234;
     dstr_var10.Does_Customer_Have_EDI_Capability__c='Yes';
     dstr_var10.Customer_On_Electronic_Funds_Tra__c = 'No';
     dstr_var10.Is_the_Customer_Tax_Exempt__c='No';
     dstr_var10.Equipped_to_Handle_GE_Product__c = 'Yes';
     date myDate1 = date.today();
     dstr_var10.Date_of_Visit_by_Account_Manager__c = myDate1 ;
     dstr_var10.GE_Sales_Representative_Contact_Core__c = UserInfo.getUserId();
     dstr_var10.GE_Sales_Representative_Core__c = 'test';
     dstr_var10.Region_District_Core__c = 'test';
     dstr_var10.GE_Sales_Rep_Contact_Solutions__c = userID;       
     dstr_var10.GE_Sales_Rep_Solutions__c = 'test';
     dstr_var10.Region_District_Solutions__c = 'test';
     dstr_var10.Account_Released__c=True;
     dstr_var10.GE_LGT_Minor_Channel__c='';
     dstr_var10.Type_of_Setup__c='Contract';
     dstr_var10.Channel__c='Utility';
     dstr_var10.D_B_Check__c=false;
     dstr_var10.GE_LGT_Sabrix_Setup_Complete__c=false;
     dstr_var10.GE_LGT_GM_Region_Exec__c= UserInfo.getUserId();
     dstr_var10.LAMP_BALLAST__c = true; 
     dstr_var10.Status__c = 'Exec Review';
     insert dstr_var10;
     try
     { 
         dstr_var10.Status__c ='Compliance Review';
         update dstr_var10;
     }
     catch(Exception exc10210){
         Boolean expectedExceptionThrown10210 =  exc10210.getMessage().contains('Please fill information under Risk Review Section and Setup Requirement section to Approve.') ? true : false;
         //System.AssertEquals(expectedExceptionThrown10210, false);    
     } 
     try{
         dstr_var10.Status__c = 'Legal Approved';
         update dstr_var10;
     }
     catch(Exception exc10210){
         Boolean expectedExceptionThrown10210 =  exc10210.getMessage().contains('Please attach contract to move to the next step in approval.') ? true : false;
         //System.AssertEquals(expectedExceptionThrown10210, false);    
     } 
          
     try{
         dstr_var10.Status__c = 'Ship To';
         update dstr_var10; 
     }        
     catch(Exception exc10210){
         Boolean expectedExceptionThrown10210 =  exc10210.getMessage().contains('Please complete information under the Setup Requirement Section') ? true : false;
         //System.AssertEquals(expectedExceptionThrown10210, false);    
     } 
     
     test.stopTest();
    }
    
        
}
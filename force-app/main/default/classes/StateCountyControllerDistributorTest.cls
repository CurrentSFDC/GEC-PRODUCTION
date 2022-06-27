@isTest
public class StateCountyControllerDistributorTest
{
    public static testMethod void testAddingStateCounty()
    {
        ID userID = UserInfo.getUserID();
  
       // ID recDirAccTypeID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Solutions and/or Controls Branch').getRecordTypeId(); RQT-1475
     
         //ID RecordtypeId2=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Solutions and/or Controls Branch').getRecordTypeId(); RQT-1475
        ID RecordtypeId2=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Solutions and/or Controls Branch Approval').getRecordTypeId();
        ID recDirAccTypeID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Solutions and/or Controls Branch Approval').getRecordTypeId();
         Distributor__c dstr_var = TestDataUtil.createDistributor(RecordtypeId2);
          insert dstr_var;

          dstr_var.Status__c = 'Pricing/Finance Review';
          dstr_var.Sales_Office_Solutions__c = Null; 
          dstr_var.Sales_District_Solutions__c = Null; 
          dstr_var.Sales_Group_Solutions__c = Null ;  
          dstr_var.Account_Assignment_Group__c = Null;  
          dstr_var.KYC_Number__c = Null;  
          dstr_var.Credit_ID_Number__c = Null ; 
          dstr_var.Credit_Limit_Approved_USD__c = Null;  
          dstr_var.Credit_Quality_Rating__c = Null;
          update dstr_var;   
         
      
        PageReference pageRef = Page.StateCountySelectorForDistributor;
        pageRef.getParameters().put('id',dstr_var.id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('ID',dstr_var.id);
        ApexPages.StandardController sc = new ApexPages.standardController(dstr_var);
        StateCountyControllerforDistributor sCC = new StateCountyControllerforDistributor(sc);
        sCC.showAddNewBlock();
        sCC.hideAddNewBlock();
        sCC.getStateCodes();
        sCC.getIsAllCountiesSelect();
        sCC.selectclick();
        sCC.unselectclick();
        sCC.getCountyCodes();
        sCC.selectedState();
        sCC.selectedCounties();
        sCC.getunSelectedValues();
        sCC.getSelectedValues();
        sCC.isAllCounties = 'Yes';
        PageReference selectAllValues =sCC.selectAllValues();
        
        StateCountyHelper sch = new StateCountyHelper();
        
       
        sCC.edit = false;
        sCC.state = 'AS';
        sCC.isAllCounties = 'No';
        sCC.rightValues.add('American Somoa - AS01');
        sCC.saveStateAndCounties();   
     
        sCC.edit = true;
        sCC.stateNumber = '1';
        sCC.state = 'PR';
        sCC.rightValues.add('Puerto Rico - PR01');
        sCC.isAllCounties = 'No';
        sCC.saveStateAndCounties();
        sCC.stateNumber = '1';
        sCC.editState();
       
        sCC.stateNumber = '1';
        sCC.deleteState();
        
    }
    public static testMethod void testAddingStateCountyselected()
    {
        ID userID = UserInfo.getUserID();
  
       // ID recDirAccTypeID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Solutions and/or Controls Branch').getRecordTypeId(); RQT-1475
     
        // ID RecordtypeId2=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Solutions and/or Controls Branch').getRecordTypeId(); RQT-1475
        
        ID recDirAccTypeID=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Solutions and/or Controls Branch Approval').getRecordTypeId();
        ID RecordtypeId2=Schema.SObjectType.Distributor__c.getRecordTypeInfosByName().get('Distributor- New Solutions and/or Controls Branch Approval').getRecordTypeId();
        Distributor__c dstr_var = TestDataUtil.createDistributor(RecordtypeId2);
          insert dstr_var;

          dstr_var.Status__c = 'Pricing/Finance Review';
          dstr_var.Sales_Office_Solutions__c = Null; 
          dstr_var.Sales_District_Solutions__c = Null; 
          dstr_var.Sales_Group_Solutions__c = Null ;  
          dstr_var.Account_Assignment_Group__c = Null;  
          dstr_var.KYC_Number__c = Null;  
          dstr_var.Credit_ID_Number__c = Null ; 
          dstr_var.Credit_Limit_Approved_USD__c = Null;  
          dstr_var.Credit_Quality_Rating__c = Null;
          update dstr_var;   
         
      
        PageReference pageRef = Page.StateCountySelectorForDistributor;
        pageRef.getParameters().put('id',dstr_var.id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('ID',dstr_var.id);
        ApexPages.StandardController sc = new ApexPages.standardController(dstr_var);
        StateCountyControllerforDistributor sCC = new StateCountyControllerforDistributor(sc);
        sCC.showAddNewBlock();
        sCC.hideAddNewBlock();
        sCC.getStateCodes();
        sCC.getIsAllCountiesSelect();
        sCC.selectclick();
        sCC.unselectclick();
        sCC.getCountyCodes();
        sCC.selectedState();
        sCC.selectedCounties();
        sCC.getunSelectedValues();
        sCC.getSelectedValues();
        sCC.isAllCounties = 'No';
        PageReference selectAllValues =sCC.selectAllValues();
        
        StateCountyHelper sch = new StateCountyHelper();
        
       
        sCC.edit = false;
        sCC.state = 'AS';
        sCC.isAllCounties = 'Yes';
        sCC.rightValues.add('American Somoa - AS01');
        sCC.saveStateAndCounties();   
     
        sCC.edit = true;
        sCC.stateNumber = '1';
        sCC.state = 'PR';
        sCC.rightValues.add('Puerto Rico - PR01');
        sCC.isAllCounties = 'Yes';
        sCC.saveStateAndCounties();
        sCC.stateNumber = '1';
        sCC.editState();
       
        sCC.stateNumber = '1';
        sCC.deleteState();
        
    }
}
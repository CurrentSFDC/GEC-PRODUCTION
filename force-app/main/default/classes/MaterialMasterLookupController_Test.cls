@isTest
public class  MaterialMasterLookupController_Test {
   //Rashmitha Changed the API vesion from 35 to 45 on 6-Mar-2019 as per 1447 request
    @IsTest
    static  void testWithoutSearch(){
        GE_LGT_EM_MaterialMaster__c mm=TestDataUtil.createMaterialMaster('93012111');
        GE_LGT_EM_MaterialMaster__c mm2=TestDataUtil.createMaterialMaster('513339');    
        GE_LGT_EM_MaterialMaster__c mm3=TestDataUtil.createMaterialMaster('513339');   
        List<GE_LGT_EM_MaterialMaster__c> mms = new List<GE_LGT_EM_MaterialMaster__c>(); 
        mms.add(mm);
        mms.add(mm2);
        mms.add(mm3);
        insert mms;
        Test.StartTest();
        PageReference pageReftemp = Page.MaterialMasterLookupPopup;
        system.Test.setCurrentPage(pageReftemp); 
        ApexPages.currentPage().getParameters().put('prodHierarchy',mm.GE_LGT_EM_ProductHierarchy__c);
        ApexPages.currentPage().getParameters().put('skuID', 'j_id0:j_id90:cpli:pbSection:idpbt1:14:targetId');
        ApexPages.currentPage().getParameters().put('skuName', 'j_id0:j_id90:cpli:pbSection:idpbt1:14:targetName');
        MaterialMasterLookupController Mmlc = new MaterialMasterLookupController();
        List<GE_LGT_EM_MaterialMaster__c> SKUs = Mmlc.SKUs;
        Mmlc.hasNext = false;
        Mmlc.hasPrevious = false;
        System.assertNotEquals(null, SKUs);
        Test.StopTest();
    }
    @IsTest
    static  void testWithSearch(){
        GE_LGT_EM_MaterialMaster__c mm=TestDataUtil.createMaterialMaster('93012111');
        GE_LGT_EM_MaterialMaster__c mm2=TestDataUtil.createMaterialMaster('513339');    
        GE_LGT_EM_MaterialMaster__c mm3=TestDataUtil.createMaterialMaster('513339');   
        List<GE_LGT_EM_MaterialMaster__c> mms = new List<GE_LGT_EM_MaterialMaster__c>(); 
        mms.add(mm);
        mms.add(mm2);
        mms.add(mm3);
        insert mms;
        Test.StartTest();
        PageReference pageReftemp = Page.MaterialMasterLookupPopup;
        system.Test.setCurrentPage(pageReftemp); 
        ApexPages.currentPage().getParameters().put('prodHierarchy',mm.GE_LGT_EM_ProductHierarchy__c);
        ApexPages.currentPage().getParameters().put('skuID', 'j_id0:j_id90:cpli:pbSection:idpbt1:14:targetId');
        ApexPages.currentPage().getParameters().put('skuName', 'j_id0:j_id90:cpli:pbSection:idpbt1:14:targetName');
        MaterialMasterLookupController Mmlc = new MaterialMasterLookupController();
        Mmlc.query = 'ALV101T57D8SAVSTKNW';
        Mmlc.runQuery();
        List<GE_LGT_EM_MaterialMaster__c> SKUs = Mmlc.SKUs;
        boolean next = Mmlc.hasNext;
        boolean previous = Mmlc.hasPrevious;
        System.assertNotEquals(null, SKUs);
        System.assertNotEquals(false, next);
        System.assertNotEquals(false, previous);
        Test.StopTest();
    }
    @IsTest
    static  void testForNextandPrevious(){
        GE_LGT_EM_MaterialMaster__c mm=TestDataUtil.createMaterialMaster('93012111');
        GE_LGT_EM_MaterialMaster__c mm1=TestDataUtil.createMaterialMaster('513339');    
        GE_LGT_EM_MaterialMaster__c mm2=TestDataUtil.createMaterialMaster('513339');
        GE_LGT_EM_MaterialMaster__c mm3=TestDataUtil.createMaterialMaster('513339');
        GE_LGT_EM_MaterialMaster__c mm4=TestDataUtil.createMaterialMaster('513339');
        GE_LGT_EM_MaterialMaster__c mm5=TestDataUtil.createMaterialMaster('513339');
        GE_LGT_EM_MaterialMaster__c mm6=TestDataUtil.createMaterialMaster('513339');
        GE_LGT_EM_MaterialMaster__c mm7=TestDataUtil.createMaterialMaster('513339');
        GE_LGT_EM_MaterialMaster__c mm8=TestDataUtil.createMaterialMaster('513339');
        GE_LGT_EM_MaterialMaster__c mm9=TestDataUtil.createMaterialMaster('513339');
        GE_LGT_EM_MaterialMaster__c mm0=TestDataUtil.createMaterialMaster('513339');
        List<GE_LGT_EM_MaterialMaster__c> mms = new List<GE_LGT_EM_MaterialMaster__c>(); 
        mms.add(mm);
        mms.add(mm1);
        mms.add(mm2);
        mms.add(mm3);
        mms.add(mm4);
        mms.add(mm5);
        mms.add(mm6);
        mms.add(mm7);
        mms.add(mm8);
        mms.add(mm9);
        mms.add(mm0);
        insert mms;
        Test.StartTest();
        PageReference pageReftemp = Page.MaterialMasterLookupPopup;
        system.Test.setCurrentPage(pageReftemp); 
        ApexPages.currentPage().getParameters().put('prodHierarchy',mm.GE_LGT_EM_ProductHierarchy__c);
        ApexPages.currentPage().getParameters().put('skuID', 'j_id0:j_id90:cpli:pbSection:idpbt1:14:targetId');
        ApexPages.currentPage().getParameters().put('skuName', 'j_id0:j_id90:cpli:pbSection:idpbt1:14:targetName');
        MaterialMasterLookupController Mmlc = new MaterialMasterLookupController();
        List<GE_LGT_EM_MaterialMaster__c> SKUs = Mmlc.SKUs;
        Mmlc.next();
        Mmlc.previous();
        System.assertNotEquals(null, SKUs);
        Test.StopTest();
    }
    @IsTest
    static  void testFornull(){
        Test.StartTest();
        PageReference pageReftemp = Page.MaterialMasterLookupPopup;
        system.Test.setCurrentPage(pageReftemp); 
        ApexPages.currentPage().getParameters().put('prodHierarchy','');
        MaterialMasterLookupController Mmlc = new MaterialMasterLookupController();
        List<GE_LGT_EM_MaterialMaster__c> SKUs = Mmlc.SKUs;
        System.assertEquals(null, SKUs);
        Test.stopTest();
    }
    
}
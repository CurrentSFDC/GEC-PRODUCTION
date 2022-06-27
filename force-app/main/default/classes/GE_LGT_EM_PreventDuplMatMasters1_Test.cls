@isTest
public class GE_LGT_EM_PreventDuplMatMasters1_Test 
{
    @testsetup
    public static void createMatMasters()
    {
        GE_LGT_EM_MaterialMaster__c matMaster=testdatautil.createMaterialMaster('1234');
        matMaster.GE_LGT_EM_SAP_MaterialNumber__c='1234';
        matMaster.GE_LGT_EM_ProductHierarchy__c='IDL100100600100';
        insert matMaster;
    }
    static testmethod void insertMatMasterWithSameSAPNumber()
    {
        GE_LGT_EM_MaterialMaster__c matMaster=testdatautil.createMaterialMaster('12345');
        matMaster.GE_LGT_EM_SAP_MaterialNumber__c='12345';
        matMaster.GE_LGT_EM_ProductHierarchy__c='IDL100100600100';
        insert matMaster;
    }
    static testmethod void insertMatMasterWithDiffSAPNumber()
    {
        GE_LGT_EM_MaterialMaster__c matMaster=testdatautil.createMaterialMaster('1234');
      matMaster.GE_LGT_EM_SAP_MaterialNumber__c='1234';
      matMaster.GE_LGT_EM_ProductHierarchy__c='IDL100100600100';
        insert matMaster;
    }
    static testmethod void insertMatMasterWithDiffPH()
    {
        GE_LGT_EM_MaterialMaster__c matMaster=testdatautil.createMaterialMaster('1234');
       matMaster.GE_LGT_EM_SAP_MaterialNumber__c='1234';
       matMaster.GE_LGT_EM_ProductHierarchy__c='IDL100100600100';
        insert matMaster;
    }
    static testmethod void insertMatMasterWithDuplicates()
    {
        GE_LGT_EM_MaterialMaster__c matMaster= testdatautil.createMaterialMaster('1234');
      matMaster.GE_LGT_EM_SAP_MaterialNumber__c='1234';
       matMaster.GE_LGT_EM_ProductHierarchy__c='IDL100100600100';
        GE_LGT_EM_MaterialMaster__c matMaster1=testdatautil.createMaterialMaster('1234');
        matMaster1.GE_LGT_EM_SAP_MaterialNumber__c='1234';
        matMaster1.GE_LGT_EM_ProductHierarchy__c='IDL100100600100';
         matMaster1.GE_LGT_EM_MaterialDescription__c='Test';
        List<GE_LGT_EM_MaterialMaster__c> matMasterList=new List<GE_LGT_EM_MaterialMaster__c>();
        matMasterList.add(matMaster);
        matMasterList.add(matMaster1);
        Database.insert(matMasterList);
        
    }
    static testmethod void insertMatMasterWithPHInformation()
    {
        GE_LGT_EM_MaterialMaster__c matMaster=testdatautil.createMaterialMaster('1234');
        matMaster.GE_LGT_EM_SAP_MaterialNumber__c='1234';
                                                matMaster.GE_LGT_EM_ProductHierarchy__c='IDL100100600100';matMaster.Level_1__c='IDL-INDUSTRIAL FIXTURES - LED-1';matMaster.Level_2__c='IDL100-HIGH BAY-2';
                                                matMaster.Level_3__c='IDL1001006-ABV1 UL-3';matMaster.Level_4__c='IDL1001006001-ABV1 UL 1 MODULE-4';matMaster.Level_5__c='IDL100100600100-IDL HIGH BAY ABV1 UL 1 MODULE-5';
        insert matMaster;
    }
}
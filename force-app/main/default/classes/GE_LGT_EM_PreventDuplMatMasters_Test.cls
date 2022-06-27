@isTest
public class GE_LGT_EM_PreventDuplMatMasters_Test 
{
    @testsetup
    public static void createMatMasters()
    {
        GE_LGT_EM_MaterialMaster__c matMaster=testdatautil.createMaterialMaster('1234');
        matMaster.GE_LGT_EM_SAP_MaterialNumber__c='1234';
        matMaster.GE_LGT_EM_ProductHierarchy__c='IDL100100600100';
        insert matMaster;
        system.assertEquals(matMaster.Level_3__c,'IDL1001006-ABV1 UL-3');  

    }
    static testmethod void insertMatMasterWithSameSAPNumber()
    {
        GE_LGT_EM_MaterialMaster__c matMaster=testdatautil.createMaterialMaster('12345');
        matMaster.GE_LGT_EM_SAP_MaterialNumber__c='12345';
        matMaster.GE_LGT_EM_ProductHierarchy__c='IDL100100600100';
        insert matMaster;
        system.assertEquals(matMaster.Level_2__c,'IDL100-HIGH BAY-2');
    
    }
    static testmethod void insertMatMasterWithDiffSAPNumber()
    {
        GE_LGT_EM_MaterialMaster__c matMaster=testdatautil.createMaterialMaster('1234');
        matMaster.GE_LGT_EM_SAP_MaterialNumber__c='1234';
        matMaster.GE_LGT_EM_ProductHierarchy__c='IDL100100600100';
        insert matMaster;
        system.assertEquals(matMaster.Level_1__c,'IDL-INDUSTRIAL FIXTURES - LED-1');
        
    }
    static testmethod void insertMatMasterWithDiffPH()
    {
        GE_LGT_EM_MaterialMaster__c matMaster=testdatautil.createMaterialMaster('1234');
        matMaster.GE_LGT_EM_SAP_MaterialNumber__c='1234';
        matMaster.GE_LGT_EM_ProductHierarchy__c='IDL100100600100';
        insert matMaster;
        system.assertEquals(matMaster.Level_2__c,'IDL100-HIGH BAY-2');
        
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
        system.assertEquals(matMaster.Level_1__c,'IDL-INDUSTRIAL FIXTURES - LED-1');
    }
    static testmethod void insertMatMasterWithPHInformation()
    {
        GE_LGT_EM_MaterialMaster__c matMaster=testdatautil.createMaterialMaster('1234');
        matMaster.GE_LGT_EM_SAP_MaterialNumber__c='1234';
        matMaster.GE_LGT_EM_ProductHierarchy__c='IDL100100600100';
        matMaster.Level_1__c='IDL-INDUSTRIAL FIXTURES - LED-1';
        matMaster.Level_2__c='IDL100-HIGH BAY-2';
        matMaster.Level_3__c='IDL1001006-ABV1 UL-3';
        matMaster.Level_4__c='IDL1001006001-ABV1 UL 1 MODULE-4';
        matMaster.Level_5__c='IDL100100600100-IDL HIGH BAY ABV1 UL 1 MODULE-5';                                        
        insert matMaster;
        system.assertEquals(matMaster.Level_1__c,'IDL-INDUSTRIAL FIXTURES - LED-1');
    }
    static testmethod void insertMatMasterWithoutPHInformation()
    {
        GE_LGT_EM_MaterialMaster__c matMaster= new GE_LGT_EM_MaterialMaster__c();
        matMaster.GE_LGT_EM_SAP_MaterialNumber__c='12340345456';
        matMaster.GE_LGT_EM_ProductHierarchy__c='IDL100100600100';
        matMaster.Level_4__c=null;
        matMaster.SAP_Flag__c='Yes';                                       
        insert matMaster;
        system.assertEquals(matMaster.SAP_Flag__c,'Yes');
    }
    static testmethod void insertNullproducthirarchyNullLevel4()
    {
        GE_LGT_EM_MaterialMaster__c matMaster= new GE_LGT_EM_MaterialMaster__c();
        matMaster.GE_LGT_EM_SAP_MaterialNumber__c='1234034545656';
        matMaster.GE_LGT_EM_ProductHierarchy__c=null;
        matMaster.Level_4__c=null;
        matMaster.SAP_Flag__c='Yes';                                       
        insert matMaster;
    }
	 static testmethod void updatePHMethod()
    {
        GE_LGT_EM_MaterialMaster__c matMaster=testdatautil.createMaterialMaster('A1234');
        matMaster.GE_LGT_EM_SAP_MaterialNumber__c='A1234';
		matMaster.GE_LGT_EM_MaterialDescription__c='TESTD1';
        matMaster.GE_LGT_EM_ProductHierarchy__c='IDL100100600100';
        matMaster.Level_1__c='IDL-INDUSTRIAL FIXTURES - LED-1';
        matMaster.Level_2__c='IDL100-HIGH BAY-2';
        matMaster.Level_3__c='IDL1001006-ABV1 UL-3';
        matMaster.Level_4__c='IDL1001006001-ABV1 UL 1 MODULE-4';
        matMaster.Level_5__c='IDL100100600100-IDL HIGH BAY ABV1 UL 1 MODULE-5';                                        
        insert matMaster;
		
		GE_LGT_EM_MaterialMaster__c matMaster1=testdatautil.createMaterialMaster('A1234');
        matMaster1.GE_LGT_EM_SAP_MaterialNumber__c='A1234';
		matMaster1.GE_LGT_EM_MaterialDescription__c='TESTD2';
        matMaster1.GE_LGT_EM_ProductHierarchy__c='AIDL100100600100';
        matMaster1.Level_1__c='AIDL-INDUSTRIAL FIXTURES - LED-1';
        matMaster1.Level_2__c='AIDL100-HIGH BAY-2';
        matMaster1.Level_3__c='AIDL1001006-ABV1 UL-3';
        matMaster1.Level_4__c='AIDL1001006001-ABV1 UL 1 MODULE-4';
        matMaster1.Level_5__c='AIDL100100600100-IDL HIGH BAY ABV1 UL 1 MODULE-5';                                        
        insert matMaster1;

    }
}
@isTest
public class GE_LGT_EM_Product_Hierarchy_Code_UpdateT  {
  static testMethod void Test() { 
     
         //Insert Product2 Record
    PriceBook2 pb2= TestDataUtil.createPriceBook('LED');
    insert pb2;
         Product2  p2= TestDataUtil.createProduct('TestVenky');
         p2.Name='TestVenky';
         p2.Product_Hierarchy_Code__c='TestProduct12345';
         insert p2;
         //Insert Material Master Record

         GE_LGT_EM_MaterialMaster__c mm1 =TestDataUtil.createMaterialMaster('999999');      
         mm1.GE_LGT_EM_ProductHierarchy__c ='TestProduct12345';
         mm1.Level_4__c='IDL100-HIGH BAY-2';
         mm1.Product_Hierarchy_Code_2__c = p2.id ;
         insert mm1;

    
         
         Test.startTest();
         GE_LGT_EM_Product_Hierarchy_Code_Update  Sc = new GE_LGT_EM_Product_Hierarchy_Code_Update(); 
          
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, Sc);
         Test.stopTest();
     }
}
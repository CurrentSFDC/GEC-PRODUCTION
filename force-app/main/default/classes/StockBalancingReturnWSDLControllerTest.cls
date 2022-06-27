@isTest
public class StockBalancingReturnWSDLControllerTest {
    static testMethod void createOrderInSAPTest(){

        Id NA_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('North America').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.GE_LGT_EM_SAP_Customer_Number__c = 'H9M';
        acc.GE_LGT_Rep_Code__c = 'H9M';
        acc.Customer_Segmentation__c = 'LB';
        acc.GE_LGT_EM_Distribution_Channel__c = '20';
        acc.GE_LGT_EM_Division__c = '10';
        acc.GE_LGT_EM_Partner_Function__c = 'Sold-to party';
        insert acc;


        Case cas = new Case();
        cas.eLight_Reason_for_Return__c = 'Agent Error';
        cas.Type = 'Returns';
        cas.GE_NAS_Sub_Type__c = 'Stock Balancing Return';
        cas.AccountId = acc.id;
        cas.Sold_To_Account__c = acc.id;
        cas.SuppliedEmail = 'matthew.gugumuck@gecurrent.com';
        cas.SuppliedPhone = '804-314-5023';
        cas.RecordTypeID = NA_RecordType;
        cas.GE_NAS_Purchase_Order__c = '123456';
        cas.eLight_Comments__c = 'TEST ONLY';
        insert cas;

        GE_LGT_EM_MaterialMaster__c mat = new GE_LGT_EM_MaterialMaster__c();
        mat.GE_LGT_EM_SAP_MaterialNumber__c = '93136179';
        mat.GE_LGT_EM_ProductHierarchy__c = 'IDL110113000500';
        mat.GE_LGT_EM_MaterialDescription__c = 'ALV204T04T581DSQVQSTKQW1PK';
        insert mat;

        Dispute_Request__c dis = new Dispute_Request__c();
        dis.Case__c = cas.Id;
        dis.Customer_PO__c = '31104';
        dis.Discrepancy_Total__c = 545.40;
        dis.SAP_Doc_Type__c = 'ZRE';
        dis.Status__c = 'Approved';
        insert dis;

        Shipment_Detail__c sd = new Shipment_Detail__c();
        sd.GE_NAS_Case_Number__c = cas.id;
        sd.GE_NAS_Product_Code__c = 'ALV204T04T581DSQVQSTKQW1PK';
        sd.Rep_Code__c = 'H9M';
        sd.Material_Number__c = mat.id;
        sd.Discrepancy_Qty__c = 10;
        sd.Invoiced_Price__c = 54.54;
        sd.Dispute_Request__c = dis.id;
        sd.Approved__c = true;
        insert sd;

        Shipment_Detail__c sd1 = new Shipment_Detail__c();
        sd1.GE_NAS_Case_Number__c = cas.id;
        sd1.GE_NAS_Product_Code__c = '93136179';
        sd1.Material_Number__c = mat.id;
        sd1.Rep_Code__c = 'H9M';
        sd1.Discrepancy_Qty__c = 10;
        sd1.Invoiced_Price__c = 54.54;
        sd1.Dispute_Request__c = dis.id;
        sd1.Approved__c = true;
        insert sd1;

        StockBalancingReturnWSDLController.createOrderInSAP(dis.id);

      
          
          
        invocableStockBalancingReturnWSDLCall.methodInputs argument;
          argument = new invocableStockBalancingReturnWSDLCall.methodInputs();
          argument.disID = dis.Id;
          System.debug('disID is '+dis.Id);
          invocableStockBalancingReturnWSDLCall.callStockBalancingReturnWSDL(new List<invocableStockBalancingReturnWSDLCall.methodInputs>{argument});
         

    }
}
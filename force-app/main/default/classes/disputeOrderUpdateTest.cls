@isTest
public class disputeOrderUpdateTest {
    static testMethod void insertDisputeOrderUpdateTest1(){

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
        
        Test.startTest();
        Database.SaveResult result = Database.update(dis, true);
        Test.stopTest();
    }
        static testMethod void TestMethod2(){

        Id NA_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('North America').getRecordTypeId();
        Id PO_Received = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Received PO').getRecordTypeId();
    	Id StandardOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard').getRecordTypeId();

        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.GE_LGT_EM_SAP_Customer_Number__c = 'H9M';
        acc.GE_LGT_Rep_Code__c = 'H9M';
        acc.Customer_Segmentation__c = 'LB';
        acc.GE_LGT_EM_Sales_Org__c = '1US1';
        acc.GE_LGT_EM_Partner_Function__c = 'Sold-to party';
        insert acc;
            
            Contact con = new Contact();
            con.FirstName = 'MatthewTest';
            con.LastName = 'Gugumuck';
            con.AccountId = acc.Id;
            insert con;
        
            /*Date newDate = Date.today();
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.RecordTypeId = StandardOpp;
        opp.GE_LGT_GE_Opportunity_Id__c = 'NA000000001';
        opp.CloseDate = newDate;
        insert opp;*/
            
        Date newDate = Date.today();
        Order ord = new Order();
        ord.RecordTypeId = PO_Received;
            ord.AccountId = acc.Id;
            ord.Sold_To__c = acc.Id;
            ord.EffectiveDate = newDate;
        ord.Sold_To__c = acc.Id;
        ord.ShippingStreet = '8725 Branchs Woods Lane';
        ord.ShippingCity = 'North Chesterfield';
            ord.ShippingState = 'VA';
            ord.ShippingPostalCode = '23237';
            ord.ShippingCountry = 'US';
            //ord.GE_Opportunity_Id__c = opp.GE_LGT_GE_Opportunity_Id__c;
            insert ord;
            
        Case cas1 = new Case();
        cas1.ContactId = con.Id;
        cas1.eLight_Reason_for_Return__c = 'Agent Error';
        cas1.Type = 'Returns';
        cas1.GE_NAS_Sub_Type__c = 'NEW RGA';
        cas1.AccountId = acc.id;
        cas1.Sold_To_Account__c = acc.id;
        cas1.SuppliedEmail = 'matthew.gugumuck@gecurrent.com';
        cas1.SuppliedPhone = '804-314-5023';
        cas1.RecordTypeID = NA_RecordType;
        insert cas1;

        Dispute_Request__c dis1 = new Dispute_Request__c();
        dis1.Case__c = cas1.Id;
        dis1.Customer_PO__c = '31104';
        dis1.Sold_To__c = acc.Id;
        dis1.Original_Order__c = ord.Id;
        dis1.Discrepancy_Total__c = 545.40;
        dis1.SAP_Doc_Type__c = 'ZOR';
        dis1.Status__c = 'Approved';
        insert dis1;

        Shipment_Detail__c sd1 = new Shipment_Detail__c();
        sd1.GE_NAS_Case_Number__c = cas1.id;
        sd1.GE_NAS_Product_Code__c = 'ALV204T04T581DSQVQSTKQW1PK';
        sd1.Rep_Code__c = 'H9M';
        sd1.Discrepancy_Qty__c = 10;
        sd1.Invoiced_Price__c = 54.54;
        sd1.Dispute_Request__c = dis1.id;
        sd1.Approved__c = true;
        insert sd1;
            
         Test.startTest();
        Database.SaveResult result = Database.update(dis1, true);
        Test.stopTest();
            
            
        }

        static testMethod void TestMethod3(){

            Id NA_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('North America').getRecordTypeId();
            Id PO_Received = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Received PO').getRecordTypeId();

         Account acc = new Account();
        acc.Name = 'Test Account';
        acc.GE_LGT_EM_SAP_Customer_Number__c = 'H9M';
        acc.GE_LGT_Rep_Code__c = 'H9M';
        acc.Customer_Segmentation__c = 'LB';
        acc.GE_LGT_EM_Sales_Org__c = '1US1';
        acc.GE_LGT_EM_Partner_Function__c = 'Sold-to party';
        insert acc;   
            
            GE_LGT_EM_MaterialMaster__c mt = new GE_LGT_EM_MaterialMaster__c();
            mt.GE_LGT_EM_MaterialDescription__c = 'ALV204T04T581DSQVQSTKQW1PK';
            mt.GE_LGT_EM_SAP_MaterialNumber__c = '1234567';
            insert mt;
            
              
        
            Date newDate = Date.today();
        Order ord1 = new Order();
        ord1.AccountId = acc.Id;
            ord1.EffectiveDate = newDate;
        ord1.ShippingStreet = '8725 Branchs Woods Lane';
        ord1.ShippingCity = 'North Chesterfield';
            ord1.ShippingState = 'VA';
            ord1.ShippingPostalCode = '23237';
            ord1.ShippingCountry = 'US';
            insert ord1;
        
        Case cas2 = new Case();
        cas2.eLight_Reason_for_Return__c = 'Agent Error';
        cas2.Type = 'Returns';
        cas2.GE_NAS_Sub_Type__c = 'NEW RGA';
        cas2.AccountId = acc.id;
        cas2.Sold_To_Account__c = acc.id;
        cas2.SuppliedEmail = 'matthew.gugumuck@gecurrent.com';
        cas2.SuppliedPhone = '804-314-5023';
        cas2.RecordTypeID = NA_RecordType;
        insert cas2;

        Dispute_Request__c dis2 = new Dispute_Request__c();
        dis2.Case__c = cas2.Id;
        dis2.Customer_PO__c = '31104';
        dis2.Discrepancy_Total__c = 545.40;
        dis2.Original_Order__c = ord1.Id;
        dis2.SAP_Doc_Type__c = 'ZRE';
        dis2.Status__c = 'Approved';
        insert dis2;

        Shipment_Detail__c sd2 = new Shipment_Detail__c();
        sd2.GE_NAS_Case_Number__c = cas2.id;
        sd2.GE_NAS_Product_Code__c = 'ALV204T04T581DSQVQSTKQW1PK';
        sd2.Rep_Code__c = 'H9M';
        sd2.Discrepancy_Qty__c = 10;
        sd2.Invoiced_Price__c = 54.54;
        sd2.Dispute_Request__c = dis2.id;
        sd2.Material_Number__c = mt.id;
        sd2.Approved__c = true;
        insert sd2;
            
        Test.startTest();
        Database.SaveResult result = Database.update(dis2, true);
        Test.stopTest();

        }
        static testMethod void TestMethod4(){

            Id NA_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('North America').getRecordTypeId();
            Id PO_Received = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Received PO').getRecordTypeId();

         Account acc = new Account();
        acc.Name = 'Test Account';
        acc.GE_LGT_EM_SAP_Customer_Number__c = 'H9M';
        acc.GE_LGT_Rep_Code__c = 'H9M';
        acc.Customer_Segmentation__c = 'LB';
        acc.GE_LGT_EM_Partner_Function__c = 'Sold-to party';
        insert acc;
            
            Date newDate = Date.today();
        Order ord3 = new Order();
        ord3.RecordTypeId = PO_Received;
            ord3.AccountId = acc.Id;
            ord3.EffectiveDate = newDate;
        ord3.Sold_To__c = acc.Id;
        ord3.ShippingStreet = '8725 Branchs Woods Lane';
        ord3.ShippingCity = 'North Chesterfield';
            ord3.ShippingState = 'VA';
            ord3.ShippingPostalCode = '23237';
            ord3.ShippingCountry = 'US';
            //ord.GE_Opportunity_Id__c = opp.GE_LGT_GE_Opportunity_Id__c;
            insert ord3;
            
        Case cas3 = new Case();
        cas3.eLight_Reason_for_Return__c = 'Agent Error';
        cas3.Type = 'Warranty';
        cas3.GE_NAS_Sub_Type__c = 'Warranty Claim';
        cas3.AccountId = acc.id;
        cas3.Sold_To_Account__c = acc.id;
        cas3.SuppliedEmail = 'matthew.gugumuck@gecurrent.com';
        cas3.SuppliedPhone = '804-314-5023';
        cas3.RecordTypeID = NA_RecordType;
        insert cas3;

        Dispute_Request__c dis3 = new Dispute_Request__c();
        dis3.Case__c = cas3.Id;
        dis3.Customer_PO__c = '31104';
        dis3.Discrepancy_Total__c = 545.40;
        dis3.SAP_Doc_Type__c = 'ZFDD';
            dis3.Original_Order__c = ord3.Id;
        //dis3.Status__c = 'Approved';
        insert dis3;

        Shipment_Detail__c sd3 = new Shipment_Detail__c();
        sd3.GE_NAS_Case_Number__c = cas3.id;
        sd3.GE_NAS_Product_Code__c = 'ALV204T04T581DSQVQSTKQW1PK';
        sd3.Rep_Code__c = 'H9M';
        sd3.Discrepancy_Qty__c = 10;
        sd3.Invoiced_Price__c = 54.54;
        sd3.Dispute_Request__c = dis3.id;
        sd3.Approved__c = true;
        insert sd3;
            
            Test.startTest();
        Database.SaveResult result = Database.update(dis3, true);
        Test.stopTest();
        }


    
}
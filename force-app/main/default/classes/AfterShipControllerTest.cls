@isTest
public class AfterShipControllerTest  {

    
    @IsTest public static void testGetTrackingDetails(){
         // Set mock callout class 
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new AfterShipControllerMock());
         AfterShipController.ShipingDetails spd = AfterShipController.getTrackingDetails('FEDEX GROUND', '123133', 'user1@gmail.com');
         AfterShipController.ShipingDetails spd3 = AfterShipController.getTrackingDetails('FEDEX GROUND POST', '123133', 'user1@gmail.com');

         System.assertEquals(0, spd.indicator);
        
         AfterShipController.ShipingDetails spd1 = AfterShipController.getTrackingDetails('HEMS', '123133', 'user1@gmail.com');
         System.assertEquals(2, spd1.indicator);
         AfterShipController.ShipingDetails spd2 = AfterShipController.getTrackingDetails('HEMS2', '123133', 'user1@gmail.com');
         System.assertEquals(1, spd2.indicator);
         Test.stopTest();
    }

    @IsTest public static void regForNotifications(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AfterShipControllerMock());
        Boolean res = AfterShipController.regForNotifications('FEDEX GROUND', '123133', 'user1@gmail.com', 'fedex');
        
        Test.stopTest();
    }

    @testSetup
    private static void setupData() {
       
        Aftership_Carrier__c newRecord = new Aftership_Carrier__c(Company_Name__c = 'FEDEX GROUND',  Slug__c = 'fedex',
        URL__c = 'http://www.fedex.com/');
        insert newRecord;

        Aftership_Carrier__c newRecord1 = new Aftership_Carrier__c(Company_Name__c = 'HEMS',  Slug__c = null,
        URL__c = null);
        insert newRecord1;

        Aftership_Carrier__c newRecord2 = new Aftership_Carrier__c(Company_Name__c = 'HEMS2',  Slug__c = null,
        URL__c = 'http://test');
        insert newRecord2;
        
        Aftership_Carrier__c newRecord3 = new Aftership_Carrier__c(Company_Name__c = 'FEDEX GROUND POST',  Slug__c = 'fedexPOST',
        URL__c = 'http://www.fedex.com/');
        insert newRecord3;
       
    }

   


}
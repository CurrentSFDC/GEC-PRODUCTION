/*---------------------------------------------------------------------------------
Name:       gecurrentCom475AgreementpriceTest.cls
Purpose:    Test Class for Product Agreement Price Service.
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          11-Jan-2021             Initial Development 
---------------------------------------------------------------------------------*/
@isTest
private class gecurrentCom475AgreementpriceTest  {
    @isTest static void testCallout() {              
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new gecurrentCom475AgreementpriceMock());
        gecurrentCom475Agreementprice.HTTPS_Port geAPPort = new gecurrentCom475Agreementprice.HTTPS_Port();
        System.assertNotEquals(null, geAPPort.SI_SFB2B_AgreementPriceCall_475_OB_SYNC_N6('','','','','','','','','','','','','','','',null,null,null) );
      
     }
}
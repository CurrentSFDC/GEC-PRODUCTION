/**
 * Created by PA on 2021. 04. 28..
 */

@IsTest
private class ShipToAccountLookupControllerTest {
    @IsTest
    static void testBehavior() {
        try {
            ShipToAccountLookupController.getShipToAccounts(null, 'test');
        }
        catch (Exception e){
            System.assertEquals('soldToAccountId must be specified!', e.getMessage());
        }

        Account a = new Account(Name = 'Test');
        insert a;
        ShipToAccountLookupController.getShipToAccounts(a.id, 'test');
    }
}
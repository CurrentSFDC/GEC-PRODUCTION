public with sharing class invocableStockBalancingReturnWSDLCall {
    @InvocableMethod(label='Call  Stock Balancing Return WSDL for LB Auto Approval' description='Used for Auto Approval of LB SB Returns')
    public static void callStockBalancingReturnWSDL(List<methodInputs> request){
        Id disputeId = request[0].disID;
        StockBalancingReturnWSDLController.createOrderInSAP(disputeId);
    }

    public class methodInputs{
        @InvocableVariable
        public String disID;
    }
}
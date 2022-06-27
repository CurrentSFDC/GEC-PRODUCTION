public without sharing class invocableReturnWSDLCall {
   
    @InvocableMethod(label='Call Return WSDL for Auto Approval' description='Used for Auto Approval of LB Returns')
    public static void callReturnWSDL(List<methodInputs> request){
        Id disputeId = request[0].disID;
        ReturnWSDLCallDisp.getOrderDtl(disputeId);
    }


    public class methodInputs{
        @InvocableVariable
        public String disID;
    }


}
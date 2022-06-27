public with sharing class invocableReplaceWSDLCall {

    @InvocableMethod(label='Call Replace WSDL for Auto Approval' description='Used for Auto Approval of Replacements')
    public static void callReplaceWSDL(List<methodInputs> request){
        Id disputeId = request[0].disID;
        ReplaceWSDLCallDisp.getOrderDtlreplace(disputeId);
    }


    public class methodInputs{
        @InvocableVariable
        public String disID;
    }
}
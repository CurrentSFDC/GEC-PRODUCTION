public with sharing class invocableWarrantyReplaceWSDLCall {

    @InvocableMethod(label='Call Replace WSDL for Auto Approval' description='Used for Auto Approval of Replacements')
    public static void callWarrantyReplaceWSDL(List<methodInputs> request){
        Id disputeId = request[0].disID;
        WarrantyClaimWSDLCall.getOrderDtl(disputeId);
    }


    public class methodInputs{
        @InvocableVariable
        public String disID;
    }
}
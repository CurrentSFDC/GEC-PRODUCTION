/*---------------------------------------------------------------------------------
Name:       CallProductSpecCache.cls
Purpose:    REST Service to call Menu Cache.
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          06-Dec-2020             Initial Development 
---------------------------------------------------------------------------------*/
@RestResource(urlMapping='/commerce/productspec/*')
global with sharing class CallProductSpecCache {

    @HttpGet
    global static responseWrapper doGet() {

        responseWrapper responseJSON = new responseWrapper();

        try{
            //Database.executeBatch(new ccrz.cc_job_LoadProductSpecIndex('Select Id, ParentProduct__c, FilterData__c from E_Product__c'), 12);
            Database.executeBatch(new ccrz.cc_job_LoadProductSpecIndex('SELECT Id, ccrz__ParentProduct__c, ccrz__FilterData__c FROM ccrz__E_Product__c'));
            responseJSON.success = true;
            responseJSON.message = '"Successfully called job."';
        }
        catch (DmlException e){ responseJSON.success = false;responseJSON.message = e.getMessage();}
        return responseJSON;
    }

    //wrapper class for the response to an API request
    global class responseWrapper {

        global boolean success {get;set;} //status string
        global String message {get;set;} //message string

        //constructor
        global responseWrapper() {
            //default all values
            this.success = true;
            this.message = '""';
        }
    }

    @InvocableMethod(
        label = 'B2B Product Spec Index'
        description =  'B2B Product Spec Index'
    )
    public static List<Response>  createProductSpecIndex() {
        List<Response> responses = new List<Response>();
        Response res = new Response();

        try{
            if(!Test.isRunningTest()){
                Database.executeBatch(new ccrz.cc_job_LoadProductSpecIndex('SELECT Id, ccrz__ParentProduct__c, ccrz__FilterData__c FROM ccrz__E_Product__c'));
            }
            res.message = 'Successfully called job.';  
            res.success = true;    
            responses.add( res );
        }
        catch (DmlException e){ res.success = false;res.message = e.getMessage(); responses.add( res );}

        return responses;
    }
   

    public class Response {
        /*
         * Each @InvocableVariable defined in this class
         * is an output variable whose value you populate
         * in your @InvocableMethod to return back to
         * Process Builder or Flow, although Flow may be
         * the only one that can do something with the response.
         * Process Builder takes more of a "fire and forget" style.
         */

        @InvocableVariable(
            label = 'success'
            description = 'Cache Builder Boolean value'
        )
        public Boolean success;

        @InvocableVariable(
            label = 'message'
            description = 'Cache Builder Message'
        )
        public String message;
    }
}
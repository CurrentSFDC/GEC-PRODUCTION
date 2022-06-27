/*---------------------------------------------------------------------------------
Name:       CallSiteIndexCache.cls
Purpose:    REST Service to call Menu Cache.
------------------------------History---------------------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          -----------------------------
1.0         Devang          06-Dec-2020             Initial Development 
---------------------------------------------------------------------------------*/
@RestResource(urlMapping='/commerce/siteindex/*')
global with sharing class CallSiteIndexCache {

    @HttpGet
    global static responseWrapper doGet() {

        responseWrapper responseJSON = new responseWrapper();

        try{
            ccrz.ccSiteIndexBuilder.build(new Map<String,Object>{ccrz.ccSiteIndexBuilder.STOREFRONT => 'DefaultStore'});
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
        label = 'B2B Site Index'
        description =  'B2B Site Index'
    )
    public static List<Response>  createSiteIndex() {
        List<Response> responses = new List<Response>();
        Response res = new Response();

        try{
            if(!Test.isRunningTest()){
                ccrz.ccSiteIndexBuilder.build(new Map<String,Object>{ccrz.ccSiteIndexBuilder.STOREFRONT => 'DefaultStore'});
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
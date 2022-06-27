/*----------------------------------------------------------------------
Name:       AfterShipController.cls
Purpose:    Call AfterShip Service For Shipment Information
------------------------------History----------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          ------------------
1.0         Devang          12-Dec-2020             Initial Development 
----------------------------------------------------------------------*/
public class AfterShipController {
    
    
    
    @AuraEnabled
    public static Boolean regForNotifications(String carrierName, String trackingNumber, String emailTo, String slug){
        System.Debug('regForNotifications****');
        system.debug('carrierName= ****' + carrierName + '*');
        system.debug('trackingNumber= *' + trackingNumber + '*');
        system.debug('emailTo= *' + emailTo + '*');
        system.debug('slug= ****' + slug + '*');
        Boolean registerStatus = false;
        @testVisible Aftership__mdt[] services = [SELECT Endpoint__c, Access_Key__c FROM Aftership__mdt where MasterLabel = 'Tracking Results'];
        
        if(services != null && services[0].Endpoint__c != null){
            httpRequest req = new httpRequest();
            //Instantiate an httpRequest and set the required attributes
            req.setHeader('Content-Type','application/json');
            req.setMethod('POST');
            ///notifications/:slug/:tracking_number/add
            req.setEndpoint(services[0].Endpoint__c + 'notifications/' + slug + '/' + trackingNumber + '/' + 'add');
            req.setHeader('aftership-api-key', services[0].Access_Key__c);
            req.setTimeout(120000);
            
            notificationdata ndreq = new notificationdata();
            notification n = new notification();
            List<String> el = new List<String>();
            el.add(emailTo);
            n.emails = el;
            ndreq.notification = n;
            String jsonBody = json.serialize(ndreq);
            system.debug('jsonBody = ' + jsonBody);  
            // Set the body as a JSON object
            req.setBody(jsonBody);
            httpResponse res = new http().send(req);
            // Parse the JSON response
            if (res.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                             res.getStatusCode() + ' ' + res.getStatus());
                system.debug('response1 =' + res.toString());
                system.debug('response1 body =' + res.getBody());
            } else {
                System.debug('res**=' + res.getBody());
                registerStatus = true;	
            }
        }
        return registerStatus;
        
    }
    
    //Method to perform a callout and return an httpResponse
    @AuraEnabled
    public static ShipingDetails getTrackingDetails(String carrierName, String trackingNumber, String emailTo){
        //trackingNumber='516330454998';
        system.debug('carrierName= *' + carrierName + '*');
        system.debug('trackingNumber= *' + trackingNumber + '*');
        system.debug('emailTo= *' + emailTo + '*');
        ShipingDetails spd = new ShipingDetails();
        spd.companyName = carrierName;
        spd.trackingNumber = trackingNumber;
        spd.indicator = 2;
        spd.isError = false;
        
        try{
            List<Aftership_Carrier__c> acList = [SELECT Id, Company_Name__c,  Slug__c, URL__c FROM Aftership_Carrier__c WHERE Company_Name__c = :carrierName LIMIT 1 ];
            if (acList != null && acList[0].Company_Name__c != null && String.isNotBlank(acList[0].Company_Name__c)){
                spd.companyName = acList[0].Company_Name__c;
                if(acList[0].Slug__c != null && String.isNotBlank(acList[0].Slug__c)){
                    spd.indicator = 0;
                    spd.slug = acList[0].Slug__c;
                    spd.url = acList[0].URL__c;
                    
                } else {				
                    if(acList[0].URL__c != null || String.isNotBlank(acList[0].URL__c)){
                        spd.indicator = 1;
                        spd.slug = '';
                        spd.url = acList[0].URL__c;
                        spd.url = spd.url.replace('{TRACK_NO}', trackingNumber);
                    } else {
                        spd.indicator = 2;
                        spd.slug = '';
                        spd.url = '';
                    }
                }
            }
            
            system.debug('indicator ' + spd.indicator);
            system.debug('slug ' + spd.slug);
            system.debug('url ' + spd.url);
            system.debug('company name ' + spd.companyName);
            
            if(spd.indicator == 0){
                httpRequest req = new httpRequest();
                //Instantiate an httpRequest and set the required attributes
                req.setHeader('Content-Type','application/json');
                req.setMethod('GET');
                
                Aftership__mdt[] services = [SELECT Endpoint__c, Access_Key__c FROM Aftership__mdt where MasterLabel = 'Tracking Results'];
                
                if(services != null && services[0].Endpoint__c != null){
                    req.setEndpoint(services[0].Endpoint__c + 'trackings/' + spd.slug +'/' + trackingNumber);
                    req.setHeader('aftership-api-key', services[0].Access_Key__c);
                    
                    //system.debug('endpoint ' + services[0].Endpoint__c + '/' + slug +'/' + trackingNumber);
                }			
                
                //The timeout duration (in milliseconds) to deal with slow servers or large payloads
                req.setTimeout(120000);
                
                //Use the HTTP Class to send the httpRequest and receive an httpResposne
                /*If you are not using an HttpCalloutMock: 
if (!test.isRunningTest){
*/
                httpResponse res = new http().send(req);
                
                system.debug('response =' + res.toString());
                system.debug('response body =' + res.getBody());
                AfterShipResponse asp = (AfterShipResponse)JSON.deserialize(res.getBody(),AfterShipResponse.class);
                system.debug('response data = ' + asp.data.toString());
                if(asp != null && asp.data != null && asp.meta.code != null &&  asp.meta.code == 200){
                    List<checkpoint> checkpoints = new List<checkpoint>();
                    if(asp.data.tracking != null && asp.data.tracking.checkpoints != null){
                        spd.checkpoints =  asp.data.tracking.checkpoints;
                        system.debug('checkpoints size = ' + asp.data.tracking.checkpoints.size());
                        if(asp.data.tracking.created_at != null && String.isNotBlank(asp.data.tracking.created_at)){
                            system.debug('asp.data.tracking.created_at = ' + asp.data.tracking.created_at);
                            spd.createdAt = formatDate(asp.data.tracking.created_at);
                        }
                        if(asp.data.tracking.updated_at != null && String.isNotBlank(asp.data.tracking.updated_at)){
                            system.debug('asp.data.tracking.updated_at = ' + asp.data.tracking.updated_at);
                            spd.updatedAt = formatDate(asp.data.tracking.updated_at);
                        }
                        spd.lastUpdatedAt = asp.data.tracking.last_updated_at;
                        spd.trackingNumber = asp.data.tracking.tracking_number;
                        
                        if(asp.data.tracking.expected_delivery != null && String.isNotBlank(asp.data.tracking.expected_delivery)){
                            system.debug('asp.data.tracking.expected_delivery = ' + asp.data.tracking.expected_delivery);
                            spd.expectedDelivery = formatDate(asp.data.tracking.expected_delivery);
                        }                          
                    }
                    
                    spd.isInTransit = false;
                    spd.isDispatched = false;
                    spd.isDelivered = false;
                    for(checkpoint c : spd.checkpoints){
                        if(String.isNotBlank(c.created_at)){
                            system.debug('*created_at = ' + c.created_at);
                            c.created_at = formatDate(c.created_at);				
                            system.debug('**created_at = ' + c.created_at);
                        }
                        if(String.isNotBlank(c.checkpoint_time)){
                            system.debug('*checkpoint_time = ' + c.checkpoint_time);					
                            c.checkpoint_time = formatDate(c.checkpoint_time);
                            system.debug('**checkpoint_time = ' + c.checkpoint_time);
                        }
                        
                        if(String.isNotBlank(c.tag)){
                            if(c.tag.contains('InTransit')){
                                spd.isInTransit = true;
                                spd.isDispatched = true;
                            }
                            if(c.tag.contains('Delivered')){
                                spd.isDelivered = true;
                            }
                        }
                    } 
                    system.debug('tracking number= ' + spd.trackingNumber);
                } 
                else if(asp.meta.code == 4004){
                    system.debug('inside post branch');
                    httpRequest postReq = new httpRequest();
                    //Instantiate an httpRequest and set the required attributes
                    postReq.setHeader('Content-Type','application/json');
                    postReq.setMethod('POST');
                    
                    if(services != null && services[0].Endpoint__c != null){
                        postReq.setEndpoint(services[0].Endpoint__c+ 'trackings');
                        postReq.setHeader('aftership-api-key', services[0].Access_Key__c);
                    }
                    system.debug('check 1');
                    AfterShipPostReq postLoad= new AfterShipPostReq();
                    system.debug('check 2');
                    trackingPost tpost=new trackingPost();
                    tpost.tracking_number=trackingNumber;
                    tpost.slug=spd.slug;
					postLoad.tracking=tpost;
                    system.debug('check 3');
                    
                    system.debug('postLoad '+postLoad);
                    String tempJson=(String) JSON.serialize(postLoad);
                    system.debug('tempJson '+tempJson);
                    postReq.setBody(tempJson);
                    
                    postReq.setTimeout(120000);
                    httpResponse postrRes = new http().send(postReq);
                    AfterShipResponse postAsp = (AfterShipResponse)JSON.deserialize(postrRes.getBody(),AfterShipResponse.class);
                    system.debug('Post response data = ' + postAsp.data.toString());
                    
                    if(postAsp != null && postAsp.data != null && postAsp.meta.code != null &&  postAsp.meta.code == 201){
                        List<checkpoint> Postcheckpoints = new List<checkpoint>();
                        if(postAsp.data.tracking != null && postAsp.data.tracking.checkpoints != null){
                            spd.checkpoints =  postAsp.data.tracking.checkpoints;
                            
                            if(postAsp.data.tracking.created_at != null && String.isNotBlank(postAsp.data.tracking.created_at)){
                            	spd.createdAt = formatDate(postAsp.data.tracking.created_at);
                            }
                            if(postAsp.data.tracking.updated_at != null && String.isNotBlank(postAsp.data.tracking.updated_at)){
                            	spd.updatedAt = formatDate(postAsp.data.tracking.updated_at);
                            }
                            spd.lastUpdatedAt = postAsp.data.tracking.last_updated_at;
                            spd.trackingNumber = postAsp.data.tracking.tracking_number;
                            
                            if(postAsp.data.tracking.expected_delivery != null && String.isNotBlank(postAsp.data.tracking.expected_delivery)){
                            	spd.expectedDelivery = formatDate(postAsp.data.tracking.expected_delivery);
                            }    
                            
                        }
                        
                        spd.isInTransit = false;
                        spd.isDispatched = false;
                        spd.isDelivered = false;
                        for(checkpoint c : spd.checkpoints){
                            if(String.isNotBlank(c.created_at)){
                                system.debug('*created_at = ' + c.created_at);
                                c.created_at = formatDate(c.created_at);				
                                system.debug('**created_at = ' + c.created_at);
                            }
                            if(String.isNotBlank(c.checkpoint_time)){
                                system.debug('*checkpoint_time = ' + c.checkpoint_time);					
                                c.checkpoint_time = formatDate(c.checkpoint_time);
                                system.debug('**checkpoint_time = ' + c.checkpoint_time);
                            }
                            
                            if(String.isNotBlank(c.tag)){
                                if(c.tag.contains('InTransit')){
                                    spd.isInTransit = true;
                                    spd.isDispatched = true;
                                }
                                if(c.tag.contains('Delivered')){
                                    spd.isDelivered = true;
                                }
                            }
                        } 
                    }
                    
                    else{
                        
                        spd.isError = true;
                        spd.errorMessage = postAsp.meta.message;
                        
                    }
                    
                }
                else if(asp != null && asp.meta != null && asp.meta.code != null &&  asp.meta.code != 200 &&  asp.meta.code != 4004){
                    spd.isError = true;
                    spd.errorMessage = asp.meta.message;
                }
                
                //Get notification status
                /*if(services != null && services[0].Endpoint__c != null){

httpRequest req1 = new httpRequest();
spd.isEmailToNotification = false;
spd.emailTo = emailTo;
system.debug('check email To ' + emailTo);
req1.setHeader('Content-Type','application/json');
req1.setMethod('GET');

req1.setEndpoint(services[0].Endpoint__c + 'notifications/' + spd.slug +'/' + trackingNumber);
req1.setHeader('aftership-api-key', services[0].Access_Key__c);
//The timeout duration (in milliseconds) to deal with slow servers or large payloads
req1.setTimeout(120000);

//Use the HTTP Class to send the httpRequest and receive an httpResposne
//If you are not using an HttpCalloutMock: 
//if (!test.isRunningTest){

httpResponse res1 = new http().send(req1);

system.debug('response1 =' + res1.toString());
system.debug('response1 body =' + res1.getBody());

AfterShipNotificationResponse asp1 = (AfterShipNotificationResponse)JSON.deserialize(res1.getBody(),AfterShipNotificationResponse.class);
system.debug('response1 data = ' + asp1.data.toString());
if(asp1 != null && asp1.data != null ){					
if(asp1.data.notification != null && asp1.data.notification.emails != null){

for (String s : asp1.data.notification.emails){
if(s.contains(emailTo)){
spd.isEmailToNotification = true;

break;
}
}
}
}
system.debug('emailTo Registered = ' + spd.isEmailToNotification);
system.debug('emailTo Registered = ' + spd.emailTo);
}*/
                
            }
        } catch (Exception e){
            system.debug('Exception '+e);
            spd.isError = true;
            spd.errorMessage = e.getMessage();
        }
        return spd;
    }
    
    private static String formatDate(String dtIn){
        String strTimeInAMorPM = '';
        try{			
            //dtIn format 2020-11-09T14:46:00-05:00
            // Convert String into DateTime using "replace" method of String and "Valueof" method of DateTime
            DateTime acceptableDateTime = DateTime.Valueof(dtIn.replace('T', ' '));
            System.Debug('>>Acceptable DateTime :<<'+acceptableDateTime);			
            strTimeInAMorPM = acceptableDateTime.format('MMMMM dd, yyyy hh:mm:ss a');
            System.debug('time in am and pm ==> '+strTimeInAMorPM); 
            
        } catch (Exception e) {
            system.debug('gg8 = ' + e.getMessage());
        }
        return strTimeInAMorPM;
    }
    
    public class ShipingDetails {
        @AuraEnabled
        public integer indicator;
        @AuraEnabled
        public String url;
        @AuraEnabled
        public String companyName;
        @AuraEnabled
        public String createdAt;
        @AuraEnabled
        public String updatedAt;
        @AuraEnabled
        public String lastUpdatedAt;
        @AuraEnabled
        public String trackingNumber;
        @AuraEnabled
        public String slug;
        @AuraEnabled
        public String expectedDelivery;
        @AuraEnabled
        public Boolean isInTransit;
        @AuraEnabled
        public Boolean isDispatched;
        @AuraEnabled
        public Boolean isDelivered;
        @AuraEnabled
        public List<checkpoint> checkpoints;
        @AuraEnabled
        public String emailTo;
        @AuraEnabled
        public Boolean isEmailToNotification;
        @AuraEnabled
        public String sms;
        @AuraEnabled
        public Boolean isSMSToNotification;
        @AuraEnabled
        public Boolean isError;
        @AuraEnabled
        public String errorMessage;
    }
    
    public class AfterShipResponse {
        @AuraEnabled
        public meta meta;
        @AuraEnabled
        public data data;
    }
    
    public class AfterShipPostReq {
        @AuraEnabled
        public trackingPost tracking;
        
    }
    
    public class trackingPost {
        @AuraEnabled
        public String tracking_number;
        @AuraEnabled
        public String slug;
        
    }
    
    public class meta {
        @AuraEnabled
        public Integer code;
        @AuraEnabled
        public String message;
    }
    
    public class tracking {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String created_at;
        @AuraEnabled
        public String updated_at;
        @AuraEnabled
        public String last_updated_at;
        @AuraEnabled
        public String tracking_number;
        @AuraEnabled
        public String slug;
        @AuraEnabled
        public Boolean active;
        @AuraEnabled
        public List<android> android;
        @AuraEnabled
        public String custom_fields;
        @AuraEnabled
        public String customer_name;
        @AuraEnabled
        public Integer delivery_time;
        @AuraEnabled
        public String destination_country_iso3;
        @AuraEnabled
        public String courier_destination_country_iso3;
        @AuraEnabled
        public List<String> emails;
        @AuraEnabled
        public String expected_delivery;
        @AuraEnabled
        public List<String> ios;
        @AuraEnabled
        public String note;
        @AuraEnabled
        public String order_id;
        @AuraEnabled
        public String order_id_path;
        @AuraEnabled
        public String origin_country_iso3;
        @AuraEnabled
        public Integer shipment_package_count;
        @AuraEnabled
        public String shipment_pickup_date;
        @AuraEnabled
        public String shipment_delivery_date;
        @AuraEnabled
        public String shipment_type;
        @AuraEnabled
        public Double shipment_weight;
        @AuraEnabled
        public String shipment_weight_unit;
        @AuraEnabled
        public String signed_by;
        @AuraEnabled
        public List<String> smses;
        @AuraEnabled
        public String source;
        @AuraEnabled
        public String tag;
        @AuraEnabled
        public String subtag;
        @AuraEnabled
        public String subtag_message;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public Integer tracked_count;
        @AuraEnabled
        public Boolean last_mile_tracking_supported;
        @AuraEnabled
        public String language;
        @AuraEnabled
        public String unique_token;
        @AuraEnabled
        public List<checkpoint> checkpoints;
        @AuraEnabled
        public List<android> subscribed_smses;
        @AuraEnabled
        public List<android> subscribed_emails;
        @AuraEnabled
        public Boolean return_to_sender;
        @AuraEnabled
        public String order_promised_delivery_date;
        @AuraEnabled
        public String delivery_type;
        @AuraEnabled
        public String pickup_location;
        @AuraEnabled
        public String pickup_note;
        @AuraEnabled
        public String courier_tracking_link;
        @AuraEnabled
        public String first_attempted_at;
        @AuraEnabled
        public String courier_redirect_link;
        @AuraEnabled
        public String tracking_account_number;
        @AuraEnabled
        public String tracking_origin_country;
        @AuraEnabled
        public String tracking_destination_country;
        @AuraEnabled
        public String tracking_key;
        @AuraEnabled
        public String tracking_postal_code;
        @AuraEnabled
        public String tracking_ship_date;
        @AuraEnabled
        public String tracking_state;
    }
    
    public class checkpoint {
        @AuraEnabled
        public String slug;
        @AuraEnabled
        public String city;
        @AuraEnabled
        public String created_at;
        @AuraEnabled
        public String location;
        @AuraEnabled
        public String country_name;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String country_iso3;
        @AuraEnabled
        public String tag;
        @AuraEnabled
        public String subtag;
        @AuraEnabled
        public String subtag_message;
        @AuraEnabled
        public String checkpoint_time;
        @AuraEnabled
        public List<android> coordinates;
        @AuraEnabled
        public String state;
        @AuraEnabled
        public String zip;
        @AuraEnabled
        public String raw_tag;
    }
    
    public class data {
        @AuraEnabled
        public Tracking tracking;
    }
    
    public class android {
    }
    
    public class AfterShipNotificationRequest {
        @AuraEnabled
        public notificationdata data;
    }
    
    public class AfterShipNotificationResponse {
        @AuraEnabled
        public meta meta;
        @AuraEnabled
        public notificationdata data;
    }
    
    public class notificationdata {
        @AuraEnabled
        public notification notification;
    }
    
    public class notification {
        @AuraEnabled
        public List<string> emails;
        @AuraEnabled
        public List<string> smses;
        @AuraEnabled
        public List<string> android;
        @AuraEnabled
        public List<string> ios;
    }
    
}
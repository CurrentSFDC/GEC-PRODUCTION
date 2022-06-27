@isTest
global class AfterShipControllerMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();

        if (req.getEndpoint().contains('tracking')) {
            
            if(req.getEndpoint().contains('fedexPOST')){
                if(req.getMethod().contains('POST')){
            	res.setHeader('Content-Type', 'application/json');        
            	res.setBody('{"meta":{"code":201},"data":{"tracking":{"id":"aaaa","created_at":"2020-11-10T01:39:47+00:00","updated_at":"2020-12-23T11:56:37+00:00","last_updated_at":"2020-12-23T11:56:37+00:00","tracking_number":"153705794927","slug":"fedex","active":false,"android":[],"custom_fields":null,"customer_name":null,"delivery_time":2,"destination_country_iso3":"USA","courier_destination_country_iso3":"USA","emails":["user1@gmail.com"],"expected_delivery":"2020-11-10T00:00:00-06:00","ios":[],"note":null,"order_id":null,"order_id_path":null,"origin_country_iso3":"USA","shipment_package_count":1,"shipment_pickup_date":"2020-11-09T06:00:00","shipment_delivery_date":"2020-11-10T17:47:32","shipment_type":"FedEx Ground","shipment_weight":0.2,"shipment_weight_unit":"lb","signed_by":null,"smses":[],"source":"api","tag":"Delivered","subtag":"Delivered_001","subtag_message":"Delivered","title":"32323221","tracked_count":14,"last_mile_tracking_supported":true,"language":null,"unique_token":"deprecated","checkpoints":[{"slug":"fedex","city":"aaa","created_at":"2020-11-10T18:04:14+00:00","location":"aaa, OH, United States","country_name":"USA","message":"Delivered - Left at front door. Signature Service not requested.","country_iso3":"USA","tag":"Delivered","subtag":"Delivered_001","subtag_message":"Delivered","checkpoint_time":"2020-11-10T12:47:32-05:00","coordinates":[],"state":"OH","zip":null,"raw_tag":"DL"}],"subscribed_smses":[],"subscribed_emails":[],"return_to_sender":false,"order_promised_delivery_date":null,"delivery_type":null,"pickup_location":null,"pickup_note":null,"courier_tracking_link":"","first_attempted_at":"2020-11-10T12:47:32-05:00","courier_redirect_link":"","tracking_account_number":null,"tracking_origin_country":null,"tracking_destination_country":null,"tracking_key":null,"tracking_postal_code":null,"tracking_ship_date":null,"tracking_state":null}}}');
            
            	res.setStatusCode(201);
               }
             else{
                 
                 res.setHeader('Content-Type', 'application/json');        
            	 res.setBody('{"meta":{"code":4004},"data":{"tracking":{"id":"aaaa","created_at":"2020-11-10T01:39:47+00:00","updated_at":"2020-12-23T11:56:37+00:00","last_updated_at":"2020-12-23T11:56:37+00:00","tracking_number":"153705794927","slug":"fedex","active":false,"android":[],"custom_fields":null,"customer_name":null,"delivery_time":2,"destination_country_iso3":"USA","courier_destination_country_iso3":"USA","emails":["user1@gmail.com"],"expected_delivery":"2020-11-10T00:00:00-06:00","ios":[],"note":null,"order_id":null,"order_id_path":null,"origin_country_iso3":"USA","shipment_package_count":1,"shipment_pickup_date":"2020-11-09T06:00:00","shipment_delivery_date":"2020-11-10T17:47:32","shipment_type":"FedEx Ground","shipment_weight":0.2,"shipment_weight_unit":"lb","signed_by":null,"smses":[],"source":"api","tag":"Delivered","subtag":"Delivered_001","subtag_message":"Delivered","title":"32323221","tracked_count":14,"last_mile_tracking_supported":true,"language":null,"unique_token":"deprecated","checkpoints":[{"slug":"fedex","city":"aaa","created_at":"2020-11-10T18:04:14+00:00","location":"aaa, OH, United States","country_name":"USA","message":"Delivered - Left at front door. Signature Service not requested.","country_iso3":"USA","tag":"Delivered","subtag":"Delivered_001","subtag_message":"Delivered","checkpoint_time":"2020-11-10T12:47:32-05:00","coordinates":[],"state":"OH","zip":null,"raw_tag":"DL"}],"subscribed_smses":[],"subscribed_emails":[],"return_to_sender":false,"order_promised_delivery_date":null,"delivery_type":null,"pickup_location":null,"pickup_note":null,"courier_tracking_link":"","first_attempted_at":"2020-11-10T12:47:32-05:00","courier_redirect_link":"","tracking_account_number":null,"tracking_origin_country":null,"tracking_destination_country":null,"tracking_key":null,"tracking_postal_code":null,"tracking_ship_date":null,"tracking_state":null}}}');
                 res.setStatusCode(4004);                
                    
                }   
            }
            else{
                res.setHeader('Content-Type', 'application/json');        
            	res.setBody('{"meta":{"code":200},"data":{"tracking":{"id":"aaaa","created_at":"2020-11-10T01:39:47+00:00","updated_at":"2020-12-23T11:56:37+00:00","last_updated_at":"2020-12-23T11:56:37+00:00","tracking_number":"153705794927","slug":"fedex","active":false,"android":[],"custom_fields":null,"customer_name":null,"delivery_time":2,"destination_country_iso3":"USA","courier_destination_country_iso3":"USA","emails":["user1@gmail.com"],"expected_delivery":"2020-11-10T00:00:00-06:00","ios":[],"note":null,"order_id":null,"order_id_path":null,"origin_country_iso3":"USA","shipment_package_count":1,"shipment_pickup_date":"2020-11-09T06:00:00","shipment_delivery_date":"2020-11-10T17:47:32","shipment_type":"FedEx Ground","shipment_weight":0.2,"shipment_weight_unit":"lb","signed_by":null,"smses":[],"source":"api","tag":"Delivered","subtag":"Delivered_001","subtag_message":"Delivered","title":"32323221","tracked_count":14,"last_mile_tracking_supported":true,"language":null,"unique_token":"deprecated","checkpoints":[{"slug":"fedex","city":"aaa","created_at":"2020-11-10T18:04:14+00:00","location":"aaa, OH, United States","country_name":"USA","message":"Delivered - Left at front door. Signature Service not requested.","country_iso3":"USA","tag":"Delivered","subtag":"Delivered_001","subtag_message":"Delivered","checkpoint_time":"2020-11-10T12:47:32-05:00","coordinates":[],"state":"OH","zip":null,"raw_tag":"DL"}],"subscribed_smses":[],"subscribed_emails":[],"return_to_sender":false,"order_promised_delivery_date":null,"delivery_type":null,"pickup_location":null,"pickup_note":null,"courier_tracking_link":"","first_attempted_at":"2020-11-10T12:47:32-05:00","courier_redirect_link":"","tracking_account_number":null,"tracking_origin_country":null,"tracking_destination_country":null,"tracking_key":null,"tracking_postal_code":null,"tracking_ship_date":null,"tracking_state":null}}}');
            
            	res.setStatusCode(200);
                
            }
            
        } else if (req.getEndpoint().contains('notification')) {
            
            res.setHeader('Content-Type', 'application/json');        
            res.setBody('{"meta":{"code":200},"data":{"notification":{"emails":["user1@gmail.com","user2@gmail.com"],"smses":["+85291239123","+85261236123"]}}}');
            
            res.setStatusCode(200);
            
        }
        return res;
    }
}
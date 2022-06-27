({
    getTrackingDetails : function(component, event, helper) {
        component.set("v.inProgress", true);

        var params = event.getParam('arguments');
        if (params) {
            component.set("v.bShowModal", false);
            var param1 = params.carrierName;
            var param2 = params.trackingNumber;
            var param3 = $A.get("$SObjectType.CurrentUser.Email");
            //console.log('param1' + param1);
            //console.log('param2' + param2);
            //console.log('param3' + param3);
            // add your code here
        
            var action = component.get("c.getTrackingDetails");
            var recordId = component.get("v.recordId");
            //console.log('step1');
            //'FEDEX GROUND','153705794927'      
            action.setParams({"carrierName" : param1, "trackingNumber" : param2, "emailTo" : param3 });
            //action.setParams({"carrierName" : 'FEDEX GROUND', "trackingNumber" : '153705794927' });
            action.setCallback(this,function(response){   
                console.log('Tracking Call Response getState',response.getState());
                console.log('Tracking Call Response getReturnValue',response.getReturnValue());

                var state = response.getState();
                //console.log('step2');
                //console.log('response status' + response.getState());
                if(state === "SUCCESS"){
                    //console.log('response status' + response.getState());
                    var records = response.getReturnValue();
                    if(records.checkpoints!==undefined){
                        records.checkpoints=records.checkpoints.reverse();
                    }
                    //console.log('indicator=' + records.indicator);
                    //console.log('url=' + records.url);
                    component.set("v.shipmentData", records);
                    //console.log('tracking number=' + records.trackingNumber);
                    if(records.indicator == 1){
                        window.open(records.url,'_blank');
                        component.set("v.bShowModal", false);
                    }    
                    else if(records.indicator == 0 ){
                        component.set("v.bShowModal", true);
                    }
                    else if(records.indicator == 2 ){
                        component.set("v.bShowModal", true);
                    } else {

                    }
                }
                else if (state === "ERROR") 
                {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            //console.log(errors[0].message);
                            helper.addPageMessage(component, "error","Error message: " + errors[0].message);
                        }
                    } 
                    else {
                        helper.addPageMessage(component, "error", "There was a problem returning the latest Shipment Information. Please contact your GE Current for help.");
                    }
                }
                window.scrollTo(0, 150);
                component.set("v.inProgress", false);
            });
            //console.log('step3');
            $A.enqueueAction(action);
            //console.log('step4');
        }
    },

    
    registerForNotifications : function(component, event, helper) {
        var data = component.get('v.shipmentData'); 
        //console.log('data' + data);
        if (data != null) {                
            var param1 = data.companyName;
            var param2 = data.trackingNumber;
            var param3 = data.emailTo;
            var param4 = data.slug;
            //console.log('param1*' + param1);
            //console.log('param2' + param2);
            //console.log('param3' + param3);
            //console.log('param4*' + param4);
            // add your code here       
            var action1 = component.get("c.regForNotifications"); 
            action1.setParams({"carrierName" : param1, "trackingNumber" : param2, "emailTo" : param3, "slug" : param4 });            
               
            action1.setCallback(this,function(response){
                var state = response.getState();                
                //console.log('response status' + response.getState());
                if(state === "SUCCESS"){
                    //console.log('response status of registerForNotifications' + response.getState());                   
                    //console.log('records' + response.getReturnValue());
                    component.set('v.shipmentData.isEmailToNotification', true);                   
                }
                else if (state === "ERROR") 
                {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            //console.log(errors[0].message);
                            helper.addPageMessage(component, "error","Error message: " + errors[0].message);
                        }
                    } 
                    else {
                        helper.addPageMessage(component, "error", "There was a problem while registering for the Shipment Information. Please contact your GE Current for help.");
                    }
                }
            });           
            $A.enqueueAction(action1);           
        }
    },


    addPageMessage: function(component, severity, messages, closable) {
        if ($A.util.isEmpty(messages)) { return; }
        if (!$A.util.isArray(messages)) { messages = [messages]; }
        var pageMessage = {};
        pageMessage.closable = closable;
        pageMessage.severity = (severity) ? severity.toLowerCase() : "error";
        pageMessage.messages = (messages) ? messages : [];
        pageMessage.title = (severity === "confirm") ? "Success" : (severity === "warning") ? "Warning"
                                : (severity === "info") ? "Information" : "Error";

        var pageMessages = component.get("v.pageMessages");
        pageMessages.push(pageMessage);
        component.set("v.pageMessages", pageMessages);
    },

    closeModal: function(component, event, helper){
        component.set("v.bShowModal", false);
    },

    showModal: function(component, event, helper){
        component.set("v.bShowModal", true);
    },
    
    hideSpinner : function (component, event, helper) {
            var spinner = component.find('spinner');
            var evt = spinner.get("e.toggle");
            evt.setParams({ isVisible : false });
            evt.fire();    
    }
    

})
({


    getCountries: function(component) {
        
        var action = component.get("c.getCountries"); 
       
        action.setCallback(this, function(response) {
            var state = response.getState();
            var records = response.getReturnValue();
            if (state === "SUCCESS") {
                component.set("v.countries", records);            
            }else{
                var errorList = helper.getErrors(response);     
            }
        });
       
         $A.enqueueAction(action);
    },

    getStates: function(component) {
        
        var action = component.get("c.getStates"); 
        action.setParams({"country" : component.get("v.previousCountry") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var records = response.getReturnValue();
            if (state === "SUCCESS") {
                component.set("v.states", records);            
            }else{
                var errorList = helper.getErrors(response);     
            }
        });
       
         $A.enqueueAction(action);
    },

    handleCreateUser: function (component, helper) {        
        
        component.set("v.inProgress", true);
        component.set("v.pageMessages", []);
        var userdata = component.get("v.userData"); 
        
        var action = component.get("c.registerUser");
        action.setParams({"userData" : component.get("v.userData") });
       
        action.setCallback(this, function(response) {
            var state = response.getState();
           
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result) { result  = result.toLowerCase(); }

                if (result === "valid") {
                    component.set("v.disable", true);
                   
                    helper.addPageMessage(component, "confirm",$A.get("$Label.c.SelfRegistration_Success_Message"), false);
                } else if (result === "invalid-email") {
                    helper.addPageMessage(component, "error", "_Input_EmailInvalid");
                } else if (result === "existing-contact" || result === "existing-user") {
                    helper.addPageMessage(component, "error", $A.get("$Label.c.SelfRegistration_EmailAddressAlreadyRegister"));
                } else if (result === "invalid-account") {
                    helper.addPageMessage(component, "error", $A.get("$Label.c.SelfRegistration_NoAccountMessage"));
                } else if (result === "tnctosign") {
                    helper.addPageMessage(component, "error", $A.get("$Label.c.SelfRegistration_Terms_Conditions"));
                } else if (result === "exception") {
                        helper.addPageMessage(component, "error", $A.get("$Label.c.SelfRegistration_ErrorMessageContactCreation"));
                } else if (result === "invalid") {
                        helper.addPageMessage(component, "error", $A.get("$Label.c.SelfRegistration_CompleteRequiredFields"));
                } else if (result !== "invalid") {
                    helper.addPageMessage(component, "error", "Error_Unknown");
                }
            } else {
               
                var errorList = helper.getErrors(response);
                
            }
           
            //window.scrollTo(0, 150);
            console.log("Scroll To Top");
            window.scrollTo({top: 0, behavior: 'smooth'});
            component.set("v.inProgress", false);
        });
       
        $A.enqueueAction(action);
    },

    navigateToURL: function(redirectUrl) {
        if (!redirectUrl) { return; }

        try {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({"url": redirectUrl});
            urlEvent.fire();
        } catch(e){
            window.location = redirectUrl;
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

    validateForm : function(component, helper, hideMessage) {
        var hasErrors = false;
        var formFieldComps = component.find("form-field");
        if (!$A.util.isArray(formFieldComps)) { formFieldComps = [formFieldComps]; }

        formFieldComps.forEach(function(fieldComp) {
            if (fieldComp && fieldComp.get("v.validity")) {
                var fieldValidity = fieldComp.get("v.validity");
                if (!fieldValidity.valid) {
                    hasErrors = true;
                    if (!hideMessage) {
                        fieldComp.showHelpMessageIfInvalid();
                    }
                }
            }
        });

        return (!hasErrors);
    },   

    fetchPrefferedLanguagePicklistVal: function(component) {
        var action = component.get("c.getPrefferedLanguageSelectOptions");
        var opts = [];
        
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                
                var allValues = response.getReturnValue();
                /*
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "Select Your Default Language",
                        value: ""
                    });
                }
                */
                for (var i = 0; i < allValues.length; i++) {
                    
                    opts.push({
                        class: "optionClass",
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                component.set("v.preferredLanguageList", opts);
                
            }
        });
       
        $A.enqueueAction(action);
    }

})
({
    doInit : function(component, event, helper) {

    },

    
    closeModal: function(component, event, helper){
        helper.closeModal(component, helper);
    },
    


    showModal: function(component, event, helper){  
        // console.log('got the event');      
        component.set("v.inProgress", true);
        helper.getTrackingDetails(component, event, helper);
        component.set("v.inProgress", false);
        var ind = component.get('v.shipmentData.indicator'); 
        if(ind == 0 || ind == 1) {       
            helper.showModal(component, helper);
        }
    },

    registerForNotifications: function(component, event, helper){  
        // console.log('got the event to register');     
        helper.registerForNotifications(component, event, helper);
    }

})
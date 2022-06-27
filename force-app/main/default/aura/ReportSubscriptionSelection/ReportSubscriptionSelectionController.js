({
    saveReportSubscriptions: function(component, event, helper) {  
        helper.saveReportSubscriptionsHelper(component, helper);
        component.set("v.inProgress", false);
    },

    init: function(component, event, helper){
        helper.fetchData(component, helper);
        component.set("v.inProgress", false);
    }
    
  
    
  

})
({
    doInit: function(component, event, helper){        
        component.set("v.inProgress", true);
        helper.getInvoiceDetails(component, event, helper);
        component.set("v.inProgress", false);
    },

    showInvoicePdfModal :function(component,event,helper){
        var inv = event.target.id;
        var objCompInvoicePdf = component.find('compInvoicePdfInvoiceLineItems');
        objCompInvoicePdf.invoicePdfMethod(inv);
    },

    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
        
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    },

})
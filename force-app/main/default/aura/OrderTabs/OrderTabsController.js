({
    doInit: function(component, event, helper){ 
        
        //back button fix
            if (typeof history.pushState === "function") {
                history.pushState("dummy", null, null);
                window.onpopstate = function () {
                    //window.location.replace('../../');
                   
                   // window.location.replace('/Agents');
                   console.log("Check for eralier URL" + window.history);
                   //window.history.back()
                   window.location.replace('/s');
                };
            }     
        component.set("v.inProgress", true);
        helper.getOrderSFDCFields(component, event, helper);
        helper.getOrderDetails(component, event, helper);
        component.set("v.inProgress", false);
    },
    onAction : function(component, event, helper) {
        var objCompB = component.find('compB');
        objCompB.aftershipMethod('FEDEX GROUND','153705794927');
    },

    showInvoicePdfModal :function(component,event,helper){
        var inv = event.target.id;
        console.log("Inv Id" + inv);
        
        var objCompInvoicePdf = component.find('compInvoicePdfOrderLineItems');
        objCompInvoicePdf.invoicePdfMethod(inv);
    },

    showOrderConfirmationPdfModal :function(component,event,helper){
        var ord = event.target.id;
       
        var objCompOrderAckPdf = component.find('compOrderAckPdf');
        objCompOrderAckPdf.orderAckPdfMethod(ord);
    },

    showAgreementPdfModal :function(component,event,helper){
        var agreement = event.target.id;
        
        var objCompAgreementPdf = component.find('AgreementPDFLineItems');
        objCompAgreementPdf.agreementPdfMethod(agreement);
    },

    showRmaPdfModal :function(component,event,helper){
        var ord = event.target.id;
        
        var RMAPdf = component.find('RMAPdf');
        RMAPdf.orderRMAPdfMethod(ord);
    },

    handleRowAction :function(component,event,helper){
        console.log('Inside handleRowAction');
        //action gives which action performed
        //var action = event.getParam('action');
        // console.log('*****action='+ event.getParam('action').name);
        //row gives complete row information
        //var row = event.getParam('row');
        // console.log('*****row:'+JSON.stringify(row) + '***');
       

        //var actionName = event.getParam('action').name;
        
        var actionName = event.target.name;
        var itemNumber = event.target.id;

        console.log('Inside actionName',actionName);
        console.log('Inside itemNumber',itemNumber);

        if ( actionName == 'Invoice' ) {
            // console.log('*****row:'+ row.INVOICE_NUMBER);
            var objCompInvoicePdf = component.find('compInvoicePdf');
            objCompInvoicePdf.invoicePdfMethod(itemNumber);
        } else  if ( actionName == 'DeliveryNote' ) {
            // console.log('*****row:'+ row.DEL_NUMBER);
            var objCompDeliveryNotesPdf = component.find('compDeliveryNotesPdf');
            objCompDeliveryNotesPdf.deliveryNotesPdfMethod(itemNumber);
        } else {
            var objCompB = component.find('compB');
            objCompB.aftershipMethod(actionName,itemNumber);
        }

       
        //alert('You have selected View Action for '+row.Name+'(id='+row.Id+')');
    },

    getSelectedName: function (cmp, event) {
        var selectedRows = event.getParam('selectedRows');
        // Display that fieldName of the selected rows
        for (var i = 0; i < selectedRows.length; i++){
            //alert("You selected: " + selectedRows[i].opportunityName);
        }
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

    toggle: function(component, event, helper) {
       
        var items = component.get("v.orderItemData");        
        var index = event.getSource().get("v.value");        
        items[index].expanded = !items[index].expanded;
        component.set("v.orderItemData", items);
    },

    accordionLoaded: function(component, event, helper) {
        var orderDetails = document.getElementById('custom_order_details');
        orderDetails.style.display = "flex";


        var x = document.getElementById('accordionDiv').firstChild;
        // console.log(x);
        component.set('v.accordionLoaded', true);
        if(component.get('v.accordionLoaded') && component.get('v.orderItemData').length > 0){
            // console.log('setting accordion titles...');
            
            helper.setAccordionTitles(component, component.get('v.orderItemData'));
            

        }
        
    },

    handleBackButton: function(component, event, helper) {
        window.location.replace('../../');
    },

    hideDetailElement: function(component, event, helper) {
        var orderDetails = document.getElementById('custom_order_details');
        orderDetails.style.display = "none";
    }

})
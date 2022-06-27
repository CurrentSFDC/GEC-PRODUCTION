({

    handleClick: function(component, event, helper) {
        helper.fetchData(component); 
    },

    handleKeyUp: function(component, event, helper) {
        if (event.which == 13) {
            helper.fetchData(component);
        }
    },

    init: function(component, event, helper) {
        // console.log('init:');
        helper.fetchData(component);
    },

    handleRowAction: function(component, event, helper) {
        var action = event.getParam('action');
        var data = component.get("v.data");
        var row = event.getParam('row');
        switch(action.name){
            case 'modify':
                var url = helper.viewInvoice(component, row);
                break;
            case 'invoicePDF':
                // console.log('invoicePDF data: ', data);
                // console.log('*****row:'+JSON.stringify(row) + '***');
                // // console.log(row.GE_LGT_EM_SAPInvoiceNumber__c);
                // var objCompInvoicePdf = component.find('compInvoicePdf');
                // objCompInvoicePdf.invoicePdfMethod(row.GE_LGT_EM_SAPInvoiceNumber__c);
        }
    },

    //Method gets called by onsort action,
    handleSort : function(component,event,helper){
        //Returns the field which has to be sorted
        var sortBy = event.getParam("fieldName");
        //returns the direction of sorting like asc or desc
        var sortDirection = event.getParam("sortDirection");
        //Set the sortBy and SortDirection attributes
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        // call sortData helper function
        helper.sortData(component,sortBy,sortDirection);
    }

})
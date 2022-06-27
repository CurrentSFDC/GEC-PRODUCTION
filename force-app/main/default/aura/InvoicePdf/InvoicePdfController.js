({
	showModal : function(component, event, helper) {     
        component.set("v.inProgress", true);
		helper.getInvoiceData(component, event, helper);
        component.set("v.inProgress", false);
	},

	closeModal: function(component, event, helper){
        helper.closeModal(component, event, helper);
    },
    
})
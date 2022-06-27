({
    getInvoiceDetails : function(component, event, helper) {
        component.set("v.inProgress", true);
        
        var action = component.get("c.getInvoiceDetails");
        var recordId = component.get("v.recordId");
             
        // console.log('Id=' + recordId);
        action.setParams({"invoiceId" : recordId });
        action.setCallback(this,function(response){   
            
            var state = response.getState();
            if(state === "SUCCESS"){
                // console.log('Success, state: ' + response.getState());
                var records = response.getReturnValue();
                // console.log('records' + records);
                component.set("v.invoiceItemData", records);

            }
            else if (state === "ERROR") 
			{
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						helper.addPageMessage(component, "error","Error message: " + errors[0].message);
					}
				} 
				else {
                    helper.addPageMessage(component, "error", "There was a problem returning the latest Order Information. Please contact your GE Current for help.");
				}
			}            
            component.set("v.inProgress", false);
        });
        $A.enqueueAction(action);
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

    processItemData: function(component, records){
        var itemData = records.salesItemData;                
        component.set("v.orderItemData", itemData);
    }
})
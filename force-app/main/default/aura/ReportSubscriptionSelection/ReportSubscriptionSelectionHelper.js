({
    fetchData: function(component, helper) {
        // queries for subscriptions
        // then sets subscriptions to marked/unmarked
        var selaccountid1; 
        let agentNumber1 = localStorage.getItem('AgentNumber'); 
        let Distributornumber1 = localStorage.getItem('DistributorAccount');
        if(agentNumber1 == null){
            selaccountid1 = Distributornumber1;
            console.log('DistributorAccount1',selaccountid1);
        }
        else{
            selaccountid1 = agentNumber1;
            console.log('agentNumber1',selaccountid1);

        }
        var action = component.get('c.queryReportSubscriptions');   
        action.setParams({
            'customernum1': selaccountid1
        });
  
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var records = response.getReturnValue();
                if(records!=null){
                   // component.set('v.checkCutOrderReport', records.Cut_Order_Report__c);
                   // component.set('v.checkDailyCommissionReport', records.Daily_Commission_Report__c);
                    component.set('v.checkDueDTCGEReport', records.Due_DT_CGE_Report__c);
                    component.set('v.checkMonthlyCommissionReport', records.Monthly_Commission_Report__c);
                    component.set('v.checkOpenOrderReport', records.Open_Order_Report__c);
                    component.set('v.checkOrderLineReport', records.Order_Line_Report__c);
                    component.set('v.checkOrderShipReport', records.Order_Ship_Report__c);
                  //  component.set('v.checkInvoiceByBill', records.Invoice_By_Bill__c);
                  //  component.set('v.checkPriceMismatch', records.Price_Mismatch__c);
                  console.log('selaccountid1: ', selaccountid1);
                }
            }
            // else(console.log('fetchData: ',response.getError()));
        });
        $A.enqueueAction(action);
    },
        
    saveReportSubscriptionsHelper: function(component, helper) {

        helper.showSuccessToast(component);
        
        var selaccountid; 
        let agentNumber = localStorage.getItem('AgentNumber'); 
        let Distributornumber = localStorage.getItem('DistributorAccount');
        if(agentNumber == null){
            selaccountid = Distributornumber;
            console.log('DistributorAccount',selaccountid);
        }
        else{
            selaccountid = agentNumber;
            console.log('agentNumber',selaccountid);

        }
        var action = component.get('c.setReportSubscriptions');
        // var checkCutOrderReport = document.getElementById("ckCutOrderReport").checked;    
        // var checkDailyCommissionReport = document.getElementById("ckDailyCommissionReport").checked;
        var checkDueDTCGEReport = document.getElementById("ckDueDTCGEReport").checked;
        var checkMonthlyCommissionReport = document.getElementById("ckMonthlyCommissionReport").checked; 
        var checkOpenOrderReport = document.getElementById("ckOpenOrderReport").checked;
        var checkOrderLineReport = document.getElementById("ckOrderLineReport").checked;
        var checkOrderShipReport = document.getElementById("ckOrderShipReport").checked; 
       // var checkInvoiceByBill = document.getElementById("ckInvoiceByBill").checked;
       // var checkPriceMismatch = document.getElementById("ckCheckPriceMismatch").checked;


        action.setParams({
            'checkDueDTCGEReport':checkDueDTCGEReport, 
            'checkMonthlyCommissionReport':checkMonthlyCommissionReport, 
            'checkOpenOrderReport':checkOpenOrderReport, 
            'checkOrderLineReport':checkOrderLineReport, 
            'checkOrderShipReport':checkOrderShipReport,
            'customernum': selaccountid
        });


        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result) { result  = result.toLowerCase(); }

                if (result === "valid") {
                    component.set("v.disable", true);

                    helper.addPageMessage(component, "confirm", "Your Report Subscriptions Have Been Saved!");
                   
                } else if (result === "exception") {
                        helper.addPageMessage(component, "error", "Exception");
                } else if (result !== "invalid") {
                    helper.addPageMessage(component, "error", "Error_Unknown");
                }
            } 
            // else {
            //     console.log(response.getError());
            //     var errorList = helper.getErrors(response);
            //     console.log(errorList);
                
            // }          
        });

        $A.enqueueAction(action);
    },

    showSuccessToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: 'Your Report Subscriptions have been saved',
            messageTemplate: 'Record {0} created! See it {1}!',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
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


})
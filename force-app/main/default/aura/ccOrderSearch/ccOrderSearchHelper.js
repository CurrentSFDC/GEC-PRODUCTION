({
    fetchData : function(component) {

        var searchText = component.get('v.searchText');
        var startDate;
        var endDate;
        var defaultDate;

        if(component.get('v.startDate') == null){
            var defaultDate = new Date(0);
            startDate = defaultDate.getFullYear() + "-" + (defaultDate.getMonth() + 1) + "-" + defaultDate.getDate();
        }
        else{
            startDate = component.get('v.startDate');
        }

        if(component.get('v.endDate') == null){
            var defaultDate = new Date();
            endDate = defaultDate.getFullYear() + "-" + (defaultDate.getMonth() + 1) + "-" + defaultDate.getDate();
        }
        else{
            endDate = component.get('v.endDate');
        }
        
        if (searchText == '') {
            var action = component.get('c.initCCOrders');
            action.setParams({"startDateStr": startDate, "endDateStr": endDate});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS') {
                    var records = response.getReturnValue();
                    this.makeTable(component, records);
                }
                // else(console.log(response.getError()));
            });
            $A.enqueueAction(action);
        }
        else{
            var action = component.get('c.searchForCCOrders');
            action.setParams({"searchText": searchText, "startDateStr": startDate, "endDateStr": endDate});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS') {
                    var records = response.getReturnValue();
                    this.makeTable(component, records);
                }
                // else(console.log(response.getError()));
            });
            $A.enqueueAction(action);
        }

    },
    makeTable : function(component, records) {
        records.forEach(function(record){
            record.ccrz__OrderDate__c=record.ccrz__OrderDate__c.replace(/-/g, '\/');
        });
        component.set('v.columns', [
            {label: $A.get("$Label.c.orderSearchOrderNo"), fieldName: 'linkName', type: 'url', initialWidth: 250, wrapText: true,
                typeAttributes: {label: { fieldName: 'SAP_Order_Number__c' }, target: '_self'}},
            {label: $A.get("$Label.c.ccOrderSearchType"), fieldName: 'Order_Type__c', type: 'text', initialWidth: 200, wrapText: true},
            {label: $A.get("$Label.c.orderSearchStatus"), fieldName: 'ccrz__OrderStatus__c', type: 'text', initialWidth: 200, wrapText: true},
            //{label: $A.get("$Label.c.orderSearchStatus"), fieldName: 'SAP_Order_Number__c', type: 'text', initialWidth: 100, wrapText: true},
            {label: $A.get("$Label.c.ccOderSearchOrderDate"), fieldName: 'ccrz__OrderDate__c', type: 'date', typeAttributes: {  
                day: 'numeric',  
                month: 'numeric',  
                year: 'numeric',   
                hour12: true}, initialWidth: 150, wrapText: true},
            {label: $A.get("$Label.c.orderSearchAmount"), fieldName: 'ccrz__TotalAmount__c', type: 'currency', typeAttributes: { currencyCode: 'USD', maximumSignificantDigits: 5}, initialWidth: 200, wrapText: true,
                cellAttributes: { alignment: 'left' }}
        ]);

        records.forEach(function(record){
            record.linkName = '../../DefaultStore/ccrz__OrderView?o='+record.ccrz__EncryptedId__c;
            if(record.Account!=null){
                record.AccountName = record.Account.Name;
                delete record.Account;
            }
            if(record.Sold_To__r!=null){
                record.Sold_To_Account__c = record.Sold_To_Account__c;
            delete record.Sold_To_Account__c;
            }
        });
        component.set('v.data', records);
        document.getElementById('ccOrdersTable').style.display='block';
    },

    reorder: function (cmp, row) {
        var data = cmp.get('v.data');

        var action = cmp.get('c.reorder');
        action.setParams({orderId: row.Id});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                //send user to cart page in storefront
                var cartId = response.getReturnValue();
                cmp.find("navigationService").navigate({ 
                    type: "standard__webPage", 
                    attributes: { 
                        url: cartId 
                    } 
                });
            }
            // else(console.log(response.getError()));
        });
        $A.enqueueAction(action);

        return cartId;
    },
})
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
            var action = component.get('c.initOrders');
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
            var action = component.get('c.searchForOrders');
            action.setParams({"startDateStr": startDate, "endDateStr": endDate, "searchText": searchText});
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
        component.set('v.columns', [
            {label: $A.get("$Label.c.orderSearchOrderNo"), fieldName: 'linkName', type: 'url', initialWidth: 175, wrapText: true,
                typeAttributes: {label: { fieldName: 'GE_Order_NO__c' }, target: '_self'}},
            {label: $A.get("$Label.c.orderSearchPO"), fieldName: 'Customer_PO_Number__c', type: 'text', initialWidth: 170, wrapText: true},
            //{label: $A.get("$Label.c.orderSearchGECNo"), fieldName: 'GE_Order_NO__c', type: 'text', initialWidth: 170, wrapText: true},
            {label: $A.get("$Label.c.orderSearchSoldTo"), fieldName: 'SoldToName', type: 'text', initialWidth: 150, wrapText: true},
            {label: $A.get("$Label.c.orderSearchInvoiceNo"), fieldName: 'invoice', type: 'text', initialWidth: 110, wrapText: true},
            {label: $A.get("$Label.c.orderSearchAmount"), fieldName: 'TotalAmount', type: 'currency', typeAttributes: { currencyCode: 'USD', maximumSignificantDigits: 5}, initialWidth: 100, wrapText: true},
            {label: $A.get("$Label.c.orderSearchStartDate"), fieldName: 'EffectiveDate', type: 'date', typeAttributes: {  
                day: 'numeric',  
                month: 'numeric',  
                year: 'numeric',   
                hour12: true}, initialWidth: 90, wrapText: true},
            {label: $A.get("$Label.c.orderSearchStatus"), fieldName: 'GBSTK__c', type: 'text', initialWidth: 80, wrapText: true},
            {label: $A.get("$Label.c.orderSearchReorder"), type: 'button', initialWidth: 135, typeAttributes: { label: $A.get("$Label.c.orderSearchReorder"), name: 'reorder', title: $A.get("$Label.c.orderSearchReorder")}, cellAttributes: { alignment: 'center'}, initialWidth: 100, wrapText: true}
        ]);

        records.forEach(function(record){
            record.linkName = '/Agents/s/order/'+record.Id;
            if(record.Account!=null){
                record.AccountName = record.Account.Name;
                delete record.Account;
            }
            if(record.Sold_To__r!=null){
                record.SoldToName = record.Sold_To__r.Name;
            delete record.Sold_To__r;
            }
        });
        component.set('v.data', records);
        document.getElementById('myTable').style.display='block';
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
                window.location.replace(cartId);
                // cmp.find("navigationService").navigate({ 
                //     type: "standard__webPage", 
                //     attributes: { 
                //         url: cartId 
                //     } 
                // });
            }
            // else(console.log(response.getError()));
        });
        $A.enqueueAction(action);

        return cartId;
    },
})
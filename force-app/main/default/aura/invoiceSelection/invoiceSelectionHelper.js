({
    
    fetchData: function(component){
        // console.log('fetchData');
        var searchText = component.get('v.searchText');
        var startDate;
        var endDate;
        var defaultDate;

        // console.log('Search Text: ', searchText);

        if(component.get('v.startDate') == null){
            var defaultDate = new Date(0);
            startDate = defaultDate.getFullYear() + "-" + (defaultDate.getMonth() + 1) + "-" + defaultDate.getDate();
            // console.log('Start Date: ', startDate);
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
            var action = component.get('c.initInvoices');
            action.setParams({"startDateStr": startDate, "endDateStr": endDate});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS') {
                    var records = response.getReturnValue();
                    this.makeTable(component, records);
                    // console.log('fetchData records: ', records);
                }
                // else(console.log('fetchData error', response.getError()));
            });
            $A.enqueueAction(action);

        }
        else {
            var action = component.get('c.searchForInvoice');
            action.setParams({"startDateStr": startDate, "endDateStr": endDate, "searchText": searchText});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS') {
                    var records = response.getReturnValue();
                    this.makeTable(component, records);
                    // console.log('Search Records: ', records);
                }
                // else(console.log(response.getError()));
            });
            $A.enqueueAction(action);
        }


    },


    makeTable: function(component, records){
        // console.log('makeTable');
        component.set('v.columns', [
            // {label: $A.get("$Label.c.invoiceSelectionNumber"), fieldName: 'GE_LGT_EM_SAPInvoiceNumber__c', type: 'text', initialWidth:100, wrapText: true},
            {label: $A.get("$Label.c.invoiceSelectionNumber"), fieldName: 'linkName', type: 'url', initialWidth:100, wrapText: true, sortable : true,
                        typeAttributes: {label: {fieldName:'GE_LGT_EM_SAPInvoiceNumber__c'},target:'_self'}},
            {label: "Name", fieldName: 'Name', type: 'text', initialWidth:100, wrapText: true},
            {label: $A.get("$Label.c.invoiceSelectionSoldToAccountNumber"), fieldName:'GE_LGT_EM_Sold_to_Account_Number__c', type: 'text', initialWidth:100, wrapText:true, sortable : true},
            {label: $A.get("$Label.c.invoiceSelectionCustomerName"), fieldName:'GE_LGT_EM_CustomerName__c', type: 'text', initialWidth:100, wrapText:true, sortable : true},
            {label: $A.get("$Label.c.invoiceSelectionCreationDate"), fieldName:'GE_LGT_EM_Invoice_Creation_Date__c', type: 'text', initialWidth:100, wrapText:true, sortable : true},
            {label: $A.get("$Label.c.invoiceSelectionBillingDate"), fieldName:'GE_LGT_EM_Billing_Date__c', type: 'text', initialWidth:100, wrapText:true, sortable : true},
            {label: $A.get("$Label.c.invoiceSelectionTaxNumber"), fieldName:'GE_LGT_EM_Tax_Number_1__c', type: 'text', initialWidth:100, wrapText:true, sortable : true},
            {label: $A.get("$Label.c.invoiceSelectionNetValue"), fieldName:'GE_LGT_EM_Net_value__c', type: 'text', initialWidth:100, wrapText:true, sortable : true},
            // {label: $A.get("$Label.c.invoiceSelectionInvoiceCurrency"), fieldName:'Invoice_Currency__c', type: 'text', initialWidth:100, wrapText:true, sortable : true},
            {label: $A.get("$Label.c.invoiceSelectionISOCurrency"), fieldName:'CurrencyIsoCode', type: 'text', initialWidth:100, wrapText:true, sortable : true},
            // {label: $A.get("$Label.c.invoiceSelectionViewButton"), type: 'button', initialWidth: 135, 
            //     typeAttributes: { label: $A.get("$Label.c.invoiceSelectionViewButton"), name: 'invoicePDF', title: 'viewInvoice'},
            //     cellAttributes: { alignment: 'center'}, initialWidth: 100, wrapText: true}
        ]);

        records.forEach(function(record){
            // console.log('Record : ', record);
            record.linkName = '/Agents/s/invoice/'+record.Id;
            // if(record.Account!=null){
            //     record.AccountName = record.Account.Name;
            //     delete record.Account;
            // }
            // if(record.Sold_To__r!=null){
            //     record.SoldToName = record.Sold_To__r.Name;
            // delete record.Sold_To__r;
            // }
        });

        component.set('v.data', records);
        document.getElementById('myInvoiceTable').style.display='block';
    },

    sortData : function(component,fieldName,sortDirection){
        var data = component.get("v.data");
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        

        data.sort(function(a,b){
            var a = key(a) ? key(a) : '';
            var b = key(b) ? key(b) : '';
            return reverse * ((a>b) - (b>a));
        }); 
        // data.sort(function(a,b){ 
        //     var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
        //     var b = key(b) ? key(b).toLowerCase() : '';
        //     return reverse * ((a>b) - (b>a));
        // });    
        

        component.set("v.data",data);
    }




})
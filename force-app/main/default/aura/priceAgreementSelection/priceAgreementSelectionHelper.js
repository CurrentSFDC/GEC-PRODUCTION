({
    
    fetchData: function(component){
        var searchText = component.get('v.searchText');
        console.log("-------------------------")
        if(searchText == ''){
            var action = component.get('c.initPriceAgreements');
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS') {
                    var records = response.getReturnValue();
                    this.makeTable(component, records);
                }
                // else(console.log(response.getError()));
            });
            $A.enqueueAction(action);
        }else{
            var action = component.get('c.searchForPAs');
            action.setParams({"searchText": searchText});
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


    makeTable: function(component, records){

        component.set('v.columns', [
            {label: $A.get("$Label.c.PASelectionNumber"), fieldName: 'palinkName', type: 'button', initialWidth: 145, wrapText: true, hideDefaultActions: true,
            typeAttributes: {label: { fieldName: 'Agreement_No__c' }, target: '_blank', name: 'PriceAgreement'}},            
            {label:$A.get("$Label.c.PAAgentName"), fieldName: 'Agent_Name__c', type: 'text', initialWidth:115, wrapText: true},
            {label:$A.get("$Label.c.PAType"), fieldName: 'Agreement_Type__c', type: 'text', initialWidth:145, wrapText: true},
            {label:$A.get("$Label.c.PACurrency"), fieldName: 'CurrencyIsoCode', type: 'text', initialWidth:95, wrapText: true},
            {label:$A.get("$Label.c.PACustomerName"), fieldName: 'Customer_Name__c', type: 'text', initialWidth:140, wrapText: true},
            {label:$A.get("$Label.c.PADescription"), fieldName: 'Description__c', type: 'text', initialWidth:125, wrapText: true},
            //{label:$A.get("$Label.c.PASelectionStatus"), fieldName: 'Processing_Status__c', type: 'text', initialWidth:200, wrapText: true},
            {label: $A.get("$Label.c.PAModifyButton"), type: 'button', initialWidth: 135, 
                typeAttributes: { label: $A.get("$Label.c.PAModifyButton"), name: 'modify', title: 'modify'},
                cellAttributes: { alignment: 'center'}, initialWidth: 95, wrapText: true},
            {label: $A.get("$Label.c.PAConvertToOrder"), type: 'button', initialWidth: 135, typeAttributes: { label: $A.get("$Label.c.PAConvertToOrder"), name: 'reorder', title: $A.get("$Label.c.orderSearchReorder")}, cellAttributes: { alignment: 'center'}, initialWidth: 150, wrapText: true}
        ]);

        records.forEach(function(record) {
           
            if(record.Agreement_Type__c == 'ZTRM') {
                record.Agreement_Type__c = 'Term';
            } else if(record.Agreement_Type__c == 'ZPRJ') {
                record.Agreement_Type__c = 'Project';
            } else if(record.Agreement_Type__c == 'ZOPT') {
                record.Agreement_Type__c = 'One Time';
            }
            record.palinkName = record.Agreement_No__c ; 
        });

        component.set('v.data', records);
        document.getElementById('myPATable').style.display='block';
    },


    modify: function(component, row) {
        var data = component.get('v.data');
        var action = component.get('c.modify');
        action.setParams({priceAgreementNum: row.Agreement_No__c, isRevise: true});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var cartUrl = response.getReturnValue();
                // console.log(cartUrl);
                window.location.replace(cartUrl);
            }
            // else(console.log(response.getError()));
        });
        $A.enqueueAction(action);
        return cartUrl;
    },

    reorder: function(component, row) {
        var data = component.get('v.data');
        var action = component.get('c.modify');
        action.setParams({priceAgreementNum: row.Agreement_No__c, isRevise: false});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var cartUrl = response.getReturnValue();
                // console.log(cartUrl);
                window.location.replace(cartUrl);
            }
            // else(console.log(response.getError()));
        });
        $A.enqueueAction(action);
        return cartUrl;
    }

})
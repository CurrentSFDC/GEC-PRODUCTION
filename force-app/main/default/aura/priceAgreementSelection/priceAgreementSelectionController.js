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
        helper.fetchData(component);
    },

    handleRowAction: function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch(action.name){
            case 'modify':
                var url = helper.modify(component, row);
                break;
            case 'reorder':
                var url = helper.reorder(component, row);
                break;
            case 'PriceAgreement':
                console.log('step 1' );
                var objCompAgreementPdf = component.find('AgreementPDFLineItems');
                objCompAgreementPdf.agreementPdfMethod(row.Agreement_No__c);
                break;
        }
    }

})
({
    handleClick : function(component, event, helper) {
        helper.fetchData(component);
    },

    handleKeyUp : function(component, event, helper) {
        if(event.which == 13){
            helper.fetchData(component);
        }
    },

    init : function(component, event, helper) {
        helper.fetchData(component);
    },

    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        
        switch (action.name) {
            case 'reorder':
                var url = helper.reorder(cmp,row);
                break;
        }
    }
})
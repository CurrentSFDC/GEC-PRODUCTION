({
    doInit : function(component, event, helper){
        component.set('v.columns', [
            {label: 'Status', fieldName: 'Current_Status__c', type: 'text'},
            {label: 'DAYS', fieldName: 'TotalDays', type: 'number', cellAttributes: {alignment: 'left'}},
            {label: 'HRS', fieldName: 'TotalHours', type: 'number', cellAttributes: {alignment: 'left'}},
            {label: 'MINS', fieldName: 'TotalMinutes', type: 'number', cellAttributes: {alignment: 'left'}}
        ]);
        helper.getTimeTracking(component, helper);
    }
})
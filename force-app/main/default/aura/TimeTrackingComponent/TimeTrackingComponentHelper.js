({
	getTimeTracking : function(component, event, helper) {
        var action = component.get("c.getTimeTrackers");
        var caseId = component.get("v.recordId");
        
        action.setParams({
            "caseId":caseId
        })
        action.setCallback(this,function(response){
                           var state = response.getState();
        if (state === "SUCCESS"){
            component.set("v.data", response.getReturnValue());
            console.log('data is:' + JSON.stringify(response.getReturnValue()));
        }
        });
		$A.enqueueAction(action);
    }
    
})
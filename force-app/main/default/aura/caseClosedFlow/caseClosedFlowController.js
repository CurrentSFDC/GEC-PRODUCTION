({
    init : function (component) {
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        var inputVariables = [
            {
                name: "recordId",
                type: "SObject",
                value: {
                    "Id" : component.get("v.recordId"),
                }
            }
        ]
        // In that component, start your flow. Reference the flow's Unique Name.
        flow.startFlow("Create_New_Note", inputVariables);
    },
})
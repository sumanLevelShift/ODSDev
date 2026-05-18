({
	initiateJob : function(component, event, helper) {
        var action = component.get("c.runJob");
        component.set("v.jobStatus", 'Initiated Sub-feature client usage job...');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.jobStatus", 'Sub-feature client usage job completed!');
                $A.get("e.force:closeQuickAction").fire();
                $A.get("e.force:refreshView").fire();
            }
        });
        $A.enqueueAction(action);
	}
})
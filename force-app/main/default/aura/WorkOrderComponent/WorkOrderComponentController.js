({
    init : function (component,event,helper) {
        // Find the component whose aura:id is "flowId"
        var flow = component.find("flowId");
        // In that component, start your flow. Reference the flow's Unique Name.
        flow.startFlow("WorkOrder_Flow");
    },
    handleStatusChange : function (component, event) {
   if(event.getParam("status") === "FINISHED") {
       var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": "/a0A/o"
    });
    urlEvent.fire();
    }
}
})
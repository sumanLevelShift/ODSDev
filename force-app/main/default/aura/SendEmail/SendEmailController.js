({
      doInit: function(component){
          debugger;
        var action = component.get("c.getCandidateId");
        action.setParams({      
            recordId : component.get("v.recordId")
        }),
        action.setCallback(this, function(a){
            var state = a.getState();
            debugger;
            if (state === "SUCCESS") {
                component.set("v.Candidates", a.getReturnValue());
            }
        });	
       $A.enqueueAction(action);
    }
	
})
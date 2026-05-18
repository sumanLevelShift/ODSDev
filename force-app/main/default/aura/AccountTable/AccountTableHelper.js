({
	getAccounts : function(component) {
		var action = component.get("c.getAccountsList");
        
        action.setCallback(this, function(response){
            var state = response.getState();
			if (state === "SUCCESS") {
                var listAccount = response.getReturnValue();
                component.set("v.accounts",listAccount);
            }
            else if (state === "INCOMPLETE") {
                alert("Callback state is INCOMPLETE!!");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	}
})
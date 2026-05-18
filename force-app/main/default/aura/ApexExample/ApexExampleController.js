({
	getNewStringArray : function(component, event) {
		var oldArray = component.get("v.stringArray");
        console.log(oldArray);
        alert("hskdksd")
        var action = component.get("c.returnStringArray");
        alert("66666");
        action.setCallback(this, function(response){
            var responseState = response.getState();
            if(responseState === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.stringArray",result);
            }
            else{
                alert("Response is not success");
            }
        });
        $A.enqueueAction(action);
	}
})
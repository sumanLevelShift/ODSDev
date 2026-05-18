({
	identifyClick : function(component, event) {
		var attr = component.get("v.attr");
        alert(attr);
        console.log("@@@@@" + attr);
        
        var clickedButtonId = event.getSource().getLocalId();
        component.set("v.attr", clickedButtonId);
	}
})
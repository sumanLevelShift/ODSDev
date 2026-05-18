({
	createClassTab : function(component, event, helper) {
        console.log('Inside createClassTab! ');
		component.set("v.displayClassTab", true); 
        component.set("v.selTabId" , '2');
    },
    moveToClasstab : function(component, event, helper) {
        console.log('Inside moveToClasstab! ');
		component.set("v.selTabId" , '2');
    }
})
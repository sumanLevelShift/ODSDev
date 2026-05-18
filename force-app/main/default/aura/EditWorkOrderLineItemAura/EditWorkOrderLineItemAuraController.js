({
    doInit: function(component, event, helper) {
        var pageRef = component.get("v.pageReference");
        console.log('record 111'+component.get("v.recordId"));
        component.set("v.isAura", true); 
        if(component.get("v.recordId") !=null){
            component.set("v.recordId", component.get("v.recordId"));
        }else{
            console.log('Falling back to URL parameter extraction');
            
            var currentUrl = window.location.href;
            console.log('Current URL:', currentUrl);
            
            var urlParams = new URLSearchParams(window.location.search);
            var retURL = urlParams.get('id');
            component.set("v.isVFPage", true); 
            if (retURL) {
                console.log('retURL parameter:', retURL);
                
                var idMatch = retURL.match(/(a8[\w]{12,18})/);
                //alert(idMatch);
                if (idMatch && idMatch[0]) {
                    var extractedId = idMatch[0];
                    console.log('Extracted ID from retURL:', extractedId);
                    component.set("v.recordId", extractedId);
                    return;
                }
            }
        }                
    }
})
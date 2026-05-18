({
    doInit: function(component, event, helper) {
        var pageRef = component.get("v.pageReference");
        console.log('record'+component.get("v.recordId"));
        //omponent.set("v.recordId", component.get("v.recordId"));  
        //alert('r-'+component.get("v.recordId"))
        component.set("v.isAura", true); 
        if(pageRef!=null){
            var state = pageRef.state;
            var base64Context = state.inContextOfRef;
            if(base64Context!=null){
                if (base64Context.startsWith("1\.")) {
                    base64Context = base64Context.substring(2);
                }
                var addressableContext = JSON.parse(window.atob(base64Context));
                //alert(addressableContext.attributes.recordId);
                component.set("v.recordId", addressableContext.attributes.recordId);
               // alert('record'+component.get("v.recordId"));
                
            }
        }else{
            console.log('Falling back to URL parameter extraction');
            
            var currentUrl = window.location.href;
            console.log('Current URL:', currentUrl);
            
            var urlParams = new URLSearchParams(window.location.search);
            var retURL = urlParams.get('retURL');
            component.set("v.isVFPage", true); 
            if (retURL) {
                console.log('retURL parameter:', retURL);
                
                var idMatch = retURL.match(/(a0[\w]{12,18})/);
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
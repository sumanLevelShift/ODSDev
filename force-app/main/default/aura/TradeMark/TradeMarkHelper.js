({
    saveQuestionsToDB : function(component, event, helper) {
        var action = component.get('c.saveQuestionsToDB');
        action.setCallback(this,function(response){
            var state = response.getState(); // get the response state
            if(state == 'SUCCESS') {
                var newPropertyId = response.getReturnValue();
                console.log('Property Id - ' + newPropertyId);
                component.set('v.propId', newPropertyId);
            }
            else if (response.getState() === "ERROR") {
                var errors = response.getError();
                if(errors)
                    alert(errors[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    deleteQuestionsFromDB : function(component, event, helper) {
        var action = component.get('c.deleteQuestionsFromDB');
        action.setParams({
            "propId" : component.get('v.propId')
        });
        action.setCallback(this,function(response){
            var state = response.getState(); // get the response state
            if(state == 'SUCCESS') {
                var deleteFlag = response.getReturnValue();
                console.log('deleteFlag - ' + deleteFlag);
            }
            else if (response.getState() === "ERROR") {
                var errors = response.getError();
                if(errors)
                    alert(errors[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    validateTradeMarkWizard : function(component, event, helper) {
        var errorFlag = false;
        console.log('Inside validateTradeMarkWizard! ');
        var q1 = component.find("q1");
        var value1 = q1.get("v.value");
        var q2 = component.find("q2");
        var value2 = q2.get("v.value");
        
        if (value1 === "Test") {
            q1.setCustomValidity("Test is already registered");
            q1.reportValidity(); 
            errorFlag = true;
        } 
        if (value2 === "Test") {
            q2.setCustomValidity("Test 1 is already registered");
            q2.reportValidity(); 
            errorFlag = true;
        } 
        return errorFlag;
        
    },
    getuploadedFiles:function(component){
        var action = component.get("c.getFiles");  
        action.setParams({  
            "recordId":component.get("v.propId")  
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();           
                component.set("v.files",result);  
            }  
        });  
        $A.enqueueAction(action);  
    },
    delUploadedfiles : function(component,documentId) {  
        var action = component.get("c.deleteFiles");           
        action.setParams({
            "sdocumentId":documentId            
        });  
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                this.getuploadedFiles(component);
                component.set("v.Spinner", false); 
            }  
        });  
        $A.enqueueAction(action);  
    },  
})
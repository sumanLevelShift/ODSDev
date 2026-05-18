({
    saveCandidate : function(component, event, helper) {
        //Validate the input fields
        var nameField=component.find("candName");
        var candName=nameField.get("v.value");
        var emailField=component.find("candEmail");
        var candEmail=emailField.get("v.value");
        var reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
        if($A.util.isEmpty(candName)){
            nameField.set("v.errors", [{message:"Candidate Name cant be empty"}]);
        }
        else if($A.util.isEmpty(candEmail)){
            emailField.set("v.errors", [{message:"Candidate Email cant be empty"}]);
        }
        else if(reg.test(candEmail) == false){   
            emailField.set("v.errors", [{message: "Please Enter a Valid Email Address"}]);
        }
        else{
            nameField.set("v.errors", [{message: null}]);
            emailField.set("v.errors", [{message: null}]);   
            
            //Save the record
            var attrCandidate = component.get("v.candidate");
            var action = component.get("c.createCandidateRecord");
            action.setParams({ candidate : attrCandidate });
            //Actions to be done once the record is saved
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    alert("State is SUCCESS & Record is created");
                    //var emptyAttr = {'sObjectType':'Candidate__c','Name':'','Candidate_Email__c':''};
                    //component.set("v.candidate", emptyAttr);
                    var result = response.getReturnValue();
                    component.set("v.candidate" , result);          
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
    },
    deleteCandidate : function(component, event, helper) {
        var attrCandidate = component.get("v.candidate");
        var action = component.get("c.deleteCandidateRecord");
        action.setParams({ candidate : attrCandidate });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                alert("State is SUCCESS & Record is deleted");
                var emptyAttr = {'sObjectType':'Candidate__c','Name':'','Candidate_Email__c':''};
                component.set("v.candidate", emptyAttr);
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
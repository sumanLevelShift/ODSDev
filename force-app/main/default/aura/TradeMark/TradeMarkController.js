({
    createRecord : function(component, event, helper) {
        console.log('Inside handleNextClick! ');
        
        helper.saveQuestionsToDB(component, event, helper);
    },
    handleNextClick : function(component, event, helper) {
        console.log('Inside handleNextClick! ');
        
        var test = helper.validateTradeMarkWizard(component, event, helper);
        console.log("----" + test);
        if(test == true)
            return;
        
        var searchResultEvent = component.getEvent("QuestionNextEvent");
        /*searchResultEvent.setParams({
            "selectedObject" : component.get('v.sObjectName'),
            "selectedFieldAndValuesMap" : component.get('v.searchFieldNameAndValue')
        });*/
        searchResultEvent.fire();
        console.log('After Event!!');
        
    },
    handleCancelClick : function(component, event, helper) {
        console.log('Inside handleCancelClick! ');
        
        $A.createComponent("c:OverlayLibraryModal", {},
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   var modalBody = content;
                                   component.find('overlayLib').showCustomModal({
                                       header: "Clicking on 'Cancel' will result in loss of all entered data/info in Filing Wizard. Are you sure?",
                                       body: modalBody, 
                                       showCloseButton: false,
                                       closeCallback: function(ovl) {
                                           console.log('Overlay is closing');
                                       }
                                   }).then(function(overlay){
                                       console.log("Overlay is made");
                                   });
                               }
                           });
        
        
        
        //helper.deleteQuestionsFromDB(component, event, helper);
        //$A.get("e.force:closeQuickAction").fire();
    },
    handleUploadFinished: function (cmp, event, helper) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        //var documentId = uploadedFiles[0].documentId;  
        //var fileName = uploadedFiles[0].name; 
        
        
        helper.getuploadedFiles(cmp); 
        alert("Files uploaded : " + uploadedFiles.length);
        console.log(cmp.get("v.files"));
        //$A.get('e.force:refreshView').fire();
        
        /*cmp.find('notifLib').showNotice({
            "variant": "info",
            "header": "Success",
            "message": "File Uploaded successfully!!",
            closeCallback: function() {}
        });*/
    },
    handleApplicationEvent : function(cmp, event, helper) {
        var message = event.getParam("message");
        alert('@@@ ==> ' + message);
        if(message == 'Ok')
        {
            helper.deleteQuestionsFromDB(cmp, event, helper);
            $A.get("e.force:closeQuickAction").fire();
        }
        else if(message == 'Cancel')
        {
            // Do nothing!
        }
    },
    delFiles:function(component,event,helper){
        component.set("v.Spinner", true); 
        var documentId = event.currentTarget.id;        
        helper.delUploadedfiles(component,documentId);  
    },
    previewFile :function(component,event,helper){  
        var rec_id = event.currentTarget.id;  
        $A.get('e.lightning:openFiles').fire({ 
            recordIds: [rec_id]
        });  
    },  
})
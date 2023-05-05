({  
    doInit : function(component, event, helper) {
	    var recordId = component.get("v.recordId");
        console.log('recordID ==>' + recordId);
        if (recordId != undefined & recordId != null) {
            console.log('1');
            component.set('v.checkInRec.buildertek__Project__c', recordId);
            component.set('v.desableProjectSelection', true);
            console.log('2');
        } else {
            component.set('v.desableProjectSelection', false);
        }
    },

    closeModel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();

        var uploadedFileId = component.get('v.uploadedFileId');
        console.log('uploadedFileId ==>' , uploadedFileId);
        if (uploadedFileId.length > 0) {
            helper.deleteUploadedFiles(component, event, helper, uploadedFileId);
        }
    },

    saveRecordData: function (component, event, helper) {
        helper.saveRecordData(component, event, helper);
    },

    handleUploadFinished: function (component, event, helper) {
        var uploadedFiles = event.getParam("files");

        // Get the file name
        var contentDocId = [];
        uploadedFiles.forEach(file => {
            console.log(file.name + ' Id ==>' + file.documentId);
            contentDocId.push(file.documentId);
        });
        component.set('v.uploadedFileId', contentDocId);
    
    },

})
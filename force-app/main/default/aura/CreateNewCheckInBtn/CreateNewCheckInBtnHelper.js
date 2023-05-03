({
    createRecord: function (component, event, helper) {
        try {
            component.set("v.disableBtn", true);
            component.set("v.Spinner", true);
            var checkInRec = component.get('v.checkInRec');
            var action = component.get("c.createCheckIn");
            action.setParams({
                checkInRec: checkInRec
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log({ state });
                var result = response.getReturnValue();
                console.log({ result });

                if (state === "SUCCESS") {

                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function (response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({
                            tabId: focusedTabId
                        });
                    })
                        .catch(function (error) {
                            console.log(error);
                        });

                    helper.showToast("Success", "Success", "New Check-In Created Successfully", "5000");

                    var navEvent = $A.get("e.force:navigateToSObject");
                    navEvent.setParams({
                        "recordId": result,
                    });
                    navEvent.fire();

                } else {
                    helper.showToast("Error", "Error", "Something Went Wrong.", "5000");
                    component.set("v.disableBtn", false);
                }
            });
            $A.enqueueAction(action);
        } catch (error) {
            console.log("error in helper createRecord Method");
            console.log({ error });
        }
    },

    closePopup: function (component, event, helper) {
        try {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({
                    tabId: focusedTabId
                });
            })
                .catch(function (error) {
                    console.log(error);
                });

        } catch (error) {
            console.log("error in helper closePopup Method");
            console.log({ error });
        }
    },

    showToast: function (type, title, message, time) {
        try {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "type": type,
                "message": message,
                "duration": time
            });
            toastEvent.fire();
        } catch (error) {
            console.log("error in helper showToast Method");
            console.log({ error });
        }
    },
})
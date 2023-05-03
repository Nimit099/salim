({
    getCheckInRecords: function (component, next, prev, offset) {
        offset = offset || 0;
        var action = component.get("c.getCheckIns");
        action.setParams({
            "next": next,
            "prev": prev,
            "off": offset
        });
        action.setCallback(this, function (res) {
            var state = res.getState();
            if (state == "SUCCESS") {
                var result = res.getReturnValue();
                component.set('v.offset', result.offst);
                component.set('v.checkIns', result.checkInList);
                component.set('v.next', result.hasnext);
                component.set('v.prev', result.hasprev);
                component.set('v.orgBaseURL', result.orgBaseUrl);

                console.log('result ==>' , result);

                var tempList  = component.get('v.checkIns');
                console.log('tempList ==>' , tempList);
            }
        });
        $A.enqueueAction(action);
    },

    openMultipleFiles: function(component, event, helper, selectedId) {
		$A.get('e.lightning:openFiles').fire({
		    recordIds: ['06904000001K9g0AAC', '06904000001KAcnAAG', '06904000001K9vVAAS'],
		    selectedRecordId: selectedId
		});
	},
})
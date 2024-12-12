({
    handleClick : function (cmp, event, helper) {
        var name = event.getParam('result');
        cmp.set("v.result", result);
         
        //fire toast message
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode" : 'sticky',
            "title" : "Success",
            "message" : 'call from LWC component',
            "type" : "success"
        });
        toastEvent.fire();
    }
})
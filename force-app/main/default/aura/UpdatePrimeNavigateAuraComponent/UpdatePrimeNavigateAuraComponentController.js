({
   doInit: function(component, event, helper) {
       var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: 'Prime rate has been updated successfully!!',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
      var navigate = component.get("v.navigateFlow");
      navigate("FINISH");
   }
})
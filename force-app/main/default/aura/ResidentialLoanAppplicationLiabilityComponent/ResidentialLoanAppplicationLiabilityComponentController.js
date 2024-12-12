({
    doInit : function(component, event, helper) {
        helper.getLiabilityDataHelper(component, event);
    },
    
    handleAddLiability: function(component, event, helper) {
        component.set("v.addLiabilityPopup", true);
    },
    
    handleCancel : function(component, event, helper) {
        component.set('v.addLiabilityPopup', false);
    },
    
    handleOnLoad : function(component, event, helper) {
        
    },
    
    handleOnSubmit : function(component, event, helper) {
        
    },
    
    handleOnSuccess : function(component, event, helper) {
        component.set('v.addLiabilityPopup', false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : 'success',
            "mode" : 'dismissible',
            "duration" : 5000,
            "message": "Liability is added successfully."
        });
        toastEvent.fire();
        $A.get('e.force:refreshView').fire();
    },
    
    deleteLiabilitys: function(component, event, helper) {
        helper.removeLiabilitys(component, event, helper);
    },
    editLiabilitys: function(component, event, helper) {
        var id = event.currentTarget.getAttribute("data-edit") || event.currentTarget.parentNode.getAttribute("data-edit")
        component.set("v.selectedForEdit", id);
        $A.get('e.force:refreshView').fire();
        //helper.removeLiabilitys(component, event, helper);
    },
     saveLiabilitys: function(component, event, helper) {
       // var id = event.currentTarget.getAttribute("data-save") || event.currentTarget.parentNode.getAttribute("data-save")
        //component.set("v.selectedForEdit", id);
        //helper.removeLiabilitys(component, event, helper);
       
        helper.saveValution(component, event, helper);
    },
    closeEdit: function(component, event, helper) {
        component.set("v.selectedForEdit", '');
         $A.get('e.force:refreshView').fire();
    },
    
    handleSelectedValue : function(component, event, helper) {
        var selectedValue=  event.getSource().get("v.value");
        component.set("v.selectedValue", selectedValue);
        component.set("v.isChecked", event.getSource().get("v.checked"));
    },
    
    calculateLiabilitys : function(component, event, helper) {
        helper.calculateLiabilitysHelper(component, event, helper);
    }
})
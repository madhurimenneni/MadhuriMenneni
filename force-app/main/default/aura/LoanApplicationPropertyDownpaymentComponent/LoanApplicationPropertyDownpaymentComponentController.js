({
	doInit : function(component, event, helper) {
		helper.getDownpaymentDataHelper(component, event);
	},

  handleAddDownpayment: function(component, event, helper) {
      component.set("v.addDownpaymentPopup", true);
  },

  handleCancel : function(component, event, helper) {
    component.set('v.addDownpaymentPopup', false); 
  },
    
    handleOnLoad : function(component, event, helper) {
          
    },
      
    handleOnSubmit : function(component, event, helper) {
         
    },

  handleOnSuccess : function(component, event, helper) {
      component.set('v.addDownpaymentPopup', false);
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
          "type" : 'success',
          "mode" : 'dismissible',
          "duration" : 5000,
          "message": "Downpayment is added successfully."
      });
      toastEvent.fire();
      $A.get('e.force:refreshView').fire();
  },
  
  deleteDownpayment: function(component, event, helper) {
      helper.removeDownpayments(component, event, helper);
  },
    
  handleSelectedValue : function(component, event, helper) {
      var selectedValue=  event.getSource().get("v.value");
      component.set("v.selectedValue", selectedValue);
      component.set("v.isChecked", event.getSource().get("v.checked"));
  },
  editDownpayment: function(component, event, helper) {
        var id = event.currentTarget.getAttribute("data-edit") || event.currentTarget.parentNode.getAttribute("data-edit")
        component.set("v.selectedForEdit", id);
        $A.get('e.force:refreshView').fire();
        //helper.removeValuations(component, event, helper);
    },
     saveDownpayment: function(component, event, helper) {
       // var id = event.currentTarget.getAttribute("data-save") || event.currentTarget.parentNode.getAttribute("data-save")
        //component.set("v.selectedForEdit", id);
        //helper.removeValuations(component, event, helper);
       
        helper.saveDownpayment(component, event, helper);
    },
    closeEdit: function(component, event, helper) {
        component.set("v.selectedForEdit", '');
         $A.get('e.force:refreshView').fire();
    },  
    
   calculateDownpayments : function(component, event, helper) {
    console.log('yes');
       helper.calculateDownpaymentsHelper(component, event, helper);
    }
})
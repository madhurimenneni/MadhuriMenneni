({
	getDownpaymentDataHelper : function(component, event) {
		var action = component.get("c.getDownpayment");
        action.setParams({
            loanApplicationPropertyId : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {

            var state = response.getState();
            if (state === "SUCCESS") {
                var downnPaymentObj = JSON.parse(response.getReturnValue());
                console.log('downnPaymentObj.hasData: '+downnPaymentObj.hasData);
                component.set('v.hasData', downnPaymentObj.hasData);
                component.set('v.downpaymentData', downnPaymentObj.downpayment);
                
            } else if (state === "ERROR") {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(action);
	},
    
    selectedValues: function(component, event, helper) {
        console.log('yes');
        var downPaymentToDelete = component.find("deleteDownpayment");
        var idsToDelete = [];
        if( downPaymentToDelete.length != undefined ) {
            for( var i=0 ; i<downPaymentToDelete.length ; i++ ) {
                if(downPaymentToDelete[i].get("v.checked"))            
                    idsToDelete.push(downPaymentToDelete[i].get("v.value"));
            }            
        } else {
            if(downPaymentToDelete.get("v.checked"))            
                idsToDelete.push(downPaymentToDelete.get("v.value"));            
        }

      console.log('idsToDelete: '+idsToDelete);
    },
    
    saveDownpayment : function(component, event, helper) {
       var selectdtoedit= component.get("v.selectedForEdit");
        var downpaymentsDATA =component.get("v.downpaymentData");
        var editedrecord;
         console.log('selectdtoedit: '+selectdtoedit);
        
        downpaymentsDATA.forEach(function(record) {
            if (record.Id === selectdtoedit) {
                
                editedrecord=record;
            }
         });
        console.log('editedrecord: '+JSON.stringify(editedrecord));
          var saveAction = component.get('c.saveDownPayment');
         saveAction.setParams({
                payInfo: editedrecord
         });
         saveAction.setCallback(this, function(response) {
            console.log('editedrecord: '+JSON.stringify(response.getError()));
             var state = response.getState();
             var toastEvent = $A.get('e.force:showToast');
              if(state === 'SUCCESS') {
                    var dataMap = response.getReturnValue();
                 if( dataMap.status == 'success' ) {
                     
                        toastEvent.setParams({
                            'type': 'success',
                            'mode': 'dismissable',
                            'message': dataMap.message
                        });
                        toastEvent.fire();   
                        component.set("v.selectedForEdit", '');
                        $A.get('e.force:refreshView').fire();
                   }
                  else if( dataMap.status == 'error' ) {
                        toastEvent.setParams({
                            'type': 'error',
                            'mode': 'dismissable',
                            'message': dataMap.message
                        });
                        toastEvent.fire(); 
                        $A.get('e.force:refreshView').fire();
                  }
              }
             else{
                  alert('Error in saving the data');
             }
            
          });
            $A.enqueueAction(saveAction);    
    },
    
    removeDownpayments : function(component, event, helper) {
        var id = event.currentTarget.getAttribute("data-data") || event.currentTarget.parentNode.getAttribute("data-data")
        var idsToDelete = [];
        idsToDelete.push(id); 
        console.log('idsToDelete: '+idsToDelete);
        if( idsToDelete.length >= 1 ){
            var toastEvent = $A.get('e.force:showToast');
            var deleteAction = component.get('c.deleteDownpaymentList');
            deleteAction.setParams({
                downpaymentIds: idsToDelete
            });
            deleteAction.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS') {
                    var dataMap = response.getReturnValue();
                    if( dataMap.status == 'success' ) {
                        toastEvent.setParams({
                            'type': 'success',
                            'mode': 'dismissable',
                            'message': dataMap.message
                        });
                        toastEvent.fire();            
                        $A.get('e.force:refreshView').fire();
                    }
                    else if( dataMap.status == 'error' ) {
                        toastEvent.setParams({
                            'type': 'error',
                            'mode': 'dismissable',
                            'message': dataMap.message
                        });
                        toastEvent.fire(); 
                        $A.get('e.force:refreshView').fire();
                    }
                }
                else {
                    alert('Error in getting data');
                }            
            });
            $A.enqueueAction(deleteAction);
        } else{
            var toastEvent = $A.get('e.force:showToast');
            toastEvent.setParams({
                            'type': 'Warning',
                            'mode': 'dismissable',
                            'message': 'Please select the Down Payment to delete !!'
                        });
            toastEvent.fire();   
        }
    },
    
    calculateDownpaymentsHelper : function(component, event, helper) {
       var selectedVal = component.get("v.selectedValue");
       var isChecked = component.get("v.isChecked");
       var toastEvent = $A.get('e.force:showToast');
       var propertyRecordId = component.get('v.recordId');
        console.log(selectedVal+' '+isChecked);
        
       if( isChecked == true ){
           var calculateAction = component.get('c.calculatePropetyValueAction');
            calculateAction.setParams({
                selectedVal: selectedVal
            });
            calculateAction.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state: '+state);
                if(state === 'SUCCESS') {
                   var dataMap = response.getReturnValue();
                    console.log('dataMap.status: '+dataMap.status);
                    if( dataMap.status == 'success' ) {
                        var updateDefaultAction = component.get('c.updateDefaultAction');
                        updateDefaultAction.setParams({
                            selectedVal: selectedVal,
                            isChecked: isChecked,
                            propertyRecordId: propertyRecordId
                        });
                        updateDefaultAction.setCallback(this, function(response) {
                            console.log('yes');
                            var state = response.getState();
                            console.log('check status: '+state);
                            if(state === 'SUCCESS') {
                            }
                            else {
                                alert('Error in getting data');
                            }            
                        });
                        $A.enqueueAction(updateDefaultAction);
                        toastEvent.setParams({
                            'type': 'success',
                            'mode': 'dismissable',
                            'message': dataMap.message
                        });
                        toastEvent.fire();            
                        $A.get('e.force:refreshView').fire();
                    }
                    else if( dataMap.status == 'error' ) {
                        toastEvent.setParams({
                            'type': 'error',
                            'mode': 'dismissable',
                            'message': dataMap.message
                        });
                        toastEvent.fire(); 
                        $A.get('e.force:refreshView').fire();
                    }
                }
                else {
                    alert('Error in getting data');
                }            
            });
            $A.enqueueAction(calculateAction);
       }
    }
})
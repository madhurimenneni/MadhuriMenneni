({
	getLiabilityDataHelper : function(component, event) {
		var action = component.get("c.getLiability");
        action.setParams({
            loanApplicationPropertyId : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {

            var state = response.getState();
            if (state === "SUCCESS") {
                var liabilityObj = JSON.parse(response.getReturnValue());
                console.log('liabilityObj.hasData: '+liabilityObj.hasData);
                console.log('liabilityObj.liabilities: '+liabilityObj.liabilities);
                component.set('v.hasData', liabilityObj.hasData);
                component.set('v.liabilityData', liabilityObj.liabilities);
                
            } else if (state === "ERROR") {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(action);
	},
    
    selectedValues: function(component, event, helper) {
        console.log('yes');
        var liabilitysToDelete = component.find("deleteLiability");
        var idsToDelete = [];
        if( liabilitysToDelete.length != undefined ) {
            for( var i=0 ; i<liabilitysToDelete.length ; i++ ) {
                if(liabilitysToDelete[i].get("v.checked"))            
                    idsToDelete.push(liabilitysToDelete[i].get("v.value"));
            }            
        } else {
            if(liabilitysToDelete.get("v.checked"))            
                idsToDelete.push(liabilitysToDelete.get("v.value"));            
        }
      console.log('idsToDelete: '+idsToDelete);
    },
    saveValution : function(component, event, helper) {
       var selectdtoedit= component.get("v.selectedForEdit");
        var liabilitysDATA =component.get("v.liabilityData");
        var editedrecord;
         console.log('selectdtoedit: '+selectdtoedit);
        
        liabilitysDATA.forEach(function(record) {
            if (record.Id === selectdtoedit) {
                
                editedrecord=record;
            }
         });
        console.log('editedrecord: '+JSON.stringify(editedrecord));
          var saveAction = component.get('c.saveLiability');
         saveAction.setParams({
                valueinfo: editedrecord
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
    
  	removeLiabilitys : function(component, event, helper) {
        var id = event.currentTarget.getAttribute("data-data") || event.currentTarget.parentNode.getAttribute("data-data")
        var idsToDelete = [];
        idsToDelete.push(id); 
        console.log('idsToDelete: '+idsToDelete);
        if( idsToDelete.length >= 1 ){
            var toastEvent = $A.get('e.force:showToast');
            var deleteAction = component.get('c.deleteLiabilityList');
            deleteAction.setParams({
                liabilityIds: idsToDelete
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
                            'message': 'Please select the Liability to delete !!'
                        });
            toastEvent.fire();   
        }
    },
    
    calculateLiabilitysHelper : function(component, event, helper) {
       var selectedVal = component.get("v.selectedValue");
        console.log('selectedVal: ' + selectedVal);
       var isChecked = component.get("v.isChecked");
       var toastEvent = $A.get('e.force:showToast');
       var propertyRecordId = component.get('v.recordId');
        console.log('selectedVal: ' + isChecked);
        
       if( isChecked == true ){
           var calculateAction = component.get('c.calculatePropetyValueAction');
            calculateAction.setParams({
                selectedVal: selectedVal
            });
            calculateAction.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state: '+response.getReturnValue());
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
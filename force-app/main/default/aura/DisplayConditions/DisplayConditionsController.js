({
    doinit: function (component, event, helper) {    //  component, event, helper are parameter                                                                                                of doinit function
        var reccid = component.get("v.recordId");
        var action = component.get('c.getConditions');
        action.setParams({ "MyString": reccid });
        action.setCallback(this, function (response)   // getting response back from apex method
        {
            var state = response.getState();            // getting the state
            if (state === 'SUCCESS') {
                component.set('v.SubConditions', response.getReturnValue());    // setting the value in attribute

            }


        });
        $A.enqueueAction(action);


    }
})
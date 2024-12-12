({
    doInit: function (component, event, helper) {
        helper.getResidentialLoanApplicationHelper(component, event);
        helper.getLoanApplicationPropertyHelper(component, event);
        helper.getAmlFlagHelper(component, event);
        helper.getValuationHelper(component);
        //helper.getLoanApplicantHelper(component, event);
    },

    /*
     * Reload error field on case update
     */
    recordUpdated: function (component, event, helper) {
        component.set("v.errorMessage", null);
    },

    isRecordDataRefreshed: function (component, event) {
        component.find('recordData').reloadRecord(true);
    },
})
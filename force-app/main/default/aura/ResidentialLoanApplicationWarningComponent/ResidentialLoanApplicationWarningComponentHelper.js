({
    getResidentialLoanApplicationHelper: function (component, event) {
        var action = component.get("c.getResidentialLoanApplication");
        action.setParams({
            residentialLoanAppId: component.get("v.recordId")
        });

        action.setCallback(this, function (response) {

            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var residentialLoanAppObj = JSON.parse(response.getReturnValue());
                component.set('v.shortfallOrOverageSign', residentialLoanAppObj.shortfallOrOverageSign);
                component.set('v.shortfallOverage', residentialLoanAppObj.shortfallOverage);
                if (residentialLoanAppObj.status != 'DUPLICATE' && residentialLoanAppObj.status != 'Unprocessed' && residentialLoanAppObj.status != 'Failed') {
                    component.set('v.brokerEmail', residentialLoanAppObj.brokerEmail);
                    component.set('v.accountName', residentialLoanAppObj.accountName);
                    component.set('v.dayOfinterestAdjustmentDate', residentialLoanAppObj.interestAdjustmentDate);
                    component.set('v.highriskFlags', residentialLoanAppObj.highriskFlags);
                    component.set('v.mediumriskFlags', residentialLoanAppObj.mediumriskFlags);
                    component.set('v.missingPrimaryApplicant', residentialLoanAppObj.primaryApplicant);
                    component.set('v.uncheckASAP', residentialLoanAppObj.uncheckASAPBox);
                    component.set('v.checkASAP', residentialLoanAppObj.checkASAPBox);
                    component.set('v.blankCloseDate', residentialLoanAppObj.blankCloseDate);
                    component.set('v.missingCloseDate', residentialLoanAppObj.missingCloseDate);
                    component.set('v.LTVCreditScore575LimitError', residentialLoanAppObj.LTVCreditScore575LimitError);
                    component.set('v.LTVCreditScore500LimitError', residentialLoanAppObj.LTVCreditScore500LimitError);
                    component.set('v.thresholdCreditScore', residentialLoanAppObj.thresholdCreditScore);
                    component.set('v.aprwarning',residentialLoanAppObj.aprwarning);

                    if (residentialLoanAppObj.secondMortgageWarningMessage == true) {
                        component.set('v.secondMortgageWarningMessage', residentialLoanAppObj.secondMortgageWarningMessage);
                        component.set('v.hasData', true);
                    }

                    if (residentialLoanAppObj.brokerEmail == null) {
                        component.set('v.hasData', true);
                    }

                    if (residentialLoanAppObj.highriskFlags >= 1) {
                        component.set('v.highriskFlags', true);
                    }

                    if (residentialLoanAppObj.mediumriskFlags >= 1) {
                        component.set('v.mediumriskFlags', true);
                    }
                    if (residentialLoanAppObj.accountName == 'Brightpath Capital' || residentialLoanAppObj.interestAdjustmentDate != 1
                        || residentialLoanAppObj.primaryApplicant == true || residentialLoanAppObj.uncheckASAPBox == true
                        || residentialLoanAppObj.checkASAPBox == true || residentialLoanAppObj.blankCloseDate == true
                        || residentialLoanAppObj.missingCloseDate == true) {
                        component.set('v.hasData', true);
                    }
                    if (residentialLoanAppObj.LTVCreditScore575LimitError == true || residentialLoanAppObj.LTVCreditScore500LimitError == true || residentialLoanAppObj.thresholdCreditScore == true) {
                        component.set('v.hasData', true);
                    }
                }

                if (residentialLoanAppObj.status != 'Complete' && residentialLoanAppObj.status != 'Cancelled' && residentialLoanAppObj.status != 'Declined'
                    && residentialLoanAppObj.status != 'DUPLICATE' && residentialLoanAppObj.status != 'Failed' && residentialLoanAppObj.status != 'Unprocessed') {
                    component.set('v.primeRateMessage', residentialLoanAppObj.primeRateMessage);
                    if (residentialLoanAppObj.primeRateMessage != null) {
                        component.set('v.hasData', true);
                    }
                }
            } else if (state === "ERROR") {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(action);
    },

    getLoanApplicationPropertyHelper: function (component, event) {
        var action = component.get("c.getLoanApplicationProperty");
        action.setParams({
            residentialLoanAppId: component.get("v.recordId")
        });

        action.setCallback(this, function (response) {

            var state = response.getState();
            if (state === "SUCCESS") {
                var residentialLoanAppObj = JSON.parse(response.getReturnValue());
                if (residentialLoanAppObj.status != 'DUPLICATE' && residentialLoanAppObj.status != 'Unprocessed' && residentialLoanAppObj.status != 'Failed') {
                    component.set('v.missingUnitNumber', residentialLoanAppObj.missingUnitNumber);
                    component.set('v.missingColleteralLegalAddress', residentialLoanAppObj.missingColleteralLegalAddress);
                    component.set('v.missingAppraisalValue', residentialLoanAppObj.missingAppraisalValue);
                    component.set('v.missingAppraisalDate', residentialLoanAppObj.missingAppraisalDate);
                    component.set('v.missingParkingInfo', residentialLoanAppObj.missingParkingInfo);

                    if (residentialLoanAppObj.missingUnitNumber == true) {
                        component.set('v.hasData', true);
                    }
                    if (residentialLoanAppObj.missingColleteralLegalAddress == true) {
                        component.set('v.hasData', true);
                        component.set('v.collateralLegalPropNames', residentialLoanAppObj.colleteralLegalMsg);
                    }

                    if (residentialLoanAppObj.missingParkingInfo == true) {
                        component.set('v.hasData', true);
                        component.set('v.parkingErrorPropNames', residentialLoanAppObj.missingParkingMsg);
                    }

                    if (residentialLoanAppObj.missingAppraisalValue == true || residentialLoanAppObj.missingAppraisalDate == true) {
                        component.set('v.hasData', true);
                    }
                }
            } else if (state === "ERROR") {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(action);
    },

    getAmlFlagHelper: function (component, event) {
        var action = component.get("c.getAmlFalgs");
        action.setParams({
            residentialLoanAppId: component.get("v.recordId")
        });

        action.setCallback(this, function (response) {

            var state = response.getState();
            if (state === "SUCCESS") {
                var amlFlagsObj = JSON.parse(response.getReturnValue());

                if (amlFlagsObj.hasActiveAmlFlags == true) {
                    component.set('v.unresolvedAMLFlags', true);
                }

            } else if (state === "ERROR") {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(action);
    },

    getValuationHelper: function (component) {
        var action = component.get("c.getValuations");
        action.setParams({
            residentialLoanAppId: component.get("v.recordId")
        });

        action.setCallback(this, function (response) {

            var state = response.getState();
            if (state === "SUCCESS") {
                var valuationsObj = JSON.parse(response.getReturnValue());

                if (valuationsObj.zeroappraisalvalue == true) {
                    component.set('v.hasData', true);
                    component.set('v.zeroappraisalvalue', valuationsObj.zeroappraisalvalue);
                    component.set('v.zeroappraisalPropNames', valuationsObj.zeroappraisalvalueMsg);
                }
            } else if (state === "ERROR") {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(action);
    },
})
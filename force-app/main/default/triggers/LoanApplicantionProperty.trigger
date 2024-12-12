trigger LoanApplicantionProperty on LoanApplicationProperty (before insert,before update,after insert, after update, before delete, after delete, after undelete) {
    if ( !Utils.loanApplicantPropertyTriggerSwitch.Disable_Loan_Applicant_Property_Trigger__c ) {
        SObjectDomain.triggerHandler( LoanApplicationProperties.class );
    }
}
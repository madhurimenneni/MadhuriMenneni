trigger LoanApplicationLiabilityTrigger on LoanApplicationLiability (before insert,before update,after insert, after update, before delete, after delete, after undelete) {
    Control_LoanApplicationLiability__c sObjectControlSetting = Control_LoanApplicationLiability__c.getInstance();
    if(SObjectDomain.isSObjectTriggerEnabled(sObjectControlSetting)) {
        SObjectDomain.triggerHandler( LoanApplicationLiabilities.class );
        ErrorHandlingLogException.saveExceptionLog();
    }
}
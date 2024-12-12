trigger LoanApplicantTrigger on LoanApplicant (before insert,before update,after insert, after update, before delete, after delete, after undelete) {
    Control_LoanApplicant__c sObjectControlSetting = Control_LoanApplicant__c.getInstance();
    if(SObjectDomain.isSObjectTriggerEnabled(sObjectControlSetting)) {
        SObjectDomain.triggerHandler(LoanApplicants.class);
        ErrorHandlingLogException.saveExceptionLog();
    }
}
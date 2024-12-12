trigger LoanApplicantEmploymentTrigger on LoanApplicantEmployment (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    Control_LoanApplicantEmployment__c sObjectControlSetting = Control_LoanApplicantEmployment__c.getInstance();
    if(SObjectDomain.isSObjectTriggerEnabled(sObjectControlSetting)) {
        SObjectDomain.triggerHandler(LoanApplicantEmployments.class);
        ErrorHandlingLogException.saveExceptionLog();
    }
}
trigger LoanApplicantAddressTrigger on LoanApplicantAddress (before insert,before update,after insert, after update, before delete, after delete, after undelete) {
    Control_LoanApplicantAddress__c sObjectControlSetting = Control_LoanApplicantAddress__c.getInstance();
    if(SObjectDomain.isSObjectTriggerEnabled(sObjectControlSetting)) {
        SObjectDomain.triggerHandler(LoanApplicantAddresses.class);
        ErrorHandlingLogException.saveExceptionLog();
    }
}
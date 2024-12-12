trigger LoanApplicantIncomeTrigger on LoanApplicantIncome ( before insert,before update,after insert, after update, before delete, after delete, after undelete ) {
    Control_LoanApplicantIncome__c sObjectControlSetting = Control_LoanApplicantIncome__c.getInstance();
    if(SObjectDomain.isSObjectTriggerEnabled(sObjectControlSetting)) {
        SObjectDomain.triggerHandler(LoanApplicantIncomes.class);
        ErrorHandlingLogException.saveExceptionLog();
    }
}
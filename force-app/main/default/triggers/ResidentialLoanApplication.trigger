trigger ResidentialLoanApplication on ResidentialLoanApplication ( before update,after insert, after update, after delete, after undelete ) {
    Control_ResidentialLoanApplication__c sObjectControlSetting = Control_ResidentialLoanApplication__c.getInstance();
    if(SObjectDomain.isSObjectTriggerEnabled(sObjectControlSetting)) {
        SObjectDomain.triggerHandler(ResidentialLoanApplications.class);
        ErrorHandlingLogException.saveExceptionLog();
    }
}
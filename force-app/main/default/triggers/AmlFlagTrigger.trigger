trigger AmlFlagTrigger on AML_Flag__c (before insert,before update,after insert, after update, before delete, after delete, after undelete) {
    Control_AML_Flag__c sObjectControlSetting = Control_AML_Flag__c.getInstance();
    if(SObjectDomain.isSObjectTriggerEnabled(sObjectControlSetting)) {
        SObjectDomain.triggerHandler(AmlFlags.class);
        ErrorHandlingLogException.saveExceptionLog();
    }
}
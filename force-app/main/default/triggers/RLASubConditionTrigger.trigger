trigger RLASubConditionTrigger on RLA_Sub_Condition__c (before insert,before update,after insert, after update, before delete, after delete, after undelete) {
    Control_RLA_Sub_Condition__c sObjectControlSetting = Control_RLA_Sub_Condition__c.getInstance();
    if(SObjectDomain.isSObjectTriggerEnabled(sObjectControlSetting)) {
        SObjectDomain.triggerHandler(RLASubConditions.class);
        ErrorHandlingLogException.saveExceptionLog();
    }
}
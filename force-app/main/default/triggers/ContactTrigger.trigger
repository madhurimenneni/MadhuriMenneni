trigger ContactTrigger on Contact (before insert, after insert, after update, after delete, after undelete) {
    Control_Contact__c sObjectControlSetting = Control_Contact__c.getInstance();
    if(SObjectDomain.isSObjectTriggerEnabled(sObjectControlSetting)) {
        SObjectDomain.triggerHandler(Contacts.class);
        ErrorHandlingLogException.saveExceptionLog();
    }
}
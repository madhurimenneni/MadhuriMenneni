/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-25-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger PropertyOwnerTrigger on Property_Owner__c (before insert, before update, before delete, after undelete) {
    Control_Property_Owner__c sObjectControlSetting = Control_Property_Owner__c.getInstance();
    if(SObjectDomain.isSObjectTriggerEnabled(sObjectControlSetting)) {
        SObjectDomain.triggerHandler(PropertyOwner.class);
        ErrorHandlingLogException.saveExceptionLog();
    }
}
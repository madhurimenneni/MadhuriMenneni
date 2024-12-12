/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-25-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

trigger RentalIncomeTrigger on Rental_Income__c (before insert, before update, before delete, after undelete) {
    Control_Rental_Income__c sObjectControlSetting = Control_Rental_Income__c.getInstance();
    if(SObjectDomain.isSObjectTriggerEnabled(sObjectControlSetting)) {
        SObjectDomain.triggerHandler(RentalIncome.class);
        ErrorHandlingLogException.saveExceptionLog();
    }
}
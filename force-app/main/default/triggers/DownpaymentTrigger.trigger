trigger DownpaymentTrigger on Downpayment__c (before insert, before update, before delete, after undelete) {
    Control_Downpayment__c sObjectControlSetting = Control_Downpayment__c.getInstance();
    if(SObjectDomain.isSObjectTriggerEnabled(sObjectControlSetting)) {
        SObjectDomain.triggerHandler(Downpayments.class);
        ErrorHandlingLogException.saveExceptionLog();
    }
}
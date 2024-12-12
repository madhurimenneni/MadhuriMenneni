trigger Webinar on Webinar__c (before insert, after insert, before update, after update) {
    if ( !Utils.webinarAttendeeTriggerSwitch.Disable_Trigger__c ) {
        SObjectDomain.triggerHandler( Webinars.class );
    }
}
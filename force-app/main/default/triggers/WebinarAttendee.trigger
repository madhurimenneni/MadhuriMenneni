trigger WebinarAttendee on Webinar_Attendee__c (before insert, before update) {
    if ( !Utils.webinarAttendeeTriggerSwitch.Disable_Trigger__c ) {
        SObjectDomain.triggerHandler( WebinarAttendees.class );
    }
}
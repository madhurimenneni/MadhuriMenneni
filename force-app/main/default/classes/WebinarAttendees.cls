public class WebinarAttendees extends SObjectDomain{
    protected override void onBeforeInsert() { 
        if ( !Utils.webinarAttendeeTriggerSwitch.Before_Insert_Trigger__c ) {
            new WebinarAttendeeHandler( ( List<Webinar_Attendee__c> ) newRecords, null )
            .populateWebinarAttendeeContacts();
    	}
    }

    protected override void onBeforeUpdate() { 
        if ( !Utils.webinarAttendeeTriggerSwitch.Before_Update_Trigger__c ) {
            new WebinarAttendeeHandler( ( List<Webinar_Attendee__c> ) newRecords, (Map<Id,Webinar_Attendee__c>) oldRecordsMap )
            .populateWebinarAttendeeContacts();
    	}
    }
}
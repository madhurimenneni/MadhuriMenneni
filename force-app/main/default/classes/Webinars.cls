public class Webinars extends SObjectDomain{
    protected override void onBeforeInsert() { 
        if ( !Utils.webinarTriggerSwitch.Before_Insert_Trigger__c ) {
            new WebinarHandler( ( List<Webinar__c> ) newRecords, null )
            .checkForLatestWebinar();
    	}
    }

    protected override void onAfterInsert() { 
        if ( !Utils.webinarTriggerSwitch.Before_Insert_Trigger__c ) {
            new WebinarHandler( ( List<Webinar__c> ) newRecords, null )
            .createEventForWebinar();
    	}
    }

    protected override void onBeforeUpdate() { 
        if ( !Utils.webinarTriggerSwitch.Before_Update_Trigger__c ) {
            new WebinarHandler( ( List<Webinar__c> ) newRecords, (Map<Id,Webinar__c>) oldRecordsMap )
            .checkForLatestWebinar();
    	}
    }

    protected override void onAfterUpdate() { 
        if ( !Utils.webinarTriggerSwitch.Before_Insert_Trigger__c ) {
            new WebinarHandler( ( List<Webinar__c> ) newRecords, (Map<Id,Webinar__c>) oldRecordsMap )
            .createEventForWebinar();
    	}
    }
}
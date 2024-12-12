trigger OpportunityTrigger on Opportunity (before insert,before update,after insert, after update, after delete, after undelete) {
    if( !Utils.opportunityTriggerSwitch.Disable_Opportunity_Trigger__c ) {
        SObjectDomain.triggerHandler( Opportunities.class );
    }
}
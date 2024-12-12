trigger ValuationTrigger on Valuation__c (before insert,before update,after insert, after update, before delete, after delete, after undelete) {
    if ( !Utils.ValuationTriggerSwitch.Disable_Valuation_Trigger__c ) {
        SObjectDomain.triggerHandler( Valuations.class );
    }
}
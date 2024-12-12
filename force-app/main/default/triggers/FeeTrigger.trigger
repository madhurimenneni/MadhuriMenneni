trigger FeeTrigger on Fee__c(before insert,before update,after insert, after update, after delete, before delete, after undelete) {
    if( !Utils.feeTriggerSwitch.Disable_Fee_Trigger__c ) {
        SObjectDomain.triggerHandler( Fees.class );
    }
}
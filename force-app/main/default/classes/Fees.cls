public with sharing class Fees extends SObjectDomain{
    protected override void onBeforeUpdate() { 
                            ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
        if ( !Utils.feeTriggerSwitch.Disable_Before_Update_Functionality__c ) {
            if ( !Utils.feeTriggerSwitch.B_U_Fee_Validation__c ) {
                new FeeHandler( ( List<Fee__c> ) newRecords, (Map<Id,Fee__c>) oldRecordsMap )
                .validateFeeRecords();
                  new FeeHandler( ( List<Fee__c> ) newRecords, (Map<Id,Fee__c>) oldRecordsMap )
                .updateAmtORPercent();
            }
        }
    }

    protected override void onBeforeInsert() { 
                            ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
        if ( !Utils.feeTriggerSwitch.Disable_Before_Insert_Functionality__c ) {
            if ( !Utils.feeTriggerSwitch.B_I_Fee_Validation__c ) {
                new FeeHandler( ( List<Fee__c> ) newRecords, null )
                .validateFeeRecords();
                  new FeeHandler( ( List<Fee__c> ) newRecords, null )
                .updateAmtORPercent();
            }
        }
    }
    
    protected override void onBeforeDelete() {
        ApprovalProcessRecordLockingHelper.lockRecord(oldRecords);
    }

protected override void onAfterUndelete() {
        ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
}
}
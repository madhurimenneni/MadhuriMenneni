public with sharing class AmlFlags extends SObjectDomain{
    protected override void onBeforeInsert() {
    ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
        new AmlFlagHandler(( List<AML_Flag__c> ) newRecords, null).updateResolvedDetails();
    }

    protected override void onAfterInsert() {
        new AmlFlagHandler(( List<AML_Flag__c> ) newRecords, null).updateScreeningFalsePositiveOnContact();
    }

    protected override void onBeforeUpdate() {
                    ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
        new AmlFlagHandler(( List<AML_Flag__c> ) newRecords, (Map<Id,AML_Flag__c>) oldRecordsMap).updateResolvedDetails();
    }

    protected override void onAfterUpdate() {
        new AmlFlagHandler(( List<AML_Flag__c> ) newRecords, (Map<Id,AML_Flag__c>) oldRecordsMap).updateScreeningFalsePositiveOnContact();
    }
    
     protected override void onBeforeDelete() {
        ApprovalProcessRecordLockingHelper.lockRecord(oldRecords);
    }


    protected override void onAfterUndelete() {
        ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
}
}
public with sharing class RLASubConditions extends SObjectDomain{
    protected override void onAfterInsert() {
        new RLASubConditionHandler(( List<RLA_Sub_Condition__c> ) newRecords, null).updateIdVerifiedDateOnRla();
    }

    protected override void onAfterUpdate() {
        new RLASubConditionHandler(( List<RLA_Sub_Condition__c> ) newRecords, (Map<Id,RLA_Sub_Condition__c>) oldRecordsMap).updateIdVerifiedDateOnRla();
    }
    
    protected override void onBeforeInsert() {
        ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
    }

protected override void onBeforeUpdate() {
        ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
    }
    
     protected override void onBeforeDelete() {
        ApprovalProcessRecordLockingHelper.lockRecord(oldRecords);
    }

protected override void onAfterUndelete() {
        ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
        
}
}
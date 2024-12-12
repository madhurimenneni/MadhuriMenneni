/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-25-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class PropertyOwner extends SObjectDomain{
    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 11-25-2024
    * @description Called by the trigger framework to carry out the actions before the newRecords are Inserted. 
    */
    protected override void onBeforeInsert() {
        ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
    }

    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 11-25-2024
    * @description Called by the trigger framework to carry out the actions before the newRecords are Updated. 
    */
    protected override void onBeforeUpdate() {
        ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
    }

     /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 11-25-2024
    * @description Called by the trigger framework to carry out the actions before the newRecords are Deleted. 
    */
    protected override void onBeforeDelete() {
        ApprovalProcessRecordLockingHelper.lockRecord(oldRecords);
    }

    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 11-25-2024
    * @description Called by the trigger framework to carry out the actions before the newRecords are UnDeleted. 
    */
    protected override void onAfterUndelete() {
        ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
    }
}
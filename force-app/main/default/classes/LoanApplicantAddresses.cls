public with sharing class LoanApplicantAddresses extends SObjectDomain {

    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 14-August-2024
    * @description Called by the trigger framework to carry out the actions after the newRecords are Inserted. 
    */
     protected override void onBeforeInsert() {
        ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
    }
    
    protected override void onAfterInsert() {
        new LoanApplicantAddressAmlFlagsHelper( ( List<LoanApplicantAddress> ) newRecords, null )
        .insertLoanApplicantAddressAmlFlag();
    }

    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 14-August-2024
    * @description Called by the trigger framework to carry out the actions after the newRecords are Updated. 
    */
    
        protected override void onBeforeUpdate() {
        ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
    }

    protected override void onAfterUpdate() {
        new LoanApplicantAddressAmlFlagsHelper( ( List<LoanApplicantAddress> ) newRecords, ( Map<Id, LoanApplicantAddress> ) oldRecordsMap )
        .insertLoanApplicantAddressAmlFlag();
    }

    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 14-August-2024
    * @description Called by the trigger framework to carry out the actions after the newRecords are Updated. 
    */
    
      protected override void onBeforeDelete() {
        ApprovalProcessRecordLockingHelper.lockRecord(oldRecords);
    }

    protected override void onAfterDelete() {
        new LoanApplicantAddressAmlFlagsHelper( ( List<LoanApplicantAddress> ) oldRecords, null )
        .insertLoanApplicantAddressAmlFlag();
    }

    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 14-August-2024
    * @description Called by the trigger framework to carry out the actions after the newRecords are Updated. 
    */
    protected override void onAfterUndelete() {
                    ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
        new LoanApplicantAddressAmlFlagsHelper( ( List<LoanApplicantAddress> ) newRecords, null )
        .insertLoanApplicantAddressAmlFlag();
    }
}
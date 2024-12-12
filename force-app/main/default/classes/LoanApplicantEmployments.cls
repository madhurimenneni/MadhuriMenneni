public with sharing class LoanApplicantEmployments extends SObjectDomain {
    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 14-August-2024
    * @description Called by the trigger framework to carry out the actions before the newRecords are Inserted. 
    */
    protected override void onBeforeInsert() {
        ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
    }

    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 14-August-2024
    * @description Called by the trigger framework to carry out the actions after the newRecords are Inserted. 
    */
    protected override void onAfterInsert() {
        new LoanApplicantEmploymentAmlFlagsHelper( ( List<LoanApplicantEmployment> ) newRecords, null )
        .insertLoanApplicantEmploymentAmlFlag();
    }

    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 14-August-2024
    * @description Called by the trigger framework to carry out the actions before the newRecords are Updated. 
    */
    protected override void onBeforeUpdate() {
        ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
    }

    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 14-August-2024
    * @description Called by the trigger framework to carry out the actions after the newRecords are Updated. 
    */
    protected override void onAfterUpdate() {
        new LoanApplicantEmploymentAmlFlagsHelper( ( List<LoanApplicantEmployment> ) newRecords, ( Map<Id, LoanApplicantEmployment> ) oldRecordsMap )
        .insertLoanApplicantEmploymentAmlFlag();
    }

     /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 14-August-2024
    * @description Called by the trigger framework to carry out the actions before the newRecords are deleted. 
    */
    protected override void onBeforeDelete() {
        ApprovalProcessRecordLockingHelper.lockRecord(oldRecords);
    }

    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 14-August-2024
    * @description Called by the trigger framework to carry out the actions after the newRecords are Inserted. 
    */
    protected override void onAfterDelete() {
        new LoanApplicantEmploymentAmlFlagsHelper( ( List<LoanApplicantEmployment> ) oldRecords, null )
        .insertLoanApplicantEmploymentAmlFlag();
    }

    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 14-August-2024
    * @description Called by the trigger framework to carry out the actions after the newRecords are Updated. 
    */
    protected override void onAfterUndelete() {
        ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
        new LoanApplicantEmploymentAmlFlagsHelper( ( List<LoanApplicantEmployment> ) newRecords, null )
        .insertLoanApplicantEmploymentAmlFlag();
    }
}
public with sharing class LoanApplicantIncomes extends SObjectDomain {
    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 14-August-2024
    * @description Called by the trigger framework to carry out the actions after the newRecords are Inserted. 
    */
    
    protected override void onBeforeInsert() {
        ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
    }

    protected override void onAfterInsert() {
        new LoanApplicantIncomeAmlFlagsHelper( ( List<LoanApplicantIncome> ) newRecords, null )
        .insertLoanApplicantIncomeAmlFlag();
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
        new LoanApplicantIncomeAmlFlagsHelper( ( List<LoanApplicantIncome> ) newRecords, ( Map<Id, LoanApplicantIncome> ) oldRecordsMap )
        .insertLoanApplicantIncomeAmlFlag();
    }

    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 14-August-2024
    * @description Called by the trigger framework to carry out the actions after the newRecords are deleted. 
    */
     protected override void onBeforeDelete() {
        ApprovalProcessRecordLockingHelper.lockRecord(oldRecords);
    }

    protected override void onAfterDelete() {
        new LoanApplicantIncomeAmlFlagsHelper( ( List<LoanApplicantIncome> ) oldRecords, null )
        .insertLoanApplicantIncomeAmlFlag();
    }

    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 14-August-2024
    * @description Called by the trigger framework to carry out the actions after the newRecords are unDeleted. 
    */
    protected override void onAfterUndelete() {
            ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
        new LoanApplicantIncomeAmlFlagsHelper( ( List<LoanApplicantIncome> ) newRecords, null )
        .insertLoanApplicantIncomeAmlFlag();
    }
}
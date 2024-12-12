public with sharing class LoanApplicationLiabilities extends SObjectDomain{
    protected override void onBeforeInsert() { 
                    ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
        new LoanApplicationLiabilityHandler( ( List<LoanApplicationLiability> ) newRecords, null )
        .updateLoanApplicationLiabilities();
    }

    protected override void onAfterInsert() {
        new LoanApplicationLiabilityHandler( ( List<LoanApplicationLiability> ) newRecords, null )
        .calculateRLAValues();
    }

    protected override void onBeforeUpdate() { 
                    ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
        new LoanApplicationLiabilityHandler( ( List<LoanApplicationLiability> ) newRecords, (Map<Id,LoanApplicationLiability>) oldRecordsMap )
        .lockLoanApplicantionLiability();
    
        new LoanApplicationLiabilityHandler( ( List<LoanApplicationLiability> ) newRecords, (Map<Id,LoanApplicationLiability>) oldRecordsMap )
        .updateLoanApplicationLiabilities();
    }

    protected override void onAfterUpdate() {
        new LoanApplicationLiabilityHandler( ( List<LoanApplicationLiability> ) newRecords, ( Map<Id, LoanApplicationLiability> ) oldRecordsMap )
        .calculateRLAValues();
    }

 protected override void onBeforeDelete() {
        ApprovalProcessRecordLockingHelper.lockRecord(oldRecords);
    }
    
    protected override void onAfterDelete() { 
        new LoanApplicationLiabilityHandler( ( List<LoanApplicationLiability> ) oldRecords, null )
        .calculateRLAValues();
    }

    protected override void onAfterUnDelete() { 
                    ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
        new LoanApplicationLiabilityHandler( ( List<LoanApplicationLiability> ) newRecords, null )
        .calculateRLAValues();
    }
}
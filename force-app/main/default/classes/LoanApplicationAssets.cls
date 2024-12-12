public class LoanApplicationAssets extends SObjectDomain{
    protected override void onBeforeInsert() { 
                    ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
        new LoanApplicationAssetHandler( ( List<LoanApplicationAsset> ) newRecords, null )
        .beforeOperations();
    }

    protected override void onAfterInsert() { 
        new LoanApplicationAssetHandler( ( List<LoanApplicationAsset> ) newRecords, null )
        .calCulateTotalAssetValue();
    }

    protected override void onBeforeUpdate() { 
                    ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
        new LoanApplicationAssetHandler( ( List<LoanApplicationAsset> ) newRecords, null )
        .beforeOperations();
        new LoanApplicationAssetHandler( ( List<LoanApplicationAsset> ) newRecords, (Map<Id,LoanApplicationAsset>) oldRecordsMap )
        .lockLoanApplicantionAsset();
    }

    protected override void onAfterUpdate() { 
        new LoanApplicationAssetHandler( ( List<LoanApplicationAsset> ) newRecords, (Map<Id,LoanApplicationAsset>) oldRecordsMap )
        .calCulateTotalAssetValue();
    }

 protected override void onBeforeDelete() {
        ApprovalProcessRecordLockingHelper.lockRecord(oldRecords);
    }
    
    protected override void onAfterDelete() { 
        new LoanApplicationAssetHandler( ( List<LoanApplicationAsset> ) oldRecords, null)
        .calCulateTotalAssetValue();
    }

    protected override void onAfterUnDelete() { 
                    ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
        new LoanApplicationAssetHandler( ( List<LoanApplicationAsset> ) newRecords, null )
        .calCulateTotalAssetValue();
    }
}
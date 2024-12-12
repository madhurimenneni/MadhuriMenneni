public with sharing class LoanApplicants extends SObjectDomain{
    protected override void onBeforeInsert() {
        ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
        if ( !Utils.loanApplicantTriggerSwitch.Disable_Before_Insert_Functionality__c ) {
            if ( !Utils.loanApplicantTriggerSwitch.B_I_Loan_Applicant_Validation__c ) {
                new LoanApplicantHandler( ( List<LoanApplicant> ) newRecords, null )
                .validateLoanApplicant()
                .validateSinNumber();
            }
        }
    }

    protected override void onAfterInsert() { 
        if ( !Utils.loanApplicantTriggerSwitch.Disable_After_Insert_Functionality__c ) {
            if(!Utils.loanApplicantTriggerSwitch.A_I_Update_Loan_Applicant_Fields__c){
                new LoanApplicantHandler((List<LoanApplicant>) newRecords, null).updateLoanApplicantFields();
            }
        }

        new LoanApplicantAmlFlagsHelper( ( List<LoanApplicant> ) newRecords, null )
        .insertLoanApplicantAmlFlag();
    }
    
    protected override void onBeforeUpdate() {
        ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
        if ( !Utils.loanApplicantTriggerSwitch.Disable_Before_Update_Functionality__c ) {
            if ( !Utils.loanApplicantTriggerSwitch.B_U_Loan_Applicant_Validation__c ) {
                new LoanApplicantHandler( ( List<LoanApplicant> ) newRecords, (Map<Id,LoanApplicant>) oldRecordsMap )
                .validateLoanApplicant()
                .validateSinNumber();
            }
        }
    }
    
    
    protected override void onAfterUpdate() { 
        if ( !Utils.loanApplicantTriggerSwitch.Disable_After_Update_Functionality__c ) {
            if ( !Utils.loanApplicantTriggerSwitch.A_U_Update_Loan_Applicant_Fields__c ) {
                new LoanApplicantHandler( ( List<LoanApplicant> ) newRecords, (Map<Id,LoanApplicant>) oldRecordsMap ).updateLoanApplicantFields();
            }
        }

        new LoanApplicantAmlFlagsHelper( ( List<LoanApplicant> ) newRecords, (Map<Id,LoanApplicant>) oldRecordsMap )
        .insertLoanApplicantAmlFlag();
    }
    
    protected override void onBeforeDelete() {
        ApprovalProcessRecordLockingHelper.lockRecord(oldRecords);
    }

    protected override void onAfterDelete() { 
        new LoanApplicantHandler( ( List<LoanApplicant> ) oldRecords, null )
        .updateLoanApplicantFields();

        new LoanApplicantAmlFlagsHelper( ( List<LoanApplicant> ) oldRecords, null )
        .insertLoanApplicantAmlFlag();
    }
    protected override void onAfterUndelete() {
        ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
        new LoanApplicantHandler( ( List<LoanApplicant> ) newRecords, null )
        .updateLoanApplicantFields();

        new LoanApplicantAmlFlagsHelper( ( List<LoanApplicant> ) newRecords, null )
        .insertLoanApplicantAmlFlag();

    }
}
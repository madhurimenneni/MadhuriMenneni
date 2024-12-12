public with sharing class LoanApplicationProperties extends SObjectDomain{
    public static List<LoanApplicationLiability> liabilitiesList;
    protected override void onBeforeInsert() { 
                            ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
        if ( !Utils.loanApplicantPropertyTriggerSwitch.Disable_Before_Insert_Functionality__c ) {
            if ( !Utils.loanApplicantPropertyTriggerSwitch.B_I_Loan_App_Property_Validation__c ) {
                new LoanApplicationPropertyHandler( ( List<LoanApplicationProperty> ) newRecords, null )
                .validateLoanApplicationProperty();
            }
            if ( !Utils.loanApplicantPropertyTriggerSwitch.B_I_UpdateLoanApplicationProperties__c ) {
                new LoanApplicationPropertyHandler( ( List<LoanApplicationProperty> ) newRecords, null )
                .updateLoanApplicationProperties();
            }
        }
    }

    protected override void onAfterInsert() { 
        if ( !Utils.loanApplicantPropertyTriggerSwitch.Disable_After_Insert_Functionality__c ) {
            if ( !Utils.loanApplicantPropertyTriggerSwitch.A_I_Update_Lenders_Lien_Type__c ) {
                new LoanApplicationPropertyHandler( ( List<LoanApplicationProperty> ) newRecords, null )
                .updateLoanAppPropertyValue();
            }
        }
    }

    protected override void onBeforeUpdate() { 
                            ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
        if ( !Utils.loanApplicantPropertyTriggerSwitch.Disable_Before_Update_Functionality__c ) {
            if ( !Utils.loanApplicantPropertyTriggerSwitch.B_U_Loan_App_Property_Validation__c ) {
                new LoanApplicationPropertyHandler( ( List<LoanApplicationProperty> ) newRecords, (Map<Id,LoanApplicationProperty>) oldRecordsMap )
                .validateLoanApplicationProperty();
                new LoanApplicationPropertyHandler( ( List<LoanApplicationProperty> ) newRecords, (Map<Id,LoanApplicationProperty>) oldRecordsMap )
                .lockLoanApplicationProperty();
            }
            
        }   
    }

    protected override void onAfterUpdate() { 
        if ( !Utils.loanApplicantPropertyTriggerSwitch.Disable_After_Update_Functionality__c ) {
            if ( !Utils.loanApplicantPropertyTriggerSwitch.A_U_Update_Lenders_Lien_Type__c ) {
                new LoanApplicationPropertyHandler( ( List<LoanApplicationProperty> ) newRecords, null )
                .updateLoanAppPropertyValue();
            }
        }

        new LoanApplicationPropertyAmlFlagsHelper( ( List<LoanApplicationProperty> ) newRecords, ( Map<Id, LoanApplicationProperty> ) oldRecordsMap )
        .insertLoanApplicationPropertyAmlFlag();
    }
    
    protected override void onBeforeDelete() {
        ApprovalProcessRecordLockingHelper.lockRecord(oldRecords);
    }

    protected override void onAfterDelete() { 
        system.debug('delete');
        new LoanApplicationPropertyHandler( ( List<LoanApplicationProperty> ) newRecords, null )
        .updateLoanAppPropertyValue();
    }

    protected override void onAfterUnDelete() { 
                    ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
        system.debug('undelete');
        new LoanApplicationPropertyHandler( ( List<LoanApplicationProperty> ) newRecords, null )
        .updateLoanAppPropertyValue();
                ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
    }
}
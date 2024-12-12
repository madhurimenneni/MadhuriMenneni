/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-01-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Valuations extends SObjectDomain{
    protected override void onBeforeInsert() {
                    ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
        new ValuationHandler( ( List<Valuation__c> ) newRecords, null )
        .stopCreatingDuplicatePurchaseValuation();
    }
    protected override void onAfterInsert() { 
        if ( !Utils.ValuationTriggerSwitch.Disbale_After_Insert_Functionality__c ) {
            if ( !Utils.ValuationTriggerSwitch.A_I_Update_Valuation_Fields__c ) {
                new ValuationHandler( ( List<Valuation__c> ) newRecords, null )
                .updateValuationLoanAppPropertyFields();
            }
        }

        new ValuationAmlFlagsHelper(( List<Valuation__c> ) newRecords, null ).insertValuationAmlFlag();
    }

    protected override void onBeforeUpdate() {
                    ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
        new ValuationHandler( ( List<Valuation__c> ) newRecords, (Map<Id,Valuation__c>) oldRecordsMap )
        .stopCreatingDuplicatePurchaseValuation();
    }

    protected override void onAfterUpdate() { 
        if ( !Utils.ValuationTriggerSwitch.Disbale_After_Update_Functionality__c ) {
            if ( !Utils.ValuationTriggerSwitch.A_U_Update_Valuation_Fields__c ) {
                new ValuationHandler( ( List<Valuation__c> ) newRecords, (Map<Id,Valuation__c>) oldRecordsMap )
                .updateValuationLoanAppPropertyFields();
            }
        }
        new ValuationAmlFlagsHelper(( List<Valuation__c> ) newRecords, (Map<Id,Valuation__c>) oldRecordsMap ).insertValuationAmlFlag();
    }
    
     protected override void onBeforeDelete() {
        ApprovalProcessRecordLockingHelper.lockRecord(oldRecords);
    }
    
    protected override void onAfterDelete() { 
        if ( !Utils.ValuationTriggerSwitch.Disbale_After_Update_Functionality__c ) {
            if ( !Utils.ValuationTriggerSwitch.A_U_Update_Valuation_Fields__c ) {
                new ValuationHandler( ( List<Valuation__c> ) oldRecords, null )
                .updateValuationLoanAppPropertyFieldsAfterDelete();
            }
        }
        new ValuationAmlFlagsHelper(( List<Valuation__c> ) oldRecords, null ).insertValuationAmlFlag();
    }
    
    protected override void onAfterUnDelete() { 
                    ApprovalProcessRecordLockingHelper.lockRecord(newRecords);
        new ValuationAmlFlagsHelper(( List<Valuation__c> ) newRecords, null ).insertValuationAmlFlag();
    }
}
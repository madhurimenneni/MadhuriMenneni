public class Opportunities extends SObjectDomain{
    protected override void onBeforeUpdate() { 
        if ( !Utils.opportunityTriggerSwitch.Disable_Before_Update_Functionality__c ) {
            if ( !Utils.opportunityTriggerSwitch.B_U_Populate_Primary_Campaign_Source__c ) {
                new OpportunityHandler( ( List<Opportunity> ) newRecords, (Map<Id,Opportunity>) oldRecordsMap )
                .populatePrimaryCampaignSource();
            }
        }
    }
    protected override void onBeforeInsert() { 
        if ( !Utils.opportunityTriggerSwitch.Disable_Before_Insert_Functionality__c ) {
            if ( !Utils.opportunityTriggerSwitch.B_I_Populate_Primary_Campaign_Source__c ) {
                new OpportunityHandler( ( List<Opportunity> ) newRecords, null )
                .populatePrimaryCampaignSource();
            }
        }
    }
}
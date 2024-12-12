/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-12-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class RLASubConditionHandler {
    List<RLA_Sub_Condition__c> newRLASubConditions = new List<RLA_Sub_Condition__c>();
    Map<Id, RLA_Sub_Condition__c> oldRLASubConditions = new Map<Id, RLA_Sub_Condition__c>();

    public RLASubConditionHandler( List<RLA_Sub_Condition__c> newRecords, Map<Id, RLA_Sub_Condition__c> oldRecords ) {
        newRLASubConditions = newRecords;
        oldRLASubConditions = oldRecords;
    }

    public void updateIdVerifiedDateOnRla(){
        List<ResidentialLoanApplication> rlasToUpdate = new List<ResidentialLoanApplication>();
        for ( RLA_Sub_Condition__c newRLASubCondition : newRLASubConditions ) {
            if ( oldRLASubConditions != null ) {
                RLA_Sub_Condition__c oldRLASubCondition = oldRLASubConditions.get(newRLASubCondition.Id);
                if ( !oldRLASubCondition.Received__c && newRLASubCondition.Received__c && newRLASubCondition.Condition__c.toLowerCase().contains(('2 Pieces of ID').toLowerCase()) ) {
                    ResidentialLoanApplication rlaToUpdate = new ResidentialLoanApplication();
                    rlaToUpdate.Id = newRLASubCondition.Residential_Loan_Application__c;
                    rlaToUpdate.ID_Verified_Date__c = System.Today();
                    rlasToUpdate.add(rlaToUpdate);
                } else if ( oldRLASubCondition.Received__c && !newRLASubCondition.Received__c && newRLASubCondition.Condition__c.toLowerCase().contains(('2 Pieces of ID').toLowerCase()) ) {
                    ResidentialLoanApplication rlaToUpdate = new ResidentialLoanApplication();
                    rlaToUpdate.Id = newRLASubCondition.Residential_Loan_Application__c;
                    rlaToUpdate.ID_Verified_Date__c = null;
                    rlasToUpdate.add(rlaToUpdate);
                }
            }
        }

        if ( !rlasToUpdate.isEmpty() ) {
            SObjectDomain.getTriggerEvent(ResidentialLoanApplications.class).disableAll();
                update rlasToUpdate;
            SObjectDomain.getTriggerEvent(ResidentialLoanApplications.class).enableAll();
        }
    }
}
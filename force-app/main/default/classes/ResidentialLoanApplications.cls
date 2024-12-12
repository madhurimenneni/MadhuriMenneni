public with sharing class ResidentialLoanApplications extends SObjectDomain {
    
    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 28-June-2022
    * @description Called by the trigger framework to carry out the actions after the newRecords are Inserted. 
    */
    protected override void onAfterInsert() {
        new ResidentialLoanApplicationsHelper( ( List<ResidentialLoanApplication> ) newRecords, null )
        .updateBrokerKpis();
    }

    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 21-Oct-2022
    * @description Called by the trigger framework to carry out the actions before the newRecords are Updated. 
    */
    protected override void onBeforeUpdate() {
        if ( !Utils.rlaTriggerSwitch.B_U_Resedential_Loan_App_Validation__c ) {
            new ResidentialLoanApplicationsHelper( ( List<ResidentialLoanApplication> ) newRecords, (Map<Id,ResidentialLoanApplication>) oldRecordsMap )
            .residentialLoanAppValidation();
        }
        new ResidentialLoanApplicationsHelper( ( List<ResidentialLoanApplication> ) newRecords, (Map<Id,ResidentialLoanApplication>) oldRecordsMap )
        .automationOnLeadAppStatus();
        new ResidentialLoanApplicationsHelper( ( List<ResidentialLoanApplication> ) newRecords, (Map<Id,ResidentialLoanApplication>) oldRecordsMap )
        .ltvCalculator();
        new ResidentialLoanApplicationsHelper( ( List<ResidentialLoanApplication> ) newRecords, (Map<Id,ResidentialLoanApplication>) oldRecordsMap )
        .populateRlaFields();

        new RlaDealScoring((List<ResidentialLoanApplication> ) newRecords, (Map<Id,ResidentialLoanApplication>) oldRecordsMap).calculateDealScore();
    }

    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 28-June-2022
    * @description Called by the trigger framework to carry out the actions after the newRecords are Updated. 
    */
    protected override void onAfterUpdate() {
        new ResidentialLoanApplicationsHelper( ( List<ResidentialLoanApplication> ) newRecords, ( Map<Id, ResidentialLoanApplication> ) oldRecordsMap )
        .updateBrokerKpis();

        new ResidentialLoanApplicationsHelper( ( List<ResidentialLoanApplication> ) newRecords, ( Map<Id, ResidentialLoanApplication> ) oldRecordsMap )
        .addStandardConditionsOnRLA();
        
        new ResidentialLoanApplicationsHelper( ( List<ResidentialLoanApplication> ) newRecords, ( Map<Id, ResidentialLoanApplication> ) oldRecordsMap )
        .DeleteFailedApplications();

        new RlaAmlFlagHelper( ( List<ResidentialLoanApplication> ) newRecords, ( Map<Id, ResidentialLoanApplication> ) oldRecordsMap )
        .insertAmlFlag();

        new ResidentialLoanApplicationsHelper( ( List<ResidentialLoanApplication> ) newRecords, (Map<Id,ResidentialLoanApplication>) oldRecordsMap )
        .updateLoanApplicationPropertyValues();
    }

     /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 28-June-2022
    * @description Called by the trigger framework to carry out the actions after the newRecords are Updated. 
    */
    protected override void onAfterDelete() {
        if ( !Utils.rlaTriggerSwitch.A_D_Disable__c ) {
            new ResidentialLoanApplicationsHelper( ( List<ResidentialLoanApplication> ) oldRecords, null )
            .updateBrokerKpis();
        }
    }

    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 28-June-2022
    * @description Called by the trigger framework to carry out the actions after the newRecords are Updated. 
    */
    protected override void onAfterUndelete() {
        new ResidentialLoanApplicationsHelper( ( List<ResidentialLoanApplication> ) newRecords, null )
        .updateBrokerKpis();

        new ResidentialLoanApplicationsHelper( ( List<ResidentialLoanApplication> ) newRecords, null )
        .ltvCalculator();
    }
}
public class RlaCloneController {
    @InvocableMethod(label='Clone Rla' description='Clones RLA and Related Records' category='ResidentialLoanApplication')
    public static List<Id> cloneRla(List<Id> rlaId) {
        Id[] results = new List<Id>();
        List<String> rlaFields = new List<String>(ResidentialLoanApplication.SObjectType.getDescribe().fields.getMap().keySet());
        String rlaSoql = ''
                + ' select ' + String.join(rlaFields, ',')
                + ' from ResidentialLoanApplication'
                + ' where Id =: rlaId';
        ResidentialLoanApplication rlaToBeCloned = database.query(rlaSoql);
        ResidentialLoanApplication rlaToBeInserted = rlaToBeCloned.Clone(false,true,true,true);
        rlaToBeInserted.Status = ApexConstants.UNPROCESSED_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS;
        rlaToBeInserted.Drive_Link__c = '';
        rlaToBeInserted.Cloned__c = true;
        rlaToBeInserted.cloned_Rla__c = rlaToBeCloned.Id;
        insert rlaToBeInserted;


        List<String> loanApplicantFields = new List<String>(LoanApplicant.SObjectType.getDescribe().fields.getMap().keySet());
        List<String> loanApplicantAddressFields = new List<String>(LoanApplicantAddress.SObjectType.getDescribe().fields.getMap().keySet());
        List<String> loanApplicantEmploymentFields = new List<String>(LoanApplicantEmployment.SObjectType.getDescribe().fields.getMap().keySet());
        List<String> loanApplicantIncomeFields = new List<String>(LoanApplicantIncome.SObjectType.getDescribe().fields.getMap().keySet());
        List<String> propertyOwnerFields = new List<String>(Property_Owner__c.SObjectType.getDescribe().fields.getMap().keySet());
        List<String> loanApplicationPropertyFields = new List<String>(LoanApplicationProperty.SObjectType.getDescribe().fields.getMap().keySet());
        List<String> valuationFields = new List<String>(Valuation__c.SObjectType.getDescribe().fields.getMap().keySet());
        List<String> downpaymentFields = new List<String>(Downpayment__c.SObjectType.getDescribe().fields.getMap().keySet());
        List<String> rentalIncomeFields = new List<String>(Rental_Income__c.SObjectType.getDescribe().fields.getMap().keySet());
        
        String loanApplicantsSoql = ''
                                  + ' SELECT ' + String.join(loanApplicantFields, ',')
                                    + ' ,( SELECT ' + String.join(loanApplicantAddressFields, ',') 
                                    + ' FROM LoanApplicantAddresses)'
                                    + ' ,( SELECT ' + String.join(loanApplicantEmploymentFields, ',') 
                                    + ' FROM LoanApplicantEmployments)'
                                    + ' ,( SELECT ' + String.join(loanApplicantIncomeFields, ',') 
                                    + ' FROM LoanApplicantIncomes)'
                                    + ' ,( SELECT ' + String.join(propertyOwnerFields, ',') 
                                    + ' FROM Property_Owners__r)'
                                  + ' FROM LoanApplicant'
                                  + ' WHERE LoanApplicationId =: rlaId';
        
        String loanApplicationPropertiesSoql = ''
                                                + ' SELECT ' + String.join(loanApplicationPropertyFields, ',')
                                                + ' ,( SELECT ' + String.join(valuationFields, ',') 
                                                + ' FROM Valuations__r)'
                                                + ' ,( SELECT ' + String.join(downpaymentFields, ',') 
                                                + ' FROM Downpayments__r)'
                                                + ' ,( SELECT ' + String.join(rentalIncomeFields, ',') 
                                                + ' FROM Rental_Incomes__r)'
                                                + ' FROM LoanApplicationProperty'
                                                + ' WHERE LoanApplicationId =: rlaId';

        List<LoanApplicant> loanApplicantsToBeCloned = database.query(loanApplicantsSoql);
        List<LoanApplicationProperty> loanApplicationPropertiesToBeCloned = database.query(loanApplicationPropertiesSoql);

        List<LoanApplicant> loanApplicantsToBeInserted = new List<LoanApplicant>();
        List<LoanApplicantAddress> loanApplicantAddressesToBeInserted = new List<LoanApplicantAddress>();
        List<LoanApplicantEmployment> loanApplicantEmploymentsToBeInserted = new List<LoanApplicantEmployment>();
        List<LoanApplicantIncome> loanApplicantIncomesToBeInserted = new List<LoanApplicantIncome>();
        List<Property_Owner__c> propertyOwnersToBeInserted = new List<Property_Owner__c>();
        List<LoanApplicationProperty> loanApplicationPropertiesToBeInserted = new List<LoanApplicationProperty>();
        List<Valuation__c> valuationsToBeInserted = new List<Valuation__c>();
        List<Downpayment__c> downpaymentsToBeInserted = new List<Downpayment__c>();
        List<Rental_Income__c> rentalIncomesToBeInserted = new List<Rental_Income__c>();

        Map<Id, Id> loanApplicationPropertyClonedIdTONewInsertedId = new Map<Id, Id>();
        for ( LoanApplicationProperty loanApplicationPropertyToBeCloned : loanApplicationPropertiesToBeCloned ) {
            LoanApplicationProperty loanApplicationPropertyToBeInserted = loanApplicationPropertyToBeCloned.Clone(false,true,true,true);
            loanApplicationPropertyToBeInserted.LoanApplicationId = rlaToBeInserted.Id;
            loanApplicationPropertyToBeInserted.Cloned_From_Id__c = loanApplicationPropertyToBeCloned.Id;
            insert loanApplicationPropertyToBeInserted;
            System.debug(loanApplicationPropertyToBeInserted.LoanApplicationId);

            loanApplicationPropertyClonedIdTONewInsertedId.put(loanApplicationPropertyToBeCloned.Id, loanApplicationPropertyToBeInserted.Id);

            for ( Valuation__c valuationToBeCloned : loanApplicationPropertyToBeCloned.Valuations__r ) {
                Valuation__c valuationToBeInserted = valuationToBeCloned.Clone(false,true,true,true);
                valuationToBeInserted.Loan_Application_Property__c = loanApplicationPropertyToBeInserted.Id;
                valuationsToBeInserted.add(valuationToBeInserted);
            }

            for ( Downpayment__c downpaymentToBeCloned : loanApplicationPropertyToBeCloned.Downpayments__r ) {
                Downpayment__c downpaymentToBeInserted = downpaymentToBeCloned.Clone(false,true,true,true);
                downpaymentToBeInserted.Loan_Application_Property__c = loanApplicationPropertyToBeInserted.Id;
                downpaymentsToBeInserted.add(downpaymentToBeInserted);
            }

            for ( Rental_Income__c rentalIncomeToBeCloned : loanApplicationPropertyToBeCloned.Rental_Incomes__r ) {
                Rental_Income__c rentalIncomeToBeInserted = rentalIncomeToBeCloned.Clone(false,true,true,true);
                rentalIncomeToBeInserted.Property__c = loanApplicationPropertyToBeInserted.Id;
                rentalIncomesToBeInserted.add(rentalIncomeToBeInserted);
            }
        }

        insert valuationsToBeInserted;
        insert downpaymentsToBeInserted;
        insert rentalIncomesToBeInserted;

        for ( LoanApplicant loanApplicantToBeCloned : loanApplicantsToBeCloned ) {
            LoanApplicant loanApplicantToBeInserted = loanApplicantToBeCloned.Clone(false,true,true,true);
            loanApplicantToBeInserted.LoanApplicationId = rlaToBeInserted.Id;
            insert loanApplicantToBeInserted;

            for ( LoanApplicantAddress loanApplicantAddressToBeCloned : loanApplicantToBeCloned.LoanApplicantAddresses ) {
                LoanApplicantAddress loanApplicantAddressToBeInserted = loanApplicantAddressToBeCloned.Clone(false,true,true,true);
                loanApplicantAddressToBeInserted.LoanApplicationId = rlaToBeInserted.Id;
                loanApplicantAddressToBeInserted.LoanApplicantId = loanApplicantToBeInserted.Id;
                loanApplicantAddressesToBeInserted.add(loanApplicantAddressToBeInserted);
            }

            for ( LoanApplicantEmployment loanApplicantEmploymentToBeCloned : loanApplicantToBeCloned.LoanApplicantEmployments ) {
                LoanApplicantEmployment loanApplicantEmploymentToBeInserted = loanApplicantEmploymentToBeCloned.Clone(false,true,true,true);
                loanApplicantEmploymentToBeInserted.LoanApplicationId = rlaToBeInserted.Id;
                loanApplicantEmploymentToBeInserted.LoanApplicantId = loanApplicantToBeInserted.Id;
                loanApplicantEmploymentsToBeInserted.add(loanApplicantEmploymentToBeInserted);
            }

            for ( LoanApplicantIncome loanApplicantIncomeToBeCloned : loanApplicantToBeCloned.LoanApplicantIncomes ) {
                LoanApplicantIncome loanApplicantIncomeToBeInserted = loanApplicantIncomeToBeCloned.Clone(false,true,true,true);
                loanApplicantIncomeToBeInserted.LoanApplicationId = rlaToBeInserted.Id;
                loanApplicantIncomeToBeInserted.LoanApplicantId = loanApplicantToBeInserted.Id;
                loanApplicantIncomesToBeInserted.add(loanApplicantIncomeToBeInserted);
            }

            for ( Property_Owner__c propertyOwnerToBeCloned : loanApplicantToBeCloned.Property_Owners__r ) {
                Property_Owner__c propertyOwnerToBeInserted = propertyOwnerToBeCloned.Clone(false,true,true,true);
                propertyOwnerToBeInserted.Loan_Applicant__c = loanApplicantToBeInserted.Id;
                propertyOwnerToBeInserted.Property__c = loanApplicationPropertyClonedIdTONewInsertedId.get(propertyOwnerToBeCloned.Property__c);
                propertyOwnersToBeInserted.add(propertyOwnerToBeInserted);
            }
        }

        insert loanApplicantAddressesToBeInserted;
        insert loanApplicantEmploymentsToBeInserted;
        insert loanApplicantIncomesToBeInserted;
        insert propertyOwnersToBeInserted;

        List<String> loanApplicationAssetFields = new List<String>(LoanApplicationAsset.SObjectType.getDescribe().fields.getMap().keySet());
        String loanApplicationAssetSoql = ''
                + ' select ' + String.join(loanApplicationAssetFields, ',')
                + ' from LoanApplicationAsset'
                + ' where LoanApplicationId =: rlaId';
        List<LoanApplicationAsset> loanApplicationAssetsToBeCloned = database.query(loanApplicationAssetSoql);
        List<LoanApplicationAsset> loanApplicationAssetsToBeInserted = new List<LoanApplicationAsset>();
        for ( LoanApplicationAsset loanApplicationAssetToBeCloned : loanApplicationAssetsToBeCloned) {
            LoanApplicationAsset loanApplicationAssetToBeInserted = loanApplicationAssetToBeCloned.Clone(false,true,true,true);
            loanApplicationAssetToBeInserted.LoanApplicationId = rlaToBeInserted.Id;
            loanApplicationAssetsToBeInserted.add( loanApplicationAssetToBeInserted );
        }
        insert loanApplicationAssetsToBeInserted;

        List<String> loanApplicationLiabilityFields = new List<String>(LoanApplicationLiability.SObjectType.getDescribe().fields.getMap().keySet());
        String loanApplicationLiabilitySoql = ''
                + ' select ' + String.join(loanApplicationLiabilityFields, ',')
                + ' from LoanApplicationLiability'
                + ' where LoanApplicationId =: rlaId';
        List<LoanApplicationLiability> loanApplicationLiabilitiesToBeCloned = database.query(loanApplicationLiabilitySoql);
        List<LoanApplicationLiability> loanApplicationLiabilitiesToBeInserted = new List<LoanApplicationLiability>();
        for ( LoanApplicationLiability loanApplicationLiabilityToBeCloned : loanApplicationLiabilitiesToBeCloned ) {
            LoanApplicationLiability loanApplicationLiabilityToBeInserted = loanApplicationLiabilityToBeCloned.Clone(false,true,true,true);
            loanApplicationLiabilityToBeInserted.LoanApplicationId = rlaToBeInserted.Id;
            loanApplicationLiabilityToBeInserted.Loan_Application_Property__c = loanApplicationPropertyClonedIdTONewInsertedId.get(loanApplicationLiabilityToBeCloned.Loan_Application_Property__c);
            loanApplicationLiabilitiesToBeInserted.add( loanApplicationLiabilityToBeInserted );
            System.debug(loanApplicationLiabilityToBeInserted.LoanApplicationId);
        }
        insert loanApplicationLiabilitiesToBeInserted;
        results.add(rlaToBeInserted.Id);
        return results;
    }
}
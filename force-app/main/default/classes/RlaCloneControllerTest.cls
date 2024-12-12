@istest
private class RlaCloneControllerTest {
    static Integer COUNT = 1;
    @istest
    private static void testRlaCloneFuncationality(){
        List<Apex_static_components__c> constantsList = TestDataFactory.createConstant(true);
        List<Account> personAccounts = TestDataFactory.createPersonAccounts(COUNT, true);
        List<Account> brokerageAccounts = TestDataFactory.createBrokerageAccounts(COUNT, true);

        List<Contact> brokerageContactsToInsert = new List<Contact>();
        for ( integer i=0; i<COUNT; i++ ) {
            brokerageContactsToInsert.add(TestDataFactory.createBrokerContact( brokerageAccounts[i].Id, false ) );
        }
        insert brokerageContactsToInsert;

        List<ResidentialLoanApplication> residentialLoanApplicationsToInsert = new List<ResidentialLoanApplication>();
        for ( integer i=0; i<COUNT; i++ ) {
            ResidentialLoanApplication rla = TestDataFactory.createResidentialLoanApplication( personAccounts[i].Id, brokerageAccounts[i].Id, false );
            rla.Contact__c = brokerageContactsToInsert[i].Id;
            residentialLoanApplicationsToInsert.add( rla );
        }
        insert residentialLoanApplicationsToInsert;

        List<LoanApplicant> loanApplicantsToInsert = new List<LoanApplicant>();
        for ( Integer i =0; i<COUNT; i++ ) {
            loanApplicantsToInsert.addAll(TestDataFactory.createRegularLoanApplicant(residentialLoanApplicationsToInsert[i].Id, 1, false ));
        }
        insert loanApplicantsToInsert;

        List<LoanApplicantAddress> loanApplicantAddressesToInsert = new List<LoanApplicantAddress>();
        for ( Integer i = 0; i < COUNT; i++ ) {
            loanApplicantAddressesToInsert.add( TestDataFactory.createLoanApplicantAddress(loanApplicantsToInsert[i].Id, false ) );
        }
        insert loanApplicantAddressesToInsert;

        List<LoanApplicantEmployment> loanApplicantEmploymentsToInsert = new List<LoanApplicantEmployment>();
        for ( Integer i = 0; i < COUNT; i++ ) {
            loanApplicantEmploymentsToInsert.addAll( TestDataFactory.createLoanApplicantEmployments(residentialLoanApplicationsToInsert[i].Id, loanApplicantsToInsert[i].Id, 1, false ) );
        }
        insert loanApplicantEmploymentsToInsert;

        List<LoanApplicantIncome> loanApplicantIncomesToInsert = new List<LoanApplicantIncome>();
        for ( Integer i = 0; i < COUNT; i++ ) {
            loanApplicantIncomesToInsert.addAll( TestDataFactory.createLoanApplicantIncome(residentialLoanApplicationsToInsert[i].Id, loanApplicantsToInsert[i].Id, 1, false ) );
        }
        insert loanApplicantIncomesToInsert;

        List<LoanApplicationProperty> loanApplicationPropertiesToInsert = new List<LoanApplicationProperty>();
        for ( Integer i = 0; i < COUNT; i++ ) {
            loanApplicationPropertiesToInsert.addAll( TestDataFactory.createRegularLoanApplicationProperty(residentialLoanApplicationsToInsert[i].Id, 1, false ) );
        }
        insert loanApplicationPropertiesToInsert;

        List<Property_Owner__c> loanApplicantOwnedPropertiesToInsert = new List<Property_Owner__c>();
        for ( Integer i = 0; i < COUNT; i++ ) {
            loanApplicantOwnedPropertiesToInsert.addAll( TestDataFactory.createLoanApplicantOwnedProperties(loanApplicantsToInsert[i].Id, loanApplicationPropertiesToInsert[i].Id, 1, false ) );
        }
        insert loanApplicantOwnedPropertiesToInsert;

        List<Valuation__c> valuationsToInsert = new List<Valuation__c>();
        for ( Integer i = 0; i < COUNT; i++ ) {
            valuationsToInsert.addAll(TestDataFactory.createAppraisedValueValuation(loanApplicationPropertiesToInsert[i].Id, 1, false));
        }
        insert valuationsToInsert;

        List<Downpayment__c> downpaymentsToInsert = new List<Downpayment__c>();
        for ( Integer i = 0; i < COUNT; i++ ) {
            downpaymentsToInsert.addAll(TestDataFactory.createDownpayment(loanApplicationPropertiesToInsert[i].Id, 1, false));
        }
        insert downpaymentsToInsert;

        List<Rental_Income__c> rentalIncomesToBeInserted = new List<Rental_Income__c>();
        for ( Integer i = 0; i < COUNT; i++ ) {
            rentalIncomesToBeInserted.addAll(TestDataFactory.CreatePrimaryResidenceRentalIncome(loanApplicationPropertiesToInsert[i].Id, 1, false));
        }
        insert rentalIncomesToBeInserted;

        List<LoanApplicationAsset> loanApplicationAssetsToBeInserted = new List<LoanApplicationAsset>();
        for ( Integer i = 0; i < COUNT; i++ ) {
            loanApplicationAssetsToBeInserted.addAll(TestDataFactory.createLoanApplicationAssets(residentialLoanApplicationsToInsert[i].Id, 1, false));
        }
        insert loanApplicationAssetsToBeInserted;

        List<LoanApplicationLiability> loanApplicationLiabilitiesToBeInserted = new List<LoanApplicationLiability>();
        for ( Integer i = 0; i < COUNT; i++ ) {
            loanApplicationLiabilitiesToBeInserted.addAll(TestDataFactory.createLoanApplicantionLiability(residentialLoanApplicationsToInsert[i].Id, loanApplicationPropertiesToInsert[i].Id, 1, false));
        }
        insert loanApplicationLiabilitiesToBeInserted;

        testCloning(new List<Id>{residentialLoanApplicationsToInsert[0].Id});
    }

    @future
    private static void testCloning( List<Id> residentialLoanAppsIds ) {
        RlaCloneController.cloneRla(residentialLoanAppsIds);
    }
}
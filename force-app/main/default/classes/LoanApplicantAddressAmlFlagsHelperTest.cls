@istest
private class LoanApplicantAddressAmlFlagsHelperTest {
    static Integer COUNT = 30;

    @TestSetup
    static void makeData(){
        List<Apex_static_components__c> constantsList = TestDataFactory.createConstant(true);
    }

    @isTest
    private static void testAddressPOBoxFlag() {
        List<Account> personAccounts = TestDataFactory.createPersonAccounts(COUNT, true);
        List<Account> brokerageAccounts = TestDataFactory.createBrokerageAccounts(COUNT, true);

        List<Contact> brokerageContactsToInsert = new List<Contact>();
        for (integer i = 0; i < COUNT; i++) {
            brokerageContactsToInsert.add(TestDataFactory.createBrokerContact(brokerageAccounts[i].Id, false));
        }
        insert brokerageContactsToInsert;

        List<ResidentialLoanApplication> residentialLoanApplicationsToInsert = new List<ResidentialLoanApplication>();
        for (integer i = 0; i < COUNT; i++) {
            ResidentialLoanApplication rla = TestDataFactory.createResidentialLoanApplication(personAccounts[i].Id, brokerageAccounts[i].Id, false);
            rla.Contact__c = brokerageContactsToInsert[i].Id;
            residentialLoanApplicationsToInsert.add(rla);
        }
        insert residentialLoanApplicationsToInsert;

        List<LoanApplicant> loanApplicantsToInsert = new List<LoanApplicant>();
        for (Integer i = 0; i < COUNT; i++) {
            loanApplicantsToInsert.addAll(TestDataFactory.createRegularLoanApplicant(residentialLoanApplicationsToInsert[i].Id, 1, false));
        }
        insert loanApplicantsToInsert;

        // Insert LoanApplicantAddress records with PO Box in ResidenceStreet
        List<LoanApplicantAddress> loanApplicantAddressesToInsert = new List<LoanApplicantAddress>();
        for (Integer i = 0; i < COUNT; i++) {
            LoanApplicantAddress loanApplicantAddressToInsert = TestDataFactory.createLoanApplicantAddress(loanApplicantsToInsert[i].Id, false);
            loanApplicantAddressToInsert.ResidenceStreet = 'P.O Box 1234';
            loanApplicantAddressesToInsert.add(loanApplicantAddressToInsert);
        }
        insert loanApplicantAddressesToInsert;

        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = false AND Type__c = 'Only PO Box Provided'].size(), 'Number of Flags created are not as expected');

        for (LoanApplicantAddress loanApplicantAddress : loanApplicantAddressesToInsert) {
            loanApplicantAddress.ResidenceStreet = '123 Street';
        }
        update loanApplicantAddressesToInsert;

        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = true AND Type__c = 'Only PO Box Provided'].size(), 'Flags should be resolved after updating all addresses to non-PO Box.');
    }

    @isTest
    private static void testNoFlagsCreation() {
        List<Account> personAccounts = TestDataFactory.createPersonAccounts(COUNT, true);
        List<Account> brokerageAccounts = TestDataFactory.createBrokerageAccounts(COUNT, true);

        List<Contact> brokerageContactsToInsert = new List<Contact>();
        for (integer i = 0; i < COUNT; i++) {
            brokerageContactsToInsert.add(TestDataFactory.createBrokerContact(brokerageAccounts[i].Id, false));
        }
        insert brokerageContactsToInsert;

        List<ResidentialLoanApplication> residentialLoanApplicationsToInsert = new List<ResidentialLoanApplication>();
        for (integer i = 0; i < COUNT; i++) {
            ResidentialLoanApplication rla = TestDataFactory.createResidentialLoanApplication(personAccounts[i].Id, brokerageAccounts[i].Id, false);
            rla.Contact__c = brokerageContactsToInsert[i].Id;
            residentialLoanApplicationsToInsert.add(rla);
        }
        insert residentialLoanApplicationsToInsert;

        List<LoanApplicant> loanApplicantsToInsert = new List<LoanApplicant>();
        for (Integer i = 0; i < COUNT; i++) {
            loanApplicantsToInsert.addAll(TestDataFactory.createRegularLoanApplicant(residentialLoanApplicationsToInsert[i].Id, 1, false));
        }
        insert loanApplicantsToInsert;

        List<LoanApplicantAddress> loanApplicantAddressesToInsert = new List<LoanApplicantAddress>();
        for (Integer i = 0; i < COUNT; i++) {
            LoanApplicantAddress loanApplicantAddressToInsert = TestDataFactory.createLoanApplicantAddress(loanApplicantsToInsert[i].Id, false);
            loanApplicantAddressesToInsert.add(loanApplicantAddressToInsert);
        }
        insert loanApplicantAddressesToInsert;

        Assert.areEqual(0, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = false AND Type__c = 'Only PO Box Provided'].size(), 'No flags should be created for valid addresses.');
    }
}
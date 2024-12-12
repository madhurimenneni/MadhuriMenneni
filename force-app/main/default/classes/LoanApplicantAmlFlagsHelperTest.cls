@istest
private class LoanApplicantAmlFlagsHelperTest {
    static Integer COUNT = 30;
   @TestSetup
    static void makeData(){
        List<Apex_static_components__c> constantsList = TestDataFactory.createConstant(true);
    }

    @isTest
    private static void testNonResidentFlagsForCitizen(){

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
            rla.Status = ApexConstants.SENT_COMMITMENT_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS;
            residentialLoanApplicationsToInsert.add( rla );
        }
        insert residentialLoanApplicationsToInsert;

        List<LoanApplicant> loanApplicantsToInsert = new List<LoanApplicant>();
        for ( Integer i =0; i<COUNT; i++ ) {
            loanApplicantsToInsert.addAll(TestDataFactory.createRegularLoanApplicant(residentialLoanApplicationsToInsert[i].Id, 1, false ));
        }
        insert loanApplicantsToInsert;

        for ( LoanApplicant loanApplicant : loanApplicantsToInsert ) {
            loanApplicant.CitizenshipStatus = 'U.S. Citizen';
        }

        update loanApplicantsToInsert;

        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = false AND Type__c = 'Non-Resident'].size(), 'Number of Flags created are not as expected');

        List<LoanApplicant> loanApplicantsToUpdate = new List<LoanApplicant>();
        for ( LoanApplicant loanApplicant : [SELECT Id, CitizenshipStatus FROM LoanApplicant] ) {
            loanApplicant.CitizenshipStatus = 'Citizen';
            loanApplicantsToUpdate.add( loanApplicant );
        }
        update loanApplicantsToUpdate;

        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = true AND Type__c = 'Non-Resident'].size(), 'Number of Flags created are not as expected');
    }

    @isTest
    private static void testNonResidentFlagsForResident(){

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
            rla.Status = ApexConstants.SENT_COMMITMENT_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS;
            residentialLoanApplicationsToInsert.add( rla );
        }
        insert residentialLoanApplicationsToInsert;

        List<LoanApplicant> loanApplicantsToInsert = new List<LoanApplicant>();
        for ( Integer i =0; i<COUNT; i++ ) {
            loanApplicantsToInsert.addAll(TestDataFactory.createRegularLoanApplicant(residentialLoanApplicationsToInsert[i].Id, 1, false ));
        }
        insert loanApplicantsToInsert;

        for ( LoanApplicant loanApplicant : loanApplicantsToInsert ) {
            loanApplicant.CitizenshipStatus = 'U.S. Citizen';
        }

        update loanApplicantsToInsert;

        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = false AND Type__c = 'Non-Resident'].size(), 'Number of Flags created are not as expected');

        List<LoanApplicant> loanApplicantsToUpdate = new List<LoanApplicant>();
        for ( LoanApplicant loanApplicant : [SELECT Id, CitizenshipStatus FROM LoanApplicant] ) {
            loanApplicant.CitizenshipStatus = 'Resident';
            loanApplicantsToUpdate.add( loanApplicant );
        }
        update loanApplicantsToUpdate;

        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = true AND Type__c = 'Non-Resident'].size(), 'Number of Flags created are not as expected');
    }

    @isTest
    private static void testNonResidentFlagsForStudentVisa(){
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
            rla.Status = ApexConstants.SENT_COMMITMENT_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS;
            residentialLoanApplicationsToInsert.add( rla );
        }
        insert residentialLoanApplicationsToInsert;

        List<LoanApplicant> loanApplicantsToInsert = new List<LoanApplicant>();
        for ( Integer i =0; i<COUNT; i++ ) {
            loanApplicantsToInsert.addAll(TestDataFactory.createRegularLoanApplicant(residentialLoanApplicationsToInsert[i].Id, 1, false ));
        }
        insert loanApplicantsToInsert;

        for ( LoanApplicant loanApplicant : loanApplicantsToInsert ) {
            loanApplicant.CitizenshipStatus = 'U.S. Citizen';
        }

        update loanApplicantsToInsert;

        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = false AND Type__c = 'Non-Resident'].size(), 'Number of Flags created are not as expected');

        List<LoanApplicant> loanApplicantsToUpdate = new List<LoanApplicant>();
        for ( LoanApplicant loanApplicant : [SELECT Id, CitizenshipStatus FROM LoanApplicant] ) {
            loanApplicant.CitizenshipStatus = 'Student Visa';
            loanApplicantsToUpdate.add( loanApplicant );
        }
        update loanApplicantsToUpdate;

        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = true AND Type__c = 'Non-Resident'].size(), 'Number of Flags created are not as expected');
    }

    @isTest
    private static void testNonResidentFlagsForWorkVisa(){
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
            rla.Status = ApexConstants.SENT_COMMITMENT_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS;
            residentialLoanApplicationsToInsert.add( rla );
        }
        insert residentialLoanApplicationsToInsert;

        List<LoanApplicant> loanApplicantsToInsert = new List<LoanApplicant>();
        for ( Integer i =0; i<COUNT; i++ ) {
            loanApplicantsToInsert.addAll(TestDataFactory.createRegularLoanApplicant(residentialLoanApplicationsToInsert[i].Id, 1, false ));
        }
        insert loanApplicantsToInsert;

        for ( LoanApplicant loanApplicant : loanApplicantsToInsert ) {
            loanApplicant.CitizenshipStatus = 'U.S. Citizen';
        }

        update loanApplicantsToInsert;

        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = false AND Type__c = 'Non-Resident'].size(), 'Number of Flags created are not as expected');

        List<LoanApplicant> loanApplicantsToUpdate = new List<LoanApplicant>();
        for ( LoanApplicant loanApplicant : [SELECT Id, CitizenshipStatus FROM LoanApplicant] ) {
            loanApplicant.CitizenshipStatus = 'Work Visa';
            loanApplicantsToUpdate.add( loanApplicant );
        }
        update loanApplicantsToUpdate;

        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = true AND Type__c = 'Non-Resident'].size(), 'Number of Flags created are not as expected');
    }

    @isTest
    private static void testNonResidentFlagsForLandedImmigrant(){
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
            rla.Status = ApexConstants.SENT_COMMITMENT_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS;
            residentialLoanApplicationsToInsert.add( rla );
        }
        insert residentialLoanApplicationsToInsert;

        List<LoanApplicant> loanApplicantsToInsert = new List<LoanApplicant>();
        for ( Integer i =0; i<COUNT; i++ ) {
            loanApplicantsToInsert.addAll(TestDataFactory.createRegularLoanApplicant(residentialLoanApplicationsToInsert[i].Id, 1, false ));
        }
        insert loanApplicantsToInsert;

        for ( LoanApplicant loanApplicant : loanApplicantsToInsert ) {
            loanApplicant.CitizenshipStatus = 'U.S. Citizen';
        }

        update loanApplicantsToInsert;

        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = false AND Type__c = 'Non-Resident'].size(), 'Number of Flags created are not as expected');

        List<LoanApplicant> loanApplicantsToUpdate = new List<LoanApplicant>();
        for ( LoanApplicant loanApplicant : [SELECT Id, CitizenshipStatus FROM LoanApplicant] ) {
            loanApplicant.CitizenshipStatus = 'Landed Immigrant';
            loanApplicantsToUpdate.add( loanApplicant );
        }
        update loanApplicantsToUpdate;

        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = true AND Type__c = 'Non-Resident'].size(), 'Number of Flags created are not as expected');
    }

    @isTest
    private static void testNameChangeFlagForSentCommitment(){
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
            rla.Status = ApexConstants.SENT_COMMITMENT_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS;
            residentialLoanApplicationsToInsert.add( rla );
        }
        insert residentialLoanApplicationsToInsert;
        List<LoanApplicant> loanApplicantsToInsert = new List<LoanApplicant>();
        for ( Integer i =0; i<COUNT; i++ ) {
            loanApplicantsToInsert.addAll(TestDataFactory.createRegularLoanApplicant(residentialLoanApplicationsToInsert[i].Id, 1, false ));
        }
        insert loanApplicantsToInsert;

        for ( LoanApplicant loanApplicant : loanApplicantsToInsert ) {
            loanApplicant.CitizenshipStatus = 'U.S. Citizen';
            loanApplicant.Middle_Name__c = 'Test';
        }

        update loanApplicantsToInsert;

        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = false AND Type__c = 'Name Change'].size(), 'Number of Flags created are not as expected');
    }
    @isTest
    private static void testNameChangeFlagForReceivedCommitment(){
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
            rla.Status = '3. Received Commitment';
            residentialLoanApplicationsToInsert.add( rla );
        }
        insert residentialLoanApplicationsToInsert;
        List<LoanApplicant> loanApplicantsToInsert = new List<LoanApplicant>();
        for ( Integer i =0; i<COUNT; i++ ) {
            loanApplicantsToInsert.addAll(TestDataFactory.createRegularLoanApplicant(residentialLoanApplicationsToInsert[i].Id, 1, false ));
        }
        insert loanApplicantsToInsert;

        for ( LoanApplicant loanApplicant : loanApplicantsToInsert ) {
            loanApplicant.CitizenshipStatus = 'U.S. Citizen';
            loanApplicant.Middle_Name__c = 'Test';
        }

        update loanApplicantsToInsert;

        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = false AND Type__c = 'Name Change'].size(), 'Number of Flags created are not as expected');
    }

    @isTest
    private static void testNameChangeFlagForInstructed(){
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
            rla.Status = '4. Instructed';
            residentialLoanApplicationsToInsert.add( rla );
        }
        insert residentialLoanApplicationsToInsert;
        List<LoanApplicant> loanApplicantsToInsert = new List<LoanApplicant>();
        for ( Integer i =0; i<COUNT; i++ ) {
            loanApplicantsToInsert.addAll(TestDataFactory.createRegularLoanApplicant(residentialLoanApplicationsToInsert[i].Id, 1, false ));
        }
        insert loanApplicantsToInsert;

        for ( LoanApplicant loanApplicant : loanApplicantsToInsert ) {
            loanApplicant.CitizenshipStatus = 'U.S. Citizen';
            loanApplicant.Middle_Name__c = 'Test';
        }

        update loanApplicantsToInsert;

        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = false AND Type__c = 'Name Change'].size(), 'Number of Flags created are not as expected');
    }

    @isTest
    private static void testNameChangeFlagForFundsRequested(){
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
            rla.Status = '5. Funds Requested';
            residentialLoanApplicationsToInsert.add( rla );
        }
        insert residentialLoanApplicationsToInsert;
        List<LoanApplicant> loanApplicantsToInsert = new List<LoanApplicant>();
        for ( Integer i =0; i<COUNT; i++ ) {
            loanApplicantsToInsert.addAll(TestDataFactory.createRegularLoanApplicant(residentialLoanApplicationsToInsert[i].Id, 1, false ));
        }
        insert loanApplicantsToInsert;

        for ( LoanApplicant loanApplicant : loanApplicantsToInsert ) {
            loanApplicant.CitizenshipStatus = 'U.S. Citizen';
            loanApplicant.Middle_Name__c = 'Test';
        }

        update loanApplicantsToInsert;

        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = false AND Type__c = 'Name Change'].size(), 'Number of Flags created are not as expected');
    }

    @isTest
    private static void testNameChangeFlagForFunded(){
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
            rla.Status = '6. Funded';
            residentialLoanApplicationsToInsert.add( rla );
        }
        insert residentialLoanApplicationsToInsert;
        List<LoanApplicant> loanApplicantsToInsert = new List<LoanApplicant>();
        for ( Integer i =0; i<COUNT; i++ ) {
            loanApplicantsToInsert.addAll(TestDataFactory.createRegularLoanApplicant(residentialLoanApplicationsToInsert[i].Id, 1, false ));
        }
        insert loanApplicantsToInsert;

        for ( LoanApplicant loanApplicant : loanApplicantsToInsert ) {
            loanApplicant.CitizenshipStatus = 'U.S. Citizen';
            loanApplicant.Middle_Name__c = 'Test';
        }

        update loanApplicantsToInsert;

        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = false AND Type__c = 'Name Change'].size(), 'Number of Flags created are not as expected');
    }

    @isTest
    private static void testNoFalgsCreation(){
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
            rla.Status = '6. Funded';
            residentialLoanApplicationsToInsert.add( rla );
        }
        insert residentialLoanApplicationsToInsert;
        List<LoanApplicant> loanApplicantsToInsert = new List<LoanApplicant>();
        for ( Integer i =0; i<COUNT; i++ ) {
            List<LoanApplicant> loanApplicantToInsert = TestDataFactory.createRegularLoanApplicant(residentialLoanApplicationsToInsert[i].Id, 1, false );
            loanApplicantsToInsert.addAll(loanApplicantToInsert);
        }

        for ( LoanApplicant loanApplicant : loanApplicantsToInsert ) {
            loanApplicant.CitizenshipStatus = 'Citizen';
        }
        insert loanApplicantsToInsert;

        Assert.areEqual(0, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = false AND Type__c = 'Non-Resident'].size(), 'Number of Flags created are not as expected');
    }
}
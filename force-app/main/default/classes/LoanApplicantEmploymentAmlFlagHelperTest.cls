@isTest
private class LoanApplicantEmploymentAmlFlagHelperTest {
    static Integer COUNT = 1;
    @TestSetup
    static void makeData(){
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
    }

    @isTest
    private static void testForInsert(){
        List<LoanApplicant> loanApplicantsToInsert = [SELECT Id FROM LoanApplicant];
        List<ResidentialLoanApplication> residentialLoanApplicationsToInsert = [SELECT Id FROM ResidentialLoanApplication];
        List<LoanApplicantEmployment> loanApplicantEmploymentsToInsert = new List<LoanApplicantEmployment>();
        for ( Integer i = 0; i < COUNT; i++ ) {
            loanApplicantEmploymentsToInsert.addAll( TestDataFactory.createLoanApplicantEmployments(residentialLoanApplicationsToInsert[i].Id, loanApplicantsToInsert[i].Id, 1, false ) );
        }

        for ( LoanApplicantEmployment loanApplicantEmployment : loanApplicantEmploymentsToInsert ) {
            loanApplicantEmployment.Name = loanApplicantEmployment.Name + ' Bar';
            loanApplicantEmployment.Description__c = loanApplicantEmployment.Name + ' Bar';
            loanApplicantEmployment.EmployerName = loanApplicantEmployment.Name + ' Bar';
            loanApplicantEmployment.JobTitle = loanApplicantEmployment.Name + ' Bar';

        }
        insert loanApplicantEmploymentsToInsert;
        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = false AND Type__c = 'Gambling Income'].size(), 'Number of Flags created are not as expected');

        List<LoanApplicantIncome> loanApplicantIncomesToInsert = new List<LoanApplicantIncome>();
        for ( Integer i = 0; i < COUNT; i++ ) {
            loanApplicantIncomesToInsert.addAll( TestDataFactory.createLoanApplicantIncome(residentialLoanApplicationsToInsert[i].Id, loanApplicantsToInsert[i].Id, 1, false ) );
        }

        for ( LoanApplicantIncome loanApplicantIncome : loanApplicantIncomesToInsert ) {
            loanApplicantIncome.Name = loanApplicantIncome.Name + ' Bar';
            loanApplicantIncome.Description__c = loanApplicantIncome.Name + ' Bar';
        }

        insert loanApplicantIncomesToInsert;
        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = false AND Type__c = 'Gambling Income'].size(), 'Number of Flags created are not as expected');


        for ( LoanApplicantIncome loanApplicantIncome : loanApplicantIncomesToInsert ) {
            loanApplicantIncome.Name = TestDataFactory.LOAN_APPLICANT_INCOME;
            loanApplicantIncome.Description__c = TestDataFactory.LOAN_APPLICANT_INCOME;
        }

        update loanApplicantIncomesToInsert;
        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = false AND Type__c = 'Gambling Income'].size(), 'Number of Flags created are not as expected');

        for ( LoanApplicantEmployment loanApplicantEmployment : loanApplicantEmploymentsToInsert ) {
            loanApplicantEmployment.Name = TestDataFactory.LOAN_APPLICANT_EMPLOYMENT;
            loanApplicantEmployment.Description__c = TestDataFactory.LOAN_APPLICANT_EMPLOYMENT;
            loanApplicantEmployment.EmployerName = TestDataFactory.LOAN_APPLICANT_EMPLOYMENT;
            loanApplicantEmployment.JobTitle = TestDataFactory.LOAN_APPLICANT_EMPLOYMENT;
        }
        update loanApplicantEmploymentsToInsert;
        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = true AND Type__c = 'Gambling Income'].size(), 'Number of Flags created are not as expected');

        for ( LoanApplicantEmployment loanApplicantEmployment : loanApplicantEmploymentsToInsert ) {
            loanApplicantEmployment.Name = loanApplicantEmployment.Name + ' Bar';
            loanApplicantEmployment.Description__c = loanApplicantEmployment.Name + ' Bar';
            loanApplicantEmployment.EmployerName = loanApplicantEmployment.Name + ' Bar';
            loanApplicantEmployment.JobTitle = loanApplicantEmployment.Name + ' Bar';

        }
        update loanApplicantEmploymentsToInsert;
        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = true AND Type__c = 'Gambling Income'].size(), 'Number of Flags created are not as expected');

    }
}
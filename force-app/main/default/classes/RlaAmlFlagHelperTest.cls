@istest
private class RlaAmlFlagHelperTest {
    static Integer COUNT = 30;
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

        List<LoanApplicationProperty> loanApplicationPropertiesToInsert = new List<LoanApplicationProperty>();
        for ( Integer i = 0; i < COUNT; i++ ) {
            loanApplicationPropertiesToInsert.addAll( TestDataFactory.createRegularLoanApplicationProperty(residentialLoanApplicationsToInsert[i].Id, 1, false ) );
        }
        insert loanApplicationPropertiesToInsert;

        List<Downpayment__c> downpaymentsToInsert = new List<Downpayment__c>();
        for ( Integer i = 0; i < COUNT; i++ ) {
            downpaymentsToInsert.addAll(TestDataFactory.createDownpayment(loanApplicationPropertiesToInsert[i].Id, 1, false));
        }
        insert downpaymentsToInsert;
    }

    @isTest
    private static void testCreationOfFlag(){
        List<ResidentialLoanApplication> rlasToUpdate = new List<ResidentialLoanApplication>();
        for ( ResidentialLoanApplication rla : [SELECT Id, Status,LTV__c  FROM ResidentialLoanApplication]) {
            rla.Status = ApexConstants.LEAD_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS;
            rla.LTV__c = 50;
            rlasToUpdate.add( rla );
        }

        update rlasToUpdate;

        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = false].size(), 'Number of Flags created are not as expected');
        rlasToUpdate = new List<ResidentialLoanApplication>();
        for ( ResidentialLoanApplication rla : [SELECT Id, Status,LTV__c, Loan_Amount__c FROM ResidentialLoanApplication]) {
            rla.Loan_Amount__c = 9000;
            rlasToUpdate.add( rla );
        }
        SObjectDomain.getTriggerEvent(ResidentialLoanApplications.class).disableAll();
            update rlasToUpdate;
        SObjectDomain.getTriggerEvent(ResidentialLoanApplications.class).enableAll();
        rlasToUpdate = new List<ResidentialLoanApplication>();
        for ( ResidentialLoanApplication rla : [SELECT Id, Status,LTV__c  FROM ResidentialLoanApplication]) {
            rla.Status = ApexConstants.SENT_COMMITMENT_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS;
            rla.LTV__c = 50;
            rlasToUpdate.add( rla );
        }

        update rlasToUpdate;

        Assert.areEqual(0, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = false].size(), 'Number of Flags created are not as expected');
        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = true].size(), 'Number of Flags created are not as expected');
    }
}
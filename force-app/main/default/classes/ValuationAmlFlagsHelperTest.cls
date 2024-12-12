@isTest
private class ValuationAmlFlagsHelperTest {
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

        List<LoanApplicationProperty> loanApplicationPropertiesToInsert = new List<LoanApplicationProperty>();
        for ( Integer i = 0; i < COUNT; i++ ) {
            LoanApplicationProperty loanApplicationProperty = TestDataFactory.createRegularLoanApplicationProperty(residentialLoanApplicationsToInsert[i].Id, false );
            loanApplicationProperty.Construction_Type__c = 'Existing';
            loanApplicationPropertiesToInsert.add( loanApplicationProperty );
        }
        insert loanApplicationPropertiesToInsert;


        List<Valuation__c> valuationsToInsert = new List<Valuation__c>();
        for ( Integer i = 0; i < COUNT; i++ ) {
            valuationsToInsert.addAll(TestDataFactory.createAppraisedValueValuation(loanApplicationPropertiesToInsert[i].Id, 1, false));
            valuationsToInsert.addAll(TestDataFactory.createPurchaseValueValuation(loanApplicationPropertiesToInsert[i].Id, 1, false));
        }
        insert valuationsToInsert;
    }

    @isTest
    private static void testFlagsWithValuations(){
        List<LoanApplicationProperty> loanApplicationPropertiesToInsert = [SELECT Id, Purchase_Price__c FROM LoanApplicationProperty];
        List<Valuation__c> valuationsToInsert = [SELECT Id,Loan_Application_Property__c FROM Valuation__c WHERE Valuation_Source__c =: ApexConstants.APPRAISED_VALUE_SOURCE ];

        for ( Valuation__c valuation : valuationsToInsert ) {
            valuation.Valuation_Amount__c = 5000;
        }

        update valuationsToInsert;
        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = false AND Type__c = 'Purchase Price'].size(), 'Number of Flags created are not as expected');

        for ( Valuation__c valuation : valuationsToInsert ) {
            valuation.Valuation_Amount__c = 12000;
        }

        update valuationsToInsert;
        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = true AND Type__c = 'Purchase Price'].size(), 'Number of Flags resolved are not as expected');
    }

    @isTest
    private static void testFlagsWithOutValuations(){
        List<Valuation__c> valuationsToInsert = [SELECT Id, Loan_Application_Property__c FROM Valuation__c WHERE  Valuation_Source__c =: ApexConstants.APPRAISED_VALUE_SOURCE];
        for ( Valuation__c valuation : valuationsToInsert ) {
            valuation.Valuation_Amount__c = 5000;
        }

        update valuationsToInsert;
        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = false AND Type__c = 'Purchase Price'].size(), 'Number of Flags created are not as expected');

        List<Valuation__c> valuations = [SELECT Id FROM Valuation__c];
        delete valuations;
        Assert.areEqual(COUNT, [SELECT Id FROM Aml_Flag__c WHERE Resolved__c = true AND Type__c = 'Purchase Price'].size(), 'Number of Flags resolved are not as expected');
    }
}
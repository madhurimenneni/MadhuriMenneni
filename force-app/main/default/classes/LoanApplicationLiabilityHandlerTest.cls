@isTest
private class LoanApplicationLiabilityHandlerTest {
	@testSetup static void setupData() {
        List<Apex_static_components__c> constantsList = TestDataFactory.createConstant(true);
        Id recordTypeId = Utils.getRecordTypeId( Utils.ACCOUNT_OBJECT_TYPE, Utils.BROKERAGE_ACCOUNT_RECORD_TYPE_NAME );
        Account acc = new Account(OwnerId = UserInfo.getUserId(), Name = 'Neighbourhood Holdings', RecordTypeId = recordTypeId); 
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.id, Email = 'test_1@gmail.com' );
        insert con;
        test.startTest();
        SObjectDomain.getTriggerEvent(ResidentialLoanApplications.class).disableAll();
        List<ResidentialLoanApplication> loanApp = TestDataFactory.createResidentialLoanApplications(acc.Id, 1, false);
        loanApp[0].Contact__c = con.Id;
        insert loanApp;

        SObjectDomain.getTriggerEvent(ResidentialLoanApplications.class).enableAll();
        List<LoanApplicationProperty> loanApplicationProperty = TestDataFactory.createRegularLoanApplicationProperty(loanApp[0].Id, 1, true);
        List<LoanApplicant> loanApplicant = TestDataFactory.createRegularLoanApplicant(loanApp[0].Id, 1, true);
        test.stopTest();
      //  List<LoanApplicationLiability> loanApplicationLiability = TestDataFactory.createLoanApplicantionLiability(loanApp[0].Id, loanApplicationProperty[0].Id, 1, true);
    }
    
    @isTest static void calculateLTVAndcLTVTest() {
        ResidentialLoanApplication residentialLoanApp = [SELECT Id, AccountId, Contact__c, Status FROM ResidentialLoanApplication WHERE Account.Name = 'Neighbourhood Holdings' LIMIT 1];
        LoanApplicant loanApp = [SELECT Id, Name FROM LoanApplicant WHERE LoanApplicationId =: residentialLoanApp.Id];
        LoanApplicationProperty loanAppProperty = [SELECT Id FROM LoanApplicationProperty WHERE LoanApplicationId =: residentialLoanApp.Id];
        LoanApplicationLiability lal = new LoanApplicationLiability();
        lal.Name = 'Test Liability';
        lal.Liability_Type__c = 'Mortgage';
        lal.Liability_Status__c = 'New';
        lal.Balance__c = 430051;
        lal.Monthly_Payment__c = 2198;
        lal.Payoff__c = 'No';
        lal.LoanApplicationId = residentialLoanApp.Id;
        lal.Loan_Applicant__c = loanApp.Id;
        lal.Position__c = '1';
        lal.Loan_Application_Property__c = loanAppProperty.Id;
        test.startTest();
        insert lal;
        test.stopTest();
        LoanApplicationLiability lAppLiability = [SELECT Id, LTV__c FROM LoanApplicationLiability WHERE Id =: lal.Id];
        system.AssertEquals(200.00, lAppLiability.LTV__c);
    }
    
    @isTest static void calculateSumOfLiabilitiesPaidFromProceedsTest(){
        ResidentialLoanApplication residentialLoanApp = [SELECT Id, Contact__c, Status FROM ResidentialLoanApplication ];
        LoanApplicant loanApp = [SELECT Id, Name FROM LoanApplicant WHERE LoanApplicationId =: residentialLoanApp.Id];
        LoanApplicationProperty loanApplicationProperty = [SELECT Id, Name FROM  LoanApplicationProperty WHERE LoanApplicationId =: residentialLoanApp.Id];
        LoanApplicationLiability lal = new LoanApplicationLiability();
        lal.Name = 'Test Liability';
        lal.Liability_Type__c = 'Mortgage';
        lal.Liability_Status__c = 'New';
        lal.Balance__c = 430051;
        lal.Monthly_Payment__c = 2198;
        lal.Payoff__c = 'No';
        lal.LoanApplicationId = residentialLoanApp.Id;
        lal.Loan_Applicant__c = loanApp.Id;
        lal.Position__c = '1';
        lal.Loan_Application_Property__c = loanApplicationProperty.Id;
        test.startTest();
        insert lal;
        
        
        LoanApplicationLiability liability = [SELECT Id, Payoff__c, Liability_Status__c FROM LoanApplicationLiability WHERE Id =: lal.Id];
        liability.Payoff__c = ApexConstants.PAY_FROM_PROCEEDS_PAYOFF;
        liability.Liability_Status__c = ApexConstants.EXISTING_LIABILITY_STATUS;
        SObjectDomain.getTriggerEvent(LoanApplicationLiabilities.class).disableAll();
        update liability;
        SObjectDomain.getTriggerEvent(LoanApplicationLiabilities.class).enableAll();
        test.stopTest();
        delete liability;
        liability = [SELECT Id FROM LoanApplicationLiability ALL ROWS];
        undelete liability;
    }

    @isTest static void calculateTotalLiabilitiesMonthlyPaymentTest(){
        ResidentialLoanApplication residentialLoanApp = [SELECT Id, Contact__c, Status FROM ResidentialLoanApplication ];
        LoanApplicant loanApp = [SELECT Id, Name FROM LoanApplicant WHERE LoanApplicationId =: residentialLoanApp.Id];
        LoanApplicationProperty loanApplicationProperty = [SELECT Id, Name FROM  LoanApplicationProperty WHERE LoanApplicationId =: residentialLoanApp.Id];
        LoanApplicationLiability lal = new LoanApplicationLiability();
        lal.Name = 'Test Liability';
        lal.Liability_Type__c = 'Mortgage';
        lal.Liability_Status__c = 'New';
        lal.Balance__c = 430051;
        lal.Monthly_Payment__c = 2198;
        lal.Payoff__c = 'No';
        lal.LoanApplicationId = residentialLoanApp.Id;
        lal.Loan_Applicant__c = loanApp.Id;
        lal.Position__c = '1';
        lal.Loan_Application_Property__c = loanApplicationProperty.Id;
        test.startTest();
        insert lal;
        
        
        LoanApplicationLiability liability = [SELECT Id, Payoff__c, Liability_Status__c FROM LoanApplicationLiability WHERE Id =: lal.Id];
        lal.Balance__c = 430052;
        lal.Monthly_Payment__c = 2199;
        update liability;
        test.stopTest();
        delete liability;
        liability = [SELECT Id FROM LoanApplicationLiability ALL ROWS];
        undelete liability;
    }
}
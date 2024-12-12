@isTest
private class ResidentialLoanApplicationControllerTest {
	@testSetup static void setupData() {  
        List<Apex_static_components__c> constantsList = TestDataFactory.createConstant(true);
        Id recordTypeId = Utils.getRecordTypeId( Utils.ACCOUNT_OBJECT_TYPE, Utils.BROKERAGE_ACCOUNT_RECORD_TYPE_NAME );
        Account acc = new Account(OwnerId = UserInfo.getUserId(), Name = 'Neighbourhood Holdings', RecordTypeId = recordTypeId); 
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.id, Email = 'test_1@gmail.com' );
        insert con;
        
    }
    
    @isTest static void getResidentialLoanApplicationTest(){
        string residentialLoanApplicationJSON = '';
        Account brokerageAcc = new Account( Name = 'Brightpath Capital' );
        insert brokerageAcc;
        Account acc = [SELECT Id FROM Account WHERE Name =: 'Neighbourhood Holdings' LIMIT 1];
        List<ResidentialLoanApplication> loanApp = TestDataFactory.createResidentialLoanApplications(acc.Id, 1, true);
        List<LoanApplicant> loanApplicant = TestDataFactory.createCorporateLoanApplicant(loanApp[0].Id, 1, true);
        List<LoanApplicationProperty> loanApplicationProperty = TestDataFactory.createRegularLoanApplicationProperty(loanApp[0].Id, 1, true);
        Update new ResidentialLoanApplication( Id = loanApp[0].Id, 
                                              Brokerage__c = brokerageAcc.Id,
                                              Interest_Adjustment_Date__c = Date.Today(),
                                              ASAP__c = true,
                                              Close_Date__c = Date.today(),
                                              Loan_Purpose__c = 'Purchase');
        test.startTest();
        residentialLoanApplicationJSON = ResidentialLoanApplicationController.getResidentialLoanApplication(loanApp[0].Id);
        ResidentialLoanApplicationController.getLoanApplicationProperty(loanApp[0].Id);
        test.stopTest();
        ResidentialLoanApplicationController.ResidentialLoanApplicationWrapper result = (ResidentialLoanApplicationController.ResidentialLoanApplicationWrapper) JSON.deserialize(residentialLoanApplicationJSON, ResidentialLoanApplicationController.ResidentialLoanApplicationWrapper.class);
        system.debug('result: ' + result);
        system.assertEquals('positive', result.shortfallOrOverageSign);
     /*   List<LoanApplicationProperty> loanApplicationProperty = TestDataFactory.createRegularLoanApplicationProperty(loanApp[0].Id, 1, true);
        
        TestDataFactory.createLoanApplicantEmployments(loanApp[0].Id, loanApplicant[0].Id, 1, true);
        TestDataFactory.createLoanApplicantIncome(loanApp[0].Id, loanApplicant[0].Id, 1, true);
        TestDataFactory.createDownpayment(loanApplicationProperty[0].Id, 1, true);
        ResidentialLoanApplicationController.getResidentialLoanApplication( loanApp[0].Id );
        ResidentialLoanApplicationController.getLoanApplicationProperty( loanApp[0].Id ); */
    }
    @isTest static void getLoanApplicationPropertyTest(){
        string loanApplicationPropertyJSON = '';
        Account brokerageAcc = new Account( Name = 'Brightpath Capital' );
        insert brokerageAcc;
        Account acc = [SELECT Id FROM Account WHERE Name =: 'Neighbourhood Holdings' LIMIT 1];
        List<ResidentialLoanApplication> loanApp = TestDataFactory.createResidentialLoanApplications(acc.Id, 1, true);
        List<LoanApplicant> loanApplicant = TestDataFactory.createCorporateLoanApplicant(loanApp[0].Id, 1, true);
        List<LoanApplicationProperty> loanApplicationProperty = TestDataFactory.createRegularLoanApplicationProperty(loanApp[0].Id, 1, true);
        loanApplicationProperty[0].Property_Type__c = 'Subject Property';
        loanApplicationProperty[0].Title_Type__c = 'Strata';
        update loanApplicationProperty[0];
        
        Update new ResidentialLoanApplication( Id = loanApp[0].Id, 
                                              Brokerage__c = brokerageAcc.Id,
                                              Interest_Adjustment_Date__c = Date.Today(),
                                              ASAP__c = true,
                                              Close_Date__c = Date.today(),
                                              Loan_Purpose__c = 'Purchase');
        test.startTest();
        loanApplicationPropertyJSON = ResidentialLoanApplicationController.getLoanApplicationProperty(loanApp[0].Id);
        test.stopTest();
        ResidentialLoanApplicationController.LoanApplicationPropertyWrapper result = (ResidentialLoanApplicationController.LoanApplicationPropertyWrapper) JSON.deserialize(loanApplicationPropertyJSON, ResidentialLoanApplicationController.LoanApplicationPropertyWrapper.class);
        system.debug('result: ' + result);
       // system.assertEquals('positive', result.shortfallOrOverageSign);
    }
}
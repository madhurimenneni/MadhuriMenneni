@isTest
private class LoanApplicantHandlerTest {
    @testSetup static void setupData() {
        List<Apex_static_components__c> constantsList = TestDataFactory.createConstant(true);
        Id recordTypeId = Utils.getRecordTypeId( Utils.ACCOUNT_OBJECT_TYPE, Utils.BROKERAGE_ACCOUNT_RECORD_TYPE_NAME );
        Account acc = new Account(OwnerId = UserInfo.getUserId(), Name = 'Neighbourhood Holdings', RecordTypeId = recordTypeId); 
        insert acc;
        Contact contact = new Contact();
        contact.LastName = 'Test Contact';
        contact.AccountId = acc.id;
        contact.Email = 'test_1@gmail.com';
        contact.Submitted_Lifetime__c = 0;
        contact.In_Progress__c = 0;
        contact.Volume_Submitted_Lifetime__c = 0;
        contact.Volume_Funded__c = 0;
        contact.Funded__c = 0;
        contact.Of_Applications_In_12_Months__c = 0;
        contact.Volume_submitted_in_12_months__c = 0;
        contact.Complete_Funded_in_last_12_months__c = 0;
        contact.Volume_Funded_in_12_Months__c = 0;
        contact.Of_Applications_In_24_Months__c = 0;
        contact.Complete_in_last_24_months__c = 0;
        contact.cancelled__c = 0;
        contact.Declined_Lifetime__c = 0;
        contact.Submitted_This_Year__c = 0;
        contact.Submitted_Last_Year__c = 0;
        contact.Completed_This_Year__c = 0;
        contact.Completed_Last_Year__c = 0;
        insert contact;
        
        List<ResidentialLoanApplication> loanApp = TestDataFactory.createResidentialLoanApplications(acc.Id, 1, false);
        loanApp[0].Contact__c = contact.Id;
        insert loanApp;

        List<LoanApplicant> loanApplicant = TestDataFactory.createRegularLoanApplicant(loanApp[0].Id, 1, true);
        List<LoanApplicationProperty> loanApplicationProperty = TestDataFactory.createRegularLoanApplicationProperty(loanApp[0].Id, 1, true);
        test.startTest();
        TestDataFactory.createLoanApplicationAssets(loanApp[0].Id, 1, true);
        TestDataFactory.createLoanApplicantionLiability(loanApp[0].Id, loanApplicationProperty[0].Id, 1, true);
        test.stopTest();
    }
    
    @isTest static void validateLoanApplicantTest(){
        ResidentialLoanApplication loanApp = [SELECT Id, Contact__c, Status FROM ResidentialLoanApplication ];
        Boolean exceptionThrown = false;
        try{
            TestDataFactory.createRegularLoanApplicant(loanApp.Id, 1, true);
        } catch ( Exception e ) { 
            exceptionThrown = true;
            Boolean expectedExceptionThrown =  (e.getMessage().contains('There is already a Loan Applicant as Primary')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage());
        }
        
        try{
            TestDataFactory.createCorporateLoanApplicant(loanApp.Id, 1, true);
        } catch ( Exception e ) { 
            exceptionThrown = true;
            Boolean expectedExceptionThrown =  (e.getMessage().contains('Please fix other Loan Applicants as Co-Applicant/Guarantor')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage());
        }
    }
    
    @isTest static void lockLoanApplicantTest(){
        Residential_Loan_App_Trigger_Switch__c loanAppValidation = new Residential_Loan_App_Trigger_Switch__c( 
            B_U_Resedential_Loan_App_Validation__c = true);
        insert loanAppValidation;
        ResidentialLoanApplication loanApp = [SELECT Id, Contact__c, Status FROM ResidentialLoanApplication WHERE Account.Name = 'Neighbourhood Holdings'];
        Boolean exceptionThrown = false;
        try{
            test.startTest();
            loanApp.Status = ApexConstants.COMPLETE_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS;
            update loanApp;
            LoanApplicant loanApplicant = [SELECT Id, Name, LoanApplicationId FROM LoanApplicant WHERE LoanApplicationId =: loanApp.Id];
            loanApplicant.Name = 'Edit loan Applicant';
            update loanApplicant ;
            test.stopTest();
        } catch ( Exception e ) { 
            exceptionThrown = true;
            Boolean expectedExceptionThrown =  (e.getMessage().contains('You cannot edit this record as its related Application is Complete')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage());
        }
    }
    
    @isTest static void validateSinNumberTest(){
        LoanApplicant loanApplicant = [SELECT Id, Name, Sin__c FROM LoanApplicant ];
        test.startTest();
        update new loanApplicant( Id = loanApplicant.Id, Sin__c = '1234' );
        test.stopTest();
    }
    
    @isTest static void updateLoanApplicantFieldsTest(){
        LoanApplicant loanApplicant = [SELECT Id, Name, Applicant_Type__c FROM LoanApplicant WHERE Applicant_Type__c =: ApexConstants.PRIMARY_APPLICANT_TYPE];
        ResidentialLoanApplication loanApp = [SELECT Id, Primary_Applicant__c FROM ResidentialLoanApplication ];
        
        system.assertEquals(loanApplicant.Id, loanApp.Primary_Applicant__c, 'Primary applicant is not matching');
        
        LoanApplicationProperty loanApplicationProperty = [SELECT Id, Primary_Applicant__c FROM LoanApplicationProperty WHERE LoanApplicationId =: loanApp.Id];
        system.assertEquals(loanApplicant.Id, loanApplicationProperty.Primary_Applicant__c, 'Primary applicant is not matching');
        
        LoanApplicationAsset loanApplicationAsset = [SELECT Id, Primary_Applicant__c FROM LoanApplicationAsset WHERE LoanApplicationId =: loanApp.Id];
        system.assertEquals(loanApplicant.Id, loanApplicationAsset.Primary_Applicant__c, 'Primary applicant is not matching');
        
        LoanApplicationLiability LoanApplicationLiability = [SELECT Id, Primary_Applicant__c FROM LoanApplicationLiability WHERE LoanApplicationId =: loanApp.Id];
        system.assertEquals(loanApplicant.Id, LoanApplicationLiability.Primary_Applicant__c, 'Primary applicant is not matching');
        test.startTest();
        update new loanApplicant(Id = loanApplicant.Id, Applicant_Type__c = ApexConstants.GUARANTOR_APPLICANT_TYPE);
        test.stopTest();
        loanApp = [SELECT Id, Primary_Applicant__c FROM ResidentialLoanApplication ];
        
        system.assertEquals(null, loanApp.Primary_Applicant__c, 'Primary applicant is not matching');
    }
    @isTest static void updateApplicantAndBorrowerAndGuarantorsTest(){
        List<ResidentialLoanApplication> appRLA = [SELECT Id, Primary_Applicant__c FROM ResidentialLoanApplication WHERE Account.Name = 'Neighbourhood Holdings' LIMIT 1];
        LoanApplicant la = [SELECT Id, First_Name__c, Last_Name__c, Middle_Name__c FROM LoanApplicant WHERE LoanApplicationId =: appRLA[0].Id];
        la.Last_Name__c = 'Regular Loan Applicant One';
        List<LoanApplicant> loanApplicantsToBeInserted = new List<LoanApplicant>();
        
        LoanApplicant coBorrowerLoanAppOne = new LoanApplicant();
        coBorrowerLoanAppOne.Last_Name__c = 'Regular Loan Applicant Two';
        coBorrowerLoanAppOne.Name = 'Regular Loan Applicant Two';
        coBorrowerLoanAppOne.LoanApplicationId = appRLA[0].Id;
        coBorrowerLoanAppOne.RecordTypeId = Utils.regularLoanApplicantRecordTypeId;
        coBorrowerLoanAppOne.Applicant_Type__c = ApexConstants.CO_APPLICANT_TYPE;
      //  loanApplicantsToBeInserted.add(coBorrowerLoanAppOne);

        test.startTest();
        update la;
        insert coBorrowerLoanAppOne;
        test.stopTest();
        
        ResidentialLoanApplication rlaApp = [SELECT Id, Applicants__c, Borrowers__c, Guarantors__c FROM ResidentialLoanApplication WHERE Account.Name = 'Neighbourhood Holdings' LIMIT 1];
        system.assertEquals('Regular Loan Applicant One and Regular Loan Applicant Two', rlaApp.Applicants__c);
        system.assertEquals('Regular Loan Applicant One and Regular Loan Applicant Two', rlaApp.Borrowers__c);
        system.assertEquals(null, rlaApp.Guarantors__c);

    }
}
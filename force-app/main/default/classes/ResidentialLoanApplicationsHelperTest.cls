@istest
private class ResidentialLoanApplicationsHelperTest {
    @testSetup static void setupData() {  
        List<Apex_static_components__c> constantsList = TestDataFactory.createConstant(true);
        Id recordTypeId = Utils.getRecordTypeId( Utils.ACCOUNT_OBJECT_TYPE, Utils.BROKERAGE_ACCOUNT_RECORD_TYPE_NAME );
        Account acc = new Account(OwnerId = UserInfo.getUserId(), Name = 'Neighbourhood Holdings', RecordTypeId = recordTypeId); 
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.id, Email = 'test_1@gmail.com' );
        insert con;
        test.startTest();
        List<ResidentialLoanApplication> loanApp = TestDataFactory.createResidentialLoanApplications(acc.Id, 1, false);
        loanApp[0].Contact__c = con.Id;
        insert loanApp;
        List<LoanApplicationProperty> loanApplicationProperty = TestDataFactory.createRegularLoanApplicationProperty(loanApp[0].Id, 1, true);
        List<LoanApplicant> loanApplicant = TestDataFactory.createRegularLoanApplicant(loanApp[0].Id, 1, true);
        LoanApplicantAddress loanApplicantsAddress = TestDataFactory.createLoanApplicantAddress(loanApplicant[0].Id, true);
        test.stopTest();
       /* List<LoanApplicationLiability> loanApplicantsLiability = TestDataFactory.createLoanApplicantionLiability(loanApp[0].Id, loanApplicationProperty[0].Id, 1, true);
        List<LoanApplicationAsset> loanApplicantsAsset = TestDataFactory.createLoanApplicationAssets(loanApp[0].Id, 1, true);
        List<LoanApplicantEmployment> loanApplicantsEmployment = TestDataFactory.createLoanApplicantEmployments(loanApp[0].Id, loanApplicant[0].Id, 1, true);
        List<LoanApplicantIncome> loanApplicantsIncome = TestDataFactory.createLoanApplicantIncome(loanApp[0].Id, loanApplicant[0].Id, 1, true); */
    }

    @isTest static void updateBrokerKpisTest() {
        test.startTest();
        Contact con = [SELECT Id, AccountId, RFM_Total_Deals_in_Calculated_Month__c FROM Contact WHERE LastName =: 'Test Contact' LIMIT 1];
        ResidentialLoanApplication residentialLoanApps = new ResidentialLoanApplication();
        residentialLoanApps.Name = 'residentialLoanAppName';
        residentialLoanApps.Application_Type__c = ApexConstants.APPROVAL_APPLICATION_TYPE;
        residentialLoanApps.AccountId = con.AccountId;
        residentialLoanApps.contact__c = con.Id;
        residentialLoanApps.Lendesk_Creation_Date__c = DateTime.newInstance(2023, 2, 17, 0, 0, 0);
        residentialLoanApps.Loan_Amount__c = 20000;
        residentialLoanApps.Status = 'Complete';
        
        
        insert residentialLoanApps;
        
        
        Contact updatedCon = [SELECT Id, AccountId, RFM_Total_Deals_in_Calculated_Month__c FROM Contact WHERE LastName =: 'Test Contact' LIMIT 1];
        test.stopTest();
        system.assertEquals(1, updatedCon.RFM_Total_Deals_in_Calculated_Month__c);
    }
    
    @isTest static void leadResidentialLoanAppValidationTest() {
        test.startTest();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Neighbourhood Holdings' LIMIT 1];
        ResidentialLoanApplication loanApp = [ SELECT Id, Contact__c, Status FROM ResidentialLoanApplication WHERE AccountId =: acc.Id];
        
       // List<LoanApplicant> corporateLoanApp = TestDataFactory.createCorporateLoanApplicant(loanApp.Id, 1, true);
        
        LoanApplicationProperty loanApplicationProperty = [SELECT Id, Name, PropertyUseType, LoanApplicationId, Downpayment__c
                                                           FROM LoanApplicationProperty
                                                           WHERE LoanApplicationId =: loanApp.Id];
        
        system.debug(loanApplicationProperty.Downpayment__c);
        loanApplicationProperty.Title_Type__c = 'Strata';
        update loanApplicationProperty;
        
        loanApp.Status = ApexConstants.LEAD_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS;
        loanApp.Loan_Purpose__c = ApexConstants.PURCHASE_LOAN_PURPOSE;
        DmlException expectedException = null;
        try {
            update loanApp;
        }
        catch ( DmlException error ) { 
            expectedException = error;
        }
        test.stopTest();
    }
    
    @isTest static void sentCommittmentResidentialLoanAppValidationTest() {
        test.startTest();
        ResidentialLoanApplication loanApp = [SELECT Id, Contact__c, Status FROM ResidentialLoanApplication ];
        
        //TestDataFactory.createRegularLoanApplicant(loanApp.Id, 1, true);
        
        LoanApplicationProperty loanApplicationProperty = [SELECT Id,Name, PropertyUseType, LoanApplicationId, Downpayment__c
                                                           FROM LoanApplicationProperty
                                                           WHERE LoanApplicationId =: loanApp.Id];
   
        
        loanApp.Status = ApexConstants.SENT_COMMITMENT_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS;
        loanApp.Loan_Purpose__c = ApexConstants.PURCHASE_LOAN_PURPOSE;
        DmlException expectedException = null;
        try {
            update loanApp;
        }
        catch ( DmlException error ) { 
            expectedException = error;
            system.debug(expectedException.getMessage());
        }
        List<String> errorMessageList = new List<String>{'Down payment is blank','Missing Interest Adjustment Date'};
            for( String errorMsg : errorMessageList ){system.debug(expectedException.getMessage());
                Boolean expectedExceptionThrows = (expectedException.getMessage().Contains(errorMsg)) ? true : false;
                //System.assertEquals( true, expectedExceptionThrows, 'No error/Record saved' );
            }
        test.stopTest();
    }

   /* @isTest static void automationOnLeadAppStatusTest() {
        Residential_Loan_App_Trigger_Switch__c loanAppValidation = new Residential_Loan_App_Trigger_Switch__c( 
            B_U_Resedential_Loan_App_Validation__c = true);
        insert loanAppValidation;
        
        ResidentialLoanApplication loanApp = [ SELECT 
                                                    Id,
                                                    Contact__c,
                                                    Status
                                              FROM 
                                                    ResidentialLoanApplication ];
        update new ResidentialLoanApplication( Id = loanApp.Id, 
                                            Status = ApexConstants.LEAD_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS,
                                            Interest_Adjustment_Date__c = Date.Today(),
                                            Loan_Term_Months__c = 1 );
        loanApp = [ SELECT 
                            Id,
                            First_Payment_Date__c,
                            Maturity_Date__c
                    FROM 
                            ResidentialLoanApplication ];
        system.debug(loanApp);
    }*/

    @isTest static void ltvCalculatorTest() {
        test.starttest();
        Residential_Loan_App_Trigger_Switch__c loanAppValidation = new Residential_Loan_App_Trigger_Switch__c( 
            B_U_Resedential_Loan_App_Validation__c = true);
        insert loanAppValidation;
        ResidentialLoanApplication loanApp = [SELECT Id, Status FROM ResidentialLoanApplication ];
        /*TestDataFactory.createRegularLoanApplicationProperty(loanApp.Id, 1, true);
        List<LoanApplicationProperty> loanApplicationProperty = [ SELECT 
                                                                            Id,
                                                                            Name,
                                                                            PropertyUseType,
                                                                                LoanApplicationId,
                                                                            Downpayment__c
                                                                    FROM 
                                                                            LoanApplicationProperty
                                                                    WHERE
                                                                            LoanApplicationId =: loanApp.Id];
        TestDataFactory.createAppraisedValueValuation(loanApplicationProperty[0].Id, 1, true);
        TestDataFactory.createAppraisedValueValuation(loanApplicationProperty[1].Id, 1, true);
        TestDataFactory.createLoanApplicantionLiability(loanApp.Id, loanApplicationProperty[0].Id, 1, true);*/
        update new ResidentialLoanApplication( Id = loanApp.Id, Status = ApexConstants.LEAD_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS, EstateHoldType = 'First');
        test.stoptest();
    }
    
    @isTest static void DeleteFailedApplicationsTest(){
        test.startTest();
        ResidentialLoanApplication loanApp = [ SELECT Id, Status FROM ResidentialLoanApplication ];
        update new ResidentialLoanApplication( Id = loanApp.Id, Status = ApexConstants.FAILED_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS);
        test.stopTest();
        Set<Id> loanAppIdSet = new Set<Id>{loanApp.Id};
        Id jobID = System.enqueueJob( new ResidentialLoanApplicationQueueable( loanAppIdSet, 'failedApps' ) );
        
    }
}
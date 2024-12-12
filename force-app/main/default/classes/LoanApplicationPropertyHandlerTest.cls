@isTest
private class LoanApplicationPropertyHandlerTest {
    @testSetup static void setupData() {  
        List<Apex_static_components__c> constantsList = TestDataFactory.createConstant(true);
        Id recordTypeId = Utils.getRecordTypeId( Utils.ACCOUNT_OBJECT_TYPE, Utils.BROKERAGE_ACCOUNT_RECORD_TYPE_NAME );
        Account acc = new Account(OwnerId = UserInfo.getUserId(), 
                                  Name = 'Neighbourhood Holdings',
                                  RecordTypeId = recordTypeId); 
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.id, Email = 'test_1@gmail.com' );
        insert con;
        List<ResidentialLoanApplication> loanApp = TestDataFactory.createResidentialLoanApplications(acc.Id, 1, false);
        loanApp[0].Contact__c = con.Id;
        insert loanApp;
        
        List<LoanApplicationProperty> loanApplicationProperty = TestDataFactory.createRegularLoanApplicationProperty(loanApp[0].Id, 1, true);
    }
    
    
    
    @isTest static void lockLoanApplicantionPropertyTest(){
        Residential_Loan_App_Trigger_Switch__c loanAppValidation = new Residential_Loan_App_Trigger_Switch__c( 
            B_U_Resedential_Loan_App_Validation__c = true);
        test.startTest();
        insert loanAppValidation;
        ResidentialLoanApplication loanApp = [SELECT Id, Contact__c, Status FROM ResidentialLoanApplication];
        update new ResidentialLoanApplication(Id = loanApp.Id, Status = ApexConstants.COMPLETE_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS);
        LoanApplicationProperty prop = [ SELECT Id, Name FROM LoanApplicationProperty ];
        
        Boolean exceptionThrown = false;
        try{ 
            update new LoanApplicationProperty( Id = prop.Id, Name = 'Edit loan App property' );
        } catch ( Exception e ) { 
            exceptionThrown = true;
            Boolean expectedExceptionThrown =  (e.getMessage().contains('You can not edit this record as its related Application is Complete')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage());
        }
        test.stopTest();
    }
    
    @isTest static void deleteUndeletePropTest() {
        Residential_Loan_App_Trigger_Switch__c loanAppValidation = new Residential_Loan_App_Trigger_Switch__c( 
            B_U_Resedential_Loan_App_Validation__c = true);
        test.startTest();
        insert loanAppValidation;
        LoanApplicationProperty prop = [SELECT Id, Name FROM LoanApplicationProperty];
        delete prop;
        prop = [SELECT Id, Name FROM LoanApplicationProperty ALL ROWS];
        undelete prop;
        ResidentialLoanApplication loanApp = [SELECT Id, Contact__c, Status FROM ResidentialLoanApplication];   
        test.stopTest();
    }
    
    @isTest static void validateLoanApplicationPropertyTest() {
        Residential_Loan_App_Trigger_Switch__c loanAppValidation = new Residential_Loan_App_Trigger_Switch__c( 
            B_U_Resedential_Loan_App_Validation__c = true);
        test.startTest();
        insert loanAppValidation;
        LoanApplicationProperty prop = [SELECT Id, Name, Collateral_Position__c FROM LoanApplicationProperty];
        ResidentialLoanApplication loanApp = [SELECT Id, Contact__c, Status FROM ResidentialLoanApplication];
        TestDataFactory.createLoanApplicantionLiability(loanApp.Id, prop.Id, 1, true); 
        Boolean exceptionThrown = false;
        try{ 
            update new LoanApplicationProperty( Id = prop.Id, Collateral_Position__c = '1' );
        } catch ( Exception e ) { 
            exceptionThrown = true;
        }
        test.stopTest();
    }
    
    @isTest static void validateLoanApplicationPropertyTest2() {
        Residential_Loan_App_Trigger_Switch__c loanAppValidation = new Residential_Loan_App_Trigger_Switch__c( 
            B_U_Resedential_Loan_App_Validation__c = true);
        test.startTest();
        insert loanAppValidation;
        LoanApplicationProperty prop = [SELECT Id, Name, Collateral_Position__c FROM LoanApplicationProperty ];
        ResidentialLoanApplication loanApp = [SELECT Id, Contact__c, Status FROM ResidentialLoanApplication ];
        List<LoanApplicationLiability> liabillity = TestDataFactory.createLoanApplicantionLiability(loanApp.Id, prop.Id, 1, true); 
        update new LoanApplicationLiability( Id = liabillity[0].Id, 
                                            Payoff__c = ApexConstants.PAY_FROM_PROCEEDS_PAYOFF,
                                            Liability_Status__c = ApexConstants.EXISTING_LIABILITY_STATUS);
        Boolean exceptionThrown = false;
        try{ 
            update new LoanApplicationProperty(Id = prop.Id, Collateral_Position__c = '3');
        } catch ( Exception e ) { 
            exceptionThrown = true;
        }
        test.stopTest();
    }
    
    @isTest static void validateLoanApplicationPropertyTest3() {
        Residential_Loan_App_Trigger_Switch__c loanAppValidation = new Residential_Loan_App_Trigger_Switch__c(B_U_Resedential_Loan_App_Validation__c = true);
        test.startTest();
        insert loanAppValidation;
        LoanApplicationProperty prop = [SELECT Id, Name, Collateral_Position__c FROM LoanApplicationProperty];
        ResidentialLoanApplication loanApp = [SELECT Id, Contact__c, Status FROM ResidentialLoanApplication];
        List<LoanApplicationLiability> liabillity = TestDataFactory.createLoanApplicantionLiability(loanApp.Id, prop.Id, 1, true); 
        update new LoanApplicationLiability( Id = liabillity[0].Id, 
                                            Position__c = '2',
                                            Payoff__c = ApexConstants.PAY_FROM_PROCEEDS_PAYOFF,
                                            Liability_Status__c = ApexConstants.EXISTING_LIABILITY_STATUS);
        Boolean exceptionThrown = false;
        try{ 
            update new LoanApplicationProperty(Id = prop.Id, Collateral_Position__c = '3');
        } catch ( Exception e ) { 
            exceptionThrown = true;
        }
        test.stopTest();
    }
    
    @isTest static void validateLoanApplicationPropertyTest4() {
        Residential_Loan_App_Trigger_Switch__c loanAppValidation = new Residential_Loan_App_Trigger_Switch__c( 
            B_U_Resedential_Loan_App_Validation__c = true);
        test.startTest();
        insert loanAppValidation;
        LoanApplicationProperty prop = [SELECT Id, Name, Collateral_Position__c FROM LoanApplicationProperty ];
        ResidentialLoanApplication loanApp = [SELECT Id, Contact__c, Status FROM ResidentialLoanApplication ];
        List<LoanApplicationLiability> liabillity = TestDataFactory.createLoanApplicantionLiability(loanApp.Id, prop.Id, 1, true); 
        update new LoanApplicationLiability( Id = liabillity[0].Id, 
                                            Position__c = '3',
                                            Payoff__c = ApexConstants.PAY_FROM_PROCEEDS_PAYOFF,
                                            Liability_Status__c = ApexConstants.EXISTING_LIABILITY_STATUS);
        Boolean exceptionThrown = false;
        try{ 
            update new LoanApplicationProperty( Id = prop.Id, Collateral_Position__c = '3' );
        } catch ( Exception e ) { 
            exceptionThrown = true;
        }
        test.stopTest();
    }
    
    @isTest static void validateLoanApplicationPropertyTest5() {
        Residential_Loan_App_Trigger_Switch__c loanAppValidation = new Residential_Loan_App_Trigger_Switch__c( 
            B_U_Resedential_Loan_App_Validation__c = true);
        test.startTest();
        insert loanAppValidation;
        LoanApplicationProperty prop = [SELECT Id, Name, Collateral_Position__c FROM LoanApplicationProperty ];
        ResidentialLoanApplication loanApp = [SELECT Id, Contact__c, Status FROM ResidentialLoanApplication ];
        List<LoanApplicationLiability> liabillity = TestDataFactory.createLoanApplicantionLiability(loanApp.Id, prop.Id, 3, true); 
        List<LoanApplicationLiability> liabillityList = new List<LoanApplicationLiability>();
        for( LoanApplicationLiability l : liabillity ){
            l.Position__c = '3';
            l.Payoff__c = ApexConstants.PAY_FROM_PROCEEDS_PAYOFF;
            l.Liability_Status__c = ApexConstants.EXISTING_LIABILITY_STATUS;
            liabillityList.add(l);
        }
        update liabillityList;
        Boolean exceptionThrown = false;
        try{ 
            update new LoanApplicationProperty( Id = prop.Id, Collateral_Position__c = '1' );
        } catch ( Exception e ) { 
            exceptionThrown = true;
        }
        test.stopTest();
    } 
    @isTest static void fieldLoanPurposeUpdateTest(){
        ResidentialLoanApplication rla = [SELECT Id, Contact__c, Status FROM ResidentialLoanApplication WHERE Account.Name = 'Neighbourhood Holdings'];
        LoanApplicationProperty loanAppProp = [SELECT Id, Loan_Purpose__c FROM LoanApplicationProperty WHERE LoanApplicationId =: rla.Id];
        loanAppProp.Loan_Purpose__c = 'Refinance';
        test.startTest();
        update loanAppProp;
        test.stopTest();
        ResidentialLoanApplication rlapp = [SELECT Id, Loan_Purpose__c FROM ResidentialLoanApplication WHERE Id =: rla.Id];
        system.assertEquals('Refinance', rlapp.Loan_Purpose__c);
    }
    
    @isTest static void fieldLoanPurposeUpdateTwoTest(){
        ResidentialLoanApplication rla = [SELECT Id, Contact__c, Status FROM ResidentialLoanApplication WHERE Account.Name = 'Neighbourhood Holdings'];
        LoanApplicationProperty loanAppProp = [SELECT Id, Loan_Purpose__c FROM LoanApplicationProperty WHERE LoanApplicationId =: rla.Id];
        loanAppProp.Loan_Purpose__c = 'Purchase';
        test.startTest();
        update loanAppProp;
        test.stopTest();
        ResidentialLoanApplication rlapp = [SELECT Id, Loan_Purpose__c FROM ResidentialLoanApplication WHERE Id =: rla.Id];
        system.assertEquals('Purchase', rlapp.Loan_Purpose__c);
    }
    
    @isTest static void fieldLoanPurposeUpdateThreeTest(){
        ResidentialLoanApplication rla = [SELECT Id, Contact__c, Status FROM ResidentialLoanApplication WHERE Account.Name = 'Neighbourhood Holdings'];
        List<LoanApplicationProperty> loanAppPropList = new List<LoanApplicationProperty>();
        LoanApplicationProperty purchaseLoanAppProp = new LoanApplicationProperty();
        purchaseLoanAppProp.Name = 'Regular Loan Applicantion Property Purchase';
        purchaseLoanAppProp.LoanApplicationId = rla.Id;
        purchaseLoanAppProp.Property_Type__c = ApexConstants.SUBJECT_PROPERTY_TYPE;
        purchaseLoanAppProp.PropertyState = 'ON';
        purchaseLoanAppProp.PropertyUseType = ApexConstants.PRIMART_RESIDENCE_OCCUPANCY_TYPE;
        purchaseLoanAppProp.Collateral_Position__c = '1';
        purchaseLoanAppProp.Property_value__c = 10000;
        purchaseLoanAppProp.Purchase_Price__c = 100;
        purchaseLoanAppProp.Loan_Purpose__c = 'Purchase';
        loanAppPropList.add(purchaseLoanAppProp);
        
        LoanApplicationProperty refinanceLoanAppProp = new LoanApplicationProperty();
        refinanceLoanAppProp.Name = 'Regular Loan Applicantion Property Refinance';
        refinanceLoanAppProp.LoanApplicationId = rla.Id;
        refinanceLoanAppProp.Property_Type__c = ApexConstants.SUBJECT_PROPERTY_TYPE;
        refinanceLoanAppProp.PropertyState = 'ON';
        refinanceLoanAppProp.PropertyUseType = ApexConstants.PRIMART_RESIDENCE_OCCUPANCY_TYPE;
        refinanceLoanAppProp.Collateral_Position__c = '1';
        refinanceLoanAppProp.Property_value__c = 10000;
        refinanceLoanAppProp.Purchase_Price__c = 100;
        refinanceLoanAppProp.Loan_Purpose__c = 'Refinance';
        loanAppPropList.add(refinanceLoanAppProp);
        
        test.startTest();
        insert loanAppPropList;
        test.stopTest();
        ResidentialLoanApplication rlapp = [SELECT Id, Loan_Purpose__c FROM ResidentialLoanApplication WHERE Id =: rla.Id];
        system.assertEquals('Purchase/Refinance', rlapp.Loan_Purpose__c);
    }
}
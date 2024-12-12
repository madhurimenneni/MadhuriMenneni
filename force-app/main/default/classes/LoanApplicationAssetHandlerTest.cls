@isTest
private class LoanApplicationAssetHandlerTest {
 	@testSetup static void setupData() {  
        List<Apex_static_components__c> constantsList = TestDataFactory.createConstant(true);
        Id recordTypeId = Utils.getRecordTypeId( Utils.ACCOUNT_OBJECT_TYPE, Utils.BROKERAGE_ACCOUNT_RECORD_TYPE_NAME );
        Account acc = new Account(OwnerId = UserInfo.getUserId(), 
                                  Name = 'Neighbourhood Holdings',
                                  RecordTypeId = recordTypeId); 
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
        
        TestDataFactory.createLoanApplicationAssets(loanApp[0].Id, 1, true);
    }
    
    @isTest static void beforeOperationsTest(){
        LoanApplicationAsset asset = [ SELECT 
                                              Id,
                                              Name,
                                      		  LoanApplicationId,
                                      		  Primary_Applicant__c
                                        FROM 
                                              LoanApplicationAsset ];
        update new LoanApplicationAsset( Id = asset.Id, LoanApplicationId = null );
         asset = [ SELECT 
                          Id,
                          Name,
                          LoanApplicationId,
                          Primary_Applicant__c
                    FROM 
                          LoanApplicationAsset ];
        System.AssertEquals(null, asset.Primary_Applicant__c, 'Primary applicant on Asset is not null');
   }

   @isTest static void calCulateTotalAssetValueTest(){
    LoanApplicationAsset asset = [ SELECT 
                                          Id,
                                          Name,
                                            LoanApplicationId,
                                            Primary_Applicant__c
                                    FROM 
                                          LoanApplicationAsset ];
    update new LoanApplicationAsset( Id = asset.Id, CashOrMarketValue = 20000 );
    delete asset;
    undelete asset;
}
    
    @isTest static void lockLoanApplicantionAssetTest(){
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
                                              Status = ApexConstants.COMPLETE_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS
                                             );
        LoanApplicationAsset asset = [ SELECT 
                                              Id,
                                              Name
                                        FROM 
                                              LoanApplicationAsset ];
        
        Boolean exceptionThrown = false;
        try{
            update new LoanApplicationAsset( Id = asset.Id, Name = 'Edit loan Application Asset' );
        } catch ( Exception e ) { 
            exceptionThrown = true;
            Boolean expectedExceptionThrown =  (e.getMessage().contains('You can not edit this record')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage());
        }
    }
}
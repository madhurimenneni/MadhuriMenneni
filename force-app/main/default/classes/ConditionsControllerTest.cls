@isTest
private class ConditionsControllerTest {
	@testSetup static void setupData() { 
        List<Apex_static_components__c> constantsList = TestDataFactory.createConstant(true);
        Id recordTypeId = Utils.getRecordTypeId( Utils.ACCOUNT_OBJECT_TYPE, Utils.BROKERAGE_ACCOUNT_RECORD_TYPE_NAME );
        Account acc = new Account(OwnerId = UserInfo.getUserId(), 
                                  Name = 'Neighbourhood Holdings',
                                  RecordTypeId = recordTypeId); 
        insert acc;
        TestDataFactory.createResidentialLoanApplications(acc.Id, 1, true);
    }
    
    @isTest static void getConditionsTest() {
        ResidentialLoanApplication loanApp = [ SELECT 
                                                        Id,
                                                        Selected_Conditions__c,
                                                        Status
                                                  FROM 
                                                        ResidentialLoanApplication ];
        ConditionsController.getConditions( loanApp.Id );
     }
}
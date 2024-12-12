@isTest
private class tabconditionsControllerTest {
    @testSetup static void setupData() {  
        List<Apex_static_components__c> constantsList = TestDataFactory.createConstant(true);
        Id recordTypeId = Utils.getRecordTypeId( Utils.ACCOUNT_OBJECT_TYPE, Utils.BROKERAGE_ACCOUNT_RECORD_TYPE_NAME );
        Account acc = new Account(OwnerId = UserInfo.getUserId(), 
                                  Name = 'Neighbourhood Holdings',
                                  RecordTypeId = recordTypeId); 
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.id, Email = 'test_1@gmail.com' );
        insert con;
        List<ResidentialLoanApplication> loanApp = TestDataFactory.createResidentialLoanApplications(acc.Id, 1, true);
        system.debug('Loan APP: ' + loanApp[0]);
        Main_Conditions__mdt mainMetadata = [SELECT Id,MasterLabel FROM Main_Conditions__mdt WHERE MasterLabel =: 'Proof of Down Payment'];
        RLA_Standard_Condition__c standardCondition = new RLA_Standard_Condition__c( Name = mainMetadata.MasterLabel,
                                                                                    Residential_Loan_Application__c = loanApp[0].Id);
        insert standardCondition;
        Sub_Conditions__mdt childMetadata = [SELECT Id, MasterLabel FROM Sub_Conditions__mdt WHERE MasterLabel =: '100'];
        RLA_Sub_Condition__c subCondition = new RLA_Sub_Condition__c(
            RLA_Standard_Condition__c = standardCondition.Id,
            Residential_Loan_Application__c = loanApp[0].Id
        );
        insert subCondition;
    }
    
    @isTest static void getParentConditionTest(){
        ResidentialLoanApplication loanApp = [ SELECT Id, Contact__c, Status FROM ResidentialLoanApplication WHERE Account.Name = 'Neighbourhood Holdings'];
        List<Main_Conditions__mdt> mainMetadata = [SELECT Id,MasterLabel FROM Main_Conditions__mdt WHERE MasterLabel IN ('Proof of Down Payment','FR Corporate Borrower')];
        List<String> selectedMasterIds = new List<String>{mainMetadata[0].Id};
        List<String> unselectedMasterIds = new List<String>{mainMetadata[1].Id};
        tabconditionsController.getMdata( );
        tabconditionsController.getCdata( mainMetadata[0].Id );
        tabconditionsController.updateCondition( loanApp.Id, selectedMasterIds );
    }
}
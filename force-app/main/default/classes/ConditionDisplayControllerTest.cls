@isTest
private class ConditionDisplayControllerTest {
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
    }
    @isTest static void getPicklistValuesTest(){
        test.startTest();
        List<Map<String, String>> values = ConditionDisplayController.getPicklistValues();
        test.stopTest();
        system.assertEquals(3, values.size());
    }
    @isTest static void getParentConditionTest(){
        ResidentialLoanApplication loanApp = [SELECT Id, Contact__c, Status FROM ResidentialLoanApplication ];
        Main_Conditions__mdt mainMetadata = [SELECT Id,MasterLabel FROM Main_Conditions__mdt WHERE MasterLabel =: 'Proof of Down Payment'];
        RLA_Standard_Condition__c standardCondition = new RLA_Standard_Condition__c( Name = mainMetadata.MasterLabel,
                                                                                   Residential_Loan_Application__c = loanApp.Id);
        insert standardCondition;
        Sub_Conditions__mdt childMetadata = [SELECT Id,MasterLabel FROM Sub_Conditions__mdt WHERE MasterLabel =: '100'];
        RLA_Sub_Condition__c subCondition = new RLA_Sub_Condition__c( 
                                                                      RLA_Standard_Condition__c = standardCondition.Id,
                                                                      Residential_Loan_Application__c = loanApp.Id);
        insert subCondition;
        RLA_Standard_Condition__c sc = [SELECT Id FROM RLA_Standard_Condition__c];
        List<LoanApplicationProperty> prop = TestDataFactory.createRegularLoanApplicationProperty(loanApp.Id, 1, true);
        ConditionDisplayController.getParentCondition( prop[0].Id );
        ConditionDisplayController.getChildCondition( sc.Id );
        ConditionDisplayController.getChildConditionsList( sc.Id );
        ConditionDisplayController.deletecondi(subCondition);
    }
    
    @isTest static void updateConditionTest(){
        ResidentialLoanApplication loanApp = [SELECT Id, Contact__c, Status FROM ResidentialLoanApplication ];
        List<Main_Conditions__mdt> mainMetadata = [SELECT Id,MasterLabel FROM Main_Conditions__mdt WHERE MasterLabel IN ('Proof of Down Payment','FR Corporate Borrower')];
        List<String> selectedMasterIds = new List<String>{mainMetadata[0].Id};
        List<String> unselectedMasterIds = new List<String>{mainMetadata[1].Id};
        ConditionDisplayController.updateCondition( loanApp.Id, selectedMasterIds, unselectedMasterIds );
    }
    @isTest static void getAllChildConditionsTest(){
        ResidentialLoanApplication appRLA = [SELECT Id, Contact__c, Status FROM ResidentialLoanApplication WHERE Account.Name = 'Neighbourhood Holdings' LIMIT 1];
        List<Main_Conditions__mdt> mainMetadata = [SELECT Id, MasterLabel FROM Main_Conditions__mdt WHERE MasterLabel IN ('Proof of Down Payment','FR Corporate Borrower')];
        List<LoanApplicationProperty> appProperties = TestDataFactory.createRegularLoanApplicationProperty(appRLA.Id, 1, true);
        RLA_Standard_Condition__c rlaStandardCon = new RLA_Standard_Condition__c();
        rlaStandardCon.Name = mainMetadata[0].MasterLabel;
        rlaStandardCon.Residential_Loan_Application__c = appRLA.Id;
        insert rlaStandardCon;
        
        List<RLA_Sub_Condition__c> subConList = new List<RLA_Sub_Condition__c>();
        RLA_Sub_Condition__c subCon = new RLA_Sub_Condition__c();
        subCon.Residential_Loan_Application__c = appRLA.Id;
        subCon.RLA_Standard_Condition__c = rlaStandardCon.Id;
        subConList.add(subCon);
        
        RLA_Sub_Condition__c subConTwo = new RLA_Sub_Condition__c();
        subConTwo.Residential_Loan_Application__c = appRLA.Id;
        subConTwo.RLA_Standard_Condition__c = rlaStandardCon.Id;
        subConList.add(subConTwo);
        insert subConList;
        
        test.startTest();
        List<RLA_Sub_Condition__c> subCons = ConditionDisplayController.getAllChildConditions(appProperties[0].Id);
        test.stopTest();
        system.assertEquals(2, subCons.size());
    }
}
@isTest
private class FeeHandlerTest {
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
        List<ResidentialLoanApplication> listRLA = TestDataFactory.createResidentialLoanApplications(acc.Id, 1, false);
        listRLA[0].Contact__c = contact.Id;
        insert listRLA;
    }
    
    @isTest static void validateFeeRecordsTest() {
        List<ResidentialLoanApplication> rlaList = [SELECT Id, Status FROM ResidentialLoanApplication WHERE Account.Name = 'Neighbourhood Holdings'];
        Fee__c fee = new Fee__c();
        fee.Fee_Type__c = 'Wire Fee';
        fee.Amount__c = 100;
        fee.Residential_Loan_Application__c = rlaList[0].Id;
        insert fee;
        
        Fee__c feeTwo = new Fee__c();
        feeTwo.Fee_Type__c = 'Wire Fee';
        feeTwo.Amount__c = 100;
        feeTwo.Residential_Loan_Application__c = rlaList[0].Id;
        
        test.startTest();     
        DmlException expectedException;
        try{
            system.debug('try');
            insert feeTwo;
        } Catch(DmlException error){
            expectedException = error;system.debug(expectedException.getMessage());
        }
        Boolean expectedExceptionThrows = (expectedException.getMessage().Contains('Fee already exist, please check the existing fee records.')) 
            ? true
            : false;
        test.stopTest();
        System.assertEquals( true, expectedExceptionThrows, 'No error/Record saved' ); 
    }
}
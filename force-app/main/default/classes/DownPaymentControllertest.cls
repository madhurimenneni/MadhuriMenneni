@isTest
private class DownPaymentControllertest {
    @testSetup static void setupData() {
        List<Apex_static_components__c> constantsList = TestDataFactory.createConstant(true);
        Id recordTypeId = Utils.getRecordTypeId( Utils.ACCOUNT_OBJECT_TYPE, Utils.BROKERAGE_ACCOUNT_RECORD_TYPE_NAME );
        Account acc = new Account(OwnerId = UserInfo.getUserId(), 
                                  Name = 'Neighbourhood Holdings',
                                  RecordTypeId = recordTypeId); 
        insert acc;
        Account brokerageAcc = new Account( Name = 'Brightpath Capital' );
        insert brokerageAcc;
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
        SObjectDomain.getTriggerEvent(ResidentialLoanApplications.class).disableAll();
        List<ResidentialLoanApplication> loanApp = TestDataFactory.createResidentialLoanApplications(acc.Id, 1, false);
        loanApp[0].Contact__c = contact.Id;
        insert loanApp;

        loanApp[0].Brokerage__c = brokerageAcc.Id;
        loanApp[0].Interest_Adjustment_Date__c = Date.Today();
        loanApp[0].ASAP__c = true;
        loanApp[0].Close_Date__c = Date.today();
       
        update loanApp[0];
        SObjectDomain.getTriggerEvent(ResidentialLoanApplications.class).enableAll();
        
        List<LoanApplicationProperty> loanApplicationProperty = TestDataFactory.createRegularLoanApplicationProperty(loanApp[0].Id, 1, true);
    }
    @isTest static void getDownpaymentTest(){
        List<LoanApplicationProperty> loanApplicationProperty = [SELECT Id FROM LoanApplicationProperty WHERE LoanApplication.Account.Name = 'Neighbourhood Holdings'];
        test.startTest();
        List<Downpayment__c> downPayments = TestDataFactory.createDownpayment(loanApplicationProperty[0].Id, 1, true);
        String downPaymentsResult = DownpaymentController.getDownpayment( loanApplicationProperty[0].Id );
        DownpaymentController.downpaymentWrapper result = (DownpaymentController.downpaymentWrapper) JSON.deserialize(downPaymentsResult, DownpaymentController.downpaymentWrapper.class);
        test.stopTest();
        system.assertEquals(true, result.hasData);
    }
    @isTest static void deleteDownpaymentListTest(){
        List<LoanApplicationProperty> loanApplicationProperty = [SELECT Id FROM LoanApplicationProperty WHERE LoanApplication.Account.Name = 'Neighbourhood Holdings'];
        
        List<Downpayment__c> downPayments = TestDataFactory.createDownpayment(loanApplicationProperty[0].Id, 1, true);
        test.startTest();
        List<Id> downPaymentIds = new List<Id>();
        for(Downpayment__c downPayment : downPayments){
            downPaymentIds.add( downPayment.Id );
        }
        Map<String,String> resultMap = DownpaymentController.deleteDownpaymentList(downPaymentIds);
        test.stopTest();
        List<String> mapString = resultMap.values();
        system.assertEquals('success', mapString[0]);
        system.assertEquals('Downpayment is Deleted Successfully', mapString[1]);
    }
    @isTest static void calculatePropetyValueActionTest(){
        List<LoanApplicationProperty> loanApplicationProperty = [SELECT Id FROM LoanApplicationProperty WHERE LoanApplication.Account.Name = 'Neighbourhood Holdings'];
        test.startTest();
        List<Downpayment__c> downPayments = TestDataFactory.createDownpayment(loanApplicationProperty[0].Id, 1, true);
        Map<String,String> resultMap = DownpaymentController.calculatePropetyValueAction( downPayments[0].Id );
        test.stopTest();
    }
    @isTest static void updateDefaultActionTest(){
        List<LoanApplicationProperty> loanApplicationProperty = [SELECT Id FROM LoanApplicationProperty WHERE LoanApplication.Account.Name = 'Neighbourhood Holdings'];
        test.startTest();
        List<Downpayment__c> downPayments = TestDataFactory.createDownpayment(loanApplicationProperty[0].Id, 1, true);
        DownpaymentController.updateDefaultAction(downPayments[0].Id, true, loanApplicationProperty[0].Id);
        test.stopTest();
    }
    @isTest static void updateDefaultActionOnDeletionTest(){
        List<LoanApplicationProperty> loanApplicationProperty = [SELECT Id FROM LoanApplicationProperty WHERE LoanApplication.Account.Name = 'Neighbourhood Holdings'];
        test.startTest();
        List<Downpayment__c> downPayments = TestDataFactory.createDownpayment(loanApplicationProperty[0].Id, 1, true);
        DownpaymentController.updateDefaultActionOnDeletion(downPayments[0].Id, true, loanApplicationProperty[0].Id);
        test.stopTest();
    }
}
@isTest Private class ValuationControllerTest {
    @testSetup static void setupData() { 
        List<Apex_static_components__c> constantsList = TestDataFactory.createConstant(true);
        Id recordTypeId = Utils.getRecordTypeId( Utils.ACCOUNT_OBJECT_TYPE, Utils.BROKERAGE_ACCOUNT_RECORD_TYPE_NAME );
        Account acc = new Account(OwnerId = UserInfo.getUserId(), Name = 'Neighbourhood Holdings',RecordTypeId = recordTypeId); 
        insert acc;
        List<ResidentialLoanApplication> loanApp = TestDataFactory.createResidentialLoanApplications(acc.Id, 1, true);
        List<LoanApplicationProperty> prop = TestDataFactory.createRegularLoanApplicationProperty(loanApp[0].Id, 1, true);
        Valuation__c valuation = new Valuation__c();
        valuation.Valuation_Amount__c = 5000;
        valuation.Valuation_Date__c = date.newInstance(2021,05,22);
        valuation.Loan_Application_Property__c = prop[0].Id;
        insert valuation;
    }
    
    @isTest static void getValuationTest() {
        String valuationResult = '';
        List<ResidentialLoanApplication> listRLA = [SELECT Id FROM ResidentialLoanApplication WHERE Account.Name = 'Neighbourhood Holdings'];
        LoanApplicationProperty prop = [SELECT Id, Name FROM LoanApplicationProperty WHERE LoanApplicationId =: listRLA[0].Id];
        test.startTest();
        valuationResult = ValuationController.getValuation( prop.Id );
        ValuationController.valuationWrapper result = (ValuationController.valuationWrapper) JSON.deserialize(valuationResult, ValuationController.valuationWrapper.class);
        test.stopTest();
        system.assertEquals(true, result.hasData);
    }
    @isTest static void deleteValuationTest() {
        List<LoanApplicationProperty> prop = [SELECT Id FROM LoanApplicationProperty WHERE LoanApplication.Account.Name = 'Neighbourhood Holdings'];
        List<Valuation__c> valuation = [SELECT Id, Valuation_Source__c, Valuation_Amount__c, Valuation_Date__c, Loan_Application_Property__c FROM Valuation__c WHERE Loan_Application_Property__c =: prop[0].Id];
        valuation[0].Valuation_Source__c = 'Homeowner Estimate';
        update valuation[0];
        List<Id> valuationIds = new List<Id>();
        for( Valuation__c v : valuation ){
            valuationIds.add(v.Id);
        } 
        test.startTest();
        Map<String, String> resultMap = ValuationController.deleteValuationList(valuationIds);
        test.stopTest();
        List<String> mapString = resultMap.values();
        system.assertEquals('success', mapString[0]);
        system.assertEquals('Valuation is Deleted Successfully', mapString[1]);
    }
    
    @isTest static void calculatePropetyValueActionOneTest() {
        List<LoanApplicationProperty> prop = [SELECT Id FROM LoanApplicationProperty WHERE LoanApplication.Account.Name = 'Neighbourhood Holdings'];
        List<Valuation__c> valuationList = [SELECT Id, Valuation_Source__c, Valuation_Amount__c, Valuation_Date__c, Loan_Application_Property__c FROM Valuation__c WHERE Loan_Application_Property__c =: prop[0].Id];
        valuationList[0].Valuation_Source__c = 'Appraised Value';
        update valuationList[0];
        
        test.startTest();
        List<Id> valuationIds = new List<Id>();
        Map<String, String> resultMap = new Map<String, String>();
         for( Valuation__c v : valuationList ){
             valuationIds.add(v.Id);
             resultMap = ValuationController.calculatePropetyValueAction( v.Id );
         }
        test.stopTest();
        List<String> mapString = resultMap.values();
        system.assertEquals('success', mapString[0]);
        system.assertEquals('Valuation is calculated Successfully', mapString[1]);
     }
    @isTest static void calculatePropetyValueActionTwoTest() {
        List<LoanApplicationProperty> prop = [SELECT Id FROM LoanApplicationProperty WHERE LoanApplication.Account.Name = 'Neighbourhood Holdings'];
        List<Valuation__c> valuationList = [SELECT Id, Valuation_Source__c, Valuation_Amount__c, Valuation_Date__c, Loan_Application_Property__c FROM Valuation__c WHERE Loan_Application_Property__c =: prop[0].Id];
        valuationList[0].Valuation_Source__c = 'Homeowner Estimate';
        update valuationList[0];
        test.startTest();
        List<Id> valuationIds = new List<Id>();
        Map<String, String> resultMap = new Map<String, String>();
         for( Valuation__c v : valuationList ){
             valuationIds.add(v.Id);
             resultMap = ValuationController.calculatePropetyValueAction( v.Id );
         }
        test.stopTest();
        List<String> mapString = resultMap.values();
        system.assertEquals('success', mapString[0]);
        system.assertEquals('Valuation is calculated Successfully', mapString[1]);
     } 
    @isTest static void calculatePropetyValueActionThreeTest() {
        List<ResidentialLoanApplication> loanApp = [SELECT Id FROM ResidentialLoanApplication WHERE Account.Name = 'Neighbourhood Holdings'];
        List<LoanApplicationProperty> prop = [SELECT Id FROM LoanApplicationProperty WHERE LoanApplicationId =: loanApp];
        List<Valuation__c> valuationList = [SELECT Id, Valuation_Source__c, Valuation_Amount__c, Valuation_Date__c, Loan_Application_Property__c FROM Valuation__c WHERE Loan_Application_Property__c =: prop[0].Id];
        valuationList[0].Valuation_Source__c = 'Homeowner Estimate';
        update valuationList[0];
        test.startTest();
        List<Id> valuationIds = new List<Id>();
        Map<String, String> resultMap = new Map<String, String>();
         for( Valuation__c v : valuationList ){
             valuationIds.add(v.Id);
             resultMap = ValuationController.calculatePropetyValueAction( v.Id );
         }
        test.stopTest();
        List<String> mapString = resultMap.values();
        system.assertEquals('success', mapString[0]);
        system.assertEquals('Valuation is calculated Successfully', mapString[1]);
     } 
    @isTest static void updateDefaultActionTest() {
        List<LoanApplicationProperty> prop = [SELECT Id FROM LoanApplicationProperty WHERE LoanApplication.Account.Name = 'Neighbourhood Holdings'];
        List<Valuation__c> valuationList = [SELECT Id, Valuation_Source__c, Valuation_Amount__c, Valuation_Date__c, Loan_Application_Property__c FROM Valuation__c WHERE Loan_Application_Property__c =: prop[0].Id];
        valuationList[0].Valuation_Source__c = 'Homeowner Estimate';
        update valuationList[0];
        test.startTest();
        ValuationController.updateDefaultAction( valuationList[0].Id, true, prop[0].Id );
        test.stopTest();
        Valuation__c valuationRecord = [SELECT Id, Default__c FROM Valuation__c WHERE Valuation_Source__c = 'Homeowner Estimate' LIMIT 1];
        system.assertEquals(True, valuationRecord.Default__c);
    }
    @isTest static void updateDefaultActionOnDeletionTest() {
        List<LoanApplicationProperty> prop = [SELECT Id FROM LoanApplicationProperty WHERE LoanApplication.Account.Name = 'Neighbourhood Holdings'];
        List<Valuation__c> valuationList = [SELECT Id, Valuation_Source__c, Valuation_Amount__c, Valuation_Date__c, Loan_Application_Property__c FROM Valuation__c WHERE Loan_Application_Property__c =: prop[0].Id];
        valuationList[0].Valuation_Source__c = 'Homeowner Estimate';
        update valuationList[0];
        
        test.startTest();
        ValuationController.updateDefaultActionOnDeletion( valuationList[0].Id, true, prop[0].Id );
        test.stopTest();
        
        Valuation__c valuationRecord = [SELECT Id, Default__c FROM Valuation__c WHERE Valuation_Source__c = 'Homeowner Estimate' LIMIT 1];
        system.assertEquals(False, valuationRecord.Default__c);
    }
}
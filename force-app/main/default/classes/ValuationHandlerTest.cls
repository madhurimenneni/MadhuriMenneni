@isTest Private class ValuationHandlerTest {
    @testSetup static void setupData() { 
        List<Apex_static_components__c> constantsList = TestDataFactory.createConstant(true);
        Id recordTypeId = Utils.getRecordTypeId( Utils.ACCOUNT_OBJECT_TYPE, Utils.BROKERAGE_ACCOUNT_RECORD_TYPE_NAME );
        Account acc = new Account(OwnerId = UserInfo.getUserId(), Name = 'Neighbourhood Holdings', RecordTypeId = recordTypeId); 
        insert acc;
        List<ResidentialLoanApplication> listRLA = TestDataFactory.createResidentialLoanApplications(acc.Id, 1, true);
        List<LoanApplicationProperty> listLAP = TestDataFactory.createRegularLoanApplicationProperty(listRLA[0].Id, 1, true);
    }
    
    @isTest static void updateValuationLoanAppPropertyFieldsInsertTest() {
        LoanApplicationProperty loanAppProp = [SELECT Id FROM LoanApplicationProperty WHERE LoanApplication.Account.Name = 'Neighbourhood Holdings' LIMIT 1];
        test.startTest();
        List<Valuation__c> listValuation = TestDataFactory.createAppraisedValueValuation(loanAppProp.Id, 1, true);
        test.stopTest();
        List<LoanApplicationProperty> loanAppPropList = [SELECT Id, Collateral_Appraisal_Value__c FROM LoanApplicationProperty WHERE Id =: listValuation[0].Loan_Application_Property__c ];
        system.assertEquals(listValuation[0].Valuation_Amount__c, loanAppPropList[0].Collateral_Appraisal_Value__c);
    }
    @isTest static void updateValuationLoanAppPropertyFieldsUpdateTest() {
        LoanApplicationProperty loanAppProp = [SELECT Id FROM LoanApplicationProperty WHERE LoanApplication.Account.Name = 'Neighbourhood Holdings' LIMIT 1];
        test.startTest();
        List<Valuation__c> listNonAppraisalValuation = TestDataFactory.createNonAppraisedValueValuation(loanAppProp.Id, 1, true);
        List<Valuation__c> ToBeUpdatedValuations = new List<Valuation__c>();
        for(Valuation__c val : listNonAppraisalValuation){
            val.Valuation_Source__c = ApexConstants.APPRAISED_VALUE_SOURCE;
            ToBeUpdatedValuations.add(val);
        }
        if(!ToBeUpdatedValuations.isEmpty()){
            update ToBeUpdatedValuations;
        }
        test.stopTest();
        List<LoanApplicationProperty> loanAppPropList = [SELECT Id, Collateral_Appraisal_Value__c FROM LoanApplicationProperty WHERE Id =: ToBeUpdatedValuations[0].Loan_Application_Property__c ];
        system.assertEquals(ToBeUpdatedValuations[0].Valuation_Amount__c, loanAppPropList[0].Collateral_Appraisal_Value__c);
    }
    @isTest static void updateAppraisalValuationLoanAppPropertyFieldsDeleteTest() {
        LoanApplicationProperty loanAppProp = [SELECT Id FROM LoanApplicationProperty WHERE LoanApplication.Account.Name = 'Neighbourhood Holdings' LIMIT 1];
        test.startTest();
        List<Valuation__c> listValuation = TestDataFactory.createAppraisedValueValuation(loanAppProp.Id, 1, true);
        if(!listValuation.isEmpty()){
            delete listValuation;            
        }
        test.stopTest();
        List<LoanApplicationProperty> loanAppPropList = [SELECT Id, Collateral_Appraisal_Value__c FROM LoanApplicationProperty WHERE Id =: listValuation[0].Loan_Application_Property__c ];
        system.assertEquals(null, loanAppPropList[0].Collateral_Appraisal_Value__c);
    }
}
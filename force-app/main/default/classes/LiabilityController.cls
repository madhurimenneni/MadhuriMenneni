public with sharing class LiabilityController {
    @AuraEnabled(cacheable=true)
    public static List<LoanApplicationLiability> getLiabilities( String loanApplicationId ) {
        List<LoanApplicationLiability> liabilities = [SELECT Id,Name, Liability_Type__c,Description__c, Balance__c, Monthly_Payment__c, Credit_Card_Balance__c, Annual_Liability_Balance_Calculated__c, Payoff__c, Loan_Application_Property__r.Name
                                         FROM LoanApplicationLiability
                                         WHERE LoanApplicationId =: loanApplicationId ORDER BY CreatedDate DESC];
        
        return liabilities;
    }
}
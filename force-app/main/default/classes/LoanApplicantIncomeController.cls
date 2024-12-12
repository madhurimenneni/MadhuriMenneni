public class LoanApplicantIncomeController {
    @AuraEnabled(cacheable=true)
    public static List<LoanApplicantIncome> getIncomeRecords( String loanApplicantId ) {
        List<LoanApplicantIncome> loanApplicantIncomes = [SELECT Id,Name,IncomeSourceType,Annual_Income__c, Description__c,Start_Date__c, End_Date__c, Currently_Receives__c, LoanApplicationId
                                         FROM LoanApplicantIncome
                                         WHERE LoanApplicantId =: loanApplicantId ORDER BY CreatedDate DESC];
        
        return loanApplicantIncomes;
    }
}
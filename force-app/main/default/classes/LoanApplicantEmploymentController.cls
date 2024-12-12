public class LoanApplicantEmploymentController {
    @AuraEnabled(cacheable=true)
    public static List<LoanApplicantEmployment> getEmploymentRecords( String loanApplicantId ) {
        List<LoanApplicantEmployment> loanApplicantEmployments = [SELECT Id,Name, Employment_Type__c,Frequency__c, Income__c, Income_Type__c, Currently_works_here__c, LoanApplicationId
                                         FROM LoanApplicantEmployment
                                         WHERE LoanApplicantId =: loanApplicantId ORDER BY CreatedDate DESC];
        
        return loanApplicantEmployments;
    }
}
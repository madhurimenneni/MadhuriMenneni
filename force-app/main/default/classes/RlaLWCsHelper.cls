/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-03-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class RlaLWCsHelper {
    @AuraEnabled(cacheable=true)
    public static List<LoanApplicantEmployment> getRlaEmploymentRecords( String loanApplicationId ) {
        List<LoanApplicantEmployment> rlaEmployments = [SELECT Id,Name, Employment_Type__c,Frequency__c, Income__c, Income_Type__c, Currently_works_here__c, LoanApplicationId, JobTitle
                                         FROM LoanApplicantEmployment
                                         WHERE LoanApplicationId =: loanApplicationId ORDER BY CreatedDate DESC];
        
        return rlaEmployments;
    }

    @AuraEnabled(cacheable=true)
    public static List<LoanApplicantIncome> getRlaIncomeRecords( String loanApplicationId ) {
        List<LoanApplicantIncome> rlaIncomes = [SELECT Id,Name,IncomeSourceType,Annual_Income__c, Description__c,Start_Date__c, End_Date__c, Currently_Receives__c, LoanApplicationId
                                         FROM LoanApplicantIncome
                                         WHERE LoanApplicationId =: loanApplicationId ORDER BY CreatedDate DESC];
        
        return rlaIncomes;
    }

    @AuraEnabled(cacheable=true)
    public static List<LoanApplicationAsset> getRlaAssetsRecords( String loanApplicationId ) {
        List<LoanApplicationAsset> rlaAssets = [SELECT Id,Name,AssetType,CashOrMarketValue, LoanApplicationId
                                         FROM LoanApplicationAsset
                                         WHERE LoanApplicationId =: loanApplicationId ORDER BY CreatedDate DESC];
        
        return rlaAssets;
    }

    @AuraEnabled(cacheable=true)
    public static List<Aml_Flag__c> getRlaAmlFlagsRecords( String loanApplicationId ) {
        List<Aml_Flag__c> rlaAmlFlags = [SELECT Id,Name,Related_Applicant__c, Related_Property__c, Related_Broker__c, Residential_Loan_Application__c, Resolution_Notes__c, Resolved__c, Type__c, Description__c, Resolution_Notes_CO__c,Resolution_Notes_Manager__c, Risk_Type__c, Resolution_Required_By__c, Related_Applicant__r.Name,Related_Property__r.Name, Related_Applicant_Name__c, Related_Property_Name__c 
                                         FROM Aml_Flag__c
                                         WHERE Residential_Loan_Application__c =: loanApplicationId ORDER BY CreatedDate DESC];
        
        return rlaAmlFlags;
    }

    @AuraEnabled(cacheable=true)
    public static List<Fee__c> getRlaFeeRecords( String loanApplicationId ) {
        List<Fee__c> rlaFees = [SELECT Id,Name,FR_Fee_Type__c, Fee_Type__c, Residential_Loan_Application__c, Fee_Percent__c, Fee_Category__c, Extracted_Fee_Type__c, Description__c, Amount__c 
                                         FROM Fee__c
                                         WHERE Residential_Loan_Application__c =: loanApplicationId ORDER BY CreatedDate DESC];
        
        return rlaFees;
    }

    @AuraEnabled(cacheable=true)
    public static List<Rental_Income__c> getRentalIncomeRecords( String loanApplicationId ) {
        List<Rental_Income__c> rentalIncomes = [SELECT Id,Name,Property_Name__c,Monthly_Rental_Income__c,Property_Rental_Policy__c,Property__c,Adjusted_Monthly_Rental_Income__c,Occupancy_Type__c, Property_Addback_Offset_Percentage__c, Unit_Number__c, Property__r.Name
                                         FROM Rental_Income__c
                                         WHERE LoanApplicationId__c =: loanApplicationId ORDER BY CreatedDate DESC];
        
      return rentalIncomes;
    }

    @AuraEnabled(cacheable=true)
    public static List<LoanApplicant> getRlaApplicantsRecords( String loanApplicationId ) {
        List<LoanApplicant> rlaApplicants = [SELECT Id,Name,Applicant_Type__c,Credit_Score__c, CitizenshipStatus,Sum_of_Employments_and_Incomes__c
                                         FROM LoanApplicant
                                         WHERE LoanApplicationId =: loanApplicationId ORDER BY CreatedDate DESC];
        
        return rlaApplicants;
    }

    @AuraEnabled(cacheable=true)
    public static List<LoanApplicationProperty> getRlaLoanApplicationPropertyRecords( String loanApplicationId ) {
        List<LoanApplicationProperty> rlaProperties = [SELECT Id, Name, Loan_Purpose__c, Property_Type__c, Purchase_Price__c, PropertyUseType, Collateral_Position__c, Property_Value__c
                                         FROM LoanApplicationProperty
                                         WHERE LoanApplicationId =: loanApplicationId ORDER BY CreatedDate DESC];
        
        return rlaProperties;
    }
}
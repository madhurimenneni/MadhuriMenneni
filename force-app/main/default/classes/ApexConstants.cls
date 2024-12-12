/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-09-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class ApexConstants {
    //Loan Application
    public static final String LEAD_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS = '0. Lead'; 
    public static final String SENT_COMMITMENT_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS = '2. Sent Commitment'; 
    public static final String DUPLICATE_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS = 'DUPLICATE';
    public static final String UNPROCESSED_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS = 'Unprocessed'; 
    public static final String COMPLETE_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS = 'Complete'; 
    public static final String FAILED_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS = 'Failed'; 
    public static final String NEW_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS = 'New'; 
    public static final String BC_PROVINCE = 'BC'; 
    public static final String MONTHLY_PAYMENT_FREQUENCY = 'Monthly'; 
    public static final String WEEKLY_PAYMENT_FREQUENCY = 'Weekly'; 
    public static final String SEMI_ANNUALY_COMPOUND_FREQUENCY = 'Semi-Annually'; 
    public static final String OPEN_OPTION_TYPE = 'Open'; 
    public static final String CLOSED_OPTION_TYPE = 'Closed'; 
    public static final String INTEREST_ONLY_AMORTIATION_TYPE = 'Interest Only'; 
    public static final String MONTHS_AMORTIZATION_DURATION_UNIT = 'Months'; 
    public static final String YEARS_AMORTIZATION_DURATION_UNIT = 'Years'; 
    public static final String APPROVAL_APPLICATION_TYPE = 'Approval'; 
    public static final String PURCHASE_LOAN_PURPOSE = 'Purchase';
    public static final String REFINANCE_LOAN_PURPOSE = 'Refinance';
    public static final String EQUITY_TAKEOUT_LOAN_PURPOSE = 'Equity Takeout';
    public static final String PURCHASE_REFINANCE_LOAN_PURPOSE = 'Purchase/Refinance';
    public static final String ENGLISH_PREFERRED_LANGUAGE = 'English';
    public static final String FRENCH_PREFERRED_LANGUAGE = 'French';
    public static final String VARIABLE_RATE_TYPE_RLA = 'Variable';
    public static final String FIXED_RATE_TYPE_RLA = 'Fixed';
    public static final String CANCELLED_STATUS = 'Cancelled';
    public static final String DECLINED_STATUS = 'Declined';

    //Loan Applicant Property
    public static final String PRIMART_RESIDENCE_OCCUPANCY_TYPE = 'Primary Residence'; 
    public static final String STRATA_TITLE_TYPE = 'Strata'; 
    public static final String LEASEHOLD_TITLE_TYPE = 'Leasehold'; 

    public static final String WIRE_FEE_TYPE = 'Wire Fee';
    public static final String LEGAL_FEE_TYPE = 'Legal Fee';
    public static final String TITLE_INSURANCE_FEE_TYPE = 'Title Insurance';
    public static final String FLAT_FEE_TYPE = 'Flat Prepayment Penalty';
    public static final String FINAL_APPROVAL_RECEIVED_SUBJECT = 'Final Approval Received';
    public static final String Title_Search_SUBJECT = 'Title Search';
    public static final String TASK_STATUS_OPEN = 'Open';
    public static final String TASK_PRIORITY_NORMAL = 'Normal';
    public static final String FIRST_LENDERS_LIEN_TYPE = 'First';
    public static final String SECOND_LENDERS_LIEN_TYPE = 'Second';
    public static final String THIRD_LENDERS_LIEN_TYPE = 'Third';
    public static final String FIRST_OR_SECOND_LENDERS_LIEN_TYPE = 'First/Second';
    public static final String APPRAISED_VALUE_VALUATION_SOURCE = 'Appraised Value';
    public static final String ASSESSMENT_VALUATION_SOURCE = 'Assessment';
    public static final String SUBJECT_PROPERTY_TYPE = 'Subject Property';
    
    //Loan Applicant
    public static final String PRIMARY_APPLICANT_TYPE = 'Primary Applicant';
    public static final String CO_APPLICANT_TYPE = 'Co-Applicant';
    public static final String GUARANTOR_APPLICANT_TYPE = 'Guarantor';
    public static final String CORPORATE_BORROWER_RECORD_TYPE_DEV_NAME = 'Corporate_Borrower';
    
    //Rental Income
    public static final String PRIMARY_RESIDENCE = 'Primary Residence';
    public static final String TO_BE_RENTED = 'To be Rented';
    
    //Loan Liability
    public static final String MORTGAGE_LIABILITY_TYPE = 'Mortgage';
    public static final String PAY_FROM_PROCEEDS_PAYOFF = 'Pay from Proceeds';
    public static final String BEFORE_ADVANCE_PAYOFF = 'Before Advance';
    public static final String NO_PAYOFF = 'No';
    public static final String NEW_LIABILITY_STATUS = 'New';
    public static final String EXISTING_LIABILITY_STATUS = 'Existing';
    
    //Campaign
    public static final String PLANNED_CAMPAIGN_STATUS = 'Planned';
    public static final String EVENT_CAMPAIGN_TYPE = 'Event';
    
    //Campaign Member
    public static final String SENT_CAMPAIGN_MEMBER_STATUS = 'Sent';
    
    //Valuation
    public static final String APPRAISED_VALUE_SOURCE = 'Appraised Value';
    public static final String PURCHASE_PRICE_SOURCE = 'Purchase Price';
    public static final String PURVIEW_PRICE_SOURCE =  'Purview';
    
    //Opportunity
    public static final String QUALIFICATION_OPPORTUNITY_STAGE = 'Qualification';
    
    public static String getProfileId{
        get{
            if ( getProfileId == null ) {
                getProfileId = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'].Id;
            }
            
            return getProfileId;
        }set;
    }
}
/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-02-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class ResidentialLoanApplicationController {
    public Decimal activePrimeRate;

    public static List<Prime_Rate__mdt> primeMetadataValues {
        get {
            if (primeMetadataValues == null) {
                primeMetadataValues = [SELECT Id, MasterLabel, Active__c, Variable_Rate__c, Fixed_Rate__c 
                                       FROM Prime_Rate__mdt 
                                       WHERE Active__c =: true 
                                       LIMIT 1];
            }
            return primeMetadataValues;
        }
        set;
    }

	@AuraEnabled
    public static String getResidentialLoanApplication( String residentialLoanAppId ) {
        return JSON.serialize(ResidentialLoanApplicationController.getResidentialLoanApplicationWrapper(residentialLoanAppId));
    } 
    
    public static ResidentialLoanApplicationController.ResidentialLoanApplicationWrapper getResidentialLoanApplicationWrapper( String residentialLoanAppId ) {
        ResidentialLoanApplicationController.ResidentialLoanApplicationWrapper result = new ResidentialLoanApplicationController.ResidentialLoanApplicationWrapper();
        List<ResidentialLoanApplication> oldResidentialLoanApps = [SELECT Id, Contact__r.Email, Brokerage__r.Name, Interest_Adjustment_Date__c, Primary_Applicant__c, Loan_Purpose__c, 
                                                                   ASAP__c, Close_Date__c, LTV__c, Shortfall_Overage__c, APR__c, Prime_Rate__c, Property_Value__c, Status, Rate_Type__c, High_Risk_Flags__c, Medium_Risk_Flags__c
                                                                   FROM ResidentialLoanApplication 
                                                                   WHERE Id =: residentialLoanAppId ]; 
        Set<Id> subjectPropertyLoanAppIdSet = new Set<Id>();
        List<LoanApplicationProperty> loanAppPropList = [SELECT Id, Collateral_Position__c, Property_Value__c, LoanApplicationId, PropertyUseType, Parking__c
                                                         FROM LoanApplicationProperty
                                                         WHERE LoanApplicationId =: residentialLoanAppId 
                                                         AND Property_Type__c =: ApexConstants.SUBJECT_PROPERTY_TYPE];
        Decimal sumOfLoanAppPropValue = 0;
        for( LoanApplicationProperty loanAppProp : loanAppPropList ){
            if( loanAppProp.PropertyUseType == ApexConstants.PRIMART_RESIDENCE_OCCUPANCY_TYPE ){
                subjectPropertyLoanAppIdSet.add( loanAppProp.LoanApplicationId );
            }
        }

        List<Valuation__c> valuationsList = new List<Valuation__c>();
        Set<String> loanproZeroAppraisalNames = new Set<String>();
        for (Valuation__c valuation : [SELECT Id, Loan_Application_Property__r.Id, Loan_Application_Property__r.Property_Type__c, Loan_Application_Property__r.Name, Valuation_Source__c, Valuation_Amount__c
                                      FROM Valuation__c
                                      WHERE Loan_Application_Property__r.Id IN :loanAppPropList
                                      AND Loan_Application_Property__r.Property_Type__c = 'Subject Property'
                                      AND Valuation_Source__c = 'Appraised Value'
                                      AND Valuation_Amount__c = 0]) {  
                                     valuationsList.add(valuation);
                                     loanproZeroAppraisalNames.add(valuation.Loan_Application_Property__r.Name);
        }

        if (valuationsList.size() > 0) {
        result.zeroappraisalvalue = true;
        }

        if(loanproZeroAppraisalNames.size () > 0) {
            result.zeroappraisalvalue = true;
            result.zeroappraisalvalueMsg = '';
            for(String str:loanproZeroAppraisalNames){
                result.zeroappraisalvalueMsg +=str +' & ';
            }
            result.zeroappraisalvalueMsg = result.zeroappraisalvalueMsg.removeEnd(' & ');
        }

        List<LoanApplicationLiability> liabilities = new List<LoanApplicationLiability>();
        for ( LoanApplicationLiability loanAppLiability : [SELECT Id, Loan_Application_Property__r.Id, Loan_Application_Property_Position__c, Position__c
                                                           FROM LoanApplicationLiability
                                                           WHERE Loan_Application_Property__r.Id IN: loanAppPropList
                                                                        AND Liability_Type__c = 'Mortgage'
                                                                        AND Liability_Status__c = 'Existing'
                                                                        AND Payoff__c = 'No'] ) {
                                                        if( loanAppLiability.Position__c > loanAppLiability.Loan_Application_Property_Position__c ) {
                                                            liabilities.add(loanAppLiability);
                                                        }
            }

            if ( liabilities.size() > 0 ){
                result.secondMortgageWarningMessage = true;
            }

        List<LoanApplicant> oldLoanApplicants = [SELECT Id, LoanApplicationId, RecordType.DeveloperName, Applicant_Type__c, Sum_of_Employments_and_Incomes__c, Credit_Score__c
                                                 FROM LoanApplicant 
                                                 WHERE LoanApplicationId =: subjectPropertyLoanAppIdSet ];
        
        Set<Id> regularLoanAppIdSet = new Set<Id>();
        Set<Id> corporateLoanAppIdSet = new Set<Id>();
        if( oldLoanApplicants.size() > 0 ){
            for( LoanApplicant loanApplicant : oldLoanApplicants ){
                if( loanApplicant.Applicant_Type__c == ApexConstants.PRIMARY_APPLICANT_TYPE ) {
                    if ( loanApplicant.RecordType.DeveloperName != ApexConstants.CORPORATE_BORROWER_RECORD_TYPE_DEV_NAME ) {
                        regularLoanAppIdSet.add(loanApplicant.LoanApplicationId);
                    } else{
                        corporateLoanAppIdSet.add(loanApplicant.LoanApplicationId);
                    } 
                }
            }
        }
        Decimal sum = 0.0;
        Decimal creditScore = 0.0;
        
        for( LoanApplicant loanApplicant : oldLoanApplicants ){
            if ( corporateLoanAppIdSet.size() > 0 && 
                (loanApplicant.Applicant_Type__c == ApexConstants.CO_APPLICANT_TYPE || loanApplicant.Applicant_Type__c == ApexConstants.GUARANTOR_APPLICANT_TYPE)) {
                    if( loanApplicant.Sum_of_Employments_and_Incomes__c > sum ) {
                        sum = loanApplicant.Sum_of_Employments_and_Incomes__c;
                        creditScore = loanApplicant.Credit_Score__c;
                    }
                }
            if ( regularLoanAppIdSet.size() > 0 && 
                (loanApplicant.Applicant_Type__c == ApexConstants.PRIMARY_APPLICANT_TYPE || loanApplicant.Applicant_Type__c == ApexConstants.CO_APPLICANT_TYPE || loanApplicant.Applicant_Type__c == ApexConstants.GUARANTOR_APPLICANT_TYPE)) {
                    if( loanApplicant.Sum_of_Employments_and_Incomes__c > sum ) {
                        sum = loanApplicant.Sum_of_Employments_and_Incomes__c;
                        creditScore = loanApplicant.Credit_Score__c;
                    }
                } 
        }
		system.debug('Old RLA Status: ' + oldResidentialLoanApps[0].Status);
        result.status = oldResidentialLoanApps[0].Status;
        system.debug('RLA Status: ' + result.status);
        if( creditScore == null ){
            result.thresholdCreditScore = true;
            
        }
		
        if( creditScore > 0 && creditScore < 575 && oldResidentialLoanApps[0].LTV__c >= 65 ){
            result.LTVCreditScore575LimitError = true;
            
        }

        if( creditScore > 0 && creditScore < 500 ){
            result.LTVCreditScore500LimitError = true;
            
        }
        if( !oldResidentialLoanApps.isEmpty() ){
            result.brokerEmail = oldResidentialLoanApps[0].Contact__r.Email;
            system.debug('test: '+result.brokerEmail);
            if( result.brokerEmail == null ){
                
            }
            if( result.accountName == 'Brightpath Capital' ){
                
            }
            result.accountName = oldResidentialLoanApps[0].Brokerage__r.Name;
            if( oldResidentialLoanApps[0].Interest_Adjustment_Date__c != null ){
                result.interestAdjustmentDate = oldResidentialLoanApps[0].Interest_Adjustment_Date__c.day();
                if( result.interestAdjustmentDate != 1 ){
                    
                }
            }

            if( oldResidentialLoanApps[0].Primary_Applicant__c == null ) {
                result.primaryApplicant = true;
                
            } else {
                result.primaryApplicant = false;
            }

            if( oldResidentialLoanApps[0].Medium_Risk_Flags__c != null && oldResidentialLoanApps[0].Medium_Risk_Flags__c >= 1 ) {
                result.mediumriskFlags = true;
            } else {
                result.mediumriskFlags = false;
            }
            
            if( oldResidentialLoanApps[0].High_Risk_Flags__c != null && oldResidentialLoanApps[0].High_Risk_Flags__c >= 1 ) {
                result.highriskFlags = true;
            } else {
                result.highriskFlags = false;
            }            
            
            if( oldResidentialLoanApps[0].Loan_Purpose__c == ApexConstants.PURCHASE_LOAN_PURPOSE
                && oldResidentialLoanApps[0].ASAP__c == true ) {
                    result.uncheckASAPBox = true;      
            }

            if (oldResidentialLoanApps[0].APR__c != null && oldResidentialLoanApps[0].APR__c >= 30) {
                result.aprwarning = true;
            } else {
                result.aprwarning = false;
            }            
        
            if( (oldResidentialLoanApps[0].Loan_Purpose__c == ApexConstants.REFINANCE_LOAN_PURPOSE
                || oldResidentialLoanApps[0].Loan_Purpose__c == ApexConstants.EQUITY_TAKEOUT_LOAN_PURPOSE)
                && oldResidentialLoanApps[0].ASAP__c == false ) {
                    result.checkASAPBox = true;
                    
            }

            if( ( oldResidentialLoanApps[0].Loan_Purpose__c == ApexConstants.REFINANCE_LOAN_PURPOSE 
                || oldResidentialLoanApps[0].Loan_Purpose__c == ApexConstants.EQUITY_TAKEOUT_LOAN_PURPOSE )
                && oldResidentialLoanApps[0].Close_Date__c != null ) {
                    result.blankCloseDate = true;
                    
            }

            if( oldResidentialLoanApps[0].Loan_Purpose__c == ApexConstants.PURCHASE_LOAN_PURPOSE 
                && oldResidentialLoanApps[0].Close_Date__c == null ) {
                    result.missingCloseDate = true;
                    
            }

            String shortfallOrOverageSignValue = null;
            if( oldResidentialLoanApps[0].Shortfall_Overage__c != null ){
            	shortfallOrOverageSignValue = String.valueOf(oldResidentialLoanApps[0].Shortfall_Overage__c);
            	result.shortfallOverage = oldResidentialLoanApps[0].Shortfall_Overage__c;
                if( shortfallOrOverageSignValue.StartsWith('-') 
                    && oldResidentialLoanApps[0].Shortfall_Overage__c < 0 ){
                    result.shortfallOrOverageSign = 'negative';
                } else if(oldResidentialLoanApps[0].Shortfall_Overage__c > 0){
                    result.shortfallOrOverageSign = 'positive';
                }
                if( result.shortfallOrOverageSign == 'negative'
                    || result.shortfallOrOverageSign == 'positive' ){
                        
                    }
            }
            if((oldResidentialLoanApps[0].Rate_Type__c == ApexConstants.VARIABLE_RATE_TYPE_RLA && oldResidentialLoanApps[0].Prime_Rate__c != primeMetadataValues[0].Variable_Rate__c)){
                 result.primeRateMessage = 'The application prime rate is '+oldResidentialLoanApps[0].Prime_Rate__c+','+
                    ' but the current prime rate is '+ primeMetadataValues[0].Variable_Rate__c +'.'+
                    ' Please update the Prime Rate. ';
            }
            if((oldResidentialLoanApps[0].Rate_Type__c == ApexConstants.FIXED_RATE_TYPE_RLA && oldResidentialLoanApps[0].Prime_Rate__c != primeMetadataValues[0].Fixed_Rate__c)){
                 result.primeRateMessage = 'The application prime rate is '+oldResidentialLoanApps[0].Prime_Rate__c+','+
                    ' but the current prime rate is '+ primeMetadataValues[0].Fixed_Rate__c +'.'+
                    ' Please update the Prime Rate. ';
            }
           /* if(primeMetadataValues[0].Variable_Rate__c != oldResidentialLoanApps[0].Prime_Rate__c ){
                result.primeRateMessage = 'The application prime rate is '+oldResidentialLoanApps[0].Prime_Rate__c+','+
                    ' but the current prime rate is '+ primeMetadataValues[0].Variable_Rate__c +'.'+
                    ' Please update the Prime Rate. ';
                    
            } */
        }
        return result;
    } 
    
    @AuraEnabled
    public static string getLoanApplicationProperty( String residentialLoanAppId ){
        return JSON.serialize(ResidentialLoanApplicationController.getLoanApplicationPropertyWrapper(residentialLoanAppId));
    }
    
    public static ResidentialLoanApplicationController.LoanApplicationPropertyWrapper getLoanApplicationPropertyWrapper( String residentialLoanAppId ) {
        ResidentialLoanApplicationController.LoanApplicationPropertyWrapper result = new ResidentialLoanApplicationController.LoanApplicationPropertyWrapper();
        List<LoanApplicationProperty> oldLoanApplicationProperties = [SELECT Id,name, PropertyStreet, LoanApplication.status, Title_Type__c, Property_Type__c, Property_Value__c, Collateral_Appraisal_Date__c, 
                                                                      LoanApplicationid, Legal_Description__c, Collateral_Appraisal_Value__c, Unit__c, Parking__c
                                                                      FROM LoanApplicationProperty 
                                                                      WHERE LoanApplicationid =: residentialLoanAppId ]; 
        Set<Id> missingUnitNumberSet = new Set<Id>();
        Set<Id> missingColleteralLegalAddressSet = new Set<Id>();
        Set<Decimal> missingAppraisalValueSet = new Set<Decimal>();
        Set<Date> missingAppraisalDateSet = new Set<Date>();
        Set<String> loanproNames=new Set<String>();
        Set<String> loanproParkingErrorNames = new Set<String>();
        for( LoanApplicationProperty loanAppProp : oldLoanApplicationProperties ){
            if( loanAppProp.Property_Type__c == ApexConstants.SUBJECT_PROPERTY_TYPE
                && loanAppProp.Title_Type__c == ApexConstants.STRATA_TITLE_TYPE
                && loanAppProp.Unit__c == null) {
                    missingUnitNumberSet.add(loanAppProp.Unit__c);
            }
            if( loanAppProp.Legal_Description__c == null
              	&& loanAppProp.Property_Type__c == ApexConstants.SUBJECT_PROPERTY_TYPE) {
                    missingColleteralLegalAddressSet.add(loanAppProp.ID);
                    loanproNames.add(loanAppProp.name);
            }
            if( loanAppProp.Property_Type__c == ApexConstants.SUBJECT_PROPERTY_TYPE ) {
                if( loanAppProp.Parking__c != null ) {
                    List<String> parkingSelections = loanAppProp.Parking__c.split(';');
                    if( parkingSelections.size() == 0 || parkingSelections.contains('None') || parkingSelections.contains('On-street') ){
                        loanproParkingErrorNames.add(loanAppProp.name);
                    }
                } else {
                    loanproParkingErrorNames.add(loanAppProp.name);
                }
                    
            }
            if( loanAppProp.Collateral_Appraisal_Value__c == null
              	&& loanAppProp.Property_Type__c == ApexConstants.SUBJECT_PROPERTY_TYPE) {
                missingAppraisalValueSet.add(loanAppProp.Collateral_Appraisal_Value__c);
            }
            if( loanAppProp.Collateral_Appraisal_Date__c == null
              	&& loanAppProp.Property_Type__c == ApexConstants.SUBJECT_PROPERTY_TYPE) {
                missingAppraisalDateSet.add(loanAppProp.Collateral_Appraisal_Date__c);
            }  
            result.status = loanAppProp.LoanApplication.Status;
        }
        
        if( missingUnitNumberSet.size() > 0 ) {
            result.missingUnitNumber = true;
            
        }
        if( missingColleteralLegalAddressSet.size() > 0 ) {
            result.missingColleteralLegalAddress = true;
            result.colleteralLegalMsg='';
            for(string str:loanproNames){
                 result.colleteralLegalMsg +=str +' & ';
            }
            result.colleteralLegalMsg=result.colleteralLegalMsg.removeEnd(' & ');
            
        }

        if( loanproParkingErrorNames.size() > 0 ) {
            result.missingParkingInfo = true;
            result.missingParkingMsg = '';
            for(string str:loanproParkingErrorNames){
                result.missingParkingMsg +=str +' & ';
           }
            result.missingParkingMsg = result.missingParkingMsg.removeEnd(' & ');
        }
        if( missingAppraisalValueSet.size() > 0 ) {
            result.missingAppraisalValue = true;
            
        }
        if( missingAppraisalDateSet.size() > 0 ) {
            result.missingAppraisalDate = true;
            
        }
        
        return result;
    }
    
    public class ResidentialLoanApplicationWrapper{
        public String brokerEmail;
        public String accountName; 
        public Integer interestAdjustmentDate;
        public Boolean primaryApplicant;
        public Boolean uncheckASAPBox;
        public Boolean blankCloseDate;
        public Boolean checkASAPBox;
        public Boolean missingCloseDate;
        public Boolean thresholdCreditScore;
        public Boolean LTVCreditScore575LimitError;
        public Boolean LTVCreditScore500LimitError;
        public String shortfallOrOverageSign;
        public Decimal shortfallOverage;
        public String primeRateMessage;
        public String status;
        public Boolean secondMortgageWarningMessage;
        public Boolean highriskFlags;
        public Boolean mediumriskFlags;
        public Boolean zeroappraisalvalue;
        public String zeroappraisalvalueMsg;
        public Boolean aprwarning = false;
       // public Boolean datarefreshed = false;
    }
    
    public class LoanApplicationPropertyWrapper{
        public Boolean missingUnitNumber = false;
        public Boolean missingColleteralLegalAddress = false;
        public Boolean missingParkingInfo = false;
        public Boolean missingAppraisalValue = false;
        public Boolean missingAppraisalDate = false;
        public String colleteralLegalMsg;
        public String missingParkingMsg;
        public String status;
    }

    public class AmlFlagWrapper{
        public Boolean hasActiveAmlFlags = false;
        public String hasActiveAmlFlagsMsg;
        public String rlaStatus;
    }
    public class ValuationWrapper {
        public Boolean zeroappraisalvalue = false;
        public String zeroappraisalvalueMsg;
    }
    
    @AuraEnabled
    public static string getAmlFalgs( String residentialLoanAppId ){
        return JSON.serialize(ResidentialLoanApplicationController.AmlFlagWrapper(residentialLoanAppId));
    }

    public static ResidentialLoanApplicationController.AmlFlagWrapper AmlFlagWrapper( String residentialLoanAppId ) {
        ResidentialLoanApplicationController.AmlFlagWrapper result = new ResidentialLoanApplicationController.AmlFlagWrapper();
        List<AML_Flag__c> amlFlags = [SELECT Id,Resolved__c,Residential_Loan_Application__r.Status
                                                            FROM AML_Flag__c 
                                                            WHERE Residential_Loan_Application__c =: residentialLoanAppId AND Resolved__c = false ]; 

        if( amlFlags.size() > 0 ) {
            result.hasActiveAmlFlags = true;
            result.hasActiveAmlFlagsMsg = 'Unresolved AML Flags';
            result.rlaStatus = amlFlags[0].Residential_Loan_Application__r.Status;
        }
        return result;
    }

    @AuraEnabled
    public static string getValuations(String residentialLoanAppId) {
        return JSON.serialize(ResidentialLoanApplicationController.ValuationWrapper(residentialLoanAppId));
    }

    public static ResidentialLoanApplicationController.ValuationWrapper ValuationWrapper(String residentialLoanAppId) {
        ResidentialLoanApplicationController.ValuationWrapper result = new ResidentialLoanApplicationController.ValuationWrapper();
        
        List<Valuation__c> valuationsList = [SELECT Id, Valuation_Source__c, Valuation_Amount__c, Loan_Application_Property__r.Id, Loan_Application_Property__r.Name
                                              FROM Valuation__c 
                                              WHERE Residential_Loan_Application__c = :residentialLoanAppId 
                                              AND Valuation_Source__c = 'Appraised Value'
                                              AND Loan_Application_Property__r.Property_Type__c = 'Subject Property'
                                              AND Valuation_Amount__c = 0]; 

        Set<String> loanproZeroAppraisalNames = new Set<String>(); 
        
        for (Valuation__c valuation : valuationsList) {
            loanproZeroAppraisalNames.add(valuation.Loan_Application_Property__r.Name);
        }

        if (valuationsList.size() > 0) {
            result.zeroappraisalvalue = true;
            result.zeroappraisalvalueMsg = String.join(new List<String>(loanproZeroAppraisalNames), ' & ');
        }

        return result;
    }
}
/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-02-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class ValuationHandler {
    List<Valuation__c> newValuations = new List<Valuation__c>();
    Map<Id, Valuation__c> oldValuations = new Map<Id, Valuation__c>();

    public ValuationHandler(List<Valuation__c> newRecords, Map<Id, Valuation__c> oldRecords){
        newValuations = newRecords;
        oldValuations = oldRecords;
    }

    public void stopCreatingDuplicatePurchaseValuation(){
        Set<Id> loanPropertyIds = new Set<Id>();
        for ( Valuation__c newValuation : newValuations ) {
            if (oldValuations != null){
                Valuation__c oldValuation = oldValuations.get( newValuation.Id );
                if ( oldValuation != null && oldValuation.Valuation_Source__c != newValuation.Valuation_Source__c 
                    && newValuation.Valuation_Source__c != ApexConstants.APPRAISED_VALUE_SOURCE ) {
                    loanPropertyIds.add( newValuation.Loan_Application_Property__c );
                }
            } else {
                if ( newValuation.Valuation_Source__c != ApexConstants.APPRAISED_VALUE_SOURCE ) {
                    loanPropertyIds.add( newValuation.Loan_Application_Property__c );
                }
            }
        }

        Map<Id,LoanApplicationProperty> loanApplicationPropertiesMap = new Map<Id,LoanApplicationProperty> ( [SELECT
                                                                        Id,
                                                                        ( SELECT 
                                                                                Id,
                                                                                Valuation_Source__c
                                                                         FROM
                                                                            Valuations__r
                                                                         WHERE 
                                                                            Valuation_Source__c !=: ApexConstants.APPRAISED_VALUE_SOURCE
                                                                        )
                                                                    FROM
                                                                        LoanApplicationProperty
                                                                    WHERE Id IN: loanPropertyIds] );
        Map<Id, Set<String>> loanApplicationPropertyIdToValuationSourcesMap = new Map<Id, Set<String>>();
        for ( Id loanApplicationPropertyId : loanApplicationPropertiesMap.KeySet()) {
            if ( loanApplicationPropertiesMap.get(loanApplicationPropertyId).Valuations__r.size() > 0 ) {
                if ( !loanApplicationPropertyIdToValuationSourcesMap.containsKey( loanApplicationPropertyId ) ) {
                    loanApplicationPropertyIdToValuationSourcesMap.put( loanApplicationPropertyId, new Set<String>() );
                }

                for ( Valuation__c valuation : loanApplicationPropertiesMap.get(loanApplicationPropertyId).Valuations__r ) {
                    loanApplicationPropertyIdToValuationSourcesMap.get(loanApplicationPropertyId).add(valuation.Valuation_Source__c);
                }
            }
        }
        for (Valuation__c newValuation : newValuations ) {
            if( loanApplicationPropertyIdToValuationSourcesMap.containsKey(newValuation.Loan_Application_Property__c) &&
            loanApplicationPropertyIdToValuationSourcesMap.get(newValuation.Loan_Application_Property__c).contains(newValuation.Valuation_Source__c)) {
                System.debug( '+++++++++++ ');
                    newValuation.addError(newValuation.Valuation_Source__c + ' valuation record already exists');
            }
        }
    }

    public void updateValuationLoanAppPropertyFields(){
        Set<Id> valuationLoanAppPropertySet = new Set<Id>();
        for(Valuation__c newValuation : newValuations ){
            if(meetsRequirement(newValuation)){ 
                valuationLoanAppPropertySet.add(newValuation.Loan_Application_Property__c);
            }
        }
        
        if(!valuationLoanAppPropertySet.isEmpty()){
            processQualifiedValuations(valuationLoanAppPropertySet);
        }
    }
    
    public void updateValuationLoanAppPropertyFieldsAfterDelete(){
        Set<Id> valuationLoanAppPropertySet = new Set<Id>();
        for(Valuation__c oldValuation : newValuations){
            valuationLoanAppPropertySet.add( oldValuation.Loan_Application_Property__c );
        }
        
        if(!valuationLoanAppPropertySet.isEmpty()){
            processQualifiedValuations(valuationLoanAppPropertySet);
        }
    }
    
    public void processQualifiedValuations(Set<Id> valuationLoanAppPropertySet) {
        Map<Id, LoanApplicationProperty> updatedPropMap = new Map<Id, LoanApplicationProperty>(); 
        Map<Id, Valuation__c> appraisedValuationsMap = new Map<Id, Valuation__c>(); 
        Map<Id, Valuation__c> purchasedValuationsMap = new Map<Id, Valuation__c>(); 
        Map<Id, Valuation__c> purviewValuationsMap = new Map<Id, Valuation__c>(); 
        List<Valuation__c> valuationList = [SELECT Id, Valuation_Source__c, Valuation_Date__c, Valuation_Amount__c, Loan_Application_Property__c
                                            FROM Valuation__c
                                            WHERE Loan_Application_Property__c IN: valuationLoanAppPropertySet ORDER BY Valuation_Date__c DESC NULLS LAST , CreatedDate DESC ];
        for(Valuation__c val : valuationList){
            if ( val.Valuation_Source__c == ApexConstants.APPRAISED_VALUE_SOURCE ) {
                if( !appraisedValuationsMap.containsKey(val.Loan_Application_Property__c)) {
                    appraisedValuationsMap.put( val.Loan_Application_Property__c, val );
                }
            } else if (  val.Valuation_Source__c == ApexConstants.PURCHASE_PRICE_SOURCE ) {
                if( !purchasedValuationsMap.containsKey(val.Loan_Application_Property__c)) {
                    purchasedValuationsMap.put( val.Loan_Application_Property__c, val );
                }
            } else if (  val.Valuation_Source__c == ApexConstants.PURVIEW_PRICE_SOURCE ) {
                if( !purviewValuationsMap.containsKey(val.Loan_Application_Property__c)) {
                    purviewValuationsMap.put( val.Loan_Application_Property__c, val );
                }
            }
        }
        for ( Id valuationLoanAppPropertyId : valuationLoanAppPropertySet) {
            System.debug( valuationLoanAppPropertyId );
            LoanApplicationProperty prop = new LoanApplicationProperty();
            prop.Id = valuationLoanAppPropertyId;
            if( !updatedPropMap.containsKey(valuationLoanAppPropertyId) ) {
                updatedPropMap.put( valuationLoanAppPropertyId, prop );
            }
            if ( appraisedValuationsMap.containsKey( valuationLoanAppPropertyId ) ) {
                Valuation__c val = appraisedValuationsMap.get(valuationLoanAppPropertyId);
                updatedPropMap.get(valuationLoanAppPropertyId).Collateral_Appraisal_Value__c = val.Valuation_Amount__c;
                updatedPropMap.get(valuationLoanAppPropertyId).Collateral_Appraisal_Date__c = val.Valuation_Date__c;
            } else {
                updatedPropMap.get(valuationLoanAppPropertyId).Collateral_Appraisal_Value__c = null;
                updatedPropMap.get(valuationLoanAppPropertyId).Collateral_Appraisal_Date__c = null;
            }

            if ( purchasedValuationsMap.containsKey( valuationLoanAppPropertyId ) ) {
                Valuation__c val = purchasedValuationsMap.get(valuationLoanAppPropertyId);
                updatedPropMap.get(valuationLoanAppPropertyId).Purchase_Price__c = val.Valuation_Amount__c;
            } else {
                updatedPropMap.get(valuationLoanAppPropertyId).Purchase_Price__c = null;
            }

            if ( purviewValuationsMap.containsKey( valuationLoanAppPropertyId ) ) {
                Valuation__c val = purviewValuationsMap.get(valuationLoanAppPropertyId);
                updatedPropMap.get(valuationLoanAppPropertyId).Purview_Value__c = val.Valuation_Amount__c;
            } else {
                updatedPropMap.get(valuationLoanAppPropertyId).Purview_Value__c = null;
            }
        }
        System.debug( updatedPropMap );
        if(!updatedPropMap.isEmpty() && updatedPropMap.values().size() > 0 ) {
            update updatedPropMap.values();
        }
    }
    
    public Boolean meetsRequirement( Valuation__c newLoanApp ) {
        Boolean metRequirements = false;
        if(oldValuations != null){
            Valuation__c oldLoanApp = oldValuations.get( newLoanApp.Id ); 
            if( ( String.isNotBlank(newLoanApp.Valuation_Source__c) && newLoanApp.Valuation_Source__c != oldLoanApp.Valuation_Source__c 
               && newLoanApp.Valuation_Source__c == ApexConstants.APPRAISED_VALUE_SOURCE ) ||
                ( ( newLoanApp.Valuation_Source__c != oldLoanApp.Valuation_Source__c || newLoanApp.Valuation_Amount__c != oldLoanApp.Valuation_Amount__c )  && 
                ( String.isNotBlank(newLoanApp.Valuation_Source__c) && ( newLoanApp.Valuation_Source__c == 'Purview' || newLoanApp.Valuation_Source__c == 'Purchase Price' ) )  ) ) {
                   metRequirements = true; 
               }
        } else{
            if( ( String.isNotBlank(newLoanApp.Valuation_Source__c) && newLoanApp.Valuation_Source__c == ApexConstants.APPRAISED_VALUE_SOURCE ) ||
                ( String.isNotBlank(newLoanApp.Valuation_Source__c) && ( newLoanApp.Valuation_Source__c == 'Purview' || newLoanApp.Valuation_Source__c == 'Purchase Price' ) ) ) {
                metRequirements = true; 
            }
        }
        return metRequirements;
    }
}
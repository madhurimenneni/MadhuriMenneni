public class ValuationController {
    public class valuationWrapper {
        public List<Valuation__c> valuation;
        public Boolean hasData;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Valuation__c> getRlaValuations( String loanApplicationId ) {
        List<Valuation__c> valuations = [SELECT Id,Name,Property_Name__c, Loan_Application_Property__c, Valuation_Amount__c,
                                         Valuation_Source__c, Valuation_Date__c, Default__c, Eligible_for_Selection__c,Appraisal_Company_Name__c
                                         FROM Valuation__c
                                         WHERE Residential_Loan_Application__c =: loanApplicationId];
        return valuations;
    }

    @AuraEnabled(cacheable=true)
    public static List<Valuation__c> getValuations( String loanApplicationPropertyId ) {
        List<Valuation__c> valuations = [SELECT Id,Name, Loan_Application_Property__c, Valuation_Amount__c,
                                         Valuation_Source__c, Valuation_Date__c, Default__c, Eligible_for_Selection__c,Appraisal_Company_Name__c
                                         FROM Valuation__c
                                         WHERE Loan_Application_Property__c =: loanApplicationPropertyId];
        return valuations;
    }

    @AuraEnabled
    public static String getValuation( String loanApplicationPropertyId ) {
        return JSON.serialize(ValuationController.getValuationWrapper(loanApplicationPropertyId));
    } 
    
    public static ValuationController.valuationWrapper getValuationWrapper( String loanApplicationPropertyId ) {
        system.debug('loanApplicationPropertyId: '+loanApplicationPropertyId);
        ValuationController.valuationWrapper result = new ValuationController.valuationWrapper();
        List<Valuation__c> valuations = [SELECT Id, Loan_Application_Property__c, Valuation_Amount__c,
                                         Valuation_Source__c, Valuation_Date__c, Default__c, Eligible_for_Selection__c,Appraisal_Company_Name__c
                                         FROM Valuation__c
                                         WHERE Loan_Application_Property__c =: loanApplicationPropertyId];
        system.debug('valuations: '+valuations.size());
        if(!valuations.isEmpty()){
            result.hasData = true;
            result.valuation = valuations;
        }
        return result;
    }
    @AuraEnabled
    public static  Map<String,String> saveValuation(Map<String, Object> valueinfo) {
        Map<String,String> resultMap = new Map<String,String>();
        try {
            Valuation__c Valuation =new Valuation__c(id=(id)valueinfo.get('Id'));
            string  valAmt=string.valueOf(valueinfo.get('Valuation_Amount__c'));
            system.debug('valAmt+:'+valAmt);
            if(valAmt!=null){
                Valuation.Valuation_Amount__c=decimal.valueof(valAmt);
            }else{
                Valuation.Valuation_Amount__c=null;
            }
            
            Valuation.Valuation_Source__c=(string)valueinfo.get('Valuation_Source__c');
            string valdate=(string)valueinfo.get('Valuation_Date__c');
            if(valdate!='' && valdate!=null){
                Valuation.Valuation_Date__c=Date.valueOf(valdate);
            }else{
                Valuation.Valuation_Date__c=null;
            }
            
            Valuation.Appraisal_Company_Name__c=(string)valueinfo.get('Appraisal_Company_Name__c');
            system.debug('Valuation:'+Valuation);
            update Valuation;
            resultMap.put('status', 'success');
            resultMap.put('message', 'Valuation is updated Successfully');
        }
        catch(Exception e) {
            resultMap.put('status', 'error');
            resultMap.put('message',e.getMessage());
        }
        return resultMap; 
    }
    
    @AuraEnabled
    public static Map<String,String> deleteValuationList(List<Id> valuationIds) {
        List<Valuation__c> valuationsToDelete = [ SELECT Id,Loan_Application_Property__c FROM Valuation__c WHERE Id IN: valuationIds ];
        Map<String,String> resultMap = new Map<String,String>();
        try {
            update new LoanApplicationProperty( Id = valuationsToDelete[0].Loan_Application_Property__c );
            delete valuationsToDelete;
            resultMap.put('status', 'success');
            resultMap.put('message', 'Valuation is Deleted Successfully');        
        }
        catch(Exception e) {
            resultMap.put('status', 'error');
            resultMap.put('message',e.getMessage());
        }
        return resultMap;                
    }
    
    @AuraEnabled
    public static Map<String,String> calculatePropetyValueAction( String selectedVal ) {
        Map<String,String> resultMap = new Map<String,String>();
        system.debug('selectedVal: '+selectedVal);
        Valuation__c  valuationsToDelete = [SELECT Id, Valuation_Amount__c, Loan_Application_Property__c, Valuation_Source__c, Valuation_Date__c, Default__c
                                            FROM Valuation__c 
                                            WHERE Id =: selectedVal];
        Update new Valuation__c( Id = valuationsToDelete.Id, Default__c = true );
        
        LoanApplicationProperty loanAppProperty = [SELECT Id, Property_Type__c, Property_Value__c, Valuation_Source__c, Valuation_Date__c,
                                                   Collateral_Appraisal_Value__c, Collateral_Appraisal_Date__c, LoanApplicationId
                                                   FROM LoanApplicationProperty 
                                                   WHERE Id =: valuationsToDelete.Loan_Application_Property__c];
        system.debug('loanAppProperty: '+loanAppProperty);
        LoanApplicationProperty updateLoanAppProperty = new LoanApplicationProperty();
        if( loanAppProperty != null && (loanAppProperty.Property_Type__c == ApexConstants.SUBJECT_PROPERTY_TYPE ||loanAppProperty.Property_Type__c == 'Asset Property')){
            updateLoanAppProperty.Id = loanAppProperty.Id;
            updateLoanAppProperty.Property_Value__c = valuationsToDelete.Valuation_Amount__c;
            updateLoanAppProperty.Valuation_Source__c = valuationsToDelete.Valuation_Source__c;
            if( valuationsToDelete.Valuation_Source__c == ApexConstants.APPRAISED_VALUE_VALUATION_SOURCE ) {
                updateLoanAppProperty.Valuation_Date__c = valuationsToDelete.Valuation_Date__c;
                updateLoanAppProperty.Collateral_Appraisal_Date__c = valuationsToDelete.Valuation_Date__c;
            } else{
                updateLoanAppProperty.Valuation_Date__c = valuationsToDelete.Valuation_Date__c;
                updateLoanAppProperty.Collateral_Appraisal_Date__c = null;
                updateLoanAppProperty.Collateral_Appraisal_Value__c = null;
            }
            
            system.debug('updateLoanAppProperty: '+updateLoanAppProperty);
            update updateLoanAppProperty;
            
            List<Valuation__c> appraisedValuationList = [SELECT Id, Valuation_Source__c, Valuation_Date__c, Valuation_Amount__c, Loan_Application_Property__c
                                                         FROM Valuation__c
                                                         WHERE Loan_Application_Property__c =: valuationsToDelete.Loan_Application_Property__c
                                                         AND Valuation_Source__c =: ApexConstants.APPRAISED_VALUE_SOURCE
                                                         ORDER BY  Valuation_Date__c DESC LIMIT 1];
            system.debug('appraisedValuationList: '+appraisedValuationList);
            List< LoanApplicationProperty> updatedPropList = new List<LoanApplicationProperty>();  
            if (!appraisedValuationList.isEmpty()) {
                for ( Valuation__c val : appraisedValuationList ) {
                    LoanApplicationProperty prop = new LoanApplicationProperty();
                    prop.Id = val.Loan_Application_Property__c;
                    prop.Collateral_Appraisal_Value__c = val.Valuation_Amount__C;
                    prop.Collateral_Appraisal_Date__c = val.Valuation_Date__c;
                    updatedPropList.add( prop );
                }
            } else if( appraisedValuationList.isEmpty() && valuationsToDelete.Loan_Application_Property__c != null){
                LoanApplicationProperty prop = new LoanApplicationProperty();
                prop.Id = valuationsToDelete.Loan_Application_Property__c;
                prop.Collateral_Appraisal_Value__c = null;
                prop.Collateral_Appraisal_Date__c = null;
                updatedPropList.add( prop );
            }
            system.debug('updatedPropList: '+updatedPropList.size());
            if( updatedPropList.size() > 0 ) {
                update updatedPropList;
            }
            if(loanAppProperty.Property_Type__c == ApexConstants.SUBJECT_PROPERTY_TYPE){
            ResidentialLoanApplication loanApp = [SELECT Id, EstateHoldType, Loan_Amount__c, LTV__c, Property_Value__c, cLTV__c
                                                  FROM ResidentialLoanApplication
                                                  WHERE Id =: loanAppProperty.LoanApplicationId ];
            Map<Id,Decimal> loanAppWithLTVBalanceMap = new Map<Id,Decimal>();
            Map<Id,Decimal> loanAppWithcLTVBalanceMap = new Map<Id,Decimal>();
            List<LoanApplicationLiability> liabilityList = [SELECT Id, LoanApplicationId, Loan_Application_Property__r.Property_Type__c,
                                                            Loan_Application_Property__r.Collateral_Position__c, Liability_Type__c, Balance__c, Payoff__c,
                                                            Liability_Status__c, Position__c
                                                            FROM  LoanApplicationLiability
                                                            WHERE  LoanApplicationId =: loanAppProperty.LoanApplicationId AND Liability_Type__c =: ApexConstants.MORTGAGE_LIABILITY_TYPE
                                                            AND  Balance__c !=: null AND Payoff__c =: ApexConstants.NO_PAYOFF AND Loan_Application_Property__r.Property_Type__c =: ApexConstants.SUBJECT_PROPERTY_TYPE ];
            
            Decimal liabilityBalanceForLTV = 0;
            Decimal liabilityBalanceForcLTV = 0;
            for( LoanApplicationLiability liability : liabilityList ){
                system.debug(liability.Position__c + ' '+liability.Loan_Application_Property__r.Collateral_Position__c);
                if ( liability.Position__c < liability.Loan_Application_Property__r.Collateral_Position__c ) {
                    liabilityBalanceForLTV = liabilityBalanceForLTV + liability.Balance__c;
                }
                liabilityBalanceForcLTV = liabilityBalanceForcLTV + liability.Balance__c;
                loanAppWithLTVBalanceMap.put( liability.LoanApplicationId, liabilityBalanceForLTV );
                loanAppWithcLTVBalanceMap.put( liability.LoanApplicationId, liabilityBalanceForcLTV );
            }
            
            Decimal LTV = 0;
            Decimal cLTV = 0;
            
            ResidentialLoanApplication newRLApp = new ResidentialLoanApplication();
            newRLApp.Id = loanApp.Id;system.debug(loanApp.Id+' '+loanApp.Property_Value__c+' '+loanApp.Loan_Amount__c);
            if(loanApp.Property_Value__c != 0 && loanApp.Loan_Amount__c != null){
                if ( loanAppWithLTVBalanceMap.KeySet().Size() > 0 ){
                    LTV = ((loanAppWithLTVBalanceMap.get(newRLApp.Id) + loanApp.Loan_Amount__c)/loanApp.Property_Value__c)*100;
                } else{
                    LTV = (loanApp.Loan_Amount__c/loanApp.Property_Value__c)*100;
                }
                if( loanAppWithcLTVBalanceMap.KeySet().Size() > 0 ) {
                    cLTV = ((loanAppWithcLTVBalanceMap.get(newRLApp.Id) + loanApp.Loan_Amount__c)/loanApp.Property_Value__c)*100;
                } else{
                    cLTV = (loanApp.Loan_Amount__c/loanApp.Property_Value__c)*100;
                }
            }
            
            newRLApp.LTV__c = LTV.setScale(2);   
            newRLApp.cLTV__c = cLTV.setScale(2); 
            if( loanApp.EstateHoldType == null ) {
                resultMap.put('status', 'error');
                resultMap.put('message','Lenders Lien Type is blank');
            } else{
                try{
                    update newRLApp;
                    resultMap.put('status', 'success');
                    resultMap.put('message', 'Valuation is calculated Successfully'); 
                } catch( DmlException e ) {
                    resultMap.put('status', 'error');
                    resultMap.put('message',e.getMessage());
                }
            }
            }else{
                 resultMap.put('status', 'success');
                 resultMap.put('message', 'Valuation submitted Successfully');
            }
        } else {
            resultMap.put('status', 'error');
            resultMap.put('message','Subject Property is unchecked');
        } 
        return resultMap;
    }
    
    @AuraEnabled
    public static void updateDefaultAction( String selectedVal, Boolean isChecked, String propertyRecordId ) {
        system.debug('updateDefaultAction');
        List<Valuation__c> updateValuationList = new List<Valuation__c>();
        List<Valuation__c> valuationsToDelete = [SELECT Id, Valuation_Amount__C, Loan_Application_Property__c, Valuation_Source__c,
                                                 Valuation_Date__c, Default__c
                                                 FROM  Valuation__c 
                                                 WHERE Loan_Application_Property__c =: propertyRecordId ];
        for( Valuation__c valuationDelete : valuationsToDelete ) {
            if( valuationDelete.Id == selectedVal ) {
                valuationDelete.Default__c = true;
                updateValuationList.add(valuationDelete);
            } else {
                valuationDelete.Default__c = false;
                updateValuationList.add(valuationDelete);
            }
        }
        if( updateValuationList.size() > 0 ) {
            update updateValuationList;
        }
    }
    
    @AuraEnabled
    public static void updateDefaultActionOnDeletion( String selectedVal, Boolean isChecked, String propertyRecordId ) {
        system.debug('updateDefaultAction');
        List<Valuation__c> updateValuationList = new List<Valuation__c>();
        List<Valuation__c> valuationsToDelete = [SELECT Id, Valuation_Amount__c, Loan_Application_Property__c, Valuation_Source__c,
                                                 Valuation_Date__c, Default__c
                                                 FROM Valuation__c 
                                                 WHERE Loan_Application_Property__c =: propertyRecordId];
        for( Valuation__c valuationDelete : valuationsToDelete ) {
            if( valuationDelete.Id == selectedVal ) {
                valuationDelete.Default__c = false;
                updateValuationList.add(valuationDelete);
            } 
        }
        if( updateValuationList.size() > 0 ) {
            update updateValuationList;
        }
    } 
}
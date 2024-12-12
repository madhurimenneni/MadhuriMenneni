public class LoanApplicationLiabilityHandler {
    List<LoanApplicationLiability> newLoanApplicantionLiabilities = new List<LoanApplicationLiability>();
    Map<Id, LoanApplicationLiability> oldLoanApplicantionLiabilities = new Map<Id, LoanApplicationLiability>();
    public LoanApplicationLiabilityHandler( List<LoanApplicationLiability> newRecords, Map<Id, LoanApplicationLiability> oldRecordsMap ) {
        newLoanApplicantionLiabilities = newRecords;
        oldLoanApplicantionLiabilities = oldRecordsMap;
    }
    
    public void calculateRLAValues(){
        Set<Id> ltvAndCltvCalculationQualifiedIds = new Set<Id>();
        Set<Id> sumOfLiabilitiesPaidFromProceedsQualifiedIds = new Set<Id>();
        Set<Id> sumOfOtherDebtObligationsIds = new Set<Id>();
        Set<Id> sumOfMonthlyMortgagePaymentIds = new Set<Id>();
        Set<Id> sumOfOutStandingBalanceIds = new Set<Id>();
        Set<Id> sumOfTotalMonthlyPaymentAndOutstandingBalances = new Set<Id>();
        Map<Id, List<LoanApplicationLiability>> residentialLoanAppIdMap = new Map<Id, List<LoanApplicationLiability>>();
        for ( LoanApplicationLiability newLoanAppLiability : newLoanApplicantionLiabilities ) {
            if ( oldLoanApplicantionLiabilities != null ) {
                LoanApplicationLiability oldLoanAppLiability = oldLoanApplicantionLiabilities.get( newLoanAppLiability.Id ); 
                if ( (newLoanAppLiability.Liability_Type__c != oldLoanAppLiability.Liability_Type__c
                      && newLoanAppLiability.Liability_Type__c == ApexConstants.MORTGAGE_LIABILITY_TYPE) || 
                    (newLoanAppLiability.Balance__c != oldLoanAppLiability.Balance__c)|| 
                    (newLoanAppLiability.Payoff__c != oldLoanAppLiability.Payoff__c
                     && newLoanAppLiability.Payoff__c == ApexConstants.NO_PAYOFF) || 
                    newLoanAppLiability.Liability_Status__c != oldLoanAppLiability.Liability_Status__c || 
                    newLoanAppLiability.Position__c != oldLoanAppLiability.Position__c ) {
                        ltvAndCltvCalculationQualifiedIds.add( newLoanAppLiability.LoanApplicationId );
                    }
                
                if ( (newLoanAppLiability.Balance__c != oldLoanAppLiability.Balance__c
                      || newLoanAppLiability.Payoff__c != oldLoanAppLiability.Payoff__c)
                    && newLoanAppLiability.Balance__c != null ) {
                            sumOfLiabilitiesPaidFromProceedsQualifiedIds.add(newLoanAppLiability.LoanApplicationId);
                        }
                if ( (newLoanAppLiability.Balance__c != oldLoanAppLiability.Balance__c
                    || newLoanAppLiability.Payoff__c != oldLoanAppLiability.Payoff__c 
                    || newLoanAppLiability.Monthly_Payment__c != oldLoanAppLiability.Monthly_Payment__c)) {
                        sumOfOtherDebtObligationsIds.add(newLoanAppLiability.LoanApplicationId);
                        }

                if ( (newLoanAppLiability.Liability_Type__c != oldLoanAppLiability.Liability_Type__c
                        && newLoanAppLiability.Liability_Type__c == ApexConstants.MORTGAGE_LIABILITY_TYPE) || 
                      (newLoanAppLiability.Balance__c != oldLoanAppLiability.Balance__c && newLoanAppLiability.Balance__c != null )|| 
                      (newLoanAppLiability.Monthly_Payment__c != oldLoanAppLiability.Monthly_Payment__c && newLoanAppLiability.Monthly_Payment__c != null ) ) {
                        sumOfMonthlyMortgagePaymentIds.add(newLoanAppLiability.LoanApplicationId);
                        sumOfOutStandingBalanceIds.add(newLoanAppLiability.LoanApplicationId);
                      }
                if ( ( newLoanAppLiability.Balance__c != oldLoanAppLiability.Balance__c )|| 
                    (newLoanAppLiability.Monthly_Payment__c != oldLoanAppLiability.Monthly_Payment__c ) ) {
                    sumOfTotalMonthlyPaymentAndOutstandingBalances.add(newLoanAppLiability.LoanApplicationId);
                }
                
            } else {
                if ( newLoanAppLiability.Liability_Type__c == ApexConstants.MORTGAGE_LIABILITY_TYPE
                    || newLoanAppLiability.Payoff__c == ApexConstants.NO_PAYOFF ){
                        ltvAndCltvCalculationQualifiedIds.add( newLoanAppLiability.LoanApplicationId );
                    }
                
                if ( newLoanAppLiability.Balance__c != null ){
                            sumOfLiabilitiesPaidFromProceedsQualifiedIds.add(newLoanAppLiability.LoanApplicationId);
                        }
                if ( newLoanAppLiability.Balance__c != null
                && ( newLoanAppLiability.Payoff__c != ApexConstants.PAY_FROM_PROCEEDS_PAYOFF &&
                    newLoanAppLiability.Payoff__c != ApexConstants.BEFORE_ADVANCE_PAYOFF) ){
                        sumOfOtherDebtObligationsIds.add(newLoanAppLiability.LoanApplicationId);
                    }
                if ( newLoanAppLiability.Balance__c != null
                && ( newLoanAppLiability.Liability_Type__c == ApexConstants.MORTGAGE_LIABILITY_TYPE &&
                    newLoanAppLiability.Monthly_Payment__c != null) ){
                        sumOfMonthlyMortgagePaymentIds.add(newLoanAppLiability.LoanApplicationId);
                        sumOfOutStandingBalanceIds.add(newLoanAppLiability.LoanApplicationId);
                    }

                    if ( newLoanAppLiability.Balance__c != null
                    && ( newLoanAppLiability.Liability_Type__c == ApexConstants.MORTGAGE_LIABILITY_TYPE &&
                        newLoanAppLiability.Monthly_Payment__c != null) ){
                        }

                    sumOfTotalMonthlyPaymentAndOutstandingBalances.add( newLoanAppLiability.LoanApplicationId );
            }
        }
        
        Map<Id,ResidentialLoanApplication> loanAppWithLialibityBalanceMap = new Map<Id,ResidentialLoanApplication>();
        
        List<ResidentialLoanApplication> loanAppList = [SELECT Id, Sum_of_Liabilities_Paid_From_Proceeds__c, Loan_Amount__c, Property_Value__c,
                                                        (SELECT Id, LoanApplicationId, Loan_Application_Property__r.Property_Type__c, Loan_Application_Property__r.Collateral_Position__c, Liability_Type__c,
                                                         Balance__c, Liability_Status__c, Position__c, Payoff__c, Loan_Application_Property__c, Monthly_Payment__c
                                                         FROM LoanApplicationLiabilities WHERE Balance__c != null)
                                                        FROM ResidentialLoanApplication
                                                        WHERE Id IN: sumOfLiabilitiesPaidFromProceedsQualifiedIds OR Id IN: ltvAndCltvCalculationQualifiedIds OR Id IN: sumOfOtherDebtObligationsIds OR 
                                                        Id IN: sumOfMonthlyMortgagePaymentIds OR Id IN: sumOfOutStandingBalanceIds OR Id IN: sumOfTotalMonthlyPaymentAndOutstandingBalances];
        Map<Id,Decimal> loanAppWithLTVBalanceMap = new Map<Id,Decimal>();
        Map<Id,Decimal> loanAppWithcLTVBalanceMap = new Map<Id,Decimal>();
        Map<Id,Decimal> loanAppWithLoanAmountBehindMap = new Map<Id,Decimal>();
        Map<Id,LoanApplicationProperty> loanPropWithMonthlyMortgagePaymentMap= new Map<Id,LoanApplicationProperty>();
        
        for(ResidentialLoanApplication app : loanAppList){
            Decimal liabilityBalance = 0;
            Decimal loanAmountBehind = 0;
            Decimal liabilityBalanceForLTV = 0;
            Decimal liabilityBalanceForcLTV = 0;
            Decimal otherDebtObligations = 0;
            Decimal totalLiabilitiesMonthlyPayment = 0;
            Decimal totalLiabilitiesOutstandingBalance = 0;
            Decimal LTV = 0;
            Decimal cLTV = 0;
            if( app.LoanApplicationLiabilities.size() > 0 ){
                for ( LoanApplicationLiability liability : app.LoanApplicationLiabilities ) {
                    if( sumOfLiabilitiesPaidFromProceedsQualifiedIds.contains(liability.LoanApplicationId) && liability.Payoff__c == ApexConstants.PAY_FROM_PROCEEDS_PAYOFF ) {
                        liabilityBalance = liabilityBalance + liability.Balance__c;
                    }
                    app.Sum_of_Liabilities_Paid_From_Proceeds__c = liabilityBalance;
                    
                    if( ltvAndCltvCalculationQualifiedIds.contains( liability.LoanApplicationId )
                       && liability.Liability_Type__c == ApexConstants.MORTGAGE_LIABILITY_TYPE
                       && liability.Payoff__c == ApexConstants.NO_PAYOFF
                       && liability.Loan_Application_Property__r.Property_Type__c == ApexConstants.SUBJECT_PROPERTY_TYPE ) {
                           if ( !residentialLoanAppIdMap.containsKey(liability.LoanApplicationId)){
                               residentialLoanAppIdMap.put(liability.LoanApplicationId, new List<LoanApplicationLiability>());
                           }
                           
                           residentialLoanAppIdMap.get( liability.LoanApplicationId).add(liability);
                           
                           if ( liability.Position__c < liability.Loan_Application_Property__r.Collateral_Position__c ) {
                               liabilityBalanceForLTV = liabilityBalanceForLTV + liability.Balance__c;
                           }
                           if (liability.Position__c > liability.Loan_Application_Property__r.Collateral_Position__c
                               && liability.Liability_Status__c == 'New') {
                                   loanAmountBehind += liability.Balance__c;
                               }
                           liabilityBalanceForcLTV = liabilityBalanceForcLTV + liability.Balance__c;
                           
                           loanAppWithLTVBalanceMap.put( app.Id, liabilityBalanceForLTV );
                           loanAppWithcLTVBalanceMap.put( app.Id, liabilityBalanceForcLTV );
                           loanAppWithLoanAmountBehindMap.put( app.Id, loanAmountBehind);
                       }

                       if( sumOfOtherDebtObligationsIds.contains(liability.LoanApplicationId ) && liability.Monthly_Payment__c != null && liability.Payoff__c != ApexConstants.PAY_FROM_PROCEEDS_PAYOFF &&
                       liability.Payoff__c != ApexConstants.BEFORE_ADVANCE_PAYOFF) {
                            otherDebtObligations += liability.Monthly_Payment__c * 12;
                            app.Other_Debt_Obligations__c = otherDebtObligations;
                       }

                       if( sumOfMonthlyMortgagePaymentIds.contains(liability.LoanApplicationId) && 
                            liability.Liability_Type__c == ApexConstants.MORTGAGE_LIABILITY_TYPE && 
                            liability.Monthly_Payment__c != null && 
                            liability.Loan_Application_Property__c != null) {
                                if( !loanPropWithMonthlyMortgagePaymentMap.containsKey(liability.Loan_Application_Property__c) ) {
                                    loanPropWithMonthlyMortgagePaymentMap.put(liability.Loan_Application_Property__c, new LoanApplicationProperty(Id = liability.Loan_Application_Property__c, Monthly_Mortgage_Payment__c = 0, Prior_Charges__c = 0));
                                }

                                loanPropWithMonthlyMortgagePaymentMap.get(liability.Loan_Application_Property__c).Monthly_Mortgage_Payment__c += liability.Monthly_Payment__c;
                            }
                        
                        if( sumOfOutStandingBalanceIds.contains(liability.LoanApplicationId) &&
                            liability.Balance__c != null &&
                            liability.Position__c != null &&
                            liability.Loan_Application_Property__r.Collateral_Position__c != null &&
                            liability.Position__c < liability.Loan_Application_Property__r.Collateral_Position__c && 
                            liability.Loan_Application_Property__c != null &&
                            liability.Loan_Application_Property__r.Property_Type__c == ApexConstants.SUBJECT_PROPERTY_TYPE
                            ) {
                                if( !loanPropWithMonthlyMortgagePaymentMap.containsKey(liability.Loan_Application_Property__c) ) {
                                    loanPropWithMonthlyMortgagePaymentMap.put(liability.Loan_Application_Property__c,new LoanApplicationProperty(Id = liability.Loan_Application_Property__c, Prior_Charges__c = 0));
                                }
                                System.debug(loanPropWithMonthlyMortgagePaymentMap);
                                loanPropWithMonthlyMortgagePaymentMap.get(liability.Loan_Application_Property__c).Prior_Charges__c += liability.Balance__c;
                            }

                            if ( sumOfTotalMonthlyPaymentAndOutstandingBalances.contains(liability.LoanApplicationId) && liability.Payoff__c == ApexConstants.NO_PAYOFF ) {
                                if( liability.Monthly_Payment__c != null ) {
                                    totalLiabilitiesMonthlyPayment += liability.Monthly_Payment__c;
                                    app.Total_Liabilities_Monthly_Payment__c = totalLiabilitiesMonthlyPayment;
                                }

                                if( liability.Balance__c != null ) {
                                    totalLiabilitiesOutstandingBalance += liability.Balance__c;
                                    app.Total_Liabilities_Outstanding_Balance__c = totalLiabilitiesOutstandingBalance;

                                }
                            }
                }
            }
            
            
            if( ltvAndCltvCalculationQualifiedIds.contains(app.Id)) {
                if( loanAppWithLoanAmountBehindMap.containsKey( app.Id ) ) {
                    loanAmountBehind = (loanAppWithLoanAmountBehindMap.get(app.Id));
                }
                if(app.Property_Value__c != 0){
                    if ( loanAppWithLTVBalanceMap.KeySet().Size() > 0 && loanAppWithLTVBalanceMap.get(app.Id) != null
                        && app.Property_Value__c != null && app.Loan_Amount__c != null){
                            LTV = ((loanAppWithLTVBalanceMap.get(app.Id) + app.Loan_Amount__c)/app.Property_Value__c)*100;
                        } else {
                            if( app.Loan_Amount__c != null && app.Property_Value__c != null ){
                                LTV = (app.Loan_Amount__c/app.Property_Value__c)*100;
                            }
                        }
                    if(loanAppWithcLTVBalanceMap.KeySet().Size() > 0 && loanAppWithcLTVBalanceMap.get(app.Id) != null
                       && app.Loan_Amount__c != null && app.Property_Value__c != null ) {
                           cLTV = ((loanAppWithcLTVBalanceMap.get(app.Id) + app.Loan_Amount__c)/app.Property_Value__c)*100;
                       } else{
                           if( app.Loan_Amount__c != null && app.Property_Value__c != null ){
                               cLTV = (app.Loan_Amount__c/app.Property_Value__c)*100;
                           }
                       }
                }
                app.LTV__c = LTV.setScale(2);   
                app.cLTV__c = cLTV.setScale(2); 
                app.Loan_Amount_Behind__c = loanAmountBehind.setScale(2);
            }
            
            
            loanAppWithLialibityBalanceMap.put( app.Id, app );
        }
        if( !loanAppWithLialibityBalanceMap.isEmpty() ) {
            update loanAppWithLialibityBalanceMap.values();
        }

        if ( !loanPropWithMonthlyMortgagePaymentMap.isEmpty() ) {
            update loanPropWithMonthlyMortgagePaymentMap.values();
        }
    }
    
    public void updateLoanApplicationLiabilities(){
        Set<Id> loanAppIdSet = new Set<Id>();
        for ( LoanApplicationLiability newLoanAppLiability : newLoanApplicantionLiabilities ) { 
            loanAppIdSet.add( newLoanAppLiability.LoanApplicationId );
        }
        List<ResidentialLoanApplication> loanApps = [SELECT Id, Primary_Applicant__c FROM ResidentialLoanApplication WHERE Id IN: loanAppIdSet];
        Map<Id,Id> loanAppMap = new Map<Id,Id>();
        for( ResidentialLoanApplication loanApp : loanApps ){
            loanAppMap.put( loanApp.Id, loanApp.Primary_Applicant__c );
        }
        for ( LoanApplicationLiability newLoanAppLiability : newLoanApplicantionLiabilities ) { 
            //to update primary applicant on liability record insertion
            if( loanAppMap.containsKey( newLoanAppLiability.LoanApplicationId ) ){
                newLoanAppLiability.Primary_Applicant__c = loanAppMap.get( newLoanAppLiability.LoanApplicationId );
            }
            
            if( oldLoanApplicantionLiabilities == null ) {
                if( newLoanAppLiability.Monthly_Payment__c == null &&
                    newLoanAppLiability.Balance__c != null &&  
                    newLoanAppLiability.Interest_Rate__c != null && 
                    newLoanAppLiability.Liability_Type__c == 'Mortgage' && 
                    newLoanAppLiability.Liability_Status__c == 'New') {
                       newLoanAppLiability.Monthly_Payment__c = (newLoanAppLiability.Balance__c * newLoanAppLiability.Interest_Rate__c)/(100 * 12 );
                   } else if(newLoanAppLiability.Monthly_Payment__c == null ) {
                        newLoanAppLiability.Monthly_Payment__c = ( (newLoanAppLiability.Balance__c != null ? newLoanAppLiability.Balance__c : 0 ) * ( newLoanAppLiability.Interest_Rate__c != null ? newLoanAppLiability.Interest_Rate__c : 3 ) )/(100 * 12 );
                   }
            } 
            // else {
            //     LoanApplicationLiability oldLoanAppLiability = oldLoanApplicantionLiabilities.get(newLoanAppLiability.Id);
            //     if ( oldLoanAppLiability.Balance__c != newLoanAppLiability.Balance__c || oldLoanAppLiability.Interest_Rate__c != newLoanAppLiability.Interest_Rate__c || newLoanAppLiability.Monthly_Payment__c != oldLoanAppLiability.Monthly_Payment__c) {
            //         newLoanAppLiability.Monthly_Payment__c = ( (newLoanAppLiability.Balance__c != null ? newLoanAppLiability.Balance__c : 0 ) * ( newLoanAppLiability.Interest_Rate__c != null ? newLoanAppLiability.Interest_Rate__c : 3 ) )/(100 * 12 );
            //     }
            // }
        }
    } 
    
    public LoanApplicationLiabilityHandler lockLoanApplicantionLiability(){
        Id profileId = userInfo.getProfileId();
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Edit_Complete_Applications');
        if(!hasCustomPermission && ApexConstants.getProfileId != profileId){
            Map<Id,LoanApplicationLiability> loanAppIdWithLiabilityMap = new Map<Id,LoanApplicationLiability>();
            for ( LoanApplicationLiability newLoanApplicationLiability : newLoanApplicantionLiabilities ) {
                if ( oldLoanApplicantionLiabilities != null ) {
                    LoanApplicationLiability oldLoanApplicationLiability = oldLoanApplicantionLiabilities.get( newLoanApplicationLiability.Id );
                    if ( oldLoanApplicationLiability != newLoanApplicationLiability ) {
                        loanAppIdWithLiabilityMap.put( newLoanApplicationLiability.LoanApplicationId,newLoanApplicationLiability  );
                    }
                } 
            }
            List<ResidentialLoanApplication> appList = new List<ResidentialLoanApplication>();
            Set<Id> completeLoanApplicationIdSet = new Set<Id>();
            if( loanAppIdWithLiabilityMap.keySet().size() > 0 ){
                appList = [SELECT Id, Status FROM ResidentialLoanApplication WHERE Id IN: loanAppIdWithLiabilityMap.keySet()];
                for( ResidentialLoanApplication app : appList ){
                    if( app.Status == ApexConstants.COMPLETE_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS ){
                        completeLoanApplicationIdSet.add( app.Id );
                    }
                }
            }
            if( completeLoanApplicationIdSet.size() > 0 ){
                for ( LoanApplicationLiability newLoanApplicationLiability : newLoanApplicantionLiabilities ) {
                    if( completeLoanApplicationIdSet.contains(newLoanApplicationLiability.LoanApplicationId) ){
                        newLoanApplicationLiability.addError('You can not edit this record');
                    }
                }
            }
        }
        return this;
    }
}
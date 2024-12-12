public with sharing class LoanApplicationPropertyAmlFlagsHelper {
    List<LoanApplicationProperty> newLoanApplicationProperties = new List<LoanApplicationProperty>();
    Map<Id, LoanApplicationProperty> oldLoanApplicationProperties = new Map<Id, LoanApplicationProperty>();
    
    public LoanApplicationPropertyAmlFlagsHelper( List<LoanApplicationProperty> newRecords, Map<Id, LoanApplicationProperty> oldRecords ) {
        newLoanApplicationProperties = newRecords;
        oldLoanApplicationProperties = oldRecords;
    }

    public void insertLoanApplicationPropertyAmlFlag(){
        Map<Id, Map<String, Boolean>> residentialLoanAppIdToFlagBooleansMap = new Map<Id, Map<String, Boolean>>();
        List<Aml_Flag__c> newAmlRecordsToUpsert = new List<Aml_Flag__c>();
        Map<Id, Map<String, Boolean>> loanApplicationPropertyIdToFlagBooleansMap = new Map<Id, Map<String, Boolean>>();
        Decimal thresholdPercentage = Decimal.valueOf( Utils.apexStaticComponentsMap.get('Threshold % to check for Appraisal').Value__c );
        for ( LoanApplicationProperty newLoanApplicationProperty : newLoanApplicationProperties ) {
            if (oldLoanApplicationProperties != null) {
                LoanApplicationProperty oldLoanApplicationProperty = oldLoanApplicationProperties.get(newLoanApplicationProperty.Id);
                if ( newLoanApplicationProperty.Property_Type__c == 'Subject Property' &&
                    ( newLoanApplicationProperty.Construction_Type__c == 'Existing' || 
                      newLoanApplicationProperty.Construction_Type__c == null ) &&
                    ( newLoanApplicationProperty.Purchase_Price__c != oldLoanApplicationProperty.Purchase_Price__c ||
                    newLoanApplicationProperty.Construction_Type__c != oldLoanApplicationProperty.Construction_Type__c) ) {
                    if ( !loanApplicationPropertyIdToFlagBooleansMap.containsKey(newLoanApplicationProperty.Id) ) {
                        loanApplicationPropertyIdToFlagBooleansMap.put(newLoanApplicationProperty.Id, new Map<String, Boolean>());
                    }
                    loanApplicationPropertyIdToFlagBooleansMap.get(newLoanApplicationProperty.Id).put( 'createPurchasePriceFlag', true );
                    
                    if ( !residentialLoanAppIdToFlagBooleansMap.containsKey(newLoanApplicationProperty.LoanApplicationId)) {
                        residentialLoanAppIdToFlagBooleansMap.put(newLoanApplicationProperty.LoanApplicationId, new Map<String, Boolean>());
                    }
                    residentialLoanAppIdToFlagBooleansMap.get( newLoanApplicationProperty.LoanApplicationId ).put( 'createPurchasePriceFlag', true );
                } else if ( newLoanApplicationProperty.Property_Type__c == 'Subject Property' &&
                    newLoanApplicationProperty.Construction_Type__c != 'Existing' && 
                    newLoanApplicationProperty.Construction_Type__c != null &&
                    newLoanApplicationProperty.Construction_Type__c != oldLoanApplicationProperty.Construction_Type__c ) {
                        if ( !loanApplicationPropertyIdToFlagBooleansMap.containsKey(newLoanApplicationProperty.Id) ) {
                            loanApplicationPropertyIdToFlagBooleansMap.put(newLoanApplicationProperty.Id, new Map<String, Boolean>());
                        }
                        loanApplicationPropertyIdToFlagBooleansMap.get(newLoanApplicationProperty.Id).put( 'resolvePurchasePriceFlag', true );
                        
                        if ( !residentialLoanAppIdToFlagBooleansMap.containsKey(newLoanApplicationProperty.LoanApplicationId)) {
                            residentialLoanAppIdToFlagBooleansMap.put(newLoanApplicationProperty.LoanApplicationId, new Map<String, Boolean>());
                        }
                        residentialLoanAppIdToFlagBooleansMap.get( newLoanApplicationProperty.LoanApplicationId ).put( 'resolvePurchasePriceFlag', true );
                }
            }
        }
        
        if ( residentialLoanAppIdToFlagBooleansMap.isEmpty() ) {
            return;
        }
        Map<Id, Map<String,Aml_Flag__c>> residentialLoanAppIdToAlmRecordsMap = new Map<Id, Map<String,Aml_Flag__c>>();

        Map<Id, ResidentialLoanApplication> qualifiedRlas = new Map<Id, ResidentialLoanApplication>([SELECT Id,
                                                                                                            (SELECT 
                                                                                                                    Id, 
                                                                                                                    Property_Value__c,
                                                                                                                    Collateral_Appraisal_Value__c,
                                                                                                                    Purchase_Price__c,
                                                                                                                    Name,
                                                                                                                    ( SELECT 
                                                                                                                            Id,
                                                                                                                            Valuation_Amount__c,
                                                                                                                            Valuation_Date__c,
                                                                                                                            Valuation_Source__c
                                                                                                                      FROM 
                                                                                                                            Valuations__r
                                                                                                                      WHERE 
                                                                                                                            Valuation_Source__c = 'Appraised Value'
                                                                                                                      ORDER BY  Valuation_Amount__c ASC )
                                                                                                            FROM 
                                                                                                                    LoanApplicationProperties 
                                                                                                            WHERE 
                                                                                                                    Property_Type__c = 'Subject Property' 
                                                                                                                                    AND 
                                                                                                                    Id IN: loanApplicationPropertyIdToFlagBooleansMap.keySet() 
                                                                                                            ORDER BY Property_Value__c DESC),
                                                                                                            (SELECT 
                                                                                                                    Id, 
                                                                                                                    Type__c, 
                                                                                                                    Residential_Loan_Application__c,
                                                                                                                    Resolved__c,
                                                                                                                    Related_Applicant__c,
                                                                                                                    Related_Property__c,
                                                                                                                    Description__c
                                                                                                            FROM 
                                                                                                                    AmlFlags__r)
                                                                                                    FROM 
                                                                                                        ResidentialLoanApplication 
                                                                                                    WHERE 
                                                                                                        Id IN: residentialLoanAppIdToFlagBooleansMap.keySet()]);

        for ( String rlaId : qualifiedRlas.keySet() ) {
            residentialLoanAppIdToAlmRecordsMap.put( rlaId, new Map<String,Aml_Flag__c>());
            for ( Aml_Flag__c amlFlagRecord : qualifiedRlas.get(rlaId).AmlFlags__r ) {
                residentialLoanAppIdToAlmRecordsMap.get( amlFlagRecord.Residential_Loan_Application__c ).put( amlFlagRecord.Related_Applicant__c != null ?  amlFlagRecord.Type__c+amlFlagRecord.Related_Applicant__c : amlFlagRecord.Type__c, amlFlagRecord);
                residentialLoanAppIdToAlmRecordsMap.get( amlFlagRecord.Residential_Loan_Application__c ).put( amlFlagRecord.Related_Property__c != null ?  amlFlagRecord.Type__c+amlFlagRecord.Related_Property__c : amlFlagRecord.Type__c, amlFlagRecord);

            }

            if ( !loanApplicationPropertyIdToFlagBooleansMap.isEmpty() &&
                 ( residentialLoanAppIdToFlagBooleansMap.get(rlaId).containsKey('createPurchasePriceFlag') &&
                 residentialLoanAppIdToFlagBooleansMap.get(rlaId).get('createPurchasePriceFlag') ) ||
                 ( residentialLoanAppIdToFlagBooleansMap.get(rlaId).containsKey('resolvePurchasePriceFlag') &&
                 residentialLoanAppIdToFlagBooleansMap.get(rlaId).get('resolvePurchasePriceFlag') )) {
                for ( LoanApplicationProperty loanApplicationProperty : qualifiedRlas.get(rlaId).LoanApplicationProperties ) {
                    if ( loanApplicationProperty.Valuations__r.size() > 0 ) {
                        Decimal thresholdAppraisal = 0;
                        Decimal percentageDifference = 0;
                        if ( loanApplicationPropertyIdToFlagBooleansMap.containsKey(loanApplicationProperty.Id ) && 
                            loanApplicationPropertyIdToFlagBooleansMap.get(loanApplicationProperty.Id).containsKey('createPurchasePriceFlag') && 
                            loanApplicationPropertyIdToFlagBooleansMap.get(loanApplicationProperty.Id).get( 'createPurchasePriceFlag' )  ) {
                            if( loanApplicationProperty.Valuations__r.size() > 1 ) {
                                List<Valuation__c> qualifiedValuations = new List<Valuation__c>();
                                for ( Valuation__c valuation : loanApplicationProperty.Valuations__r ) {
                                    if ( valuation.Valuation_Date__c > System.today().addMonths(-6)) {
                                        qualifiedValuations.add( valuation );
                                    }
                                }

                                if( !qualifiedValuations.isEmpty() ) {
                                    thresholdAppraisal = qualifiedValuations[0].Valuation_Amount__c + (qualifiedValuations[0].Valuation_Amount__c * thresholdPercentage );
                                    if ( loanApplicationProperty.Purchase_Price__c != null && qualifiedValuations[0].Valuation_Amount__c != null && qualifiedValuations[0].Valuation_Amount__c > 0 ) {
                                        percentageDifference = ( (Math.abs(loanApplicationProperty.Purchase_Price__c - qualifiedValuations[0].Valuation_Amount__c)) / ( qualifiedValuations[0].Valuation_Amount__c ) ).setScale(2);
                                    }
                                } else {
                                    thresholdAppraisal = loanApplicationProperty.Valuations__r[0].Valuation_Amount__c + (loanApplicationProperty.Valuations__r[0].Valuation_Amount__c * thresholdPercentage );
                                    if ( loanApplicationProperty.Purchase_Price__c != null && loanApplicationProperty.Valuations__r[0].Valuation_Amount__c != null && loanApplicationProperty.Valuations__r[0].Valuation_Amount__c > 0 ) {

                                        percentageDifference = ( (Math.abs(loanApplicationProperty.Purchase_Price__c - loanApplicationProperty.Valuations__r[0].Valuation_Amount__c)) / ( loanApplicationProperty.Valuations__r[0].Valuation_Amount__c ) ).setScale(2);
                                    }
                                }
                            } else if ( loanApplicationProperty.Valuations__r.size() == 1) {
                                thresholdAppraisal = loanApplicationProperty.Valuations__r[0].Valuation_Amount__c + (loanApplicationProperty.Valuations__r[0].Valuation_Amount__c * thresholdPercentage );
                                if ( loanApplicationProperty.Purchase_Price__c != null && loanApplicationProperty.Valuations__r[0].Valuation_Amount__c != null && loanApplicationProperty.Valuations__r[0].Valuation_Amount__c > 0 ) {
                                    percentageDifference = ( (Math.abs(loanApplicationProperty.Purchase_Price__c - loanApplicationProperty.Valuations__r[0].Valuation_Amount__c)) / (loanApplicationProperty.Valuations__r[0].Valuation_Amount__c ) ).setScale(2);
                                }
                            }
                        }

                        if ( loanApplicationProperty.Purchase_Price__c >= thresholdAppraisal && 
                        !residentialLoanAppIdToAlmRecordsMap.get(rlaId).containsKey( 'Purchase Price'+loanApplicationProperty.Id ) ) {
                            Aml_Flag__c amlFlagRecord = new Aml_Flag__c();
                            amlFlagRecord.Residential_Loan_Application__c = rlaId;
                            amlFlagRecord.Type__c = 'Purchase Price';
                            amlFlagRecord.Related_Property__c = loanApplicationProperty.Id;
                            amlFlagRecord.Description__c = 'Purchase price for '+loanApplicationProperty.Name+' above appraised value by ' +percentageDifference*100 + '%';
                            newAmlRecordsToUpsert.add(amlFlagRecord);
                        } else if ( loanApplicationProperty.Purchase_Price__c < thresholdAppraisal && 
                        residentialLoanAppIdToAlmRecordsMap.get(rlaId).containsKey( 'Purchase Price'+loanApplicationProperty.Id )) {
                            Aml_Flag__c amlFlagRecord = residentialLoanAppIdToAlmRecordsMap.get(rlaId).get( 'Purchase Price'+loanApplicationProperty.Id );
                            amlFlagRecord.Resolved__c = true;
                            newAmlRecordsToUpsert.add(amlFlagRecord);
                        }
                    } else if ( residentialLoanAppIdToAlmRecordsMap.get(rlaId).containsKey( 'Purchase Price'+loanApplicationProperty.Id ) ) {
                        Aml_Flag__c amlFlagRecord = residentialLoanAppIdToAlmRecordsMap.get(rlaId).get( 'Purchase Price'+loanApplicationProperty.Id );
                        amlFlagRecord.Resolved__c = true;
                        newAmlRecordsToUpsert.add(amlFlagRecord);
                    }

                    if ( loanApplicationPropertyIdToFlagBooleansMap.containsKey(loanApplicationProperty.Id ) && 
                        loanApplicationPropertyIdToFlagBooleansMap.get(loanApplicationProperty.Id).containsKey('resolvePurchasePriceFlag') && 
                        loanApplicationPropertyIdToFlagBooleansMap.get(loanApplicationProperty.Id).get( 'resolvePurchasePriceFlag' ) &&
                        residentialLoanAppIdToAlmRecordsMap.get(rlaId).containsKey( 'Purchase Price'+loanApplicationProperty.Id ) ) {
                        Aml_Flag__c amlFlagRecord = residentialLoanAppIdToAlmRecordsMap.get(rlaId).get( 'Purchase Price'+loanApplicationProperty.Id );
                        amlFlagRecord.Resolved__c = true;
                        newAmlRecordsToUpsert.add(amlFlagRecord);
                    }
                }
            }
        }
        upsert newAmlRecordsToUpsert;
    }
}
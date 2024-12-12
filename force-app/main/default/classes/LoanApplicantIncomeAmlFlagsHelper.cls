public with sharing class LoanApplicantIncomeAmlFlagsHelper {
    List<LoanApplicantIncome> newLoanApplicantIncomes = new List<LoanApplicantIncome>();
    Map<Id, LoanApplicantIncome> oldLoanApplicantIncomes = new Map<Id, LoanApplicantIncome>();
    public LoanApplicantIncomeAmlFlagsHelper(List<LoanApplicantIncome> newRecords, Map<Id, LoanApplicantIncome> oldRecords) {
        newLoanApplicantIncomes = newRecords;
        oldLoanApplicantIncomes = oldRecords;
    }

    public void insertLoanApplicantIncomeAmlFlag(){
        Map<Id, Map<String, Boolean>> residentialLoanAppIdToFlagBooleansMap = new Map<Id, Map<String, Boolean>>();
        List<Aml_Flag__c> newAmlRecordsToUpsert = new List<Aml_Flag__c>();
        Map<Id, Map<String, Boolean>> LoanApplicantIncomeIdToFlagBooleansMap = new Map<Id, Map<String, Boolean>>();
        List<String> words = Utils.apexStaticComponentsMap.get('Loan Applicant Gambling Flag').Value__c.split(',');
        for ( LoanApplicantIncome newLoanApplicantIncome : newLoanApplicantIncomes ) {
            Boolean newIncomeContainsGamblingKeyWord = false;
            for ( String word : words ) {
                if ( newLoanApplicantIncome.Name != null && newLoanApplicantIncome.Name.toLowerCase().contains( word.toLowerCase() ) ) {
                    newIncomeContainsGamblingKeyWord = true;
                }

                if ( newLoanApplicantIncome.Description__c != null && newLoanApplicantIncome.Description__c.toLowerCase().contains( word.toLowerCase() ) ) {
                    newIncomeContainsGamblingKeyWord = true;
                }
            }
            if ( oldLoanApplicantIncomes != null ) {
                Boolean oldIncomeContainsGamblingKeyWord = false;
                LoanApplicantIncome oldLoanApplicantIncome = oldLoanApplicantIncomes.get( newLoanApplicantIncome.Id ); 
                
                for ( String word : words ) {
                    if ( oldLoanApplicantIncome.Name != null && oldLoanApplicantIncome.Name.toLowerCase().contains( word.toLowerCase() ) ) {
                        oldIncomeContainsGamblingKeyWord = true;
                    }

                    if ( oldLoanApplicantIncome.Description__c != null && oldLoanApplicantIncome.Description__c.toLowerCase().contains( word.toLowerCase() ) ) {
                        oldIncomeContainsGamblingKeyWord = true;
                    }
                }
                if ( !oldIncomeContainsGamblingKeyWord && newIncomeContainsGamblingKeyWord ) {
                    if ( !LoanApplicantIncomeIdToFlagBooleansMap.containsKey(newLoanApplicantIncome.Id ) ) {
                        LoanApplicantIncomeIdToFlagBooleansMap.put( newLoanApplicantIncome.Id, new Map<String, Boolean>() );
                    }

                    LoanApplicantIncomeIdToFlagBooleansMap.get( newLoanApplicantIncome.Id ).put( 'CreateGamblingFlag', true );
                    
                    if ( !residentialLoanAppIdToFlagBooleansMap.containsKey(newLoanApplicantIncome.LoanApplicationId)) {
                        residentialLoanAppIdToFlagBooleansMap.put(newLoanApplicantIncome.LoanApplicationId, new Map<String, Boolean>());
                    }
                    residentialLoanAppIdToFlagBooleansMap.get( newLoanApplicantIncome.LoanApplicationId ).put( 'CreateGamblingFlag', true );
                } else if ( oldIncomeContainsGamblingKeyWord && !newIncomeContainsGamblingKeyWord ) {
                    if ( !LoanApplicantIncomeIdToFlagBooleansMap.containsKey(newLoanApplicantIncome.Id ) ) {
                        LoanApplicantIncomeIdToFlagBooleansMap.put( newLoanApplicantIncome.Id, new Map<String, Boolean>() );
                    }

                    LoanApplicantIncomeIdToFlagBooleansMap.get( newLoanApplicantIncome.Id ).put( 'ResolveGamblingFlag', true );
                    
                    if ( !residentialLoanAppIdToFlagBooleansMap.containsKey(newLoanApplicantIncome.LoanApplicationId)) {
                        residentialLoanAppIdToFlagBooleansMap.put(newLoanApplicantIncome.LoanApplicationId, new Map<String, Boolean>());
                    }
                    residentialLoanAppIdToFlagBooleansMap.get( newLoanApplicantIncome.LoanApplicationId ).put( 'ResolveGamblingFlag', true );
                }
            } else {
                if ( newIncomeContainsGamblingKeyWord ) {
                    if ( !LoanApplicantIncomeIdToFlagBooleansMap.containsKey(newLoanApplicantIncome.Id ) ) {
                        LoanApplicantIncomeIdToFlagBooleansMap.put( newLoanApplicantIncome.Id, new Map<String, Boolean>() );
                    }

                    LoanApplicantIncomeIdToFlagBooleansMap.get( newLoanApplicantIncome.Id ).put( 'CreateGamblingFlag', true );

                    if ( !residentialLoanAppIdToFlagBooleansMap.containsKey(newLoanApplicantIncome.LoanApplicationId)) {
                        residentialLoanAppIdToFlagBooleansMap.put(newLoanApplicantIncome.LoanApplicationId, new Map<String, Boolean>());
                    }
                    residentialLoanAppIdToFlagBooleansMap.get( newLoanApplicantIncome.LoanApplicationId ).put( 'CreateGamblingFlag', true );
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
                                                                                                                    Name,
                                                                                                                    Description__c,
                                                                                                                    LoanApplicantId
                                                                                                            FROM 
                                                                                                                    LoanApplicantIncomes),
                                                                                                            (SELECT 
                                                                                                                    Id,
                                                                                                                    Name,
                                                                                                                    Description__c,
                                                                                                                    EmployerName,
                                                                                                                    JobTitle,
                                                                                                                    LoanApplicantId
                                                                                                            FROM 
                                                                                                                    LoanApplicantEmployments),
                                                                                                            (SELECT 
                                                                                                                    Id, 
                                                                                                                    Type__c, 
                                                                                                                    Residential_Loan_Application__c,
                                                                                                                    Resolved__c,
                                                                                                                    Related_Applicant__c,
                                                                                                                    Related_Property__c
                                                                                                            FROM 
                                                                                                                    AmlFlags__r)
                                                                                                    FROM 
                                                                                                        ResidentialLoanApplication 
                                                                                                    WHERE 
                                                                                                        Id IN: residentialLoanAppIdToFlagBooleansMap.keySet()]);
        for ( String rlaId : qualifiedRlas.keySet() ) {
            Map<Id, List<LoanApplicantEmployment>> loanApplicantEmploymentIdToLoanApplicantEmploymentMap = new Map<Id, List<LoanApplicantEmployment>>();
            for ( LoanApplicantEmployment loanApplicantEmployment : qualifiedRlas.get(rlaId).LoanApplicantEmployments ) {
                if ( !loanApplicantEmploymentIdToLoanApplicantEmploymentMap.containsKey( loanApplicantEmployment.LoanApplicantId ) ) {
                    loanApplicantEmploymentIdToLoanApplicantEmploymentMap.put(loanApplicantEmployment.LoanApplicantId, new List<loanApplicantEmployment>() );
                }
                loanApplicantEmploymentIdToLoanApplicantEmploymentMap.get(loanApplicantEmployment.LoanApplicantId).add( loanApplicantEmployment );
            }

            Map<Id, List<LoanApplicantIncome>> loanApplicantIncomeIdToLoanApplicantIncomeMap = new Map<Id, List<LoanApplicantIncome>>();
            for ( LoanApplicantIncome loanApplicantIncome : qualifiedRlas.get(rlaId).LoanApplicantIncomes ) {
                if ( !loanApplicantIncomeIdToLoanApplicantIncomeMap.containsKey( loanApplicantIncome.LoanApplicantId ) ) {
                    loanApplicantIncomeIdToLoanApplicantIncomeMap.put(loanApplicantIncome.LoanApplicantId, new List<LoanApplicantIncome>() );
                }
                loanApplicantIncomeIdToLoanApplicantIncomeMap.get(loanApplicantIncome.LoanApplicantId).add( loanApplicantIncome );
            }



            residentialLoanAppIdToAlmRecordsMap.put( rlaId, new Map<String,Aml_Flag__c>());
            for ( Aml_Flag__c amlFlagRecord : qualifiedRlas.get(rlaId).AmlFlags__r ) {
                residentialLoanAppIdToAlmRecordsMap.get( amlFlagRecord.Residential_Loan_Application__c ).put( amlFlagRecord.Related_Applicant__c != null ?  amlFlagRecord.Type__c+amlFlagRecord.Related_Applicant__c : amlFlagRecord.Type__c, amlFlagRecord);
                residentialLoanAppIdToAlmRecordsMap.get( amlFlagRecord.Residential_Loan_Application__c ).put( amlFlagRecord.Related_Property__c != null ?  amlFlagRecord.Type__c+amlFlagRecord.Related_Property__c : amlFlagRecord.Type__c, amlFlagRecord);

            }
            if ( residentialLoanAppIdToFlagBooleansMap.get(rlaId).containsKey('CreateGamblingFlag') &&
                residentialLoanAppIdToFlagBooleansMap.get(rlaId).get('CreateGamblingFlag') ) {
                for ( LoanApplicantIncome loanApplicantIncome : qualifiedRlas.get(rlaId).LoanApplicantIncomes ) {
                    if ( LoanApplicantIncomeIdToFlagBooleansMap.containsKey(loanApplicantIncome.Id ) && 
                        LoanApplicantIncomeIdToFlagBooleansMap.get(loanApplicantIncome.Id).containsKey('CreateGamblingFlag') && 
                        LoanApplicantIncomeIdToFlagBooleansMap.get(loanApplicantIncome.Id).get( 'CreateGamblingFlag' ) ) {
                        if( !residentialLoanAppIdToAlmRecordsMap.get(rlaId).containsKey( 'Gambling Income'+loanApplicantIncome.loanApplicantId ) ) {
                            Aml_Flag__c amlFlagRecord = new Aml_Flag__c();
                            amlFlagRecord.Residential_Loan_Application__c = rlaId;
                            amlFlagRecord.Type__c = 'Gambling Income';
                            amlFlagRecord.Related_Applicant__c = loanApplicantIncome.loanApplicantId;
                            amlFlagRecord.Description__c = 'One or more of applicant’s incomes is from a bar/club/gambling: ' + loanApplicantIncome.Name;
                            newAmlRecordsToUpsert.add(amlFlagRecord);
                        }
                    }
                }
            }
            
            if ( residentialLoanAppIdToFlagBooleansMap.get(rlaId).containsKey('ResolveGamblingFlag') &&
                residentialLoanAppIdToFlagBooleansMap.get(rlaId).get('ResolveGamblingFlag') ) {
                for ( LoanApplicantIncome loanApplicantIncome : qualifiedRlas.get(rlaId).LoanApplicantIncomes ) {
                    if ( LoanApplicantIncomeIdToFlagBooleansMap.containsKey(loanApplicantIncome.Id ) && 
                        LoanApplicantIncomeIdToFlagBooleansMap.get(loanApplicantIncome.Id).containsKey('ResolveGamblingFlag') && 
                        LoanApplicantIncomeIdToFlagBooleansMap.get(loanApplicantIncome.Id).get( 'ResolveGamblingFlag' ) && 
                        residentialLoanAppIdToAlmRecordsMap.get(rlaId).containsKey( 'Gambling Income'+loanApplicantIncome.loanApplicantId ) ) {
                            Boolean relatedEmploymentContainsGamblingKeyWord = false;
                            if ( loanApplicantEmploymentIdToLoanApplicantEmploymentMap.containsKey(loanApplicantIncome.LoanApplicantId) ) {
                                for ( LoanApplicantEmployment loanApplicantEmployment : loanApplicantEmploymentIdToLoanApplicantEmploymentMap.get(loanApplicantIncome.LoanApplicantId)) {
                                    for ( String word : words ) {
                                        if ( loanApplicantEmployment.Name != null && loanApplicantEmployment.Name.toLowerCase().contains( word.toLowerCase() ) ) {
                                            relatedEmploymentContainsGamblingKeyWord = true;
                                        }
                        
                                        if ( loanApplicantEmployment.Description__c != null && loanApplicantEmployment.Description__c.toLowerCase().contains( word.toLowerCase() ) ) {
                                            relatedEmploymentContainsGamblingKeyWord = true;
                                        }
                        
                                        if ( loanApplicantEmployment.EmployerName != null && loanApplicantEmployment.EmployerName.toLowerCase().contains( word.toLowerCase() ) ) {
                                            relatedEmploymentContainsGamblingKeyWord = true;
                                        }
                        
                                        if ( loanApplicantEmployment.JobTitle != null && loanApplicantEmployment.JobTitle.toLowerCase().contains( word.toLowerCase() ) ) {
                                            relatedEmploymentContainsGamblingKeyWord = true;
                                        }
                                    }
                                }
                            }

                            Boolean relatedIncomeContainsGamblingKeyWord = false;
                            if ( loanApplicantIncomeIdToLoanApplicantIncomeMap.containsKey(loanApplicantIncome.LoanApplicantId) ) {
                                for ( LoanApplicantIncome loanAppIncome : loanApplicantIncomeIdToLoanApplicantIncomeMap.get(loanApplicantIncome.LoanApplicantId)) {
                                    for ( String word : words ) {
                                        if ( loanAppIncome.Name != null && loanAppIncome.Name.toLowerCase().contains( word.toLowerCase() ) ) {
                                            relatedIncomeContainsGamblingKeyWord = true;
                                        }
                        
                                        if ( loanAppIncome.Description__c != null && loanAppIncome.Description__c.toLowerCase().contains( word.toLowerCase() ) ) {
                                            relatedIncomeContainsGamblingKeyWord = true;
                                        }
                                    }
                                }
                            }
    
                            if ( !relatedEmploymentContainsGamblingKeyWord && !relatedIncomeContainsGamblingKeyWord ) {
                                Aml_Flag__c amlFlagRecord = residentialLoanAppIdToAlmRecordsMap.get(rlaId).get( 'Gambling Income'+loanApplicantIncome.loanApplicantId );
                                amlFlagRecord.Resolved__c = true;
                                newAmlRecordsToUpsert.add(amlFlagRecord);
                            }
                    }
                }   
            }
        }
        upsert newAmlRecordsToUpsert;
    }
}
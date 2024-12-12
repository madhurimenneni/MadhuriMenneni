public with sharing class LoanApplicantEmploymentAmlFlagsHelper {
    List<LoanApplicantEmployment> newLoanApplicantEmployments = new List<LoanApplicantEmployment>();
    Map<Id, LoanApplicantEmployment> oldLoanApplicantEmployments = new Map<Id, LoanApplicantEmployment>();
    public LoanApplicantEmploymentAmlFlagsHelper(List<LoanApplicantEmployment> newRecords, Map<Id, LoanApplicantEmployment> oldRecords) {
        newLoanApplicantEmployments = newRecords;
        oldLoanApplicantEmployments = oldRecords;
    }

    public void insertLoanApplicantEmploymentAmlFlag(){
        Map<Id, Map<String, Boolean>> residentialLoanAppIdToFlagBooleansMap = new Map<Id, Map<String, Boolean>>();
        List<Aml_Flag__c> newAmlRecordsToUpsert = new List<Aml_Flag__c>();
        Map<Id, Map<String, Boolean>> LoanApplicantEmploymentIdToFlagBooleansMap = new Map<Id, Map<String, Boolean>>();
        List<String> words = Utils.apexStaticComponentsMap.get('Loan Applicant Gambling Flag').Value__c.split(',');
        for ( LoanApplicantEmployment newLoanApplicantEmployment : newLoanApplicantEmployments ) {
            Boolean newEmploymentContainsGamblingKeyWord = false;
            for ( String word : words ) {
                if ( newLoanApplicantEmployment.Name != null && newLoanApplicantEmployment.Name.toLowerCase().contains( word.toLowerCase() ) ) {
                    newEmploymentContainsGamblingKeyWord = true;
                }

                if ( newLoanApplicantEmployment.Description__c != null && newLoanApplicantEmployment.Description__c.toLowerCase().contains( word.toLowerCase() ) ) {
                    newEmploymentContainsGamblingKeyWord = true;
                }

                if ( newLoanApplicantEmployment.EmployerName != null && newLoanApplicantEmployment.EmployerName.toLowerCase().contains( word.toLowerCase() ) ) {
                    newEmploymentContainsGamblingKeyWord = true;
                }

                if ( newLoanApplicantEmployment.JobTitle != null && newLoanApplicantEmployment.JobTitle.toLowerCase().contains( word.toLowerCase() ) ) {
                    newEmploymentContainsGamblingKeyWord = true;
                }
            }
            if ( oldLoanApplicantEmployments != null ) {
                Boolean oldEmploymentContainsGamblingKeyWord = false;
                LoanApplicantEmployment oldLoanApplicantEmployment = oldLoanApplicantEmployments.get( newLoanApplicantEmployment.Id ); 
                
                for ( String word : words ) {
                    if ( oldLoanApplicantEmployment.Name != null && oldLoanApplicantEmployment.Name.toLowerCase().contains( word.toLowerCase() ) ) {
                        oldEmploymentContainsGamblingKeyWord = true;
                    }

                    if ( oldLoanApplicantEmployment.Description__c != null && oldLoanApplicantEmployment.Description__c.toLowerCase().contains( word.toLowerCase() ) ) {
                        oldEmploymentContainsGamblingKeyWord = true;
                    }

                    if ( oldLoanApplicantEmployment.EmployerName != null && oldLoanApplicantEmployment.EmployerName.toLowerCase().contains( word.toLowerCase() ) ) {
                        oldEmploymentContainsGamblingKeyWord = true;
                    }

                    if ( oldLoanApplicantEmployment.JobTitle != null && oldLoanApplicantEmployment.JobTitle.toLowerCase().contains( word.toLowerCase() ) ) {
                        oldEmploymentContainsGamblingKeyWord = true;
                    }
                }
                if ( !oldEmploymentContainsGamblingKeyWord && newEmploymentContainsGamblingKeyWord ) {
                    if ( !LoanApplicantEmploymentIdToFlagBooleansMap.containsKey(newLoanApplicantEmployment.Id ) ) {
                        LoanApplicantEmploymentIdToFlagBooleansMap.put( newLoanApplicantEmployment.Id, new Map<String, Boolean>() );
                    }

                    LoanApplicantEmploymentIdToFlagBooleansMap.get( newLoanApplicantEmployment.Id ).put( 'CreateGamblingFlag', true );
                    
                    if ( !residentialLoanAppIdToFlagBooleansMap.containsKey(newLoanApplicantEmployment.LoanApplicationId)) {
                        residentialLoanAppIdToFlagBooleansMap.put(newLoanApplicantEmployment.LoanApplicationId, new Map<String, Boolean>());
                    }
                    residentialLoanAppIdToFlagBooleansMap.get( newLoanApplicantEmployment.LoanApplicationId ).put( 'CreateGamblingFlag', true );
                } else if ( oldEmploymentContainsGamblingKeyWord && !newEmploymentContainsGamblingKeyWord ) {
                    if ( !LoanApplicantEmploymentIdToFlagBooleansMap.containsKey(newLoanApplicantEmployment.Id ) ) {
                        LoanApplicantEmploymentIdToFlagBooleansMap.put( newLoanApplicantEmployment.Id, new Map<String, Boolean>() );
                    }

                    LoanApplicantEmploymentIdToFlagBooleansMap.get( newLoanApplicantEmployment.Id ).put( 'ResolveGamblingFlag', true );
                    
                    if ( !residentialLoanAppIdToFlagBooleansMap.containsKey(newLoanApplicantEmployment.LoanApplicationId)) {
                        residentialLoanAppIdToFlagBooleansMap.put(newLoanApplicantEmployment.LoanApplicationId, new Map<String, Boolean>());
                    }
                    residentialLoanAppIdToFlagBooleansMap.get( newLoanApplicantEmployment.LoanApplicationId ).put( 'ResolveGamblingFlag', true );
                }
            } else {
                if ( newEmploymentContainsGamblingKeyWord ) {
                    if ( !LoanApplicantEmploymentIdToFlagBooleansMap.containsKey(newLoanApplicantEmployment.Id ) ) {
                        LoanApplicantEmploymentIdToFlagBooleansMap.put( newLoanApplicantEmployment.Id, new Map<String, Boolean>() );
                    }

                    LoanApplicantEmploymentIdToFlagBooleansMap.get( newLoanApplicantEmployment.Id ).put( 'CreateGamblingFlag', true );

                    if ( !residentialLoanAppIdToFlagBooleansMap.containsKey(newLoanApplicantEmployment.LoanApplicationId)) {
                        residentialLoanAppIdToFlagBooleansMap.put(newLoanApplicantEmployment.LoanApplicationId, new Map<String, Boolean>());
                    }
                    residentialLoanAppIdToFlagBooleansMap.get( newLoanApplicantEmployment.LoanApplicationId ).put( 'CreateGamblingFlag', true );
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
                                                                                                                    JobTitle,
                                                                                                                    EmployerName,
                                                                                                                    LoanApplicantId
                                                                                                            FROM 
                                                                                                                    LoanApplicantEmployments
                                                                                                            WHERE 
                                                                                                                    Id IN: LoanApplicantEmploymentIdToFlagBooleansMap.keySet()),
                                                                                                            (SELECT 
                                                                                                                    Id,
                                                                                                                    Name,
                                                                                                                    Description__c,
                                                                                                                    LoanApplicantId
                                                                                                            FROM 
                                                                                                                    LoanApplicantIncomes),
                                                                                                            (SELECT 
                                                                                                                    Id, 
                                                                                                                    Type__c, 
                                                                                                                    Residential_Loan_Application__c,
                                                                                                                    Resolved__c,
                                                                                                                    Related_Applicant__c,
                                                                                                                    Related_Property__c
                                                                                                                    //Loan_Applicant_Employment__c,
                                                                                                                    //Loan_Applicant_Income__c,
                                                                                                                    //Loan_Applicant_Income__r.Name,
                                                                                                                    //Loan_Applicant_Income__r.Description__c
                                                                                                            FROM 
                                                                                                                    AmlFlags__r)
                                                                                                    FROM 
                                                                                                        ResidentialLoanApplication 
                                                                                                    WHERE 
                                                                                                        Id IN: residentialLoanAppIdToFlagBooleansMap.keySet()]);
        for ( String rlaId : qualifiedRlas.keySet() ) {
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
                for ( LoanApplicantEmployment loanApplicantEmployment : qualifiedRlas.get(rlaId).LoanApplicantEmployments ) {
                    if ( LoanApplicantEmploymentIdToFlagBooleansMap.containsKey(loanApplicantEmployment.Id ) && 
                        LoanApplicantEmploymentIdToFlagBooleansMap.get(loanApplicantEmployment.Id).containsKey('CreateGamblingFlag') && 
                        LoanApplicantEmploymentIdToFlagBooleansMap.get(loanApplicantEmployment.Id).get( 'CreateGamblingFlag' ) ) {
                        if (!residentialLoanAppIdToAlmRecordsMap.get(rlaId).containsKey( 'Gambling Income'+loanApplicantEmployment.loanApplicantId ) ) {
                            Aml_Flag__c amlFlagRecord = new Aml_Flag__c();
                            amlFlagRecord.Residential_Loan_Application__c = rlaId;
                            amlFlagRecord.Type__c = 'Gambling Income';
                            //amlFlagRecord.Loan_Applicant_Employment__c = loanApplicantEmployment.Id;
                            amlFlagRecord.Related_Applicant__c = loanApplicantEmployment.loanApplicantId;
                            amlFlagRecord.Description__c = 'One or more of applicant’s incomes/employments is from a bar/club/gambling: ' + loanApplicantEmployment.Name;
                            newAmlRecordsToUpsert.add(amlFlagRecord);
                        } 
                        // else if (residentialLoanAppIdToAlmRecordsMap.get(rlaId).containsKey( 'Gambling Income'+loanApplicantEmployment.loanApplicantId ) ) {
                        //     Aml_Flag__c amlFlagRecord = residentialLoanAppIdToAlmRecordsMap.get(rlaId).get( 'Gambling Income'+loanApplicantEmployment.loanApplicantId );
                        //     amlFlagRecord.Loan_Applicant_Employment__c = loanApplicantEmployment.Id;
                        //     newAmlRecordsToUpsert.add(amlFlagRecord);
                        // }
                    }
                }
            }
            
            if ( residentialLoanAppIdToFlagBooleansMap.get(rlaId).containsKey('ResolveGamblingFlag') &&
                residentialLoanAppIdToFlagBooleansMap.get(rlaId).get('ResolveGamblingFlag') ) {
                for ( LoanApplicantEmployment loanApplicantEmployment : qualifiedRlas.get(rlaId).LoanApplicantEmployments ) {
                    if ( LoanApplicantEmploymentIdToFlagBooleansMap.containsKey(loanApplicantEmployment.Id ) && 
                        LoanApplicantEmploymentIdToFlagBooleansMap.get(loanApplicantEmployment.Id).containsKey('ResolveGamblingFlag') && 
                        LoanApplicantEmploymentIdToFlagBooleansMap.get(loanApplicantEmployment.Id).get( 'ResolveGamblingFlag' ) && 
                        residentialLoanAppIdToAlmRecordsMap.get(rlaId).containsKey( 'Gambling Income'+loanApplicantEmployment.loanApplicantId ) ) {
                            Boolean relatedIncomeContainsGamblingKeyWord = false;
                            if ( loanApplicantIncomeIdToLoanApplicantIncomeMap.containsKey(loanApplicantEmployment.LoanApplicantId) ) {
                                for ( LoanApplicantIncome loanApplicantIncome : loanApplicantIncomeIdToLoanApplicantIncomeMap.get(loanApplicantEmployment.LoanApplicantId)) {
                                    for ( String word : words ) {
                                        if ( loanApplicantIncome.Name != null && loanApplicantIncome.Name.toLowerCase().contains( word.toLowerCase() ) ) {
                                            relatedIncomeContainsGamblingKeyWord = true;
                                        }
                        
                                        if ( loanApplicantIncome.Description__c != null && loanApplicantIncome.Description__c.toLowerCase().contains( word.toLowerCase() ) ) {
                                            relatedIncomeContainsGamblingKeyWord = true;
                                        }
                                    }
                                }
                            }
                            if ( !relatedIncomeContainsGamblingKeyWord ) {
                                Aml_Flag__c amlFlagRecord = residentialLoanAppIdToAlmRecordsMap.get(rlaId).get( 'Gambling Income'+loanApplicantEmployment.loanApplicantId );
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
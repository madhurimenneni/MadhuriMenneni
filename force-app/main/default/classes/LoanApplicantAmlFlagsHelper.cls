public with sharing class LoanApplicantAmlFlagsHelper {
    List<LoanApplicant> newLoanApplicants = new List<LoanApplicant>();
    Map<Id, LoanApplicant> oldLoanApplicants = new Map<Id, LoanApplicant>();
    

    public LoanApplicantAmlFlagsHelper( List<LoanApplicant> newRecords, Map<Id, LoanApplicant> oldRecords ) {
        newLoanApplicants = newRecords;
        oldLoanApplicants = oldRecords;
    }
    
    public void insertLoanApplicantAmlFlag(){
        Map<Id, Map<String, Boolean>> loanApplicantIdToFlagBooleansMap = new Map<Id, Map<String, Boolean>>();
        Map<Id, Map<String, Boolean>> residentialLoanAppIdToFlagBooleansMap = new Map<Id, Map<String, Boolean>>();
        List<Aml_Flag__c> newAmlRecordsToUpsert = new List<Aml_Flag__c>();
        for ( LoanApplicant newLoanApplicant : newLoanApplicants ) {
            if (oldLoanApplicants != null) {
                LoanApplicant oldLoanApp = oldLoanApplicants.get(newLoanApplicant.Id); 
                if (newLoanApplicant.Full_Name__c != oldLoanApp.Full_Name__c && 
                    ( newLoanApplicant.Application_Status__c == '2. Sent Commitment' || 
                    newLoanApplicant.Application_Status__c == '3. Received Commitment' || 
                    newLoanApplicant.Application_Status__c == '4. Instructed' || 
                    newLoanApplicant.Application_Status__c == '5. Funds Requested' ||
                    newLoanApplicant.Application_Status__c == '6. Funded') ) {
                        if ( !loanApplicantIdToFlagBooleansMap.containsKey(newLoanApplicant.Id) ) {
                            loanApplicantIdToFlagBooleansMap.put(newLoanApplicant.Id, new Map<String, Boolean>());
                        }
                        loanApplicantIdToFlagBooleansMap.get(newLoanApplicant.Id).put( 'createNameChangeFlag', true );
                        
                        if ( !residentialLoanAppIdToFlagBooleansMap.containsKey(newLoanApplicant.LoanApplicationId)) {
                            residentialLoanAppIdToFlagBooleansMap.put(newLoanApplicant.LoanApplicationId, new Map<String, Boolean>());
                        }
                        residentialLoanAppIdToFlagBooleansMap.get( newLoanApplicant.LoanApplicationId ).put( 'createNameChangeFlag', true );
                }

                if (newLoanApplicant.RecordType_Developer_Name__c == 'Regular_Borrower') {
                    if (newLoanApplicant.CitizenshipStatus != oldLoanApp.CitizenshipStatus ) {
                        if ( ( newLoanApplicant.CitizenshipStatus == '' && (newLoanApplicant.Sin_First_Digit__c == null || newLoanApplicant.Sin_First_Digit__c == 0 || newLoanApplicant.Sin_First_Digit__c == 9) ) ||
                            ( newLoanApplicant.CitizenshipStatus != 'Citizen' &&
                            newLoanApplicant.CitizenshipStatus != 'Resident' &&
                            newLoanApplicant.CitizenshipStatus != 'Student Visa' &&
                            newLoanApplicant.CitizenshipStatus != 'Work Visa' &&
                            newLoanApplicant.CitizenshipStatus != 'Landed Immigrant' ) ) {
                            if ( !loanApplicantIdToFlagBooleansMap.containsKey(newLoanApplicant.Id) ) {
                                loanApplicantIdToFlagBooleansMap.put(newLoanApplicant.Id, new Map<String, Boolean>());
                            }
                            loanApplicantIdToFlagBooleansMap.get(newLoanApplicant.Id).put( 'createCitizenshipStatusFlag', true );
                            
                            if ( !residentialLoanAppIdToFlagBooleansMap.containsKey(newLoanApplicant.LoanApplicationId)) {
                                residentialLoanAppIdToFlagBooleansMap.put(newLoanApplicant.LoanApplicationId, new Map<String, Boolean>());
                            }
                            residentialLoanAppIdToFlagBooleansMap.get( newLoanApplicant.LoanApplicationId ).put( 'createCitizenshipStatusFlag', true );
                        } else if ( newLoanApplicant.CitizenshipStatus == 'Citizen' || 
                            newLoanApplicant.CitizenshipStatus == 'Resident' || 
                            newLoanApplicant.CitizenshipStatus == 'Student Visa' || 
                            newLoanApplicant.CitizenshipStatus == 'Work Visa' ||
                            newLoanApplicant.CitizenshipStatus == 'Landed Immigrant') {
                            if ( !loanApplicantIdToFlagBooleansMap.containsKey(newLoanApplicant.Id) ) {
                                loanApplicantIdToFlagBooleansMap.put(newLoanApplicant.Id, new Map<String, Boolean>());
                            }
                            loanApplicantIdToFlagBooleansMap.get(newLoanApplicant.Id).put( 'resolveCitizenshipStatusFlag', true );
                            
                            if ( !residentialLoanAppIdToFlagBooleansMap.containsKey(newLoanApplicant.LoanApplicationId)) {
                                residentialLoanAppIdToFlagBooleansMap.put(newLoanApplicant.LoanApplicationId, new Map<String, Boolean>());
                            }
                            residentialLoanAppIdToFlagBooleansMap.get( newLoanApplicant.LoanApplicationId ).put( 'resolveCitizenshipStatusFlag', true );
                        }
                    } else if ( newLoanApplicant.Sin_First_Digit__c != oldLoanApp.Sin_First_Digit__c) {
                        if (newLoanApplicant.Sin_First_Digit__c == null || newLoanApplicant.Sin_First_Digit__c == 0 || newLoanApplicant.Sin_First_Digit__c == 9 ) {
                            if ( !loanApplicantIdToFlagBooleansMap.containsKey(newLoanApplicant.Id) ) {
                                loanApplicantIdToFlagBooleansMap.put(newLoanApplicant.Id, new Map<String, Boolean>());
                            }
                            loanApplicantIdToFlagBooleansMap.get(newLoanApplicant.Id).put( 'createCitizenshipStatusFlag', true );
                            
                            if ( !residentialLoanAppIdToFlagBooleansMap.containsKey(newLoanApplicant.LoanApplicationId)) {
                                residentialLoanAppIdToFlagBooleansMap.put(newLoanApplicant.LoanApplicationId, new Map<String, Boolean>());
                            }
                            residentialLoanAppIdToFlagBooleansMap.get( newLoanApplicant.LoanApplicationId ).put( 'createCitizenshipStatusFlag', true );
                        } else if (newLoanApplicant.Sin_First_Digit__c != null && newLoanApplicant.Sin_First_Digit__c != 0 && newLoanApplicant.Sin_First_Digit__c != 9 ) {
                            if ( !loanApplicantIdToFlagBooleansMap.containsKey(newLoanApplicant.Id) ) {
                                loanApplicantIdToFlagBooleansMap.put(newLoanApplicant.Id, new Map<String, Boolean>());
                            }
                            loanApplicantIdToFlagBooleansMap.get(newLoanApplicant.Id).put( 'resolveCitizenshipStatusFlag', true );
                            
                            if ( !residentialLoanAppIdToFlagBooleansMap.containsKey(newLoanApplicant.LoanApplicationId)) {
                                residentialLoanAppIdToFlagBooleansMap.put(newLoanApplicant.LoanApplicationId, new Map<String, Boolean>());
                            }
                            residentialLoanAppIdToFlagBooleansMap.get( newLoanApplicant.LoanApplicationId ).put( 'resolveCitizenshipStatusFlag', true );
                        }
                    }
                }
            } else {
                if (newLoanApplicant.RecordType_Developer_Name__c == 'Regular_Borrower') {
                    if ( ( newLoanApplicant.CitizenshipStatus == '' && (newLoanApplicant.Sin_First_Digit__c == null || newLoanApplicant.Sin_First_Digit__c == 0 || newLoanApplicant.Sin_First_Digit__c == 9) ) &&
                        ( newLoanApplicant.CitizenshipStatus != 'Citizen' && 
                        newLoanApplicant.CitizenshipStatus != 'Resident' &&
                        newLoanApplicant.CitizenshipStatus != 'Student Visa' && 
                        newLoanApplicant.CitizenshipStatus != 'Work Visa' &&
                        newLoanApplicant.CitizenshipStatus != 'Landed Immigrant' ) ) {
                            if ( !loanApplicantIdToFlagBooleansMap.containsKey(newLoanApplicant.Id) ) {
                                loanApplicantIdToFlagBooleansMap.put(newLoanApplicant.Id, new Map<String, Boolean>());
                            }
                            loanApplicantIdToFlagBooleansMap.get(newLoanApplicant.Id).put( 'createCitizenshipStatusFlag', true );
                            
                            if ( !residentialLoanAppIdToFlagBooleansMap.containsKey(newLoanApplicant.LoanApplicationId)) {
                                residentialLoanAppIdToFlagBooleansMap.put(newLoanApplicant.LoanApplicationId, new Map<String, Boolean>());
                            }
                            residentialLoanAppIdToFlagBooleansMap.get( newLoanApplicant.LoanApplicationId ).put( 'createCitizenshipStatusFlag', true );
                    }
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
                                                                                                                     Application_Status__c, 
                                                                                                                     CitizenshipStatus,
                                                                                                                     Full_Name__c
                                                                                                            FROM 
                                                                                                                     LoanApplicants 
                                                                                                            WHERE 
                                                                                                                    Id IN: loanApplicantIdToFlagBooleansMap.keySet()),
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
            residentialLoanAppIdToAlmRecordsMap.put( rlaId, new Map<String,Aml_Flag__c>());
            for ( Aml_Flag__c amlFlagRecord : qualifiedRlas.get(rlaId).AmlFlags__r ) {
                residentialLoanAppIdToAlmRecordsMap.get( amlFlagRecord.Residential_Loan_Application__c ).put( amlFlagRecord.Related_Applicant__c != null ?  amlFlagRecord.Type__c+amlFlagRecord.Related_Applicant__c : amlFlagRecord.Type__c, amlFlagRecord);
                residentialLoanAppIdToAlmRecordsMap.get( amlFlagRecord.Residential_Loan_Application__c ).put( amlFlagRecord.Related_Property__c != null ?  amlFlagRecord.Type__c+amlFlagRecord.Related_Property__c : amlFlagRecord.Type__c, amlFlagRecord);

            }
            if ( residentialLoanAppIdToFlagBooleansMap.get(rlaId).containsKey('createNameChangeFlag') &&
                residentialLoanAppIdToFlagBooleansMap.get(rlaId).get('createNameChangeFlag') ) {
                for ( LoanApplicant loanApplicant : qualifiedRlas.get(rlaId).LoanApplicants ) {
                    if ( loanApplicantIdToFlagBooleansMap.containsKey(loanApplicant.Id ) && 
                        loanApplicantIdToFlagBooleansMap.get(loanApplicant.Id).containsKey('createNameChangeFlag') && 
                        loanApplicantIdToFlagBooleansMap.get(loanApplicant.Id).get( 'createNameChangeFlag' ) && 
                        !residentialLoanAppIdToAlmRecordsMap.get(rlaId).containsKey( 'Name Change'+loanApplicant.Id ) ) {
                        Aml_Flag__c amlFlagRecord = new Aml_Flag__c();
                        amlFlagRecord.Residential_Loan_Application__c = rlaId;
                        amlFlagRecord.Type__c = 'Name Change';
                        amlFlagRecord.Related_Applicant__c = loanApplicant.Id;
                        amlFlagRecord.Description__c = 'Applicant’s name was changed when the RLA stage is at '+ loanApplicant.Application_Status__c+'. The Name was Changed from "' + oldLoanApplicants.get(loanApplicant.Id).Full_Name__c + '" to "'+loanApplicant.Full_Name__c+'"';
                        newAmlRecordsToUpsert.add(amlFlagRecord);
                    }
                }
            }

            if ( residentialLoanAppIdToFlagBooleansMap.get(rlaId).containsKey('createCitizenshipStatusFlag') &&
                 residentialLoanAppIdToFlagBooleansMap.get(rlaId).get('createCitizenshipStatusFlag') ) {
                for ( LoanApplicant loanApplicant : qualifiedRlas.get(rlaId).LoanApplicants ) {
                    if ( loanApplicantIdToFlagBooleansMap.containsKey(loanApplicant.Id ) && 
                        loanApplicantIdToFlagBooleansMap.get(loanApplicant.Id).containsKey('createCitizenshipStatusFlag') && 
                        loanApplicantIdToFlagBooleansMap.get(loanApplicant.Id).get( 'createCitizenshipStatusFlag' ) && 
                        !residentialLoanAppIdToAlmRecordsMap.get(rlaId).containsKey( 'Non-Resident'+loanApplicant.Id ) ) {
                        Aml_Flag__c amlFlagRecord = new Aml_Flag__c();
                        amlFlagRecord.Residential_Loan_Application__c = rlaId;
                        amlFlagRecord.Type__c = 'Non-Resident';
                        amlFlagRecord.Related_Applicant__c = loanApplicant.Id;
                        amlFlagRecord.Description__c = 'Applicant citizenship type indicates a non-resident: '+loanApplicant.Full_Name__c;
                        newAmlRecordsToUpsert.add(amlFlagRecord);
                    }
                }
            }

            if ( residentialLoanAppIdToFlagBooleansMap.get(rlaId).containsKey('resolveCitizenshipStatusFlag') &&
                 residentialLoanAppIdToFlagBooleansMap.get(rlaId).get('resolveCitizenshipStatusFlag') ) {
                for ( LoanApplicant loanApplicant : qualifiedRlas.get(rlaId).LoanApplicants ) {
                    if ( loanApplicantIdToFlagBooleansMap.containsKey(loanApplicant.Id ) && 
                        loanApplicantIdToFlagBooleansMap.get(loanApplicant.Id).containsKey('resolveCitizenshipStatusFlag') && 
                        loanApplicantIdToFlagBooleansMap.get(loanApplicant.Id).get( 'resolveCitizenshipStatusFlag' ) && 
                        residentialLoanAppIdToAlmRecordsMap.get(rlaId).containsKey( 'Non-Resident'+loanApplicant.Id ) ) {
                            Aml_Flag__c amlFlagRecord = residentialLoanAppIdToAlmRecordsMap.get(rlaId).get('Non-Resident'+loanApplicant.Id);
                            amlFlagRecord.Resolved__c = true;
                            newAmlRecordsToUpsert.add(amlFlagRecord);
                    }
                }
            }
        }
        upsert newAmlRecordsToUpsert;
    }
}
public class LoanApplicantAddressAmlFlagsHelper {
    List<LoanApplicantAddress> newLoanApplicantAddresses = new List<LoanApplicantAddress>();
    Map<Id, LoanApplicantAddress> oldLoanApplicantAddresses = new Map<Id, LoanApplicantAddress>();
    
    public LoanApplicantAddressAmlFlagsHelper( List<LoanApplicantAddress> newRecords, Map<Id, LoanApplicantAddress> oldRecords ) {
        newLoanApplicantAddresses = newRecords;
        oldLoanApplicantAddresses = oldRecords;
    }
    
    public void insertLoanApplicantAddressAmlFlag(){
        Map<Id, Map<String, Boolean>> residentialLoanAppIdToFlagBooleansMap = new Map<Id, Map<String, Boolean>>();
        List<Aml_Flag__c> newAmlRecordsToUpsert = new List<Aml_Flag__c>();
        Map<Id, Map<String, Boolean>> loanApplicantAddressIdToFlagBooleansMap = new Map<Id, Map<String, Boolean>>();
        List<String> words = Utils.apexStaticComponentsMap.get('Loan Applicant Add P.O. Box Validation').Value__c.split(',');
        
        for ( LoanApplicantAddress newLoanApplicantAddress : newLoanApplicantAddresses ) {
            Boolean newAddressContainsPOBox = false;

            if( newLoanApplicantAddress.ResidenceStreet != null ) {
                for ( String word : words ) {
                    if ( newLoanApplicantAddress.ResidenceStreet.toLowerCase().contains( word.toLowerCase() ) ) {
                        newAddressContainsPOBox = true;
                    }
                }
            }

            if ( oldLoanApplicantAddresses != null ) {
                Boolean oldAddressContainsPOBox = false;
                LoanApplicantAddress oldLoanApplicantAddress = oldLoanApplicantAddresses.get( newLoanApplicantAddress.Id ); 
                
                if( oldLoanApplicantAddress.ResidenceStreet != null ) {
                    for ( String word : words ) {
                        if ( oldLoanApplicantAddress.ResidenceStreet.toLowerCase().contains( word.toLowerCase() ) ) {
                            oldAddressContainsPOBox = true;
                        }
                    }
                }
                
                if ( newLoanApplicantAddress.ResidenceStreet != oldLoanApplicantAddress.ResidenceStreet) {
                    if ( !oldAddressContainsPOBox && newAddressContainsPOBox ) {
                        if ( !loanApplicantAddressIdToFlagBooleansMap.containsKey(newLoanApplicantAddress.Id ) ) {
                            loanApplicantAddressIdToFlagBooleansMap.put( newLoanApplicantAddress.Id, new Map<String, Boolean>() );
                        }

                        loanApplicantAddressIdToFlagBooleansMap.get( newLoanApplicantAddress.Id ).put( 'CreateOnlyPOBoxProvided', true );
                        
                        if ( !residentialLoanAppIdToFlagBooleansMap.containsKey(newLoanApplicantAddress.LoanApplicationId)) {
                            residentialLoanAppIdToFlagBooleansMap.put(newLoanApplicantAddress.LoanApplicationId, new Map<String, Boolean>());
                        }
                        residentialLoanAppIdToFlagBooleansMap.get( newLoanApplicantAddress.LoanApplicationId ).put( 'CreateOnlyPOBoxProvided', true );
                    } else if ( oldAddressContainsPOBox && !newAddressContainsPOBox ) {
                        if ( !loanApplicantAddressIdToFlagBooleansMap.containsKey(newLoanApplicantAddress.Id ) ) {
                            loanApplicantAddressIdToFlagBooleansMap.put( newLoanApplicantAddress.Id, new Map<String, Boolean>() );
                        }

                        loanApplicantAddressIdToFlagBooleansMap.get( newLoanApplicantAddress.Id ).put( 'ResolveOnlyPOBoxProvided', true );
                        
                        if ( !residentialLoanAppIdToFlagBooleansMap.containsKey(newLoanApplicantAddress.LoanApplicationId)) {
                            residentialLoanAppIdToFlagBooleansMap.put(newLoanApplicantAddress.LoanApplicationId, new Map<String, Boolean>());
                        }
                        residentialLoanAppIdToFlagBooleansMap.get( newLoanApplicantAddress.LoanApplicationId ).put( 'ResolveOnlyPOBoxProvided', true );
                    }
                }
            } else {
                if ( newAddressContainsPOBox ) {
                    if ( !loanApplicantAddressIdToFlagBooleansMap.containsKey(newLoanApplicantAddress.Id ) ) {
                        loanApplicantAddressIdToFlagBooleansMap.put( newLoanApplicantAddress.Id, new Map<String, Boolean>() );
                    }

                    loanApplicantAddressIdToFlagBooleansMap.get( newLoanApplicantAddress.Id ).put( 'CreateOnlyPOBoxProvided', true );

                    if ( !residentialLoanAppIdToFlagBooleansMap.containsKey(newLoanApplicantAddress.LoanApplicationId)) {
                        residentialLoanAppIdToFlagBooleansMap.put(newLoanApplicantAddress.LoanApplicationId, new Map<String, Boolean>());
                    }
                    residentialLoanAppIdToFlagBooleansMap.get( newLoanApplicantAddress.LoanApplicationId ).put( 'CreateOnlyPOBoxProvided', true );
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
                                                                                                                    ResidenceStreet,
                                                                                                                    LoanApplicantId
                                                                                                            FROM 
                                                                                                                    LoanApplicantAddresses
                                                                                                            WHERE 
                                                                                                                    Id IN: loanApplicantAddressIdToFlagBooleansMap.keySet()),
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
            
            if ( residentialLoanAppIdToFlagBooleansMap.get(rlaId).containsKey('CreateOnlyPOBoxProvided') &&
                residentialLoanAppIdToFlagBooleansMap.get(rlaId).get('CreateOnlyPOBoxProvided') ) {
                
                for ( LoanApplicantAddress loanApplicantAddress : qualifiedRlas.get(rlaId).LoanApplicantAddresses ) {
                    if ( loanApplicantAddressIdToFlagBooleansMap.containsKey(loanApplicantAddress.Id ) && 
                        loanApplicantAddressIdToFlagBooleansMap.get(loanApplicantAddress.Id).containsKey('CreateOnlyPOBoxProvided') && 
                        loanApplicantAddressIdToFlagBooleansMap.get(loanApplicantAddress.Id).get( 'CreateOnlyPOBoxProvided' ) && 
                        !residentialLoanAppIdToAlmRecordsMap.get(rlaId).containsKey( 'Only PO Box Provided'+loanApplicantAddress.loanApplicantId ) ) {
                        
                        Aml_Flag__c amlFlagRecord = new Aml_Flag__c();
                        amlFlagRecord.Residential_Loan_Application__c = rlaId;
                        amlFlagRecord.Type__c = 'Only PO Box Provided';
                        amlFlagRecord.Related_Applicant__c = loanApplicantAddress.loanApplicantId;
                        amlFlagRecord.Description__c = 'One or more of applicant’s addresses has only the PO Box provided : ' + loanApplicantAddress.ResidenceStreet;
                        newAmlRecordsToUpsert.add(amlFlagRecord);
                    }
                }
            }
            
            if ( residentialLoanAppIdToFlagBooleansMap.get(rlaId).containsKey('ResolveOnlyPOBoxProvided') &&
                residentialLoanAppIdToFlagBooleansMap.get(rlaId).get('ResolveOnlyPOBoxProvided') ) {
                
                for ( LoanApplicantAddress loanApplicantAddress : qualifiedRlas.get(rlaId).LoanApplicantAddresses ) {
                    if ( loanApplicantAddressIdToFlagBooleansMap.containsKey(loanApplicantAddress.Id ) && 
                        loanApplicantAddressIdToFlagBooleansMap.get(loanApplicantAddress.Id).containsKey('ResolveOnlyPOBoxProvided') && 
                        loanApplicantAddressIdToFlagBooleansMap.get(loanApplicantAddress.Id).get( 'ResolveOnlyPOBoxProvided' ) ) {

                        // Query all LoanApplicantAddresses for the same LoanApplicant to see if any still have PO Box
                        List<LoanApplicantAddress> relatedAddresses = [
                            SELECT ResidenceStreet 
                            FROM LoanApplicantAddress 
                            WHERE LoanApplicantId = :loanApplicantAddress.LoanApplicantId
                        ];

                        Boolean otherAddressesWithPOBox = false;
                        for (LoanApplicantAddress relatedAddress : relatedAddresses) {
                            if (relatedAddress.ResidenceStreet != null) {
                                for (String word : words) {  // Use the same P.O. Box validation as before
                                    if (relatedAddress.ResidenceStreet.toLowerCase().contains(word.toLowerCase())) {
                                        otherAddressesWithPOBox = true;
                                        break;
                                    }
                                }
                            }
                            if (otherAddressesWithPOBox) break;  // If any PO Box is found, no need to continue checking
                        }

                        // Only resolve if no other address for the loan applicant contains a PO Box
                        if (!otherAddressesWithPOBox && residentialLoanAppIdToAlmRecordsMap.get(rlaId).containsKey('Only PO Box Provided' + loanApplicantAddress.loanApplicantId)) {
                            Aml_Flag__c amlFlagRecord = residentialLoanAppIdToAlmRecordsMap.get(rlaId).get('Only PO Box Provided' + loanApplicantAddress.loanApplicantId);
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
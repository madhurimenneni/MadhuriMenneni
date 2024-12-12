public class RlaAmlFlagHelper {

    List<ResidentialLoanApplication> newResidentialLoanApps = new List<ResidentialLoanApplication>();
    Map<Id, ResidentialLoanApplication> oldResidentialLoanApps = new Map<Id, ResidentialLoanApplication>();

    public RlaAmlFlagHelper( List<ResidentialLoanApplication> newRecords, Map<Id, ResidentialLoanApplication> oldRecordsMap ) {
        newResidentialLoanApps = newRecords;
        oldResidentialLoanApps = oldRecordsMap;
    }

    public void insertAmlFlag(){
        Map<Id, Map<String, Boolean>> residentialLoanAppIdToFlagBooleansMap = new Map<Id, Map<String, Boolean>>();
        List<Aml_Flag__c> newAmlRecordsToUpsert = new List<Aml_Flag__c>();
        for ( ResidentialLoanApplication newRLApp : newResidentialLoanApps) {
            if ( oldResidentialLoanApps != null ) {
                ResidentialLoanApplication oldRLApp = oldResidentialLoanApps.get( newRLApp.Id );
                if (  oldRLApp.Status != newRLApp.Status && newRLApp.Loan_Amount__c > newRLApp.Loan_Amount_Max__c ) {
                    if ( !residentialLoanAppIdToFlagBooleansMap.containsKey(newRLApp.Id)) {
                        residentialLoanAppIdToFlagBooleansMap.put(newRLApp.Id, new Map<String, Boolean>());
                    }

                    residentialLoanAppIdToFlagBooleansMap.get( newRLApp.Id ).put( 'createLoanAmountFlag', true );
                }

                if ( ( oldRLApp.Status != newRLApp.Status && newRLApp.Loan_Amount__c < newRLApp.Loan_Amount_Max__c ) ||
                     ( oldRLApp.Loan_Amount__c != newRLApp.Loan_Amount__c && newRLApp.Loan_Amount__c < newRLApp.Loan_Amount_Max__c ) ||
                     ( oldRLApp.Loan_Amount_Max__c != newRLApp.Loan_Amount_Max__c && newRLApp.Loan_Amount__c < newRLApp.Loan_Amount_Max__c ) ) {
                    if ( !residentialLoanAppIdToFlagBooleansMap.containsKey(newRLApp.Id)) {
                        residentialLoanAppIdToFlagBooleansMap.put(newRLApp.Id, new Map<String, Boolean>());
                    }
                    residentialLoanAppIdToFlagBooleansMap.get( newRLApp.Id ).put( 'resolveLoanAmountFlag', true );
                }
            }
        }

        if ( residentialLoanAppIdToFlagBooleansMap.isEmpty() ) {
            return;
        }
        Map<Id, Map<String,Aml_Flag__c>> residentialLoanAppIdToAlmRecordsMap = new Map<Id, Map<String,Aml_Flag__c>>();

        Map<Id, ResidentialLoanApplication> qualifiedRlas = new Map<Id, ResidentialLoanApplication>([SELECT Id,
                                                                                                            (SELECT 
                                                                                                                    Id 
                                                                                                            FROM 
                                                                                                                    LoanApplicationProperties 
                                                                                                            WHERE 
                                                                                                                    Property_Type__c = 'Subject Property'),
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

            if ( residentialLoanAppIdToAlmRecordsMap.containsKey(rlaId) &&
                !residentialLoanAppIdToAlmRecordsMap.get(rlaId).containsKey('Loan Amount') &&
                 residentialLoanAppIdToFlagBooleansMap.get(rlaId).containsKey('createLoanAmountFlag') &&
                 residentialLoanAppIdToFlagBooleansMap.get(rlaId).get('createLoanAmountFlag') &&
                 qualifiedRlas.get(rlaId).LoanApplicationProperties.size() == 1 ) {
                    Aml_Flag__c amlFlagRecord = new Aml_Flag__c();
                    amlFlagRecord.Residential_Loan_Application__c = rlaId;
                    amlFlagRecord.Type__c = 'Loan Amount';
                    amlFlagRecord.Related_Property__c = qualifiedRlas.get(rlaId).LoanApplicationProperties[0].Id;
                    amlFlagRecord.Description__c = 'Loan Amount is greater than Property Value of one of the subject properties.';
                    newAmlRecordsToUpsert.add(amlFlagRecord);
            }

            if ( residentialLoanAppIdToAlmRecordsMap.containsKey(rlaId) &&
                residentialLoanAppIdToAlmRecordsMap.get(rlaId).containsKey('Loan Amount') && 
                !residentialLoanAppIdToAlmRecordsMap.get(rlaId).get('Loan Amount').Resolved__c &&
                residentialLoanAppIdToFlagBooleansMap.get(rlaId).containsKey('resolveLoanAmountFlag') &&
                residentialLoanAppIdToFlagBooleansMap.get(rlaId).get('resolveLoanAmountFlag') ) {
                    Aml_Flag__c amlFlagRecord = residentialLoanAppIdToAlmRecordsMap.get(rlaId).get('Loan Amount');
                    amlFlagRecord.Resolved__c = true;
                    newAmlRecordsToUpsert.add(amlFlagRecord);
            }
        }
        upsert newAmlRecordsToUpsert;
    }
}
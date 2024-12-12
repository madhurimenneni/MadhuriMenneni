public class LoanApplicantHandler {
    List<LoanApplicant> newLoanApplicants = new List<LoanApplicant>();
    Map<Id, LoanApplicant> oldLoanApplicants = new Map<Id, LoanApplicant>();

    public LoanApplicantHandler( List<LoanApplicant> newRecords, Map<Id, LoanApplicant> oldRecords ) {
        newLoanApplicants = newRecords;
        oldLoanApplicants = oldRecords;
    }
    
    public LoanApplicantHandler validateLoanApplicant() {
        Set<Id> rlaIdSet = new Set<Id>();
        Set<Id> newLoanApplicantsIdSet = new Set<Id>();
        List<LoanApplicant> loanApplicantList = new List<LoanApplicant>();
        for ( LoanApplicant newLoanApplicant : newLoanApplicants ) {
            if ( meetsRequirement( newLoanApplicant ) ) {
                if( newLoanApplicant.Applicant_Type__c == ApexConstants.PRIMARY_APPLICANT_TYPE ) {
                    rlaIdSet.add( newLoanApplicant.LoanApplicationId);
                }

                if ( oldLoanApplicants!= null ) {
                    if(oldLoanApplicants.keySet().contains(newLoanApplicant.Id)){
                        newLoanApplicantsIdSet.add(newLoanApplicant.Id);
                    }
                }
            }
        }
        
        Map<Id, List<LoanApplicant>> residentialLoanAppToApplicantsListMap = new Map<Id, List<LoanApplicant>>();
        for ( LoanApplicant loanApplicant : [SELECT 
                                                    Id, 
                                                    LoanApplicationId 
                                            FROM 
                                                    LoanApplicant 
                                            WHERE 
                                                    LoanApplicationId IN: rlaIdSet 
                                                                AND 
                                                    Applicant_Type__c =: ApexConstants.PRIMARY_APPLICANT_TYPE 
                                                                AND 
                                                    Id NOT IN: newLoanApplicantsIdSet] ) {
            if (!residentialLoanAppToApplicantsListMap.containsKey( loanApplicant.LoanApplicationId)) {
                residentialLoanAppToApplicantsListMap.put( loanApplicant.LoanApplicationId, new List<LoanApplicant>() );
            }
            residentialLoanAppToApplicantsListMap.get( loanApplicant.LoanApplicationId ).add( loanApplicant );
        }
        
        for( LoanApplicant newLoanApplicant : newLoanApplicants ){
                if ( residentialLoanAppToApplicantsListMap.keyset().contains( newLoanApplicant.LoanApplicationId ) &&
                !residentialLoanAppToApplicantsListMap.get( newLoanApplicant.LoanApplicationId ).isEmpty()
                && !Utils.loanApplicantValidationRule.Validate_Primary_Applicant_Type__c) {
                    if ( newLoanApplicant.RecordTypeId == Utils.corporateBorrowerLoanApplicantRecordTypeId ) {
                        newLoanApplicant.addError( 'Please fix other Loan Applicants as Co-Applicant/Guarantor' );    
                    } else {
                        newLoanApplicant.addError( 'There is already a Loan Applicant as Primary' );  
                    }
                }
            }
            return this;
    }

    public LoanApplicantHandler validateSinNumber(){
        for ( LoanApplicant newLoanApplicant : newLoanApplicants ) {
            if ( oldLoanApplicants != null ) {
                LoanApplicant oldLoanApplicant = oldLoanApplicants.get( newLoanApplicant.Id );
                if ( oldLoanApplicant.Sin__c != newLoanApplicant.Sin__c ) {
                    newLoanApplicant.Valid_Sin__c = Utils.validateSinNumber( newLoanApplicant.Sin__c );
                    newLoanApplicant.Sin_Issued_Province__c = Utils.identifySinNumberIssuedProvince( newLoanApplicant.Sin__c );
                }
            } else {
                newLoanApplicant.Valid_Sin__c = Utils.validateSinNumber( newLoanApplicant.Sin__c );
                newLoanApplicant.Sin_Issued_Province__c = Utils.identifySinNumberIssuedProvince( newLoanApplicant.Sin__c );
            }
        }
        return this;
    }
    
    public void updateLoanApplicantFields() {
        Map<Id,Id> loanAppWithPrimaryApplicantMap = new Map<Id,Id>();
        for ( LoanApplicant newLoanApplicant : newLoanApplicants ) { 
            if ( meetsRequirement( newLoanApplicant ) ) {
                    if( newLoanApplicant.Applicant_Type__c == ApexConstants.PRIMARY_APPLICANT_TYPE ) {
                        loanAppWithPrimaryApplicantMap.put(newLoanApplicant.LoanApplicationId, newLoanApplicant.Id);
                    } else {
                        loanAppWithPrimaryApplicantMap.put(newLoanApplicant.LoanApplicationId, null );
                    }
                }
            }
        if(!loanAppWithPrimaryApplicantMap.isEmpty()) {
            updateRLAApplications(loanAppWithPrimaryApplicantMap);
            updateLoanApplicationProperties(loanAppWithPrimaryApplicantMap);
            updateLoanApplicationAssets(loanAppWithPrimaryApplicantMap);
            updateLoanApplicationLiabilities(loanAppWithPrimaryApplicantMap);
        }
    }
    
    public Boolean meetsRequirement( LoanApplicant newLoanApplicant ) {
        Boolean metRequirements = false;
        if (oldLoanApplicants != null) {
            LoanApplicant oldLoanApp = oldLoanApplicants.get(newLoanApplicant.Id); 
            if (newLoanApplicant.Applicant_Type__c != oldLoanApp.Applicant_Type__c ||
                newLoanApplicant.RecordTypeId != oldLoanApp.RecordTypeId ||
                newLoanApplicant.Full_Name__c != oldLoanApp.Full_Name__c
                // ||
                // ( newLoanApplicant.Applicant_Type__c == 'Primary Applicant' && (
                // newLoanApplicant.First_Name__c != oldLoanApp.First_Name__c ||
                // newLoanApplicant.Last_Name__c != oldLoanApp.Last_Name__c ) ) 
                ) {
                    metRequirements = true; 
            }
        } else{
            metRequirements = true;
        }
        return metRequirements;
    }

    public void updateRLAApplications(Map<Id,Id> loanAppWithPrimaryApplicantMap){
        Map<Id, List<LoanApplicant>> rlaIdToLoanApplicantsMap = new Map<Id, List<LoanApplicant>>();

        for(LoanApplicant loanApplicant : [SELECT Id, 
                                                  Full_Name__c, 
                                                  Applicant_Type__c, 
                                                  LoanApplicationId
                                            FROM 
                                                    LoanApplicant 
                                            WHERE 
                                                    LoanApplicationId IN :loanAppWithPrimaryApplicantMap.keySet() ORDER BY Applicant_Type__c] ) {
            if(!rlaIdToLoanApplicantsMap.containsKey(loanApplicant.LoanApplicationId)){
                rlaIdToLoanApplicantsMap.put(loanApplicant.LoanApplicationId, new List<LoanApplicant>());
            }
            rlaIdToLoanApplicantsMap.get(loanApplicant.LoanApplicationId).add(loanApplicant);
        }
        Map<Id,List<String>> rlaIdToApplicantNameListMap = new Map<Id,List<String>>();
        Map<Id,String> rlaIdToApplicantNameMap = new Map<Id,String>();
        Map<Id,List<String>> rlaIdToBorrowerApplicantNameListMap = new Map<Id,List<String>>();
        //Map<Id,String> rlaIdToPrimaryApplicantFullnameNameListMap = new Map<Id,String>();
        Map<Id,Id> rlaIdToPrimaryApplicantId = new Map<Id,Id>();
        Map<Id,String> rlaIdToBorrowerApplicantNameMap = new Map<Id,String>();
        Map<Id,List<String>> rlaIdToGuarantorApplicantNameListMap = new Map<Id,List<String>>();
        Map<Id,String> rlaIdToGuarantorApplicantNameMap = new Map<Id,String>();
    
        for ( String rlaId : rlaIdToLoanApplicantsMap.keySet()){
            for (LoanApplicant loanApplicant : rlaIdToLoanApplicantsMap.get(rlaId)) {
                if (loanApplicant.Full_Name__c != null && loanApplicant.Applicant_Type__c != null) {
                    if(!rlaIdToApplicantNameListMap.containsKey(loanApplicant.LoanApplicationId)){
                        rlaIdToApplicantNameListMap.put(loanApplicant.LoanApplicationId, new List<String>());
                    }
                    rlaIdToApplicantNameListMap.get(loanApplicant.LoanApplicationId).add(loanApplicant.Full_Name__c);
                }
                if (loanApplicant.Full_Name__c != null && (loanApplicant.Applicant_Type__c == 'Primary Applicant' || loanApplicant.Applicant_Type__c == 'Co-Applicant')) {
                    if(!rlaIdToBorrowerApplicantNameListMap.containsKey(loanApplicant.LoanApplicationId)){
                        rlaIdToBorrowerApplicantNameListMap.put(loanApplicant.LoanApplicationId, new List<String>());
                    }
                    rlaIdToBorrowerApplicantNameListMap.get(loanApplicant.LoanApplicationId).add(loanApplicant.Full_Name__c);
                }

                if( loanApplicant.Applicant_Type__c == 'Primary Applicant' ){
                    rlaIdToPrimaryApplicantId.put(loanApplicant.LoanApplicationId, loanApplicant.Id);
                }

                // if (loanApplicant.Full_Name__c != null && (loanApplicant.Applicant_Type__c == 'Primary Applicant')) {
                //     if(!rlaIdToPrimaryApplicantFullnameNameListMap.containsKey(loanApplicant.LoanApplicationId)){
                //        rlaIdToPrimaryApplicantFullnameNameListMap.put(loanApplicant.LoanApplicationId, loanApplicant.Full_Name__c);
                //     }
                // }

                if (loanApplicant.Full_Name__c != null && loanApplicant.Applicant_Type__c == 'Guarantor') {
                    if(!rlaIdToGuarantorApplicantNameListMap.containsKey(loanApplicant.LoanApplicationId)){
                        rlaIdToGuarantorApplicantNameListMap.put(loanApplicant.LoanApplicationId, new List<String>());
                    }
                    rlaIdToGuarantorApplicantNameListMap.get(loanApplicant.LoanApplicationId).add(loanApplicant.Full_Name__c);
                }
            }
        }
		//All Applicants
        for ( String rlaId : rlaIdToApplicantNameListMap.keySet()){
            if(!rlaIdToApplicantNameListMap.get(rlaId).isEmpty()){
                String applicantsName = '';
                String lastTwoApplicantNameElement = '';
                List<String> applicantNameList = rlaIdToApplicantNameListMap.get(rlaId);
                System.debug('++++ applicantNameList ' + applicantNameList);
                if(applicantNameList.size() == 2){
                    string allstring = string.join(applicantNameList,',');
                    String[] apName = allstring.split(',');
                    applicantsName = apName[0] + ' and ' + apName[1];
                } else if (applicantNameList.size() > 2){
                    List<String> firstElementsList = new List<String>();
                    List<String> lastElementsList = new List<String>();
                    for(Integer i=0; i<applicantNameList.size()-2; i++){
                        firstElementsList.add(applicantNameList.get(i));
                    }
                    for(String st : applicantNameList){
                        if(!firstElementsList.contains(st)){
                            lastElementsList.add(st);
                        }
                    }
                    System.debug('++++ lastElementsList ' + lastElementsList);
                    lastTwoApplicantNameElement = lastElementsList[0] + ' and ' + lastElementsList[1];
                    string firstElement = string.join(firstElementsList,', ');
                    applicantsName = firstElement + ', ' + lastTwoApplicantNameElement;
                } else {
                    applicantsName = applicantNameList[0];
                }
                rlaIdToApplicantNameMap.put(rlaId, applicantsName);
            }
        }
        
        //All Borrowers
        for ( String rlaId : rlaIdToBorrowerApplicantNameListMap.keySet() ) {
            if(!rlaIdToBorrowerApplicantNameListMap.get(rlaId).isEmpty()){
                String borrowerApplicantsName = '';
                String lastTwoApplicantNameElement = '';
                List<String> borrowerApplicantNameList = rlaIdToBorrowerApplicantNameListMap.get(rlaId);
                if(borrowerApplicantNameList.size() == 2){
                    string allBorrowers = string.join(borrowerApplicantNameList,',');
                    String[] bAPName = allBorrowers.split(',');
                    borrowerApplicantsName = bAPName[0] + ' and ' + bAPName[1];
                } else if (borrowerApplicantNameList.size() > 2){
                    List<String> firstElementsList = new List<String>();
                    List<String> lastElementsList = new List<String>();
                    for(Integer i=0; i<borrowerApplicantNameList.size()-2; i++){
                        firstElementsList.add(borrowerApplicantNameList.get(i));
                    }
                    for(String st : borrowerApplicantNameList){
                        if(!firstElementsList.contains(st)){
                            lastElementsList.add(st);
                        }
                    }
                    lastTwoApplicantNameElement = lastElementsList[0] + ' and ' + lastElementsList[1];
                    string firstElement = string.join(firstElementsList,', ');
                    borrowerApplicantsName = firstElement + ', ' + lastTwoApplicantNameElement;
                } else {
                    borrowerApplicantsName = borrowerApplicantNameList[0];
                }
                rlaIdToBorrowerApplicantNameMap.put(rlaId, borrowerApplicantsName);      
            }
        }
        
        for(String rlaId : rlaIdToGuarantorApplicantNameListMap.keySet() ) {
            if(!rlaIdToGuarantorApplicantNameListMap.get(rlaId).isEmpty()){
                String guarantoraApplicantsName = '';
                String lastTwoApplicantNameElement = '';
                List<String> guarantorApplicantNameList = rlaIdToGuarantorApplicantNameListMap.get(rlaId);
                if(guarantorApplicantNameList.size() == 2){
                    string allGuarantors = string.join(guarantorApplicantNameList,',');
                    String[] gAPName = allGuarantors.split(',');
                    guarantoraApplicantsName = gAPName[0] + ' and ' + gAPName[1];
                } else if (guarantorApplicantNameList.size() > 2){
                    List<String> firstElementsList = new List<String>();
                    List<String> lastElementsList = new List<String>();
                    for(Integer i=0; i<guarantorApplicantNameList.size()-2; i++){
                        firstElementsList.add(guarantorApplicantNameList.get(i));
                    }
                    for(String st : guarantorApplicantNameList){
                        if(!firstElementsList.contains(st)){
                            lastElementsList.add(st);
                        }
                    }
                    lastTwoApplicantNameElement = lastElementsList[0] + ' and ' + lastElementsList[1];
                    string firstElement = string.join(firstElementsList,', ');
                    guarantoraApplicantsName = firstElement + ', ' + lastTwoApplicantNameElement;
                } else {
                    guarantoraApplicantsName = guarantorApplicantNameList[0];
                }
                rlaIdToGuarantorApplicantNameMap.put(rlaId, guarantoraApplicantsName);
            }
        }
        
        List<ResidentialLoanApplication> rlaToBeUpdated = new List<ResidentialLoanApplication>();
            for(ResidentialLoanApplication resLoanApp : [SELECT Id,
                                                                Name,
                                                                Applicants__c, 
                                                                Borrowers__c, 
                                                                Guarantors__c,
                                                                Primary_Applicant__c 
                                                        FROM 
                                                                ResidentialLoanApplication 
                                                        WHERE 
                                                                Id =: loanAppWithPrimaryApplicantMap.keySet()]){
                if( resLoanApp.Applicants__c != rlaIdToApplicantNameMap.get(resLoanApp.Id)){
                    resLoanApp.Applicants__c = rlaIdToApplicantNameMap.get(resLoanApp.Id);
                }
                if( resLoanApp.Borrowers__c != rlaIdToBorrowerApplicantNameMap.get(resLoanApp.Id)){
                    resLoanApp.Borrowers__c = rlaIdToBorrowerApplicantNameMap.get(resLoanApp.Id);
                }
                if( resLoanApp.Guarantors__c != rlaIdToGuarantorApplicantNameMap.get(resLoanApp.Id)){
                    resLoanApp.Guarantors__c = rlaIdToGuarantorApplicantNameMap.get(resLoanApp.Id);
                }

                if(resLoanApp.Primary_Applicant__c != rlaIdToPrimaryApplicantId.get(resLoanApp.Id)){
                    resLoanApp.Primary_Applicant__c = rlaIdToPrimaryApplicantId.get(resLoanApp.Id);
                }

                // if(rlaIdToPrimaryApplicantFullnameNameListMap.get(resLoanApp.Id) != null && resLoanApp.Name != rlaIdToPrimaryApplicantFullnameNameListMap.get(resLoanApp.Id)){
                //     resLoanApp.Name = rlaIdToPrimaryApplicantFullnameNameListMap.get(resLoanApp.Id);
                // }
                
                rlaToBeUpdated.add(resLoanApp);
            }
        if(!rlaToBeUpdated.isEmpty()){
            SObjectDomain.getTriggerEvent(ResidentialLoanApplications.class).disableAll();
            List<Database.SaveResult> results = Database.update(rlaToBeUpdated, false);
            for(Database.SaveResult sr : results) {
                if(!sr.isSuccess()) {
                    ErrorHandlingLogException.LogException(new DmlException(sr.getErrors()[0].getMessage()), sr.getId());
                }
            }
            SObjectDomain.getTriggerEvent(ResidentialLoanApplications.class).enableAll();
        }
    }

    public void updateLoanApplicationProperties(Map<Id,Id> loanAppWithPrimaryApplicantMap){
        List<LoanApplicationProperty> loanAppPropertyList = [SELECT 
                                                                    Id, 
                                                                    Primary_Applicant__c, 
                                                                    LoanApplicationId 
                                                            FROM 
                                                                    LoanApplicationProperty 
                                                            WHERE 
                                                                    LoanApplicationId IN: loanAppWithPrimaryApplicantMap.keySet()];
        
        List<LoanApplicationProperty> updatePropPrimaryApplicantList = new List<LoanApplicationProperty>();
        for( LoanApplicationProperty prop : loanAppPropertyList ) {
            if( loanAppWithPrimaryApplicantMap.containsKey( prop.LoanApplicationId ) ) {
                if( prop.Primary_Applicant__c != loanAppWithPrimaryApplicantMap.get( prop.LoanApplicationId )) {
                    prop.Primary_Applicant__c = loanAppWithPrimaryApplicantMap.get( prop.LoanApplicationId );
                    updatePropPrimaryApplicantList.add( prop );
                }
            }
        }

        if(!updatePropPrimaryApplicantList.isEmpty()) {
            SObjectDomain.getTriggerEvent(LoanApplicationProperties.class).disableAll();
            List<Database.SaveResult> results = Database.update(updatePropPrimaryApplicantList, false);
            for(Database.SaveResult sr : results) {
                if(!sr.isSuccess()) {
                    ErrorHandlingLogException.LogException(new DmlException(sr.getErrors()[0].getMessage()), sr.getId());
                }
            }
            SObjectDomain.getTriggerEvent(LoanApplicationProperties.class).enableAll();
        }
    }

    public void updateLoanApplicationAssets(Map<Id,Id> loanAppWithPrimaryApplicantMap){
        List<LoanApplicationAsset> loanAppAssetList = [SELECT Id, Primary_Applicant__c, LoanApplicationId FROM LoanApplicationAsset WHERE LoanApplicationId IN: loanAppWithPrimaryApplicantMap.keySet()];  
        List<LoanApplicationAsset> updateAssetPrimaryApplicantList = new List<LoanApplicationAsset>();
        for( LoanApplicationAsset asset : loanAppAssetList ) {
            if( loanAppWithPrimaryApplicantMap.containsKey( asset.LoanApplicationId ) &&
                asset.Primary_Applicant__c != loanAppWithPrimaryApplicantMap.get( asset.LoanApplicationId )) {
                asset.Primary_Applicant__c = loanAppWithPrimaryApplicantMap.get( asset.LoanApplicationId );
                updateAssetPrimaryApplicantList.add( asset );
            }
        }

        if(!updateAssetPrimaryApplicantList.isEmpty()) {
            SObjectDomain.getTriggerEvent(LoanApplicationAssets.class).disableAll();
            List<Database.SaveResult> results = Database.update(updateAssetPrimaryApplicantList, false);
            for(Database.SaveResult sr : results) {
                if(!sr.isSuccess()) {
                    ErrorHandlingLogException.LogException(new DmlException(sr.getErrors()[0].getMessage()), sr.getId());
                }
            }
            SObjectDomain.getTriggerEvent(LoanApplicationAssets.class).enableAll();
        }
    }

    public void updateLoanApplicationLiabilities(Map<Id,Id> loanAppWithPrimaryApplicantMap){
        List<LoanApplicationLiability> loanAppLiabilityList = [SELECT Id, 
                                                                      Primary_Applicant__c, 
                                                                      LoanApplicationId 
                                                               FROM 
                                                                      LoanApplicationLiability 
                                                               WHERE 
                                                                      LoanApplicationId IN: loanAppWithPrimaryApplicantMap.keySet()];
        
        List<LoanApplicationLiability> updateLiabilityPrimaryApplicantList = new List<LoanApplicationLiability>();
        for( LoanApplicationLiability liability : loanAppLiabilityList ) {
            if( loanAppWithPrimaryApplicantMap.containsKey( liability.LoanApplicationId ) &&
                liability.Primary_Applicant__c != loanAppWithPrimaryApplicantMap.get( liability.LoanApplicationId )) {
                liability.Primary_Applicant__c = loanAppWithPrimaryApplicantMap.get( liability.LoanApplicationId );
                updateLiabilityPrimaryApplicantList.add( liability );
            }
        }

        if(!updateLiabilityPrimaryApplicantList.isEmpty()) {
            SObjectDomain.getTriggerEvent(LoanApplicationLiabilities.class).disableAll();
            List<Database.SaveResult> results = Database.update(updateLiabilityPrimaryApplicantList, false);
            for(Database.SaveResult sr : results) {
                if(!sr.isSuccess()) {
                    ErrorHandlingLogException.LogException(new DmlException(sr.getErrors()[0].getMessage()), sr.getId());
                }
            }
            SObjectDomain.getTriggerEvent(LoanApplicationLiabilities.class).enableAll();
        }
    }
}
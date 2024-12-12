public with sharing class LoanApplicationAssetHandler {
    List<LoanApplicationAsset> newLoanApplicationAssets = new List<LoanApplicationAsset>();
    Map<Id, LoanApplicationAsset> oldLoanApplicationAssets = new Map<Id, LoanApplicationAsset>();
    public LoanApplicationAssetHandler( List<LoanApplicationAsset> newLoanApplicationAssets, Map<Id, LoanApplicationAsset> oldLoanApplicationAssets ) {
        this.newLoanApplicationAssets = newLoanApplicationAssets;
        this.oldLoanApplicationAssets = oldLoanApplicationAssets;
    }

    public void beforeOperations(){
        Set<Id> residentialLoanApplicationIds = new Set<Id>();
        for ( LoanApplicationAsset loanApplicationAsset : newLoanApplicationAssets) {
            if( oldLoanApplicationAssets != null ) {
                LoanApplicationAsset oldLoanApplicationAsset = oldLoanApplicationAssets.get( loanApplicationAsset.Id );
                if( oldLoanApplicationAsset.LoanApplicationId != loanApplicationAsset.LoanApplicationId ){
                    if( loanApplicationAsset.LoanApplicationId != null ) {
                        residentialLoanApplicationIds.add( loanApplicationAsset.LoanApplicationId );
                    } else {
                        loanApplicationAsset.Primary_Applicant__c = null;
                    }
                }
            } else if( loanApplicationAsset.LoanApplicationId != null ) {
                residentialLoanApplicationIds.add( loanApplicationAsset.LoanApplicationId );
            }
        }
        if( residentialLoanApplicationIds.size() > 0 ){
            Map<Id, ResidentialLoanApplication> residentialLoanApplicationsMap = new Map<Id, ResidentialLoanApplication>([SELECT Id, Primary_Applicant__c FROM ResidentialLoanApplication WHERE Id IN: residentialLoanApplicationIds]);

            for ( LoanApplicationAsset loanApplicationAsset : newLoanApplicationAssets) {
                loanApplicationAsset.Primary_Applicant__c = residentialLoanApplicationsMap.get( loanApplicationAsset.LoanApplicationId).Primary_Applicant__c;
            }
        }
    }
    
    public LoanApplicationAssetHandler lockLoanApplicantionAsset(){
        Id profileId = userInfo.getProfileId();
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Edit_Complete_Applications');
        if((!hasCustomPermission && ApexConstants.getProfileId != profileId)
           || Test.isRunningTest()){
            Map<Id,LoanApplicationAsset> loanAppIdWithAppAssetMap = new Map<Id,LoanApplicationAsset>();
            for ( LoanApplicationAsset newLoanApplicationAsset : newLoanApplicationAssets ) {
                if ( oldLoanApplicationAssets != null ) {
                    LoanApplicationAsset oldLoanApplicationAsset = oldLoanApplicationAssets.get( newLoanApplicationAsset.Id );
                    if ( oldLoanApplicationAsset != newLoanApplicationAsset ) {
                        loanAppIdWithAppAssetMap.put( newLoanApplicationAsset.LoanApplicationId,newLoanApplicationAsset  );
                    }
                } 
            }
            List<ResidentialLoanApplication> appList = new List<ResidentialLoanApplication>();
            Set<Id> completeLoanApplicationIdSet = new Set<Id>();system.debug(loanAppIdWithAppAssetMap.keySet().size());
            if( loanAppIdWithAppAssetMap.keySet().size() > 0 ){
                appList = [SELECT
                                      Id,
                                      Status
                              FROM
                                      ResidentialLoanApplication
                              WHERE
                                      Id IN: loanAppIdWithAppAssetMap.keySet()];
                for( ResidentialLoanApplication app : appList ){
                    if( app.Status == ApexConstants.COMPLETE_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS ){
                        completeLoanApplicationIdSet.add( app.Id );
                    }
                }
            }
            if( completeLoanApplicationIdSet.size() > 0 ){
                for ( LoanApplicationAsset newLoanApplicationAsset : newLoanApplicationAssets ) {
                    if( completeLoanApplicationIdSet.contains(newLoanApplicationAsset.LoanApplicationId) ){
                        newLoanApplicationAsset.addError('You can not edit this record');
                    }
                }
            }
        }
        return this;
    }

    public void calCulateTotalAssetValue(){
        Set<Id> loanAppIdsSet = new Set<Id>();
        List<ResidentialLoanApplication> loanAppsToUpdate = new List<ResidentialLoanApplication>();
        Map<Id,List<LoanApplicationAsset>> loanAppIdWithAppAssetMap = new Map<Id,List<LoanApplicationAsset>>();
        for ( LoanApplicationAsset newLoanApplicationAsset : newLoanApplicationAssets ) {
            if ( oldLoanApplicationAssets != null ) {
                LoanApplicationAsset oldLoanApplicationAsset = oldLoanApplicationAssets.get( newLoanApplicationAsset.Id );
                if ( oldLoanApplicationAsset.CashOrMarketValue != newLoanApplicationAsset.CashOrMarketValue ) {
                    loanAppIdsSet.add(newLoanApplicationAsset.LoanApplicationId);
                }
            } else {
                if( newLoanApplicationAsset.CashOrMarketValue != null ) {
                    loanAppIdsSet.add(newLoanApplicationAsset.LoanApplicationId);
                }
            }
        }

        if(!loanAppIdsSet.isEmpty()){
            for ( LoanApplicationAsset loanAppAsset : [ SELECT Id, LoanApplicationId, CashOrMarketValue FROM LoanApplicationAsset WHERE LoanApplicationId IN: loanAppIdsSet]){
                if(!loanAppIdWithAppAssetMap.containsKey(loanAppAsset.LoanApplicationId)){
                    loanAppIdWithAppAssetMap.put(loanAppAsset.LoanApplicationId, new List<LoanApplicationAsset>());
                }
                loanAppIdWithAppAssetMap.get(loanAppAsset.LoanApplicationId).add(loanAppAsset);
            }
        }

        if( !loanAppIdWithAppAssetMap.isEmpty() ) {
            for ( String loanAppId : loanAppIdWithAppAssetMap.keySet() ) {
                Decimal CashOrMarketValue = 0;
                for ( LoanApplicationAsset loanAppAsset : loanAppIdWithAppAssetMap.get( loanAppId )) {
                    CashOrMarketValue += loanAppAsset.CashOrMarketValue;
                }

                ResidentialLoanApplication resLoanApp = new ResidentialLoanApplication();
                resLoanApp.Id = loanAppId;
                resLoanApp.Total_Asset_Value__c = CashOrMarketValue;
                loanAppsToUpdate.add(resLoanApp);
            }
        }

        if ( loanAppsToUpdate.size() > 0 ) {
            SObjectDomain.getTriggerEvent(ResidentialLoanApplications.class).disableAll();
            List<Database.SaveResult> results = Database.update(loanAppsToUpdate, false);
            for(Database.SaveResult sr : results) {
                if(!sr.isSuccess()) {
                    ErrorHandlingLogException.LogException(new DmlException(sr.getErrors()[0].getMessage()), sr.getId());
                }
            }
            SObjectDomain.getTriggerEvent(ResidentialLoanApplications.class).enableAll();
        }
    }
}
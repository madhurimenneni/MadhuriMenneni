public class LoanApplicationPropertyHandler {
    List<LoanApplicationProperty> newLoanApplicantProperties = new List<LoanApplicationProperty>();
    Map<Id, LoanApplicationProperty> oldLoanApplicantProperties = new Map<Id, LoanApplicationProperty>();
    public static Map<Id, String> errorTypeByLoanAppPropertyId = new Map<Id, String>();
    
    @testVisible private static final String SUBJECT_OR_ASSET_PROPERTY = 'Subject or Asset Property';

    public static List<Lender_s_Lien_Type_Values__mdt> lenderValues {
        get {
            if ( lenderValues == null ) {
                lenderValues = Lender_s_Lien_Type_Values__mdt.getAll().values();
            }
            return lenderValues;
        }
        set;
    }
    
    public static Map<String,String> lenderLienTypeMap {
        get {
            if ( lenderLienTypeMap == null ) {
                lenderLienTypeMap = new Map<String,String>();
                for ( Lender_s_Lien_Type_Values__mdt staticVal : lenderValues ) {
                    lenderLienTypeMap.put(staticVal.MasterLabel, staticVal.Values__c);
                }
            }
            return lenderLienTypeMap;
        }
        set;
    }
    
    public LoanApplicationPropertyHandler( List<LoanApplicationProperty> newRecords, Map<Id, LoanApplicationProperty> oldRecordsMap ) {
        newLoanApplicantProperties = newRecords;
        oldLoanApplicantProperties = oldRecordsMap;
    }
 
    public void validateLoanApplicationProperty() {
        Set<LoanApplicationProperty> collateralPositionLoanAppPropSet = new Set<LoanApplicationProperty>();
        Set<Id> qualifiedResLoanAppIdSet = new Set<Id>();
        Set<Id> resLoanAppIdSet = new Set<Id>();
        Set<Id> propIdSet = new Set<Id>();
        Set<Id> updatedPropIdSet = new Set<Id>();
        Set<LoanApplicationProperty> addBackOrOffsetPercentageChangedpropIdSet = new Set<LoanApplicationProperty>();
        for ( LoanApplicationProperty newLoanAppProp : newLoanApplicantProperties ) {
            resLoanAppIdSet.add( newLoanAppProp.LoanApplicationId );
            if (oldLoanApplicantProperties != null && oldLoanApplicantProperties.containsKey(newLoanAppProp.Id)) {
                LoanApplicationProperty oldLoanApp = oldLoanApplicantProperties.get(newLoanAppProp.Id);
                updatedPropIdSet.add(  newLoanAppProp.Id );
                if ((newLoanAppProp.Collateral_Position__c != oldLoanApp.Collateral_Position__c)
                    || (newLoanAppProp.Property_Type__c != oldLoanApp.Property_Type__c)) {
                        collateralPositionLoanAppPropSet.add( newLoanAppProp );
                        qualifiedResLoanAppIdSet.add( newLoanAppProp.LoanApplicationId );
                        propIdSet.add( newLoanAppProp.Id );
                    }
                if ( newLoanAppProp.Add_Back_or_Offset_Percentage__c != oldLoanApp.Add_Back_or_Offset_Percentage__c ){
                    addBackOrOffsetPercentageChangedpropIdSet.add( newLoanAppProp );
                }
                } else if ( newLoanAppProp.Collateral_Position__c != null  ){
                    collateralPositionLoanAppPropSet.add( newLoanAppProp );
                    qualifiedResLoanAppIdSet.add( newLoanAppProp.LoanApplicationId );
                    propIdSet.add( newLoanAppProp.Id );
                }
        }
        Map<Id, ResidentialLoanApplication> residentialLoanApplicationsMap = new Map<Id, ResidentialLoanApplication>();
        if(Limits.getQueries() < Limits.getLimitQueries()){
            residentialLoanApplicationsMap = new Map<Id, ResidentialLoanApplication>([SELECT Id, Primary_Applicant__c FROM ResidentialLoanApplication WHERE Id IN: resLoanAppIdSet]);
        }
         

        for ( LoanApplicationProperty newLoanAppProp : newLoanApplicantProperties ) {
            if ( newLoanAppProp.Property_Type__c == ApexConstants.SUBJECT_PROPERTY_TYPE ) {
                newLoanAppProp.Primary_Applicant__c = residentialLoanApplicationsMap.get( newLoanAppProp.LoanApplicationId).Primary_Applicant__c;
            }
        }
        Map<Id,List<LoanApplicationLiability>> liabilitiesWithLoanAppPropMapForValidations = new Map<Id,List<LoanApplicationLiability>>();
        Map<Id,List<LoanApplicationLiability>> liabilitiesWithLoanAppPropMap = new Map<Id,List<LoanApplicationLiability>>();
       
        List<LoanApplicationLiability> liabilitiesList = [SELECT Id, Name, LoanApplicationId, Loan_Application_Property__r.Property_Type__c,
                                                      Loan_Application_Property__r.Collateral_Position__c, Loan_Application_Property__c,  LoanApplication.Loan_Amount__c,
                                                      Balance__c, Liability_Status__c, Position__c, Payoff__c, Liability_Type__c, Loan_Application_Property_Position__c
                                                      FROM LoanApplicationLiability
                                                      WHERE LoanApplicationId IN: resLoanAppIdSet];
        List<LoanApplicationLiability> qualifiedLiabilities = new List<LoanApplicationLiability>();
        for ( LoanApplicationLiability liability : liabilitiesList ){
            if ( qualifiedResLoanAppIdSet.contains( liability.LoanApplicationId ) && liability.Liability_Type__c == ApexConstants.MORTGAGE_LIABILITY_TYPE && liability.Loan_Application_Property__r.Property_Type__c == ApexConstants.SUBJECT_PROPERTY_TYPE){
                qualifiedLiabilities.add(liability);
            }

            if( !liabilitiesWithLoanAppPropMap.containsKey( liability.Loan_Application_Property__c ) ) {
                liabilitiesWithLoanAppPropMap.put( liability.Loan_Application_Property__c, new List<LoanApplicationLiability>() );
            }
            liabilitiesWithLoanAppPropMap.get( liability.Loan_Application_Property__c).add( liability );
        }
        // List<LoanApplicationLiability> liabilitiesList = [SELECT Id, Name, LoanApplicationId, Loan_Application_Property__r.Property_Type__c,
        //                                               Loan_Application_Property__r.Collateral_Position__c, Loan_Application_Property__c,  LoanApplication.Loan_Amount__c,
        //                                               Balance__c, Liability_Status__c, Position__c, Payoff__c, Liability_Type__c, Loan_Application_Property_Position__c
        //                                               FROM LoanApplicationLiability
        //                                               WHERE LoanApplicationId IN: qualifiedResLoanAppIdSet AND Liability_Type__c =: ApexConstants.MORTGAGE_LIABILITY_TYPE 
        //                                               AND Loan_Application_Property__r.Property_Type__c =: ApexConstants.SUBJECT_PROPERTY_TYPE];

        for ( LoanApplicationProperty loanApplicationProp : addBackOrOffsetPercentageChangedpropIdSet ){
            if( liabilitiesWithLoanAppPropMap.containsKey(loanApplicationProp.Id) ) {
                
            }
        }
        Boolean validToCalculateLTV = false;
        if(qualifiedLiabilities.size() > 0){
            for ( LoanApplicationLiability liability : qualifiedLiabilities ) {
                if( propIdSet.contains(liability.Loan_Application_Property__c) ){
                    if( !liabilitiesWithLoanAppPropMapForValidations.containsKey( liability.Loan_Application_Property__c ) ) {
                        liabilitiesWithLoanAppPropMapForValidations.put( liability.Loan_Application_Property__c, new List<LoanApplicationLiability>() );
                    }
                    liabilitiesWithLoanAppPropMapForValidations.get( liability.Loan_Application_Property__c).add( liability );
                    system.debug('final: '+liabilitiesWithLoanAppPropMapForValidations);
                }
            }
        }

        for ( LoanApplicationProperty newLoanAppProp : collateralPositionLoanAppPropSet ) {
            Boolean firstCollateralpostionExists = false;
            Boolean secondCollateralpostionExists = false;
            Boolean thirdCollateralpostionExists = false;

            Boolean firstCollateralpostionWithPayFromProceeds = false;
            Boolean secondCollateralpostionWithPayFromProceeds = false;
            Boolean thirdCollateralpostionWithPayFromProceeds = false;
            
            if ( !updatedPropIdSet.isEmpty() && updatedPropIdSet.contains( newLoanAppProp.Id ) && 
                ( newLoanAppProp.Collateral_Position__c == '2' || newLoanAppProp.Collateral_Position__c == '3'  ) && 
                ( liabilitiesWithLoanAppPropMapForValidations.get( newLoanAppProp.Id ) == null || 
                    liabilitiesWithLoanAppPropMapForValidations.get( newLoanAppProp.Id ).size() == 0  ) ) {
                system.debug('here');
                newLoanAppProp.addError( 'Collateral position for the new mortgage should be 1st' );
            }
            if( liabilitiesWithLoanAppPropMapForValidations.values().size() > 0 && 
                liabilitiesWithLoanAppPropMapForValidations.get( newLoanAppProp.Id ) != null ) {
                for ( LoanApplicationLiability liability : liabilitiesWithLoanAppPropMapForValidations.get( newLoanAppProp.Id ) ) {
                    system.debug(liability.name);
                    if ( liability.Position__c == '1' ) {
                        firstCollateralpostionExists = true;
                        if ( liability.Payoff__c == ApexConstants.PAY_FROM_PROCEEDS_PAYOFF || liability.Payoff__c == ApexConstants.BEFORE_ADVANCE_PAYOFF ) {
                            firstCollateralpostionWithPayFromProceeds = true;
                        }
                    }
                
                    if ( liability.Position__c == '2' ) {
                        secondCollateralpostionExists = true;
                        if ( liability.Payoff__c == ApexConstants.PAY_FROM_PROCEEDS_PAYOFF || liability.Payoff__c == ApexConstants.BEFORE_ADVANCE_PAYOFF ) {
                            secondCollateralpostionWithPayFromProceeds = true;
                        }
                    }
                
                    if ( liability.Position__c == '3' ) {
                        thirdCollateralpostionExists = true;
                        if ( liability.Payoff__c == ApexConstants.PAY_FROM_PROCEEDS_PAYOFF || liability.Payoff__c == ApexConstants.BEFORE_ADVANCE_PAYOFF ) {
                            thirdCollateralpostionWithPayFromProceeds = true;
                        }
                    }

                    if ( newLoanAppProp.Collateral_Position__c == '2' || newLoanAppProp.Collateral_Position__c == '3' ) {
                        Boolean throwError = false;   

                        if ( !firstCollateralpostionExists && !secondCollateralpostionExists && !thirdCollateralpostionExists ) {
                            system.debug(1);
                            throwError = true;
                        }

                        if ( liabilitiesWithLoanAppPropMapForValidations.get( newLoanAppProp.Id ).size() == 1 && firstCollateralpostionExists && firstCollateralpostionWithPayFromProceeds ) {
                            system.debug(2);
                            throwError = true;
                        }

                        if ( liabilitiesWithLoanAppPropMapForValidations.get( newLoanAppProp.Id ).size() == 3 && 
                            firstCollateralpostionExists && firstCollateralpostionWithPayFromProceeds && 
                            secondCollateralpostionExists && secondCollateralpostionWithPayFromProceeds &&
                            thirdCollateralpostionExists && thirdCollateralpostionWithPayFromProceeds) {
                            system.debug(3);
                                throwError = true;
                            }

                        if ( throwError ) {
                            newLoanAppProp.addError( 'Collateral position for the new mortgage should be 1st' );
                            continue;
                        }
                    }
            
                    if ( newLoanAppProp.Collateral_Position__c == '1' || newLoanAppProp.Collateral_Position__c == '3' ) {
                        Boolean throwError = false;
                        if ( liabilitiesWithLoanAppPropMapForValidations.get( newLoanAppProp.Id ).size() == 1 && firstCollateralpostionExists && !firstCollateralpostionWithPayFromProceeds ) {
                            system.debug(1);
                            throwError = true;
                        }
                        
                        if ( liabilitiesWithLoanAppPropMapForValidations.get( newLoanAppProp.Id ).size() == 2 && 
                            firstCollateralpostionExists && !firstCollateralpostionWithPayFromProceeds && 
                            secondCollateralpostionExists && secondCollateralpostionWithPayFromProceeds ) {
                                system.debug(2);
                                throwError = true;
                            }
                        
                        if ( liabilitiesWithLoanAppPropMapForValidations.get( newLoanAppProp.Id ).size() == 3 && 
                            firstCollateralpostionExists && !firstCollateralpostionWithPayFromProceeds && 
                            secondCollateralpostionExists && secondCollateralpostionWithPayFromProceeds &&
                            thirdCollateralpostionExists && thirdCollateralpostionWithPayFromProceeds) {
                                system.debug(3);
                                throwError = true;
                            }
                        system.debug(throwError);
                        if ( throwError ) {
                            newLoanAppProp.addError( 'Collateral position for the new mortgage should be 2nd' );
                            continue;
                        }
                    }
            
                    if ( newLoanAppProp.Collateral_Position__c == '1' || newLoanAppProp.Collateral_Position__c == '2' ) {
                        Boolean throwError = false;
                        if ( liabilitiesWithLoanAppPropMapForValidations.get( newLoanAppProp.Id ).size() == 2 && 
                            firstCollateralpostionExists && secondCollateralpostionExists && !secondCollateralpostionWithPayFromProceeds) {
                                throwError = true;
                            }
                        
                        if ( liabilitiesWithLoanAppPropMapForValidations.get( newLoanAppProp.Id ).size() == 3 && 
                            firstCollateralpostionExists && !firstCollateralpostionWithPayFromProceeds && 
                            secondCollateralpostionExists && !secondCollateralpostionWithPayFromProceeds &&
                            thirdCollateralpostionExists && thirdCollateralpostionWithPayFromProceeds) {
                                throwError = true;
                            }
                        
                        if ( throwError ) {
                            newLoanAppProp.addError( 'Collateral position for the new mortgage should be 3rd' );
                            continue;
                        }
                    }
                }
            }
        }
    }
    
    public Boolean meetsRequirementForCollateralPosition( LoanApplicationProperty newLoanAppProp ) {
        Boolean meetsRequirementForCollateralPosition = false;
        if (oldLoanApplicantProperties != null && oldLoanApplicantProperties.containsKey(newLoanAppProp.Id)) {
        LoanApplicationProperty oldLoanApp = oldLoanApplicantProperties.get(newLoanAppProp.Id);
        if ((newLoanAppProp.Collateral_Position__c != oldLoanApp.Collateral_Position__c)
            || (newLoanAppProp.Property_Type__c != oldLoanApp.Property_Type__c)) {
                     meetsRequirementForCollateralPosition = true; 
            }

        } else if ( newLoanAppProp.Collateral_Position__c != null  ){
            meetsRequirementForCollateralPosition = true; 
        }
        system.debug('meetsRequirementForCollateralPosition: '+meetsRequirementForCollateralPosition);
        return meetsRequirementForCollateralPosition;
    }
    
    public void updateLoanApplicationProperties(){
        Set<Id> loanAppIdSet = new Set<Id>();
        Set<Id> residentialLoanApplicationIds = new Set<Id>();
        for ( LoanApplicationProperty newLoanAppProperty : newLoanApplicantProperties ) { 
            loanAppIdSet.add( newLoanAppProperty.LoanApplicationId );
            
        }
        List<ResidentialLoanApplication> loanApps = [SELECT Id, Primary_Applicant__c FROM ResidentialLoanApplication WHERE Id IN: loanAppIdSet ];
        Map<Id,Id> loanAppMap = new Map<Id,Id>();
        for( ResidentialLoanApplication loanApp : loanApps ){
            loanAppMap.put( loanApp.Id, loanApp.Primary_Applicant__c );
        }
        for ( LoanApplicationProperty newLoanAppProperty : newLoanApplicantProperties ) { 
            //to update primary applicant on loan application property record insertion
            if( loanAppMap.containsKey( newLoanAppProperty.LoanApplicationId ) ){
                newLoanAppProperty.Primary_Applicant__c = loanAppMap.get( newLoanAppProperty.LoanApplicationId );
            }
        }
    }

    public void updateLoanAppPropertyValue(){
        Set<Id> residentialLoanAppIdSet = new Set<Id>();
        Map<Id, ResidentialLoanApplication> loanAppIdToLoanAppMap = new Map<Id, ResidentialLoanApplication>();
        Map<Id, List<LoanApplicationProperty>> residentialLoanAppIdMap = new Map<Id, List<LoanApplicationProperty>>();

        for ( LoanApplicationProperty newLoanAppProp : newLoanApplicantProperties ) {
            if ( oldLoanApplicantProperties != null ) {
                LoanApplicationProperty oldLoanApp = oldLoanApplicantProperties.get( newLoanAppProp.Id ); 
                if ( (newLoanAppProp.Collateral_Position__c != oldLoanApp.Collateral_Position__c) || 
                     (newLoanAppProp.Property_Type__c != oldLoanApp.Property_Type__c )|| 
                     (newLoanAppProp.Property_Value__c != oldLoanApp.Property_Value__c && newLoanAppProp.Property_Value__c != null)||
                     (newLoanAppProp.Loan_Purpose__c != oldLoanApp.Loan_Purpose__c && newLoanAppProp.Loan_Purpose__c != null)) {
                    residentialLoanAppIdSet.add( newLoanAppProp.LoanApplicationId );
                }
            } else if ( newLoanAppProp.Collateral_Position__c != null || 
                        newLoanAppProp.Property_Value__c != null || 
                        newLoanAppProp.Property_Type__c != null || 
                        newLoanAppProp.Loan_Purpose__c != null ) {
                residentialLoanAppIdSet.add( newLoanAppProp.LoanApplicationId );
            }
        }

        List<LoanApplicationProperty> loanAppPropList = [SELECT Id, 
                                                                Collateral_Position__c, 
                                                                Property_Value__c, 
                                                                LoanApplicationId, 
                                                                LoanApplication.Loan_Amount__c,
                                                                Loan_Purpose__c,
                                                                Formatted_Address__c
                                                        FROM 
                                                                LoanApplicationProperty
                                                        WHERE 
                                                                LoanApplicationId IN: residentialLoanAppIdSet 
                                                                                AND 
                                                                Collateral_Position__c != null
                                                                                AND 
                                                                Property_Type__c =: ApexConstants.SUBJECT_PROPERTY_TYPE 
                                                                                AND 
                                                                Property_Value__c != null];
        System.debug(loanAppPropList);

        for ( LoanApplicationProperty loanAppProp : loanAppPropList){
            if ( !residentialLoanAppIdMap.containsKey(loanAppProp.LoanApplicationId)){
                residentialLoanAppIdMap.put(loanAppProp.LoanApplicationId, new List<LoanApplicationProperty>());
            }

            residentialLoanAppIdMap.get( loanAppProp.LoanApplicationId).add(loanAppProp);
            loanAppIdToLoanAppMap.put(loanAppProp.LoanApplicationId, new ResidentialLoanApplication(Id = loanAppProp.LoanApplicationId ));
        }

        Map<Id,Decimal> loanAppWithPropValueMap = new Map<Id,Decimal>();
        if( !residentialLoanAppIdMap.isEmpty() )  {
            for ( String rlaId : residentialLoanAppIdMap.keyset() ) {
                Decimal sumOfLoanAppPropValue = 0;
                String loanPurposePurchase = '';
                String loanPurposeRefinance = '';
                String formattedAddress = '';
                for ( LoanApplicationProperty loanAppProperty :  residentialLoanAppIdMap.get(rlaId)) {
                    sumOfLoanAppPropValue = sumOfLoanAppPropValue + loanAppProperty.Property_Value__c;
                    if(loanAppProperty.Loan_Purpose__c == ApexConstants.PURCHASE_LOAN_PURPOSE){
                        loanPurposePurchase = ApexConstants.PURCHASE_LOAN_PURPOSE;
                  } 
                  if(loanAppProperty.Loan_Purpose__c == ApexConstants.REFINANCE_LOAN_PURPOSE || loanAppProperty.Loan_Purpose__c == ApexConstants.EQUITY_TAKEOUT_LOAN_PURPOSE){
                        loanPurposeRefinance = ApexConstants.REFINANCE_LOAN_PURPOSE;
                  }

                  formattedAddress += loanAppProperty.Formatted_Address__c + '; ';
                }
                loanAppIdToLoanAppMap.get( rlaId).Property_Value__c = sumOfLoanAppPropValue;
                loanAppIdToLoanAppMap.get( rlaId).Subject_Property_Name_List__c = formattedAddress.removeEnd('; ');
                if(loanPurposePurchase == ApexConstants.PURCHASE_LOAN_PURPOSE && loanPurposeRefinance == ''){
                    loanAppIdToLoanAppMap.get( rlaId).Loan_Purpose__c = ApexConstants.PURCHASE_LOAN_PURPOSE;
                } 
                if(loanPurposeRefinance == ApexConstants.REFINANCE_LOAN_PURPOSE && loanPurposePurchase == ''){
                    loanAppIdToLoanAppMap.get( rlaId).Loan_Purpose__c = ApexConstants.REFINANCE_LOAN_PURPOSE;
                }
                if(loanPurposeRefinance == ApexConstants.REFINANCE_LOAN_PURPOSE && loanPurposePurchase == ApexConstants.PURCHASE_LOAN_PURPOSE){
                    loanAppIdToLoanAppMap.get( rlaId).Loan_Purpose__c = ApexConstants.PURCHASE_REFINANCE_LOAN_PURPOSE;
                }
            }
        }                      
        
        //SAL - 336 (RLA Position Calculation)
        Map<Id,Set<String>> collateralPositionWithLoanAppMap = new Map<Id,Set<String>>();
        Set<String> collateralPositionSet = new Set<String>();
        
        if( loanAppPropList.size() > 0 ) {
            for( LoanApplicationProperty prop : loanAppPropList ) {
                if( !collateralPositionWithLoanAppMap.containsKey( prop.LoanApplicationId ) ) {
                    collateralPositionWithLoanAppMap.put( prop.LoanApplicationId, new Set<String>() );
                } 
            
                collateralPositionWithLoanAppMap.get( prop.LoanApplicationId ).add( prop.Collateral_Position__c );
            }
        }

        Map<Id,String> loanAppWithCollateralPositionMap = new Map<Id,String>();
        for( Id  appId : collateralPositionWithLoanAppMap.keySet() ) {
            if( collateralPositionWithLoanAppMap.get( appId ) != null ) {
                String str = String.join( new List<String>(collateralPositionWithLoanAppMap.get( appId ) ), ',' );
                ResidentialLoanApplication loanApp = new ResidentialLoanApplication();
                if ( lenderLienTypeMap.containsKey( str ) ) {
                    if ( loanAppIdToLoanAppMap.containsKey( appId ) ) {
                        loanApp = loanAppIdToLoanAppMap.get( appId );
                    } else {
                        loanApp.Id = appId;
                    }
                    loanApp.EstateHoldType = lenderLienTypeMap.get( str );
                    loanAppIdToLoanAppMap.put(appId, loanApp);
                     
                    //updateLendersLienTypeList.put( loanApp.Id, loanApp );
                }
            }
            residentialLoanAppIdSet.remove(appId);
            
        }

        if( !residentialLoanAppIdSet.isEmpty() ) {
            for( Id appId : residentialLoanAppIdSet ) {
                ResidentialLoanApplication loanApp = new ResidentialLoanApplication();
                if ( loanAppIdToLoanAppMap.containsKey( appId ) ) {
                    loanApp = loanAppIdToLoanAppMap.get( appId );
                } else {
                    loanApp.Id = appId;
                }
                loanApp.EstateHoldType = '';
                loanAppIdToLoanAppMap.put( loanApp.Id, loanApp );
            }
        }
        
        if( !loanAppIdToLoanAppMap.keySet().isEmpty() ) {
            update loanAppIdToLoanAppMap.values();
        }
    }

    public Boolean meetsRequirementForPropertyValue( LoanApplicationProperty newLoanAppProp ) {
        Boolean meetsRequirementForPropertyValue = false;
        if ( oldLoanApplicantProperties != null ) {
            LoanApplicationProperty oldLoanApp = oldLoanApplicantProperties.get( newLoanAppProp.Id ); 
            if ( newLoanAppProp.Property_Value__c != oldLoanApp.Property_Value__c
                 && newLoanAppProp.Property_Value__c != null ) {
                    meetsRequirementForPropertyValue = true; 
            }

        } else if ( newLoanAppProp.Property_Value__c != null ){
            meetsRequirementForPropertyValue = true; 
        }
        system.debug('meetsRequirementForPropertyValue: '+meetsRequirementForPropertyValue);
        return meetsRequirementForPropertyValue;
    }
    
    public LoanApplicationPropertyHandler lockLoanApplicationProperty(){
        Id profileId = userInfo.getProfileId();
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Edit_Complete_Applications');
        if(!hasCustomPermission && ApexConstants.getProfileId != profileId){
            Map<Id,LoanApplicationProperty> loanAppIdWithAppPropertyMap = new Map<Id,LoanApplicationProperty>();
            for ( LoanApplicationProperty newLoanAppProperty : newLoanApplicantProperties ) {
                if ( oldLoanApplicantProperties != null ) {
                    LoanApplicationProperty oldLoanAppProperty = oldLoanApplicantProperties.get( newLoanAppProperty.Id );
                    if ( oldLoanAppProperty != newLoanAppProperty ) {
                        loanAppIdWithAppPropertyMap.put( newLoanAppProperty.LoanApplicationId,newLoanAppProperty  );
                    }
                } 
            }
            List<ResidentialLoanApplication> appList = new List<ResidentialLoanApplication>();
            Set<Id> completeLoanApplicationIdSet = new Set<Id>();
            if( loanAppIdWithAppPropertyMap.keySet().size() > 0 ){
                appList = [SELECT Id, Status FROM ResidentialLoanApplication WHERE Id IN: loanAppIdWithAppPropertyMap.keySet()];
                for( ResidentialLoanApplication app : appList ){
                    if( app.Status == ApexConstants.COMPLETE_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS ){
                        completeLoanApplicationIdSet.add( app.Id );
                    }
                }
            }
            if( completeLoanApplicationIdSet.size() > 0 ){
                for ( LoanApplicationProperty newLoanAppProperty : newLoanApplicantProperties ) {
                    if( completeLoanApplicationIdSet.contains(newLoanAppProperty.LoanApplicationId) ){
                        newLoanAppProperty.addError('You can not edit this record as its related Application is Complete');
                    }
                }
            }
        }
        return this;
    } 
}
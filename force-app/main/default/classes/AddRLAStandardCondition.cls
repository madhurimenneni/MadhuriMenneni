public with sharing class AddRLAStandardCondition {
/*    List<ResidentialLoanApplication> newResedentialLoanApps = new List<ResidentialLoanApplication>();
    Map<Id, ResidentialLoanApplication> oldResedentialLoanApps = new Map<Id, ResidentialLoanApplication>();

    public AddRLAStandardCondition(List<ResidentialLoanApplication> newRecords, Map<Id, ResidentialLoanApplication> oldRecords) {
        newResedentialLoanApps = newRecords;
        oldResedentialLoanApps = oldRecords;
    }

    public void addRLAStandardConditions(){
        Set<Id> rlaIds = new Set<Id>();
        List<ResidentialLoanApplication> residentialLoanAppList = new List<ResidentialLoanApplication>();
        Map<Id,String> rlaPreferredLangMap = new Map<Id,String>();
        Map<Id,String> rlaLoanPurposeMap = new Map<Id,String>();
        for ( ResidentialLoanApplication newRLApp : newResedentialLoanApps) {
            // if ( oldResedentialLoanApps != null ) {
            //      ResidentialLoanApplication oldRLApp = oldResedentialLoanApps.get( newRLApp.Id );
            //      if ( oldRLApp.Status != newRLApp.Status
            //          && newRLApp.Status == ApexConstants.LEAD_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS ) {
            //             rlaIds.add( newRLApp.Id );
            //             // residentialLoanAppList.add(newRLApp);
            //             // rlaPreferredLangMap.put( newRLApp.Id, newRLApp.Preferred_Language__c );
            //             // rlaLoanPurposeMap.put( newRLApp.Id, newRLApp.Loan_Purpose__c );
            //      } 
            //  } else {
            //      if ( newRLApp.Status != null
            //          && newRLApp.Status == ApexConstants.LEAD_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS ) {
                     rlaIds.add( newRLApp.Id );
            //         residentialLoanAppList.add(newRLApp);
            //         rlaPreferredLangMap.put( newRLApp.Id, newRLApp.Preferred_Language__c );
            //         rlaLoanPurposeMap.put( newRLApp.Id, newRLApp.Loan_Purpose__c );
            //      }
            //  }
        }

        Map<Id, ResidentialLoanApplication> rlas = new Map<Id, ResidentialLoanApplication>([SELECT 
                                                        Id,
                                                        Preferred_Language__c, 
                                                        Loan_Purpose__c, 
                                                        Brokerage__c,
                                                        Pricing_Tag__c,
                                                        ( SELECT
                                                                Id,
                                                                Date_Uploaded__c,
                                                                MaritalStatus,
                                                                Sin_Issued_Province__c,
                                                                RecordType.Name
                                                         FROM
                                                                LoanApplicants ),
                                                        ( SELECT
                                                                Id,
                                                                Property_Type__c,
                                                                Property_Province__c,
                                                                Construction_Type__c,
                                                                Title_Type__c,
                                                                LoanPurposeType
                                                         FROM
                                                                LoanApplicationProperties )
                                                 FROM
                                                        ResidentialLoanApplication 
                                                 WHERE
                                                        Id IN: rlaIds ]);
        
        Map<Id, Main_Conditions__mdt> mainConditions = new Map<Id, Main_Conditions__mdt>();
        
        Map<String, Set<Id>> conditionToRlaMap = new Map<String, Set<Id>>();
        for ( ResidentialLoanApplication rla : rlas.values() ) {
            String rlaPreferredLanguage = '';
            String rlaLoanPurpose = '';
            String rlaPriceTag = '';
            
            String loanApplicantDateUploaded = '';
            String loanApplicantMaritalStatus = '';
            String loanApplicantSinFirstDigit = '';
            String loanApplicantRecordType = '';

            if ( rla.Preferred_Language__c != null ){
                rlaPreferredLanguage = rla.Preferred_Language__c;
            }

            if ( rla.Loan_Purpose__c != null ){
                rlaLoanPurpose = rla.Loan_Purpose__c;
            }

            if ( rla.Pricing_Tag__c != null ){
                rlaPriceTag = rla.Pricing_Tag__c;
            }

            if ( rla.LoanApplicationProperties.size() > 0 ) {
                for ( LoanApplicationProperty loanApplicationProperty : rla.LoanApplicationProperties ) {
                    String lapPropertyType = '';
            String lapConstructionType = '';
            String lapPropertyProvince = '';
            String lapTitleType = '';
                    if ( loanApplicationProperty.Property_Type__c != null ) {
                        lapPropertyType = loanApplicationProperty.Property_Type__c;
                    }

                    if ( loanApplicationProperty.Construction_Type__c != null ) {
                        lapConstructionType = loanApplicationProperty.Construction_Type__c;
                    }

                    if ( loanApplicationProperty.Property_Province__c != null ) {
                        lapPropertyProvince = loanApplicationProperty.Property_Province__c;
                    }

                    if ( loanApplicationProperty.Title_Type__c != null ) {
                        lapTitleType = loanApplicationProperty.Title_Type__c;
                    }

                    if ( !conditionToRlaMap.containsKey(rlaPreferredLanguage + rlaLoanPurpose  + rlaPriceTag + lapPropertyType + lapConstructionType + lapPropertyProvince + lapTitleType) ) {
                        conditionToRlaMap.put( rlaPreferredLanguage + rlaLoanPurpose  + rlaPriceTag + lapPropertyType + lapConstructionType + lapPropertyProvince + lapTitleType, new Set<Id>());
                    }
                    conditionToRlaMap.get( rlaPreferredLanguage + rlaLoanPurpose  + rlaPriceTag + lapPropertyType + lapConstructionType + lapPropertyProvince + lapTitleType).add(rla.Id );
                    System.debug(conditionToRlaMap);

                }
            }

            if ( rla.LoanApplicants.size() > 0 ) {

            }
        }

        System.debug( conditionToRlaMap );

        //get main conditions from metadata
        Map<String,Master_Conditon__mdt> masterConditionTemplate = Master_Conditon__mdt.getAll();
        Map<String,Master_Conditon__mdt> masterConditionTemplateByConfig = new Map<String,Master_Conditon__mdt>();
        Map<String,Master_Conditon__mdt> masterConditionsVsSubConditions =  new Map<String,Master_Conditon__mdt>();
        String masterConditionKeyStr = null;
        Map<String, Id> conditionToMasterConditionMap = new Map<String, Id>();
        for( Master_Conditon__mdt masterConditionRec : [SELECT
                                                            Id,DeveloperName,RLA_Pricing_Tag__c,
                                                            RLA_Preferred_Language__c,
                                                            RLA_Loan_Purpose__c,
                                                            Prop_Property_Type__c,
                                                            Prop_Construction_Type__c,
                                                            Prop_Property_Province__c,
                                                            Prop_Title_Type__c
                                                     FROM 
                                                     Master_Conditon__mdt ] ){
            System.debug( masterConditionRec );
            //for(SObjectField field: Main_Conditions__mdt.sobjectType.getDescribe().fields.getMap().values()) {
                String rlaPreferredLanguage = '';
                String rlaLoanPurpose = '';
                String rlaPriceTag = '';
                String lapPropertyType = '';
                String lapConstructionType = '';
                String lapPropertyProvince = '';
                String lapTitleType = '';
                String loanApplicantDateUploaded = '';
                String loanApplicantMaritalStatus = '';
                String loanApplicantSinFirstDigit = '';
                String loanApplicantRecordType = '';

                if ( masterConditionRec.RLA_Pricing_Tag__c != null ){
                    rlaPriceTag = masterConditionRec.RLA_Preferred_Language__c;
                }
                if ( masterConditionRec.RLA_Preferred_Language__c != null ){
                    rlaPreferredLanguage = masterConditionRec.RLA_Preferred_Language__c;
                }

                if ( masterConditionRec.RLA_Loan_Purpose__c != null ){
                    rlaLoanPurpose = masterConditionRec.RLA_Loan_Purpose__c;
                }

                    if ( masterConditionRec.Prop_Property_Type__c != null ) {
                        lapPropertyType = masterConditionRec.Prop_Property_Type__c;
                   }

                    if ( masterConditionRec.Prop_Construction_Type__c != null ) {
                        lapConstructionType = masterConditionRec.Prop_Construction_Type__c;
                    }

                    if ( masterConditionRec.Prop_Property_Province__c != null ) {
                        lapPropertyProvince = masterConditionRec.Prop_Property_Province__c;
                    }

                    if ( masterConditionRec.Prop_Title_Type__c != null ) {
                        lapTitleType = masterConditionRec.Prop_Title_Type__c;
                    }
                    System.debug('========================mc' + rlaPreferredLanguage + rlaLoanPurpose  + lapPropertyType + lapConstructionType + lapPropertyProvince + lapTitleType + masterConditionRec);
                    masterConditionTemplateByConfig.put( rlaPreferredLanguage + rlaLoanPurpose  + lapPropertyType + lapConstructionType + lapPropertyProvince + lapTitleType, masterConditionRec );                                  
                    conditionToMasterConditionMap.put( rlaPreferredLanguage + rlaLoanPurpose  + lapPropertyType + lapConstructionType + lapPropertyProvince + lapTitleType, masterConditionRec.Id );
                    masterConditionsVsSubConditions.put(masterConditionRec.DeveloperName,masterConditionRec);                                     

               
            //}
            //system.debug('mainConditionKeyStr: '+mainConditionKeyStr);
            //masterConditionTemplateByConfig.put( mainConditionKeyStr, masterConditionRec.MasterLabel );
        }

        //conditionToMasterConditionMap
        //conditionToRlaMap
        Map<Id, Id> masterConditionToRlaIds = new Map<Id, Id>();
        for ( String rlaKeyString : conditionToRlaMap.keySet() ) {
            //System.debug( rlaKeyString );
            //System.debug( conditionToRlaMap.get(rlaKeyString) );
            if( conditionToMasterConditionMap.containsKey( rlaKeyString ) ) {
                // if ( !masterConditionToRlaIds.containsKey(conditionToMasterConditionMap.get( rlaKeyString ))) {
                //     masterConditionToRlaIds.put( conditionToMasterConditionMap.get( rlaKeyString ), new Set<Id>() );
                // }
                // System.debug( masterConditionToRlaIds.get(conditionToMasterConditionMap.get( rlaKeyString )) );
                // masterConditionToRlaIds.get(conditionToMasterConditionMap.get( rlaKeyString )).addAll(conditionToRlaMap.get(rlaKeyString));
                for ( Id rlaId : conditionToRlaMap.get( rlaKeyString ) ) {
                    if ( !masterConditionToRlaIds.containsKey(rlaId)) {
                        masterConditionToRlaIds.put( rlaId, conditionToMasterConditionMap.get(rlaKeyString) );
                    }
                    //System.debug( masterConditionToRlaIds.get(conditionToMasterConditionMap.get( rlaKeyString )) );
                    //masterConditionToRlaIds.get(conditionToRlaMap.get( rlaId )).add(conditionToMasterConditionMap.get(rlaKeyString));
                }
            }
            //(masterConditionTemplateByConfig.get( rlaKeyString ), conditionToRlaMap.get(rlaKeyString))
        }

        Map<Id,Set<Id>> masterToJunctionIdsMap = new Map<Id,Set<Id>>();
        
        Set<Id> mainConditionIds = new Set<Id>();
        for ( Conditions_Junction__mdt conditionJunction : [SELECT 
                                                                    Master_Conditon__c, 
                                                                    Main_Conditions__c FROM Conditions_Junction__mdt WHERE Master_Conditon__c IN: masterConditionToRlaIds.values()]){
                
                if ( !masterToJunctionIdsMap.containsKey(conditionJunction.Master_Conditon__c) ) {
                    masterToJunctionIdsMap.put( conditionJunction.Master_Conditon__c, new Set<Id>() );
                }
                masterToJunctionIdsMap.get( conditionJunction.Master_Conditon__c ).add( conditionJunction.Main_Conditions__c );
                mainConditionIds.add( conditionJunction.Main_Conditions__c);
        }
        System.debug( masterToJunctionIdsMap );

        Map<Id,Map<Id,Set<Sub_Conditions__mdt>>> rlaIdToMainConditionIdsMap = new Map<Id,Map<Id,Set<Sub_Conditions__mdt>>>();

        for ( Id rlaId : masterConditionToRlaIds.keySet()){
            if(!rlaIdToMainConditionIdsMap.containsKey(rlaId)) {
                rlaIdToMainConditionIdsMap.put( rlaId, new Map<Id,Set<Sub_Conditions__mdt>>() );
            }
            for( Id mainConditionId : masterToJunctionIdsMap.get( masterConditionToRlaIds.get(rlaId))) {
                rlaIdToMainConditionIdsMap.get( rlaId ).put( mainConditionId, new Set<Sub_Conditions__mdt>());
            }
            
        }

        System.debug( rlaIdToMainConditionIdsMap);
        Map<Id, Main_Conditions__mdt> mainConditionsMap = new Map<Id, Main_Conditions__mdt>([SELECT Id, Automation_Logic__c, MasterLabel FROM Main_Conditions__mdt ]);

        Map<Id, Set<Sub_Conditions__mdt>> MainConditionIdToSubConditionsMap = new Map<Id, Set<Sub_Conditions__mdt>>();
        for ( Sub_Conditions__mdt subCondition : [SELECT 
                                                            Id,
                                                            Description__c,
                                                            Parent_Conditions__c
                                                    FROM 
                                                            Sub_Conditions__mdt]) {
            if ( !MainConditionIdToSubConditionsMap.containsKey( subCondition.Parent_Conditions__c ) ) {
                MainConditionIdToSubConditionsMap.put( subCondition.Parent_Conditions__c, new Set<Sub_Conditions__mdt>() );
            }
            MainConditionIdToSubConditionsMap.get( subCondition.Parent_Conditions__c ).add( subCondition );
        }

        Map<String, List<RLA_Sub_Condition__c>> subconditionsMap = new Map<String, List<RLA_Sub_Condition__c>>();
        List<RLA_Standard_Condition__c> standardConditions = new List<RLA_Standard_Condition__c>();
        for ( Id rlaId : rlaIdToMainConditionIdsMap.keySet() ) {
            for ( Id mainConditionId : rlaIdToMainConditionIdsMap.get( rlaId ).keySet() ) {
                Main_Conditions__mdt mainCondition = mainConditionsMap.get(mainConditionId);
                RLA_Standard_Condition__c standardCondition = new RLA_Standard_Condition__c();
                standardCondition.Logic__c = mainCondition.Automation_Logic__c;
                standardCondition.Residential_Loan_Application__c = rlaId;
                standardCondition.Name = mainCondition.MasterLabel;
                standardConditions.add( standardCondition );
                String standardStirng = standardCondition.Logic__c + standardCondition.Residential_Loan_Application__c + standardCondition.Name;
                for ( Sub_Conditions__mdt subCond : rlaIdToMainConditionIdsMap.get( rlaId).get( mainConditionId )) {
                    RLA_Sub_Condition__c subCondition = new RLA_Sub_Condition__c();
                    subCondition.Condition__c = subCond.Description__c;
                    subCondition.Residential_Loan_Application__c = rlaId;
                    if ( !subconditionsMap.containsKey( standardStirng ) ) {
                        subconditionsMap.put( standardStirng, new List<RLA_Sub_Condition__c>() );
                    }
                    subconditionsMap.get( standardStirng  ).add( subCondition );
                }
            }
        }

        insert standardConditions;

        List<RLA_Sub_Condition__c> subConditionsToInsert = new List<RLA_Sub_Condition__c>();

        for ( RLA_Standard_Condition__c standardCondition : standardConditions ) {
            String standardStirng = standardCondition.Logic__c + standardCondition.Residential_Loan_Application__c + standardCondition.Name;
            System.debug( subconditionsMap);
            System.debug( standardCondition);
            for (  RLA_Sub_Condition__c subCondition : subconditionsMap.get( standardStirng ) ){
                subCondition.RLA_Standard_Condition__c = standardCondition.Id;
                subConditionsToInsert.add( subCondition );
            }
            System.debug( subconditionsMap);
        }

        insert subConditionsToInsert;
        System.debug( rlaIdToMainConditionIdsMap);
    }  */
}
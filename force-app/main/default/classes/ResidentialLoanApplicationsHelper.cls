/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-01-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class ResidentialLoanApplicationsHelper {
    List<ResidentialLoanApplication> newResedentialLoanApps = new List<ResidentialLoanApplication>();
    Map<Id, ResidentialLoanApplication> oldResedentialLoanApps = new Map<Id, ResidentialLoanApplication>();
   
    public ResidentialLoanApplicationsHelper( List<ResidentialLoanApplication> newRecords, Map<Id, ResidentialLoanApplication> oldRecordsMap ) {
        newResedentialLoanApps = newRecords;
        oldResedentialLoanApps = oldRecordsMap;
    }
   
    public ResidentialLoanApplicationsHelper updateBrokerKpis() {
        Set<Id> brokerIds = new Set<Id>();
        Map<Id, List<ResidentialLoanApplication>> brokerResidentialLoanApplicationsMap = new Map<Id, List<ResidentialLoanApplication>>();
        for(ResidentialLoanApplication newResedentialLoanApp : newResedentialLoanApps ){
            if( newResedentialLoanApp.contact__c != null && newResedentialLoanApp.Status != ApexConstants.FAILED_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS ) {
                if ( oldResedentialLoanApps != null ) {
                    ResidentialLoanApplication oldResedentialLoanApp = oldResedentialLoanApps.get(newResedentialLoanApp.Id);
                    if ( oldResedentialLoanApp.Status != newResedentialLoanApp.Status ) {
                        brokerIds.add( newResedentialLoanApp.Contact__c );
                        brokerResidentialLoanApplicationsMap.put( newResedentialLoanApp.Contact__c, new List<ResidentialLoanApplication>() );
                    }

                    if ( oldResedentialLoanApp.Contact__c != newResedentialLoanApp.Contact__c ) {
                        if ( oldResedentialLoanApp.Contact__c != null ){
                            brokerIds.add( oldResedentialLoanApp.Contact__c );
                            brokerResidentialLoanApplicationsMap.put( oldResedentialLoanApp.Contact__c, new List<ResidentialLoanApplication>() );
                        }

                        if ( newResedentialLoanApp.Contact__c != null ){
                            brokerIds.add( newResedentialLoanApp.Contact__c );
                            brokerResidentialLoanApplicationsMap.put( newResedentialLoanApp.Contact__c, new List<ResidentialLoanApplication>() );
                        }
                    }
                } else {
                    brokerIds.add( newResedentialLoanApp.Contact__c );
                    brokerResidentialLoanApplicationsMap.put( newResedentialLoanApp.Contact__c, new List<ResidentialLoanApplication>() );
                }
            }
        }
        if( !brokerIds.isEmpty() ) {
            for( ResidentialLoanApplication rla : [SELECT Id,
                                                        Lendesk_Creation_Date__c,
                                                        Loan_Amount__c,
                                                        Status,
                                                        Contact__c
                                                    FROM
                                                        ResidentialLoanApplication
                                                    WHERE
                                                        Contact__c IN: brokerIds ORDER BY Lendesk_Creation_Date__c asc ] ) {
                                                            if( !brokerResidentialLoanApplicationsMap.containsKey( rla.Contact__c ) ) {
                                                                brokerResidentialLoanApplicationsMap.put( rla.Contact__c, new List<ResidentialLoanApplication>() );
                                                            }
                                                           
                                                            brokerResidentialLoanApplicationsMap.get( rla.Contact__c ).add( rla );
            }

            List<Contact> contactsToUpdate = new List<Contact>();
            for ( Id brokerId : brokerResidentialLoanApplicationsMap.keySet() ) {
                Set<Date> rlaApplicationcreatedinLendeskDates = new Set<Date>();
                Contact brokerContact = new Contact();
                brokerContact.Id = brokerId;
                brokerContact.In_Progress__c = 0;
                brokerContact.Volume_Submitted_Lifetime__c = 0;
                brokerContact.Volume_Funded__c = 0;
                brokerContact.Submitted_Lifetime__c = 0;
                brokerContact.Funded__c = 0;
                brokerContact.Of_Applications_In_12_Months__c = 0;
                brokerContact.Volume_submitted_in_12_months__c = 0;
                brokerContact.Complete_Funded_in_last_12_months__c = 0;
                brokerContact.Volume_Funded_in_12_Months__c = 0;
                brokerContact.Of_Applications_In_24_Months__c = 0;
                brokerContact.Complete_in_last_24_months__c = 0;
                brokerContact.cancelled__c = 0;
                brokerContact.Declined_Lifetime__c = 0;
                brokerContact.RFM_Completed_Deals_in_Calculated_Month__c = 0;
                brokerContact.RFM_Total_Deals_in_Calculated_Month__c = 0;
                brokerContact.Submitted_This_Year__c = 0;
                brokerContact.Completed_This_Year__c = 0;
                brokerContact.Submitted_Last_Year__c = 0;
                brokerContact.Completed_Last_Year__c = 0;
                if( brokerResidentialLoanApplicationsMap.get( brokerId ) != null && brokerResidentialLoanApplicationsMap.get( brokerId ).size() >0 ) {
                    brokerContact.RFM_First_Application_Submitted_Date__c = Date.valueOf( brokerResidentialLoanApplicationsMap.get( brokerId )[0]. Lendesk_Creation_Date__c );
                } else {
                    brokerContact.RFM_First_Application_Submitted_Date__c = null;
                }
               
                for( ResidentialLoanApplication rla : brokerResidentialLoanApplicationsMap.get( brokerId ) ) {
                    brokerContact.Submitted_Lifetime__c += 1;
                    if( rla.Lendesk_Creation_Date__c.year() == System.today().year() ) {
                        brokerContact.Submitted_This_Year__c += 1;
                    }

                    if( rla.Lendesk_Creation_Date__c.year() == ( System.today().year() - 1)  ) {
                        brokerContact.Submitted_Last_Year__c += 1;
                    }

                    if( rla.Status != 'Complete' && rla.Status != 'Declined' && rla.Status != 'Cancelled' ) {
                        brokerContact.In_Progress__c += 1;
                    }

                    if( rla.Loan_Amount__c != null ) {
                        brokerContact.Volume_Submitted_Lifetime__c += rla.Loan_Amount__c;
                    }

                    if( rla.Status == 'Complete' ) {
                        if ( rla.Loan_Amount__c != null ) {
                            brokerContact.Volume_Funded__c += rla.Loan_Amount__c;
                        }

                        if( rla.Lendesk_Creation_Date__c.year() == System.today().year() ) {
                            brokerContact.Completed_This_Year__c += 1;
                        }

                        if( rla.Lendesk_Creation_Date__c.year() == ( System.today().year() - 1)  ) {
                            brokerContact.Completed_Last_Year__c += 1;
                        }

                        brokerContact.Funded__c += 1;
                    }

                   
                    if( rla.Lendesk_Creation_Date__c != null ) {
                        rlaApplicationcreatedinLendeskDates.add(Date.valueOf( rla.Lendesk_Creation_Date__c ));
                    }
                    if( rla.Lendesk_Creation_Date__c > System.today().addMonths( -12 ) ) {
                        brokerContact.Of_Applications_In_12_Months__c += 1;
                        if ( rla.Loan_Amount__c != null ) {
                            brokerContact.Volume_submitted_in_12_months__c += rla.Loan_Amount__c;
                        }
                        if ( rla.Status == 'Complete' ) {
                            brokerContact.Complete_Funded_in_last_12_months__c += 1;
                            if ( rla.Loan_Amount__c != null ) {
                                brokerContact.Volume_Funded_in_12_Months__c += rla.Loan_Amount__c;
                            }
                        }
                    }
                    if( rla.Lendesk_Creation_Date__c > System.today().addMonths( -24 ) ) {
                        brokerContact.Of_Applications_In_24_Months__c += 1;
                        if ( rla.Status == 'Complete' ) {
                            brokerContact.Complete_in_last_24_months__c += 1;
                        }
                    }
                   
                    if( rla.Status == 'Cancelled' ) {
                        brokerContact.cancelled__c += 1;
                    }
                    if( rla.Status == 'Declined' ) {
                        brokerContact.Declined_Lifetime__c += 1;
                    }
                }
           
                List<Date> rlaApplicationcreatedinLendeskDatesList = new List<Date>(rlaApplicationcreatedinLendeskDates);
                rlaApplicationcreatedinLendeskDatesList.sort();
                if( rlaApplicationcreatedinLendeskDatesList.size() > 0 ) {
                    if( rlaApplicationcreatedinLendeskDatesList.size() > 1 ) {
                        brokerContact.Date_last_deal_submitted__c = rlaApplicationcreatedinLendeskDatesList[rlaApplicationcreatedinLendeskDatesList.size() - 1];
                    } else {
                        brokerContact.Date_last_deal_submitted__c = rlaApplicationcreatedinLendeskDatesList[0];
                    }
                }
               
                if( brokerContact.Date_last_deal_submitted__c > System.today().addMonths( -12 ) ) {
                        brokerContact.RFM_Completed_Deals_in_Calculated_Month__c = brokerContact.Complete_Funded_in_last_12_months__c;
                } else {
                    brokerContact.RFM_Completed_Deals_in_Calculated_Month__c = brokerContact.Funded__c;
                }
                   
                if( brokerContact.Date_last_deal_submitted__c > System.today().addMonths( -12 ) ) {
                    brokerContact.RFM_Total_Deals_in_Calculated_Month__c = brokerContact.Of_Applications_In_12_Months__c;
                } else {
                    brokerContact.RFM_Total_Deals_in_Calculated_Month__c = brokerContact.Submitted_Lifetime__c;
                }
                contactsToUpdate.add( brokerContact );
            }
            if( !contactsToUpdate.isEmpty() ) {
                update contactsToUpdate;
            }
        }
        return this;
    }

    public void addStandardConditionsOnRLA(){
        Map<Id, ResidentialLoanApplication> residentialLoanAppIdSet = new Map<Id, ResidentialLoanApplication>();
        Set<String> standardConditonsLabels = new Set<String>{'Standard Conditions', 'QC Standard Conditions FR', 'QC Standard Conditions English'};
        for ( ResidentialLoanApplication newRLApp : newResedentialLoanApps) {
            if ( oldResedentialLoanApps != null ) {
                ResidentialLoanApplication oldRLApp = oldResedentialLoanApps.get( newRLApp.Id );
                if ( oldRLApp.Status != newRLApp.Status ) {
                    if ( newRLApp.Status != null && newRlApp.Status == ApexConstants.LEAD_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS ) {
                        residentialLoanAppIdSet.put(newRLApp.Id, newRLApp);
                    }
                }
            } else {
                if ( newRLApp.Status != null && newRlApp.Status == ApexConstants.LEAD_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS ) {
                    residentialLoanAppIdSet.put(newRLApp.Id, newRLApp);
                }
            }
        }

        if ( residentialLoanAppIdSet.isEmpty() ) {
            return;
        }

        Map<String, Main_Conditions__mdt> mainConditionMap = new Map<String, Main_Conditions__mdt>();
        for ( Main_conditions__mdt mainCondition : [SELECT
                                                            Id,
                                                            MasterLabel
                                                    FROM
                                                            Main_Conditions__mdt
                                                    WHERE
                                                            MasterLabel IN: standardConditonsLabels] ) {
                                                                mainConditionMap.put( mainCondition.MasterLabel, mainCondition );
                                                            }
       
        List<RLA_Standard_Condition__c> alreadyExistingConditions = [SELECT
                                                                            Id,
                                                                            Name,
                                                                            Residential_Loan_Application__c,
                                                                            (SELECT
                                                                                    Id,
                                                                                    Name,
                                                                                    Condition__c
                                                                            FROM
                                                                                    RLA_Sub_Conditions__r )
                                                                    FROM
                                                                            RLA_Standard_Condition__c
                                                                    WHERE
                                                                            Residential_Loan_Application__c IN: residentialLoanAppIdSet.keySet() ];
        Map<Id, RLA_Standard_Condition__c> rlaIdTostandardConditionMap = new Map<Id, RLA_Standard_Condition__c>();
        Map<Id, Map<String, List<String>>> alreadyExistingConditionsNames =  new Map<Id, Map<String, List<String>>>();
        for ( RLA_Standard_Condition__c alreadyExistingCondition : alreadyExistingConditions ) {
            if ( !rlaIdTostandardConditionMap.containsKey(alreadyExistingCondition.Residential_Loan_Application__c) ) {
                rlaIdTostandardConditionMap.put(alreadyExistingCondition.Residential_Loan_Application__c, alreadyExistingCondition);
            }
            if( !alreadyExistingConditionsNames.containsKey( alreadyExistingCondition.Residential_Loan_Application__c )) {
                alreadyExistingConditionsNames.put( alreadyExistingCondition.Residential_Loan_Application__c, new Map<String, List<String>>() );
            }
            if ( !alreadyExistingConditionsNames.get( alreadyExistingCondition.Residential_Loan_Application__c ).containsKey( alreadyExistingCondition.Name ) ) {
                alreadyExistingConditionsNames.get( alreadyExistingCondition.Residential_Loan_Application__c ).put( alreadyExistingCondition.Name, new List<String>() );
            }
            for ( RLA_Sub_Condition__c rlaSubCondition : alreadyExistingCondition.RLA_Sub_Conditions__r ) {
                alreadyExistingConditionsNames.get( alreadyExistingCondition.Residential_Loan_Application__c ).get( alreadyExistingCondition.Name ).add( rlaSubCondition.Condition__c );
            }
        }
       
        List<Main_Sub_Condition__mdt> mainSubConditions = [SELECT
                                                                Id,
                                                                Main_Conditions__c,
                                                                Main_Conditions__r.MasterLabel, Sub_Conditions__c,
                                                                MasterLabel,
                                                                Sub_Conditions__r.MasterLabel,
                                                                Sub_Conditions__r.Description__c,
                                                                Sub_Conditions__r.Condition_Assignee__c
                                                          FROM
                                                                Main_Sub_Condition__mdt
                                                          WHERE
                                                                Main_Conditions__r.MasterLabel IN: standardConditonsLabels];

        List<RLA_Standard_Condition__c> rlaStandardConditionsToInsert = new List<RLA_Standard_Condition__c>();
        for ( Id recId : residentialLoanAppIdSet.KeySet() ) {
            String conditionsSelection = '';
            if ( residentialLoanAppIdSet.get(recId).Province__c != 'QC'){
                conditionsSelection = 'Standard Conditions';
            } else if ( residentialLoanAppIdSet.get(recId).Province__c == 'QC' ) {
                if ( residentialLoanAppIdSet.get(recId).Preferred_Language__c == 'English' ) {
                    conditionsSelection = 'QC Standard Conditions English';
                } else {
                    conditionsSelection = 'QC Standard Conditions FR';
                }
            }
            if( conditionsSelection != '') {
                Main_Conditions__mdt mainCondition = mainConditionMap.get(conditionsSelection);
                if ( alreadyExistingConditionsNames.get(recId) == null || ( alreadyExistingConditionsNames.get(recId) != null && !alreadyExistingConditionsNames.get(recId).containsKey( mainCondition.MasterLabel ) ) ) {
                    RLA_Standard_Condition__c rlasc = new RLA_Standard_Condition__c();
                    rlasc.Name = mainCondition.MasterLabel;
                    rlasc.Residential_Loan_Application__c = recId;
                    rlaStandardConditionsToInsert.add( rlasc );
                }
            }
        }

        if(!rlaStandardConditionsToInsert.isEmpty()){
            insert rlaStandardConditionsToInsert;

            for ( RLA_Standard_Condition__c rlaStandardCondition : rlaStandardConditionsToInsert ) {
                rlaIdTostandardConditionMap.put( rlaStandardCondition.Residential_Loan_Application__c, rlaStandardCondition );
            }
        }

        List<RLA_Sub_Condition__c> rlaSubConditionsToInsert = new List<RLA_Sub_Condition__c>();
        for ( Id recId : residentialLoanAppIdSet.KeySet() ) {
            for(Main_Sub_Condition__mdt mscon : mainSubConditions){
                RLA_Standard_Condition__c rlasc = rlaIdTostandardConditionMap.get(recId);
                if ( mscon.Main_Conditions__r.MasterLabel == rlasc.Name ) {
                    //System.Debug( alreadyExistingConditionsNames.get(recId) );
                    //System.Debug( alreadyExistingConditionsNames.get(recId).get( mscon.Main_Conditions__r.MasterLabel ) );
                    if(alreadyExistingConditionsNames.get(recId) == null || alreadyExistingConditionsNames.get(recId).get( mscon.Main_Conditions__r.MasterLabel ) == null || !alreadyExistingConditionsNames.get(recId).get( mscon.Main_Conditions__r.MasterLabel ).contains(mscon.Sub_Conditions__r.Description__c)) {
                        RLA_Sub_Condition__c rlaSubCondition = new RLA_Sub_Condition__c();
                        rlaSubCondition.Residential_Loan_Application__c = recId;
                        rlaSubCondition.RLA_Standard_Condition__c = rlasc.Id;
                        rlaSubCondition.Condition__c = mscon.Sub_Conditions__r.Description__c;
                        if ( (mscon.Sub_Conditions__r.MasterLabel == '6' || mscon.Sub_Conditions__r.MasterLabel == '7') && 
                        (residentialLoanAppIdSet.get(recId).Brokerage_Name__c == 'RBC Alternate Mortgage Solutions' || 
                        residentialLoanAppIdSet.get(recId).Brokerage_Name__c == 'CIBC Mortgage Options') ) {
                        rlaSubCondition.Condition_Assignee__c = 'Lender\'s Lawyer';
                        } else {
                        rlaSubCondition.Condition_Assignee__c = mscon.Sub_Conditions__r.Condition_Assignee__c;
                        }
                        rlaSubConditionsToInsert.add( rlaSubCondition );
                    }
                }
            }
        }
        if(!rlaSubConditionsToInsert.isEmpty()){
            insert rlaSubConditionsToInsert;
        }

    }
    //SAL - 312
    public void residentialLoanAppValidation(){
        Set<Id> residentialLoanAppIdSet = new Set<Id>();
        for ( ResidentialLoanApplication newRLApp : newResedentialLoanApps) {
            if ( oldResedentialLoanApps != null ) {
                ResidentialLoanApplication oldRLApp = oldResedentialLoanApps.get( newRLApp.Id );
                if ( oldRLApp.Status != newRLApp.Status ) {
                    if ( newRLApp.Status != null ) {
                        residentialLoanAppIdSet.add(newRLApp.Id);
                    }
                }
            } else {
                if ( newRLApp.Status != null ) {
                    residentialLoanAppIdSet.add(newRLApp.Id);
                }
            }
        }
        if ( !residentialLoanAppIdSet.isEmpty() ) {
            //Loan Applicant Property details
            Map<Id,String> loanAppicationPropertyStateMap = new Map<Id,String>();
            Map<Id,String> propertyWithNoStreetMap = new Map<Id,String>();
            Map<Id,String> propertyWithNoCityMap = new Map<Id,String>();
            Map<Id,String> propertyWithNoStateMap = new Map<Id,String>();
            Map<Id,String> propertyWithNoPostalCodeMap = new Map<Id,String>();
            Map<Id,String> propertyWithNoCountryMap = new Map<Id,String>();
            Map<Id,String> blankTitleTypeIdMap = new Map<Id,String>();
            Map<Id,String> blankDownPayment1Map = new Map<Id,String>();
            Map<Id,List<String>> loanAppicationPropertyTitleMap = new Map<Id,List<String>>();
            Map<Id,String> loanAppicationPropertyDwellingTypeMap = new Map<Id,String>();
            Map<Id,String> loanAppicationPropertyCollateralIntendedMap  = new Map<Id,String>();
            Set<Id> loanAppicationPropertyMaritalStatusAppIdSet  = new Set<Id>();
            List<LoanApplicationProperty> loanAppPropertyList = new List<LoanApplicationProperty>();
           
                loanAppPropertyList = [SELECT Id, Name, PropertyAddress, PropertyStreet, PropertyCity, PropertyState,
                                    PropertyPostalCode, PropertyCountry, LoanApplicationId, Title_Type__c,
                                    Dwelling_Type__c, PropertyUseType, Property_Type__c, Primary_Applicant__c,
                                    Primary_Applicant__r.RecordType.DeveloperName, Primary_Applicant__r.MaritalStatus,
                                    Downpayment__c FROM LoanApplicationProperty WHERE LoanApplicationId IN: residentialLoanAppIdSet ];
           
           
           
            for ( LoanApplicationProperty loanAppProperty : loanAppPropertyList ) {
                if( loanAppProperty.Property_Type__c == ApexConstants.SUBJECT_PROPERTY_TYPE ){
                    if ( loanAppProperty.PropertyStreet == null ) {
                        propertyWithNoStreetMap.put(loanAppProperty.LoanApplicationId, loanAppProperty.Name);
                    }
                    if ( loanAppProperty.PropertyCity == null ) {
                        propertyWithNoCityMap.put(loanAppProperty.LoanApplicationId, loanAppProperty.Name);
                    }
       
                    if ( loanAppProperty.PropertyState == null ) {
                        propertyWithNoStateMap.put(loanAppProperty.LoanApplicationId, loanAppProperty.Name);
                    }
                   
                    if( loanAppProperty.PropertyState != null && loanAppProperty.PropertyState != 'BC' ) {
                        loanAppicationPropertyStateMap.put(loanAppProperty.LoanApplicationId, loanAppProperty.PropertyState);
                    }
       
                    if ( loanAppProperty.PropertyPostalCode == null ) {
                        propertyWithNoPostalCodeMap.put(loanAppProperty.LoanApplicationId, loanAppProperty.Name);
                    }
       
                    if ( loanAppProperty.PropertyCountry == null ) {
                        propertyWithNoCountryMap.put(loanAppProperty.LoanApplicationId, loanAppProperty.Name);
                    }
                    if( loanAppProperty.Title_Type__c == null ){
                        blankTitleTypeIdMap.put(loanAppProperty.LoanApplicationId, loanAppProperty.Name);
                    }
                    if( loanAppProperty.Title_Type__c != null ){
                    if( !loanAppicationPropertyTitleMap.containsKey( loanAppProperty.LoanApplicationId )){
                        loanAppicationPropertyTitleMap.put(loanAppProperty.LoanApplicationId, new List<String>());
                    }
                        loanAppicationPropertyTitleMap.get(loanAppProperty.LoanApplicationId).add(loanAppProperty.Title_Type__c);
                    }
                    if(  loanAppProperty.Dwelling_Type__c == null ){
                        loanAppicationPropertyDwellingTypeMap.put(loanAppProperty.LoanApplicationId, loanAppProperty.Name);
                    }
                    if( loanAppProperty.PropertyUseType != null && loanAppProperty.Property_Type__c == ApexConstants.SUBJECT_PROPERTY_TYPE
                        && loanAppProperty.PropertyUseType == ApexConstants.PRIMART_RESIDENCE_OCCUPANCY_TYPE ) {
                            loanAppicationPropertyMaritalStatusAppIdSet.add(loanAppProperty.LoanApplicationId);
                    }
                    if ( loanAppProperty.Downpayment__c == 0 ) {
                        blankDownPayment1Map.put(loanAppProperty.LoanApplicationId,loanAppProperty.Name);
                    }
                }
                if( loanAppProperty.PropertyUseType == null ){
                    loanAppicationPropertyCollateralIntendedMap.put(loanAppProperty.LoanApplicationId, loanAppProperty.Name);
                }
            }

            //Loan Applicant details
            Set<Id> loanAppIdSet = new Set<Id>();
            Set<Id> regularLoanAppIdSet = new Set<Id>();
            Set<Id> corporateLoanAppIdSet = new Set<Id>();
            List<LoanApplicant> loanAppList = new List<LoanApplicant>();
                loanAppList = [SELECT Id, Name, Credit_Score__c, LoanApplicationId, RecordType.DeveloperName, MaritalStatus,
                            Applicant_Type__c, Sum_of_Employments_and_Incomes__c, RecordTypeId,
                            (SELECT Id FROM LoanApplicantAddresses)
                            FROM LoanApplicant
                            WHERE LoanApplicationId IN: loanAppicationPropertyMaritalStatusAppIdSet];
           
            Decimal sum = 0.0;
            Map<Id,String> blankMaritalStatusAppIdSet = new Map<Id,String>();
            Map<Id,Decimal> creditScoreWithLoanAppMap = new Map<Id,Decimal>();
            Map<Id,String> loanApplicantRecordTypeWithLoanAppMap = new Map<Id,String>();
            Map<Id,String> blankAddressLoanApplicantMap = new Map<Id,String>();
            for ( LoanApplicant loanAppAdd : loanAppList ) {
                loanAppIdSet.add(loanAppAdd.Id);
               
                if( loanAppAdd.Applicant_Type__c == ApexConstants.PRIMARY_APPLICANT_TYPE ) {
                    loanApplicantRecordTypeWithLoanAppMap.put( loanAppAdd.LoanApplicationId, loanAppAdd.RecordType.DeveloperName );
                    if ( loanAppAdd.RecordType.DeveloperName != ApexConstants.CORPORATE_BORROWER_RECORD_TYPE_DEV_NAME ) {
                        regularLoanAppIdSet.add(loanAppAdd.LoanApplicationId);
                    } else{
                        corporateLoanAppIdSet.add(loanAppAdd.LoanApplicationId);
                    }
                }
            }
           
                for( LoanApplicant loanApp : loanAppList ) {
                    if( corporateLoanAppIdSet.size() > 0
                        && corporateLoanAppIdSet.contains(loanApp.LoanApplicationId)) {
                        if ( loanApp.Applicant_Type__c == ApexConstants.CO_APPLICANT_TYPE
                            || loanApp.Applicant_Type__c == ApexConstants.GUARANTOR_APPLICANT_TYPE) {
                            if( loanApp.LoanApplicantAddresses.size() == 0 ){
                                blankAddressLoanApplicantMap.put( loanApp.LoanApplicationId, loanApp.Name );
                            }
                        }
                    }
                    else if( (regularLoanAppIdSet.size() > 0
                        && regularLoanAppIdSet.contains(loanApp.LoanApplicationId)
                        || loanApp.RecordTypeId == null)) {
                            if( loanApp.MaritalStatus == null ){
                                blankMaritalStatusAppIdSet.put( loanApp.LoanApplicationId, loanApp.Name );
                            }
                            if( loanApp.LoanApplicantAddresses.size() == 0 ){
                                blankAddressLoanApplicantMap.put( loanApp.LoanApplicationId, loanApp.Name );
                            }
                    }
                }
           
            //Loan Applicant Address details
            Map<Id,String> applicantsWithNoResidenceStreetMap = new Map<Id,String>();
            Map<Id,String> applicantsWithNoResidenceCityMap = new Map<Id,String>();
            Map<Id,String> applicantsWithNoResidenceStateMap = new Map<Id,String>();
            Map<Id,String> applicantsWithNoResidePostalCodeMap = new Map<Id,String>();
            Map<Id,String> applicantsWithNoResidenceCountryMap = new Map<Id,String>();
            List<LoanApplicantAddress> loanAppAddrList = new List<LoanApplicantAddress>();
                loanAppAddrList  = [SELECT Id, Name, ResidenceAddress, ResidenceStreet, ResidenceCity, ResidenceState,
                                    ResidencePostalCode, ResidenceCountry, LoanApplicantId, LoanApplicationId
                                    FROM LoanApplicantAddress
                                    WHERE LoanApplicantId IN: loanAppIdSet];
           
            if( loanAppAddrList.size() > 0 ){
                for ( LoanApplicantAddress loanAppAddr : loanAppAddrList ) {
                    if( loanAppIdSet.contains(loanAppAddr.LoanApplicantId) ){
                       
                        if ( loanAppAddr.ResidenceStreet == null ) {
                            applicantsWithNoResidenceStreetMap.put(loanAppAddr.LoanApplicationId, loanAppAddr.Name);
                        }
                       
                        if ( loanAppAddr.ResidenceCity == null ) {
                            applicantsWithNoResidenceCityMap.put(loanAppAddr.LoanApplicationId, loanAppAddr.Name);
                        }
                       
                        if ( loanAppAddr.ResidenceState == null ) {
                            applicantsWithNoResidenceStateMap.put(loanAppAddr.LoanApplicationId, loanAppAddr.Name);
                        }
                       
                        if ( loanAppAddr.ResidencePostalCode == null ) {
                            applicantsWithNoResidePostalCodeMap.put(loanAppAddr.LoanApplicationId, loanAppAddr.Name);
                        }
                       
                        if ( loanAppAddr.ResidenceCountry == null ) {
                            applicantsWithNoResidenceCountryMap.put(loanAppAddr.LoanApplicationId, loanAppAddr.Name);
                        }
                    }
                }
            }/* else {
                    isblankLoanAppAddr = true;
                }*/
           
           
            Set<Id> updatePayOffLiabilityLoanAppIdSet = new Set<Id>();
            List<LoanApplicationLiability> loanAppLiabilityList = new List<LoanApplicationLiability>();
                loanAppLiabilityList = [SELECT Id, Liability_Type__c, Payoff__c, LoanApplicationId, Loan_Application_Property__r.Property_Type__c
                                        FROM LoanApplicationLiability
                                        WHERE LoanApplicationId IN: residentialLoanAppIdSet
                                        AND Loan_Application_Property__r.Property_Type__c =: ApexConstants.SUBJECT_PROPERTY_TYPE
                                        AND Liability_Type__c =: ApexConstants.MORTGAGE_LIABILITY_TYPE
                                        AND ( Payoff__c !=: ApexConstants.PAY_FROM_PROCEEDS_PAYOFF OR Payoff__c !=: ApexConstants.BEFORE_ADVANCE_PAYOFF )];
           
            for( LoanApplicationLiability liability : loanAppLiabilityList ) {
                updatePayOffLiabilityLoanAppIdSet.add( liability.LoanApplicationId );
            }
       


            //Loan Application details
            Map<Id,ResidentialLoanApplication> resAppList = new Map<Id,ResidentialLoanApplication>();
                resAppList = new Map<Id,ResidentialLoanApplication>([SELECT Id, LTV__c, Contact__r.Email, Primary_Applicant__r.Email__c,
                                                                    EstateHoldType, Primary_Applicant__r.MaritalStatus,
                                                                    Primary_Applicant__r.Applicant_Type__c
                                                                    FROM ResidentialLoanApplication
                                                                    WHERE Id IN : residentialLoanAppIdSet]);
           
            Map<Id,Id> loanAppIdQualifiedForFeeCreation = new Map<Id,Id>();
            List<Fee__c> feeList = new List<Fee__c>();
            List<Task> newTasks = new List<Task>();
           
            for ( ResidentialLoanApplication app : newResedentialLoanApps ) {
                ResidentialLoanApplication oldRLApp = oldResedentialLoanApps.get( app.Id );
                if (resAppList.keyset().contains(app.Id)
                    && app.Status != ApexConstants.DUPLICATE_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS
                    && app.Status != ApexConstants.UNPROCESSED_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS
                    && app.Status != ApexConstants.CANCELLED_STATUS
                    && app.Status != ApexConstants.DECLINED_STATUS ) {
                    //validation rules
                    String errorMessage = '';
                        if (app.Status != null && app.Status != oldRLApp.Status
                            && app.status != ApexConstants.FAILED_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS ) {
                                Boolean leadError = false;
                        if(blankAddressLoanApplicantMap.containsKey(app.Id)
                        && app.status == ApexConstants.LEAD_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS){
                            errorMessage+= 'Mailing Address is blank of '+
                            '\'' + blankAddressLoanApplicantMap.get( app.Id )+'\'' + ' |';
                            leadError = true;
                        }
                        if ( app.LTV__c != null && app.LTV__c > 75
                            && !Utils.residentialLoanAppValidationRule.Validate_LTV__c ) {
                            errorMessage+= 'LTV  is above the maximum. | ';
                            leadError = true;
                        }
                       
                        if( !Utils.residentialLoanAppValidationRule.Validate_Loan_Applicant_Address__c ){
                            if ( applicantsWithNoResidenceStreetMap.containsKey(app.Id) ) {
                                errorMessage+= 'Missing Mailing Street of '+'\''
                                + applicantsWithNoResidenceStreetMap.get(app.Id) +'\''+' | ';
                                leadError = true;
                            }
                            if ( applicantsWithNoResidenceCityMap.containsKey(app.Id) ) {
                                errorMessage+= 'Missing Mailing City of '+'\''
                                + applicantsWithNoResidenceCityMap.get(app.Id) +'\''+' | ';
                                leadError = true;
                            }
                            if ( applicantsWithNoResidenceStateMap.containsKey(app.Id) ) {
                                errorMessage+= 'Missing Mailing State of '+'\''
                                + applicantsWithNoResidenceStateMap.get(app.Id) +'\''+' | ';
                                leadError = true;
                            }
                            if ( applicantsWithNoResidePostalCodeMap.containsKey(app.Id) ) {
                                errorMessage+= 'Missing Mailing Postal code of '+'\''
                                + applicantsWithNoResidePostalCodeMap.get(app.Id) +'\''+' | ';
                                leadError = true;
                            }
                            if ( applicantsWithNoResidenceCountryMap.containsKey(app.Id) ) {
                                errorMessage+= 'Missing Mailing Country of '+'\''
                                + applicantsWithNoResidenceCountryMap.get(app.Id) +'\''+' | ';
                                leadError = true;
                            }
                        }
                        if ( loanAppicationPropertyStateMap.get(app.Id) != null
                            && loanAppicationPropertyStateMap.get(app.Id) != 'BC'
                            && app.EstateHoldType != null && app.EstateHoldType == ApexConstants.SECOND_LENDERS_LIEN_TYPE
                            && !Utils.residentialLoanAppValidationRule.Validate_2nd_Mortgage__c ) {
                                errorMessage+= '2nd mortgages are not permitted in ' + '\''
                                +loanAppicationPropertyStateMap.get(app.Id)  +'\'' +'. | ';
                                leadError = true;
                        }
                        if( !Utils.residentialLoanAppValidationRule.Validate_Collateral_Address__c ){
                            if ( propertyWithNoStreetMap.containsKey(app.Id) ) {
                                errorMessage+= 'Missing Subject Street of '+'\''
                                + propertyWithNoStreetMap.get(app.Id) +'\''+' | ';
                                leadError = true;
                            }
                            if ( propertyWithNoCityMap.containsKey(app.Id) ) {
                                errorMessage+= 'Missing Subject City of '+'\''
                                + propertyWithNoCityMap.get(app.Id) +'\''+' | ';
                                leadError = true;
                            }
                            if ( propertyWithNoStateMap.containsKey(app.Id) ) {
                                errorMessage+= 'Missing Subject State of '+'\''
                                + propertyWithNoStateMap.get(app.Id) +'\''+' | ';
                                leadError = true;
                            }
                            if ( propertyWithNoPostalCodeMap.containsKey(app.Id) ) {
                                errorMessage+= 'Missing Subject Postal code of '+'\''
                                + propertyWithNoPostalCodeMap.get(app.Id) +'\''+' | ';
                                leadError = true;
                            }
                            if ( propertyWithNoCountryMap.containsKey(app.Id) ) {
                                errorMessage+= 'Missing Subject Country of '+'\''
                                + propertyWithNoCountryMap.get(app.Id) +'\''+' | ';
                                leadError = true;
                            }
                        }
                        if ( blankTitleTypeIdMap.containsKey(app.Id)&&
                            !Utils.residentialLoanAppValidationRule.Validate_Title_Type__c ) {
                                errorMessage+= 'Missing Title Type of '+'\''
                                + blankTitleTypeIdMap.get(app.Id) +'\''+' | ';
                                leadError = true;
                        }
                       
                        if ( !blankTitleTypeIdMap.containsKey(app.Id) &&
                            loanAppicationPropertyTitleMap.containsKey(app.Id) &&
                            loanAppicationPropertyTitleMap.get(app.Id).contains(ApexConstants.LEASEHOLD_TITLE_TYPE) &&
                            !Utils.residentialLoanAppValidationRule.Validate_Title_Type__c ) {
                                errorMessage+= 'Leasehold properties are not permitted. | ';
                                leadError = true;
                        }
                        if ( loanAppicationPropertyDwellingTypeMap.containsKey(app.Id) &&
                            !Utils.residentialLoanAppValidationRule.Validate_Dwelling_Type__c ) {
                                errorMessage+= 'Missing Dwelling Type of '+'\''
                                + loanAppicationPropertyDwellingTypeMap.get(app.Id) +'\''+' | ';
                                leadError = true;
                        }
                        if ( loanAppicationPropertyCollateralIntendedMap.containsKey(app.Id) &&
                            !Utils.residentialLoanAppValidationRule.Validate_Occupancy_Type__c ) {
                                errorMessage+= 'Missing Collateral Intended Use of '+'\''
                                + loanAppicationPropertyCollateralIntendedMap.get(app.Id) +'\''+' | ';
                                leadError = true;
                        }                   
                        if (blankMaritalStatusAppIdSet.containsKey(app.Id)
                            && !Utils.residentialLoanAppValidationRule.Validate_Marital_Status__c
                            && app.status == ApexConstants.LEAD_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS) {
                                errorMessage+= 'Missing Loan Applicant Marital Status of  test ' +'\''
                                + blankMaritalStatusAppIdSet.get(app.Id) +'\''+' | ';
                                leadError = true;
                        }   
                        system.debug(app.Prepayment_Type__c != ApexConstants.CLOSED_OPTION_TYPE);
                                    system.debug(app.Prepayment_Penalty_Term_Months__c == null);
                        if ( app.Prepayment_Type__c == ApexConstants.CLOSED_OPTION_TYPE ) {
                            if( app.Prepayment_Penalty_Options__c == null
                                || app.Prepayment_Penalty_Term_Months__c == null
                                && !Utils.residentialLoanAppValidationRule.Validate_Prepayment_Details__c  ) {
                                    errorMessage+= 'Missing Prepayment Details. | ';
                                    leadError = true;
                                }
                        }           
                        if (leadError) {
                            app.addError(errorMessage, false);
                        }
                    }
                    if ( app.Status != null && app.Status != oldRLApp.Status
                        && app.Status != ApexConstants.LEAD_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS
                        && app.status != ApexConstants.FAILED_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS ) {
                        Boolean sentCommitmentError = false;
                        if ( app.AmortizationType != ApexConstants.INTEREST_ONLY_AMORTIATION_TYPE
                            && app.Amortization_Duration_Unit__c != ApexConstants.MONTHS_AMORTIZATION_DURATION_UNIT
                            && app.Amortization_Duration_Unit__c != ApexConstants.YEARS_AMORTIZATION_DURATION_UNIT
                            && !Utils.residentialLoanAppValidationRule.Validate_Amortization__c ) {
                            errorMessage+= 'Amortization Duration is not Years or Months. | ';
                            sentCommitmentError = true;
                        }
                        if ( app.Loan_Term_Months__c == null
                            && !Utils.residentialLoanAppValidationRule.Validate_Loan_Term_Months__c ) {
                            errorMessage+= 'Loan term months is blank. | ';
                            sentCommitmentError = true;
                        }
                        if ( app.Payment_Frequency__c != null
                            && app.Payment_Frequency__c != ApexConstants.MONTHLY_PAYMENT_FREQUENCY
                            && !Utils.residentialLoanAppValidationRule.Validate_Payment_Frequency__c ) {
                            errorMessage+= 'Payment frequency not Monthly. | ';
                            sentCommitmentError = true;
                        }
                        if ( app.Payment_Frequency__c != null && app.Compounding_Frequency__c != null
                            && app.Compounding_Frequency__c != ApexConstants.MONTHLY_PAYMENT_FREQUENCY
                            && !Utils.residentialLoanAppValidationRule.Validate_Compounding_Frequency__c ) {
                            errorMessage+= 'Compounding frequency not Monthly. | ';
                            sentCommitmentError = true;
                        }
                                   
                       
                        if ( app.Interest_Adjustment_Date__c == null
                            && !Utils.residentialLoanAppValidationRule.Validate_Interest_Adjustment_Date__c ) {
                            errorMessage+= 'Missing Interest Adjustment Date. | ';
                            sentCommitmentError = true;
                        }
       
                        if (sentCommitmentError) {
                            app.addError(errorMessage);
                        }
                    }
                    if ( app.Status != null && app.Status != oldRLApp.Status
                        && app.Status == ApexConstants.LEAD_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS
                        && app.status != ApexConstants.FAILED_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS ) {
                        Boolean leadError = false;
                        if( app.Loan_Purpose__c == ApexConstants.PURCHASE_LOAN_PURPOSE
                            && blankDownPayment1Map.containsKey(app.Id) ) {
                            errorMessage+= 'Down payment is blank on ' + blankDownPayment1Map.get(app.Id)+ ' |';
                            leadError = true;
                        }
                        if (leadError) {
                            app.addError(errorMessage);
                        }
                    }
                }
               
            }
        }
    }
   
    public void automationOnLeadAppStatus() {
        Set<Id> residentialLoanAppIdSet = new Set<Id>();
        Set<Id> residentialLoanAppPricingTagUpdatedIdSet = new Set<Id>();
       
        for ( ResidentialLoanApplication newRLApp : newResedentialLoanApps) {
            if ( oldResedentialLoanApps != null ) {
                ResidentialLoanApplication oldRLApp = oldResedentialLoanApps.get( newRLApp.Id );
                if ( oldRLApp.Status != newRLApp.Status ) {
                    newRLApp.Previous_RLA_Status__c = oldRLApp.Status;
                    if ( newRLApp.Status != null
                        && newRLApp.Status == ApexConstants.LEAD_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS ) {
                        residentialLoanAppIdSet.add(newRLApp.Id);
                    }
                }

                if( oldRLApp.Pricing_Tag__c != newRLApp.Pricing_Tag__c && ( ( oldRLApp.Pricing_Tag__c!= null && oldRLApp.Pricing_Tag__c.contains('KingSett') ) || ( newRLApp.Pricing_Tag__c!= null && newRLApp.Pricing_Tag__c.contains('KingSett')) )) {
                    residentialLoanAppPricingTagUpdatedIdSet.add(newRLApp.Id);
                }

                //SAL - 323 (Interest Adjustment Date)
                if ( ( oldRLApp.Close_Date__c != newRLApp.Close_Date__c ) ||
                    ( oldRLApp.Status == 'New' || oldRLApp.Status == 'Unprocessed'  && newRLApp.Status == '0. Lead') ) {
                    if ( newRLApp.Close_Date__c != null) {
                        // If Close Date is the 1st day of the month
                        if (newRLApp.Close_Date__c.day() == 1) {
                            newRLApp.Interest_Adjustment_Date__c = newRLApp.Close_Date__c;
                        } else {
                            // If Close Date is any other day, set Interest Adjustment Date to 1st day of the next month
                            newRLApp.Interest_Adjustment_Date__c = newRLApp.Close_Date__c.toStartOfMonth().addMonths(1);
                        }
                    } else if ( (oldRLApp.Loan_Purpose__c != newRLApp.Loan_Purpose__c && newRLApp.Loan_Purpose__c == 'Refinance'  && newRLApp.ASAP__c == true ) ||  
                    (oldRLApp.ASAP__c != newRLApp.ASAP__c && newRLApp.Loan_Purpose__c == 'Refinance' && newRLApp.ASAP__c == true) ) {
                        // Set Interest Adjustment Date to 1st day of the next month based on the current date
                        newRLApp.Interest_Adjustment_Date__c = Date.today().toStartOfMonth().addMonths(1);
                    }
                }
                
                if( ( oldRLApp.Interest_Adjustment_Date__c != newRLApp.Interest_Adjustment_Date__c
                    || oldRLApp.Loan_Term_Months__c != newRLApp.Loan_Term_Months__c ||
                    oldRLApp.Close_Date__c != newRLApp.Close_Date__c )
                    && newRLApp.Interest_Adjustment_Date__c != null && newRLApp.Loan_Term_Months__c != null ){
                        newRLApp.First_Payment_Date__c = newRLApp.Interest_Adjustment_Date__c.addMonths(1);
                        newRLApp.Maturity_Date__c = newRLApp.Interest_Adjustment_Date__c.addMonths(Integer.valueOf( newRLApp.Loan_Term_Months__c ));
                    }
            } else {
                if ( newRLApp.Status != null
                    && newRLApp.Status == ApexConstants.LEAD_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS ) {
                    residentialLoanAppIdSet.add(newRLApp.Id);
                }
                if( newRLApp.Interest_Adjustment_Date__c != null && newRLApp.Loan_Term_Months__c != null ){
                    newRLApp.First_Payment_Date__c = newRLApp.Interest_Adjustment_Date__c.addMonths(1);
                    newRLApp.Maturity_Date__c = newRLApp.Interest_Adjustment_Date__c.addMonths(Integer.valueOf( newRLApp.Loan_Term_Months__c ));
                }

                if (newRLApp.Status == '0. Lead') {
                    if ( newRLApp.Close_Date__c != null) {
                        // If Close Date is the 1st day of the month
                        if (newRLApp.Close_Date__c.day() == 1) {
                            newRLApp.Interest_Adjustment_Date__c = newRLApp.Close_Date__c;
                        } else {
                            // If Close Date is any other day, set Interest Adjustment Date to 1st day of the next month
                            newRLApp.Interest_Adjustment_Date__c = newRLApp.Close_Date__c.toStartOfMonth().addMonths(1);
                        }
                    } else if (newRLApp.Loan_Purpose__c == 'Refinance' && newRLApp.ASAP__c == true) {
                        // Set Interest Adjustment Date to 1st day of the next month based on the current date
                        newRLApp.Interest_Adjustment_Date__c = Date.today().toStartOfMonth().addMonths(1);
                    }
                }
            }
        }


        //SAL-273
        List<Fee__c> feeList = new List<Fee__c>();
        List<Task> newTasks = new List<Task>();   
        Map<Id, List<Fee__c>> residentialLoanIdTFeeRecordsMap = new Map<Id, List<Fee__c>>();
        if(!residentialLoanAppIdSet.isEmpty() || !residentialLoanAppPricingTagUpdatedIdSet.isEmpty()){
            List<Fee__c> feeRecords = [SELECT Id, Name, Residential_Loan_Application__c, Fee_Type__c FROM Fee__c
                                       WHERE (Fee_Type__c =: ApexConstants.WIRE_FEE_TYPE OR Fee_Type__c =: ApexConstants.LEGAL_FEE_TYPE OR Fee_Type__c =: ApexConstants.TITLE_INSURANCE_FEE_TYPE)
                                       AND ( Residential_Loan_Application__c IN : residentialLoanAppIdSet
                                            OR Residential_Loan_Application__c IN : residentialLoanAppPricingTagUpdatedIdSet ) ];
            for ( Fee__c feeRecord : feeRecords ) {
                if( !residentialLoanIdTFeeRecordsMap.containsKey(feeRecord.Residential_Loan_Application__c)){
                    residentialLoanIdTFeeRecordsMap.put( feeRecord.Residential_Loan_Application__c, new List<Fee__c>());
                }
                residentialLoanIdTFeeRecordsMap.get(feeRecord.Residential_Loan_Application__c).add(feeRecord);
            }
            Map<String,Decimal> feeMap = new Map<String,Decimal>();
            List<Apex_static_components__c> constantValues = Apex_static_components__c.getAll().values();
            for ( Apex_static_components__c staticVal : constantValues ) {
                feeMap.put(staticVal.Name, staticVal.Fee_Amount__c);
            }
            for (ResidentialLoanApplication app : newResedentialLoanApps) {
                if( residentialLoanAppIdSet.contains(app.Id)) {
                    if (feeMap.values().size() > 0 && feeRecords.isEmpty()) {
                        //creation of Fee details
                        feeList.add(new Fee__c(Residential_Loan_Application__c = app.Id,
                                            Fee_Type__c = ApexConstants.WIRE_FEE_TYPE,
                                            Amount__c = app.Pricing_Tag__c == null ? feeMap.get(ApexConstants.WIRE_FEE_TYPE) : app.Pricing_Tag__c.contains('KingSett')? 0: feeMap.get(ApexConstants.WIRE_FEE_TYPE) ) );
                        feeList.add(new Fee__c( Residential_Loan_Application__c = app.Id,
                                            Fee_Type__c = ApexConstants.LEGAL_FEE_TYPE,
                                            Amount__c = feeMap.get(ApexConstants.LEGAL_FEE_TYPE) ) );
                        feeList.add(new Fee__c( Residential_Loan_Application__c = app.Id,
                                            Fee_Type__c = ApexConstants.TITLE_INSURANCE_FEE_TYPE,
                                            Amount__c = feeMap.get(ApexConstants.TITLE_INSURANCE_FEE_TYPE ) ) );
                        system.debug('feeList: ' + feeList);
                        //creation of Final Approval task
                        newTasks.add(new Task( WhatId = app.Id,
                                            OwnerId = app.OwnerId,
                                            ActivityDate = Date.Today().addDays(2),
                                            Subject = ApexConstants.FINAL_APPROVAL_RECEIVED_SUBJECT,
                                            Status = ApexConstants.TASK_STATUS_OPEN, 
                                            Priority = ApexConstants.TASK_PRIORITY_NORMAL ) );
                    }
               
                    String feeListString = '';
                    String newTasksString = '';
       
                    if ( feeList.size() > 0 ) {
                        feeListString = JSON.serialize(feeList);
                        system.debug('feeListString: ' + feeListString);
                    }
                    if ( newTasks.size() > 0 ) {
                        newTasksString = JSON.serialize(newTasks);
                    }
                }

                if( residentialLoanAppPricingTagUpdatedIdSet.contains(app.Id)) {
                    if( residentialLoanIdTFeeRecordsMap.get(app.Id) != null &&!residentialLoanIdTFeeRecordsMap.get(app.Id).isEmpty()) {
                        for ( Fee__c feeRecord : residentialLoanIdTFeeRecordsMap.get( app.Id) ) {
                            if ( feeRecord.Fee_Type__c == ApexConstants.WIRE_FEE_TYPE){
                                if ( app.Pricing_Tag__c != null && app.Pricing_Tag__c.contains('KingSett')) {
                                    feeRecord.Amount__c = 0;
                                } else {
                                    feeRecord.Amount__c = feeMap.get(ApexConstants.WIRE_FEE_TYPE);
                                }
                            }
                            feeList.add( feeRecord );
                        }
                    }
                }

                if (feeList.size() > 0 || newTasks.size() > 0) {     
                    updateApplicationStatusToLeadFuture(JSON.serialize(feeList), JSON.serialize(newTasks));
                }
            }   
        }
    }


    public void ltvCalculator() {
        Set<Id> residentialLoanAppIdSet = new Set<Id>();
        for ( ResidentialLoanApplication newRLApp : newResedentialLoanApps ) {
            if ( meetsRequirementForLTV( newRLApp ) ) {
                residentialLoanAppIdSet.add( newRLApp.Id );
            }
        }
               
        Map<Id,Decimal> loanAppWithLTVBalanceMap = new Map<Id,Decimal>();
        Map<Id,Decimal> loanAppWithcLTVBalanceMap = new Map<Id,Decimal>();
        Decimal liabilityBalanceForLTV = 0;
        Decimal liabilityBalanceForcLTV = 0;
        if( residentialLoanAppIdSet.size() > 0 ){
            List<LoanApplicationLiability> liabilityList = new List<LoanApplicationLiability>();
                liabilityList = [SELECT Id, LoanApplicationId, Loan_Application_Property__r.Property_Type__c,
                                 Loan_Application_Property__r.Collateral_Position__c, Liability_Type__c, Balance__c,
                                 Liability_Status__c, Position__c, Payoff__c, Loan_Application_Property__c
                                 FROM  LoanApplicationLiability
                                 WHERE LoanApplicationId IN: residentialLoanAppIdSet
                                 AND Liability_Type__c =: ApexConstants.MORTGAGE_LIABILITY_TYPE
                                 AND Balance__c !=: null
                                 AND Payoff__c =: ApexConstants.NO_PAYOFF
                                 AND Loan_Application_Property__r.Property_Type__c =: ApexConstants.SUBJECT_PROPERTY_TYPE];
           
            List<LoanApplicationProperty> loanAppPropList = new List<LoanApplicationProperty>();
                loanAppPropList = [SELECT Id, Collateral_Position__c, Property_Value__c,LoanApplicationId
                                   FROM LoanApplicationProperty
                                   WHERE LoanApplicationId IN: residentialLoanAppIdSet
                                   AND Collateral_Position__c != null
                                   AND Property_Type__c =: ApexConstants.SUBJECT_PROPERTY_TYPE];
           
            Map<Id,Decimal> loanAppWithPropertyValueMap = new Map<Id,Decimal>();
            for ( LoanApplicationProperty loanAppProperty : loanAppPropList ) {
   
                if( !loanAppWithPropertyValueMap.containsKey( loanAppProperty.LoanApplicationId ) ) {
                    loanAppWithPropertyValueMap.put( loanAppProperty.LoanApplicationId, 0 );
                }
   
                Decimal propertyValue = loanAppProperty.Property_Value__c!= null ? loanAppWithPropertyValueMap.get( loanAppProperty.LoanApplicationId ) + loanAppProperty.Property_Value__c : loanAppWithPropertyValueMap.get( loanAppProperty.LoanApplicationId );
                loanAppWithPropertyValueMap.put( loanAppProperty.LoanApplicationId, propertyValue );
            }
           
            for ( LoanApplicationLiability liability : liabilityList ) {
                if ( liability.Position__c < liability.Loan_Application_Property__r.Collateral_Position__c ) {
                    liabilityBalanceForLTV = liabilityBalanceForLTV + liability.Balance__c;
                }
                liabilityBalanceForcLTV = liabilityBalanceForcLTV + liability.Balance__c;
                loanAppWithLTVBalanceMap.put( liability.LoanApplicationId, liabilityBalanceForLTV );
                loanAppWithcLTVBalanceMap.put( liability.LoanApplicationId, liabilityBalanceForcLTV );
            }
           
            Decimal LTV = 0;
            Decimal cLTV = 0;
           
            for ( ResidentialLoanApplication newRLApp : newResedentialLoanApps) {
                if(loanAppWithPropertyValueMap.get( newRLApp.Id ) != 0
                && newRLApp.Loan_Amount__c != null){
                    if ( loanAppWithLTVBalanceMap.KeySet().Size() > 0  ){
                        LTV = ((loanAppWithLTVBalanceMap.get(newRLApp.Id) + newRLApp.Loan_Amount__c)/loanAppWithPropertyValueMap.get( newRLApp.Id ))*100;
                    } else{
                        if(newRLApp.Loan_Amount__c != null && newRLApp.Property_Value__c != null){
                            LTV = (newRLApp.Loan_Amount__c/loanAppWithPropertyValueMap.get( newRLApp.Id ))*100;
                        }
                    }
                    if( loanAppWithcLTVBalanceMap.KeySet().Size() > 0 ) {
                        cLTV = ((loanAppWithcLTVBalanceMap.get(newRLApp.Id) + newRLApp.Loan_Amount__c)/loanAppWithPropertyValueMap.get( newRLApp.Id ))*100;
                    } else{
                        if(newRLApp.Loan_Amount__c != null && newRLApp.Property_Value__c != null){
                            cLTV = (newRLApp.Loan_Amount__c/loanAppWithPropertyValueMap.get( newRLApp.Id ))*100;
                        }
                    }
                }
               
               
                system.debug('LTV: '+LTV);
                system.debug('cLTV: '+cLTV);
                newRLApp.LTV__c = LTV.setScale(2);   
                newRLApp.cLTV__c = cLTV.setScale(2);
            }
        }
    }

    public Boolean meetsRequirementForLTV( ResidentialLoanApplication newLoanApp ) {
        Boolean meetsRequirementForLTV = false;
        if ( oldResedentialLoanApps != null ) {
            ResidentialLoanApplication oldLoanApp = oldResedentialLoanApps.get( newLoanApp.Id );
            system.debug( newLoanApp.EstateHoldType +' '+ oldLoanApp.EstateHoldType );
            if ( ( newLoanApp.EstateHoldType != oldLoanApp.EstateHoldType || newLoanApp.Loan_Amount__c != oldLoanApp.Loan_Amount__c || newLoanApp.Property_Value__c != oldLoanApp.Property_Value__c )
                    && newLoanApp.EstateHoldType != null
                    && newLoanApp.Loan_Amount__c != null
                    && newLoanApp.Property_Value__c != null
                    && newLoanApp.Property_Value__c > 0
                    && newLoanApp.Status != ApexConstants.FAILED_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS) {
                        meetsRequirementForLTV = true;
            }
        } else{
            if ( ( newLoanApp.EstateHoldType != null || newLoanApp.Loan_Amount__c != null )
                    && newLoanApp.Property_Value__c != null
                    && newLoanApp.Property_Value__c > 0) {
                        system.debug('true');
                        meetsRequirementForLTV = true;
            }
        }
        return meetsRequirementForLTV;
    }
   
    @future
    public static void updateApplicationStatusToLeadFuture( String feeList, String newTasks ) {
        List<Fee__c> feeValuesList = (List<Fee__c>)Json.deserialize(feeList,List<Fee__c>.class);
        system.debug('feeValuesList: ' + feeValuesList);
        List<Task> taskValuesList = (List<Task>)Json.deserialize(newTasks,List<Task>.class);
       
        if ( !feeValuesList.isEmpty() ) {
            SObjectDomain.getTriggerEvent(Fees.class).disableAll();
            upsert feeValuesList;
            SObjectDomain.getTriggerEvent(Fees.class).enableAll();
        }
        if ( !taskValuesList.isEmpty() ) {
            insert taskValuesList;
        }
    }


    //SAL-339
    public void populateRlaFields(){
        Map<Id, ResidentialLoanApplication> ResidentialLoanApplicationsIdMap = new Map<Id, ResidentialLoanApplication>();
        Set<Id> residentialLoanApplicationsIdSet = new Set<Id>();
        for ( ResidentialLoanApplication newResLoanApp : newResedentialLoanApps ) {
            if ( oldResedentialLoanApps != null ) {
                ResidentialLoanApplication oldResLoanApp = oldResedentialLoanApps.get( newResLoanApp.Id );
                if ( ( oldResLoanApp.Primary_Applicant__c != newResLoanApp.Primary_Applicant__c && newResLoanApp.Primary_Applicant__c == null ) ) {
                    residentialLoanApplicationsIdSet.add( newResLoanApp.Id );
                }
            }
        }
        if(!residentialLoanApplicationsIdSet.isEmpty()){
            for (ResidentialLoanApplication resLoanApp : [SELECT Id, Contact__r.AccountId, (SELECT Id FROM LoanApplicants WHERE Applicant_Type__c = 'Primary Applicant')
                                                           FROM ResidentialLoanApplication
                                                           WHERE Id IN: residentialLoanApplicationsIdSet]) {
                if ( resLoanApp.LoanApplicants.size() > 0 ) {
                    ResidentialLoanApplicationsIdMap.put( resLoanApp.Id, resLoanApp );
                }
            }
            for ( ResidentialLoanApplication newResLoanApp : newResedentialLoanApps ) {
                if( ResidentialLoanApplicationsIdMap.containsKey(newResLoanApp.Id) ) {
                    newResLoanApp.Primary_Applicant__c = ResidentialLoanApplicationsIdMap.get( newResLoanApp.Id ).LoanApplicants[0].Id;
                }
            }
        }
    }


    public void DeleteFailedApplications(){
        Set<Id> failedApplicationIds = new Set<Id>();

        // Find all failed applications
        for (ResidentialLoanApplication app : newResedentialLoanApps) {
            ResidentialLoanApplication oldApp = oldResedentialLoanApps.get( app.Id );
            if (app.Status == ApexConstants.FAILED_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS
                && (oldApp.Status == ApexConstants.NEW_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS
                   || oldApp.Status == ApexConstants.UNPROCESSED_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS)) {
                failedApplicationIds.add(app.Id);
            }
        }

        if ( !failedApplicationIds.isEmpty() ) {
                system.debug(System.isBatch() || System.isFuture());
            if ( System.isBatch() || System.isFuture() ) {
                Id jobID = System.enqueueJob( new ResidentialLoanApplicationQueueable( failedApplicationIds, 'failedApps' ) );
            } else {
                DeleteFailedApplicationsFuture( failedApplicationIds );
            }
        }
    }

    @future( callout = true )
    public static void DeleteFailedApplicationsFuture( Set<Id> appIds ) {
        DeleteFailedApplicationsNonFuture( appIds );
    }

    public static void DeleteFailedApplicationsNonFuture( Set<Id> appIds ) {
        if (!appIds.isEmpty()) {
            List<ResidentialLoanApplication> appList = [SELECT Id,Primary_Applicant__c FROM ResidentialLoanApplication WHERE Id IN: appIds ];
           
            // Delete Loan Applicants
            List<LoanApplicant> applicantsToDelete = [SELECT Id,LoanApplicationId,Applicant_Type__c FROM LoanApplicant WHERE LoanApplicationId IN :appIds];
            List<LoanApplicant> updatedApplicantsToDelete = new List<LoanApplicant>();
            for( LoanApplicant loanApplicant : applicantsToDelete ){
                if( loanApplicant.Applicant_Type__c == ApexConstants.PRIMARY_APPLICANT_TYPE ){
                    loanApplicant.Applicant_Type__c = ApexConstants.CO_APPLICANT_TYPE;
                }
                updatedApplicantsToDelete.add( loanApplicant );
            }
            if (!updatedApplicantsToDelete.isEmpty()) {
                update updatedApplicantsToDelete;
            }
           
            // Delete Fees
            List<Fee__c> feesToDelete = [SELECT Id FROM Fee__c WHERE Residential_Loan_Application__c IN :appIds];
            if (!feesToDelete.isEmpty()) {
                delete feesToDelete;
            }

            // Delete Loan Application Assets
            List<LoanApplicationAsset> assetsToDelete = [SELECT Id FROM LoanApplicationAsset WHERE LoanApplicationId IN :appIds];
            if (!assetsToDelete.isEmpty()) {
                delete assetsToDelete;
            }

            // Delete Loan Application Liabilities
            List<LoanApplicationLiability> liabilitiesToDelete = [SELECT Id FROM LoanApplicationLiability WHERE LoanApplicationId IN :appIds];
            if (!liabilitiesToDelete.isEmpty()) {
                delete liabilitiesToDelete;
            }
           
            // Delete Loan Applicant Addreess
            List<LoanApplicantAddress> addreessToDelete = [SELECT Id FROM LoanApplicantAddress WHERE LoanApplicationId IN :appIds];
            if (!addreessToDelete.isEmpty()) {
                delete addreessToDelete;
            }

            // Delete Loan Applicant Employments
            List<LoanApplicantEmployment> employmentsToDelete = [SELECT Id FROM LoanApplicantEmployment WHERE LoanApplicationId IN :appIds];
            if (!employmentsToDelete.isEmpty()) {
                delete employmentsToDelete;
            }
           
            // Delete Loan Applicant Incomes
            List<LoanApplicantIncome> incomesToDelete = [SELECT Id FROM LoanApplicantIncome WHERE LoanApplicationId IN :appIds];
            if (!incomesToDelete.isEmpty()) {
                delete incomesToDelete;
            }
           
            List<ResidentialLoanApplication> updatedAppList = new List<ResidentialLoanApplication>();
            for( ResidentialLoanApplication app : appList ){
                if( app.Primary_Applicant__c != null ){
                    app.Primary_Applicant__c = null;
                }
                updatedAppList.add(app);
            }
            if(!updatedAppList.isEmpty()){
                update updatedAppList;
            }
            if(!updatedAppList.isEmpty()){
                deteleRLA(updatedAppList);
            }
        }
    }
    public static void deteleRLA(List<ResidentialLoanApplication> toBeDeletedRLAList){
        if(!toBeDeletedRLAList.isEmpty()){
            delete toBeDeletedRLAList;
        }
    }

    public void updateLoanApplicationPropertyValues() {
        Set<Id> residentialLoanApplicationsIdSet = new Set<Id>();
        for ( ResidentialLoanApplication newResLoanApp : newResedentialLoanApps ) {
            if ( oldResedentialLoanApps != null ) {
                ResidentialLoanApplication oldResLoanApp = oldResedentialLoanApps.get( newResLoanApp.Id );
                if ( ( oldResLoanApp.Monthly_Payment__c != newResLoanApp.Monthly_Payment__c  ) || 
                ( oldResLoanApp.Import_Complete__c != newResLoanApp.Import_Complete__c &&
                newResLoanApp.Import_Complete__c )) {
                    residentialLoanApplicationsIdSet.add( newResLoanApp.Id );
                }
            }
        }

        Map<Id,ResidentialLoanApplication> resAppList = new Map<Id,ResidentialLoanApplication>([SELECT
                                                                                                        Id,
                                                                                                        Monthly_Payment__c,
                                                                                                        ( SELECT
                                                                                                                Id,
                                                                                                                Monthly_Mortgage_Payment__c
                                                                                                          FROM
                                                                                                                LoanApplicationProperties
                                                                                                          WHERE
                                                                                                                Property_Type__c = 'Subject Property'
                                                                                                                            AND
                                                                                                                ( Loan_Purpose__c = 'Purchase'
                                                                                                                            OR
                                                                                                                  Loan_Purpose__c = 'Refinance')
                                                                                                                            AND
                                                                                                                Collateral_Position__c = '1'),
                                                                                                        ( SELECT
                                                                                                                Id,
                                                                                                                Loan_Application_Property__c
                                                                                                          FROM
                                                                                                                LoanApplicationLiabilities )
                                                                                                FROM
                                                                                                        ResidentialLoanApplication
                                                                                                WHERE
                                                                                                        Id IN : residentialLoanApplicationsIdSet]);
        Map<Id, List<LoanApplicationLiability>>  loanApplicationPropertyIdToLoanApplicationLiabilityListMap = new Map<Id, List<LoanApplicationLiability>>();
        for( ResidentialLoanApplication rla : resAppList.values() ) {
            if ( rla.LoanApplicationLiabilities.size() > 0 ) {
                for ( LoanApplicationLiability loanApplicationLiability : rla.LoanApplicationLiabilities ) {
                    if ( !loanApplicationPropertyIdToLoanApplicationLiabilityListMap.containsKey(loanApplicationLiability.Loan_Application_Property__c ) ) {
                        loanApplicationPropertyIdToLoanApplicationLiabilityListMap.put( loanApplicationLiability.Loan_Application_Property__c, new List<LoanApplicationLiability>() );
                    }
                    loanApplicationPropertyIdToLoanApplicationLiabilityListMap.get( loanApplicationLiability.Loan_Application_Property__c ).add( loanApplicationLiability );
                }
            }
        }
        List<LoanApplicationProperty> loanApplicationPropertiesToUpdate = new List<LoanApplicationProperty>();
        for( ResidentialLoanApplication rla : resAppList.values() ) {
            if ( rla.LoanApplicationProperties.size() > 0 ) {
                for ( LoanApplicationProperty loanApplicationProperty : rla.LoanApplicationProperties ) {
                    if ( !loanApplicationPropertyIdToLoanApplicationLiabilityListMap.containsKey( loanApplicationProperty.Id ) ) {
                        loanApplicationProperty.Monthly_Mortgage_Payment__c = rla.Monthly_Payment__c;
                        loanApplicationPropertiesToUpdate.add( loanApplicationProperty );
                    }
                }
            }
        }

        update loanApplicationPropertiesToUpdate;
    }
}
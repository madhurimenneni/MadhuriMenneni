public class Utils {
    
    public static final String ACCOUNT_OBJECT_TYPE = 'Account';
    public static final String CONTACT_OBJECT_TYPE = 'Contact';
    public static final String LOAN_APPLICANT_OBJECT_TYPE = 'LoanApplicant';
    public static final String BROKERAGE_ACCOUNT_RECORD_TYPE_NAME = 'Brokerage';
    public static final String CORPORATE_BORROWER_LOAN_APPLICANT_RECORD_TYPE = 'Corporate_Borrower';
    public static final String PERSON_ACCOUNT_RECORD_TYPE_NAME = 'PersonAccount';
    public static final String BROKER_CONTACT_RECORD_TYPE_NAME = 'Broker';
    public static final String REGULAR_LOAN_APPLICANT_RECORD_TYPE_NAME = 'Regular_Borrower';
    public static final String CORPORATE_LOAN_APPLICANT_RECORD_TYPE_NAME = 'Corporate_Borrower';
    

    /**
    * A Lazy Getter and Setter method for the variable opportuisSandboxnitiesRecordTypesMap
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 28-June-2022
    * @return isSandbox
    */
    public static Boolean isSandbox {
        get {
            if ( isSandbox == null ) {
                isSandbox = [ SELECT IsSandbox FROM Organization LIMIT 1 ].IsSandbox;
            }
            return isSandbox;
        }
        set;
    }

    /**
    * A Lazy Getter and Setter method for the variable opportunitiesRecordTypesMap
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 28-June-2022
    * @return Map<String, Id>
    */
    public static Map<String, Id> accountRecordTypesMap {
        get {
            if ( accountRecordTypesMap == null ) {
                accountRecordTypesMap = Utils.getRecordTypeIdsMap( ACCOUNT_OBJECT_TYPE, null );
            }
            return accountRecordTypesMap;
        }
        set;
    }
    
    public static Map<String, Id> contactRecordTypesMap {
        get {
            if ( contactRecordTypesMap == null ) {
                contactRecordTypesMap = Utils.getRecordTypeIdsMap( CONTACT_OBJECT_TYPE, null );
            }
            return contactRecordTypesMap;
        }
        set;
    }
    
    public static Map<String, Id> loanApplicantRecordTypesMap {
        get {
            if ( loanApplicantRecordTypesMap == null ) {
                loanApplicantRecordTypesMap = Utils.getRecordTypeIdsMap( LOAN_APPLICANT_OBJECT_TYPE, null );
            }
            return loanApplicantRecordTypesMap;
        }
        set;
    }

    /**
    * A Lazy Getter and Setter method for the variable consumerLeadsRecordTypeId
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 28-June-2022
    * @return Id
    */
   public static Id brokerageAccountRecordTypeId {
        get {
            if ( brokerageAccountRecordTypeId == null )
                brokerageAccountRecordTypeId = accountRecordTypesMap.get( BROKERAGE_ACCOUNT_RECORD_TYPE_NAME );
            return brokerageAccountRecordTypeId;
         }
        set;
    }
    
    public static Id personAccountRecordTypeId {
        get {
            if ( personAccountRecordTypeId == null )
                personAccountRecordTypeId = accountRecordTypesMap.get( PERSON_ACCOUNT_RECORD_TYPE_NAME );
            return personAccountRecordTypeId;
         }
        set; 
    }
    
    public static Id brokerContactRecordTypeId { 
        get {
            if ( brokerContactRecordTypeId == null )
                brokerContactRecordTypeId = contactRecordTypesMap.get( BROKER_CONTACT_RECORD_TYPE_NAME );
            return brokerContactRecordTypeId;
         }
        set; 
    }
    
    public static Id regularLoanApplicantRecordTypeId { 
        get {
            if ( regularLoanApplicantRecordTypeId == null )
                regularLoanApplicantRecordTypeId = loanApplicantRecordTypesMap.get( REGULAR_LOAN_APPLICANT_RECORD_TYPE_NAME );
            return regularLoanApplicantRecordTypeId;
         }
        set; 
    }
    
    public static Id corporateLoanApplicantRecordTypeId { 
        get {
            if ( corporateLoanApplicantRecordTypeId == null )
                corporateLoanApplicantRecordTypeId = loanApplicantRecordTypesMap.get( CORPORATE_LOAN_APPLICANT_RECORD_TYPE_NAME );
            return corporateLoanApplicantRecordTypeId;
         }
        set; 
    }

    public static Map<String,Apex_Static_Components__c> apexStaticComponentsMap{
        get{
            if ( apexStaticComponentsMap == null ){
                apexStaticComponentsMap = new Map<String,Apex_Static_Components__c>();
                for ( Apex_static_components__c apexStaticComponent : Apex_static_components__c.getAll().values() ) {
                    apexStaticComponentsMap.put(apexStaticComponent.Name, apexStaticComponent);
                }
            }
            return apexStaticComponentsMap;
        }
        set; 
    }

    /**
    * A function to retrieve the record type Id of recordtype passed as variable
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 28-June-2022
    * @param objectName [The Name of the Object for which the record types should be returned]
    * @param recordTypeIdName [ Record Type name for which the Id should be returned]
    * @return Id [ A Id of the recordtype mentoioned ]
    */
    public static Id getRecordTypeId( String objectName, String recordTypeIdName ) { 
        List<String> recordTypeIdNames = new List<String>{ recordTypeIdName };
        List<Id> recordTypeIds = new List<Id>();
        Map<String, Id> recordTypeMap = getRecordTypeIdsMap( objectName, recordTypeIdNames );
        if ( recordTypeMap == null ) {
          return null;
        }
        recordTypeIds.addAll( recordTypeMap.values() );
        return recordTypeIds != null ? recordTypeIds[0] : null;
    }

    /**
    * A function to retrieve the record type Id of specified list of recordtypes or return all recordTypes of the given object, if the list is null
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 28-June-2022
    * @param objectName [The Name of the Object for which the record types should be returned]
    * @param recordTypeIdNames [ List of Record Type names for which the Id's should be returned]
    * @return recordTypesMap [ A Map<String, Id> which contains the RecordType Name and Id ]
    */
    public static  Map<String, Id> getRecordTypeIdsMap(  String objectName, List<String> recordTypeIdNames ) {
        Map<String, Id> recordTypesMap = new Map<String, Id>();
        List<Schema.RecordTypeInfo> recordTypeInformations;
        try {
            recordTypeInformations = Schema.getGlobalDescribe().get( objectName ).getDescribe().getRecordTypeInfos();
        } catch ( exception e) {
            //only executed when there is a exception
            System.debug( 'Error running custom code for ' + objectName + ': ' + e.getMessage());
            return null;
        }
        //Check if the list of Record Type Names is null or not
        if ( recordTypeIdNames == null ) {
            for ( Schema.RecordTypeInfo recordTypeInformation : recordTypeInformations ) {
        //Add all the Record types of the given object to the Map
                recordTypesMap.put( recordTypeInformation.getDeveloperName(), recordTypeInformation.getRecordTypeId() );
            }
        } else {
            Set<String> recordTypeIdNamesSet = new Set<String>( recordTypeIdNames );
            for ( Schema.RecordTypeInfo recordTypeInformation : recordTypeInformations ) {
                if ( recordTypeIdNamesSet.contains( recordTypeInformation.getDeveloperName() ) ) {
          //Add only the Record types in the list of the given object to the Map
                    recordTypesMap.put( recordTypeInformation.getDeveloperName(), recordTypeInformation.getRecordTypeId() );
                }
            }
        }
        return recordTypesMap != null ? recordTypesMap : null;
    }

    public static Residential_Loan_App_Trigger_Switch__c rlaTriggerSwitch {
        get {
            if ( rlaTriggerSwitch == null ) {
                rlaTriggerSwitch = Residential_Loan_App_Trigger_Switch__c.getValues( UserInfo.getUserId() );
            } 

            if ( rlaTriggerSwitch == null ) {
                rlaTriggerSwitch = Residential_Loan_App_Trigger_Switch__c.getValues( UserInfo.getProfileId() );
            }

            if ( rlaTriggerSwitch == null ) {
                rlaTriggerSwitch = Residential_Loan_App_Trigger_Switch__c.getOrgDefaults();
            }
            
            return rlaTriggerSwitch;
        }
        set;
    }
    
    public static Contact_Trigger_Switch__c contactTriggerSwitch {
        get {
            if ( contactTriggerSwitch == null ) {
                contactTriggerSwitch = Contact_Trigger_Switch__c.getValues( UserInfo.getUserId() );
            } 

            if ( contactTriggerSwitch == null ) {
                contactTriggerSwitch = Contact_Trigger_Switch__c.getValues( UserInfo.getProfileId() );
            }

            if ( contactTriggerSwitch == null ) {
                contactTriggerSwitch = Contact_Trigger_Switch__c.getOrgDefaults();
            }
            
            return contactTriggerSwitch;
        }
        set;
    }
    
    //validation rule switches
    public static Residential_Loan_Validation_Rules__c residentialLoanAppValidationRule {
        get {
            if ( residentialLoanAppValidationRule == null ) {
                residentialLoanAppValidationRule = Residential_Loan_Validation_Rules__c.getValues( UserInfo.getUserId() );
            } 

            if ( residentialLoanAppValidationRule == null ) {
                residentialLoanAppValidationRule = Residential_Loan_Validation_Rules__c.getValues( UserInfo.getProfileId() );
            }

            if ( residentialLoanAppValidationRule == null ) {
                residentialLoanAppValidationRule = Residential_Loan_Validation_Rules__c.getOrgDefaults();
            }
            
            return residentialLoanAppValidationRule;
        }
        set;
    } 
    
    public static Loan_Applicant_Trigger_Switch__c loanApplicantTriggerSwitch {
        get {
            if ( loanApplicantTriggerSwitch == null ) {
                loanApplicantTriggerSwitch = Loan_Applicant_Trigger_Switch__c.getValues( UserInfo.getUserId() );
            } 

            if ( loanApplicantTriggerSwitch == null ) {
                loanApplicantTriggerSwitch = Loan_Applicant_Trigger_Switch__c.getValues( UserInfo.getProfileId() );
            }

            if ( loanApplicantTriggerSwitch == null ) {
                loanApplicantTriggerSwitch = Loan_Applicant_Trigger_Switch__c.getOrgDefaults();
            }
            
            return loanApplicantTriggerSwitch;
        }
        set;
    }
    
    
    //validation rule switches
    public static Loan_Applicant_Validation_Rules__c loanApplicantValidationRule {
        get {
            if ( loanApplicantValidationRule == null ) {
                loanApplicantValidationRule = Loan_Applicant_Validation_Rules__c.getValues( UserInfo.getUserId() );
            } 

            if ( loanApplicantValidationRule == null ) {
                loanApplicantValidationRule = Loan_Applicant_Validation_Rules__c.getValues( UserInfo.getProfileId() );
            }

            if ( loanApplicantValidationRule == null ) {
                loanApplicantValidationRule = Loan_Applicant_Validation_Rules__c.getOrgDefaults();
            }
            
            return loanApplicantValidationRule;
        }
        set;
    } 
    
    public static Opportunity_Trigger_Switch__c opportunityTriggerSwitch {
        get {
            if ( opportunityTriggerSwitch == null ) {
                opportunityTriggerSwitch = Opportunity_Trigger_Switch__c.getValues( UserInfo.getUserId() );
            } 

            if ( opportunityTriggerSwitch == null ) {
                opportunityTriggerSwitch = Opportunity_Trigger_Switch__c.getValues( UserInfo.getProfileId() );
            }

            if ( opportunityTriggerSwitch == null ) {
                opportunityTriggerSwitch = Opportunity_Trigger_Switch__c.getOrgDefaults();
            }
            
            return opportunityTriggerSwitch;
        }
        set;
    }

    public static Fee_Trigger_Switch__c feeTriggerSwitch {
        get {
            if ( feeTriggerSwitch == null ) {
                feeTriggerSwitch = Fee_Trigger_Switch__c.getValues( UserInfo.getUserId() );
            } 

            if ( feeTriggerSwitch == null ) {
                feeTriggerSwitch = Fee_Trigger_Switch__c.getValues( UserInfo.getProfileId() );
            }

            if ( feeTriggerSwitch == null ) {
                feeTriggerSwitch = Fee_Trigger_Switch__c.getOrgDefaults();
            }
            
            return feeTriggerSwitch;
        }
        set;
    }
    
     public static Loan_Applicant_Property_Trigger_Switch__c loanApplicantPropertyTriggerSwitch {
        get {
            if ( loanApplicantPropertyTriggerSwitch == null ) {
                loanApplicantPropertyTriggerSwitch = Loan_Applicant_Property_Trigger_Switch__c.getValues( UserInfo.getUserId() );
            } 

            if ( loanApplicantPropertyTriggerSwitch == null ) {
                loanApplicantPropertyTriggerSwitch = Loan_Applicant_Property_Trigger_Switch__c.getValues( UserInfo.getProfileId() );
            }

            if ( loanApplicantPropertyTriggerSwitch == null ) {
                loanApplicantPropertyTriggerSwitch = Loan_Applicant_Property_Trigger_Switch__c.getOrgDefaults();
            }
            
            return loanApplicantPropertyTriggerSwitch;
        }
        set;
    }
    
    public static Loan_Application_Liability_Switch__c loanApplicantionLiabilityTriggerSwitch {
        get {
            if ( loanApplicantionLiabilityTriggerSwitch == null ) {
                loanApplicantionLiabilityTriggerSwitch = Loan_Application_Liability_Switch__c.getValues( UserInfo.getUserId() );
            } 

            if ( loanApplicantionLiabilityTriggerSwitch == null ) {
                loanApplicantionLiabilityTriggerSwitch = Loan_Application_Liability_Switch__c.getValues( UserInfo.getProfileId() );
            }

            if ( loanApplicantionLiabilityTriggerSwitch == null ) {
                loanApplicantionLiabilityTriggerSwitch = Loan_Application_Liability_Switch__c.getOrgDefaults();
            }
            
            return loanApplicantionLiabilityTriggerSwitch;
        }
        set;
    }
    
    //validation rule switches
    public static Loan_App_Property_Validation_Rules__c LoanApplicationPropertyValidationRule {
        get {
            if ( LoanApplicationPropertyValidationRule == null ) {
                LoanApplicationPropertyValidationRule = Loan_App_Property_Validation_Rules__c.getValues( UserInfo.getUserId() );
            } 

            if ( LoanApplicationPropertyValidationRule == null ) {
                LoanApplicationPropertyValidationRule = Loan_App_Property_Validation_Rules__c.getValues( UserInfo.getProfileId() );
            }

            if ( LoanApplicationPropertyValidationRule == null ) {
                LoanApplicationPropertyValidationRule = Loan_App_Property_Validation_Rules__c.getOrgDefaults();
            }
            
            return LoanApplicationPropertyValidationRule;
        }
        set;
    } 
    
    public static Valuation_Trigger_Switch__c ValuationTriggerSwitch {
        get {
            if ( ValuationTriggerSwitch == null ) {
                ValuationTriggerSwitch = Valuation_Trigger_Switch__c.getValues( UserInfo.getUserId() );
            } 

            if ( ValuationTriggerSwitch == null ) {
                ValuationTriggerSwitch = Valuation_Trigger_Switch__c.getValues( UserInfo.getProfileId() );
            }

            if ( ValuationTriggerSwitch == null ) {
                ValuationTriggerSwitch = Valuation_Trigger_Switch__c.getOrgDefaults();
            }
            
            return ValuationTriggerSwitch;
        }
        set;
    }

    public static Webinar_Attendee_Trigger_Switch__c webinarAttendeeTriggerSwitch {
        get {
            if ( webinarAttendeeTriggerSwitch == null ) {
                webinarAttendeeTriggerSwitch = Webinar_Attendee_Trigger_Switch__c.getValues( UserInfo.getUserId() );
            } 

            if ( webinarAttendeeTriggerSwitch == null ) {
                webinarAttendeeTriggerSwitch = Webinar_Attendee_Trigger_Switch__c.getValues( UserInfo.getProfileId() );
            }

            if ( webinarAttendeeTriggerSwitch == null ) {
                webinarAttendeeTriggerSwitch = Webinar_Attendee_Trigger_Switch__c.getOrgDefaults();
            }
            
            return webinarAttendeeTriggerSwitch;
        }
        set;
    }

    public static Webinar_Trigger_Switch__c webinarTriggerSwitch {
        get {
            if ( webinarTriggerSwitch == null ) {
                webinarTriggerSwitch = Webinar_Trigger_Switch__c.getValues( UserInfo.getUserId() );
            } 

            if ( webinarTriggerSwitch == null ) {
                webinarTriggerSwitch = Webinar_Trigger_Switch__c.getValues( UserInfo.getProfileId() );
            }

            if ( webinarTriggerSwitch == null ) {
                webinarTriggerSwitch = Webinar_Trigger_Switch__c.getOrgDefaults();
            }
            
            return webinarTriggerSwitch;
        }
        set;
    }
    
    //Loan Applicant Corporate Borrower Recordtypeidset
    public static Map<String, Id> loanApplicantsRecordTypesMap {
        get {
            if ( loanApplicantsRecordTypesMap == null ) {
                loanApplicantsRecordTypesMap = Utils.getRecordTypeIdsMap( LOAN_APPLICANT_OBJECT_TYPE, null );
            }
            return loanApplicantsRecordTypesMap;
        }
        set;
    }
    
    public static Id corporateBorrowerLoanApplicantRecordTypeId {
        get {
            if ( corporateBorrowerLoanApplicantRecordTypeId == null )
                corporateBorrowerLoanApplicantRecordTypeId = loanApplicantsRecordTypesMap.get( CORPORATE_BORROWER_LOAN_APPLICANT_RECORD_TYPE );
            return corporateBorrowerLoanApplicantRecordTypeId;
            }
        set;
    }

    public static Boolean validateSinNumber(String sinNumber ){
        Integer iChecksum = 0;
        Integer iDigit = 0;
        if ( sinNumber == null || sinNumber.length() == 0 ) {
            return false;
        }
        for (Integer i = 0; i < sinNumber.length(); i++){
            if ((Math.Mod((i+1),2)) == 0){
                iDigit = Integer.Valueof(sinNumber.Substring(i, i+1))*2;
                iChecksum += (iDigit < 10) ? iDigit : iDigit - 9;
            } else {
                iChecksum += Integer.Valueof(sinNumber.Substring(i, i+1));
            }
        }

        if(Math.Mod(iChecksum,10) == 0){
            return true;
        } else {
            return false;
        }
    }

    public static String identifySinNumberIssuedProvince(String sinNumber ){
        if ( sinNumber == null || sinNumber.length() == 0 ) {
            return null;
        }
        
        String sinFirstNumber = sinNumber.Substring(0,1);
        if(sinFirstNumber == '1'){
            return sinFirstNumber + ' - NB, NF, NS, PE';
        } else if( sinFirstNumber == '2' || sinFirstNumber == '3' ){
            return sinFirstNumber + ' - QC';
        } else if( sinFirstNumber == '4' || sinFirstNumber == '5' ){
            return sinFirstNumber + ' - ON';
        } else if( sinFirstNumber == '6' ){
            return sinFirstNumber + ' - AB, MB, SK, NT, NU';
        } else if( sinFirstNumber == '7' ){
            return sinFirstNumber + ' - BC, YU';
        } else if( sinFirstNumber == '9' ){
            return sinFirstNumber + ' - Immigrant/Temporary Sin';
        } else if( sinFirstNumber == '0' ){
            return sinFirstNumber + ' - 0 Sin';
        } else {
            return 'Not Used';
        }
    }
}
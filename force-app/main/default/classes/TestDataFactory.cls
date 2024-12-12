@isTest
public class TestDataFactory {
    @testVisible private static final String residentialLoanAppName = 'Test Neighbourhood';
    @testVisible private static final String NAME = 'Neighbourhood Holdings';
    @testVisible private static final String REGULAR_LOAN_APPLICANT = 'Regular Loan Applicant';
    @testVisible private static final String CORPORATE_LOAN_APPLICANT = 'Corporate Loan Applicant';
    @testVisible private static final String REGULAR_LOAN_APPLICANT_ADDRESS = 'Regular Loan Applicant Address';
    @testVisible private static final String REGULAR_LOAN_APPLICATION_LIABILITY = 'Regular Loan Application Liability';
    @testVisible private static final String REGULAR_LOAN_APPLICATION_PROPERTY = 'Regular Loan Applicantion Property';
    @testVisible private static final String LOAN_APPLICATION_ASSET = 'Test loan application Asset';
    @testVisible private static final String LOAN_APPLICANT_EMPLOYMENT = 'Test loan applicant Employment';
    @testVisible private static final String LOAN_APPLICANT_INCOME = 'Test loan applicant Income';
    @testVisible private static final String DOWN_PAYMENT = 'Test down payment';
    @testVisible private static final String TEST_EMAIL = 'test@Neighbourhood.com';
    @testVisible private static final String PRIMARY_RESIDENCE = 'Primary Residence';
    @testVisible private static final String TO_BE_RENTED = 'To be Rented';
    //@testVisible private static final List<Apex_static_components__c> apexStaticComponents = createConstant(true);
    
    public static Account createBrokerageAccount( Boolean doInsert ) {
        return createBrokerageAccounts( 1, doInsert )[0];
    }

    public static List<Account> createBrokerageAccounts( Integer howMany, Boolean doInsert ) {
        Id brokerageAccRecTypeId = Utils.brokerageAccountRecordTypeId;
        List<Account> accounts = new List<Account>();

        for ( Integer i = 0; i < howMany; i++ ) { 
            accounts.add( new Account(
                            RecordTypeId = brokerageAccRecTypeId,
                            BillingStreet = '123 Street',
                            BillingCity = 'Toronto',
                            BillingState = 'ON',
                            BillingPostalCode = 'T3N 0X1',
                            BillingCountry = 'Canada',
                            Name = TestDataFactory.NAME)
                        );
        }

        if ( doInsert ) insert accounts;
        return accounts;
    }

    public static Account createPersonAccount( Boolean doInsert ) {
        return createPersonAccounts( 1, doInsert )[0];
    }

    public static List<Account> createPersonAccounts( Integer howMany, Boolean doInsert ) {
        Id personAccRecTypeId = Utils.personAccountRecordTypeId;
        List<Account> accounts = new List<Account>();

        for ( Integer i = 0; i < howMany; i++ ) { 
            accounts.add( new Account(
                            RecordTypeId = personAccRecTypeId,
                            FirstName = TestDataFactory.NAME + i,
                            LastName = TestDataFactory.NAME + i,
                            PersonEmail = 'Test'+i+'@Neighbourhood.com')
                        );
        }

        if ( doInsert ) insert accounts;
        return accounts;
    }

    public static Contact createBrokerContact( Id brokerageAccountId, Boolean doInsert ) {
        return createBrokerContacts( brokerageAccountId, 1, doInsert )[0];
    }

    public static List<Contact> createBrokerContacts( Id brokerageAccountId, Integer howMany, Boolean doInsert ) {
        Id brokerContactRecordTypeId = Utils.brokerContactRecordTypeId;
        List<Contact> contacts = new List<Contact>();

        for ( Integer i = 0; i < howMany; i++ ) { 
            contacts.add( new Contact(
                            RecordTypeId = brokerContactRecordTypeId,
                            FirstName = TestDataFactory.NAME + i,
                            LastName = TestDataFactory.NAME + i,
                            AccountId = brokerageAccountId,
                            Email = 'Test'+i+'@Neighbourhood.com')
                        );
        }

        if ( doInsert ) insert contacts;
        return contacts;
    }
    
    public static ResidentialLoanApplication createResidentialLoanApplication( Id personAccountId, Id brokerageAccountId, Boolean doInsert ) {
        return createResidentialLoanApplications( personAccountId, brokerageAccountId, 1, doInsert )[0];
    }

    public static List<ResidentialLoanApplication> createResidentialLoanApplications( Id personAccountId, Integer howMany, Boolean doInsert ) {
        return createResidentialLoanApplications( personAccountId, null, 1, doInsert );
    }
    public static List<ResidentialLoanApplication> createResidentialLoanApplications( Id personAccountId, Id brokerageAccountId, Integer howMany, Boolean doInsert ) {
        List<ResidentialLoanApplication> residentialLoanApps = new List<ResidentialLoanApplication>();

        for ( Integer i = 0; i < howMany; i++ ) {
            residentialLoanApps.add( new ResidentialLoanApplication(
                            Name = residentialLoanAppName + i,
                            Application_Type__c = ApexConstants.APPROVAL_APPLICATION_TYPE,
                            AccountId = personAccountId,
                            Brokerage__c = brokerageAccountId,
                            EstateHoldType = ApexConstants.SECOND_LENDERS_LIEN_TYPE,
                            Payment_Frequency__c = ApexConstants.WEEKLY_PAYMENT_FREQUENCY,
                            Compounding_Frequency__c = ApexConstants.SEMI_ANNUALY_COMPOUND_FREQUENCY,
                            Loan_Amount__c = 20000,
                            Property_Value__c = 10000,
                            Lendesk_Creation_Date__c = System.Today(),
                            Status = ApexConstants.UNPROCESSED_RESEDENTIAL_LOAN_APP_APPLICATION_STATUS)
                        );
        }

        if ( doInsert ) insert residentialLoanApps;
        return residentialLoanApps;
    }
    
    public static List<LoanApplicant> createRegularLoanApplicant( Id loanAppId, Integer howMany, Boolean doInsert ) {
        List<LoanApplicant> LoanApplicants = new List<LoanApplicant>();

        for ( Integer i = 0; i < howMany; i++ ) {
            LoanApplicants.add( new LoanApplicant(
                            Name = REGULAR_LOAN_APPLICANT + i,
                            Last_Name__c = REGULAR_LOAN_APPLICANT + i,
                            LoanApplicationId = loanAppId,
                            RecordTypeId = Utils.regularLoanApplicantRecordTypeId,
                            Applicant_Type__c = ApexConstants.PRIMARY_APPLICANT_TYPE)
                        );
        }

        if ( doInsert ) insert LoanApplicants;
        return LoanApplicants;
    }
    
    public static List<LoanApplicant> createCorporateLoanApplicant( Id loanAppId, Integer howMany, Boolean doInsert ) {
        List<LoanApplicant> LoanApplicants = new List<LoanApplicant>();

        for ( Integer i = 0; i < howMany; i++ ) {
            LoanApplicants.add( new LoanApplicant(
                            Name = CORPORATE_LOAN_APPLICANT + i,
                            Last_Name__c = CORPORATE_LOAN_APPLICANT + i,
                            LoanApplicationId = loanAppId,
                            RecordTypeId = Utils.corporateLoanApplicantRecordTypeId,
                            Applicant_Type__c = ApexConstants.PRIMARY_APPLICANT_TYPE)
                        );
        }

        if ( doInsert ) insert LoanApplicants;
        return LoanApplicants;
    }
    
    public static List<LoanApplicationProperty> createRegularLoanApplicationProperty( Id loanAppId, Integer howMany, Boolean doInsert ) {
        List<LoanApplicationProperty> LoanApplicationProperties = new List<LoanApplicationProperty>();

        for ( Integer i = 0; i < howMany; i++ ) {
            LoanApplicationProperty LoanApplicationProperty = createRegularLoanApplicationProperty(loanAppId, false);
            LoanApplicationProperty.Name = REGULAR_LOAN_APPLICATION_PROPERTY + i;
            LoanApplicationProperties.add( LoanApplicationProperty );
        }

        if ( doInsert ) insert LoanApplicationProperties;
        return LoanApplicationProperties;
    }

    public static LoanApplicationProperty createRegularLoanApplicationProperty( Id loanAppId, Boolean doInsert ) {
       LoanApplicationProperty LoanApplicationProperty = new LoanApplicationProperty(
                                                            Name = REGULAR_LOAN_APPLICATION_PROPERTY,
                                                            LoanApplicationId = loanAppId,
                                                            Property_Type__c = ApexConstants.SUBJECT_PROPERTY_TYPE,
                                                            PropertyStreet = '123 Street',
                                                            PropertyCity = 'Toronto',
                                                            PropertyState = 'ON',
                                                            PropertyPostalCode = 'T3N 0X1',
                                                            PropertyCountry = 'Canada',
                                                            Title_Type__c = 'Freehold',
                                                            Loan_Purpose__c = ApexConstants.PURCHASE_LOAN_PURPOSE,
                                                            Collateral_Position__c = '1',
                                                            Dwelling_Type__c = 'Single Detached House',
                                                            PropertyUseType = 'Primary Residence',
                                                            Property_value__c = 10000,
                                                            Purchase_Price__c = 100);

        if ( doInsert ) insert LoanApplicationProperty;
        return LoanApplicationProperty;
    }

    public static LoanApplicantAddress createLoanApplicantAddress( Id loanApplicantId, Boolean doInsert ) {

        LoanApplicantAddress LoanApplicantAddress = new LoanApplicantAddress(
            Name = REGULAR_LOAN_APPLICANT_ADDRESS,
            ResidenceStreet = '123 Street',
            ResidenceCity = 'Toronto',
            ResidenceState = 'ON',
            ResidencePostalCode = 'T3N 0X1',
            ResidenceCountry = 'Canada',
            LoanApplicantId = loanApplicantId);

        if ( doInsert ) insert LoanApplicantAddress;
        return LoanApplicantAddress;
    }

    public static List<LoanApplicationLiability> createLoanApplicantionLiability( Id LoanAppId, Id LoanAppPropertyId, Integer howMany, Boolean doInsert ) {
        List<LoanApplicationLiability> liabilityToBeInserted = new List<LoanApplicationLiability>();
        for ( Integer i = 0; i < howMany; i++ ) {
            LoanApplicationLiability liability = new LoanApplicationLiability();
            liability.Name = REGULAR_LOAN_APPLICATION_LIABILITY + i;
            liability.Liability_Type__c = ApexConstants.MORTGAGE_LIABILITY_TYPE;
            liability.Payoff__c = ApexConstants.NO_PAYOFF;
            liability.LoanApplicationId = LoanAppId;
            liability.Loan_Application_Property__c = LoanAppPropertyId;
            liability.Balance__c = 5000;
            liability.Liability_Status__c = ApexConstants.NEW_LIABILITY_STATUS;
            liability.Position__c = '1';
            liabilityToBeInserted.add(liability);
        }
        if(doInsert && !liabilityToBeInserted.isEmpty()){
            insert liabilityToBeInserted;
        }
        return liabilityToBeInserted;
    }

    public static List<Valuation__c> createAppraisedValueValuation( Id LoanAppPropertyId, Integer howMany, Boolean doInsert ) {
        List<Valuation__c> valuations = new List<Valuation__c>();

        for ( Integer i = 0; i < howMany; i++ ) {
            valuations.add( new Valuation__c(
                            Valuation_Date__c = Date.Today(),
                            Valuation_Amount__c = 10000,
                            Valuation_Source__c = ApexConstants.APPRAISED_VALUE_SOURCE,
                            Loan_Application_Property__c = LoanAppPropertyId )
                        );
        }

        if ( doInsert ) insert valuations;
        return valuations;
    }

    public static List<Valuation__c> createPurchaseValueValuation( Id LoanAppPropertyId, Integer howMany, Boolean doInsert ) {
        List<Valuation__c> valuations = new List<Valuation__c>();

        for ( Integer i = 0; i < howMany; i++ ) {
            valuations.add( new Valuation__c(
                            Valuation_Date__c = Date.Today(),
                            Valuation_Amount__c = 10000,
                            Valuation_Source__c = 'Purchase Price',
                            Loan_Application_Property__c = LoanAppPropertyId )
                        );
        }

        if ( doInsert ) insert valuations;
        return valuations;
    }
    
    public static List<Valuation__c> createNonAppraisedValueValuation( Id LoanAppPropertyId, Integer howMany, Boolean doInsert ) {
        List<Valuation__c> valuations = new List<Valuation__c>();

        for ( Integer i = 0; i < howMany; i++ ) {
            valuations.add( new Valuation__c(
                            Valuation_Date__c = Date.Today(),
                            Valuation_Amount__c = 10000,
                            Valuation_Source__c = ApexConstants.ASSESSMENT_VALUATION_SOURCE,
                            Loan_Application_Property__c = LoanAppPropertyId )
                        );
        }

        if ( doInsert ) insert valuations;
        return valuations;
    }
    
    public static List<LoanApplicationAsset> createLoanApplicationAssets( Id LoanApplicationId, Integer howMany, Boolean doInsert ) {
        List<LoanApplicationAsset> assets = new List<LoanApplicationAsset>();

        for ( Integer i = 0; i < howMany; i++ ) {
            assets.add( new LoanApplicationAsset(
                            Name = LOAN_APPLICATION_ASSET + i,
                            LoanApplicationId = LoanApplicationId,
                            CashOrMarketValue = 10000 )
                        );
        }

        if ( doInsert ) insert assets;
        return assets;
    }
    
    public static List<LoanApplicantEmployment> createLoanApplicantEmployments( Id LoanApplicationId, Id LoanApplicantId, Integer howMany, Boolean doInsert ) {
        List<LoanApplicantEmployment> employments = new List<LoanApplicantEmployment>();

        for ( Integer i = 0; i < howMany; i++ ) {
            employments.add( new LoanApplicantEmployment(
                            Name = LOAN_APPLICANT_EMPLOYMENT + i,
                            LoanApplicationId = LoanApplicationId,
                            LoanApplicantId = LoanApplicantId,
                            Income__c = 100)
                        );
        }

        if ( doInsert ) insert employments;
        return employments;
    }
    
    public static List<LoanApplicantIncome> createLoanApplicantIncome( Id LoanApplicationId, Id LoanApplicantId, Integer howMany, Boolean doInsert ) {
        List<LoanApplicantIncome> incomes = new List<LoanApplicantIncome>();

        for ( Integer i = 0; i < howMany; i++ ) {
            incomes.add( new LoanApplicantIncome(
                            Name = LOAN_APPLICANT_INCOME + i,
                            LoanApplicationId = LoanApplicationId,
                            LoanApplicantId = LoanApplicantId,
                            Annual_Income__c = 200)
                        );
        }

        if ( doInsert ) insert incomes;
        return incomes;
    }

    public static List<Property_Owner__c> createLoanApplicantOwnedProperties( Id LoanApplicantId, Id LoanApplicationPropertyId, Integer howMany, Boolean doInsert ) {
        List<Property_Owner__c> properties = new List<Property_Owner__c>();

        for ( Integer i = 0; i < howMany; i++ ) {
            properties.add( new Property_Owner__c(
                            Property__c = LoanApplicationPropertyId,
                            Loan_Applicant__c = LoanApplicantId)
                        );
        }

        if ( doInsert ) insert properties;
        return properties;
    }
    
    public static List<Downpayment__c> createDownpayment( Id LoanAppPropertyId, Integer howMany, Boolean doInsert ) {
        List<Downpayment__c> downPayments = new List<Downpayment__c>();

        for ( Integer i = 0; i < howMany; i++ ) {
            downPayments.add( new Downpayment__c(
                            Amount__c = 50,
                            Loan_Application_Property__c = LoanAppPropertyId)
                        );
        }

        if ( doInsert ) insert downPayments;
        return downPayments;
    }

    public static List<Rental_Income__c> CreatePrimaryResidenceRentalIncome( Id LoanAppPropertyId, Integer howMany, Boolean doInsert ) {
        List<Rental_Income__c> rentalIncomes = new List<Rental_Income__c>();

        for ( Integer i = 0; i < howMany; i++ ) {
            rentalIncomes.add( new Rental_Income__c(
                            Unit_Number__c = String.valueOf(i),
                            Property__c = LoanAppPropertyId,
                            Monthly_Rental_Income__c = 1000,
                            Occupancy_Type__c = PRIMARY_RESIDENCE)
                        );
        }

        if ( doInsert ) insert rentalIncomes;
        return rentalIncomes;
    }
    
    public static List<Rental_Income__c> createTobeRentedRentalIncome( Id LoanAppPropertyId, Integer howMany, Boolean doInsert ) {
        List<Rental_Income__c> rentalIncomes = new List<Rental_Income__c>();

        for ( Integer i = 0; i < howMany; i++ ) {
            rentalIncomes.add( new Rental_Income__c(
                            Unit_Number__c = String.valueOf(i),
                            Property__c = LoanAppPropertyId,
                            Monthly_Rental_Income__c = 1000,
                            Occupancy_Type__c = TO_BE_RENTED)
                        );
        }

        if ( doInsert ) insert rentalIncomes;
        return rentalIncomes;
    }


    public static List<Fee__c> createFees( Id LoanApplicationId, Integer howMany, Boolean doInsert ) {
        List<Fee__c> fees = new List<Fee__c>();

        for ( Integer i = 0; i < howMany; i++ ) {
            fees.add( new Fee__c(
                            Fee_Type__c = 'Wire Fee',
                            Residential_Loan_Application__c = LoanApplicationId,
                            Amount__c = 1000,
                            Fee_Percent__c = 2)
                        );
        }

        if ( doInsert ) insert fees;
        return fees;
    }
    
    public static List<Apex_static_components__c> createConstant(Boolean doInsert){
        List<Apex_static_components__c> constantvalues = new List<Apex_static_components__c>();
        constantvalues.add(new Apex_static_components__c(Name = 'Legal Fee',
                                                             Fee_Amount__c = 2000));
        constantvalues.add(new Apex_static_components__c(Name = 'Title Insurance',
                                                             Fee_Amount__c = 325));
        constantvalues.add(new Apex_static_components__c(Name = 'Wire Fee',
                                                             Fee_Amount__c = 35));
        constantvalues.add(new Apex_static_components__c(Name = 'Threshold % to check for Appraisal',
                                                             Value__c = '0.05'));
        constantvalues.add(new Apex_static_components__c(Name = 'Loan Applicant Add P.O. Box Validation',
                                                             Value__c = 'P.O Box'));
        constantvalues.add(new Apex_static_components__c(Name = 'Loan Applicant Gambling Flag',
                                                             Value__c = 'Bar'));
        if(doInsert) insert constantvalues;
        
        return constantvalues;
    }
}
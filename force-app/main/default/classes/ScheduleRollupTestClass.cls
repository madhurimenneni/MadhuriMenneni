@isTest
public class ScheduleRollupTestClass {
    
    @testSetup
    static void dataCreation()
    {
        //String advisorRTId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        //String dealerRTId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        /*
List<Account> listOfAccounts = new List<Account>();

Account dealer = new Account();
dealer.RecordTypeId = dealerRTId;
dealer.Name = 'Test Dealer';
listOfAccounts.add(dealer);

Account advisor = new Account();
advisor.RecordTypeId = advisorRTId;
advisor.LastName = 'Test Advisor';
listOfAccounts.add(advisor);

insert listOfAccounts;
*/
        // Advisor_Code__c advisorCode = new Advisor_Code__c();
        // advisorCode.External_ID__c = '-TestAdvisorCode';
        // advisorCode.Advisor__c = advisor.id;
        // insert advisorCode;
        
        /*
Product2 fund = new Product2 ();
fund.Name = 'Test Fund';
//  fund.Current_AUM__c = 100000;
insert fund;

Pricebook2 stdPriceBook = new Pricebook2();
stdPriceBook.Name = 'Standard Price Book';
stdPriceBook.IsActive = true;
insert stdPriceBook;
*/
        // Dealer_Code__c  dealerCode = new Dealer_Code__c ();
        // dealerCode.Total_AUM__c = 100000;
        // dealerCode.Dealer_Code__c = 'test dealer code';
        // dealerCode.Dealer__c = dealer.id;
        // insert dealerCode;
        
        // AUM_Snapshot__c aumSnap = new AUM_Snapshot__c ();
        // aumSnap.Advisor_Code__c = advisorCode.id;
        // aumSnap.Fund__c = fund.id;
        // aumSnap.Amount__c = 100000;
        // aumSnap.Dealer_Code__c = dealerCode.id;
        // insert aumSnap;
        
        List<Apex_static_components__c> constantsList = TestDataFactory.createConstant(true);
        Account acc = new Account();
        acc.name= 'Test Acc';
        
        Contact con = new Contact();
        con.LastName = 'Gary';
        con.AccountId = acc.Id;
        
        ResidentialLoanApplication rla = new ResidentialLoanApplication();
        rla.AccountId = acc.Id;
        rla.Name = 'Test RLA';
        
        FinServ__RollupByLookupConfig__c rollup = new FinServ__RollupByLookupConfig__c();
        rollup.FinServ__Active__c = true;
        rollup.FinServ__FromField__c = 'Id';
        rollup.FinServ__FromObject__c = 'ResidentialLoanApplication';
        rollup.FinServ__LookupField__c = 'Contact__c';
        rollup.FinServ__Namespace__c = 'Industries';
        rollup.FinServ__RollupOperation__c = 'Count';
        rollup.FinServ__ToField__c = 'In_Progress__c';
        rollup.FinServ__ToObject__c = 'Contact';
        rollup.Name = 'NumberOfActiveRLAsPerContact';
        
        insert rollup;
        
        
    }
    
    @isTest
    static void testRollups()
    {
        Test.startTest();
        String jobId = System.schedule('ScheduleRollup','0 0 0 15 3 ? 2100',new ScheduleRollup());
        Test.stopTest();
        System.assertNotEquals(null, jobId);
    }
    
}
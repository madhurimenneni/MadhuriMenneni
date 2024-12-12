@istest
public class ContactRFMSegmentationTypeUpdateTest {
    @TestSetup
    static void makeData(){
        List<Apex_static_components__c> constantsList = TestDataFactory.createConstant(true);
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId = Utils.brokerageAccountRecordTypeId;
        insert acc;

        Contact contact = new Contact();
        contact.LastName = 'test';
        contact.RecordTypeId = Utils.getRecordTypeId('Contact', 'IndustriesBusiness');
        contact.Province__c = 'BC';
        contact.Email = 'test@test.com';
        contact.Date_last_deal_submitted__c  = Date.today().addMonths(-1);
        contact.RFM_Completed_Deals_in_Calculated_Month__c = 12;
        contact.RFM_First_Application_Submitted_Date__c  = Date.today().addMonths(-10);
        contact.RFM_Total_Deals_in_Calculated_Month__c =10;
        contact.Complete_Funded_in_last_12_months__c = 10;
        contact.AccountId = acc.Id;
        contact.Submitted_Lifetime__c = 0;
        contact.In_Progress__c = 0;
        contact.Volume_Submitted_Lifetime__c = 0;
        contact.Volume_Funded__c = 0;
        contact.Funded__c = 0;
        contact.Of_Applications_In_12_Months__c = 0;
        contact.Volume_submitted_in_12_months__c = 0;
        contact.Volume_Funded_in_12_Months__c = 0;
        contact.Of_Applications_In_24_Months__c = 0;
        contact.Complete_in_last_24_months__c = 0;
        contact.cancelled__c = 0;
        contact.Declined_Lifetime__c = 0;
        contact.Submitted_This_Year__c = 0;
        contact.Submitted_Last_Year__c = 0;
        contact.Completed_This_Year__c = 0;
        contact.Completed_Last_Year__c = 0;
        insert contact;
    }

    @isTest
    private static void testContactRFMSegmentationTypeUpdateSchedulable() {
      Test.startTest();
        Datetime nextRunTimeDate = Datetime.now().addMonths( 1 );
        Time schTime = Time.newInstance( 06, 00, 0, 0 );
        Date schDate = Date.newInstance( nextRunTimeDate.year(), nextRunTimeDate.month(), nextRunTimeDate.day() ).toStartOfMonth();
        Datetime nextRunTime = Datetime.newInstance( schDate, schTime );
        System.schedule('RFM Segmentation Update', '0 0 6 1 * ?', new ContactRFMSegmentationTypeUpdateSch() );
      Test.stopTest();

        for ( CronTrigger ct :   [ SELECT 
                                        Id
                                        ,CronExpression 
                                        ,TimesTriggered 
                                        ,NextFireTime
                                        ,CronJobDetail.Name
                                  FROM 
                                        CronTrigger 
                                  WHERE 
                                       CronJobDetail.Name = 'RFM Segmentation Update'                              
                                  ] ) {
            if ( ct.CronJobDetail.Name == 'RFM Segmentation Update'  ) {
                // Verify the expressions are the same
                System.assertEquals( '0 0 6 1 * ?', 
                                     ct.CronExpression, 
                                    'Cron Expression of the trigger is not same as the Cron Expression Declared for ContactRFMSegmentationTypeUpdateSch class' );
                // Verify the job has not run
                System.assertEquals( 0, 
                                    ct.TimesTriggered, 
                                    'Cron Trigger has fired already' );
                //TO DO
                // Verify the next time the job will run
                System.assertEquals( String.valueOf( nextRunTime ), 
                                     String.valueOf( ct.NextFireTime ), 
                                     'The anticpated time to fire the Cron Trigger is not as expected/Specified' );
                                     
            }   
        } 
    }

    @istest
    private static void testContactRFMSegmentationTypeUpdateBatch() {
        test.startTest();
            Database.executeBatch( new ContactRFMSegmentationTypeUpdateBatch() );
        test.stopTest();
    }
}
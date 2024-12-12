@istest
private class WebinarHandlerTest {
    @istest
    public static void testForLatestWebinar(){
        Webinar__c webinar1 = new Webinar__c();
        webinar1.Name = 'Test Webinar 1';
        webinar1.Webinar_Host__c = UserInfo.getUserId();
        webinar1.Webinar_date__c = System.today();
        webinar1.Latest_Webinar__c = true;

        insert webinar1;

        Webinar__c webinar2 = new Webinar__c();
        webinar2.Name = 'Test Webinar 2';
        webinar2.Webinar_Host__c = UserInfo.getUserId();
        webinar2.Webinar_date__c = System.today();
        webinar2.Latest_Webinar__c = true;

        Boolean exceptionThrown = false;
        try {
            insert webinar2;
        } catch( Exception e ){
            exceptionThrown = true;
            Boolean expectedExceptionThrown =  (e.getMessage().contains('There is already a Webinar')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage());
        }

        Webinar__c webinar3 = new Webinar__c();
        webinar3.Name = 'Test Webinar 3';
        webinar3.Webinar_Host__c = UserInfo.getUserId();
        webinar3.Webinar_date__c = System.today();
        webinar3.Latest_Webinar__c = false;
        insert webinar3;

        webinar3.Latest_Webinar__c = true;
        try{
            update webinar3;
        } catch ( Exception e ) {
            exceptionThrown = true;
            Boolean expectedExceptionThrown =  (e.getMessage().contains('There is already a Webinar')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage());
        }
    }
    // Account acc = new Account();
    // acc.name= 'Test Acc';
    
    // Contact con = new Contact();
    // con.FirstName = 'Test';
    // con.LastName = 'Gary';
    // con.AccountId = acc.Id;
}
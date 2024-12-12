@istest
private class WebinarAttendeeHandlerTest {
    @istest
    public static void testForwebinarAttendees(){
        Webinar__c webinar1 = new Webinar__c();
        webinar1.Name = 'Test Webinar 1';
        webinar1.Latest_Webinar__c = true;
        webinar1.Webinar_Host__c = UserInfo.getUserId();
        webinar1.Webinar_date__c = System.today();
        insert webinar1;

        Account acc = new Account();
        acc.name= 'Test Acc';
        insert acc;
    
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Gary';
        con.Email = 'test@test.com';
        con.AccountId = acc.Id;
        insert con;

        Webinar_Attendee__c webinarAttendee = new Webinar_Attendee__c();
        webinarAttendee.Email__c = 'test@test.com';
		webinarAttendee.Webinar__c =  webinar1.Id ;    
        insert webinarAttendee; 
		webinarAttendee.Email__c = 'test2@test.com';
        
        Webinar_Attendee__c webinarAttendee1 = new Webinar_Attendee__c();
        webinarAttendee1.Webinar__c =  webinar1.Id ; 
        webinarAttendee1.Email__c = 'test@test.com';

		test.startTest();
        update webinarAttendee;
        insert webinarAttendee1;
        test.stopTest();
        
        Webinar_Attendee__c webinarAttendee2 = [SELECT Id, Email__c, Webinar_Attendee__c, Webinar__c, Webinar_Attendee__r.Last_Webinar_Attended__c FROM Webinar_Attendee__c WHERE Id =: webinarAttendee1.Id LIMIT 1];
        system.AssertEquals(webinar1.Id, webinarAttendee2.Webinar_Attendee__r.Last_Webinar_Attended__c);
    }
}
public class WebinarHandler {
    List<Webinar__c> newWebinars = new List<Webinar__c>();
    Map<Id, Webinar__c> oldWebinars = new Map<Id, Webinar__c>();
    public WebinarHandler(List<Webinar__c> newRecords, Map<Id, Webinar__c> oldRecordsMap) {
        this.newWebinars = newRecords;
        this.oldWebinars = oldRecordsMap;
    }

    public void checkForLatestWebinar(){
        List<Webinar__c> webinars = [SELECT Id, Name FROM Webinar__c WHERE Latest_Webinar__c = true ORDER BY LastModifiedDate DESC];
        for ( Webinar__c webinar : newWebinars ) {
            if( oldWebinars != null ) {
                Webinar__c oldWebinar = oldWebinars.get( webinar.Id );
                if( oldWebinar.Latest_Webinar__c != webinar.Latest_Webinar__c && webinar.Latest_Webinar__c ) {
                    if ( webinars.size() > 0 ) {
                        webinar.addError( 'There is already a Webinar, '+ webinars[0].Name +', checked as latest, please uncheck it first');
                    }
                }
            } else {
                if ( webinar.Latest_Webinar__c ) {
                    if ( webinars.size() > 0 ) {
                        webinar.addError( 'There is already a Webinar, '+ webinars[0].Name +', checked as latest, please uncheck it first');
                    }
                }
            }
        }
    }

    public void createEventForWebinar(){
        List<Event> eventsToInsert = new List<Event>();
        for ( Webinar__c webinar : newWebinars ) {
            if( oldWebinars == null ) {
                Event newEvent = new Event();
                newEvent.WhatId = webinar.Brokerage__c;
                newEvent.OwnerId = webinar.Webinar_Host__c;
                newEvent.Description = webinar.Description__c;
                newEvent.Type = 'Webinar';
                if( webinar.Webinar_date__c != null ) {
                    newEvent.StartDateTime = DateTime.newInstance( webinar.Webinar_date__c.year(), webinar.Webinar_date__c.month(), webinar.Webinar_date__c.day(),9,0,0 );
                    newEvent.EndDateTime = DateTime.newInstance( webinar.Webinar_date__c.year(), webinar.Webinar_date__c.month(), webinar.Webinar_date__c.day(),17,0,0 );
                }
                newEvent.Subject = webinar.Name;
                eventsToInsert.add(newEvent);
            } else {
                Webinar__c oldWebinar = oldWebinars.get( webinar.Id);
                if ( oldWebinar.Brokerage__c != webinar.Brokerage__c ) {
                    Event newEvent = new Event();
                    newEvent.WhatId = webinar.Brokerage__c;
                    newEvent.OwnerId = webinar.Webinar_Host__c;
                    newEvent.Description = webinar.Description__c;
                    newEvent.Type = 'Webinar';
                    if( webinar.Webinar_date__c != null ) {
                        newEvent.StartDateTime = DateTime.newInstance( webinar.Webinar_date__c.year(), webinar.Webinar_date__c.month(), webinar.Webinar_date__c.day(),9,0,0 );
                        newEvent.EndDateTime = DateTime.newInstance( webinar.Webinar_date__c.year(), webinar.Webinar_date__c.month(), webinar.Webinar_date__c.day(),17,0,0 );
                    }
                    newEvent.Subject = webinar.Name;
                    eventsToInsert.add(newEvent);
                }
            }
        }
        insert eventsToInsert;
    }
}
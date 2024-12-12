public class WebinarAttendeeHandler {
    List<Webinar_Attendee__c> newWebinarAttendees = new List<Webinar_Attendee__c>();
    Map<Id, Webinar_Attendee__c> oldWebinarAttendees = new Map<Id, Webinar_Attendee__c>();
    public WebinarAttendeeHandler(List<Webinar_Attendee__c> newRecords, Map<Id, Webinar_Attendee__c> oldRecordsMap) {
        this.newWebinarAttendees = newRecords;
        this.oldWebinarAttendees = oldRecordsMap;
    }

    public void populateWebinarAttendeeContacts(){
        Set<String> webinarAttendeeEmailsSet = new Set<String>();
        Set<Id> webinarIdSet = new Set<Id>();
        List<Contact> contactsToUpdate = new List<Contact>();
        Map<String, Contact> contactsMap = new Map<String, Contact>();
        List<Webinar_Attendee__c> qualifiedWebinarAttendees = new List<Webinar_Attendee__c>();

        for ( Webinar_Attendee__c webinarAttendee : newWebinarAttendees ) {
            if( oldWebinarAttendees != null ) {
                Webinar_Attendee__c oldWebinarAttendee = oldWebinarAttendees.get( webinarAttendee.Id );
                if( oldWebinarAttendee.Email__c != webinarAttendee.Email__c ) {
                    
                    if ( webinarAttendee.Email__c != null &&  webinarAttendee.Email__c != '' ) {
                        webinarAttendeeEmailsSet.add( WebinarAttendee.Email__c );
                        qualifiedWebinarAttendees.add( webinarAttendee );
                    } else {
                        webinarAttendee.Webinar_Attendee__c = null;
                    }
                }
            } else {
                if ( webinarAttendee.Email__c != null ) {
                    webinarIdSet.add( webinarAttendee.Webinar__c );
                    webinarAttendeeEmailsSet.add( WebinarAttendee.Email__c );
                    qualifiedWebinarAttendees.add( webinarAttendee );
                }
            }
        }

        Map<Id, Webinar__c> webinarsMap = new Map<Id, Webinar__c>([SELECT Id, Name, Webinar_date__c FROM Webinar__c WHERE Id IN: webinarIdSet ORDER BY LastModifiedDate DESC]);

        if ( !webinarAttendeeEmailsSet.isEmpty() ) {
            for ( Contact contact : [ SELECT Id, Email, FirstName, LastName, Last_Webinar_Attended__c FROM Contact WHERE Email IN: webinarAttendeeEmailsSet ] ) {
                if( contact.Email != null ) {
                    contactsMap.put( contact.Email, contact );
                }
            }
        }

        if ( !contactsMap.isEmpty() ) {
            for ( Webinar_Attendee__c webinarAttendee : qualifiedWebinarAttendees ) {
                if ( contactsMap.keySet().contains( webinarAttendee.Email__c ) ) {
                    Contact contact = contactsMap.get( webinarAttendee.Email__c );
                    webinarAttendee.Webinar_Attendee__c = contact.Id;
                    webinarAttendee.First_Name__c = contact.FirstName;
                    webinarAttendee.Last_Name__c = contact.LastName;
                    if ( webinarAttendee.Webinar__c != null ) {
                        Webinar__c webinar = webinarsMap.get( webinarAttendee.Webinar__c );
                        contact.Last_Webinar_Attended__c = webinar.Id;
                        contactsToUpdate.add( contact );
                    }
                }
            }
        }

        if ( contactsToUpdate.size() > 0 ) {
            Database.update( contactsToUpdate, false );
        }
    }
}
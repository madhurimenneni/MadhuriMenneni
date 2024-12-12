public with sharing class ContactsHelper {
    List<Contact> newContacts = new List<Contact>();
    Map<Id, Contact> oldContacts = new Map<Id, Contact>();
    
    public ContactsHelper( List<Contact> newRecords, Map<Id, Contact> oldRecordsMap ) {
        newContacts = newRecords;
        oldContacts = oldRecordsMap;
    }

    public ContactsHelper updateBrokerKpis() {
        Map<Id, List<Contact>> brokerContactsMap = new Map<Id, List<Contact>>();
        for(Contact newContact : newContacts ){
                if ( oldContacts != null ) {
                    Contact oldContact = oldContacts.get(newContact.Id);
                    if ( oldContact.In_Progress__c != newContact.In_Progress__c ||
                         oldContact.Volume_Submitted_Lifetime__c != newContact.Volume_Submitted_Lifetime__c||
                         oldContact.Volume_Funded__c != newContact.Volume_Funded__c||
                         oldContact.Submitted_Lifetime__c != newContact.Submitted_Lifetime__c||
                         oldContact.Funded__c != newContact.Funded__c||
                         oldContact.Of_Applications_In_12_Months__c != newContact.Of_Applications_In_12_Months__c||
                         oldContact.Volume_submitted_in_12_months__c != newContact.Volume_submitted_in_12_months__c||
                         oldContact.Complete_Funded_in_last_12_months__c != newContact.Complete_Funded_in_last_12_months__c||
                         oldContact.Volume_Funded_in_12_Months__c != newContact.Volume_Funded_in_12_Months__c||
                         oldContact.Of_Applications_In_24_Months__c != newContact.Of_Applications_In_24_Months__c||
                         oldContact.Complete_in_last_24_months__c != newContact.Complete_in_last_24_months__c||
                         oldContact.cancelled__c != newContact.cancelled__c||
                         oldContact.Declined_Lifetime__c != newContact.Declined_Lifetime__c ||
                         oldContact.Submitted_This_Year__c != newContact.Submitted_This_Year__c||
                         oldContact.Submitted_Last_Year__c != newContact.Submitted_Last_Year__c||
                         oldContact.Completed_This_Year__c != newContact.Completed_This_Year__c||
                         oldContact.Completed_Last_Year__c != newContact.Completed_Last_Year__c) {
                            brokerContactsMap.put( newContact.AccountId, new List<Contact>() );
                    }
                } else {
                    brokerContactsMap.put( newContact.AccountId, new List<Contact>() );
                }
        }
        if( !brokerContactsMap.keySet().isEmpty() ) {
            for( Contact contact : [SELECT 
                                            Id,
                                            AccountId,
                                            In_Progress__c,
                                            Volume_Submitted_Lifetime__c,
                                            Volume_Funded__c,
                                            Submitted_Lifetime__c,
                                            Funded__c,
                                            Of_Applications_In_12_Months__c,
                                            Volume_submitted_in_12_months__c,
                                            Complete_Funded_in_last_12_months__c,
                                            Volume_Funded_in_12_Months__c,
                                            Of_Applications_In_24_Months__c,
                                            Complete_in_last_24_months__c,
                                            cancelled__c,
                                            Declined_Lifetime__c,
                                            Date_last_deal_submitted__c,
                                            Submitted_This_Year__c,
                                            Submitted_Last_Year__c,
                                            Completed_This_Year__c,
                                            Completed_Last_Year__c
                                    FROM 
                                            Contact 
                                    WHERE 
                                            AccountId IN: brokerContactsMap.keySet() /*ORDER BY Lendesk_Creation_Date__c asc*/ ] ) {
                                            if( !brokerContactsMap.containsKey( contact.AccountId ) ) {
                                                brokerContactsMap.put( contact.AccountId, new List<Contact>() );
                                            }
                                            brokerContactsMap.get( contact.AccountId ).add( contact );
            }

            List<Account> accountsToUpdate = new List<Account>();
            for ( Id brokerageAccountId : brokerContactsMap.keySet() ) {
                Set<Date> contactApplicationcreatedinLendeskDates = new Set<Date>();
                Account brokerageAccount = new Account();
                brokerageAccount.Id = brokerageAccountId;
                brokerageAccount.In_Progress__c = 0;
                brokerageAccount.Volume_Submitted_Lifetime__c = 0;
                brokerageAccount.Volume_Funded_Lifetime__c = 0;
                brokerageAccount.Submitted_Lifetime__c = 0;
                brokerageAccount.Completed_Lifetime__c = 0;
                brokerageAccount.Submitted_in_12_Months__c = 0;
                brokerageAccount.Volume_submitted_in_12_months__c = 0;
                brokerageAccount.Funded_in_12_Months__c = 0;
                brokerageAccount.Volume_Funded_in_12_Months__c = 0;
                brokerageAccount.Submitted_in_24_Months__c = 0;
                brokerageAccount.Completed_in_24_Months__c = 0;
                brokerageAccount.Cancelled_Lifetime__c = 0;
                brokerageAccount.Declined_Lifetime__c = 0;
                brokerageAccount.Submitted_This_Year__c = 0;
                brokerageAccount.Submitted_Last_Year__c = 0;
                brokerageAccount.Completed_This_Year__c = 0;
                brokerageAccount.Completed_Last_Year__c = 0;
                
                for( Contact contact : brokerContactsMap.get( brokerageAccountId ) ) {
                    if( contact.Date_last_deal_submitted__c != null ) {
                         contactApplicationcreatedinLendeskDates.add(Date.valueOf( contact.Date_last_deal_submitted__c ));
                    }
                    brokerageAccount.Submitted_Lifetime__c += contact.Submitted_Lifetime__c;
                    brokerageAccount.In_Progress__c += contact.In_Progress__c;
                    brokerageAccount.Volume_Submitted_Lifetime__c += contact.Volume_Submitted_Lifetime__c;
                    brokerageAccount.Volume_Funded_Lifetime__c += contact.Volume_Funded__c;
                    brokerageAccount.Completed_Lifetime__c += contact.Funded__c;
                    brokerageAccount.Submitted_in_12_Months__c += contact.Of_Applications_In_12_Months__c;
                    brokerageAccount.Volume_submitted_in_12_months__c += contact.Volume_submitted_in_12_months__c;
                    brokerageAccount.Funded_in_12_Months__c += contact.Complete_Funded_in_last_12_months__c;
                    brokerageAccount.Volume_Funded_in_12_Months__c += contact.Volume_Funded_in_12_Months__c;
                    brokerageAccount.Submitted_in_24_Months__c += contact.Of_Applications_In_24_Months__c;
                    brokerageAccount.Completed_in_24_Months__c += contact.Complete_in_last_24_months__c;
                    brokerageAccount.Cancelled_Lifetime__c += contact.cancelled__c;
                    brokerageAccount.Declined_Lifetime__c += contact.Declined_Lifetime__c;
                    brokerageAccount.Submitted_This_Year__c += contact.Submitted_This_Year__c;
                    brokerageAccount.Submitted_Last_Year__c += contact.Submitted_Last_Year__c;
                    brokerageAccount.Completed_This_Year__c += contact.Completed_This_Year__c;
                    brokerageAccount.Completed_Last_Year__c += contact.Completed_Last_Year__c;
                }
            
                List<Date> contactApplicationcreatedinLendeskDatesList = new List<Date>(contactApplicationcreatedinLendeskDates);
                contactApplicationcreatedinLendeskDatesList.sort();
                if( contactApplicationcreatedinLendeskDatesList.size() > 0 ) {
                     if( contactApplicationcreatedinLendeskDatesList.size() > 1 ) {
                         brokerageAccount.Last_Deal_Submission_Date__c = contactApplicationcreatedinLendeskDatesList[contactApplicationcreatedinLendeskDatesList.size() - 1];
                     } else {
                         brokerageAccount.Last_Deal_Submission_Date__c = contactApplicationcreatedinLendeskDatesList[0];
                     }
                 }
                
                 if( brokerageAccount.Last_Deal_Submission_Date__c > System.today().addMonths( -12 ) ) {
                         brokerageAccount.RFM_Completed_Deals_in_Calculated_Month__c = brokerageAccount.Funded_in_12_Months__c;
                 } else {
                     brokerageAccount.RFM_Completed_Deals_in_Calculated_Month__c = brokerageAccount.Completed_Lifetime__c;
                 }
                    
                 if( brokerageAccount.Last_Deal_Submission_Date__c > System.today().addMonths( -12 ) ) {
                     brokerageAccount.RFM_Total_Deals_in_Calculated_Month__c = brokerageAccount.Submitted_in_12_Months__c;
                 } else {
                     brokerageAccount.RFM_Total_Deals_in_Calculated_Month__c = brokerageAccount.Submitted_Lifetime__c;
                 }
                accountsToUpdate.add( brokerageAccount );
            }
            if( !accountsToUpdate.isEmpty() ) {
                update accountsToUpdate;
            }
        }
        return this;
    }

    public void populateValuesOnFields(){
        for(Contact newContact : newContacts ){
            newContact.Submitted_Lifetime__c = 0;
            newContact.In_Progress__c = 0;
            newContact.Volume_Submitted_Lifetime__c = 0;
            newContact.Volume_Funded__c = 0;
            newContact.Funded__c = 0;
            newContact.Of_Applications_In_12_Months__c = 0;
            newContact.Volume_submitted_in_12_months__c = 0;
            newContact.Complete_Funded_in_last_12_months__c = 0;
            newContact.Volume_Funded_in_12_Months__c = 0;
            newContact.Of_Applications_In_24_Months__c = 0;
            newContact.Complete_in_last_24_months__c = 0;
            newContact.cancelled__c = 0;
            newContact.Declined_Lifetime__c = 0;
            newContact.Submitted_This_Year__c = 0;
            newContact.Submitted_Last_Year__c = 0;
            newContact.Completed_This_Year__c = 0;
            newContact.Completed_Last_Year__c = 0;
        }
    }
}
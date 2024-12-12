public with sharing class AmlFlagHandler {

    List<AML_Flag__c> newAmlFlags = new List<AML_Flag__c>();
    Map<Id, AML_Flag__c> oldAmlFlags = new Map<Id, AML_Flag__c>();

    public AmlFlagHandler( List<AML_Flag__c> newRecords, Map<Id, AML_Flag__c> oldRecords ) {
        newAmlFlags = newRecords;
        oldAmlFlags = oldRecords;
    }

    public void updateResolvedDetails(){
        for ( AML_Flag__c newAmlFlag : newAmlFlags ) {
            if ( oldAmlFlags != null ) {
                AML_Flag__c oldAmlFlag = oldAmlFlags.get(newAmlFlag.Id);
                if ( !oldAmlFlag.Resolved__c && newAmlFlag.Resolved__c ) {
                    newAmlFlag.Resolved_By__c = UserInfo.getUserId();
                    newAmlFlag.Resolved_At__c = System.now();
                } else if ( oldAmlFlag.Resolved__c && !newAmlFlag.Resolved__c ) {
                    newAmlFlag.Resolved_By__c = null;
                    newAmlFlag.Resolved_At__c = null;
                }
            }
        }
    }

    public void updateScreeningFalsePositiveOnContact(){
        List<Contact> contactsToUpdate = new List<Contact>();
        for ( AML_Flag__c newAmlFlag : newAmlFlags ) {
            if ( oldAmlFlags != null ) {
                AML_Flag__c oldAmlFlag = oldAmlFlags.get(newAmlFlag.Id);
                if ( !oldAmlFlag.Resolved__c && newAmlFlag.Resolved__c && ( newAmlFlag.Type__c == 'AML Screening Hit' || newAmlFlag.Type__c == 'PEP' ) && newAmlFlag.Broker_s_Screening_Date_Within_One_Year__c) {
                    Contact contactToUpdate = new Contact();
                    contactToUpdate.Id = newAmlFlag.Related_Broker__c;
                    contactToUpdate.Screening_False_Positive__c = true;
                    contactsToUpdate.add(contactToUpdate);
                }
            }
        }

        if ( !contactsToUpdate.isEmpty() ) {
            SObjectDomain.getTriggerEvent(Contacts.class).disableAll();
                update contactsToUpdate;
            SObjectDomain.getTriggerEvent(Contacts.class).enableAll();
        }
    }
}
public with sharing class Contacts extends SObjectDomain {

    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 14-August-2024
    * @description Called by the trigger framework to carry out the actions after the newRecords are Inserted. 
    */
    protected override void onBeforeInsert() {
        new ContactsHelper( ( List<Contact> ) newRecords, null )
        .populateValuesOnFields();
    }

    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 14-August-2024
    * @description Called by the trigger framework to carry out the actions after the newRecords are Inserted. 
    */
    protected override void onAfterInsert() {
        new ContactsHelper( ( List<Contact> ) newRecords, null )
        .updateBrokerKpis();
    }

    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 14-August-2024
    * @description Called by the trigger framework to carry out the actions after the newRecords are Updated. 
    */
    protected override void onAfterUpdate() {
        new ContactsHelper( ( List<Contact> ) newRecords, ( Map<Id, Contact> ) oldRecordsMap )
        .updateBrokerKpis();
    }

     /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 14-August-2024
    * @description Called by the trigger framework to carry out the actions after the newRecords are Updated. 
    */
    protected override void onAfterDelete() {
        new ContactsHelper( ( List<Contact> ) oldRecords, null )
        .updateBrokerKpis();
    }

    /** 
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 14-August-2024
    * @description Called by the trigger framework to carry out the actions after the newRecords are Updated. 
    */
    protected override void onAfterUndelete() {
        new ContactsHelper( ( List<Contact> ) newRecords, null )
        .updateBrokerKpis();
    }
}
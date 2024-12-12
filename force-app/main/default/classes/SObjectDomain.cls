/**
 * SObjectDomain
 * @description Handles common domain functionality such as trigger events
 * @author Madhuri Menneni, Neighbourhood Holdings
 * @date 04-March-2022
 * 
 */
public abstract class SObjectDomain {
    protected List<SObject> newRecords;
    protected List<SObject> oldRecords;
    protected Map<Id, SObject> newRecordsMap;
	protected Map<Id, SObject> oldRecordsMap;

	//Retains the trigger tracking configuration used for each domain
	private static Map<Type, TriggerEvent> TriggerEventByClass = new Map<Type, TriggerEvent>();
	
    /**
    * @description When called within a Trigger context executes the appropriate logic
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 04-March-2022
    */
    public static void triggerHandler(Type domainClass) {
        Control_All_Objects__c allObjectsControlSetting = Control_All_Objects__c.getInstance();
        //has the triggers diabled?
        if(!isGlobalTriggerSwitchEnabled(allObjectsControlSetting)) {
            return;
        }

		// has this event been disabled?
        if (!getTriggerEvent(domainClass).isEnabled(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete)) {
			return;
		}
        //create a new instance of handler class
        SObjectDomain domain = (SObjectDomain) domainClass.newInstance();

        //Construct List of new records in the trigger context
        domain.newRecords = (Trigger.isDelete) ? (Trigger.old != null) ? Trigger.old : new List<SObject>() :
                                            ((Trigger.new != null) ? Trigger.new : new List<SObject>());
        //Construct Map of new records in the trigger context
		domain.newRecordsMap = (Trigger.isDelete) ? (Trigger.oldMap != null) ? Trigger.oldMap : new Map<Id, SObject>() :
											((Trigger.newMap != null) ? Trigger.newMap : new Map<Id, SObject>());
        //Construct List of old records in the trigger context
        domain.oldRecords = (Trigger.old != null) ? Trigger.old : new List<SObject>();
        //Construct Map of old records in the trigger context
		domain.oldRecordsMap = (Trigger.oldMap != null) ? Trigger.oldMap : new Map<Id, SObject>();

        //Check for trigger context and event to fire respective handler method
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                domain.onBeforeInsert();
            }
            else if (Trigger.isUpdate) {
                domain.onBeforeUpdate();
            }
            else if (Trigger.isDelete) {
                domain.onBeforeDelete();
            }
        } else if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                domain.onAfterInsert();
            }
            else if (Trigger.isUpdate) {
                domain.onAfterUpdate();
            }
            else if (Trigger.isDelete) {
                domain.onAfterDelete();
            }
            else if (Trigger.isUndelete) {
                domain.onAfterUndelete();
            }
        }
    }

    /**
    * @description Called by the trigger framework to carry out the actions before the records are inserted.
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 04-March-2022
    */
    protected virtual void onBeforeInsert() {}

    /**
    * @description Called by the trigger framework to carry out the actions before the records are updated.
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 04-March-2022
    */
    protected virtual void onBeforeUpdate() {}

    /**
    * @description Called by the trigger framework to carry out the actions before the records are Deleted.
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 04-March-2022
    */
    protected virtual void onBeforeDelete() {}

    /**
    * @description Called by the trigger framework to carry out the actions after the records are inserted.
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 04-March-2022
    */
    protected virtual void onAfterInsert() {}

    /**
    * @description Called by the trigger framework to carry out the actions after the records are updated.
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 04-March-2022
    */
    protected virtual void onAfterUpdate() {}

    /**
    * @description Called by the trigger framework to carry out the actions after the records are deleted.
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 04-March-2022
    */
    protected virtual void onAfterDelete() {}

    /**
    * @description Called by the trigger framework to carry out the actions after the records are undeleted.
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 04-March-2022
    */
    protected virtual void onAfterUndelete() {}

	/**
    * @description Called by the trigger framework to construct a map of the handler classes and events.
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 04-March-2022
    */
    public static TriggerEvent getTriggerEvent(Type domainClass){
		if(!TriggerEventByClass.containsKey(domainClass)) {
			TriggerEventByClass.put(domainClass, new TriggerEvent());
		}
		return TriggerEventByClass.get(domainClass);
	}

    /**
    * @description Called by the trigger framework to check if the trigger events are disabled in the transaction.
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 04-March-2022
    */
    public class TriggerEvent {
		public boolean beforeInsertEnabled {get; private set;}
		public boolean beforeUpdateEnabled {get; private set;}
		public boolean beforeDeleteEnabled {get; private set;}

		public boolean afterInsertEnabled {get; private set;}
		public boolean afterUpdateEnabled {get; private set;}
		public boolean afterDeleteEnabled {get; private set;}
		public boolean afterUndeleteEnabled {get; private set;}

        /**
        * @description Constructor for the class
        * @author Madhuri Menneni, Neighbourhood Holdings
        * @date 04-March-2022
        */
		public TriggerEvent(){
			this.enableAll();
		}

		//befores
		public TriggerEvent enableBeforeInsert() {beforeInsertEnabled = true; return this;}
		public TriggerEvent enableBeforeUpdate() {beforeUpdateEnabled = true; return this;}
		public TriggerEvent enableBeforeDelete() {beforeDeleteEnabled = true; return this;}

		public TriggerEvent disableBeforeInsert() {beforeInsertEnabled = false; return this;}
		public TriggerEvent disableBeforeUpdate() {beforeUpdateEnabled = false; return this;}
		public TriggerEvent disableBeforeDelete() {beforeDeleteEnabled = false; return this;}
		
		//afters
		public TriggerEvent enableAfterInsert() 	{afterInsertEnabled 	= true; return this;}
		public TriggerEvent enableAfterUpdate() 	{afterUpdateEnabled 	= true; return this;}
		public TriggerEvent enableAfterDelete() 	{afterDeleteEnabled 	= true; return this;}
		public TriggerEvent enableAfterUndelete()   {afterUndeleteEnabled 	= true; return this;}

		
		public TriggerEvent disableAfterInsert()	{afterInsertEnabled 	= false; return this;}
		public TriggerEvent disableAfterUpdate()	{afterUpdateEnabled 	= false; return this;}
		public TriggerEvent disableAfterDelete()	{afterDeleteEnabled 	= false; return this;}
		public TriggerEvent disableAfterUndelete()  {afterUndeleteEnabled 	= false; return this;}

        //enable all events
		public TriggerEvent enableAll() {
			return this.enableAllBefore().enableAllAfter();
		}

        //disable all events
		public TriggerEvent disableAll() {
			return this.disableAllBefore().disableAllAfter();
		}

        //enable all before events
		public TriggerEvent enableAllBefore() {
			return this.enableBeforeInsert().enableBeforeUpdate().enableBeforeDelete();
		}

        //disable all before events
		public TriggerEvent disableAllBefore() {
			return this.disableBeforeInsert().disableBeforeUpdate().disableBeforeDelete();
		}

        //enable all after events
		public TriggerEvent enableAllAfter() {
			return this.enableAfterInsert().enableAfterUpdate().enableAfterDelete().enableAfterUndelete();
		}

        //disable all after events
		public TriggerEvent disableAllAfter() {
			return this.disableAfterInsert().disableAfterUpdate().disableAfterDelete().disableAfterUndelete();
		}

        //method to check if the event is enabled
		public boolean isEnabled(Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
			if(isBefore) {
				if(isInsert) return beforeInsertEnabled;
				else if(isUpdate) return beforeUpdateEnabled;
				else if(isDelete) return beforeDeleteEnabled;
			}
			else if(isAfter) {
				if(isInsert) 		return afterInsertEnabled;
				else if(isUpdate) 	return afterUpdateEnabled;
				else if(isDelete) 	return afterDeleteEnabled;
				else if(isUndelete) return afterUndeleteEnabled;
			}
			return true;
		}
	}

    /**
    * @description Called by the trigger framework to check if the trigger is disabled through the object trigger custom setting switch
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 04-March-2022
    * @param controlSetting, Instance of trigger switch custom setting
    * @return Boolean variable referring to execute trigger or not
    */
    public static Boolean isSObjectTriggerEnabled(sObject controlSetting) {
        return (controlSetting == null || ((Boolean) controlSetting.get('Trigger_Disable_All_Operations__c') != true && (Boolean) controlSetting.get('Trigger_Disable_' + Trigger.operationType.name() + '__c') != true));
    }

    /**
    * @description Called by the trigger framework to check if all objects triggers are disabled through the all objects trigger custom setting switch
    * @author Madhuri Menneni, Neighbourhood Holdings
    * @date 04-March-2022
    * @param controlSetting, Instance of trigger switch custom setting
    * @return Boolean variable referring to execute trigger or not
    */
    public static Boolean isGlobalTriggerSwitchEnabled(sObject controlSetting) {
        return (controlSetting == null || ((Boolean) controlSetting.get('Disable_All_Triggers__c') != true));
    }
}
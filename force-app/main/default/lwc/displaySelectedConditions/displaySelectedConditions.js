import { LightningElement, track, api, wire } from 'lwc';
import getAllChildConditionsList from '@salesforce/apex/ConditionDisplayController.getAllChildConditions';
import getCustomConditionId from '@salesforce/apex/ConditionDisplayController.getCustomConditionId';
import { updateRecord } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { reduceErrors } from 'c/idsUtils';
import { getRecordCreateDefaults, generateRecordInputForCreate } from "lightning/uiRecordApi";
import RLA_SUB_CONDITION_OBJECT from '@salesforce/schema/RLA_Sub_Condition__c';
import RLA_STANDARD_CONDITION_OBJECT from '@salesforce/schema/RLA_Standard_Condition__c';
import Condition_Assignee_FIELD from '@salesforce/schema/RLA_Sub_Condition__c.Condition_Assignee__c';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
} from 'lightning/messageService';
import msgService from '@salesforce/messageChannel/RefreshLwc__c';
export default class ConditionDisplayController extends LightningElement {
    subscription = null;
    @track areChildConditionsAvailable = false;
    @track data = [];
    @api recordId;
    @track description;
    @track saveDraftValues = [];
    @track draftValues = [];
    @track columns = [
        { 
            label: 'Received', 
            fieldName:'Received__c', 
            editable: true, 
            type: 'boolean',
            initialWidth:75, 
            cellAttributes: { 
                                alignment: 'center' 
                            }},
        { 
            label: 'Name', 
            fieldName:'Condition__c', 
            editable: true,  
            type: 'customTextArea', 
            cellAttributes: { 
                                alignment: 'left',
                                wrapText: true,
                            }},
        { 
            label: 'Condition Assignee', 
            fieldName: 'Condition_Assignee__c', 
            type: 'picklistColumn', 
            editable: true, 
            initialWidth:160, 
            cellAttributes: { 
                                alignment: 'left' 
                            }, 
            typeAttributes: {
                                placeholder: 'Choose Type', 
                                options: { fieldName: 'pickListOptions' }, 
                                value: { fieldName: 'Condition_Assignee__c' }, // default value for picklist,
                                context: { fieldName: 'Id' } // binding account Id with context variable to be returned back
                            }},
        { 
            label: 'Source', 
            fieldName: 'RLA_Standard_Condition_Name__c', 
            editable: false, 
            wrapText: true, 
            type: 'text', 
            initialWidth:90, 
            cellAttributes: { 
                                alignment: 'center' 
                            }},
        { 
            label: 'Actions', 
            type: 'button',
            initialWidth:75,
            typeAttributes: { 
                                name: 'delete_button' ,
                                iconName: 'utility:delete'
                            }}
    ];
    showSpinner = false;
    @track subContionsData;
    lastSavedData = [];
    @track pickListOptions;
    @track standardConditionId;

    @wire(MessageContext)
    messageContext;

    @wire(getRecordCreateDefaults, { objectApiName: RLA_SUB_CONDITION_OBJECT })
    subConditionCreateDefaults;

    @wire(getRecordCreateDefaults, { objectApiName: RLA_STANDARD_CONDITION_OBJECT })
    standardConditionCreateDefaults;

    //here I pass picklist option so that this wire method call after above method
    @wire(getAllChildConditionsList, { pickList: '$pickListOptions', recId: '$recordId' })
    subContionsData(result) {
        this.subContionsData = result;
        if (result.data) {
            this.data = JSON.parse(JSON.stringify(result.data));
            if(this.data.length > 0 ) {
                this.areChildConditionsAvailable = true;
            }
            console.log('Data: ' + this.data);
            this.data.forEach(ele => {
                ele.pickListOptions = this.pickListOptions;
                console.log('ele: ' + JSON.stringify(ele));
            })
 
            this.lastSavedData = JSON.parse(JSON.stringify(this.data));
 
        } else if (result.error) {
            this.data = undefined;
        }
    };

    @wire(getCustomConditionId, {recId: '$recordId' })
    standardConditionId(result){
        if (result.data) {
            this.standardConditionId = result.data;
        } else if (result.error) {
            this.standardConditionId = undefined;
        }
    };
    
    async createNewCustomConditionRecord() {
        if (!this.subConditionCreateDefaults.data) {
          return undefined;
        }

        if( this.standardConditionId == undefined ) {
            const standardConditionObjectInfo =
            this.standardConditionCreateDefaults.data.objectInfos[RLA_STANDARD_CONDITION_OBJECT.objectApiName];
            const recordDefaults = this.standardConditionCreateDefaults.data.record;
            const recordInput = generateRecordInputForCreate(recordDefaults, standardConditionObjectInfo);
            recordInput.fields.Residential_Loan_Application__c = this.recordId;
            recordInput.fields.Name = 'Custom Condition';
            const retStandardCondition = await createRecord(recordInput);
            this.standardConditionId = retStandardCondition.id;
        }
    
        const subConditionObjectInfo =
        this.subConditionCreateDefaults.data.objectInfos[RLA_SUB_CONDITION_OBJECT.objectApiName];
        const recordDefaults = this.subConditionCreateDefaults.data.record;
        const recordInput = generateRecordInputForCreate(recordDefaults, subConditionObjectInfo);
        recordInput.fields.Residential_Loan_Application__c = this.recordId;
        console.log(this.standardConditionId);
        recordInput.fields.RLA_Standard_Condition__c = this.standardConditionId;
        console.log(recordInput);
		try {
            this.showSpinner = true;
            await createRecord(recordInput);
            await refreshApex(this.subContionsData);
            this.showSpinner = false;
        } catch (error) {
            this.showToast('Error', reduceErrors(error).join(', '), 'error');
            this.showSpinner = false;
        }
    }

    @wire(getObjectInfo, { objectApiName: RLA_SUB_CONDITION_OBJECT })
    objectInfo;
 
    //fetch picklist options
    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: Condition_Assignee_FIELD
    })
 
    wirePickList({ error, data }) {
        if (data) {
            this.pickListOptions = data.values;
        } else if (error) {
            console.log(error);
        }
    }
 
    updateDataValues(updateItem) {
        let copyData = JSON.parse(JSON.stringify(this.data));
 
        copyData.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });
        this.data = [...copyData];
    }
 
    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [...this.draftValues];
        copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });
 
        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
    }
 
    //handler to handle cell changes & update values in draft values
    handleCellChange(event) {
        //this.updateDraftValues(event.detail.draftValues[0]);
        let draftValues = event.detail.draftValues;
        draftValues.forEach(ele=>{
            this.updateDraftValues(ele);
        })
    }
 
    handleSave(event) {
        this.showSpinner = true;
        this.saveDraftValues = this.draftValues;
        
        const recordInputs = this.saveDraftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
 
        // Updateing the records using the UiRecordAPi
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(res => {
            this.showToast('Success', 'Records Updated Successfully!', 'success', 'dismissable');
            this.draftValues = [];
            return this.refresh();
        }).catch(error => {
            console.log(error);
            this.showToast('Error', 'An Error Occured!!', 'error', 'dismissable');
        }).finally(() => {
            this.draftValues = [];
            this.showSpinner = false;
        });
    }
 
    handleCancel(event) {
        //remove draftValues & revert data changes
        this.data = JSON.parse(JSON.stringify(this.lastSavedData));
        this.draftValues = [];
    }
 
    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
    handleSelect(event) {
        console.log('action', event.detail.name);
        this.description = event.detail.name;
        console.log('recId', this.recordId);
    }

    async handleRowActions(event) {
        if (event.detail.action.name==='delete_button') {
            const row = event.detail.row;
            try {
                this.showSpinner = true;
                await deleteRecord(row.Id);
                await refreshApex(this.subContionsData);
                this.showSpinner = false;
                this.showToast('Success', 'Condition deleted', 'success');
            } catch (error) {
                this.showToast('Error', reduceErrors(error).join(', '), 'error');
                this.showSpinner = false;
            }
        }
    }
    async refresh() {
        await refreshApex(this.subContionsData);
    }

    handleMessage(message) {
        this.recordId = message.recordId;
        this.refreshConditions();
    }

    async refreshConditions() {
		try {
			    this.showSpinner = true;
				await refreshApex(this.subContionsData);
				this.showSpinner = false;
		} catch (error) {
			this.showToast('Error', reduceErrors(error).join(', '), 'error');
			this.showSpinner = false;
		}
	}

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                msgService,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

};
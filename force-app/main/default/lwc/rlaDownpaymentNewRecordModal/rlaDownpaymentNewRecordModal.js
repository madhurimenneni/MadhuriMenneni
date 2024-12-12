import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { updateRecord } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { reduceErrors } from 'c/idsUtils';

import ModalRecordEditForm from "c/rlaDownpaymentNewRecordModal";
import getDownpaymentRecords from '@salesforce/apex/DownpaymentController.getDownpayments';
import DOWNPAYMENT_OBJECT from '@salesforce/schema/Downpayment__c';
import AMOUNT_FIELD from '@salesforce/schema/Downpayment__c.Amount__c';
import SOURCE_FIELD from '@salesforce/schema/Downpayment__c.Source__c';
import DATE_FIELD from '@salesforce/schema/Downpayment__c.Date__c';

const COLUMNS = [
    {
        label: 'Name',
        fieldName: 'nameUrl',
        type: 'url',
        sortable: true,
        typeAttributes: { label: { fieldName: 'Name' } }
    },
    {
        label: 'Amount',
        fieldName: AMOUNT_FIELD.fieldApiName,
        type: 'currency',
        editable: true,
        sortable: true,
        cellAttributes: {
            alignment: 'left'
        }
    },
    {
        label: 'Source',
        fieldName: SOURCE_FIELD.fieldApiName,
        type: 'text',
        editable: true,
        sortable: true,
        wrapText: true
    },
    {
        label: 'Date',
        fieldName: DATE_FIELD.fieldApiName,
        type: 'date-local',
        editable: true,
        sortable: true
    },
    {
        label: 'Delete',
        type: 'button',
        typeAttributes: {
            label: 'Delete',
            name: 'Delete',
            title: 'Delete',
            iconName: 'utility:delete',
            disabled: false
        }
    }
];

export default class LoanApplicationPropertyDownpayments extends NavigationMixin(LightningElement) {
    @api recordId;
    columns = COLUMNS;
    @track downpaymentRecords;
    showSpinner = false;

    downpaymentRecords;
    downpaymentRecordsRefreshProp;

    @track draftValues = [];
    @track changedRows = [];
    @track valuationSourcePickListValues = [];
    @track selectedRows = [];
    @track selectedRowsRecords = [];
    @track sortBy;
    @track sortDirection;
    @track loanPropertyId;

    @wire(getDownpaymentRecords, { objectApiName: DOWNPAYMENT_OBJECT })
    downpaymentRecordsWire(result) {
        this.downpaymentRecordsRefreshProp = result;
        if (result.data) {
            this.downpaymentRecords = result.data.map(record => ({
                ...record,
                nameUrl: `/lightning/r/${record.Id}/view`
            }));
        } else if (result.error) {
            this.showToast('Error', reduceErrors(result.error).join(', '), 'error');
        }
    }

    async handleSave(event) {
        this.showSpinner = true;
        const records = event.detail.draftValues.map(record => ({ fields: { ...record } }));

        try {
            await Promise.all(records.map(updateRecord));
            await refreshApex(this.downpaymentRecordsRefreshProp);
            this.showToast('Success', 'Records updated successfully', 'success');
            this.draftValues = [];
        } catch (error) {
            this.showToast('Error', reduceErrors(error).join(', '), 'error');
        } finally {
            this.showSpinner = false;
        }
    }

    handleRowAction(event) {
        const row = event.detail.row;
        this.deleteRow(row);

    }

    async deleteRow(row) {
        try {
            this.showSpinner = true;
            await deleteRecord(row.Id);
            await refreshApex(this.downpaymentRecordsRefreshProp);
            this.showSpinner = false;
            this.showToast('Success', 'Downpayment deleted', 'success');
        } catch (error) {
            this.showToast('Error', reduceErrors(error).join(', '), 'error');
            this.showSpinner = false;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    async createNewRecord() {
        await ModalRecordEditForm.open({
            size: "small",
            loanApplicationPropertyId: this.loanapplicationproperty.Id
        }).then((result) => {
            if (result !== undefined) {
                if (result === 'Success') {
                    refreshApex(this.downpaymentRecordsRefreshProp);
                    this.showToast('Success', 'Downpayment Created', 'success');
                } else {
                    this.showToast('Error', result, 'error');
                }
            }
        }
        );
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.downpaymentRecords));
        let keyValue = (a) => { 
            return a[fieldname]; 
        };
        // cheking reverse direction 
        let isReverse = direction === 'asc' ? 1 : -1; 
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.downpaymentRecords = parseData;
    }
    
    handleClick(event) {
        const recordId = event.target.dataset.oppid;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                actionName: "view",
                recordId: recordId
            }
        });
    }
}
import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { updateRecord } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from "lightning/navigation";
import { reduceErrors } from 'c/idsUtils';

import ModalRecordEditForm from "c/loanApplicationPropertyDownpaymentNewRecordModal";
import getDownpaymentRecords from "@salesforce/apex/DownpaymentController.getDownpayments";
import DOWNPAYMENT_OBJECT from "@salesforce/schema/Downpayment__c";
import AMOUNT_FIELD from "@salesforce/schema/Downpayment__c.Amount__c";
import SOURCE_FIELD from "@salesforce/schema/Downpayment__c.Source__c";
import DATE_FIELD from "@salesforce/schema/Downpayment__c.Date__c";

const COLUMNS = [
    {
        label: 'Name',
        fieldName: 'nameUrl',
        type: 'url',
        sortable: true,
        typeAttributes: { label: { fieldName: 'Name' } }
    },
    {
        label: "Amount",
        fieldName: AMOUNT_FIELD.fieldApiName,
        type: 'currency',
        sortable: true,
        editable: true,
        cellAttributes: {
            alignment: 'left'
        }
    },
    {
        label: "Source",
        fieldName: SOURCE_FIELD.fieldApiName,
        type: "liabilityTypePicklist",
        editable: true,
        wrapText: true,
        sortable: true,
        typeAttributes: {
            options: { fieldName: 'downpaymentSourcePickListOptions' },
            value: { fieldName: 'Source__c' },
            context: { fieldName: 'Id' }
        }
    },
    {
        label: "Date",
        fieldName: DATE_FIELD.fieldApiName,
        type: "date-local",
        editable: true,
        sortable: true
    },
    {
        label: 'Delete',
        type: "button",
        typeAttributes: {
            label: 'Delete',
            name: 'Delete',
            title: 'Delete',
            disabled: false,
            iconPosition: 'left',
            iconName: 'utility:record_delete'
        }
    }
];

export default class LoanApplicationPropertyDownpayments extends NavigationMixin(LightningElement) {
    @api recordId;
    columns = COLUMNS;
    showSpinner = false;

    downpaymentRecords;
    downpaymentRecordsRefreshProp;

    @track draftValues = [];
    @track changedRows = [];
    @track downpaymentSourcePickListValues = [];
    @track sortBy;
    @track sortDirection;
    @track loanPropertyId;

    @wire(getObjectInfo, { objectApiName: DOWNPAYMENT_OBJECT })
    downpaymentObjectMetadata;

    @wire(getPicklistValues, { recordTypeId: '$downpaymentObjectMetadata.data.defaultRecordTypeId', fieldApiName: SOURCE_FIELD })
    getDownpaymentSourceTypePicklistValues({ data, error }) {
        if (data) {
            this.downpaymentSourcePickListValues = data.values;
        } else if (error) {
            console.error("Error loading picklist values")
        }
    }

    @wire(getDownpaymentRecords, { loanApplicationPropertyId: "$recordId", pickList: "$downpaymentSourcePickListValues" })
    getDownpaymentsOutput(result) {
        this.downpaymentRecordsRefreshProp = result;
        if (result.data && this.downpaymentSourcePickListValues.length > 0) {
            this.downpaymentRecords = result.data.map(currItem => {
                let downpaymentSourcePickListOptions = this.downpaymentSourcePickListValues;
                let nameUrl = `/lightning/r/${currItem.Id}/edit`;
                if (currItem.Default__c) {
                    //this.selectedRows = [currItem.Id];
                    //this.selectedRowsRecords = [currItem];
                }
                return {
                    ...currItem,
                    downpaymentSourcePickListOptions: downpaymentSourcePickListOptions,
                    nameUrl
                };
            });

        } else if (result.error) {
            console.log("Error while loading Records", result.error);
        }
    }

    async handleSave(event) {
        this.showSpinner = true;
        let records = event.detail.draftValues;
        let recordDefault = [];
        this.changedRows.map((currItem) => {
            records.push(currItem);
            if (currItem.Default__c) {
                recordDefault = [currItem.Id];
            }
        });
        let updateRecordsArray = records.map((currItem) => {
            let fieldInput = { ...currItem };
            return {
                fields: fieldInput
            };
        });

        this.draftValues = [];
        try {
            let updateRecordsArrayPromise = updateRecordsArray.map((currItem) =>
                updateRecord(currItem)
            );
            //updateRecordstest({ selectedVal: recordDefault[0] });
            await Promise.all(updateRecordsArrayPromise);
            await refreshApex(this.downpaymentRecordsRefreshProp);
            this.showSpinner = false;
            this.showToast('Success', 'Downpayment updated', 'success');
        } catch (error) {
            this.showToast('Error', reduceErrors(error).join(', '), 'error');
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
            loanApplicationPropertyId: this.recordId
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
        // Return the value stored in the field
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

    }
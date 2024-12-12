import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { updateRecord } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from "lightning/navigation";
import { reduceErrors } from 'c/idsUtils';

import ModalRecordEditForm from "c/loanApplicationPropertyValuationsNewRecordModal";
import getValuationRecords from "@salesforce/apex/ValuationController.getValuations";
import updateRecordstest from "@salesforce/apex/ValuationController.calculatePropetyValueAction";
import VALUATION_OBJECT from "@salesforce/schema/Valuation__c";
import VALUATION_AMOUNT_FIELD from "@salesforce/schema/Valuation__c.Valuation_Amount__c";
import VALUATION_SOURCE_FIELD from "@salesforce/schema/Valuation__c.Valuation_Source__c";
import APPRAISAL_COMPANY_NAME_FIELD from "@salesforce/schema/Valuation__c.Appraisal_Company_Name__c";
import VALUATION_DATE_FIELD from "@salesforce/schema/Valuation__c.Valuation_Date__c";
import DEFAULT_FIELD from "@salesforce/schema/Valuation__c.Default__c";

const COLUMNS = [
    {
        label: 'Name',
        fieldName: 'nameUrl',
        type: 'url',
        sortable: true,
        typeAttributes: { label: { fieldName: 'Name' } }
    },
    {
        label: "Valuation Amount",
        fieldName: VALUATION_AMOUNT_FIELD.fieldApiName,
        type: 'currency',
        sortable: true,
        editable: true,
        cellAttributes: {
            alignment: 'left'
        }
    },
    {
        label: "Valuation Source",
        fieldName: VALUATION_SOURCE_FIELD.fieldApiName,
        type: "liabilityTypePicklist",
        editable: true,
        wrapText: true,
        sortable: true,
        typeAttributes: {
            options: { fieldName: 'valuationSourcePickListOptions' },
            value: { fieldName: 'Valuation_Source__c' },
            context: { fieldName: 'Id' }
        }
    },
    {
        label: "Appraisal Company Name",
        fieldName: APPRAISAL_COMPANY_NAME_FIELD.fieldApiName,
        editable: true,
        type: "Text",
        wrapText: true,
        sortable: true,
        cellAttributes: {
            alignment: 'left',
            wrapText: true
        }
    },
    {
        label: "Date",
        fieldName: VALUATION_DATE_FIELD.fieldApiName,
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

export default class LoanApplicationPropertyValuations extends NavigationMixin(LightningElement) {
    @api loanapplicationproperty;
    columns = COLUMNS;
    showSpinner = false;

    valuationRecords;
    valuationRecordsRefreshProp;

    @track draftValues = [];
    @track changedRows = [];
    @track valuationSourcePickListValues = [];
    @track selectedRows = [];
    @track selectedRowsRecords = [];
    @track sortBy;
    @track sortDirection;
    @track loanPropertyId;

    @wire(getObjectInfo, { objectApiName: VALUATION_OBJECT })
    valuationObjectMetadata;

    @wire(getPicklistValues, { recordTypeId: '$valuationObjectMetadata.data.defaultRecordTypeId', fieldApiName: VALUATION_SOURCE_FIELD })
    getValuationSourceTypePicklistValues({ data, error }) {
        if (data) {
            this.valuationSourcePickListValues = data.values;
        } else if (error) {
            console.log("Error loading picklist values")
        }
    }

    @wire(getValuationRecords, { loanApplicationPropertyId: "$loanapplicationproperty.Id", pickList: "$valuationSourcePickListValues" })
    getValuationsOutput(result) {
        this.valuationRecordsRefreshProp = result;
        if (result.data) {
            this.valuationRecords = result.data.map(currItem => {
                let valuationSourcePickListOptions = this.valuationSourcePickListValues;
                let nameUrl = `/lightning/r/${currItem.Id}/edit`;

                if (currItem.Default__c) {
                    this.selectedRows = [currItem.Id];
                    this.selectedRowsRecords = [currItem];
                }
                return {
                    ...currItem,
                    valuationSourcePickListOptions: valuationSourcePickListOptions,
                    nameUrl
                };
            });

        } else if (result.error) {
            console.log("Error while loading Records");
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
        this.selectedRows = [];
        try {
            let updateRecordsArrayPromise = updateRecordsArray.map((currItem) =>
                updateRecord(currItem)
            );
            updateRecordstest({ selectedVal: recordDefault[0] });
            await Promise.all(updateRecordsArrayPromise);
            await refreshApex(this.valuationRecordsRefreshProp);
            this.showSpinner = false;
            this.showToast('Success', 'Valuation updated', 'success');
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
            await refreshApex(this.valuationRecordsRefreshProp);
            this.showSpinner = false;
            this.showToast('Success', 'Valuation deleted', 'success');
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
                    refreshApex(this.valuationRecordsRefreshProp);
                    this.showToast('Success', 'Valuation Created', 'success');
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
        let parseData = JSON.parse(JSON.stringify(this.valuationRecords));
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
        this.valuationRecords = parseData;
    }

    handleRowSelection(event) {
        this.changedRows = [];
        this.selectedRowsRecords.forEach(row => {
            var obj = {};
            obj["Default__c"] = false;
            obj["Id"] = row.Id;

            this.changedRows.push(obj);
            this.draftValues = [...this.draftValues, obj];
        });

        this.selectedRowsRecords = [];
        var selectedRow = event.detail.selectedRows;
        selectedRow.forEach(row => {

            var obj = {};
            obj["Default__c"] = true;
            obj["Id"] = row.Id;

            this.changedRows.push(obj);
            this.selectedRows = [row.Id];
            this.selectedRowsRecords.push(obj);
            this.draftValues = [...this.draftValues, obj];
        });
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
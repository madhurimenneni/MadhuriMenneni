import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { updateRecord } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from "lightning/navigation";
import { reduceErrors } from 'c/idsUtils';

import ModalRecordEditForm from "c/rlaRentalIncomeNewRecordModal";
import getRentalIncomeRecords from "@salesforce/apex/RlaLWCsHelper.getRentalIncomeRecords";
import Rental_Income_OBJECT from "@salesforce/schema/Rental_Income__c";
import Unit_Number_FIELD from "@salesforce/schema/Rental_Income__c.Unit_Number__c";
import Monthly_Rental_Income_FIELD from "@salesforce/schema/Rental_Income__c.Monthly_Rental_Income__c";
import Property_Rental_Policy_FIELD from "@salesforce/schema/Rental_Income__c.Property_Rental_Policy__c";
import Property_Name_FIELD from "@salesforce/schema/Rental_Income__c.Property_Name__c";
import Property_Addback_Offset_Percentage__FIELD from "@salesforce/schema/Rental_Income__c.Property_Addback_Offset_Percentage__c";
import OCCUPANCY_TYPE_FIELD from "@salesforce/schema/Rental_Income__c.Occupancy_Type__c";

const COLUMNS = [
    {
        label: 'Name',
        fieldName: 'nameUrl',
        type: 'url',
        sortable: true,
        typeAttributes: { label: { fieldName: 'Name' } }
    },
    {
        label: 'Property Name',
        fieldName: 'propertyUrl',
        type: 'url',
        sortable: true,
        typeAttributes: { label: { fieldName: 'Property_Name__c' } }
    },
    {
        label: 'Unit Number',
        fieldName: Unit_Number_FIELD.fieldApiName,
        editable: true,
        type: 'customTextArea',
        sortable: false,
        cellAttributes: {
            alignment: 'left',
            wrapText: true
        }
    },
    {
        label: 'Rental Policy',
        fieldName: Property_Rental_Policy_FIELD.fieldApiName,
        editable: false,
        type: 'customTextArea',
        sortable: false,
        cellAttributes: {
            alignment: 'left',
            wrapText: true
        }
    },
    {
        label: "Monthly Rental Income",
        fieldName: Monthly_Rental_Income_FIELD.fieldApiName,
        type: 'currency',
        sortable: true,
        editable: true,
        cellAttributes: {
            alignment: 'left'
        }
    },
    {
        label: "Addback or Offset Percentage",
        fieldName: 'propertyAddbackOffsetPercentage',
        type: 'percent',
        sortable: true,
        editable: false,
        cellAttributes: {
            alignment: 'left'
        }
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
export default class RentalIncome extends NavigationMixin(LightningElement) {
    @api recordId;
    columns = COLUMNS;
    rentalIncomeRecords;
    @track draftValues = [];
    @track typePicklistValues = [];
    @track sortBy;
    @track sortDirection;
    @track residentialLoanApplicationId;
    showSpinner = false;
    rentalIncomeRefreshProp;

    @wire(getObjectInfo, { objectApiName: Rental_Income_OBJECT })
    rentalIncomeObjectMetadata;

    @wire(getPicklistValues, { recordTypeId: '$rentalIncomeObjectMetadata.data.defaultRecordTypeId', fieldApiName: Property_Rental_Policy_FIELD })
    getrentalIncomePicklistValues({ data, error }) {
        if (data) {
            this.typePicklistValues = data.values;
        } else if (error) {
            console.log("Error loading picklist values")
        }
    }

    @wire(getRentalIncomeRecords)
    getrentalIncomeOutput({ error, data }) {
        if (data) {
            this.data = data.map(record => {
                return {
                    ...record
                };
            });
        } else if (error) {
            console.error(error);
        }
    }
    @wire(getRentalIncomeRecords, { loanApplicationId: "$recordId", pickList: "$typePicklistValues" })
    getrentalIncomeOutput(result) {
        this.rentalIncomeRefreshProp = result;
        if (result.data) {
            this.rentalIncomeRecords = result.data.map(currItem => {
                let typePickListOptions = this.typePicklistValues;
                let nameUrl = `/lightning/r/${currItem.Id}/edit`;
                let propertyUrl = '';
                var propertyAddbackOffsetPercentage = currItem.Property_Addback_Offset_Percentage__c / 100;
                if (currItem.Property__c !== undefined && currItem.Property__c !== null) {
                    propertyUrl = `/lightning/r/${currItem.Property__c}/edit`;
                }

                return {
                    ...currItem,
                    typePickListOptions: typePickListOptions,
                    nameUrl,
                    propertyUrl,
                    propertyAddbackOffsetPercentage
                };
            });

        } else if (result.error) {
            console.log("Error while loading Records");
        }
    }

    async handleSave(event) {
        this.showSpinner = true;
        let records = event.detail.draftValues;
        let updateRecordsArray = records.map((currItem) => {
            let fieldInput = { ...currItem };
            return {
                fields: fieldInput
            };
        });

        this.draftValues = [];
        let updateRecordsArrayPromise = updateRecordsArray.map((currItem) =>
            updateRecord(currItem)
        );

        await Promise.all(updateRecordsArrayPromise);
        await refreshApex(this.rentalIncomeRefreshProp);
        this.showSpinner = false;
        this.showToast('Success', 'Rental Income updated', 'success');
    }

    handleRowAction(event) {
        const row = event.detail.row;
        this.deleteRow(row);

    }

    async deleteRow(row) {
        try {
            this.showSpinner = true;
            await deleteRecord(row.Id);
            await refreshApex(this.rentalIncomeRefreshProp);
            this.showSpinner = false;
            this.showToast('Success', 'Rental Income deleted', 'success');
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

            if (result === 'Success') {
                refreshApex(this.rentalIncomeRefreshProp);
                this.showToast('Success', 'Rental Income Created', 'success');
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
        let parseData = JSON.parse(JSON.stringify(this.rentalIncomeRecords));
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
        this.rentalIncomeRecords = parseData;
    }
}
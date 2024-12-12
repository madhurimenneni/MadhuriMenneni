import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { updateRecord } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from "lightning/navigation";
import { reduceErrors } from 'c/idsUtils';

import ModalRecordEditForm from "c/rlaPropertiesNewRecordModal";
import getLoanApplicationPropertyRecords from "@salesforce/apex/RlaLWCsHelper.getRlaLoanApplicationPropertyRecords";
import LOANAPPLICATIONPROPERTY_OBJECT from "@salesforce/schema/LoanApplicationProperty";
import LOAN_PURPOSE_FIELD from "@salesforce/schema/LoanApplicationProperty.Loan_Purpose__c";
import PROPERTY_TYPE_FIELD from "@salesforce/schema/LoanApplicationProperty.Property_Type__c";
import PROPERTY_VALUE_FIELD from "@salesforce/schema/LoanApplicationProperty.Property_Value__c";
import OCCUPANCY_TYPE from "@salesforce/schema/LoanApplicationProperty.PropertyUseType";
import COLLATERAL_POSITION_FIELD from "@salesforce/schema/LoanApplicationProperty.Collateral_Position__c";


const COLUMNS = [
    {
        label: 'Name',
        fieldName: 'nameUrl',
        type: 'url',
        sortable: true,
        typeAttributes: { label: { fieldName: 'Name' } }
    },
    {
        label: "Property Type",
        fieldName: PROPERTY_TYPE_FIELD.fieldApiName,
        type: "propertyTypePicklist",
        editable: true,
        wrapText: true,
        sortable: true,
        typeAttributes: {
            options: { fieldName: 'typePickListOptions' },
            value: { fieldName: 'Property_Type__c' },
            context: { fieldName: 'Id' }
        }
    },
    {
        label: "Occupancy Type",
        fieldName: OCCUPANCY_TYPE.fieldApiName,
        type: "propertyTypePicklist",
        editable: true,
        wrapText: true,
        sortable: true,
        typeAttributes: {
            options: { fieldName: 'typePickListOptions' },
            value: { fieldName: 'PropertyUseType' },
            context: { fieldName: 'Id' }
        }
    },
    {
        label: "Loan Purpose",
        fieldName: LOAN_PURPOSE_FIELD.fieldApiName,
        type: "propertyTypePicklist",
        editable: true,
        wrapText: true,
        sortable: true,
        typeAttributes: {
            options: { fieldName: 'typePickListOptions' },
            value: { fieldName: 'Loan_Purpose__c' },
            context: { fieldName: 'Id' }
        }
    },
    {
        label: "Collateral Position",
        fieldName: COLLATERAL_POSITION_FIELD.fieldApiName,
        type: "propertyTypePicklist",
        editable: true,
        wrapText: true,
        sortable: true,
        typeAttributes: {
            options: { fieldName: 'typePickListOptions' },
            value: { fieldName: 'Collateral_Position__c' },
            context: { fieldName: 'Id' }
        }
    },
    {
        label: 'Property Value',
        fieldName: PROPERTY_VALUE_FIELD.fieldApiName,
        editable: true,
        type: 'currency',
        sortable: true,
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
export default class LoanApplicationProperty extends NavigationMixin(LightningElement) {
    @api recordId;
    columns = COLUMNS;
    loanApplicationPropertyRecords;
    @track draftValues = [];
    @track typePicklistValues = [];
    @track sortBy;
    @track sortDirection;
    @track residentialLoanApplicationId;
    showSpinner = false;
    loanApplicationPropertyRefreshProp;

    @wire(getObjectInfo, { objectApiName: LOANAPPLICATIONPROPERTY_OBJECT })
    loanApplicationPropertyObjectMetadata;

    @wire(getPicklistValues, { recordTypeId: '$loanApplicationPropertyObjectMetadata.data.defaultRecordTypeId', fieldApiName: PROPERTY_TYPE_FIELD })
    getEmploymentPicklistValues({ data, error }) {
        if (data) {
            this.typePicklistValues = data.values;
        } else if (error) {
            console.log("Error loading picklist values")
        }
    }

    @wire(getLoanApplicationPropertyRecords, { loanApplicationId: "$recordId", pickList: "$typePicklistValues" })
    getFeeOutput(result) {
        this.loanApplicationPropertyRefreshProp = result;
        if (result.data) {
            this.loanApplicationPropertyRecords = result.data.map(currItem => {
                let typePickListOptions = this.typePicklistValues;
                let nameUrl = `/lightning/r/${currItem.Id}/edit`;

                return {
                    ...currItem,
                    typePickListOptions: typePickListOptions,
                    nameUrl,
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
        await refreshApex(this.loanApplicationPropertyRefreshProp);
        this.showSpinner = false;
        this.showToast('Success', 'Property updated', 'success');
    }

    handleRowAction(event) {
        const row = event.detail.row;
        this.deleteRow(row);

    }

    async deleteRow(row) {
        try {
            this.showSpinner = true;
            await deleteRecord(row.Id);
            await refreshApex(this.loanApplicationPropertyRefreshProp);
            this.showSpinner = false;
            this.showToast('Success', 'Property deleted', 'success');
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
            loanApplicationId: this.recordId
        }).then((result) => {
            console.log(result);
            if (result === 'Success') {
                refreshApex(this.loanApplicationPropertyRefreshProp);
                this.showToast('Success', 'Property Created', 'success');
            } else {
                this.showToast('Error', result, 'error');
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
        let parseData = JSON.parse(JSON.stringify(this.loanApplicationPropertyRecords));
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
        this.loanApplicationPropertyRecords = parseData;
    }
}
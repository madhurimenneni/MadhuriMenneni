import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { updateRecord } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from "lightning/navigation";
import { reduceErrors } from 'c/idsUtils';

import ModalRecordEditForm from "c/rlaApplicantsNewRecordModal";
import getRlaApplicantsRecords from "@salesforce/apex/RlaLWCsHelper.getRlaApplicantsRecords";
import LOANAPPLICANT_OBJECT from "@salesforce/schema/LoanApplicant";
import APPLICANT_TYPE_FIELD from "@salesforce/schema/LoanApplicant.Applicant_Type__c";
import CREDIT_SCORE_FIELD from "@salesforce/schema/LoanApplicant.Credit_Score__c";
import CITIZENSHIPSTATUS_FIELD from "@salesforce/schema/LoanApplicant.CitizenshipStatus";
import SUM_OF_EMPLOYMENTS_AND_INCOMES_FIELD from "@salesforce/schema/LoanApplicant.Sum_of_Employments_and_Incomes__c";

const COLUMNS = [
    {
        label: 'Name',
        fieldName: 'nameUrl',
        type: 'url',
        sortable: true,
        typeAttributes: { label: { fieldName: 'Name' } }
    },
    {
        label: "Applicant Type",
        fieldName: APPLICANT_TYPE_FIELD.fieldApiName,
        type: "liabilityTypePicklist",
        editable: true,
        wrapText: true,
        sortable: true,
        typeAttributes: {
            options: { fieldName: 'ApplicantTypePickListOptions' },
            value: { fieldName: 'Applicant_Type__c' },
            context: { fieldName: 'Id' }
        }
    },
    {
        label: "Credit Score",
        fieldName: CREDIT_SCORE_FIELD.fieldApiName,
        type: 'number',
        sortable: true,
        wrapText: true,
        editable: true,
        cellAttributes: {
            alignment: 'left'
        }
    },
    {
        label: "Citizenship Status",
        fieldName: CITIZENSHIPSTATUS_FIELD.fieldApiName,
        type: "liabilityTypePicklist",
        editable: true,
        wrapText: true,
        sortable: true,
        typeAttributes: {
            options: { fieldName: 'CitizenshipStatusTypePickListOptions' },
            value: { fieldName: 'CitizenshipStatus' },
            context: { fieldName: 'Id' }
        }
    },
    {
        label: "Sum Of All Income",
        fieldName: SUM_OF_EMPLOYMENTS_AND_INCOMES_FIELD.fieldApiName,
        type: 'currency',
        sortable: true,
        wrapText: true,
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
export default class LoanApplicant extends NavigationMixin(LightningElement) {
    @api recordId;
    columns = COLUMNS;
    loanApplicantRecords;
    @track draftValues = [];
    @track ApplicantTypePickListValues = [];
    @track CitizenshipStatusTypePickListValues = [];
    @track sortBy;
    @track sortDirection;
    @track residentialLoanApplicationId;
    showSpinner = false;
    loanApplicantRefreshProp;

    @wire(getObjectInfo, { objectApiName: LOANAPPLICANT_OBJECT })
    loanApplicantObjectMetadata;

    @wire(getPicklistValues, { recordTypeId: '$loanApplicantObjectMetadata.data.defaultRecordTypeId', fieldApiName: APPLICANT_TYPE_FIELD })
    getApplicantTypePickListValues({ data, error }) {
        if (data) {
            this.ApplicantTypePickListValues = data.values;
        } else if (error) {
            console.log("Error loading picklist values")
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$loanApplicantObjectMetadata.data.defaultRecordTypeId', fieldApiName: CITIZENSHIPSTATUS_FIELD })
    getCitizenshipStatusTypePickListValues({ data, error }) {
        if (data) {
            this.CitizenshipStatusTypePickListValues = data.values;
        } else if (error) {
            console.log("Error loading picklist values")
        }
    }
    @wire(getRlaApplicantsRecords, { loanApplicationId: "$recordId", pickList: "$ApplicantTypePickListValues", pickList: "$CitizenshipStatusTypePickListValues" })
    getLiabilitiesOutput(result) {
        this.loanApplicantRefreshProp = result;
        if (result.data) {
            this.loanApplicantRecords = result.data.map(currItem => {

                let CitizenshipStatusTypePickListOptions = this.CitizenshipStatusTypePickListValues;
                let ApplicantTypePickListOptions = this.ApplicantTypePickListValues;

                let nameUrl = `/lightning/r/${currItem.Id}/edit`;
                return {
                    ...currItem,
                    CitizenshipStatusTypePickListOptions: CitizenshipStatusTypePickListOptions,
                    ApplicantTypePickListOptions: ApplicantTypePickListOptions,
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
        await refreshApex(this.loanApplicantRefreshProp);
        this.showSpinner = false;
        this.showToast('Success', 'Applicant updated', 'success');
    }

    handleRowAction(event) {
        const row = event.detail.row;
        this.deleteRow(row);

    }

    async deleteRow(row) {
        try {
            this.showSpinner = true;
            await deleteRecord(row.Id);
            await refreshApex(this.loanApplicantRefreshProp);
            this.showSpinner = false;
            this.showToast('Success', 'Applicant deleted', 'success');
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

            if (result === 'Success') {
                refreshApex(this.loanApplicantRefreshProp);
                this.showToast('Success', 'Applicant Created', 'success');
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
        let parseData = JSON.parse(JSON.stringify(this.loanApplicantRecords));
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
        this.loanApplicantRecords = parseData;
    }
}
import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { updateRecord } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from "lightning/navigation";
import { reduceErrors } from 'c/idsUtils';

import ModalRecordEditForm from "c/loanApplicantEmploymentsNewRecordModal";
import getEmploymentRecords from "@salesforce/apex/LoanApplicantEmploymentController.getEmploymentRecords";
import LOANAPPLICANTEMPLOYMENT_OBJECT from "@salesforce/schema/LoanApplicantEmployment";
import EMPLOYMENT_TYPE_FIELD from "@salesforce/schema/LoanApplicantEmployment.Employment_Type__c";
import FREQUENCY_FIELD from "@salesforce/schema/LoanApplicantEmployment.Frequency__c";
import INCOME_FIELD from "@salesforce/schema/LoanApplicantEmployment.Income__c";
import INCOME_TYPE_FIELD from "@salesforce/schema/LoanApplicantEmployment.Income_Type__c";
import CURRENTLY_WORKS_HERE_FIELD from "@salesforce/schema/LoanApplicantEmployment.Currently_works_here__c";

const COLUMNS = [
    {
        label: 'Name',
        fieldName: 'nameUrl',
        type: 'url',
        sortable: true,
        typeAttributes: {label: { fieldName: 'Name' }}
    },
    {
        label: "Employment Type",
        fieldName: EMPLOYMENT_TYPE_FIELD.fieldApiName,
        type: "liabilityTypePicklist",
        editable: true,
        wrapText: true,
        sortable: true,
        typeAttributes: {
            options: { fieldName : 'employmentTypePickListOptions' },
            value : { fieldName : 'Employment_Type__c'},
            context: { fieldName : 'Id' }
        }
    },
    {
        label: "Frequency",
        fieldName: FREQUENCY_FIELD.fieldApiName,
        type: "liabilityTypePicklist",
        editable: true,
        wrapText: true,
        sortable: true,
        typeAttributes: {
            options: { fieldName : 'frequencyPickListOptions' },
            value : { fieldName : 'Frequency__c'},
            context: { fieldName : 'Id' }
        }
    },
    {
        label: "Income",
        fieldName: INCOME_FIELD.fieldApiName,
        type: 'currency',
        sortable: true,
        editable: true,
        cellAttributes: { 
            alignment: 'left' 
        }
      },
      {
        label: "Income Type",
        fieldName: INCOME_TYPE_FIELD.fieldApiName,
        type: "liabilityTypePicklist",
        editable: true,
        wrapText: true,
        sortable: true,
        typeAttributes: {
            options: { fieldName : 'incomeTypePickListOptions' },
            value : { fieldName : 'Income_Type__c'},
            context: { fieldName : 'Id' }
        }
    },
    { 
        label: 'Currently works here', 
        fieldName:CURRENTLY_WORKS_HERE_FIELD.fieldApiName, 
        editable: true, 
        type: 'boolean',
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
            iconName:'utility:record_delete' }  
    }
];
export default class LoanApplicantEmployments extends NavigationMixin(LightningElement) {
    @api recordId;
    columns = COLUMNS;
    loanApplicantEmploymentsRecords;
    @track draftValues = [];
    @track employmentTypePicklistValues = [];
    @track frequencyPicklistValues = [];
    @track incomeTypePicklistValues = [];
    @track sortBy;
    @track sortDirection;
    @track residentialLoanApplicationId;
    showSpinner = false;
    loanApplicantEmploymentsRefreshProp;
    sumOfTotalIncome = 0;

    @wire(getObjectInfo, { objectApiName: LOANAPPLICANTEMPLOYMENT_OBJECT })
    loanApplicantEmploymentObjectMetadata;

    @wire(getPicklistValues, { recordTypeId: '$loanApplicantEmploymentObjectMetadata.data.defaultRecordTypeId', fieldApiName: EMPLOYMENT_TYPE_FIELD })
    getEmploymentPicklistValues({data, error}) {
        if (data) {
            this.employmentTypePicklistValues = data.values;
        } else if(error){
            console.log("Error loading picklist values")
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$loanApplicantEmploymentObjectMetadata.data.defaultRecordTypeId', fieldApiName: FREQUENCY_FIELD })
    getFrequencyPicklistValues({data, error}) {
        if (data) {
            this.frequencyPicklistValues = data.values;
        } else if(error){
            console.log("Error loading picklist values")
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$loanApplicantEmploymentObjectMetadata.data.defaultRecordTypeId', fieldApiName: INCOME_TYPE_FIELD })
    getIncomeTypePicklistValues({data, error}) {
        if (data) {
            this.incomeTypePicklistValues = data.values;
        } else if(error){
            console.log("Error loading picklist values")
        }
    }

    @wire (getEmploymentRecords, {loanApplicantId: "$recordId", pickList: "$employmentTypePicklistValues", pickList: "$frequencyPicklistValues", pickList: "$incomeTypePicklistValues" } )
	getLiabilitiesOutput(result) {
		this.loanApplicantEmploymentsRefreshProp = result;
		if(result.data){
            let sumOfTotalIncomelocal = 0;
            let CADDollar = new Intl.NumberFormat('en-US', {
                style: 'currency',
                currency: 'USD',
            });
			this.loanApplicantEmploymentsRecords = result.data.map(currItem => {
                if(currItem.LoanApplicationId !== undefined && currItem.LoanApplicationId !== null ){
                    this.residentialLoanApplicationId = currItem.LoanApplicationId;
                }
                if(currItem.Income__c !== undefined && currItem.Income__c !== null  && currItem.Currently_works_here__c) {
                    sumOfTotalIncomelocal = sumOfTotalIncomelocal + currItem.Income__c;
                }
				let employmentTypePickListOptions = this.employmentTypePicklistValues;
                let frequencyPickListOptions = this.frequencyPicklistValues;
                let incomeTypePickListOptions = this.incomeTypePicklistValues;
                
                let nameUrl = `/lightning/r/${currItem.Id}/edit`;
				return {
					...currItem, 
					employmentTypePickListOptions : employmentTypePickListOptions,
                    frequencyPickListOptions : frequencyPickListOptions,
                    incomeTypePickListOptions : incomeTypePickListOptions,
                    nameUrl
				};
			});
            this.sumOfTotalIncome = CADDollar.format(sumOfTotalIncomelocal);
            
		} else if (result.error){
			console.log("Error while loading Records");
		}
	}

    async handleSave(event) {
		this.showSpinner = true;
        let records = event.detail.draftValues;
        let updateRecordsArray = records.map((currItem) => {
            let fieldInput = {...currItem };
            return {
                fields: fieldInput
            };
        });

        this.draftValues = [];
        let updateRecordsArrayPromise = updateRecordsArray.map((currItem) => 
            updateRecord(currItem)
        );

        await Promise.all(updateRecordsArrayPromise);
        await refreshApex(this.loanApplicantEmploymentsRefreshProp);
        this.showSpinner = false;
        this.showToast('Success', 'Employment updated', 'success');
	}

    handleRowAction(event) {
		const row = event.detail.row;
		this.deleteRow(row);
				
	}

	async deleteRow(row) {
		try {
			    this.showSpinner = true;
				await deleteRecord(row.Id);
				await refreshApex(this.loanApplicantEmploymentsRefreshProp);
				this.showSpinner = false;
				this.showToast('Success', 'Employment deleted', 'success');
		} catch (error) {
			this.showToast('Error', reduceErrors(error).join(', '), 'error');
			this.showSpinner = false;
		}
	}

    showToast(title, message, variant){
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
              loanApplicantId : this.recordId,
              loanApplicationId : this.residentialLoanApplicationId
            }).then((result) => {
                
                if(result === 'Success') {
                    refreshApex(this.loanApplicantEmploymentsRefreshProp);
                    this.showToast('Success', 'Employment Created', 'success');
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
        let parseData = JSON.parse(JSON.stringify(this.loanApplicantEmploymentsRecords));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.loanApplicantEmploymentsRecords = parseData;
    }  
}
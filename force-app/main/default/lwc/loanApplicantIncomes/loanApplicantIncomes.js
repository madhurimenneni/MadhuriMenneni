import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { updateRecord } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from "lightning/navigation";
import { reduceErrors } from 'c/idsUtils';

import ModalRecordEditForm from "c/loanApplicantIncomesNewRecordModal";
import getIncomeRecords from "@salesforce/apex/LoanApplicantIncomeController.getIncomeRecords";
import LOANAPPLICANTINCOME_OBJECT from "@salesforce/schema/LoanApplicantIncome";
import INCOMESOURCETYPE_FIELD from "@salesforce/schema/LoanApplicantIncome.IncomeSourceType";
import DESCRIPTION_FIELD from "@salesforce/schema/LoanApplicantIncome.Description__c";
import ANNUAL_INCOME_FIELD from "@salesforce/schema/LoanApplicantIncome.Annual_Income__c";
import START_DATE_FIELD from "@salesforce/schema/LoanApplicantIncome.Start_Date__c";
import END_DATE_FIELD from "@salesforce/schema/LoanApplicantIncome.End_Date__c";
import CURRENTLY_RECEIVES_FIELD from "@salesforce/schema/LoanApplicantIncome.Currently_Receives__c";

const COLUMNS = [
    {
        label: 'Name',
        fieldName: 'nameUrl',
        type: 'url',
        sortable: true,
        typeAttributes: {label: { fieldName: 'Name' }}
    },
    {
        label: "Income Source Type",
        fieldName: INCOMESOURCETYPE_FIELD.fieldApiName,
        type: "liabilityTypePicklist",
        editable: true,
        wrapText: true,
        sortable: true,
        typeAttributes: {
            options: { fieldName : 'incomeSourceTypePickListOptions' },
            value : { fieldName : 'IncomeSourceType'},
            context: { fieldName : 'Id' }
        }
    },
    {
        label: "Description", 
        fieldName: DESCRIPTION_FIELD.fieldApiName, 
        editable: true,  
        type: "customTextArea", 
        cellAttributes: { 
                            alignment: 'left', 
                            wrapText: true 
                        }
    },
    {
        label: "Annual Income",
        fieldName: ANNUAL_INCOME_FIELD.fieldApiName,
        type: 'currency',
        sortable: true,
        editable: true,
        cellAttributes: { 
            alignment: 'left' 
        }
      },
      {
        label: "Start Date",
        fieldName: START_DATE_FIELD.fieldApiName,
        type: "date-local",
        editable: true,
        sortable: true
    },
    {
        label: "End Date",
        fieldName: END_DATE_FIELD.fieldApiName,
        type: "date-local",
        editable: true,
        sortable: true
    },
    { 
        label: 'Currently Receives', 
        fieldName:CURRENTLY_RECEIVES_FIELD.fieldApiName, 
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
    loanApplicantIncomesRecords;
    @track draftValues = [];
    @track incomeSourceTypePickListValues = [];
    @track sortBy;
    @track sortDirection;
    @track residentialLoanApplicationId;
    showSpinner = false;
    loanApplicantIncomesRefreshProp;
    sumOfAnnualIncome = 0;

    @wire(getObjectInfo, { objectApiName: LOANAPPLICANTINCOME_OBJECT })
    loanApplicantIncomeObjectMetadata;

    @wire(getPicklistValues, { recordTypeId: '$loanApplicantIncomeObjectMetadata.data.defaultRecordTypeId', fieldApiName: INCOMESOURCETYPE_FIELD })
    getIncomeSourceTypePicklistValues({data, error}) {
        if (data) {
            this.incomeSourceTypePickListValues = data.values;
        } else if(error){
            console.log("Error loading picklist values")
        }
    }

    @wire (getIncomeRecords, {loanApplicantId: "$recordId", pickList: "$incomeSourceTypePickListValues"} )
	getIncomesOutput(result) {
		this.loanApplicantIncomesRefreshProp = result;
		if(result.data){
            let sumOfAnnualIncomelocal = 0;
            let CADDollar = new Intl.NumberFormat('en-US', {
                style: 'currency',
                currency: 'USD',
            });
			this.loanApplicantIncomesRecords = result.data.map(currItem => {
                if(currItem.LoanApplicationId !== undefined && currItem.LoanApplicationId !== null ){
                    this.residentialLoanApplicationId = currItem.LoanApplicationId;
                }
                if(currItem.Annual_Income__c !== undefined && currItem.Annual_Income__c !== null && currItem.Currently_Receives__c) {
                    sumOfAnnualIncomelocal = sumOfAnnualIncomelocal + currItem.Annual_Income__c;
                }
				let incomeSourceTypePickListOptions = this.incomeSourceTypePickListValues;
                
                let nameUrl = `/lightning/r/${currItem.Id}/edit`;
				return {
					...currItem, 
					incomeSourceTypePickListOptions : incomeSourceTypePickListOptions,
                    nameUrl
				};
			});
            this.sumOfAnnualIncome = CADDollar.format(sumOfAnnualIncomelocal);
            
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
        await refreshApex(this.loanApplicantIncomesRefreshProp);
        this.showSpinner = false;
        this.showToast('Success', 'Income updated', 'success');
	}

    handleRowAction(event) {
		const row = event.detail.row;
		this.deleteRow(row);
				
	}

	async deleteRow(row) {
		try {
			    this.showSpinner = true;
				await deleteRecord(row.Id);
				await refreshApex(this.loanApplicantIncomesRefreshProp);
				this.showSpinner = false;
				this.showToast('Success', 'Income deleted', 'success');
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
                    refreshApex(this.loanApplicantIncomesRefreshProp);
                    this.showToast('Success', 'Income Created', 'success');
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
        let parseData = JSON.parse(JSON.stringify(this.loanApplicantIncomesRecords));
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
        this.loanApplicantIncomesRecords = parseData;
    }  
}
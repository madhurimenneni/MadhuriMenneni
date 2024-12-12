import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { updateRecord } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from "lightning/navigation";
import { reduceErrors } from 'c/idsUtils';
import ModalRecordEditForm from "c/rlaLiabilitiesNewRecordModal";
import getLiabilities from "@salesforce/apex/LiabilityController.getLiabilities";
import LOANAPPLICATIONLIABILITY_OBJECT from "@salesforce/schema/LoanApplicationLiability";
import LIABILITYTYPE_FIELD from "@salesforce/schema/LoanApplicationLiability.Liability_Type__c";
import PAYOFF_FIELD from "@salesforce/schema/LoanApplicationLiability.Payoff__c";
import MONTHLY_PAYMENT_FIELD from "@salesforce/schema/LoanApplicationLiability.Monthly_Payment__c";
import BALANCE_FIELD from "@salesforce/schema/LoanApplicationLiability.Balance__c";
import CREDIT_CARD_BALANCE_FIELD from "@salesforce/schema/LoanApplicationLiability.Credit_Card_Balance__c";

const COLUMNS = [
    {
        label: 'Name',
        fieldName: 'nameUrl',
        type: 'url',
        sortable: true,
        typeAttributes: {label: { fieldName: 'Name' }}
    },
    {
        label: "Monthly Payment",
        fieldName: MONTHLY_PAYMENT_FIELD.fieldApiName,
        type: 'currency',
        sortable: true,
        editable: true
      },
    {
      label: "Credit Card Balance",
      fieldName: CREDIT_CARD_BALANCE_FIELD.fieldApiName,
      type: 'currency',
      sortable: true,
      editable: true
    },
    {
      label: "Balance",
      fieldName: BALANCE_FIELD.fieldApiName,
      type: 'currency',
      sortable: true,
      editable: true
    },
    {
        label: "Liability Type",
        fieldName: LIABILITYTYPE_FIELD.fieldApiName,
        type: "liabilityTypePicklist",
        editable: true,
        wrapText: true,
        sortable: true,
        typeAttributes: {
            options: { fieldName : 'liabilityTypePickListOptions' },
            value : { fieldName : 'Liability_Type__c'},
            context: { fieldName : 'Id' }
        }
    },
    {
        label: "Payoff",
        fieldName: PAYOFF_FIELD.fieldApiName,
        type: "liabilityTypePicklist",
        editable: true,
        wrapText: true,
        sortable: true,
        typeAttributes: {
            options: { fieldName : 'payoffPickListOptions' },
            value : { fieldName : 'Payoff__c'},
            context: { fieldName : 'Id' }
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
export default class RlaLiabilities extends NavigationMixin(LightningElement) {
    @api recordId;
    columns = COLUMNS;
    liabilities;
    @track draftValues = [];
    @track liabilityTypePicklistValues = [];
    @track payoffPicklistValues = [];
    @track sortBy;
    @track sortDirection;
    showSpinner = false;
    liabilityRefreshProp;
    sumOfMonthlyPayment = 0;
    sumOfBalance = 0;

    @wire(getObjectInfo, { objectApiName: LOANAPPLICATIONLIABILITY_OBJECT })
    liabilityObjectMetadata;

    @wire(getPicklistValues, { recordTypeId: '$liabilityObjectMetadata.data.defaultRecordTypeId', fieldApiName: LIABILITYTYPE_FIELD })
    getStagePicklistValues({data, error}) {
        if (data) {
            this.liabilityTypePicklistValues = data.values;
        } else if(error){
            console.log("Error loading picklist values")
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$liabilityObjectMetadata.data.defaultRecordTypeId', fieldApiName: PAYOFF_FIELD })
    getPayoffPicklistValues({data, error}) {
        if (data) {
            this.payoffPicklistValues = data.values;
        } else if(error){
            console.log("Error loading picklist values")
        }
    }

    @wire (getLiabilities, {loanApplicationId: "$recordId", pickList: "$liabilityTypePicklistValues", pickList: "$payoffPicklistValues" } )
	getLiabilitiesOutput(result) {
		this.liabilityRefreshProp = result;
		if(result.data){
            let sumOfMonthlyPaymentlocal = 0;
            let sumOfBalancelocal = 0;
            let CADDollar = new Intl.NumberFormat('en-US', {
                style: 'currency',
                currency: 'USD',
            });
			this.liabilities = result.data.map(currItem => {
                if(currItem.Monthly_Payment__c !== undefined && currItem.Monthly_Payment__c !== null) {
                    sumOfMonthlyPaymentlocal = sumOfMonthlyPaymentlocal + currItem.Monthly_Payment__c;
                }
                if(currItem.Balance__c !== undefined && currItem.Balance__c !== null) {
                    sumOfBalancelocal = sumOfBalancelocal + currItem.Balance__c;
                }
				let liabilityTypePickListOptions = this.liabilityTypePicklistValues;
                let payoffPicklistOptions = this.payoffPicklistValues;
                let nameUrl = `/lightning/r/${currItem.Id}/edit`;
				return {
					...currItem, 
					liabilityTypePickListOptions : liabilityTypePickListOptions,
                    payoffPickListOptions : payoffPicklistOptions,
                    nameUrl
				};
			});
            this.sumOfMonthlyPayment = CADDollar.format(sumOfMonthlyPaymentlocal);
            this.sumOfBalance = CADDollar.format(sumOfBalancelocal);
            
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
        await refreshApex(this.liabilityRefreshProp);
        this.showSpinner = false;
        this.showToast('Success', 'Liability updated', 'success');
	}

    handleRowAction(event) {
		const row = event.detail.row;
		this.deleteRow(row);
				
	}

	async deleteRow(row) {
		try {
			    this.showSpinner = true;
				await deleteRecord(row.Id);
				await refreshApex(this.liabilityRefreshProp);
				this.showSpinner = false;
				this.showToast('Success', 'Liability deleted', 'success');
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
              rlaId : this.recordId
            }).then((result) => {
                
                if(result === 'Success') {
                    refreshApex(this.liabilityRefreshProp);
                    this.showToast('Success', 'Liability Created', 'success');
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
        let parseData = JSON.parse(JSON.stringify(this.liabilities));
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
        this.liabilities = parseData;
    }  
}
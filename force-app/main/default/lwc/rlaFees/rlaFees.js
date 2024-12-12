import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { updateRecord } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from "lightning/navigation";
import { reduceErrors } from 'c/idsUtils';

import ModalRecordEditForm from "c/rlaFeeNewRecordModal";
import getFeeRecords from "@salesforce/apex/RlaLWCsHelper.getRlaFeeRecords";
import FEE_OBJECT from "@salesforce/schema/Fee__c";
import DESCRIPTION_FIELD from "@salesforce/schema/Fee__c.Description__c";
import AMOUNT_FIELD from "@salesforce/schema/Fee__c.Amount__c";
import FEE_PERCENT_FIELD from "@salesforce/schema/Fee__c.Fee_Percent__c";
import FEE_TYPE_FIELD from "@salesforce/schema/Fee__c.Fee_Type__c";

const COLUMNS = [
    {
        label: 'Name',
        fieldName: 'nameUrl',
        type: 'url',
        sortable: true,
        typeAttributes: {label: { fieldName: 'Name' }}
    },
    {
        label: "Fee Type",
        fieldName: FEE_TYPE_FIELD.fieldApiName,
        type: "liabilityTypePicklist",
        editable: true,
        wrapText: true,
        sortable: true,
        typeAttributes: {
            options: { fieldName : 'typePickListOptions' },
            value : { fieldName : 'Type__c'},
            context: { fieldName : 'Id' }
        }
    },
    { 
        label: 'Amount', 
        fieldName:AMOUNT_FIELD.fieldApiName, 
        editable: true, 
        type: 'currency',
        sortable: true,
        cellAttributes: { 
                            alignment: 'left' 
                        }
    },
    { 
        label: 'Fee Percentage', 
        fieldName:FEE_PERCENT_FIELD.fieldApiName, 
        editable: true, 
        type: 'number',
        sortable: true,
        wrapText: true, 
        cellAttributes: { 
                            alignment: 'left' 
                        }
    },
    {
        label: "Description", 
        fieldName: DESCRIPTION_FIELD.fieldApiName, 
        editable: true,  
        type: "customTextArea",
        wrapText: true,
        cellAttributes: { 
                            alignment: 'left',  
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
export default class Fee extends NavigationMixin(LightningElement) {
    @api recordId;
    columns = COLUMNS;
   feeRecords;
    @track draftValues = [];
    @track typePicklistValues = [];
    @track sortBy;
    @track sortDirection;
    @track residentialLoanApplicationId;
    showSpinner = false;
    feeRefreshProp;

    @wire(getObjectInfo, { objectApiName: FEE_OBJECT })
    feeObjectMetadata;

    @wire(getPicklistValues, { recordTypeId: '$feeObjectMetadata.data.defaultRecordTypeId', fieldApiName: FEE_TYPE_FIELD })
    getEmploymentPicklistValues({data, error}) {
        if (data) {
            this.typePicklistValues = data.values;
        } else if(error){
            console.log("Error loading picklist values")
        }
    }

    @wire (getFeeRecords, {loanApplicationId: "$recordId", pickList: "$typePicklistValues" } )
    getFeeOutput(result) {
        this.feeRefreshProp = result;
        if(result.data){
            this.feeRecords = result.data.map(currItem => {
                let typePickListOptions = this.typePicklistValues;
                let nameUrl = `/lightning/r/${currItem.Id}/edit`;
                let FEE_PERCENT_FIELD = currItem.Fee_Percent__c / 100;
               
                return {
                    ...currItem, 
                    typePickListOptions : typePickListOptions,
                    nameUrl,
                    FEE_PERCENT_FIELD
                };
            });
            
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
        await refreshApex(this.feeRefreshProp);
        this.showSpinner = false;
        this.showToast('Success', 'Fees updated', 'success');
    }

    handleRowAction(event) {
        const row = event.detail.row;
        this.deleteRow(row);
                
    }

    async deleteRow(row) {
        try {
                this.showSpinner = true;
                await deleteRecord(row.Id);
                await refreshApex(this.feeRefreshProp);
                this.showSpinner = false;
                this.showToast('Success', 'Fees deleted', 'success');
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
              loanApplicationId : this.recordId
            }).then((result) => {
                
                if(result === 'Success') {
                    refreshApex(this.feeRefreshProp);
                    this.showToast('Success', 'Fees Created', 'success');
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
        let parseData = JSON.parse(JSON.stringify(this.feeRecords));
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
        this.feeRecords = parseData;
    }  
}
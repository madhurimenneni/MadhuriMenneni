import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { updateRecord } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from "lightning/navigation";
import { reduceErrors } from 'c/idsUtils';

import ModalRecordEditForm from "c/rlaAssetsNewRecordModal";
import getEmploymentRecords from "@salesforce/apex/RlaLWCsHelper.getRlaAssetsRecords";
import LOANAPPLICATIONASSET_OBJECT from "@salesforce/schema/LoanApplicationAsset";
import ASSETTYPE_FIELD from "@salesforce/schema/LoanApplicationAsset.AssetType";
import CASHORMARKETVALUE_FIELD from "@salesforce/schema/LoanApplicationAsset.CashOrMarketValue";

const COLUMNS = [
    {
        label: 'Name',
        fieldName: 'nameUrl',
        type: 'url',
        sortable: true,
        typeAttributes: {label: { fieldName: 'Name' }}
    },
    {
        label: "Asset Type",
        fieldName: ASSETTYPE_FIELD.fieldApiName,
        type: "liabilityTypePicklist",
        editable: true,
        wrapText: true,
        sortable: true,
        typeAttributes: {
            options: { fieldName : 'assetTypePickListOptions' },
            value : { fieldName : 'AssetType'},
            context: { fieldName : 'Id' }
        }
    },
    {
        label: "Cash or Market Value",
        fieldName: CASHORMARKETVALUE_FIELD.fieldApiName,
        type: 'currency',
        sortable: true,
        editable: true,
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
    loanApplicantAssetsRecords;
    @track draftValues = [];
    @track assetTypePicklistValues = [];
    @track sortBy;
    @track sortDirection;
    @track residentialLoanApplicationId;
    showSpinner = false;
    loanApplicantAssetsRefreshProp;
    sumOfTotalAssetValue = 0;

    @wire(getObjectInfo, { objectApiName: LOANAPPLICATIONASSET_OBJECT })
    loanApplicantAssetObjectMetadata;

    @wire(getPicklistValues, { recordTypeId: '$loanApplicantAssetObjectMetadata.data.defaultRecordTypeId', fieldApiName: ASSETTYPE_FIELD })
    getEmploymentPicklistValues({data, error}) {
        if (data) {
            this.assetTypePicklistValues = data.values;
        } else if(error){
            console.log("Error loading picklist values")
        }
    }

    @wire (getEmploymentRecords, {loanApplicationId: "$recordId", pickList: "$assetTypePicklistValues"} )
	getLiabilitiesOutput(result) {
		this.loanApplicantAssetsRefreshProp = result;
		if(result.data){
            let sumOfTotalAssetValuelocal = 0;
            let CADDollar = new Intl.NumberFormat('en-US', {
                style: 'currency',
                currency: 'USD',
            });
			this.loanApplicantAssetsRecords = result.data.map(currItem => {
                if(currItem.CashOrMarketValue !== undefined && currItem.CashOrMarketValue !== null ) {
                    sumOfTotalAssetValuelocal = sumOfTotalAssetValuelocal + currItem.CashOrMarketValue;
                }
				let assetTypePickListOptions = this.assetTypePicklistValues;
                
                let nameUrl = `/lightning/r/${currItem.Id}/edit`;
				return {
					...currItem, 
					assetTypePickListOptions : assetTypePickListOptions,
                    nameUrl
				};
			});
            this.sumOfTotalAssetValue = CADDollar.format(sumOfTotalAssetValuelocal);
            
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
        await refreshApex(this.loanApplicantAssetsRefreshProp);
        this.showSpinner = false;
        this.showToast('Success', 'Asset updated', 'success');
	}

    handleRowAction(event) {
		const row = event.detail.row;
		this.deleteRow(row);
				
	}

	async deleteRow(row) {
		try {
			    this.showSpinner = true;
				await deleteRecord(row.Id);
				await refreshApex(this.loanApplicantAssetsRefreshProp);
				this.showSpinner = false;
				this.showToast('Success', 'Asset deleted', 'success');
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
                    refreshApex(this.loanApplicantAssetsRefreshProp);
                    this.showToast('Success', 'Asset Created', 'success');
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
        let parseData = JSON.parse(JSON.stringify(this.loanApplicantAssetsRecords));
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
        this.loanApplicantAssetsRecords = parseData;
    }  
}
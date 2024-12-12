import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { updateRecord } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from "lightning/navigation";
import { reduceErrors } from 'c/idsUtils';

import ModalRecordEditForm from "c/amlFlagsNewRecordModal";
import getAMLRecords from "@salesforce/apex/RlaLWCsHelper.getRlaAmlFlagsRecords";
import AMLFLAG_OBJECT from "@salesforce/schema/AML_Flag__c";
import DESCRIPTION_FIELD from "@salesforce/schema/AML_Flag__c.Description__c";
import RESOLVED_FIELD from "@salesforce/schema/AML_Flag__c.Resolved__c";
import RESOLUTION_NOTES_FIELD from "@salesforce/schema/AML_Flag__c.Resolution_Notes__c";
import RESOLUTION_NOTES_CO_FIELD from "@salesforce/schema/AML_Flag__c.Resolution_Notes_CO__c";
import RESOLUTION_NOTES_MANAGER_FIELD from "@salesforce/schema/AML_Flag__c.Resolution_Notes_Manager__c";
import RESOLUTION_REQUIRED_BY_FIELD from "@salesforce/schema/AML_Flag__c.Resolution_Required_By__c";
import RISK_TYPE_FIELD from "@salesforce/schema/AML_Flag__c.Risk_Type__c";
import TYPE_FIELD from "@salesforce/schema/AML_Flag__c.Type__c";

const COLUMNS = [
    {
        label: 'Name',
        fieldName: 'nameUrl',
        type: 'url',
        sortable: true,
        initialWidth:65, 
        typeAttributes: {label: { fieldName: 'Name' }}
    },
    { 
        label: 'Risk', 
        fieldName:RISK_TYPE_FIELD.fieldApiName, 
        editable: false, 
        type: 'text',
        sortable: true,
        initialWidth:65, 
        cellAttributes: { 
                            alignment: 'left' 
                        }
    },
    {
        label: "Type",
        fieldName: TYPE_FIELD.fieldApiName,
        type: "liabilityTypePicklist",
        editable: true,
        wrapText: true,
        sortable: true,
        initialWidth:150, 
        typeAttributes: {
            options: { fieldName : 'typePickListOptions' },
            value : { fieldName : 'Type__c'},
            context: { fieldName : 'Id' }
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
        label: 'Resolved', 
        fieldName:RESOLVED_FIELD.fieldApiName, 
        editable: true, 
        type: 'boolean',
        sortable: true,
        initialWidth:65, 
        cellAttributes: { 
                            alignment: 'left' 
                        }
    },
    { 
        label: 'Resolution Required by', 
        fieldName:RESOLUTION_REQUIRED_BY_FIELD.fieldApiName, 
        editable: false, 
        type: 'text',
        sortable: true,
        wrapText: true, 
        cellAttributes: { 
                            alignment: 'left' 
                        }
    },
    {
        label: "Resolution Notes UW", 
        fieldName: RESOLUTION_NOTES_FIELD.fieldApiName, 
        editable: true,  
        type: "customTextArea",
        wrapText: true,
        cellAttributes: { 
                            alignment: 'left',  
                        }
    },
    {
        label: "Resolution Notes Manager", 
        fieldName: RESOLUTION_NOTES_MANAGER_FIELD.fieldApiName, 
        editable: true,  
        type: "customTextArea",
        wrapText: true,
        cellAttributes: { 
                            alignment: 'left',
                        }
    },
    {
        label: "Resolution Notes CO", 
        fieldName: RESOLUTION_NOTES_CO_FIELD.fieldApiName, 
        editable: true,  
        type: "customTextArea",
        wrapText: true,
        cellAttributes: { 
                            alignment: 'left', 
                        }
    },
    {
        label: 'Related Applicant',
        fieldName: 'relatedApplicantUrl',
        type: 'url',
        sortable: true,
        initialWidth:110, 
        typeAttributes: {label: { fieldName: 'Related_Applicant_Name__c' }}
    },
    {
        label: 'Related Property',
        fieldName: 'relatedPropertyUrl',
        type: 'url',
        sortable: true,
        initialWidth:110, 
        typeAttributes: {label: { fieldName: 'Related_Property_Name__c' }}
    }
];
export default class AmlFlags extends NavigationMixin(LightningElement) {
    @api recordId;
    columns = COLUMNS;
    amlFlagsRecords;
    @track draftValues = [];
    @track typePicklistValues = [];
    @track sortBy;
    @track sortDirection;
    @track residentialLoanApplicationId;
    showSpinner = false;
    amlFlagsRefreshProp;

    @wire(getObjectInfo, { objectApiName: AMLFLAG_OBJECT })
    amlFlagObjectMetadata;

    @wire(getPicklistValues, { recordTypeId: '$amlFlagObjectMetadata.data.defaultRecordTypeId', fieldApiName: TYPE_FIELD })
    getEmploymentPicklistValues({data, error}) {
        if (data) {
            this.typePicklistValues = data.values;
        } else if(error){
            console.log("Error loading picklist values")
        }
    }

    @wire (getAMLRecords, {loanApplicationId: "$recordId", pickList: "$typePicklistValues" } )
	getAmlFlagsOutput(result) {
		this.amlFlagsRefreshProp = result;
		if(result.data){
			this.amlFlagsRecords = result.data.map(currItem => {
				let typePickListOptions = this.typePicklistValues;
                let nameUrl = `/lightning/r/${currItem.Id}/edit`;
                let relatedApplicantUrl = '';
                if(currItem.Related_Applicant__c !== undefined && currItem.Related_Applicant__c !== null) {
                    relatedApplicantUrl = `/lightning/r/${currItem.Related_Applicant__c}/edit`;
                }
                
                let relatedPropertyUrl = ''; 
                if(currItem.Related_Property__c !== undefined && currItem.Related_Property__c !== null) {
                    relatedPropertyUrl = `/lightning/r/${currItem.Related_Property__c}/edit`;
                }
				return {
					...currItem, 
					typePickListOptions : typePickListOptions,
                    nameUrl,
                    relatedApplicantUrl,
                    relatedPropertyUrl
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
        await refreshApex(this.amlFlagsRefreshProp);
        this.showSpinner = false;
        this.showToast('Success', 'AML FLags updated', 'success');
	}

    handleRowAction(event) {
		const row = event.detail.row;
		this.deleteRow(row);
				
	}

	async deleteRow(row) {
		try {
			    this.showSpinner = true;
				await deleteRecord(row.Id);
				await refreshApex(this.amlFlagsRefreshProp);
				this.showSpinner = false;
				this.showToast('Success', 'AML Flag deleted', 'success');
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
                    refreshApex(this.amlFlagsRefreshProp);
                    this.showToast('Success', 'AML Flags Created', 'success');
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
        let parseData = JSON.parse(JSON.stringify(this.amlFlagsRecords));
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
        this.amlFlagsRecords = parseData;
    }  
}
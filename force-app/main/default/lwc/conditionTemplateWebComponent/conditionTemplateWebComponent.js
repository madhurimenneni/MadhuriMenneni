import { LightningElement, track, api, wire } from 'lwc';
import getParentCondition from '@salesforce/apex/ConditionTemplateController.getParentCondition';
import getChildCondition from '@salesforce/apex/ConditionTemplateController.getChildCondition';
import updateCondition from '@salesforce/apex/ConditionTemplateController.updateCondition';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import msgService from '@salesforce/messageChannel/RefreshLwc__c';
import { publish, MessageContext } from 'lightning/messageService';
export default class ConditionTemplateController extends LightningElement {
    @track tabContentId = '';
    @api recordId;
    @track tempResult = [];
    @track childConditions = [];
    @track description;
    @track selectedConditions = [];
    @track unSelectedConditions = [];

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        getParentCondition({ recId: this.recordId}).then(result => {
            console.log('23', result);
            var conts = result;
            for (var key in conts) {
                console.log('key', key);
                console.log('conts[key]', conts[key]);
                this.tempResult.push({ value: conts[key], key: key }); //Here we are creating the array to show on UI.
            }
            console.log('7845', this.tempResult);
        }).catch(error => {
            console.log(error);
            this.error = error;
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Error',
                variant: 'Error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        });
    }
    handleActive(event) {
        this.childConditions = [];
        this.tabContentId = event.target.value;
        console.log(this.tabContent);
        console.log('recid: ' + this.tabContentId);
        var conts = this.tempResult;
        getChildCondition({ recId: this.tabContentId }).then(result => {
            console.log('23', result);
            var conts = result;
            for (var key in conts) {
                this.childConditions.push({ value: conts[key], key: key });
            }
            console.log('7845', this.childConditions);
        }).catch(error => {
            console.log(error);
            this.error = error;
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Error',
                variant: 'Error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        });
    }
    handleSelect(event) {
        console.log('action', event.detail.name);
        this.description = event.detail.name;
        console.log('recId', this.recordId);
    }
    handleChange(event) {
        let checked = event.target.checked;
        let mtTabid = event.target.value;
        console.log('checked', event.target.checked);
        console.log('mtTabid', event.target.value);
        if (event.target.checked) {
            this.selectedConditions.push(event.target.value);
            console.log(this.unSelectedConditions.includes( event.target.value ));
            if ( this.unSelectedConditions.includes( event.target.value )) {
                const index = this.unSelectedConditions.indexOf(event.target.value);
                console.log(index);
                if (index > -1) { // only splice array when item is found
                    this.unSelectedConditions.splice(index, 1); // 2nd parameter means remove one item only
                }
            }
        }

        if ( !event.target.checked ) {
            this.unSelectedConditions.push( event.target.value );
            if ( this.selectedConditions.includes( event.target.value )) {
                const index = this.selectedConditions.indexOf(event.target.value);

                if (index > -1) { // only splice array when item is found
                    this.selectedConditions.splice(index, 1); // 2nd parameter means remove one item only
                }
            }
        }
    }

    handleClick(event) {
        console.log('selectedConditions', this.selectedConditions);
        console.log('unSelectedConditions', this.unSelectedConditions);
        console.log('recid1: ' + this.recordId);
        console.log('tabContentId: ' + this.tabContentId);
        updateCondition({ recId: this.recordId, selectedMdtIds: this.selectedConditions, unSelectedMdtIds: this.unSelectedConditions }).then(result => {
            if (result) {
                const event = new ShowToastEvent({
                    title: 'Success',
                    message: 'Successfully Updated',
                    variant: 'success',
                    mode: 'dismissable'
                });
                //added aura for displaying data
                // this.values = result;
                // alert('added values' + values);

                this.dispatchEvent(event);
                this.dispatchEvent(new CloseActionScreenEvent());
                //var url = window.location.origin + '/lightning/r/ResidentialLoanApplication/' + this.recordId + '/view';
                //window.open(url, "_top");
                let paramData = { result: this.childConditions };//JSON.parse({Name:this.Name, City:this.City});
                let ev = new CustomEvent('childmethod',
                    { detail: paramData }
                );
                this.dispatchEvent(ev);
                const payload = { recordId: this.recordId };
                publish(this.messageContext, msgService, payload);
            }



        }).catch(error => {
            console.log('error: '+error);
            this.error = error;
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Error',
                variant: 'Error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        });
        refreshApex(this.result);
    }

}
import { LightningElement, api } from 'lwc';

export default class DatatablePicklist extends LightningElement {

    @api label;
    @api placeholder;
    @api options;
    @api value;
    @api context;
    @api contextName;
    @api fieldName;

    handleChange(event) {

        //show the selected value on UI
        this.value = event.detail.value;
        let draftValue = {};
        draftValue[this.contextName] = typeof(this.context) == 'number' ? this.context.toString() : this.context;
        draftValue[this.fieldName] = this.value;
        let draftValues = [];
        draftValues.push(draftValue);
        //fire event to send context and selected value to the data table

        this.dispatchEvent(new CustomEvent('cellchange', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                draftValues: draftValues
            }
        }));
    }
}
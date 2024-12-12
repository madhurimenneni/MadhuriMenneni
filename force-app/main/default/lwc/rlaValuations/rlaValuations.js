import { LightningElement, wire, track, api } from 'lwc';
import getLoanApplicationProperties from '@salesforce/apex/RlaLWCsHelper.getRlaLoanApplicationPropertyRecords';

export default class RlaValuations extends LightningElement {
    @track loanApplicationProperties;  // Holds the loanApplicationProperties data
    @track error;     // To capture any errors
    @api recordId;

    // Fetch records using an Apex method
    @wire(getLoanApplicationProperties, { loanApplicationId: "$recordId" })
    wiredLoanApplicationProperties({ data, error }) {
        if (data) {
            this.loanApplicationProperties = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.loanApplicationProperties = undefined;
        }
    }

    get hasLoanApplicationProperties() {
        return this.loanApplicationProperties && this.loanApplicationProperties.length > 0;
    }
}
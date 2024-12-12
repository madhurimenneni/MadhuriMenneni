import { api, track } from "lwc";
import LightningModal from "lightning/modal";

export default class ModalRecordEditForm extends LightningModal {
	@api loanApplicationPropertyId;
	@track appraisedValueSelected = false;
	handleSuccess() {
		this.close('Success');
	}

	handleError(event) {
		this.close(JSON.stringify(event.detail.detail));
	}

	handleOnchangeOfValuationSource(event) {
		if (event.detail.value == 'Appraised Value') {
			this.appraisedValueSelected = true;
		} else {
			this.appraisedValueSelected = false;
		}
	}
}
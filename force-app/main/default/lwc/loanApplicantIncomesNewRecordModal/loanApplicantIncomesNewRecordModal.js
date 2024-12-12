import { api } from "lwc";
import LightningModal from "lightning/modal";

export default class ModalRecordEditForm extends LightningModal {
  @api loanApplicantId;
  @api loanApplicationId;

  handleSuccess(){
    this.close('Success');
  }
}
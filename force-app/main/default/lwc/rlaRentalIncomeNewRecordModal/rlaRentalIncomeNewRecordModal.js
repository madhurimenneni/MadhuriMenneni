import { api } from "lwc";
import LightningModal from "lightning/modal";

export default class ModalRecordEditForm extends LightningModal {
  @api rlaId;
  @api loanApplicationPropertyId;

  handleSuccess(){
    this.close('Success');
  }
}
import LightningDatatable from 'lightning/datatable';
import picklistTemplate from './picklistTemplate.html';
import richtextTemplate from './richtextTemplate.html';
import { loadStyle } from 'lightning/platformResourceLoader';
//import DataTableResource from '@salesforce/resourceUrl/CustomDataTable';

export default class ExtendedDatatable extends LightningDatatable {

    static customTypes = {
        picklist: {
            template: picklistTemplate,
            typeAttributes: ['options', 'label', 'value', 'placeholder', 'context', 'contextName', 'fieldName']
        },
        richtext: {
            template: richtextTemplate,
            typeAttributes: ['text']
        }
    };
    constructor() {
        super();
        Promise.all([
            loadStyle(this, DataTableResource),
        ]).then(() => {})
    } 
}
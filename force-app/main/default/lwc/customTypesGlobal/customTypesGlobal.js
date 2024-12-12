import LightningDataTable from 'lightning/datatable';
import customPicklist from './customPicklist.html';
import customPicklistEdit from './customPicklistEdit.html';
import customLookup from './customLookup.html';
import customRadio from './customRadio.html';
import customLookupEdit from './customLookupEdit.html';

export default class CustomTypesGlobal extends LightningDataTable {
    static customTypes = {
        liabilityTypePicklist : {
            template: customPicklist,
            editTemplate: customPicklistEdit,
            standardCellLayout : true,
            typeAttributes: [  'options','value','context']
        },
        customLookup : {
            template: customLookup,
            editTemplate: customLookupEdit,
            standardCellLayout : true,
            typeAttributes: [  'options','value','context']
        },
        customRadio : {
            template: customRadio,
            editTemplate: customLookupEdit,
            standardCellLayout : true,
            typeAttributes: [  'options','value','context']
        }
    }
}
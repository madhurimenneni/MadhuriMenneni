import LightningDatatable from 'lightning/datatable';
import picklistColumn from './picklistColumn.html';
import pickliststatic from './pickliststatic.html'
import textAreaStatic from './textAreaStatic.html'
import textAreaStaticEditable from './textAreaStaticEditable.html'
 
export default class LWCCustomDatatableType extends LightningDatatable {
    static customTypes = {
        picklistColumn: {
            template: pickliststatic,
            editTemplate: picklistColumn,
            standardCellLayout: true,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context', 'variant','name']
        },
        customTextArea : {
            template : textAreaStatic,
            editTemplate : textAreaStaticEditable,
            standardCellLayout : true,
        }
    };
}
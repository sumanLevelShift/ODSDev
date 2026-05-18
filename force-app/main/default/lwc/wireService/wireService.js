import { LightningElement, wire, api } from 'lwc';
import { getRecord }  from 'lightning/uiRecordApi'

const FIELDS = [
    'Contact.Name',
    'Contact.Phone',
];
export default class WireService extends LightningElement {

    @api recordId;
    

    @wire(getRecord,{recordId : '$recordId', fields : FIELDS})
    contact;

    get name() {
        
        //console.log('Contact - ' + this.contact);
        return this.contact.data.fields.Name.value;
    }
    
}
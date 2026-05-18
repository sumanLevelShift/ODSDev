import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'WorkOrder_Line_Item__c.RecordType.DeveloperName',
];
export default class EditWOLI extends LightningElement {
    @api workOrderLineItemId;
    @api isAura = false;
    @api isVFPage = false;
    @track selectedRecordType = '';
    @track showChildComponent = false;
    @wire(getRecord, { recordId: '$workOrderLineItemId', fields: FIELDS })
    wiredLineItem({ error, data }) {
        console.log('LWC RECORD ID 12' + this.workOrderLineItemId)
        if (data) {
            console.log('Line Item Data:', JSON.stringify(data));
            this.selectedRecordType = data.fields.RecordType.value.fields.DeveloperName.value;
            this.showChildComponent = true;
            console.log('this.selectedRecordType-' + this.selectedRecordType);
        } else if (error) {
            console.error('Error loading line item:', error);
            this.showToast('Error', 'Error loading work order line item data', 'error');
        }
    }
    get showLicenseComponent() {
        return this.selectedRecordType === 'License';
    }
    get showSlabRateComponent() {
        return this.selectedRecordType === 'Slab_Rate';
    }
    get showPointsComponent() {
        return this.selectedRecordType === 'Points';
    }
    get showKPOComponent() {
        return this.selectedRecordType === 'KPO';
    }
    get showFixedUnitPriceComponent() {
        return this.selectedRecordType === 'Fixed_Unit_Price';
    }
     get showStaffingComponent() {
        return this.selectedRecordType === 'Staffing';
    }
}
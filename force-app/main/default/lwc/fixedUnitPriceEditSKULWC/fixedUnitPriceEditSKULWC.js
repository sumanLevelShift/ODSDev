import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

const FIELDS = [
    'WorkOrder_Line_Item__c.Id',
    'WorkOrder_Line_Item__c.Description__c',
    'WorkOrder_Line_Item__c.Quantity__c',
    'WorkOrder_Line_Item__c.Rate__c',
    'WorkOrder_Line_Item__c.WorkOrder__r.Project_Start_Date__c',
    'WorkOrder_Line_Item__c.WorkOrder__r.Project_End_Date__c',
    'WorkOrder_Line_Item__c.WorkOrder__r.BC_Work_Order_ID__c',
    'WorkOrder_Line_Item__c.WorkOrder__c',
    'WorkOrder_Line_Item__c.Unit_of_Measure__c',
];

export default class FixedUnitPriceEditSKULWC extends NavigationMixin(LightningElement) {
    @api workOrderLineItemId;
    @track lineItemData = {};

    @track isLoading = false;
    @api isAura = false;
    @api isVFPage = false;

    // Wire method to get the work order line item record
    @wire(getRecord, { recordId: '$workOrderLineItemId', fields: FIELDS })
    wiredLineItem({ error, data }) {
        console.log('LWC RECORD ID 12' + this.workOrderLineItemId)
        if (data) {
            console.log('Line Item Data:', data);
            this.lineItemData = {
                id: data.fields.Id.value,
                description: data.fields.Description__c.value || '',
                quantity: data.fields.Quantity__c.value || 0,
                rate: data.fields.Rate__c.value || 0,
                workOrderId: data.fields.WorkOrder__c.value,
                projectStartDate: data.fields.WorkOrder__r.value?.fields?.Project_Start_Date__c?.value || null,
                projectEndDate: data.fields.WorkOrder__r.value?.fields?.Project_End_Date__c?.value || null,
                bcWorkOrderId: data.fields.WorkOrder__r.value?.fields?.BC_Work_Order_ID__c?.value || null,
                uOM: data.fields.Unit_of_Measure__c.value,
            };


        } else if (error) {
            console.error('Error loading line item:', error);
            this.showToast('Error', 'Error loading work order line item data', 'error');
        }
    }
    handleQuantityChange(event) {
        this.lineItemData.quantity = parseFloat(event.target.value) || 0;
    }

    handleRateChange(event) {
        this.lineItemData.rate = parseFloat(event.target.value) || 0;
    }

    // Handle save
    handleSave() {
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

        if (!allValid) {
            this.showToast('Error', 'Please fill in all required fields', 'error');
            return;
        }

        if (this.lineItemData.quantity <= 0 || this.lineItemData.rate <= 0) {
            this.showToast('Error', 'Quantity and Rate must be greater than zero', 'error');
        }
        this.isLoading = true;

        const fields = {
            Id: this.workOrderLineItemId,
            Quantity__c: this.lineItemData.quantity,
            Rate__c: this.lineItemData.rate
        };

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.showToast('Success', 'Work Order Line Item updated successfully', 'success');
                if (this.isVFPage) {
                    window.history.back();
                } else {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.workOrderLineItemId,
                            actionName: 'view'
                        }
                    });
                }

            })
            .catch(error => {
                console.error('Error updating record:', error);
                this.showToast('Error', error.body?.message || 'Error updating record', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleCancel() {
        window.history.back();
    }

    formatDate(date) {
        return date.toLocaleDateString();
    }

    get formattedRate() {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD'
        }).format(this.lineItemData.rate || 0);
    }

    get formattedTaxRate() {
        return `${this.lineItemData.taxRate || 0}%`;
    }

    // Show toast message
    showToast(title, message, variant) {
        if (this.isVFPage) {
            alert(message)
        } else {
            const event = new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            });
            this.dispatchEvent(event);
        }

    }
}
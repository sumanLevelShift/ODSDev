// editWorkOrderLineItem.js
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
//import updateLineItem from '@salesforce/apex/BC_WorkOrderLineItemLWCController.updateLineItem';

// Define fields to fetch
const FIELDS = [
    'WorkOrder_Line_Item__c.Id',
    'WorkOrder_Line_Item__c.Deactivation_Date__c',
    'WorkOrder_Line_Item__c.Description__c',
    'WorkOrder_Line_Item__c.Quantity__c',
    'WorkOrder_Line_Item__c.Rate__c',
    'WorkOrder_Line_Item__c.Tax_Rate__c',
    'WorkOrder_Line_Item__c.WorkOrder__r.Project_Start_Date__c',
    'WorkOrder_Line_Item__c.WorkOrder__r.Project_End_Date__c',
    'WorkOrder_Line_Item__c.WorkOrder__r.BC_Work_Order_ID__c',
    'WorkOrder_Line_Item__c.WorkOrder__c'
];

export default class EditSKULWC extends NavigationMixin(LightningElement) {
    @api workOrderLineItemId;
    @track lineItemData = {};
    @track deactivationDate = null;
    @track isDeactivationDateEditable = false;
    @track isSaveButtonEnabled = false;
    @track isLoading = false;
    @api isAura = false;
    @api isVFPage = false;
    @track isSaveButtonDisabled = true;
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
                taxRate: data.fields.Tax_Rate__c.value || 0,
                deactivationDate: data.fields.Deactivation_Date__c.value || null,
                workOrderId: data.fields.WorkOrder__c.value,
                projectStartDate: data.fields.WorkOrder__r.value?.fields?.Project_Start_Date__c?.value || null,
                projectEndDate: data.fields.WorkOrder__r.value?.fields?.Project_End_Date__c?.value || null,
                bcWorkOrderId: data.fields.WorkOrder__r.value?.fields?.BC_Work_Order_ID__c?.value || null
            };

            this.deactivationDate = this.lineItemData.deactivationDate;

            // Set editability and save button state based on BC_Work_Order_ID__c
            this.isDeactivationDateEditable = this.lineItemData.bcWorkOrderId ? true : false;
            this.isSaveButtonEnabled = this.lineItemData.bcWorkOrderId ? true : false;
            this.isSaveButtonDisabled = this.lineItemData.bcWorkOrderId ? false : true;
        } else if (error) {
            console.error('Error loading line item:', error);
            this.showToast('Error', 'Error loading work order line item data', 'error');
        }
    }

    // Handle deactivation date change
    handleDeactivationDateChange(event) {
        this.deactivationDate = event.target.value;
    }

    // Validate deactivation date
    validateDeactivationDate() {
        if (!this.deactivationDate) {
            return { isValid: false, message: 'Deactivation Date is required' };
        }

        const deactivationDate = new Date(this.deactivationDate);
        const startDate = this.lineItemData.projectStartDate ? new Date(this.lineItemData.projectStartDate) : null;
        const endDate = this.lineItemData.projectEndDate ? new Date(this.lineItemData.projectEndDate) : null;

        if (startDate && deactivationDate < startDate) {
            return {
                isValid: false,
                message: `Deactivation Date must be on or after the Project Start Date (${this.formatDate(startDate)})`
            };
        }

        if (endDate && deactivationDate > endDate) {
            return {
                isValid: false,
                message: `Deactivation Date must be on or before the Project End Date (${this.formatDate(endDate)})`
            };
        }

        return { isValid: true, message: '' };
    }

    // Handle save
    handleSave() {
        // Validate deactivation date
        const validation = this.validateDeactivationDate();
        if (!validation.isValid) {
            this.showToast('Validation Error', validation.message, 'error');
            return;
        }

        this.isLoading = true;
        /*  updateLineItem({
              lineItemId: this.recordId,
              deactivationDate: this.deactivationDate
          })
              .then(result => {
                  this.showToast('Success', 'Work Order Line Item updated successfully', 'success');
  
              })
              .catch(error => {
                  var errorMessageFlow = error.body?.message || error.message || 'Error creating records';
                  //alert(errorMessageFlow)
                  this.showToast('Error', errorMessageFlow, 'error');
                  console.error('Error creating records:', error);
              }).finally(() => {
                  this.isLoading = false;
              });*/

        const fields = {
            Id: this.workOrderLineItemId,
            Deactivation_Date__c: this.deactivationDate
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

    // Format currency for display
    get formattedRate() {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD'
        }).format(this.lineItemData.rate || 0);
    }

    // Format tax rate for display
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
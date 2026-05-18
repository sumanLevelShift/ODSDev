import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createWorkOrderLineItems from '@salesforce/apex/BC_WorkOrderLineItemLWCController.createWorkOrderLineItems';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { NavigationMixin } from "lightning/navigation";
import getWorkOrder from '@salesforce/apex/BC_WorkOrderLineItemLWCController.getWorkOrder';
import getUnitOfMeasure from '@salesforce/apex/BC_WorkOrderLineItemLWCController.getUnitOfMeasure';

export default class AddSKULWC extends NavigationMixin(LightningElement) {
    @api workOrderId = '';
    @api unitOfMeasure = '';
    @api skuResult = false;
    @api errorMessageFlow = '';
    @track skuRows = [];
    @track nextRowId = 1;
    @api isAura = false;
    @api isVFPage = false;
    @track showSuccessMessage = false;
    @track workOrderData = null;
    @track showEffectiveDateColumn = false;
    @track currentDatetime = new Date();
    @api selectedRecordType;
    @api unitOfMeasureBasedOnSelectedRecordType='';
    @wire(getWorkOrder, { recordId: '$workOrderId', currentDatetime: '$currentDatetime' })
    wiredWorkOrder({ error, data }) {
        if (data) {
            this.workOrderData = data;
            this.showEffectiveDateColumn = data && data.BC_Work_Order_ID__c ? true : false;

        } else if (error) {
            console.error('Error loading work order:', error);
            alert(error)
            //this.showToast('Error', 'Error loading work order data', 'error');
        }
    }
    @wire(getUnitOfMeasure, { selectedRecordType: '$selectedRecordType', currentDatetime: '$currentDatetime' })
    wiredUOM({ error, data }) {
        if (data) {
            this.unitOfMeasureBasedOnSelectedRecordType = data;

        } else if (error) {
            console.error('Error loading work order:', error);
            alert(error)
        }
    }
    @api
    get selectedSKUData() {
        return this.skuRows.map(row => ({
            itemId: row.selectedItem ? row.selectedItem.Id : null,
            description: row.selectedItem ? row.selectedItem.Description__c : null,
            uOM: row.selectedItem ? row.selectedItem.Unit_of_Measure__c : null,
            rate: row.rate,
            quantity: row.quantity,
            taxRate: row.Tax_Rate__c,
            effectiveDate: row.effectiveDate
        }));
    }

    connectedCallback() {
        // Initialize with one row
        this.addNewRow();
    }

    // Add new row
    handleAddRow() {
        this.addNewRow();
    }

    addNewRow() {
        const newRow = {
            id: this.nextRowId++,
            selectedItem: null,
            rate: 0.00,
            quantity: 1,
            isValid: false,
            taxRate: 0,
            effectiveDate: null
        };
        this.skuRows = [...this.skuRows, newRow];
    }

    // Remove row
    handleRemoveRow(event) {
        if (this.skuRows.length <= 1) {
            this.showToast('Warning', 'At least one row is required', 'warning');
            return;
        }

        const rowId = parseInt(event.target.dataset.rowId);
        this.skuRows = this.skuRows.filter(row => row.id !== rowId);
        this.dispatchUpdateEvent();
    }

    // Handle lookup selection
    handleLookupUpdate(event) {
        const rowId = parseInt(event.target.dataset.rowId);
        const selectedRecord = event.detail.selectedRecord;
        console.log('selectedRecord-' + JSON.stringify(selectedRecord))
        this.skuRows = this.skuRows.map(row => {
            if (row.id === rowId) {
                return {
                    ...row,
                    selectedItem: selectedRecord,
                    isValid: selectedRecord ? true : false,
                    taxRate: selectedRecord ? selectedRecord.Tax_Rate__c : 0,
                };
            }
            return row;
        });
        console.log('this.selectedSKUData--' + JSON.stringify(this.selectedSKUData))
        //this.dispatchUpdateEvent();
    }

    // Handle rate change
    handleRateChange(event) {
        const rowId = parseInt(event.target.dataset.rowId);
        const rate = parseFloat(event.target.value) || 0;

        this.skuRows = this.skuRows.map(row => {
            if (row.id === rowId) {
                return {
                    ...row,
                    rate: rate,
                };
            }
            return row;
        });

        this.dispatchUpdateEvent();
    }

    // Handle quantity change
    handleQuantityChange(event) {
        const rowId = parseInt(event.target.dataset.rowId);
        const quantity = parseInt(event.target.value) || 1;

        this.skuRows = this.skuRows.map(row => {
            if (row.id === rowId) {
                return {
                    ...row,
                    quantity: quantity,
                };
            }
            return row;
        });

        //this.dispatchUpdateEvent();
    }
    handleEffectiveDateChange(event) {
        const rowId = parseInt(event.target.dataset.rowId);
        const effectiveDate = event.target.value;

        this.skuRows = this.skuRows.map(row => {
            if (row.id === rowId) {
                return {
                    ...row,
                    effectiveDate: effectiveDate,
                };
            }
            return row;
        });

        //this.dispatchUpdateEvent();
    }
    handleSave() {
        if (!this.validateRows()) {
            return;
        }
        if (this.workOrderId == '') {
            alert('Work Order ID is Not Available.'); return;
        }
        // Prepare data for Apex call
        const lineItems = this.skuRows
            .filter(row => row.selectedItem) // Only rows with selected items
            .map(row => ({
                itemMasterId: row.selectedItem.Id,
                rate: row.rate,
                quantity: row.quantity,
                description: row.selectedItem.Description__c || '',
                unitOfMeasure: row.selectedItem.Unit_of_Measure__c || '',
                taxRate: row.selectedItem.Tax_Rate__c || 0,
                effectiveDate: row.effectiveDate
            }));

        createWorkOrderLineItems({
            lineItems: lineItems,
            workOrderId: this.workOrderId,
            selectedRecordType: this.selectedRecordType
        })
            .then(result => {
                this.showToast('Success', 'Work Order Line Items created successfully', 'success');
                // Reset the form
                this.skuRows = [];
                this.addNewRow();
                //this.dispatchUpdateEvent();
                this.showSuccessMessage = true;
                this.sendToFlow(true);
                if (this.isVFPage == true) {
                    this.handleCancel();
                }
                else if (this.isAura == true) {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.workOrderId,
                            actionName: 'view'
                        }
                    });
                    setTimeout(() => {
                        window.location.reload();
                    }, 500);
                }
                // this.notifyParent('success', 'Records successfully created');
            })
            .catch(error => {
                this.sendToFlow(false);
                this.errorMessageFlow = error.body?.message || error.message || 'Error creating records';
                this.dispatchEvent(new FlowAttributeChangeEvent('errorMessageFlow', 'Error :' + this.errorMessageFlow));
                alert(this.errorMessageFlow)
                // this.showToast('Error', errorMessageFlow, 'error');
                //this.notifyParent('error', this.errorMessageFlow);
                console.error('Error creating records:', error);
            })
    }

    // Validate all rows
    @api
    validateRows() {
        let isValid = true;
        let errorMessage = '';

        for (let i = 0; i < this.skuRows.length; i++) {
            const row = this.skuRows[i];
            if (!row.selectedItem) {
                isValid = false;
                errorMessage = `Please select an item for row ${i + 1}`;
                break;
            }
            if (row.rate <= 0) {
                isValid = false;
                errorMessage = `Please enter a valid rate for row ${i + 1}`;
                break;
            }
            if (row.quantity <= 0) {
                isValid = false;
                errorMessage = `Please enter a valid quantity for row ${i + 1}`;
                break;
            }
            if (this.showEffectiveDateColumn) {
                if (!row.effectiveDate) {
                    isValid = false;
                    errorMessage = `Effective Date is required for row ${i + 1}`;
                    break;
                }

                // Validate effective date is between project start and end dates
                if (this.workOrderData) {
                    const effectiveDate = new Date(row.effectiveDate);
                    const startDate = this.workOrderData.Project_Start_Date__c ? new Date(this.workOrderData.Project_Start_Date__c) : null;
                    const endDate = this.workOrderData.Project_End_Date__c ? new Date(this.workOrderData.Project_End_Date__c) : null;

                    if (startDate && effectiveDate < startDate) {
                        isValid = false;
                        errorMessage = `Effective Date for row ${i + 1} must be on or after the Project Start Date (${this.formatDate(startDate)})`;
                        break;
                    }

                    if (endDate && effectiveDate > endDate) {
                        isValid = false;
                        errorMessage = `Effective Date for row ${i + 1} must be on or before the Project End Date (${this.formatDate(endDate)})`;
                        break;
                    }
                }
            }
        }

        if (!isValid) {
            alert(errorMessage);
            // this.notifyParent('error', errorMessage);
            //this.dispatchEvent(new FlowAttributeChangeEvent('errorMessageFlow', 'Error :' + errorMessage));
            //  this.showToast('Validation Error', errorMessage, 'error');
        }

        return isValid;
    }

    // Dispatch update event to Flow
    dispatchUpdateEvent() {
        const updateEvent = new CustomEvent('skuupdate', {
            detail: {
                skuData: this.selectedSKUData,
            }
        });
        this.dispatchEvent(updateEvent);
    }
    notifyParent(type, message) {
        const resultEvent = new CustomEvent('skuresultchange', {
            detail: {
                type: type,
                message: message,
                timestamp: new Date().toISOString()
            },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(resultEvent);
    }
    // Show toast message
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
    sendToFlow(skuResult) {
        this.dispatchEvent(new FlowAttributeChangeEvent('skuResult', skuResult));
    }
    handleCancel() {
        window.history.back();
    }
    formatDate(date) {
        return date.toLocaleDateString();
    }
    handleBackToParent() {
        const backEvent = new CustomEvent('backtoparent', {
            detail: { action: 'back' },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(backEvent);
    }
}
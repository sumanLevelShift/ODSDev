import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createKPOWorkOrderLineItems from '@salesforce/apex/BC_WorkOrderLineItemLWCController.createKPOWorkOrderLineItems';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { NavigationMixin } from "lightning/navigation";
import getWorkOrder from '@salesforce/apex/BC_WorkOrderLineItemLWCController.getWorkOrder';
import getUnitOfMeasure from '@salesforce/apex/BC_WorkOrderLineItemLWCController.getUnitOfMeasure';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import WORKORDER_LINEITEM_OBJECT from '@salesforce/schema/WorkOrder_Line_Item__c';

export default class KPOConsumptionAddSKULWC extends NavigationMixin(LightningElement) {
    @api workOrderId = '';
    @track unitOfMeasure = '';
    @api skuResult = false;
    @api errorMessageFlow = '';
    @track skuRows = [];
    @track nextRowId = 1;
    @api isAura = false;
    @api isVFPage = false;
    @track showSuccessMessage = false;
    @track workOrderData = null;
    @track currentDatetime = new Date();
    @api selectedRecordType;

    kPOPicklistOptions = [];
    recordTypeId;

    // Get object info to retrieve the KPO record type ID
    @wire(getObjectInfo, { objectApiName: WORKORDER_LINEITEM_OBJECT })
    objectInfo({ data, error }) {
        if (data) {
            const recordTypes = data.recordTypeInfos;
            this.recordTypeId = Object.keys(recordTypes).find(
                rtId => recordTypes[rtId].name === 'KPO'
            );
        }
        if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    // Get all picklist values for the record type
    @wire(getPicklistValuesByRecordType, {
        objectApiName: WORKORDER_LINEITEM_OBJECT,
        recordTypeId: '$recordTypeId'
    })
    picklistsByRecordType({ data, error }) {
        if (data) {
            const unitOfMeasurePicklist =
                data.picklistFieldValues.Unit_of_Measure__c;

            if (unitOfMeasurePicklist) {
                this.kPOPicklistOptions = [
                    { label: '-- None --', value: '' },
                    ...unitOfMeasurePicklist.values.map(item => ({
                        label: item.label,
                        value: item.value
                    }))
                ];
                console.log('kPOPicklistOptions Options:', this.kPOPicklistOptions);
            }
        }
        if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }

    @wire(getWorkOrder, { recordId: '$workOrderId', currentDatetime: '$currentDatetime' })
    wiredWorkOrder({ error, data }) {
        if (data) {
            this.workOrderData = data;

        } else if (error) {
            console.error('Error loading work order:', error);
            alert(error)
            //this.showToast('Error', 'Error loading work order data', 'error');
        }
    }
    @wire(getUnitOfMeasure, { selectedRecordType: '$selectedRecordType', currentDatetime: '$currentDatetime' })
    wiredUOM({ error, data }) {
        if (data) {
            this.unitOfMeasure = data;
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
            uOM: row.kpoUOM,
            rate: row.rate,
            quantity: row.quantity,
            description2: row.description2,
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
            description2: null,
            kpoUOM: ''
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
    handleDescription2Change(event) {
        const rowId = parseInt(event.target.dataset.rowId);
        const description2Value = event.target.value;

        this.skuRows = this.skuRows.map(row => {
            if (row.id === rowId) {
                return {
                    ...row,
                    description2: description2Value
                };
            }
            return row;
        });
    }

    handleUOMChange(event) {
        const rowId = parseInt(event.target.dataset.rowId);
        const kpoUOMValue = event.detail.value;

        this.skuRows = this.skuRows.map(row => {
            if (row.id === rowId) {
                return {
                    ...row,
                    kpoUOM: kpoUOMValue
                };
            }
            return row;
        });
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
                unitOfMeasure: row.kpoUOM || '',
                description2: row.description2,
            }));

        createKPOWorkOrderLineItems({
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
                errorMessage = `Please select an Description for row ${i + 1}`;
                break;
            }
            if (row.description2 && row.description2.length > 50) {
                isValid = false;
                errorMessage = `Description 2 for row ${i + 1} cannot exceed 50 characters`;
                break;
            }
            if (!row.kpoUOM || row.kpoUOM === '') {
                isValid = false;
                errorMessage = `Please select Unit of Measure for row ${i + 1}`;
                break;
            }
            if (!row.quantity || row.quantity <= 0) {
                isValid = false;
                errorMessage = `Please enter a valid quantity (greater than 0) for row ${i + 1}`;
                break;
            }

            if (row.rate === null || row.rate === undefined || row.rate <= 0) {
                isValid = false;
                errorMessage = `Please enter a valid rate (greater than 0) for row ${i + 1}`;
                break;
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
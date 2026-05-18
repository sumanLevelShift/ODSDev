import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createFPUWorkOrderLineItems from '@salesforce/apex/BC_WorkOrderLineItemLWCController.createFPUWorkOrderLineItems';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { NavigationMixin } from "lightning/navigation";
import getWorkOrder from '@salesforce/apex/BC_WorkOrderLineItemLWCController.getWorkOrder';
import getUnitOfMeasure from '@salesforce/apex/BC_WorkOrderLineItemLWCController.getUnitOfMeasure';
import getExistingFPULineItems from '@salesforce/apex/BC_WorkOrderLineItemLWCController.getExistingFPULineItems';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import WORKORDER_LINEITEM_OBJECT from '@salesforce/schema/WorkOrder_Line_Item__c';

export default class FixedUnitPriceAddSKULWC extends NavigationMixin(LightningElement) {
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
    originalUOMPicklistOptions = [];
    recordTypeId;
    DX_CATEGORIES = [
        'DX -Fixed Unit Price',
        'DX -Fixed Unit Price-CO'
    ];
    @track existingMonthsRecord = false;
    @track existingHoursRecord = false;

    @wire(getObjectInfo, { objectApiName: WORKORDER_LINEITEM_OBJECT })
    objectInfo({ data, error }) {
        if (data) {
            const recordTypes = data.recordTypeInfos;
            this.recordTypeId = Object.keys(recordTypes).find(
                rtId => recordTypes[rtId].name === 'Fixed Unit Price'
            );
        }
        if (error) {
            console.error('Error fetching object info:', error);
        }
    }
    @wire(getPicklistValuesByRecordType, {
        objectApiName: WORKORDER_LINEITEM_OBJECT,
        recordTypeId: '$recordTypeId'
    })
    picklistsByRecordType({ data, error }) {
        if (data) {
            const unitOfMeasurePicklist =
                data.picklistFieldValues.Unit_of_Measure__c;

            if (unitOfMeasurePicklist) {
                this.originalUOMPicklistOptions = [
                    { label: '-- None --', value: '' },
                    ...unitOfMeasurePicklist.values.map(item => ({
                        label: item.label,
                        value: item.value
                    }))
                ];
                console.log('originalUOMPicklistOptions Options:', this.originalUOMPicklistOptions);
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
    get uOMPicklistOptions() {
        if (!this.originalUOMPicklistOptions || this.originalUOMPicklistOptions.length === 0) {
            return [];
        }

        const subCategory = this.workOrderData?.SubCategory__c;

        const excludedCategories = [
            'Enterprise Integration -Fixed Unit Price',
            'Enterprise Integration -Fixed Unit Price-CO'
        ];

        // If SubCategory matches excluded categories, remove HOURS
        if (subCategory && excludedCategories.includes(subCategory)) {
            return this.originalUOMPicklistOptions.filter(
                option => option.value.toUpperCase() !== 'HOURS'
            );
        }

        return this.originalUOMPicklistOptions;
    }
    @wire(getExistingFPULineItems, { workOrderId: '$workOrderId', selectedRecordType: '$selectedRecordType', currentDatetime: '$currentDatetime' })
    wiredExistingDXLineItems({ error, data }) {
        if (data) {
            this.existingMonthsRecord = data.hasMonths;
            this.existingHoursRecord = data.hasHours;
            console.log('Existing MONTH record:', this.existingMonthsRecord);
            console.log('Existing HOURS record:', this.existingHoursRecord);
        } else if (error) {
            console.error('Error checking existing DX records:', error);
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
            fpuUOM: row.fpuUOM,
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
        const subCategory = this.workOrderData?.SubCategory__c;

        if (this.DX_CATEGORIES.includes(subCategory)) {
            if (this.existingMonthsRecord && this.existingHoursRecord) {
                alert('Both MONTH and HOURS records already exist. No additional rows can be added.');
                return;
            }

            if (this.existingMonthsRecord || this.existingHoursRecord) {
                if (this.skuRows.length >= 1) {
                    alert('Only 1 row allowed to add the missing record (MONTH or HOURS).');
                    return;
                }
            } else {
                if (this.skuRows.length >= 2) {
                    alert('Maximum 2 rows allowed for DX Fixed Unit Price.');
                    return;
                }
            }
        }
        const newRow = {
            id: this.nextRowId++,
            selectedItem: null,
            rate: 0.00,
            quantity: 1,
            isValid: false,
            fpuUOM: ''
        };
        this.skuRows = [...this.skuRows, newRow];
    }
    handleUOMChange(event) {
        const rowId = parseInt(event.target.dataset.rowId);
        const UOMValue = event.detail.value;

        this.skuRows = this.skuRows.map(row => {
            if (row.id === rowId) {
                return {
                    ...row,
                    fpuUOM: UOMValue
                };
            }
            return row;
        });
    }
    @track globalSelectedItem = '';
    handleGlobalLookupUpdate(event) {
        const selectedRecord = event.detail.selectedRecord;
        this.globalSelectedItem = selectedRecord;
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
    handleRemoveRow(event) {
        if (this.skuRows.length <= 1) {
            this.showToast('Warning', 'At least one row is required', 'warning');
            return;
        }

        const rowId = parseInt(event.target.dataset.rowId);
        this.skuRows = this.skuRows.filter(row => row.id !== rowId);
        this.dispatchUpdateEvent();
    }
    handleSave() {
        if (!this.validateRows()) {
            return;
        }
       /* if (!this.validateDXSubcategory()) {
            return;
        }
        if (!this.validateExistingDXRecords()) {
            return;
        }*/
        if (this.workOrderId == '') {
            alert('Work Order ID is Not Available.'); return;
        }
        if (!this.globalSelectedItem) {
            alert('Please select an Service Name.');
            return;
        }
        console.log('skuRows--' + JSON.stringify(this.skuRows))
        console.log('this.globalSelectedItem-' + JSON.stringify(this.globalSelectedItem));
        // Prepare data for Apex call
        const lineItems = this.skuRows
            .map(row => ({
                itemMasterId: this.globalSelectedItem.Id,
                rate: row.rate,
                quantity: row.quantity,
                description: this.globalSelectedItem.Description__c || '',
                unitOfMeasure: row.fpuUOM || '',
            }));
        console.log('lineItems-' + JSON.stringify(lineItems))
        createFPUWorkOrderLineItems({
            lineItems: lineItems,
            workOrderId: this.workOrderId,
            selectedRecordType: this.selectedRecordType
        })
            .then(result => {
                this.showToast('Success', 'Work Order Line Items created successfully', 'success');
                // Reset the form
                this.skuRows = [];
                this.addNewRow();
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
                console.error('Error creating records:', error);
            })
    }
    validateExistingDXRecords() {
        const subCategory = this.workOrderData?.SubCategory__c;

        if (!this.DX_CATEGORIES.includes(subCategory)) {
            return true;
        }

        if (this.existingMonthsRecord && this.existingHoursRecord) {
            alert('Both MONTH and HOURS records already exist for this DX Fixed Unit Price Work Order. Cannot create duplicate records.');
            return false;
        }

        const uomValues = this.skuRows.map(row => row.fpuUOM?.toUpperCase()).filter(Boolean);
        const hasMonth = uomValues.includes('MONTH') || uomValues.includes('MONTHS');
        const hasHours = uomValues.includes('HOURS') || uomValues.includes('HOUR');

        if (this.existingMonthsRecord && hasMonth) {
            alert('A MONTH record already exists for this DX Fixed Unit Price Work Order. Cannot create duplicate MONTH record.');
            return false;
        }

        if (this.existingHoursRecord && hasHours) {
            alert('An HOURS record already exists for this DX Fixed Unit Price Work Order. Cannot create duplicate HOURS record.');
            return false;
        }

        return true;
    }
    // Validate all rows
    @api
    validateRows() {
        let isValid = true;
        let errorMessage = '';

        for (let i = 0; i < this.skuRows.length; i++) {
            const row = this.skuRows[i];
            /* if (!row.selectedItem) {
                 isValid = false;
                 errorMessage = `Please select an Description for row ${i + 1}`;
                 break;
             }*/
            if (!row.quantity || row.quantity <= 0) {
                isValid = false;
                errorMessage = `Please enter a valid quantity (greater than 0) for row ${i + 1}`;
                break;
            }
            if (!row.fpuUOM || row.fpuUOM === '') {
                isValid = false;
                errorMessage = `Please select Unit of Measure for row ${i + 1}`;
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
    validateDXSubcategory() {
        const subCategory = this.workOrderData?.SubCategory__c;

        if (!this.DX_CATEGORIES.includes(subCategory)) {
            return true;
        }

        // Get current UOM values from rows
        const uomValues = this.skuRows.map(row => row.fpuUOM?.toUpperCase()).filter(Boolean);
        const hasMonth = uomValues.includes('MONTH') || uomValues.includes('MONTHS');
        const hasHours = uomValues.includes('HOURS') || uomValues.includes('HOUR');

        // Case 1: Both MONTH and HOURS already exist - user should not be here
        if (this.existingMonthsRecord && this.existingHoursRecord) {
            alert('Both MONTH and HOURS records already exist for this DX Fixed Unit Price Work Order.');
            return false;
        }

        // Case 2: MONTH exists, only HOURS is missing
        if (this.existingMonthsRecord && !this.existingHoursRecord) {
            // User should only add 1 row with HOURS
            if (this.skuRows.length !== 1) {
                alert('Only 1 row is required to add the missing HOURS record.');
                return false;
            }
            if (!hasHours) {
                alert('Please select HOURS as Unit of Measure to complete the DX Fixed Unit Price records.');
                return false;
            }
            if (hasMonth) {
                alert('MONTH record already exists. Please select only HOURS as Unit of Measure.');
                return false;
            }
            return true;
        }

        // Case 3: HOURS exists, only MONTH is missing
        if (this.existingHoursRecord && !this.existingMonthsRecord) {
            // User should only add 1 row with MONTH
            if (this.skuRows.length !== 1) {
                alert('Only 1 row is required to add the missing MONTH record.');
                return false;
            }
            if (!hasMonth) {
                alert('Please select MONTH as Unit of Measure to complete the DX Fixed Unit Price records.');
                return false;
            }
            if (hasHours) {
                alert('HOURS record already exists. Please select only MONTH as Unit of Measure.');
                return false;
            }
            return true;
        }

        // Case 4: Neither exists - user must add both MONTH and HOURS (initial creation)
        if (!this.existingMonthsRecord && !this.existingHoursRecord) {
            if (this.skuRows.length !== 2) {
                alert('For DX Fixed Unit Price, exactly 2 rows are required (one with MONTH and one with HOURS)');
                return false;
            }

            if (!hasMonth || !hasHours) {
                alert('For DX Fixed Unit Price, one row must have Unit of Measure as MONTH and another row must have HOURS');
                return false;
            }

            const monthCount = uomValues.filter(uom => uom === 'MONTH' || uom === 'MONTHS').length;
            const hoursCount = uomValues.filter(uom => uom === 'HOURS' || uom === 'HOUR').length;

            if (monthCount > 1 || hoursCount > 1) {
                alert('Each Unit of Measure (MONTH and HOURS) should be used only once');
                return false;
            }
        }

        return true;
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
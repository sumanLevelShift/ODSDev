// homeWOLI.js
import { LightningElement, api, track, wire } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecordTypes from '@salesforce/apex/BC_WorkOrderLineItemLWCController.getRecordTypes';
import getRecordTypeName from '@salesforce/apex/BC_WorkOrderLineItemLWCController.getRecordTypeName';


export default class HomeWOLI extends LightningElement {

    @api workOrderId = '';
    @api unitOfMeasure = '';

    @api skuResult = false;
    @api errorMessageFlow = '';
    @api selectedRecordTypeValue = '';

    @track selectedRecordType = '';
    @track showChildComponent = false;
    @track childSkuResult = false;
    @track childErrorMessage = '';
    @api isAura = false;
    @api isVFPage = false;
    @track hideBackButton = false;
    @track recordTypeOptions = [];
    @track currentDatetime = new Date();
    @track title = 'Add Work Order Line Items';

    @wire(getRecordTypes, { workOrderId: '$workOrderId' })
    wiredRecordTypes({ data, error }) {
        if (data) {
            this.recordTypeOptions = data;
            console.log('Record Type Options:' + JSON.stringify(this.recordTypeOptions));
        } else if (error) {
            this.error = error;
            console.error('Error:', JSON.stringify(error));
        }
    }
    @wire(getRecordTypeName, { workOrderId: '$workOrderId', currentDatetime: '$currentDatetime' })
    wiredRecordTypeDev({ error, data }) {
        if (data) {
            this.selectedRecordType = data;
            if (this.selectedRecordType) {
                this.showChildComponent = true;
                this.hideBackButton = true;
            }
            else {
                this.showChildComponent = false;
                this.hideBackButton = false;
            }
        } else if (error) {
            console.error('Error loading work order:', error);
            alert(error)
            //this.showToast('Error', 'Error loading work order data', 'error');
        }
    }
    get isNextDisabled() {
        return !this.selectedRecordType;
    }
    get pageTitle() {

        if (!this.selectedRecordType || !this.recordTypeOptions) {
            return 'Add Work Order Line Items';
        }
        const selectedOption = this.recordTypeOptions.find(
            option => option.value === this.selectedRecordType
        );
        const label = selectedOption ? selectedOption.label : '';
        const baseTitle = 'Add Work Order Line Items';
        return label ? baseTitle + " - " + label : baseTitle;
    }
    get showLicenseComponent() {
        return this.showChildComponent && this.selectedRecordType === 'License';
    }

    get showSlabRateComponent() {
        return this.showChildComponent && this.selectedRecordType === 'Slab_Rate';
    }
    get showPointsComponent() {
        return this.showChildComponent && this.selectedRecordType === 'Points';
    }
    get showKPOComponent() {
        return this.showChildComponent && this.selectedRecordType === 'KPO';
    }
    get showFixedUnitPriceComponent() {
        return this.showChildComponent && this.selectedRecordType === 'Fixed_Unit_Price';
    }
     get showStaffingComponent() {
        return this.showChildComponent && this.selectedRecordType === 'Staffing';
    }
    handleRecordTypeChange(event) {
        this.selectedRecordType = event.detail.value;
        console.log('Selected Record Type:', this.selectedRecordType);

        this.selectedRecordTypeValue = this.selectedRecordType;
        this.dispatchEvent(new FlowAttributeChangeEvent('selectedRecordTypeValue', this.selectedRecordTypeValue));
    }

    handleContinue() {
        if (!this.selectedRecordType) {
            this.showToast('Warning', 'Please select a record type before continuing', 'warning');
            return;
        }

        this.showChildComponent = true;
    }

    handleBack() {
        this.showChildComponent = false;
        this.childSkuResult = false;
        this.childErrorMessage = '';

        this.skuResult = false;
        this.errorMessageFlow = '';
        this.dispatchEvent(new FlowAttributeChangeEvent('skuResult', false));
        this.dispatchEvent(new FlowAttributeChangeEvent('errorMessageFlow', ''));
    }
    handleBackFromChild(event) {
        if (this.hideBackButton) {
            window.history.back();
        } else {
            this.handleBack();
        }
    }
    handleChildResult(event) {
        console.log('Child result received:', event.detail);

        if (event.detail.type === 'success') {
            this.childSkuResult = true;
            this.childErrorMessage = '';

            this.skuResult = true;
            this.errorMessageFlow = '';
            this.dispatchEvent(new FlowAttributeChangeEvent('skuResult', true));
            this.dispatchEvent(new FlowAttributeChangeEvent('errorMessageFlow', ''));

            this.showToast('Success', 'Records created successfully!', 'success');

        } else if (event.detail.type === 'error') {
            this.childSkuResult = false;
            this.childErrorMessage = event.detail.message || 'An error occurred';

            // Pass error to flow
            this.skuResult = false;
            this.errorMessageFlow = this.childErrorMessage;
            this.dispatchEvent(new FlowAttributeChangeEvent('skuResult', false));
            this.dispatchEvent(new FlowAttributeChangeEvent('errorMessageFlow', this.childErrorMessage));

            this.showToast('Error', this.childErrorMessage, 'error');
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    @api
    resetComponent() {
        this.selectedRecordType = '';
        this.showChildComponent = false;
        this.childSkuResult = false;
        this.childErrorMessage = '';
        this.skuResult = false;
        this.errorMessageFlow = '';
        this.selectedRecordTypeValue = '';
    }

    @api
    getCurrentState() {
        return {
            selectedRecordType: this.selectedRecordType,
            showChildComponent: this.showChildComponent,
            childSkuResult: this.childSkuResult,
            childErrorMessage: this.childErrorMessage,
            workOrderId: this.workOrderId,
            unitOfMeasure: this.unitOfMeasure
        };
    }
}
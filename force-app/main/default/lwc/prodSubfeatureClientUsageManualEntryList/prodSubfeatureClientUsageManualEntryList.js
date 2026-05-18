import { LightningElement, track, wire } from 'lwc';

import getAccountList from '@salesforce/apex/ProdSubfeatureClientUsageController.getAccountList';
import getSubFeatureList from '@salesforce/apex/ProdSubfeatureClientUsageController.getManualEntrySubFeatureList';
import getFeatureList from '@salesforce/apex/ProdSubfeatureClientUsageController.getFeatureList';
import saveProductSubFeatureClientUsage from '@salesforce/apex/ProdSubfeatureClientUsageController.saveProductSubFeatureClientUsage';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProductList from '@salesforce/apex/ProdSubfeatureClientUsageController.getProductList';

export default class ProdSubfeatureClientUsageManualEntryList extends LightningElement {
    @track accountList = [];
    @track featureList = [];
    @track selectedAcc = '';
    @track displaySubFeatureList = false;
    @track productList = [];
    @track subFeatureList = [];
    @track featureName;
    @track featureId = '';
    @track productId;

    @track productClientUsage = [];

    @wire(getAccountList)
    wiredAccountList({ error, data }) {
        if (data) {
            for (let i = 0; i < data.length; i++) {
                this.accountList = [...this.accountList, { value: data[i].Id, label: data[i].Name }];
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
        console.log('---' + JSON.stringify(this.accountList))
    }

    handleAccountChange(event) {
        this.selectedAcc = event.detail.value;
        this.featureList = [];
        this.productList = [];
        this.featureName = '';
        this.featureId = '';
        this.productId = '';
        this.displaySubFeatureList = false;

        this.template.querySelectorAll('.featureClass').forEach(each => {
            each.value = undefined;
        });

        this.template.querySelectorAll('.productClass').forEach(each => {
            each.value = undefined;
        });
        getProductList({ accountId: this.selectedAcc })
            .then(result => {
                if (result.length === 0) {
                    const evt = new ShowToastEvent({
                        title: "Info",
                        message: "There is no sub feature available...!",
                        variant: "info",
                        mode: "pester"
                    });

                    this.dispatchEvent(evt);
                } else {
                    for (let i = 0; i < result.length; i++) {
                        this.productList = [...this.productList, { value: result[i].Id, label: result[i].Name }];
                    }
                    this.error = undefined;
                }
            })
            .catch(error => {
                console.log(error)
            });

    }
    handleProductChange(event) {
        this.productId = event.detail.value;
        this.displaySubFeatureList = false;
        this.featureList = [];
        let productName = event.target.options.find(opt => opt.value === event.detail.value).label;
        this.template.querySelectorAll('.featureClass').forEach(each => {
            each.value = undefined;
        });
        getFeatureList({ productId: this.productId })
            .then(result => {
                if (result.length === 0) {
                    const evt = new ShowToastEvent({
                        title: "Info",
                        message: "There is no sub feature available for " + productName + "...!",
                        variant: "info",
                        mode: "pester"
                    });

                    this.dispatchEvent(evt);
                } else {
                    for (let i = 0; i < result.length; i++) {
                        this.featureList = [...this.featureList, { value: result[i].Id, label: result[i].Name }];
                    }
                    this.error = undefined;
                }
            })
            .catch(error => {
                console.log(error)
            });
    }
    handleFeatureChange(event) {
        this.featureId = event.detail.value;
        this.featureName = event.target.options.find(opt => opt.value === event.detail.value).label;
        this.subFeatureList = [];
        getSubFeatureList({ featureId: this.featureId, accountId: this.selectedAcc })
            .then(result => {
                if (result.length === 0) {
                    const evt = new ShowToastEvent({
                        title: "Info",
                        message: "There is no sub feature available for " + this.featureName + "...!",
                        variant: "info",
                        mode: "pester"
                    });

                    this.dispatchEvent(evt);
                    this.displaySubFeatureList = false;
                }
                else {
                    this.displaySubFeatureList = true;
                    this.subFeatureList = result;
                    this.productId = result[0].Salesforce_Product__c;
                }
            })
            .catch(error => {
                console.log(error)
            });

    }
    handleClientUsageUpdate(event) {
        var c = event.target.value;
        let usageField = this.template.querySelector('.' + event.currentTarget.dataset.id);

        if (event.target.value < 0 || event.target.value > 100 || c.length === 0) {
            usageField.setCustomValidity("Please enter value 0 to 100.");
            usageField.reportValidity();
        } else {
            usageField.setCustomValidity('');
            usageField.reportValidity();

            //var checkOflength = event.target.value;*/
            var check;

            if (this.productClientUsage.length != 0) {
                for (var i = 0; i < this.productClientUsage.length; i++) {
                    var item = this.productClientUsage[i];
                    if (item.Id === event.target.dataset.id) {
                        this.productClientUsage.splice(i, 1);
                        this.productClientUsage.push(
                            {
                                Id: event.target.dataset.id,
                                Client_Usage_Percentage__c: event.target.value,
                            });
                        check = 1;
                        break;
                    }
                }
                if (check != 1) {
                    this.productClientUsage.push(
                        {
                            Id: event.target.dataset.id,
                            Client_Usage_Percentage__c: event.target.value,
                        });
                }
            }
            else {
                this.productClientUsage.push(
                    {
                        Id: event.target.dataset.id,
                        Client_Usage_Percentage__c: event.target.value,
                    });
            }


        }
    }

    handleCancel(event) {
        // this.featureList=[];
        this.productClientUsage = [];

        this.subFeatureList = [];
        getSubFeatureList({ featureId: this.featureId, accountId: this.selectedAcc })
            .then(result => {
                if (result.length === 0) {
                    const evt = new ShowToastEvent({
                        title: "Info",
                        message: "There is no sub feature available for " + this.featureName + "...!",
                        variant: "info",
                        mode: "pester"
                    });

                    this.dispatchEvent(evt);
                    this.displaySubFeatureList = false;
                }
                else {
                    this.displaySubFeatureList = true;
                    this.subFeatureList = result;
                    this.productId = result[0].Salesforce_Product__c;
                }
            })
            .catch(error => {
                console.log(error)
            });
    }

    handleSave(event) {
        if (this.selectedAcc == '' || this.selectedAcc === null || this.selectedAcc == undefined) {
            const evt = new ShowToastEvent({
                title: 'Warning',
                message: 'Please select an account!',
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        } else {
            const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
                .reduce((validSoFar, inputField) => {
                    inputField.reportValidity();
                    return validSoFar && inputField.checkValidity();
                }, true);
            if (isInputsCorrect) {
                saveProductSubFeatureClientUsage({ clientUsageJson: JSON.stringify(this.productClientUsage), accountId: this.selectedAcc, leadMgtFeatureId: this.featureId, productId: this.productId })
                    .then(result => {
                        const event = new ShowToastEvent({
                            title: 'Success Message',
                            message: 'Client Usage saved successfully!',
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                        this.productClientUsage = [];
                        //this.handleCancel();
                    })
                    .catch(error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error updating record',
                                message: error.body.message,
                                variant: 'error'
                            })
                        );
                    });
            }
        }
    }
}
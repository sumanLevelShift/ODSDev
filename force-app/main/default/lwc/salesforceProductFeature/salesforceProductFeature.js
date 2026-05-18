import { LightningElement, wire, api, track } from 'lwc';
import fetchSalesforceProduct from '@salesforce/apex/SalesforceProduct.fetchSalesforceProduct';
import fetchSalesforceProductAfterAccountSelect from '@salesforce/apex/SalesforceProduct.fetchSalesforceProductAfterAccountSelect';
import jquery from '@salesforce/resourceUrl/jquery';
import { loadScript } from 'lightning/platformResourceLoader';
import { createMessageContext, APPLICATION_SCOPE, subscribe } from 'lightning/messageService';
import SAMPLEMC from "@salesforce/messageChannel/SampleMessageChannel__c";
const columns = [
    { label: 'Id', fieldName: 'Id', fixedWidth: 1 },
    { label: 'Client Usage Percentage', fieldName: 'Client_Usage_Percentage__c', editable: true },
    { label: 'Feature', fieldName: 'Name', wrapText: true }

];


export default class SalesforceProductFeature extends LightningElement {
    @api accountId;
    @track accountSelected;
    @track oldAccountSelected;
    error;
    columns = columns;
    draftValues = [];
    @api isChecked = false;
    context = createMessageContext();
    subscription = null;
    @track LMSFlag = true;
    connectedCallback() {
        this.subscribeMC();

    }
    @track oldId;
    subscribeMC() {

        this.subscription = subscribe(this.context, SAMPLEMC, (message) => {
            this.LMSFlag = false;
            this.onAccountSelection(message.recordId);

        }, { scope: APPLICATION_SCOPE });
    }


    jqueryPackage = jquery;
    renderedCallback() {

        Promise.all([
            loadScript(this, this.jqueryPackage),
        ]).then(() => {

        })
            .catch(error => {
                this.error = error;
                console.log(' Error Occured-- ', +error);
            });

    }

    accountOptions = []; //this will hold key, value pair

    accountRecords;
    accountWiredRecords;





    options = []; //this will hold key, value pair
    value = ''; //initialize combo box value
    salesforceProductSelected = '';
    salesforceProductRecords;
    wiredSalesforceProductRecords;
    @wire(fetchSalesforceProduct)
    wiredSalesforceProduct(value) {
        this.wiredSalesforceProductRecords = value; // track the provisioned value
        const { data, error } = value;
        if (data) {

            this.salesforceProductRecords = data;
            this.error = null;
        } else if (error) {
            this.error = error;
            this.salesforceProductRecords = null;
        }
    }



    noRecords = false;
    salesforceProductFeatureRecords;

    accordionMethod(event) {
        this.salesforceProductSelected = '';
        this.salesforceProductSelected = event.target.dataset.id;
        let accHeading = this.template.querySelectorAll(".accordion");
        let accPanel = this.template.querySelectorAll('.panel');
        if (event.target.classList.contains("active")) {
            event.target.classList.remove("active");
            event.target.nextElementSibling.classList.remove("panelShow");
            event.target.nextElementSibling.style.maxHeight = null;
        } else {
            for (let i = 0; i < accHeading.length; i++) {
                if (accPanel[i].classList.contains("panelShow")) {
                    accPanel[i].classList.remove("panelShow");
                    accHeading[i].classList.remove("active");
                    accPanel[i].style.maxHeight = null;
                }

            }
            event.target.classList.add("active");
            event.target.nextElementSibling.classList.add("panelShow");
            event.target.nextElementSibling.style.maxHeight = event.target.nextElementSibling.scrollHeight + "px";
        }
    }

    @api
    fetchSalesforcerecentRecord() {
        fetchSalesforceProductAfterAccountSelect({ accountId: this.accountSelected })
            .then(result => {
                this.salesforceProductRecords = [];
                this.salesforceProductRecords = result;
            })
            .catch(error => {
                console.log(error);
            });
    }
    @track SampleTest = [];
    @track childList = [];
    onAccountSelection(accId) {

        this.updateSalesforceProduct = [];
        this.accountSelected = accId;

        if (this.accountSelected === null) {
            fetchSalesforceProduct()
                .then(result => {
                    this.salesforceProductRecords = [];
                    this.salesforceProductRecords = result;
                })
                .catch(error => {
                    console.log(error);
                });
        }
        else {

            fetchSalesforceProductAfterAccountSelect({ accountId: this.accountSelected })
                .then(result => {
                    this.salesforceProductRecords = [];
                    this.salesforceProductRecords = result;
                    const selectedEvent = new CustomEvent("accountvalue", {
                        detail: this.accountSelected
                    });
                    this.dispatchEvent(selectedEvent);
                })
                .catch(error => {
                    console.log(error);
                });

        }
    }
    @api updateSalesforceProduct = [];
    handleFeature(event) {
        let checkOflength = event.target.value;

        if (event.target.value < 0 || event.target.value > 100 || checkOflength.length === 0) {
            console.log('Enter valid a value.')
        }
        else if (this.accountSelected === null || this.accountSelected === ''  || this.accountSelected ===undefined) {
            const selectedEvent = new CustomEvent("alert", {
                detail: true
            });
            this.dispatchEvent(selectedEvent);
        } else {
            this.updateSalesforceProduct = [];
            this.updateSalesforceProduct.push(
                {
                    Salesforce_Product__c: event.target.dataset.id,
                    Salesforce_Product_Usage__c: event.target.value,
                    Account__c: this.accountSelected
                });


            const selectedEvent = new CustomEvent("progressvaluechange", {
                detail: this.updateSalesforceProduct
            });
            this.dispatchEvent(selectedEvent);
        }
    }
    @track classNames = [];
    handleFeatureChange(event) {
        if (this.accountSelected === null || this.accountSelected === '' || this.accountSelected ===undefined ) {
            const selectedEvent = new CustomEvent("alert", {
                detail: true
            });
            this.dispatchEvent(selectedEvent);
        } else {
            const selectedEvent = new CustomEvent("alert", {
                detail: false
            });
            this.dispatchEvent(selectedEvent);
            this.classNames.push(event.currentTarget.dataset.id);

            if (this.classNames.length != 0) {
                for (let i = 0; i < this.classNames.length; i++) {

                    this.template.querySelector('.' + this.classNames[i]).style.display = "none";
                    this.template.querySelector('.' + this.classNames[i]).parentNode.querySelector('p').style.display = "block";
                    event.currentTarget.parentNode.querySelector('p');
                }
            }

            this.template.querySelector('.' + event.currentTarget.dataset.id).style.display = "block";
            event.currentTarget.querySelector('p').style.display = "none";

        }
    }
    handleFeatureChangeForOnClick(event) {
        if (this.accountSelected === null || this.accountSelected === ''  || this.accountSelected ===undefined) {
            const selectedEvent = new CustomEvent("alert", {
                detail: true
            });
            this.dispatchEvent(selectedEvent);
        } else {
            const selectedEvent = new CustomEvent("alert", {
                detail: false
            });
            this.dispatchEvent(selectedEvent);
            this.classNames.push(event.currentTarget.dataset.id);

            if (this.classNames.length != 0) {
                for (let i = 0; i < this.classNames.length; i++) {

                    this.template.querySelector('.' + this.classNames[i]).style.display = "none";
                    this.template.querySelector('.' + this.classNames[i]).parentNode.querySelector('p').style.display = "block";
                    event.currentTarget.parentNode.querySelector('p');
                }
            }

            this.template.querySelector('.' + event.currentTarget.dataset.id).style.display = "block";
            event.currentTarget.parentNode.style.display = "none";
        }
    }

    @track clientProductUsage = [];
    handleClientFeature(event) {
        let usageField = this.template.querySelector('.' + event.currentTarget.dataset.id);

        let c = event.target.value;

        if (event.target.value < 0 || event.target.value > 100 || c.length === 0) {
            usageField.setCustomValidity("Please enter value 0 to 100.");
            usageField.reportValidity();
        } else {
            usageField.setCustomValidity('');
            usageField.reportValidity();
            this.template.querySelector('.' + event.currentTarget.dataset.id).style.display = "none";
            event.currentTarget.parentNode.querySelector('p').style.display = "block";
            let parent = event.currentTarget.parentNode.querySelector('p');
            parent.querySelector('span').innerText = event.target.value;

            this.clientProductUsage = [];
            this.clientProductUsage.push(
                {
                    Id: event.target.dataset.id,
                    Client_Usage_Percentage__c: event.target.value,
                });

            const selectedEvent = new CustomEvent("clientvaluechange", {
                detail: this.clientProductUsage
            });
            this.dispatchEvent(selectedEvent);


        }
    }
}
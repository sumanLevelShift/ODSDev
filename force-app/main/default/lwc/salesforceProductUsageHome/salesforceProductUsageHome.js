import { LightningElement, api, } from 'lwc';
import fetchSalesforceProductAfterAccountSelect from '@salesforce/apex/SalesforceProduct.fetchSalesforceProductAfterAccountSelect';
import { createMessageContext, publish } from 'lightning/messageService';
import SAMPLEMC from "@salesforce/messageChannel/SampleMessageChannel__c";
import updateSessionData from '@salesforce/apex/SalesforceProduct.updateSessionData';

export default class SalesforceProductUsageHome extends LightningElement {
  @api features;
  @api accountId;
  @api client;
  @api flag
  context = createMessageContext();

  @api accountIFromAura;
  @api serviceIdFromAura;
  connectedCallback() {
    if (this.accountIFromAura != null || this.accountIFromAura != '' || this.accountIFromAura != undefined) {
      fetchSalesforceProductAfterAccountSelect({ accountId: this.accountIFromAura })
        .then(result => {
          console.log(result);
          const message = {
            recordId: this.accountIFromAura,
            recordData: { value: result }
          };
          publish(this.context, SAMPLEMC, message);
        })
        .catch(error => {
          console.log(error);
        });
    }
    else if (this.accountIFromAura == 'All') {
      console.log('All Customer')
    }
    this.updateSessionsFunction();
  }

  dynamicMethod(event) {
    this.flag = event.detail;
    this.template.querySelector('c-salesforce-product-feature').fetchSalesforcerecentRecord();
  }

  updateSessionsFunction() {
    updateSessionData({ accountId: this.accountIFromAura, serviceId: this.serviceIdFromAura })
      .then(data => {
        console.log('Updated sessions.');
      })
      .catch(error => {
        console.log('update--' + error);
      });
  }
  hanldeProgressValueChange(event) {
    if (this.accountId == undefined) {
      this.template.querySelector('.alert').style.display = "block";
      setTimeout(function () {
        this.template.querySelector('.alert').style.display = "none";
      }.bind(this), 2500);
    } else {
      this.features = [];
      this.features = event.detail;
      this.client = [];
      this.template.querySelector('c-salesforce-product-overall-usage-chart').handleRun(this.accountId, this.features, this.client);
    }
  }
  handleAccount(event) {
    this.accountId = event.detail;
    this.template.querySelector('c-salesforce-product-overall-usage-chart').handleRun(this.accountId);
  }
  handleClientvalue(event) {
    this.client = [];
    this.client = event.detail;
    this.features = [];
    this.template.querySelector('c-salesforce-product-overall-usage-chart').handleRun(this.accountId, this.features, this.client);
  }
  handleAlert(event) {
    if (event.detail === true) {
      this.template.querySelector('.alert').style.display = "block";
      setTimeout(function () {
        this.template.querySelector('.alert').style.display = "none";
      }.bind(this), 2500);
    }
  }
  closeButton() {
    this.template.querySelector('.alert').style.display = "none";
  }
  get year() {
    let d = new Date();
    return d.getFullYear();
  }
}
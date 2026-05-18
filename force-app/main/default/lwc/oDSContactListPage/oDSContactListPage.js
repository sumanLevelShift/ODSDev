import { LightningElement, wire, api, track } from 'lwc';
import GetContacts from '@salesforce/apex/ODS_ContactComponentController.GetContacts';
//import myChannel from "@salesforce/messageChannel/PassRecordId__c";
import { createMessageContext, APPLICATION_SCOPE, subscribe } from 'lightning/messageService';
import ODS_JqueryUpdated from '@salesforce/resourceUrl/ODS_JqueryUpdated'
import { loadScript, loadStyle } from 'lightning/platformResourceLoader'
import GetAccountPicklistValues from '@salesforce/apex/ODS_ContactComponentController.GetAccountPicklistValues';
import getCurrentContact from '@salesforce/apex/ODS_ContactComponentController.getCurrentContact';
import updateSelectedContact from '@salesforce/apex/ODS_ContactComponentController.updateSelectedContact';
import updateSessionData from '@salesforce/apex/ODS_ContactComponentController.updateSessionData';
import getAccountList from '@salesforce/apex/ODS_ContactComponentController.getAccountList';
import getReportId from '@salesforce/apex/ODS_ContactComponentController.getReportId';
import getODSDotNetStatusPickListValue from '@salesforce/apex/ODS_ContactComponentController.getODSDotNetStatusPickListValue';
import getStatusPickListValue from '@salesforce/apex/ODS_ContactComponentController.getStatusPickListValue';
import ContactListCSS from '@salesforce/resourceUrl/ContactListCSS';
import ODS_Statussign from '@salesforce/resourceUrl/ODS_Statussign';


export default class ODS_ContactComponentController extends LightningElement {

    context = createMessageContext();
    @track spinner = ODS_Statussign;

    //Sub
    @api accId = '';
    @api srvcId = '';
    @track selectcontactId;
    @track AccNames;
    @track accountid;
    @track Accoutlist = [];
    @track AccountNameList = [];
    @track selectedAccountId;
    @track ReportNameList = [];
    @track DotNetPickListValue = [];
    @track StatusPickListValue = [];
    @track selectedDotNetPickListValue = '';
    @track selectedStatusPickListValue = '';
    @track selectedReportId = '';
    @track selectedMailingState = '';
    @track selectedOtherState = '';
    @track selectedMailingPostalCode = '';
    @track selectedOtherPostalCode = '';
    @track SelectedMobilePhone = '';

    @wire(getAccountList)
    wiredAccountList({ error, data }) {
        if (data) {
            let lstOption = [];
            for (var i = 0; i < data.length; i++) {
                lstOption.push({
                    value: data[i].Id, label: data[i].Name
                });
            }
            this.AccountNameList = lstOption;
            this.selectedAccountId = this.accId;
            this.getReportList(this.selectedAccountId);
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }

    @wire(getODSDotNetStatusPickListValue)
    wiredDotNet({ error, data }) {
        if (data) {
            let lstOption = [];
            lstOption.push({
                value: '', label: '--None--'
            });
            for (var i = 0; i < data.length; i++) {
                lstOption.push({
                    value: data[i], label: data[i]
                });
            }
            this.DotNetPickListValue = lstOption;

        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }
    @wire(getStatusPickListValue)
    wiredStatus({ error, data }) {
        if (data) {
            let lstOption = [];
            lstOption.push({
                value: '', label: '--None--'
            });
            for (var i = 0; i < data.length; i++) {
                lstOption.push({
                    value: data[i], label: data[i]
                });
            }
            this.StatusPickListValue = lstOption;
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }
    handleAccountName(event) {
        this.selectedAccountId = event.detail.value;
        this.getReportList(this.selectedAccountId);
    }
    handleDotNetStatus(event) {
        this.selectedDotNetPickListValue = event.detail.value;
    }
    handleForceComStatus(event) {
        this.selectedStatusPickListValue = event.detail.value;
    }
    handleReportId(event) {
        this.selectedReportId = event.detail.value;
    }
    handleMailingState(event) {
        this.selectedMailingState = event.detail.value;
    }
    handleOtherState(event) {
        this.selectedOtherState = event.detail.value;
    }
    handleMailingPostalCode(event) {
        this.selectedMailingPostalCode = event.detail.value;
    }
    handleOtherPostalCode(event) {
        this.selectedOtherPostalCode = event.detail.value;
    }
    handleMobilePhone(event) {
        this.SelectedMobilePhone = event.detail.value;
    }


    getReportList(a) {
        getReportId({ AccountId: this.selectedAccountId })
            .then(data => {
                let lstOption = [];
                lstOption.push({ value: '', label: "--None--" });
                for (var i = 0; i < data.length; i++) {
                    lstOption.push({
                        value: data[i].Id, label: data[i].Name
                    });
                }
                this.ReportNameList = lstOption;
            })
            .catch(error => {
               // console.log('update--' + error);
            });
    }
    connectedCallback() {
        Promise.all([
            loadStyle(this, ContactListCSS)

        ]).then(() => {
           // console.log('External CSS done.')
        })
            .catch(error => {
               // console.log('External CSS Error Occured-- ', +error);
            });

        this.getAccid(this.accId, this.srvcId)
        
        updateSessionData({ accountId: this.accId, serviceId: this.srvcId })
            .then(data => {
              //  console.log('Updated sessions.');
            })
            .catch(error => {
              //  console.log('update--' + error);
            });
    }

    renderedCallback() {



        Promise.all([
            //loadStyle( this, ODS_Assets )
            loadStyle(this, ODS_Assets + '/css/style.css'),
            loadStyle(this, ODS_Assets + '/css/style_dev.css'),
            loadStyle(this, ODS_Assets + '/css/bootstrap.css'),
            loadStyle(this, ODS_Assets + '/js/bootstrap.js'),
            loadStyle(this, ODS_Assets + '/css/bootstrap.css'),
            loadStyle(this, ODS_Assets + 'font-awesome/css/font-awesome.css')

        ])

    }
    @wire(GetAccountPicklistValues)
    wiredAcc({ error, data }) {
        if (data) {
            var conts = data;
            for (var key in conts) {
                if (key !== 'All') {
                    const a = { label: conts[key], value: key };
                    this.Accoutlist = [... this.Accoutlist, a];
                }
            }
        } else if (error) {
           // console.log(error);
            //this.error = error;

        }
    }

    renderedCallback() {
        Promise.all([
            loadScript(this, ODS_JqueryUpdated)


        ]).then(() => {
            console.log('done.')
        })
            .catch(error => {
                this.error = error;
              //  console.log(' Error Occured-- ', +error);
            });

    }
    items;
    @track getContactList = [];
    getAccid(accid, serid) {

        GetContacts({ AccountId: accid, ServiceId: serid })
            .then(data => {
                this.items = data;
                let lstOption = [];
                lstOption.push({ value: '', label: "--None--" });
                for (var i = 0; i < data.length; i++) {
                    lstOption.push({
                        value: data[i].Id, label: data[i].Name
                    });
                }
                this.getContactList = lstOption;

            })
            .catch(error => {
              //  console.log(error);
                this.error = error;
            });
    }
    @track accountIdForSelectedContact;
    @track ReportsToIdForSelectedContact = '';
    @track MailingStateForSelectedContact = '';
    @track OtherStateForSelectedContact = '';
    @track MailingPostalCodeForSelectedContact = '';
    @track OtherPostalCodeForSelectedContact = '';
    @track MobilePhoneForSelectedContact = '';
    handleGetContactDetail(event) {

        this.selectcontactId = event.target.dataset.item;
        this.template.querySelector('.SearchDiv').style.display = "block";
        this.template.querySelector('.myDIV').style.display = "none";

        getCurrentContact({ contactId: this.selectcontactId })
            .then(data => {
               // console.log('result data:' + JSON.stringify(data));
                this.accountIdForSelectedContact = data.AccountId;
                this.ReportsToIdForSelectedContact = data.ReportsToId;
                this.MailingStateForSelectedContact = data.MailingState;
                this.OtherStateForSelectedContact = data.OtherState;
                this.MailingPostalCodeForSelectedContact = data.MailingPostalCode;
                this.OtherPostalCodeForSelectedContact = data.OtherPostalCode;
                this.MobilePhoneForSelectedContact = data.MobilePhone;


            })
            .catch(error => {
                console.log(error);
                this.error = error;
            });
    }

    handleReset(event) {
        window.location.reload(true);

      
    }
    handleCreateCon(event) {
        this.template.querySelector('.spinnerDiv').style.display = "block";

        this.template.querySelector('.addcontact').style.display = "block";
        this.template.querySelector('.myDIV').style.display = "none";
        this.template.querySelector('.spinnerDiv').style.display = "none";

    }

    handleCancle(event) {
        window.location.reload(true);
    }
    handleBack(event) {
        window.location.reload(true);

    }
    handleODSDotNetStatus(event) {
        this.ODSDotNetStatuss = event.detail.value;
    }

    handleSuccess(event) {
        //alert('Contact Created 1 - ' + event.detail.id);
    }
    handleSubmitCreateContact(event) {
        document.location.reload(true);
       
    }
    handleErrorForNewContact(event) {
        alert(event.detail.detail)
    }
    handleUpdate(event) {
        event.preventDefault();
       // let isnum = /^\d+$/.test(this.MobilePhoneForSelectedContact);
       // let ispin = /^\d+$/.test(this.MailingPostalCodeForSelectedContact);
       // let iscode = /^\d+$/.test(this.OtherPostalCodeForSelectedContact);

//console.log('mob'+isnum);
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
       
       
        updateSelectedContact({ contactId: this.selectcontactId, newReportsToId: this.ReportsToIdForSelectedContact, newMailingstateId: this.MailingStateForSelectedContact,newAccountId: this.accountIdForSelectedContact, newOtherStateId: this.OtherStateForSelectedContact,newMailingPostalCodeId: this.MailingPostalCodeForSelectedContact,newOtherPostalCodeId: this.OtherPostalCodeForSelectedContact,newMobilePhone: this.MobilePhoneForSelectedContact })
            .then(data => {
                this.error = undefined;
                window.location.reload(false);

            })
            .catch(error => {
               // console.log(error);
                this.error = error;
            });
        
    }

    handleSave(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit(fields)

            .then(data => {

            })
            .catch(error => {
                console.log(error);
                this.error = error;
            });
    }


    handleNewRecSave(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit(fields)

            .then(data => {

            })
            .catch(error => {
                console.log(error);
                this.error = error;
            });
    }
    handleAccountForUpdate(event) {
        this.accountIdForSelectedContact = event.target.value;

    }
    handleReportIdForUpdate(event) {
        this.ReportsToIdForSelectedContact = event.target.value;
    }
    handleMailingStateForUpdate(event) {
        this.MailingStateForSelectedContact = event.target.value;
    }
    handleOtherStateForUpdate(event) {
        this.OtherStateForSelectedContact = event.target.value;
    }
    handleMailingPostalCodeForUpdate(event) {
        this.MailingPostalCodeForSelectedContact = event.target.value;
    }
    OtherPostalCodeForUpdate(event) {
        this.OtherPostalCodeForSelectedContact = event.target.value;
    }
    MobilePhoneForUpdate(event) {
        this.MobilePhoneForSelectedContact = event.target.value;
    }

}
import { LightningElement, wire, track, api } from 'lwc';

import getInitiativeDetails from '@salesforce/apex/ODS_InitiativeReportController.getInitiativeDetails';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import PDFForReports from '@salesforce/resourceUrl/PDFForReports';
import InitiativeReportCSS from '@salesforce/resourceUrl/InitiativeReportCSS';
import getSearchDetails from '@salesforce/apex/ODS_InitiativeReportController.getSearchDetails';
import getAccountDetails from '@salesforce/apex/ODS_InitiativeReportController.getAccountDetails';
import getPickListValuesIntoList from '@salesforce/apex/ODS_InitiativeReportController.getPickListValuesIntoList';
import getSearchDetailsForStatus from '@salesforce/apex/ODS_InitiativeReportController.getSearchDetailsForStatus';
import ODS_Statussign from '@salesforce/resourceUrl/ODS_Statussign';
import getExportDetailsWithDate from '@salesforce/apex/ODS_InitiativeReportController.getExportDetailsWithDate';
import getExportDetailsWithOutDate from '@salesforce/apex/ODS_InitiativeReportController.getExportDetailsWithOutDate';


export default class ODS_InitiativeReport extends LightningElement {

    isAsc = false;
    isDsc = false;
    sortedDirection = 'asc';
    sortedColumn;
    isStatusSort = false;
    isNameSort = false;
    isApprovedSort = false;
    @track spinner = ODS_Statussign;
    @track initiList = [];
    @api accountIFromAura;
    @api serviceIdFromAura;
    @track tamRec = [];
    frmDate;
    toDate;
    initstatus;
    @track SelectedStatusValue = '';
    @track accountName = '';
    @track serviceName = '';
    @track options = [];
    @track flagBoolean = false;

    connectedCallback() {
        if (this.flagBoolean == false) {
            loadScript(this, PDFForReports)
                .then(() => console.log('Loaded download.js')
                )
                .catch(error => console.log(error));

            loadStyle(this, InitiativeReportCSS)
                .then(() => console.log('css'))
                .catch(error => console.log(error));
            this.flagBoolean = true;
        }

        if (this.accountIFromAura !== null && this.serviceIdFromAura !== null) {
            getAccountDetails({ accountId: this.accountIFromAura, serviceId: this.serviceIdFromAura })
                .then(response => {
                    console.log(response);
                    this.accountName = response[0].Account__r.Name;
                    this.serviceName = response[0].ODS_Service_Name__c;

                }).catch(error => {
                    console.log('Error: ' + error);
                });

            this.initiList = [];
            this.GetInitiativeList();

        }
    }

    @wire(getPickListValuesIntoList)
    wiredclass(value) {
        const { data, error } = value;
        if (data) {
            let datas = JSON.parse(JSON.stringify(data));
            let lstOption = [];
            lstOption.push({ label: '--None--', value: '' });
            for (var i = 0; i < datas.length; i++) {
                lstOption.push({ label: datas[i], value: datas[i] });
            }
            this.options = lstOption;
        } else if (error) {
            console.log(error);
        }
    }


    @track allValues = [];
    handleChange(event) {
        if (event.target.value != '') {
            if (!this.allValues.includes(event.target.value)) {
                this.allValues.push(event.target.value);
            }
        }
    }

    handleRemove(event) {
        const valueRemoved = event.target.name;
        this.allValues.splice(this.allValues.indexOf(valueRemoved), 1);
        if (this.allValues.length == 0) {
            this.template.querySelectorAll('lightning-combobox').forEach(each => {
                each.value = '';
            });
        }


    }

    GetInitiativeList() {

        this.initiList = [];
        getInitiativeDetails({ accountId: this.accountIFromAura, serviceId: this.serviceIdFromAura })
            .then(result => {
                this.initiList = result;
                if (this.initiList.length == 0) {
                    this.template.querySelector('.norecords').style.display = "block";
                    this.template.querySelector('.tableListEST').style.display = "none";
                    this.template.querySelector('.bottomButtons').style.display = "none";

                } else {
                    if (this.initiList.length == 1) {
                        this.template.querySelector('.verticalScrollBar').style.height = "100px";
                    }
                    else if (this.initiList.length < 20) {
                        var h = (this.initiList.length * 40) + 40;
                        var heightPx = h.toString() + 'px'
                        this.template.querySelector('.verticalScrollBar').style.height = heightPx;
                    } else {
                        this.template.querySelector('.verticalScrollBar').style.height = "900px";
                    }
                    this.template.querySelector('.norecords').style.display = "none";
                    this.template.querySelector('.tableListEST').style.display = "block";
                    this.template.querySelector('.bottomButtons').style.display = "block";
                }
            })
            .catch(error => {
                console.log(error)
                this.error = error;


            })

    }
    handleFetchQuery(event) {
        this.template.querySelector('.spinnerDiv').style.display = "block";

        this.frmDate = this.template.querySelector('.startdate').value;
        this.toDate = this.template.querySelector('.enddate').value;
        console.log(' this.frmDate--' + this.frmDate + '---toDate--' + this.toDate);
        if (this.frmDate == null) {
            this.frmDate = '';
        }
        if (this.toDate == null) {
            this.toDate = '';
        }
        if ((this.frmDate == '' && this.toDate != '') || (this.frmDate != '' && this.toDate == '')) {
            console.log('1');
            alert('Please select the approved start/end date...!');
            this.template.querySelector('.spinnerDiv').style.display = "none";

        } else if (this.frmDate == '' && this.toDate == '') {
            console.log('3');
            getSearchDetailsForStatus({ accountId: this.accountIFromAura, serviceId: this.serviceIdFromAura, Initiativestatus: this.allValues })
                .then(result => {
                    this.initiList = result;
                    if (this.initiList.length == 0) {
                        this.template.querySelector('.norecords').style.display = "block";
                        this.template.querySelector('.tableListEST').style.display = "none";
                        this.template.querySelector('.bottomButtons').style.display = "none";
                        this.template.querySelector('.spinnerDiv').style.display = "none";

                    } else {
                        if (this.initiList.length == 1) {
                            this.template.querySelector('.verticalScrollBar').style.height = "100px";
                        }
                        else if (this.initiList.length < 20) {
                            var h = (this.initiList.length * 40) + 40;
                            var heightPx = h.toString() + 'px'
                            this.template.querySelector('.verticalScrollBar').style.height = heightPx;
                        } else {
                            this.template.querySelector('.verticalScrollBar').style.height = "900px";
                        }
                        this.template.querySelector('.norecords').style.display = "none";
                        this.template.querySelector('.tableListEST').style.display = "block";
                        this.template.querySelector('.bottomButtons').style.display = "block";
                    }
                    this.template.querySelector('.spinnerDiv').style.display = "none";

                })
                .catch(error => {
                    console.log(error)
                    this.error = error;
                    this.template.querySelector('.spinnerDiv').style.display = "none";

                })
        } else {
            console.log('5');
            getSearchDetails({ accountId: this.accountIFromAura, serviceId: this.serviceIdFromAura, Initiativestatus: this.allValues, startDate: this.frmDate, endDate: this.toDate })
                .then(result => {
                    this.initiList = result;
                    if (this.initiList.length == 0) {
                        this.template.querySelector('.norecords').style.display = "block";
                        this.template.querySelector('.tableListEST').style.display = "none";
                        this.template.querySelector('.bottomButtons').style.display = "none";
                        this.template.querySelector('.spinnerDiv').style.display = "none";

                    } else {
                        if (this.initiList.length == 1) {
                            this.template.querySelector('.verticalScrollBar').style.height = "100px";
                        }
                        else if (this.initiList.length < 20) {
                            var h = (this.initiList.length * 40) + 40;
                            var heightPx = h.toString() + 'px'
                            this.template.querySelector('.verticalScrollBar').style.height = heightPx;
                        } else {
                            this.template.querySelector('.verticalScrollBar').style.height = "900px";
                        }
                        this.template.querySelector('.norecords').style.display = "none";
                        this.template.querySelector('.tableListEST').style.display = "block";
                        this.template.querySelector('.bottomButtons').style.display = "block";
                    }
                    this.template.querySelector('.spinnerDiv').style.display = "none";

                })
                .catch(error => {
                    console.log(error)
                    this.error = error;
                    this.template.querySelector('.spinnerDiv').style.display = "none";

                })
        }

    }

    sortStatus(event) {
        this.isStatusSort = true;
        this.isNameSort = false;
        this.isApprovedSort = false;

        this.sortData(event.currentTarget.dataset.id);
    }
    sortName(event) {
        this.isStatusSort = false;
        this.isNameSort = true;
        this.isApprovedSort = false;

        this.sortData(event.currentTarget.dataset.id);
    }
    sortApproved(event) {
        this.isStatusSort = false;
        this.isNameSort = false;
        this.isApprovedSort = true;

        this.sortData(event.currentTarget.dataset.id);
    }

    sortData(sortColumnName) {
        this.template.querySelector('.spinnerDiv').style.display = "block";

        if (this.sortedColumn === sortColumnName) {
            this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
        }
        else {
            this.sortedDirection = 'asc';
        }
        if (this.sortedDirection === 'asc') {
            this.isAsc = true;
            this.isDsc = false;
        }
        else {
            this.isAsc = false;
            this.isDsc = true;
        }
        let isReverse = this.sortedDirection === 'asc' ? 1 : -1;
        this.sortedColumn = sortColumnName;
        this.initiList = JSON.parse(JSON.stringify(this.initiList)).sort((a, b) => {
            a = a[sortColumnName] ? a[sortColumnName].toLowerCase() : ''; // Handle null values
            b = b[sortColumnName] ? b[sortColumnName].toLowerCase() : '';

            return a > b ? 1 * isReverse : -1 * isReverse;
        });;
        this.template.querySelector('.spinnerDiv').style.display = "none";

    }

    generatePdf() {
        this.template.querySelector('.spinnerDiv').style.display = "block";

        if (this.frmDate == '' && this.toDate == '') {
            getExportDetailsWithOutDate({ accountId: this.accountIFromAura, serviceId: this.serviceIdFromAura, Initiativestatus: this.allValues, fileType: 'PDF' })
                .then(response => {

                    var strFile = "data:application/pdf;base64," + response;
                    window.download(strFile, "Initiative Report For " + this.accountName + ".pdf", "application/pdf");
                    this.template.querySelector('.spinnerDiv').style.display = "none";
                })
                .catch(error => {
                    console.log(error)
                    this.error = error;
                    this.template.querySelector('.spinnerDiv').style.display = "none";

                })

        } else {
            getExportDetailsWithDate({ accountId: this.accountIFromAura, serviceId: this.serviceIdFromAura, Initiativestatus: this.allValues, startDate: this.frmDate, endDate: this.toDate, fileType: 'PDF' })
                .then(response => {

                    var strFile = "data:application/pdf;base64," + response;
                    window.download(strFile, "Initiative Report For " + this.accountName + ".pdf", "application/pdf");
                    this.template.querySelector('.spinnerDiv').style.display = "none";
                })
                .catch(error => {
                    console.log(error)
                    this.error = error;
                    this.template.querySelector('.spinnerDiv').style.display = "none";

                })

        }

    }

    generateExcel() {
        this.template.querySelector('.spinnerDiv').style.display = "block";

        if (this.frmDate == '' && this.toDate == '') {
            getExportDetailsWithOutDate({ accountId: this.accountIFromAura, serviceId: this.serviceIdFromAura, Initiativestatus: this.allValues, fileType: 'EXCEL' })
                .then(response => {

                    var strFile = "data:application/excel;base64," + response;
                    download(strFile, "Initiative Report For " + this.accountName + ".xls", "application/excel");
                    this.template.querySelector('.spinnerDiv').style.display = "none";
                })
                .catch(error => {
                    console.log(error)
                    this.error = error;
                    this.template.querySelector('.spinnerDiv').style.display = "none";

                })

        } else {
            getExportDetailsWithDate({ accountId: this.accountIFromAura, serviceId: this.serviceIdFromAura, Initiativestatus: this.allValues, startDate: this.frmDate, endDate: this.toDate, fileType: 'EXCEL' })
                .then(response => {

                    var strFile = "data:application/excel;base64," + response;
                    download(strFile, "Initiative Report For " + this.accountName + ".xls", "application/excel");
                    this.template.querySelector('.spinnerDiv').style.display = "none";
                })
                .catch(error => {
                    console.log(error)
                    this.error = error;
                    this.template.querySelector('.spinnerDiv').style.display = "none";

                })

        }
    }

    searchOnClick() {
        var x = this.template.querySelector('.searchDiv');
        this.allValues = [];
        this.template.querySelector('.startdate').value = '';
        this.template.querySelector('.enddate').value = '';

        this.template.querySelectorAll('lightning-combobox').forEach(each => {
            each.value = '';
        });
        if (x.style.display === "none") {
            x.style.display = "block";
        } else {
            x.style.display = "none";
        }
    }

}
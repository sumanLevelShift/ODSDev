import { LightningElement, wire, track, api } from 'lwc';
import getTimesheetDetails from '@salesforce/apex/ODS_HoursConsumedController.getTimesheetDetails';
import { loadScript } from 'lightning/platformResourceLoader';
import PDFForReports from '@salesforce/resourceUrl/PDFForReports';
import downloadPDF from '@salesforce/apex/ODS_HoursConsumedController.exportPDF';
import getAccountDetails from '@salesforce/apex/ODS_HoursConsumedController.getAccountDetails';
import exportExcel from '@salesforce/apex/ODS_HoursConsumedController.exportExcel';
import ODS_Statussign from '@salesforce/resourceUrl/ODS_Statussign';

export default class ODS_HoursConsumedbyCalendarYear extends LightningElement {


    @api accountIFromAura;
    @api serviceIdFromAura;
    timesheetyear;
    totalTimesheetHours;
    @track timesheetlist = [];
    @track accountName = '';
    @track serviceName = '';
    data;
    data = [];
    @track spinner = ODS_Statussign;

    connectedCallback() {
        //alert(this.accountIFromAura);
        // alert(this.serviceIdFromAura);
        if (this.accountIFromAura !== null && this.serviceIdFromAura !== null) {
            getAccountDetails({ accountId: this.accountIFromAura, serviceId: this.serviceIdFromAura })
                .then(response => {
                    console.log(response);
                    this.accountName = response[0].Account__r.Name;
                    this.serviceName = response[0].ODS_Service_Name__c;

                }).catch(error => {
                    console.log('Error: ' + error);
                });

            this.GetTimesheetRecordList();

        }
    }


    GetTimesheetRecordList() {
        getTimesheetDetails({ accountId: this.accountIFromAura, serviceId: this.serviceIdFromAura })
            .then(data => {

                // console.log('welcome data : '+JSON.stringify(data));
                this.timesheetlist = data;
                if(this.timesheetlist.length==0){
                    this.template.querySelector('.norecords').style.display = "block";
                    this.template.querySelector('.tableListEST').style.display = "none";
                    this.template.querySelector('.bottomButtons').style.display = "none";

                }else{
                    this.template.querySelector('.norecords').style.display = "none";
                    this.template.querySelector('.tableListEST').style.display = "block";
                    this.template.querySelector('.bottomButtons').style.display = "block";
                }

            })
            .catch(error => {
                console.log(error);
            });
    }
    renderedCallback() {
        loadScript(this, PDFForReports)
            .then(() => console.log('Loaded download.js'))
            .catch(error => console.log(error));
    }

    generatePdf() {
        this.template.querySelector('.spinnerDiv').style.display = "block";

        downloadPDF({ accountId: this.accountIFromAura, serviceId: this.serviceIdFromAura }).then(response => {
            console.log(response);
            this.boolShowSpinner = false;
            var strFile = "data:application/pdf;base64," + response;
            window.download(strFile, "Hours Consumed by Calendar Year For " + this.accountName + ".pdf", "application/pdf");

        }).catch(error => {
            console.log('Error: ' + error);
        });
        this.template.querySelector('.spinnerDiv').style.display = "none";


    }

    generateExcel() {
        this.template.querySelector('.spinnerDiv').style.display = "block";

        exportExcel({ accountId: this.accountIFromAura, serviceId: this.serviceIdFromAura }).then(response => {
            console.log(response);
            var strFile = "data:application/excel;base64," + response;
            download(strFile, "Hours Consumed by Calendar Year For " + this.accountName + ".xls", "application/excel");

        }).catch(error => {
            console.log('Error: ' + error);
        });
        this.template.querySelector('.spinnerDiv').style.display = "none";

    }



    handleSearchKeyword() {

    }
}
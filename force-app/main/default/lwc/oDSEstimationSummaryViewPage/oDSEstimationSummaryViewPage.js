import { LightningElement, api, track } from 'lwc';
import getEstimationSummaryRecords from '@salesforce/apex/oDSEstimationSummaryViewPageController.getEstimationSummaryRecords';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import deleteEstimationSummaryRecords from '@salesforce/apex/oDSEstimationSummaryViewPageController.deleteEstimationSummaryRecords';
import ODS_Statussign from '@salesforce/resourceUrl/ODS_Statussign';
import { NavigationMixin } from 'lightning/navigation';
import updateSessionData from '@salesforce/apex/oDSEstimationSummaryViewPageController.updateSessionData';
import EstimationSummaryResource from '@salesforce/resourceUrl/EstimationSummaryResource';
import getcurrentUserAccessForEstimation from '@salesforce/apex/oDSEstimationSummaryViewPageController.getcurrentUserAccessForEstimation';

export default class ODSEstimationSummaryViewPage extends NavigationMixin(LightningElement) {
    @api accountIFromAura;
    @api serviceIdFromAura;
    @track estimateSummaryList = [];
    @track spinner = ODS_Statussign;

    @track pageSize = 10;
    @track pageNumber = 1;
    @track totalRecords = 0;
    @track totalPages = 0;
    @track recordEnd = 0;
    @track recordStart = 0;
    @track isPrev = true;
    @track isNext = true;
    @track pageNumberButton = [];
    @track firstPageFlag = true;
    @track enableForDeliveryRole=false;
    renderedCallback() {
        if (this.firstPageFlag == true) {
            var divId = '1';
            var Element = this.template.querySelectorAll("[data-item='" + divId + "']");
            if (Element !== null) {
                Element.forEach(elem => elem.className = 'paginate_button current');

            }
        }

        /*  Promise.all([
              loadScript(this, jquery3_6_0)
  
          ])*/
        Promise.all([
            loadScript(this, EstimationSummaryResource + '/jquery3_6_0.js')
        ]).then(() => {
        }).catch(error => {
            this.error = error;
            console.log(' Error Occured-- ', +error);
        });
    }
    handlePageSizeChange(event) {
        this.pageSize = this.template.querySelector('.pageDropDow').value;
        this.pageNumber = 1;
        this.GetEstimationRecordList();
        this.firstPageFlag = true;
    }

    connectedCallback() {
        if (this.accountIFromAura != null || this.accountIFromAura != '' || this.accountIFromAura != undefined) {
            this.GetEstimationRecordList();
            this.updateSessionsFunction();
            getcurrentUserAccessForEstimation()
            .then(data => {
                this.enableForDeliveryRole=data;
            })
            .catch(error => {
                console.log('update--' + error);
            });
        }


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

    //handle next
    handleNext() {
        this.pageNumber = this.pageNumber + 1;
        this.GetEstimationRecordList();
        this.firstPageFlag = false;
        var elems = Array.from(this.template.querySelectorAll('.current'));
        if (elems !== null) {
            elems.forEach(elem => elem.classList.remove('current'));
        }
        var e = Array.from(this.template.querySelectorAll('.paginate_button'));
        for (let index = 0; index < e.length; ++index) {
            const element = e[index];
            if (element.text == this.pageNumber) {
                element.className = 'paginate_button current';
            }
        }
    }

    //handle prev
    handlePrev() {
        this.pageNumber = this.pageNumber - 1;
        this.GetEstimationRecordList();
        this.firstPageFlag = false;
        var elems = Array.from(this.template.querySelectorAll('.current'));
        if (elems !== null) {
            elems.forEach(elem => elem.classList.remove('current'));
        }
        var e = Array.from(this.template.querySelectorAll('.paginate_button'));
        for (let index = 0; index < e.length; ++index) {
            const element = e[index];
            if (element.text == this.pageNumber) {
                element.className = 'paginate_button current';
            }
        }
    }
    showSpinner() {
        let spin = this.template.querySelector('.spinnerDiv');
        if (spin) {
            spin.style.display = "block";
        }
    }
    hideSpinner() {
        let spin = this.template.querySelector('.spinnerDiv');
        if (spin) {
            spin.style.display = "none";
        }
    }
    GetEstimationRecordList() {
        this.showSpinner();
        this.estimateSummaryList = [];
        getEstimationSummaryRecords({ accountId: this.accountIFromAura, pageSize: this.pageSize, pageNumber: this.pageNumber })
            .then(result => {
                // this.estimateSummaryList = result;
                var resultData = JSON.parse(result);
                this.estimateSummaryList = resultData.WrapODSEstimate;
                this.pageNumber = resultData.pageNumber;
                this.totalRecords = resultData.totalRecords;
                this.recordStart = resultData.recordStart;
                this.recordEnd = resultData.recordEnd;
                this.totalPages = Math.ceil(resultData.totalRecords / this.pageSize);
                this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
                this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);
                this.pageNumberButton = [];
                if (this.pageSize != 0) {
                    for (var i = 1; i <= this.totalPages; i++) {
                        this.pageNumberButton.push(i);
                    }
                } else {
                    this.pageNumberButton.push(1);
                    this.isNext = true;
                }
                // alert('pagenumber--'+JSON.stringify(this.pageNumberButton));
                if (this.estimateSummaryList.length == 0) {
                    this.template.querySelector('.tableListEST').style.display = "none";
                    this.template.querySelector('.norecords').style.display = "block";

                } else {
                    this.template.querySelector('.tableListEST').style.display = "block";
                    this.template.querySelector('.norecords').style.display = "none";

                }
                this.hideSpinner();

            })
            .catch(error => {
                console.log(error);
                this.hideSpinner();

            });
    }

    handleDeleteRecord(event) {
        let c = confirm('Are you sure you want to delete?');
        if (c) {
            this.template.querySelector('.spinnerDiv').style.display = "block";
            deleteEstimationSummaryRecords({ recordId: event.target.dataset.item })
                .then(data => {
                    this.GetEstimationRecordList();
                    this.template.querySelector('.spinnerDiv').style.display = "none";

                })
                .catch(error => {
                    console.log(error);
                });
        }
    }

    handleViewRecord(event) {
        this.template.querySelector('.spinnerDiv').style.display = "block";
        window.location.href = '/apex/DetailsEstimationSummary?estimationId=' + event.target.dataset.item + '&accountId=' + this.accountIFromAura + '&serviceId=' + this.serviceIdFromAura;
        this.template.querySelector('.spinnerDiv').style.display = "None";

    }
    handlePageButton(event) {
        if (event.target.dataset.item != this.pageNumber) {
            this.firstPageFlag = false;
            this.pageNumber = event.target.dataset.item;
            this.GetEstimationRecordList();

            var elems = Array.from(this.template.querySelectorAll('.current'));
            if (elems !== null) {
                elems.forEach(elem => elem.classList.remove('current'));
            }
            var Element = this.template.querySelectorAll("[id='" + event.srcElement.id + "']");
            if (Element !== null) {
                Element.forEach(elem => elem.className = 'paginate_button current');
            }
        }
    }
    handleAddEstimate(event) {
        event.preventDefault();

        window.location.href = "/apex/DetailsEstimationSummary";
        /* this[NavigationMixin.GenerateUrl]({
             type: 'standard__webPage',
             attributes: {
                 url: '/apex/DetailsEstimationSummary'
             }
         }).then(vfURL => {
             alert(vfURL);
             window.open(vfURL);
         });*/

    }
}
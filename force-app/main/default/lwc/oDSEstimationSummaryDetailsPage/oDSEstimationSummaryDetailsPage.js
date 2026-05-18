import { LightningElement, api, track } from 'lwc';
import getCustomerNamedetails from '@salesforce/apex/EstimationSummaryDetailsPageContrl.getCustomerNamedetails';
import updateWithRisk from '@salesforce/apex/EstimationSummaryDetailsPageContrl.updateWithRisk';
import checkInventorySize from '@salesforce/apex/EstimationSummaryDetailsPageContrl.checkInventorySize';
import ODS_Statussign from '@salesforce/resourceUrl/ODS_Statussign';
import EstimationSummaryResource from '@salesforce/resourceUrl/EstimationSummaryResource';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class ODSEstimationSummaryDetailsPage extends LightningElement {
    @api accountIFromAura;
    @api serviceIdFromAura;
    @track tabActive = "1";
    @api newEstimationSummaryId;
    @track tabOne = true;
    @track customerName = '-';
    @track projectId = '-';
    @track otherTabs = false;
    @track otherTabs1 = false;
    @track timer;
    @track spinner = ODS_Statussign;
    @track TotalEffortInMonths = 0;
    @track TotalEffortInWeeks = 0;
    @track TotalEffortInHours = 0;
    @track unsaved = false;
    @api editbutton = false;
    connectedCallback() {
        window.addEventListener('scroll', event => this.stickyFunction());

        //alert('newEstimationSummaryId--'+this.newEstimationSummaryId);  
        if (this.newEstimationSummaryId) {
            this.otherTabs = true;
            this.otherTabs1 = false;
            checkInventorySize({ estimateSummaryId: this.newEstimationSummaryId })
                .then(data => {

                    if (data != 0) {
                        this.otherTabs1 = true;
                    }

                })
                .catch(error => {
                    console.log(error);
                });

            getCustomerNamedetails({ estimateSummaryId: this.newEstimationSummaryId })
                .then(data => {

                    this.customerName = data.Customer__r.Name;
                    this.projectId = data.Project_ID__r.Name;
                })
                .catch(error => {
                    console.log(error);
                });
        }
    }
    renderedCallback() {
        Promise.all([
            loadStyle(this, EstimationSummaryResource + '/EstimationDetails.css'),
            loadScript(this, EstimationSummaryResource + '/jquery3_6_0.js')
        ]).then(() => {
        }).catch(error => {
            this.error = error;
            console.log(' Error Occured-- ', +error);
        });
        // this.template.querySelector('lightning-tabset').activeTabValue = this.tabActive;

    }
    getWithRisk(event) {
        this.TotalEffortInMonths = event.detail;
        //  alert(this.TotalEffortInMonths)
        /*   updateWithRisk({ estimateSummaryId: this.newEstimationSummaryId, withRisk: this.TotalEffortInMonths })
               .then(data => {
   
   
               })
               .catch(error => {
                   console.log(error);
               });*/
        getCustomerNamedetails({ estimateSummaryId: this.newEstimationSummaryId })
            .then(data => {
                if (data) {
                    this.TotalEffortInWeeks = (this.TotalEffortInMonths * data.Work_Days_Per_Month__c) / data.Work_Days_Per_Week__c;
                    this.TotalEffortInHours = this.TotalEffortInMonths * data.Work_Days_Per_Month__c * data.Work_Hours_Per_Day__c;
                }

            })
            .catch(error => {
                console.log(error);
            });
    }
    handleEditButton(event) {
        this.editbutton = event.detail;
        //  alert('editbutton parent-'+event.detail)
    }
    fromChildCmp(event) {
        var count = 0;
        if (event.detail == "3") {
            this.otherTabs1 = true;
        }

        this.timer = setInterval(() => {
            this.tabActive = event.detail;
            this.otherTabs = true;
            //    this.template.querySelector('lightning-tabset').activeTabValue = this.tabActive;
            if (this.tabActive == "2") {
                /* let childinventory = this.template.querySelector('c-create-inventory');
                 if (childinventory) {
                     childinventory.disableAllTheFields();
                 }*/
            }
            if (this.tabActive == "3") {
                this.otherTabs1 = true;
                let effortCal = this.template.querySelector('.effortCal1');
                if (effortCal) {
                    effortCal.reCalculatedEffortCal(event.detail);
                }
                /* let complex = this.template.querySelector('c-create-estimation-complexity-matrix');
                  if (complex) {
                      complex.disableAllTheFields();
                  }*/
            }

            if (this.tabActive == "4") {
                this.otherTabs1 = true;
                let child = this.template.querySelector('c-create-checklist');
                /* if (child) {
                     child.triggerExitRecord(this.tabActive);
                 }
                 let childCheckList = this.template.querySelector('c-create-checklist');
                 if (childCheckList) {
                     childCheckList.disableAllTheFields();
                 }*/
            }

            if (this.tabActive == "5") {
                /*   let effortCal = this.template.querySelector('.effortCal');
                   if (effortCal) {
                       effortCal.disableAllTheFields();
                   }*/
            }
            count++;
            if (count > 7) {
                clearInterval(this.timer);
            }
        }, 1000);

    }
    calleffortcalCMP(event) {
        let effortCal = this.template.querySelector('.effortCal1');
        if (effortCal) {
            effortCal.invokeChildMethod(event.detail);
        }
    }
    resumbitEffort(event) {
        if (event.detail) {
            let effortCal = this.template.querySelector('.effortCal1');
            if (effortCal) {
                effortCal.reSubmitEffortFromInventory(event.detail);
            }
        }
    }
    callFromEstimationSummary(event) {
        //alert(JSON.stringify(event.detail));
        var res = event.detail;
        let effortCal = this.template.querySelector('.effortCal1');
        if (effortCal) {
            effortCal.triggerExitRecord();
        }
        //  this.TotalEffortInWeeks = (this.TotalEffortInMonths * res[0].perMonth) / res[0].perWeek;
        //  this.TotalEffortInHours = this.TotalEffortInMonths * res[0].perMonth * res[0].perDayHours;
    }
    handleOnactiveTab(event) {
        let preTab = this.tabActive;
        clearInterval(this.timer);
        if (preTab != event.target.value) {
            var discard = false;
            if (this.unsaved == true) {
                discard = confirm('You have unsaved changes. Do you want to Continue?');
            }
            if (discard == true || this.unsaved == false) {
                this.tabActive = event.target.value;
                this.template.querySelector('.spinnerDiv').style.display = "block";
                if (event.target.value === "1") {
                    const inventory = this.template.querySelector('c-create-estimation-summary');
                    if (inventory) {
                        inventory.triggerExitRecord(event.target.value);
                    }

                }
                if (event.target.value === "2") {
                    const inventory = this.template.querySelector('c-create-inventory');
                    if (inventory) {
                        inventory.triggerExitRecord(event.target.value);
                    }

                }
                if (event.target.value === "3") {
                    let matrix = this.template.querySelector('c-create-estimation-complexity-matrix');
                    if (matrix) {
                        matrix.triggerExitRecord(event.target.value);
                    }
                }
                if (event.target.value === "4") {
                    let checkList = this.template.querySelector('c-create-checklist');
                    if (checkList) {
                        checkList.triggerExitRecord(event.target.value);
                    }
                }
                if (event.target.value === "5") {
                    let effortCal = this.template.querySelector('.effortCal');
                    if (effortCal) {
                        effortCal.triggerExitRecord(event.target.value);
                    }
                }
                this.unsaved = false;
                this.template.querySelector('.spinnerDiv').style.display = "None";
            } else {
                this.tabActive = preTab;
                this.template.querySelector('lightning-tabset').activeTabValue = this.tabActive;
            }
        }
    }

    getEstimationSummaryId(event) {
        this.otherTabs = true;
        this.newEstimationSummaryId = event.detail;
        // alert(this.newEstimationSummaryId);
        getCustomerNamedetails({ estimateSummaryId: this.newEstimationSummaryId })
            .then(data => {

                this.customerName = data.Customer__r.Name;
                this.projectId = data.Project_ID__r.Name;
                this.template.querySelector('.panel-heading').style.display = "block";

            })
            .catch(error => {
                console.log(error);
            });
    }
    stickyFunction(event) {
        var header = this.template.querySelector('.header-info')

        var sticky = header.offsetTop;

        if (window.pageYOffset > sticky) {
            header.classList.add("sticky");
        } else {
            header.classList.remove("sticky");
        }
    }
    unsavedChangesFunction(event) {
        this.unsaved = event.detail;
    }
}
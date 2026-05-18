import { LightningElement, api, track } from 'lwc';
import ODS_Statussign from '@salesforce/resourceUrl/ODS_Statussign';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import EstimationSummaryButtonIcons from '@salesforce/resourceUrl/EstimationSummaryButtonIcons';
import ODS_Estimate_Line_Items from '@salesforce/label/c.ODS_Estimate_Line_Items';
import CalculateTotalBaseHours from '@salesforce/apex/CreateEstimationEffortCalculationCntrl.CalculateTotalBaseHours';
import getExistSDLCPhasesData from '@salesforce/apex/CreateEstimationEffortCalculationCntrl.getExistSDLCPhasesData';
import reGenerateInitialSDLCPhases from '@salesforce/apex/CreateEstimationEffortCalculationCntrl.reGenerateInitialSDLCPhases';
import generateOtherActivities from '@salesforce/apex/CreateEstimationEffortCalculationCntrl.generateOtherActivities';
import getEstimationRecord from '@salesforce/apex/CreateEstimationEffortCalculationCntrl.getEstimationRecord';
import insertEffortCalculations from '@salesforce/apex/CreateEstimationEffortCalculationCntrl.insertEffortCalculations';
import updateEstimationSummary from '@salesforce/apex/CreateEstimationEffortCalculationCntrl.updateEstimationSummary';
import getExistOtherActivitiesEffort from '@salesforce/apex/CreateEstimationEffortCalculationCntrl.getExistOtherActivitiesEffort';
import getExistProjectSpecificActivitiesEffort from '@salesforce/apex/CreateEstimationEffortCalculationCntrl.getExistProjectSpecificActivitiesEffort';
import getTotalHoursForEstimation from '@salesforce/apex/CreateEstimationEffortCalculationCntrl.getTotalHoursForEstimation';
import insertODSEstimate from '@salesforce/apex/CreateEstimationEffortCalculationCntrl.insertODSEstimate';
import getInventoryLineItem from '@salesforce/apex/CreateEstimationEffortCalculationCntrl.getInventoryLineItem';


import EstimationSummaryResource from '@salesforce/resourceUrl/EstimationSummaryResource';
import checkEstimationIsApproved from '@salesforce/apex/CreateEstimationInventoryController.checkEstimationIsApproved';

import CheckInitiativeIsSavedOrNot from '@salesforce/apex/ExportToInitiativeController.CheckInitiativeIsSavedOrNot';
import createEstimationElement from '@salesforce/apex/ExportToInitiativeController.createEstimationElement';
import getReEvaluateInitiatives from '@salesforce/apex/CreateEstimationSummaryController.getReEvaluateInitiatives';
import clearStatusToMakeEdit from '@salesforce/apex/CreateEstimationSummaryController.clearStatusToMakeEdit';


import validationForApproverButton from '@salesforce/apex/CreateEstimationInventoryController.validationForApproverButton';
import approveTheEstimation from '@salesforce/apex/CreateEstimationSummaryController.approveTheEstimation';
import getStatusResult from '@salesforce/apex/CreateEstimationInventoryController.getStatusResult';
import getNotApproverUser from '@salesforce/apex/CreateEstimationSummaryController.getNotApproverUser';
import getcurrentUserAccessForEstimation from '@salesforce/apex/CreateEstimationSummaryController.getcurrentUserAccessForEstimation';
import getcurrentUserPM from '@salesforce/apex/CreateEstimationSummaryController.getcurrentUserPM';


export default class CreateEffortCalculation extends LightningElement {
    @track spinner = ODS_Statussign;
    @track saveButton = EstimationSummaryButtonIcons + '/save_icon.svg';
    @track addButton = EstimationSummaryButtonIcons + '/add_icon.svg';
    @track cancelButton = EstimationSummaryButtonIcons + '/delete_icon.svg';
    @track exportButton = EstimationSummaryButtonIcons + '/download_icon.svg';
    @track exportToInitiativeButton = EstimationSummaryButtonIcons + '/export_initiative_icon.svg';
    @track editButtonIcon = EstimationSummaryButtonIcons + '/edit_icon.svg';
    @track approveButtonIcon = EstimationSummaryButtonIcons + '/approve_icon.svg';

    @track approvedButton = false;
    @api accountId = '';
    @track error = '';
    @api estimationSummary = '';
    @track teamProductivityValue = 0.9;
    @track withRiskValue = 0;
    @track baseEffortDeclarativeValue = 0;
    @track baseEffortDeclarativePercentValue = 0;
    @track withoutRiskValue = 0;
    @track baseEffortProgrammingValue = 0;
    @track baseEffortProgrammingPercentValue = 0;
    @track totalBaseEffortValue = 0;
    @track newSdlcPhaseWise = [];
    @track newOtherActivities = [];
    @track newSpecificActivities = [];
    @track estimateLineItem = [];
    @track rows = [];
    @track index = 0;
    @track autoFlag = false;
    @track ProjectSpecificForOtherActivities = 0.0;
    @track isShowModal = false;
    @track risksActivity = 0;
    @track totalActualHours = 0;
    @track isApproved = false;
    @track disableForAll = false;
    @track exportToInitiative = false;
    @api enableEditButton = false;
    @api edit = false;

    @track approverUserList = [];
    @track approverUserValue = '';
    @track isShowModalForApprovalUser = false;
    @track approverButtonOnPopUp = true;
    @track activeProgramManager = false;
    @track enableForDeliveryRole = false;
    


    @api invokeChildMethod(strString) {
        console.log('strString--' + JSON.stringify(strString));
        this.baseEffortDeclarativeValue = strString[0].totalofDeclarative;
        this.baseEffortDeclarativePercentValue = strString[0].totalofDeclarativePercentage;
        this.baseEffortProgrammingValue = strString[0].totalOfProgramming;
        this.baseEffortProgrammingPercentValue = strString[0].totalOfProgrammingPercentage;
        this.totalBaseEffortValue = strString[0].totalEffortOfMonths;
        //this.reGenerateSDLCPhases();
        this.getSDLCPhasesMethod();
    }
    @api reCalculatedEffortCal(strString) {

        const custEvent0 = new CustomEvent(
            'callunsavedchanges', {
            detail: false,
        });
        this.dispatchEvent(custEvent0);
        CalculateTotalBaseHours({ estimationSummary: this.estimationSummary })
            .then(result => {
                if (result) {
                    this.baseEffortDeclarativeValue = result.totalBaseEffortDeclarative;
                    this.baseEffortDeclarativePercentValue = result.totalBaseEffortDeclarativePercentage;
                    this.baseEffortProgrammingValue = result.totalBaseEffortProgramming;
                    this.baseEffortProgrammingPercentValue = result.totalBaseEffortProgrammingPercentage;
                    this.totalBaseEffortValue = result.totalBaseEffortPersonMonth;
                    this.teamProductivityValue = result.teamProductivity;

                    this.getSDLCPhasesMethod();

                }
            })
            .catch(error => {
                console.log(error);
            });
    }
    showModalBox() {

        let DevelopmentCodePW = 0;
        let DevelopmentCode = Array.from(this.template.querySelectorAll("[data-phases='Development (Code and unit testing)']"));
        DevelopmentCode.map(row => {
            if (row.name == 'person week') {
                DevelopmentCodePW = row.value;
            }
        });
        /*var productionDeploymentPW = 0;
        let pDeploPW = Array.from(this.template.querySelectorAll("[data-rowno='Production Deployment']"));
        pDeploPW.map(row => {
            if (row.name == 'person week') {
                productionDeploymentPW = row.value;
            }
        });
        var sandboxnDeploymentPW = 0;
        let sDeploPW = Array.from(this.template.querySelectorAll("[data-rowno='Sandbox Deployment']"));
        sDeploPW.map(row => {
            if (row.name == 'person week') {
                sandboxnDeploymentPW = row.value;
            }
        });*/
        let TotalOtherActivitiesPW = this.template.querySelector('.totalPersonWeeksSDLCOtherActivity').value;
        let TotalOtherProjectSpecificActivitiesPW = this.template.querySelector('.totalPersonWeeksProjectSpecific').value;
        let developmentPercentage = this.template.querySelector("[data-phases='Development (Code and unit testing)']").value;

        var deploymentValue = this.calculateDeploymentPersonWeek();

        var inventoryLineItem = [];
        getInventoryLineItem({
            estimationSummary: this.estimationSummary, OtherActivitiesPersonWeek: TotalOtherActivitiesPW, SpecificActivitiesPersonWeek: TotalOtherProjectSpecificActivitiesPW,
            ProdDeploymentPW: deploymentValue, DevelopmentPW: DevelopmentCodePW, developmentPercentage: developmentPercentage / 100
        })
            .then(result => {
                if (result) {
                    inventoryLineItem = result;
                    console.log(inventoryLineItem);
                    this.showSpinner();
                    var totalHours = 0;
                    var RequirementsPW = 0;
                    var DesignPW = 0;
                    var DevelopmentPW = 0;
                    var IntTestingPW = 0;
                    var SystemTestingPW = 0;
                    var UATTestingPW = 0;
                    var Others =0;
                    let RequirementsRow = Array.from(this.template.querySelectorAll("[data-phases='Requirements']"));
                    RequirementsRow.map(row => {
                        if (row.name == 'person week') {
                            /// RequirementsPW = parseFloat(row.value);
                            RequirementsPW = row.value;
                        }
                    });
                    console.log('--=-RequirementsPW'+RequirementsPW)
                    let DesignRow = Array.from(this.template.querySelectorAll("[data-phases='Design']"));
                    DesignRow.map(row => {
                        if (row.name == 'person week') {
                            // DesignPW = parseFloat(row.value);
                            DesignPW = row.value;
                        }
                    });
                    let DevelopmentRow = Array.from(this.template.querySelectorAll("[data-phases='Development (Code and unit testing)']"));
                    DevelopmentRow.map(row => {
                        if (row.name == 'person week') {
                            //DevelopmentPW = parseFloat(row.value);
                            DevelopmentPW = row.value;
                        }
                    });
                    let InteTestingRow = Array.from(this.template.querySelectorAll("[data-phases='Integration Testing']"));
                    InteTestingRow.map(row => {
                        if (row.name == 'person week') {
                            //IntTestingPW = parseFloat(row.value);
                            IntTestingPW = row.value;
                        }
                    });
                    let SystemTestingRow = Array.from(this.template.querySelectorAll("[data-phases='System Testing']"));
                    SystemTestingRow.map(row => {
                        if (row.name == 'person week') {
                            //SystemTestingPW = parseFloat(row.value);
                            SystemTestingPW = row.value;
                        }
                    });
                    let UATRow = Array.from(this.template.querySelectorAll("[data-phases='User Acceptance Testing (UAT)']"));
                    UATRow.map(row => {
                        if (row.name == 'person week') {
                            UATTestingPW = row.value;
                        }
                    });
                    var testingPW = IntTestingPW + SystemTestingPW + UATTestingPW;

                   /* let OtherRow = Array.from(this.template.querySelectorAll("[data-classification='other']"));
                    OtherRow.map(row => {
                        if (row.name == 'person week') {
                            Others = row.value;
                        }
                    });
*/
                    getTotalHoursForEstimation({ estimationSummary: this.estimationSummary })
                        .then(result => {
                            totalHours = parseFloat(result);
                            let TotalOtherActivities = this.template.querySelector('.totalPersonWeeksSDLCOtherActivity').value;
                            let TotalOtherProjectSpecificActivities = this.template.querySelector('.totalPersonWeeksProjectSpecific').value;
                            var productionDeployment = 0;
                            let selectedRow = Array.from(this.template.querySelectorAll("[data-rowno='Production Deployment']"));
                            selectedRow.map(row => {
                                if (row.name == 'person week') {
                                    productionDeployment = row.value;
                                }
                            });
                            var sandboxDeployment = 0;
                            let sandboxDeploymentRow = Array.from(this.template.querySelectorAll("[data-rowno='Sandbox Deployment']"));
                            sandboxDeploymentRow.map(row => {
                                if (row.name == 'person week') {
                                    sandboxDeployment = row.value;
                                }
                            });
                            var deployment = deploymentValue;
                            var base = ((TotalOtherActivities + TotalOtherProjectSpecificActivities) - deployment) * totalHours;
                            base = base.toFixed(2);
                            console.log('base-' + base)
                            if (ODS_Estimate_Line_Items) {
                                this.estimateLineItem = [];
                                const a = ODS_Estimate_Line_Items.split("|");
                                this.totalActualHours = 0;
                                for (var i = 0; i < a.length; i++) {
                                    var subtable = false;
                                    var percentage = 0;
                                    var actualHours = 0;
                                    if (a[i].split("==")[0] === 'Analysis') {
                                        console.log('percentage'+percentage)
                                        console.log('actualHours'+actualHours)
                                        percentage = this.template.querySelector("[data-phases='Requirements']").value;
                                        percentage = percentage / 100;
                                        actualHours = (base * percentage) + (RequirementsPW * totalHours);
                                        console.log('==percentage1'+percentage)
                                        console.log('==actualHours1'+actualHours)
                                    }
                                    if (a[i].split("==")[0] === 'Design') {
                                        
                                        percentage = this.template.querySelector("[data-phases='Design']").value;
                                        percentage = percentage / 100;
                                        actualHours = (base * percentage) + (DesignPW * totalHours);
                                    }
                                    if (a[i].split("==")[0] === 'Development') {
                                        percentage = this.template.querySelector("[data-phases='Development (Code and unit testing)']").value;
                                        percentage = percentage / 100;
                                        actualHours = (base * percentage) + (DevelopmentPW * totalHours);

                                        subtable = true;
                                    }
                                    if (a[i].split("==")[0] === 'System Testing') {
                                        var intTesting = this.template.querySelector("[data-phases='Integration Testing']").value;
                                        var systemTesting = this.template.querySelector("[data-phases='System Testing']").value;
                                        var UAT = this.template.querySelector("[data-phases='User Acceptance Testing (UAT)']").value;
                                        percentage = parseFloat(intTesting) + parseFloat(systemTesting) + parseFloat(UAT);
                                        percentage = percentage / 100;

                                        actualHours = (base * percentage) + (testingPW * totalHours);
                                    }
                                    if (a[i].split("==")[0] === 'Production Deployment') {
                                        actualHours = productionDeployment * totalHours;
                                    }
                                    if (a[i].split("==")[0] === 'Sandbox Deployment') {
                                        actualHours = sandboxDeployment * totalHours;
                                    }
                                    this.totalActualHours = Math.round(this.totalActualHours + actualHours);
                                    // actualHours = actualHours.toFixed(2);
                                    // this.totalActualHours=this.totalActualHours.toFixed(2);
                                    this.estimateLineItem.push({
                                        LineItem: a[i].split("==")[0],
                                        Percentage: Math.round(percentage * 100),
                                        ActualHours: Math.round(actualHours),
                                        subtable: subtable,
                                        newOtherValue:false,
                                        inventory: inventoryLineItem
                                    });
                                }
                                const rowsWithDeployment = this.template.querySelectorAll('.activityTextArea');
                                rowsWithDeployment.forEach((row, index) => {
                                    if (row.value != 'Production Deployment' && row.value != 'Sandbox Deployment') {
                                        const activityText = row.value.toLowerCase();
                                        if (activityText.includes('deployment')) {
                                            var actualHours = 0;
                                            const parentTr = row.closest('tr');
                                            const rowNumber = parentTr.dataset.rowno;
                                            const personWeeksElement = this.template.querySelector('.personWeeksSpecificActivities[data-rowno="' + rowNumber + '"]');
                                            actualHours = personWeeksElement.value * totalHours;
                                            this.estimateLineItem.push({
                                                LineItem: row.value,
                                                Percentage: Math.round(percentage * 100),
                                                ActualHours: Math.round(actualHours),
                                                subtable: false,
                                                newOtherValue:false,
                                                inventory: inventoryLineItem
                                            });
                                        } 
                                        //added for other 14/11/2023
                                        else if(row.dataset.classification==='other' || row.dataset.other=='true') {
                                            //this.isChecked = this.activityText ? true : false;
                                            var actualHours = 0;
                                            const parentTr = row.closest('tr');
                                            const rowNumber = parentTr.dataset.rowno;
                                            const personWeeksElement = this.template.querySelector('.personWeeksSpecificActivities[data-rowno="' + rowNumber + '"]');
                                            actualHours = personWeeksElement.value * totalHours;
                                           // alert(actualHours)
                                          //  alert(personWeeksElement.value)
                                         // alert(row.value)
                                            if (personWeeksElement.value > 0 ) {
                                            this.estimateLineItem.push({
                                                LineItem: row.value,
                                                Percentage: Math.round(percentage * 100),
                                                ActualHours: Math.round(actualHours),
                                                subtable: false,
                                                newOtherValue:true,
                                                inventory: inventoryLineItem
                                            });
                                            this.totalActualHours = Math.round(this.totalActualHours + actualHours);

                                        }
                                        }
                                    }
                                });
                                this.hideSpinner();
                                this.isShowModal = true;
                            }
                        })
                        .catch(error => {
                            console.log(error);
                        });
                }
            })
            .catch(error => {
                console.log(error);
            });
        this.calculatedODSEstimate();
    }

    hideModalBox() {
        this.isShowModal = false;
    }
    @api triggerExitRecord(strString) {
        // this.reGenerateSDLCPhases();
        this.getTotalBase();
        this.disableAllTheFields();
        this.handleExportToInitiatives();
        this.handleForEnableEditButton();
        this.enableApproverButtonForTPM();
        if (this.edit == true) {
            this.enableEditButton = false;
            this.isApproved = false;
            this.disableForAll = false;
            this.template.querySelectorAll('.actionButton').forEach(item => {
                item.style.pointerEvents = "none";

            });
        }
        this.checkCurrentUserIsPM();

    }
    calculateDeploymentPersonWeek() {
        const rowsWithDeployment = this.template.querySelectorAll('.activityTextArea');
        let totalPersonWeeks = 0;

        rowsWithDeployment.forEach((row, index) => {
            const activityText = row.value.toLowerCase();
            if (activityText.includes('deployment')) {
                const parentTr = row.closest('tr');
                const rowNumber = parentTr.dataset.rowno;
                const personWeeksElement = this.template.querySelector('.personWeeksSpecificActivities[data-rowno="' + rowNumber + '"]');
                totalPersonWeeks += parseFloat(personWeeksElement.value);
            }
            else if(row.dataset.classification==='other' || row.dataset.other=='true') {
                const parentTr = row.closest('tr');
                const rowNumber = parentTr.dataset.rowno;
                const personWeeksElement = this.template.querySelector('.personWeeksSpecificActivities[data-rowno="' + rowNumber + '"]');
                totalPersonWeeks += parseFloat(personWeeksElement.value);
  
            }
        });
        return totalPersonWeeks;
    }
    renderedCallback() {
        // Promise.all([loadStyle(this, EstimateEffortCalculationsCSS)], loadScript(this, jquery3_6_0))
        Promise.all([
            loadStyle(this, EstimationSummaryResource + '/EstimateEffortCalculationsCSS.css'),
            loadScript(this, EstimationSummaryResource + '/jquery3_6_0.js')
        ]).then(() => {
        }).catch(error => {
            this.error = error;
            console.log(' Error Occured-- ', +error);
        });
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
    handleAddRow() {
        if (this.rows.length != 0) {
            this.index++;
        } else {
            this.index = 1;
        }
        this.rows.push(this.index);
    }

    handleTeamProductivity(event) {
        var decimalValue = event.target.value;
        if (decimalValue == 0.7 || decimalValue == 0.8 || decimalValue == 0.9 || decimalValue == 1) {
            // this.template.querySelector('.teamProductivity').value = 1;
            this.teamProductivityValue = decimalValue;
        } else {
            this.template.querySelector('.teamProductivity').value = 0.9;
            this.teamProductivityValue = 0.9;
        }

        this.getSDLCPhasesMethod();

    }

    connectedCallback() {


        if (this.estimationSummary) {
            this.getTotalBase();
            this.disableAllTheFields();
            this.handleExportToInitiatives();
            this.handleForEnableEditButton();
            this.enableApproverButtonForTPM();
        }
        getcurrentUserAccessForEstimation()
            .then(data => {
                this.enableForDeliveryRole = data;
                if (data == false) {
                    //initial status based on overall estimation record status identified by disableAllTheFields()
                    this.disableForAll = this.isApproved;

                    this.isApproved = true;
                    this.template.querySelectorAll('.actionButton').forEach(item => {
                        item.style.pointerEvents = "none";

                    });
                }
            })
            .catch(error => {
                console.log('update--' + error);
            });
        this.checkCurrentUserIsPM();

    }
    checkCurrentUserIsPM() {
        getcurrentUserPM({ summaryId: this.estimationSummary })
            .then(data => {
                this.enableEditButton = data;
            })
            .catch(error => {
                console.log('update--' + error);
            });

    }
    handleForEditButton() {
        let text = "Do you want to re-evaluate the estimates?";
        if (confirm(text) == true) {
            this.isApproved = false;
            this.disableForAll = false;
            this.enableEditButton = false;

            this.template.querySelectorAll('.actionButton').forEach(item => {
                item.style.pointerEvents = "none";

            });

            clearStatusToMakeEdit({ estimatedId: this.estimationSummary })
                .then(result => {
                    this.handleExportToInitiatives();
                })
                .catch(error => {
                    console.log(error);
                });

            const custEvent = new CustomEvent(
                'editbutton', {
                detail: true,
            });
            this.dispatchEvent(custEvent);
        }
    }
    handleForEnableEditButton() {
        this.enableEditButton = false;
        getReEvaluateInitiatives({ estimatedId: this.estimationSummary })
            .then(result => {
                if (result == true && this.edit == false) {
                    this.enableEditButton = true;
                }
            })
            .catch(error => {
                console.log(error);
            });
    }

    @api
    disableAllTheFields() {
        checkEstimationIsApproved({ estimateSummaryId: this.estimationSummary })
            .then(result => {
                if (result == true && this.edit == false) {
                    this.isApproved = true;
                    this.disableForAll = true;
                    this.template.querySelectorAll('.actionButton').forEach(item => {
                        item.style.pointerEvents = "none";

                    });
                }
            })
            .catch(error => {
                console.log(error);
            });
    }
    @api
    getTotalBase() {
        this.showSpinner();
        CalculateTotalBaseHours({ estimationSummary: this.estimationSummary })
            .then(result => {
                if (result) {
                    console.log('result--' + JSON.stringify(result));

                    this.baseEffortDeclarativeValue = result.totalBaseEffortDeclarative;
                    this.baseEffortDeclarativePercentValue = result.totalBaseEffortDeclarativePercentage;
                    this.baseEffortProgrammingValue = result.totalBaseEffortProgramming;
                    this.baseEffortProgrammingPercentValue = result.totalBaseEffortProgrammingPercentage;
                    this.totalBaseEffortValue = result.totalBaseEffortPersonMonth;
                    this.teamProductivityValue = result.teamProductivity;
                    this.getSDLCPhasesMethod();
                }
            })
            .catch(error => {
                console.log(error);
            });
        this.hideSpinner();
    }

    getSDLCPhasesMethod() {
        this.showSpinner();
        this.newSdlcPhaseWise = [];
        getExistSDLCPhasesData({ teamProductivity: this.teamProductivityValue, totalBaseEffortMonth: this.totalBaseEffortValue, estimationSummary: this.estimationSummary })
            .then(result => {
                this.newSdlcPhaseWise = result;
                var count;
                var timer
                timer = setInterval(() => {
                    const e = new Event("focusout");
                    const element = this.template.querySelectorAll('.projectSpecificWiseClass')
                    if (element) {
                        for (var i = 0; i < element.length; i++) {
                            this.autoFlag = true;
                            element[i].dispatchEvent(e);
                            clearInterval(timer);
                            break;
                        }
                    }
                    count++;
                    if (count > 3) {
                        clearInterval(timer);
                    }
                }, 1000);
            })
            .catch(error => {
                console.log(error);
            });
        this.newOtherActivities = [];
        getExistOtherActivitiesEffort({ estimationSummary: this.estimationSummary })
            .then(result => {
                this.newOtherActivities = result;
                for (var i = 0; i < this.newOtherActivities.length; i++) {
                    if (this.newOtherActivities[i].Activity == 'Effort for unforeseen risks, situations') {
                        this.risksActivity = this.newOtherActivities[i].PersonMonth;
                    }
                }
                var count;
                var timer
                timer = setInterval(() => {
                    const e = new Event("focusout");
                    const element = this.template.querySelectorAll('.projectSpecificOtherClass')
                    if (element) {
                        for (var i = 0; i < element.length; i++) {
                            element[i].dispatchEvent(e);
                            clearInterval(timer);
                        }
                    }

                    count++;
                    if (count > 2) {
                        clearInterval(timer);
                    }
                }, 1000);
                this.sumForPersonMonthWeekForSLDCPhases();
                this.sumForPersonMonthWeekForOtherActivity();
                this.sumForPersonMonthWeekForProjectSpecific();
            })
            .catch(error => {
                console.log(error);
            });
        this.newSpecificActivities = [];
        getExistProjectSpecificActivitiesEffort({ estimationSummary: this.estimationSummary })
            .then(result => {
                this.newSpecificActivities = result;
                this.sumForPersonMonthWeekForSLDCPhases();
                this.sumForPersonMonthWeekForOtherActivity();
                this.sumForPersonMonthWeekForProjectSpecific();
            })
            .catch(error => {
                console.log(error);
            });
        this.sumForPersonMonthWeekForSLDCPhases();
        this.sumForPersonMonthWeekForOtherActivity();
        this.sumForPersonMonthWeekForProjectSpecific();
        this.hideSpinner();
    }

    handleForSumOfProjectSpeicficSDLCWise(event) {
        if (this.autoFlag == false) {
            this.reGenerateSDLCPhases();
        }
        let rowsValues = Array.from(this.template.querySelectorAll(".projectSpecificWiseClass"));
        var sum = 0.0;
        rowsValues.map(row => {

            sum = parseFloat(sum) + parseFloat(row.value);
        });
        sum.toFixed(1);
        this.template.querySelector(".totalProjectSpecificSDLCPhase").value = sum;
        if (sum != 100) {
            this.template.querySelector(".totalProjectSpecificSDLCPhase").style.background = 'red';
            this.template.querySelector(".totalProjectSpecificSDLCPhase").style.color = 'white';

        } else {
            this.template.querySelector(".totalProjectSpecificSDLCPhase").style.background = '';
            this.template.querySelector(".totalProjectSpecificSDLCPhase").style.color = 'black';

        }

        this.autoFlag = false;

        this.sumForPersonMonthWeekForSLDCPhases();
        this.sumForPersonMonthWeekForOtherActivity();
        this.sumForPersonMonthWeekForProjectSpecific();

    }
    reGenerateSDLCPhases() {
        let SDLCPhasesDraft = [];
        let rowsValues = Array.from(this.template.querySelectorAll("tr.SDLCPhasesTable"));
        rowsValues.map(row => {
            let SDLCPhasesName = row.querySelector(".SDLCPhasesName");
            let projectSpecificWiseClass = row.querySelector(".projectSpecificWiseClass");
            let personMonthsSDLCPhases = row.querySelector(".personMonthsSDLCPhases");
            let personWeeksSDLCPhases = row.querySelector(".personWeeksSDLCPhases");
            SDLCPhasesDraft.push({
                SDLCPhasesName: SDLCPhasesName.value,
                ProjectSpecific: projectSpecificWiseClass.value,
                personMonth: personMonthsSDLCPhases.value,
                personWeek: personWeeksSDLCPhases.value
            });
        });
        console.log('SDLCPhasesDraft---' + JSON.stringify(SDLCPhasesDraft));
        let development = this.template.querySelector("[data-phases='Development (Code and unit testing)']");
        if (development) {
            reGenerateInitialSDLCPhases({ teamProductivity: this.teamProductivityValue, totalBaseEffortMonth: this.totalBaseEffortValue, estimationSummary: this.estimationSummary, SDLCDreaftRes: JSON.stringify(SDLCPhasesDraft), developmentCode: development.value })
                .then(result => {
                    if (result) {
                        for (var i = 0; i < result.length; i++) {
                            let selectedRow = Array.from(this.template.querySelectorAll("[data-phases='" + result[i].Phases + "']"));
                            selectedRow.map(row => {
                                if (row.name == 'person month') {
                                    row.value = result[i].PersonMonth;
                                }
                                if (row.name == 'person week') {
                                    row.value = result[i].PersonWeeks;
                                }
                            });
                        }


                        const e = new Event("focusout");
                        const element = this.template.querySelectorAll('.projectSpecificOtherClass')
                        if (element) {
                            for (var i = 0; i < element.length; i++) {
                                element[i].dispatchEvent(e);
                            }
                        }

                    }
                    this.sumForPersonMonthWeekForSLDCPhases();
                })
                .catch(error => {
                    console.log(error);
                });
        }
    }
    handleFocusOutprojectSpecificOther(event) {

        var applicable = event.target.dataset.applicable;
        var activity = event.target.dataset.activity;
        let SDLCPhasesDraft = [];
        let rowsValues = Array.from(this.template.querySelectorAll("tr.SDLCPhasesTable"));
        rowsValues.map(row => {
            let SDLCPhasesName = row.querySelector(".SDLCPhasesName");
            let projectSpecificWiseClass = row.querySelector(".projectSpecificWiseClass");
            let personMonthsSDLCPhases = row.querySelector(".personMonthsSDLCPhases");
            let personWeeksSDLCPhases = row.querySelector(".personWeeksSDLCPhases");

            SDLCPhasesDraft.push({
                SDLCPhasesName: SDLCPhasesName.value,
                ProjectSpecific: projectSpecificWiseClass.value,
                personMonth: personMonthsSDLCPhases.value,
                personWeek: personWeeksSDLCPhases.value
            });
        });
        generateOtherActivities({ estimationSummary: this.estimationSummary, applicable: applicable, SDLCDreaftRes: JSON.stringify(SDLCPhasesDraft), changedProjectSpecific: event.target.value })
            .then(result => {
                if (result) {

                    let selectedRow = Array.from(this.template.querySelectorAll("[data-activity='" + activity + "']"));
                    selectedRow.map(row => {
                        if (row.name == 'person month') {
                            row.value = result.PersonMonth;
                        }
                        if (row.name == 'person week') {
                            row.value = result.PersonWeeks;
                        }
                    });
                    if (activity == 'Effort for unforeseen risks, situations') {
                        this.risksActivity = result.PersonMonth;
                    }
                    this.sumForPersonMonthWeekForOtherActivity();
                }
            })
            .catch(error => {
                console.log(error);
            });

    }
    handlePersonMonthSpecificActivites(event) {
        try {
            var rowno = event.target.dataset.rowno;
            var changedValue = event.target.value;
            if (changedValue.length == 0) {
                changedValue = 0;
            }
            getEstimationRecord({ estimationSummary: this.estimationSummary, personMonth: parseFloat(changedValue) })
                .then(result => {
                    if (result) {
                        let selectedRow = Array.from(this.template.querySelectorAll("[data-rowno='" + rowno + "']"));
                        selectedRow.map(row => {
                            if (row.name == 'person week') {
                                row.value = result;
                            }
                            if (row.name == 'person month') {
                                row.value = changedValue;
                            }
                        });
                    }
                    this.sumForPersonMonthWeekForProjectSpecific();
                })
                .catch(error => {
                    console.log(error);
                });
        } catch (e) {
            alert(JSON.stringify(e))
        }
    }
    @track InventoryFlag = false;
    @api
    reSubmitEffortFromInventory(event) {
        this.InventoryFlag = true;
        this.handleForInsertEffort(false);
        // this.calculatedODSEstimate();

    }
    handleForSaveEffortCalculation() {
            this.handleForInsertEffort(true);
       
    }
    handleForInsertEffort(isEffortSubmit) {
        this.calculatedODSEstimate();
        this.showSpinner();
        let totalProjectSpecificSDLCPhase = this.template.querySelector(".totalProjectSpecificSDLCPhase");
        if (totalProjectSpecificSDLCPhase.value != 100) {
            alert('Please make sure the sum Of The Project Specific should be 100% on the SDLC Phases (Phase-wise Effort Distribution)...!')
            this.hideSpinner();

        } else {
            let SDLCPhasesWise = [];
            let OtherActivitiesEffort = [];
            let ProjectSpecificActivitiesEffort = [];
            let table1Validation = false;
            let OtherActivitiesValidtion = false;

            let SDLCPhasesWiseRow = Array.from(this.template.querySelectorAll("tr.SDLCPhasesTable"));
            SDLCPhasesWiseRow.map(row => {
                let SDLCPhasesName = row.querySelector(".SDLCPhasesName");
                let projectSpecificWiseClass = row.querySelector(".projectSpecificWiseClass");
                let recommendedEffortSLDC = row.querySelector(".recommendedEffortSLDC");
                let personMonthsSDLCPhases = row.querySelector(".personMonthsSDLCPhases");
                let personWeeksSDLCPhases = row.querySelector(".personWeeksSDLCPhases");
                let rationaleSDLCPhases = row.querySelector(".rationaleSDLCPhases");
                if (projectSpecificWiseClass.value && !rationaleSDLCPhases.value) {
                    if (projectSpecificWiseClass.value != recommendedEffortSLDC.value) {
                        table1Validation = true;
                    }
                }
                if (!table1Validation) {
                    SDLCPhasesWise.push({
                        SDLCPhasesName: SDLCPhasesName.value,
                        ProjectSpecific: projectSpecificWiseClass.value,
                        personMonth: personMonthsSDLCPhases.value,
                        personWeek: personWeeksSDLCPhases.value,
                        Rationale: rationaleSDLCPhases.value
                    });
                }
            });

            let OtherActivitiesEffortRow = Array.from(this.template.querySelectorAll("tr.OtherActivitiesEffort"));
            OtherActivitiesEffortRow.map(row => {
                let Activity = row.querySelector(".activityClass");
                let Applicable = row.querySelector(".applicableClass");
                let ProjectSpecific = row.querySelector(".projectSpecificOtherClass");
                let PersonMonths = row.querySelector(".personMonthsOtherActivities");
                let PersonWeeks = row.querySelector(".personWeeksOtherActivities");
                let Rationale = row.querySelector(".commentsOthers");

                OtherActivitiesEffort.push({
                    Activity: Activity.value,
                    Applicable: Applicable.value,
                    ProjectSpecific: ProjectSpecific.value,
                    personMonth: PersonMonths.value,
                    personWeek: PersonWeeks.value,
                    Rationale: Rationale.value
                });
            });

            let ProjectSpecificActivitiesRow = Array.from(this.template.querySelectorAll("tr.ProjectSpecificActivitiesRow"));
            debugger;
            ProjectSpecificActivitiesRow.map(row => {
                let Activity = row.querySelector(".activityTextArea");
                let PersonMonths = row.querySelector(".personMonthSpecificActivities");
                let PersonWeeks = row.querySelector(".personWeeksSpecificActivities");
                let Rationale = row.querySelector(".commentsSpecific");
                //added for other 14/11/2023
                let isOther = Activity.dataset.classification === 'other' || Activity.dataset.other=='true';
                debugger;
                if(Activity.value ==undefined || Activity.value == null){
                   OtherActivitiesValidtion = true;
                    
                }
                else{
                    ProjectSpecificActivitiesEffort.push({
                        Activity: Activity.value,
                        personMonth: PersonMonths.value,
                        personWeek: PersonWeeks.value,
                        Rationale: Rationale.value,
                        NewOtherValue: isOther
                    });
                }
                
            });

            if (table1Validation == true) {
                alert('Please Fill The Rationale If Different Then Recommended Fields When Project Specific Fields Have Value..!');
                this.hideSpinner();
            }
            if(OtherActivitiesValidtion == true){
                alert('Please fill the Activity value in Effort Calculation for Other Project Specific Activities Section ');
                this.hideSpinner();
            }
            if (table1Validation == false && OtherActivitiesValidtion == false) {
                insertEffortCalculations({ estimationSummary: this.estimationSummary, SDLCPhaseEffortRes: JSON.stringify(SDLCPhasesWise), OtherActivityEffortRes: JSON.stringify(OtherActivitiesEffort), ProjectSpecificActivityEffortRes: JSON.stringify(ProjectSpecificActivitiesEffort) })
                    .then(result => {
                        this.rows = [];
                        this.index = 0;
                        this.hideSpinner();
                        if (!this.InventoryFlag) {
                            alert('Effort calculations are successfully submitted!');
                        }
                        const custEvent = new CustomEvent(
                            'callunsavedchanges', {
                            detail: false,
                        });
                        this.dispatchEvent(custEvent);
                        this.getTotalBase();
                        this.InventoryFlag = false;

                        let teamProductivity = this.template.querySelector(".teamProductivity");
                        let withRisk = this.template.querySelector(".withRisk");
                        let WithoutRisk = this.template.querySelector(".withoutRisk");

                        updateEstimationSummary({ estimationSummary: this.estimationSummary, teamProductivity: teamProductivity.value, withRisk: withRisk.value, withOutRisk: WithoutRisk.value })
                            .then(result => {
                                if (result) {

                                }
                            })
                            .catch(error => {
                                console.log(error);
                            });

                        //need to refresh entire page on effort calculation Submit, otherwise the old values 
                        //in effort calculation tab LWC components are getting used for calculation 
                        //on Summary & Inventory tab submit. NOTE: Refresh the page only on the Submit of the effort calcualtion tab
                        if (isEffortSubmit) {
                            this.updateEfforCalculationView();
                        }

                    })
                    .catch(error => {
                        alert(JSON.stringify(error));
                        this.hideSpinner();
                    });

            }
        }

    }

    updateEfforCalculationView() {
        setTimeout(() => {
            window.location.reload();
        }, 1000);
    }

    handleReset() {
        this.rows = [];
        this.getTotalBase();
    }
    sumForPersonMonthWeekForSLDCPhases() {
        //Calculate for person month
        let personMonthRow = Array.from(this.template.querySelectorAll(".personMonthsSDLCPhases"));
        var sumPersonMonth = 0;
        personMonthRow.map(row => {
            sumPersonMonth = sumPersonMonth + row.value;
        });
        this.template.querySelector(".totalPersonMonthsSDLCPhase").value = sumPersonMonth;

        //Calculate for person Week
        let personWeekRow = Array.from(this.template.querySelectorAll(".personWeeksSDLCPhases"));
        var sumPersonWeek = 0;
        personWeekRow.map(row => {
            sumPersonWeek = sumPersonWeek + row.value;
        });
        this.template.querySelector(".totalPersonWeeksSDLCPhase").value = sumPersonWeek;
        this.calculateRiskValues();

    }
    sumForPersonMonthWeekForOtherActivity() {
        //Calculate for person month
        let personMonthRow = Array.from(this.template.querySelectorAll(".personMonthsOtherActivities"));
        var sumPersonMonth = 0;
        personMonthRow.map(row => {
            sumPersonMonth = sumPersonMonth + row.value;
        });
        this.template.querySelector(".totalPersonMonthsSDLCOtherActivity").value = sumPersonMonth;

        //Calculate for person Week
        let personWeekRow = Array.from(this.template.querySelectorAll(".personWeeksOtherActivities"));
        var sumPersonWeek = 0;
        personWeekRow.map(row => {
            sumPersonWeek = sumPersonWeek + row.value;
        });
        this.template.querySelector(".totalPersonWeeksSDLCOtherActivity").value = sumPersonWeek;
        this.calculateRiskValues();
    }
    sumForPersonMonthWeekForProjectSpecific() {
        //Calculate for person month
        let personMonthRow = Array.from(this.template.querySelectorAll(".personMonthSpecificActivities"));
        var sumPersonMonth = 0;
        personMonthRow.map(row => {
            var pm = row.value;
            if (pm.length == 0) {
                pm = 0;
            }
            sumPersonMonth = parseFloat(sumPersonMonth) + parseFloat(pm);
        });
        this.template.querySelector(".totalPersonMonthsProjectSpecific").value = sumPersonMonth;

        //Calculate for person Week
        let personWeekRow = Array.from(this.template.querySelectorAll(".personWeeksSpecificActivities"));
        var sumPersonWeek = 0;
        personWeekRow.map(row => {
            sumPersonWeek = parseFloat(sumPersonWeek) + parseFloat(row.value);
        });
        this.template.querySelector(".totalPersonWeeksProjectSpecific").value = sumPersonWeek;
        this.calculateRiskValues();
    }
    calculateRiskValues() {
        let sldcPhaseMonth = this.template.querySelector(".totalPersonMonthsSDLCPhase");
        let otherActivity = this.template.querySelector(".totalPersonMonthsSDLCOtherActivity");
        let projectSpec = this.template.querySelector(".totalPersonMonthsProjectSpecific");
        let withRisk = sldcPhaseMonth.value + otherActivity.value + projectSpec.value;
        let wihoutRisk = withRisk - this.risksActivity;
        this.template.querySelector(".withRisk").value = withRisk;
        this.template.querySelector(".withoutRisk").value = wihoutRisk;
        //alert(withRisk);
        const custEvent = new CustomEvent(
            'wihoutriskforparent', {
            detail: withRisk,
        });
        this.dispatchEvent(custEvent);
    }
    @track closeArrow = false;
    @track closeArrow1 = false;
    @track closeArrow2 = false;
    handleForDetailsElement() {
        if (this.closeArrow == false) {
            this.template.querySelector('.detailsClose').style.display = "block";
            this.template.querySelector('.detailsOpen').style.display = "none";
            this.closeArrow = true;
        } else {
            this.template.querySelector('.detailsClose').style.display = "none";
            this.template.querySelector('.detailsOpen').style.display = "block";
            this.closeArrow = false;
        }
    }
    handleForDetailsElement1() {
        if (this.closeArrow1 == false) {
            this.template.querySelector('.detailsClose1').style.display = "block";
            this.template.querySelector('.detailsOpen1').style.display = "none";
            this.closeArrow1 = true;
        } else {
            this.template.querySelector('.detailsClose1').style.display = "none";
            this.template.querySelector('.detailsOpen1').style.display = "block";
            this.closeArrow1 = false;
        }
    }
    handleForDetailsElement2() {
        if (this.closeArrow2 == false) {
            this.template.querySelector('.detailsClose2').style.display = "block";
            this.template.querySelector('.detailsOpen2').style.display = "none";
            this.closeArrow2 = true;
        } else {
            this.template.querySelector('.detailsClose2').style.display = "none";
            this.template.querySelector('.detailsOpen2').style.display = "block";
            this.closeArrow2 = false;
        }
    }
    unSavedChanges(event) {
        var labelName = event.target.name;
        var flag = false;
        if (labelName == 'ApproverList') {
            flag = true;
        }
        if (flag != true) {
            const custEvent = new CustomEvent(
                'callunsavedchanges', {
                detail: true,
            });
            this.dispatchEvent(custEvent);
        }
    }
    exportExcel() {
        this.showSpinner();
        window.location.href = "/apex/EstimationReport?AccountId=" + this.accountId + "&EstimationId=" + this.estimationSummary;
        this.hideSpinner();
    }
    calculatedODSEstimate() {
        var totalHours = 0;
        var RequirementsPW = 0;
        var DesignPW = 0;
        var DevelopmentPW = 0;
        var IntTestingPW = 0;
        var SystemTestingPW = 0;
        var UATTestingPW = 0;
        let RequirementsRow = Array.from(this.template.querySelectorAll("[data-phases='Requirements']"));
        RequirementsRow.map(row => {
            if (row.name == 'person week') {
                RequirementsPW = parseFloat(row.value);
            }
        });
        let DesignRow = Array.from(this.template.querySelectorAll("[data-phases='Design']"));
        DesignRow.map(row => {
            if (row.name == 'person week') {
                DesignPW = parseFloat(row.value);
            }
        });
        let DevelopmentRow = Array.from(this.template.querySelectorAll("[data-phases='Development (Code and unit testing)']"));
        DevelopmentRow.map(row => {
            if (row.name == 'person week') {
                DevelopmentPW = parseFloat(row.value);
            }
        });
        let InteTestingRow = Array.from(this.template.querySelectorAll("[data-phases='Integration Testing']"));
        InteTestingRow.map(row => {
            if (row.name == 'person week') {
                IntTestingPW = parseFloat(row.value);
            }
        });
        let SystemTestingRow = Array.from(this.template.querySelectorAll("[data-phases='System Testing']"));
        SystemTestingRow.map(row => {
            if (row.name == 'person week') {
                SystemTestingPW = parseFloat(row.value);
            }
        });
        let UATRow = Array.from(this.template.querySelectorAll("[data-phases='User Acceptance Testing (UAT)']"));
        UATRow.map(row => {
            if (row.name == 'person week') {
                UATTestingPW = row.value;
            }
        });
        var testingPW = IntTestingPW + SystemTestingPW + UATTestingPW;


        getTotalHoursForEstimation({ estimationSummary: this.estimationSummary })
            .then(result => {
                console.log('EnteredgetTotalHoursForEstimation'+JSON.stringify(result));
                totalHours = parseFloat(result);
                let TotalOtherActivities = this.template.querySelector('.totalPersonWeeksSDLCOtherActivity').value;
                let TotalOtherProjectSpecificActivities = this.template.querySelector('.totalPersonWeeksProjectSpecific').value;
                var productionDeployment = 0;
                let selectedRow = Array.from(this.template.querySelectorAll("[data-rowno='Production Deployment']"));
                selectedRow.map(row => {
                    if (row.name == 'person week') {
                        productionDeployment = row.value;
                    }
                });
                var sandboxDeployment = 0;
                let sandboxSelectedRow = Array.from(this.template.querySelectorAll("[data-rowno='Sandbox Deployment']"));
                sandboxSelectedRow.map(row => {
                    if (row.name == 'person week') {
                        sandboxDeployment = row.value;
                    }
                });
                var deploymentValue = this.calculateDeploymentPersonWeek();
                TotalOtherActivities = parseFloat(TotalOtherActivities);
                TotalOtherProjectSpecificActivities = parseFloat(TotalOtherProjectSpecificActivities);
               // productionDeployment = parseFloat(productionDeployment);
             //   sandboxDeployment = parseFloat(sandboxDeployment);
             var deployment = deploymentValue;
             var base = ((TotalOtherActivities + TotalOtherProjectSpecificActivities) - deployment) * totalHours;
                base = base.toFixed(2);
                if (ODS_Estimate_Line_Items) {
                    this.estimateLineItem = [];
                    const a = ODS_Estimate_Line_Items.split("|");
                    this.totalActualHours = 0;
                    for (var i = 0; i < a.length; i++) {
                        var percentage = 0;
                        var actualHours = 0;
                        percentage = percentage / 100;
                        if (a[i].split("==")[0] === 'Analysis') {
                            percentage = this.template.querySelector("[data-phases='Requirements']").value;
                            percentage = percentage / 100;
                            actualHours = (base * percentage) + (RequirementsPW * totalHours);
                        }
                        if (a[i].split("==")[0] === 'Design') {
                            percentage = this.template.querySelector("[data-phases='Design']").value;
                            percentage = percentage / 100;
                            actualHours = (base * percentage) + (DesignPW * totalHours);
                        }
                        if (a[i].split("==")[0] === 'Development') {
                            percentage = this.template.querySelector("[data-phases='Development (Code and unit testing)']").value;
                            percentage = percentage / 100;
                            actualHours = (base * percentage) + (DevelopmentPW * totalHours);
                        }
                        if (a[i].split("==")[0] === 'System Testing') {
                            var intTesting = this.template.querySelector("[data-phases='Integration Testing']").value;
                            var systemTesting = this.template.querySelector("[data-phases='System Testing']").value;
                            var UAT = this.template.querySelector("[data-phases='User Acceptance Testing (UAT)']").value;
                            percentage = parseFloat(intTesting) + parseFloat(systemTesting) + parseFloat(UAT);
                            percentage = percentage / 100;

                            actualHours = (base * percentage) + (testingPW * totalHours);
                        }
                        if (a[i].split("==")[0] === 'Production Deployment') {
                            actualHours = productionDeployment * totalHours;
                        }
                        if (a[i].split("==")[0] === 'Sandbox Deployment') {
                            actualHours = sandboxDeployment * totalHours;
                        }
                        this.totalActualHours = Math.round(this.totalActualHours + actualHours);
                        // actualHours = actualHours.toFixed(2);
                        // this.totalActualHours=this.totalActualHours.toFixed(2);
                        this.estimateLineItem.push({
                            LineItem: a[i].split("==")[0],
                            Percentage: percentage * 100,
                            newOtherValue:false,
                            ActualHours: Math.round(actualHours)
                        });
                    }
                    const rowsWithDeployment = this.template.querySelectorAll('.activityTextArea');
                    rowsWithDeployment.forEach((row, index) => {
                        
                            //added for other 14/11/2023
                            if(row.dataset.classification==='other' || row.dataset.other=='true') {
                                //this.isChecked = this.activityText ? true : false;
                                var actualHours = 0;
                                const parentTr = row.closest('tr');
                                const rowNumber = parentTr.dataset.rowno;
                                const personWeeksElement = this.template.querySelector('.personWeeksSpecificActivities[data-rowno="' + rowNumber + '"]');
                                actualHours = personWeeksElement.value * totalHours;
                                if (personWeeksElement.value > 0 ) {
                                this.estimateLineItem.push({
                                    LineItem: row.value,
                                    Percentage: Math.round(percentage * 100),
                                    newOtherValue:true,
                                    ActualHours: Math.round(actualHours) 
                                });
                                this.totalActualHours = Math.round(this.totalActualHours + actualHours);
                            }  
                        }
                    });
                    insertODSEstimate({ ODSEstimateResponse: JSON.stringify(this.estimateLineItem), estimationSummaryId: this.estimationSummary })
                        .then(result => {
                        })
                        .catch(error => {
                            console.log(error);
                        });
                }
            })
            .catch(error => {
                console.log(error);
            });
    }
    handleExportToInitiatives() {
        CheckInitiativeIsSavedOrNot({ estimatedId: this.estimationSummary })
            .then(data => {
                this.exportToInitiative = data;
            })
            .catch(error => {
                console.log('handleExportToInitiatives'+error);
            });
    }
    exportToInitiativeMethod() {
        this.showSpinner();
        createEstimationElement({ estimatedId: this.estimationSummary })
            .then(data => {
                alert('Successfully exported the estimation to the initiative.!');
                this.hideSpinner();
            })
            .catch(error => {
                console.log(error);
            });
    }
    enableApproverButtonForTPM() {
        validationForApproverButton({ summaryId: this.estimationSummary })
            .then(data => {
                if (data == true) {
                    this.approvedButton = true;
                } else {
                    this.approvedButton = false;
                    this.disbaleFieldWhenReadyForApproval();
                }
                //  alert('enable--' + data)
            })
            .catch(error => {
                console.log(error);
                // this.hideSpinner();

            });

    }
    @track enableButtonSection = true;
    @track ObsoleteStatus = false;

    disbaleFieldWhenReadyForApproval() {
        getStatusResult({ estimateSummaryId: this.estimationSummary })
            .then(data => {
                if (data == 'Ready for Approval') {
                    this.enableButtonSection = false;
                    if (this.edit == false) {
                        this.isApproved = true;
                        this.disableForAll = false;
                        this.template.querySelectorAll('.actionButton').forEach(item => {
                            item.style.pointerEvents = "none";

                        });
                    }

                }
                if (data === 'Obsolete') {
                    this.ObsoleteStatus = true;
                    this.isApproved = true;
                    this.disableForAll = true;
                    this.template.querySelectorAll('.actionButton').forEach(item => {
                        item.style.pointerEvents = "none";

                    });
                }
            })
            .catch(error => {
                console.log(error);
            });
    }
    ApproveTheEstimation() {
        this.showSpinner();
        approveTheEstimation({ summaryId: this.estimationSummary, userName: this.approverUserValue })
            .then(result => {
                this.hideSpinner();
                //  alert('The estiomation is approved.!')
                if (result === 'Approved') {
                    /* this.getTotalBase();
                     this.disableAllTheFields();
                     this.handleExportToInitiatives();
                     this.handleForEnableEditButton();
                     this.enableApproverButtonForTPM();*/
                    this.approvedButton = false;
                    this.checkCurrentUserIsPM();

                }
                if (result === 'Invalid') {
                    alert('The estimation is not approved. Please fill the Scope Details and save the estimation.!')
                } else {
                    alert('The estimation is approved.!');
                }
                this.triggerExitRecord();
                this.isShowModalForApprovalUser = false;

                this.hideSpinner();
            })
            .catch(error => {
                console.log(error);
                this.hideSpinner();
            });
    }
    handleApproversPopUp(event) {
        this.approverUserValue = event.detail.value;
        if (this.approverUserValue == '') {
            this.approverButtonOnPopUp = true;
        } else {
            this.approverButtonOnPopUp = false;
        }
    }
    hideModalBoxForApproval() {
        this.isShowModalForApprovalUser = false;
    }
    handleForApproveButton() {
        this.isShowModalForApprovalUser = true;
        getNotApproverUser({ summaryId: this.estimationSummary })
            .then(result => {
                let lstOption = [];
                lstOption.push({
                    value: '', label: '--None--'
                });
                if (result.length != 0) {
                    this.approverUserList = [];

                    for (var i = 0; i < result.length; i++) {
                        lstOption.push({
                            value: result[i], label: result[i]
                        });
                    }
                }
                this.approverUserList = lstOption;
                this.approverUserValue = '';
            })
            .catch(error => {
                this.hideSpinner();
                console.log(error);
            });
    }
}
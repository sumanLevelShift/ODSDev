import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import EstimationSummaryResource from '@salesforce/resourceUrl/EstimationSummaryResource';
import EstimationSummaryButtonIcons from '@salesforce/resourceUrl/EstimationSummaryButtonIcons';
import ODS_Statussign from '@salesforce/resourceUrl/ODS_Statussign';
import getCustomerList from '@salesforce/apex/CreateEstimationSummaryController.getCustomerList';
import getCSMNameList from '@salesforce/apex/CreateEstimationSummaryController.getCSMNameList';
import getInitiativesList from '@salesforce/apex/CreateEstimationSummaryController.getInitiativesList';
import getInitiativeDetails from '@salesforce/apex/CreateEstimationSummaryController.getInitiativeDetails';
import getSummaryCreatedDate from '@salesforce/apex/CreateEstimationSummaryController.getSummaryCreatedDate';
import getRiskBoundaryPickListValue from '@salesforce/apex/CreateEstimationSummaryController.getRiskBoundaryPickListValue';
import insertInsertRDList from '@salesforce/apex/CreateEstimationSummaryController.insertInsertRDList';
import getEstimatedSummeryRecord from '@salesforce/apex/CreateEstimationSummaryController.getEstimatedSummeryRecord';
import getRiskDescriptionList from '@salesforce/apex/CreateEstimationSummaryController.getRiskDescriptionList';
import getReEvaluateInitiatives from '@salesforce/apex/CreateEstimationSummaryController.getReEvaluateInitiatives';
//import updateStatus from '@salesforce/apex/CreateEstimationSummaryController.updateStatus';
import CheckInitiativeIsSavedOrNot from '@salesforce/apex/ExportToInitiativeController.CheckInitiativeIsSavedOrNot';
import createEstimationElement from '@salesforce/apex/ExportToInitiativeController.createEstimationElement';
import checkExistRecordsOnRelated from '@salesforce/apex/CreateEstimationSummaryController.checkExistRecordsOnRelated';
import clearStatusToMakeEdit from '@salesforce/apex/CreateEstimationSummaryController.clearStatusToMakeEdit';
import validationOnCheckList from '@salesforce/apex/CreateEstimationSummaryController.validationOnCheckList';
import validationOnEffortCalculation from '@salesforce/apex/CreateEstimationSummaryController.validationOnEffortCalculation';
import validationOnInventory from '@salesforce/apex/CreateEstimationSummaryController.validationOnInventory';
import validationOnComplexity from '@salesforce/apex/CreateEstimationSummaryController.validationOnComplexity';

import getStatusPickListValue from '@salesforce/apex/CreateEstimationSummaryController.getStatusPickListValue';
import validationForApproverButton from '@salesforce/apex/CreateEstimationSummaryController.validationForApproverButton';
import getTPMDetails from '@salesforce/apex/CreateEstimationSummaryController.getTPMDetails';

import approveTheEstimation from '@salesforce/apex/CreateEstimationSummaryController.approveTheEstimation';
import updateHours from '@salesforce/apex/CreateEstimationSummaryController.updateHours';
import getNotApproverUser from '@salesforce/apex/CreateEstimationSummaryController.getNotApproverUser';
import getcurrentUserAccessForEstimation from '@salesforce/apex/CreateEstimationSummaryController.getcurrentUserAccessForEstimation';
import getcurrentUserPM from '@salesforce/apex/CreateEstimationSummaryController.getcurrentUserPM';
import sendEstimationReadyForApproval from '@salesforce/apex/CreateEstimationSummaryController.sendEstimationReadyForApproval';

import updateApproverUserTrack from '@salesforce/apex/CreateEstimationSummaryController.updateApproverUserTrack';

import Estimation_Threshold from '@salesforce/label/c.Estimation_Threshold';


export default class CreateEstimationSummary extends LightningElement {
    @api accountId = '';
    @api serviceId = '';
    @api estimationSummary;
    @api totalEffortHours;
    @track spinner = ODS_Statussign;
    @track saveButton = EstimationSummaryButtonIcons + '/save_icon.svg';
    @track addButton = EstimationSummaryButtonIcons + '/add_icon.svg';
    @track cancelButton = EstimationSummaryButtonIcons + '/delete_icon.svg';
    @track exportButton = EstimationSummaryButtonIcons + '/download_icon.svg';
    @track exportToInitiativeButton = EstimationSummaryButtonIcons + '/export_initiative_icon.svg';
    @track editButtonIcon = EstimationSummaryButtonIcons + '/edit_icon.svg';
    @track approveButtonIcon = EstimationSummaryButtonIcons + '/approve_icon.svg';

    @track customerNameList = [];
    @track CSMOptionsList = [];
    @track initiativesList = [];
    @track JiraOptionList = [];
    @track approvedByList = [];
    // @track semVerticalList = [];
    //  @track programManagerList = [];
    @track createByValue = '';
    @track customerId = '';
    @track CSMRecordID = '';
    @track initiativesId = '';
    @track approvedById = '';
    @track estimationApproved = false;
    @track estimationApprovedLevel1 = false;
    @track SEMVerticalValue = '';
    @track programManagerValue = '';
    @track tpmName = '';
    @track createdDate;
    @track disabledTheFIelds = false;
    @track perDayHours = 8;
    @track perWeek = 5;
    @track perMonth = 21;
    @track rows = [];
    @track riskBoundaryValue = [];
    @track riskBoundary = '';
    @track index = 0;
    @track existRecord;
    @track existRiskDescription = [];
    @track approvedByField = false;
    @track exportToInitiative = false;
    @api edit = false;
    @track activeProgramManager = false;

    @track statusFlag = false;
    @track statusOption = [];
    @track statusValue = '';
    @track statusValueOnchangePrevent = false;
    @track approvedButton = false;
    @track checkListValidation = false;
    @track effortCalValidation = false;
    @track inventoryValidation = false;
    @track complexityValidation = false;

    @track approverUserList = [];
    @track approverUserValue = '';
    @track isShowModalForApprovalUser = false;
    @track approverButtonOnPopUp = true;
    @track ScopeDetailsFields = false;
    @track enableForDeliveryRole = false;
    @track previousStatus = '';
    @api triggerExitRecord(strString) {
        if (this.estimationSummary) {

            this.getCSMList(this.accountId, this.serviceId);
            this.generateEstimationSummaryRecords();
            this.generateStatusList();
            // this.handleTheApprovedByField();
            this.disableAllTheFieldsWhenApprovedHaveValue();
            this.handleExportToInitiatives();
            this.handleForEnableEditButton();
            this.validationForCheckList();
            this.validationForEffortCal();
            this.validationForInventory();
            this.validationForComplexity();
            this.statusValueOnchangePrevent = true;
        }
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if (inputFields) {
            inputFields.forEach((field) => {
                field.reset();
            });
        }

        if (this.edit == true) {
            this.enableEditButton = false;
            this.MakeEditableThePage();
        }
        const custEvent0 = new CustomEvent(
            'callunsavedchanges', {
            detail: false,
        });
        this.dispatchEvent(custEvent0);
        this.checkCurrentUserIsPM();

    }
    renderedCallback() {
        //   Promise.all([loadStyle(this, EstimateSummaryCSS), loadScript(this, jquery3_6_0)])
        Promise.all([
            loadStyle(this, EstimationSummaryResource + '/EstimateSummaryCSS.css'),
            loadStyle(this, EstimationSummaryResource + '/EstimationInventroyCSS.css'),
            loadStyle(this, EstimationSummaryResource + '/EstimateEffortCalculationsCSS.css'),
            loadStyle(this, EstimationSummaryResource + '/EstimateAddCheckListCSS.css'),
            loadScript(this, EstimationSummaryResource + '/jquery3_6_0.js')
        ]).then(() => {
        }).catch(error => {
            this.error = error;
            console.log(' Error Occured-- ', +error);
        });
    }

    @wire(getCustomerList)
    wiredcustomerList({ error, data }) {
        if (data) {
            let lstOption = [];
            lstOption.push({ value: '', label: "--None--" });
            for (var i = 0; i < data.length; i++) {
                lstOption.push({
                    value: data[i].Id, label: data[i].Name
                });
            }
            this.customerNameList = lstOption;
            this.customerId = this.accountId;
        } else if (error) {
            this.error = error;
        }
    }
    /* @wire(getSEMVerticalUsers)
     wiredSEMList({ error, data }) {
         let lstOption = [];
         lstOption.push({ value: '', label: "--None--" });
         if (data) {
 
             for (var i = 0; i < data.length; i++) {
                 lstOption.push({
                     value: data[i].Id, label: data[i].Name
                 });
             }
         } else if (error) {
             this.error = error;
         }
         this.semVerticalList = lstOption;
 
     }*/
    @wire(getRiskBoundaryPickListValue)
    wiredRiskBoundary({ error, data }) {
        if (data) {
            let lstOption = [];
            lstOption.push({ value: '', label: "--None--" });
            for (var i = 0; i < data.length; i++) {
                lstOption.push({
                    value: data[i], label: data[i]
                });
            }
            this.riskBoundaryValue = lstOption;
        } else if (error) {
            alert(error)
            this.error = error;
        }
    }
    connectedCallback() {
        this.generateEstimationSummaryRecords();
        if (this.estimationSummary.length != 0) {
            // this.handleTheApprovedByField();
            this.handleExportToInitiatives();
            this.handleForEnableEditButton();
            this.validationForCheckList();
            this.validationForEffortCal();
            this.validationForInventory();
            this.validationForComplexity();
        }
        getcurrentUserAccessForEstimation()
            .then(data => {
                this.enableForDeliveryRole = data;
                if (data == false) {
                    this.template.querySelectorAll('.lightningFields').forEach(item => {
                        item.disabled = true;
                    });
                    this.template.querySelectorAll('.add-row').forEach(item => {
                        item.style.pointerEvents = "none";

                    });
                    this.template.querySelectorAll('lightning-icon').forEach(item => {
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
    MakeEditableThePage() {
        this.approvedById = '';
        this.estimationApproved = false;
        this.approvedByField = false;
        this.template.querySelectorAll('.lightningFields').forEach(item => {
            item.disabled = false;
        });

        this.template.querySelectorAll('.add-row').forEach(item => {
            item.style.pointerEvents = "auto";
        });
        this.template.querySelectorAll('.CodingInvoled').forEach(item => {
            item.disabled = true;
        });
        this.disableProgramManager = false;
        this.exportToInitiative = false;
    }
    handleForEditButton() {
        let text = "Do you want to re-evaluate the estimates?";
        if (confirm(text) == true) {
            this.enableEditButton = false;
            clearStatusToMakeEdit({ estimatedId: this.estimationSummary })
                .then(result => {
                    this.statusValue = 'Reevaluation In-progress';
                    this.statusOption = [];
                    let lstOption = [];
                    lstOption.push({
                        value: 'Reevaluation In-progress', label: 'Reevaluation In-progress'
                    });
                    lstOption.push({
                        value: 'Ready for Approval', label: 'Ready for Approval'
                    });
                    this.statusOption = lstOption;
                    //this.generateStatusList();
                    //this.statusFlag = false;
                    this.MakeEditableThePage();
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
    handleExportToInitiatives() {
        CheckInitiativeIsSavedOrNot({ estimatedId: this.estimationSummary })
            .then(data => {
                this.exportToInitiative = data;
            })
            .catch(error => {
                console.log(error);
            });
    }
    generateEstimationSummaryRecords() {
        this.activeProgramManager = false;
        if (this.accountId != null || this.accountId != '' || this.accountId != undefined) {
            this.getCSMList(this.accountId, this.serviceId);
            this.getInitiativesListFunction(this.accountId, this.serviceId);
            this.getApprovedByFunction(this.accountId, this.serviceId);
            this.tpmName = '';
            this.generateStatusList();
            this.statusValue = 'Estimation In-progress';
        }
        if (this.estimationSummary.length !== 0) {
            getEstimatedSummeryRecord({ estimatedId: this.estimationSummary })
                .then(result => {
                    this.existRecord = result;
                    this.initiativesList.push({
                        value: result.Project_ID__c, label: result.Project_ID__r.Name
                    });
                    this.JiraOptionList.push({
                        value: result.Project_ID__c, label: result.Project_ID__r.JIRA_ID__c
                    });

                    if (result.Total_Effort_In_Hours__c > Estimation_Threshold) {
                        this.activeProgramManager = true;
                    }
                    this.customerId = result.Customer__c;
                    this.initiativesId = result.Project_ID__c;
                    this.perDayHours = result.Work_Hours_Per_Day__c;
                    this.perWeek = result.Work_Days_Per_Week__c;
                    this.perMonth = result.Work_Days_Per_Month__c;
                    this.tpmName = result.Technical_Project_Manager__c;
                    this.CSMRecordID = result.Customer_Success_Manager__c;
                    this.createdDate = result.CreatedDate;
                    this.statusValue = result.Status__c;
                    this.previousStatus = result.Status__c;
                    this.createByValue = result.Created_By__c;
                    this.statusValueOnchangePrevent = true;
                    if (this.statusValue === 'Approved') {
                        this.estimationApproved = true;
                    }
                    if (this.statusValue === 'Ready for Approval') {
                        this.estimationApprovedLevel1 = true;
                    }

                    if (result.Approved_By__c) {
                        this.approvedById = result.Approved_By__c;
                    } else {
                        this.approvedById = '';

                    }
                    if (result.SME_Vertical__c) {
                        this.SEMVerticalValue = result.SME_Vertical__c;
                    } else {
                        this.SEMVerticalValue = '';
                    }
                    if (result.Program_Manager__c) {
                        this.programManagerValue = result.Program_Manager__c;
                        // alert(this.programManagerValue)
                    } else {
                        this.programManagerValue = '';
                    }
                    this.enableApproverButtonForTPM();
                    this.disableAllTheFieldsWhenApprovedHaveValue();

                })
                .catch(error => {
                    console.log(error);
                });

            this.riskDescriptionFunction();
        } else {
            // this.statusFlag=true;
            //  this.getProgramManagerOption();
        }
    }
    generateStatusList() {
        getStatusPickListValue({ summaryId: this.estimationSummary })
            .then(result => {

                let lstOption = [];

                if (result.length != 0) {
                    this.statusOption = [];
                    for (var i = 0; i < result.length; i++) {
                        lstOption.push({
                            value: result[i], label: result[i]
                        });
                    }
                }
                this.statusOption = lstOption;
                //this.statusValueOnchangePrevent = false;
                /* getTPMValidations({ summaryId: this.estimationSummary })
                     .then(result => {
                         if (result == false) {
                             this.statusFlag = true;
                         } else {
                             this.statusFlag = false;
                         }
                         // alert(this.statusFlag)
                     })
                     .catch(error => {
                         console.log(error);
                     });*/
            })
            .catch(error => {
                console.log(error);
            });

    }
    riskDescriptionFunction() {
        this.existRiskDescription = [];
        this.rows = [];
        getRiskDescriptionList({ estimatedId: this.estimationSummary })
            .then(result => {
                this.existRiskDescription = result;
                this.disableAllTheFieldsWhenApprovedHaveValue();
            })
            .catch(error => {
                console.log(error);
            });
    }
    @track disableProgramManager = false;
    @track enableButtonSection = true;
    @track ObsoleteStatus = false;
    disableAllTheFieldsWhenApprovedHaveValue() {
        this.approvedByField = false;
        this.enableButtonSection = true;
        if (this.statusValue === 'Obsolete') {
            this.ObsoleteStatus = true;
        }
        if (this.estimationApproved == true || this.statusValue === 'Obsolete') {
            this.approvedByField = true;

            this.template.querySelectorAll('.lightningFields').forEach(item => {
                item.disabled = true;

            });
            this.disableProgramManager = true;
            this.template.querySelectorAll('.add-row').forEach(item => {
                item.style.pointerEvents = "none";

            });
        }
    }
    onChangeWorkHoursPerDay(event) {
        this.perDayHours = event.detail.value;
        updateHours({ summaryId: this.estimationSummary, month: this.perMonth, week: this.perWeek, day: this.perDayHours })
            .then(result => {
                const custEvent = new CustomEvent(
                    'callunsavedchanges', {
                    detail: false,
                });
                this.dispatchEvent(custEvent);
                this.calculateTotaleffort();
            })
            .catch(error => {
                console.log(error);
            });
    }
    onChangeWorkPerWeek(event) {
        this.perWeek = event.detail.value;
        updateHours({ summaryId: this.estimationSummary, month: this.perMonth, week: this.perWeek, day: this.perDayHours })
            .then(result => {
                const custEvent = new CustomEvent(
                    'callunsavedchanges', {
                    detail: false,
                });
                this.dispatchEvent(custEvent);
                this.calculateTotaleffort();
            })
            .catch(error => {
                console.log(error);
            });
    }
    onChangeWorkPerMonth(event) {
        this.perMonth = event.detail.value;
        updateHours({ summaryId: this.estimationSummary, month: this.perMonth, week: this.perWeek, day: this.perDayHours })
            .then(result => {
                const custEvent = new CustomEvent(
                    'callunsavedchanges', {
                    detail: false,
                });
                this.dispatchEvent(custEvent);
                this.calculateTotaleffort();
            })
            .catch(error => {
                console.log(error);
            });
    }
    calculateTotaleffort() {
        if (this.estimationSummary.length != 0) {
            var totalhours = [];
            totalhours.push({
                perDayHours: this.perDayHours,
                perWeek: this.perWeek,
                perMonth: this.perMonth
            });
            const custEvent = new CustomEvent(
                'callfromestimationsummary', {
                detail: totalhours,
            });
            this.dispatchEvent(custEvent);
        }
    }
    handleSaveSuccess(event) {
        this.template.querySelector('.spinnerDiv').style.display = "block";
        this.estimationSummary = event.detail.id;
        // alert('event.detail.id--' + event.detail.id);

        getSummaryCreatedDate({ summaryId: event.detail.id })
            .then(result => {
                this.createdDate = result;
            })
            .catch(error => {
                console.log(error);
            });

        this.disabledTheFIelds = true;

        /*start insert Risk Description*/
        var records = [];
        let rowsValues = Array.from(this.template.querySelectorAll("tr.inputRows"));
        try {
            rowsValues.map(row => {
                let riskDescription = row.querySelector(".riskDescription");
                let riskBoundary = row.querySelector(".riskBoundary");
                if (riskDescription.value.length != 0 || riskBoundary.value.length != 0) {
                    records.push({
                        RiskDescription: riskDescription.value,
                        RiskBoundary: riskBoundary.value,
                    });
                }
            });
        } catch (e) {
            alert(JSON.stringify(e))
        }
        console.log(JSON.stringify(records));
        if (records.length != 0) {
            insertInsertRDList({ insertRiskDescriptionList: JSON.stringify(records), estimationSummaryId: event.detail.id })
                .then(result => {
                    this.riskDescriptionFunction();
                })
                .catch(error => {
                    console.log(error);
                });
        }
        /*End insert Risk Description*/
        const custEvent0 = new CustomEvent(
            'callunsavedchanges', {
            detail: false,
        });
        this.dispatchEvent(custEvent0);

        const custEvent1 = new CustomEvent(
            'callgetestimationsummaryid', {
            detail: event.detail.id,
        });
        this.dispatchEvent(custEvent1);

        const custEvent = new CustomEvent(
            'callfromchildcmp', {
            detail: "2",
        });
        this.template.querySelector('.spinnerDiv').style.display = "none";

        this.dispatchEvent(custEvent);

        this.generateEstimationSummaryRecords();
        this.handleExportToInitiatives();
        this.handleForEnableEditButton();
        alert('Estimation summary is successfully submitted!');
        window.location.href = '/apex/DetailsEstimationSummary?estimationId=' + this.estimationSummary + '&accountId=' + this.accountId + '&serviceId=' + this.serviceId;
    }
    handleSaveSubmit(event) {
        console.log('onsubmit event recordEditForm' + JSON.stringify(event.detail.fields));
    }
    handleReset(event) {
        this.template.querySelector('.spinnerDiv').style.display = "block";
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                if (field.name != 'customer') {
                    field.reset();
                }
            });
        }
        window.location.href = '/apex/DetailsEstimationSummary';

        this.template.querySelector('.spinnerDiv').style.display = "none";

    }

    isInputValid(event) {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validatedField');
        inputFields.forEach(inputField => {
            if (!inputField.value) {
                inputField.reportValidity();
                isValid = false;
                if (inputField.fieldName == 'Created_By__c') {
                    var txt = this.template.querySelector('.createdByFieldNew');
                    if (txt) {
                        txt.style.display = "block";
                    }
                    var box = this.template.querySelector('.redColorBox');
                    if (box) {
                        box.style.boxShadow = "#ea001e 0 0 0 1px ";
                        box.style.borderRadius = "6px";

                    }
                }
            } else {

            }
        });
        return isValid;
    }

    handleSaveRecord(event) {
        this.showSpinner();
        var StartDate;
        var EndDate;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (inputField.name == 'stDate') {
                StartDate = inputField.value;
            }
            if (inputField.name == 'eDate') {
                EndDate = inputField.value;
            }
        });
        if (StartDate > EndDate) {
            this.template.querySelectorAll('.validate').forEach(element => element.reportValidity());
            alert('Proposed End Date should be later than Proposed Start Date.');
            this.hideSpinner();
        }
        else {
            var flag1 = false;
            var flag2 = false;
            var flag3 = false;
            if (this.isInputValid()) {
                if (this.perDayHours === 0) {
                    alert("Work hours per day hours should be between 1 to 8.")
                    flag1 = false;
                    this.hideSpinner();
                }
                else {
                    flag1 = true;
                }
                if (this.perWeek === 0) {
                    alert("Work days per week hours should be between 1 to 5.");
                    flag2 = false;
                    this.hideSpinner();
                } else {
                    flag2 = true;
                }
                if (this.perMonth === 0) {
                    alert("Work days per month hours should be between 1 to 21.");
                    flag3 = false;
                    this.hideSpinner();
                } else {
                    flag3 = true;
                }
            } else {
                alert('Please fill in all the required fields.');
                this.hideSpinner();
            }

            if (flag1 && flag2 && flag3) {
                const btn = this.template.querySelector(".hidden");
                btn.click();
                this.hideSpinner();
            }

        }
    }

    handleCustomerName(event) {
        this.customerId = event.detail.value;
        // alert('bug')
        this.initiativesList = [];
        this.approvedByList = [];
        this.CSMOptionsList = [];
        this.JiraOptionList = [];
        this.tpmName = '';
        this.getCSMList(event.detail.value, this.serviceId);
        this.getInitiativesListFunction(event.detail.value, this.serviceId);
        this.getApprovedByFunction(event.detail.value, this.serviceId);
    }
    handleCSM(event) {
        this.CSMRecordID = event.detail.value;
    }
    handleStatusDropDown(event) {
        this.statusValue = event.detail.value;
        if (!this.statusValueOnchangePrevent) {
            this.statusValueOnchangePrevent = false;
        }
    }
    /* handleSEMVertical(event) {
         this.SEMVerticalValue = event.detail.value;
         if (this.SEMVerticalValue != '') {
             if (this.totalEffortHours > Estimation_Threshold) {
                 this.activeProgramManager = true;
             }
         } else {
             this.programManagerValue = '';
             this.activeProgramManager = false;
         }
     }*/

    /*getProgramManagerOption() {
        getProgramManagerUsers({ tpmName: this.tpmName })
            .then(data => {
                //alert('data--' + JSON.stringify(data))
                this.programManagerList = [];
                let lstOption = [];
                lstOption.push({
                    value: '', label: '--None--'
                });
                if (data.length != 0) {
                    for (var i = 0; i < data.length; i++) {
                        lstOption.push({
                            value: data[i].ManagerId, label: data[i].Manager.Name
                        });
                    }
                }
                //this.programManagerValue = '';
                this.programManagerList = lstOption;
                //  alert(JSON.stringify(this.programManagerList))
            })
            .catch(error => {
                console.log(error);
            });
    }*/
    handleInitiatives(event) {
        this.initiativesId = event.detail.value;
        getInitiativeDetails({ initiativeId: this.initiativesId })
            .then(result => {
                if (result[0].Account_Service__r.Technical_Account_manager__c != null) {
                    this.CSMRecordID = result[0].Account_Service__r.Technical_Account_manager__c;
                } else {
                    this.CSMRecordID = '';
                }

                if (result[0].Technical_Project_Manager__c != null && result[0].Technical_Project_Manager__c != 'None') {

                    getTPMDetails({ tPMName: result[0].Technical_Project_Manager__c })
                        .then(result => {
                            this.tpmName = result;
                            if (this.tpmName == '') {
                                this.template.querySelector('.tpmLookUp').handleRemove();
                            }
                        })
                        .catch(error => {
                            console.log(error);
                        });
                } else {
                    this.tpmName = '';
                    this.template.querySelector('.tpmLookUp').handleRemove();
                }
            })
            .catch(error => {
                console.log(error);
            });
    }
    handleApprovedBy(event) {
        this.approvedById = event.detail.value;
    }
    getCSMList(accId, serId) {
        getCSMNameList({ accountId: accId, serviceId: serId })
            .then(result => {
                this.CSMOptionsList = [];
                let lstOption = [];
                lstOption.push({
                    value: '', label: '--None--'
                });
                if (result.length != 0) {

                    lstOption.push({ value: result[0].Account__r.User__r.Id, label: result[0].Account__r.User__r.Name });
                    lstOption.push({ value: result[0].Account__r.Backup_CSM__r.Id, label: result[0].Account__r.Backup_CSM__r.Name });
                    lstOption.push({ value: result[0].Technical_Account_manager__c, label: result[0].Technical_Account_manager__r.Name });
                }
                this.CSMOptionsList = lstOption;
                this.CSMRecordID = '';
            })
            .catch(error => {
                console.log(error);
            });
    }
    getInitiativesListFunction(accId, serId) {
        getInitiativesList({ accountId: accId, serviceId: serId })
            .then(data => {
                this.initiativesList = [];
                this.JiraOptionList = [];
                let lstOption = [];
                let lstOption1 = [];
                lstOption.push({
                    value: '', label: '--None--'
                });
                lstOption1.push({
                    value: '', label: '--None--'
                });
                if (data.length != 0) {
                    for (var i = 0; i < data.length; i++) {
                        lstOption.push({
                            value: data[i].Id, label: data[i].Name
                        });
                        lstOption1.push({
                            value: data[i].Id, label: data[i].JIRA_ID__c
                        });
                    }
                }
                this.initiativesId = '';
                this.initiativesList = lstOption;
                this.JiraOptionList = lstOption1;

            })
            .catch(error => {
                console.log(error);
            });
    }
    getApprovedByFunction(accId, serId) {
        this.approvedByList = [];
        let lstOption = [];
        lstOption.push({
            value: '', label: '--None--'
        });
        this.approvedById = '';
        this.approvedByList = lstOption;
        /* getApprovedByList({ accountId: accId, serviceId: serId })
             .then(data => {
                 this.approvedByList = [];
                 let lstOption = [];
                 lstOption.push({
                     value: '', label: '--None--'
                 });
                 if (data.length != 0) {
                     for (var i = 0; i < data.length; i++) {
                         lstOption.push({
                             value: data[i].User__r.Id, label: data[i].User__r.Name
                         });
                     }
                 }
                 this.approvedById = '';
                 this.approvedByList = lstOption;
 
             })
             .catch(error => {
                 console.log(error);
                 this.approvedByList = [];
             });*/
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
    handleAddRow() {
        var i;
        if (this.rows.length != 0) {
            this.index++;
        } else {
            this.index = 1;
        }
        this.rows.push(this.index);
    }
    removeRow(event) {
        if (this.approvedByField != true) {
            var id = event.target.dataset.id;
            const tds = this.template.querySelector("[data-id='" + id + "']");
            var trId = $(tds).closest('tr').attr('id');
            let selectedRow = this.template.querySelectorAll("[id='" + trId + "']");
            let s;
            selectedRow.forEach(b => {
                //  s = b.querySelector("p").innerHTML;
                b.remove();
            });
        }
    }

    handleUpdateSubmit(event) {
        // event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        //  fields.Status__c = this.statusValue;
        this.template.querySelector('lightning-record-edit-form').submit(fields);

        /*start insert Risk Description*/
        var records = [];
        let rowsValues = Array.from(this.template.querySelectorAll("tr.inputRows"));
        try {
            rowsValues.map(row => {
                let riskDescription = row.querySelector(".riskDescription");
                let riskBoundary = row.querySelector(".riskBoundary");
                if (riskDescription.value.length != 0 || riskBoundary.value.length != 0) {
                    records.push({
                        RiskDescription: riskDescription.value,
                        RiskBoundary: riskBoundary.value,
                    });
                }
            });
        } catch (e) {
            alert(JSON.stringify(e))
        }

        if (records.length != 0) {
            insertInsertRDList({ insertRiskDescriptionList: JSON.stringify(records), estimationSummaryId: this.estimationSummary })
                .then(result => {

                })
                .catch(error => {
                    console.log(error);
                });
        }
        // alert('this.previousStatus-'+this.previousStatus)
        // alert('this.statusValue-'+this.statusValue)

        if (this.previousStatus != 'Ready for Approval' && this.statusValue == 'Ready for Approval') {
            sendEstimationReadyForApproval({ estimationId: this.estimationSummary })
                .then(result => {
                })
                .catch(error => {
                    console.log(error);
                });
        }
        if (this.statusValue != 'Ready for Approval' && this.statusValue != 'Approved') {
            updateApproverUserTrack({ estimationId: this.estimationSummary })
                .then(result => {
                })
                .catch(error => {
                    console.log(error);
                });
        }
        /*End insert Risk Description*/

        // window.location.href = '/apex/DetailsEstimationSummary?estimationId=' + this.estimationSummary + '&accountId=' + this.accountId;

    }
    handleForRelated() {
        checkExistRecordsOnRelated({ estimationSummaryId: this.estimationSummary })
            .then(data => {
                const inputFields = this.template.querySelectorAll('lightning-input-field');
                if (inputFields) {
                    inputFields.forEach((field) => {
                        field.reset();
                    });
                }

            })
            .catch(error => {
                console.log(error);
            });
    }
    enableApproverButtonForTPM() {
        if (this.statusValue === 'Ready for Approval') {
            validationForApproverButton({ summaryId: this.estimationSummary })
                .then(data => {
                    if (data == true) {
                        this.approvedButton = true;
                    } else {
                        this.approvedButton = false;
                        if (this.estimationApprovedLevel1 == true) {
                            this.approvedByField = true;
                            this.enableButtonSection = false;
                            this.template.querySelectorAll('.lightningFields').forEach(item => {
                                item.disabled = true;

                            });
                            this.disableProgramManager = true;
                            this.template.querySelectorAll('.add-row').forEach(item => {
                                item.style.pointerEvents = "none";

                            });

                        }
                    }
                })
                .catch(error => {
                    console.log(error);
                    // this.hideSpinner();

                });
        } else {
            this.approvedButton = false;
        }
    }
    reSubmitEffortCal() {
        validationOnEffortCalculation({ estimationSummaryId: this.estimationSummary })
            .then(data => {
                if (!data) {
                    const custEvent = new CustomEvent(
                        'callforresumbiteffortcal', {
                        detail: true,
                    });
                    this.dispatchEvent(custEvent);
                }
            })
            .catch(error => {
                console.log(error);
                this.hideSpinner();

            });
    }
    handleUpdateSuccess() {
        //success message
        alert('Estimation summary is successfully submitted!');
        this.reSubmitEffortCal();
        /*  this.disableAllTheFieldsWhenApprovedHaveValue();
          this.handleExportToInitiatives();
          this.enableApproverButtonForTPM();
          this.generateStatusList();*/
        this.triggerExitRecord();
        if (this.estimationApproved == true) {
            this.edit = false;
            this.handleForEnableEditButton();
        }
        if (this.ValidProsposedDate != true) {
            const custEvent1 = new CustomEvent(
                'callunsavedchanges', {
                detail: false,
            });
            this.dispatchEvent(custEvent1);
            const custEvent = new CustomEvent(
                'callfromchildcmp', {
                detail: "2",
            });
            this.dispatchEvent(custEvent);

        }



    }
    handleUpdateReset() {
        window.location.href = '/apex/DetailsEstimationSummary?estimationId=' + this.estimationSummary + '&accountId=' + this.accountId + '&serviceId=' + this.serviceId;
    }
    handleErrorMessage(event) {
        alert('error--' + JSON.stringify(event.detail))
        this.template.querySelector('[data-id="formerror"]').setError(event.detail);
        event.preventDefault();
        event.stopImmediatePropagation();
    }
    @track ValidProsposedDate = false;
    validationForCheckList() {
        this.checkListValidation = false;
        validationOnCheckList({ estimationSummaryId: this.estimationSummary })
            .then(data => {
                // alert('data---' + data)
                if (data == true) {
                    this.checkListValidation = true;
                }
            })
            .catch(error => {
                console.log(error);
                this.hideSpinner();

            });
    }
    validationForEffortCal() {
        this.effortCalValidation = false;
        validationOnEffortCalculation({ estimationSummaryId: this.estimationSummary })
            .then(data => {
                this.effortCalValidation = data;
            })
            .catch(error => {
                console.log(error);
                this.hideSpinner();

            });
    }
    validationForInventory() {
        this.inventoryValidation = false;
        validationOnInventory({ estimationSummaryId: this.estimationSummary })
            .then(data => {
                this.inventoryValidation = data;
            })
            .catch(error => {
                console.log(error);
                this.hideSpinner();

            });
    }
    validationForComplexity() {
        this.complexityValidation = false;
        validationOnComplexity({ estimationSummaryId: this.estimationSummary })
            .then(data => {
                this.complexityValidation = data;
            })
            .catch(error => {
                console.log(error);
                this.hideSpinner();

            });
    }
    validateFields() {

        this.showSpinner();
        var flag = false;
        let inputFields = this.template.querySelectorAll('.validate');
        var StartDate, EndDate;
        inputFields.forEach(inputField => {
            if (inputField.name == 'stDate') {
                StartDate = inputField.value;
            }
            if (inputField.name == 'eDate') {
                EndDate = inputField.value;
            }
        });
        if (StartDate > EndDate) {
            this.ValidProsposedDate = true;
            alert('Proposed End Date should be later than Proposed Start Date.');
            this.hideSpinner();
        } else {
            this.ValidProsposedDate = false;
            flag = false;
        }

        this.template.querySelectorAll('.validatedField').forEach(element => {
            if (!element.value) {
                element.reportValidity();
                flag = true;
            }
        });
        if (flag) {
            alert('Please fill in all the required fields.');
            this.hideSpinner();
        }
        var tpmValue = false;
        var tpmValueV1 = false;
        if (this.statusValue === 'Ready for Approval') {
            var scopeFieldFlag = false;
            this.ScopeDetailsFields = true;
            this.template.querySelectorAll('.scopeFields').forEach(element => {
                if (!element.value) {
                    element.reportValidity();
                    scopeFieldFlag = true;
                    this.hideSpinner();

                }
            });
            if (scopeFieldFlag == true) {
                alert('Please fill in all the required fields.');
            }
            this.handleForRelated();
            if (this.tpmName == '' || this.tpmName == undefined || this.tpmName == null) {
                tpmValue = true;
                alert('Please select the Technical Project Manager!');
                this.hideSpinner();
            }

            if (this.inventoryValidation) {
                alert('Inventory line items cannot be empty!');
                const custEvent0 = new CustomEvent(
                    'callunsavedchanges', {
                    detail: false,
                });
                this.dispatchEvent(custEvent0);
                this.hideSpinner();
            }
            if (this.complexityValidation) {
                alert('Estimation Complexity Matrix is not submitted. Please submit it.')
                const custEvent0 = new CustomEvent(
                    'callunsavedchanges', {
                    detail: false,
                });
                this.dispatchEvent(custEvent0);
                this.hideSpinner();
            }
            if (this.checkListValidation) {
                alert('Before approving the estimation, Please make sure the remarks are filled when status is not selected on the checklist section.!');
                const custEvent0 = new CustomEvent(
                    'callunsavedchanges', {
                    detail: false,
                });
                this.dispatchEvent(custEvent0);
                this.hideSpinner();
            }
            if (this.effortCalValidation) {
                alert('Effort Calculation is not submitted. Please submit it.')
                const custEvent0 = new CustomEvent(
                    'callunsavedchanges', {
                    detail: false,
                });
                this.dispatchEvent(custEvent0);
                this.hideSpinner();
            }

            if (!this.checkListValidation && !this.effortCalValidation && !this.inventoryValidation && !this.complexityValidation) {
                if (!flag && !this.ValidProsposedDate && !tpmValue && !scopeFieldFlag) {
                    const btn = this.template.querySelector(".hidden");
                    btn.click();
                    this.hideSpinner();

                }
            }
        } else {
            if (!flag && !this.ValidProsposedDate && !tpmValue) {
                const btn = this.template.querySelector(".hidden");
                btn.click();
                this.hideSpinner();

            }
        }



    }

    unSavedChanges(event) {
        var labelName = event.target.fieldName;
        var labelName1 = event.target.name;

        // alert(labelName)
        var flag = false;
        if (labelName1 == 'ApproverList' || labelName == 'Technical_Project_Manager__c' || labelName == 'Customer_Success_Manager__c' || this.statusValueOnchangePrevent == true) {
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
    exportToInitiativeMethod() {
        this.showSpinner();
        createEstimationElement({ estimatedId: this.estimationSummary })
            .then(data => {
                alert('Successfully exported the estimation to the initiative.!');
                this.hideSpinner();

            })
            .catch(error => {
                console.log(error);
                this.hideSpinner();

            });
    }
    lookupCreateByRecord(event) {
        var i = event.detail.selectedRecord;
        if (i != undefined) {
            this.createByValue = i.Id;
        } else {
            this.createByValue = '';
        }
        var txt = this.template.querySelector('.createdByFieldNew');
        if (txt) {
            txt.style.display = "none";
        }
        var box = this.template.querySelector('.redColorBox');
        if (box) {
            box.style.boxShadow = "";
            box.style.borderRadius = "";

        }
    }
    lookupTPMRecord(event) {
        var i = event.detail.selectedRecord;
        //alert(JSON.stringify(i))
        if (i != undefined) {
            this.tpmName = i.Id;
        } else {
            this.tpmName = '';
        }
        // alert(this.tpmName)
    }
    lookupSEMRecord(event) {
        var i = event.detail.selectedRecord;
        if (i != undefined) {
            this.SEMVerticalValue = i.Id;
        } else {
            this.SEMVerticalValue = '';
        }
        /*  if (this.SEMVerticalValue != '') {
              if (this.totalEffortHours > Estimation_Threshold) {
                  this.activeProgramManager = true;
              }
          } else {
              this.programManagerValue = '';
              this.activeProgramManager = false;
          }*/
    }
    lookupPMRecord(event) {
        var i = event.detail.selectedRecord;
        if (i != undefined) {
            this.programManagerValue = i.Id;
        } else {
            this.programManagerValue = '';
        }
    }
    hideModalBoxForApproval() {
        this.isShowModalForApprovalUser = false;
    }
    handleApproversPopUp(event) {
        this.approverUserValue = event.detail.value;
        if (this.approverUserValue == '') {
            this.approverButtonOnPopUp = true;
        } else {
            this.approverButtonOnPopUp = false;
        }
    }
    ApproveTheEstimation() {
        this.showSpinner();
        approveTheEstimation({ summaryId: this.estimationSummary, userName: this.approverUserValue })
            .then(result => {
                // alert('result---' + result)
                this.hideSpinner();
                if (result === 'Approved') {
                    /* this.generateEstimationSummaryRecords();
                     this.handleExportToInitiatives();
                     this.handleForEnableEditButton();*/
                    this.checkCurrentUserIsPM();
                }
                if (result === 'Invalid') {
                    alert('The estimation is not approved. Please fill the Scope Details and save the estimation.!')
                } else {
                    alert('The estimation is approved.!');
                }
                this.triggerExitRecord();
                this.isShowModalForApprovalUser = false;
            })
            .catch(error => {
                this.hideSpinner();
                console.log(error);
            });
    }
    handleForApproveButton() {
        var scopeFieldFlag = false;
        this.template.querySelectorAll('.scopeFields').forEach(element => {
            if (!element.value) {
                element.reportValidity();
                scopeFieldFlag = true;

            }
        });
        if (scopeFieldFlag == true) {
            alert('Please fill the Scope Details.!');
        } else {
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
}
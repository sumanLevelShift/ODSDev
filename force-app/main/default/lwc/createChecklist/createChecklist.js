import { LightningElement, api, track, wire } from 'lwc';
import getCheckList from '@salesforce/apex/estimationCheckListController.getCheckList';
import insertInsertCheckList from '@salesforce/apex/estimationCheckListController.insertInsertCheckList';
import updateCheckList from '@salesforce/apex/estimationCheckListController.updateCheckList';
import getCheckListRecord from '@salesforce/apex/estimationCheckListController.getCheckListRecord';
import ODS_Statussign from '@salesforce/resourceUrl/ODS_Statussign';
//import EstimateAddCheckListCSS from '@salesforce/resourceUrl/EstimateAddCheckListCSS';
import EstimationSummaryButtonIcons from '@salesforce/resourceUrl/EstimationSummaryButtonIcons';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
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

export default class CreateChecklist extends LightningElement {
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
    @track checkList = [];
    @api estimationSummary = '';
    @track insertRecord = [];
    @track checkListRecord = [];
    @track oldCheckList = false;
    @track isApproved = false;
    @track exportToInitiative = false;
    @api enableEditButton = false;
    @api edit = false;

    @track approverUserList = [];
    @track approverUserValue = '';
    @track isShowModalForApprovalUser = false;
    @track approverButtonOnPopUp = true;
    @track activeProgramManager = false;
    @track enableForDeliveryRole = false;

    @api triggerExitRecord(strString) {
        alert('onclick on the tab')
        //alert(strString);
        if (strString == "4")
            this.generateExistCheckList();
        this.disableAllTheFields();
        this.handleExportToInitiatives();
        this.handleForEnableEditButton();
        this.enableApproverButtonForTPM();
        if (this.edit == true) {
            this.enableEditButton = false;
            this.isApproved = false;
            this.template.querySelectorAll('.actionButton').forEach(item => {
                item.style.pointerEvents = "none";

            });
        }
        this.checkCurrentUserIsPM();

    }
    connectedCallback() {
        if (this.estimationSummary != '') {
            this.showSpinner();
            getCheckList({ estimationSummaryId: this.estimationSummary })
                .then(result => {
                    this.checkList = result;
                    this.hideSpinner();
                })
                .catch(error => {
                    console.log(error);
                    this.hideSpinner();
                });

            this.generateExistCheckList();
            this.disableAllTheFields();
            this.handleExportToInitiatives();
            this.handleForEnableEditButton();
            this.enableApproverButtonForTPM();
        }
        getcurrentUserAccessForEstimation()
            .then(data => {
                this.enableForDeliveryRole = data;
                if (data == false) {
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
            this.enableEditButton = false;
            this.isApproved = false;
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
        //alert(this.edit)
        checkEstimationIsApproved({ estimateSummaryId: this.estimationSummary })
            .then(result => {
                if (result == true && this.edit == false) {
                    this.isApproved = true;
                    this.template.querySelectorAll('.actionButton').forEach(item => {
                        item.style.pointerEvents = "none";

                    });
                }
                if (this.edit == true) {
                    this.isApproved = false;
                    this.enableEditButton = false;
                    this.template.querySelectorAll('.actionButton').forEach(item => {
                        item.style.pointerEvents = "auto";

                    });
                }
            })
            .catch(error => {
                console.log(error);
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
    generateExistCheckList() {
        this.checkListRecord = [];
        this.showSpinner();

        getCheckListRecord({ estimationSummaryId: this.estimationSummary })
            .then(result => {
                // this.checkListRecord = result;

                result.forEach(element => {
                    if (element.Status__c == 'Yes') {
                        this.checkListRecord.push({
                            Id: element.Id,
                            Activities__c: element.Activities__c,
                            Status__c: true,
                            Remarks__c: element.Remarks__c
                        });
                    } else {
                        this.checkListRecord.push({
                            Id: element.Id,
                            Activities__c: element.Activities__c,
                            Status__c: false,
                            Remarks__c: element.Remarks__c
                        });
                    }
                });
                if (this.checkListRecord.length != 0) {
                    this.oldCheckList = true;
                }
                this.hideSpinner();
            })
            .catch(error => {
                console.log(error);
                this.hideSpinner();
            });
    }
    renderedCallback() {
        // Promise.all([loadStyle(this, EstimateAddCheckListCSS)])
        Promise.all([
            loadStyle(this, EstimationSummaryResource + '/EstimateAddCheckListCSS.css'),
            loadScript(this, EstimationSummaryResource + '/jquery3_6_0.js')
        ]).then(() => {
        }).catch(error => {
            this.error = error;
            console.log(' Error Occured-- ', +error);
        });
    }
    handleReset(event) {
        this.checkListRecord = [];
        this.generateExistCheckList();
    }

    handleSaveRecord(event) {
        this.template.querySelector('.spinnerDiv').style.display = "block";
        this.insertRecord = [];
        let rowsValues = Array.from(this.template.querySelectorAll("tr.inputRows"));
        var i = 0;
        var flag = false;
        rowsValues.map(row => {
            i++;
            let checkListIdCM = row.querySelector(".checkListIdCM");
            let status = row.querySelector(".status");
            let remarkTextArea = row.querySelector(".remarkTextArea");
            if (!status.checked && !remarkTextArea.value && !flag) {
                this.insertRecord = [];
                flag = true;
                alert('Please fill remarks field when status is not selected.!');
            }
            if (!flag) {
                this.insertRecord.push({
                    SNO: i,
                    CheckListIdCM: checkListIdCM.value,
                    Status: status.checked,
                    RemarkTextArea: remarkTextArea.value,
                });
            }
        });
        if (!flag) {
            let newComplex = JSON.stringify(this.insertRecord);
            insertInsertCheckList({ insertCheckList: newComplex, estimationSummaryId: this.estimationSummary })
                .then(result => {
                    alert('Estimation checkList are successfully submitted!')
                    this.generateExistCheckList();
                    this.template.querySelector('.spinnerDiv').style.display = "none";
                    const custEvent = new CustomEvent(
                        'callfromchildcmp', {
                        detail: "5",
                    });
                    this.dispatchEvent(custEvent);
                })
                .catch(error => {
                    console.log(error);
                });
        } else {
            this.template.querySelector('.spinnerDiv').style.display = "none";
        }
    }

    handleUpdateRecord(event) {
        this.template.querySelector('.spinnerDiv').style.display = "block";
        this.insertRecord = [];
        let rowsValues = Array.from(this.template.querySelectorAll("tr.inputRows"));
        var i = 0;
        var flag = false;
        rowsValues.map(row => {
            i++;
            let checkListId = row.querySelector(".checkListId");
            let status = row.querySelector(".status");
            let remarkTextArea = row.querySelector(".remarkTextArea");

            if (!status.checked && !remarkTextArea.value && !flag) {
                this.insertRecord = [];
                flag = true;
                alert('Please fill remarks field when status is not selected.!');
            }
            if (!flag) {
                this.insertRecord.push({
                    SNO: i,
                    CheckListId: checkListId.value,
                    Status: status.checked,
                    RemarkTextArea: remarkTextArea.value,
                });
            }
        });
        if (!flag) {
            let newComplex = JSON.stringify(this.insertRecord);
            updateCheckList({ updateCheckList: newComplex, estimationSummaryId: this.estimationSummary })
                .then(result => {
                    alert('Estimation checklists are successfully submitted!')
                    this.generateExistCheckList();

                    this.template.querySelector('.spinnerDiv').style.display = "none";
                    const custEvent1 = new CustomEvent(
                        'callunsavedchanges', {
                        detail: false,
                    });
                    this.dispatchEvent(custEvent1);
                    const custEvent = new CustomEvent(
                        'callfromchildcmp', {
                        detail: "5",
                    });
                    this.dispatchEvent(custEvent);
                })
                .catch(error => {
                    console.log(error);
                    this.template.querySelector('.spinnerDiv').style.display = "none";

                });
        } else {
            this.template.querySelector('.spinnerDiv').style.display = "none";

        }
    }
    unSavedChanges(event) {
        var labelName = event.target.name;
        var flag = false;
        // alert(labelName)
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
        this.hideSpinner()
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
    exportToInitiativeMethod() {
        this.showSpinner();
        createEstimationElement({ estimatedId: this.estimationSummary })
            .then(data => {
                alert('Successfully exported the estimation to the initiative.!');
                this.hideSpinner()
            })
            .catch(error => {
                console.log(error);
                this.hideSpinner()
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
                        this.template.querySelectorAll('.actionButton').forEach(item => {
                            item.style.pointerEvents = "none";

                        });
                    }

                }
                if (data === 'Obsolete') {
                    this.ObsoleteStatus = true;
                    this.isApproved = true;
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
                //alert('The estiomation is approved.!')
                if (result === 'Approved') {
                    /* this.generateExistCheckList();
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
                this.hideSpinner();
                this.isShowModalForApprovalUser = false;

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
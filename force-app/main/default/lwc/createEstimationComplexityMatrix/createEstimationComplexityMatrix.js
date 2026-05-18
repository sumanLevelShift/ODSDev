import { LightningElement, wire, track, api } from 'lwc';
import getComplexityMatrixList from '@salesforce/apex/estimationComplexityMatrixController.getComplexityMatrixList';
import getExistEstimationDetailForComplexityMatrix from '@salesforce/apex/estimationComplexityMatrixController.getExistEstimationDetailForComplexityMatrix';
import insertComplexityMatrix from '@salesforce/apex/estimationComplexityMatrixController.insertComplexityMatrix';
import updateComplexityMatrix from '@salesforce/apex/estimationComplexityMatrixController.updateComplexityMatrix';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import EstimationSummaryButtonIcons from '@salesforce/resourceUrl/EstimationSummaryButtonIcons';
import ODS_Statussign from '@salesforce/resourceUrl/ODS_Statussign';
import getRecordTypeIdForInventory from '@salesforce/apex/CreateEstimationInventoryController.getRecordTypeIdForInventory';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import getFilterComplexityMatrixFromEstDetails from '@salesforce/apex/estimationComplexityMatrixController.getFilterComplexityMatrixFromEstDetails';
import getFilterComplexityMatrixFromcustomMetadata from '@salesforce/apex/estimationComplexityMatrixController.getFilterComplexityMatrixFromcustomMetadata';
import EstimationSummaryResource from '@salesforce/resourceUrl/EstimationSummaryResource';
import checkEstimationIsApproved from '@salesforce/apex/CreateEstimationInventoryController.checkEstimationIsApproved';
import CheckInitiativeIsSavedOrNot from '@salesforce/apex/ExportToInitiativeController.CheckInitiativeIsSavedOrNot';
import createEstimationElement from '@salesforce/apex/ExportToInitiativeController.createEstimationElement';
import getReEvaluateInitiatives from '@salesforce/apex/CreateEstimationSummaryController.getReEvaluateInitiatives';
import clearStatusToMakeEdit from '@salesforce/apex/CreateEstimationSummaryController.clearStatusToMakeEdit';

import validationForApproverButton from '@salesforce/apex/CreateEstimationInventoryController.validationForApproverButton';
import approveTheEstimation from '@salesforce/apex/CreateEstimationSummaryController.approveTheEstimation';
import getStatusResult from '@salesforce/apex/CreateEstimationInventoryController.getStatusResult';
import getcurrentUserAccessForEstimation from '@salesforce/apex/CreateEstimationSummaryController.getcurrentUserAccessForEstimation';
import getcurrentUserPM from '@salesforce/apex/CreateEstimationSummaryController.getcurrentUserPM';
import getNotApproverUser from '@salesforce/apex/CreateEstimationSummaryController.getNotApproverUser';

export default class CreateEstimationComplexityMatrix extends LightningElement {
    @track spinner = ODS_Statussign;
    @track saveButton = EstimationSummaryButtonIcons + '/save_icon.svg';
    @track addButton = EstimationSummaryButtonIcons + '/add_icon.svg';
    @track cancelButton = EstimationSummaryButtonIcons + '/delete_icon.svg';
    @track exportButton = EstimationSummaryButtonIcons + '/download_icon.svg';
    @track exportToInitiativeButton = EstimationSummaryButtonIcons + '/export_initiative_icon.svg';
    @track editButtonIcon = EstimationSummaryButtonIcons + '/edit_icon.svg';
    @track approveButtonIcon = EstimationSummaryButtonIcons + '/approve_icon.svg';

    @track error = '';
    @track complexityMatrixList = [];
    @api accountId = '';
    @api estimationSummary = '';
    @track insertRecord = [];
    @track existEstimationDetailCompMat = [];
    @track newEstimationDetails = false;
    @track platformOptionList = [];
    @track entityTypeListValue = [];

    @track recordTypeIdPlatform = '';
    @track dependentEntityTypePicklist = [];
    @track isApproved = false;
    @track exportToInitiative = false;
    @api enableEditButton = false;
    @api edit = false;
    @track approvedButton = false;

    rowLimit = 25;
    rowOffSet = 0;


    @track approverUserList = [];
    @track approverUserValue = '';
    @track isShowModalForApprovalUser = false;
    @track approverButtonOnPopUp = true;
    @track activeProgramManager = false;
    @track enableForDeliveryRole = false;

    @api triggerExitRecord(strString) {
        this.showSpinner();
        this.template.querySelector('.searchDiv').style.display = 'none';
        this.existEstimationDetailCompMat = [];
        if (this.estimationSummary != '') {
            this.rowLimit = 25;
            this.rowOffSet = 0;
            this.getExistComplexityMatrixRecords();
            this.disableAllTheFields();
            this.handleExportToInitiatives();
            this.handleForEnableEditButton();
            this.enableApproverButtonForTPM();
        }
        this.hideSpinner();

        if (this.edit == true) {
            this.enableEditButton = false;
            this.isApproved = false;
            this.template.querySelectorAll('.actionButton').forEach(item => {
                item.style.pointerEvents = "auto";

            });
        }
        const custEvent0 = new CustomEvent(
            'callunsavedchanges', {
            detail: false,
        });
        this.dispatchEvent(custEvent0);
        this.checkCurrentUserIsPM();

    }
    @wire(getRecordTypeIdForInventory)
    wiredRecordPlatform({ error, data }) {
        if (data) {
            this.recordTypeIdPlatform = data;
        } else if (error) {
            alert(error)
        }
    };

    @wire(getPicklistValuesByRecordType, { objectApiName: 'Estimation_Detail__c', recordTypeId: '$recordTypeIdPlatform' })
    fetchPicklist({ error, data }) {

        if (data && data.picklistFieldValues) {
            this.platformOptionList = [];
            let optionsValue = {};
           // this.platformOptionList.push(optionsValue);
            this.platformOptionList.push({ label: '--None--', value: '' });

            data.picklistFieldValues['Platform__c'].values.forEach(optionData => {
                this.platformOptionList.push({ label: optionData.label, value: optionData.value });
            });
            this.platformValue = data.picklistFieldValues['Platform__c'].values[0].value;
            this.dependentEntityTypePicklist = data.picklistFieldValues['Entity_Type__c'];
        } else if (error) {
            console.log(error);
        }
    }
    handleForPlatformPickList(event) {
        this.entityOptionList = [];
        const selectedVal = event.target.value;
        let controllerValues = this.dependentEntityTypePicklist.controllerValues;
        let entityTypetag = this.template.querySelector('.entityTypeValue');
        $(entityTypetag).empty();
        $(entityTypetag).append($("<option>").val('').text('--None--'));

        if (this.dependentEntityTypePicklist.length != 0) {
            this.dependentEntityTypePicklist.values.forEach(depVal => {
                depVal.validFor.forEach(depKey => {
                    if (depKey === controllerValues[selectedVal]) {
                        $(entityTypetag).append($("<option>").val(depVal.label).text(depVal.value));
                    }
                });

            });
        }
        $("select option").css("background-color", "White");
    }
    renderedCallback() {
        /*  Promise.all([
              loadScript(this, jquery3_6_0), loadStyle(this, AddEstimate)
  
          ])*/
        Promise.all([
            loadStyle(this, EstimationSummaryResource + '/EstimateSummaryCSS.css'),
            loadScript(this, EstimationSummaryResource + '/jquery3_6_0.js')
        ]).then(() => {

        }).catch(error => {
            this.error = error;
            console.log(' Error Occured-- ', +error);
        });

    }
    getComplexityMatrixListMethod() {
        this.showSpinner();
        getComplexityMatrixList({ limitSize: this.rowLimit, offset: this.rowOffSet })
            .then(result => {
                let updatedRecords = [...this.complexityMatrixList, ...result];
                this.complexityMatrixList = updatedRecords;

                this.hideSpinner();
            })
            .catch(error => {
                console.log(error);
                this.hideSpinner();
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
    @track stopFlag = false;
    connectedCallback() {
        //alert(this.estimationSummary)
        if (this.estimationSummary) {
            this.getExistComplexityMatrixRecords();
            this.disableAllTheFields();
            this.handleExportToInitiatives();
            this.handleForEnableEditButton();
            this.enableApproverButtonForTPM();
        }
            getcurrentUserAccessForEstimation()
            .then(data => {
                this.enableForDeliveryRole=data;
                if(data==false){
                 this.isApproved = true;
                    this.template.querySelectorAll('.actionButton').forEach(item => {
                        item.style.pointerEvents = "none";

                    });
                }
            })
            .catch(error => {
                console.log('update--' + error);
            });
        
        //alert(this.newEstimationDetails)
        if (!this.stopFlag) {
            //   window.addEventListener('scroll', event => this.loadRecords());
            this.stopFlag = true;
        }
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
                item.style.pointerEvents = "auto";

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
    getExistComplexityMatrixRecords() {
        this.existEstimationDetailCompMat = [];
        this.newEstimationDetails = false;
        this.showSpinner();
        getExistEstimationDetailForComplexityMatrix({ estimationSummary: this.estimationSummary, limitSize: this.rowLimit, offset: this.rowOffSet })
            .then(result => {
                this.existEstimationDetailCompMat = result;
                if (result.length != 0) {
                    this.newEstimationDetails = true;
                } else {
                    this.getComplexityMatrixListMethod();
                }
                this.hideSpinner();
            })
            .catch(error => {
                console.log(error);
                this.hideSpinner();
            });
    }
    handleReset(event) {
        this.existEstimationDetailCompMat = [];
        if (this.estimationSummary != '') {
            this.getExistComplexityMatrixRecords();
        }
    }
    handleSaveRecord(event) {
        this.showSpinner();
        var validationFlag = false;
        this.insertRecord = [];
        let rowsValues = Array.from(this.template.querySelectorAll("tr.inputRows"));
        var i = 0;
        rowsValues.map(row => {
            i++;
            let complexityMatrixId = row.querySelector(".complexityMatrixId");
            let revisedEffortValue = row.querySelector(".revisedEffortValue");
            let rationalIfDifferentValue = row.querySelector(".rationalIfDifferentValue");
            if (revisedEffortValue.value) {
                if (!rationalIfDifferentValue.value) {
                    validationFlag = true;
                }
            }
            if (validationFlag == false) {
                this.insertRecord.push({
                    SNO: i,
                    ComplexityMatrixId: complexityMatrixId.value,
                    RevisedEffortValue: revisedEffortValue.value,
                    RationalIfDifferentValue: rationalIfDifferentValue.value,
                });
            }
        });
        if (validationFlag == true) {
            alert('Please Fill the Rationale If Different Fields When Revised Effort (Hours) Fields Are Have Value...!');
            this.hideSpinner();
        } else {
            if (this.insertRecord) {
                insertComplexityMatrix({ insertComplex: JSON.stringify(this.insertRecord), estimationSummaryId: this.estimationSummary })
                    .then(result => {
                        alert('Estimation complexity matrix are successfully submitted!');
                        this.rowLimit = 25;
                        this.rowOffSet = 0;
                        this.getExistComplexityMatrixRecords();

                        const custEvent1 = new CustomEvent(
                            'callunsavedchanges', {
                            detail: false,
                        });
                        this.dispatchEvent(custEvent1);
                        const custEvent = new CustomEvent(
                            'callfromchildcmp', {
                            detail: "4",
                        });

                        this.dispatchEvent(custEvent);
                        this.hideSpinner();

                    })
                    .catch(error => {
                        console.log(error);
                        this.hideSpinner();

                    });
            }

        }

    }
    handleUpdateRecord(event) {
        this.showSpinner();
        var validationFlag = false;
        this.insertRecord = [];
        let rowsValues = Array.from(this.template.querySelectorAll("tr.inputRows"));
        var i = 0;
        rowsValues.map(row => {
            i++;
            let estimationDetailId = row.querySelector(".estimationDetailId");
            let revisedEffortValue = row.querySelector(".revisedEffortValue");
            let rationalIfDifferentValue = row.querySelector(".rationalIfDifferentValue");
            //alert(revisedEffortValue.value);
            if (revisedEffortValue.value || revisedEffortValue.value != 0) {
                if (!rationalIfDifferentValue.value) {
                    validationFlag = true;
                }
            }
            if (validationFlag == false) {
                this.insertRecord.push({
                    SNO: i,
                    EstimationDetailId: estimationDetailId.value,
                    RevisedEffortValue: revisedEffortValue.value,
                    RationalIfDifferentValue: rationalIfDifferentValue.value,
                });
            }
        });
        if (validationFlag == true) {
            alert('Please Fill the Rationale If Different Fields When Revised Effort (Hours) Fields Are Have Value...!');
            this.hideSpinner();
        } else {
            if (this.insertRecord) {
                updateComplexityMatrix({ updateComplex: JSON.stringify(this.insertRecord), estimationSummaryId: this.estimationSummary })
                    .then(result => {
                        alert('Estimation complexity matrix are successfully submitted!');
                        this.rowLimit = 25;
                        this.rowOffSet = 0;
                        this.getExistComplexityMatrixRecords();

                        const custEvent1 = new CustomEvent(
                            'callunsavedchanges', {
                            detail: false,
                        });
                        this.dispatchEvent(custEvent1);
                        const custEvent = new CustomEvent(
                            'callfromchildcmp', {
                            detail: "4",
                        });
                        this.hideSpinner();

                        this.dispatchEvent(custEvent);

                    })
                    .catch(error => {
                        console.log(error);
                        this.hideSpinner();

                    });
            }

        }

    }
    searchOnClick() {
        var x = this.template.querySelector('.searchDiv');

        /*  this.template.querySelectorAll('lightning-combobox').forEach(each => {
              each.value = '';
          });
          let entityTypetag = this.template.querySelector('.entityTypeValue');
          $(entityTypetag).empty();
          $(entityTypetag).append($("<option>").val('').text('--None--'));*/
        if (x.style.display === "none") {
            x.style.display = "block";
        } else {
            x.style.display = "none";
        }
    }
    @track filterActive = false;
    handleFetchComplexity() {
        this.showSpinner();
        this.filterActive = true;
        this.rowLimit = 25;
        this.rowOffSet = 0
        this.existEstimationDetailCompMat = [];
        this.complexityMatrixList = [];
        this.getFilterList();
    }

    unSavedChanges(event) {
        var labelName = event.target.name;
        var flag = false;
        if (labelName == 'enityType' || labelName == 'Platform' || labelName == 'ApproverList') {
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
    @track oldValue = 0
    @track newValue = 0
    loadRecords(event) {
        var element = event.target;
        if (element.offsetHeight + Math.round(element.scrollTop) === element.scrollHeight) {
            console.log('done')
            this.newValue = element.scrollTop;
            if (this.oldValue < this.newValue) {
                this.rowOffSet = this.rowOffSet + this.rowLimit;

                this.loadMoreData()
            }
            this.oldValue = this.newValue;
        }

    }
    loadMoreData() {
        this.showSpinner();
        if (!this.filterActive) {
            if (this.newEstimationDetails) {
                getExistEstimationDetailForComplexityMatrix({ estimationSummary: this.estimationSummary, limitSize: this.rowLimit, offset: this.rowOffSet })
                    .then(result => {
                        let updatedRecords = [...this.existEstimationDetailCompMat, ...result];
                        this.existEstimationDetailCompMat = updatedRecords;
                        this.hideSpinner();
                    })
                    .catch(error => {
                        console.log(error);
                        this.hideSpinner();
                    });
            } else {
                getComplexityMatrixList({ limitSize: this.rowLimit, offset: this.rowOffSet })
                    .then(result => {
                        let updatedRecords = [...this.complexityMatrixList, ...result];
                        this.complexityMatrixList = updatedRecords;
                        this.hideSpinner();
                    })
                    .catch(error => {
                        console.log(error);
                        this.hideSpinner();
                    });
            }
        } else {
            this.getFilterList();
        }
    }
    getFilterList() {
        var platformValue = this.template.querySelector('.platformPickList').value;
        var entityTypeValue = this.template.querySelector('.entityTypeValue').value;
        if (this.newEstimationDetails == true) {
            getFilterComplexityMatrixFromEstDetails({ estimationSummary: this.estimationSummary, entityType: entityTypeValue, platform: platformValue, limitSize: this.rowLimit, offset: this.rowOffSet })
                .then(result => {
                    let updatedRecords = [...this.existEstimationDetailCompMat, ...result];
                    this.existEstimationDetailCompMat = updatedRecords;
                    if (this.existEstimationDetailCompMat.length == 0) {
                        this.template.querySelector('.norecords').style.display = 'block';
                        this.template.querySelector('.dataTable').style.display = 'none';
                        this.template.querySelector('.pull-right').style.display = 'none';

                    } else {
                        this.template.querySelector('.norecords').style.display = 'none';
                        this.template.querySelector('.dataTable').style.display = 'block';
                        this.template.querySelector('.pull-right').style.display = 'block';

                    }
                    this.hideSpinner();
                })
                .catch(error => {
                    console.log(error);
                    this.hideSpinner();
                });
        } else {
            getFilterComplexityMatrixFromcustomMetadata({ entityType: entityTypeValue, platform: platformValue, limitSize: this.rowLimit, offset: this.rowOffSet })
                .then(result => {
                    let updatedRecords = [...this.complexityMatrixList, ...result];
                    this.complexityMatrixList = updatedRecords;
                    if (this.complexityMatrixList.length == 0) {
                        this.template.querySelector('.norecords').style.display = 'block';
                        this.template.querySelector('.dataTable').style.display = 'none';
                    } else {
                        this.template.querySelector('.norecords').style.display = 'none';
                        this.template.querySelector('.dataTable').style.display = 'block';
                    }
                    this.hideSpinner();
                })
                .catch(error => {
                    console.log(error);
                    this.hideSpinner();
                });
        }
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
                this.hideSpinner();

            })
            .catch(error => {
                console.log(error);
                this.hideSpinner();

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
    @track ObsoleteStatus=false;

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
                if(data==='Obsolete'){
                    this.ObsoleteStatus=true;
                    this.isApproved=true;
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
               // alert('The estiomation is approved.!')
                if (result === 'Approved') {
                    /*this.getExistComplexityMatrixRecords();
                    this.disableAllTheFields();
                    this.handleExportToInitiatives();
                    this.handleForEnableEditButton();
                    this.enableApproverButtonForTPM();*/
                    this.approvedButton = false;
                    this.checkCurrentUserIsPM();

                }
                if(result ==='Invalid'){
                    alert('The estimation is not approved. Please fill the Scope Details and save the estimation.!')
                }else{
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
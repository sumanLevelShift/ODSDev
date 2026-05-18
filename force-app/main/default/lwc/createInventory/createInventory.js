import { LightningElement, api, track, wire } from 'lwc';
import ODS_Statussign from '@salesforce/resourceUrl/ODS_Statussign';
import EstimationSummaryButtonIcons from '@salesforce/resourceUrl/EstimationSummaryButtonIcons';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import getEffortTypePickListValue from '@salesforce/apex/CreateEstimationInventoryController.getEffortTypePickListValue';
import getComplexityPickListValue from '@salesforce/apex/CreateEstimationInventoryController.getComplexityPickListValue';
import getExistEstimationDetailForInventory from '@salesforce/apex/CreateEstimationInventoryController.getExistEstimationDetailForInventory';
import insertInventoryRecords from '@salesforce/apex/CreateEstimationInventoryController.insertInventoryRecords';
import getRecommendedEffortHours from '@salesforce/apex/CreateEstimationInventoryController.getRecommendedEffortHours';
import getRecordTypeIdForInventory from '@salesforce/apex/CreateEstimationInventoryController.getRecordTypeIdForInventory';
import getCustomerNamedetails from '@salesforce/apex/EstimationSummaryDetailsPageContrl.getCustomerNamedetails';
import checkExistRecordCount from '@salesforce/apex/CreateEstimationInventoryController.checkExistRecordCount';
import checkEstimationIsApproved from '@salesforce/apex/CreateEstimationInventoryController.checkEstimationIsApproved';
import clearStatusToMakeEdit from '@salesforce/apex/CreateEstimationSummaryController.clearStatusToMakeEdit';
import validationOnEffortCalculation from '@salesforce/apex/CreateEstimationSummaryController.validationOnEffortCalculation';

import EstimationSummaryResource from '@salesforce/resourceUrl/EstimationSummaryResource';

import CheckInitiativeIsSavedOrNot from '@salesforce/apex/ExportToInitiativeController.CheckInitiativeIsSavedOrNot';
import createEstimationElement from '@salesforce/apex/ExportToInitiativeController.createEstimationElement';

import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import getReEvaluateInitiatives from '@salesforce/apex/CreateEstimationSummaryController.getReEvaluateInitiatives';


import validationForApproverButton from '@salesforce/apex/CreateEstimationInventoryController.validationForApproverButton';
import approveTheEstimation from '@salesforce/apex/CreateEstimationSummaryController.approveTheEstimation';
import getStatusResult from '@salesforce/apex/CreateEstimationInventoryController.getStatusResult';
import getNotApproverUser from '@salesforce/apex/CreateEstimationSummaryController.getNotApproverUser';
import getcurrentUserAccessForEstimation from '@salesforce/apex/CreateEstimationSummaryController.getcurrentUserAccessForEstimation';
import getcurrentUserPM from '@salesforce/apex/CreateEstimationSummaryController.getcurrentUserPM';


import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import EstimateDetail_OBJECT from '@salesforce/schema/Estimation_Detail__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import PLATFORM_FIELD from '@salesforce/schema/Estimation_Detail__c.Platform__c';
import EntityType_FIELD from '@salesforce/schema/Estimation_Detail__c.Entity_Type__c';

export default class CreateInventory extends LightningElement {
    @api estimationSummary = '';
    @api accountId = '';
    @track spinner = ODS_Statussign;
    @track saveButton = EstimationSummaryButtonIcons + '/save_icon.svg';
    @track addButton = EstimationSummaryButtonIcons + '/add_icon.svg';
    @track cancelButton = EstimationSummaryButtonIcons + '/delete_icon.svg';
    @track exportButton = EstimationSummaryButtonIcons + '/download_icon.svg';
    @track exportToInitiativeButton = EstimationSummaryButtonIcons + '/export_initiative_icon.svg';
    @track editButtonIcon = EstimationSummaryButtonIcons + '/edit_icon.svg';
    @track approveButtonIcon = EstimationSummaryButtonIcons + '/approve_icon.svg';

    @track rows = [];
    @track index = 0;
    @track platformOptionList = [];
    @track entityOptionList = [];
    @track effortTypeOptionList = [];
    @track complexityOptionList = [];
    @track platformValue = '';
    @track entityValue = '';
    @track effortTypeValue = '';
    @track complexityValue = '';
    @track existEstimationDetailInventroy = [];
    @track newEstimationDetails = true;
    @track recordTypeIdPlatform = '';
    @track dependentEntityTypePicklist = [];
    @track isApproved = false;
    @track disableForAll = false;
    @track exportToInitiative = false;
    @api enableEditButton = false;
    @api edit = false;
    @track approvedButton = false;
    @track activeProgramManager = false;

    @track approverUserList = [];
    @track approverUserValue = '';
    @track isShowModalForApprovalUser = false;
    @track approverButtonOnPopUp = true;
    @track entityTypeOptions = [];
    @track enableForDeliveryRole = false;

    @wire(getRecordTypeIdForInventory)
    wiredRecordPlatform({ error, data }) {
        if (data) {
            this.recordTypeIdPlatform = data;
        } else if (error) {
            alert(error)
        }
    };
    @wire(getObjectInfo, { objectApiName: EstimateDetail_OBJECT })
    estimateDetailInfo;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeIdPlatform', fieldApiName: PLATFORM_FIELD })
    platFormFieldInfo({ data, error }) {
        if (data) {
            console.log('data.values--' + JSON.stringify(data.values));
            // this.platformOptionList = data.values;
            let lstOption = [];
            lstOption.push({
                value: '', label: '--None--'
            });
            for (var i = 0; i < data.values.length; i++) {
                lstOption.push({
                    value: data.values[i].value, label: data.values[i].label
                });
            }
            this.platformOptionList = lstOption;
        }
        if (error) {
            console.log(error)
        }
    }
    @track entityTypeFieldData = [];
    @wire(getPicklistValues, { recordTypeId: '$recordTypeIdPlatform', fieldApiName: EntityType_FIELD })
    etFieldInfo({ data, error }) {
        if (data)
            this.entityTypeFieldData = data;
    }

    @api triggerExitRecord(strString) {
        //this.rows=[];
        this.existEstimationDetailInventroy = [];
        this.template.querySelectorAll('.inputRows').forEach(item => {
            item.remove();

        });
        this.generateExistInventroyList();
        if (this.estimationSummary) {
            this.disableAllTheFields();
            this.handleExportToInitiatives();
            this.handleForEnableEditButton();
            this.enableApproverButtonForTPM();
        }
        if (this.edit == true) {
            this.isApproved = false;
            this.disableForAll = false;
            this.enableEditButton = false;
            this.template.querySelectorAll('lightning-icon').forEach(item => {
                item.style.pointerEvents = "auto";

            });
        }
        this.checkCurrentUserIsPM();
    }
    connectedCallback() {
        if (this.estimationSummary) {
            this.generateExistInventroyList();
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
    handleForEditButton() {
        let text = "Do you want to re-evaluate the estimates?";
        if (confirm(text) == true) {
            this.isApproved = false;
            this.disableForAll = false;
            this.enableEditButton = false;
            this.template.querySelectorAll('lightning-icon').forEach(item => {
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
                    this.disableForAll = true;
                    this.template.querySelectorAll('lightning-icon').forEach(item => {
                        item.style.pointerEvents = "none";

                    });
                }
                if (this.edit == true) {
                    this.isApproved = false;
                    this.disableForAll = false;
                    this.enableEditButton = false;
                    this.template.querySelectorAll('lightning-icon').forEach(item => {
                        item.style.pointerEvents = "auto";

                    });
                }
            })
            .catch(error => {
                console.log(error);
            });

    }
    @track newInventory = false;
    @track stopOnchangeForExistRecord = false;
    generateExistInventroyList() {
        //this.newEstimationDetails = true;

        let spin = this.template.querySelector('.spinnerDiv');
        if (spin) {
            spin.style.display = "block";
        }
        getExistEstimationDetailForInventory({ estimationSummary: this.estimationSummary })
            .then(result => {
                this.existEstimationDetailInventroy = [];
                this.existEstimationDetailInventroy = result;
                if (this.existEstimationDetailInventroy.length != 0) {
                    this.rows = [];
                    //  this.index=0;
                    //this.newEstimationDetails = false;
                    this.stopOnchangeForExistRecord = true;

                } else {
                    this.newInventory = true;
                    for (var i = 1; i < 6; i++) {
                        this.index++;
                        this.existEstimationDetailInventroy.push(
                            {
                                Id: this.index,
                                Platform__c: '',
                                Entity_Type__c: '',
                                Effort_Type__c: '',
                                Complexity__c: '',
                                Estimation_Element__c: '',
                                Brief_Description__c: '',
                                Quantity__c: 1,
                                Recommended_Effort__c: '',
                                Project_Specfic_Effort__c: '',
                                Rationale_If_Different_From_Recommended__c: '',
                                Assumptions__c: '',
                            }
                        );
                    }
                    this.stopOnchangeForExistRecord = false;
                }
                let spinNone = this.template.querySelector('.spinnerDiv');
                if (spinNone) {
                    spinNone.style.display = "none";
                }
                var count;
                var timer
                timer = setInterval(() => {
                    const e = new Event("change");
                    const element = this.template.querySelectorAll('.platformValue')
                    if (element) {
                        for (var i = 0; i < element.length; i++) {
                            element[i].dispatchEvent(e);
                        }
                        clearInterval(timer);
                    }

                    count++;
                    if (count > 3) {
                        clearInterval(timer);
                        this.stopOnchangeForExistRecord = false;
                    }
                }, 1000);
            })
            .catch(error => {
                console.log(error);
                let spinNone = this.template.querySelector('.spinnerDiv');
                if (spinNone) {
                    spinNone.style.display = "none";
                }
            });
    }
    renderedCallback() {
        //   Promise.all([loadStyle(this, EstimationInventroyCSS)], loadScript(this, jquery3_6_0))
        Promise.all([
            loadStyle(this, EstimationSummaryResource + '/EstimationInventroyCSS.css'),
            loadScript(this, EstimationSummaryResource + '/jquery3_6_0.js')
        ]).then(() => {
        }).catch(error => {
            this.error = error;
            console.log(' Error Occured-- ', +error);
        });
    }

    @wire(getEffortTypePickListValue)
    wiredEffortType({ error, data }) {
        if (data) {
            let lstOption = [];
            // lstOption.push({ value: '', label: "--None--" });
            for (var i = 0; i < data.length; i++) {
                lstOption.push({
                    value: data[i], label: data[i]
                });
            }
            this.effortTypeOptionList = lstOption;
            this.effortTypeValue = data[0];
        } else if (error) {
            alert(error)
            this.error = error;
        }
    }
    @wire(getComplexityPickListValue)
    wiredComplexity({ error, data }) {
        if (data) {
            let lstOption = [];
            //  lstOption.push({ value: '', label: "--None--" });
            for (var i = 0; i < data.length; i++) {
                lstOption.push({
                    value: data[i], label: data[i]
                });
            }
            this.complexityOptionList = lstOption;
            this.complexityValue = data[0];
        } else if (error) {
            alert(error)
            this.error = error;
        }
    }

    handleAddRow() {
        this.stopOnchangeForExistRecord = false;
        let spin = this.template.querySelector('.spinnerDiv');
        if (spin) {
            spin.style.display = "block";
        }
        //alert(this.index)
        if (this.index != 0) {
            this.index++;

        } else {
            this.index = 1;
        }
        this.rows.push(this.index);
        let rowsValues = Array.from(this.template.querySelectorAll("tr.inputRows"));
        var pos;
        if (rowsValues.length != 0) {
            pos = rowsValues.length;
            pos = pos - 1;
        }

        let spinNone = this.template.querySelector('.spinnerDiv');
        if (spinNone) {
            spinNone.style.display = "None";
        }

        var count;
        var timer
        timer = setInterval(() => {
            //entity type
            var entityTypeEle = rowsValues[pos].querySelector(".entityTypeValue");
            if (entityTypeEle) {
                var newEntityTypeRowsValues = this.template.querySelector("[data-entity='" + this.index + "']");
                if (newEntityTypeRowsValues) {
                    newEntityTypeRowsValues.value = entityTypeEle.value;
                }
            }
            //platform
            var platformValue = rowsValues[pos].querySelector("lightning-combobox.platformValue")
            if (platformValue) {
                var newPlatFormRowsValues = this.template.querySelector("[data-platform='" + this.index + "']");
                if (newPlatFormRowsValues) {
                    newPlatFormRowsValues.value = platformValue.value;
                }
            }
            //effort type
            var effortTypeEle = rowsValues[pos].querySelector("lightning-combobox.effortTypeValue")
            if (effortTypeEle) {
                var newEffortTypeValues = this.template.querySelector("[data-effort='" + this.index + "']");
                if (newEffortTypeValues) {
                    newEffortTypeValues.value = effortTypeEle.value;
                }
            }
            const e = new Event("change");
            const element = this.template.querySelectorAll("[data-platform='" + this.index + "']")
            if (element) {
                for (var i = 0; i < element.length; i++) {
                    element[i].dispatchEvent(e);
                }
                clearInterval(timer);
            }

            count++;
            if (count > 3) {
                clearInterval(timer);
            }
        }, 1000);

    }

    removeRow(event) {
        if (this.isApproved != true) {
            var id = event.target.dataset.id;
            const tds = this.template.querySelector("[data-id='" + id + "']");
            var trId = $(tds).closest('tr').attr('id');
            let selectedRow = this.template.querySelectorAll("[id='" + trId + "']");
            let s;
            selectedRow.forEach(b => {
                b.remove();
            });
            if (this.newInventory !== true) {
                this.calculateEffortTotalFunction();
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
    handleForInsertInventroy() {
        try {
            this.showSpinner();
            var flag = false;
            this.template.querySelectorAll('.requiredClass').forEach(element => {
                if (!element.value) {
                    element.setCustomValidity(element.validationMessage);
                    element.reportValidity();
                    flag = true;
                } else {
                    element.setCustomValidity('');
                    element.reportValidity();
                }
            });

            if (flag) {
                alert('Please fill in all the required fields.');
                this.hideSpinner();
            } else {

                var validationFlag = false;
                var validationFlag1 = false;
                var records = [];
                let rowsValues = Array.from(this.template.querySelectorAll("tr.inputRows"));
                var i = 0;
                rowsValues.map(row => {
                    i++;
                    let platformValue = row.querySelector("lightning-combobox.platformValue");
                    let entityTypeValue = row.querySelector(".entityTypeValue");
                    let effortTypeValue = row.querySelector(".effortTypeValue");
                    let estimationElementValue = row.querySelector(".estimationElementValue");
                    let briefDescriptionValue = row.querySelector(".briefDescriptionValue");
                    let complexityValue = row.querySelector(".complexityValue");
                    let quantityValue = row.querySelector(".quantityValue");
                    let recommendedEffortValue = row.querySelector(".recommendedEffortValue");
                    let revisedEffortValue = row.querySelector(".revisedEffortValue");
                    let rationalIfDifferentValue = row.querySelector(".rationalIfDifferentValue");
                    let assumptionValue = row.querySelector(".assumptionValue");
                    if (revisedEffortValue.value == 0 || !revisedEffortValue.value) {
                        validationFlag1 = true;
                        revisedEffortValue.setAttribute("required", "true");
                        revisedEffortValue.reportValidity();

                    }
                    if (revisedEffortValue.value && recommendedEffortValue.value != 0) {
                        if (recommendedEffortValue.value != revisedEffortValue.value) {
                            if (!rationalIfDifferentValue.value) {
                                validationFlag = true;
                            }
                        }
                    }

                    if (validationFlag == false) {
                        var estimationElement = estimationElementValue.value;
                        if (estimationElement) {
                            if (estimationElement.includes("\\")) {
                                estimationElement = estimationElement.replaceAll("\\", "/");
                            }
                        }
                        var briefDescription = briefDescriptionValue.value;
                        if (briefDescription) {
                            if (briefDescription.includes("\\")) {
                                briefDescription = briefDescription.replaceAll("\\", "/");
                            }
                        }
                        records.push({
                            SNO: i,
                            PlatformValue: platformValue.value,
                            EntityTypeValue: entityTypeValue.value,
                            EffortTypeValue: effortTypeValue.value,
                            EstimationElementValue: estimationElement,
                            BriefDescriptionValue: briefDescription,
                            ComplexityValue: complexityValue.value,
                            QuantityValue: quantityValue.value,
                            RecommendedEffortValue: recommendedEffortValue.value,
                            RevisedEffortValue: revisedEffortValue.value,
                            RationalIfDifferentValue: rationalIfDifferentValue.value,
                            AssumptionValue: assumptionValue.value,
                        });
                    }
                });

                //console.log('---record---' + JSON.stringify(records))
                if (validationFlag1 == true) {
                    alert('Please fill the Planned Effort (Hours) fields!');
                    this.hideSpinner();

                }
                if (validationFlag == true) {
                    alert('Remarks/Rationale is required when Planned Effort is not same as Recommeneded Effort!');
                    this.hideSpinner();

                } else if (validationFlag == false && validationFlag1 == false) {
                    if (records) {
                        insertInventoryRecords({ insertInventroy: JSON.stringify(records), estimationSummaryId: this.estimationSummary })
                            .then(result => {

                                alert('Inventory line items are successfully submitted!')

                                // this.generateExistInventroyList();

                                const custEvent1 = new CustomEvent(
                                    'callunsavedchanges', {
                                    detail: false,
                                });
                                this.dispatchEvent(custEvent1);

                                const custEvent = new CustomEvent(
                                    'callfromchildcmp', {
                                    detail: "3",
                                });
                                this.dispatchEvent(custEvent);

                                this.reSubmitEffortCal();
                                this.hideSpinner();

                            })
                            .catch(error => {
                                console.log(error);
                                this.hideSpinner();

                            });
                    }
                }
            }
        } catch (e) {
            console.log(e.name + ' messae:' + e.message + 'at ' + e.lineNumber);
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
    handleReset() {
        this.existEstimationDetailInventroy = [];
        this.rows = [];
        if (this.estimationSummary) {
            this.generateExistInventroyList();
        }
    }
    getRecommendedEffort(event) {
        var platformOnchange = event.target.name;
        let spin = this.template.querySelector('.spinnerDiv');
        if (spin) {
            spin.style.display = "block";
        }
        if (platformOnchange === 'Platform') {
            const selectedVal = event.target.value;
            const rowId = this.template.querySelector("[data-entity='" + event.target.dataset.rowid + "']");
            let lstOption = [];
            lstOption.push({
                value: '', label: '--None--'
            });
            if (selectedVal != '') {
                let key = this.entityTypeFieldData.controllerValues[selectedVal];
                var childDropdown = this.entityTypeFieldData.values.filter(opt => opt.validFor.includes(key));
                for (var i = 0; i < childDropdown.length; i++) {
                    lstOption.push({
                        value: childDropdown[i].value, label: childDropdown[i].label
                    });
                }
            }
            if (rowId) {
                rowId.options = lstOption;
            }
        }

        var id = event.target.dataset.rowid;
        const tds = this.template.querySelector("[data-rowid='" + id + "']");
        var trId = $(tds).closest('tr').attr('id');
        let rowsValues = Array.from(this.template.querySelectorAll("[id='" + trId + "']"));
        rowsValues.map(row => {
            var platform, entityType, effortType, complexity;
            let platformValue = row.querySelector("lightning-combobox.platformValue");
            if (platformValue) {
                platform = platformValue.value;
            }
            let entityTypeValue = row.querySelector(".entityTypeValue");
            if (entityTypeValue) {
                entityType = entityTypeValue.value;
            }
            let effortTypeValue = row.querySelector(".effortTypeValue");
            if (effortTypeValue) {
                effortType = effortTypeValue.value;
            }
            let complexityValue = row.querySelector(".complexityValue");
            if (complexityValue) {
                complexity = complexityValue.value;
            }
            if (!this.stopOnchangeForExistRecord) {
                let spinblock = this.template.querySelector('.spinnerDiv');
                if (spinblock) {
                    spinblock.style.display = "block";
                }
                if (platform && entityType && effortType && complexity) {
                    getRecommendedEffortHours({ platform: platform, entityType: entityType, effortType: effortType, complexity: complexity, estimationSummary: this.estimationSummary })
                        .then(result => {
                            let recommendedEffortValue = row.querySelector(".recommendedEffortValue");
                            recommendedEffortValue.value = result;
                            console.log('this.stopOnchangeForExistRecord--' + this.stopOnchangeForExistRecord);
                            let revisedEffortValue = row.querySelector(".revisedEffortValue");
                            revisedEffortValue.value = result;
                            let spinNone = this.template.querySelector('.spinnerDiv');
                            if (spinNone) {
                                spinNone.style.display = "none";
                            }
                            this.handleInvokeParentMethod();
                        })
                        .catch(error => {
                            console.log(error);
                            let spinNone = this.template.querySelector('.spinnerDiv');
                            if (spinNone) {
                                spinNone.style.display = "none";
                            }
                        });
                }
            }
        });
        let spinNone = this.template.querySelector('.spinnerDiv');
        if (spinNone) {
            spinNone.style.display = "none";
        }
    }
    handleInvokeParentMethod() {
        checkExistRecordCount({ estimateSummaryId: this.estimationSummary })
            .then(data => {
                if (data == true) {
                    this.calculateEffortTotalFunction();
                }
            }).catch(error => {
                console.log(error);
            });
    }
    calculateEffortTotalFunction() {
        var totalOfPro = 0;
        var totalOfDec = 0;
        var totalOfProPer = 0;
        var totalOfDecPer = 0;
        var totalOfEffortMonth = 0;
        let rowsValues = Array.from(this.template.querySelectorAll("tr.inputRows"));
        rowsValues.map(row => {
            let effortTypeValue = row.querySelector(".effortTypeValue");
            let recommendedEffortValue = row.querySelector(".recommendedEffortValue");
            let revisedEffortValue = row.querySelector(".revisedEffortValue");
            let quantityValue = row.querySelector(".quantityValue");

            if (effortTypeValue.value == 'Programming') {
                if (revisedEffortValue.value && revisedEffortValue.value != 0) {
                    var revised = parseFloat(revisedEffortValue.value) * parseFloat(quantityValue.value);
                    totalOfPro = parseFloat(totalOfPro) + revised;
                } else {
                    var recomm = parseFloat(recommendedEffortValue.value) * parseFloat(quantityValue.value);
                    totalOfPro = parseFloat(totalOfPro) + recomm;
                }
            } else {
                if (revisedEffortValue.value && revisedEffortValue.value != 0) {
                    var revised = parseFloat(revisedEffortValue.value) * parseFloat(quantityValue.value);
                    totalOfDec = parseFloat(totalOfDec) + revised;
                } else {
                    var recomm = parseFloat(recommendedEffortValue.value) * parseFloat(quantityValue.value);
                    totalOfDec = parseFloat(totalOfDec) + recomm;
                }
            }
        });
        if (!totalOfDec) {
            totalOfDec = 0;
        }
        if (!totalOfPro) {
            totalOfPro = 0;
        }
        totalOfProPer = parseFloat(totalOfPro) + (parseFloat(totalOfPro) / parseFloat(totalOfDec));
        totalOfDecPer = parseFloat(totalOfDec) + (parseFloat(totalOfPro) / parseFloat(totalOfDec));
        if (!totalOfProPer) {
            totalOfProPer = 0;
        }
        if (!totalOfDecPer) {
            totalOfDecPer = 0;
        }
        var technologySFDC = [];
        getCustomerNamedetails({ estimateSummaryId: this.estimationSummary })
            .then(data => {
                if (data) {
                    totalOfEffortMonth = (totalOfPro + totalOfDec) / (data.Work_Hours_Per_Day__c * data.Work_Days_Per_Month__c);
                    technologySFDC.push({
                        totalOfProgramming: totalOfPro.toFixed(2),
                        totalofDeclarative: totalOfDec.toFixed(2),
                        totalOfProgrammingPercentage: totalOfProPer,
                        totalofDeclarativePercentage: totalOfDecPer,
                        totalEffortOfMonths: totalOfEffortMonth.toFixed(2)
                    });
                    const custEvent = new CustomEvent(
                        'calleffortcalculation', {
                        detail: technologySFDC,
                    });
                    this.dispatchEvent(custEvent);
                }
            })
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

            })
            .catch(error => {
                console.log(error);
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
                        this.template.querySelectorAll('lightning-icon').forEach(item => {
                            item.style.pointerEvents = "none";

                        });
                    }
                    /* if (this.edit == true) {
                         this.isApproved = false;
                         this.enableEditButton = false;
                         this.template.querySelectorAll('lightning-icon').forEach(item => {
                             item.style.pointerEvents = "auto";
 
                         });
                     }*/
                }
                if (data === 'Obsolete') {
                    this.ObsoleteStatus = true;
                    this.isApproved = true;
                    this.disableForAll = true;
                    this.template.querySelectorAll('lightning-icon').forEach(item => {
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
        this.showSpinner();
        approveTheEstimation({ summaryId: this.estimationSummary, userName: this.approverUserValue })
            .then(result => {
                this.hideSpinner();
                // alert('The estiomation is approved.!')
                if (result === 'Approved') {
                    /* this.generateExistCheckList();
                     this.disableAllTheFields();
                     this.handleExportToInitiatives();
                     this.handleForEnableEditButton();
                     this.enableApproverButtonForTPM();*/
                    this.checkCurrentUserIsPM();


                    this.approvedButton = false;
                }
                if (result === 'Invalid') {
                    alert('The estimation is not approved. Please fill the Scope Details and save the estimation.!')
                } else {
                    alert('The estimation is approved.!');
                }
                this.generateExistInventroyList();
                this.disableAllTheFields();
                this.handleExportToInitiatives();
                this.handleForEnableEditButton();
                this.enableApproverButtonForTPM();
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
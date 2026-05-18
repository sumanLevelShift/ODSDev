import { LightningElement, track, wire } from 'lwc';
import ODS_Statussign from '@salesforce/resourceUrl/ODS_Statussign';
import getAllSObjects from '@salesforce/apex/conditionalRendererConfigController.getAllSObjects';
import getFieldAPINames from '@salesforce/apex/conditionalRendererConfigController.getFieldAPINames';
import getFieldType from '@salesforce/apex/conditionalRendererConfigController.getFieldType';
import insertConditionalRendererConfig from '@salesforce/apex/conditionalRendererConfigController.insertConditionalRendererConfig';
import getFieldAPINamesForFields from '@salesforce/apex/conditionalRendererConfigController.getFieldAPINamesForFields';
import checkDuplicateRecords from '@salesforce/apex/conditionalRendererConfigController.checkDuplicateRecords';
import getExistingRecords from '@salesforce/apex/conditionalRendererConfigController.getExistingRecords';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import conditionalRendererCSS from '@salesforce/resourceUrl/conditionalRendererCSS';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class ConditionalRendererConfig extends LightningElement {
    @track spinner = ODS_Statussign;
    sObjectNames = [];
    selectedObject = '';
    selectedField = '';
    selectedFieldType = '';
    @track tableData = [];
    @track oldTableData = [];
    @track index = 0;
    @track stopCalling = false;
    actionOptions = [
        { label: 'ENABLE', value: 'ENABLE' },
        { label: 'DISABLE', value: 'DISABLE' },
        { label: 'SHOW', value: 'SHOW' },
        { label: 'HIDE', value: 'HIDE' },
    ];
    typeOptions = [
        { label: 'BOOLEAN', value: 'BOOLEAN' },
        { label: 'PICKLIST', value: 'PICKLIST' },
        { label: 'NUMBER', value: 'NUMBER' },
        { label: 'STRING', value: 'STRING' },
    ];
    @wire(getAllSObjects)
    objectNameList({ data, error }) {
        if (data) {
            this.sObjectNames = [];
            let lstOption = [];
            for (var i = 0; i < data.length; i++) {
                lstOption.push({
                    value: data[i], label: data[i]
                });
            }
            this.sObjectNames = lstOption;
        } else if (error) {
            console.error(error);
        }
    }
    connectedCallback() {
        Promise.all([
            loadStyle(this, conditionalRendererCSS)

        ])
        this.generateRecords();
    }
    generateRecords() {
        this.showSpinner();
        this.oldTableData = [];
        this.tableData = [];
        this.index = 0;
        getExistingRecords()
            .then(data => {
                this.stopCalling = true;
                this.showSpinner();
                if (data) {
                    this.oldTableData = data;
                } else {
                    for (var i = 1; i < 2; i++) {
                        this.oldTableData.push(
                            {
                                Id: this.index,
                                Sobject__c: '',
                                Controlling_Field__c: '',
                                Type__c: '',
                                Value__c: '',
                                Fields__c: '',
                                Action__c: 'ENABLE'
                            }
                        );
                    }
                }
                var count;
                var timer
                timer = setInterval(() => {
                    this.showSpinner();
                    const e = new Event("focusout");
                    const element = this.template.querySelectorAll('.sObjectClass')
                    if (element) {
                        for (var i = 0; i < element.length; i++) {
                            element[i].dispatchEvent(e);
                        }
                    }
                    const e1 = new Event("change");
                    const element1 = this.template.querySelectorAll('.controllingFieldClass')
                    if (element1) {
                        for (var i = 0; i < element1.length; i++) {
                            element1[i].dispatchEvent(e1);
                        }
                        clearInterval(timer);
                    }
                    count++;
                    if (count > 3) {
                        clearInterval(timer);
                        this.stopCalling = false;
                    }
                }, 1000);
                this.hideSpinner();
            })
            .catch(error => {
                console.error(error);
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
        this.template.querySelector('.spinnerDiv').style.display = "none";
    }

    handleDuplicateRecord(rowId) {
        if (!this.stopCalling) {
            const sobjectRow = this.template.querySelector("[data-sobject='" + rowId + "']");
            const controllingFieldRow = this.template.querySelector("[data-cfield='" + rowId + "']");
            const valueRow = this.template.querySelector("[data-value='" + rowId + "']");
            const actionRow = this.template.querySelector("[data-action='" + rowId + "']");

            checkDuplicateRecords({ sObjectName: sobjectRow.value, controllingField: controllingFieldRow.value, value: valueRow.value, action: actionRow.value })
                .then((result) => {
                    if (result) {
                        alert('Duplicate entire is found.!')
                    }
                })
                .catch((error) => {
                    console.error(error);
                    this.hideSpinner();

                });
        }
    }

    handleObjectChange(event) {

        const rowId = this.template.querySelector("[data-cfield='" + event.target.dataset.rowid + "']");
        const sobject = this.template.querySelector("[data-sobject='" + event.target.dataset.rowid + "']");
        this.selectedObject = sobject.value;
        let lstOption = [];
        console.log('sobject-' + this.selectedObject);
        if (this.selectedObject) {
            this.showSpinner();
            getFieldAPINames({ objectAPIName: this.selectedObject })
                .then((result) => {
                    if (rowId && result) {
                        console.log('result--' + JSON.stringify(result))
                        lstOption = result.map((field) => ({ label: field, value: field }));
                        rowId.options = lstOption;
                    }
                    this.hideSpinner();

                })
                .catch((error) => {
                    console.error(error);
                    this.hideSpinner();

                });


        }
        this.handleDuplicateRecord(event.target.dataset.rowid);
    }

    handleFieldChange(event) {
        this.showSpinner();
        const fieldRow = this.template.querySelector("[data-cfield='" + event.target.dataset.rowid + "']");
        const rowId = this.template.querySelector("[data-type='" + event.target.dataset.rowid + "']");
        const sobject = this.template.querySelector("[data-sobject='" + event.target.dataset.rowid + "']");
        getFieldType({ objectAPIName: sobject.value, fieldAPIName: fieldRow.value })
            .then((result) => {
                if (rowId && result) {
                    rowId.value = result;
                    rowId.disabled = true;
                }
                this.hideSpinner();

            })
            .catch((error) => {
                console.error(error);
                this.hideSpinner();

            });
        const rowIdField = this.template.querySelector("[data-mfield='" + event.target.dataset.rowid + "']");
        let fieldOption = [];
        getFieldAPINamesForFields({ objectAPIName: sobject.value, fieldName: fieldRow.value })
            .then((result) => {
                if (rowIdField && result) {
                    fieldOption = result.map((field) => ({ label: field, value: field }));
                    rowIdField.options = fieldOption;
                }
                this.hideSpinner();

            })
            .catch((error) => {
                console.error(error);
                this.hideSpinner();

            });
        this.handleDuplicateRecord(event.target.dataset.rowid);

    }
    handleValue(event) {
        this.handleDuplicateRecord(event.target.dataset.rowid);
    }
    handleAction(event) {
        this.handleDuplicateRecord(event.target.dataset.rowid);
    }
    addNewRow() {
        if (this.index != 0) {
            this.index++;

        } else {
            this.index = 1;
        }

        this.tableData.push(this.index);

    }
    removeRow(event) {
        var id = event.target.dataset.id;
        let selectedRow = this.template.querySelectorAll("[data-tr='" + id + "']");
        selectedRow.forEach(b => {
            b.remove();
        });
    }

    handleSubmit(event) {
        let isValid = true;
        const searchableCombobox = this.template.querySelector("[data-sobject='" + event.target.dataset.rowid + "']");
        if (searchableCombobox) {
            let flag = searchableCombobox.validate();
            if (!flag) {
                isValid = false;
            }
        }
        const inputs = this.template.querySelectorAll("[data-required='" + event.target.dataset.rowid + "']");
        inputs.forEach(input => {
            if (!input.value) {
                input.setCustomValidity('This field is required');
                input.reportValidity();
                isValid = false;
            }
        });
        if (isValid) {
            var records = [];
            let rowsValues = this.template.querySelector("[data-tr='" + event.target.dataset.rowid + "']");
            if (rowsValues) {
                let sObjectClass = rowsValues.querySelector(".sObjectClass");
                let controllingFieldClass = rowsValues.querySelector(".controllingFieldClass");
                let dataTypeClass = rowsValues.querySelector(".dataTypeClass");
                let valueClass = rowsValues.querySelector(".valueClass");
                let actionClass = rowsValues.querySelector(".actionClass");
                let fieldClass = rowsValues.querySelector(".fieldClass");
                records.push({
                    RowId: event.target.dataset.rowid,
                    SObject: sObjectClass.value,
                    ControllingFields: controllingFieldClass.value,
                    Type: dataTypeClass.value,
                    Value: valueClass.value,
                    Action: actionClass.value,
                    Field: fieldClass.selectedItems

                });

                console.log('records--' + JSON.stringify(records));
                insertConditionalRendererConfig({ conditionalRecords: JSON.stringify(records) })
                    .then(result => {
                        alert('Conditional Renderer Config are successfully submitted!');
                        var eve = setTimeout(() => {
                            this.generateRecords();
                            clearTimeout(eve);
                        }, 5000);
                        //window.location.reload();
                    })
                    .catch(error => {
                        console.log(error);
                        this.hideSpinner();

                    });
            }
            /*  if (records) {
                insertConditionalRendererConfig({ conditionalRecords: JSON.stringify(records) })
                    .then(result => {
                        alert('Conditional Renderer Config are successfully submitted!');
                        window.location.reload();
                    })
                    .catch(error => {
                        console.log(error);
                        this.hideSpinner();
    
                    });
            }*/
        }

        /*  const inputs = this.template.querySelectorAll('lightning-combobox.requiredField');
        let isValid = true;
        const searchableCombobox = this.template.querySelectorAll('c-searchable-combobox');
        searchableCombobox.forEach(input => {
            let flag = input.validate();
            if (!flag) {
                isValid = false;
            }
        });
        inputs.forEach(input => {
            if (!input.value) {
                input.setCustomValidity('This field is required');
                input.reportValidity();
                isValid = false;
            }
        });
    
    
        if (isValid) {
            var records = [];
            let rowsValues = Array.from(this.template.querySelectorAll("tr.inputRows"));
            rowsValues.map(row => {
                let sObjectClass = row.querySelector(".sObjectClass");
                let controllingFieldClass = row.querySelector(".controllingFieldClass");
                let dataTypeClass = row.querySelector(".dataTypeClass");
                let valueClass = row.querySelector(".valueClass");
                let actionClass = row.querySelector(".actionClass");
                let fieldClass = row.querySelector(".fieldClass");
                if (sObjectClass.value) {
                    records.push({
                        SObject: sObjectClass.value,
                        ControllingFields: controllingFieldClass.value,
                        Type: dataTypeClass.value,
                        Value: valueClass.value,
                        Action: actionClass.value,
                        Field: fieldClass.selectedItems
    
                    });
    
                }
            });
            if (records) {
                insertConditionalRendererConfig({ conditionalRecords: JSON.stringify(records) })
                    .then(result => {
                        alert('Conditional Renderer Config are successfully submitted!');
                        window.location.reload();
                    })
                    .catch(error => {
                        console.log(error);
                        this.hideSpinner();
    
                    });
            }
        }
        */
    }
}
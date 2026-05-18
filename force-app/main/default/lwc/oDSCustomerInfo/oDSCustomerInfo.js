import { LightningElement, api, wire, track } from 'lwc';
import { createMessageContext, APPLICATION_SCOPE, subscribe } from 'lightning/messageService';
import getAccountService from '@salesforce/apex/ODS_CustomerInfoControllerLWC.getAccountService';
import getCurrentAccount from '@salesforce/apex/ODS_CustomerInfoControllerLWC.getCurrentAccount';
import getAccountIncidents from '@salesforce/apex/ODS_CustomerInfoControllerLWC.getAccountIncidents';
import getSalesforceAFDetails from '@salesforce/apex/ODS_CustomerInfoControllerLWC.getSalesforceAFDetails';
import updateCustomerInfo from '@salesforce/apex/ODS_CustomerInfoControllerLWC.updateCustomerInfo';
import updateKickoffStatus from '@salesforce/apex/ODS_CustomerInfoControllerLWC.updateKickoffStatus';

//import getCustomerEngagementScorePicklist from '@salesforce/apex/ODS_CustomerInfoControllerLWC.getCustomerEngagementScorePicklist';
//import getCustomerEngagementValue from '@salesforce/apex/ODS_CustomerInfoControllerLWC.getCustomerEngagementValue';
import getEmail from '@salesforce/apex/ODS_CustomerInfoControllerLWC.getEmail';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import SRF_FIELD from '@salesforce/schema/Account_Services__c.Status_Report_Frequency__c';
import ACCOUNTSERVICES_OBJECT from '@salesforce/schema/Account_Services__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ODS_Statussign from '@salesforce/resourceUrl/ODS_Statussign';
import { loadStyle } from 'lightning/platformResourceLoader';
import CustomerInfoCSS from '@salesforce/resourceUrl/CustomerInfoCSS';
import updateSessionData from '@salesforce/apex/ODS_CustomerInfoControllerLWC.updateSessionData';
import getCases from '@salesforce/apex/ODS_CustomerInfoControllerLWC.getCases';
import updateCases from '@salesforce/apex/ODS_CustomerInfoControllerLWC.updateCases';

import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import CustomerPortalAccess_Field from '@salesforce/schema/Account.Customer_Portal_Access__c';
import SetupWeeklyMonthlyMeeting_Field from '@salesforce/schema/Account.Setup_Weekly_Monthly_Meeting__c';
import EnvironmentAccess_Field from '@salesforce/schema/Account.Environment_Access__c';
import OnboardhingDocument_Field from '@salesforce/schema/Account.Onboarding_Document__c';
import LightningReadinessCheck_Field from '@salesforce/schema/Account.Lightning_Readiness_Check__c';
import CustomerEnagementScore_Field from '@salesforce/schema/Account.Customer_Engagement_Score__c';
import KickOffStatus_Field from '@salesforce/schema/Account.Kickoff__c';
import ProjectStatus_FIELD from '@salesforce/schema/Account_Services__c.Project_Status_LV__c';
import ScopeofWork_FIELD from '@salesforce/schema/Account_Services__c.Scope_of_Work_LV__c';
import Schedule_FIELD from '@salesforce/schema/Account_Services__c.Schedule_LV__c';
import Budget_FIELD from '@salesforce/schema/Account_Services__c.Budget_LV__c';

export default class ODSCustomerInfos extends LightningElement {
    @track SRFPicklist;
    @track CESPicklist;
    @track CESValue;
    @track error;
    @track spinner = ODS_Statussign;
    @track allowTimesheetBoolean = false;
    @track salesforceAF;
    @track currentAccount = [];
    @track CustomerEnagementScoreOption = [];
    @track kickOffStatusOption = [];
    @track isShowModal = false;

    @wire(getObjectInfo, { objectApiName: ACCOUNTSERVICES_OBJECT })
    accountServiceMetadata;
    @track casesList;
    @track CustomerPortalAccessOption = [];
    @track SetupWeeklyMonthlyMeeting = [];
    @track EnvironmentAccessOption = [];
    @track OnboardhingDocumentOption = [];
    @track LightningReadinessCheck = [];
    @track kickoffCompletionButton = true;
    @track ProjectStatuslist;
    @track ScopeofWorklist;
    @track Schedulelist;
    @track Budgetlist;

    @wire(getPicklistValues, { recordTypeId: '$accountServiceMetadata.data.defaultRecordTypeId', fieldApiName: SRF_FIELD })
    wiredPickListValueSRF({ error, data }) {

        if (data) {
            this.SRFPicklist = data.values;
            this.error = undefined;
        }
        if (error) {
            this.error = error;
            this.SRFPicklist = undefined;
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$accountServiceMetadata.data.defaultRecordTypeId', fieldApiName: ProjectStatus_FIELD })
    wiredPickListValueProjectStatus({error, data }) {

        if (data) {
            this.ProjectStatuslist = data.values;
            this.error = undefined;
        }
        if (error) {
            this.error = error;
            this.ProjectStatuslist = undefined;
        }
    }
     @wire(getPicklistValues, { recordTypeId: '$accountServiceMetadata.data.defaultRecordTypeId', fieldApiName: ScopeofWork_FIELD })
    wiredPickListValueScope({ data, error }) {

        if (data) {
            this.ScopeofWorklist = data.values;
            this.error = undefined;
        }
        if (error) {
            this.error = error;
            this.ScopeofWorklist = undefined;
        }
    }
     @wire(getPicklistValues, { recordTypeId: '$accountServiceMetadata.data.defaultRecordTypeId', fieldApiName: Schedule_FIELD })
    wiredPickListValueSchedul({ data, error }) {

        if (data) {
            this.Schedulelist = data.values;
            this.error = undefined;
        }
        if (error) {
            this.error = error;
            this.Schedulelist = undefined;
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$accountServiceMetadata.data.defaultRecordTypeId', fieldApiName: Budget_FIELD })
    wiredPickListValueBudget({ data, error }) {

        if (data) {
            this.Budgetlist = data.values;
            this.error = undefined;
        }
        if (error) {
            this.error = error;
            this.Budgetlist = undefined;
        }
    }


    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    accountMetadata;

    @wire(getPicklistValues, { recordTypeId: '$accountMetadata.data.defaultRecordTypeId', fieldApiName: CustomerPortalAccess_Field })
    wiredCPAPickListValue({ data, error }) {
        if (data) {
            this.CustomerPortalAccessOption = [];
            let lstOption = [];
            lstOption.push({
                value: '', label: '--None--'
            });
            for (var i = 0; i < data.values.length; i++) {
                lstOption.push({
                    value: data.values[i].value, label: data.values[i].value
                });
            }
            this.CustomerPortalAccessOption = lstOption;
        }
        if (error) {
            this.error = error;
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$accountMetadata.data.defaultRecordTypeId', fieldApiName: SetupWeeklyMonthlyMeeting_Field })
    wiredSWMMPickListValue({ data, error }) {
        if (data) {
            this.SetupWeeklyMonthlyMeeting = [];
            let lstOption = [];
            lstOption.push({
                value: '', label: '--None--'
            });
            for (var i = 0; i < data.values.length; i++) {
                lstOption.push({
                    value: data.values[i].value, label: data.values[i].value
                });
            }
            this.SetupWeeklyMonthlyMeeting = lstOption;
        }
        if (error) {
            this.error = error;
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$accountMetadata.data.defaultRecordTypeId', fieldApiName: EnvironmentAccess_Field })
    wiredEAPickListValue({ data, error }) {
        if (data) {
            this.EnvironmentAccessOption = [];
            let lstOption = [];
            lstOption.push({
                value: '', label: '--None--'
            });
            for (var i = 0; i < data.values.length; i++) {
                lstOption.push({
                    value: data.values[i].value, label: data.values[i].value
                });
            }
            this.EnvironmentAccessOption = lstOption;
        }
        if (error) {
            this.error = error;
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$accountMetadata.data.defaultRecordTypeId', fieldApiName: OnboardhingDocument_Field })
    wiredODPickListValue({ data, error }) {
        if (data) {
            this.OnboardhingDocumentOption = [];
            let lstOption = [];
            lstOption.push({
                value: '', label: '--None--'
            });
            for (var i = 0; i < data.values.length; i++) {
                lstOption.push({
                    value: data.values[i].value, label: data.values[i].value
                });
            }
            this.OnboardhingDocumentOption = lstOption;
        }
        if (error) {
            this.error = error;
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$accountMetadata.data.defaultRecordTypeId', fieldApiName: LightningReadinessCheck_Field })
    wiredLRCPickListValue({ data, error }) {
        if (data) {
            this.LightningReadinessCheck = [];
            let lstOption = [];
            lstOption.push({
                value: '', label: '--None--'
            });
            for (var i = 0; i < data.values.length; i++) {
                lstOption.push({
                    value: data.values[i].value, label: data.values[i].value
                });
            }
            this.LightningReadinessCheck = lstOption;
        }
        if (error) {
            this.error = error;
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$accountMetadata.data.defaultRecordTypeId', fieldApiName: CustomerEnagementScore_Field })
    wiredCESPickListValue({ data, error }) {
        if (data) {
            //  alert(JSON.stringify(data.values))
            this.CustomerEnagementScoreOption = data.values;
        }
        if (error) {
            this.error = error;
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$accountMetadata.data.defaultRecordTypeId', fieldApiName: KickOffStatus_Field })
    wiredkickOffPickListValue({ data, error }) {
        if (data) {

            this.kickOffStatusOption = data.values;
        }
        if (error) {
            this.error = error;
        }
    }
    context = createMessageContext();
    @api accId = '';
    @api srvcId = '';
    @track AccountInformation;
    @track incidents = [];
    @track currentSubject;
    @track currentHtmlBody;
    @track SRFValue;
    @track ProjectStatusValue;
    @track ScopeofWorkValue;
    @track ScheduleValue;
    @track BudgetValue;

    // readOnlyBool = true; //disable
    connectedCallback() {
        this.getCustomerInfo(this.accId);
        this.getIncidents(this.accId);
        this.getSalesforceAFInfo(this.accId);
        this.getReleaseCases(this.accId, this.srvcId);
        this.getCurrentAccountDetail();

        updateSessionData({ accountId: this.accId, serviceId: this.srvcId })
            .then(data => {
            })
            .catch(error => {
            });


    }
    getCurrentAccountDetail() {
        getCurrentAccount({ accountId: this.accId })
            .then(data => {
                if (data) {
                    this.currentAccount = [];
                    this.currentAccount = data;
                    if (this.currentAccount.Kickoff__c == 'Completed') {
                        this.kickoffCompletionButton = false;
                    }
                }
            })
            .catch(error => {
                // console.log(error);
                this.error = error;
            });
    }
    value;

    optionValue = [
        { label: 'Completed', value: 'Closed' },
        { label: 'In Progress', value: 'In Progress' },
        { label: 'Not Started', value: 'Not Started' },
        { label: 'Pending Customer Review', value: 'Pending Customer Review' },
    ];
    //Release
    getReleaseCases(accId, srvcId) {
        getCases({ accountId: accId, serviceId: srvcId })
            .then(data => {
                this.casesList = JSON.parse(JSON.stringify(data));

                // console.log('Cases Data : ', JSON.stringify(this.casesList));

                this.casesList.forEach(element => {
                    if (element.Status == 'Closed') { element.isDisable = true } else { element.isDisable = false }
                });

            })
            .catch(error => {
                //console.log(error);
                this.error = error;
            });

    }

    get options() {
        return this.optionValue;
    }

    //  @track records;
    handleChange(event) {

        //  this.value = event.detail.value;

        var foundelement = this.casesList.find(ele => ele.Id == event.target.dataset.id);
        console.log('foundelement: ', JSON.stringify(foundelement));
        if (foundelement.Status != 'Closed') {
            //  console.log('In FoundElement');
            foundelement.Status = event.target.value;
        }

        //  console.log('This foundelement : '+ JSON.stringify(foundelement));
        //  console.log('This casesList : '+ JSON.stringify(this.casesList));

    }


    // End Release
    @track accountName;
    @track serviceName;
    getCustomerInfo(accId) {
        getAccountService({ accountId: accId })
            .then(data => {
                this.AccountInformation = data[0];
                this.accountName = this.AccountInformation.Account__r.Name;
                this.serviceName = this.AccountInformation.ODS_Service_Name__c;
                this.SRFValue = this.AccountInformation.Status_Report_Frequency__c;
                this.ProjectStatusValue = this.AccountInformation.Project_Status_LV__c;
                this.ScopeofWorkValue = this.AccountInformation.Scope_of_Work_LV__c;
                this.ScheduleValue = this.AccountInformation.Schedule_LV__c;
                this.BudgetValue = this.AccountInformation.Budget_LV__c;
                this.allowTimesheetBoolean = this.AccountInformation.Allow_Future_Timesheets__c;
            })
            .catch(error => {
                // console.log(error);
                this.error = error;
            });
    }
    @track OrgId;
    @track salesforceProduct;

    getIncidents(accId) {
        getAccountIncidents({ accountId: accId })
            .then(data => {
                this.incidents = data;
            })
            .catch(error => {
                // console.log(error);
                this.error = error;
            });
    }

    getSalesforceAFInfo(accId) {
        getSalesforceAFDetails({ accountID: accId })
            .then(data => {
                this.salesforceAF = data[0];
            })
            .catch(error => {
                //console.log(error);
                this.error = error;
            });
    }

    handleSubmit(event) {
        this.template.querySelector('.spinnerDiv').style.display = "block";
        var orgId = this.template.querySelector('.orgID').value;
        var salesforceProduct = this.template.querySelector('.salesforceProduct').value;
        var appexchangeApps = this.template.querySelector('.appexchangeApps').value;
        var CustomerProtalAccess = this.template.querySelector('.CustomerProtalAccess').value;
        var customerService = this.template.querySelector('.customerService').value;
        var customerPortalAccessStatusDate = this.template.querySelector('.customerPortalAccessStatusDate').value;
        var CPQProduct = this.template.querySelector('.CPQProduct').value;
        var SetupWeeklyMonthlyMeeting = this.template.querySelector('.SetupWeeklyMonthlyMeeting').value;
        var Marketing = this.template.querySelector('.Marketing').value;
        var setupWeeklyMonthlyMeetingDate = this.template.querySelector('.setupWeeklyMonthlyMeetingDate').value;
        var Middleware = this.template.querySelector('.Middleware').value;
        var EnvironmentAccess = this.template.querySelector('.EnvironmentAccess').value;
        var ERP = this.template.querySelector('.ERP').value;
        var EnvironmentAccessStatusDate = this.template.querySelector('.EnvironmentAccessStatusDate').value;
        var DocumentGenration = this.template.querySelector('.DocumentGenration').value;
        var OnboardingDocument = this.template.querySelector('.OnboardingDocument').value;
        var ExternalStorage = this.template.querySelector('.ExternalStorage').value;
        var OnboardingDocumentStatusDate = this.template.querySelector('.OnboardingDocumentStatusDate').value;
        var DigitalSignature = this.template.querySelector('.DigitalSignature').value;
        var LightningReadinessCheck = this.template.querySelector('.LightningReadinessCheck').value;
        var Analytics = this.template.querySelector('.Analytics').value;
        var Backup = this.template.querySelector('.Backup').value;
        var InstanceName = this.template.querySelector('.InstanceName').value;
        var ProjectManagement = this.template.querySelector('.ProjectManagement').value;
        var MarketingCloudInstanceName = this.template.querySelector('.MarketingCloudInstanceName').value;
        var DevelopmentTools = this.template.querySelector('.DevelopmentTools').value;
        var hasCommunities = this.template.querySelector('.hasCommunities').checked;
        var CustomerEnagementScore = this.template.querySelector('.CustomerEnagementScore').value;
        var BusinessOverview = this.template.querySelector('.BusinessOverview').value;
        var ProductServicesOffered = this.template.querySelector('.ProductServicesOffered').value;
        var Customers = this.template.querySelector('.Customers').value;
        var KeyCompetitors = this.template.querySelector('.KeyCompetitors').value;
        var CollaboratorsPartners = this.template.querySelector('.CollaboratorsPartners').value;
        var ComplianceRequirements = this.template.querySelector('.ComplianceRequirements').value;
        var SalesforceRoadMap = this.template.querySelector('.SalesforceRoadMap').value;
        var ProductBacklog = this.template.querySelector('.ProductBacklog').value;
        var CurrentPainpoints = this.template.querySelector('.CurrentPainpoints').value;
        var kickOffStatus = this.template.querySelector('.kickOffStatus').value;
        var kickOffCompletedDate = this.template.querySelector('.kickOffCompletedDate').value;
        const selectedDate = new Date(kickOffCompletedDate);
        const currentDate = new Date();
        var stopSave = false;
        if (selectedDate > currentDate) {
            alert('The selected Kickoff Completed Date cannot be in the future.');
            stopSave = true;
            this.template.querySelector('.spinnerDiv').style.display = "none";
        }
        if (kickOffStatus === 'Completed' && !kickOffCompletedDate) {
            alert('Please select the Kickoff Completed Date.');
            stopSave = true;
            this.template.querySelector('.spinnerDiv').style.display = "none";
        }
        if (!stopSave) {
            var accountList = [];
            accountList.push({
                orgId: orgId,
                salesforceProduct: salesforceProduct,
                appexchangeApps: appexchangeApps,
                CustomerProtalAccess: CustomerProtalAccess,
                customerService: customerService,
                customerPortalAccessStatusDate: customerPortalAccessStatusDate,
                CPQProduct: CPQProduct,
                SetupWeeklyMonthlyMeeting: SetupWeeklyMonthlyMeeting,
                Marketing: Marketing,
                setupWeeklyMonthlyMeetingDate: setupWeeklyMonthlyMeetingDate,
                Middleware: Middleware,
                EnvironmentAccess: EnvironmentAccess,
                ERP: ERP,
                EnvironmentAccessStatusDate: EnvironmentAccessStatusDate,
                DocumentGenration: DocumentGenration,
                OnboardingDocument: OnboardingDocument,
                ExternalStorage: ExternalStorage,
                OnboardingDocumentStatusDate: OnboardingDocumentStatusDate,
                DigitalSignature: DigitalSignature,
                LightningReadinessCheck: LightningReadinessCheck,
                Analytics: Analytics,
                Backup: Backup,
                InstanceName: InstanceName,
                ProjectManagement: ProjectManagement,
                MarketingCloudInstanceName: MarketingCloudInstanceName,
                DevelopmentTools: DevelopmentTools,
                hasCommunities: hasCommunities,
                CustomerEnagementScore: CustomerEnagementScore,
                BusinessOverview: BusinessOverview,
                ProductServicesOffered: ProductServicesOffered,
                Customers: Customers,
                CollaboratorsPartners: CollaboratorsPartners,
                ComplianceRequirements: ComplianceRequirements,
                KeyCompetitors: KeyCompetitors,
                SalesforceRoadMap: SalesforceRoadMap,
                ProductBacklog: ProductBacklog,
                CurrentPainpoints: CurrentPainpoints,
                kickOffCompletedDate: kickOffCompletedDate,
                kickOffStatus: kickOffStatus

            });
            console.log('accountList--' + JSON.stringify(accountList));

            updateCustomerInfo({ draftResponse: JSON.stringify(accountList), accountId: this.accId, picklistValue: this.SRFValue, proStatuspicklistValue: this.ProjectStatusValue, sWpicklistValue: this.ScopeofWorkValue, schedulepicklistValue: this.ScheduleValue, budgetpicklistValue: this.BudgetValue, allowTimesheet: this.allowTimesheetBoolean })
                .then(result => {
                    this.template.querySelector('.spinnerDiv').style.display = "none";
                    this.getCurrentAccountDetail();
                })
                .catch(error => {   
                    this.template.querySelector('.spinnerDiv').style.display = "none";
                    if (error.body.message) {
                        alert(error.body.message);
                    }
                });


            updateCases({ data: this.casesList })
                .then(result => {
                    this.casesList = [];
                    this.getReleaseCases(this.accId, this.srvcId);

                })
                .catch(error => {
                    //console.log(error);
                    this.error = error;
                });
        }
    }


    handleReset(event) {
        this.template.querySelector('.spinnerDiv').style.display = "block";
        this.currentAccount = [];
        this.casesList = [];

        this.getCurrentAccountDetail();
        this.getCustomerInfo(this.accId);
        this.getReleaseCases(this.accId, this.srvcId);
        this.template.querySelector('.spinnerDiv').style.display = "none";

    }
    showPopUp(event) {
        this.currentSubject = '';
        this.currentHtmlBody = '';
        getEmail({ emailId: event.target.dataset.item })
            .then(data => {
                this.currentSubject = data.Subject;
                this.currentHtmlBody = data.HtmlBody;
                this.template.querySelector('.custPopup').style.display = "block";

            })
            .catch(error => {
                console.log(error);
                this.error = error;
            });
    }
    closePopUp() {
        this.template.querySelector('.custPopup').style.display = "none";

    }
    handleSPFChange(event) {
        this.SRFValue = event.detail.value;
    }
     handleProjectStatusChange(event) {
        this.ProjectStatusValue = event.detail.value;
    }
    handleScopeofWorkChange(event) {
        this.ScopeofWorkValue = event.detail.value;
    }
    handleScheduleChange(event) {
        this.ScheduleValue = event.detail.value;
    }
    handleBudgetChange(event) {
        this.BudgetValue = event.detail.value;
    }
    /* handleCESChange(event) {
         this.CESValue = event.detail.value;
     }*/
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
    renderedCallback() {

        Promise.all([
            loadStyle(this, CustomerInfoCSS)

        ])
    }
    handleAllowTimesheet(event) {
        this.allowTimesheetBoolean = event.target.checked;
    }
    HandleShowSalesforceAF() {
        this.template.querySelector('.spinnerDiv').style.display = "none";
        this.template.querySelector('.hideDIVBOX').style.display = "block";
        this.template.querySelector('.dashIconDiv').style.display = "none";
        this.template.querySelector('.hideCloseIconDiv').style.display = "block";

    }
    HandleHideSalesforceAF() {
        this.template.querySelector('.spinnerDiv').style.display = "none";
        this.template.querySelector('.hideDIVBOX').style.display = "none";
        this.template.querySelector('.dashIconDiv').style.display = "block";
        this.template.querySelector('.hideCloseIconDiv').style.display = "none";

    }
    showModalBox() {
        this.isShowModal = true;
    }

    hideModalBox() {
        this.isShowModal = false;
    }
    handleKickoffCompleted() {
        this.template.querySelector('.spinnerDiv1').style.display = "block";

        var kickOffCompletedDate = this.template.querySelector('.kickOffCompletedDatePopUp').value;
        const selectedDate = new Date(kickOffCompletedDate);
        const currentDate = new Date();
        var stopSave = false;
        if (selectedDate > currentDate) {
            alert('The selected Kickoff Completed Date cannot be in the future.');
            stopSave = true;
            this.template.querySelector('.spinnerDiv1').style.display = "none";
        }
        if (!kickOffCompletedDate) {
            alert('Please select the Kickoff Completed Date.');
            stopSave = true;
            this.template.querySelector('.spinnerDiv1').style.display = "none";
        }
        if (stopSave == false) {
            updateKickoffStatus({ completedDate: kickOffCompletedDate, accountId: this.accId })
                .then(data => {
                    location.reload();
                })
                .catch(error => {
                    alert(error.message);
                    this.template.querySelector('.spinnerDiv1').style.display = "none";

                });
        }
    }
}
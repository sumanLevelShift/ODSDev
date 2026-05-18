import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

// Apex Methods
import initializeComponent from '@salesforce/apex/ODS_InitiativeControllerLWC.initializeComponent';
import getInitiativeDetails from '@salesforce/apex/ODS_InitiativeControllerLWC.getInitiativeDetails';
import saveInitiative from '@salesforce/apex/ODS_InitiativeControllerLWC.saveInitiative';
import approveInitiative from '@salesforce/apex/ODS_InitiativeControllerLWC.approveInitiative';
import rejectInitiative from '@salesforce/apex/ODS_InitiativeControllerLWC.rejectInitiative';
import cancelInitiative from '@salesforce/apex/ODS_InitiativeControllerLWC.cancelInitiative';
import changeInitiativeStatus from '@salesforce/apex/ODS_InitiativeControllerLWC.changeInitiativeStatus';
import escalateInitiative from '@salesforce/apex/ODS_InitiativeControllerLWC.escalateInitiative';
import cloneInitiative from '@salesforce/apex/ODS_InitiativeControllerLWC.cloneInitiative';
import recallInitiative from '@salesforce/apex/ODS_InitiativeControllerLWC.recallInitiative';
import resendInitiativeEmail from '@salesforce/apex/ODS_InitiativeControllerLWC.resendInitiativeEmail';
import deleteAttachment from '@salesforce/apex/ODS_InitiativeControllerLWC.deleteAttachment';
import getUtilizationMetrics from '@salesforce/apex/ODS_InitiativeControllerLWC.getUtilizationMetrics';
import getProductList from '@salesforce/apex/ODS_InitiativeControllerLWC.getProductList';

// Labels
import Estimated_Hr_Threshold from '@salesforce/label/c.Estimated_Hr_Threshold';
import Content_Entry from '@salesforce/label/c.Content_Entry';

export default class InitiativeLWC extends NavigationMixin(LightningElement) {
    @api recordId; // Initiative Id from record page
    @api accServiceId; // Account Service Id from URL parameter
    
    // Track properties
    @track isLoading = true;
    @track errorMessage = '';
    @track successMessage = '';
    @track initiative = {};
    @track estimates = [];
    @track attachments = [];
    @track escalations = [];
    @track approverOptions = [];
    @track selectedApprover = '';
    @track selectedTags = [];
    @track activeSections = ['initiative', 'businessImpact', 'estimate'];
    
    // Picklist options
    @track initiativeTypeOptions = [];
    @track initiativeBillingTypeOptions = [];
    @track triggerForInitiativeOptions = [];
    @track architectEngineerOptions = [];
    @track technicalPMOptions = [];
    @track initiativeTagOptions = [];
    @track phaseOptions = [];
    
    // User and context info
    @track currentUser = {};
    @track accountName = '';
    @track serviceName = '';
    @track accountId = '';
    @track serviceId = '';
    @track isCustomer = false;
    @track isDeliveryTeam = false;
    @track isPortalApprover = false;
    @track isInitiativeApprover = false;
    @track nonABCType = false;
    @track showSaveCreateJira = false;
    
    // Status and visibility
    @track currentStatus = '';
    @track inactiveApproverWarning = false;
    @track inactiveApproverName = '';
    
    // Progress metrics
    @track utilizationPercent = 0;
    @track consumedHours = 0;
    @track remainingPercent = 0;
    @track remainingHours = 0;
    @track burndownData = {};
    
    // Modals
    @track showApproveRejectModal = false;
    @track showEscalationModal = false;
    @track showProductModal = false;
    @track modalTitle = '';
    @track modalComments = '';
    @track escalationComments = '';
    @track isRejectAction = false;
    @track modalActionLabel = '';
    @track modalActionVariant = 'brand';
    
    // Product selection
    @track productMap1 = [];
    @track productMap2 = [];
    @track productMap3 = [];
    @track selectedProducts = new Set();
    @track allProductsExpanded = false;
    
    // Attachment columns
    attachmentColumns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { 
            label: 'Created Date', 
            fieldName: 'CreatedDate', 
            type: 'date',
            typeAttributes: {
                year: 'numeric',
                month: '2-digit',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit'
            }
        },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'Download', name: 'download' },
                    { label: 'Delete', name: 'delete' }
                ]
            }
        }
    ];
    
    // Escalation columns
    escalationColumns = [
        { 
            label: 'Escalated Date', 
            fieldName: 'EscalationDateTime__c', 
            type: 'date',
            typeAttributes: {
                year: 'numeric',
                month: '2-digit',
                day: '2-digit'
            }
        },
        { label: 'Escalation Content', fieldName: 'EscalationDetails__c', type: 'text' },
        { label: 'Email Recipients', fieldName: 'InitiativeEscalationRecipients__c', type: 'text' }
    ];
    
    // Computed properties for status
    get statusLabel() {
        if (!this.currentStatus) return 'New';
        if (this.currentStatus === 'Initiative Submitted') return 'Initiative Submitted';
        if (this.currentStatus === 'Re-evaluate') return 'Re-evaluate Estimates';
        if (this.currentStatus === 'Estimation Rejected') return 'Re-evaluate Estimates';
        return this.currentStatus;
    }
    
    get statusBadgeClass() {
        const status = this.currentStatus;
        if (!status || status === 'Saved') return 'slds-badge';
        if (status === 'Initiative Submitted') return 'slds-badge slds-theme_warning';
        if (status === 'Initiative Approved') return 'slds-badge slds-theme_success';
        if (status === 'Active Initiative') return 'slds-badge slds-theme_success';
        if (status === 'Initiative Delivered') return 'slds-badge slds-theme_info';
        if (status === 'Re-evaluate' || status === 'Estimation Rejected') return 'slds-badge slds-theme_error';
        if (status === 'Initiative Cancelled') return 'slds-badge slds-theme_error';
        if (status === 'On Hold') return 'slds-badge slds-theme_warning';
        return 'slds-badge';
    }
    
    // Computed properties for button visibility
    get showSaveButton() {
        return !this.currentStatus || this.currentStatus === 'Saved' || 
               this.currentStatus === 'Re-evaluate' || this.currentStatus === 'Initiative Recalled';
    }
    
    get showSavePostSubmitButton() {
        if (this.currentStatus === 'Initiative Approved' || this.currentStatus === 'Active Initiative') {
            return true;
        }
        if ((this.currentStatus === 'Initiative Recalled' || this.currentStatus === 'Re-evaluate' || 
             this.currentStatus === 'Initiative Submitted') && this.isCustomer) {
            return true;
        }
        return false;
    }
    
    get showSubmitButton() {
        if (this.isDeliveryTeam) return false;
        return !this.currentStatus || this.currentStatus === 'Saved' || 
               this.currentStatus === 'Re-evaluate' || this.currentStatus === 'Initiative Recalled';
    }
    
    get showSaveCreateJiraButton() {
        return this.showSaveCreateJira && (!this.currentStatus || this.currentStatus === 'Saved');
    }
    
    get showResendButton() {
        const isTAMorPH = this.currentUser.PortalUserRole__c === 'Technical Account Manager' || 
                         this.currentUser.PortalUserRole__c === 'Practice Head';
        return this.currentStatus === 'Initiative Submitted' && isTAMorPH;
    }
    
    get showRecallButton() {
        const isTAMorPH = this.currentUser.PortalUserRole__c === 'Technical Account Manager' || 
                         this.currentUser.PortalUserRole__c === 'Practice Head';
        return this.currentStatus === 'Initiative Submitted' && isTAMorPH;
    }
    
    get showApproveButton() {
        if (this.currentStatus === 'Initiative Submitted' && this.isInitiativeApprover && this.isCustomer) {
            return true;
        }
        const isTAMorPH = this.currentUser.PortalUserRole__c === 'Technical Account Manager' || 
                         this.currentUser.PortalUserRole__c === 'Practice Head';
        return this.currentStatus === 'Initiative Submitted' && isTAMorPH;
    }
    
    get showRejectButton() {
        return this.showApproveButton;
    }
    
    get showEscalateButton() {
        return this.currentStatus === 'Active Initiative' || 
               this.currentStatus === 'Initiative Approved' || 
               this.currentStatus === 'On Hold';
    }
    
    get showCancelButton() {
        return this.currentStatus && this.currentStatus !== 'Initiative Cancelled' && 
               this.currentStatus !== 'Initiative Delivered' && !this.isCustomer;
    }
    
    get showCloneButton() {
        const isTAMorPH = this.currentUser.PortalUserRole__c === 'Technical Account Manager' || 
                         this.currentUser.PortalUserRole__c === 'Practice Head';
        return this.currentStatus && isTAMorPH;
    }
    
    get showExportButton() {
        return this.currentStatus && this.currentStatus !== 'Initiative Cancelled';
    }
    
    get showActiveInitiativeActions() {
        return this.currentStatus === 'Active Initiative';
    }
    
    get showOnHoldActions() {
        return this.currentStatus === 'On Hold';
    }
    
    get showProgressPanel() {
        return this.currentStatus === 'Active Initiative' || 
               this.currentStatus === 'Initiative Delivered';
    }
    
    get showDocumentSection() {
        const isTAMorPH = this.currentUser.PortalUserRole__c === 'Technical Account Manager' || 
                         this.currentUser.PortalUserRole__c === 'Practice Head';
        return this.currentStatus && isTAMorPH;
    }
    
    get showAttachmentUpload() {
        return this.currentStatus === 'Re-evaluate' || 
               this.currentStatus === 'Saved' || 
               this.currentStatus === 'Initiative Recalled';
    }
    
    get showEscalationPanel() {
        return this.currentStatus === 'Active Initiative' || 
               this.currentStatus === 'Initiative Approved' || 
               this.currentStatus === 'On Hold';
    }
    
    get hasAttachments() {
        return this.attachments && this.attachments.length > 0;
    }
    
    get hasEscalations() {
        return this.escalations && this.escalations.length > 0;
    }
    
    get hasEstimationSummary() {
        return this.initiative.estimationSummaryId;
    }
    
    get estimationSummaryUrl() {
        if (this.hasEstimationSummary) {
            return `/DetailsEstimationSummary?estimationId=${this.initiative.estimationSummaryId}&accountId=${this.accountId}&serviceId=${this.serviceId}`;
        }
        return '';
    }
    
    get totalEstimateHours() {
        let total = 0;
        this.estimates.forEach(est => {
            if (est.Hours__c) {
                total += parseFloat(est.Hours__c);
            }
        });
        return total.toFixed(2);
    }
    
    // Field disable logic
    get isFieldDisabled() {
        if (this.isCustomer) return true;
        if (!this.currentStatus || this.currentStatus === 'Saved' || 
            this.currentStatus === 'Re-evaluate' || this.currentStatus === 'Initiative Recalled') {
            return false;
        }
        return true;
    }
    
    get isDescriptionDisabled() {
        if (this.currentStatus === 'Initiative Rejected' || 
            this.currentStatus === 'Saved' || 
            this.currentStatus === 'Re-evaluate' || 
            this.currentStatus === 'Initiative Recalled' || 
            !this.currentStatus) {
            return false;
        }
        return true;
    }
    
    get isBusinessImpactDisabled() {
        if (!this.currentStatus || this.currentStatus === 'Saved' || 
            this.currentStatus === 'Initiative Submitted' || this.currentStatus === 'Re-evaluate' || 
            this.currentStatus === 'Initiative Recalled' || this.currentStatus === 'Initiative Approved' || 
            this.currentStatus === 'Active Initiative') {
            return false;
        }
        return true;
    }
    
    get isEstimateDisabled() {
        if (this.isCustomer) return true;
        if (!this.currentStatus || this.currentStatus === 'Saved' || 
            this.currentStatus === 'Re-evaluate' || this.currentStatus === 'Initiative Recalled') {
            return false;
        }
        return true;
    }
    
    get isProbabilityDisabled() {
        return this.currentStatus === 'Initiative Delivered' || 
               this.currentStatus === 'Initiative Approved' || 
               this.currentStatus === 'Initiative Cancelled';
    }
    
    get isOffshoreDisabled() {
        return this.currentStatus === 'Initiative Delivered';
    }
    
    get isBucketDisabled() {
        if (!this.currentStatus || this.currentStatus === 'Saved' || 
            this.currentStatus === 'Re-evaluate' || this.currentStatus === 'Initiative Recalled') {
            return false;
        }
        return true;
    }
    
    get isJiraRequired() {
        return !this.showSaveCreateJiraButton;
    }
    
    get initiativeId() {
        return this.recordId || this.initiative.Id;
    }
    
    // Lifecycle hooks
    connectedCallback() {
        this.loadInitiative();
    }
    
    // Load initiative data
    async loadInitiative() {
        this.isLoading = true;
        this.errorMessage = '';
        
        try {
            // Get URL parameters
            const urlParams = new URLSearchParams(window.location.search);
            const urlAccServiceId = urlParams.get('AccServiceId') || this.accServiceId;
            const urlInitiativeId = urlParams.get('CurrenInitiativeId') || this.recordId;
            
            // Initialize component
            const initResult = await initializeComponent({
                initiativeId: urlInitiativeId,
                accServiceId: urlAccServiceId
            });
            
            if (!initResult.success) {
                this.errorMessage = initResult.error || 'Failed to initialize component';
                return;
            }
            
            // Set context data
            this.currentUser = initResult.currentUser || {};
            this.accountName = initResult.accountName || '';
            this.serviceName = initResult.serviceName || '';
            this.accountId = initResult.accountId || '';
            this.serviceId = initResult.serviceId || '';
            this.isCustomer = initResult.isCustomer || false;
            this.isDeliveryTeam = initResult.isDeliveryTeam || false;
            this.isPortalApprover = initResult.isPortalApprover || false;
            this.isInitiativeApprover = initResult.isInitiativeApprover || false;
            this.nonABCType = initResult.nonABCType || false;
            this.showSaveCreateJira = initResult.showSaveCreateJira || false;
            
            // Set picklist options
            this.initiativeTypeOptions = this.formatPicklistOptions(initResult.initiativeTypeOptions);
            this.initiativeBillingTypeOptions = this.formatPicklistOptions(initResult.initiativeBillingTypeOptions);
            this.triggerForInitiativeOptions = this.formatPicklistOptions(initResult.triggerForInitiativeOptions);
            this.architectEngineerOptions = this.formatPicklistOptions(initResult.architectEngineerOptions);
            this.technicalPMOptions = this.formatPicklistOptions(initResult.technicalPMOptions);
            this.initiativeTagOptions = this.formatPicklistOptions(initResult.initiativeTagOptions);
            this.phaseOptions = this.formatPicklistOptions(initResult.phaseOptions);
            this.approverOptions = initResult.approvers || [];
            
            // Load initiative if exists
            if (urlInitiativeId) {
                const detailsResult = await getInitiativeDetails({
                    initiativeId: urlInitiativeId,
                    userRole: this.currentUser.PortalUserRole__c
                });
                
                this.initiative = detailsResult.initiative || {};
                this.currentStatus = detailsResult.status || '';
                this.estimates = detailsResult.estimates || [];
                this.attachments = detailsResult.attachments || [];
                this.escalations = detailsResult.escalations || [];
                
                // Set selected approver
                if (this.initiative.Client_side_Contact__r) {
                    this.selectedApprover = this.initiative.Client_side_Contact__r.Name;
                }
                
                // Set selected tags
                if (this.initiative.Tags_About_Initiative__c) {
                    this.selectedTags = this.initiative.Tags_About_Initiative__c.split(';');
                }
                
                // Set utilization metrics
                if (detailsResult.utilizationMetrics) {
                    this.utilizationPercent = detailsResult.utilizationMetrics.utilizationPercent || 0;
                    this.consumedHours = detailsResult.utilizationMetrics.totalConsumed || 0;
                    this.remainingPercent = detailsResult.utilizationMetrics.remainingPercent || 0;
                    this.remainingHours = detailsResult.utilizationMetrics.remainingHours || 0;
                }
                
                // Set burndown data
                this.burndownData = detailsResult.burndownData || {};
                
                // Add unique IDs to estimates for iteration
                this.estimates = this.estimates.map((est, index) => ({
                    ...est,
                    id: est.Id || `temp_${index}`
                }));
                
                // Check for inactive approver
                if (initResult.inactiveApprover) {
                    this.inactiveApproverWarning = true;
                    this.inactiveApproverName = initResult.inactiveApproverName || '';
                }
            } else {
                // Initialize new initiative
                this.initiative = {
                    Initiative_Billing_Type__c: 'Build',
                    Solution_Architect_Engineer__c: 'None',
                    Technical_Project_Manager__c: 'None',
                    Is_a_bucket_of_hours_type__c: false
                };
                this.currentStatus = '';
                this.addEmptyEstimate();
            }
            
        } catch (error) {
            console.error('Error loading initiative:', error);
            this.errorMessage = error.body?.message || error.message || 'An error occurred while loading the initiative';
        } finally {
            this.isLoading = false;
        }
    }
    
    // Format picklist options
    formatPicklistOptions(options) {
        if (!options) return [];
        return options.map(opt => ({
            label: opt.label,
            value: opt.value
        }));
    }
    
    // Field change handlers
    handleFieldChange(event) {
        const field = event.target.dataset.field;
        const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
        this.initiative = { ...this.initiative, [field]: value };
    }
    
    handleRichTextChange(event) {
        const field = event.target.dataset.field;
        this.initiative = { ...this.initiative, [field]: event.target.value };
    }
    
    handleApproverChange(event) {
        this.selectedApprover = event.detail.value;
    }
    
    handleTagsChange(event) {
        this.selectedTags = event.detail.value;
    }
    
    // Estimate table handlers
    handleEstimateChange(event) {
        const index = parseInt(event.target.dataset.index);
        const field = event.target.dataset.field;
        const value = event.target.value;
        
        const updatedEstimates = [...this.estimates];
        updatedEstimates[index] = { ...updatedEstimates[index], [field]: value };
        this.estimates = updatedEstimates;
    }
    
    handleAddEstimate() {
        this.addEmptyEstimate();
    }
    
    addEmptyEstimate() {
        const newEstimate = {
            id: `temp_${Date.now()}`,
            Phase__c: 'Analysis',
            Task_Components__c: '',
            Assumptions__c: '',
            Hours__c: null
        };
        this.estimates = [...this.estimates, newEstimate];
    }
    
    handleDeleteEstimate(event) {
        const index = parseInt(event.target.dataset.index);
        const updatedEstimates = this.estimates.filter((est, idx) => idx !== index);
        this.estimates = updatedEstimates;
    }
    
    // Validation
    validateInitiative(action) {
        // Initiative Name
        if (!this.initiative.Name || this.initiative.Name.trim().length < 2) {
            this.showToast('Error', 'Initiative Name is mandatory', 'error');
            return false;
        }
        
        if (this.initiative.Name.trim().length > 80) {
            this.showToast('Error', 'Initiative Name should not be greater than 80 characters', 'error');
            return false;
        }
        
        // JIRA ID (not required for SaveCreateJira)
        if (action !== 'SaveCreateJira' && (!this.initiative.JIRA_ID__c || this.initiative.JIRA_ID__c.trim().length === 0)) {
            this.showToast('Error', 'JIRA Id is mandatory', 'error');
            return false;
        }
        
        // Dates
        if (!this.initiative.Probable_Start_Date__c) {
            this.showToast('Error', 'Probable Start Date should not be empty', 'error');
            return false;
        }
        
        if (!this.initiative.Probable_End_Date__c) {
            this.showToast('Error', 'Probable End Date should not be empty', 'error');
            return false;
        }
        
        const startDate = new Date(this.initiative.Probable_Start_Date__c);
        const endDate = new Date(this.initiative.Probable_End_Date__c);
        
        if (startDate > endDate) {
            this.showToast('Error', 'Probable End date should be more than Probable Start date', 'error');
            return false;
        }
        
        // UAT Date validation
        if (this.initiative.UAT_Expected_Date__c) {
            const isTAMorPH = this.currentUser.PortalUserRole__c === 'Technical Account Manager' || 
                             this.currentUser.PortalUserRole__c === 'Practice Head';
            if (isTAMorPH) {
                const uatDate = new Date(this.initiative.UAT_Expected_Date__c);
                if (uatDate < startDate) {
                    this.showToast('Error', 'UAT Expected Date should be later than Probable Start date', 'error');
                    return false;
                }
            }
        }
        
        // Initiative Type
        if (!this.initiative.Initiative_Type__c || this.initiative.Initiative_Type__c === 'None') {
            this.showToast('Error', 'Initiative Type is Mandatory', 'error');
            return false;
        }
        
        // Programming Reason
        if (this.initiative.Initiative_Type__c === 'Programming' && 
            (!this.initiative.Initiative_Programming_Reason__c || this.initiative.Initiative_Programming_Reason__c.trim() === '')) {
            this.showToast('Error', "Specify the reason the Initiative can't be done in a declarative way", 'error');
            return false;
        }
        
        // Trigger
        if (!this.initiative.Trigger_For_Initiative__c || this.initiative.Trigger_For_Initiative__c === 'None') {
            this.showToast('Error', 'Trigger for Initiative is Mandatory', 'error');
            return false;
        }
        
        // Tags
        if (!this.selectedTags || this.selectedTags.length === 0) {
            this.showToast('Error', 'Tags about Initiative is Mandatory', 'error');
            return false;
        }
        
        // Estimates validation
        const totalHours = parseFloat(this.totalEstimateHours);
        
        if (action !== 'Saved' && action !== 'SaveCreateJira' && totalHours === 0) {
            this.showToast('Error', 'Estimates Should not be Empty', 'error');
            return false;
        }
        
        // Validate estimate rows
        for (let est of this.estimates) {
            if (!est.Task_Components__c || est.Task_Components__c.trim() === '') {
                this.showToast('Error', 'Task/Components should not be empty!!', 'error');
                return false;
            }
            if (!est.Hours__c || est.Hours__c <= 0) {
                this.showToast('Error', 'Hours should be greater than 0!!', 'error');
                return false;
            }
        }
        
        // Delivery Estimate validation for Submit
        if (action === 'Submitted') {
            if (!this.initiative.Offshore_Estimate__c || this.initiative.Offshore_Estimate__c === 0) {
                this.showToast('Error', 'Delivery estimate field should have the estimate provided by the delivery team.', 'error');
                return false;
            }
            
            // Technical Project Manager validation
            if (!this.initiative.Technical_Project_Manager__c || this.initiative.Technical_Project_Manager__c === 'None') {
                this.showToast('Error', 'Please assign a Technical Project Manager to this initiative.', 'error');
                return false;
            }
        }
        
        // Business Impact validation for Submit or btnSavePostSubmit
        if ((action === 'Submitted' || action === 'btnSavePostSubmit') && totalHours >= parseFloat(Estimated_Hr_Threshold)) {
            const contentLength = parseInt(Content_Entry);
            
            if (!this.initiative.Business_Challenge__c || this.initiative.Business_Challenge__c.trim().length < contentLength) {
                this.showToast('Error', `Business Challenge should not be empty and must be greater than ${contentLength} characters!!`, 'error');
                return false;
            }
            if (!this.initiative.Persona_s_Involved__c || this.initiative.Persona_s_Involved__c.trim().length < contentLength) {
                this.showToast('Error', `Personas Involved should not be empty and must be greater than ${contentLength} characters!!`, 'error');
                return false;
            }
            if (!this.initiative.Technology_Details__c || this.initiative.Technology_Details__c.trim().length < contentLength) {
                this.showToast('Error', `Technology Details should not be empty and must be greater than ${contentLength} characters!!`, 'error');
                return false;
            }
            if (!this.initiative.Outcome_of_our_solution__c || this.initiative.Outcome_of_our_solution__c.trim().length < contentLength) {
                this.showToast('Error', `Outcome Of Our Solution should not be empty and must be greater than ${contentLength} characters!!`, 'error');
                return false;
            }
        }
        
        // Approver validation
        if (!this.selectedApprover) {
            this.showToast('Error', 'Please select the approver!!', 'error');
            return false;
        }
        
        return true;
    }
    
    // Save handlers
    async handleSave() {
        await this.saveInitiativeData('Saved');
    }
    
    async handleSavePostSubmit() {
        await this.saveInitiativeData('btnSavePostSubmit');
    }
    
    async handleSubmit() {
        if (!confirm('Are you sure you want to submit the Initiative Page')) {
            return;
        }
        await this.saveInitiativeData('Submitted');
    }
    
    async handleSaveCreateJira() {
        await this.saveInitiativeData('SaveCreateJira');
    }
    
    async saveInitiativeData(action) {
        if (!this.validateInitiative(action)) {
            return;
        }
        
        this.isLoading = true;
        this.errorMessage = '';
        this.successMessage = '';
        
        try {
            // Prepare initiative data
            const initiativeData = {
                ...this.initiative,
                ClientContact: this.selectedApprover,
                Tags_About_Initiative__c: this.selectedTags.join(';')
            };
            
            // Prepare estimates data
            const estimatesData = this.estimates.map(est => ({
                Phase: est.Phase__c,
                TaskName: est.Task_Components__c,
                Assumption: est.Assumptions__c,
                Hours: est.Hours__c
            }));
            
            const result = await saveInitiative({
                initiativeData: JSON.stringify(initiativeData),
                estimatesData: JSON.stringify(estimatesData),
                action: action,
                accServiceId: this.accServiceId || this.accountService?.Id
            });
            
            if (result.success) {
                this.successMessage = result.message || 'Initiative saved successfully';
                this.showToast('Success', this.successMessage, 'success');
                
                // Reload data
                await this.loadInitiative();
                
                // Navigate to view initiative page after a delay
                setTimeout(() => {
                    this.navigateToViewInitiative();
                }, 2000);
            } else {
                this.errorMessage = result.error || 'Failed to save initiative';
                this.showToast('Error', this.errorMessage, 'error');
            }
            
        } catch (error) {
            console.error('Error saving initiative:', error);
            this.errorMessage = error.body?.message || error.message || 'An error occurred while saving';
            this.showToast('Error', this.errorMessage, 'error');
        } finally {
            this.isLoading = false;
        }
    }
    
    // Status change handlers
    async handleMarkOnHold() {
        await this.changeStatus('On Hold');
    }
    
    async handleMarkDelivered() {
        await this.changeStatus('Initiative Delivered');
    }
    
    async handleMakeActive() {
        await this.changeStatus('Active Initiative');
    }
    
    async changeStatus(newStatus) {
        this.isLoading = true;
        
        try {
            const result = await changeInitiativeStatus({
                initiativeId: this.initiativeId,
                newStatus: newStatus
            });
            
            if (result.success) {
                this.showToast('Success', result.message || 'Status updated successfully', 'success');
                await this.loadInitiative();
            } else {
                this.showToast('Error', result.error || 'Failed to update status', 'error');
            }
        } catch (error) {
            console.error('Error changing status:', error);
            this.showToast('Error', error.body?.message || error.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }
    
    // Approve/Reject handlers
    handleApproveClick() {
        this.modalTitle = 'Approve';
        this.modalActionLabel = 'Approve Initiative';
        this.modalActionVariant = 'success';
        this.isRejectAction = false;
        this.modalComments = '';
        this.showApproveRejectModal = true;
    }
    
    handleRejectClick() {
        this.modalTitle = 'Reject';
        this.modalActionLabel = 'Re-evaluate Estimates';
        this.modalActionVariant = 'destructive';
        this.isRejectAction = true;
        this.modalComments = '';
        this.showApproveRejectModal = true;
    }
    
    handleModalCommentsChange(event) {
        this.modalComments = event.target.value;
    }
    
    handleModalClose() {
        this.showApproveRejectModal = false;
        this.modalComments = '';
    }
    
    async handleModalAction() {
        if (this.isRejectAction && (!this.modalComments || this.modalComments.trim() === '')) {
            this.showToast('Error', 'Please enter comments', 'error');
            return;
        }
        
        this.isLoading = true;
        this.showApproveRejectModal = false;
        
        try {
            let result;
            if (this.isRejectAction) {
                result = await rejectInitiative({
                    initiativeId: this.initiativeId,
                    comments: this.modalComments
                });
            } else {
                result = await approveInitiative({
                    initiativeId: this.initiativeId,
                    comments: this.modalComments
                });
            }
            
            if (result.success) {
                this.showToast('Success', result.message, 'success');
                await this.loadInitiative();
            } else {
                this.showToast('Error', result.error, 'error');
            }
        } catch (error) {
            console.error('Error in modal action:', error);
            this.showToast('Error', error.body?.message || error.message, 'error');
        } finally {
            this.isLoading = false;
            this.modalComments = '';
        }
    }
    
    // Escalation handlers
    handleEscalateClick() {
        this.escalationComments = '';
        this.showEscalationModal = true;
    }
    
    handleEscalationCommentsChange(event) {
        this.escalationComments = event.target.value;
    }
    
    handleEscalationModalClose() {
        this.showEscalationModal = false;
        this.escalationComments = '';
    }
    
    async handleEscalationSubmit() {
        if (!this.escalationComments || this.escalationComments.trim() === '') {
            this.showToast('Error', 'Please enter escalation details', 'error');
            return;
        }
        
        this.isLoading = true;
        this.showEscalationModal = false;
        
        try {
            const result = await escalateInitiative({
                initiativeId: this.initiativeId,
                escalationDetails: this.escalationComments
            });
            
            if (result.success) {
                this.showToast('Success', result.message, 'success');
                await this.loadInitiative();
            } else {
                this.showToast('Error', result.error, 'error');
            }
        } catch (error) {
            console.error('Error escalating initiative:', error);
            this.showToast('Error', error.body?.message || error.message, 'error');
        } finally {
            this.isLoading = false;
            this.escalationComments = '';
        }
    }
    
    // Other action handlers
    async handleCancelInitiative() {
        if (!confirm('Are you sure you want to cancel this initiative?')) {
            return;
        }
        
        this.isLoading = true;
        
        try {
            const result = await cancelInitiative({
                initiativeId: this.initiativeId
            });
            
            if (result.success) {
                this.showToast('Success', result.message, 'success');
                await this.loadInitiative();
            } else {
                this.showToast('Error', result.error, 'error');
            }
        } catch (error) {
            console.error('Error cancelling initiative:', error);
            this.showToast('Error', error.body?.message || error.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }
    
    async handleClone() {
        if (!confirm('Are you sure you want to clone the Initiative Record and Estimates?')) {
            return;
        }
        
        this.isLoading = true;
        
        try {
            const result = await cloneInitiative({
                initiativeId: this.initiativeId
            });
            
            if (result.success) {
                this.showToast('Success', 'Initiative cloned successfully!!!', 'success');
                // Navigate to cloned initiative
                this.navigateToInitiative(result.initiativeId);
            } else {
                this.showToast('Error', result.error, 'error');
            }
        } catch (error) {
            console.error('Error cloning initiative:', error);
            this.showToast('Error', error.body?.message || error.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }
    
    async handleRecall() {
        this.isLoading = true;
        
        try {
            const result = await recallInitiative({
                initiativeId: this.initiativeId
            });
            
            if (result.success) {
                this.showToast('Success', 'Initiative has been recalled', 'success');
                await this.loadInitiative();
            } else {
                this.showToast('Error', result.error, 'error');
            }
        } catch (error) {
            console.error('Error recalling initiative:', error);
            this.showToast('Error', error.body?.message || error.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }
    
    async handleResend() {
        this.isLoading = true;
        
        try {
            const result = await resendInitiativeEmail({
                initiativeId: this.initiativeId
            });
            
            if (result.success) {
                this.showToast('Success', 'Initiative email resent successfully', 'success');
            } else {
                this.showToast('Error', result.error, 'error');
            }
        } catch (error) {
            console.error('Error resending email:', error);
            this.showToast('Error', error.body?.message || error.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }
    
    // Attachment handlers
    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        this.showToast('Success', `${uploadedFiles.length} file(s) uploaded successfully`, 'success');
        this.loadInitiative(); // Reload to show new attachments
    }
    
    async handleAttachmentAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        
        if (actionName === 'download') {
            this.downloadAttachment(row.Id);
        } else if (actionName === 'delete') {
            await this.deleteAttachmentRecord(row.Id);
        }
    }
    
    downloadAttachment(attachmentId) {
        const baseUrl = window.location.origin;
        window.open(`${baseUrl}/servlet/servlet.FileDownload?file=${attachmentId}`, '_blank');
    }
    
    async deleteAttachmentRecord(attachmentId) {
        if (!confirm('Are you sure you want to delete this file?')) {
            return;
        }
        
        this.isLoading = true;
        
        try {
            const result = await deleteAttachment({
                attachmentId: attachmentId
            });
            
            if (result.success) {
                this.showToast('Success', result.message, 'success');
                await this.loadInitiative();
            } else {
                this.showToast('Error', result.error, 'error');
            }
        } catch (error) {
            console.error('Error deleting attachment:', error);
            this.showToast('Error', error.body?.message || error.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }
    
    // Navigation
    handleBack() {
        this.navigateToViewInitiative();
    }
    
    navigateToViewInitiative() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'ViewInitiative'
            }
        });
    }
    
    navigateToInitiative(initiativeId) {
        const urlParams = `CurrenInitiativeId=${initiativeId}&AccServiceId=${this.accServiceId}`;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `/lightning/n/InitiativeLWC?${urlParams}`
            }
        });
    }
    
    handleExport() {
        // Navigate to Apex method that generates Excel
        const url = `/apex/InitiativePage?CurrenInitiativeId=${this.initiativeId}&AccServiceId=${this.accServiceId}&export=true`;
        window.open(url, '_blank');
    }
    
    async handleSelectProducts() {
        try {
            this.showProductModal = true;
            const currentProducts = this.initiative.Product__c || '';
            
            const result = await getProductList({ selectedProducts: currentProducts });
            
            if (result.success) {
                // Convert objects to arrays for iteration
                this.productMap1 = this.convertProductMapToArray(result.productMap1 || {});
                this.productMap2 = this.convertProductMapToArray(result.productMap2 || {});
                this.productMap3 = this.convertProductMapToArray(result.productMap3 || {});
                
                // Initialize selected products set
                this.selectedProducts = new Set();
                if (currentProducts) {
                    currentProducts.split(',').forEach(p => {
                        if (p.trim()) {
                            this.selectedProducts.add(p.trim());
                        }
                    });
                }
            } else {
                this.showToast('Error', 'Failed to load products: ' + (result.error || 'Unknown error'), 'error');
            }
        } catch (error) {
            this.showToast('Error', 'Error loading products: ' + error.body?.message || error.message, 'error');
            console.error('Error in handleSelectProducts:', error);
        }
    }
    
    handleProductCheckboxChange(event) {
        const productName = event.currentTarget.dataset.product || event.target.dataset.product;
        const isChecked = event.detail.checked;
        
        if (isChecked) {
            this.selectedProducts.add(productName);
        } else {
            this.selectedProducts.delete(productName);
        }
        
        // Update the checkbox state in the product maps
        this.updateProductCheckboxState(productName, isChecked);
    }
    
    convertProductMapToArray(productMap) {
        const result = [];
        for (let key in productMap) {
            if (productMap.hasOwnProperty(key)) {
                result.push({
                    key: key,
                    value: productMap[key]
                });
            }
        }
        return result;
    }
    
    updateProductCheckboxState(productName, isChecked) {
        // Update in all three maps
        [this.productMap1, this.productMap2, this.productMap3].forEach(mapArray => {
            mapArray.forEach(group => {
                if (group.value) {
                    group.value.forEach(product => {
                        if (product.pname === productName) {
                            product.ischecked = isChecked;
                        }
                    });
                }
            });
        });
    }
    
    handleProductModalClose() {
        this.showProductModal = false;
        this.allProductsExpanded = false;
    }
    
    handleProductSelect() {
        // Convert selected products set to comma-separated string
        const productArray = Array.from(this.selectedProducts);
        this.initiative.Product__c = productArray.join(', ');
        this.showProductModal = false;
        this.allProductsExpanded = false;
        this.showToast('Success', 'Products selected successfully', 'success');
    }
    
    handleExpandAllProducts(event) {
        event.preventDefault();
        this.allProductsExpanded = !this.allProductsExpanded;
        // Toggle all accordion sections in product modal
        const productModal = this.template.querySelector('.slds-modal_large');
        if (productModal) {
            const accordions = productModal.querySelectorAll('lightning-accordion-section');
            accordions.forEach(accordion => {
                if (this.allProductsExpanded) {
                    accordion.expand();
                } else {
                    accordion.collapse();
                }
            });
        }
    }
    
    // Utility methods
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}
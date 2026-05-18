/**
 * View Initiative LWC Component
 * 
 * Migration from ViewInitiative.page Visualforce page to Lightning Web Component
 * 
 * Key Features:
 * - Displays all initiatives by default on page load (requirement #4)
 * - Advanced search with text and status filtering
 * - Account/Service selection for non-customers
 * - Action icons: View (always), Approve/Reject (for Submitted), Delete (for Recalled/Cancelled)
 * - Yellow highlight for "Initiative Submitted" status (customers only)
 * - Pagination with configurable page size
 * - Modal for Approve/Reject with comments
 * 
 * Design matches the provided image and original VF page exactly
 */

import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

// Apex Methods - Using ODS_ViewIntiativeControllerLWC wrapper methods
// All methods are @AuraEnabled and follow best practices (bulkification, exception handling, security)
import getInitiatives from '@salesforce/apex/ODS_ViewIntiativeControllerLWC.getInitiatives';
import getAccountOptions from '@salesforce/apex/ODS_ViewIntiativeControllerLWC.getAccountOptions';
import getServiceOptions from '@salesforce/apex/ODS_ViewIntiativeControllerLWC.getServiceOptions';
import getStatusOptions from '@salesforce/apex/ODS_ViewIntiativeControllerLWC.getStatusOptions';
import deleteInitiative from '@salesforce/apex/ODS_ViewIntiativeControllerLWC.deleteInitiative';
import approveInitiative from '@salesforce/apex/ODS_ViewIntiativeControllerLWC.approveInitiative';
import rejectInitiative from '@salesforce/apex/ODS_ViewIntiativeControllerLWC.rejectInitiative';
import getUserContext from '@salesforce/apex/ODS_ViewIntiativeControllerLWC.getUserContext';
import canDeleteInitiative from '@salesforce/apex/ODS_ViewIntiativeControllerLWC.canDeleteInitiative';
import canApproveRejectInitiative from '@salesforce/apex/ODS_ViewIntiativeControllerLWC.canApproveRejectInitiative';
import getAccountServiceIdForAdd from '@salesforce/apex/ODS_ViewIntiativeControllerLWC.getAccountServiceIdForAdd';
import getInitiativeDetailsForView from '@salesforce/apex/ODS_ViewIntiativeControllerLWC.getInitiativeDetailsForView';

export default class ViewInitiativeLWC extends NavigationMixin(LightningElement) {
    // User context
    @track isCustomer = false;
    @track portalUserRole = '';
    @track isInitiativeApprover = false;

    // Search and filter properties
    @track searchText = '';
    @track selectedStatus = 'All';
    @track selectedAccountId = 'All';
    @track selectedServiceId = 'All';
    @track showAdvancedSearch = true; // Show advanced search by default to match image

    // Data properties
    @track initiatives = [];
    @track totalRecords = 0;
    @track isLoading = false;
    @track showNoRecords = false;
    @track currentPage = 0;
    @track pageSize = 25;
    @track currentPageInfo = '';

    // UI control properties
    @track showAddInitiative = false;
    @track showDisclaimer = false;
    @track accountServiceID = '';

    // Modal properties
    @track showModal = false;
    @track selectedInitiativeId = '';
    @track modalAction = ''; // 'Approve' or 'Reject'
    @track modalComments = '';

    // Options for dropdowns
    @track accountOptions = [];
    @track serviceOptions = [];
    @track statusOptions = [];

    // Wire user data
    @wire(getUserContext)
    wiredUserContext({ error, data }) {
        if (data) {
            // Handle null/undefined values gracefully
            this.portalUserRole = data.portalUserRole || '';
            this.isCustomer = data.isCustomer || false;
            this.isInitiativeApprover = data.isInitiativeApprover || false;
            this.initializeComponent();
        } else if (error) {
            // Handle error gracefully - use default values and continue
            console.error('Error loading user context:', error);
            this.portalUserRole = '';
            this.isCustomer = false;
            this.isInitiativeApprover = false;
            // Still initialize component with default values
            this.initializeComponent();
            // Show error toast only if error body exists
            if (error && error.body && error.body.message) {
                this.showErrorToast('Error loading user data: ' + error.body.message);
            } else {
                this.showErrorToast('Error loading user data. Using default settings.');
            }
        }
    }

    // Computed properties
    get searchIconName() {
        return this.showAdvancedSearch ? 'utility:chevronup' : 'utility:chevrondown';
    }

    get advancedSearchClass() {
        return this.showAdvancedSearch ? 'slds-card__body slds-card__body_inner' : 'slds-hide';
    }

    get isSearchValid() {
        return this.searchText.length === 0 || this.searchText.length >= 3;
    }

    get modalTitle() {
        return this.modalAction === 'Approve' ? 'Approve Initiative' : 'Reject Initiative';
    }
    
    get modalButtonLabel() {
        return this.modalAction === 'Approve' ? 'Approve Initiative' : 'Re-evaluate';
    }

    get isAddButtonDisabled() {
        return !this.showAddInitiative;
    }

    get startRecord() {
        return this.currentPage * this.pageSize + 1;
    }
    
    get endRecord() {
        return Math.min((this.currentPage + 1) * this.pageSize, this.totalRecords);
    }
    
    get paginatedInitiatives() {
        const start = this.currentPage * this.pageSize;
        const end = start + this.pageSize;
        return this.initiatives.slice(start, end);
    }
    
    get totalPages() {
        return Math.ceil(this.totalRecords / this.pageSize);
    }
    
    get isFirstPage() {
        return this.currentPage === 0;
    }
    
    get isLastPage() {
        return this.currentPage >= this.totalPages - 1;
    }
    
    get pageNumbers() {
        const pages = [];
        const maxPagesToShow = 5;
        let startPage = Math.max(0, this.currentPage - Math.floor(maxPagesToShow / 2));
        let endPage = Math.min(this.totalPages, startPage + maxPagesToShow);
        
        if (endPage - startPage < maxPagesToShow) {
            startPage = Math.max(0, endPage - maxPagesToShow);
        }
        
        for (let i = startPage; i < endPage; i++) {
            pages.push({
                number: i + 1,
                variant: i === this.currentPage ? 'brand' : 'neutral',
                pageIndex: i
            });
        }
        
        return pages;
    }

    // Lifecycle methods
    connectedCallback() {
        this.currentPage = 0;
        this.pageSize = 25;
        // Load options first, then initialize component will be called from wiredUserContext
        this.loadOptions();
    }

    async initializeComponent() {
        try {
            // Match VF constructor initialization exactly
            // On page load, display all records by default (requirement #4)
            this.selectedStatus = 'All';
            this.selectedAccountId = 'All';
            this.selectedServiceId = 'All';
            this.currentPage = 0;
            this.pageSize = 25;
            this.showAddInitiative = false;
            this.searchText = ''; // Clear search text on init
            
            if (this.isCustomer) {
                this.showDisclaimer = false;
                this.showAddInitiative = false;
            } else {
                this.showDisclaimer = true;
            }
            
            // Check for URL parameters (matching VF page behavior)
            const urlParams = new URLSearchParams(window.location.search);
            const accntId = urlParams.get('accntId');
            const srvcId = urlParams.get('srvcId');
            const timesheetStatus = urlParams.get('TimesheetStatus');
            
            if (timesheetStatus) {
                this.selectedStatus = 'Initiative Submitted';
            }
            
            if (accntId && accntId !== 'All') {
                this.selectedAccountId = accntId;
                try {
                    const services = await getServiceOptions({ accountId: accntId });
                    if (services && Array.isArray(services)) {
                        this.serviceOptions = services.map(opt => ({
                            label: opt.label || '',
                            value: opt.value || ''
                        }));
                    }
                } catch (error) {
                    console.error('Error loading services:', error);
                }
            }
            
            if (srvcId && srvcId !== 'All') {
                this.selectedServiceId = srvcId;
            }
            
            // Update UI controls based on selections
            this.updateUIControls();
            
            // Load all records by default on page load (requirement #4)
            // This will load all initiatives when account/service are "All"
            // Match VF page: ApplySearchAction(AccountID,ServiceID) on page load
            await this.loadInitiatives();
        } catch (error) {
            console.error('Error in initializeComponent:', error);
            this.showErrorToast('Error initializing component. Please refresh the page.');
        }
    }

    /**
     * Load dropdown options (Account, Service, Status)
     * Migration Note: Replaces VF page's dropdown initialization
     */
    async loadOptions() {
        try {
            this.isLoading = true;
            
            // Load all options in parallel with error handling
            const [accounts, services, statuses] = await Promise.all([
                getAccountOptions().catch(err => {
                    console.error('Error loading accounts:', err);
                    return [];
                }),
                getServiceOptions({ accountId: this.selectedAccountId || 'All' }).catch(err => {
                    console.error('Error loading services:', err);
                    return [{ label: 'All Services', value: 'All' }];
                }),
                getStatusOptions().catch(err => {
                    console.error('Error loading statuses:', err);
                    return [{ label: 'All', value: 'All' }];
                })
            ]);

            // Map options with null checks
            this.accountOptions = (accounts && Array.isArray(accounts)) 
                ? accounts.map(opt => ({
                    label: opt.label || '',
                    value: opt.value || ''
                }))
                : [];
                
            this.serviceOptions = (services && Array.isArray(services))
                ? services.map(opt => ({
                    label: opt.label || '',
                    value: opt.value || ''
                }))
                : [{ label: 'All Services', value: 'All' }];
                
            this.statusOptions = (statuses && Array.isArray(statuses))
                ? statuses.map(opt => ({
                    label: opt.label || '',
                    value: opt.value || ''
                }))
                : [{ label: 'All', value: 'All' }];

        } catch (error) {
            console.error('Error in loadOptions:', error);
            // Set default options on error
            this.accountOptions = [];
            this.serviceOptions = [{ label: 'All Services', value: 'All' }];
            this.statusOptions = [{ label: 'All', value: 'All' }];
            this.showErrorToast('Error loading options: ' + (error.message || 'Unknown error'));
        } finally {
            this.isLoading = false;
        }
    }

    /**
     * Load initiatives from Apex controller with filter criteria
     * Migration Note: Replaces VF page's GetTimesheet() method
     * Handles all filter combinations: Account, Service, Status, and Search Text
     */
    async loadInitiatives() {
        try {
            this.isLoading = true;
            
            // Prepare filter parameters - ensure proper values are passed
            const params = {
                accountId: this.selectedAccountId || 'All',
                serviceId: this.selectedServiceId || 'All',
                status: this.selectedStatus || 'All',
                searchText: this.searchText || ''
            };
            
            console.log('Loading initiatives with filters:', params);

            const result = await getInitiatives(params);
            
            console.log('Initiatives loaded:', result);
            
            if (!result || !result.initiativesList) {
                this.initiatives = [];
                this.totalRecords = 0;
                this.showNoRecords = true;
                return;
            }
            
            // Transform data for display and check permissions
            this.initiatives = await Promise.all(
                result.initiativesList.map(async (initiative) => {
                    const accountService = `${initiative.Account_Service__r?.ODS_Account_Name__c || ''} - ${initiative.Account_Service__r?.ODS_Service_Name__c || ''}`;
                    const consumedHours = initiative.Submitted_Hours__c != null && initiative.Submitted_Hours__c != 0 
                        ? initiative.Submitted_Hours__c 
                        : 0;
                    
                    // Check permissions for each initiative based on status and role
                    // Matching VF page logic exactly
                    let canDelete = false;
                    let canApproveReject = false;
                    
                    try {
                        // Delete permission: Based on VF page logic
                        // Cannot delete if: Customer, Partner, or status in restricted list
                        // Can delete for: Initiative Recalled, Initiative Cancelled, and other non-restricted statuses
                        canDelete = await canDeleteInitiative({ initiativeId: initiative.Id });
                        
                        // Approve/Reject permission: Only for "Initiative Submitted" status
                        // And user must be approver (Customer approver, TAM, or Practice Head)
                        canApproveReject = await canApproveRejectInitiative({ initiativeId: initiative.Id });
                    } catch (error) {
                        console.error('Error checking permissions:', error);
                    }
                    
                    // Yellow highlight for "Initiative Submitted" status (customers only)
                    // Matching VF page: styleClass="{!IF(AND(initiative.Status__c == 'Initiative Submitted', isCustomer),'cust-init-sub', '')}"
                    const isSubmittedHighlight = this.isCustomer && initiative.Status__c == 'Initiative Submitted';
                    
                    return {
                        ...initiative,
                        accountService: accountService,
                        consumedHours: consumedHours.toFixed(2),
                        isSubmittedHighlight: isSubmittedHighlight,
                        rowClass: isSubmittedHighlight ? 'cust-init-sub' : '',
                        canDelete: canDelete,
                        canApproveReject: canApproveReject,
                        // Status-based icon visibility (matching image exactly)
                        showApproveReject: canApproveReject && initiative.Status__c == 'Initiative Submitted',
                        showDelete: canDelete && initiative.Status__c != 'Initiative Submitted'
                    };
                })
            );

            this.totalRecords = this.initiatives.length;
            this.showNoRecords = this.totalRecords === 0;
            this.accountServiceID = result.accountServiceID || '';
            this.isCustomer = result.isCustomer;
            this.portalUserRole = result.portalUserRole;
            this.isInitiativeApprover = result.isInitiativeApprover;
            
            // Update pagination
            this.updatePagination();

        } catch (error) {
            console.error('Error loading initiatives:', error);
            // Handle different error types
            let errorMessage = 'Error loading initiatives';
            if (error && error.body) {
                if (error.body.message) {
                    errorMessage += ': ' + error.body.message;
                } else if (typeof error.body === 'string') {
                    errorMessage += ': ' + error.body;
                }
            } else if (error && error.message) {
                errorMessage += ': ' + error.message;
            } else if (typeof error === 'string') {
                errorMessage += ': ' + error;
            } else {
                errorMessage += '. Please try again.';
            }
            this.showErrorToast(errorMessage);
            this.initiatives = [];
            this.totalRecords = 0;
            this.showNoRecords = true;
        } finally {
            this.isLoading = false;
        }
    }
    
    updatePagination() {
        this.currentPageInfo = `Showing ${this.startRecord} to ${this.endRecord} of ${this.totalRecords} entries`;
    }

    // Event handlers
    toggleAdvancedSearch() {
        this.showAdvancedSearch = !this.showAdvancedSearch;
        if (!this.showAdvancedSearch) {
            // Clear search when closing
            this.searchText = '';
            this.selectedStatus = 'All';
        }
    }
    
    handleSearchInput(event) {
        this.searchText = event.target.value || '';
        // Don't auto-search - wait for Search button click to match VF behavior
    }
    
    handleSearchKeyPress(event) {
        // Allow Enter key to trigger search
        if (event.key === 'Enter') {
            event.preventDefault();
            this.handleSearch();
        }
    }
    
    clearSearch() {
        this.searchText = '';
        // Clear search and reload all records
        this.currentPage = 0;
        this.loadInitiatives();
    }
    
    handleStatusChange(event) {
        // Handle native select element
        if (event.target && event.target.value) {
            this.selectedStatus = event.target.value;
        } else if (event.detail && event.detail.value) {
            this.selectedStatus = event.detail.value;
        }
        // Update selected option in dropdown (for visual feedback)
        const selectElement = this.template.querySelector('#statusSelect');
        if (selectElement) {
            selectElement.value = this.selectedStatus;
        }
    }

    /**
     * Handle Account dropdown change
     * Resets Service selection and updates UI controls
     * Migration Note: Replaces VF page's ApplySearchAction with AccountId parameter
     */
    async handleAccountChange(event) {
        this.selectedAccountId = event.detail.value;
        this.selectedServiceId = 'All'; // Reset service when account changes
        
        try {
            // Load services for selected account
            const services = await getServiceOptions({ accountId: this.selectedAccountId });
            this.serviceOptions = services.map(opt => ({
                label: opt.label,
                value: opt.value
            }));
        } catch (error) {
            this.showErrorToast('Error loading services: ' + error.message);
        }
        
        // Update UI controls (show/hide Add button and disclaimer)
        this.updateUIControls();
        
        // Load initiatives when account is selected
        if (this.selectedAccountId && this.selectedAccountId !== 'All') {
            await this.loadInitiatives();
        } else {
            // If "All" is selected, load all records
            await this.loadInitiatives();
        }
    }

    /**
     * Handle Service dropdown change
     * Updates UI controls and loads initiatives
     * Migration Note: Replaces VF page's ApplySearchAction with ServiceId parameter
     */
    async handleServiceChange(event) {
        this.selectedServiceId = event.detail.value;
        
        // Update UI controls (show/hide Add button and disclaimer)
        this.updateUIControls();
        
        // Load initiatives when service is selected
        if (this.selectedServiceId && this.selectedServiceId !== 'All') {
            await this.loadInitiatives();
        } else {
            // If "All" is selected, load all records
            await this.loadInitiatives();
        }
    }

    async handleSearch() {
        // Match VF page: validateSearch() requires minimum 3 characters
        if (this.searchText && this.searchText.trim().length > 0 && this.searchText.trim().length < 3) {
            this.showWarningToast('Please enter at least 3 characters for search term!!!');
            return;
        }
        
        this.currentPage = 0;
        await this.loadInitiatives();
    }
    
    handleReset() {
        // Match VF page: resetSearch() clears status dropdown and search text
        this.searchText = '';
        this.selectedStatus = 'All';
        this.currentPage = 0;
        this.loadInitiatives();
    }
    
    handlePageSizeChange(event) {
        this.pageSize = parseInt(event.target.value, 10);
        this.currentPage = 0;
        this.updatePagination();
    }
    
    handlePreviousPage() {
        if (this.currentPage > 0) {
            this.currentPage--;
            this.updatePagination();
        }
    }
    
    handleNextPage() {
        if (this.currentPage < this.totalPages - 1) {
            this.currentPage++;
            this.updatePagination();
        }
    }
    
    handlePageChange(event) {
        const pageIndex = parseInt(event.currentTarget.dataset.page, 10);
        this.currentPage = pageIndex;
        this.updatePagination();
    }

    // Action handlers
    handleViewClick(event) {
        event.preventDefault();
        const initiativeId = event.currentTarget.dataset.id;
        this.viewInitiative(initiativeId);
    }
    
    handleDeleteClick(event) {
        event.preventDefault();
        const initiativeId = event.currentTarget.dataset.id;
        this.deleteInitiativeRecord(initiativeId);
    }
    
    handleApproveClick(event) {
        event.preventDefault();
        const initiativeId = event.currentTarget.dataset.id;
        this.openModal(initiativeId, 'Approve');
    }
    
    handleRejectClick(event) {
        event.preventDefault();
        const initiativeId = event.currentTarget.dataset.id;
        this.openModal(initiativeId, 'Reject');
    }
    
    /**
     * Handle Add Initiative button click
     * Validates that Account and Service are selected before navigating
     * Migration Note: Replaces VF page's AddInitiative() action method
     */
    async handleAddInitiative() {
        // Validate that Account and Service are selected
        if (this.selectedAccountId === 'All' || this.selectedServiceId === 'All') {
            this.showWarningToast('Please select Account and Service to add an Initiative');
            return;
        }
        
        try {
            this.isLoading = true;
            
            // Get AccountServiceID for navigation
            const accServiceId = await getAccountServiceIdForAdd({
                accountId: this.selectedAccountId,
                serviceId: this.selectedServiceId
            });
            
            if (!accServiceId) {
                this.showErrorToast('Unable to determine Account Service. Please select Account and Service again.');
                return;
            }
            
            // Navigate to InitiativePage with AccountServiceID
            this.navigateToAddPage(accServiceId);
            
        } catch (error) {
            this.showErrorToast('Error adding initiative: ' + error.message);
        } finally {
            this.isLoading = false;
        }
    }

    // CRUD operations
    /**
     * View initiative - Navigate to InitiativePage with proper AccountServiceID
     * Migration Note: Replaces VF page's ViewInitiative() action method
     * Fetches initiative details first to get AccountServiceID, matching VF behavior
     */
    async viewInitiative(initiativeId) {
        try {
            this.isLoading = true;
            
            // Fetch initiative details to get AccountServiceID and Status (matching VF ViewInitiative method)
            const details = await getInitiativeDetailsForView({ initiativeId: initiativeId });
            
            if (!details || !details.accountServiceId) {
                this.showErrorToast('Unable to load initiative details. Please try again.');
                return;
            }
            
            const accountServiceId = details.accountServiceId;
            const status = details.status || '';
            
            // Navigate to InitiativePage with all required parameters (matching VF page)
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: `/apex/InitiativePage?CurrenInitiativeId=${initiativeId}&AccServiceId=${accountServiceId}&Status=${encodeURIComponent(status)}`
                }
            });
        } catch (error) {
            console.error('Error viewing initiative:', error);
            this.showErrorToast('Error loading initiative: ' + (error.body?.message || error.message || 'Unknown error'));
        } finally {
            this.isLoading = false;
        }
    }

    async deleteInitiativeRecord(initiativeId) {
        // Check permission first
        try {
            const canDelete = await canDeleteInitiative({ initiativeId: initiativeId });
            if (!canDelete) {
                this.showErrorToast('You do not have permission to delete this initiative');
                return;
            }
        } catch (error) {
            this.showErrorToast('Error checking permissions: ' + error.message);
            return;
        }
        
        const result = await this.showConfirmDialog('Are you sure you want to delete this initiative?');
        if (result) {
            try {
                this.isLoading = true;
                await deleteInitiative({ initiativeId: initiativeId });
                this.showSuccessToast('Initiative deleted successfully');
                await this.loadInitiatives();
            } catch (error) {
                this.showErrorToast('Error deleting initiative: ' + error.message);
            } finally {
                this.isLoading = false;
            }
        }
    }
    
    openModal(initiativeId, action) {
        this.selectedInitiativeId = initiativeId;
        this.modalAction = action;
        this.modalComments = '';
        this.showModal = true;
    }
    
    closeModal() {
        this.showModal = false;
        this.selectedInitiativeId = '';
        this.modalAction = '';
        this.modalComments = '';
    }
    
    handleModalCommentsChange(event) {
        this.modalComments = event.target.value;
    }
    
    async handleApproveSubmit() {
        if (!this.modalComments || this.modalComments.trim() === '') {
            this.showWarningToast('Please enter comments');
            return;
        }
        
        try {
            this.isLoading = true;
            await approveInitiative({
                initiativeId: this.selectedInitiativeId,
                comments: this.modalComments,
                accountServiceId: this.accountServiceID
            });
            this.showSuccessToast('Initiative approved successfully');
            this.closeModal();
            await this.loadInitiatives();
        } catch (error) {
            this.showErrorToast('Error approving initiative: ' + error.message);
        } finally {
            this.isLoading = false;
        }
    }
    
    async handleRejectSubmit() {
        if (!this.modalComments || this.modalComments.trim() === '') {
            this.showWarningToast('Please enter comments');
            return;
        }
        
        try {
            this.isLoading = true;
            await rejectInitiative({
                initiativeId: this.selectedInitiativeId,
                comments: this.modalComments,
                accountServiceId: this.accountServiceID
            });
            this.showSuccessToast('Initiative rejected successfully');
            this.closeModal();
            await this.loadInitiatives();
        } catch (error) {
            this.showErrorToast('Error rejecting initiative: ' + error.message);
        } finally {
            this.isLoading = false;
        }
    }
    
    handleModalSubmit() {
        if (this.modalAction === 'Approve') {
            this.handleApproveSubmit();
        } else {
            this.handleRejectSubmit();
        }
    }

    /**
     * Navigate to InitiativePage for adding new initiative
     * Migration Note: Replaces VF page's AddInitiative() PageReference navigation
     * 
     * @param {String} accServiceId - Account Service ID (optional, uses this.accountServiceID if not provided)
     */
    navigateToAddPage(accServiceId) {
        const serviceId = accServiceId || this.accountServiceID;
        
        if (!serviceId) {
            this.showErrorToast('Account Service ID is required to add an Initiative');
            return;
        }
        
        // Navigate to Visualforce page using standard__webPage type
        // This matches the VF page behavior: /apex/InitiativePage?AccServiceId=...
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `/apex/InitiativePage?AccServiceId=${serviceId}`
            }
        });
    }

    /**
     * Update UI controls based on Account/Service selection
     * Migration Note: Replaces VF page's GetAccountServices() method logic
     * Matches VF page behavior: ShowAddTimesheet and ShowDisclaimer properties
     */
    updateUIControls() {
        // If Account or Service is "All", hide Add button and show disclaimer (for non-customers)
        if (this.selectedAccountId === 'All' || this.selectedServiceId === 'All') {
            this.showAddInitiative = false;
            // Show disclaimer only for non-customers
            this.showDisclaimer = !this.isCustomer;
        } else {
            // Both Account and Service are selected
            this.showDisclaimer = false;
            // Show Add button only for non-customers and non-partners
            // Matching VF: rendered="{!ShowAddTimesheet && PortalUserRole != 'Partner'}"
            this.showAddInitiative = !this.isCustomer && this.portalUserRole !== 'Partner';
        }
    }

    // Toast methods
    showSuccessToast(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: message,
                variant: 'success'
            })
        );
    }

    showErrorToast(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error'
            })
        );
    }

    showWarningToast(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Warning',
                message: message,
                variant: 'warning'
            })
        );
    }

    // Confirmation dialog
    async showConfirmDialog(message) {
        return new Promise((resolve) => {
            if (confirm(message)) {
                resolve(true);
            } else {
                resolve(false);
            }
        });
    }
}
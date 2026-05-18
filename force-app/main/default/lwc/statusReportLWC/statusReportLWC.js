import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';

// Apex Methods - Using ODS_StatusReportController wrapper methods (exact VF match)
import getStatusReports from '@salesforce/apex/ODS_StatusReportController.getStatusReports';
import getAccountOptions from '@salesforce/apex/ODS_StatusReportController.getAccountOptions';
import getServiceOptions from '@salesforce/apex/ODS_StatusReportController.getServiceOptions';
import getStatusOptions from '@salesforce/apex/ODS_StatusReportController.getStatusOptions';
import deleteStatusReportLWC from '@salesforce/apex/ODS_StatusReportController.deleteStatusReportLWC';

// User Info
import Id from '@salesforce/user/Id';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import USER_PORTAL_ROLE_FIELD from '@salesforce/schema/User.PortalUserRole__c';

export default class StatusReportLWC extends NavigationMixin(LightningElement) {
    // User context
    userId = Id;
    @track isCustomer = false;
    @track portalUserRole = '';

    // Search and filter properties
    @track fromDate = '';
    @track toDate = '';
    @track selectedStatus = 'All';
    @track selectedAccountId = 'All';
    @track selectedServiceId = 'All';
    @track showAdvancedSearch = false;
    @track searchText = '';

    // Data properties
    @track statusReports = [];
    @track totalRecords = 0;
    @track isLoading = false;
    @track showNoRecords = false;
    @track currentPage = 0;
    @track pageSize = 25;
    @track currentPageInfo = '';

    // UI control properties
    @track showAddSR = false;
    @track showDisclaimer = false;
    @track isDaily = true;

    // Modal properties
    @track showModal = false;
    @track selectedRecord = {};
    @track selectedRecordIndex = 0;

    // Toast properties
    @track showToast = false;
    @track toastMessage = '';
    @track toastVariant = 'success';

    // Options for dropdowns
    @track accountOptions = [];
    @track serviceOptions = [];
    @track statusOptions = [];

    // DataTable properties
    @track sortedBy = 'Status_Date__c';
    @track sortedDirection = 'desc';
    @track enableInfiniteLoading = false;

    // Wire user data - Get user info on component load
    @wire(getRecord, { recordId: '$userId', fields: [USER_PORTAL_ROLE_FIELD] })
    wiredUser({ error, data }) {
        if (data) {
            this.portalUserRole = getFieldValue(data, USER_PORTAL_ROLE_FIELD);
            this.isCustomer = this.portalUserRole === 'Customer';
            // Initialize like VF constructor
            this.initializeComponent();
        } else if (error) {
            this.showErrorToast('Error loading user data: ' + error.body.message);
        }
    }
    
    async initializeComponent() {
        // Match VF constructor initialization exactly
        this.srStatus = 'All';
        this.selectedAccountId = 'All';
        this.selectedServiceId = 'All';
        this.currentPage = 0;
        this.pageSize = 25;
        this.pageNumber = 1;
        this.showPrevious = false;
        this.isDaily = true;
        this.showAddSR = false;
        
        if (this.isCustomer) {
            this.showDisclaimer = false;
            this.showAddSR = false;
        } else {
            this.showDisclaimer = true;
        }
        
        // Check for URL parameters (matching VF page behavior with accntId and srvcId params)
        const urlParams = new URLSearchParams(window.location.search);
        const accntId = urlParams.get('accntId');
        const srvcId = urlParams.get('srvcId');
        
        if (accntId && accntId !== 'All') {
            this.selectedAccountId = accntId;
            // Load services for this account
            try {
                const services = await getServiceOptions({ accountId: accntId });
                this.serviceOptions = services.map(opt => ({
                    label: opt.label,
                    value: opt.value
                }));
            } catch (error) {
                console.error('Error loading services:', error);
            }
        }
        
        if (srvcId && srvcId !== 'All') {
            this.selectedServiceId = srvcId;
        }
        
        // Load all records by default on page load (requirement change)
        this.updateUIControls();
        await this.loadStatusReports();
    }

    // Computed properties
    get todayDate() {
        return new Date().toISOString().split('T')[0];
    }

    get searchIconName() {
        return this.showAdvancedSearch ? 'utility:chevronup' : 'utility:chevrondown';
    }

    get advancedSearchClass() {
        return this.showAdvancedSearch ? 'slds-card__body slds-card__body_inner' : 'slds-hide';
    }

    get workPerformedLabel() {
        return this.isDaily ? 'WORK PERFORMED TODAY' : 'WORK PERFORMED FOR THE WEEK';
    }

    get workToBePerformedLabel() {
        return this.isDaily ? 'WORK TO BE PERFORMED NEXT WORKING DAY' : 'WORK TO BE PERFORMED NEXT WEEK';
    }

    get statusVariant() {
        if (!this.selectedRecord.status) return 'inverse';
        
        switch (this.selectedRecord.status.toLowerCase()) {
            case 'submitted': return 'success';
            case 'draft': return 'warning';
            case 'approved': return 'success';
            default: return 'inverse';
        }
    }

    get isFirstRecord() {
        return this.selectedRecordIndex === 0;
    }

    get isLastRecord() {
        return this.selectedRecordIndex === this.statusReports.length - 1;
    }

    get toastClass() {
        const baseClass = 'slds-notify slds-notify_toast';
        switch (this.toastVariant) {
            case 'success': return `${baseClass} slds-theme_success`;
            case 'error': return `${baseClass} slds-theme_error`;
            case 'warning': return `${baseClass} slds-theme_warning`;
            default: return `${baseClass} slds-theme_info`;
        }
    }

    get toastIcon() {
        switch (this.toastVariant) {
            case 'success': return 'utility:success';
            case 'error': return 'utility:error';
            case 'warning': return 'utility:warning';
            default: return 'utility:info';
        }
    }

    get toastIconClass() {
        return `slds-icon_container slds-icon-utility-${this.toastVariant} slds-m-right_small slds-no-flex slds-align-top`;
    }

    // DataTable columns configuration - Matching image exactly
    get columns() {
        const baseColumns = [
            {
                label: this.isDaily ? 'DATE' : 'WEEK START DATE',
                fieldName: 'Status_Date__c',
                type: 'date',
                sortable: true,
                cellAttributes: { alignment: 'left' },
                typeAttributes: {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit'
                }
            },
            {
                label: 'ACCOUNT',
                fieldName: 'accountService',
                type: 'text',
                sortable: true,
                wrapText: true,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: this.isDaily ? 'WORK PERFORMED TODAY' : 'WORK PERFORMED FOR THE WEEK',
                fieldName: 'Work_For_The_Day__c',
                type: 'text',
                wrapText: true,
                cellAttributes: { 
                    alignment: 'left',
                    class: 'work-performed-cell'
                }
            },
            {
                label: this.isDaily ? 'WORK TO BE PERFORMED NEXT WORKING DAY' : 'WORK TO BE PERFORMED NEXT WEEK',
                fieldName: 'Work_For_The_Next_Day__c',
                type: 'text',
                wrapText: true,
                cellAttributes: { 
                    alignment: 'left',
                    class: 'work-next-day-cell'
                }
            },
            {
                label: 'ISSUES / CONCERNS / ROAD BLOCKS / QUESTIONS',
                fieldName: 'Issues_and_Concerns__c',
                type: 'text',
                wrapText: true,
                cellAttributes: { 
                    alignment: 'left',
                    class: 'issues-cell'
                }
            }
        ];

        // Add Status column for non-customers
        if (!this.isCustomer) {
            baseColumns.push({
                label: 'STATUS',
                fieldName: 'Status__c',
                type: 'text',
                sortable: true,
                cellAttributes: { alignment: 'left' }
            });
        }

        // Add Actions column - will be rendered as custom icons in template
        baseColumns.push({
            label: 'ACTION',
            fieldName: 'actionIcons',
            type: 'text',
            sortable: false,
            cellAttributes: { 
                alignment: 'center',
                class: 'action-cell'
            },
            fixedWidth: 120
        });

        return baseColumns;
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
        // Initialize pagination
        this.currentPage = 0;
        this.pageSize = 25;
        this.loadOptions();
    }

    // Data loading methods
    async loadInitialData() {
        try {
            await this.loadStatusReports();
            this.updateUIControls();
        } catch (error) {
            this.showErrorToast('Error loading initial data: ' + error.message);
        }
    }

    async loadOptions() {
        try {
            this.isLoading = true;
            
            // Load dropdown options
            const [accounts, services, statuses] = await Promise.all([
                getAccountOptions(),
                getServiceOptions({ accountId: this.selectedAccountId }),
                getStatusOptions()
            ]);

            // Convert Map format to array format for lightning-combobox
            this.accountOptions = accounts.map(opt => ({
                label: opt.label,
                value: opt.value
            }));
            this.serviceOptions = services.map(opt => ({
                label: opt.label,
                value: opt.value
            }));
            this.statusOptions = statuses.map(opt => ({
                label: opt.label,
                value: opt.value
            }));

        } catch (error) {
            this.showErrorToast('Error loading options: ' + error.message);
        } finally {
            this.isLoading = false;
        }
    }

    async loadStatusReports() {
        try {
            this.isLoading = true;
            
            const params = {
                accountId: this.selectedAccountId,
                serviceId: this.selectedServiceId,
                status: this.selectedStatus,
                fromDate: this.fromDate,
                toDate: this.toDate
            };

            const result = await getStatusReports(params);
            
            // Result is a wrapper object with stRprtList, accountName, serviceName, isDaily, totalRecords
            if (!result || !result.stRprtList) {
                this.statusReports = [];
                this.totalRecords = 0;
                this.showNoRecords = true;
                return;
            }
            
            // Update page size from result if provided
            if (result.pageSize) {
                this.pageSize = result.pageSize;
            }
            
            // Transform data for display
            this.statusReports = result.stRprtList.map(record => {
                const accountService = `${record.Account_Services__r?.Account__r?.Name || ''} - ${record.Account_Services__r?.ODS_Services__r?.Name__c || ''}`;
                
                // Determine if daily or weekly based on first record
                if (this.statusReports.length === 0 && record.Account_Services__r) {
                    this.isDaily = record.Account_Services__r.Status_Report_Frequency__c !== 'Weekly';
                }
                
                // Format rich text to plain text for table display (matching image)
                const workForDay = this.formatRichText(record.Work_For_The_Day__c);
                const workForNextDay = this.formatRichText(record.Work_For_The_Next_Day__c);
                const issues = this.formatRichText(record.Issues_and_Concerns__c);
                
                return {
                    ...record,
                    accountService: accountService,
                    formattedDate: this.formatDate(record.Status_Date__c),
                    // Store both formatted (for table) and original (for modal)
                    Work_For_The_Day__c: workForDay,
                    Work_For_The_Day__c_Original: record.Work_For_The_Day__c,
                    Work_For_The_Next_Day__c: workForNextDay,
                    Work_For_The_Next_Day__c_Original: record.Work_For_The_Next_Day__c,
                    Issues_and_Concerns__c: issues,
                    Issues_and_Concerns__c_Original: record.Issues_and_Concerns__c,
                    canEdit: !this.isCustomer && record.Status__c !== 'Submitted' && this.portalUserRole !== 'Partner',
                    canDelete: !this.isCustomer && record.Status__c !== 'Submitted' && this.portalUserRole !== 'Partner',
                    // Add action icons placeholder
                    actionIcons: 'icons' // Placeholder for custom rendering
                };
            });

            // Use totalRecords from wrapper, not calculated length
            this.totalRecords = result.totalRecords || this.statusReports.length;
            this.showNoRecords = this.totalRecords === 0;
            this.accountName = result.accountName || '';
            this.serviceName = result.serviceName || '';
            this.isDaily = result.isDaily !== undefined ? result.isDaily : true;
            
            // Update pagination
            this.updatePagination();

        } catch (error) {
            this.showErrorToast('Error loading status reports: ' + error.message);
            this.statusReports = [];
            this.totalRecords = 0;
            this.showNoRecords = true;
        } finally {
            this.isLoading = false;
        }
    }
    
    updatePagination() {
        const totalPages = Math.ceil(this.totalRecords / this.pageSize);
        this.currentPageInfo = `Showing ${this.startRecord} to ${this.endRecord} of ${this.totalRecords} entries`;
    }
    
    get startRecord() {
        return this.currentPage * this.pageSize + 1;
    }
    
    get endRecord() {
        return Math.min((this.currentPage + 1) * this.pageSize, this.totalRecords);
    }
    
    get paginatedReports() {
        const start = this.currentPage * this.pageSize;
        const end = start + this.pageSize;
        return this.statusReports.slice(start, end);
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
    
    get isAddButtonDisabled() {
        return !this.showAddSR;
    }
    

    // Event handlers
    toggleAdvancedSearch() {
        this.showAdvancedSearch = !this.showAdvancedSearch;
    }
    
    handleSearchInput(event) {
        this.searchText = event.target.value;
        // Implement search filtering if needed
        this.filterReports();
    }
    
    clearSearch() {
        this.searchText = '';
        this.filterReports();
    }
    
    filterReports() {
        // Filter logic can be added here if needed
        this.currentPage = 0;
        this.updatePagination();
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

    handleFromDateChange(event) {
        this.fromDate = event.target.value;
    }

    handleToDateChange(event) {
        this.toDate = event.target.value;
    }

    handleStatusChange(event) {
        this.selectedStatus = event.detail.value;
    }

    async handleAccountChange(event) {
        this.selectedAccountId = event.detail.value;
        this.selectedServiceId = 'All';
        
        // Reload service options based on selected account
        try {
            const services = await getServiceOptions({ accountId: this.selectedAccountId });
            this.serviceOptions = services.map(opt => ({
                label: opt.label,
                value: opt.value
            }));
        } catch (error) {
            this.showErrorToast('Error loading services: ' + error.message);
        }
        
        this.updateUIControls();
        
        // Auto-load data when account changes (matching VF ApplySearchAction behavior)
        if (this.selectedAccountId && this.selectedAccountId !== 'All') {
            await this.loadStatusReports();
        }
    }

    async handleServiceChange(event) {
        this.selectedServiceId = event.detail.value;
        this.updateUIControls();
        
        // Auto-load data when service changes (matching VF ApplySearchAction behavior)
        if (this.selectedServiceId && this.selectedServiceId !== 'All') {
            await this.loadStatusReports();
        }
    }

    async handleSearch() {
        // Reset to first page when searching
        this.currentPage = 0;
        await this.loadStatusReports();
    }

    handleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        this.sortData();
    }

    handleViewClick(event) {
        event.preventDefault();
        const recordId = event.currentTarget.dataset.id;
        const record = this.statusReports.find(r => r.Id === recordId);
        if (record) {
            this.viewRecord(record);
        }
    }
    
    handleEditClick(event) {
        event.preventDefault();
        const recordId = event.currentTarget.dataset.id;
        const record = this.statusReports.find(r => r.Id === recordId);
        if (record) {
            this.editRecord(record);
        }
    }
    
    handleDeleteClick(event) {
        event.preventDefault();
        const recordId = event.currentTarget.dataset.id;
        const record = this.statusReports.find(r => r.Id === recordId);
        if (record) {
            this.deleteRecord(record);
        }
    }

    handleAddStatusReport() {
        this.navigateToAddPage();
    }

    // Modal methods
    viewRecord(record) {
        this.selectedRecord = record;
        this.selectedRecordIndex = this.statusReports.findIndex(r => r.Id === record.Id);
        this.showModal = true;
        
        // Set rich text content
        this.setModalContent();
    }

    setModalContent() {
        // Use setTimeout to ensure DOM is rendered
        setTimeout(() => {
            const workPerformedElement = this.template.querySelector('[data-field="workPerformed"]');
            const workToBePerformedElement = this.template.querySelector('[data-field="workToBePerformed"]');
            const issuesConcernsElement = this.template.querySelector('[data-field="issuesConcerns"]');
            
            if (workPerformedElement) {
                // Use original rich text for modal display
                workPerformedElement.innerHTML = this.selectedRecord.Work_For_The_Day__c_Original || this.selectedRecord.Work_For_The_Day__c || '';
            }
            if (workToBePerformedElement) {
                workToBePerformedElement.innerHTML = this.selectedRecord.Work_For_The_Next_Day__c_Original || this.selectedRecord.Work_For_The_Next_Day__c || '';
            }
            if (issuesConcernsElement) {
                issuesConcernsElement.innerHTML = this.selectedRecord.Issues_and_Concerns__c_Original || this.selectedRecord.Issues_and_Concerns__c || '';
            }
        }, 0);
    }

    closeModal() {
        this.showModal = false;
        this.selectedRecord = {};
    }

    showPreviousRecord() {
        if (this.selectedRecordIndex > 0) {
            this.selectedRecordIndex--;
            this.selectedRecord = this.statusReports[this.selectedRecordIndex];
            this.setModalContent();
        }
    }

    showNextRecord() {
        if (this.selectedRecordIndex < this.statusReports.length - 1) {
            this.selectedRecordIndex++;
            this.selectedRecord = this.statusReports[this.selectedRecordIndex];
            this.setModalContent();
        }
    }

    // CRUD operations
    editRecord(record) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `/apex/AddStatusReport?accntId=${record.Account_Services__r?.Account__c}&srvcId=${record.Account_Services__r?.ODS_Services__c}&srId=${record.Id}`
            }
        });
    }

    async deleteRecord(record) {
        const result = await this.showConfirmDialog('Are you sure you want to delete this status report?');
        if (result) {
            try {
                this.isLoading = true;
                await deleteStatusReportLWC({ deleteSRId: record.Id });
                this.showSuccessToast('Status report deleted successfully');
                await this.loadStatusReports();
            } catch (error) {
                this.showErrorToast('Error deleting status report: ' + error.message);
            } finally {
                this.isLoading = false;
            }
        }
    }

    navigateToAddPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `/apex/AddStatusReport?accntId=${this.selectedAccountId}&srvcId=${this.selectedServiceId}`
            }
        });
    }


    updateUIControls() {
        if (this.selectedAccountId === 'All' || this.selectedServiceId === 'All') {
            this.showAddSR = false;
            this.showDisclaimer = !this.isCustomer;
        } else {
            this.showAddSR = !this.isCustomer;
            this.showDisclaimer = false;
        }
    }

    sortData() {
        const cloneData = [...this.statusReports];
        cloneData.sort((a, b) => {
            let aVal = a[this.sortedBy];
            let bVal = b[this.sortedBy];
            
            if (aVal === bVal) return 0;
            
            if (this.sortedDirection === 'asc') {
                return aVal > bVal ? 1 : -1;
            } else {
                return aVal < bVal ? 1 : -1;
            }
        });
        this.statusReports = cloneData;
    }

    formatDate(dateString) {
        if (!dateString) return '';
        const date = new Date(dateString);
        // Format as MM/DD/YYYY to match image
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const year = date.getFullYear();
        return `${month}/${day}/${year}`;
    }
    
    formatRichText(htmlContent) {
        if (!htmlContent) return '';
        // Strip HTML tags for display in datatable text field
        // Use regex to remove HTML tags
        return htmlContent.replace(/<[^>]*>/g, '').replace(/&nbsp;/g, ' ').trim();
    }

    // Toast methods
    showSuccessToast(message) {
        this.showToastMessage(message, 'success');
    }

    showErrorToast(message) {
        this.showToastMessage(message, 'error');
    }

    showWarningToast(message) {
        this.showToastMessage(message, 'warning');
    }

    showToastMessage(message, variant) {
        this.toastMessage = message;
        this.toastVariant = variant;
        this.showToast = true;
        
        // Auto-hide toast after 5 seconds
        setTimeout(() => {
            this.hideToast();
        }, 5000);
    }

    hideToast() {
        this.showToast = false;
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

    // Infinite loading (for future enhancement)
    handleLoadMore() {
        // Implementation for loading more records
        this.enableInfiniteLoading = false;
    }
}
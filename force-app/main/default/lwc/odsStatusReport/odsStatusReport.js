import { LightningElement, api, track } from 'lwc';
import getStatusReports from '@salesforce/apex/ODS_StatusReportController_New.getStatusReport';
import getAccountPicklistValuesRemote from '@salesforce/apex/ODS_StatusReportController_New.getAccountPicklistValuesRemote';
import getServicePicklistValues from '@salesforce/apex/ODS_StatusReportController_New.getServicePicklistValues';
import getStatusPicklistValuesRemote from '@salesforce/apex/ODS_StatusReportController_New.getStatusPicklistValuesRemote';
import deleteStatusReport from '@salesforce/apex/ODS_StatusReportController_New.deleteStatusReport';
import editStatusReport from '@salesforce/apex/ODS_StatusReportController_New.editStatusReport';
import addStatusReport from '@salesforce/apex/ODS_StatusReportController_New.addStatusReport';

export default class OdsStatusReport extends LightningElement {
    @api recordId;
    @track accountOptions = [];
    @track serviceOptions = [];
    @track statusOptions = [];
    @track statusReports = [];
    @track selectedAccount = 'All';
    @track selectedService = 'All';
    @track selectedStatus = 'All';
    @track fromDate = '';
    @track toDate = '';
    @track showModal = false;
    @track showEditModal = false;
    @track selectedReport = {};
    @track editingReportId = null;
    @track currentPage = 1;
    @track totalRecords = 0;
    @track pageSize = 25;
    @track isCustomer = false;
    @track showAddSR = false;
    @track showDisclaimer = false;
    @track currentPageInfo = '';
    @track isDaily = true;
    @track showAddSRButton = false;
    @track showStatusDropdown = true;
    @track canEditRecord = true;

    columns = [
        { 
            label: 'Date', 
            fieldName: 'Date__c', 
            type: 'date',
            typeAttributes: {
                year: 'numeric',
                month: '2-digit',
                day: '2-digit'
            },
            initialWidth: 120
        },
        { label: 'Account', fieldName: 'AccountName', type: 'text', initialWidth: 200 },
        { 
            label: 'Work Performed Today', 
            fieldName: 'Work_For_The_Day__c', 
            type: 'text', 
            initialWidth: 200 
        },
        { 
            label: 'Work To Be Performed Next Working Day', 
            fieldName: 'Work_For_The_Next_Day__c', 
            type: 'text', 
            initialWidth: 200 
        },
        { 
            label: 'Issues / Concerns / Road Blocks / Questions', 
            fieldName: 'Issues_and_Concerns__c', 
            type: 'text', 
            initialWidth: 200 
        },
        { 
            label: 'Status', 
            fieldName: 'Status__c', 
            type: 'text', 
            initialWidth: 150 
        },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'View', name: 'view' },
                    { label: 'Edit', name: 'edit' },
                    { label: 'Delete', name: 'delete' }
                ]
            },
            initialWidth: 150
        }
    ];

    connectedCallback() {
        this.loadPicklistValues();
        this.loadStatusReports();
    }

    // Getters for pagination buttons
    get isPreviousDisabled() {
        return this.currentPage <= 1;
    }

    get isNextDisabled() {
        const totalPages = Math.ceil(this.totalRecords / this.pageSize);
        return this.currentPage >= totalPages;
    }

    get isFirstDisabled() {
        return this.currentPage <= 1;
    }

    get isLastDisabled() {
        const totalPages = Math.ceil(this.totalRecords / this.pageSize);
        return this.currentPage >= totalPages;
    }

    get isStatusReportsEmpty() {
        return !this.statusReports || this.statusReports.length === 0;
    }

    // Getter to format the selected report's date for the modal
    get formattedSelectedReportDate() {
        if (!this.selectedReport || !this.selectedReport.Date__c) return '';
        const date = new Date(this.selectedReport.Date__c);
        return date.toLocaleDateString();
    }

    // Helper method to sanitize HTML content
    sanitizeHtml(content) {
        if (!content) return '';
        // Create a temporary element to strip HTML tags
        const temp = document.createElement('div');
        temp.innerHTML = content;
        return temp.textContent || temp.innerText || '';
    }

    // Getters for sanitized content to avoid HTML tags in output
    get sanitizedWorkForToday() {
        return this.sanitizeHtml(this.selectedReport.Work_For_The_Day__c);
    }

    get sanitizedWorkForNextDay() {
        return this.sanitizeHtml(this.selectedReport.Work_For_The_Next_Day__c);
    }

    get sanitizedIssuesAndConcerns() {
        return this.sanitizeHtml(this.selectedReport.Issues_and_Concerns__c);
    }

    // Getter to determine if daily popup should be shown
    get showDailyPopup() {
        return this.isDaily;
    }

    // Getter to determine if weekly popup should be shown
    get showWeeklyPopup() {
        return !this.isDaily;
    }

    // Load picklist values
    loadPicklistValues() {
        getAccountPicklistValuesRemote()
            .then(result => {
                this.accountOptions = result.map(opt => ({
                    label: opt.label,
                    value: opt.value
                }));
            })
            .catch(error => console.error('Error fetching accounts:', error));

        this.getServicePicklistValuesHelper();

        getStatusPicklistValuesRemote()
            .then(result => {
                this.statusOptions = result.map(opt => ({
                    label: opt.label,
                    value: opt.value
                }));
            })
            .catch(error => console.error('Error fetching statuses:', error));
    }

    getServicePicklistValuesHelper() {
        getServicePicklistValues({ AccountId: this.selectedAccount })
            .then(result => {
                this.serviceOptions = result.map(opt => ({
                    label: opt.label,
                    value: opt.value
                }));
            })
            .catch(error => console.error('Error fetching services:', error));
    }

    // Load status reports
    loadStatusReports() {
        getStatusReports({
            AccountId: this.selectedAccount,
            ServiceId: this.selectedService,
            srStatus: this.selectedStatus,
            FromDate: this.fromDate,
            ToDate: this.toDate,
            pageNumber: this.currentPage,
            pageSize: this.pageSize
        })
            .then(result => {
                // Transform data to include Account and Service names for datatable
                this.statusReports = result.statusReports.map(report => ({
                    ...report,
                    AccountName: report.Account__r?.Name || '',
                    ServiceName: report.Service__r?.Name || '',
                    // Sanitize the fields for display in the table
                    Work_For_The_Day__c: this.sanitizeHtml(report.Work_For_The_Day__c),
                    Work_For_The_Next_Day__c: this.sanitizeHtml(report.Work_For_The_Next_Day__c),
                    Issues_and_Concerns__c: this.sanitizeHtml(report.Issues_and_Concerns__c)
                }));
                this.isDaily = result.isDaily;
                this.totalRecords = result.totalRecords;
                this.showAddSR = result.showAddSR;
                this.showDisclaimer = result.showDisclaimer;
                this.isCustomer = result.isCustomer;
                this.showAddSRButton = result.showAddSRButton;
                this.showPaginationControls();
            })
            .catch(error => console.error('Error fetching reports:', error));
    }

    showPaginationControls() {
        const totalPages = Math.ceil(this.totalRecords / this.pageSize);
        this.currentPageInfo = `Page ${this.currentPage} of ${totalPages}`;
    }

    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.loadStatusReports();
        }
    }

    handleNext() {
        const totalPages = Math.ceil(this.totalRecords / this.pageSize);
        if (this.currentPage < totalPages) {
            this.currentPage++;
            this.loadStatusReports();
        }
    }

    handleAccountChange(event) {
        this.selectedAccount = event.target.value;
        this.getServicePicklistValuesHelper();
        this.loadStatusReports();
    }

    handleServiceChange(event) {
        this.selectedService = event.target.value;
        this.loadStatusReports();
    }

    handleStatusChange(event) {
        this.selectedStatus = event.target.value;
        this.loadStatusReports();
    }

    handleFromDateChange(event) {
        this.fromDate = event.target.value;
        this.loadStatusReports();
    }

    handleToDateChange(event) {
        this.toDate = event.target.value;
        this.loadStatusReports();
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        
        switch (actionName) {
            case 'view':
                this.handleViewAction(row);
                break;
            case 'edit':
                this.handleEditAction(row);
                break;
            case 'delete':
                this.handleDeleteAction(row);
                break;
        }
    }

    handleViewAction(row) {
        this.selectedReport = this.statusReports.find(rep => rep.recordId === row.recordId);
        this.showModal = true;
    }

    handleEditAction(row) {
        if (row && row.Id) {
            this.editingReportId = row.Id;
            this.showEditModal = true;
        } else {
            console.error('Invalid row data for edit action');
        }
    }

    handleDeleteAction(row) {
        if (confirm('Are you sure you want to delete this report?')) {
            deleteStatusReport({ deleteSRId: row.Id })
                .then(() => this.loadStatusReports())
                .catch(error => console.error('Error deleting report:', error));
        }
    }

    handleEditSuccess() {
        this.showEditModal = false;
        this.editingReportId = null;
        this.loadStatusReports();
    }

    closeEditModal() {
        this.showEditModal = false;
        this.editingReportId = null;
    }

    closeModal() {
        this.showModal = false;
        this.selectedReport = {};
    }

    handleSearch() {
        this.currentPage = 1;
        this.loadStatusReports();
    }

    handleFirst() {
        this.currentPage = 1;
        this.loadStatusReports();
    }

    handleLast() {
        const totalPages = Math.ceil(this.totalRecords / this.pageSize);
        this.currentPage = totalPages;
        this.loadStatusReports();
    }

    toggleSearch() {
        const advncSearch = this.template.querySelector('.advnc_search');
        if (advncSearch) {
            advncSearch.classList.toggle('active');
        }
    }

    handleAddStatusReport() {
        addStatusReport()
            .then(result => console.log('Add status report:', result))
            .catch(error => console.error('Error adding report:', error));
    }
}
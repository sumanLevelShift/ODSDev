import { LightningElement, api, track } from 'lwc';
import getPortalContext from '@salesforce/apex/ODS_ViewInitiativeService_New.getPortalContext';
import getStatusPicklist from '@salesforce/apex/ODS_ViewInitiativeService_New.getStatusPicklist';
import getInitList from '@salesforce/apex/ODS_ViewInitiativeService_New.getInitList';
import computeTotals from '@salesforce/apex/ODS_ViewInitiativeService_New.computeTotals';
import approveInitiative from '@salesforce/apex/ODS_ViewInitiativeService_New.approveInitiative';
import rejectInitiative from '@salesforce/apex/ODS_ViewInitiativeService_New.rejectInitiative';
import deleteInitiative from '@salesforce/apex/ODS_ViewInitiativeService_New.deleteInitiative';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class ViewInitiative extends NavigationMixin(LightningElement) {
    // Filters
    @api recordId;
    @track accountId = '';
    @track serviceId = '';
    @track statusFilter = 'All';
    @track searchText = '';
    @track searchStyle = 'display: none;';

    // Options/context
    @track statusOptions = [];
    @track showAddInitiative = false;
    @track showDisclaimer = false;
    @track isCustomer = false;
    @track portalUserRole;
    @track isInitiativeApprover = false;

    // Data state
    @track rows = [];
    @track totals;
    @track isLoading = false;

    // Modal state
    @track showModal = false;
    @track isApproveFlow = true;
    @track modalTitle = '';
    @track modalComments = '';
    @track modalInitiativeId;
    @track approveStyle = 'display: inline-block;';
    @track rejectStyle = 'display: none;';

    get hasRecords() {
        return this.rows && this.rows.length > 0;
    }

    connectedCallback() {
        this.bootstrap();
    }

    async bootstrap() {
        this.isLoading = true;
        try {
            const ctx = await getPortalContext();
            this.portalUserRole = ctx.portalUserRole;
            this.isCustomer = ctx.isCustomer;
            this.isInitiativeApprover = ctx.isInitiativeApprover;
            this.showAddInitiative = ctx.showAddInitiative;
            this.showDisclaimer = ctx.showDisclaimer;

            // Pre-fill account/service if provided by context
            if (ctx.defaultAccountId) this.accountId = ctx.defaultAccountId;
            if (ctx.defaultServiceId) this.serviceId = ctx.defaultServiceId;

            this.statusOptions = await getStatusPicklist();

            await this.fetchList();
        } catch (e) {
            this.notify('Initialization error', this.reduceError(e), 'error');
        } finally {
            this.isLoading = false;
        }
    }

    async fetchList() {
        this.isLoading = true;
        try {
            const resp = await getInitList({
                accountId: this.accountId || null,
                serviceId: this.serviceId || null,
                statusFilter: this.statusFilter || 'All',
                searchText: this.searchText || ''
            });
            this.rows = resp.records || [];
            this.isCustomer = resp.isCustomer;
            this.portalUserRole = resp.portalUserRole;
            this.isInitiativeApprover = resp.isInitiativeApprover;
            this.showAddInitiative = resp.showAddInitiative;
            this.showDisclaimer = resp.showDisclaimer;

            // Process rows to add computed properties for rendering
            this.rows = this.rows.map(row => {
                // Determine row class for customer submitted initiatives
                const rowClass = (row.status === 'Initiative Submitted' && this.isCustomer) ? 'cust-init-sub' : '';
                
                // Determine visibility flags for actions based on VF logic
                const finalStatuses = new Set([
                    'Initiative Approved',
                    'Initiative Submitted',
                    'Active Initiative',
                    'Initiative Delivered',
                    'On Hold',
                    'Approved After Re-evaluation'
                ]);
                const isCustomer = this.isCustomer;
                const isPartner = this.portalUserRole === 'Partner';
                const showDelete = !isCustomer && !isPartner && !finalStatuses.has(row.status);
                
                // Approve/Reject visibility:
                // If (Customer AND isInitiativeApprover AND status == 'Initiative Submitted')
                // OR (TAM/Practice Head AND status == 'Initiative Submitted')
                const canApproveReject =
                    (this.portalUserRole === 'Customer' && this.isInitiativeApprover && row.status === 'Initiative Submitted') ||
                    ((this.portalUserRole === 'Technical Account Manager' || this.portalUserRole === 'Practice Head') && row.status === 'Initiative Submitted');
                const showApprove = canApproveReject;
                const showReject = canApproveReject;
                const showView = true; // Always show view

                return {
                    ...row,
                    rowClass,
                    showDelete,
                    showApprove,
                    showReject,
                    showView
                };
            });

            // Totals
            if (this.accountId) {
                this.totals = await computeTotals({ accountId: this.accountId });
            } else {
                this.totals = undefined;
            }
        } catch (e) {
            this.notify('Fetch error', this.reduceError(e), 'error');
        } finally {
            this.isLoading = false;
        }
    }

    toggleSearch() {
        if (this.searchStyle === 'display: none;') {
            this.searchStyle = 'display: block;';
        } else {
            this.searchStyle = 'display: none;';
        }
    }

    handleSearchKeyup(event) {
        // Validate search term (minimum 3 characters)
        const minLength = 3;
        const searchText = event.target.value.trim();
        if (searchText.length >= minLength || searchText.length === 0) {
            // Allow the search to proceed
            this.searchText = searchText;
        }
    }

    handleStatusChange(e) { 
        this.statusFilter = e.detail.value; 
    }
    handleAccountChange(e) { this.accountId = e.detail.value; }
    handleServiceChange(e) { this.serviceId = e.detail.value; }

    async handleSearch() {
        // enforce min length like VF: allow empty or >= 3
        const term = (this.searchText || '').trim();
        if (term.length > 0 && term.length < 3) {
            this.notify('Validation', 'Please enter at least 3 characters for search term', 'warning');
            return;
        }
        await this.fetchList();
    }

    async handleReset() {
        this.statusFilter = 'All';
        this.searchText = '';
        this.accountId = '';
        this.serviceId = '';
        await this.fetchList();
    }

    handleViewClick(event) {
        // In VF, this called ViewInitiativeAction which navigated to InitiativePage
        // We'll maintain the same behavior for consistency
        const initiativeId = event.target.closest('tr').dataset.initiativeId;
        const url = `/apex/InitiativePage?CurrenInitiativeId=${initiativeId}`;
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: { url }
        }).then((generatedUrl) => {
            window.location.assign(generatedUrl);
        });
    }

    handleDeleteClick(event) {
        const initiativeId = event.target.closest('tr').dataset.initiativeId;
        // Simple confirm; for richer UX consider lightning-confirm (not GA for LWC OSS)
        // eslint-disable-next-line no-alert
        const proceed = window.confirm('Are you sure you want to delete?');
        if (!proceed) return;
        this.doDelete(initiativeId);
    }

    handleApproveClick(event) {
        const initiativeId = event.target.closest('tr').dataset.initiativeId;
        this.openModal(true, initiativeId);
    }

    handleRejectClick(event) {
        const initiativeId = event.target.closest('tr').dataset.initiativeId;
        this.openModal(false, initiativeId);
    }

    openModal(isApprove, initiativeId) {
        this.isApproveFlow = isApprove;
        this.modalTitle = isApprove ? 'Approve' : 'Reject';
        this.modalComments = '';
        this.modalInitiativeId = initiativeId;
        this.approveStyle = isApprove ? 'display: inline-block;' : 'display: none;';
        this.rejectStyle = isApprove ? 'display: none;' : 'display: inline-block;';
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
        this.modalComments = '';
        this.modalInitiativeId = undefined;
    }

    handleModalComments(e) { this.modalComments = e.detail.value; }

    async confirmApprove() {
        try {
            this.isLoading = true;
            await approveInitiative({ initiativeId: this.modalInitiativeId, comments: this.modalComments || '' });
            this.notify('Success', 'Initiative approved', 'success');
            this.closeModal();
            await this.fetchList();
        } catch (e) {
            this.notify('Approve failed', this.reduceError(e), 'error');
        } finally {
            this.isLoading = false;
        }
    }

    async confirmReject() {
        // Require comments like VF for reject
        const cmnts = (this.modalComments || '').trim();
        if (!cmnts) {
            this.notify('Validation', 'Please enter comments', 'warning');
            return;
        }
        try {
            this.isLoading = true;
            await rejectInitiative({ initiativeId: this.modalInitiativeId, comments: cmnts });
            this.notify('Success', 'Initiative set to Re-evaluate', 'success');
            this.closeModal();
            await this.fetchList();
        } catch (e) {
            this.notify('Reject failed', this.reduceError(e), 'error');
        } finally {
            this.isLoading = false;
        }
    }

    async doDelete(id) {
        try {
            this.isLoading = true;
            await deleteInitiative({ initiativeId: id });
            this.notify('Deleted', 'Initiative deleted', 'success');
            await this.fetchList();
        } catch (e) {
            this.notify('Delete failed', this.reduceError(e), 'error');
        } finally {
            this.isLoading = false;
        }
    }

    handleAddInitiative() {
        // VF flow for add: redirect to InitiativePage with AccServiceId built from selected Account+Service context is non-trivial
        // In original VF it calls AddInitiative which navigates to /apex/InitiativePage?AccServiceId=...
        // Here we just navigate to the Initiatives landing page; optionally this can be enhanced to compute the AccountServiceId first.
        const url = '/apex/InitiativePage';
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: { url }
        }).then((generatedUrl) => {
            window.location.assign(generatedUrl);
        });
    }

    notify(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    reduceError(error) {
        let message = 'Unknown error';
        if (Array.isArray(error?.body)) {
            message = error.body.map(e => e.message).join(', ');
        } else if (typeof error?.body?.message === 'string') {
            message = error.body.message;
        } else if (typeof error?.message === 'string') {
            message = error.message;
        }
        return message;
    }
}
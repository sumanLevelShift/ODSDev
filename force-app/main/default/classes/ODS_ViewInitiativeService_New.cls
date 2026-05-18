public with sharing class ODS_ViewInitiativeService_New {
    public class PortalContext {
        @AuraEnabled public String portalUserRole;
        @AuraEnabled public Boolean isCustomer;
        @AuraEnabled public Boolean isInitiativeApprover;
        @AuraEnabled public Boolean showAddInitiative;
        @AuraEnabled public Boolean showDisclaimer;
        @AuraEnabled public Id defaultAccountId;
        @AuraEnabled public Id defaultServiceId;
    }

    public class InitiativeRow {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String jiraId;
        @AuraEnabled public String accountServiceName;
        @AuraEnabled public String status;
        @AuraEnabled public Decimal estimatedHours;
        @AuraEnabled public Decimal submittedHours;
        @AuraEnabled public Decimal remainingHours;
        @AuraEnabled public Decimal submittedUtilization;
        @AuraEnabled public Decimal approvedUtilization;
        @AuraEnabled public Id accountServiceId;
    }

    public class ListResponse {
        @AuraEnabled public List<InitiativeRow> records;
        @AuraEnabled public Boolean isCustomer;
        @AuraEnabled public String portalUserRole;
        @AuraEnabled public Boolean isInitiativeApprover;
        @AuraEnabled public Boolean showAddInitiative;
        @AuraEnabled public Boolean showDisclaimer;
    }

    public class TotalsResponse {
        @AuraEnabled public Decimal estimatedHours;
        @AuraEnabled public Decimal submittedHours;
        @AuraEnabled public Decimal remainingHours;
    }

    @AuraEnabled(cacheable=true)
    public static PortalContext getPortalContext() {
        PortalContext ctx = new PortalContext();
        User u = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());
        ctx.portalUserRole = u.PortalUserRole__c;
        // Default flags based on ODS_ViewIntiativeController_New constructor
        if (ctx.portalUserRole == 'Customer') {
            ctx.isCustomer = true;
            ctx.showAddInitiative = false;
            ctx.showDisclaimer = false;
        } else {
            ctx.isCustomer = false;
            ctx.showAddInitiative = true;
            ctx.showDisclaimer = true;
        }

        // Determine initiative approver flag from Initiative contact account service for "all" by default
        ctx.isInitiativeApprover = false;
        if (u.ContactId != null) {
            // When no service filter is chosen yet use 'all' services; approver check will be refined once a service is picked in getInitList
            List<Contact_Account_Service__c> cas = ODS_Data_Utility.fetchInitiativeContactAccountService(u.ContactId, 'All');
            if (!cas.isEmpty()) {
                ctx.isInitiativeApprover = cas[0].Is_initiate_approver__c;
            }
        }

        // Provide default account/service when Customer, mimicking GetLoggedUserAccountService()
        if (ctx.portalUserRole == 'Customer') {
            List<Contact> cnt = ODS_Data_Utility.FetchAccountIdByCustomer(u.ContactId);
            if (!cnt.isEmpty()) {
                ctx.defaultAccountId = cnt[0].AccountId;
                List<Account_Services__c> accService = ODS_Data_Utility.fetchAccServcesByAcc(ctx.defaultAccountId);
                if (!accService.isEmpty()) {
                    ctx.defaultServiceId = accService[0].ODS_Services__c;
                }
            }
        }

        return ctx;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getStatusPicklist() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        // Always include 'All'
        options.add(new Map<String, String>{ 'label' => 'All', 'value' => 'All' });

        User u = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());
        Boolean isCustomer = (u.PortalUserRole__c == 'Customer');

        Schema.DescribeSObjectResult objDscrb = Initiatives__c.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fields = objDscrb.fields.getMap();
        for (Schema.PicklistEntry ple : fields.get('Status__c').getDescribe().getPickListValues()) {
            if (isCustomer && ple.getLabel() == 'Saved') {
                continue;
            }
            options.add(new Map<String, String>{ 'label' => ple.getLabel(), 'value' => ple.getValue() });
        }
        return options;
    }

    @AuraEnabled(cacheable=true)
    public static ListResponse getInitList(Id accountId, Id serviceId, String statusFilter, String searchText) {
        ListResponse resp = new ListResponse();
        User u = ODS_Data_Utility.fetchUserById(UserInfo.getUserId());
        resp.portalUserRole = u.PortalUserRole__c;

        // Determine approver flag per selected service
        resp.isInitiativeApprover = false;
        if (u.ContactId != null) {
            List<Contact_Account_Service__c> iCas = ODS_Data_Utility.fetchInitiativeContactAccountService(u.ContactId, (serviceId == null ? 'All' : (String)serviceId));
            if (!iCas.isEmpty()) {
                resp.isInitiativeApprover = iCas[0].Is_initiate_approver__c;
            }
        }
        if (resp.portalUserRole == 'Customer') {
            resp.isCustomer = true;
            resp.showAddInitiative = false;
            resp.showDisclaimer = false;
        } else {
            resp.isCustomer = false;
            resp.showAddInitiative = true;
            resp.showDisclaimer = true;
        }

        // Build Account_Service__c filter set
        Set<Id> accountServiceIds = new Set<Id>();
        if (accountId != null && serviceId != null) {
            for (Account_Services__c asx : [SELECT Id FROM Account_Services__c WHERE Account__c = :accountId AND ODS_Services__c = :serviceId]) {
                accountServiceIds.add(asx.Id);
            }
        } else if (accountId != null) {
            for (Account_Services__c asx : [SELECT Id FROM Account_Services__c WHERE Account__c = :accountId]) {
                accountServiceIds.add(asx.Id);
            }
        } else if (serviceId != null) {
            for (Account_Services__c asx : [SELECT Id FROM Account_Services__c WHERE ODS_Services__c = :serviceId]) {
                accountServiceIds.add(asx.Id);
            }
        }

        // Build SOSL search id set when searchText length >= 3
        Set<Id> searchedInitIds = new Set<Id>();
        String term = (searchText == null ? '' : searchText.trim());
        if (term != null && term.length() >= 3 && !accountServiceIds.isEmpty()) {
            List<List<SObject>> searchResults = [
                FIND :term IN ALL FIELDS
                RETURNING
                Estimate__c (Initiative_Lookup__c WHERE Initiative_Lookup__r.Account_Service__c IN :accountServiceIds ORDER BY LastModifiedDate DESC LIMIT 1000),
                Initiatives__c (Id WHERE Account_Service__c IN :accountServiceIds ORDER BY LastModifiedDate DESC LIMIT 1000)
            ];
            for (Estimate__c est : (List<Estimate__c>)searchResults[0]) {
                if (est.Initiative_Lookup__c != null) searchedInitIds.add(est.Initiative_Lookup__c);
            }
            for (Initiatives__c ini : (List<Initiatives__c>)searchResults[1]) {
                searchedInitIds.add(ini.Id);
            }
        }

        // Build WHERE clauses
        List<String> wheres = new List<String>();
        if (!accountServiceIds.isEmpty()) {
            wheres.add('Account_Service__c IN :accountServiceIds');
        }
        if (!String.isBlank(term) && term.length() >= 3) {
            wheres.add('Id IN :searchedInitIds');
        }
        if (String.isBlank(statusFilter)) statusFilter = 'All';
        if (statusFilter != 'All') {
            wheres.add('Status__c = :statusFilter');
        } else {
            wheres.add('Status__c != :statusFilter'); // match legacy behavior using "All" as sentinel
        }

        String whereSoql = wheres.isEmpty() ? '' : (' WHERE ' + String.join(wheres, ' AND '));
        String orderBy = (resp.portalUserRole == 'Customer')
            ? ' ORDER BY Status_Order__c, LastModifiedDate DESC'
            : ' ORDER BY LastModifiedDate DESC';

        // If Partner, optionally constrain by partner account/contact as in VF logic when available
        String extraPartnerWhere = '';
        if (resp.portalUserRole == 'Partner') {
            // Leverage fields used in VF controller
            User fu = u;
            Id partnerAccId = (fu.Contact != null) ? fu.Contact.AccountId : null;
            Id partnerContId = fu.ContactId;
            if (partnerAccId != null && partnerContId != null) {
                extraPartnerWhere = ' AND Account_Service__r.Account__r.Channel_Partner__c = :partnerAccId AND Account_Service__r.Account__r.Channel_Partner_Contact__c = :partnerContId';
            }
        }

        String baseSoql = 'SELECT Id, Name, Account_Service__c, ' +
                          'Account_Service__r.ODS_Service_Name__c, Account_Service__r.ODS_Account_Name__c, ' +
                          'Estimated_hours__c, Submitted_Hours__c, JIRA_ID__c, Offshore_Estimate__c, ' +
                          'LastModifiedDate, Status__c, Submitted_Utilization__c, Remaining_Hours__c, Utilization__c, Status_Order__c ' +
                          'FROM Initiatives__c' + whereSoql + extraPartnerWhere + orderBy;

        List<Initiatives__c> inits = Database.query(baseSoql);

        List<InitiativeRow> rows = new List<InitiativeRow>();
        for (Initiatives__c i : inits) {
            InitiativeRow r = new InitiativeRow();
            r.id = i.Id;
            r.name = i.Name;
            r.jiraId = i.JIRA_ID__c;
            String accName = (i.Account_Service__r != null) ? i.Account_Service__r.ODS_Account_Name__c : null;
            String svcName = (i.Account_Service__r != null) ? i.Account_Service__r.ODS_Service_Name__c : null;
            r.accountServiceName = (accName != null ? accName : '') + (svcName != null ? ' - ' + svcName : '');
            r.status = i.Status__c;
            r.estimatedHours = i.Estimated_hours__c;
            r.submittedHours = i.Submitted_Hours__c;
            r.remainingHours = i.Remaining_Hours__c;
            r.submittedUtilization = i.Submitted_Utilization__c;
            r.approvedUtilization = i.Utilization__c;
            r.accountServiceId = i.Account_Service__c;
            rows.add(r);
        }
        resp.records = rows;
        return resp;
    }

    @AuraEnabled(cacheable=true)
    public static TotalsResponse computeTotals(Id accountId) {
        TotalsResponse t = new TotalsResponse();
        if (accountId == null) return t;
        AggregateResult[] results = [
            SELECT SUM(Estimated_Hours__c) totalEstimated,
                   SUM(Submitted_Hours__c) totalConsumed,
                   SUM(Remaining_Hours__c) totalRemaining
            FROM Initiatives__c
            WHERE Account_Service__r.Account__c = :accountId
        ];
        if (!results.isEmpty()) {
            t.estimatedHours = (Decimal)results[0].get('totalEstimated');
            t.submittedHours = (Decimal)results[0].get('totalConsumed');
            t.remainingHours = (Decimal)results[0].get('totalRemaining');
        }
        return t;
    }

    @AuraEnabled
    public static void approveInitiative(Id initiativeId, String comments) {
        if (initiativeId == null) return;
        Initiatives__c initiative = new Initiatives__c(Id = initiativeId);
        initiative.Status__c = 'Initiative Approved';
        if (comments != null) initiative.Comments__c = comments.trim();
        initiative.Approver_Name__c = UserInfo.getUserId();
        initiative.Initiative_Approved_Date__c = Date.today();
        update initiative;

        // Send email notification similar to VF logic
        Initiatives__c init = [SELECT Client_side_Contact__r.Name, Status__c, Account_Service__c FROM Initiatives__c WHERE Id = :initiativeId LIMIT 1];
        String url = URL.getOrgDomainUrl().toExternalForm() + '/apex/InitiativePage?CurrenInitiativeId=' + initiativeId + '&AccServiceId=' + init.Account_Service__c;
        ODS_InitiativeController.sendEmailInitiative(initiativeId, init.Account_Service__c, init.Status__c, init.Client_side_Contact__r.Name, url);
    }

    @AuraEnabled
    public static void rejectInitiative(Id initiativeId, String comments) {
        if (initiativeId == null) return;
        Initiatives__c initiative = new Initiatives__c(Id = initiativeId);
        initiative.Status__c = 'Re-evaluate';
        if (comments != null) initiative.Comments__c = comments.trim();
        initiative.Approver_Name__c = UserInfo.getUserId();
        initiative.Initiative_Re_Evaluation_Date__c = Date.today();
        update initiative;

        Initiatives__c init = [SELECT Client_side_Contact__r.Name, Status__c, Account_Service__c FROM Initiatives__c WHERE Id = :initiativeId LIMIT 1];
        String url = URL.getOrgDomainUrl().toExternalForm() + '/apex/InitiativePage?CurrenInitiativeId=' + initiativeId + '&AccServiceId=' + init.Account_Service__c;
        ODS_InitiativeController.sendEmailInitiative(initiativeId, init.Account_Service__c, init.Status__c, init.Client_side_Contact__r.Name, url);
    }

    @AuraEnabled
    public static void deleteInitiative(Id initiativeId) {
        if (initiativeId == null) return;
        delete new Initiatives__c(Id = initiativeId);
    }
}
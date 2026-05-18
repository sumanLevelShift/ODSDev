public with sharing class MissedPickupRoutingService {
    public class AssignRequest {
        @InvocableVariable(required=true) public Id missedPickupReportId;
    }

    public class AssignResponse {
        @InvocableVariable public Id assignedUserId;
        @InvocableVariable public String message;
    }

    @AuraEnabled
    public static void updateReportStatus(Id reportId, String status, String resolutionNotes) {
        if (reportId == null || String.isBlank(status)) return;
        MissedPickupReport__c rpt = [SELECT Id, Status__c, ResolutionNotes__c FROM MissedPickupReport__c WHERE Id = :reportId LIMIT 1 FOR UPDATE];
        rpt.Status__c = status;
        if (!String.isBlank(resolutionNotes)) {
            rpt.ResolutionNotes__c = resolutionNotes;
        }
        update rpt;
    }

    @InvocableMethod(label='Assign Staff to Missed Pickup' description='Assigns a staff user based on neighborhood heuristic')
    public static List<AssignResponse> assignStaff(List<AssignRequest> requests) {
        List<AssignResponse> responses = new List<AssignResponse>();
        if (requests == null || requests.isEmpty()) return responses;
        Set<Id> reportIds = new Set<Id>();
        for (AssignRequest r : requests) if (r != null && r.missedPickupReportId != null) reportIds.add(r.missedPickupReportId);

        Map<Id, MissedPickupReport__c> reports = new Map<Id, MissedPickupReport__c>([
            SELECT Id, Citizen__c, Location__c, Status__c
            FROM MissedPickupReport__c WHERE Id IN :reportIds
        ]);

        // Heuristic: pick the first active user in the org with a role name containing 'Waste' or fallback to current user
        User assigned = [SELECT Id FROM User WHERE IsActive = true AND (UserRole.Name LIKE '%Waste%' OR Profile.Name LIKE '%Service%') ORDER BY LastLoginDate DESC NULLS LAST LIMIT 1];
        Id userId = assigned != null ? assigned.Id : UserInfo.getUserId();

        List<MissedPickupReport__c> toUpdate = new List<MissedPickupReport__c>();
        for (AssignRequest r : requests) {
            AssignResponse resp = new AssignResponse();
            MissedPickupReport__c m = reports.get(r.missedPickupReportId);
            if (m == null) {
                resp.message = 'Report not found';
                responses.add(resp);
                continue;
            }
            m.Status__c = 'InProgress';
            toUpdate.add(m);
            resp.assignedUserId = userId;
            resp.message = 'Assigned';
            responses.add(resp);
        }
        if (!toUpdate.isEmpty()) update toUpdate;
        return responses;
    }
}
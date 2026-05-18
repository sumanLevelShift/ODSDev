import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getReports from '@salesforce/apex/StaffDashboardController.getReports';
import optimize from '@salesforce/apex/StaffDashboardController.optimizeSample';
import assignReport from '@salesforce/apex/StaffDashboardController.assignReport';

export default class StaffWasteManagement extends LightningElement {
    reportColumns = [
        { label: 'Report #', fieldName: 'Name' },
        { label: 'Status', fieldName: 'Status__c' },
        { label: 'Reason', fieldName: 'Reason__c' },
        { label: 'Report Date', fieldName: 'ReportDate__c', type: 'date' },
        { type: 'action', typeAttributes: { rowActions: [
            { label: 'Assign to me', name: 'assign' },
            { label: 'Mark Resolved', name: 'resolve' }
        ]}}
    ];

    @wire(getReports)
    reports;

    refresh(){
        return refreshApex(this.reports);
    }

    async handleReportAction(event){
        const action = event.detail.action.name;
        const row = event.detail.row;
        if(action==='assign'){
            await assignReport({ reportId: row.Id });
            this.refresh();
        } else if(action==='resolve'){
            await assignReport({ reportId: row.Id, status: 'Resolved' });
            this.refresh();
        }
    }

    async optimize(){
        await optimize();
    }
}
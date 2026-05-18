import { LightningElement, wire, track } from 'lwc';
import getMySchedules from '@salesforce/apex/CitizenScheduleController.getMySchedules';

export default class CitizenWasteSchedule extends LightningElement {
    @track selectedScheduleId;

    columns = [
        { label: 'Date', fieldName: 'ScheduleDate__c', type: 'date' },
        { label: 'Type', fieldName: 'CollectionType__c' },
        { label: 'Frequency', fieldName: 'Frequency__c' },
        { label: 'Window', fieldName: 'ServiceWindow__c' },
        { label: 'Status', fieldName: 'Status__c' },
        { label: 'Route', fieldName: 'Route__c' },
        { type: 'action', typeAttributes: { rowActions: [ { label: 'Report Missed Pickup', name: 'report' } ] } }
    ];

    @wire(getMySchedules)
    schedules;

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'report') {
            this.selectedScheduleId = row.Id;
        }
    }

    handleReportSuccess() {
        this.selectedScheduleId = null;
    }
}
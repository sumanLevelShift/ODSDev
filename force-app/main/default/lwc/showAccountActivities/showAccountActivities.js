import { LightningElement,api,wire,track} from 'lwc';
import getActivities from '@salesforce/apex/ActivitiesForCSM.getActivities';
const dataTablecolumns = [        
    { label: 'Subject', fieldName: 'Subject', type: 'text', sortable: true },
    { label: 'Owner', fieldName: 'WhoIDName', type: 'text', sortable: true },
    { label: 'Assigned To', fieldName: 'AssignedToName', type: 'text', sortable: true },
    { label: 'Related To', fieldName: 'RelatedToName', type: 'text', sortable: true },
    { label: 'Type', fieldName: 'ActivityType', type: 'text', sortable: true },
    { label: 'StartDate', fieldName: 'StartDateTime', sortable: true},
    { label: 'EndDate', fieldName: 'EndDateTime', sortable: true},
    { label: 'Comments', fieldName: 'ActivityDescription', type: 'text', sortable: true},];

export default class ShowAccountActivities extends LightningElement {    
    @api recordId;
    @track activityRecords;
    @track columns = dataTablecolumns;
    @track sortBy;
    @track sortDirection;
    @track error;    
    
     @wire(getActivities,{accountId: '$recordId'}) accountActivityList(result) {
        if(result.data){        
          this.activityRecords=result.data;
          this.error = undefined;
        }
        else if(result.error){          
          this.error = result.error;
          this.data = undefined;
        }
      }

    updateColumnSorting(event){       
        //assign the values
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        //call the custom sort method.
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
      }
     
    sortData(fieldName, sortDirection){
        var data = Object.assign([], this.activityRecords);
        //function to return the value stored in the field
        var key =(a) => a[fieldName]; 
        //cheking reverse direction
        var reverse = sortDirection === 'asc' ? 1: -1;
        //sorting data 
        data.sort((a,b) => {
            let valueA = key(a) ? key(a).toLowerCase() : '';
            let valueB = key(b) ? key(b).toLowerCase() : '';
            //sorting values based on direction
            return reverse * ((valueA > valueB) - (valueB > valueA));
        });
        //set sorted data to data table attribute
        this.activityRecords = data;
    }    
}
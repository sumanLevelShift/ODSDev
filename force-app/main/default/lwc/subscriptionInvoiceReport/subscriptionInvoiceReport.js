import { LightningElement, wire, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import getworkorderdetails from '@salesforce/apex/ODSSubscriptionInvoiceReport.getworkorderdetails';
import getTableLabels from '@salesforce/apex/ODSSubscriptionInvoiceReport.getTableLabels';
import SubscriptionInvoiceReportCSS from '@salesforce/resourceUrl/SubscriptionInvoiceReportCSS';
import ODS_Statussign from '@salesforce/resourceUrl/ODS_Statussign';

export default class SubscriptionInvoiceReport extends LightningElement {
  @track Workorderdetails = [];
  @track tableLabelMonths = [];
  @track selectedYear = '';
  @track yearOptions = [];


  //pagecontrolling
  @track recordEnd = 0;
  @track recordStart = 0;
  @track pageNumber = 1;
  @track totalRecords = 0;
  @track totalPages = 0;
  @track loaderSpinner = false;
  @track error = null;
  @track pageSize = '50';
  @track isPrev = true;
  @track isNext = true;
  @track spinner = ODS_Statussign;
  isAsc = false;
  isDsc = false;
  sortedDirection = 'asc';

  connectedCallback() {
    var thisYear = (new Date()).getFullYear();
    const currentMonth = new Date().getMonth();
    thisYear = currentMonth >= 3 ? thisYear + 1 : thisYear;//js April month index= 3;
    const yearArray = [0, 1].map((count) => `${thisYear - count - 1}-${(thisYear - count).toString().slice(-4)}`);
    yearArray.reverse();
    this.yearOptions = yearArray.map(elem => (
      {
        label: elem,
        value: elem
      }
    ));
    this.selectedYear = yearArray[1];
    if (this.selectedYear) {
      this.queryData();
    }
    loadStyle(this, SubscriptionInvoiceReportCSS)
      .then(() => console.log('css'))
      .catch(error => console.log(error));
  }
  get opt() {
    return [
      { label: '50', value: '50' },
      { label: '100', value: '100' },

    ];

  }
  handleChangeentries(event) {
    this.template.querySelector('.spinnerDiv').style.display = "block";
    this.pageSize = event.target.value;
    this.pageNumber = 1;
    this.isNext = true;
    this.queryData();

  }
  handleTypeChange(event) {
    this.template.querySelector('.spinnerDiv').style.display = "block";
    this.selectedYear = event.target.value;
    this.pageNumber = 1;
    this.isNext = true;
    this.queryData();

  }


  queryData() {
    getTableLabels({ selectedYear: this.selectedYear })
      .then(data => {
        this.tableLabelMonths = data.labels;

        getworkorderdetails({ selectedYear: this.selectedYear, pageSize: this.pageSize, pageNumber: this.pageNumber })
          .then(data => {
            this.Workorderdetails = data;
            var resultData = JSON.parse(data);
            this.recordEnd = resultData.recordEnd;
            this.totalRecords = resultData.totalRecords;
            this.recordStart = resultData.recordStart;
            this.Workorderdetails = resultData.WorkOrderDetails;
            this.pageNumber = resultData.pageNumber;
            this.totalPages = Math.ceil(resultData.totalRecords / this.pageSize);
            this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
            this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);

            this.template.querySelector('.spinnerDiv').style.display = "none";

          })
          .catch(error => {
            console.log(error);
            this.error = error;
            this.template.querySelector('.spinnerDiv').style.display = "none";

            alert(error.message)
          });
      }).catch(error => {
        console.log(error);
        this.error = error;
        this.template.querySelector('.spinnerDiv').style.display = "none";

        alert(error)
      });
  }
  handlePageNextAction() {
    this.template.querySelector('.spinnerDiv').style.display = "block";
    this.pageNumber = this.pageNumber + 1;
    this.queryData();


  }

  handlePagePrevAction() {
    this.template.querySelector('.spinnerDiv').style.display = "block";
    this.pageNumber = this.pageNumber - 1;
    this.queryData();

  }
  get isDisplayNoRecords() {
    var isDisplay = true;
    if (this.Workorderdetails) {
      if (this.Workorderdetails.length == 0) {
        isDisplay = true;
      } else {
        isDisplay = false;
      }
    }
    return isDisplay;
  }
  sortName(event) {
    this.template.querySelector('.spinnerDiv').style.display = "block";

    this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
    if (this.sortedDirection === 'asc') {
      this.isAsc = true;
      this.isDsc = false;
    }
    else {
      this.isAsc = false;
      this.isDsc = true;
    }
    let isReverse = this.sortedDirection === 'asc' ? 1 : -1;
    this.Workorderdetails = JSON.parse(JSON.stringify(this.Workorderdetails)).sort((a, b) => {
      a = a['CustomerName'] ? a['CustomerName'].toLowerCase() : '';
      b = b['CustomerName'] ? b['CustomerName'].toLowerCase() : '';

      return a > b ? 1 * isReverse : -1 * isReverse;

    });;
    this.template.querySelector('.spinnerDiv').style.display = "none";

  }

  exportExcel() {
    this.template.querySelector('.spinnerDiv').style.display = "block";
    window.location.href = "/apex/SubscriptionInvoiceExcel?selectedYear=" + this.selectedYear ;

    this.template.querySelector('.spinnerDiv').style.display = "none";

}
  
}
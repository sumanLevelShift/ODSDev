import { LightningElement, track, api, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import weeklyConsumption from '@salesforce/apex/ODS_DashboardController.weeklyConsumption';
import chartJSV3 from '@salesforce/resourceUrl/ChartJs';
import jquery from '@salesforce/resourceUrl/jquery';


export default class ODSDashboardConsumption extends LightningElement {

  @api accId;
  @api serId;
  @track dataSet;


  chartYData = [];
  chartLabelX = [];
  chartLabelY = [];
  abcDate = [];
  @track chartBackgroundColor = [];

  connectedCallback() {

    this.getChart(this.accId, this.serId);

  }
  dateFormat(inputDate, format) {
    //parse the input date
    const date = new Date(inputDate);

    //extract the parts of the date
    const day = date.getDate();
    const month = date.getMonth() + 1;
    const year = date.getFullYear();

    //replace the month
    format = format.replace("MM", month.toString().padStart(2, "0"));

    //replace the year
    if (format.indexOf("yyyy") > -1) {
      format = format.replace("yyyy", year.toString());
    } else if (format.indexOf("yy") > -1) {
      format = format.replace("yy", year.toString().substr(2, 2));
    }

    //replace the day
    format = format.replace("dd", day.toString().padStart(2, "0"));

    return format;
  }
  getChart(accid, serid) {
    weeklyConsumption({ accountId: accid, serviceId: serid })
      .then(data => {
        this.dataSet = data;
       // console.log('Weekly Consumption Data : ' + JSON.stringify(this.dataSet));
        this.chartBackgroundColor = [];

        this.dataSet.forEach(opp => {
          this.chartYData.push(opp.Total_Hours__c);
         // console.log('Week_Start_Date__c : '+opp.Week_Start_Date__c);
          this.chartLabelX.push(this.dateFormat(opp.Week_Start_Date__c, 'MM/dd/yyyy'));
          let r = Math.floor(Math.random() * 255);
          let g = Math.floor(Math.random() * 255);
          let b = Math.floor(Math.random() * 255);
          this.chartBackgroundColor.push("rgb(" + r + "," + g + "," + b + ")");

        })
       // console.log('chartYData : ' + JSON.stringify(this.chartYData));
        //console.log('chartXData : ' + JSON.stringify(this.chartLabelX));

        this.Initializechartjs();
        this.error = undefined;

      })
      .catch(error => {
       // console.log(error);
        this.error = error;
      });
  }

  jqueryPackage = jquery;

  @api isChartJsInitialized = false;

  renderedCallback() {

    Promise.all([
      loadScript(this, this.jqueryPackage),
      loadScript(this, chartJSV3 + '/chart.esm.js'),
      loadScript(this, chartJSV3 + '/chart.js'),
      loadScript(this, chartJSV3 + '/helpers.esm.js')

    ])
      .then(() => {
        this.isChartJsInitialized = true;
        if (this.isChartJsInitialized) {
          this.Initializechartjs();
        }

      //  console.log('done.');
      })
      .catch(error => {
      //  console.log(error)

      });
  }

  @track linechart;
  Initializechartjs() {
   // console.log("loaded");

    var ctx = this.template.querySelector(".line-chart").getContext('2d');
    if (this.linechart) {
      this.linechart.destroy();
    }
 const scale = window.devicePixelRatio; // Change to 1 on retina screens to see blurry canvas.
//this.template.querySelector(".doughnut-chart").width = Math.floor(200 * scale);
//this.template.querySelector(".doughnut-chart").height = Math.floor(200 * scale);

    this.linechart = new window.Chart(ctx, {
      type: 'line',

      data: {
        labels: this.chartLabelX,
        datasets: [{

          data: this.chartYData,
          fill: true,
          backgroundColor: [

            "#ADD8E6", "#ADD8E6", "#ADD8E6", "#ADD8E6", "#ADD8E6", "#ADD8E6", "#ADD8E6", "#ADD8E6", "#ADD8E6", "#ADD8E6", "#ADD8E6", "#ADD8E6", "#ADD8E6", "#ADD8E6", "#ADD8E6"

          ],
          borderColor: [

            "#0074D9", "#0074D9", "#0074D9", "#0074D9", "#0074D9", "#0074D9", "#0074D9", "#0074D9", "#0074D9", "#0074D9", "#0074D9", "#0074D9", "#0074D9", "#0074D9", "#0074D9"

          ],
          borderWidth: 1

        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        devicePixelRatio: 1.5,
        layout: {
          padding: {
            bottom: 30,
            left: 30
          }
        },
        scales: {
          xAxes: {
            display: true,
            offset: true,
            ticks: {
              major: {
                fontStyle: 'bold',
                fontColor: '#FF0000'
              }
            },
            title: {
              display: true,
              text: 'Week Start Date',

            }
          }
          ,
          yAxes: {
            title: {
              display: true,
              text: 'Sum of Total Hours'
            }
          }
        },
        plugins: {
          legend: {
            display: false
          }

        }
      }
    });

  }
}
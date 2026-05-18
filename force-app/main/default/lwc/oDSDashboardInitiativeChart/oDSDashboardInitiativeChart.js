import { LightningElement, track, api, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import initiativeByStatus from '@salesforce/apex/ODS_DashboardController.initiativeByStatus';
import chartJSV3 from '@salesforce/resourceUrl/ChartJs';
import jquery from '@salesforce/resourceUrl/jquery';


export default class ODSDashboardInitiativeChart extends LightningElement {

    @api accId;
    @api serId;
    @track dataSet;
    @track displayInitiativeChart = true;

    chartLabel = [];
    chartData = [];
    totalRecord = 0;


    @track chartBackgroundColor = [];
    connectedCallback() {

        this.getChart(this.accId, this.serId);

    }


    getChart(accid, serid) {
      //  alert(accid+serid);
        initiativeByStatus({ accountId: accid, serviceId: serid })
            .then(data => {
                if(data.length===0){
                    this.displayInitiativeChart = false;
                }
                else{
                    this.dataSet = data;
                    //console.log('Initiative Data : ' + JSON.stringify(this.dataSet));
                    this.chartBackgroundColor = [];
                    this.dataSet.forEach(opp => {
                        this.chartData.push(opp.expr0);
                        this.chartLabel.push(opp.Status__c);
                        this.totalRecord += opp.expr0;
                        let r = Math.floor(Math.random() * 255);
                        let g = Math.floor(Math.random() * 255);
                        let b = Math.floor(Math.random() * 255);
                        this.chartBackgroundColor.push("rgb(" + r + "," + g + "," + b + ")");
                    })
    
    
    
                    //console.log('chartData : ' + JSON.stringify(this.chartData));
                    //console.log('chartLabel : ' + JSON.stringify(this.chartLabel));
    
                    //console.log('TotalRecord : ' + this.totalRecord);
                    this.Initializechartjs();
                    this.error = undefined;
    
                }
               
            })
            .catch(error => {
                //console.log(error);
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
            loadScript(this, chartJSV3 + '/helpers.esm.js'),
            loadScript(this, chartJSV3 + '/chartjs-plugin-labels.js')

        ])
            .then(() => {
                this.isChartJsInitialized = true;
                if (this.isChartJsInitialized) {
                    this.Initializechartjs();
                }

                //console.log('done.');
            })
            .catch(error => {
                //console.log(error)

            });
    }

    @track donutchart;
    Initializechartjs() {
        //console.log("loaded");

        var ctx = this.template.querySelector(".doughnut-chart").getContext('2d');
       
        if (this.donutchart) {
            this.donutchart.destroy();
        }


        this.donutchart = new window.Chart(ctx, {
            type: 'doughnut',

            data: {
                labels: this.chartLabel,
                datasets: [{
                    data: this.chartData,
                    backgroundColor: [
                        "#00A1E0","#E69F00","#3573CE","#76DED9","#E2CE7D","#08A69E","#39CCCC","#F5DEB3", "#2ECC40","#DB7093", "#B10DC9", "#F5DEB3", "#39CCCC", "#01FF70", "#85144b", "#F012BE", "#FF7F50", "#1C171B"
                    ],
                    hoverOffset: 7
                }]
            },
            showDatapoints: true,
            borderWidth: 1,
            options: {
                radius:105,
                responsive: true,
                maintainAspectRatio: false,
                aspectRatio:1,
                animation: {
                    animateScale: true,
                    animateRotate: true,
                    onProgress: function () {
                        // console.error('this', this);
                        const ctx = this.ctx;
                        // ctx.font = Chart.helpers.fontString(Chart.defaults.global.defaultFontFamily, 'normal', Chart.defaults.global.defaultFontFamily);
                        ctx.textAlign = 'center';
                        ctx.textBaseline = 'bottom';

                        let dataSum = 0;
                        if (this._sortedMetasets.length > 0 && this._sortedMetasets[0].data.length > 0) {
                            const dataset = this._sortedMetasets[0].data[0].$context.dataset;
                            dataSum = dataset.data.reduce((p, c) => p + c, 0);
                        }
                        if (dataSum <= 0) return;

                        this._sortedMetasets.forEach(meta => {
                            meta.data.forEach(metaData => {
                                const dataset = metaData.$context.dataset;
                                const datasetIndex = metaData.$context.dataIndex;
                                const value = dataset.data[datasetIndex];
                                if ((Math.round(value / dataSum * 1000) / 10) > 9) {
                                    const percent = '(' + (Math.round(value / dataSum * 1000) / 10) + '%)';
                                    const mid_radius = metaData.innerRadius + (metaData.outerRadius - metaData.innerRadius) * 0.5;
                                    const start_angle = metaData.startAngle;
                                    const end_angle = metaData.endAngle;
                                    if (start_angle === end_angle) return; // hidden
                                    const mid_angle = start_angle + (end_angle - start_angle) / 2;
                                    const x = mid_radius * Math.cos(mid_angle);
                                    const y = mid_radius * Math.sin(mid_angle);
                                    
                                    ctx.fillStyle = '#000';
                                    ctx.textAlign = "center";
                                    ctx.font = "bold 8.5px 'Verdana'";
                                    // ctx.font = 1.2 + "em sans-serif";
                                    ctx.fillText(value, metaData.x + x, metaData.y + y);
                                    ctx.fillText(percent, metaData.x + x, metaData.y + y + 10);
                                }
                            });
                        });
                    }

                },
                pieceLabel: {
                    mode: 'percentage',
                    fontColor: '#000'
                },
                plugins: {

                    cutoutPercentage: 50,
                    legend: {
                        display: true,
                        align: 'start',
                        position: 'right',
                        title: {
                            // text: 'Status',
                            display: false

                        }
                    },

                    tooltip: {
                        enabled: true,
                        callbacks: {
                            footer: (ttItem) => {
                                let sum = 0;
                                let dataArr = ttItem[0].dataset.data;
                                dataArr.map(data => {
                                    sum += Number(data);
                                });

                                let percentage = (ttItem[0].parsed * 100 / sum).toFixed(2) + '%';
                                return `Percentage of data: ${percentage} of ${sum}`;
                            }
                        }
                    }

                }



            },
            plugins: [{
                id: 'customPlugin',
                afterDatasetsDraw: (chart, args, options) => {
                    const {ctx, chartArea:{left,right,top,bottom,width,height}}=chart;
                    ctx.save();
                    
                    ctx.textBaseline = "middle";
                    var text = this.totalRecord;
                  
                        ctx.font = "bold 20px 'Open Sans',sans-serif";
                        ctx.textAlign = "center";
                        ctx.fillText(text, width/2, height/2);
                        ctx.restore();
                    

                }
            }]

        });


    }

}
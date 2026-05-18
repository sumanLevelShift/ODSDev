import getRevenueCalcForSubsChart from '@salesforce/apex/ODS_PartnerApexController.getRevenueCalcForSubsChart';
import getRevenueCalcForTnMChart from '@salesforce/apex/ODS_PartnerApexController.getRevenueCalcForTnMChart';
import LoadCostSavingpanel from '@salesforce/apex/ODS_PartnerApexController.LoadCostSavingpanel';
import updateSessionData from '@salesforce/apex/ODS_PartnerApexController.updateSessionData';
import LM_Partner from '@salesforce/resourceUrl/LM_Partner';
//import myChannel from "@salesforce/messageChannel/PassRecordId__c";
import ODS_Assets from '@salesforce/resourceUrl/ODS_Assets';
import { APPLICATION_SCOPE, createMessageContext, subscribe } from 'lightning/messageService';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { api, LightningElement, track, wire } from 'lwc';

export default class ODSPartnerLWC extends LightningElement {


    context = createMessageContext();

    @track name;
    OdsThisMonthCost;
    PartnerThisMnthCost;
    OdsYTDCost;
    PartnerYTDCost;
    OdsLifeTimeCost;
    partnerLifeTimeCost;
    CurrentMonthDate;
    ytdDate;
    @track scriptsLoaded = false;
    slctdYear;
    valueMonth;
    slctdRevType;

    @api acoountIDFromParent = '';
    @api serviceIDFromParent = '';

    connectedCallback() {
        loadStyle(this, LM_Partner)
            .then(() => console.log('css'))
            .catch(error => console.log(error));

        this.getAccid(this.acoountIDFromParent, this.serviceIDFromParent);
        this.timer = setInterval(() => {
            var Month = this.template.querySelector('.ddlstUSMonths');
            Month.dispatchEvent(new Event('change'));
        }, 2500);
        this.updateSessionsFunction();
        
    }
    updateSessionsFunction() {
        updateSessionData({ accountId: this.acoountIDFromParent, serviceId: this.serviceIDFromParent })
            .then(data => {
                //console.log('Updated sessions.');
            })
            .catch(error => {
              //  console.log('update--' + error);
            });
    }
    timer;

    //Loaded all the static resources
    renderedCallback() {
        if (!this.scriptsLoaded) {
            Promise.all([
                loadScript(this, ODS_Assets + '/js/amcharts.js'),
            ]).then(() => {
                //console.log('AM Charts ....done.');
                Promise.all([
                    loadScript(this, ODS_Assets + '/js/serial.js'),
                    loadScript(this, ODS_Assets + '/js/light.js'),
                    //loadScript(this, AmChartLwc + '/gauge.js'),
                    loadStyle(this, ODS_Assets + '/css/export.css'),
                    //loadScript(this, AmChartLwc + '/jquery-1.4.4.min.js'),
                    //loadScript(this, ODS_Assets + '/js/jquery-1.4.4.min.js')



                ]).then(() => {
                   // console.log('done.');
                    this.scriptsLoaded = true;


                })
                    .catch(error => {
                        //this.error = error;
                       // console.log(' Error Occured-- ', +error);
                    });
            })
                .catch(error => {
                    this.error = error;
                   // console.log(' Error Occured-- ', +error);
                });

        }


    }

    getAccid(accid, serid) {

        LoadCostSavingpanel({ AccountId: accid, ServiceId: serid })
            .then(data => {
                this.OdsThisMonthCost = data.odsThisMonth;
                this.PartnerThisMnthCost = data.partnerThisMnth;
                this.OdsYTDCost = data.odsYTD;
                this.PartnerYTDCost = data.partnerYTD;
                this.OdsLifeTimeCost = data.odsLifeTime;
                this.partnerLifeTimeCost = data.partnerLifeTime;
                this.CurrentMonthDate = data.currMonthDt;
                this.ytdDate = data.ytdDt;
                this.error = undefined;
            })
            .catch(error => {
                //console.log(error);
                this.error = error;
            });

        getRevenueCalcForSubsChart({ slctdAccId: this.acoountIDFromParent, slctdSrvceId: this.serviceIDFromParent })
            .then(result => {


                this.subscArray = JSON.parse(result);
                //console.log('subscArray : ' + JSON.stringify(result));
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;

            })

        getRevenueCalcForTnMChart({ slctdAccId: this.acoountIDFromParent, slctdSrvceId: this.serviceIDFromParent })
            .then(result => {


                this.timeshtArray = JSON.parse(result);
                //console.log('TimeshtArray : ' + JSON.stringify(result));
                this.error = undefined;

            })
            .catch(error => {
                this.error = error;

            })

    }

    //Chart functions


    timeshtArray = [];
    subscArray = [];


    get yearOptions() {

        var yearLst = [];
        var startYear = new Date().getFullYear();
        var endYear = new Date().getFullYear() - 3;
        for (var i = startYear; i >= endYear; i--) {
            yearLst.push({ label: i, value: i.toString() },);
        }
        this.slctdYear = startYear.toString();
        return yearLst;

    }

    get monthOptions() {
        const monthNames = ["0", "1", "2", "3", "4", "5", "6",
            "7", "8", "9", "10", "11", "12"];
        const d = new Date();
        this.valueMonth = monthNames[0];




        return [
            { label: 'ALL', value: '0' },
            { label: 'JANUARY', value: '1' },
            { label: 'FEBRUARY', value: '2' },
            { label: 'MARCH', value: '3' },
            { label: 'APRIL', value: '4' },
            { label: 'MAY', value: '5' },
            { label: 'JUNE', value: '6' },
            { label: 'JULY', value: '7' },
            { label: 'AUGUST', value: '8' },
            { label: 'SEPTEMBER', value: '9' },
            { label: 'OCTOBER', value: '10' },
            { label: 'NOVEMBER', value: '11' },
            { label: 'DECEMBER', value: '12' }
        ];
    }

    get revType() {
        this.slctdRevType = 'subscription';
        return [
            { label: 'SUBSCRIPTION', value: 'subscription' },
            { label: 'INVOICE', value: 'timeandmoney' }
        ];

    }

    //Function to get the month name based on the month number
    formatMonth(monthNumber) {

        var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return months[monthNumber - 1];
    }

    // function to get all the month values
    getMonthInYear() {
        var Months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
        return Months;
    }

    //Function to get the number of days in a month
    getDaysInMonth(month, year) {
        // Since no month has fewer than 28 days
        var date = new Date(year, month, 1);
        var days = [];
        while (date.getMonth() === month) {
            days.push(new Date(date));
            date.setDate(date.getDate() + 1);
        }
        return days; //returning null
    }

    //Function to get hours worked based on the month and year selected.
    GetPartnerRevInMonthJson(value, yearVal, revTyp) {

        var reslt = [];
        if (revTyp == "tnm") {
            reslt = this.timeshtArray.filter((element) =>
                (((new Date(element.chartDate).getMonth() + 1) == value) && ((new Date(element.chartDate).getFullYear()) == yearVal))
            );


        } else {
            reslt = this.subscArray.filter((element) =>
                (((new Date(element.chartDate).getMonth() + 1) == value) && ((new Date(element.chartDate).getFullYear()) == yearVal))
            );

        }
       // console.log('Result GetPartnerRevInMonthJson : ' + reslt);
        var finalRevenue = 0;
        if (reslt != '') {
            for (var i = 0; i < reslt.length; i++) {

                finalRevenue += reslt[i].partnerRevenue;
            }
        }

        return (finalRevenue);
    }

    //Function to get selected date Partner revenue
    GetPartRevInJson(value, revnType) {
        var reslt = [];


        if (revnType == "tnm") {
            reslt = this.timeshtArray.filter((element) => element.chartDate == value);

        } else {
            reslt = this.subscArray.filter((element) => element.chartDate == value);

        }
        var finlRevenue = 0;
       // console.log('In GetPartRevInJson reslt : ' + reslt);
        if (reslt != '') {
            finlRevenue = reslt[0].partnerRevenue;
        }

       // console.log('In GetPartRevInJson : ' + finlRevenue);
        return (finlRevenue);
    }

    //Function to format date in MM/dd/YYYY format
    formatDate(inputDate) {

        var d = new Date(inputDate);
        var month = '' + (d.getMonth() + 1);
        var day = '' + d.getDate();
        var year = d.getFullYear();
        return [month, day, year].join('/');
    }

    //Reload chart data on drop down value changes
    eventHandle(event) {
        clearInterval(this.timer);


        let t_this = this;

        getRevenueCalcForSubsChart({ slctdAccId: this.acoountIDFromParent, slctdSrvceId: this.serviceIDFromParent })
            .then(result => {


                this.subscArray = JSON.parse(result);
               // console.log('subscArray : ' + JSON.stringify(result));
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;

            })

        getRevenueCalcForTnMChart({ slctdAccId: this.acoountIDFromParent, slctdSrvceId: this.serviceIDFromParent })
            .then(result => {

                this.timeshtArray = JSON.parse(result);
               // console.log('TimeshtArray : ' + JSON.stringify(result));
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;

            })



        var chartData = [];
        var Year = this.template.querySelector('.ddlstUSYears').value;
       // console.log('Year :' + Year);
        var Month = this.template.querySelector('.ddlstUSMonths').value;
        //console.log('Month :' + Month);
        var selectedrevType = this.template.querySelector('.ddlstUSRevType').value;
        //console.log('selectedrevType :' + selectedrevType);

        //console.log('subscArray :' + JSON.stringify(this.subscArray));
       // console.log('timeshtArray :' + JSON.stringify(this.timeshtArray));

        var now = new Date(); // To get server date
        var currentChartMonth = now.getMonth() + 1; //months from 1-12
        var currentChartYear = now.getFullYear();


        if (Month > currentChartMonth && Year == currentChartYear) {
            alert('Sorry, you cannot select upcoming months.');
            this.template.querySelector('.ddlstUSYears').value(currentChartYear);
            this.template.querySelector('.ddlstUSMonths').value(currentChartMonth);

            SelectedMonthDates = this.getDaysInMonth(currentChartMonth - 1, currentChartYear);
        }

        //Checks if the selected month value is 'ALL'    
        if (Month == 0) {
            var SelectedMonthInYear = this.getMonthInYear();
            var l = SelectedMonthInYear.length;
            for (var i = 0; i < l; i++) {
                //Loops through all the months and gets the Partner revenue of each month.
                var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                var formatedMonth1 = months[SelectedMonthInYear[i] - 1];
                var partnerRev = [];
                if (selectedrevType == "subscription") {
                    partnerRev = t_this.GetPartnerRevInMonthJson(SelectedMonthInYear[i], Year, "subs");
                } else {
                    partnerRev = t_this.GetPartnerRevInMonthJson(SelectedMonthInYear[i], Year, "tnm");
                }

                //Builds an array of each month and count of hours worked for related month
                chartData.push({
                    date: formatedMonth1,
                    revenue: partnerRev
                });
            }
        }
        else {
            //Displays all the dates in a selected month and the related Partner revenue
            var SelectedMonthDates = this.getDaysInMonth(Month - 1, Year);
            var l = SelectedMonthDates.length;
            //Loops through each date in a month
            for (var i = 0; i < l; i++) {


                var d = new Date(SelectedMonthDates[i]);
                var month = '' + (d.getMonth() + 1);
                var day = '' + d.getDate();
                var year = d.getFullYear();
                var formatedDate1 = [month, day, year].join('/');
                var partnerRevn = [];
                if (selectedrevType == "subscription") {
                    partnerRevn = t_this.GetPartRevInJson(formatedDate1, "subs");
                } else {
                    partnerRevn = t_this.GetPartRevInJson(formatedDate1, "tnm");
                }

                var newDate = new Date(formatedDate1);

                //Builds the array of each date and partner revenue in each date
                chartData.push({
                    date: newDate,
                    revenue: partnerRevn
                });
            }
        }
       // console.log('chart---' + JSON.stringify(chartData));
       // console.log('Account id : ' + this.acoountIDFromParent);
       // console.log('Service id : ' + this.serviceIDFromParent);
        try {

            const canvas = document.createElement('canvas');
            this.template.querySelector('.chartdivs').appendChild(canvas);
            const ctx = canvas.getContext('2d');


            //Binds the chart with data from built array
            var chart = AmCharts.makeChart(this.template.querySelector('.chartdivs'), {
                "theme": "light",
                "type": "serial",
                "marginRight": 80,
                "autoMarginOffset": 20,
                "marginTop": 20,
                "dataProvider": chartData,
                "valueAxes": [{
                    "id": "v1",
                    "axisAlpha": 0.1
                }],
                "graphs": [{

                    "balloonText": "[[category]]<br><b>Revenue: [[value]]</b>",
                    "bullet": "round",
                    "bulletBorderAlpha": 1,
                    "bulletBorderColor": "#FFFFFF",
                    "hideBulletsCount": 50,
                    "lineThickness": 2,
                    "lineColor": "#0083c0",
                    "negativeLineColor": "#0083c0",
                    "valueField": "revenue"
                }],
                "chartScrollbar": {
                    "scrollbarHeight": 5,
                    "selectedBackgroundAlpha": 0.1,
                    "selectedBackgroundColor": "#888888",

                    "color": "#AAAAAA"
                },
                "chartCursor": {
                    "valueLineEnabled": true,
                    "valueLineBalloonEnabled": true
                },
                "categoryField": "date",
                "categoryAxis": {
                    "parseDates": true,
                    "axisAlpha": 0,
                },
                "export": {
                    "enabled": true
                }
            });
            chart.dataProvider = chartData;
            //If month value selected is 'ALL', then the chart property of parse date is set to false as date is not populated on the x axis.
            if (Month == 0) {
                chart.categoryAxis.parseDates = false;
            }
            chart.validateData();

        }
        catch (err) {
            //console.log('Error---' + err.message);
        }
    }
}
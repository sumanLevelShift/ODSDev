import { LightningElement, track, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import findFeaturesProduct from '@salesforce/apex/SalesforceProduct.findFeaturesProduct';
import createSalesforceClientUsage from '@salesforce/apex/SalesforceProduct.createSalesforceClientUsage';
import updateClientFeatureUsage from '@salesforce/apex/SalesforceProduct.updateClientFeatureUsage';
import getCloudName from '@salesforce/apex/SalesforceProduct.getCloudName';
import getCloudNameFromSP from '@salesforce/apex/SalesforceProduct.getCloudNameFromSP';

import getProductSubFeatureDetails from '@salesforce/apex/ProdSubfeatureClientUsageController.getProductSubFeatureDetails';
import checkConnectedApp from '@salesforce/apex/ProdSubfeatureClientUsageController.checkConnectedApp';


import heatMapInstallUrl from '@salesforce/label/c.Heatmap_Install_URL';
import sandBoxHeatMapInstallUrl from '@salesforce/label/c.Heatmap_Sandbox_Install_URL';
import AboutHeatMap from '@salesforce/label/c.AboutHeatMap';

import chartJSV3 from '@salesforce/resourceUrl/ChartJs';
import QuestionMarkIcon from '@salesforce/resourceUrl/QuestionMarkIcon';
import jquery from '@salesforce/resourceUrl/jquery';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class SalesforceProductOverallUsageChart extends LightningElement {
    @track labelColorCloud = [];
    @track labelColorFeature = [];
    @track labelColorSubFeature = [];
    hmInstallURL = heatMapInstallUrl;
    sandboxHMInstallURL = sandBoxHeatMapInstallUrl;
    handleHeatmapButton = true;
    @track questionMarkIcon = QuestionMarkIcon;
    @track error;
    chart;
    @api initChart = false;
    @api chartBackgroundColor = [];
    @api salesforceProduct = [];
    @api accountId;
    @api clientRecord = [];
    @api
    handleRun(accId, overallUsage, featureUsage) {
        this.accountId = accId;
        this.salesforceProduct = overallUsage;
        this.clientRecord = featureUsage;
        this.chartLabel = [];
        this.chartData = [];
        this.template.querySelector('.alert').style.display = "none";


        checkConnectedApp({ accountId: this.accountId })
            .then(result => {
                if (result == true) {
                    this.handleHeatmapButton = false;
                }
            })
            .catch(error => {
                console.log(error)
            });

        let changeValue = JSON.stringify(this.clientRecord);
        if (changeValue === undefined || this.clientRecord.length === 0) {
            if (this.salesforceProduct != undefined) {

                getCloudNameFromSP({ featureId: this.salesforceProduct[0].Salesforce_Product__c })
                    .then(result => {
                        this.childchartName = result
                    })
                    .catch(error => {
                        console.log(error)
                    });
            }
            createSalesforceClientUsage({ salesforceClientUsage: this.salesforceProduct, accountid: this.accountId })
                .then(result => {

                    for (let i = 0; i < result.length; i++) {
                        let r = Math.floor(Math.random() * 255);
                        let g = Math.floor(Math.random() * 255);
                        let b = Math.floor(Math.random() * 255);
                        this.chartBackgroundColor.push(result[i].color);
                        if (result[i].value == 0) {
                            this.labelColorCloud.push('#FF0000');
                        } else {
                            this.labelColorCloud.push('#000000');
                        }
                        this.chartLabel.push(result[i].label + ' (' + result[i].value + '%)');
                        this.chartData.push(result[i].value);
                    }
                    this.salesforceProduct = [];
                    this.template.querySelector('.msg').style.display = "none";
                    this.generateSteppedChart(this.chartLabel, this.chartData);
                    if (this.relatedchart != undefined) {
                        this.generateFeatureChart();
                    }
                })
                .catch(error => {
                    console.log(error)
                });
        } else {

            getCloudName({ featureId: this.clientRecord[0].Id })
                .then(result => {
                    this.childchartName = result
                })
                .catch(error => {
                    console.log(error)
                });
            updateClientFeatureUsage({ updateObjStr: changeValue, accountId: this.accountId })
                .then(result => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Records updated',
                            variant: 'success'
                        })
                    );

                    createSalesforceClientUsage({ salesforceClientUsage: this.salesforceProduct, accountid: this.accountId })
                        .then(result => {
                            this.chartLabel = [];
                            this.chartData = [];
                            this.chartBackgroundColor = [];
                            for (let i = 0; i < result.length; i++) {
                                let r = Math.floor(Math.random() * 255);
                                let g = Math.floor(Math.random() * 255);
                                let b = Math.floor(Math.random() * 255);
                                // this.chartBackgroundColor.push("rgb(" + r + "," + g + "," + b + ")");
                                this.chartBackgroundColor.push(result[i].color);
                                if (result[i].value == 0) {
                                    this.labelColorCloud.push('#FF0000');
                                } else {
                                    this.labelColorCloud.push('#000000');
                                }
                                this.chartLabel.push(result[i].label + ' (' + result[i].value + '%)');
                                this.chartData.push(result[i].value);
                            }
                            this.salesforceProduct = [];
                            this.template.querySelector('.msg').style.display = "none";
                            this.generateSteppedChart(this.chartLabel, this.chartData);
                            this.generateFeatureChart();
                        })
                        .catch(error => {
                            console.log(error)
                        });

                })
                .catch(error => {
                    console.log(error);
                });
        }

    }
    closeButton() {
        this.template.querySelector('.alert').style.display = "none";
    }

    jqueryPackage = jquery;
    renderedCallback() {
        Promise.all([
            loadScript(this, this.jqueryPackage),
            //loadScript(this, this.chartjs)
            loadScript(this, chartJSV3 + '/chart.esm.js'),
            loadScript(this, chartJSV3 + '/chart.js'),
            loadScript(this, chartJSV3 + '/helpers.esm.js'),

        ]).then(() => {
            console.log('done.')
        })
            .catch(error => {
                this.error = error;
                console.log(' Error Occured-- ', +error);
            });

    }

    errorCallback(error, stack) {
        this.error = error;
        console.log(' this.error ', this.error);
    }
    @track chartLabel = [];
    @track chartData = [];
    myChart;
    relatedchart;
    subFeatureChart;
    childchartName;
    cloudName;
    generateSteppedChart(a, b) {
        let chartDiv = this.template.querySelector('canvas.sales').getContext('2d');
        let labelName = [];
        let valuePer = [];
        let polar = [];
        let dataarea = [];
        let bgColor = [];
        let t_this = this;
        //child chart
        let realtedFeatures = function (label, account) {
            t_this.childchartName = label.substr(0, label.lastIndexOf(' ('));
            labelName = [];
            valuePer = [];
            polar = [];
            dataarea = [];
            bgColor = [];
            t_this.labelColorFeature = [];
            //alert(label.substr(0,label.lastIndexOf(':')));
            // alert(t_this.accountId)
            findFeaturesProduct({ feature: label.substr(0, label.lastIndexOf(' (')), accountId: t_this.accountId })
                .then(data => {
                    for (let i = 0; i < data.length; i++) {
                        let r = Math.floor(Math.random() * 255);
                        let g = Math.floor(Math.random() * 255);
                        let b = Math.floor(Math.random() * 255);
                        // bgColor.push("rgb(" + r + "," + g + "," + b + ")");
                        bgColor.push(data[i].Chart_Color_Code__c);
                        labelName.push(data[i].Salesforce_Product_Feature__r.Name + ' (' + data[i].Client_Usage_Percentage__c + '%)');
                        valuePer.push(data[i].Client_Usage_Percentage__c);
                        if (data[i].Client_Usage_Percentage__c == 0) {
                            t_this.labelColorFeature.push('#FF0000');
                        } else {
                            t_this.labelColorFeature.push('#000000');
                        }
                    }
                    polar = {
                        labels: labelName,
                        datasets: [{
                            label: 'Salesforce Affinity Feature For ' + t_this.childchartName,
                            backgroundColor: bgColor,
                            borderAlign: 'inner',
                            yAxisID: 'y-axis-1',
                            data: valuePer,
                            borderWidth: 1,
                            hoverBorderColor: "white",
                        }]
                    };
                    dataarea = {
                        type: 'polarArea',
                        data: polar,

                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            onClick: function (c, i) {
                                let e = i[0];
                                if (i.length !== 0) {
                                    let x_value = this.data.labels[e.index];
                                    t_this.productSubFeatureChart(x_value, this.accountId);
                                }
                            },
                            scale: {
                                min: 0,
                                max: 100,
                                beginAtZero: true,
                                maxTicksLimit: 20,
                            },
                            plugins: {
                                datalabels: {
                                    formatter: function (value, context) {
                                        return context.chart.data.labels[context.dataIndex];
                                    },
                                    anchor: 'start',
                                    align: 'end',
                                    offset: 8 // Gets updated
                                },
                                cutoutPercentage: 20,
                                title: {
                                    display: true,
                                    text: 'Salesforce Affinity Feature For ' + label.substr(0, label.lastIndexOf(' (')),
                                    fontSize: 16
                                },
                                chartArea: { backgroundColor: 'red' },
                                animation: {
                                    animateRotate: true,
                                    animateScale: true,
                                    duration: 4000,
                                    xAxis: true,
                                    yAxis: true,
                                },
                                legend: {
                                    display: true,
                                    position: 'bottom',
                                    labels: {
                                        generateLabels: function (chart) {
                                            const data = chart.data;
                                            if (data.labels.length && data.datasets.length) {
                                                const { labels: { pointStyle } } = chart.legend.options;
                                                return data.labels.map((label, i) => {
                                                    const meta = chart.getDatasetMeta(0);
                                                    const style = meta.controller.getStyle(i);
                                                    return {
                                                        text: label,
                                                        fillStyle: style.backgroundColor,
                                                        strokeStyle: style.borderColor,
                                                        lineWidth: style.borderWidth,
                                                        pointStyle: pointStyle,
                                                        hidden: !chart.getDataVisibility(i),
                                                        fontColor: t_this.labelColorFeature[i],
                                                        // Extra data used for toggling the correct item
                                                        index: i
                                                    };
                                                });
                                            }
                                            return [];
                                        }
                                    }
                                },
                                tooltip: {
                                    callbacks: {
                                        label: function (context) {
                                            let label = context.chart.data.labels[context.dataIndex];
                                            let s = label.substr(0, label.lastIndexOf(' ('));
                                            return s + ':' + context.dataset.data[context.dataIndex] + '%';
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if (t_this.relatedchart) {
                        t_this.relatedchart.destroy();
                    }
                    t_this.relatedchart = new window.Chart(chartDiv, dataarea);
                })
                .catch(error => {
                    this.error = error;
                    console.log(error);
                });

        }

        const selectedEvent = new CustomEvent("callaccount", {
            detail: this.updateSalesforceProduct
        });
        this.dispatchEvent(selectedEvent);

        let polarAreaData = {
            labels: this.chartLabel,
            datasets: [{
                label: 'Salesforce Affinity',
                backgroundColor: this.chartBackgroundColor,
                borderAlign: 'inner',
                yAxisID: 'y-axis-1',
                data: this.chartData,
                borderWidth: 1,
                hoverBorderColor: "white",
            }]
        };
        let dataSet = {

            type: 'polarArea',
            data: polarAreaData,

            options: {
                responsive: true,
                maintainAspectRatio: false,
                scale: {
                    min: 0,
                    max: 100,
                    display: false,
                    beginAtZero: true,
                    maxTicksLimit: 10,
                    reverse: false,
                },
                cutoutPercentage: 20,

                onClick: function (c, i) {
                    let e = i[0];
                    if (i.length !== 0) {
                        let x_value = this.data.labels[e.index];
                        t_this.cloudName = x_value;
                        realtedFeatures(x_value, this.accountId);
                        t_this.destroySubFeatureChart();
                    }
                },
                plugins: {

                    datalabels: {
                        formatter: function (value, context) {
                            return value + '%';
                        },
                        anchor: 'start',
                        align: 'end',
                        offset: 8 // Gets updated
                    },
                    title: {
                        display: true,
                        text: '',
                        fontSize: 16
                    },
                    chartArea: { backgroundColor: 'red' },

                    animation: {
                        animateRotate: true,
                        animateScale: true,
                        duration: 4000,
                        xAxis: true,
                        yAxis: true,
                    },
                    legend: {
                        display: true,
                        position: 'bottom',
                        labels: {
                            generateLabels: function (chart) {
                                const data = chart.data;
                                if (data.labels.length && data.datasets.length) {
                                    const { labels: { pointStyle } } = chart.legend.options;
                                    return data.labels.map((label, i) => {
                                        const meta = chart.getDatasetMeta(0);
                                        const style = meta.controller.getStyle(i);
                                        return {
                                            text: label,
                                            fillStyle: style.backgroundColor,
                                            strokeStyle: style.borderColor,
                                            lineWidth: style.borderWidth,
                                            pointStyle: pointStyle,
                                            hidden: !chart.getDataVisibility(i),
                                            fontColor: t_this.labelColorCloud[i],
                                            // Extra data used for toggling the correct item
                                            index: i
                                        };
                                    });
                                }
                                return [];
                            }
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function (context) {
                                let label = context.chart.data.labels[context.dataIndex];
                                let s = label.substr(0, label.lastIndexOf(' ('));
                                return s + ':' + context.dataset.data[context.dataIndex] + '%';
                            }
                        }
                    }
                }
            }
        }
        if (this.myChart) {
            this.myChart.destroy();
        }


        const ctx = this.template
            .querySelector('canvas.stepped')
            .getContext('2d');

        this.myChart = new window.Chart(ctx, dataSet);


        $("canvas.sales").remove();
        $("div.chartDivList").append('<canvas class="sales" ></canvas>');
    }

    random(min, max) {
        return Math.random() * (max - min) + min;
    }

    //generating feature chart
    @api
    generateFeatureChart() {
        let t_this = this;
        let labelName = [];
        let valuePer = [];
        let polar = [];
        let dataarea = [];
        let bgColor = [];
        let chartDiv = this.template.querySelector('canvas.sales').getContext('2d');
        t_this.labelColorFeature = [];
        if (this.childchartName != undefined) {
            findFeaturesProduct({ feature: this.childchartName, accountId: this.accountId })
                .then(data => {
                    const selectedEvent = new CustomEvent("callaccount", {
                        detail: this.updateSalesforceProduct
                    });
                    this.dispatchEvent(selectedEvent);
                    for (let i = 0; i < data.length; i++) {
                        let r = Math.floor(Math.random() * 255);
                        let g = Math.floor(Math.random() * 255);
                        let b = Math.floor(Math.random() * 255);
                        // bgColor.push("rgb(" + r + "," + g + "," + b + ")");
                        bgColor.push(data[i].Chart_Color_Code__c);
                        labelName.push(data[i].Salesforce_Product_Feature__r.Name + ' (' + data[i].Client_Usage_Percentage__c + '%)');
                        valuePer.push(data[i].Client_Usage_Percentage__c);
                        if (data[i].Client_Usage_Percentage__c == 0) {
                            t_this.labelColorFeature.push('#FF0000');
                        } else {
                            t_this.labelColorFeature.push('#000000');
                        }
                    }
                    polar = {
                        labels: labelName,
                        datasets: [{
                            label: 'Salesforce Affinity Feature For ' + this.childchartName,
                            backgroundColor: bgColor,
                            borderAlign: 'inner',
                            yAxisID: 'y-axis-1',
                            data: valuePer,
                            borderWidth: 1,
                            hoverBorderColor: "white",
                        }]
                    };
                    dataarea = {
                        type: 'polarArea',
                        data: polar,

                        options: {
                            onClick: function (c, i) {
                                let e = i[0];
                                if (i.length !== 0) {
                                    let x_value = this.data.labels[e.index];
                                    t_this.productSubFeatureChart(x_value, this.accountId);
                                }
                            },
                            scale: {
                                min: 0,
                                max: 100,
                                display: false,
                                beginAtZero: true,
                                maxTicksLimit: 10,
                                reverse: false
                            },
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: {
                                datalabels: {
                                    formatter: function (value, context) {
                                        return context.chart.data.labels[context.dataIndex];
                                    },
                                    anchor: 'start',
                                    align: 'end',
                                    offset: 8 // Gets updated
                                },
                                cutoutPercentage: 20,
                                title: {
                                    display: true,
                                    text: 'Salesforce Affinity Feature For ' + this.childchartName,
                                    fontSize: 16
                                },
                                chartArea: { backgroundColor: 'red' },

                                animation: {
                                    animateRotate: true,
                                    animateScale: true,
                                    duration: 4000,
                                    xAxis: true,
                                    yAxis: true,
                                },
                                legend: {
                                    display: true,
                                    position: 'bottom',
                                    labels: {
                                        generateLabels: function (chart) {
                                            const data = chart.data;
                                            if (data.labels.length && data.datasets.length) {
                                                const { labels: { pointStyle } } = chart.legend.options;
                                                return data.labels.map((label, i) => {
                                                    const meta = chart.getDatasetMeta(0);
                                                    const style = meta.controller.getStyle(i);
                                                    return {
                                                        text: label,
                                                        fillStyle: style.backgroundColor,
                                                        strokeStyle: style.borderColor,
                                                        lineWidth: style.borderWidth,
                                                        pointStyle: pointStyle,
                                                        hidden: !chart.getDataVisibility(i),
                                                        fontColor: t_this.labelColorFeature[i],
                                                        // Extra data used for toggling the correct item
                                                        index: i
                                                    };
                                                });
                                            }
                                            return [];
                                        }
                                    }
                                },
                                tooltip: {
                                    callbacks: {
                                        label: function (context) {
                                            let label = context.chart.data.labels[context.dataIndex];
                                            let s = label.substr(0, label.lastIndexOf(' ('));
                                            return s + ':' + context.dataset.data[context.dataIndex] + '%';
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if (this.relatedchart) {
                        this.relatedchart.destroy();
                    }
                    this.relatedchart = new window.Chart(chartDiv, dataarea);
                })
                .catch(error => {
                    this.error = error;
                    console.log(error);
                });

        }
    }
    destroySubFeatureChart() {
        this.template.querySelector('div.subDiv').style.display = 'none';
    }
    //generating subfeature chart
    productSubFeatureChart(x) {
        let t_this = this;
        let labelName = [];
        let valuePer = [];
        let polar = [];
        let dataarea = [];
        let bgColor = [];
        t_this.labelColorSubFeature = [];
        let chartDiv = this.template.querySelector('canvas.subFeature').getContext('2d');
        let sName = x.substr(0, x.lastIndexOf(' ('));
        // alert('sName--'+sName)
        //  alert(this.cloudName.substr(0,this.cloudName.lastIndexOf(':')))
        getProductSubFeatureDetails({ subFeatureName: sName, accountId: this.accountId, cloudName: this.cloudName.substr(0, this.cloudName.lastIndexOf(' (')) })
            .then(data => {
                for (let i = 0; i < data.length; i++) {
                    let r = Math.floor(Math.random() * 255);
                    let g = Math.floor(Math.random() * 255);
                    let b = Math.floor(Math.random() * 255);
                    //bgColor.push("rgb(" + r + "," + g + "," + b + ")");
                    bgColor.push(data[i].Chart_Color_Code__c);

                    labelName.push(data[i].Name + ' (' + data[i].Client_Usage_Percentage__c + '%)');
                    valuePer.push(data[i].Client_Usage_Percentage__c);
                    if (data[i].Client_Usage_Percentage__c == 0) {
                        t_this.labelColorSubFeature.push('#FF0000');
                    } else {
                        t_this.labelColorSubFeature.push('#000000');
                    }
                }
                polar = {
                    labels: labelName,
                    datasets: [{
                        label: 'Salesforce Affinity Sub-Feature For ' + sName,
                        backgroundColor: bgColor,
                        borderAlign: 'inner',
                        yAxisID: 'y-axis-1',
                        data: valuePer,
                        borderWidth: 1,
                        hoverBorderColor: "white",
                    }]
                };
                dataarea = {
                    type: 'polarArea',
                    data: polar,

                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scale: {
                            min: 0,
                            max: 100,
                            display: false,
                            beginAtZero: true,
                            maxTicksLimit: 10,
                            reverse: false
                        },
                        plugins: {
                            datalabels: {
                                formatter: function (value, context) {
                                    return context.chart.data.labels[context.dataIndex];
                                },
                                anchor: 'start',
                                align: 'end',
                                offset: 8 // Gets updated
                            },
                            cutoutPercentage: 20,
                            title: {
                                display: true,
                                text: 'Salesforce Affinity Sub-Feature For ' + sName,
                                fontSize: 16
                            },
                            chartArea: { backgroundColor: 'red' },

                            animation: {
                                animateRotate: true,
                                animateScale: true,
                                duration: 4000,
                                xAxis: true,
                                yAxis: true,
                            },
                            legend: {
                                display: true,
                                position: 'bottom',
                                labels: {
                                    generateLabels: function (chart) {
                                        const data = chart.data;
                                        if (data.labels.length && data.datasets.length) {
                                            const { labels: { pointStyle } } = chart.legend.options;
                                            return data.labels.map((label, i) => {
                                                const meta = chart.getDatasetMeta(0);
                                                const style = meta.controller.getStyle(i);
                                                return {
                                                    text: label,
                                                    fillStyle: style.backgroundColor,
                                                    strokeStyle: style.borderColor,
                                                    lineWidth: style.borderWidth,
                                                    pointStyle: pointStyle,
                                                    hidden: !chart.getDataVisibility(i),
                                                    fontColor: t_this.labelColorSubFeature[i],
                                                    // Extra data used for toggling the correct item
                                                    index: i
                                                };
                                            });
                                        }
                                        return [];
                                    }
                                }
                            },
                            tooltip: {
                                callbacks: {
                                    label: function (context) {
                                        let label = context.chart.data.labels[context.dataIndex];
                                        let s = label.substr(0, label.lastIndexOf(' ('));
                                        return s + ':' + context.dataset.data[context.dataIndex] + '%';
                                    }
                                }
                            }
                        }
                    }
                }
                if (this.subFeatureChart) {
                    this.subFeatureChart.destroy();
                }
                this.template.querySelector('div.subDiv').style.display = 'block';

                this.subFeatureChart = new window.Chart(chartDiv, dataarea);
            })
            .catch(error => {
                this.error = error;
                console.log(error);
            });

    }

    @track isShowModal = false;

    showModalBox() {
        this.isShowModal = true;
    }
    hideModalBox() {
        this.isShowModal = false;
    }
    handleAboutHeatMap() {
        window.open(AboutHeatMap, '_blank');
    }
}
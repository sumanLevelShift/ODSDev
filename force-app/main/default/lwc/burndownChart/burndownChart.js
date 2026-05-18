import { LightningElement, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/ChartJs';

export default class BurndownChart extends LightningElement {
    @api chartData;
    
    chartjsInitialized = false;
    chart;
    
    get hasData() {
        return this.chartData && 
               this.chartData.labels && 
               this.chartData.labels.length > 0;
    }
    
    renderedCallback() {
        if (this.chartjsInitialized) {
            return;
        }
        
        if (this.hasData) {
            this.loadChartJs();
        }
    }
    
    async loadChartJs() {
        try {
            await loadScript(this, chartjs + '/chartjs-3.6.2/dist/chart.min.js');
            this.chartjsInitialized = true;
            this.initializeChart();
        } catch (error) {
            console.error('Error loading Chart.js', error);
        }
    }
    
    initializeChart() {
        const canvas = this.refs.chartCanvas;
        if (!canvas) return;
        
        const ctx = canvas.getContext('2d');
        
        // Calculate max value for Y axis
        let maxValue = 0;
        if (this.chartData.actualHours) {
            maxValue = Math.max(...this.chartData.actualHours, 0);
        }
        if (this.chartData.cumulativeHours) {
            maxValue = Math.max(maxValue, ...this.chartData.cumulativeHours, 0);
        }
        maxValue = Math.ceil(maxValue * 1.1); // Add 10% padding
        
        // Create chart
        this.chart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: this.chartData.labels || [],
                datasets: [
                    {
                        label: 'Hours',
                        type: 'line',
                        data: this.chartData.cumulativeHours || [],
                        borderColor: '#0000FF',
                        backgroundColor: '#0000FF',
                        borderWidth: 2,
                        fill: false,
                        pointBackgroundColor: 'transparent',
                        tension: 0.1
                    },
                    {
                        label: 'Timesheet Date & Hours',
                        type: 'bar',
                        data: this.chartData.actualHours || [],
                        backgroundColor: '#00B000',
                        borderColor: 'green',
                        borderWidth: 1
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                animation: {
                    onComplete: function() {
                        const chart = this;
                        const ctx = chart.ctx;
                        
                        ctx.textAlign = 'center';
                        ctx.fillStyle = 'rgba(0, 0, 0, 1)';
                        ctx.textBaseline = 'bottom';
                        
                        chart.data.datasets.forEach((dataset, i) => {
                            const meta = chart.getDatasetMeta(i);
                            meta.data.forEach((bar, index) => {
                                const data = dataset.data[index];
                                if (data) {
                                    ctx.fillText(data, bar.x, bar.y - 5);
                                }
                            });
                        });
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        max: maxValue,
                        title: {
                            display: true,
                            text: 'Hours'
                        }
                    },
                    x: {
                        title: {
                            display: true,
                            text: 'Timesheet Date'
                        }
                    }
                },
                plugins: {
                    legend: {
                        display: true,
                        position: 'top'
                    },
                    tooltip: {
                        enabled: true,
                        mode: 'index',
                        intersect: false
                    }
                }
            }
        });
    }
    
    disconnectedCallback() {
        if (this.chart) {
            this.chart.destroy();
        }
    }
}
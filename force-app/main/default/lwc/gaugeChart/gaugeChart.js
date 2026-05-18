import { LightningElement, api } from 'lwc';

export default class GaugeChart extends LightningElement {
    @api percentage = 0;
    @api value = 0;
    @api label = 'Hours';
    
    get displayValue() {
        return parseFloat(this.value).toFixed(2);
    }
    
    get displayPercentage() {
        return parseFloat(this.percentage).toFixed(2);
    }
    
    get progressColor() {
        const pct = parseFloat(this.percentage);
        if (pct < 50) return '#4bca81'; // Green
        if (pct < 75) return '#ffb75d'; // Orange
        return '#ea001e'; // Red
    }
    
    get backgroundArc() {
        // Draw a semi-circle arc from -90 to 90 degrees (180 degrees total)
        return this.describeArc(100, 100, 70, -90, 90);
    }
    
    get progressArc() {
        // Calculate the angle based on percentage (0-100% maps to -90 to 90 degrees)
        const pct = Math.min(100, Math.max(0, parseFloat(this.percentage)));
        const angle = -90 + (pct / 100) * 180;
        return this.describeArc(100, 100, 70, -90, angle);
    }
    
    // Helper function to describe an arc path
    describeArc(x, y, radius, startAngle, endAngle) {
        const start = this.polarToCartesian(x, y, radius, endAngle);
        const end = this.polarToCartesian(x, y, radius, startAngle);
        const largeArcFlag = endAngle - startAngle <= 180 ? '0' : '1';
        
        return [
            'M', start.x, start.y,
            'A', radius, radius, 0, largeArcFlag, 0, end.x, end.y
        ].join(' ');
    }
    
    // Helper function to convert polar coordinates to cartesian
    polarToCartesian(centerX, centerY, radius, angleInDegrees) {
        const angleInRadians = (angleInDegrees - 90) * Math.PI / 180.0;
        return {
            x: centerX + (radius * Math.cos(angleInRadians)),
            y: centerY + (radius * Math.sin(angleInRadians))
        };
    }
}
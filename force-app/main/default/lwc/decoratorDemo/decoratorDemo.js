import { LightningElement,api } from 'lwc';

export default class decoratorDemo extends LightningElement {
    @api itemName = 'Salesforce';
}
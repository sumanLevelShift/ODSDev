import { LightningElement } from 'lwc';
import templateOne from './templateOne.html';
import templateTwo from './templateTwo.html';

export default class MultipleTemplates extends LightningElement {
    test = true;

    render() {
        return this.test ? templateOne : templateTwo;
    }

    switchTemplate(){ 
        this.test = this.test === true ? false : true; 
    }
}
import { LightningElement, track } from 'lwc';

export default class ParentComp1 extends LightningElement {

    @track inputVal;

    handleInputChangeEvent(event){
        const textVal = event.detail;

        this.inputVal = textVal;
    }
}
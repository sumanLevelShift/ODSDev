import { LightningElement } from 'lwc';

export default class ChildComp1 extends LightningElement {
    handleChange(event){
        const name = event.target.value;

        const changesEvent = new CustomEvent('simpleevent',{detail:name});
        this.dispatchEvent(changesEvent);
    }
}
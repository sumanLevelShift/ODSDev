import { LightningElement } from 'lwc';

export default class LwcComp3 extends LightningElement {
    areDetailsVisible = false;

    handleChange(event) {
        this.areDetailsVisible = event.target.checked;
    }
}
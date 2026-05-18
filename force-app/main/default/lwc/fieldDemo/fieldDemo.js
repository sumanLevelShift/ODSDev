import { LightningElement } from 'lwc';

export default class FieldDemo extends LightningElement {
    firstName = '';
    lastname = '';

    handleNameChange(event){
        const field = event.target.name;
        if(field === 'firstName'){
            this.firstName = event.target.value;
        }
        else if(field === 'lastName'){
            this.lastname = event.target.value;
        }
    }

    get upperCaseName(){
        return `${this.firstName} ${this.lastname}`.trim().toUpperCase();
    }
}
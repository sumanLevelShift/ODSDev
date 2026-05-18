import { LightningElement, track } from 'lwc';

export default class FieldDemo extends LightningElement {
    
    @track fullName = {firstName : '', lastname : ''};

    handleNameChange(event){
        const field = event.target.name;
        if(field === 'firstName'){
            this.fullName.firstName = event.target.value;
        }
        else if(field === 'lastName'){
            this.fullName.lastname = event.target.value;
        }
    }

    get upperCaseName(){
        return `${this.fullName.firstName} ${this.fullName.lastname}`.trim().toUpperCase();
    }
}
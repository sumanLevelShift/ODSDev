import { LightningElement } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

export default class ChatGPTWrapper extends NavigationMixin(LightningElement) {
    handleSandboxLogin(e){
        var loginUrl = e.detail;
        //unable to navigate to the URL using NavigationMixin
        /*this.externalURL = {
            type: 'standard__webPage',
            attributes: {
                url: loginUrl
            }
        };
        this[NavigationMixin.Navigate](this.externalURL);*/
        window.open(loginUrl, '_blank');
    }    
}
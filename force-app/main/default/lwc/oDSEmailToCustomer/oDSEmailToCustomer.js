import { LightningElement, wire, track } from 'lwc';
import ODS_Assets from '@salesforce/resourceUrl/ODS_Assets';
import ODSEmailToCustomerCss from '@salesforce/resourceUrl/ODSEmailToCustomerCss';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import getAccountList from '@salesforce/apex/ODSEmailToCustomerPageController.getAccountList';
import getDraftEmails from '@salesforce/apex/ODSEmailToCustomerPageController.getDraftEmails';
import saveDraftEmail from '@salesforce/apex/ODSEmailToCustomerPageController.saveDraftEmail';
import deleteDraftEmail from '@salesforce/apex/ODSEmailToCustomerPageController.deleteDraftEmail';
import sendEmails from '@salesforce/apex/ODSEmailToCustomerPageController.sendEmails';
import clickOnDraft from '@salesforce/apex/ODSEmailToCustomerPageController.clickOnDraft';
//import myChannel from "@salesforce/messageChannel/PassRecordId__c";
import { APPLICATION_SCOPE, createMessageContext, subscribe } from 'lightning/messageService';
import uId from '@salesforce/user/Id';
import jquery3_6_0 from '@salesforce/resourceUrl/jquery3_6_0';
import updateSessionData from '@salesforce/apex/ODSEmailToCustomerPageController.updateSessionData';

export default class ODSEmailToCustomer extends LightningElement {
    userId = uId;
    draftFlag = false;
    emailFlag = false;
    @track error;
    @track draftData = [];
    @track lstOptions = [];
    @track lstSelected = [];
  //  @track lstSelected1 = [];
    @track existDraftEmail = '';
    recipients;
    dFlag = false;

    visibleDraftData;


    @track accId = '';
    @track srvcId = '';
    context = createMessageContext();

    connectedCallback() {
       this.getCurrentId(this.userId);
      // console.log('acc id : '+this.accId +' '+ 'svc id : '+this.srvcId);
         updateSessionData({ accountId: this.accId, serviceId: this.srvcId })
            .then(data => {
               // console.log('Updated sessions.');
            })
            .catch(error => {
              //  console.log('update--' + error);
            });

    }

    renderedCallback() {
        Promise.all([

           // loadStyle(this, ODS_Assets + '/css/bootstrap.css'),
            loadStyle(this, ODS_Assets + '/css/style.css'),
            loadStyle(this, ODS_Assets + '/css/jquery-ui.css'),
          //  loadScript(this, ODS_Assets + '/ckeditor/ckeditor.js'),
            loadStyle(this, ODSEmailToCustomerCss),
            loadScript(this, jquery3_6_0)


        ]).then(() => {
           // console.log('done.')
        })
            .catch(error => {
                this.error = error;
              //  console.log(' Error Occured-- ', +error);

            });


    }

    sendEmail(event) {
        const emailSub = this.template.querySelector('lightning-input[data-name="subject"]').value;
       // console.log('emailSub : ' + emailSub);
        const emailBody = this.template.querySelector('lightning-input-rich-text[data-name="body"]').value;
      //  console.log('emailBody : ' + emailBody);

        if(emailSub === "undefined" || emailSub == null || emailSub.trim() == "" || emailSub.length <= 0){
            alert("Email subject should not be empty!!");
        }

        if(emailBody === "undefined" || emailBody == null || emailBody.trim() == "" || emailBody.length <= 0) {
            alert("Email body should not be empty!!");
            return false;
        }


        if(this.existDraftEmail){
            let savedCust = this.existDraftEmail.savedCustomers;
           // console.log('savedCust : '+savedCust);
            if((savedCust===null || savedCust===undefined) && (this.lstSelected===null || this.lstSelected===undefined || this.lstSelected.length===0 || this.lstSelected.length==='' )){
                alert('Selected Customers should not be empty!!');
            }
            else if((savedCust===null || savedCust===undefined) && (this.lstSelected!==null || this.lstSelected!==undefined) ){
               // console.log('In abc: '+ this.lstSelected);
                sendEmails({ draftEmailSubject: emailSub, draftEmailBody: emailBody, selectedCustomers: this.lstSelected  })  
                .then((result) => {
                 
                          //  alert('send');
                            window.location.reload();
                        
                  
                    })
                    .catch((error) => {
                    this.error = error;
    
                    });
            }

            if((savedCust!==null || savedCust.length!=='' ||  savedCust.length!==0 ) && (this.lstSelected===null || this.lstSelected.length==0 || this.lstSelected.length=='')){
              //  console.log('In recep : '+   this.existDraftEmail.customerNames +  savedCust);
                sendEmails({ draftEmailSubject: emailSub, draftEmailBody: emailBody, selectedCustomers: savedCust})
                .then((result) => {
                 
                  //  alert('send');
                    window.location.reload();
                
          
                })
                .catch((error) => {
                this.error = error;

                });
            }
            else if((savedCust!=null || savedCust!=undefined ) && (this.lstSelected!=null || this.lstSelected.length!='' || this.lstSelected!=0)){
              //  console.log('lstselected xyz '+ this.lstSelected);
                sendEmails({ draftEmailSubject: emailSub, draftEmailBody: emailBody, selectedCustomers: this.lstSelected })
                .then((result) => {
                 
                    //alert('send');
                    window.location.reload();
                
          
                })
                .catch((error) => {
                this.error = error;

                });
            }

        }
        else if(this.lstSelected)
        {
            
              //  console.log('In select : '+ this.lstSelected);
                sendEmails({ draftEmailSubject: emailSub, draftEmailBody: emailBody, selectedCustomers: this.lstSelected })
                .then((result) => {
                 
                   // alert('send');
                    window.location.reload();
                
          
                })
                .catch((error) => {
                this.error = error;

                });  
            
                
        }


      //  window.location.reload();
}

newEmail(event) {
        this.emailFlag = true;
        let emailSub = this.template.querySelector('lightning-input');
        if(emailSub){
        emailSub.value="";
        }
        let emailBody = this.template.querySelector('lightning-input-rich-text');
        if(emailBody){
        emailBody.value="";

        }
        this.recipients = null;
        this.dFlag = false;
        this.existDraftEmail=null;

   /*     let allrow=this.template.querySelectorAll("tr.dataRow");
        for(let i=0; i<allrow.length; i++){
            allrow[i].style.backgroundColor = '#F4F4F4';
        } */
}

    // Get Picklist values.
    @wire(getAccountList)
    pushAccountValue({ data, error }) {

        if (data) {
           // console.log('Data : ' + JSON.stringify(data))
            for (var i = 0; i < data.length; i++) {
                this.lstOptions.push({
                    label: data[i].Name,
                    value: data[i].Id
                });
            }
           // console.log('array : ' + JSON.stringify(this.lstOptions));
            
        }
        if(error){
            this.error=error;
          //  console.log('Error', error);
        }


    }


    handleChange(event) {
        this.lstSelected = event.detail.value;
      //  console.log('selected : ' + this.lstSelected);
    }

    //To save the Email in Draft
    saveAsDraft(event) {
        const emailSub = this.template.querySelector('lightning-input[data-name="subject"]').value;
            if(emailSub === "undefined" || emailSub == null || emailSub.trim() == "" || emailSub.length <= 0){
                alert("Email subject should not be empty!!");
            }
          
        const emailBody = this.template.querySelector('lightning-input-rich-text[data-name="body"]').value;
            if(emailBody === "undefined" || emailBody == null || emailBody.trim() == "" || emailBody.length <= 0) {
                alert("Email body should not be empty!!");
                return false;
            }
          
       // console.log('Selected value : ' + this.lstSelected);
        
       
      //  console.log('Receipient available : '+ JSON.stringify(this.existDraftEmail));

        if(this.existDraftEmail){
          let savedCust = this.existDraftEmail.savedCustomers;
          let lstSelected1;
         //  console.log('savedCust: '+ savedCust)
            if((savedCust!==null || savedCust.length!=='' ||  savedCust.length!==0 || savedCust!==undefined) && (this.lstSelected===null || this.lstSelected.length==0 || this.lstSelected.length==''||this.lstSelected=='')){
              //  console.log('In recep : '+   this.existDraftEmail.customerNames +  savedCust);
                
                saveDraftEmail({ draftEmailSubject: emailSub, draftEmailBody: emailBody, selectedCustomers: savedCust})
               .then((result) => {
              //  console.log('Save Draft: ' + JSON.stringify(result));
                    if(result===1){
                      //  alert(result);
                        window.location.reload();
                    }
              
                })
                .catch((error) => {
                this.error = error;

                });
            }
            else if((savedCust!==null || savedCust.length!=='' ||  savedCust.length!==0) && (this.lstSelected!==null || this.lstSelected.Size()>0 || !this.lstSelected.IsEmpty())){
                lstSelected1=this.lstSelected;
              //  console.log('lstselected1 : '+ lstSelected1);
                
                saveDraftEmail({ draftEmailSubject: emailSub, draftEmailBody: emailBody, selectedCustomers: lstSelected1 })
                .then((result) => {
                  //  console.log('Save Draft1: ' + JSON.stringify(result));
                        if(result===1){
                          //  alert(result);
                            window.location.reload();
                        }
                  
                    })
                    .catch((error) => {
                    this.error = error;
    
                    });
            }
            
         

        }
     
       // if(!(this.existDraftEmail))
       else
        {
            let lstSelected1;
            lstSelected1=this.lstSelected;
           // console.log('In select2 : '+ lstSelected1);
           
            saveDraftEmail({ draftEmailSubject: emailSub, draftEmailBody: emailBody, selectedCustomers: lstSelected1})
            .then((result) => {
              //  alert(result);
                console.log('Save Draft4: ' + JSON.stringify(result));
                if(result===1){
                  //  alert(result);
                    window.location.reload();
                }
               
              
                })
                .catch((error) => {
                this.error = error;

                });
        
            
        }

       //window.location.reload();
    }
  
    getCurrentId(uId) {
        getDraftEmails({ currId: uId })
            .then(data => {
                this.draftData = data;
             //   console.log('Data Draft: ' + JSON.stringify(data));
              //  console.log('User Id : ' + uId);

                if (data) {
                    this.draftFlag = true;
                }
                else {
                    this.draftFlag = false;
                }

            })
            .catch(error => {
             //   console.log(error);
                this.error = error;
            });
    }

    //Delete the drafted Email Records
    delDraftEmail(event) {
        var id = event.target.dataset.id;
      //  console.log('Id to be deleted : ' + id);
        deleteDraftEmail({ draftEmailId: id })
        .then((result) => {
                 // alert('in del');
                  window.location.reload();
              })
              .catch((error) => {
              this.error = error;

              });
        // eval("$A.get('e.force:refreshView').fire();");
        

    }

     lastRow;
    //clickOnDraftEmail
    clickOnDraftEmail(event) {


        var divId = event.currentTarget.dataset.id;
        if (this.lastRow != undefined) {
            this.lastRow.style.backgroundColor = '#F4F4F4';

        }
        /*let elem = this.template.querySelector("tr[id='" + divId + "-10']");
        console.log('css '+ divId);
        elem.style.backgroundColor = 'yellow';*/

        const tds = this.template.querySelector("[data-id='" + divId + "']");
        var trId = $(tds).closest('tr').attr('id');
        let selectedRow = this.template.querySelector("[id='" + trId + "']");
        selectedRow.style.backgroundColor = 'yellow';

        this.lastRow = selectedRow;


        this.emailFlag = true;
        this.dFlag = true;
        const draftId = event.currentTarget.dataset.id;
       // console.log('Draft Email Id : ' + draftId);

        clickOnDraft({ draftEmailId: draftId })
            .then((result) => {
               // console.log('In Click on Draft : ' + JSON.stringify(result));
                this.existDraftEmail=result;
              
            })
            .catch((error) => {
                this.error = error;

            });


    }

    updateDraftHandler(event) {
        this.visibleDraftData = [...event.detail.records]
        console.log(event.detail.records);
    }

 /*   jumpTOCharacter(event){
        console.log('here');
        let keyChar = this.currentTarget.options;
        console.log('Character pressed : '+keyChar);
    }
*/
}
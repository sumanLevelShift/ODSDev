import { LightningElement, wire, track, api } from 'lwc';
import GetQueriesByUserId from '@salesforce/apex/ODS_ClientQueriesApexController.GetQueriesByUserId';
import ODS_JqueryUpdated from '@salesforce/resourceUrl/ODS_JqueryUpdated';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
//import myChannel from "@salesforce/messageChannel/PassRecordId__c";
import { createMessageContext, APPLICATION_SCOPE, subscribe } from 'lightning/messageService';
import CSSClientQuery from '@salesforce/resourceUrl/CSSClientQuery';
import updateSessionData from '@salesforce/apex/ODS_ClientQueriesApexController.updateSessionData';


export default class ODS_ClientQuery extends LightningElement {

    frmDate;
    toDate;
    context = createMessageContext();

    //Sub
    @api accId = '';
    @api srvcId = '';

    connectedCallback() {
       
        this.getAccid(this.accId,this.srvcId)

        updateSessionData({ accountId: this.accId, serviceId: this.srvcId })
        .then(data => {
           // console.log('Updated sessions.');
        })
        .catch(error => {
           // console.log('update--' + error);
        });
    }
 

//To handle jquery 
    renderedCallback() {
        Promise.all([
            loadStyle(this, CSSClientQuery)

        ])

        Promise.all([
           loadScript(this, ODS_JqueryUpdated)
           

        ]).then(() => {
           // console.log('done.')
        })
            .catch(error => {
                this.error = error;
                console.log(' Error Occured-- ', +error);
            });

    }
    
//to implement search dropdown
    handleOnSearch(event) {
        var flag = window.getComputedStyle(this.template.querySelector('.SearchDiv')).display;
        if (flag === 'none') {

            this.template.querySelector('.SearchDiv').style.display = "block";
            
            this.template.querySelector('.advnc_search1').style.display = "block";

        } else {
            this.template.querySelector('.SearchDiv').style.display = "none";
            this.template.querySelector('.advnc_search1').style.display = "none";

        }

    }


//new handle on click

value;
error;
data;
searchKey = '';
result;

page; 
items; 
 
 
startingRecord = 1;
endingRecord = 0; 
pageSize = 10; 
totalRecountCount = 0;
totalPage = 0;
isPrev;
isNext;

getAccid(accid, serid) {

    GetQueriesByUserId({ AccountId: accid, ServiceId: serid, startDate: null, endDate: null  })
        .then(data => {
           // console.log('aid sid sd ed:'+this.accId+''+this.srvcId+''+this.startDate+this.endDate);
           // console.log('result data:'+JSON.stringify(data));
            this.items = data;
            this.totalRecountCount = data.length; 
            console.log('start date :' + this.totalRecountCount);
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
            if (this.totalRecountCount == 0) {
                this.template.querySelector('.norecords').style.display = "block";
                this.template.querySelector('.tableListEST').style.display = "none";
            } 
            else{
                this.template.querySelector('.norecords').style.display = "none";
                this.template.querySelector('.tableListEST').style.display = "block";
            }
            if(this.totalPage==0){
                this.page=0;
                this.isNext = true
                this.isPrev = true
                
            }
            else if(this.totalPage==1){
                this.page=1
                this.isNext = true
                this.isPrev = true
            }
            else {
                this.page=1
                this.isPrev = true
                this.isNext = false
            }
  
            this.data = this.items.slice(0,this.pageSize); 
           // console.log('data:'+JSON.stringify(items));
            this.endingRecord = this.pageSize;
            
            this.error = undefined;
        })
        .catch(error => {
           // console.log(error);
            this.error = error;
        });
}

 


    //clicking on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //clicking on next button this method will be called
    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }             
    }

    firstHandler() {
       
            this.page = 1; //On Page 1
            this.displayRecordPerPage(this.page);
       
    }

    lastHandler() {
        
            this.page = this.totalPage; //On last Page
            this.displayRecordPerPage(this.page);
        
    }


    //this method displays records page by page
    displayRecordPerPage(page){

        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 

        this.data = this.items.slice(this.startingRecord, this.endingRecord);

        this.startingRecord = this.startingRecord + 1;

        
        this.isNext = (this.page == this.totalPage || this.totalPage == 0);
        this.isPrev = (this.page == 1 || this.totalRecountCount < this.page);

      //  this.updatePageButtons();
    }        



    handleFetchQuery(event) {
        this.frmDate = this.template.querySelector('.startdate').value;
        this.toDate = this.template.querySelector('.enddate').value;
       // console.log('start date :' + this.frmDate);
       // console.log('Type of from date :' + typeof (this.frmDate));
       // console.log('start date :' + this.toDate);

        GetQueriesByUserId({ AccountId: this.accId, ServiceId: this.srvcId, startDate: this.frmDate, endDate: this.toDate })
            .then(result => {
                //alert('here3...'+this.accId + ' '+this.srvcId);
               // console.log('actual data 2 : ' + JSON.stringify(result));  
    
                this.items = result;
                this.totalRecountCount = result.length; 
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
                if (this.totalRecountCount == 0) {
                    this.template.querySelector('.norecords').style.display = "block";
                    this.template.querySelector('.tableListEST').style.display = "none";
                } 
                else{
                    this.template.querySelector('.norecords').style.display = "none";
                    this.template.querySelector('.tableListEST').style.display = "block";
                }
                if(this.totalPage==0){
                    this.page=0;
                    this.isNext = true
                    this.isPrev = true
                    
                }
                else if(this.totalPage==1){
                    this.page=1
                    this.isNext = true
                    this.isPrev = true
                }
                else {
                    this.page=1
                    this.isPrev = true
                    this.isNext = false
                }   


                this.data = this.items.slice(0,this.pageSize); 
              //  console.log('data:'+JSON.stringify(this.items));
                this.endingRecord = this.pageSize;

                this.error = undefined; 
            })
            .catch(error => {
                this.error = error;

            })


    }


}
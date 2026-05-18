import { LightningElement, wire, track, api } from 'lwc';
import getCustomerDetails from '@salesforce/apex/ODS_CustomerAccountController.getCustomerDetails';
import getClientCustomer from '@salesforce/apex/ODS_CustomerAccountController.getClientCustomer';
import ODS_Assets from '@salesforce/resourceUrl/ODS_Assets';
import getCustomerServices from '@salesforce/apex/ODS_CustomerAccountController.getCustomerServices';
import myChannel from "@salesforce/messageChannel/PassRecordId__c";
import { createMessageContext, APPLICATION_SCOPE, subscribe } from 'lightning/messageService';
import getMatchList from '@salesforce/apex/ODS_CustomerAccountController.getMatchList';
//import { NavigationMixin } from 'lightning/navigation';
import ODS_JqueryUpdated from '@salesforce/resourceUrl/ODS_JqueryUpdated';
import { CurrentPageReference } from "lightning/navigation";
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import updateSessionData from '@salesforce/apex/ODS_CustomerAccountController.updateSessionData';
import checkIsSmallBusiness from '@salesforce/apex/ODS_CustomerAccountController.checkIsSmallBusiness';

import CustomerCSS from '@salesforce/resourceUrl/CustomerCSS';
import ODS_Statussign from '@salesforce/resourceUrl/ODS_Statussign';

export default class ODS_CustomerAccountController extends LightningElement {
    @track spinner = ODS_Statussign;

    email = ODS_Assets + '/images/email-icon.png';
    phone = ODS_Assets + '/images/phone-icon.png';
    use = ODS_Assets + '/images/tech_pic.jpg';
    @api item;

    context = createMessageContext();
    @track name;
    tamName;
    tamPhone;
    tamEmail;
    bcsmname;
    bcsmphone;
    bcsmemail;
    accountname;
    website;
    billingaddress;
    csename;
    csephone;
    cseemail;
    csdate;
    cedate;
    Retainerfee;
    ODSHourlyRate;
    RetainerFeeFrequency;
    CustomerPortal;
    CustomerPortalAcccess;
    SetupWeekMonthMeeting;
    onboardingdocument;
    Lightingreadinescheck;
    conname;
    conphone;
    conemail;
    CSEname;
    CSEEmail;
    CSEPhone;
    AccMan;
    AccPhone;
    AccEmail;
    ServName;

    flag = false;
    msg = 'SearchDiv';
    //areDetailsVisible = false;
    @api accId = '';
    @api srvcId = '';

    @track aId;
    @track ObjCon = [];
    //@track acId;
    @track Accoutser = [];
    parameters = {};

    //Variables for Pagination
    page;
    items = [];

    @track listView;
    startingRecord = 1;
    endingRecord = 0;
    pageSize = 10;
    totalRecountCount = 0;
    totalPage = 0;
    isPrev;
    isNext;
    @track customerList;
    @track isSmallBusiness = false;


    connectedCallback() {
        Promise.all([
            loadStyle(this, CustomerCSS)

        ]).then(() => {
            // console.log('External CSS done.')
        })
        this.getCustomertable(this.accId, this.srvcId);

        this.parameters = this.getQueryParameters();


        this.aId = this.parameters.custId;


        if (this.aId) {
            this.flag = true;

            this.getAccserid(this.aId);

            this.getAccid(this.aId, this.srvcId);

        }
        else {
            this.flag = false;

        }
        this.getAccid(this.accId, this.srvcId)



        updateSessionData({ accountId: this.accId, serviceId: this.srvcId })
            .then(data => {
                // console.log('Updated sessions.');
            })
            .catch(error => {
                // console.log('update--' + error);
            });
        checkIsSmallBusiness({ accountId: this.accId })
            .then(data => {
                this.isSmallBusiness = data;
            })
            .catch(error => {
                console.log('error--' + error);
            });

    }




    getQueryParameters() {

        var params = {};
        var search = location.search.substring(1);

        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }

        return params;
    }

    handleBack(event) {
        this.template.querySelector('.myDIV').style.display = "block";
        this.template.querySelector('.SearchDiv').style.display = "none";
        this.listView = true;
        this.pageContentChange();

    }

    handleGetAccDetail(event) {
        //  this.template.querySelector('.spinnerDiv').style.display = "block";
        var aId = event.currentTarget.id;
        this.getAccid(aId.split("-")[0], event.target.dataset.item)
        this.getAccserid(aId.split("-")[0])
        this.template.querySelector('.SearchDiv').style.display = "block";
        this.template.querySelector('.myDIV').style.display = "none";
        this.listView = false;
        this.pageContentChange();
        setInterval(() => {
            // this.template.querySelector('.spinnerDiv').style.display = "block";

        }, 2500);
    }


    renderedCallback() {
        Promise.all([
            loadScript(this, ODS_JqueryUpdated)


        ]).then(() => {
            // console.log('done.')
        })
            .catch(error => {
                this.error = error;
                // console.log(' Error Occured-- ', +error);
            });

    }

    getCustomertable(accid, serid) {
        getClientCustomer({ accountId: accid, serviceId: serid })
            .then(data => {
                this.items = data;
                // console.log(JSON.stringify(this.items))

                //pagination

                this.totalRecountCount = data.length;
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
                if (this.totalPage == 0) {
                    this.page = 0;
                    this.isNext = true
                    this.isPrev = true

                }
                else if (this.totalPage == 1) {
                    this.page = 1
                    this.isNext = true
                    this.isPrev = true
                }
                else {
                    this.page = 1
                    this.isPrev = true
                    this.isNext = false
                }


                this.customerList = this.items.slice(0, this.pageSize);
                //  console.log('data:' + JSON.stringify(items));
                this.endingRecord = this.pageSize;


            })
            .catch(error => {
                console.log(error);
                this.error = error;
            });
    }

    getAccid(accid, serid) {

        getCustomerDetails({ accountId: accid, serviceId: serid })
            .then(data => {
                // console.log('welcome data : ' + JSON.stringify(data));
                // console.log('TAM :' + data);
                this.tamName = data.nameTam;
                // console.log('Data 2:' + JSON.stringify(this.tamName));
                this.tamPhone = data.phoneTam;
                this.tamEmail = data.emailTam;
                this.bcsmname = data.backupcsmname;
                this.bcsmphone = data.backupcsmphone;
                this.bcsmemail = data.backupcsmemail;
                this.CSEname = data.CSENames;
                this.CSEEmail = data.CSEmails;
                this.CSEPhone = data.CSEphos;
                this.AccMan = data.AccMname;
                this.AccPhone = data.AccMemail;
                this.AccEmail = data.AccMphone;
                this.accountname = data.accname;
                this.ServName = data.ServiceName;
                this.website = data.webs;
                this.billingaddress = data.billingadd;
                this.csdate = data.cssdate;
                this.cedate = data.cendsdate;
                this.Retainerfee = '$' + data.Retfeeamount;
                this.ODSHourlyRate = '$' + data.ODSHoursrateAmount;
                this.RetainerFeeFrequency = data.RetainerFFT;
                this.CustomerPortal = data.CustomerPortalD;
                this.CustomerPortalAcccess = data.CustomerPortalAcc;
                this.SetupWeekMonthMeeting = data.SetupWeekMonMeeting;
                this.onboardingdocument = data.onboardingdoc;
                this.Lightingreadinescheck = data.Lightingreadcheck;
                this.ObjCon = data.ContDetails;

            })
            .catch(error => {
                console.log(error);
                this.error = error;

            });
    }


    getAccserid(accid) {
        getCustomerServices({ accountId: accid })
            .then(data => {
                console.log(data);
                var conts = data;
                for (var key in conts) {
                    this.Accoutser.push({ value: conts[key], key: key }); //Here we are creating the array to show on UI.
                    // console.log("Table....." + JSON.stringify(this.Accoutser));
                }
            })
            .catch(error => {
                console.log(error);
                this.error = error;
            });
    }


    //Pagination methods
    //clicking on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //clicking on next button this method will be called
    nextHandler() {
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
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
    displayRecordPerPage(page) {

        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount)
            ? this.totalRecountCount : this.endingRecord;

        this.data = this.items.slice(this.startingRecord, this.endingRecord);

        this.startingRecord = this.startingRecord + 1;


        this.isNext = (this.page == this.totalPage || this.totalPage == 0);
        this.isPrev = (this.page == 1 || this.totalRecountCount < this.page);


    }


    // send value to VF page:

    listView = true;

    pageContentChange() {
        const contextData = {
            showAccount: this.listView


        };

        //to send to VF Page
        this.dispatchEvent(new CustomEvent(
            'contentChange',
            {
                detail: { data: contextData },
                bubbles: true,
                composed: true,
            }
        ));
    }

}
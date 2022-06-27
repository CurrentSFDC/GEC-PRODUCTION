/**
 * Created by Paksy Andras on 2021. 03. 22..
 */

import { LightningElement, api, track, wire } from 'lwc';
import getProdFamilies from '@salesforce/apex/StockBalancingReturnLwcController.getProductFamilies';
import getPriceAgreements from "@salesforce/apex/ClaimBackController.getPriceAgreements";
/*import getAgreedProductPrices from '@salesforce/apex/StockBalancingReturnLwcController.getAgreedProductPrices';
import getAccName from '@salesforce/apex/StockBalancingReturnLwcController.getAccountName';*/
import sendClaimToSAP from '@salesforce/apex/ClaimBackController.sendClaimToSAP';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// USED FOR GETTING THE USER DATA - WITHOUT APEX CALL
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import PHONE_FIELD from '@salesforce/schema/User.Phone';
import CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';

import { loadStyle } from 'lightning/platformResourceLoader';
import hideButtonsCss from '@salesforce/resourceUrl/hidebuttonscss';

const ACCOUNT_INFO_STEP = 'accountinfo';
const PRODUCT_ENTRY_STEP = 'productentry';
const REVIEW_STEP = 'review';
const THANK_YOU_STEP = 'thankyou';

import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/selectedAccount__c';

export default class ClaimBack extends LightningElement {
    @api transactionID;
    @api files;
    @api accountID;
    @api accountName;
    hideIfDistributor = localStorage.getItem('User Type') == 'Distributor' ? 'slds-hide' : '';
    @track currentStep = 'accountinfo';
    @track reqName;
    @track reqEmail;
    @track reqPhone;
    @track returnRefNumber;
    @track requestedAction;
    @track comments;
    @api account;
    soldToAccount;
    soldToAccountId;
    accountCurrency;
    @api shipToAccount;
    @api remainingReturns;
    @api productValidationErrorMessage;

    @track nextDisabled = true;
    @track nextLabel = 'Loading account details, please wait...';
    @track SAPOrderNumber = 'Sending request, please wait...';
    @track toggleSubmitLabel = "Submit";
    @track toggleValidationLabel = "Validate & Next"

    @track filesToInsert = [];
    @track lstAllFiles = [];
    @api caseProductInsert = [];
    @api fileToDelete;
    @track caseNumberNew;
    @track prodFamilies = [];
    @track priceAgreementNumbers = [];

    @track invoices = [];
    @track mainData = {};
    @track manualUpload = false;
    @track steps = {
        'accountinfo' : true,
        'productentry' : false,
        'review' : false,
        'thankyou' : false,
    };

        get isDistributor() {
            return localStorage.getItem('User Type') == 'Distributor';
        }

    // GET CURRENT LOGGED IN COMMUNITY USER INFORMATION
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD, EMAIL_FIELD, PHONE_FIELD, CONTACT_FIELD, ACCOUNT_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {

            let internalUser = localStorage.getItem('internalName');
                if(internalUser != null){
                    this.mainData.reqName = localStorage.getItem('internalName');
                    this.mainData.reqEmail = localStorage.getItem('internalUserName');
                    this.mainData.reqPhone = localStorage.getItem('internalUserPhone');
                } else {


                    this.mainData.reqEmail = data.fields.Email.value;
                    this.mainData.reqName = data.fields.Name.value;
                    this.mainData.reqPhone = data.fields.Phone.value;
                
                }
                this.mainData.contactID = data.fields.ContactId.value;
                this.mainData.accountID = data.fields.AccountId.value;
                this.accountID = data.fields.AccountId.value;
                this.convertPhone(this.mainData.reqPhone);

                //init with account selector
                this.accountID = localStorage.getItem('AgentID');
        }
    }

    @wire(getRecord, { 
        recordId: '$accountID', fields: ['Account.Name']})
        wiredaccount({ error, data }) {
        if(data){
            console.log(this.accountID);
            console.log(JSON.stringify(data));
            this.mainData.mainAccountName = data.fields.Name.value;
            console.log('acc data ',data);
        }
    }
    //--------------------------------------------------

    @track columns = [
        { label: 'Name', fieldName: 'Title', type: 'text' },
        { label: 'Type', fieldName: 'FileExtension', type: 'text' },
    ];

    agentCodes;
    get agentCodeOptions() {
        if (this.agentCodes == null || this.agentCodes == undefined || this.agentCodes == '') {
            return [];
        } else {
            var agentCodesArray = [];
            if (this.agentCodes.includes(",")) {
                agentCodesArray = this.agentCodes.split(',')
            } else if (this.agentCodes.includes(";")) {
                agentCodesArray = this.agentCodes.split(';')
            } else {
                agentCodesArray.push(this.agentCodes);
            }

            var agentCodeOptionSet = [];
            for (var i = 0; i < agentCodesArray.length; i++) {
                agentCodeOptionSet.push({ label: agentCodesArray[i], value: agentCodesArray[i] });
            }
            return agentCodeOptionSet
        }
    }

    handleAccountDataChange(event){
        this.mainData[event.target.dataset.fieldname] = event.target.value;
        console.log(JSON.stringify(this.mainData));
    }

    async handleSoldToAccountLookupSelect(event) {
        this.nextDisabled = true;
        this.nextLabel = 'Loading account details, please wait...';
        this.soldToAccount = event.detail.selectedAccount;
        console.log('handleSoldToAccountLookupSelect ',JSON.stringify(this.soldToAccount));
        this.soldToAccountId = this.soldToAccount.Id;
        this.agentCodes = this.soldToAccount.ConnectFixtureAgents__c;
        this.accountCurrency = this.soldToAccount.CurrencyIsoCode;
        var accountData = {};
        accountData.GE_LGT_EM_SAP_Customer_Number__c = this.soldToAccount.GE_LGT_EM_SAP_Customer_Number__c;
        accountData.GE_LGT_EM_Sales_Org__c = this.soldToAccount.GE_LGT_EM_Sales_Org__c;
        accountData.GE_LGT_EM_Distribution_Channel__c = this.soldToAccount.GE_LGT_EM_Distribution_Channel__c;
        accountData.GE_LGT_EM_Division__c = this.soldToAccount.GE_LGT_EM_Division__c;
        if (this.isDistributor) {
            this.accountID = this.soldToAccountId;
            this.mainData.accountID = this.soldToAccountId;
        }
        await getProdFamilies({ soldToAccId: this.soldToAccountId, agentAccId: this.accountID != null ? this.accountID : this.mainData.accountID })
        .then(result => {
            this.prodFamilies = result;
        })
        .catch(error => {
            console.log(error);
            this.error = error;
        });

        await getPriceAgreements({ agentId: this.soldToAccount.GE_LGT_EM_SAP_Customer_Number__c })
        .then(result => {
            console.log('thgis: ',this.soldToAccount.GE_LGT_EM_SAP_Customer_Number__c);
            this.priceAgreementNumbers = result;
            this.nextDisabled = false;
            this.nextLabel = 'Next';
        })
        .catch(error => {
            console.log(error);
            this.error = error;
        });
        console.log('PA Numbers', JSON.stringify(this.priceAgreementNumbers));
        this.mainData.soldToAccName = (this.soldToAccount != null && this.soldToAccount != undefined) ? this.soldToAccount["Name"] : '';
        this.mainData.soldToAccountId = this.soldToAccount.Id;
        var mapSourceAccObj = (this.soldToAccount != null && this.soldToAccount != undefined) ? this.soldToAccount.ShippingAddress : {};
        this.mainData.mapCountry = mapSourceAccObj["country"];
        this.mainData.mapCity = mapSourceAccObj["city"];
        this.mainData.mapState = mapSourceAccObj["state"];
        this.mainData.mapStreet = mapSourceAccObj["street"];
        this.mainData.currency = this.soldToAccount.CurrencyIsoCode;
        this.mainData.mapMarker = [{
            location: {
                Country: this.mainData.mapCountry,
                City: this.mainData.mapCity,
                State: this.mainData.mapState,
                Street: this.mainData.mapStreet
            }}];

        console.log(JSON.stringify(this.mainData));
    }

    handleSoldToAccountLookupReset() {
        this.soldToAccount = null;
        this.soldToAccountId = null;
        this.mainData.soldToAccName = '';

        this.mainData.mapMarker = [{}];
    }

    handleAccountChange(event) {
        console.log('handleAccountChange ',handleAccountChange);
        this.mainData.account = event.target.value;
    }

    handleInvoiceDataChange(event) {
        this.mainData.invoices = event.detail;
        console.log(JSON.stringify(this.mainData));
    }

    //USED TO INSERT CASE RECORD ONCE USER SELECTS SUBMIT IN STEP THREE (REVIEW)
    async handleSave(event) {
        this.toggleSubmitLabel = "Submitting...";
        this.goToStepFour();
    }

    // FOLLOWING METHODS ARE FOR PROGRESSING THROUGH THE SCREENS
    goToStep(event){
        console.log('this.currentStep ',this.currentStep);
        if(event.target.dataset.validate === 'validate'){
            let allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

            let soldToAccountComponent = this.template.querySelector('c-sold-to-account-lookup');
            if(soldToAccountComponent){
                if(!soldToAccountComponent.reportValidity()) allValid = false;
            }
            
            let productEntryComponent = this.template.querySelector('c-claim-back-product-entry');
            if(productEntryComponent){
                if(!productEntryComponent.reportValidity()) allValid = false;
            }
            if (this.currentStep == 'productentry') {
                if (JSON.stringify(this.mainData.invoices).includes('Invalid Catalog Number:')) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'ERROR',
                            message: 'There are invalid products in the list, please correct them',
                            variant: 'error'
                        })
                    );
                    return;
                }
                if (JSON.stringify(this.mainData.invoices).includes('badPaNo')) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'ERROR',
                            message: 'Please fill out all Required Fields',
                            variant: 'error'
                        })
                    );
                    return;
                }
                for(var i of this.mainData.invoices){
                    for(var prod of i.products){
                        if (parseFloat(prod['gecPrice']) < parseFloat(prod['priceAgreementPrice'])) {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'ERROR',
                                    message: 'GEC Price cannot be lower than Price Agreement Price',
                                    variant: 'error'
                                })
                            );
                            return;
                        }
                    }
                }
            }
            /*if (this.currentStep == 'accountinfo') {
                        if (!JSON.stringify(this.priceAgreementNumbers).includes('Agreement_No__c')) {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'ERROR',
                                    message: 'No Price Agreements found for the selected account or they are expired!',
                                    variant: 'error'
                                })
                            );
                            return;
                        }
            }*/

            console.log(JSON.stringify(this.mainData.invoices));
            
            if (!allValid) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'ERROR',
                        message: 'Please fill out all Required Fields',
                        variant: 'error'
                    })
                );
                return;
            }
        }
        
        this.currentStep = event.target.dataset.targetstep;
        console.log('this.currentStep after ',this.currentStep);
        this.comments = this.mainData['comments'];

        for(var step in this.steps){
            if(this.currentStep === step){
                this.steps[step] = true;
            }
            else{
                this.steps[step] = false;
            }
        }

        console.log(JSON.stringify(this.mainData));

        if(event.target.dataset.save === 'save'){
            this.handleSAPSubmit();
        }
    }

    handleSAPSubmit(){
        this.mainData.accountID = this.isDistributor ? this.soldToAccountId : this.accountID;
        this.mainData.soldToAccountId = this.isDistributor ? '' : this.soldToAccountId;
        sendClaimToSAP({ invoiceData: this.mainData })
        .then(result => {
            console.log(result);
            this.SAPOrderNumber = this.mainData.returnRefNumber;
        })
        .catch(error => {
            console.log(error);
            this.error = error;
            this.SAPOrderNumber = 'Request failed!';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ERROR',
                    message: 'An error has occurred while sending Claimback request:' + error,
                    variant: 'error'
                })
            );
        });
    }


    async handlePhoneChange(event){
        const myValue = this.template.querySelector(".rp");
        console.log('Phone Number being entered: '+myValue);

        const formattedNumber = this.formatPhoneNumber(myValue.value);        
        this.mainData.reqPhone = formattedNumber;
    }

    convertPhone(phone){
        var cleaned = ('' + phone).replace(/\D/g, '');
        var match = cleaned.match(/^(\d{3})(\d{3})(\d{4})$/);
        if (match) {
          this.mainData.reqPhone = '(' + match[1] + ') ' + match[2] + '-' + match[3];
        }
        return null;
    }

    formatPhoneNumber(value){
        // if input value is falsy eg if the user deletes the input, then just return
            if (!value) return value;

            // clean the input for any non-digit values.
            const phoneNumber = value.replace(/[^\d]/g, "");

            // phoneNumberLength is used to know when to apply our formatting for the phone number
            const phoneNumberLength = phoneNumber.length;

            // we need to return the value with no formatting if its less then four digits
            // this is to avoid weird behavior that occurs if you  format the area code to early
            if (phoneNumberLength < 4) return phoneNumber;

            // if phoneNumberLength is greater than 4 and less the 7 we start to return
            // the formatted number
            if (phoneNumberLength < 7) {
                return `(${phoneNumber.slice(0, 3)}) ${phoneNumber.slice(3)}`;
            }

            // finally, if the phoneNumberLength is greater then seven, we add the last
            // bit of formatting and return it.
            return `(${phoneNumber.slice(0, 3)}) ${phoneNumber.slice(
                3,
                6
            )}-${phoneNumber.slice(6, 9)}`;
    }

    @wire(MessageContext)
        messageContext;

        // Encapsulate logic for Lightning message service subscribe and unsubsubscribe
       async subscribeToMessageChannel() {
            if (!this.subscription) {
                this.subscription = subscribe(
                    this.messageContext,
                    recordSelected,
                    (message) => this.handleMessage(message),
                    {scope: APPLICATION_SCOPE}
                );
            }
        }

    renderedCallback() {
        Promise.all([loadStyle(this, hideButtonsCss)]);
        this.subscribeToMessageChannel();
        document.title = 'Claimback';
        this.template.querySelector('.slds-is-active').classList.remove('slds-is-active');
    }

    async handleMessage(message) {
        console.log('Account selector changing ',message);
        this.accountID = message.recordId;
        if (!message.distributorID || message.distributorID == ' ') this.soldToAccount = null;
    }

}
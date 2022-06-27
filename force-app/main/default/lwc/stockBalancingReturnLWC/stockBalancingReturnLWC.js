/**
 * Created by Paksy Andras on 2021. 03. 22..
 */

import { LightningElement, api, track, wire } from 'lwc';
import createCaseRecord from '@salesforce/apex/StockBalancingReturnLwcController.connectCreateReturnCase';
import createDisputeRequest from '@salesforce/apex/StockBalancingReturnLwcController.connectCreateReturnDisputeRequest';
import createCaseProduct from '@salesforce/apex/StockBalancingReturnLwcController.createCaseProduct';
import getCaseNumber from '@salesforce/apex/StockBalancingReturnLwcController.getCaseNumber';
import getRemainingReturns from '@salesforce/apex/StockBalancingReturnLwcController.getNoOfRemainingReturns';
import getProdFamilies from '@salesforce/apex/StockBalancingReturnLwcController.getProductFamilies';
import getAgentNames from '@salesforce/apex/StockBalancingReturnLwcController.getAgentNames';
import getReturnsQueueId from '@salesforce/apex/connectCreateCase.getReturnsQueueId';
import getAgreedProductPrices from '@salesforce/apex/StockBalancingReturnLwcController.getAgreedProductPrices';
import getAccName from '@salesforce/apex/StockBalancingReturnLwcController.getAccountName';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

// USED FOR GETTING THE USER DATA - WITHOUT APEX CALL
import { getRecord  } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import PHONE_FIELD from '@salesforce/schema/User.Phone';
import CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';

import { loadStyle } from 'lightning/platformResourceLoader';
import hideButtonsCss from '@salesforce/resourceUrl/hidebuttonscss';

import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/selectedAccount__c';

const STOCK_BALANCING_RETURNS_ONLINE = "stockBalancingReturnsOnline";
const STOCK_BALANCING_RETURNS_FILE_UPLOAD = "stockBalancingReturnsFileUpload";
const STOCK_ACCOMODATION_RETURN = "stockAccomodationReturn";
const QUICKSTOCK_RETURN = "QuickStockReturn";

export default class StockBalancingReturnLwc extends LightningElement {
    @api transactionID;
    @api files;
    @api accountID;
    @api accountName;
    @api caseId;
    @api disputeRequestId;
    @track currentStep;
    @track reqName;
    @track reqEmail;
    @track reqPhone;
    @track returnRefNumber;
    @track requestedAction;
    @track comments;
    @api account;
    @api soldToAccount;
    @api soldToAccountId;
    @api shipToAccount;
    @api remainingReturns;
    @api productValidationErrorMessage;
    @track caseOwnerId;
    accountCurrency;

    @track toggleSubmitLabel = "Submit";
    @track toggleValidationLabel = "Validate & Next"

    @track filesToInsert = [];
    @track lstAllFiles = [];
    @api caseProductInsert = [];
    @api fileToDelete;
    @track caseNumberNew;
    @track prodFamilies = [];

    @track products = [];
    @track manualUpload = false;

    hideIfDistributor = localStorage.getItem('User Type') == 'Distributor' ? 'slds-hide' : '';

    handleProductChange(event) {
        this.products = event.detail;
      }

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
        this.error = error ;
        } else if (data) {

            const id = 'id' + performance.now();
            this.transactionID = id;
            console.log('Generated ID: '+ id);

            console.log('Setting the Transcation ID: '+this.transactionID);

            let internalUser = localStorage.getItem('internalName');
            if(internalUser != null){
                    this.reqName = localStorage.getItem('internalName');
                    this.reqEmail = localStorage.getItem('internalUserName');
                    this.reqPhone = localStorage.getItem('internalUserPhone');
            } else {
                this.reqEmail = data.fields.Email.value;
                this.reqName = data.fields.Name.value;
                this.reqPhone = data.fields.Phone.value;
                this.contactID = data.fields.ContactId.value;
                this.convertPhone(this.reqPhone);
                if(localStorage.getItem('AgentID') != null && localStorage.getItem('AgentID') != undefined){
                    this.accountID = localStorage.getItem('AgentID');
                } else {
                    this.accountID = data.fields.AccountId.value;
                }
            }
        }
    }
//--------------------------------------------------

    @track columns = [
        { label: 'Name', fieldName: 'Title', type: 'text' },
        { label: 'Type', fieldName: 'FileExtension', type: 'text' },
    ];

    selectedOrderType = this.orderTypeOptions[0].value;
    get orderTypeOptions(){
        return [
                {label: "Online", value: STOCK_BALANCING_RETURNS_ONLINE},
                {label: "File Upload", value: STOCK_BALANCING_RETURNS_FILE_UPLOAD}
        ];
    }

    handleOrderTypeChange(event) {
        this.selectedOrderType = event.detail.value;
    }

    selectedReturnType = this.returnTypeOptions[0].value;
    get returnTypeOptions(){
        return [
                {label: "Stock Accommodation Return", value: STOCK_ACCOMODATION_RETURN},
                {label: "QuickStock Return", value: QUICKSTOCK_RETURN}
        ];
    }

    handleReturnTypeChange(event) {
        this.selectedReturnType = event.detail.value;
    }

    agentCodes;
    agentNames;
    get agentCodeOptions(){
        if(this.agentCodes == null || this.agentCodes == undefined || this.agentCodes == '' || this.agentNames == null || this.agentNames == undefined || this.agentNames == ''){
            return [];
        } else {
            var agentCodesArray = [];
            var agentNamesArray = this.agentNames.split(';');
            if(this.agentCodes.includes(",")){
                agentCodesArray = this.agentCodes.split(',')
            } else if(this.agentCodes.includes(";")){
                agentCodesArray = this.agentCodes.split(';')
            } else {
                agentCodesArray.push(this.agentCodes);
            }

            var agentCodeOptionSet = [];
            for(var i = 0; i < agentCodesArray.length; i++){
                agentCodeOptionSet.push({label: agentNamesArray[i], value: agentCodesArray[i]});
            }
            return agentCodeOptionSet
        }
    }

    async handleSoldToAccountLookupSelect(event) {
        this.soldToAccount = event.detail.selectedAccount;
        this.soldToAccountId = this.soldToAccount.Id;
        if (this.soldToAccount.GE_LGT_EM_SAP_Customer_Number__c == '0000308094' || this.soldToAccount.GE_LGT_EM_SAP_Customer_Number__c == '0009140000') {
            this.agentCodes = this.soldToAccount.Connect_Share_with_Account_PartA__c;
            if (this.soldToAccount.Connect_Share_with_Account_PartB__c != null && this.soldToAccount.Connect_Share_with_Account_PartB__c != '') {
                this.agentCodes = this.agentCodes + ',' + this.soldToAccount.Connect_Share_with_Account_PartB__c;
            }
            if (this.soldToAccount.Connect_Share_with_Account_PartC__c != null && this.soldToAccount.Connect_Share_with_Account_PartC__c != '') {
                this.agentCodes = this.agentCodes + ',' + this.soldToAccount.Connect_Share_with_Account_PartC__c;
            }
        } else {
            this.agentCodes = this.soldToAccount.ConnectFixtureAgents__c;
        }
        await getAgentNames({agentCodes: this.agentCodes})
            .then(result => {
                console.log('AgentName returned: ' + result);
                this.agentNames = result;
            })
            .catch(error => {
                console.log(error);
                this.error = error;
            });
        this.accountCurrency = this.soldToAccount.CurrencyIsoCode;
        console.log(JSON.stringify(this.soldToAccount));
        var accountData = {};
        accountData.GE_LGT_EM_SAP_Customer_Number__c = this.soldToAccount.GE_LGT_EM_SAP_Customer_Number__c;
        accountData.GE_LGT_EM_Sales_Org__c = this.soldToAccount.GE_LGT_EM_Sales_Org__c;
        accountData.GE_LGT_EM_Distribution_Channel__c = this.soldToAccount.GE_LGT_EM_Distribution_Channel__c;
        accountData.GE_LGT_EM_Division__c = this.soldToAccount.GE_LGT_EM_Division__c;
        console.log(accountData);
        if (this.isDistributor) {
            this.accountID = this.soldToAccountId;
        }

        console.log('SoldToAccountID: ' + this.soldToAccountId);
        console.log('AgentAccountID: ' +this.accountID);

        await getProdFamilies({soldToAccId: this.soldToAccountId, agentAccId: this.accountID})
           .then(result => {
           this.prodFamilies = result;
           console.log('getProdFamilies:' + result);
           })
           .catch(error => {
               console.log(error);
               this.error = error;
           });

        await getRemainingReturns({account: JSON.stringify(accountData)})
           .then(result => {
           this.remainingReturns = result;
           console.log(this.remainingReturns);
           })
           .catch(error => {
               console.log(error);
               this.error = error;
           });
    }

    handleSoldToAccountLookupReset() {
        this.soldToAccount = null;
        this.soldToAccountId = null;
        this.handleShipToAccountLookupReset();
    }

    handleShipToAccountLookupSelect(event) {
        this.shipToAccount = event.detail.selectedAccount;
    }

    handleShipToAccountLookupReset() {
        this.shipToAccount = null;
    }

    get isStockBalancingReturnsFileUpload() {
        return this.selectedOrderType === 'stockBalancingReturnsFileUpload';
    }

    get isReturnNumberNotNull(){
        if(this.remainingReturns != null && this.remainingReturns != undefined){
            return true
        } else{
            return false
        }
    }

    handleAccountChange(event){
        this.account = event.target.value;
    }

    //USED TO INSERT CASE RECORD ONCE USER SELECTS SUBMIT IN STEP THREE (REVIEW)
    async handleSave(event){
        this.toggleSubmitLabel = "Submitting...";

        //Case setup with static field values
        let nCase = { 'sobjectType': 'Case' };
        nCase.RecordTypeId = ''; //recordTypeId will be set in apex
        nCase.Status = 'Open';
        nCase.GE_NAS_Sub_Status__c = 'In Process';
        nCase.Priority = 'Medium';
        nCase.GE_NAS_Customer_Impact__c = '1-Customer OK';
        nCase.Type = 'Returns';
        if(this.selectedReturnType == QUICKSTOCK_RETURN){
            nCase.GE_NAS_Sub_Type__c = 'Quick Stock Return';
            nCase.Subject = 'Quick Stock Return';
        } else {
            nCase.GE_NAS_Sub_Type__c = 'Stock Balancing Return';
            nCase.Subject = 'Stock Balancing Return';
        }
        nCase.Origin = 'Connect';
        nCase.eLight_Form_Type__c = 'Stock Balancing Return';
        nCase.OwnerId = this.caseOwnerId;

        //Case setup with received field values
            console.log('GE_NAS_Purchase_Order__c: ' + this.template.querySelector(".rrn").value);
        nCase.GE_NAS_Purchase_Order__c = this.template.querySelector(".rrn").value;
        nCase.AccountId = this.accountID;
        nCase.ContactId = this.contactID;
        nCase.eLight_Requestor_Name__c = this.template.querySelector(".rn").value;
        nCase.Requestor_Email__c = this.template.querySelector(".em").value;
        nCase.eLight_Requestor_Phone__c = this.template.querySelector(".rp").value;
        nCase.SuppliedEmail = this.template.querySelector(".em").value;
        nCase.SuppliedPhone = this.template.querySelector(".rp").value;
        nCase.Site_Contact_Email__c = this.template.querySelector(".em").value;
        nCase.Site_Contact_Name__c = this.template.querySelector(".rn").value;
        nCase.Site_Contact_Phone__c = this.template.querySelector(".rp").value;
        nCase.eLight_Comments__c = this.template.querySelector(".cm").value;

        if(this.soldToAccount != null && this.soldToAccount != undefined){
            nCase.Sold_To_Account__c = this.soldToAccount["Id"];
            nCase.eLight_Sold_To__c = this.soldToAccount["Name"];
            var address = this.soldToAccount.ShippingAddress;
            nCase.eLight_Address_2__c = address["street"] + "\n" + address["city"] + ', ' + address["state"] + ' ' + address["postalcode"] + "\n" + address["country"];
        }

        if(this.shipToAccount != null && this.shipToAccount != undefined){
                                console.log('EMEA_Ship_to_Account_Name__c: ' + this.shipToAccount["Id"]);
            nCase.EMEA_Ship_to_Account_Name__c = this.shipToAccount["Id"];
                                console.log('Ship_to_Account__c: ' + this.shipToAccount["Name"]);
            nCase.Ship_to_Account__c  = this.shipToAccount["Name"];
        }

           // STEP 1 - CREATE CASE
         await  createCaseRecord({newCase: nCase})
         .then(result => {
             this.caseId = result;})
         .catch(error => {
             console.log(error);
             this.error = error;
         });

         //Create Dispute Request
            let nDispute = { 'sobjectType': 'Dispute_Request__c' };
            nDispute.Case__c = this.caseId;
            nDispute.Customer_PO__c = this.template.querySelector(".rrn").value;
            nDispute.Requestor_Email__c = this.template.querySelector(".em").value;
            nDispute.Status__c = 'Pending Action';
            nDispute.SAP_Doc_Type__c = "ZRE";
            nDispute.Transaction_ID__c = "" //transaction ID???;
            nDispute.Sold_To__c = this.soldToAccountId;

            //STEP 2 - CREATE DISPUTE REQUEST
            await  createDisputeRequest({newDisputeRequest: nDispute})
            .then(result => {
                this.disputeRequestId = result;

            //Create Case Products
             var caseProductsToInsert = [];
             for(var i = 0; i < this.products.length; i++){
                 console.log('I = '+ i);
                 if(this.products[i].materialMaster != null && this.products[i].materialMaster != undefined){
                     //Case Product setup with static field values
                     let nCaseProduct = {'sobjecttype': 'Shipment_Detail__c'};
                     nCaseProduct.GE_NAS_Type_of_Problem__c = 'Return - Return';
                     nCaseProduct.GE_NAS_Type_of_Problem1__c = 'Return';


                     //Case Product setup with received field values
                     nCaseProduct.Unique_ID__c = this.template.querySelector(".rrn").value+'-StockBalancingReturn-'+ this.contactID+'-'+this.transactionID+'-'+this.products[i].lineNumber
                     nCaseProduct.GE_NAS_Case_Number__c = this.caseId;
                     nCaseProduct.Dispute_Request__c = this.disputeRequestId;
                     nCaseProduct.Material_Number__c = this.products[i].materialMaster.Id;
                     nCaseProduct.Product_Number__c = this.products[i].materialMaster.ccProductId;
                     nCaseProduct.Discrepancy_Qty__c = this.products[i].returnQuantity;
                     nCaseProduct.GE_NAS_RAP_Qty__c = this.products[i].returnQuantity;
                     nCaseProduct.GE_NAS_Unit_of_Measure__c = this.products[i].uom;
                     nCaseProduct.Invoiced_Price__c = parseFloat(this.products[i].price);
                     nCaseProduct.Rep_Code__c = this.products[i].agent;

                     caseProductsToInsert.push(nCaseProduct);
                     console.log('Items Pushed to CP List: '+ JSON.stringify(nCaseProduct));
                 }
             }

             console.log('Total: '+ caseProductsToInsert.length +'- Case Products to Insert: '+ JSON.stringify(caseProductsToInsert));
             createCaseProduct({newCaseProduct : caseProductsToInsert});

             console.log(result);
         })
         .catch(error => {
             console.log(error);
             this.error = error;
         });
      await getCaseNumber({caseId: this.caseId})
         .then(result => {
         this.caseNumberNew = result;
         console.log(JSON.stringify("The Result for Case Number: "+ JSON.stringify(this.caseNumberNew)))
         this.goToStepFour();
         })
         .catch(error => {
             console.log(error);
             this.error = error;
         });
    }

    // FOLLOWING METHODS ARE FOR PROGRESSING THROUGH THE SCREENS
    goBackToStepOne() {
        this.currentStep = '1';

        this.template.querySelector('div.stepTwo').classList.add('slds-hide');
        this.template
            .querySelector('div.stepOne')
            .classList.remove('slds-hide');
    }

    moveOn(){
        this.stepOneButton = false;
        this.goToStepTwo();
    }

    handleValidation(){

        let acctName = this.template.querySelector('.acc').value;
        if (!acctName || this.soldToAccount == null){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ERROR',
                    message: 'Please fill out all Required Fields',
                    variant: 'error'
                })
            );
        } else {

            const allValid = [...this.template.querySelectorAll('.validValue')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
                if (allValid) {
                    this.stepOneButton = false;
                    this.goToStepTwo();
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'ERROR',
                            message: 'Please fill out all Required Fields',
                            variant: 'error'
                        })
                    );
                }
        }
    }

    goToStepTwo() {
        this.currentStep = '2';

        this.template.querySelector('div.stepOne').classList.add('slds-hide');
        this.template
            .querySelector('div.stepTwo')
            .classList.remove('slds-hide');

    }

    goBackToStepTwo() {
        this.toggleValidationLabel = "Validate & Next";
        this.currentStep = '2';

        this.template.querySelector('div.stepThree').classList.add('slds-hide');
        this.template
            .querySelector('div.stepTwo')
            .classList.remove('slds-hide');
    }

    productLineValidation(){
        var allProductsAreOk;
        for(var i = 0; i < this.products.length; i++){
            if(event.detail.selectedMaterial == null || event.detail.selectedMaterial == undefined){
                this.orderItems[index].validationComment = 'Please select a valid product'
                allProductsAreOk = false;
            } else if(products[index].returnQuantity == null || products[index].returnQuantity == undefined || products[index].returnQuantity <= 0){
                this.orderItems[index].validationComment = 'Please add the return quantity'
                allProductsAreOk = false;
            } else if(orderItems[index].uom == null || orderItems[index].uom == undefined){
                this.orderItems[index].validationComment = 'Please select the unit of measure'
                allProductsAreOk = false;
            } else {
                this.orderItems[index].validationComment = '';
                allProductsAreOk = true;
            }
        }
        return allProductsAreOk;
    }

    async stepThreeValidation() {
        this.toggleValidationLabel = "Product Validation..."
        console.log(this.products.length);
        if (this.products.length != 0) {
            var soldToAccountData = {};
            soldToAccountData.GE_LGT_EM_SAP_Customer_Number__c = this.soldToAccount.GE_LGT_EM_SAP_Customer_Number__c;
            soldToAccountData.GE_LGT_EM_Sales_Org__c = this.soldToAccount.GE_LGT_EM_Sales_Org__c;
            soldToAccountData.GE_LGT_EM_Distribution_Channel__c = this.soldToAccount.GE_LGT_EM_Distribution_Channel__c;
            soldToAccountData.GE_LGT_EM_Division__c = this.soldToAccount.GE_LGT_EM_Division__c;
            console.log(soldToAccountData);

            var prodList = [];
            for(var i = 0; i < this.products.length; i++){
               console.log('I = '+ i);
               if(this.products[i].materialMaster == null || this.products[i].materialMaster == undefined){
                   this.toggleValidationLabel = "Validate & Next"
                       this.dispatchEvent(
                           new ShowToastEvent({
                               title: 'ERROR',
                               message: 'Please select Product Master for each line, or remove the empty lines',
                               variant: 'error'
                       })
                   );
               return;
               }
               if (this.products[i].returnQuantity == '' || parseInt(this.products[i].returnQuantity) < 1) {
                   this.toggleValidationLabel = "Validate & Next"
                       this.dispatchEvent(
                           new ShowToastEvent({
                               title: 'ERROR',
                               message: 'Please fill quantity for each line, or remove unneeded lines',
                               variant: 'error'
                           })
                   );
                   return;
               }
               if (this.products[i].uom == '') {
                   this.toggleValidationLabel = "Validate & Next"
                       this.dispatchEvent(
                           new ShowToastEvent({
                               title: 'ERROR',
                               message: 'Please select Unit of Measure for each line',
                               variant: 'error'
                       })
                   );
                   return;
               }
               let prod = {};
               prod.lineNo = this.products[i].lineNumber;
               prod.itemNo = this.products[i].materialMaster.GE_LGT_EM_SAP_MaterialNumber__c;
               prod.itemDesc = this.products[i].materialMaster.GE_LGT_EM_MaterialDescription__c;
               prod.qty = this.products[i].returnQuantity;
               prod.uom = this.products[i].uom;
               console.log(JSON.stringify(prod));
               prodList.push(JSON.stringify(prod));
            }
            await getAgreedProductPrices({productList: prodList, soldToAccount: JSON.stringify(soldToAccountData), currentUserAccountId: this.accountID})
               .then(result => {
                   console.log(JSON.stringify(result));
                   console.log(result.length);
                   for(var j = 0; j<result.length; j++){
                       console.log(result[j].lineNumber);
                       if(result[j].lineNumber == '000000'){
                           this.productValidationErrorMessage = result[j].ErrorMessage;
                           console.log('Error Message from Integration: ' + this.productValidationErrorMessage);
                       } else {
                           for(var i = 0; i < this.products.length; i++){
                               if(this.products[i].lineNumber == result[j].lineNumber){
                                   this.products[i].currency = result[j].currency;
                                   this.products[i].validationComment = result[j].validationComment;
                                   //this.products[i].priceAndCurrency = result[j].price + ' ' + result[j].currency;
                                   //this.products[i].price = "" + (parseFloat(result[j].price) / parseInt(this.products[i].returnQuantity));
                                   this.products[i].price = result[j].price;
                                   this.products[i].totalPrice = result[j].totalPrice;
                                   this.products[i].status = result[j].status;
                               }
                           }
                       }
                   }
               })
               .catch(error => {
                   console.log(error);
                   this.error = error;
               });
            this.goToStepThree();
        } else {
            this.toggleValidationLabel = "Validate & Next"
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ERROR',
                    message: 'Please add at least 1 Product',
                    variant: 'error'
                })
            );
        }
    }

    async goToStepThree() {

        this.currentStep = '3';

        if (this.isDistributor) {
            this.accountID = this.soldToAccountId;
        }

        this.template.querySelector('div.stepTwo').classList.add('slds-hide');
        this.template
            .querySelector('div.stepThree')
            .classList.remove('slds-hide');

        var mainData = {};
        console.log('MainData creation');
        console.log(this.accountID);
        await getAccName({accountId: this.accountID})
                    .then(result => {
                    this.accountName = result;
                    mainData.mainAccountName = result;
                    console.log(result);
                });
        mainData.reqName = this.template.querySelector(".rn").value;
        mainData.reqEmail = this.template.querySelector(".em").value;
        mainData.reqPhone = this.template.querySelector(".rp").value;
        mainData.refNumber = this.template.querySelector(".rrn").value;
        mainData.soldToAccName = (this.soldToAccount != null && this.soldToAccount != undefined) ? this.soldToAccount["Name"] : '';
        //mainData.shipToAccName = (this.shipToAccount != null && this.shipToAccount != undefined) ? this.shipToAccount["Name"] : '';
        mainData.comments = this.template.querySelector(".cm").value;

        await getReturnsQueueId({accountId : this.setAccountID})
        .then(result=>{
            if(result){
                this.caseOwnerId = result;
                console.log('SETTING CASE QUEUE....'+this.caseOwnerId);
            } 
        })

        var mapSourceAccObj = (this.soldToAccount != null && this.soldToAccount != undefined) ? this.soldToAccount.ShippingAddress : {};
        mainData.mapCountry = mapSourceAccObj["country"];
        mainData.mapCity = mapSourceAccObj["city"];
        mainData.mapState = mapSourceAccObj["state"];
        mainData.mapStreet = mapSourceAccObj["street"];

        this.template.querySelector("c-stock-balancing-return-review").provideDataToReview(mainData, this.products);

    }

    goToStepFour(){
        this.currentStep = '4';

            this.template.querySelector('div.stepThree').classList.add('slds-hide');
            this.template
                .querySelector('div.stepFour')
                .classList.remove('slds-hide');
    }

    handlePhoneChange(event){
        const myValue = this.template.querySelector(".rp");
        console.log('Phone Number being entered: '+myValue);

        const formattedNumber = this.formatPhoneNumber(myValue.value);
        this.reqPhone = formattedNumber;
    }

    convertPhone(phone){
        var cleaned = ('' + phone).replace(/\D/g, '');
        var match = cleaned.match(/^(\d{3})(\d{3})(\d{4})$/);
        if (match) {
          this.reqPhone = '(' + match[1] + ') ' + match[2] + '-' + match[3];
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

    goToCase(){
        var baseURL = window.location.origin
        var caseLink = baseURL+"/s/case" + "/" + this.caseId + "/stock-balancing-return";
        window.open(caseLink,'_top')
        console.log(("link to Case: "+caseLink))
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
            document.title = 'Stock Accommodation Return';
        }

        async handleMessage(message) {
            this.accountID = message.recordId;
        }
}
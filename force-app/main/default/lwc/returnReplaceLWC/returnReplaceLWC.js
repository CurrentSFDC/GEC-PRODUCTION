import { LightningElement, api, track, wire } from 'lwc';
import createCaseRecord from '@salesforce/apex/connectCreateCase.connectCreateReturnCase';
import updateFiles from '@salesforce/apex/connectCreateCase.updateFiles';
import getRelatedFiles from '@salesforce/apex/FileUploadViewController.getRelatedFiles';
import createCaseProduct from '@salesforce/apex/connectCreateCase.createCaseProduct';
import getReturnsQueueId from '@salesforce/apex/connectCreateCase.getReturnsQueueId';
import getCaseNumber from '@salesforce/apex/connectCreateCase.getCaseNumber';
import getAccName from '@salesforce/apex/connectCreateCase.getAccountName';
import updateInvoiceLines from '@salesforce/apex/connectCreateCase.updateInvLines';
import getOrderItemList from '@salesforce/apex/OrderProductController.getOrderDetails'; // USED TO PULL ORDER INFORMATION FOR DEFAULTING 
import { refreshApex } from '@salesforce/apex';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAgentId from '@salesforce/apex/connectCreateCase.getAgentId';
import getOrderDetails from '@salesforce/apex/OrderProductController.getOrderDetails';
import findInvLineRecords from "@salesforce/apex/LwcLookupControllerCust.preLoadLineRecords";
import preLoadLineRecords from "@salesforce/apex/LwcLookupControllerCust.preLoadLineRecords";
import agentAndSoldToFiltering from "@salesforce/apex/LwcLookupControllerCust.agentAndSoldToFiltering";
import orderInitiatedFiltering from "@salesforce/apex/LwcLookupControllerCust.orderInitiatedFiltering";


//import Json2Apex from '@salesforce/resourceUrl/Json2Apex';

// USED FOR GETTING THE USER DATA - WITHOUT APEX CALL
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import PHONE_FIELD from '@salesforce/schema/User.Phone';
import CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';
import USER_TYPE_FIELD from '@salesforce/schema/User.User_Type__c';
//const MAX_FILE_SIZE = 26214400; //10m
const MAX_FILE_SIZE = 127328; //10m

const actions = [
    { label: 'Edit', name: 'edit'},
    { label: 'Delete', name: 'delete'}
];

export default class ReturnReplaceLWC extends LightningElement {
    @api flexipageRegionWidth;
    @track isSpinner = false;
    @track toggleSubmitLabel = "Submit";
    @api caseType = "Return/Replace";
    @track accountName=[];
    @api transactionID; // DISPLAYS THE ID FOR THIS TRANSACTION --> USED IN BOTH FRONT AND BACKEND
    @api cartCount; // GETS THE AMOUNT OF ITEMS IN THE CART --> USED TO VALIDATE BEFORE MOVING TO REVIEW
    @api contactID; // THE ID OF THE CURRENT USER (CONTACT INFORMATION) THAT IS SIGNED IN
    @api CaseNumber; // THE CASE ID THAT IS RETURNED AFTER SUBMIT
    @track currentStep; // SETS THE CURRENT STEP
    @track reqName; // REQUESTOR NAME FORM FIELD --> STEP 1
    @track reqEmail; // REQUESTTOR EMAIL FORM FIELD --> STEP 1
    @track reqPhone; // REQUESTOR PHONE FORM FIELD --> STEP 1
    @api returnReason; // RETURN REASON/CODE FORM PICKLIST --> STEP 1
    @api secondaryReason; // SECONDARY READON FOR RETURN/SUB CODE PICKLIST --> STEP 1
    @api requestedAction; // REQUESTED ACTION PICKLIST --> STEP 1
    @api comments; // COMMENTS FORM FIELD --> STEP 1
    @api soldToAccount=[]; // ACCOUNT ID SELECTED FROM THE ACCOUNT LOOKUP FIELD --> STEP 1
    @api soldToName;
    @track accountID;
    @track showDistroField = false; 
    @track agentNumber='DEFAULT';  
    @track disAccount='DEFAULT';
    @track distAccName;
    @track distLines;
    @track disName=[];
    @track action;
    @track options; // 
    @track userType; // USED TO GET THE PORTAL USER TYPE OF SIGNED IN USER
    @track setAccountID; //USED TO PASS ACCOUNT ID TO RETRIEVE THE QUEUE ID FOR ASSIGNMENT
    @track caseOwnerId; //CASE OWNER ID PASSED FROM APEX
    @track accountSelected;

    // VARIABLES FOR THE FILE UPLOAD FUNCTION
    @track files = [] ; // TEMPORARILY STORES THE FILES UPLOADED IN THE FILEUPLOADVIEWER COMPONENT
    @track filesToInsert = []; 
    @track lstAllFiles = []; // ARRAY OF FILES TO BE INSERTED INTO THE DATABASE 
    @api fileToDelete; // SELECTED FILES TO BE DELETED FROM THE FILEUPLOADVIEWER COMPONENT
    @track showFiles = false;
    @track clear;
    @track fileColumns = [
        { label: 'File Name', fieldName: 'Title', type: 'text',cellAttributes: { alignment: 'left' } },
        { label: 'Type', fieldName: 'FileExtension', type: 'text', cellAttributes: { alignment: 'left' } },
        { label: 'Size', fieldName: 'ContentSize', type: 'number',cellAttributes: { alignment: 'left' }  },
        { type: 'button-icon', typeAttributes: { name: 'openConfirmation', iconName: 'utility:delete', iconClass: 'slds-icon-text-error' }, fixedWidth: 50, cellAttributes: { alignment: 'left' } }
    ];

    @api caseProductInsert = []; // ARRAY OF CASE PRODUCTS TO BE INSERTED WITH THE CASE
    @track orderLines = []; // USED TO RECEIVED THE ORDER LINES UPDATED AND PASSED TO CONFIRMATION SCREEN COMPONENT
    @track invLinesToUpdate = [];

    @track stepOneButton = false;
    @track caseNumberNew;
    @track today;
    @track queueName;
    @track showNextButton = true;
    @track queueId;
    @track paramString=[];
    @api orderAgent;
    @track orderAgentNumber;

    @track preSelectedAccount;
    @track selectorAccount;
    @track selectedAccountName; // SELECTED ACCOUNT NAME FROM SELECTOR OR OVERRIDE FROM LOOKUP
    @track selectedAccountID; // SELECTED ACCOUNT ID FROM SELECTOR OR OVERRIDE FROM LOOKUP
    @track selectedSoldToAccountName; //SELECTED SOLD TO ACCOUNT FROM INVOICE SEARCH LWC
    @track clearSoldTo;
    @track orderNumber; // ORDER NUMBER
    @track orderPO; // ORDER PO
    @track selectedOrder; // THE SELECTED ORDER ID FROM ORDER DETAIL SCREEN
    @track preSelectedOrder; // ORDER + PO SELECTED FROM ORDER DETAIL SCREEN
    @track orderSoldToAccount;
    @track preSelectedSoldTo;
    @track sfdcOrgURL;
    @track orderID;
    @track distributorID;
    @track distributorNumber;
    @track selectedDistributorID;
    @track caseContactEmail;
    @track preLoadedLines = [];
    @track orderAgentNumber;
    @track orderAgentAccount = "";
  
    file;

    @track columns = [
        { label: 'Name', fieldName: 'Title', type: 'text' },
        { label: 'Type', fieldName: 'FileExtension', type: 'text' },
    ];

            // COLUMNS FOR THE VIEW CART MODAL  GE_LGT_EM_InvoiceHeaderNumber__r.Name,  
            @track cartColumns = [
                {
                    label: 'Invoice #',
                    fieldName: 'Invoice__c',
                    iconName: 'utility:form',
                    type: 'Text',
                    sortable: true,
                    cellAttributes: { alignment: 'left' } 
                },
                {
                    label: 'PO#',
                    fieldName: 'PO__c',
                    type: 'Text',
                    sortable: true,
                    cellAttributes: { alignment: 'right' } 
                },
                {
                    label: 'Sold To',
                    fieldName: 'Distributor_Name__c',
                    type: 'Text',
                    sortable: true,
                    cellAttributes: { alignment: 'right' } 
                },
                {
                    label: 'Catalog #',
                    fieldName: 'Product_SKU__c',
                    iconName: 'utility:products',
                    type: 'Text',
                    sortable: true,
                    cellAttributes: { alignment: 'right' }
                },
                {
                    label: 'SKU #',
                    fieldName: 'SKU__c',
                    type: 'Text',
                    sortable: true,
                    cellAttributes: { alignment: 'left' }
                },
                /*{
                    label: 'Qty',
                    fieldName: 'Quantity__c',
                    type: 'Number',
                    iconName: 'utility:number_input',
                    sortable: true,
                    cellAttributes: { alignment: 'center' }
                },*/
                {
                    label: 'Unit Price',
                    fieldName: 'UnitPrice__c',
                    iconName: 'utility:money',
                    type: 'currency',
                    sortable: true,
                    cellAttributes: { alignment: 'left' }
                },
                /*{
                    label: 'Distributor Name',
                    fieldName: 'Distributor_Name__c',
                    type: 'Text',
                    sortable: true,
                    cellAttributes: { alignment: 'center' }
                },*/
                {
                    label: 'Qty',
                    fieldName: 'Return_Qty__c',
                    iconName: 'utility:number_input',
                    type: 'number',
                    sortable: true,
                    cellAttributes: { alignment: 'left' }
                },
                {
                    label: 'UOM',
                    fieldName: 'UnitOfMeasure__c',
                    iconName: 'utility:slider',
                    type: 'text',
                    //sortable: true,
                    cellAttributes: { alignment: 'right' }
                },
                {
                    label: 'QuickStock',
                    fieldName: 'Quick_Stock__c',
                    type: 'boolean',
                    sortable: true,
                    cellAttributes: { alignment: 'center' }
                },
                /*{
                    label: 'Shipment Date',
                    fieldName: 'Shipment_Date__c',
                    iconName: 'utility:date_input',
                    type: 'date',
                    sortable: true,
                    cellAttributes: { alignment: 'center' }
                },*/
                {
                    label: 'Action',
                    fieldName: 'Requested_Action_Override__c',
                    iconName: 'utility:button_choice',
                    type: 'picklist',
                    //editable: true,
                    sortable: true,
                    cellAttributes: { alignment: 'right' },
                    typeAttributes: {
                        placeholder: 'Choose Action', options: [
                            { label: 'Return', value: 'Return' },
                            { label: 'Replace', value: 'Replace' },
                            { label: 'Return & Replace', value: 'Return & Replace' },
                        ] // list of all picklist options
                        , value: { fieldName: 'Return' } // default value for picklist
                        , context: { fieldName: 'Id' }}
                },
                {
                    type: 'button-icon',
                    initialWidth: 34,
                    iconName: 'utility:delete',
                    typeAttributes:{
                        label: 'Delete',
                        name: 'delete',
                        rowActions: actions,
                        title: 'delete',
                        iconName: 'utility:delete',
                        iconClass: 'slds-icon-text-error',
                                       
                    },
                    
                },
                ];
        //--------END COLUMNS FOR THE VIEW CART MODAL

        @track reviewColumns = [
            {
                label: 'Invoice #',
                fieldName: 'Invoice__c',
                iconName: 'utility:form',
                type: 'Text',
                sortable: true,
                cellAttributes: { alignment: 'left' } 
            },
            {
                label: 'PO#',
                fieldName: 'PO__c',
                type: 'Text',
                sortable: true,
                cellAttributes: { alignment: 'right' } 
            },
            {
                label: 'Sold To',
                fieldName: 'Distributor_Name__c',
                type: 'Text',
                sortable: true,
                cellAttributes: { alignment: 'right' } 
            },
            {
                label: 'Catalog #',
                fieldName: 'Product_SKU__c',
                iconName: 'utility:products',
                type: 'Text',
                sortable: true,
                cellAttributes: { alignment: 'right' }
            },
            {
                label: 'SKU #',
                fieldName: 'SKU__c',
                type: 'Text',
                sortable: true,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: 'Unit Price',
                fieldName: 'UnitPrice__c',
                iconName: 'utility:money',
                type: 'currency',
                sortable: true,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: 'Qty',
                fieldName: 'Quantity__c',
                type: 'Number',
                iconName: 'utility:number_input',
                sortable: true,
                cellAttributes: { alignment: 'center' }
            },
            /*{
                label: 'Distributor Name',
                fieldName: 'Distributor_Name__c',
                type: 'Text',
                sortable: true,
                cellAttributes: { alignment: 'center' }
            },*/
            {
                label: 'UOM',
                fieldName: 'UnitOfMeasure__c',
                iconName: 'utility:slider',
                type: 'text',
                //sortable: true,
                cellAttributes: { alignment: 'right' }
            },
            /*{
                label: 'Shipment Date',
                fieldName: 'Shipment_Date__c',
                iconName: 'utility:date_input',
                type: 'date',
                sortable: true,
                cellAttributes: { alignment: 'center' }
            },*/
            {
                label: 'Return Qty',
                fieldName: 'Return_Qty__c',
                iconName: 'utility:number_input',
                type: 'number',
                sortable: true,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: 'QuickStock',
                fieldName: 'Quick_Stock__c',
                type: 'boolean',
                sortable: true,
                cellAttributes: { alignment: 'center' }
            },
            {
                label: 'Action',
                fieldName: 'Requested_Action_Override__c',
                iconName: 'utility:button_choice',
                type: 'picklist',
                cellAttributes: { alignment: 'right' },
                //editable: true,
                sortable: true,
                typeAttributes: {
                    placeholder: 'Choose Action', options: [
                        { label: 'Return', value: 'Return' },
                        { label: 'Replace', value: 'Replace' },
                        { label: 'Return & Replace', value: 'Return & Replace' },
                    ] // list of all picklist options
                    , value: { fieldName: 'Return' } // default value for picklist
                    , context: { fieldName: 'Id' }}
            },
            
            ];

        returnColumns = [{
            label: 'Invoice #',
            fieldName: 'GE_LGT_EM_SAP_Invoice_Number__c',
            iconName: 'utility:form',
            type: 'Text',
            //sortable: true
            cellAttributes:{
                alignment: 'left',
                iconName:{fieldName:'rowIcon'}, 
                iconPosition:'left',
                iconTitle: {fieldName: 'iconTitle'},
                class:{
                fieldName: 'textColor' }
            }
        },
        {
            label: 'Order #',
            //fieldName: 'GE_LGT_EM_Order_Number__c',
            fieldName: 'newNumber',
            type: 'Text',
            //sortable: true,
            cellAttributes: { alignment: 'left',
            class:{
                    fieldName: 'textColor'} }
        },
        {
            label: 'PO #',
            fieldName: 'GE_LGT_EM_Customer_PO_Number__c',
            type: 'Text',
            //sortable: true,
            cellAttributes: { alignment: 'left',
            class:{
                    fieldName: 'textColor'} }
        },
        {
            label: 'Catalog #',
            fieldName: 'GE_LGT_EM_Material_Description__c',
            iconName: 'utility:products',
            type: 'Text',
            //sortable: true
            cellAttributes: { alignment: 'right',
            class:{
                    fieldName: 'textColor'} }
        },
        {
            label: 'SKU #',
            fieldName: 'SKU__c',
            iconName: 'utility:products',
            type: 'Text',
            cellAttributes: { alignment: 'left',
            class:{
                    fieldName: 'textColor'} }
            //sortable: true
        },
        {
            label: 'Unit Price',
            fieldName: 'GE_LGT_EM_Invoiced_Price__c',
            iconName: 'utility:money',
            type: 'currency',
            //sortable: true
            cellAttributes: { alignment: 'left',
            class:{
                    fieldName: 'textColor'} }
        },
        {
            label: 'Inv. Qty',
            fieldName: 'GE_LGT_EM_Invoiced_Quantity__c',
            type: 'Text',
            iconName: 'utility:number_input',
            //sortable: true,
            hideDefaultActions: true,
            cellAttributes: { alignment: 'left',
            class:{
                    fieldName: 'textColor'} }
        },
        /*{
            label: 'Distributor Name',
            fieldName: 'Distributor_Name__c',
            type: 'Text',
            sortable: true,
            cellAttributes: { alignment: 'center' }
        },*/
        {
            label: 'UOM',
            fieldName: 'GE_LGT_EM_Sales_Unit__c',
            iconName: 'utility:slider',
            type: 'text',
            //sortable: true,
            cellAttributes: { alignment: 'right',
            class:{
                    fieldName: 'textColor'} }
        },
        {
            label: 'QuickStock',
            fieldName: 'QuickStock__c',
            type: 'boolean',
            //sortable: true,
            cellAttributes: { alignment: 'center',
            class:{
                    fieldName: 'textColor'} }
        },
        /*{
            label: 'Shipment Date',
            fieldName: 'Shipment_Date__c',
            type: 'date',
            //sortable: true,
            hideDefaultActions: true,
            iconName: 'utility:date_input',
            cellAttributes: { alignment: 'center' }
        },*/
        {
            label: 'Qty',
            fieldName: 'GE_LGT_EM_DisputeCount__c',
            iconName: 'utility:number_input',
            type: 'number',
            //editable: true,
            sortable: true,
            cellAttributes: { alignment: 'left',
            class:{
                    fieldName: 'textColor'} }
        },
        
        
        {
            label: 'Action',
            fieldName: 'Requested_Action_Override__c',
            iconName: 'utility:button_choice',
            wrapText: true,
            type: 'picklist',
            cellAttributes: { alignment: 'right',
            class:{
                    fieldName: 'textColor'}}
           // editable: true,
           // sortable: true,
            /*typeAttributes: {
                placeholder: 'Choose Action', options: [
                    { label: 'Return', value: 'Return' },
                    { label: 'Replacement', value: 'Replacement' },
                    { label: 'Return and Replacement', value: 'Return and Replacement' },
                ] // list of all picklist options
                , value: { fieldName: 'Return' }
                , context: { fieldName: 'Id' } }// default value for picklist*/
                
        },
        {
            type: 'button-icon',
            initialWidth: 34,
            typeAttributes:{
                label: 'Edit',
                name: 'edit',
                rowActions: actions,
                title: 'edit',
                iconName: {fieldName: 'iconName'},
                class: 'buttonIcon',
                variant: {fieldName: 'buttonColor'},
                disabled: {fieldName: 'actionDisabled'},
                //variant: { fieldName: 'buttonColor'}
                
            },
            cellAttributes: { alignment: 'center',
            
            class:{fieldName: 'cellColor'} }
            
            
            /*type: 'action',
            typeAttributes: { rowActions: actions },
            cellAttributes: { iconName: 'utility:edit' }*/
        },
        
        ]; 

    async connectedCallback(){
        window.addEventListener("beforeunload", this.beforeUnloadHandler.bind(this));
        this.setTimer();

        var today = new Date();
        var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
        var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
        const id = 'id' + performance.now()+'-'+date+'-'+time;
        this.transactionID = id;
        console.log('Generated ID: '+ id);

        console.log('Setting the Transcation ID: '+this.transactionID);

        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();

        this.today = dd + '/' + mm + '/' + yyyy;
        console.log('Todays Date: '+this.today);

        //FUNCTION USED TO GET THE ORDER DETAILS WHEN INITIATING CASE FROM ORDER DETAIL SCREEN
        this.sfdcOrgURL = window.location.href;
            if(this.sfdcOrgURL.includes('id=')==true){
                this.paramString = this.sfdcOrgURL.split('id=')[1];
                console.log('Order ID Passed from Detail Page: '+this.paramString);
                if(this.paramString.length > 0){
                    console.log('Order ID Passed from Detail Page: '+this.paramString);
                    console.log('ATTEMPTING TO GET ORDER DETAILS....');
                   this.handleDefaultOrder();
                } 
            }

        
       
    }

//------------------- SESSION TIME OUT FUNCTIONS --------------------------------------------
@track delayTimer;
@track sessionModal = false;
@track timeVal = '00:00:00';

setTimer(){
    console.log('Creating Session Timer...');
    this.timerActive = true;
    this.delayTimer = 900000; //15 MINUTES
    var parentThis = this;
    console.log('Setting Timer to: '+this.delayTimer);

    // Run timer code in every 100 milliseconds
    this._interval = setInterval(() => {  

       // Time calculations for hours, minutes, seconds and milliseconds
     var hours = Math.floor((this.delayTimer % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
     var minutes = Math.floor((this.delayTimer % (1000 * 60 * 60)) / (1000 * 60));
     var seconds = Math.floor((this.delayTimer % ((1000 * 60)) / 1000) - 1);
     var milliseconds = Math.floor((this.delayTimer % (1000)));

    var hDisplay = hours > 0 ? (hours < 10 ? "0" + hours + ":" : hours + ":") : "00:";
    var mDisplay = minutes > 0 ? (minutes < 10 ? "0" + minutes + ":" : minutes + ":") : "00:";
    var sDisplay = seconds > 0 ? (seconds < 10 ? "0" + seconds : seconds) : "00";

       
        // Output the result in the timeVal variable
        parentThis.timeVal = hDisplay + mDisplay + sDisplay;

        
       this.delayTimer = this.delayTimer - 1000;

        
            if ( this.delayTimer === 60000 ) {  
                this.showSessionModal();  
            }  
            if ( this.delayTimer === 0 ) {  
                clearInterval(this._interval);
                this.template.querySelector("c-invoice-item-search").clearSessionCart();

                /*var baseURL = window.location.origin;
                console.log('Base URL: '+baseURL);
                this.sfdcOrgURL = baseURL+'/Agents/s/';
                console.log('New URL: '+this.sfdcOrgURL);
                window.open(this.sfdcOrgURL, "_self");  */
            }  
              
        //console.log('Timer Status: '+parentThis.timeVal);
        //console.log('Timer Countdown: '+this.delayTimer);
        
        
    }, 1000);
}

resetTimeout(){
        this.sessionModal = false;
        clearInterval(this._interval);
        this.setTimer();   
}

showSessionModal(){
    //this.setTimer();
    this.sessionModal = true;
    /*window.setTimeout(
        this.clearCart()
    , 180000);*/
}

//------------------- END SESSION TIMER FUNCTIONS --------------------------------------

    // GET CURRENT LOGGED IN COMMUNITY USER INFORMATION
        @wire(getRecord, {
            recordId: USER_ID,
            fields: [NAME_FIELD, EMAIL_FIELD, PHONE_FIELD, CONTACT_FIELD, ACCOUNT_FIELD, USER_TYPE_FIELD]
        }) wireuser({
            error,
            data
        }) {
            if (error) {
            this.error = error ; 
            } else if (data) {
                let internalUser = localStorage.getItem('internalName');
                if(internalUser != null){
                    this.reqName = localStorage.getItem('internalName');
                    this.reqEmail = localStorage.getItem('internalUserName');
                    this.reqPhone = localStorage.getItem('internalUserPhone');
                } else {
                    this.reqEmail = data.fields.Email.value;
                    this.reqName = data.fields.Name.value;
                    this.reqPhone = data.fields.Phone.value;
                  
                }
                this.caseContactEmail = data.fields.Email.value;
                this.contactID = data.fields.ContactId.value;
                this.accountID = data.fields.AccountId.value;
                this.userType = data.fields.User_Type__c.value;
                //this.soldToAccount=this.accountID;
                console.log('Requestor Phone: '+this.reqPhone);
                this.convertPhone(this.reqPhone);
            /*getAgentId({AccountId: this.soldToAccount})
            .then(result => {
            this.agentNumber = result;
            if(this.agentNumber == 'N'){
                this.showDistroField = false;
                this.disAccount='DEFAULT_DIS';
                }
                else {
                    this.showDistroField = true;   
                }
            console.log(JSON.stringify("Agent Id "+ JSON.stringify(this.agentNumber)))
            });*/

            this.setAccountfromSelector();

           /*getAccName({id_dtl: this.soldToAccount})
            .then(result => {
            this.accountName = result;
            console.log(JSON.stringify("The Result for Case Number: "+ JSON.stringify(this.accountName)))
            //SELECTED ACCOUNT == AGENT --> GET RETURN QUEUE NAME (SELECT RETURN QUEUE from ACCOUNT)
            //SELECTED ACCOUNT == CHILD OF THE AGENT ==> GET RETURN QUEUE NAME (SELECT PARENT RETURN QUEUE from ACCOUNT)
            });*/

            /*var inputacc=this.soldToAccount; 
            this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
            console.log('Sending Account ID to Account Search: '+inputacc); */
            
            
            
            }
        }
    //--------------------------------------------------

    // SETS THE ACCOUNT NAME FIELD ON CASE INITIATION FROM ACCOUNT SELECTOR
async setAccountfromSelector(){
        
        let storedUserType = localStorage.getItem('User Type');
        this.userType = localStorage.getItem('User Type');
        this.template.querySelector("c-invoice-item-search").setVisibility(storedUserType);
        
        //AGENT PERSONA
        if(storedUserType == "Agent"){
            this.preSelectedAccount = localStorage.getItem('AgentName') + ' - ' + localStorage.getItem('AgentNumber') + ' - ' + localStorage.getItem('AgentSegment');
            this.selectorAccount = localStorage.getItem('AgentNumber');
            this.selectedAccountID =  localStorage.getItem('AgentID');
            this.selectedAccountName = localStorage.getItem('AgentName');
            console.log('Setting Account Lookup LWC - Preselected: '+this.selectorAccount);

            let retrieveData = localStorage.getItem('AgentID');

            let distributorData = localStorage.getItem('DistributorID');
            if (distributorData != null){
                this.preSelectedSoldTo = localStorage.getItem('DistributorName') + ' - ' + localStorage.getItem('DistributorAccount') + ' - ' + localStorage.getItem('DistributorSegment');
                this.distributorNumber = localStorage.getItem('DistributorAccount');
                this.selectedDistributorID = localStorage.getItem('DistributorID');
                console.log('PRE SELECTED SOLD TO: '+this.preSelectedSoldTo);
                this.template.querySelector("c-invoice-item-search").preslectedSoldTo();

                //GET INVOICE LINES FOR PRELOADING - AGENT AND DISTRIBUTOR SELECTED
                this.sfdcOrgURL = window.location.href;
                if(this.sfdcOrgURL.includes('id=')==false){
                    console.log('CALLING APEX TO PRELOAD LINES FOR --> AGENT AND DISTRIBUTOR SELECTED....');
                    console.log('Sending Agent Code for Preloading Lines: '+this.selectorAccount);
                    console.log('Sending Sold To for Preloading Lines: '+this.distributorNumber);

                   await agentAndSoldToFiltering({soldTo: this.distributorNumber, agentNumber: this.selectorAccount, userType : this.userType})
                        .then(result => {
                            this.preLoadedLines = result;
                            console.log('PRELOADED INVOICE LINES: '+JSON.stringify(result));

                            var inputData={
                                //soldToNumber : this.distributorNumber,
                                //orderNumber : null,
                                lines : result
                            };

                            this.template.querySelector('c-invoice-item-search').setPreloadedLines(inputData);
                        });
                }
            } else {
                //GET INVOICE LINES FOR PRELOADING - JUST AGENT SELECTED
        
                this.sfdcOrgURL = window.location.href;
                if(this.sfdcOrgURL.includes('id=')==false){
                    console.log('CALLING APEX TO PRELOAD LINES FOR --> AGENT ONLY SELECTED....');
                    console.log('Sending Agent Code for Preloading Lines: '+this.selectorAccount);
                   

                    preLoadLineRecords({filterField: this.selectorAccount, userType : this.userType})
                        .then(result => {
                            this.preLoadedLines = result;
                            console.log('PRELOADED INVOICE LINES: '+JSON.stringify(result));

                            var inputData={
                                //soldToNumber : null,
                                //orderNumber : null,
                                lines : result
                            };

                            this.template.querySelector('c-invoice-item-search').setPreloadedLines(inputData);
                        });
                }
            }

                this.distributorNumber = localStorage.getItem('DistributorAccount');
                this.caseSoldTo = localStorage.getItem('DistributorID');
                console.log('SETTING CASE SOLD TO FROM SELECTOR: '+this.caseSoldTo);
                console.log('PRE SELECTED SOLD TO: '+this.preSelectedSoldTo);
                //let disAccountName = sessionStorage.getItem('DistributorName');
                //let disAccountSegment = sessionStorage.getItem('DistributorSegment');
                //let disID = sessionStorage.getItem('DistributorID');
                if(retrieveData != null){
                    console.log('Setting Account From Selector: '+JSON.stringify(retrieveData));
                    this.soldToAccount = retrieveData;
                    var inputacc = retrieveData;
                    console.log('Sending Account ID to Account Search: '+inputacc);
                   
                    console.log('Setting Account Number from Local Storage: '+inputacc);

                    
                }
            
        } 
        
        //DISTRIBUTOR PERSONA
        else {

            this.preSelectedAccount = localStorage.getItem('DistributorName') + ' - ' + localStorage.getItem('DistributorAccount') + ' - ' + localStorage.getItem('DistributorSegment');
            this.selectorAccount = localStorage.getItem('DistributorAccount');
            this.distributorNumber = this.selectorAccount;
            //this.selectedAccountID = localStorage.getItem('DistributorID');
            this.selectedDistributorID = localStorage.getItem('DistributorID');
            this.selectedAccountName = localStorage.getItem('DistributorName');
            console.log('Setting Account Lookup LWC - Preselected: '+this.selectorAccount);

            let retrieveData = localStorage.getItem('DistributorID');
            //let disAccountName = sessionStorage.getItem('DistributorName');
            //let disAccountSegment = sessionStorage.getItem('DistributorSegment');
            //let disID = sessionStorage.getItem('DistributorID');
            if(retrieveData != null){
                console.log('Setting Account From Selector: '+JSON.stringify(retrieveData));
                this.soldToAccount = retrieveData;
                var inputacc = retrieveData;
                console.log('Sending Account ID to Account Search: '+inputacc);
                this.distributorNumber = localStorage.getItem('DistributorAccount');
                
                console.log('Setting Account Number from Local Storage: '+inputacc);

                
            }

            //GET INVOICE LINES FOR PRELOADING - DISTRIBUTOR PERSONA
        
        this.sfdcOrgURL = window.location.href;
        if(this.sfdcOrgURL.includes('id=')==false){
           console.log('CALLING APEX TO PRELOAD LINES FOR --> DISTRIBUTOR ONLY....');
            console.log('Sending Account for Preloading Lines: '+this.selectorAccount);

            preLoadLineRecords({filterField: this.selectorAccount, userType : this.userType})
                .then(result => {
                    this.preLoadedLines = result;
                    console.log('PRELOADED INVOICE LINES: '+JSON.stringify(result));

                    var inputData={
                        //soldToNumber : null,
                        //orderNumber : null,
                        lines : result
                    };

                    this.template.querySelector('c-invoice-item-search').setPreloadedLines(inputData);
                });
        }
        }
    }

    get acceptedFormats() {
        return ['.pdf','.png','.jpg','.jpeg','.doc','.docx', '.xls','.xlsx','.ppt','.pptx','.odt', '.rtf'];
    }

    get message() {
        return ['Formats: '+'pdf','png','jpg','jpeg','doc','docx', 'xls','xlsx','ppt','pptx','odt', 'rtf' + ' Max File Size: 10 MB'];
    }
    
    // FOLLOWING OPTIONS METHODS ARE USED FOR PCIKLIST VALUES IN SCREEN/STEP 1
    
    @track baseOptions = [
            { label: 'Agent Error', value: 'Agent Error' },
            { label: 'Customer Error', value: 'Customer Error' },
            { label: 'Customer Service', value: ' Customer Service' },
            { label: 'Manufacturing', value: 'Manufacturing' },
            { label: 'Sales', value: 'Sales' },
            { label: 'Shipping', value: 'Shipping' },
            { label: 'Supply Chain', value: 'Supply Chain' },
            { label: 'Technical', value: 'Technical' },
        ];
    
    @track reworkOptions = [
        { label: 'Agent Error', value: 'Agent Error' },
        { label: 'Customer Error', value: 'Customer Error' },
        { label: 'Manufacturing', value: 'Manufacturing' },
        { label: 'Sales', value: 'Sales' },
        { label: 'Shipping', value: 'Shipping' },
        { label: 'Supply Chain', value: 'Supply Chain' },
        { label: 'Technical', value: 'Technical' },
    ];


    get SRoptions() {
        return [
            { label: 'Cancellation – failed to cancel in time', value: 'Cancellation – failed to cancel in time' },
            { label: 'Incorrect SKU Entered', value: 'Incorrect SKU Entered' },
            { label: 'Shipped Early', value: 'Shipped Early'},
            { label: 'Duplicate', value: 'Duplicate' },
            { label: 'Quantity', value: 'Qty' },
            { label: 'Price', value: 'Price' },
            { label: 'Lost or Damaged', value: 'Lost or damaged' },
            { label: 'Overshipped Qty', value: 'Overshipped qty' },
            { label: 'Shipped Wrong Item', value: 'Shipped Wrong Item' },
            { label: 'Incomplete notes or labelling', value: 'Incomplete notes or labelling' },
            
        ];
    }

    get RAoptions() {
        return [
            { label: 'Return', value: 'Return' },
            { label: 'Replacement', value: 'Replacement' },
            { label: 'Return and Replacement', value: 'Return and Replacement' },
            { label: 'Return for Rework', value: 'Return for Rework' },
        ];
    }
     // SETS THE ORDER AND SOLD TO ACCOUNT BASED ON THE ORDER INITIATION
 async handleDefaultOrder() {
       
        this.selectedOrder = this.paramString;
        console.log('ORDER ID FROM ORDER DETAIL PAGE...');
        getOrderDetails({orderId: this.selectedOrder})
        .then(result => {
            
                this.orderNumber= result[0].GE_Order_NO__c;
                this.orderID = result[0].Id;
                this.distributorNumber = result[0].Sold_To__r.GE_LGT_EM_SAP_Customer_Number__c;
                this.orderPO = result[0].Customer_PO_Number__c;
                this.caseSoldTo = result[0].Sold_To__c;
                this.selectedDistributorID = this.caseSoldTo;
                console.log('SelectedDistributorID From Order = '+this.selectedDistributorID);
                this.selectedSoldToAccountName = result[0].Sold_To__r.Name;
              
                if(result[0].Agent_Account__c == null || result[0].Agent_Account__c === undefined || result[0].Agent_Account__c === "undefined" || result[0].Agent_Account__c == ""){
                    this.orderAgentAccount = null;
                } else {
                    this.orderAgentAccount = result[0].Agent_Account__c;
                }

                this.preSelectedSoldTo = result[0].Sold_To__r.Name + ' - ' + result[0].Sold_To__r.GE_LGT_EM_SAP_Customer_Number__c + ' - ' + result[0].Sold_To__r.Customer_Segmentation__c;
                console.log("Order Number: " + this.orderNumber);
                console.log("Case Sold To: " + this.caseSoldTo);
                console.log("ORDER Sold To: " + this.distributorNumber);
                console.log("Order PO: " + this.orderPO);
                console.log("PreSelected Sold To: " + this.preSelectedSoldTo);
                console.log('Agent Account on Order: '+this.orderAgentAccount);
                console.log('Order Number Returned: '+this.orderNumber);




                
                if(this.orderAgentAccount !== null){
                    console.log('IN THE ORDER HAS AGENT BRANCH.....');
                    this.orderAgent = result[0].Agent_Account__c;
                    console.log('ORDERING AGENT ACCOUNT ID: '+this.orderAgent);
                    this.orderAgentNumber = result[0].Agent_Account__r.GE_LGT_Rep_Code__c;
                    console.log('ORDERING AGENT NUMBER: '+this.orderAgentNumber);
                    orderInitiatedFiltering({searchKey: this.orderNumber, soldTo: this.distributorNumber, agentNumber: this.orderAgentNumber, userType : this.userType})
                    .then(result => {
                        this.preLoadedLines = result;
                        console.log('PRELOADED ORDER --> INVOICE LINES: '+JSON.stringify(result));

                        var inputData={
                            //soldToNumber : this.distributorNumber,
                            //orderNumber : this.orderNumber,
                            lines : result
                        };

                        this.template.querySelector('c-invoice-item-search').setPreloadedLines(inputData);
                    });
                } else {
                    console.log('IN THE ORDER HAS NO AGENT BRANCH.....');
                    this.orderAgent = null;
                    this.orderAgentNumber = null;
                    console.log('ORDERING AGENT NUMBER: '+this.orderAgentNumber);
                    orderInitiatedFiltering({searchKey: this.orderNumber, soldTo: this.distributorNumber, agentNumber: null, userType : this.userType})
                    .then(result => {
                        this.preLoadedLines = result;
                        console.log('PRELOADED ORDER --> INVOICE LINES: '+JSON.stringify(result));

                        var inputData={
                            //soldToNumber : this.distributorNumber,
                            //orderNumber : this.orderNumber,
                            lines : result
                        };

                        this.template.querySelector('c-invoice-item-search').setPreloadedLines(inputData);
                    });
                }
            this.showOrderSelection = true;
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(result)));
            this.orderItemList  = result;
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(this.orderItemList)));
            this.isOrderIdAvailable = true;
            
            this.template.querySelector('c-invoice-item-search').setDefaultButtons();
    
        }).catch(error => {
            console.log("The error SENT TO APEX is: " +error);
            this.error = error;
           
        });
    
    }

    handleAccountSelected(event){
       
        this.selectorAccount = event.detail.selectedAccount;
        if(this.userType == "Agent"){
            this.selectedAccountID = event.detail.selectedAccountId;
        } else {
            this.selectedDistributorID = event.detail.selectedAccountId;
        }
        this.selectedAccountName = event.detail.selectedAccountName;
        console.log('Account Selected from AccountLookupLWC: '+this.selectorAccount);
        if(this.userType == "Distributor"){
            this.distributorNumber = this.selectorAccount;
            console.log('Distributor Account Number Selected: '+this.distributorNumber);
        }

        this.template.querySelector("c-invoice-item-search").setSelectorNumber(this.selectorAccount);

    // GET PRELOAD LINES WHEN ACCOUNT/AGENT CHANGES
    preLoadLineRecords({filterField: this.selectorAccount, userType : this.userType})
    .then(result => {
        this.preLoadedLines = result;
        console.log('PRELOADED INVOICE LINES -- ACCOUNT SELECTED CHANGED: '+JSON.stringify(result));

        var inputData={
            //soldToNumber : null,
            //orderNumber : null,
            lines : result
        };

        this.template.querySelector('c-invoice-item-search').setPreloadedLines(inputData);
    });
    }

    // HANDLE THE SELECTED SOLD TO ACCOUNT FROM INVOICE SEARCH LWC COMPONENT
    handleSoldToSelected(event){ 
       
        this.selectedSoldToAccountName = event.detail.selectedAccountName;
        this.selectedDistributorID = event.detail.soldto;
        console.log('SOLD TO Account Selected from AccountLookupLWC: '+this.selectedSoldToAccountName);
        console.log('SOLD TO ID Selected from AccountLookupLWC: '+this.selectedDistributorID);
    }

    // CLEARS THE SELECTED ACCOUNT ON ACCOUNT LOOKUP LWC - AND - EXECUTES CLEAR FOR SOLD TO LOOKUP LWC FOR THE INVOICE ITEM SEARCH LWC  
    clearResults(event){
        this.clear = event.detail.clear;
        console.log('CLEARING ACCOUNT.....');
        console.log('CLEAR: '+this.clear);
        if(this.clear === "true"){
            this.searchKey = '';
            this.clearSoldTo = true;
            this.preSelectedAccount = null;
            this.selectorAccount = null;
            this.template.querySelector("c-invoice-item-search").changeAccount();
        }
    }


    handleActionPick(event){
        this.action = event.target.value;
        console.log('Reason :' +this.action)
        if(this.action == "Return" || this.action == "Replacement" || this.action =="Return and Replacement"){   
            console.log('Options: ')  ;
            this.options=this.baseOptions;  
            console.log('Options After: ' + this.options)  ;         
        }
        else if(this.action == "Return for Rework"){   
            console.log('Options: ')  ;
            this.options=this.reworkOptions;  
            console.log('Options After: ' + this.options)  ;         
        }
    }
    
     // HANDLES THE FOUND ORDER FROM THE InvoiceItemSearchLWC CHILD COMPONENT
     orderRetrieved(event){
        this.orderAgent = event.detail.orderAgent;
        console.log('ORDER AGENT ACCOUNT ID: '+this.orderAgent);
                
    }
     
    // DATA PASSED FROM c/lightningWebCompDataTableOrderItem CHILD COMPONENT AND SETS THIS.ORDERLINES ARRAY
    confirmUpdate(event){
        this.orderLines = event.detail.lines;
        if(this.orderLines.length > 0){
            this.showNextButton = false;
        } else {
            this.showNextButton = true;
        }
        console.log('The lines passed to Parent: '+JSON.stringify(this.orderLines));
    }

    updateCartCount(event){
        this.cartCount = event.detail.totalItems;
    }

    setOrderAgent(event){
        this.orderAgent = event.detail.account;
        console.log('Order Agent ID: '+this.orderAgent);
    }

    /*accountID(event){
        this.soldToAccount = event.detail.recordId;
        console.log('Selected SOLD-TO ID: '+ this.soldToAccount);
        this.soldToName = event.detail.fieldValue;
        console.log('Selected SOLD TO NAME: '+this.soldToName);
    }*/

    appendLines(event){
        
        this.invLinesToUpdate = event.detail.lineId;
        console.log('Invoice Lines to Modiify: '+JSON.stringify(this.invLinesToUpdate));
    }
    
    //USED FOR WHEN FILES ARE DELETED FROM THE FILES TABLE
    handleActionFinished(event) {
        console.log('Post-Delete Action Fired...');
        this.fileToDelete = event.detail.contId;
        console.log('The File SET for deletion: ' + this.fileToDelete);

        const index = this.filesToInsert.indexOf(this.fileToDelete);
        this.filesToInsert.splice(index, 1);

        console.log('Files in the list AFTER Delete: '+ this.filesToInsert)
        console.log('File List Array Values: '+ this.files);
            getRelatedFiles({newFiles: this.filesToInsert})
            
            .then(result => {
                this.files = result;
                console.log(result);
                console.log('Files Returned from Apex: ' + result);
            })
            .catch(error => {
                console.log(error);
                this.error = error;
                console.log('Apex failed...');
            }); 
        
    }
        
    //USED FOR WHEN FILES ARE UPLOADED INTO THE SYSTEM USING THE UPLOAD FEATURE    
    handleUploadFinished(event) {
        // Get the list of uploaded files

       
        const lstUploadedFiles = event.detail.files;
        console.log('LST FILES: '+JSON.stringify(lstUploadedFiles));
         
        //alert(event.detail.files[0].documentId);
        lstUploadedFiles.forEach(fileIterator => this.filesToInsert.push(fileIterator.documentId)
        );
        
        console.log('Uploaded Files: ' + this.lstAllFiles);
        //this.filesToInsert = this.lstAllFiles;
        console.log('Files to Insert: ' + this.filesToInsert);
        
        console.log('Executing Apex Call...')
        console.log('Passing File IDs to Apex: ' + this.filesToInsert);

            getRelatedFiles({newFiles: this.filesToInsert})
            
            .then(result => {
                this.files = result;
                if(this.files.length > 0){
                    this.showFiles = true;
                } else{
                    this.showFiles = false;
                }
                console.log(result);
                console.log('Files Returned from Apex: ' + result);
            })
            .catch(error => {
                console.log(error);
                this.error = error;
                console.log('Apex failed...');
            }); 

    }



    async handleChange(event){
        this.soldToAccount = event.target.selectedRecordId;
        this.soldToName = event.target.dataset.name;
        console.log('Sold To Account ID: '+ this.soldToAccount);
        console.log('Sold To Account Name: '+ this.soldToName);
      await getAccName({id_dtl: this.soldToAccount})
            .then(result => {
            this.accountName = result;
            console.log(JSON.stringify("The Result for Case Number: "+ JSON.stringify(this.accountName)))
            //SELECTED ACCOUNT == AGENT --> GET RETURN QUEUE NAME (SELECT RETURN QUEUE from ACCOUNT)
            //SELECTED ACCOUNT == CHILD OF THE AGENT ==> GET RETURN QUEUE NAME (SELECT PARENT RETURN QUEUE from ACCOUNT)
        });

        await getAgentId({AccountId: this.soldToAccount})
            .then(result => {
            this.agentNumber = result;
            console.log(JSON.stringify("Agent Id "+ JSON.stringify(this.agentNumber)))
            });

            if(this.agentNumber == 'N'){
            this.showDistroField = false;
            this.disAccount='DEFAULT_DIS';
            }
            else{
                this.showDistroField = true; 
            }
        
    }

    setTransactionID(event){
        console.log('Setting the Transcation ID from Child: '+this.transactionID);
        this.transactionID = event.detail.transID;
    }

    //USED TO INSERT CASE RECORD ONCE USER SELECTS SUBMIT IN STEP THREE (REVIEW)
   async handleSave(event){
        this.toggleSubmitLabel = "Submitting...";
        this.isSpinner = true;
        let nCase = { 'sobjectType': 'Case' };
        nCase.RecordTypeId = '0123j000000X8ys';
        nCase.OwnerId = this.caseOwnerId;
        nCase.ContactId = this.contactID;
        nCase.Origin = 'Connect';
        nCase.eLight_Form_Type__c = 'Return';
        nCase.Connect_ID__c = this.transactionID;
        nCase.AccountId = this.selectedAccountID;
        nCase.eLight_Requestor_Name__c = this.reqName;
        nCase.Requestor_Email__c = this.reqEmail;
        nCase.eLight_Requestor_Phone__c = this.reqPhone;
        nCase.Requested_Action__c = this.requestedAction;
        nCase.eLight_Reason_for_Return__c = this.returnReason;
        nCase.eLight_Secondary_Reason_s__c = this.secondaryReason;
        nCase.eLight_Comments__c = this.comments;
        nCase.SuppliedEmail = this.caseContactEmail; 
        nCase.Type = 'Returns';
        nCase.GE_NAS_Sub_Type__c = 'New RGA';
        nCase.Subject = 'Return Requested';
        console.log('Sending '+nCase.length+ 'Case(s) to be Created');

            // STEP 1 - CREATE CASE
         await  createCaseRecord({newCase: nCase})
                .then(result => {
                    this.CaseNumber = result;
                    console.log('Sending Files to UPDATE: '+ this.filesToInsert);
                    
                    // STEP 2 - CALLS APEX TO LINK UPLOADED FILES TO CASE
                    updateFiles({passFiles: this.filesToInsert, CaseId: this.CaseNumber});
                    //CALLS APEX TO CREATE THE CASE PRODUCTS FROM THE ORDER LINES
                    //createCaseProduct({orderLines: this.orderLines, CaseNumber: this.CaseNumber});

                    // STEP 3 - CREATE CASE PRODUCTS
                    // FOR EACH ITEM IN THE ORDER LIST, CREATES A NEW ARRAY AND INSTANTIATES A NEW SHIPMENT DETAIL (CASE PRODUCT) OBJECT RECORD
                    // THIS WILL THEN CALL THE APEX CLASS TO INSERT THE LIST
                    console.log('Passing Order Lines to Create Case Products: '+ JSON.stringify(this.orderLines));
                    let tempHold = JSON.stringify(this.orderLines);
                    console.log('Temp Hold Values: '+ tempHold);
                    var linesList = JSON.parse(tempHold);
                    console.log("Lines in the List: "+ JSON.stringify(linesList));
                    console.log('Length of Lines List: '+ linesList.length);

                    var i;
                    for(i = 0; i < linesList.length; i++){
                        console.log('I = '+ i);
    
                        // CHECKS FOR PROPERTY IN THE LINES LIST --> TO BE USED FOR NEXT IF CONDITION/STATEMENT    
                        let resultCheck = linesList[i].hasOwnProperty('Requested_Action_Override__c');
                        
                        console.log('Array Check: '+resultCheck)
                            // CHECKS TO SEE IF THE LINE EQUALS RETURN AND REPLACEMENT OR LINE DOES NOT HAVE RAO PROPERTY AND HEADER ACTION IS RETURN AND REPLACEMENT
                            if(linesList[i].Requested_Action_Override__c == "Return and Replacement" || (resultCheck === false && this.requestedAction == "Return and Replacement")){
                                
                                // SPLITS THE LINE OR HEADER ACTION TO RETURN, REPLACEMENT INTO AN ARRAY
                                var splitReqAction = [];
                                   if(linesList[i].Requested_Action_Override__c == "Return and Replacement"){
                                        splitReqAction = linesList[i].Requested_Action_Override__c.split(' and ');
                                        console.log('LINE SPLIT - List Size: '+splitReqAction.length);
                                    } else{
                                        splitReqAction = this.requestedAction.split(' and ');
                                        console.log('HEADER SPLIT - List Size: '+splitReqAction.length);
                                    } 
                                // FOR EACH VARIABLE IN THE SPLIT ARRAY CREATE A CASE PRODUCT FOR EACH AND PUSH TO caseProductInsert List    
                                for(var k = 0; k < splitReqAction.length ; k++){
                                    console.log('K: '+k);
                                        console.log('Current Iteration:'+splitReqAction[k]);
                                        let nCaseProduct = {'sobjecttype': 'Shipment_Detail__c'};
                                        console.log('HEADER LEVEL EXECUTION');
                                        //nCaseProduct.Material_Number__c = linesList[i].SKU__c;
                                        //console.log('Material Assignment: '+linesList[i].SKU__c);
                                            nCaseProduct.GE_NAS_Case_Number__c = this.CaseNumber; 
                                            nCaseProduct.GE_NAS_Type_of_Problem1__c = splitReqAction[k];
                                            nCaseProduct.GE_NAS_Type_of_Problem__c = 'Return - '+splitReqAction[k];
                                            nCaseProduct.Unique_ID__c = linesList[i].Invoice__c+' | '+linesList[i].PO__c+' | '+splitReqAction[k]+' | '+linesList[i].Transaction_ID__c;
                                                console.log('Action Assignment: '+splitReqAction[k]);
                                            nCaseProduct.PO__c = linesList[i].PO__c;
                                            nCaseProduct.Material_Number__c = linesList[i].Material__c;
                                                                                   
                                            nCaseProduct.GE_NAS_Product_Code__c = linesList[i].Product_SKU__c;
                                                console.log('SKU Assignment: '+ linesList[i].Product_SKU__c);
                                            nCaseProduct.Invoiced_Price__c = linesList[i].UnitPrice__c;
                                                console.log('Unit Price: '+ linesList[i].UnitPrice__c);
                                            nCaseProduct.Discrepancy_Qty__c = linesList[i].Return_Qty__c;
                                                console.log('Disputed QTY Assignment: '+ linesList[i].Return_Qty__c);
                                            nCaseProduct.Order_Qty__c = linesList[i].Quantity__c;
                                                console.log('Ordered Quantity: '+linesList[i].Quantity__c);
                                            nCaseProduct.Order__c = linesList[i].order__c;
                                                console.log('Ordered Order: '+linesList[i].order__c);
                                            nCaseProduct.Distributor_Name__c = linesList[i].Distributor_Name__c;
                                            nCaseProduct.Distributor_ID__c = this.selectedDistributorID;
                                            nCaseProduct.GE_NAS_Unit_of_Measure__c = linesList[i].UnitOfMeasure__c;
                                            nCaseProduct.QuickStock__c = linesList[i].Quick_Stock__c;
                                            nCaseProduct.Price_Agreement__c = linesList[i].Price_Agreement__c;
                                            nCaseProduct.Invoice_Line__c = linesList[i].Invoice_Line__c;
                                            nCaseProduct.SFDC_Invoice__c = linesList[i].SFDC_Invoice__c;  
                                        this.caseProductInsert.push(nCaseProduct);
                                        console.log('Items Pushed to CP List: '+ JSON.stringify(this.caseProductInsert));
                                }
                            } else {
                                let nCaseProduct = {'sobjecttype': 'Shipment_Detail__c'};
                                nCaseProduct.GE_NAS_Case_Number__c = this.CaseNumber;
                                console.log('LINE LEVEL EXECUTION');

                                    //CHECK REQUESTED OVERRIDE ACTION (LINE LEVEL) IS BLANK. IF SO (ELSE BRANCH), USE HEADER SELECTION. IF NOT (IF BRANCH), USE LINE LEVEL
                                    if(linesList[i].hasOwnProperty('Requested_Action_Override__c') && linesList[i].Requested_Action_Override__c !== "Return and Replacement"){
                                        nCaseProduct.GE_NAS_Type_of_Problem1__c = linesList[i].Requested_Action_Override__c;
                                        nCaseProduct.GE_NAS_Type_of_Problem__c = 'Return - '+linesList[i].Requested_Action_Override__c;
                                        nCaseProduct.Unique_ID__c = linesList[i].Invoice__c+' | '+linesList[i].PO__c+' | '+linesList[i].Requested_Action_Override__c +' | '+linesList[i].Transaction_ID__c;
                                    } else{
                                       // nCaseProduct.GE_NAS_Type_of_Problem1__c = this.requestedAction;
                                        nCaseProduct.GE_NAS_Type_of_Problem1__c = this.requestedAction;
                                        nCaseProduct.GE_NAS_Type_of_Problem__c = 'Return - '+this.requestedAction;
                                        nCaseProduct.Unique_ID__c = linesList[i].Invoice__c+' | '+linesList[i].PO__c+' | '+this.requestedAction +' | '+linesList[i].Transaction_ID__c;
                                    }
                                        console.log('Action Assignment: '+ linesList[i].Requested_Action_Override__c);
                                    nCaseProduct.PO__c = linesList[i].PO__c;
                                    nCaseProduct.Material_Number__c = linesList[i].Material__c;
                                    nCaseProduct.GE_NAS_Product_Code__c = linesList[i].Product_SKU__c;
                                        console.log('SKU Assignment: '+ linesList[i].Product_SKU__c);
                                    //nCaseProduct.Material_Number__c = linesList[i].SKU__c;
                                        //console.log('Material Assignment: '+linesList[i].SKU__c);
                                    nCaseProduct.Invoiced_Price__c = linesList[i].UnitPrice__c;
                                        console.log('Unit Price: '+ linesList[i].UnitPrice__c);
                                    nCaseProduct.Discrepancy_Qty__c = linesList[i].Return_Qty__c;
                                        console.log('Disputed QTY Assignment: '+ linesList[i].Return_Qty__c);
                                    nCaseProduct.Order_Qty__c = linesList[i].Quantity__c;
                                        console.log('Ordered Quantity: '+linesList[i].Quantity__c);
                                    nCaseProduct.Order__c = linesList[i].order__c;
                                        console.log('Ordered Order: '+linesList[i].order__c);
                                    nCaseProduct.Distributor_Name__c = linesList[i].Distributor_Name__c;
                                        console.log('Distributor Name: '+linesList[i].Distributor_Name__c);
                                    nCaseProduct.Distributor_ID__c = this.selectedDistributorID;
                                    nCaseProduct.GE_NAS_Unit_of_Measure__c = linesList[i].UnitOfMeasure__c;    
                                    nCaseProduct.QuickStock__c = linesList[i].Quick_Stock__c;
                                    nCaseProduct.Price_Agreement__c = linesList[i].Price_Agreement__c;
                                    nCaseProduct.Invoice_Line__c = linesList[i].Invoice_Line__c;
                                    nCaseProduct.SFDC_Invoice__c = linesList[i].SFDC_Invoice__c;    
                                    this.caseProductInsert.push(nCaseProduct);
                            }
                           
                    }
                        console.log('Total: '+ this.caseProductInsert.length +'- Case Products to Insert: '+ JSON.stringify(this.caseProductInsert));
                        createCaseProduct({newCaseProduct : this.caseProductInsert}); 


                    console.log(result);
                    
                })
                .catch(error => {
                    console.log(error);
                    this.error = error;
                });  
             await getCaseNumber({CaseId: this.CaseNumber})
                .then(result => {
                    this.caseNumberNew = result;
                    console.log(JSON.stringify("The Result for Case Number: "+ JSON.stringify(this.caseNumberNew)))
                    if (this.caseNumberNew != ' '){
                        this.isSpinner = false;
                        this.goToStepFour();
                    }
                })
                .catch(error => {
                    console.log(error);
                    this.error = error;
                    this.isSpinner = false;
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

    goToStepTwo() {

            this.currentStep = '2';
            
            this.template.querySelector('div.stepOne').classList.add('slds-hide');
            this.template
                .querySelector('div.stepTwo')
                .classList.remove('slds-hide');
        
        
    }
    goBackToStepTwo() {
        this.currentStep = '2';

        this.template.querySelector('div.stepThree').classList.add('slds-hide');
        this.template
            .querySelector('div.stepTwo')
            .classList.remove('slds-hide');
    }
    async goToStepThree(event) {
        this.currentStep = '3';

        this.template.querySelector('div.stepTwo').classList.add('slds-hide');
        this.template
            .querySelector('div.stepThree')
            .classList.remove('slds-hide');
        
            console.log('Contact ID to be SET on CASE: '+ this.contactID);

        this.soldToAccount = this.soldToAccount;
        console.log('Sold To Account: '+this.accountName);
        this.reqName = this.template.querySelector(".rn").value;
        console.log('Requestor Name: '+this.reqName);
        this.reqEmail = this.template.querySelector(".em").value;
        console.log('Requestor Email: '+this.reqEmail);
        this.reqPhone = this.template.querySelector(".rp").value;
        console.log('Requested Phone: '+this.reqPhone);
        this.returnReason = this.template.querySelector(".rr").value;
        console.log('Return Reason: '+this.returnReason);
        this.secondaryReason = this.template.querySelector(".sr").value;
        console.log('Secondary Return Reason: '+this.secondaryReson);
        this.requestedAction = this.template.querySelector(".ra").value;
        console.log('Requested Action: '+this.requestedAction);
        this.comments = this.template.querySelector(".cm").value;
        console.log('Comments: '+this.comments);
    
        var inputData={
            Account:this.selectedAccountName,
            //SoldTo: this.selectedSoldToAccountName,
            RequestorName:this.reqName,
            RequestorEmail:this.reqEmail,
            RequestorPhone:this.reqPhone,
            ReturnReason:this.returnReason,
            RequestedAction:this.requestedAction,
            SecondaryReason:this.secondaryReason,
            Comments:this.comments
        };
        this.template.querySelector("c-return-replace-child-l-w-c").setConfirmValues(inputData);
        /*
        if(this.userType == "Agent"){
            this.setAccountID = this.soldToAccount;
        }else {
            this.setAccountID = this.orderAgent;
        }
        await getReturnsQueueId({accountId : this.setAccountID})
        .then(result=>{
            if(result){
                this.caseOwnerId = result;
                console.log('SETTING CASE QUEUE....'+this.caseOwnerId);
            } 
        })*/
        this.getCaseOwner();
        
    }

    goToStepFour(){
        //this.isSpinner = false;
        this.currentStep = '4';
        
            this.template.querySelector('div.stepThree').classList.add('slds-hide');
            this.template
                .querySelector('div.stepFour')
                .classList.remove('slds-hide');

                updateInvoiceLines({lines : this.invLinesToUpdate})
                .then(result => {
                   console.log('INVOICE LINES RESET....'+result);
                });
    }

    async getCaseOwner(){

        if(this.userType == "Agent"){
            this.setAccountID = this.soldToAccount;
            await getReturnsQueueId({accountId : this.setAccountID, userType : this.userType})
            .then(result=>{
                    if(result){
                        this.caseOwnerId = result;
                        console.log('SETTING CASE QUEUE BASED ON AGENT....'+this.caseOwnerId);
                    } 
                })
        } else {
            if(this.orderAgent != null){
                this.setAccountID = this.orderAgent;
                await getReturnsQueueId({accountId : this.setAccountID, userType : this.userType})
                .then(result=>{
                        if(result){
                            this.caseOwnerId = result;
                            console.log('SETTING CASE QUEUE BASED ON ORDER AGENT....'+this.caseOwnerId);
                        } 
                    })
            } else {
                await getReturnsQueueId({accountId : null, distributorId : this.selectedDistributorID, userType : this.userType})
                .then(result=>{
                        if(result){
                            this.caseOwnerId = result;
                            console.log('SETTING CASE QUEUE BASED ON ORDER AGENT....'+this.caseOwnerId);
                        } 
                    })
            }
        }


    }

   // DO NOT DELETE THIS METHOD, WILL BE USED
   /* handleNameChange(){
        let rName = this.template.querySelector(".rn");
        let rNameValue = rName.value;
        if(!rNameValue){
            rName.setCustomValidity("Requestor Name required");
            this.stepOneButton = true;
            this.renderedCallback();

        } else{
            rName.setCustomValidity("");
            this.stepOneButton = false;
        }
        rName.reportValidity();     
    }*/

    handleValidation(){

        let acctName = this.soldToAccount;
        if (!acctName){
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

    // USED TO DELETE FILES FROM THE FILES UPLOAD TABLE
    async handleDelete(event) {
        console.log('Executing Delete on File......');
        const row = event.detail.row;
        console.log('ROW ID Selected: '+row.Id);
        let contentDocumentId = row.Id;
            console.log('This record is about to be Deleted: '+ contentDocumentId);
            deleteRecord(contentDocumentId)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'File deleted',
                            variant: 'success'
                        })
                    );
                    const index = this.filesToInsert.indexOf(contentDocumentId);
                    this.filesToInsert.splice(index, 1);
                    if(this.filesToInsert.length > 0){
                        this.showFiles = true;
                    } else{
                        this.showFiles = false;
                    }
                    getRelatedFiles({newFiles: this.filesToInsert})

                            .then(result => {
                                this.files = result;
                                if(this.files.length > 0){
                                    this.showFiles = true;
                                } else{
                                    this.showFiles = false;
                                }
                                console.log(result);
                                console.log('Files Returned from Apex: ' + result);
                            })
                            .catch(error => {
                                console.log(error);
                                this.error = error;
                                console.log('Apex failed...');
                            }); 
                })
    }

    goHome(event){
        var baseURL = window.location.origin;
        console.log('Base URL: '+baseURL);
        this.sfdcOrgURL = baseURL+'/s/';
        console.log('New URL: '+this.sfdcOrgURL);
        window.open(this.sfdcOrgURL, "_self");
    }

    goToCase(event){
        var baseURL = window.location.origin;
        console.log('Base URL: '+baseURL);
        this.sfdcOrgURL = baseURL+'/s/case/'+this.CaseNumber+'/detail';
        console.log('New URL: '+this.sfdcOrgURL);
        window.open(this.sfdcOrgURL, "_self");
    }

    async handlePhoneChange(event){
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

    beforeUnloadHandler(event){
        console.log("beforeUnloadHandler called");
        updateInvoiceLines({lines : this.invLinesToUpdate})
                .then(result => {
                   console.log('INVOICE LINES RESET....'+result);
        });
       this.template.querySelector("c-invoice-item-search").clearSessionCart();
     
        //return "";
    }

    disconnectedCallback() {
        window.removeEventListener("beforeunload", this.beforeUnloadHandler);
    console.log("disconnectedCallback executed");
        
        
    }
}
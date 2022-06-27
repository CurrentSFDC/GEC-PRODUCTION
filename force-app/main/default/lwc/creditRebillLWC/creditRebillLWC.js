import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord, deleteRecord } from 'lightning/uiRecordApi';
import getInvoiceList from '@salesforce/apex/CreditDebitController.getInvoiceList';
import getInvoiceItemRefList from '@salesforce/apex/CreditDebitController.getInvoiceItemRefList';
import updateInvoiceLines from '@salesforce/apex/connectCreateCase.updateInvLines';
import updateReturnItemList from '@salesforce/apex/CreditDebitController.updateReturnItemList';
import getReturnList from '@salesforce/apex/CreditDebitController.getReturnList';
import invoiceListData from '@salesforce/apex/CreditDebitController.invoiceListData';
import getOrderDetails from '@salesforce/apex/OrderProductController.getOrderDetails';
import findInvLineRecords from "@salesforce/apex/LwcLookupControllerCust.preLoadLineRecords";
import preLoadLineRecords from "@salesforce/apex/LwcLookupControllerCust.preLoadLineRecords";
import agentAndSoldToFiltering from "@salesforce/apex/LwcLookupControllerCust.agentAndSoldToFiltering";
import orderInitiatedFiltering from "@salesforce/apex/LwcLookupControllerCust.orderInitiatedFiltering";


import getAgentIdNew from '@salesforce/apex/CreditDebitController.getAgentId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import PHONE_FIELD from '@salesforce/schema/User.Phone';
import CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';
import USER_TYPE_FIELD from '@salesforce/schema/User.User_Type__c';
import getCSOwnerId from '@salesforce/apex/connectCreateCase.getCSOwnerId';
import getAgentId from '@salesforce/apex/connectCreateCase.getAgentId';
import createCaseRecord from '@salesforce/apex/connectCreateCase.connectCreateReturnCase';
import createCaseProduct from '@salesforce/apex/connectCreateCase.createCaseProduct';
import getCaseNumber from '@salesforce/apex/connectCreateCase.getCaseNumber';
import getAccName from '@salesforce/apex/connectCreateCase.getAccountName';

//FETCHING FILE UPLOAD FROM APEX CLASSES
import updateFiles from '@salesforce/apex/connectCreateCase.updateFiles';
import getRelatedFiles from '@salesforce/apex/FileUploadViewController.getRelatedFiles';


const actions = [
    { label: 'edit', name: 'edit' },
    { label: 'Delete', name: 'delete' },
];

export default class CreditRebillLWC extends LightningElement {



 @track reviewColumns = [{
    label: 'Invoice #',
    fieldName: 'Invoice__c',
    iconName: 'utility:form',
    type: 'Text',
    sortable: true 
},
{
    label: 'PO#',
    fieldName: 'PO__c',
    type: 'Text',
    sortable: true 
},
{
    label: 'Sold To',
    fieldName: 'Distributor_Name__c',
    type: 'Text',
    sortable: true 
},
{
    label: 'Catalog #',
    fieldName: 'Product_SKU__c',
    iconName: 'utility:products',
    type: 'Text',
    sortable: true
},
{
    label: 'SKU #',
    fieldName: 'SKU__c',
    type: 'Text',
    sortable: true,
    cellAttributes: { alignment: 'center' }
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
    sortable: true
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
    cellAttributes: { alignment: 'center' }
},
{
    label: 'Quick Stock',
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
    label: 'Qty',
    fieldName: 'Return_Qty__c',
    iconName: 'utility:number_input',
    type: 'number',
    sortable: true
},
{
    label: 'Action',
    fieldName: 'Requested_Action_Override__c',
    iconName: 'utility:button_choice',
    type: 'picklist',
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
}
      
];


    @api cartCount = 0;
    @api soldToAccount=[];
    @api soldToName;
    @api caseProductInsert = [];
    
    
    @api reqBoxValue;
    @api transactionID;
    @api storedLines=[];
    @api selectedInvoice;
    @api valuetopass;
    @api files; // TEMPORARILY STORES THE FILES UPLOADED IN THE FILEUPLOADVIEWER COMPONENT
    @api fileToDelete; // SELECTED FILES TO BE DELETED FROM THE FILEUPLOADVIEWER COMPONENT
    @api orderLines;
    @api orderingAgency=[];

    @track agencyName='Agency Name';
    @track isInvoiceItemAvailable= false;
    @track invoiceItemList;
    @track isSpinner = false;
    @track isLoading = false;
    @track reqName;
    @track reqEmail;
    @track reqPhone;
    @track invoiceNum;
    @track invoiceLineNum;
    @track reasonCode;
    @track caseNumberNew;
    @track cartLabel; 
    @track bShowModal = false;
    @track bShowModal1 = false;
    @track currentRecordId;
    @track currentRecordDtl;
    @track isEditForm = false;
    @track flagIndi = false;
    @track error;
    @track errorMessage;
    @track invoiceItemNewList;
    @track toggleSubmitLabel = "Submit";
    value = [];
    @track filesToInsert = []; 
    @track disAccount = 'DEFAULT';
    @track lstAllFiles = []; // ARRAY OF FILES TO BE INSERTED INTO THE DATABASE 
    @track agentNumber ='DEFAULT';
    @track agentNumberDis =[];
    @track showNextButton = true;
    @track showDistroField = false;
    @track disName=[];
    @track invoiceNumber;
    @track invoicePO;
    @track transactionTotal = 0.00;
    @track action;
    @track stepOneButton = false;

    @track accountSelected;
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
    @track orderID;
    @track preSelectedAccount;
    @track preSelectedSoldTo;
    @track caseType = 'Credit';
    @track caseContactEmail;
    @track preLoadedLines = [];
    @track orderAgentNumber;
    @track orderAgentAccount = "";
    @track caseAccountId;
    @track caseSoldToId;

    get acceptedFormats() {
        return ['.pdf','.png','.jpg','.jpeg','.doc','.docx', '.xls','.xlsx','.ppt','.pptx','.odt', '.rtf'];
    }

    get message() {
        return ['Formats: '+'pdf','png','jpg','jpeg','doc','docx', 'xls','xlsx','ppt','pptx','odt', 'rtf' + ' Max File Size: 10 MB'];
    }
    

                // COLUMNS FOR THE VIEW CART MODAL  GE_LGT_EM_InvoiceHeaderNumber__r.Name,  
                @track cartColumns = [
                    {
                        label: 'Invoice #',
                        fieldName: 'Invoice__c',
                        iconName: 'utility:form',
                        type: 'Text',
                        sortable: true 
                    },
                    {
                        label: 'PO#',
                        fieldName: 'PO__c',
                        type: 'Text',
                        sortable: true 
                    },
                    {
                        label: 'Sold To',
                        fieldName: 'Distributor_Name__c',
                        type: 'Text',
                        sortable: true 
                    },
                    {
                        label: 'Catalog #',
                        fieldName: 'Product_SKU__c',
                        iconName: 'utility:products',
                        type: 'Text',
                        sortable: true
                    },
                    {
                        label: 'SKU #',
                        fieldName: 'SKU__c',
                        type: 'Text',
                        sortable: true,
                        cellAttributes: { alignment: 'center' }
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
                        sortable: true
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
                        cellAttributes: { alignment: 'center' }
                    },
                    {
                        label: 'Quick Stock',
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
                        label: 'Qty',
                        fieldName: 'Return_Qty__c',
                        iconName: 'utility:number_input',
                        type: 'number',
                        sortable: true
                    },
                    {
                        label: 'Action',
                        fieldName: 'Requested_Action_Override__c',
                        iconName: 'utility:button_choice',
                        type: 'picklist',
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
    
            creditColumns = [{
                label: 'Invoice #',
                fieldName: 'GE_LGT_EM_SAP_Invoice_Number__c',
                iconName: 'utility:form',
                type: 'Text',
                //sortable: true
            },
            {
                label: 'Order #',
                //fieldName: 'GE_LGT_EM_Order_Number__c',
                fieldName: 'newNumber',
                type: 'Text',
                //sortable: true,
                cellAttributes: { alignment: 'center' }
            },
            {
                label: 'PO #',
                fieldName: 'GE_LGT_EM_Customer_PO_Number__c',
                type: 'Text',
                //sortable: true,
                cellAttributes: { alignment: 'center' }
            },
            {
                label: 'Catalog #',
                fieldName: 'GE_LGT_EM_Material_Description__c',
                iconName: 'utility:products',
                type: 'Text',
                //sortable: true
            },
            {
                label: 'SKU #',
                fieldName: 'SKU__c',
                iconName: 'utility:products',
                type: 'Text',
                //sortable: true
            },
            {
                label: 'Inv. Qty',
                fieldName: 'GE_LGT_EM_Invoiced_Quantity__c',
                type: 'Text',
                iconName: 'utility:number_input',
                //sortable: true,
                hideDefaultActions: true,
                cellAttributes: { alignment: 'center' }
            },
            {
                label: 'Unit Price',
                fieldName: 'GE_LGT_EM_Invoiced_Price__c',
                iconName: 'utility:money',
                type: 'currency',
                //sortable: true
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
                cellAttributes: { alignment: 'center' }
            },
            {
                label: 'QuickStock',
                fieldName: 'QuickStock__c',
                type: 'boolean',
                //sortable: true,
                cellAttributes: { alignment: 'center' }
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
                sortable: true
            },
            
            
            {
                label: 'Action',
                fieldName: 'Requested_Action_Override__c',
                iconName: 'utility:button_choice',
                wrapText: true,
                type: 'picklist',
               // editable: true,
               // sortable: true,
                typeAttributes: {
                    placeholder: 'Choose Action', options: [
                        { label: 'Return', value: 'Return' },
                        { label: 'Replacement', value: 'Replacement' },
                        { label: 'Return and Replacement', value: 'Return and Replacement' },
                    ] // list of all picklist options
                    , value: { fieldName: 'Return' }
                    , context: { fieldName: 'Id' } }// default value for picklist
                    
            },
            {
                type: 'button-icon',
                initialWidth: 34,
                typeAttributes:{
                    label: 'Edit',
                    name: 'edit',
                    rowActions: actions,
                    title: 'edit',
                    iconName: 'utility:new',
                    class: 'buttonIcon',
                    variant: 'brand',
                    disabled: {fieldName: 'actionDisabled'},
                    
                },
                cellAttributes:{
                    disabled: {fieldName: 'actionDisabled'}
                }
                
                /*type: 'action',
                typeAttributes: { rowActions: actions },
                cellAttributes: { iconName: 'utility:edit' }*/
            },
            
            ]; 

    get RAoptions() {
        return [
            { label: 'Freight', value: 'Freight' }, 
            { label: 'Price Issue', value: 'Price Issue' },
            { label: 'Rebate/Marketing', value: 'Rebate/Marketing' },
            { label: 'Shortage/Overage', value: 'Shortage/Overage' },
            { label: 'Tax', value: 'Tax' },
            { label: 'Terms', value: 'Terms' },
        ];
    }


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
                    console.log('setting email: '+this.reqEmail);
                    this.reqName = data.fields.Name.value;
                    console.log('setting name: '+this.reqName);
                    this.reqPhone = data.fields.Phone.value;
                    console.log('seeting phone: '+this.reqPhone);
                   
                }
                this.caseContactEmail = data.fields.Email.value;
                this.userType = data.fields.User_Type__c.value;
                this.contactID = data.fields.ContactId.value;
                //this.soldToAccount = data.fields.AccountId.value;
                this.convertPhone(this.reqPhone);
           /* getAgentId({AccountId: this.soldToAccount})
            .then(result => {
            this.agentNumber = result;
            if(this.agentNumber == 'N'){
                this.showDistroField = false;
               // this.disAccount='DEFAULT_DIS';
               getAgentIdNew({AccountId: this.soldToAccount})
               .then(result => {
                this.agentNumberDis = result;
                console.log(JSON.stringify("Distributor Id "+ JSON.stringify(this.agentNumberDis)))
                });
            }
            else{
                this.showDistroField = true;   
            }
            console.log(JSON.stringify("Agent Id "+ JSON.stringify(this.agentNumber)))
            });*/

            //var inputacc=this.soldToAccount;
            //this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
            this.setAccountfromSelector();
            
        }
    }
        //--------------------------------------------------

// SETTING ACCOUNT NAME FIELD FROM THE ACCOUNT SELECTOR WHEN CASE IS INITIATIED
async setAccountfromSelector(){
    let storedUserType = localStorage.getItem('User Type');
    this.template.querySelector("c-invoice-item-search").setVisibility(storedUserType);
    this.userType = localStorage.getItem('User Type');

    //AGENT PERSONA
    if(storedUserType == "Agent"){
        
        this.preSelectedAccount = localStorage.getItem('AgentName') + ' - ' + localStorage.getItem('AgentNumber') + ' - ' + localStorage.getItem('AgentSegment');
        this.selectorAccount = localStorage.getItem('AgentNumber');
        this.selectedAccountID =  localStorage.getItem('AgentID');
        this.caseAccountId = localStorage.getItem('AgentID'); //SETS ACCOUNT ID ON CASE
        this.selectedAccountName = localStorage.getItem('AgentName');
        console.log('Setting Account Lookup LWC - Preselected: '+this.selectorAccount);
        
        let retrieveData = localStorage.getItem('AgentID');
        let distributorData = localStorage.getItem('DistributorID');
        if (distributorData != null){
            this.preSelectedSoldTo = localStorage.getItem('DistributorName') + ' - ' + localStorage.getItem('DistributorAccount') + ' - ' + localStorage.getItem('DistributorSegment');
            this.distributorNumber = localStorage.getItem('DistributorAccount');
            this.selectedDistributorID = localStorage.getItem('DistributorID');
            this.caseSoldToId = localStorage.getItem('DistributorID'); //SETS CASE SOLD TO ID FIELD
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
                console.log('Sending Sold To for Preloading Lines: '+this.distributorNumber);

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
        console.log('PRE SELECTED SOLD TO: '+this.preSelectedSoldTo);
        //let disAccountName = sessionStorage.getItem('DistributorName');
        //let disAccountSegment = sessionStorage.getItem('DistributorSegment');
        //let disID = sessionStorage.getItem('DistributorID');
        if(retrieveData != null){
            console.log('Setting Account From Selector: '+JSON.stringify(retrieveData));
            this.soldToAccount = retrieveData;
            var inputacc = retrieveData;
            console.log('Sending Account ID to Account Search: '+inputacc);
            //this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
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
        
        this.caseAccountId = localStorage.getItem('DistributorID');
        this.caseSoldToId = localStorage.getItem('DistributorID');

        //this.caseSoldTo = localStorage.getItem('DistributorID');
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
            //this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
            console.log('Setting Account Number from Local Storage: '+inputacc);
        }

         //GET INVOICE LINES FOR PRELOADING - DISTRIBUTOR PERSONA
        
         this.sfdcOrgURL = window.location.href;
         if(this.sfdcOrgURL.includes('id=')==false){
            console.log('CALLING APEX TO PRELOAD LINES FOR --> DISTRIBUTOR ONLY....');
             console.log('Sending Account for Preloading Lines: '+this.distributorNumber);

             preLoadLineRecords({filterField: this.distributorNumber, userType : this.userType})
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
//--------------------------------------------------------------------------

       /* @api 
        get type() {
        return this._type;
        }
     
        set type(value) {
        this._type = value;
        this.connectedCallback();
        }*/

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

          // SETS THE ORDER AND SOLD TO ACCOUNT BASED ON THE ORDER INITIATION
    handleDefaultOrder() {
       
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
                    if(this.userType == 'Agent'){
                        this.caseSoldTo = result[0].Sold_To__c;
                    } else {
                        this.caseAccountId = result[0].Sold_To__c;
                        this.caseSoldToId = result[0].Sold_To__c;
                    }
                } else {
                    this.orderAgentAccount = result[0].Agent_Account__c;
                    if(this.userType == 'Agent'){
                        this.caseAccountId = this.orderAgentAccount;
                        this.caseSoldToId = result[0].Sold_To__c;
                    } else {
                        this.caseAccountId = result[0].Sold_To__c;
                        this.caseSoldToId = result[0].Sold_To__c;
                    }
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

      // DATA PASSED FROM c/lightningWebCompDataTableOrderItem CHILD COMPONENT AND SETS THIS.ORDERLINES ARRAY
      confirmUpdate(event){
        this.storedLines = event.detail.lines;
        if(this.storedLines.length > 0){
            this.showNextButton = false;
        } else {
            this.showNextButton = true;
        }
        console.log('The lines passed to Parent: '+JSON.stringify(this.orderLines));
    }

        handleActionPick(event){
            this.action = event.target.value;
            console.log('Reason : ' +this.action);
        }

        handleAccountSelected(event){
       
            this.selectorAccount = event.detail.selectedAccount;
            if(this.userType == "Agent"){
                this.selectedAccountID = event.detail.selectedAccountId;
                this.caseSoldToId = event.detail.selectedAccountId;

            } else {
                this.selectedDistributorID = event.detail.selectedAccountId;
                this.caseAccountId = event.detail.selectedAccountId;
                this.caseSoldToId = event.detail.selectedAccountId;            
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
        
            this.selectedSoldToAccountName = event.detail.soldToName;
            this.selectedDistributorID = event.detail.soldto;
            this.caseSoldToId = event.detail.soldTo;
            console.log('SOLD TO Account Selected from AccountLookupLWC: '+this.selectedAccountName);
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

       /* get selectedValues() {
            return this.value.join(',');
        }*/

        // HANDLES THE FOUND ORDER FROM THE InvoiceItemSearchLWC CHILD COMPONENT
        orderRetrieved(event){
            this.orderAgent = event.detail.orderAgent;
            console.log('ORDER AGENT ACCOUNT ID: '+this.orderAgent);
                    
        }

        async handleChangeAcc(event){
           // this.soldToAccount = event.target.value;
           this.soldToAccount = event.detail.selectedRecordId;
           // this.soldToName = event.target.dataset.name;
            console.log('Sold To Account ID: '+ this.soldToAccount);
           // console.log('Sold To Account Name: '+ this.soldToName);
         
           await getAccName({id_dtl: this.soldToAccount})
            .then(result => {
            this.accName = result;
            console.log(JSON.stringify("Account Name Selected "+ JSON.stringify(this.accName)))
            });
            
           await getAgentId({AccountId: this.soldToAccount})
            .then(result => {
            this.agentNumber = result;
            console.log(JSON.stringify("Agent Id "+ JSON.stringify(this.agentNumber)))
            });

            if(this.agentNumber == 'N'){
                this.showDistroField = false;
               // this.disAccount='DEFAULT_DIS';
              await getAgentIdNew({AccountId: this.soldToAccount})
               .then(result => {
                this.agentNumberDis = result;
                console.log(JSON.stringify("Distributor Id "+ JSON.stringify(this.agentNumberDis)))
                });
            }
            else{
                this.showDistroField = true; 
            }
        
    
        }

        appendLines(event){
        
            this.invLinesToUpdate = event.detail.lineId;
            console.log('Invoice Lines to Modiify: '+JSON.stringify(this.invLinesToUpdate));
        }

        cartActions(event){
            const actionName = event.detail.action.name;
            const row = event.detail.row;
    
            console.log('Delete ActionName: '+ actionName);
            console.log('Delete Row: '+ JSON.stringify(row));
            switch (actionName) {
                case 'delete':
                    this.deleteCurrentRecord(row);
                    break;
                default:
            }
       }
    
       deleteCurrentRecord(currentRow){
           var currentRecordId = currentRow.Id;
           const deduction = (currentRow.Return_Qty__c * currentRow.UnitPrice__c);
           deleteRecord (currentRecordId)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Line has been deleted from the cart',
                        variant: 'success'
                    })
                );
                
                        this.fetchReturnItems();
                
            })
       }
    
       clearCart(event){
        for(var i = 0, len = this.storedLines.length; i < len; i++){
            deleteRecord (this.storedLines[i].Id)
            .then(() => {
                
                
                        this.fetchReturnItems();
                
            })
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Line has been deleted from the cart',
                    variant: 'success'
                })
            );
        }
       }

        confirmchange(event){
            this.orderLines = event.detail.selectedRecordId;
            this.orderingAgency=event.detail.selectedValue;
            console.log('The lines passed to child for Ordering: '+this.orderLines);
            this.disAccount = this.orderLines;
            if(this.orderingAgency==null){
                this.disName=[];
            }
            else{
            this.disName = this.orderingAgency;
            }

             getAgentIdNew({AccountId: this.disAccount})
            .then(result => {
            this.agentNumberDis = result;
            console.log(JSON.stringify("Distributor Agent Id "+ JSON.stringify(this.agentNumberDis)))
            });
        }

        async handleChange(event) {
            //console.log("You selected an order: " + event.detail.value[0]);
            //this.selectedInvoice = event.detail.value[0];
            this.selectedInvoice = event.detail.selectedRecordId;
            console.log("Invoice passed:" +this.selectedInvoice );

            //console.log("You selected an order: " + event.target.value);
            //this.selectedInvoice = event.target.value;

            /*UNCOMMENT THIS console.log("You selected an Invoice: " + event.detail.data.selectedId);
            this.selectedInvoice = event.detail.data.selectedId;*/

            await getInvoiceList({invoiceId: this.selectedInvoice})
            .then(result => {
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(result)));
            this.invoiceItemList  = result;
            this.invoiceNumber = result[0].GE_LGT_EM_SAP_Invoice_Number__c;
            console.log('Invoice Number: '+this.invoiceNumber);
            this.invoicePO = result[0].GE_LGT_EM_Customer_PO_Number__c;
            console.log('Invoice PO: '+this.invoicePO);
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(this.oItemList)));
            this.isInvoiceItemAvailable = true;
       
                       

            }).catch(error => {
            console.log("The error SENT TO APEX is: " +JSON.stringify(error));
            this.error = error;        
            });
        }

        //USED FOR WHEN FILES ARE UPLOADED INTO THE SYSTEM USING THE UPLOAD FEATURE    
handleUploadFinished(event) {
    // Get the list of uploaded files
    const lstUploadedFiles = event.detail.files;
    //alert(event.detail.files[0].documentId);
    lstUploadedFiles.forEach(fileIterator => this.filesToInsert.push(fileIterator.documentId));
    console.log('Uploaded Files: ' + this.lstAllFiles);
    //this.filesToInsert = this.lstAllFiles;
    console.log('Files to Insert: ' + this.filesToInsert);
    
    console.log('Executing Apex Call...')
    console.log('Passing File IDs to Apex: ' + this.filesToInsert);

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

handleRowActions(event) {
    this.cartLabel = "Add to Request";
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    console.log('Edit ActionName: '+ actionName);
    console.log('Edit Row: '+ JSON.stringify(row));
    switch (actionName) {
        case 'edit':
            this.editCurrentRecord(row);
            break;
        case 'show_details':
            this.showRowDetails(row);
            break;
        default:
    }
}

// view the current record details
viewCurrentRecord(currentRow) {
    this.bShowModal1 = true;
    this.isEditForm = false;
    this.record = currentRow;
}

// closing modal box
closeModal1() {
    this.bShowModal1 = false;
}

editCurrentRecord(currentRow) {
    // open modal box
    this.bShowModal1 = true;
    this.isEditForm = true;

    // assign record id to the record edit form
    this.currentRecordId = currentRow.Id;
}

// handleing record edit form submit
handleSubmit(event) {

    this.errorMessage = "";
    this.cartLabel = "Adding to Request...";
    this.isLoading = true;
    // prevending default type sumbit of record edit form
    //event.preventDefault();

    // querying the record edit form and submiting fields to form
    console.log('Inbuilt Form Data Check: ' + JSON.stringify(event.detail.fields));
    //this.template.querySelector('lightning-record-edit-form').submit(event.detail.fields);
    const recordInputs = event.detail.fields.slice().map(draft=>{
        const fields = Object.assign({}, draft)
        return {fields}
    })
    console.log("recordInputs", recordInputs)

    const promises = recordInputs.map(recordInput => updateRecord(recordInput))
    Promise.all(promises).then(result=>{
        this.ShowToastMsg('Success', 'Invoice Details Updated')
      // this.draftValues=[];   
      // console.log('Before Refresh: '+ JSON.stringify(this.orderItemList));
      // console.log('Check for Refresh: '+ this.selectedOrder);

    // showing success message
}).catch(error=>{
    this.ShowToastMsg('Error Updating Records', error.body.message, error)
});
    }


// refreshing the datatable after record edit form success
async handleSuccess() {
    await getInvoiceItemRefList({invoiceId: this.selectedInvoice}) 
            .then(result => {
                this.invoiceItemList = result;
                console.log(result);
                console.log('After refresh datatable data: ' + JSON.stringify(this.invoiceItemList));
                this.ShowToastMsg('Success', 'Invoice Details Updated')
                 // closing modal
                 this.bShowModal1 = false;
            });
        this.handleClick(); 
 }

 ShowToastMsg(title, message, variant){
    this.dispatchEvent(
        new ShowToastEvent({
            title:title,
            message:message,
            variant:variant||'success'
        })
    )
    }

 async handleClick( event ){

    //const updatedFields = event.detail.draftValues;

    await invoiceListData({transId: this.currentRecordId}) 
       .then(result => {
           this.invoiceItemNewList = result;
           console.log(result);
           console.log('Value passed from Apex for currentrow: ' + JSON.stringify(this.invoiceItemNewList));
       });
   //var selRows = this.template.querySelector('lightning-datatable');
    var selected = this.invoiceItemNewList;
    console.log('Edit Row: '+ JSON.stringify(selected));
    //console.log('Values for EDIT: '+this.draftValues);
    //this.storedLines = selected;
    console.log('Stored Lines: '+ JSON.stringify(this.storedLines));
    var newselval = selected.map(row => { return { "SKU__c": row.SKU__c, "PO__c": row.GE_LGT_EM_Customer_PO_Number__c, "Quantity__c": row.GE_LGT_EM_Invoiced_Quantity__c, "UnitPrice__c": row.GE_LGT_EM_Invoiced_Price__c,
        "Order_Line_Number__c":row.GE_LGT_EM_SAP_Invoice_Number__c,"Reason_Code__c":row.Reason_Code__c,"Extended_Amount__c":row.Extended_Amount__c,
        "Requested_Action_Override__c":row.Action_Override__c, "Comments__c":row.Comment__c, "Product_SKU__c": row.GE_LGT_EM_Material_Description__c, "Type__c": "Credit",
        "Invoice_Line_Item__c":row.Id, "Transaction_ID__c": this.transactionID, "Unique_ID__c": this.transactionID+'_'+row.SKU__c }});

    
    
    this.valuetopass = selected;
    console.log('value to pass check:' + JSON.stringify(this.valuetopass));
    
    console.log('value to pass check:' + JSON.stringify(newselval));
    await updateReturnItemList({data: newselval})
    .then(result => {
        
        console.log(JSON.stringify("Apex update result: "+ result));
        this.flagIndi= true;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Records added to the cart successfully',
                variant: 'success'
            })
        );
        this.fetchReturnItems();
});

 }
 fetchReturnItems(){
    getReturnList({transId : this.transactionID})
        .then(result =>{
            this.storedLines = result;
            this.cartCount = this.storedLines.length;
            this.isLoading = false;
            console.log('RESULT: '+result.length);
                console.log('Transaction Total BEFORE LOOPING: '+this.transactionTotal);
                this.showNextButton = false;
                
                    this.transactionTotal = 0.00;
             
                    for(var i = 0, len = result.length; i < len; i++){
                        
                         var tempAmount = result[i].Extended_Amount__c;
                         this.transactionTotal += tempAmount;
                    }
                    //this.transactionTotal = tempAmount;
                    console.log('Transaction Total END OF LOOPING: '+this.transactionTotal);
                 /*else {
                    this.transactionTotal -= currentDeduction;
                } */   

                /*if(this.storedLines.length > 0){
                    var tempAmount = 0;
                    for(var Transaction_Total__c in result){
                        if (result.hasOwnProperty(Transaction_Total__c)){
                            tempAmount += parseFloat(result[Transaction_Total__c]);
                        }
                    }
                    this.transactionTotal = tempAmount;
                    console.log('Transaction Total END OF LOOPING: '+this.transactionTotal);
                }*/
                if(this.storedLines.length == 0){
                    
                    this.transactionTotal = 0.00;
                    this.storedLines = '';
                    console.log('Transaction Total: '+this.transactionTotal);
                }
  
    
            });
            
        }
   
   
       showWarranty(event){
           this.warrantyEntry = true;
           this.isOrderIdAvailable = false;
       } 
   
       showCart(event) {
           this.bShowModal = true; // display modal window
       }
   
       // to close modal window set 'bShowModal' tarck value as false
       closeModal() {
           this.bShowModal = false;
       } 
   
       // POTENTIAL FUTURE - SAVE CART FUNCTION
       saveCart(){
           localStorage.setItem('localStr',JSON.stringify(this.storedLines));
           var retrieveData = JSON.parse(localStorage.getItem('localStr'));
           console.log('Data in Saved Cart: '+JSON.stringify(retrieveData));
       }
   
       

//VALIDATION FOR REQUIRED FIELDS

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
       // this.template.querySelectorAll('lightning-input-field').forEach(element => {
         //   element.reportValidity();
        //});            
}

goBackToStepTwo() {
    this.currentStep = '2';

    this.template.querySelector('div.stepThree').classList.add('slds-hide');
    this.template
    
    .querySelector('div.stepTwo')
        .classList.remove('slds-hide');
}


async goToStepThree() {
    
    this.currentStep = '3';
        
        this.template.querySelector('div.stepTwo').classList.add('slds-hide');
        this.template
            .querySelector('div.stepThree')
            .classList.remove('slds-hide');
            this.template.querySelectorAll('lightning-input-field').forEach(element => {
                element.reportValidity();
            });    
            console.log(JSON.stringify("Move to the next screen Data check: "+ JSON.stringify(this.storedLines)));  
            
        //this.accName = this.template.querySelector(".sta").value;
        //console.log('Account Name '+this.accName);
        //this.catChange = this.template.querySelector(".mn").value;
        //console.log('Category of Change '+this.catChange);
        await getAccName({id_dtl: this.soldToAccount})
        .then(result => {
        this.accName = result;
        console.log(JSON.stringify("Account Name Selected "+ JSON.stringify(this.accName)))
        }); 
        this.reqName = this.template.querySelector(".rn").value;
        console.log('Requestor Name '+this.reqName);
        this.reqEmail = this.template.querySelector(".em").value;
        console.log('Requestor Email '+this.reqEmail);
        this.reqPhone = this.template.querySelector(".rp").value;
        console.log('Requestor Phone'+this.reqPhone);
        //this.invoiceNum = this.template.querySelector(".in").value;
       // console.log('CheckBox value'+this.invoiceNum);
       // this.invoiceLineNum = this.template.querySelector(".iln").value;
       // console.log('CheckBox value'+this.invoiceLineNum);
        this.reasonCode = this.template.querySelector(".mn").value;
        console.log('CheckBox value'+this.reasonCode);

        this.getCaseOwner();
        
    }

    async getCaseOwner(){

        if(this.userType == "Agent"){
            this.setAccountID = this.caseAccountId;
            await getCSOwnerId({accountId : this.setAccountID, userType : this.userType})
            .then(result=>{
                    if(result){
                        this.caseOwnerId = result;
                        console.log('SETTING CASE QUEUE BASED ON AGENT....'+this.caseOwnerId);
                    } 
                })
        } else {
            if(this.orderAgent != null){
                this.setAccountID = this.orderAgent;
                await getCSOwnerId({accountId : this.setAccountID, userType : this.userType})
                .then(result=>{
                        if(result){
                            this.caseOwnerId = result;
                            console.log('SETTING CASE QUEUE BASED ON ORDER AGENT....'+this.caseOwnerId);
                        } 
                    })
            } else {
                await getCSOwnerId({accountId : null, distributorId : this.caseSoldToId, userType : this.userType})
                .then(result=>{
                        if(result){
                            this.caseOwnerId = result;
                            console.log('SETTING CASE QUEUE BASED ON ORDER AGENT....'+this.caseOwnerId);
                        } 
                    })
            }
        }


    }


    async handleSave(event){
        //console.log(JSON.stringify("The Result is: "));
       
        
      /* await getCSOwnerId({AccountId: this.soldToAccount})
       .then(result => {
       this.newOwnerId = result;
       console.log(JSON.stringify("New Account ID: "+ JSON.stringify(this.newOwnerId)))
       })*/

        this.toggleSubmitLabel = "Submitting...";
        this.isSpinner = true;
        let nCase = { 'sobjectType': 'Case' };
        nCase.RecordTypeId = '0123j000000X8ys';
        nCase.OwnerId = this.caseOwnerId;
        nCase.ContactId = this.contactID;
        nCase.Origin = 'Connect';
        nCase.eLight_Form_Type__c = 'Credit/Debit';
        nCase.Connect_ID__c = this.transactionID;
        nCase.AccountId = this.caseAccountId;
        nCase.Sold_To_Account__c = this.caseSoldToId;
        /*nCase.AccountId = this.soldToAccount;
        if(this.userType == "Agent"){
            nCase.Sold_To_Account__c = this.selectedDistributorID;
            console.log('Setting Case Sold To: '+this.selectedDistributorID);
        }*/
        nCase.GE_NAS_Purchase_Order__c = this.invoicePO;
        nCase.Requestor_Email__c = this.reqEmail;
        nCase.eLight_Requestor_Phone__c = this.reqPhone;
        nCase.SuppliedEmail = this.caseContactEmail;
        nCase.GE_NAS_Invoice__c = this.invoiceNumber;
        //nCase.Order_Name__c = this.selectedInvoice;
        nCase.Type = 'Pricing';
        nCase.GE_NAS_Sub_Type__c = 'Credit / Debit';
        nCase.Subject = 'Credit/Debit Case';
        console.log(JSON.stringify("Output of the Result is: "+ JSON.stringify(nCase)));        

        

        await createCaseRecord({newCase: nCase})
        .then(result => {
            //console.log(JSON.stringify("Output of the Result is:113223 "));
            this.CaseNumber = result;
            console.log(JSON.stringify("The Result is: "+ JSON.stringify(this.CaseNumber)));             
            //updateOwnerId({CaseId: this.CaseNumber});              
            console.log('Passing Product Lines to Create Case Products: '+ JSON.stringify(this.storedLines));
            let tempHold = JSON.stringify(this.storedLines);
            console.log('Temp Hold Values: '+ tempHold);
            var linesList = JSON.parse(tempHold);
            console.log("Lines in the List: "+ linesList);
            console.log('Length of Lines List: '+JSON.stringify(linesList.length) );
            
            var j;
            for(j = 0; j < linesList.length; j++){
                console.log('Prod Line Length' + this.storedLines.length);
                console.log('J = '+ j);
                let nCaseProduct = {'sobjecttype': 'Shipment_Detail__c'};
                console.log('Prod Line check' + this.storedLines.length);
                    nCaseProduct.GE_NAS_Case_Number__c = this.CaseNumber;
                    nCaseProduct.GE_NAS_Type_of_Problem1__c = linesList[j].Requested_Action_Override__c;
                    nCaseProduct.Material_Number__c = linesList[j].Material__c;                                                
                    nCaseProduct.GE_NAS_Product_Code__c = linesList[j].Product_SKU__c; 
                    //nCaseProduct.Requested_Delivery_Date__c =  linesList[j].New_Shipment_Date__c;
                    nCaseProduct.GE_NAS_Comments__c =    linesList[j].Comments__c;
                    nCaseProduct.Unique_ID__c = linesList[j].Transaction_ID__c;   
                    nCaseProduct.PO__c = linesList[j].PO__c;   
                    nCaseProduct.Invoiced_Price__c = linesList[j].UnitPrice__c;         
                    nCaseProduct.Reason_Code__c = linesList[j].Reason_Code__c;   
                    nCaseProduct.Discrepancy_Qty__c = linesList[j].Return_Qty__c;
                    console.log('Disputed QTY Assignment: '+ linesList[j].Return_Qty__c);
                    //nCaseProduct.GE_NAS_Quantity_Ordered__c = linesList[i].Quantity__c;
                        // console.log('Ordered Quantity: '+linesList[i].Quantity__c);
                    nCaseProduct.Order__c = linesList[j].order__c;
                        console.log('Order Id: '+linesList[j].order__c);
                    nCaseProduct.Distributor_Name__c = linesList[j].Distributor_Name__c;
                    nCaseProduct.Distributor_ID__c = this.selectedDistributorID ;
                    nCaseProduct.GE_NAS_Unit_of_Measure__c = linesList[j].UnitOfMeasure__c;
                    nCaseProduct.Invoice_Line__c = linesList[j].Invoice_Line__c;
                    nCaseProduct.SFDC_Invoice__c = linesList[j].SFDC_Invoice__c;
                    nCaseProduct.QuickStock__c = linesList[j].Quick_Stock__c;  
                    nCaseProduct.Order_Qty__c = linesList[j].Quantity__c;
                                 
                    this.caseProductInsert.push(nCaseProduct);
                //console.log('Case Products to Insert: '+ JSON.stringify(this.caseProductInsert));    
            }
            console.log('Case Products to Insert: '+ JSON.stringify(this.caseProductInsert));  
            createCaseProduct({newCaseProduct : this.caseProductInsert});
            console.log(result);
            
        })

            .catch(error => {
                console.log(error);
                this.error = error;
            }); 

          await  getCaseNumber({CaseId: this.CaseNumber})
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

    goToStepFour(){
        this.currentStep = '4';
        //console.log(JSON.stringify("The step is: " + JSON.stringify(currentStep)));
        
            this.template.querySelector('div.stepThree').classList.add('slds-hide');
            this.template
                .querySelector('div.stepFour')
                .classList.remove('slds-hide');

                updateInvoiceLines({lines : this.invLinesToUpdate})
                .then(result => {
                   console.log('INVOICE LINES RESET....'+result);
                });
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
import { LightningElement, api, track, wire } from 'lwc';
import createCaseRecord from '@salesforce/apex/connectCreateCase.connectCreateReturnCase';
import updateInvoiceLines from '@salesforce/apex/connectCreateCase.updateInvLines';
import updateFiles from '@salesforce/apex/connectCreateCase.updateFiles';
import getRelatedFiles from '@salesforce/apex/FileUploadViewController.getRelatedFiles';
import createCaseProduct from '@salesforce/apex/connectCreateCase.createCaseProduct';
import getCaseNumber from '@salesforce/apex/connectCreateCase.getCaseNumber';
import getAccName from '@salesforce/apex/connectCreateCase.getAccountName';
//import getReturnsQueueId from '@salesforce/apex/connectCreateCase.getReturnsQueueId';
import getCSOwnerId from '@salesforce/apex/connectCreateCase.getCSOwnerId';
import { refreshApex } from '@salesforce/apex';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import Json2Apex from '@salesforce/resourceUrl/Json2Apex';
//import getOrderItemList from '@salesforce/apex/OrderProductController.getOrderItemList';
import getOrderItemList from '@salesforce/apex/OrderProductController.getOrderDetails'; // USED TO PULL ORDER INFORMATION FOR DEFAULTING 
import getOrderDetails from '@salesforce/apex/OrderProductController.getOrderDetails';
import findInvLineRecords from "@salesforce/apex/LwcLookupControllerCust.preLoadLineRecords";
import preLoadLineRecords from "@salesforce/apex/LwcLookupControllerCust.preLoadLineRecords";
import agentAndSoldToFiltering from "@salesforce/apex/LwcLookupControllerCust.agentAndSoldToFiltering";
import orderInitiatedFiltering from "@salesforce/apex/LwcLookupControllerCust.orderInitiatedFiltering";


import getOrderItemRefList from '@salesforce/apex/OrderProductController.getOrderItemRefList';
import { updateRecord } from 'lightning/uiRecordApi';
import getReturnList from '@salesforce/apex/OrderProductController.getReturnList';
import updateReturnItemList from '@salesforce/apex/OrderProductController.updateReturnItemList';
import orderListData from '@salesforce/apex/OrderProductController.orderListData';
import updateOrderItemList from '@salesforce/apex/OrderProductController.updateOrderItemList';
import getAgentId from '@salesforce/apex/connectCreateCase.getAgentId';
import updDisName from '@salesforce/apex/OrderProductController.updDisName';
// USED FOR GETTING THE USER DATA - WITHOUT APEX CALL
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import PHONE_FIELD from '@salesforce/schema/User.Phone';
import CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';
import USER_TYPE_FIELD from '@salesforce/schema/User.User_Type__c';
const actions = [
    { label: 'Edit', name: 'edit'},
];


export default class OverageLWC extends LightningElement {
    @api flexipageRegionWidth;
    @track toggleSubmitLabel = "Submit";
    @api caseType;
    @api transactionID; // DISPLAYS THE ID FOR THIS TRANSACTION --> USED IN BOTH FRONT AND BACKEND
    @api cartCount = 0; // GETS THE AMOUNT OF ITEMS IN THE CART --> USED TO VALIDATE BEFORE MOVING TO REVIEW
    @api contactID; // THE ID OF THE CURRENT USER (CONTACT INFORMATION) THAT IS SIGNED IN
    @api files; // TEMPORARILY STORES THE FILES UPLOADED IN THE FILEUPLOADVIEWER COMPONENT
    @api CaseNumber; // THE CASE ID THAT IS RETURNED AFTER SUBMIT
    @track currentStep; // SETS THE CURRENT STEP
    @track reqName; // REQUESTOR NAME FORM FIELD --> STEP 1
    @track reqEmail; // REQUESTTOR EMAIL FORM FIELD --> STEP 1
    @track reqPhone; // REQUESTOR PHONE FORM FIELD --> STEP 1
    @track accName;
    @track RAoptions;
    @track paramString=[];//TO GET THE DEFAULT ORDER ID
    @track paramStringNew=[];
    @track dType;
    @track dTypeNew;
    @track orderAgent;
    @track setAccountID;
    @track caseOwnerId;
    @track userType;

    //@track RAoptions1;
    //@track RAoptions2;
    //@track RAoptions3;
    //@api returnReason; // RETURN REASON/CODE FORM PICKLIST --> STEP 1
    //@api secondaryReason; // SECONDARY READON FOR RETURN/SUB CODE PICKLIST --> STEP 1
    @api requestedAction; // REQUESTED ACTION PICKLIST --> STEP 1
    @api discrepancyType;
    @api comments; // COMMENTS FORM FIELD --> STEP 1
    @api soldToAccount=[]; // ACCOUNT ID SELECTED FROM THE ACCOUNT LOOKUP FIELD --> STEP 1
    @api soldToName;
    @track filesToInsert = []; 
    @track lstAllFiles = []; // ARRAY OF FILES TO BE INSERTED INTO THE DATABASE 
    @api caseProductInsert = []; // ARRAY OF CASE PRODUCTS TO BE INSERTED WITH THE CASE
    @api fileToDelete; // SELECTED FILES TO BE DELETED FROM THE FILEUPLOADVIEWER COMPONENT
    @track orderLines = []; // USED TO RECEIVED THE ORDER LINES UPDATED AND PASSED TO CONFIRMATION SCREEN COMPONENT

    @track stepOneButton = false;
    @track isSpinner = false;
    @track isLoading = false;
    @track caseNumberNew;
    @track cartLabel; 
    @track bShowModal = false;
    @track bShowModal1 = false;
    @track currentRecordId;
    @track currentRecordDtl;
    @track isEditForm = false;
    @track selectedOrder;
    @api storedLines=[];
    @api getorder;
    @track isOrderIdAvailable = false;
    @track flagIndi = false;
    //@track orderId='';
    draftValues = [];
    @track orderItemList;
    @track orderItemNewList;
    @api selectedOrder;
    @api valuetopass;
    @track rowQuantity;
    @track rowAvailForReturn;
    @track rowReturnTotal;
    @track rValue='';
    @track newValueCheck;
    @track queueName=[];
    @track orderPO;
    //@track queueId='00G3j000007ieYT';//Defaulting in case the queue is not present

    @track distributorID;
    @track showDistroField = false;  
    @track agentNumber='DEFAULT';  
    @track disAccount='DEFAULT';
    @track disName=[];
    @track showNextButton = true;
    @track sfdcOrgURL;


    @track selectedAccountName; // SELECTED ACCOUNT NAME FROM SELECTOR OR OVERRIDE FROM LOOKUP
    @track selectedAccountID; // SELECTED ACCOUNT ID FROM SELECTOR OR OVERRIDE FROM LOOKUP
    @track selectedDistributorID;
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
    @track prodFamilies;
    @track fileListSize = 0;
    @track shrinkWrapped;
    @track caseContactEmail;
    @track preLoadedLines = [];
    @track distributorNumber;
    @track orderAgentNumber;
    @track orderAgentAccount = "";
    @track caseAccountId;
    @track caseSoldToId;

    @track columns = [{
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
    //--------END COLUMNS FOR ORDER LINE ITEM SELECTION SCREEN

    @track reviewColumns = [{
        label: 'Invoice #',
        fieldName: 'Invoice__c',
        iconName: 'utility:form',
        type: 'Text',
        cellAttributes: { alignment: 'left' },
        sortable: true 
    },
    {
        label: 'PO#',
        fieldName: 'PO__c',
        type: 'Text',
        cellAttributes: { alignment: 'right' },
        sortable: true 
    },
    /*{
        label: 'Sold To',
        fieldName: 'Distributor_Name__c',
        type: 'Text',
        sortable: true 
    },*/
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
        label: 'Distributor Name',
        fieldName: 'Distributor_Name__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },*/
    {
        label: 'Unit Price',
        fieldName: 'UnitPrice__c',
        type: 'currency',
        iconName: 'utility:money',
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
        label: 'Disputed Qty',
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
        label: 'Req. Action Override',
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

    
    // COLUMNS FOR THE VIEW CART MODAL
            @track cartColumns = [{
                label: 'Invoice #',
                fieldName: 'Invoice__c',
                iconName: 'utility:form',
                type: 'Text',
                cellAttributes: { alignment: 'left' },
                sortable: true 
            },
            {
                label: 'PO#',
                fieldName: 'PO__c',
                type: 'Text',
                cellAttributes: { alignment: 'right' },
                sortable: true 
            },
            /*{
                label: 'Sold To',
                fieldName: 'Distributor_Name__c',
                type: 'Text',
                sortable: true 
            },*/
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
                label: 'Distributor Name',
                fieldName: 'Distributor_Name__c',
                type: 'Text',
                sortable: true,
                cellAttributes: { alignment: 'center' }
            },*/
            {
                label: 'QuickStock',
                fieldName: 'Quick_Stock__c',
                type: 'boolean',
                sortable: true,
                cellAttributes: { alignment: 'center' }
            },
            {
                label: 'Disputed Qty',
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
                label: 'Req. Action Override',
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
                this.contactID = data.fields.ContactId.value;
                this.caseContactEmail = data.fields.Email.value;
                this.accountID = data.fields.AccountId.value;
                this.userType = data.fields.User_Type__c.value;
                console.log('User Type in OVERAGE LWC: '+this.userType);
                this.convertPhone(this.reqPhone);
                /*this.soldToAccount=this.accountID;

            getAgentId({AccountId: this.soldToAccount})
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

            //var inputacc=this.soldToAccount;
            //this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
            this.setAccountfromSelector();

            this.sfdcOrgURL = window.location.href;    

            if(this.sfdcOrgURL.includes('id=')==true){
            this.paramStringNew = this.sfdcOrgURL.split('id=')[1]; 
            this.paramString = this.paramStringNew.split('%2F')[0]; 
            console.log("URL Check2:" + this.paramString);
            console.log("URL Check:" + this.sfdcOrgURL);//TO GET THE DEFAULT ORDER ID end
            }
            if(this.paramString.length>0){
                console.log("Param String Check" +this.paramString);
    
                var inputord=this.paramString;
                //this.template.querySelector("c-order-search-custom").setConfirmValues(inputord);
                }
            }
        }
    //--------------------------------------------------

   // SETS THE ACCOUNT NAME FIELD ON CASE INITIATION FROM ACCOUNT SELECTOR
setAccountfromSelector(){
        
    let storedUserType = localStorage.getItem('User Type');
    this.userType = localStorage.getItem('User Type');
    this.template.querySelector("c-invoice-item-search").setVisibility(storedUserType);

    //AGENT PERSONA
    if(storedUserType == "Agent"){
        this.preSelectedAccount = localStorage.getItem('AgentName') + ' - ' + localStorage.getItem('AgentNumber') + ' - ' + localStorage.getItem('AgentSegment');
        this.selectorAccount = localStorage.getItem('AgentNumber');
        this.selectedAccountID =  localStorage.getItem('AgentID');
        this.caseAccountId = localStorage.getItem('AgentID'); //SETS ACCOUNT ID ON CASE
        this.selectedAccountName = localStorage.getItem('AgentName');
        console.log('Setting Account Lookup LWC - Preselected: '+this.selectorAccount);

        let retrieveData = localStorage.getItem('AgentID');
        //let distributorData = localStorage.getItem('DistributorID');
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

               agentAndSoldToFiltering({soldTo: this.distributorNumber, agentNumber: this.selectorAccount, userType : this.userType})
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
        
    } else {
          //DISTRIBUTOR PERSONA
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
//-------------------------------------------------------------------------------------------------------------

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

        this.sfdcOrgURLNew = window.location.href;
        if(this.sfdcOrgURLNew.includes('id=')==true){
        this.dTypeNew = this.sfdcOrgURLNew.split('id=')[1]; 
        this.dType = this.dTypeNew.split('%2F')[1];
        var order = this.dTypeNew.split('%')[0];
        console.log('ORDER SPLIT: '+ order);
        if(this.dTypeNew.length > 0){
            console.log('Order ID Passed from Detail Page: '+this.dTypeNew);
            console.log('ATTEMPTING TO GET ORDER DETAILS....');
                   this.handleDefaultOrder(order);
        } 

        if(this.dType.length > 0){
            this.handlePickNew();
        } 
    }else if(this.sfdcOrgURLNew.includes('type=')==true){
            let tempURL = this.sfdcOrgURLNew.split('type=')[1]; 
            this.dType = tempURL.split('%2F')[0];
            if(tempURL.includes('%2F')==true){
                this.dType = tempURL.split('%2F')[0];
            }
            else{
                this.dType = tempURL.split('&cartId')[0];
            }
            if(this.dType.length > 0){
                this.handlePickNew();
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

    get acceptedFormats() {
        return ['.pdf','.png','.jpg','.jpeg','.doc','.docx', '.xls','.xlsx','.ppt','.pptx','.odt', '.rtf'];
    }

    get message() {
        return ['Formats: '+'pdf','png','jpg','jpeg','doc','docx', 'xls','xlsx','ppt','pptx','odt', 'rtf' + ' Max File Size: 10 MB'];
    }
    
    get discrepancyoptions(){
        return [
            { label: 'Overage', value: 'Overage' },
            { label: 'Shortage', value: 'Shortage' },                      
            { label: 'Lost/Damaged', value: 'Lost/Damaged' }, 
        ];
    }
    
    
    @track RAoptions1 =[
            { label: 'Return', value: 'Return' },
            { label: 'Keep & Bill', value: 'Keep & Bill' },   
                             
        ];
    

    @track RAoptions2=[
            { label: 'Return', value: 'Return' },
            { label: 'Return for Rework', value: 'Return for Rework' },  
            { label: 'Replacement', value: 'Replacement' },  
        ];
    

    @track RAoptions3 =[
            { label: 'Replacement', value: 'Replacement' },
            { label: 'Credit', value: 'Credit' }, 
        ];

    get SROptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }, 
        ];
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
            console.log('The lines passed to child for Delivery: '+this.disAccount);
            console.log('The lines passed to child for Delivery: '+this.disName);
        
    }

    handleDefaultOrder(order) {
       
        this.selectedOrder = order;
        console.log('ORDER ID FROM ORDER DETAIL PAGE...');
        getOrderDetails({orderId: this.selectedOrder})
        .then(result => {
                console.log('RESULT FROM ORDER DETAILS: '+JSON.stringify(result));
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
            this.template.querySelector('c-invoice-item-search').setSoldToAccount(this.caseSoldTo);
    
        }).catch(error => {
            console.log("The error SENT TO APEX is: " +error);
            this.error = error;
           
        });
        /*var newData = this.orderItemList;
        console.log("The error SENT TO APEX is: " +JSON.stringify(newData));
        for (var i =0; i< newData.length ;i++) {
            this.orderNumber= newData[i].Order.GE_Order_NO__c;
            console.log("Order Number" + this.orderNumber);
        }*/
    
    }

    handleAccountSelected(event){
       
        this.selectorAccount = event.detail.selectedAccount;
        if(this.userType == "Agent"){
            this.selectedAccountID = event.detail.selectedAccountId;
            this.caseAccountId = event.detail.selectedAccountId;
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
        this.caseSoldToId = event.detail.soldto;
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

    
    // HANDLES THE FOUND ORDER FROM THE InvoiceItemSearchLWC CHILD COMPONENT
    orderRetrieved(event){
        this.orderAgent = event.detail.orderAgent;
        console.log('ORDER AGENT ACCOUNT ID: '+this.orderAgent);
                
    }

     
    // DATA PASSED FROM c/lightningWebCompDataTableOrderItem CHILD COMPONENT AND SETS THIS.ORDERLINES ARRAY
    confirmUpdate(event){
        this.orderLines = event.detail.lines;
        let cartCount = this.orderLines.length;
        console.log('Cart Count in OVERAGE: '+cartCount);
        console.log('STATE of Show Next Button: '+this.showNextButton);
        if(this.orderLines.length > 0){
            console.log('CART HAS ITEMS: YES ');
            this.showNextButton = false;
        } else {
            this.showNextButton = true;
        }
        console.log('The lines passed to Parent: '+JSON.stringify(this.orderLines));
    
    }

    updateCartCount(event){
        this.cartCount = event.detail.totalItems;
    }

    accountID(event){
        this.soldToAccount = event.detail.recordId;
        console.log('Selected SOLD-TO ID: '+ this.soldToAccount);
        this.soldToName = event.detail.fieldValue;
        console.log('Selected SOLD TO NAME: '+this.soldToName);
    }

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
                console.log('Returned Files List Size: '+this.files.length);
                this.fileListSize = this.files.length;
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
                console.log('Returned Files List Size: '+this.files.length);
                this.fileListSize = this.files.length;
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
            this.disAccount='DEFAULT_DIS';
            }
            else{
                this.showDistroField = true; 
            }
    }

    handleActionChange(event){
        let action = event.target.value;
        this.template.querySelector("c-invoice-item-search").setAction(action);
    }

    handleSRChange(event){
        this.shrinkWrapped = event.target.value;
        console.log('Shrink Wrapped: '+this.shrinkWrapped);
        
    }

    handlePick(event){
        this.discrepancyType = event.target.value;
        this.caseType = this.discrepancyType;
        console.log('discrepancy type :' +this.discrepancyType)
        if(this.discrepancyType == "Overage"){   
            console.log('RAOptions: ')  ;
            this.RAoptions=this.RAoptions1;  
            console.log('RAOptions After: ' + this.RAoptions)  ;         
        }
        else if(this.discrepancyType == "Lost/Damaged"){   
            console.log('RAOptions: ')  ;
            this.RAoptions=this.RAoptions2;  
            console.log('RAOptions After: ' + this.RAoptions)  ;         
        }
        else{
            this.RAoptions=this.RAoptions3;  
        }
    }

    handlePickNew(event){
        console.log("DType" + this.dType);
        if(this.dType=="Lost"){
            this.discrepancyType = 'Lost/Damaged';
            this.dType='Lost/Damaged';
            this.caseType = this.discrepancyType;
            
        }
        else{
        this.discrepancyType = this.dType;
        this.caseType = this.discrepancyType;
        }
        console.log('discrepancy type :' +this.discrepancyType)
        if(this.discrepancyType == "Overage"){ 
            this.caseType = this.discrepancyType;   
            console.log('RAOptions: ')  ;
            this.RAoptions=this.RAoptions1;  
            console.log('RAOptions After: ' + this.RAoptions)  ;         
        }
        else if(this.discrepancyType == "Lost/Damage"){
            this.caseType = this.discrepancyType;    
            console.log('RAOptions: ')  ;
            this.RAoptions=this.RAoptions2;  
            console.log('RAOptions After: ' + this.RAoptions)  ;         
        }
        else{
            this.caseType = this.discrepancyType; 
            this.RAoptions=this.RAoptions3;  
        }
    }

    async handleChange1(event) {
        //console.log("You selected an order: " + event.detail.value[0]);
        //this.selectedOrder = event.detail.value[0];
        //console.log("Type of" +typeof(selectedOrder));
        this.selectedOrder = event.detail.selectedRecordId;
        console.log('The lines passed to child for Delivery: '+this.selectedOrder);
        console.log('Value for Distributor Name: '+this.disName);
        if(this.disName.length >0){
        await updDisName({orderId: this.selectedOrder, disName: this.disName})
        .then(result => {
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(result)));
        });
        }

        

        await getOrderItemList({orderId: this.selectedOrder})
        .then(result => {
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(result)));
            //this.orderItemList  = result;
            this.tempList = [];
            this.orderPO = result[0].Order.Customer_PO_Number__c;
            if(result){
            for (const orders of result){
                const clone = Object.assign({}, orders);
                console.log('JSON of Orders: '+JSON.stringify(orders));
                if(clone.Available_for_Return__c == 0){
                    console.log('Record Available for Return: '+clone.Available_for_Return__c);
                    clone.actionDisabled = true;
                }

                this.tempList.push(clone);
            }
        }
            this.orderItemList = this.tempList;
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(this.orderItemList)));
            this.isOrderIdAvailable = true;
            this.orderAgent = result[0].Order.Agent_Account__c;
            console.log('ORDER AGENT ID: '+this.orderAgent);
            //this.error = undefined;          
    
        }).catch(error => {
            console.log("The error SENT TO APEX is: " +JSON.stringify(error));
            this.error = error;
            //this.data  = undefined;
        });
        
        //this.template.querySelector('c-confirmation-details').displayValues(this.selectedOrder);
    } 

    handleRowActions(event) {
        this.cartLabel = "Add to Request";
        const actionName = event.detail.action.name;
        const row = event.detail.row;
    
        let rowQuantityValue = event.detail.row.Quantity;
        console.log('The Row Quantity: '+rowQuantityValue);
        let rowAvilForReturnValue = event.detail.row.Available_for_Return__c;
        let rowReturnTotalValue = event.detail.row.Total_Returned__c;
    
        this.rowQuantity = rowQuantityValue;
        this.rowAvailForReturn = rowAvilForReturnValue;
        this.rowReturnTotal = rowReturnTotalValue;
    
    
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


//TO GET THE DEFAULT ORDER ID
async handleChangeNew() {

    
    this.selectedOrder = this.paramString;
    console.log("You selected an order: " +  this.selectedOrder);
    //console.log("Type of" +typeof(selectedOrder));

    await getOrderItemList({orderId: this.selectedOrder})
        .then(result => {
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(result)));
            //this.orderItemList  = result;

            this.tempList = [];
            if(result){
            for (const orders of result){
                const clone = Object.assign({}, orders);
                console.log('JSON of Orders: '+JSON.stringify(orders));
                if(clone.Available_for_Return__c == 0){
                    console.log('Record Available for Return: '+clone.Available_for_Return__c);
                    clone.actionDisabled = true;
                }

                this.tempList.push(clone);
            }
        }
            this.orderItemList = this.tempList;
            console.log(JSON.stringify("The Result from APEX is: "+ JSON.stringify(this.orderItemList)));
            this.isOrderIdAvailable = true;
           
            //this.error = undefined;          
    
        }).catch(error => {
            console.log("The error SENT TO APEX is: " +JSON.stringify(error));
            this.error = error;
            //this.data  = undefined;
        });
}




// closing modal box
closeModal1() {
    this.bShowModal1 = false;
}

editCurrentRecord(currentRow) {
    // open modal box
    this.bShowModal1 = true;
    this.isEditForm = true;
    this.rValue = currentRow.Requested_Action_Override__c;

    // assign record id to the record edit form
    this.currentRecordId = currentRow.Id;
}

// handleing record edit form submit
  handleSubmit(event) {
    let returnQty = this.template.querySelector('.dq').value;
    console.log('Return Qty: '+returnQty);
    let reqOver = this.template.querySelector('.dm').value;
    console.log('Current Row Check:'+ reqOver);

    if(this.rowReturnTotal == 0 && returnQty > this.rowQuantity){

       //this.errorMessage = "ERROR: Dispute Quantity cannot be more than the Order Quantity of:  "+this.rowQuantity;
       
       this.dispatchEvent(
        new ShowToastEvent({
            title: 'ERROR',
            message: 'Dispute Quantity cannot be more than the Order Quantity of:  '+this.rowQuantity,
            variant: 'error'
        })
        );
       event.preventDefault();
       this.cartLabel = "Add to Request";
       

    }else if (this.rowAvailForReturn > 0 && returnQty > this.rowAvailForReturn){
       // this.errorMessage = "ERROR: Dispute Quantity cannot be more than Available for Return of:  "+this.rowAvailForReturn;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'ERROR',
                message: 'Dispute Quantity cannot be more than the Available for Return of:  '+this.rowAvailForReturn,
                variant: 'error'
            })
            );
        
        event.preventDefault();
        this.cartLabel = "Add to Request";
       
    }else{
        this.errorMessage = "";
    this.cartLabel = "Adding to Request...";
    this.isLoading = true;
    // prevending default type sumbit of record edit form
    //event.preventDefault();

    // querying the record edit form and submiting fields to form
    console.log('Inbuilt Form Data Check: ' + JSON.stringify(event.detail.fields));
    const fields = event.detail.fields;
    fields.Requested_Action_Override__c= reqOver;
    fields.Id=this.currentRecordId;
    this.template.querySelector('lightning-record-edit-form').submit(fields);
    console.log('After Form Update Data Check: ' + JSON.stringify(event.detail.fields));

    }
}
 
 

// refreshing the datatable after record edit form success
async handleSuccess() {
    let reqOver = this.template.querySelector('.dm').value;
    let nOrderDtl= {'sobjectType': 'OrderItem'};
    nOrderDtl.Id = this.currentRecordId;
    nOrderDtl.Requested_Action_Override__c=reqOver;
    await updateOrderItemList({data: nOrderDtl})
    .then(result => {
        this.returnID = result;
    });

   await getOrderItemRefList({orderId: this.selectedOrder}) 
           .then(result => {
               this.orderItemList = result;
               console.log(result);
               console.log('After refresh datatable data: ' + JSON.stringify(this.orderItemList));
               //this.ShowToastMsg('Success', 'Order Details Updated')
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

        await orderListData({transId: this.currentRecordId}) 
           .then(result => {
               this.orderItemNewList = result;
               console.log(result);
               console.log('Value passed from Apex for currentrow: ' + JSON.stringify(this.orderItemNewList));
           });
       //var selRows = this.template.querySelector('lightning-datatable');
        var selected = this.orderItemNewList;
        console.log('Edit Row: '+ JSON.stringify(selected));
        //console.log('Values for EDIT: '+this.draftValues);
        //this.storedLines = selected;
        console.log('Stored Lines: '+ JSON.stringify(this.storedLines));
        var newselval = selected.map(row => { return { "order__c": row.OrderId, "SKU__c": row.SKU__c, "PO__c": row.PO__c, "Quantity__c": row.Quantity, "UnitPrice__c": row.UnitPrice, "UnitOfMeasure__c": row.UnitOfMeasure__c,
            "Product_Name__c":row.Product_Name__c,"Quick_Configure__c":row.Quick_Configure__c,"Quick_Stock__c":row.Quick_Stock__c, "SKU__c":row.SKU__c, "Type__c":this.discrepancyType,
            "Shipment_Date__c":row.Shipment_Date__c,"Return_Qty__c": row.Disputed_Qty__c,"Requested_Action_Override__c":row.Requested_Action_Override__c, "Product_SKU__c": row.SKU_Description_Cat_Logic__c,
            "Order_Product_Id__c":row.Id, "Transaction_ID__c": this.transactionID, "Unique_ID__c": this.transactionID+'_'+row.SKU__c, "Distributor_Name__c":row.Distributor_Name__c,"Distributor_Id__c":this.orderLines }});

        
        
        this.valuetopass = selected;
        console.log('value to pass check:' + JSON.stringify(this.valuetopass));
        
        console.log('value to pass check:' + JSON.stringify(newselval));
        await updateReturnItemList({data: newselval})
        .then(result => {
            
            console.log(JSON.stringify("Apex update result: "+ result));
            this.flagIndi= true;
            this.isLoading = false;
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
                if(this.cartCount > 0){
                    console.log("Inside the if" + this.cartCount);
                    this.showNextButton = false;
                } else {
                    console.log("Inside the else" + this.cartCount);
                    this.showNextButton = true;
                }
            this.dispatchEvent(
                new CustomEvent('lineupdate', {
                    detail: {
                        lines : this.storedLines
                    }
                }));
            this.dispatchEvent(
                new CustomEvent('cartcount', {
                    detail: {
                        totalItems : this.cartCount
                    }
                }));
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




    

    //USED TO INSERT CASE RECORD ONCE USER SELECTS SUBMIT IN STEP THREE (REVIEW)
   async handleSave(event){
        this.toggleSubmitLabel = "Submitting...";
        this.isSpinner = true;
        let nCase = { 'sobjectType': 'Case' };
        nCase.RecordTypeId = '0123j000000X8ys';
        nCase.OwnerId = this.caseOwnerId;
        nCase.ContactId = this.contactID;
        nCase.Origin = 'Connect';
        nCase.eLight_Form_Type__c = this.discrepancyType;



        /*if(this.userType == "Agent"){
            nCase.Sold_To_Account__c = this.selectedDistributorID;
            console.log('Setting Case Sold To: '+this.selectedDistributorID);
        }*/
        nCase.Connect_ID__c = this.transactionID;
        nCase.AccountId = this.caseAccountId;
        nCase.Sold_To_Account__c = this.caseSoldToId;
        nCase.eLight_Requestor_Name__c = this.reqName;
        nCase.Requestor_Email__c = this.reqEmail;
        nCase.eLight_Requestor_Phone__c = this.reqPhone;
        nCase.Requested_Action__c = this.requestedAction;
        //nCase.eLight_Reason_for_Return__c = this.returnReason;
        nCase.SuppliedEmail = this.caseContactEmail;
        nCase.GE_NAS_Bill_of_Lading__c = this.discrepancyType;
        nCase.GE_NAS_Purchase_Order__c = this.orderPO;
        nCase.Discrepancy__c = this.discrepancyType;
        nCase.Type = 'Shipping';
        nCase.GE_NAS_Sub_Type__c = this.discrepancyType;
        nCase.eLight_Comments__c = this.comments;
        nCase.Subject = 'Shipping Discrepancy - ' +this.discrepancyType;
        //nCase.eLight_Secondary_Reason__c = this.secondaryReason;

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
                            /*if(linesList[i].Requested_Action_Override__c == "Return" || (resultCheck === false)){
                                
                                // SPLITS THE LINE OR HEADER ACTION TO RETURN, REPLACEMENT INTO AN ARRAY
                                var splitReqAction = [];
                                   if(linesList[i].Requested_Action_Override__c == "Return"){
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
                                            nCaseProduct.GE_NAS_Case_Number__c = this.CaseNumber; 
                                            nCaseProduct.GE_NAS_Type_of_Problem1__c = splitReqAction[k];
                                            nCaseProduct.GE_NAS_Type_of_Problem__c = this.discrepancyType+ ' - '+splitReqAction[k];
                                            nCaseProduct.Unique_ID__c = linesList[i].PO__c+'-'+splitReqAction[k]+'-'+linesList[i].Transaction_ID__c;
                                                console.log('Action Assignment: '+splitReqAction[k]);
                                            nCaseProduct.PO__c = linesList[i].PO__c;                                       
                                            nCaseProduct.GE_NAS_Product_Code__c = linesList[i].Product_SKU__c;
                                                console.log('SKU Assignment: '+ linesList[i].SKU__c);
                                            nCaseProduct.Invoiced_Price__c = linesList[i].UnitPrice__c;
                                                console.log('Unit Price: '+ linesList[i].UnitPrice__c);
                                            nCaseProduct.Discrepancy_Qty__c = linesList[i].Return_Qty__c;
                                                console.log('Disputed QTY Assignment: '+ linesList[i].Return_Qty__c);
                                            nCaseProduct.Order__c = linesList[i].order__c;
                                                console.log('Order Id: '+linesList[i].order__c);
                                            nCaseProduct.Distributor_Name__c = linesList[i].Distributor_Name__c;
                                            nCaseProduct.Distributor_ID__c = linesList[i].Distributor_Id__c ;   
                                            //nCaseProduct.GE_NAS_Quantity_Ordered__c = linesList[i].Quantity__c;
                                                //console.log('Ordered Quantity: '+linesList[i].Quantity__c);                                            

                                        
                                        this.caseProductInsert.push(nCaseProduct);
                                        console.log('Items Pushed to CP List: '+ JSON.stringify(this.caseProductInsert));
                                }
                            } else {*/
                                let nCaseProduct = {'sobjecttype': 'Shipment_Detail__c'};
                                nCaseProduct.GE_NAS_Case_Number__c = this.CaseNumber;

                                    //CHECK REQUESTED OVERRIDE ACTION (LINE LEVEL) IS BLANK. IF SO (ELSE BRANCH), USE HEADER SELECTION. IF NOT (IF BRANCH), USE LINE LEVEL
                                    if(linesList[i].hasOwnProperty('Requested_Action_Override__c')){
                                        nCaseProduct.GE_NAS_Type_of_Problem1__c = linesList[i].Requested_Action_Override__c;
                                        nCaseProduct.GE_NAS_Type_of_Problem__c = this.discrepancyType+ ' - '+linesList[i].Requested_Action_Override__c;
                                        nCaseProduct.Unique_ID__c = linesList[i].Invoice__c+' | '+linesList[i].PO__c+' | '+linesList[i].Requested_Action_Override__c +' | '+linesList[i].Transaction_ID__c;                                        
                                    } else{
                                        nCaseProduct.GE_NAS_Type_of_Problem1__c = this.requestedAction;
                                        nCaseProduct.GE_NAS_Type_of_Problem__c = this.discrepancyType+ ' - '+this.requestedAction;
                                        nCaseProduct.Unique_ID__c = linesList[i].Invoice__c+' | '+linesList[i].PO__c+' | '+this.requestedAction+' | '+linesList[i].Transaction_ID__c;     
                                        //nCaseProduct.GE_NAS_Bill_of_Lading__c = linesList[i].Requested_Action_Override__c;                                        
                                    }
                                        console.log('Action Assignment: '+ linesList[i].Requested_Action_Override__c);
                                    nCaseProduct.PO__c = linesList[i].PO__c;
                                    nCaseProduct.Material_Number__c = linesList[i].Material__c;                                    
                                    nCaseProduct.GE_NAS_Product_Code__c = linesList[i].Product_SKU__c;
                                        console.log('SKU Assignment: '+ linesList[i].Product_SKU__c);
                                    nCaseProduct.Invoiced_Price__c = linesList[i].UnitPrice__c;
                                        console.log('Unit Price: '+ linesList[i].UnitPrice__c);
                                    nCaseProduct.Discrepancy_Qty__c = linesList[i].Return_Qty__c;
                                        console.log('Disputed QTY Assignment: '+ linesList[i].Return_Qty__c);
                                    //nCaseProduct.GE_NAS_Quantity_Ordered__c = linesList[i].Quantity__c;
                                       // console.log('Ordered Quantity: '+linesList[i].Quantity__c);
                                    nCaseProduct.Order__c = linesList[i].order__c;
                                       console.log('Order Id: '+linesList[i].order__c);
                                    nCaseProduct.Distributor_Name__c = linesList[i].Distributor_Name__c;
                                    nCaseProduct.Distributor_ID__c = this.selectedDistributorID;
                                    nCaseProduct.GE_NAS_Unit_of_Measure__c = linesList[i].UnitOfMeasure__c;
                                    nCaseProduct.Invoice_Line__c = linesList[i].Invoice_Line__c;
                                    nCaseProduct.SFDC_Invoice__c = linesList[i].SFDC_Invoice__c;
                                    nCaseProduct.QuickStock__c = linesList[i].Quick_Stock__c;
                                    nCaseProduct.Is_the_product_shrink_wrapped__c = linesList[i].Is_the_product_shrink_wrapped__c;     
                                    this.caseProductInsert.push(nCaseProduct);
                            
                           
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

             //TO GET THE DEFAULT ORDER ID
             this.sfdcOrgURL = window.location.href;    

            if(this.sfdcOrgURL.includes('id=')==true){
            this.paramStringNew = this.sfdcOrgURL.split('id=')[1]; 
            this.paramString = this.paramStringNew.split('%2F')[0]; 
            console.log("URL Check2:" + this.paramString);
            console.log("URL Check:" + this.sfdcOrgURL);//TO GET THE DEFAULT ORDER ID end

                if(this.paramString.length>0){
                    console.log("Inside the Param call");
                    this.orderFlag='Y';
                    this.handleChangeNew();    
                }
            }

        
        
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
        await getAccName({id_dtl: this.soldToAccount})
        .then(result => {
        this.accName = result;
        console.log(JSON.stringify("Account Name Selected "+ JSON.stringify(this.accName)))
        });
        console.log('Sold To Account: '+this.soldToAccount);
        this.reqName = this.template.querySelector(".rn").value;
        console.log('Requestor Name: '+this.reqName);
        this.reqEmail = this.template.querySelector(".em").value;
        console.log('Requestor Email: '+this.reqEmail);
        this.reqPhone = this.template.querySelector(".rp").value;
        console.log('Requested Phone: '+this.reqPhone);
        /*this.returnReason = this.template.querySelector(".rr").value;
        console.log('Return Reason: '+this.returnReason);
        this.secondaryReason = this.template.querySelector(".sr").value;
        console.log('Secondary Return Reason: '+this.secondaryReson);*/
        this.requestedAction = this.template.querySelector(".ra").value;
        console.log('Requested Action: '+this.requestedAction);
        this.discrepancyType = this.template.querySelector(".an").value;
        console.log('Discrepancy Type: '+this.discrepancyType);
        this.comments = this.template.querySelector(".cm").value;
        console.log('Comments: '+this.comments);

        this.getCaseOwner();

       /* if(this.userType == "Agent"){
            this.setAccountID = this.soldToAccount;
        }else {
            this.setAccountID = this.orderAgent;
        }
            await getCSOwnerId({accountId : this.setAccountID})
            .then(result=>{
                if(result){
                    this.caseOwnerId = result;
                    console.log('QUEUE FOUND...SETTING CASE OWNER ID: ' + this.caseOwnerId);
                } 
            })
    
            .catch(error => {
                console.log(error);
                this.error = error;
                console.log('Apex failed...');
            }); */
  
      /*var qDtl=this.queueName;
      for (var i =0; i< qDtl.length ;i++) {
          this.queueId=qDtl[i].Id;
      console.log('Queue Id:' +this.queueId );    
      }*/
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

    goToStepFour(){
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
        } else if(this.caseType === 'Lost/Damaged' && this.fileListSize == 0){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ERROR',
                    message: 'You MUST attach evidence of damage',
                    variant: 'error'
                })
            );

        }else {

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
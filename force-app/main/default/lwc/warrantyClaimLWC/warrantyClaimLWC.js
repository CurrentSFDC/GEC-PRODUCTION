import { LightningElement, api, track, wire } from 'lwc';
import createCaseRecord from '@salesforce/apex/connectCreateCase.connectCreateReturnCase';
import updateFiles from '@salesforce/apex/connectCreateCase.updateFiles';
import getRelatedFiles from '@salesforce/apex/FileUploadViewController.getRelatedFiles';
import createCaseProduct from '@salesforce/apex/connectCreateCase.createCaseProduct';
import getOrderDetails from '@salesforce/apex/OrderProductController.getOrderDetails';
import getCaseNumber from '@salesforce/apex/connectCreateCase.getCaseNumber';
import getAccName from '@salesforce/apex/connectCreateCase.getAccountName';
//import getProdFamilies from '@salesforce/apex/LwcLookupControllerCust.getProductFamilies';
import getProdFamilies from '@salesforce/apex/StockBalancingReturnLwcController.getProductFamilies';
import getWarrantyQueueId from '@salesforce/apex/connectCreateCase.getWarrantyQueueId';
import updateInvoiceLines from '@salesforce/apex/connectCreateCase.updateInvLines';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import getAgentId from '@salesforce/apex/connectCreateCase.getAgentId';
import findInvLineRecords from "@salesforce/apex/LwcLookupControllerCust.preLoadLineRecords";
import preLoadLineRecords from "@salesforce/apex/LwcLookupControllerCust.preLoadLineRecords";
import agentAndSoldToFiltering from "@salesforce/apex/LwcLookupControllerCust.agentAndSoldToFiltering";
import orderInitiatedFiltering from "@salesforce/apex/LwcLookupControllerCust.orderInitiatedFiltering";


const actions = [
    { label: 'Delete', name: 'delete' },
    { label: 'Edit', name: 'edit' },
];

// USED FOR GETTING THE USER DATA - WITHOUT APEX CALL
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import PHONE_FIELD from '@salesforce/schema/User.Phone';
import CONTACT_FIELD from '@salesforce/schema/User.ContactId';
import ACCOUNT_FIELD from '@salesforce/schema/User.AccountId';

export default class WarrantyClaimLWC extends LightningElement {
    @api transactionID;
    @api files;
    @api accountID;
    @api accountName=[];
    @api CaseNumber;
    @track currentStep;
    @track warrantyCode;
    @track warrantySubCode;
    @track reqName;
    @track reqEmail;
    @track reqPhone;
    @track warSubOptions;
    @track action;
    @track caseOwnerId;
    @track orderAgent;

    @track warrantyReason;
    @track warrantySubReason;
    @track requestedAction;
    @track comments;
    @api soldToAccount=[];
    @api soldToName;

    @track endUserAddressStreet = "";
    @track endUserAddressCity = "";
    @track endUserAddressState = "";
    @track endUserAddressPostalCode = "";
    @track endUserAddressCountry = "";
    @track endUserName;
    @track endUserEmail;
    @track endUserPhone;
    @track siteName;

    @track toggleSubmitLabel = "Submit";
    @track isSpinner = false;
    @track showNextButton = true;
    @track filesToInsert = [];
    @track lstAllFiles = [];
    @api caseProductInsert = [];
    @api fileToDelete;
    @track caseNumberNew;

    @api orderLines = [];
    @track caseSoldTo;

    @track showDistroField = false; 
    @track agentNumber='DEFAULT';  
    @track disAccount='DEFAULT';
    @track distAccName;
    @track distLines;
    @track disName=[];

    
    @track notDistributor = false;
    @track selectedDistributorID;
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
    @track distributorNumber;
    @track sfdcOrgURL;
    //@track orderID;
    @track caseType = 'Warranty';
    @track prodFamilies = [];
    @track isReturnReplace = false;
    @track userType;
    @track caseContactEmail;
    @track preLoadedLines = [];
    @track orderAgentNumber;
    @track orderAgentAccount = "";
    @track caseAccountId;
    @track caseSoldToId;

     // COLUMNS FOR ORDER LINE ITEM SELECTION SCREEN
     @track warrantyColumns = [{
        label: 'Invoice #',
        fieldName: 'GE_LGT_EM_SAP_Invoice_Number__c',
        iconName: 'utility:form',
        type: 'Text',
        cellAttributes: { alignment: 'left' },
        cellAttributes:{
            alignment: 'left',
            iconName:{fieldName:'rowIcon'}, 
            iconPosition:'left',
            iconTitle: {fieldName: 'iconTitle'},
            class:{
            fieldName: 'textColor' }
        }
        //sortable: true
    },
    {
        label: 'Order #',
        //fieldName: 'GE_LGT_EM_Order_Number__c',
        fieldName: 'newNumber',
        type: 'Text',
        //sortable: true,
        cellAttributes: { alignment: 'left',
        class:{
            fieldName: 'textColor'} },
         
    },
    {
        label: 'PO #',
        fieldName: 'GE_LGT_EM_Customer_PO_Number__c',
        type: 'Text',
        //sortable: true,
        cellAttributes: { alignment: 'right',
        class:{
            fieldName: 'textColor'} }
    },
    {
        label: 'Catalog #',
        fieldName: 'GE_LGT_EM_Material_Description__c',
        iconName: 'utility:products',
        type: 'Text',
        cellAttributes: { alignment: 'right',
        class:{
            fieldName: 'textColor'} }
        //sortable: true
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
    /*{
        label: 'Distributor Name',
        fieldName: 'Distributor_Name__c',
        type: 'Text',
        sortable: true,
        cellAttributes: { alignment: 'center' }
    },*/
    {
        label: 'Qty',
        fieldName: 'GE_LGT_EM_Invoiced_Quantity__c',
        type: 'Text',
        iconName: 'utility:number_input',
        //sortable: true,
        hideDefaultActions: true,
        cellAttributes: { alignment: 'left',
        class:{
            fieldName: 'textColor'} }
    },
    {
        label: 'UOM',
        fieldName: 'GE_LGT_EM_Sales_Unit__c',
        iconName: 'utility:slider',
        type: 'text',
        //sortable: true,
        cellAttributes: { alignment: 'right',
        class:{
            fieldName: 'textColor'}
        }
    },
    {
        label: 'Date Installed',
        fieldName: 'Date_Installed__c',
        iconName: 'utility:date_input',
        type: 'date-local',
        sortable: true,
        cellAttributes: { alignment: 'left' },
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    },
    {
        label: 'Installed',
        fieldName: 'Installed_Qty__c',
        iconName: 'utility:number_input',
        type: 'number',
        sortable: true,
        cellAttributes: { alignment: 'left',
        class:{
            fieldName: 'textColor'} }
    },
    {
        label: 'Failed',
        fieldName: 'No_Of_Products_Failed__c',
        iconName: 'utility:number_input',
        type: 'number',
        sortable: true,
        cellAttributes: { alignment: 'left',
        class:{
            fieldName: 'textColor'} }
    },
    
    {
        label: 'Action Override',
        fieldName: 'Requested_Action_Override__c',
        iconName: 'utility:button_choice',
        type: 'Text',
        cellAttributes: { alignment: 'right',
        class:{
            fieldName: 'textColor'} },
        sortable: true,
        wrapText: true
    },
    {
        type: 'button-icon',
        initialWidth: 34,
        typeAttributes:{
            label: 'Edit',
            name: 'edit',
            rowActions: actions,
            //title: 'edit',
            title: {fieldName: 'iconTitle'},
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

 // COLUMNS FOR THE VIEW CART MODAL --------
 @track cartColumns = [{
    label: 'Invoice #',
    fieldName: 'Invoice__c',
    iconName: 'utility:form',
    type: 'Text',
    cellAttributes: { alignment: 'left' }
    //sortable: true
},
{
    label: 'Order #',
    fieldName: 'Current_Order__c',
    type: 'Text',
    //sortable: true,
    cellAttributes: { alignment: 'left' }
},
{
    label: 'PO #',
    fieldName: 'PO__c',
    type: 'Text',
    //sortable: true,
    cellAttributes: { alignment: 'right' }
},
{
    label: 'No CAT#',
    fieldName: 'NoCAT__c',
    iconName: 'utility:products',
    type: 'Text',
    cellAttributes: { alignment: 'right' }
    //sortable: true
},
{
    label: 'Catalog #',
    fieldName: 'Product_SKU__c',
    iconName: 'utility:products',
    type: 'Text',
    cellAttributes: { alignment: 'right' }
    //sortable: true
},
{
    label: 'SKU #',
    fieldName: 'SKU__c',
    iconName: 'utility:products',
    type: 'Text',
    cellAttributes: { alignment: 'left' }
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
    label: 'Qty',
    fieldName: 'Quantity__c',
    type: 'Text',
    iconName: 'utility:number_input',
    //sortable: true,
    hideDefaultActions: true,
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
    label: 'Date Installed',
    fieldName: 'Date_Installed__c',
    iconName: 'utility:date_input',
    type: 'date-local',
    sortable: true,
    cellAttributes: { alignment: 'left' },
    typeAttributes: {
        day: "numeric",
        month: "numeric",
        year: "numeric"
    }
},
{
    label: 'Installed',
    fieldName: 'Installed_Qty__c',
    iconName: 'utility:number_input',
    type: 'number',
    sortable: true,
    cellAttributes: { alignment: 'left' }
},
{
    label: 'Failed',
    fieldName: 'No_Of_Products_Failed__c',
    iconName: 'utility:number_input',
    type: 'number',
    sortable: true,
    cellAttributes: { alignment: 'left' }
},

{
    label: 'Action Override',
    fieldName: 'Requested_Action_Override__c',
    iconName: 'utility:button_choice',
    type: 'Text',
    cellAttributes: { alignment: 'right' },
    sortable: true,
    wrapText: true
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
//--------END COLUMNS FOR THE VIEW CART MODAL -------

 // COLUMNS FOR THE REVIEW SCREEN --------
 @track reviewColumns = [{
    label: 'Invoice #',
    fieldName: 'Invoice__c',
    iconName: 'utility:form',
    type: 'Text',
    cellAttributes: { alignment: 'left' }
    //sortable: true
},
{
    label: 'Order #',
    fieldName: 'Current_Order__c',
    type: 'Text',
    //sortable: true,
    cellAttributes: { alignment: 'left' }
},
{
    label: 'PO #',
    fieldName: 'PO__c',
    type: 'Text',
    //sortable: true,
    cellAttributes: { alignment: 'right' } 

},
{
    label: 'No CAT#',
    fieldName: 'NoCAT__c',
    iconName: 'utility:products',
    type: 'Text',
    cellAttributes: { alignment: 'right' }
    //sortable: true
},
{
    label: 'Catalog #',
    fieldName: 'Product_SKU__c',
    iconName: 'utility:products',
    type: 'Text',
    cellAttributes: { alignment: 'right' }
    //sortable: true
},
{
    label: 'SKU #',
    fieldName: 'SKU__c',
    iconName: 'utility:products',
    type: 'Text',
    cellAttributes: { alignment: 'left' }
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
    label: 'Qty',
    fieldName: 'Quantity__c',
    type: 'Text',
    iconName: 'utility:number_input',
    //sortable: true,
    hideDefaultActions: true,
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
    label: 'Date Installed',
    fieldName: 'Date_Installed__c',
    iconName: 'utility:date_input',
    type: 'date-local',
    sortable: true,
    cellAttributes: { alignment: 'left' },
    typeAttributes: {
        day: "numeric",
        month: "numeric",
        year: "numeric"
    }
},
{
    label: 'Installed',
    fieldName: 'Installed_Qty__c',
    iconName: 'utility:number_input',
    type: 'number',
    sortable: true,
    cellAttributes: { alignment: 'left' }
},
{
    label: 'Failed',
    fieldName: 'No_Of_Products_Failed__c',
    iconName: 'utility:number_input',
    type: 'number',
    sortable: true,
    cellAttributes: { alignment: 'left' }
},

{
    label: 'Action Override',
    fieldName: 'Requested_Action_Override__c',
    iconName: 'utility:button_choice',
    type: 'Text',
    cellAttributes: { alignment: 'right' },
    sortable: true,
    wrapText: true
},
]; 
//--------END COLUMNS FOR THE REVIEW SCREEN -------

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
                this.convertPhone(this.reqPhone);
                //this.soldToAccount=this.accountID;

           /* getAgentId({AccountId: this.soldToAccount})
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
            });

            getAccName({id_dtl: this.soldToAccount})
            .then(result => {
            this.accountName = result;
            console.log(JSON.stringify("The Result for Case Number: "+ JSON.stringify(this.accountName)))
            });

            var inputacc=this.soldToAccount;
            this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc); */ 
            this.setAccountfromSelector();
            
        }
    }
//--------------------------------------------------

// SETTING ACCOUNT NAME FIELD FROM THE ACCOUNT SELECTOR WHEN CASE IS INITIATIED
async setAccountfromSelector(){
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
        console.log('Setting Account Lookup LWC - Preselected ID: '+this.selectedAccountID);
        
        this.showDistroField = true; 
        let retrieveData = localStorage.getItem('AgentID');
        let agentNum = localStorage.getItem('AgentNumber');
        console.log('Passing AGENT ACCOUNT to Get Prod Families: '+this.selectedAccountID);
               


        let distributorData = localStorage.getItem('DistributorID');
        if (distributorData != null){
            this.preSelectedSoldTo = localStorage.getItem('DistributorName') + ' - ' + localStorage.getItem('DistributorAccount') + ' - ' + localStorage.getItem('DistributorSegment');
            this.distributorNumber = localStorage.getItem('DistributorAccount');
            this.selectedDistributorID = localStorage.getItem('DistributorID');
            this.caseSoldToId = localStorage.getItem('DistributorID'); //SETS CASE SOLD TO ID FIELD
            console.log('PRE SELECTED SOLD TO: '+this.preSelectedSoldTo);
            this.template.querySelector("c-invoice-item-search").preslectedSoldTo();
            this.template.querySelector("c-invoice-item-search").setManualButtons();
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
        //let disAccountName = sessionStorage.getItem('DistributorName');
        //let disAccountSegment = sessionStorage.getItem('DistributorSegment');
        //let disID = sessionStorage.getItem('DistributorID');
        if(retrieveData != null){
            console.log('Setting Account From Selector: '+JSON.stringify(retrieveData));
            this.soldToAccount = retrieveData;
            var inputacc = retrieveData;
            console.log('Sending Account ID to Account Search: '+inputacc);
            //this.caseSoldTo = localStorage.getItem('DistributorID');
           // this.template.querySelector("c-account-search-custom").setConfirmValues(inputacc);
            //this.template.querySelector("c-distributor-search-custom").setConfirmValues(agentNum);
            console.log('Setting Account Number from Local Storage: '+inputacc);
        }
         
        
    } 
    
    //DISTRIBUTOR PERSONA
    else {
        //this.getProdFamilies();
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
        console.log('Setting Account Lookup LWC - Preselected ID: '+this.selectedAccountID);
        this.distributorNumber = localStorage.getItem('DistributorAccount');
        let retrieveData = localStorage.getItem('DistributorID');
        this.template.querySelector('c-invoice-item-search').setDistributorButtons();

        await getProdFamilies({soldToAccId: this.selectedDistributorID, agentAccId: null})
        .then(result => {
        this.prodFamilies = result;
        console.log('getProdFamilies:' + result);
        })
        .catch(error => {
            console.log(error);
            this.error = error;
        });
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

    @track columns = [
        { label: 'Name', fieldName: 'Title', type: 'text' },
        { label: 'Type', fieldName: 'FileExtension', type: 'text' },
    ];

    get acceptedFormats() {
        return ['.pdf','.png','.jpg','.jpeg','.doc','.docx', '.xls','.xlsx','.ppt','.pptx','.odt', '.rtf'];
    }

    get message() {
        return ['Formats: '+'pdf','png','jpg','jpeg','doc','docx', 'xls','xlsx','ppt','pptx','odt', 'rtf' + ' Max File Size: 10 MB'];
    }

    countryOptions = [
        { label: 'United States', value: 'US' },
        { label: 'Canada', value: 'CA' },
    ];

    get countryOptions(){
        return this.countryOptions;
    }
    

   // FOLLOWING OPTIONS METHODS ARE USED FOR PCIKLIST VALUES IN SCREEN/STEP 1
get RAoptions() {
    return [
        { label: 'Return and Credit', value: 'Return and Credit' },
        { label: 'Return and Replace', value: 'Return and Replace' },
        { label: 'Return for Analysis', value: 'Return for Analysis' },
        
    ];
}

  get warOptions() {
        return [
            { label: 'Control', value: 'Control' },
            { label: 'Electrical', value: 'Electrical' },
            { label: 'Light Output', value: 'Light Output' },
            { label: 'Mechanical', value: 'Mechanical' },
            { label: 'Packaging', value: 'Packaging' },
            { label: 'Safety', value: 'Safety' },
        ];
    }

    @track warSubOptionsControl =
        [
            { label: 'Dimming Issue', value: 'Dimming Issue' },
            { label: 'Network Connection Error', value: 'Network Connection Error'},
            { label: 'Sensor Failure', value: 'Sensor Failure' },
        ];
    

    @track warSubOptionsElectrical =
        [
            { label: 'Connector Failure', value: 'Connector Failure' },
            { label: 'Failed Driver', value: 'Failed Driver' },
            { label: 'Failed on Initial Energize', value: 'Failed on Initial Energize' },
            { label: 'Inoperative', value: 'Inoperative' },
            { label: 'Intermittent Operation', value: 'Intermittent Operation' },
            { label: 'LED Failure', value: 'LED Failure' },
            { label: 'Pinched Wire', value: 'Pinched Wire' },
            { label: 'Surge Protector Failed', value: 'Surge Protector Failed' },
            { label: 'Transformer Failure', value: 'Transformer Failure' },
            { label: 'Wiring Error', value: 'Wiring Error' },
        ];
    

    @track warSubOptionsLightOutput =
        [
            { label: 'Color Objection', value: 'Color Objection' },
            { label: 'Color Shift', value: 'Color Shift'},
            { label: 'Flicker', value: 'Flicker' },
            { label: 'Low Light Levels', value: 'Low Light Levels' },
        ];
    

    @track warSubOptionsMechanical =
        [
            { label: 'Assembly Defect', value: 'Color Objection' },
            { label: 'Component - Missing', value: 'Component - Missing'},
            { label: 'Component - Loose', value: 'Component - Loose' },
            { label: 'Finish/Paint Issue', value: 'Finish/Paint Issue' },
            { label: 'Lens/Diffuser - Loose', value: 'Lens/Diffuser - Loose' },
            { label: 'Other Cosmetic Issue', value: 'Other Cosmetic Issue' },
            { label: 'Water Entry', value: 'Water Entry' },
        ];

    @track warSubOptionsPackaging =
        [
            { label: 'Label Incorrect', value: 'Label Incorrect' },
            { label: 'Packaging Quality', value: 'Packaging Quality'},
            { label: 'Wrong Part in Carton', value: 'Wrong Part in Carton' },
        ];

    @track warSubOptionsSafety =
        [
            { label: 'Burnt/Overheated', value: 'Burnt/Overheated' },
            { label: 'Fallen Component/Fixture', value: 'Fallen Component/Fixture'},
            { label: 'Shock', value: 'Wrong Part in Carton' },
        ];
    
        connectedCallback(){
            window.addEventListener("beforeunload", this.beforeUnloadHandler.bind(this));
            this.setTimer();
            var today = new Date();
            var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
            var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
            const id = 'id' + performance.now()+'-'+date+'-'+time;
            this.transactionID = id;
            console.log('Generated ID: '+ id);

            console.log('Setting the Transcation ID: '+this.transactionID);

            //Code change for order id default
            this.sfdcOrgURL = window.location.href;
            if(this.sfdcOrgURL.includes('id=')==true){
                this.paramString = this.sfdcOrgURL.split('id=')[1];
                if(this.paramString.length > 0){
                    this.orderID = this.paramString;
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
 
    
    handlePick(event){
        this.warrantyReason = event.target.value;
        console.log('Warranty Reason :' +this.warrantyReason)
        if(this.warrantyReason == "Control"){   
            console.log('warSubOptions: ')  ;
            this.warSubOptions=this.warSubOptionsControl;  
            console.log('warSubOptions After: ' + this.warSubOptions)  ;         
        }
        else if(this.warrantyReason == "Electrical"){   
            console.log('warSubOptions: ')  ;
            this.warSubOptions=this.warSubOptionsElectrical;  
            console.log('warSubOptions After: ' + this.warSubOptions)  ;         
        }
        else if(this.warrantyReason == "Light Output"){   
            console.log('warSubOptions: ')  ;
            this.warSubOptions=this.warSubOptionsLightOutput;  
            console.log('warSubOptions After: ' + this.warSubOptions)  ;         
        }
        else if(this.warrantyReason == "Mechanical"){   
            console.log('warSubOptions: ')  ;
            this.warSubOptions=this.warSubOptionsMechanical;  
            console.log('warSubOptions After: ' + this.warSubOptions)  ;         
        }
        else if(this.warrantyReason == "Packaging"){   
            console.log('warSubOptions: ')  ;
            this.warSubOptions=this.warSubOptionsPackaging;  
            console.log('warSubOptions After: ' + this.warSubOptions)  ;         
        }
        else{
            this.warSubOptions=this.warSubOptionsSafety;  
        }
    }

    handleActionChange(event){
        let value = event.target.value;
        this.action = value;
        if (value == "Return and Replace"){
            this.isReturnReplace = true;
        } else {
            this.isReturnReplace = false;
        }
    }

// HANDLES THE FOUND ORDER FROM THE InvoiceItemSearchLWC CHILD COMPONENT
orderRetrieved(event){
    this.orderAgent = event.detail.orderAgent;
    console.log('ORDER AGENT ACCOUNT ID: '+this.orderAgent);
            
}

// HANDLE ACCOUNT SELECTED FROM ACCOUNT LOOKUP LWC
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
//-----------------------------------------------------

// HANDLE SOLD TO ACCOUNT SELECTED IN THE SOLD TO LOOKUP LWC
async handleSoldToSelected(event){
    this.selectedSoldToAccountName = event.detail.soldToName;
        this.selectedDistributorID = event.detail.soldto;
        this.caseSoldToId = event.detail.soldto;
        this.searchDisabled = false;
        console.log('SOLD TO Account Selected from AccountLookupLWC: '+this.selectedSoldToAccountName);
        console.log('SOLD TO ID Selected from AccountLookupLWC: '+this.selectedDistributorID);
        
        await getProdFamilies({soldToAccId: this.selectedDistributorID, agentAccId: null})
        .then(result => {
        this.prodFamilies = result;
        console.log('getProdFamilies:' + result);
        })
        .catch(error => {
            console.log(error);
            this.error = error;
    });
    
 
}
//--------------------------------------------------------

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


// HANDLES CLEAR FOR SOLD TO ACCOUNT SELECTION (LWC)
/*changeAccount(){
    
    this.preSelectedAccount = null;
    this.selectedDistributorID = null;
    this.searchKey = '';
   
}*/
//------------------------------------------------------

// HANDLES THE ORDER ID FROM WHEN CASE EXECUTED FROM ORDER DETAIL PAGE
handleDefaultOrder(event) {
       
    this.selectedOrder = this.paramString;
   
    getOrderDetails({orderId: this.selectedOrder})
    .then(result => {
        
            this.orderNumber= result[0].GE_Order_NO__c;
            this.orderID = result[0].Id;
            this.orderPO = result[0].Customer_PO_Number__c;
            this.caseSoldTo = result[0].Sold_To__c;
            this.selectedDistributorID = this.caseSoldTo;
                console.log('SelectedDistributorID From Order = '+this.selectedDistributorID);
            this.distributorNumber = result[0].Sold_To__r.GE_LGT_EM_SAP_Customer_Number__c;
            this.selectedSoldToAccountName = result[0].Sold_To__r.Name;
            this.preSelectedOrder = result[0].GE_Order_NO__c + ' - ' + result[0].Customer_PO_Number__c;
       
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
        this.template.querySelector('c-invoice-item-search').setOrderSoldTo(this.caseSoldTo);

        getProdFamilies({soldToAccId: this.caseSoldTo, agentAccId: null})
        .then(result => {
        this.prodFamilies = result;
        console.log('getProdFamilies:' + result);
        })
        .catch(error => {
            console.log(error);
            this.error = error;
    });
               

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

appendLines(event){
        
    this.invLinesToUpdate = event.detail.lineId;
    console.log('Invoice Lines to Modiify: '+JSON.stringify(this.invLinesToUpdate));
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

    handleAddressChange(event){
        let tempStreet = event.target.street;
        console.log('Address as-is entered: '+tempStreet);



        this.endUserAddressStreet = tempStreet.replace(/\n/g, ' - ');
        console.log('Address converted entered: '+this.endUserAddressStreet);

        this.endUserAddressCity = event.target.city;
        console.log('Address City: '+this.endUserAddressCity);
        this.endUserAddressState = event.target.province;
        console.log('Address State: '+this.endUserAddressState);
        this.endUserAddressPostalCode = event.target.postalCode;
        console.log('Address Postal: '+this.endUserAddressPostalCode);
        this.endUserAddressCountry = event.target.country;
        console.log('Address Country: '+this.endUserAddressCountry);
        let fullAddress = this.template.querySelector('.eua').value;
        console.log('FULL ADDRESS: '+fullAddress);

        
        
    }

    async handleChange(event){
        this.soldToAccount = event.target.selectedRecordId;
        this.soldToName = event.target.name.value;
        console.log('Sold To Account ID: '+ this.soldToAccount);
        console.log('Sold To Account Name: '+ this.soldToName);
        await getAccName({id_dtl: this.Account})
            .then(result => {
            this.accountName = result;
            console.log(JSON.stringify("The Result for Case Number: "+ JSON.stringify(this.accountName)))
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

    //USED TO INSERT CASE RECORD ONCE USER SELECTS SUBMIT IN STEP THREE (REVIEW)
    async handleSave(event){
        this.toggleSubmitLabel = "Submitting...";
        this.isSpinner = true;
 
        let nCase = { 'sobjectType': 'Case' };
        nCase.RecordTypeId = '0123j000000X8ys';
        nCase.OwnerId = this.caseOwnerId;
        nCase.Origin = 'Connect';
        nCase.eLight_Form_Type__c = 'Warranty';
        /*if(this.selectedDistributorID != null || this.selectedDistributorID != ''){
            nCase.Sold_To_Account__c = this.selectedDistributorID;
            console.log('SETTING CASE SOLD TO FIELD: '+this.selectedDistributorID);
        } 
        nCase.AccountId = this.soldToAccount;*/
        nCase.AccountId = this.caseAccountId;
        nCase.Sold_To_Account__c = this.caseSoldToId;
        nCase.ContactId = this.contactID;
        nCase.Connect_ID__c = this.transactionID;
        nCase.eLight_Requestor_Name__c = this.reqName;
        nCase.Requestor_Email__c = this.reqEmail;
        nCase.eLight_Requestor_Phone__c = this.reqPhone;
        nCase.Requested_Action__c = this.requestedAction;
        nCase.Warranty_Code__c = this.warrantyCode;
        nCase.Warranty_Sub_Code__c = this.warrantySubCode;
        nCase.SuppliedEmail = this.caseContactEmail;
        nCase.Site_Contact_Email__c = this.endUserEmail;
        nCase.Site_Contact_Name__c = this.endUserName;
        nCase.Site_Contact_Phone__c = this.endUserPhone;
        nCase.eLight_Comments__c = this.comments;
        nCase.Type = 'Warranty';
        nCase.GE_NAS_Sub_Type__c = 'Warranty Claim';
        nCase.Subject = 'Warranty Claim';
        nCase.Site_Name__c = this.siteName;
        
        let shipToAddress = this.endUserAddressStreet !== "" ? this.endUserAddressStreet + "\n" : "";
        shipToAddress += this.endUserAddressCity !== "" ? this.endUserAddressCity + ', ' : "";
        shipToAddress += this.endUserAddressState !== "" ? this.endUserAddressState + ' ' : "";
        shipToAddress += this.endUserAddressPostalCode !== "" ? this.endUserAddressPostalCode + "\n" : "";
        shipToAddress += this.endUserAddressCountry;

        nCase.eLight_Address_2__c = shipToAddress;
        // nCase.eLight_Address_2__c = this.endUserAddressStreet + "\n" + this.endUserAddressCity + ', ' + this.endUserAddressState + ' ' + this.endUserAddressPostalCode + "\n" + this.endUserAddressCountry;
        //nCase.Description = concat('Form Type: Waranty Claim', 'Requested Action: '+this.requestedAction);

           // STEP 1 - CREATE CASE
         await  createCaseRecord({newCase: nCase})
         .then(result => {
             this.CaseNumber = result;
             console.log('Case Number Created: '+this.CaseNumber);
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
                        console.log('Array Check: '+resultCheck);

                        if(resultCheck === true){
                        console.log('INSIDE LINE LEVEL...');
                            var splitReqAction = [];
                                if(linesList[i].Requested_Action_Override__c == "Return and Replace" || linesList[i].Requested_Action_Override__c == "Return and Credit"){
                                    splitReqAction = linesList[i].Requested_Action_Override__c.split(' and ');
                                    console.log('LINE SPLIT - List Size: '+splitReqAction.length);

                                    // FOR EACH VARIABLE IN THE SPLIT ARRAY CREATE A CASE PRODUCT FOR EACH AND PUSH TO caseProductInsert List    
                                        for(var k = 0; k < splitReqAction.length ; k++){
                                            console.log('K: '+k);
                                                console.log('Current Iteration:'+splitReqAction[k]);
                                                let nCaseProduct = {'sobjecttype': 'Shipment_Detail__c'};
                                          
                                                //nCaseProduct.Material_Number__c = linesList[i].SKU__c;
                                                //console.log('Material Assignment: '+linesList[i].SKU__c);
                                                    nCaseProduct.GE_NAS_Case_Number__c = this.CaseNumber; 
                                                    nCaseProduct.GE_NAS_Type_of_Problem1__c = splitReqAction[k];
                                                    nCaseProduct.GE_NAS_Type_of_Problem__c = 'Warranty - '+splitReqAction[k];
                                                    nCaseProduct.Unique_ID__c = linesList[i].Current_Order__c+' | '+linesList[i].PO__c+' | '+splitReqAction[k]+' | '+linesList[i].Transaction_ID__c;
                                                        console.log('Action Assignment: '+splitReqAction[k]);
                                                    nCaseProduct.PO__c = linesList[i].PO__c;
                                                
                                                                                      
                                                    
                                                    if(linesList[i].Material__c != null){
                                                        nCaseProduct.Material_Number__c = linesList[i].Material__c; 
                                                    } else {
                                                        nCaseProduct.No_Cat_Number__c = linesList[i].NoCAT__c;
                                                        nCaseProduct.No_Cat__c = true;
                                                    }
                                                    
                                                    
                                                    /*if(linesList[i].Product_SKU__c != null){
                                                        nCaseProduct.GE_NAS_Product_Code__c = linesList[i].Product_SKU__c;
                                                            console.log('SKU Assignment: '+ linesList[i].Product_SKU__c);
                                                    } else {
                                                        nCaseProduct.GE_NAS_Product_Code__c = linesList[i].NoCAT__c;
                                                            console.log('SKU Assignment: '+ linesList[i].NoCAT__c);
                                                    }*/
                                                    nCaseProduct.Invoiced_Price__c = linesList[i].UnitPrice__c;
                                                        console.log('Unit Price: '+ linesList[i].UnitPrice__c);
                                                    nCaseProduct.Discrepancy_Qty__c = linesList[i].No_Of_Products_Failed__c;
                                                        console.log('Disputed QTY Assignment: '+ linesList[i].No_Of_Products_Failed__c);
                                                    nCaseProduct.Order_Qty__c = linesList[i].Quantity__c;
                                                        console.log('Ordered Quantity: '+linesList[i].Quantity__c);
                                                    nCaseProduct.Order__c = linesList[i].order__c;
                                                        console.log('Ordered Order: '+linesList[i].order__c);
                                                    nCaseProduct.Distributor_Name__c = linesList[i].Distributor_Name__c;
                                                    nCaseProduct.Distributor_ID__c = linesList[i].Distributor_Id__c;
                                                    nCaseProduct.GE_NAS_Unit_of_Measure__c = linesList[i].UnitOfMeasure__c;
                                                    nCaseProduct.QuickStock__c = linesList[i].Quick_Stock__c;
                                                    nCaseProduct.Invoice_Line__c = linesList[i].Invoice_Line__c;
                                                    nCaseProduct.SFDC_Invoice__c = linesList[i].SFDC_Invoice__c; 
                                                    nCaseProduct.No_Of_Products_Failed__c = linesList[i].No_Of_Products_Failed__C;
                                                    nCaseProduct.Installed_Qty__c = linesList[i].Installed_Qty__c;
                                                    nCaseProduct.Install_Date__c = linesList[i].Date_Installed__c;
                                                    nCaseProduct.GE_NAS_Comments__c = linesList[i].Comments__c; 
                                                this.caseProductInsert.push(nCaseProduct);
                                                console.log('Items Pushed to CP List: '+ JSON.stringify(this.caseProductInsert));
                                        }
                                } else {
                                    console.log('Current Iteration:'+linesList[i].Requested_Action_Override__c);
                                    let nCaseProduct = {'sobjecttype': 'Shipment_Detail__c'};
                                    //nCaseProduct.Material_Number__c = linesList[i].SKU__c;
                                    //console.log('Material Assignment: '+linesList[i].SKU__c);
                                        nCaseProduct.GE_NAS_Case_Number__c = this.CaseNumber; 
                                        nCaseProduct.GE_NAS_Type_of_Problem1__c = linesList[i].Requested_Action_Override__c;
                                        nCaseProduct.GE_NAS_Type_of_Problem__c = 'Warranty - '+linesList[i].Requested_Action_Override__c;
                                        nCaseProduct.Unique_ID__c = linesList[i].Current_Order__c+' | '+linesList[i].PO__c+' | '+linesList[i].Requested_Action_Override__c+' | '+linesList[i].Transaction_ID__c;
                                            console.log('Action Assignment: '+linesList[i].Requested_Action_Override__c);
                                        nCaseProduct.PO__c = linesList[i].PO__c;
                                    
                                        if(linesList[i].Material__c != null){
                                            nCaseProduct.Material_Number__c = linesList[i].Material__c; 
                                        } else {
                                            nCaseProduct.No_Cat_Number__c = linesList[i].NoCAT__c;
                                            nCaseProduct.No_Cat__c = true;
                                        }
                                        
                                        
                                        /*if(linesList[i].Product_SKU__c != null){
                                            nCaseProduct.GE_NAS_Product_Code__c = linesList[i].Product_SKU__c;
                                                console.log('SKU Assignment: '+ linesList[i].Product_SKU__c);
                                        } else {
                                            nCaseProduct.GE_NAS_Product_Code__c = linesList[i].NoCAT__c;
                                                console.log('SKU Assignment: '+ linesList[i].NoCAT__c);
                                        }*/
                                        nCaseProduct.Invoiced_Price__c = linesList[i].UnitPrice__c;
                                            console.log('Unit Price: '+ linesList[i].UnitPrice__c);
                                        nCaseProduct.Discrepancy_Qty__c = linesList[i].No_Of_Products_Failed__c;
                                            console.log('Disputed QTY Assignment: '+ linesList[i].No_Of_Products_Failed__c);
                                        nCaseProduct.Order_Qty__c = linesList[i].Quantity__c;
                                            console.log('Ordered Quantity: '+linesList[i].Quantity__c);
                                        nCaseProduct.Order__c = linesList[i].order__c;
                                            console.log('Ordered Order: '+linesList[i].order__c);
                                        nCaseProduct.Distributor_Name__c = linesList[i].Distributor_Name__c;
                                        nCaseProduct.Distributor_ID__c = linesList[i].Distributor_Id__c;
                                        nCaseProduct.GE_NAS_Unit_of_Measure__c = linesList[i].UnitOfMeasure__c;
                                        nCaseProduct.QuickStock__c = linesList[i].Quick_Stock__c;
                                        nCaseProduct.Invoice_Line__c = linesList[i].Invoice_Line__c;
                                        nCaseProduct.SFDC_Invoice__c = linesList[i].SFDC_Invoice__c; 
                                        nCaseProduct.No_Of_Products_Failed__c = linesList[i].No_Of_Products_Failed__C;
                                        nCaseProduct.Installed_Qty__c = linesList[i].Installed_Qty__c;
                                        nCaseProduct.Install_Date__c = linesList[i].Date_Installed__c;
                                        nCaseProduct.GE_NAS_Comments__c = linesList[i].Comments__c; 
                                    this.caseProductInsert.push(nCaseProduct);
                                    console.log('Items Pushed to CP List: '+ JSON.stringify(this.caseProductInsert));
                                } 

                        } else if (resultCheck === false){
                        console.log('INSIDE HEADER LEVEL...');
                                if(this.requestedAction === "Return and Replace" || this.requestedAction === "Return and Credit"){
                                    splitReqAction = this.requestedAction.split(' and ');
                                    console.log('HEADER SPLIT - List Size: '+splitReqAction.length);

                                    // FOR EACH VARIABLE IN THE SPLIT ARRAY CREATE A CASE PRODUCT FOR EACH AND PUSH TO caseProductInsert List    
                                    for(var k = 0; k < splitReqAction.length ; k++){
                                        console.log('K: '+k);
                                            console.log('Current Iteration:'+splitReqAction[k]);
                                            let nCaseProduct = {'sobjecttype': 'Shipment_Detail__c'};
                                            //nCaseProduct.Material_Number__c = linesList[i].SKU__c;
                                            //console.log('Material Assignment: '+linesList[i].SKU__c);
                                                nCaseProduct.GE_NAS_Case_Number__c = this.CaseNumber; 
                                                nCaseProduct.GE_NAS_Type_of_Problem1__c = splitReqAction[k];
                                                nCaseProduct.GE_NAS_Type_of_Problem__c = 'Warranty - '+splitReqAction[k];
                                                nCaseProduct.Unique_ID__c = linesList[i].Current_Order__c+' | '+linesList[i].PO__c+' | '+splitReqAction[k]+' | '+linesList[i].Transaction_ID__c;
                                                    console.log('Action Assignment: '+splitReqAction[k]);
                                                nCaseProduct.PO__c = linesList[i].PO__c;
                                            
                                                if(linesList[i].Material__c != null){
                                                    nCaseProduct.Material_Number__c = linesList[i].Material__c; 
                                                } else {
                                                    nCaseProduct.No_Cat_Number__c = linesList[i].NoCAT__c;
                                                    nCaseProduct.No_Cat__c = true;
                                                }
                                                
                                                
                                                /*if(linesList[i].Product_SKU__c != null){
                                                    nCaseProduct.GE_NAS_Product_Code__c = linesList[i].Product_SKU__c;
                                                        console.log('SKU Assignment: '+ linesList[i].Product_SKU__c);
                                                } else {
                                                    nCaseProduct.GE_NAS_Product_Code__c = linesList[i].NoCAT__c;
                                                        console.log('SKU Assignment: '+ linesList[i].NoCAT__c);
                                                }*/
                                                nCaseProduct.Invoiced_Price__c = linesList[i].UnitPrice__c;
                                                    console.log('Unit Price: '+ linesList[i].UnitPrice__c);
                                                nCaseProduct.Discrepancy_Qty__c = linesList[i].No_Of_Products_Failed__c;
                                                    console.log('Disputed QTY Assignment: '+ linesList[i].No_Of_Products_Failed__c);
                                                nCaseProduct.Order_Qty__c = linesList[i].Quantity__c;
                                                    console.log('Ordered Quantity: '+linesList[i].Quantity__c);
                                                nCaseProduct.Order__c = linesList[i].order__c;
                                                    console.log('Ordered Order: '+linesList[i].order__c);
                                                nCaseProduct.Distributor_Name__c = linesList[i].Distributor_Name__c;
                                                nCaseProduct.Distributor_ID__c = linesList[i].Distributor_Id__c;
                                                nCaseProduct.GE_NAS_Unit_of_Measure__c = linesList[i].UnitOfMeasure__c;
                                                nCaseProduct.QuickStock__c = linesList[i].Quick_Stock__c;
                                                nCaseProduct.Invoice_Line__c = linesList[i].Invoice_Line__c;
                                                nCaseProduct.SFDC_Invoice__c = linesList[i].SFDC_Invoice__c; 
                                                nCaseProduct.No_Of_Products_Failed__c = linesList[i].No_Of_Products_Failed__C;
                                                nCaseProduct.Installed_Qty__c = linesList[i].Installed_Qty__c;
                                                nCaseProduct.Install_Date__c = linesList[i].Date_Installed__c;
                                                nCaseProduct.GE_NAS_Comments__c = linesList[i].Comments__c; 
                                            this.caseProductInsert.push(nCaseProduct);
                                            console.log('Items Pushed to CP List: '+ JSON.stringify(this.caseProductInsert));
                                    }

                                } else {
                                    console.log('Current Iteration:'+this.requestedAction);
                                    let nCaseProduct = {'sobjecttype': 'Shipment_Detail__c'};
                                    //nCaseProduct.Material_Number__c = linesList[i].SKU__c;
                                    //console.log('Material Assignment: '+linesList[i].SKU__c);
                                        nCaseProduct.GE_NAS_Case_Number__c = this.CaseNumber; 
                                        nCaseProduct.GE_NAS_Type_of_Problem1__c = linesList[i].Requested_Action_Override__c;
                                        nCaseProduct.GE_NAS_Type_of_Problem__c = 'Warranty - '+this.requestedAction;
                                        nCaseProduct.Unique_ID__c = linesList[i].Current_Order__c+' | '+linesList[i].PO__c+' | '+this.requestedAction+' | '+linesList[i].Transaction_ID__c;
                                            console.log('Action Assignment: '+this.requestedAction);
                                        nCaseProduct.PO__c = linesList[i].PO__c;
                                    
                                        if(linesList[i].Material__c != null){
                                            nCaseProduct.Material_Number__c = linesList[i].Material__c; 
                                        } else {
                                            nCaseProduct.No_Cat_Number__c = linesList[i].NoCAT__c;
                                            nCaseProduct.No_Cat__c = true;
                                        }
                                        
                                        
                                        /*if(linesList[i].Product_SKU__c != null){
                                            nCaseProduct.GE_NAS_Product_Code__c = linesList[i].Product_SKU__c;
                                                console.log('SKU Assignment: '+ linesList[i].Product_SKU__c);
                                        } else {
                                            nCaseProduct.GE_NAS_Product_Code__c = linesList[i].NoCAT__c;
                                                console.log('SKU Assignment: '+ linesList[i].NoCAT__c);
                                        }*/
                                        nCaseProduct.Invoiced_Price__c = linesList[i].UnitPrice__c;
                                            console.log('Unit Price: '+ linesList[i].UnitPrice__c);
                                        nCaseProduct.Discrepancy_Qty__c = linesList[i].No_Of_Products_Failed__c;
                                            console.log('Disputed QTY Assignment: '+ linesList[i].No_Of_Products_Failed__c);
                                        nCaseProduct.Order_Qty__c = linesList[i].Quantity__c;
                                            console.log('Ordered Quantity: '+linesList[i].Quantity__c);
                                        nCaseProduct.Order__c = linesList[i].order__c;
                                            console.log('Ordered Order: '+linesList[i].order__c);
                                        nCaseProduct.Distributor_Name__c = linesList[i].Distributor_Name__c;
                                        nCaseProduct.Distributor_ID__c = linesList[i].Distributor_Id__c;
                                        nCaseProduct.GE_NAS_Unit_of_Measure__c = linesList[i].UnitOfMeasure__c;
                                        nCaseProduct.QuickStock__c = linesList[i].Quick_Stock__c;
                                        nCaseProduct.Invoice_Line__c = linesList[i].Invoice_Line__c;
                                        nCaseProduct.SFDC_Invoice__c = linesList[i].SFDC_Invoice__c; 
                                        nCaseProduct.No_Of_Products_Failed__c = linesList[i].No_Of_Products_Failed__C;
                                        nCaseProduct.Installed_Qty__c = linesList[i].Installed_Qty__c;
                                        nCaseProduct.Install_Date__c = linesList[i].Date_Installed__c;
                                        nCaseProduct.GE_NAS_Comments__c = linesList[i].Comments__c; 
                                    this.caseProductInsert.push(nCaseProduct);
                                    console.log('Items Pushed to CP List: '+ JSON.stringify(this.caseProductInsert));
                                }

                        }
                    }
                    /*
                            // CHECKS TO SEE IF THE LINE EQUALS RETURN AND REPLACEMENT OR LINE DOES NOT HAVE RAO PROPERTY AND HEADER ACTION IS RETURN AND REPLACEMENT
                            if(linesList[i].Requested_Action_Override__c == "Return and Replace" || (resultCheck === false && this.requestedAction == "Return and Replace")){
                                console.log('IN THE RETURN AND REPLACE IF STATEMENT....');
                                // SPLITS THE LINE OR HEADER ACTION TO RETURN, REPLACEMENT INTO AN ARRAY
                                var splitReqAction = [];
                                   if(linesList[i].Requested_Action_Override__c == "Return and Replace"){
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
                                        console.log('RETURN AND REPLACE - HEADER LEVEL EXECUTION');
                                        //nCaseProduct.Material_Number__c = linesList[i].SKU__c;
                                        //console.log('Material Assignment: '+linesList[i].SKU__c);
                                            nCaseProduct.GE_NAS_Case_Number__c = this.CaseNumber; 
                                            nCaseProduct.GE_NAS_Type_of_Problem1__c = splitReqAction[k];
                                            nCaseProduct.GE_NAS_Type_of_Problem__c = 'Warranty - '+splitReqAction[k];
                                            nCaseProduct.Unique_ID__c = linesList[i].Current_Order__c+' | '+linesList[i].PO__c+' | '+splitReqAction[k]+' | '+linesList[i].Transaction_ID__c;
                                                console.log('Action Assignment: '+splitReqAction[k]);
                                            nCaseProduct.PO__c = linesList[i].PO__c;
                                          
                                                                                   
                                            if(linesList[i].Product_SKU__c != null){
                                                nCaseProduct.GE_NAS_Product_Code__c = linesList[i].Product_SKU__c;
                                                    console.log('SKU Assignment: '+ linesList[i].Product_SKU__c);
                                            } else {
                                                nCaseProduct.GE_NAS_Product_Code__c = linesList[i].NoCAT__c;
                                                    console.log('SKU Assignment: '+ linesList[i].NoCAT__c);
                                            }
                                            nCaseProduct.Invoiced_Price__c = linesList[i].UnitPrice__c;
                                                console.log('Unit Price: '+ linesList[i].UnitPrice__c);
                                            nCaseProduct.Discrepancy_Qty__c = linesList[i].No_Of_Products_Failed__c;
                                                console.log('Disputed QTY Assignment: '+ linesList[i].No_Of_Products_Failed__c);
                                            nCaseProduct.Order_Qty__c = linesList[i].Quantity__c;
                                                console.log('Ordered Quantity: '+linesList[i].Quantity__c);
                                            nCaseProduct.Order__c = linesList[i].order__c;
                                                console.log('Ordered Order: '+linesList[i].order__c);
                                            nCaseProduct.Distributor_Name__c = linesList[i].Distributor_Name__c;
                                            nCaseProduct.Distributor_ID__c = linesList[i].Distributor_Id__c;
                                            nCaseProduct.GE_NAS_Unit_of_Measure__c = linesList[i].UnitOfMeasure__c;
                                            nCaseProduct.QuickStock__c = linesList[i].Quick_Stock__c;
                                            nCaseProduct.Invoice_Line__c = linesList[i].Invoice_Line__c;
                                            nCaseProduct.SFDC_Invoice__c = linesList[i].SFDC_Invoice__c; 
                                            nCaseProduct.No_Of_Products_Failed__c = linesList[i].No_Of_Products_Failed__C;
                                            nCaseProduct.Installed_Qty__c = linesList[i].Installed_Qty__c;
                                            nCaseProduct.Install_Date__c = linesList[i].Date_Installed__c;
                                            nCaseProduct.GE_NAS_Comments__c = linesList[i].Comments__c; 
                                        this.caseProductInsert.push(nCaseProduct);
                                        console.log('Items Pushed to CP List: '+ JSON.stringify(this.caseProductInsert));
                                }
                            } 

                            // IF LINE HAS A REQUESTED ACTION OVERRIDE VALUE OF RETURN AND REPLACE --OR-- IF LINE HAS REQUESTED ACTION OVERRIDE AND HEADER ACTION IS RETURN AND REPLACE
                            else if (linesList[i].Requested_Action_Override__c == "Return and Replace" || (resultCheck === true && this.requestedAction == "Return and Replace"))  {
                                let nCaseProduct = {'sobjecttype': 'Shipment_Detail__c'};
                                nCaseProduct.GE_NAS_Case_Number__c = this.CaseNumber;
                                console.log('INSIDE RETURN AND REPLACE ELSE STATEMENT...');
                                console.log('RETURN AND REPLACE - LINE LEVEL EXECUTION');

                                //CHECK REQUESTED OVERRIDE ACTION (LINE LEVEL) IS BLANK. IF SO (ELSE BRANCH), USE HEADER SELECTION. IF NOT (IF BRANCH), USE LINE LEVEL ACTION (WHICH IS NOT RETURN & REPLACE)
                                if(linesList[i].hasOwnProperty('Requested_Action_Override__c') && linesList[i].Requested_Action_Override__c !== "Return and Replace"){
                                    nCaseProduct.GE_NAS_Type_of_Problem1__c = linesList[i].Requested_Action_Override__c;
                                    nCaseProduct.GE_NAS_Type_of_Problem__c = 'Warranty - '+linesList[i].Requested_Action_Override__c;
                                    nCaseProduct.Unique_ID__c = linesList[i].Current_Order__c+' | '+linesList[i].PO__c+' | '+linesList[i].Requested_Action_Override__c +' | '+linesList[i].Transaction_ID__c;
                                } else{
                                    // nCaseProduct.GE_NAS_Type_of_Problem1__c = this.requestedAction;
                                    nCaseProduct.GE_NAS_Type_of_Problem1__c = this.requestedAction;
                                    nCaseProduct.GE_NAS_Type_of_Problem__c = 'Warranty - '+this.requestedAction;
                                    nCaseProduct.Unique_ID__c = linesList[i].Current_Order__c+' | '+linesList[i].PO__c+' | '+this.requestedAction +' | '+linesList[i].Transaction_ID__c;
                                }
                                    console.log('Action Assignment: '+ linesList[i].Requested_Action_Override__c);
                                nCaseProduct.PO__c = linesList[i].PO__c;
                                
                                if(linesList[i].Product_SKU__c != null){
                                    nCaseProduct.GE_NAS_Product_Code__c = linesList[i].Product_SKU__c;
                                        console.log('SKU Assignment: '+ linesList[i].Product_SKU__c);
                                } else {
                                    nCaseProduct.GE_NAS_Product_Code__c = linesList[i].NoCAT__c;
                                        console.log('SKU Assignment: '+ linesList[i].NoCAT__c);
                                }
                                //nCaseProduct.Material_Number__c = linesList[i].SKU__c;
                                    //console.log('Material Assignment: '+linesList[i].SKU__c);
                                nCaseProduct.Invoiced_Price__c = linesList[i].UnitPrice__c;
                                    console.log('Unit Price: '+ linesList[i].UnitPrice__c);
                                nCaseProduct.Discrepancy_Qty__c = linesList[i].No_Of_Products_Failed__c;
                                    console.log('Disputed QTY Assignment: '+ linesList[i].No_Of_Products_Failed__c);
                                nCaseProduct.Order_Qty__c = linesList[i].Quantity__c;
                                    console.log('Ordered Quantity: '+linesList[i].Quantity__c);
                                nCaseProduct.Order__c = linesList[i].order__c;
                                    console.log('Ordered Order: '+linesList[i].order__c);
                                nCaseProduct.Distributor_Name__c = linesList[i].Distributor_Name__c;
                                    console.log('Distributor Name: '+linesList[i].Distributor_Name__c);
                                nCaseProduct.Distributor_ID__c = linesList[i].Distributor_Id__c;
                                nCaseProduct.GE_NAS_Unit_of_Measure__c = linesList[i].UnitOfMeasure__c;    
                                nCaseProduct.QuickStock__c = linesList[i].Quick_Stock__c;
                                nCaseProduct.Invoice_Line__c = linesList[i].Invoice_Line__c;
                                nCaseProduct.SFDC_Invoice__c = linesList[i].SFDC_Invoice__c;
                                nCaseProduct.No_Of_Products_Failed__c = linesList[i].No_Of_Products_Failed__C;
                                nCaseProduct.Installed_Qty__c = linesList[i].Installed_Qty__c;
                                nCaseProduct.Install_Date__c = linesList[i].Date_Installed__c;
                                nCaseProduct.GE_NAS_Comments__c = linesList[i].Comments__c;     
                                this.caseProductInsert.push(nCaseProduct);
                        }

                        // CHECKS TO SEE IF THE LINE EQUALS RETURN AND CREDIT OR LINE DOES NOT HAVE RAO PROPERTY AND HEADER ACTION IS RETURN AND CREDIT
                        else if(linesList[i].Requested_Action_Override__c == "Return and Credit" || (resultCheck === false && this.requestedAction == "Return and Credit")){
                            console.log('IN THE RETURN AND CREDIT IF STATEMENT....');
                            // SPLITS THE LINE OR HEADER ACTION TO RETURN, CREDIT INTO AN ARRAY
                            var splitReqAction = [];
                            if(linesList[i].Requested_Action_Override__c == "Return and Credit"){
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
                                    console.log('RETURN AND CREDIT - HEADER LEVEL EXECUTION');
                                    //nCaseProduct.Material_Number__c = linesList[i].SKU__c;
                                    //console.log('Material Assignment: '+linesList[i].SKU__c);
                                        nCaseProduct.GE_NAS_Case_Number__c = this.CaseNumber; 
                                        nCaseProduct.GE_NAS_Type_of_Problem1__c = splitReqAction[k];
                                        nCaseProduct.GE_NAS_Type_of_Problem__c = 'Warranty - '+splitReqAction[k];
                                        nCaseProduct.Unique_ID__c = linesList[i].Current_Order__c+' | '+linesList[i].PO__c+' | '+splitReqAction[k]+' | '+linesList[i].Transaction_ID__c;
                                            console.log('Action Assignment: '+splitReqAction[k]);
                                        nCaseProduct.PO__c = linesList[i].PO__c;
                                        
                                                                            
                                        if(linesList[i].Product_SKU__c != null){
                                            nCaseProduct.GE_NAS_Product_Code__c = linesList[i].Product_SKU__c;
                                                console.log('SKU Assignment: '+ linesList[i].Product_SKU__c);
                                        } else {
                                            nCaseProduct.GE_NAS_Product_Code__c = linesList[i].NoCAT__c;
                                                console.log('SKU Assignment: '+ linesList[i].NoCAT__c);
                                        }
                                        nCaseProduct.Invoiced_Price__c = linesList[i].UnitPrice__c;
                                            console.log('Unit Price: '+ linesList[i].UnitPrice__c);
                                        nCaseProduct.Discrepancy_Qty__c = linesList[i].No_Of_Products_Failed__c;
                                            console.log('Disputed QTY Assignment: '+ linesList[i].No_Of_Products_Failed__c);
                                        nCaseProduct.Order_Qty__c = linesList[i].Quantity__c;
                                            console.log('Ordered Quantity: '+linesList[i].Quantity__c);
                                        nCaseProduct.Order__c = linesList[i].order__c;
                                            console.log('Ordered Order: '+linesList[i].order__c);
                                        nCaseProduct.Distributor_Name__c = linesList[i].Distributor_Name__c;
                                        nCaseProduct.Distributor_ID__c = linesList[i].Distributor_Id__c;
                                        nCaseProduct.GE_NAS_Unit_of_Measure__c = linesList[i].UnitOfMeasure__c;
                                        nCaseProduct.QuickStock__c = linesList[i].Quick_Stock__c;
                                        nCaseProduct.Invoice_Line__c = linesList[i].Invoice_Line__c;
                                        nCaseProduct.SFDC_Invoice__c = linesList[i].SFDC_Invoice__c; 
                                        nCaseProduct.No_Of_Products_Failed__c = linesList[i].No_Of_Products_Failed__C;
                                        nCaseProduct.Installed_Qty__c = linesList[i].Installed_Qty__c;
                                        nCaseProduct.Install_Date__c = linesList[i].Date_Installed__c;
                                        nCaseProduct.GE_NAS_Comments__c = linesList[i].Comments__c; 
                                    this.caseProductInsert.push(nCaseProduct);
                                    console.log('Items Pushed to CP List: '+ JSON.stringify(this.caseProductInsert));
                            }
                        } 
                        else if (linesList[i].Requested_Action_Override__c == "Return and Credit" || (resultCheck === true && this.requestedAction == "Return and Credit")) {
                        let nCaseProduct = {'sobjecttype': 'Shipment_Detail__c'};
                        nCaseProduct.GE_NAS_Case_Number__c = this.CaseNumber;
                        console.log('INSIDE RETURN AND CREDIT ELSE STATEMENT...');
                        console.log('RETURN AND CREDIT - LINE LEVEL EXECUTION');

                            //CHECK REQUESTED OVERRIDE ACTION (LINE LEVEL) IS BLANK. IF SO (ELSE BRANCH), USE HEADER SELECTION. IF NOT (IF BRANCH), USE LINE LEVEL
                            if(linesList[i].hasOwnProperty('Requested_Action_Override__c') && linesList[i].Requested_Action_Override__c !== "Return and Credit"){
                                nCaseProduct.GE_NAS_Type_of_Problem1__c = linesList[i].Requested_Action_Override__c;
                                nCaseProduct.GE_NAS_Type_of_Problem__c = 'Warranty - '+linesList[i].Requested_Action_Override__c;
                                nCaseProduct.Unique_ID__c = linesList[i].Current_Order__c+' | '+linesList[i].PO__c+' | '+linesList[i].Requested_Action_Override__c +' | '+linesList[i].Transaction_ID__c;
                            } else{
                               // nCaseProduct.GE_NAS_Type_of_Problem1__c = this.requestedAction;
                                nCaseProduct.GE_NAS_Type_of_Problem1__c = this.requestedAction;
                                nCaseProduct.GE_NAS_Type_of_Problem__c = 'Warranty - '+this.requestedAction;
                                nCaseProduct.Unique_ID__c = linesList[i].Current_Order__c+' | '+linesList[i].PO__c+' | '+this.requestedAction +' | '+linesList[i].Transaction_ID__c;
                            }
                                console.log('Action Assignment: '+ linesList[i].Requested_Action_Override__c);
                            nCaseProduct.PO__c = linesList[i].PO__c;
                            
                            if(linesList[i].Product_SKU__c != null){
                                nCaseProduct.GE_NAS_Product_Code__c = linesList[i].Product_SKU__c;
                                    console.log('SKU Assignment: '+ linesList[i].Product_SKU__c);
                            } else {
                                nCaseProduct.GE_NAS_Product_Code__c = linesList[i].NoCAT__c;
                                    console.log('SKU Assignment: '+ linesList[i].NoCAT__c);
                            }
                            //nCaseProduct.Material_Number__c = linesList[i].SKU__c;
                                //console.log('Material Assignment: '+linesList[i].SKU__c);
                            nCaseProduct.Invoiced_Price__c = linesList[i].UnitPrice__c;
                                console.log('Unit Price: '+ linesList[i].UnitPrice__c);
                            nCaseProduct.Discrepancy_Qty__c = linesList[i].No_Of_Products_Failed__c;
                                console.log('Disputed QTY Assignment: '+ linesList[i].No_Of_Products_Failed__c);
                            nCaseProduct.Order_Qty__c = linesList[i].Quantity__c;
                                console.log('Ordered Quantity: '+linesList[i].Quantity__c);
                            nCaseProduct.Order__c = linesList[i].order__c;
                                console.log('Ordered Order: '+linesList[i].order__c);
                            nCaseProduct.Distributor_Name__c = linesList[i].Distributor_Name__c;
                                console.log('Distributor Name: '+linesList[i].Distributor_Name__c);
                            nCaseProduct.Distributor_ID__c = linesList[i].Distributor_Id__c;
                            nCaseProduct.GE_NAS_Unit_of_Measure__c = linesList[i].UnitOfMeasure__c;    
                            nCaseProduct.QuickStock__c = linesList[i].Quick_Stock__c;
                            nCaseProduct.Invoice_Line__c = linesList[i].Invoice_Line__c;
                            nCaseProduct.SFDC_Invoice__c = linesList[i].SFDC_Invoice__c;
                            nCaseProduct.No_Of_Products_Failed__c = linesList[i].No_Of_Products_Failed__C;
                            nCaseProduct.Installed_Qty__c = linesList[i].Installed_Qty__c;
                            nCaseProduct.Install_Date__c = linesList[i].Date_Installed__c; 
                            nCaseProduct.GE_NAS_Comments__c = linesList[i].Comments__c;    
                            this.caseProductInsert.push(nCaseProduct);
                        } 
                       
                           
                        // CHECKS TO SEE IF THE LINE EQUALS RETURN FOR ANALYSIS OR LINE DOES NOT HAVE RAO PROPERTY AND HEADER ACTION IS RETURN AND CREDIT
                        else if (linesList[i].Requested_Action_Override__c == "Return for Analysis" || (resultCheck === true && this.requestedAction == "Return for Analysis")) {
                            let nCaseProduct = {'sobjecttype': 'Shipment_Detail__c'};
                            nCaseProduct.GE_NAS_Case_Number__c = this.CaseNumber;
                            console.log('INSIDE RETURN FOR ANALYSIS ELSE STATEMENT...');
                            console.log('RETURN AND CREDIT - LINE LEVEL EXECUTION');

                                //CHECK REQUESTED OVERRIDE ACTION (LINE LEVEL) IS BLANK. IF SO (ELSE BRANCH), USE HEADER SELECTION. IF NOT (IF BRANCH), USE LINE LEVEL
                                if(linesList[i].hasOwnProperty('Requested_Action_Override__c') && linesList[i].Requested_Action_Override__c !== "Return for Analysis"){
                                    nCaseProduct.GE_NAS_Type_of_Problem1__c = linesList[i].Requested_Action_Override__c;
                                    nCaseProduct.GE_NAS_Type_of_Problem__c = 'Warranty - '+linesList[i].Requested_Action_Override__c;
                                    nCaseProduct.Unique_ID__c = linesList[i].Current_Order__c+' | '+linesList[i].PO__c+' | '+linesList[i].Requested_Action_Override__c +' | '+linesList[i].Transaction_ID__c;
                                } else{
                                // nCaseProduct.GE_NAS_Type_of_Problem1__c = this.requestedAction;
                                    nCaseProduct.GE_NAS_Type_of_Problem1__c = this.requestedAction;
                                    nCaseProduct.GE_NAS_Type_of_Problem__c = 'Warranty - '+this.requestedAction;
                                    nCaseProduct.Unique_ID__c = linesList[i].Current_Order__c+' | '+linesList[i].PO__c+' | '+this.requestedAction +' | '+linesList[i].Transaction_ID__c;
                                }
                                    console.log('Action Assignment: '+ linesList[i].Requested_Action_Override__c);
                                nCaseProduct.PO__c = linesList[i].PO__c;
                                
                                if(linesList[i].Product_SKU__c != null){
                                    nCaseProduct.GE_NAS_Product_Code__c = linesList[i].Product_SKU__c;
                                        console.log('SKU Assignment: '+ linesList[i].Product_SKU__c);
                                } else {
                                    nCaseProduct.GE_NAS_Product_Code__c = linesList[i].NoCAT__c;
                                        console.log('SKU Assignment: '+ linesList[i].NoCAT__c);
                                }
                                //nCaseProduct.Material_Number__c = linesList[i].SKU__c;
                                    //console.log('Material Assignment: '+linesList[i].SKU__c);
                                nCaseProduct.Invoiced_Price__c = linesList[i].UnitPrice__c;
                                    console.log('Unit Price: '+ linesList[i].UnitPrice__c);
                                nCaseProduct.Discrepancy_Qty__c = linesList[i].No_Of_Products_Failed__c;
                                    console.log('Disputed QTY Assignment: '+ linesList[i].No_Of_Products_Failed__c);
                                nCaseProduct.Order_Qty__c = linesList[i].Quantity__c;
                                    console.log('Ordered Quantity: '+linesList[i].Quantity__c);
                                nCaseProduct.Order__c = linesList[i].order__c;
                                    console.log('Ordered Order: '+linesList[i].order__c);
                                nCaseProduct.Distributor_Name__c = linesList[i].Distributor_Name__c;
                                    console.log('Distributor Name: '+linesList[i].Distributor_Name__c);
                                nCaseProduct.Distributor_ID__c = linesList[i].Distributor_Id__c;
                                nCaseProduct.GE_NAS_Unit_of_Measure__c = linesList[i].UnitOfMeasure__c;    
                                nCaseProduct.QuickStock__c = linesList[i].Quick_Stock__c;
                                nCaseProduct.Invoice_Line__c = linesList[i].Invoice_Line__c;
                                nCaseProduct.SFDC_Invoice__c = linesList[i].SFDC_Invoice__c;
                                nCaseProduct.No_Of_Products_Failed__c = linesList[i].No_Of_Products_Failed__C;
                                nCaseProduct.Installed_Qty__c = linesList[i].Installed_Qty__c;
                                nCaseProduct.Install_Date__c = linesList[i].Date_Installed__c;
                                nCaseProduct.GE_NAS_Comments__c = linesList[i].Comments__c;     
                                this.caseProductInsert.push(nCaseProduct);
                            }

                            else if (linesList[i].Requested_Action_Override__c == "Return for Analysis" || (resultCheck === false && this.requestedAction == "Return for Analysis")) {
                                let nCaseProduct = {'sobjecttype': 'Shipment_Detail__c'};
                                nCaseProduct.GE_NAS_Case_Number__c = this.CaseNumber;
                                console.log('INSIDE RETURN FOR ANALYSIS ELSE STATEMENT...');
                                console.log('RETURN AND CREDIT - LINE LEVEL EXECUTION');
    
                                //CHECK REQUESTED OVERRIDE ACTION (LINE LEVEL) IS BLANK. IF SO (ELSE BRANCH), USE HEADER SELECTION. IF NOT (IF BRANCH), USE LINE LEVEL
                                if(linesList[i].hasOwnProperty('Requested_Action_Override__c') && linesList[i].Requested_Action_Override__c !== "Return for Analysis"){
                                    nCaseProduct.GE_NAS_Type_of_Problem1__c = linesList[i].Requested_Action_Override__c;
                                    nCaseProduct.GE_NAS_Type_of_Problem__c = 'Warranty - '+linesList[i].Requested_Action_Override__c;
                                    nCaseProduct.Unique_ID__c = linesList[i].Current_Order__c+' | '+linesList[i].PO__c+' | '+linesList[i].Requested_Action_Override__c +' | '+linesList[i].Transaction_ID__c;
                                } else{
                                   // nCaseProduct.GE_NAS_Type_of_Problem1__c = this.requestedAction;
                                    nCaseProduct.GE_NAS_Type_of_Problem1__c = this.requestedAction;
                                    nCaseProduct.GE_NAS_Type_of_Problem__c = 'Warranty - '+this.requestedAction;
                                    nCaseProduct.Unique_ID__c = linesList[i].Current_Order__c+' | '+linesList[i].PO__c+' | '+this.requestedAction +' | '+linesList[i].Transaction_ID__c;
                                }
                                    console.log('Action Assignment: '+ linesList[i].Requested_Action_Override__c);
                                nCaseProduct.PO__c = linesList[i].PO__c;
                                if(linesList[i].Product_SKU__c != null){
                                    nCaseProduct.GE_NAS_Product_Code__c = linesList[i].Product_SKU__c;
                                        console.log('SKU Assignment: '+ linesList[i].Product_SKU__c);
                                } else {
                                    nCaseProduct.GE_NAS_Product_Code__c = linesList[i].NoCAT__c;
                                        console.log('SKU Assignment: '+ linesList[i].NoCAT__c);
                                }
                                //nCaseProduct.Material_Number__c = linesList[i].SKU__c;
                                    //console.log('Material Assignment: '+linesList[i].SKU__c);
                                nCaseProduct.Invoiced_Price__c = linesList[i].UnitPrice__c;
                                    console.log('Unit Price: '+ linesList[i].UnitPrice__c);
                                nCaseProduct.Discrepancy_Qty__c = linesList[i].No_Of_Products_Failed__c;
                                    console.log('Disputed QTY Assignment: '+ linesList[i].No_Of_Products_Failed__c);
                                nCaseProduct.Order_Qty__c = linesList[i].Quantity__c;
                                    console.log('Ordered Quantity: '+linesList[i].Quantity__c);
                                nCaseProduct.Order__c = linesList[i].order__c;
                                    console.log('Ordered Order: '+linesList[i].order__c);
                                nCaseProduct.Distributor_Name__c = linesList[i].Distributor_Name__c;
                                    console.log('Distributor Name: '+linesList[i].Distributor_Name__c);
                                nCaseProduct.Distributor_ID__c = linesList[i].Distributor_Id__c;
                                nCaseProduct.GE_NAS_Unit_of_Measure__c = linesList[i].UnitOfMeasure__c;    
                                nCaseProduct.QuickStock__c = linesList[i].Quick_Stock__c;
                                nCaseProduct.Invoice_Line__c = linesList[i].Invoice_Line__c;
                                nCaseProduct.SFDC_Invoice__c = linesList[i].SFDC_Invoice__c;
                                nCaseProduct.No_Of_Products_Failed__c = linesList[i].No_Of_Products_Failed__C;
                                nCaseProduct.Installed_Qty__c = linesList[i].Installed_Qty__c;
                                nCaseProduct.Install_Date__c = linesList[i].Date_Installed__c;
                                nCaseProduct.GE_NAS_Comments__c = linesList[i].Comments__c;     
                                this.caseProductInsert.push(nCaseProduct);
                            }    
                    }

                   */
                    
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

    handleValidation(){

        let siteContactName = this.template.querySelector('.eun').value;
        let siteEmail = this.template.querySelector('.eum').value;
        let sitePhone = this.template.querySelector('.eup').value;
        let acctName = this.soldToAccount;
        let siteStreet = this.endUserAddressStreet;
        console.log('Site Street: '+siteStreet);
        let siteCity = this.endUserAddressCity;
        let siteState = this.endUserAddressState;
        let sitePostal = this.endUserAddressPostalCode;
        let siteCountry = this.endUserAddressCountry;
        if (!acctName){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ERROR',
                    message: 'Please fill out all Required Fields',
                    variant: 'error'
                })
            );
        } else if (this.isReturnReplace == true ){

            const address =
            this.template.querySelector('lightning-input-address');
            const isValid = address.checkValidity();
          
            const allValid = [...this.template.querySelectorAll('.validValue')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
                if (allValid) {
                    if(isValid && (siteContactName && siteEmail && sitePhone) ) {
                        this.stepOneButton = false;
                        this.goToStepTwo();
                        
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'ERROR',
                                message: 'Please fill out all required Site Information',
                                variant: 'error'
                            })
                        );
                        
                    }
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
        

         else if( this.isReturnReplace === false) {
           
            
                const allValid = [...this.template.querySelectorAll('.validValue')]
                .reduce((validSoFar, inputCmp) => {
                            inputCmp.reportValidity();
                            return validSoFar && inputCmp.checkValidity();
                }, true);
                    if (allValid) {
                        if(this.endUserAddressStreet != "" && (!this.endUserAddressCity || !this.endUserAddressPostalCode || !this.endUserAddressState || !this.endUserAddressCountry)) {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'ERROR',
                                    message: 'Please complete Address Information',
                                    variant: 'error'
                                })
                            );
                        } else {
                            this.stepOneButton = false;
                            this.goToStepTwo();
                        }
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

    handleEmailValidation(){
        const emailRegex=/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        let email=this.template.querySelector(".eum").value;
        let emailVal=email.value;
        if(emailVal.match(emailRegex)){
            email.setCustomValidity("");

        }else{
            email.setCustomValidity("Please enter valid email");
        }
        email.reportValidity();
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
        console.log("Check for order Lines" + this.orderLines.length);
        if(this.orderLines.length == 0){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ERROR',
                    message: 'You must have at least 1 product added to your Cart',
                    variant: 'error'
                })
            );

        } else{
            console.log("Inside else Check for order Lines");

        this.currentStep = '3';

        this.template.querySelector('div.stepTwo').classList.add('slds-hide');
        this.template
            .querySelector('div.stepThree')
            .classList.remove('slds-hide');

        this.soldToAccount = this.soldToAccount;
        console.log('Sold To Account: '+this.soldToAccount);
        this.reqName = this.template.querySelector(".rn").value;
        console.log('Requestor Name: '+this.reqName);
        this.reqEmail = this.template.querySelector(".em").value;
        console.log('Requestor Email: '+this.reqEmail);
        this.reqPhone = this.template.querySelector(".rp").value;
        console.log('Requested Phone: '+this.reqPhone);
        this.warrantyCode = this.template.querySelector(".wc").value;
        console.log('Warranty Code: '+this.warrantyCode);
        this.warrantySubCode = this.template.querySelector(".wsc").value;
        console.log('Warranty Sub Code: '+this.warrantySubCode);
        this.requestedAction = this.template.querySelector(".ra").value;
        console.log('Requested Action: '+this.requestedAction);
        this.comments = this.template.querySelector(".cm").value;
        console.log('Comments: '+this.comments);
        
        this.endUserName = this.template.querySelector(".eun").value;
        console.log('End User Name: '+this.endUserName);
        this.endUserPhone = this.template.querySelector(".eup").value;
        console.log('End User Phone: '+this.endUserPhone);
        this.endUserEmail = this.template.querySelector(".eum").value;
        console.log('End User Email: '+this.endUserEmail);
        this.siteName = this.template.querySelector(".sn").value;

        console.log('Sending Account '+ this.selectedAccountID + ' for obtaining QUEUE ID');
        /*await getWarrantyQueueId({AccountId : this.selectedAccountID})
        .then(result=>{
            if(result){
                this.caseOwnerId = result;
                console.log('SETTING CASE QUEUE....'+this.caseOwnerId);
            } 
        })*/
        this.getCaseOwner();

        console.log('Street: '+this.endUserAddressStreet);
        console.log('City: '+this.endUserAddressCity);
        console.log('State: '+this.endUserAddressState);
        console.log('Postal Code: '+this.endUserAddressPostalCode);
        console.log('Country: '+this.endUserAddressCountry);
    
        var inputData={
            Account:this.soldToAccount,
            RequestorName:this.reqName,
            RequestorEmail:this.reqEmail,
            RequestorPhone:this.reqPhone,
            ReturnReason:this.warrantyCode,
            RequestedAction:this.requestedAction,
            SecondaryReason:this.warrantySubCode,
            Comments:this.comments,
            EndUserAddressStreet:this.endUserAddressStreet,
            EndUserAddressCity:this.endUserAddressCity,
            EndUserAddressState:this.endUserAddressState,
            EndUserAddressPostalCode:this.endUserAddressPostalCode,
            EndUserAddressCountry:this.endUserAddressCountry,
            EndUserName:this.endUserName,
            EndUserPhone:this.endUserPhone,
            EndUserEmail:this.endUserEmail,
            SiteName:this.siteName
        };
        this.template.querySelector("c-warrant-claim-child-l-w-c").setConfirmValues(inputData);
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

    handleSitePhoneChange(event){
        const myValue = this.template.querySelector(".eup");
        console.log('Phone Number being entered: '+myValue);

        const formattedNumber = this.formatPhoneNumber(myValue.value);        
        this.endUserPhone = formattedNumber;
    }

    convertPhone(phone){
        var cleaned = ('' + phone).replace(/\D/g, '');
        var match = cleaned.match(/^(\d{3})(\d{3})(\d{4})$/);
        if (match) {
          this.reqPhone = '(' + match[1] + ') ' + match[2] + '-' + match[3];
        }
        return null;
    }

    async getCaseOwner(){

        if(this.userType == "Agent"){
            this.setAccountID = this.caseAccountId;
            await getWarrantyQueueId({accountId : this.setAccountID, userType : this.userType})
            .then(result=>{
                    if(result){
                        this.caseOwnerId = result;
                        console.log('SETTING CASE QUEUE BASED ON AGENT....'+this.caseOwnerId);
                    } 
                })
        } else {
            if(this.orderAgent != null){
                this.setAccountID = this.orderAgent;
                await getWarrantyQueueId({accountId : this.setAccountID, userType : this.userType})
                .then(result=>{
                        if(result){
                            this.caseOwnerId = result;
                            console.log('SETTING CASE QUEUE BASED ON ORDER AGENT....'+this.caseOwnerId);
                        } 
                    })
            } else {
                await getWarrantyQueueId({accountId : null, distributorId : this.caseSoldToId, userType : this.userType})
                .then(result=>{
                        if(result){
                            this.caseOwnerId = result;
                            console.log('SETTING CASE QUEUE BASED ON ORDER AGENT....'+this.caseOwnerId);
                        } 
                    })
            }
        }
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